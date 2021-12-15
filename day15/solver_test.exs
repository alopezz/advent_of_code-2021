ExUnit.start()

defmodule Day15.Test do
  use ExUnit.Case

  alias Day15.{ChitonMap, Exploration}

  test "parse" do
    %{map: map, dimensions: dims} = ChitonMap.parse(example())

    assert map[{3, 1}] == 6
    assert map[{9, 9}] == 1
    assert dims == {10, 10}
  end

  test "risk_at" do
    map = ChitonMap.parse(example())

    assert ChitonMap.risk_at(map, {10, 0}) == 2
    assert ChitonMap.risk_at(map, {10, 10}) == 3
    assert ChitonMap.risk_at(map, {10 * 5 - 1, 10 * 5 - 1}) == 9
  end

  test "explore" do
    map = ChitonMap.parse(example())

    state = Exploration.explore(map)

    assert count_visited(state) == 1
    assert state.exploration[{1, 0}] == 1
    assert state.exploration[{0, 1}] == 1

    state = Exploration.explore(state, map)
    state = Exploration.explore(state, map)

    assert count_visited(state) == 3
  end

  test "find_min_risk with example (solve part 1)" do
    assert Day15.solve_part1(example()) == 40
  end

  test "solve part 1" do
    assert Day15.solve_part1(puzzle_input()) == 589
  end

  test "find_min_risk with example (solve part 2)" do
    assert Day15.solve_part2(example()) == 315
  end

  test "solve part 2" do
    assert Day15.solve_part2(puzzle_input()) == 2885
  end

  def count_visited(%{visited: visited}) do
    Enum.count(visited)
  end

  def puzzle_input() do
    File.read!("input")
  end

  def example() do
    """
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
    """
  end
end
