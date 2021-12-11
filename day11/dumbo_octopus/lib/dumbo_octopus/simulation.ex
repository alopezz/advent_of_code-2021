defmodule DumboOctopus.Simulation do
  @moduledoc """
  Implements the rules of the puzzle.
  """

  @doc """
  Parse puzzle input into a map of locations to energy level
  """
  def parse_input(input) do
    for {row, i} <- String.split(input, "\n") |> Enum.with_index(),
        {number, j} <- String.trim(row) |> String.to_charlist() |> Enum.with_index(),
        into: %{} do
      {{i, j}, number - ?0}
    end
  end

  @doc """
  Advances one step in the simulation.
  """
  def step(sim) do
    Enum.reduce(Map.keys(sim), sim, &propagate/2)
    |> Enum.map(fn
      {key, 10} -> {key, 0}
      other -> other
    end)
    |> Enum.into(%{})
  end

  def step(sim, steps) when steps <= 0 do
    sim
  end

  def step(sim, steps) do
    Stream.iterate(sim, &step/1) |> Enum.at(steps)
  end

  @doc """
  Advances in the simulation keeping also a count of the number of 
  flashes. Returns {simulation_result, number_of_flashes}
  """
  def step_with_count({sim, count}) do
    new_sim = step(sim)
    {new_sim, count + count_flashes(new_sim)}
  end

  def step_with_count(sim) do
    step_with_count({sim, 0})
  end

  def step_with_count(sim, steps) when steps <= 0 do
    {sim, 0}
  end

  def step_with_count(sim, steps) do
    Stream.iterate(sim, &step_with_count/1) |> Enum.at(steps)
  end

  defp count_flashes(sim) do
    Enum.count(sim, fn {_, val} -> val == 0 end)
  end

  @doc """
  Find first iteration where all octopi flash simultaneously
  """
  def find_sync(sim) do
    Stream.iterate(sim, &step/1) |> Enum.find_index(&all_flash/1)
  end

  def all_flash(sim) do
    Enum.all?(sim, fn {_, val} -> val == 0 end)
  end

  @doc """
  Trigger a propagation on location `loc` for simulation state `sim`.
  The order of the arguments makes it more convenient to use as a function
  to apply as a reducing functions over a list of locations.
  """
  def propagate(loc, sim) do
    case sim[loc] do
      # Those at max energy flash and trigger a propagation
      # to all neighbours
      9 ->
        neighbours(sim, loc)
        |> Enum.filter(fn loc -> sim[loc] != 100 end)
        |> Enum.reduce(
          Map.put(sim, loc, 10),
          &propagate/2
        )

      # Those who have already flashed on this turn are skipped
      10 ->
        sim

      # For the rest, they simply increase their energy level by one
      val ->
        Map.put(sim, loc, val + 1)
    end
  end

  def neighbours(sim, {y, x} = loc) do
    for y <- (y - 1)..(y + 1),
        x <- (x - 1)..(x + 1),
        Map.has_key?(sim, {y, x}),
        {y, x} != loc do
      {y, x}
    end
  end

  @doc """
  Returns the energy levels of the octopi as a list of lists (rows).
  """
  def octopi_values(sim) do
    {h, w} = dimensions(sim)

    for row <- 0..(h - 1) do
      for column <- 0..(w - 1) do
        sim[{row, column}]
      end
    end
  end

  defp dimensions(sim) when sim == %{} do
    {0, 0}
  end

  defp dimensions(sim) do
    Map.keys(sim)
    |> Enum.unzip()
    |> then(fn {ys, xs} -> {Enum.max(ys) + 1, Enum.max(xs) + 1} end)
  end
end
