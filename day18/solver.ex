defmodule Day18.SnailfishMath do
  @moduledoc """
  Operate on Snailfish numbers.

  Snailfish numbers are represented as recursively nested lists
  (pairs).
  """

  @doc """
  Reduce number until no actions can be taken
  """
  def reduce([_left, _right] = number) do
    Stream.iterate({:cont, number}, fn {_flag, num} -> step(num) end)
    |> Enum.find_value(fn
      {:halt, result} -> result
      _ -> false
    end)
  end

  def reduce(lst) do
    # If the list is not a pair, reduce the list in pairs and accumulate
    Enum.reduce(lst, fn a, b -> reduce([b, a]) end)
  end

  @doc """
  Magnitude of a shellfish number
  """
  def magnitude([left, right]) do
    3 * magnitude(left) + 2 * magnitude(right)
  end

  def magnitude(number), do: number

  @doc """
  Execute a reducing step
  """
  def step(number) do
    with {number, nil} <- try_explode(number, 0),
         {number, false} <- try_split(number) do
      {:halt, number}
    else
      {number, _} -> {:cont, number}
    end
  end

  # Exploding happens when we have
  # - at least 4 levels of nesting
  # - both members of the pair are regular numbers
  defp try_explode([left, right], depth)
       when depth >= 4 and is_number(left) and is_number(right) do
    {0, {left, right}}
  end

  defp try_explode([left, right], depth) do
    with {:left, {_, nil}} <- {:left, try_explode(left, depth + 1)},
         {:right, {_, nil}} <- {:right, try_explode(right, depth + 1)} do
      # No explosion, return unchanged
      {[left, right], nil}
    else
      # First 2 cases: explosion happened, but can't propagate from here
      {:left, {new_left, {_, nil} = explosion}} ->
        {[new_left, right], explosion}

      {:right, {new_right, {nil, _} = explosion}} ->
        {[left, new_right], explosion}

      # Next 2 cases: An explosion happened that can be propagated downward from here
      {:left, {new_left, {left_explosion, right_explosion}}} ->
        new_right = propagate_explosion(right, right_explosion, :left)
        {[new_left, new_right], {left_explosion, nil}}

      {:right, {new_right, {left_explosion, right_explosion}}} ->
        new_left = propagate_explosion(left, left_explosion, :right)
        {[new_left, new_right], {nil, right_explosion}}
    end
  end

  defp try_explode(number, _depth) when is_number(number) do
    {number, nil}
  end

  defp propagate_explosion([left, right], explode_number, :left) do
    [propagate_explosion(left, explode_number, :left), right]
  end

  defp propagate_explosion([left, right], explode_number, :right) do
    [left, propagate_explosion(right, explode_number, :right)]
  end

  defp propagate_explosion(number, explode_number, _) do
    number + explode_number
  end

  defp try_split([left, right]) do
    with {:left, {_, false}} <- {:left, try_split(left)},
         {:right, {_, false}} <- {:right, try_split(right)} do
      {[left, right], false}
    else
      {:left, {new_left, true}} -> {[new_left, right], true}
      {:right, {new_right, true}} -> {[left, new_right], true}
    end
  end

  defp try_split(number) when is_number(number) and number >= 10 do
    half = number / 2
    {[floor(half), ceil(half)], true}
  end

  defp try_split(number) when is_number(number) do
    {number, false}
  end
end

defmodule Day18 do
  alias Day18.SnailfishMath

  def parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&Code.eval_string/1)
    |> Enum.map(fn {result, _} -> result end)
  end

  def solve_part1(numbers) do
    final_number = SnailfishMath.reduce(numbers)
    {SnailfishMath.magnitude(final_number), final_number}
  end

  def solve_part2(numbers) do
    # Compute the magnitude of adding all possible combinations
    # (in both orders, because snailfish addition is not commutative)
    for a <- numbers, b <- numbers, a != b do
      SnailfishMath.reduce([a, b]) |> SnailfishMath.magnitude()
    end
    |> Enum.max()
  end
end
