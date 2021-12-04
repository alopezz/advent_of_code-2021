-- INPUT --

DROP TABLE IF EXISTS input_numbers CASCADE;
CREATE TABLE input_numbers (
  id SERIAL,
  number INTEGER
);

\COPY input_numbers(number) FROM PROGRAM 'head -n 1 input | tr "," "\n"';

DROP TABLE IF EXISTS bingo_numbers CASCADE;
CREATE TABLE bingo_numbers (
  id SERIAL,
  board INTEGER,
  row_n INTEGER,
  column_n INTEGER,
  number INTEGER
);

\COPY bingo_numbers(board, row_n, column_n, number) FROM PROGRAM 'awk -f sql/preprocess.awk input' DELIMITER ' ';

-- SOLUTION --

CREATE OR REPLACE VIEW winning_scores AS (
WITH
  -- Add a column which adds the position/id on which that number appeared in the input
  -- A NULL value on that column means the number wasn't called.
  -- This allows us to apply logic based on the order of play.
  bingo_numbers_matched AS (
  SELECT bingo_numbers.id, board, row_n, column_n, bingo_numbers.number, input_numbers.id as input_id
  FROM bingo_numbers
  LEFT JOIN input_numbers ON (bingo_numbers.number = input_numbers.number)
  ),
  -- Two separate queries to check complete columns and rows.
  -- The max position is stored (as that is when the column/row was actually completed)
  -- Completed column/rows are identified by having 5 matched numbers.
  winning_because_columns AS (
    SELECT board, max(input_id) as input_id
    FROM bingo_numbers_matched
    WHERE input_id IS NOT NULL
    GROUP BY (board, column_n)
    HAVING count(*) = 5
  ),
  winning_because_rows AS (
    SELECT board, max(input_id) as input_id
    FROM bingo_numbers_matched
    WHERE input_id IS NOT NULL
    GROUP BY (board, row_n)
    HAVING count(*) = 5
  ),
  -- Merging of data from winning columns and rows.
  -- From all those, just pick the one with the minimum position for a given board
  -- as that represents where the board actually won.
  wins AS (
    SELECT board, min(input_id) as input_id
    FROM
      (SELECT * FROM winning_because_columns
       UNION
       SELECT * FROM winning_because_rows) as temp
    GROUP BY board
    ORDER BY input_id
  )
  -- Compute scores as given in the problem statement.
  -- For this, we merge three views to obtain all the necessary information
  -- and apply the formula.
  SELECT
    input_numbers.id, input_numbers.number * sum(bingo_numbers.number) as score
  FROM wins
  -- Grab the number that was called when a board won
  JOIN input_numbers ON wins.input_id = input_numbers.id
  -- Grab numbers in a board that were uncalled or called later than the winning number
  JOIN bingo_numbers_matched bingo_numbers
    ON wins.board = bingo_numbers.board AND
      (bingo_numbers.input_id IS NULL OR bingo_numbers.input_id > wins.input_id)
  GROUP BY (input_numbers.id, input_numbers.number, wins.board));

-- The solution to the first part is just the first winning score
SELECT score as part1_solution FROM winning_scores ORDER BY id LIMIT 1;
-- The solution to the second part is just the last winning score
SELECT score as part2_solution FROM winning_scores ORDER BY id DESC LIMIT 1;
