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
  SELECT value::bit varying AS bits FROM diagnostic_report_raw
);

-- FUNCTIONS - GENERAL --
CREATE OR REPLACE FUNCTION most_common_value(integer, table_name text = 'diagnostic_report', OUT result bit) AS
$$
BEGIN
  EXECUTE format('SELECT get_bit(bits, $1) FROM %I
      GROUP BY get_bit(bits, $1)
      ORDER BY count(get_bit(bits, $1)) DESC, get_bit(bits, $1) DESC LIMIT 1',
    table_name)
    INTO result
    USING $1;
  RETURN;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION least_common_value(integer, table_name text = 'diagnostic_report', OUT result bit) AS
$$
BEGIN
  EXECUTE format('SELECT get_bit(bits, $1) FROM %I
      GROUP BY get_bit(bits, $1)
      ORDER BY count(get_bit(bits, $1)), get_bit(bits, $1) LIMIT 1',
    table_name)
    INTO result
    USING $1;
  RETURN;
END
$$
LANGUAGE plpgsql;

-- PART 1 --
CREATE OR REPLACE FUNCTION get_part1_rating(coeff text, n_bits integer = 12, OUT result integer) AS
$$
DECLARE
  bits bit varying;
BEGIN
  bits := B'';
  FOR idx in 0..n_bits - 1 LOOP
    CASE coeff
      WHEN 'gamma' THEN
        bits := bits || most_common_value(idx);
      WHEN 'epsilon' THEN
        bits := bits || least_common_value(idx);
      ELSE
        RAISE EXCEPTION 'Invalid part 1 rating: %', coeff;
    END CASE;
  END LOOP;
  result := lpad(bits::text, 32, '0')::bit(32)::integer;
  RETURN;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_gamma(n_bits integer = 12, OUT result integer) AS
$$
BEGIN
  result := get_part1_rating('gamma', n_bits);
  RETURN;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_epsilon(n_bits integer = 12, OUT result integer) AS
$$
BEGIN
  result := get_part1_rating('epsilon', n_bits);
  RETURN;
END
$$
LANGUAGE plpgsql;


SELECT get_gamma(12) * get_epsilon(12) AS part1_solution;

-- PART 2 --

CREATE OR REPLACE FUNCTION get_part2_rating(coeff text, n_bits integer = 12, OUT result integer) AS
$$
DECLARE
  choice_bit bit;
BEGIN
  DROP TABLE IF EXISTS filtered_diagnostic;
  CREATE TABLE filtered_diagnostic AS (SELECT * FROM diagnostic_report);
  FOR idx in 0..n_bits - 1 LOOP
    CASE coeff
      WHEN 'oxygen' THEN
        choice_bit := most_common_value(idx, 'filtered_diagnostic');
      WHEN 'co2' THEN
        choice_bit := least_common_value(idx, 'filtered_diagnostic');
      ELSE
        RAISE EXCEPTION 'Invalid part 2 rating: %', coeff;
    END CASE;
    DELETE FROM filtered_diagnostic WHERE (get_bit(bits, idx))::bit != choice_bit;
    EXIT WHEN (SELECT count(*) FROM filtered_diagnostic) = 1;
  END LOOP;
  result := lpad(bits::text, 32, '0')::bit(32)::integer FROM filtered_diagnostic;
  DROP TABLE filtered_diagnostic;
  RETURN;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_oxygen_rating(n_bits integer = 12, OUT result integer) AS
$$
BEGIN
  result := get_part2_rating('oxygen', n_bits);
  RETURN;
END
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_co2_rating(n_bits integer = 12, OUT result integer) AS
$$
BEGIN
  result := get_part2_rating('co2', n_bits);
  RETURN;
END
$$
LANGUAGE plpgsql;


SELECT get_oxygen_rating(12) * get_co2_rating(12) AS part2_solution;
