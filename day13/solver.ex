defmodule Day13.Paper do
  defstruct dots: MapSet.new(), folds_left: []

  @doc """
  Get a Paper struct from a string representation (a.k.a. puzzle input)
  """
  def parse(string) do
    [dots_input, folds_input] = String.split(string, "\n\n")
    %__MODULE__{
      dots: parse_dots(dots_input),
      folds_left: parse_folds(folds_input)
    }
  end

  defp parse_dots(string) do
    string
    |> String.split("\n")
    |> Enum.map(fn line ->
      String.split(line, ",")
      |> Enum.map(&String.to_integer/1)
      |> then(fn [x, y] -> %{"x" => x, "y" => y} end)
    end)
    |> MapSet.new()
  end

  defp parse_folds(string) do
    string
    |> String.split("\n")
    |> Enum.map(fn line ->
      Regex.run(~r/([xy])=(\d+)/, line, capture: :all_but_first)
      |> List.to_tuple
      |> then(fn {d, num} -> {d, String.to_integer(num)} end)
      end)
  end

  @doc """
  Fold paper according to the next instruction
  """
  def fold(%{folds_left: []} = paper), do: paper

  def fold(%{dots: dots, folds_left: folds_left}) do
    [next_fold | folds_left] = folds_left

    %__MODULE__{dots: fold(next_fold, dots), folds_left: folds_left}
  end

  defp fold({axis, place}, dots) do
    {before_fold, after_fold} = Enum.split_with(dots, fn %{^axis => pos} -> pos < place end)

    fold_dot = fn %{^axis => pos} = loc -> %{loc | axis => 2*place - pos} end
    folded = Enum.map(after_fold, fold_dot)

    MapSet.union(MapSet.new(before_fold), MapSet.new(folded))
  end

  @doc """
  Fold the paper until all instructions are consumed.
  """
  def fold_all(%{dots: dots, folds_left: folds_left}) do
    %__MODULE__{dots: Enum.reduce(folds_left, dots, &fold/2), folds_left: []}
  end

  @doc """
  Generate a visual representation of the paper as a string.
  """
  def render(%{dots: dots}) do
    {min_x, max_x} = Enum.min_max(Enum.map(dots, fn %{"x" => x} -> x end))
    {min_y, max_y} = Enum.min_max(Enum.map(dots, fn %{"y" => y} -> y end))

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        if %{"x" => x, "y" => y} in dots, do: ?\#, else: ?\s
      end
      |> to_string()
    end
    |> Enum.join("\n")
    |> then(&(&1 <> "\n"))
  end

  @doc """
  Count the number of visible dots in the paper.
  """
  def visible_dots(%{dots: dots}), do: Enum.count(dots)
end
