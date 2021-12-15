defmodule Day15.ChitonMap do
  defstruct map: %{}, dimensions: {0, 0}, scale: 1

  @doc """
  Parse puzzle input to generate a map from locations to Chiton risk level.
  """
  def parse(input) do
    {map, {y_max, x_max}} =
      for {line, y} <- String.split(input, "\n", trim: true) |> Enum.with_index(),
          {num, x} <- String.to_charlist(line) |> Enum.with_index(),
          reduce: {%{}, {0, 0}} do
        {map, _} -> {Map.put(map, {y, x}, num - ?0), {y, x}}
      end

    %__MODULE__{map: map, dimensions: {y_max + 1, x_max + 1}}
  end

  @doc """
  Allows to get out of bounds to the right and bottom, using the expansion
  rules of part 2 of the puzzle.
  """
  def risk_at(%{map: map, dimensions: {h, w}}, {y, x}) do
    raw_value = map[{rem(y, h), rem(x, w)}] + div(y, h) + div(x, w)

    rem(raw_value - 1, 9) + 1
  end

  def scale(%__MODULE__{} = map, scale) do
    %{map | scale: scale}
  end

  def neighbors(%{scale: scale, dimensions: {h, w}}, {y, x}) do
    [{y - 1, x}, {y + 1, x}, {y, x - 1}, {y, x + 1}]
    |> Enum.filter(fn {y, x} -> x >= 0 and x < w * scale and y >= 0 and y < h * scale end)
  end
end

defmodule Day15.Exploration do
  alias Day15.ChitonMap

  defstruct exploration: %{{0, 0} => 0}, visited: MapSet.new()

  @doc """
  Take an exploration step.
  """
  def explore(%__MODULE__{exploration: exploration, visited: visited} = state, map) do
    # Next point to visit is the unvisited point with the least accumulated risk
    {next_point, _} = Enum.min_by(exploration, fn {_, risk} -> risk end)

    # Calculate risk to reach neighbors going through the point we're visiting
    neighbor_risks =
      ChitonMap.neighbors(map, next_point)
      |> Enum.reject(fn pos -> MapSet.member?(visited, pos) end)
      |> Enum.map(fn pos ->
        {pos, exploration[next_point] + ChitonMap.risk_at(map, pos)}
      end)

    # Mark point as visited
    exploration = Map.delete(exploration, next_point)
    visited = MapSet.put(visited, next_point)

    # Update exploration map with new best risks for neighbors
    exploration =
      Enum.reduce(neighbor_risks, exploration, fn {point, risk}, exp ->
        Map.update(exp, point, risk, fn old_risk ->
          if risk < old_risk, do: risk, else: old_risk
        end)
      end)

    %{state | exploration: exploration, visited: visited}
  end

  def explore(%ChitonMap{} = map) do
    explore(%__MODULE__{}, map)
  end

  @doc """
  Explore until we reach the target with minimum risk
  """
  def find_min_risk(map, target) do
    Stream.iterate(%__MODULE__{}, &explore(&1, map))
    |> Enum.find_value(fn
      %{exploration: %{^target => risk}} -> risk
      _ -> nil
    end)
  end
end

defmodule Day15 do
  alias Day15.{ChitonMap, Exploration}

  def solve_part1(input) do
    %{dimensions: {y_max, x_max}} = map = ChitonMap.parse(input)

    target = {y_max - 1, x_max - 1}
    Exploration.find_min_risk(map, target)
  end

  def solve_part2(input) do
    %{dimensions: {y_max, x_max}} = map = ChitonMap.parse(input) |> ChitonMap.scale(5)

    target = {5 * y_max - 1, 5 * x_max - 1}
    Exploration.find_min_risk(map, target)
  end
end
