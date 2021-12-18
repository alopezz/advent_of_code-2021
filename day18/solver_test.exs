ExUnit.start()

defmodule Day18.Test do
  use ExUnit.Case, async: true

  alias Day18.SnailfishMath

  def assert_step(input, expected) do
    {_, result} = SnailfishMath.step(input)
    assert expected == result
  end

  test "explode actions examples" do
    assert_step([[[[[9, 8], 1], 2], 3], 4], [[[[0, 9], 2], 3], 4])
    assert_step([7, [6, [5, [4, [3, 2]]]]], [7, [6, [5, [7, 0]]]])
    assert_step([[6, [5, [4, [3, 2]]]], 1], [[6, [5, [7, 0]]], 3])

    assert_step([[3, [2, [1, [7, 3]]]], [6, [5, [4, [3, 2]]]]], [
      [3, [2, [8, 0]]],
      [9, [5, [4, [3, 2]]]]
    ])

    assert_step([[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]], [
      [3, [2, [8, 0]]],
      [9, [5, [7, 0]]]
    ])

    assert_step(
      [
        [[[0, [4, 5]], [0, 0]], [[[4, 5], [2, 6]], [9, 5]]],
        [7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]]
      ],
      [
        [[[4, 0], [5, 0]], [[[4, 5], [2, 6]], [9, 5]]],
        [7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]]
      ]
    )

    assert_step(
      [
        [[[4, 0], [5, 0]], [[[4, 5], [2, 6]], [9, 5]]],
        [7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]]
      ],
      [
        [[[4, 0], [5, 4]], [[0, [7, 6]], [9, 5]]],
        [7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]]
      ]
    )
  end

  test "split action example" do
    assert_step([[[[0, 7], 4], [15, [0, 13]]], [1, 1]], [
      [[[0, 7], 4], [[7, 8], [0, 13]]],
      [1, 1]
    ])
  end

  test "reduce example" do
    assert SnailfishMath.reduce([[[[[4, 3], 4], 4], [7, [[8, 4], 9]]], [1, 1]]) == [
             [[[0, 7], 4], [[7, 8], [6, 0]]],
             [8, 1]
           ]
  end

  test "magnitude" do
    assert SnailfishMath.magnitude([[1, 2], [[3, 4], 5]]) == 143

    assert SnailfishMath.magnitude([
             [[[8, 7], [7, 7]], [[8, 6], [7, 7]]],
             [[[0, 7], [6, 6]], [8, 7]]
           ]) ==
             3488
  end

  test "parse_input" do
    input = """
    [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
    [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
    [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
    """

    result = Day18.parse_input(input)

    assert result == [
             [[[0, [4, 5]], [0, 0]], [[[4, 5], [2, 6]], [9, 5]]],
             [7, [[[3, 7], [4, 3]], [[6, 3], [8, 8]]]],
             [[2, [[0, 8], [3, 4]]], [[[6, 7], 1], [7, [1, 6]]]]
           ]
  end

  test "solve part 1 on example input" do
    {magnitude, number} = File.read!("example") |> Day18.parse_input() |> Day18.solve_part1()

    assert number == [[[[6, 6], [7, 6]], [[7, 7], [7, 0]]], [[[7, 7], [7, 7]], [[7, 8], [9, 9]]]]
    assert magnitude == 4140
  end

  test "solve part 1 on puzzle input" do
    {magnitude, _number} = File.read!("input") |> Day18.parse_input() |> Day18.solve_part1()

    assert magnitude == 4008
  end

  test "solve part 2 on example input" do
    result = File.read!("example") |> Day18.parse_input() |> Day18.solve_part2()

    assert result == 3993
  end

  test "solve part 2 on puzzle input" do
    result = File.read!("input") |> Day18.parse_input() |> Day18.solve_part2()

    assert result == 4667
  end
end
