-- PRELUDE --
\set ON_ERROR_STOP true

DROP SCHEMA IF EXISTS day21 CASCADE;
CREATE SCHEMA day21;
SET SCHEMA 'day21';

-- Default values for starting positions are set to the example.
-- These can be overriden by using the -v option when invoking the script with sql.
\if :{?player1_start}
\else
   \set player1_start 4
\endif

\if :{?player2_start}
\else
   \set player2_start 8
\endif

-- SOLUTION FOR PART 1 --

WITH RECURSIVE record(player, turn, pos, score) AS (
  VALUES
    (0, 0, :player1_start, 0),
    (1, 1, :player2_start, 0)
  UNION ALL
    SELECT player, turn + 2 as turn, new_position as pos, score + new_position as score
    FROM (
      SELECT
        player, turn,
        -- Keeping the formula with all the factors in it to make it a bit easier to understand
        (pos + 3*3*turn + 6 - 1) % 10 + 1 as new_position,
        score as score
      FROM record WHERE score < 1000
    ) as _
), final_turn AS (
   SELECT turn FROM record WHERE score >= 1000 ORDER BY turn LIMIT 1
)
-- The turn before the final one gives us everything we need
SELECT score * (3 * turn) as solution_part1
FROM record
WHERE turn < (SELECT turn FROM record WHERE score >= 1000 ORDER BY turn LIMIT 1)
ORDER BY turn DESC LIMIT 1;

-- SOLUTION FOR PART 2 --

\set winning_score 21

-- This table holds all possible outcomes of a 3-dice roll,
-- with how often they occur
CREATE TABLE dice_outcomes AS (
WITH individual_outcomes AS (
  SELECT a, b, c
  FROM generate_series(1, 3) as a
  CROSS JOIN generate_series(1, 3) as b
  CROSS JOIN generate_series(1, 3) as c
), summed_outcomes AS (
  SELECT a + b + c as outcome FROM individual_outcomes
)
SELECT outcome, count(*) as times FROM summed_outcomes GROUP BY outcome);

-- A view that simulates all possible games for each player
CREATE OR REPLACE VIEW game AS (
  WITH RECURSIVE record(player, turn, pos, score, count) AS (
    VALUES
      (1, 0, :player1_start, 0, 1::numeric),
      (2, 1, :player2_start, 0, 1::numeric)
  UNION ALL
    (WITH partial AS (
      SELECT
        player,
        turn + 2 as turn,
        new_position as pos,
        score + new_position as score,
        count
      FROM (
        SELECT
          player, turn, pos, score,
          (pos + outcome - 1) % 10 + 1 as new_position,
          count * dice_outcomes.times as count
        FROM record CROSS JOIN dice_outcomes
        WHERE score < :winning_score) as _
      )
      -- Group partial results
      SELECT player, turn, pos, score, sum(count)::numeric as count
      FROM partial GROUP BY (player, turn, pos, score))
  ) SELECT * FROM record);

-- Views for individual players
CREATE OR REPLACE VIEW player1 AS (SELECT turn, score, sum(count) as count
  FROM game WHERE player = 1 GROUP BY (player, turn, score));
CREATE OR REPLACE VIEW player2 AS (SELECT turn, score, sum(count) as count
  FROM game WHERE player = 2 GROUP BY (player, turn, score));

-- Compute in how many universes each player wins.
-- This is done by matching the turns in which a player reaches the target score
-- against the opponent scores in the previous turn.
WITH player1_wins AS (
  SELECT sum(p1.count * p2.count) as wins
  FROM player1 p1 JOIN player2 p2 ON p1.turn = p2.turn + 1
  WHERE p1.score >= :winning_score AND p2.score < :winning_score
), player2_wins AS (
  SELECT sum(p1.count * p2.count) as wins
  FROM player1 p1 JOIN player2 p2 ON p1.turn + 1 = p2.turn
  WHERE p2.score >= :winning_score AND p1.score < :winning_score
), times_won_per_player AS (
  SELECT wins FROM player1_wins
  UNION
  SELECT wins FROM player2_wins
)
SELECT wins FROM times_won_per_player ORDER BY wins DESC;
