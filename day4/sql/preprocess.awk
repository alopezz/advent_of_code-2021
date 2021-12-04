# Transforms the input boards into the format:
# board_id row column value

# Empty line signals change of board 
/^$/ {
    board_id++
    row = 0
}

(NR > 1 && NF > 1) {
    row++
    for (i = 1; i <= NF; i++) {
        print board_id, row, i, $i
    }
}
