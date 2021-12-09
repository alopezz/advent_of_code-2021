package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
)

type Heightmap struct {
	heights map[Location]int
	nRows   int
	nCols   int
}

type Location struct {
	Y, X int
}

func NewHeightmap() Heightmap {
	return Heightmap{
		heights: make(map[Location]int),
		nRows:   0,
		nCols:   0,
	}
}

func (h *Heightmap) AddRow(row string) {
	rowN := h.nRows
	for colN, c := range row {
		h.heights[Location{rowN, colN}], _ = strconv.Atoi(string(c))
		if colN >= h.nCols {
			h.nCols = colN + 1
		}
	}
	h.nRows++
}

func (h Heightmap) At(y int, x int) int {
	value, found := h.heights[Location{y, x}]
	if found {
		return value
	} else {
		return -1
	}
}

func (h Heightmap) neighbourLocations(y int, x int) []Location {
	neighbours := make([]Location, 0, 4)

	candidateNeighbours := []Location{
		Location{y - 1, x},
		Location{y, x - 1},
		Location{y + 1, x},
		Location{y, x + 1},
	}

	for _, loc := range candidateNeighbours {
		if h.At(loc.Y, loc.X) >= 0 {
			neighbours = append(neighbours, loc)
		}
	}
	return neighbours
}

func (h Heightmap) neighbourHeights(y int, x int) []int {
	locs := h.neighbourLocations(y, x)
	neighbours := make([]int, len(locs))
	for idx, loc := range h.neighbourLocations(y, x) {
		neighbours[idx] = h.At(loc.Y, loc.X)
	}

	return neighbours
}

func (h Heightmap) isLowPoint(y int, x int) bool {
	self := h.At(y, x)
	for _, n := range h.neighbourHeights(y, x) {
		if n <= self {
			return false
		}
	}
	return true
}

func (h Heightmap) RiskLevelAt(y int, x int) int {
	if h.isLowPoint(y, x) {
		return h.At(y, x) + 1
	} else {
		return 0
	}
}

// Modifies the basinPoints 'set' by exploring the neighbourhood
func (h Heightmap) exploreBasin(basinPoints map[Location]bool, y int, x int) {
	for _, n := range h.neighbourLocations(y, x) {
		neighbourHeight := h.At(n.Y, n.X)
		if neighbourHeight == 9 {
			continue
		}
		_, exists := basinPoints[n]
		if !exists {
			basinPoints[n] = true
			h.exploreBasin(basinPoints, n.Y, n.X)
		}
	}
}

func (h Heightmap) BasinSizeAt(y int, x int) int {
	// Only calculate basins for actual low points
	if !h.isLowPoint(y, x) {
		return 1
	}

	basinPoints := make(map[Location]bool)
	h.exploreBasin(basinPoints, y, x)

	return len(basinPoints)
}

func SolvePart1(h Heightmap) int {
	sum := 0
	for row := 0; row < h.nRows; row++ {
		for col := 0; col < h.nCols; col++ {
			sum += h.RiskLevelAt(row, col)
		}
	}
	return sum
}

func SolvePart2(h Heightmap) int {
	basinSizes := []int{}
	for row := 0; row < h.nRows; row++ {
		for col := 0; col < h.nCols; col++ {
			basinSizes = append(basinSizes, h.BasinSizeAt(row, col))
		}
	}

	sort.Ints(basinSizes)
	nBasins := len(basinSizes)
	return basinSizes[nBasins-1] * basinSizes[nBasins-2] * basinSizes[nBasins-3]
}

func readHeightmap(filename string) Heightmap {
	h := NewHeightmap()

	f, _ := os.Open(filename)
	defer f.Close()

	scanner := bufio.NewScanner(f)

	for scanner.Scan() {
		h.AddRow(scanner.Text())
	}

	return h
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: day09 FILE")
		return
	}
	h := readHeightmap(os.Args[1])
	fmt.Println(SolvePart1(h))
	fmt.Println(SolvePart2(h))
}
