"""
--- Day 22: Reactor Reboot ---
"""

import itertools
import re
import unittest

from collections import namedtuple


RebootStep = namedtuple("RebootStep", ["on", "x", "y", "z"])
Bound = namedtuple("Bound", ["min", "max"])


def parse_input(string):
    return [parse_line(line) for line in string.splitlines()]


def parse_line(line):
    [on_off, coord_str] = line.split()
    on_off = on_off == "on"

    numbers = (
        re.search(
            r"x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)",
            coord_str)
    ).groups()

    x_min, x_max, y_min, y_max, z_min, z_max = [int(n) for n in numbers]

    return RebootStep(
        on_off,
        Bound(x_min, x_max),
        Bound(y_min, y_max),
        Bound(z_min, z_max)
    )


def count_on(steps, bound=None):
    rev_steps = list(reversed(steps))

    x_grid = make_grid(steps, 'x', bound)
    y_grid = make_grid(steps, 'y', bound)
    z_grid = make_grid(steps, 'z', bound)

    count = 0

    for x, y, z in itertools.product(x_grid, y_grid, z_grid):
        volume = calculate_volume(x, y, z)
        for step in rev_steps:
            if is_contained(step, x, y, z):
                count += volume * step.on
                break

    return count    


def count_on_init(steps):
    return count_on(steps, 50)


def make_grid(steps, attr, bound=None):
    edges = (
        {getattr(s, attr).min for s in steps} |
        # For upper bounds the edge is *after* the bound
        {getattr(s, attr).max + 1 for s in steps}
    )

    if bound is not None:
        edges = {p for p in edges if -bound <= p <= bound + 1}

    edges = sorted(edges)
    
    return zip(edges, edges[1:])


def calculate_volume(x, y, z):
    return (x[1] - x[0]) * (y[1] - y[0]) * (z[1] - z[0])


def is_contained(step, x, y, z):
    return (
        step.x.min <= x[0] <= step.x.max and
        step.y.min <= y[0] <= step.y.max and
        step.z.min <= z[0] <= step.z.max
    )


class TestDay22(unittest.TestCase):
    SAMPLE_INPUT = """on x=10..12,y=10..12,z=10..12
on x=11..13,y=11..13,z=11..13
off x=9..11,y=9..11,z=9..11
on x=10..10,y=10..10,z=10..10
"""

    def test_parse_input(self):
        expected = [
            (True, (10, 12), (10, 12), (10, 12)),
            (True, (11, 13), (11, 13), (11, 13)),
            (False, (9, 11), (9, 11), (9, 11)),
            (True, (10, 10), (10, 10), (10, 10)),
        ]
        result = parse_input(self.SAMPLE_INPUT)

        self.assertEqual(result, expected)

    def test_count_on(self):
        steps = parse_input(self.SAMPLE_INPUT)

        result = count_on_init(steps)

        self.assertEqual(result, 39)

    def test_solve_part1_example(self):
        with open("example") as f:
            example = f.read()

        steps = parse_input(example)

        result = count_on_init(steps)

        self.assertEqual(result, 590784)

    def test_solve_part1_input(self):
        with open("input") as f:
            example = f.read()

        steps = parse_input(example)

        result = count_on_init(steps)

        self.assertEqual(result, 611176)

    def test_solve_part2_example(self):
        with open("example2") as f:
            example = f.read()

        steps = parse_input(example)

        result = count_on(steps)

        self.assertEqual(result, 2758514936282235)

    def test_solve_part2_input(self):
        with open("input") as f:
            example = f.read()

        steps = parse_input(example)

        result = count_on(steps)

        self.assertEqual(result, 1201259791805392)


if __name__ == '__main__':
    unittest.main()
