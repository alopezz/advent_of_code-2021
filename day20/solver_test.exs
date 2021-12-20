ExUnit.start()

defmodule Day20.Test do
  use ExUnit.Case, async: true

  alias Day20.Image

  test "parse input" do
    {algorithm, image} = Day20.parse_input(example())

    assert Enum.count(algorithm) == 512

    assert match?(
             %{0 => <<0::1>>, 511 => <<1::1>>},
             algorithm
           )

    assert Image.lit_pixels(image) == 10
  end

  test "image index at" do
    {_, image} = Day20.parse_input(example())

    assert Image.index_at(image, {2, 2}) == 34
  end

  test "solve part 1, example" do
    {algorithm, image} = Day20.parse_input(example())

    assert Day20.solve_part1(algorithm, image) == 35
  end

  test "solve part 1, puzzle input" do
    {algorithm, image} = Day20.parse_input(puzzle_input())

    assert Day20.solve_part1(algorithm, image) == 5179
  end

  test "solve part 2, example" do
    {algorithm, image} = Day20.parse_input(example())

    assert Day20.solve_part2(algorithm, image) == 3351
  end

  test "solve part 2, puzzle input" do
    {algorithm, image} = Day20.parse_input(puzzle_input())

    assert Day20.solve_part2(algorithm, image) == 16112
  end

  def example() do
    File.read!("example")
  end

  def puzzle_input() do
    File.read!("input")
  end
end
