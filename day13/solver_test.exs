ExUnit.start()

defmodule Day13.PaperTest do
  use ExUnit.Case
  alias Day13.Paper

  test "parse" do
    result = load_input("example") |> Paper.parse()

    assert %{"x" => 0, "y" => 14} in result.dots
    assert %{"x" => 3, "y" => 4} in result.dots
    assert result.folds_left == [{"y", 7}, {"x", 5}]
  end

  test "fold" do
    result = load_input("example") |> Paper.parse() |> Paper.fold()

    assert %{"x" => 0, "y" => 0} in result.dots
    assert %{"x" => 0, "y" => 1} in result.dots
    assert %{"x" => 1, "y" => 1} not in result.dots

    assert result.folds_left == [{"x", 5}]

    assert result |> Paper.visible_dots() == 17
  end

  test "puzzle part 1" do
    result = load_input("input")
    |> Paper.parse()
    |> Paper.fold()
    |> Paper.visible_dots()

    assert result == 747
  end

  test "fold_all and render" do
    result = load_input("example") |> Paper.parse() |> Paper.fold_all()

    assert %{"x" => 0, "y" => 0} in result.dots
    assert %{"x" => 0, "y" => 1} in result.dots
    assert %{"x" => 1, "y" => 1} not in result.dots

    assert Paper.render(result) == """
    #####
    #   #
    #   #
    #   #
    #####
    """
  end

  def load_input(input) do
    File.read!(input)
  end
end

# Solution to part 2 is better found by visual inspection of the result :)
alias Day13.Paper
IO.puts("\nThe answer to part 2 of the puzzle is:\n")
Day13.PaperTest.load_input("input")
|> Paper.parse()
|> Paper.fold_all()
|> Paper.render()
|> IO.puts()
