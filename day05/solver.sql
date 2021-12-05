-- Read the input data into a temporary table containing both points for each line
CREATE TEMPORARY TABLE _input_data (
  id SERIAL,
  point_a POINT,
  point_b POINT
);
\COPY _input_data(point_a, point_b) FROM PROGRAM 'cat input | sed ''s/ -> / /''' DELIMITER ' ';

-- Transform the data into line segments
DROP TABLE IF EXISTS hydrothermal_vent_lines CASCADE;
CREATE TABLE hydrothermal_vent_lines AS (
  SELECT lseg(point_a, point_b) as line FROM _input_data
);

DROP TABLE _input_data;  -- We don't need this anymore

-- Generate a 1000 x 1000 grid in a table
CREATE TEMPORARY TABLE _grid AS (
  SELECT point(y, x) as point
  FROM generate_series(0, 1000) as y
  CROSS JOIN generate_series(0, 1000) as x
);

-- Calculate solutions
WITH lines_and_points AS ( -- Relation of points belonging to each line
  SELECT line, point
  FROM _grid CROSS JOIN hydrothermal_vent_lines
  -- Condition that expresses that a line belongs to a point
  WHERE (point ## line) ~= point
), counts_all AS ( -- Count of total lines that pass through every point
  SELECT count(point) as count
  FROM lines_and_points
  GROUP BY point[0], point[1]
), counts_hv AS ( -- Same for horizontal and vertical lines
  SELECT count(point) as count
  FROM lines_and_points
  WHERE ?- line OR ?| line
  GROUP BY point[0], point[1]
)
-- Count points that have more than two vent lines going through it,
-- for horizontal/vertical lines (part 1) and for all lines (part 2)
SELECT 'PART1' AS part, count(*) AS solution
FROM counts_hv
WHERE count > 1
UNION
SELECT 'PART2' AS part, count(*) AS solution
FROM counts_all
WHERE count > 1;
