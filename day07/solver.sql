-- Usage: pipe the input data into the script (i.e. cat input | psql -f solver.sql)

\set ON_ERROR_STOP true

-- Set up data
DROP TABLE IF EXISTS crab_positions CASCADE;
CREATE TABLE crab_positions (
  position INTEGER
);

\COPY crab_positions(position) FROM PROGRAM 'tr , \\n';

-- Function that calculates the correct fuel usage for a crab sumbarine
-- to move a certain distance.
CREATE OR REPLACE FUNCTION compute_crab_fuel(distance integer) RETURNS integer AS
$$
  SELECT (distance / 2) * (1 + distance) +
    CASE WHEN (distance % 2 != 0) THEN (1 + distance / 2) ELSE 0 END;
$$
LANGUAGE SQL;

-- Rudimentary unit test
CREATE OR REPLACE PROCEDURE _test_compute_crab_fuel() AS
$$
BEGIN
  assert compute_crab_fuel(4) = 10, 'compute_fuel(4) != 10';
  assert compute_crab_fuel(11) = 66, 'compute_fuel(11) != 66';
END
$$
LANGUAGE plpgsql;

CALL _test_compute_crab_fuel();

-- Computation --
-- All positions in the input data range
WITH candidates AS (
  SELECT generate_series(min(position), max(position)) as position
  FROM crab_positions),
distances AS (
  SELECT candidates.position,
         abs(crab_positions.position - candidates.position) as distance
  FROM candidates CROSS JOIN crab_positions
),
fuel_usage AS (
  SELECT
    sum(distance) as part1_fuel,
    sum(compute_crab_fuel(distance)) as part2_fuel
  FROM distances GROUP BY position
)
(SELECT 1 as part, part1_fuel as solution FROM fuel_usage ORDER BY part1_fuel LIMIT 1)
UNION
(SELECT 2 as part, part2_fuel as solution FROM fuel_usage ORDER BY part2_fuel LIMIT 1);
