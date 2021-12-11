defmodule DumboOctopus.SimulationTest do
  use ExUnit.Case, async: true

  alias DumboOctopus.Simulation

  test "input is parsed correctly" do
    locations = Simulation.parse_input(example_input())
    assert Enum.count(locations) == 10 * 10
    assert locations[{0, 2}] == 8
    assert locations[{5, 5}] == 2
    assert locations[{9, 9}] == 6
  end

  test "neighbours" do
    sim = Simulation.parse_input(example_input())
    assert Simulation.neighbours(sim, {0, 0}) == [{0, 1}, {1, 0}, {1, 1}]

    assert Simulation.neighbours(sim, {5, 5}) == [
             {4, 4},
             {4, 5},
             {4, 6},
             {5, 4},
             {5, 6},
             {6, 4},
             {6, 5},
             {6, 6}
           ]

    assert Simulation.neighbours(sim, {9, 8}) == [{8, 7}, {8, 8}, {8, 9}, {9, 7}, {9, 9}]
  end

  test "octopi_values" do
    sim = Simulation.parse_input(example_input())

    values = Simulation.octopi_values(sim)

    assert Enum.count(values) == 10

    assert Enum.take(values, 2) == [
             [5, 4, 8, 3, 1, 4, 3, 2, 2, 3],
             [2, 7, 4, 5, 8, 5, 4, 7, 1, 1]
           ]
  end

  test "propagate" do
    sim = Simulation.parse_input(example_input())

    result = Simulation.propagate({1, 1}, sim)
    assert result[{1, 1}] == 8

    sim =
      Simulation.parse_input("""
      11111
      19991
      19191
      19991
      11111
      """)

    result = Simulation.propagate({1, 1}, sim)
    assert result[{1, 1}] == 10
    assert result[{0, 0}] == 2
    assert result[{0, 1}] == 3
    assert result[{1, 0}] == 3
    assert result[{2, 0}] == 4
  end

  test "step" do
    sim =
      Simulation.parse_input("""
      11111
      19991
      19191
      19991
      11111
      """)

    assert Simulation.step(sim) |> Simulation.octopi_values() == [
             [3, 4, 5, 4, 3],
             [4, 0, 0, 0, 4],
             [5, 0, 0, 0, 5],
             [4, 0, 0, 0, 4],
             [3, 4, 5, 4, 3]
           ]

    assert Simulation.step(sim, 2) |> Simulation.octopi_values() == [
             [4, 5, 6, 5, 4],
             [5, 1, 1, 1, 5],
             [6, 1, 1, 1, 6],
             [5, 1, 1, 1, 5],
             [4, 5, 6, 5, 4]
           ]

    assert Simulation.step(sim, 0) == sim
  end

  test "step_with_count, example input" do
    sim = Simulation.parse_input(example_input())

    {after_sim, flashes} = Simulation.step_with_count(sim, 100)

    assert after_sim == Simulation.step(sim, 100)
    assert flashes == 1656
  end

  test "step_with_count, puzzle input" do
    sim = Simulation.parse_input(puzzle_input())

    {after_sim, flashes} = Simulation.step_with_count(sim, 100)

    assert after_sim == Simulation.step(sim, 100)
    assert flashes == 1686
  end

  test "find_sync, example_input" do
    sim = Simulation.parse_input(example_input())

    assert Simulation.find_sync(sim) == 195
  end

  test "find_sync, test_input" do
    sim = Simulation.parse_input(puzzle_input())

    assert Simulation.find_sync(sim) == 360
  end

  defp example_input do
    """
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """
  end

  defp puzzle_input do
    """
    4658137637
    3277874355
    4525611183
    3128125888
    8734832838
    4175463257
    8321423552
    4832145253
    8286834851
    4885323138
    """
  end
end
