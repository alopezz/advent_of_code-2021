package main

import (
	"testing"
)

func makeExampleMap() Heightmap {
	hm := NewHeightmap()

	hm.AddRow("2199943210")
	hm.AddRow("3987894921")
	hm.AddRow("9856789892")
	hm.AddRow("8767896789")
	hm.AddRow("9899965678")

	return hm
}

func TestHeightmapCreationAndAccess(t *testing.T) {
	hm := makeExampleMap()

	testCases := [][]int{
		{0, 1, 1},
		{3, 6, 6},
		// Out of bounds
		{9, 0, -1},
		{-1, 3, -1},
	}

	for _, testCase := range testCases {
		res := hm.At(testCase[0], testCase[1])
		exp := testCase[2]
		if res != exp {
			t.Errorf("Expected %d, got %d instead.\n", exp, res)
		}
	}
}

func slicesAreEqual(a []int, b []int) bool {
	for idx := range a {
		if a[idx] != b[idx] {
			return false
		}
	}
	return true
}

func TestNeighbourHeights(t *testing.T) {
	hm := makeExampleMap()

	testInputs := [][]int{
		{0, 1},
		{3, 6},
	}

	testExpectations := [][]int{
		{2, 9, 9},
		{9, 9, 5, 7},
	}

	for testIdx, testInput := range testInputs {
		res := hm.neighbourHeights(testInput[0], testInput[1])
		exp := testExpectations[testIdx]
		if !slicesAreEqual(res, exp) {
			t.Errorf("Expected %#v, got %#v instead.\n", exp, res)
		}
	}
}

func TestRiskLevelAt(t *testing.T) {
	hm := makeExampleMap()

	testCases := [][]int{
		{0, 1, 2},
		{2, 2, 6},
		{0, 9, 1},
		{5, 3, 0},
	}

	for _, testCase := range testCases {
		res := hm.RiskLevelAt(testCase[0], testCase[1])
		exp := testCase[2]
		if res != exp {
			t.Errorf("Expected %d, got %d instead.\n", exp, res)
		}
	}
}

func TestSolvePart1(t *testing.T) {
	hm := makeExampleMap()

	exp := 15
	res := SolvePart1(hm)
	if exp != res {
		t.Errorf("Expected %d, got %d instead.\n", exp, res)
	}
}

func TestBasinSizeAt(t *testing.T) {
	hm := makeExampleMap()

	testCases := [][]int{
		{0, 1, 3},
		{0, 9, 9},
		{2, 2, 14},
	}

	for _, testCase := range testCases {
		res := hm.BasinSizeAt(testCase[0], testCase[1])
		exp := testCase[2]
		if res != exp {
			t.Errorf("Expected %d, got %d instead.\n", exp, res)
		}
	}
}

func TestSolvePart2(t *testing.T) {
	hm := makeExampleMap()

	exp := 1134
	res := SolvePart2(hm)
	if exp != res {
		t.Errorf("Expected %d, got %d instead.\n", exp, res)
	}
}
