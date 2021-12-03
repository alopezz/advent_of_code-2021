DROP TABLE IF EXISTS diagnostic_report_raw CASCADE;
DROP TABLE IF EXISTS diagnostic_report CASCADE;

CREATE TABLE diagnostic_report_raw (
       id SERIAL,
       value TEXT
);

-- Copy input into the database
COPY diagnostic_report_raw(value)
FROM '/path/to/input';


CREATE TABLE diagnostic_report AS (
  SELECT value::bit(12) AS bits FROM diagnostic_report_raw
);

-- FUNCTIONS - GENERAL --

CREATE OR REPLACE FUNCTION most_common_value(integer, OUT result integer) AS
$$
BEGIN
  result := get_bit(bits, $1) FROM diagnostic_report
    GROUP BY get_bit(bits, $1) ORDER BY count(get_bit(bits, $1)) DESC LIMIT 1;
  RETURN;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION least_common_value(integer, OUT result integer) AS
$$
BEGIN
  result := get_bit(bits, $1) FROM diagnostic_report
    GROUP BY get_bit(bits, $1) ORDER BY count(get_bit(bits, $1)) LIMIT 1;
  RETURN;
END
$$
LANGUAGE plpgsql;

-- PART 1 --

CREATE OR REPLACE FUNCTION get_gamma_bits(OUT result bit(12)) AS
$$
BEGIN
  result := B'000000000000';
  FOR idx in 0..11 LOOP
    result := set_bit(result, idx, most_common_value(idx));
  END LOOP;
  RETURN;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_epsilon_bits(OUT result bit(12)) AS
$$
BEGIN
  result := B'000000000000';
  FOR idx in 0..11 LOOP
    result := set_bit(result, idx, least_common_value(idx));
  END LOOP;
  RETURN;
END
$$
LANGUAGE plpgsql;

SELECT get_epsilon_bits()::integer * get_gamma_bits()::integer AS part1_solution;

-- PART 2 --

CREATE OR REPLACE FUNCTION get_oxygen_rating_bits(OUT result bit(12)) AS
$$
DECLARE
  most_common integer;
BEGIN
  DROP TABLE IF EXISTS filtered_diagnostic;
  CREATE TABLE filtered_diagnostic AS (SELECT * FROM diagnostic_report);
  FOR idx in 0..11 LOOP
    most_common := get_bit(bits, idx) FROM filtered_diagnostic
      GROUP BY get_bit(bits, idx) ORDER BY count(get_bit(bits, idx)) DESC, get_bit(bits, idx) DESC LIMIT 1;
    DELETE FROM filtered_diagnostic WHERE get_bit(bits, idx) != most_common;
    EXIT WHEN (SELECT count(*) FROM filtered_diagnostic) = 1;
  END LOOP;
  result := bits FROM filtered_diagnostic;
  RETURN;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_co2_rating_bits(OUT result bit(12)) AS
$$
DECLARE
  most_common integer;
BEGIN
  DROP TABLE IF EXISTS filtered_diagnostic;
  CREATE TABLE filtered_diagnostic AS (SELECT * FROM diagnostic_report);
  FOR idx in 0..11 LOOP
    most_common := get_bit(bits, idx) FROM filtered_diagnostic
      GROUP BY get_bit(bits, idx) ORDER BY count(get_bit(bits, idx)), get_bit(bits, idx) LIMIT 1;
    DELETE FROM filtered_diagnostic WHERE get_bit(bits, idx) != most_common;
    EXIT WHEN (SELECT count(*) FROM filtered_diagnostic) = 1;
  END LOOP;
  result := bits FROM filtered_diagnostic;
  RETURN;
END
$$
LANGUAGE plpgsql;

SELECT get_oxygen_rating_bits()::integer * get_co2_rating_bits()::integer AS part2_solution;
