DROP TABLE IF EXISTS aoc_day1_depth;

CREATE TABLE aoc_day1_depth (
       id SERIAL,
       depth INTEGER
);

-- Copy input into the database
COPY aoc_day1_depth(depth)
FROM '/path/to/input';

WITH consecutive_depths AS (
  SELECT a.depth AS next, b.depth AS previous
  FROM aoc_day1_depth a
  JOIN aoc_day1_depth b ON a.id = b.id + 1
)
SELECT COUNT(*) AS part1_solution FROM consecutive_depths WHERE next > previous;

-- PART 2 --

WITH windowed_depths AS (
  SELECT id, sum(depth)
  OVER (ROWS BETWEEN 0 FOLLOWING AND 2 FOLLOWING)
  FROM aoc_day1_depth
),
consecutive_depths AS (
  SELECT a.sum AS next, b.sum AS previous
  FROM windowed_depths a
  JOIN windowed_depths b ON a.id = b.id + 1
)
SELECT COUNT(*) AS part2_solution FROM consecutive_depths WHERE next > previous;

