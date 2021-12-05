-- INPUT --

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

DROP TABLE _input_data;

CREATE OR REPLACE VIEW hydrothermal_vent_hv_lines AS (
  SELECT line
  FROM hydrothermal_vent_lines
  WHERE ?- line OR ?| line
);

-- Generate a 1000 x 1000 grid in a table
CREATE TEMPORARY TABLE _grid AS (
  SELECT point(y, x) as point
  FROM generate_series(0, 1000) as y
  CROSS JOIN generate_series(0, 1000) as x
);

-- Check, for each combination of point in the grid vs line, if the
-- point lies in the line; then count those points that lie in more
-- than two lines.
WITH counts AS (
  SELECT count(point) as count
  FROM _grid CROSS JOIN hydrothermal_vent_hv_lines lines
  WHERE (_grid.point ## lines.line) ~= _grid.point
  GROUP BY _grid.point[0], _grid.point[1]
) SELECT count(count) AS part1_solution FROM counts WHERE count > 1;


-- Check, for each combination of point in the grid vs line, if the
-- point lies in the line; then count those points that lie in more
-- than two lines.
WITH counts AS (
  SELECT count(point) as count
  FROM _grid CROSS JOIN hydrothermal_vent_lines lines
  WHERE (_grid.point ## lines.line) ~= _grid.point
  GROUP BY _grid.point[0], _grid.point[1]
) SELECT count(count) AS part2_solution FROM counts WHERE count > 1;
