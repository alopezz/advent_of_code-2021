-- Read input data
CREATE TEMPORARY TABLE lanternfish_raw (
  timer INTEGER
);

\COPY lanternfish_raw(timer) FROM PROGRAM 'cat input | tr , \\n';

-- Store data as a relation between timers and the count of fish that have that timer
BEGIN;
DROP TABLE IF EXISTS lanternfish CASCADE;
CREATE TABLE lanternfish AS (
  SELECT timer, count(*) as fish_count FROM lanternfish_raw GROUP BY timer
);
DROP TABLE lanternfish_raw;
END;

-- Main function used to simulate based on the lanternfish table
CREATE OR REPLACE FUNCTION simulate(n_days integer) RETURNS bigint AS
$$
DECLARE
offspring_count bigint;
BEGIN
  -- Keep track of simulation state in a separate table
  DROP TABLE IF EXISTS simulated_lanternfish;
  CREATE TEMPORARY TABLE simulated_lanternfish AS (
    SELECT timer, fish_count FROM lanternfish
  );

  -- Apply simulation rules n_days times
  FOR idx in 1..n_days LOOP
    offspring_count := sum(fish_count) FROM simulated_lanternfish WHERE timer = 0;
    UPDATE simulated_lanternfish
      SET timer = CASE
        WHEN timer = 0 THEN 6  -- Reset the timer
                       ELSE timer - 1 END;
    INSERT INTO simulated_lanternfish (timer, fish_count) VALUES (8, COALESCE(offspring_count, 0));
  END LOOP;
  RETURN sum(fish_count) FROM simulated_lanternfish;
END
$$
LANGUAGE plpgsql;

-- Compute and display solutions
SELECT 1 as part, solution FROM simulate(80) as solution
UNION
SELECT 2 as part, solution FROM simulate(256) as solution;
