# Run with `awk -f solver_part2.awk input`

/^forward/ {
    horizontal += $2
    depth += $2 * aim
}

/^down/ {
    aim += $2
}

/^up/ {
    aim -= $2
}

END {
    print "The solution to part 2 is " horizontal * depth
}
