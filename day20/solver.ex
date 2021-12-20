defmodule Day20.Image do
  def lit_pixels(%{} = im) do
    Enum.count(im, fn {_, val} -> val == <<1::1>> end)
  end

  def index_at(%{} = im, {y, x}, default \\ <<0::1>>) do
    <<idx::9>> =
      for j <- (y - 1)..(y + 1),
          i <- (x - 1)..(x + 1),
          into: <<>> do
        Map.get(im, {j, i}, default)
      end

    idx
  end

  def enhance(im, _algorithm, 0), do: im
  def enhance(im, algorithm, 1), do: enhance_once(im, algorithm)

  def enhance(im, algorithm, times) do
    im
    |> enhance_twice(algorithm)
    |> enhance(algorithm, times - 2)
  end

  def enhance_twice(%{} = im, algorithm) do
    im
    |> enhance_once(algorithm)
    |> enhance_once(algorithm, algorithm[0])
  end

  defp enhance_once(%{} = im, algorithm, default \\ <<0::1>>) do
    {{y_min, x_min}, {y_max, x_max}} = Map.keys(im) |> Enum.min_max()

    padding = 2

    for y <- (y_min - padding)..(y_max + padding),
        x <- (x_min - padding)..(x_max + padding),
        reduce: %{} do
      acc ->
        Map.put(acc, {y, x}, algorithm[index_at(im, {y, x}, default)])
    end
  end
end

defmodule Day20 do
  alias Day20.Image

  def parse_input(input) do
    [algorithm_string, im_string] = String.split(input, "\n\n")

    algorithm =
      algorithm_string
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {c, idx}, acc -> Map.put(acc, idx, char_to_bit(c)) end)

    image =
      for {line, y} <- String.split(im_string, "\n", trim: true) |> Enum.with_index(),
          {char, x} <- String.to_charlist(line) |> Enum.with_index(),
          reduce: %{} do
        acc -> Map.put(acc, {y, x}, char_to_bit(char))
      end

    {algorithm, image}
  end

  defp char_to_bit(?\#), do: <<1::1>>
  defp char_to_bit(?.), do: <<0::1>>

  def solve_part1(algorithm, image) do
    Image.enhance(image, algorithm, 2) |> Image.lit_pixels()
  end

  def solve_part2(algorithm, image) do
    Image.enhance(image, algorithm, 50) |> Image.lit_pixels()
  end
end
