# Run with `awk -f solver.awk input`

/^forward/ {
    horizontal += $2
}

/^down/ {
    depth += $2
}

/^up/ {
    depth -= $2
}

END {
    print "The solution to part 1 is " horizontal * depth
}
