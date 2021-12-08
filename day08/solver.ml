(* --- Day 8: Seven Segment Search --- *)

type segment = A | B | C | D | E | F | G

type digit = segment list

type entry = {
    pattern: digit list;
    output: digit list;
  }

let all_segments = [A; B; C; D; E; F; G]

let digit_of_string str =
  String.to_seq str
  |> Seq.map
       (function
         | 'a' -> A
         | 'b' -> B
         | 'c' -> C
         | 'd' -> D
         | 'e' -> E
         | 'f' -> F
         | 'g' -> G
         | _ -> failwith "Bad input"
       )
  |> List.of_seq
  |> List.sort compare

let entry_of_string str =
  let split_fields =
    String.split_on_char '|' str
    |> List.map(fun x -> String.trim x |> String.split_on_char ' ')
  in
  match split_fields with
  | [pattern; output] -> {
      pattern = List.map digit_of_string pattern;
      output = List.map digit_of_string output}
  | _ -> failwith "Input error"

let count f lst =
  List.filter f lst |> List.length

(** Part 1 **)

let is_identifiable_digit digit =
  List.mem (List.length digit) [2; 3; 4; 7]

let solve_part1 entries =
  entries
  |> List.map (fun {output} -> output)
  |> List.concat
  |> count is_identifiable_digit

(** Part 2 **)

(* Convert a list of segments [signal] to an integer *)
let int_of_signal signal =
  match List.sort compare signal with
  | [A; B; C; E; F; G] -> 0
  | [C; F] -> 1
  | [A; C; D; E; G] -> 2
  | [A; C; D; F; G] -> 3
  | [B; C; D; F] -> 4
  | [A; B; D; F; G] -> 5
  | [A; B; D; E; F; G] -> 6
  | [A; C; F] -> 7
  | [A; B; C; D; E; F; G] -> 8
  | [A; B; C; D; F; G] -> 9
  | _ -> failwith "Wrong segment combination"

(* Finds first pattern in list with [c] segments *)
let pattern_with_count_of c =
  List.find (fun x -> List.length x = c)

(* The key to solving part 2: returns a mapping (as an association
   list) that can be used to match segments in the output to where
   they should go. *)
let decode_mapping patterns =
  (* There are three segments which we can deduce from a basic
     frequency analysis *)
  let flat_patterns = List.concat patterns in
  let counts = List.map (fun s -> (count (fun a -> s = a) flat_patterns), s) all_segments in
  let mapping = [
      (List.assoc 4 counts, E);
      (List.assoc 6 counts, B);
      (List.assoc 9 counts, F)
    ] in

  (* We deduce the rest by using the numbers we can recognize from the
     number of segments they have. Going through them in the right
     order, we'll always be able to deduce new segments by
     elimination. *)
  let find_missing mapping =
    List.find
      (fun x -> List.assoc_opt x mapping = None) in

  let deduce mapping (candidates, expected) =
    let added = find_missing mapping candidates in
    (added, expected) :: mapping
  in

  let pattern_for_1 = pattern_with_count_of 2 patterns in
  let pattern_for_7 = pattern_with_count_of 3 patterns in
  let pattern_for_4 = pattern_with_count_of 4 patterns in

  List.fold_left
    deduce
    mapping
    [
      (pattern_for_1, C);
      (pattern_for_7, A);
      (pattern_for_4, D);
      (all_segments, G);
    ]

(* Remaps all segments in [outputs] according to the given [mapping] *)
let rewire_outputs outputs mapping =
  List.map
    (List.map (fun x -> List.assoc x mapping))
    outputs

(* Join digits into a full number *)
let join_digits digits =
  List.map string_of_int digits
  |> String.concat ""
  |> int_of_string

(* Decode an entry and return the output number *)
let output_number_of_entry {pattern; output} =
  decode_mapping pattern
  |> rewire_outputs output
  |> List.map int_of_signal
  |> join_digits

let solve_part2 entries =
  entries
  |> List.map output_number_of_entry
  |> List.fold_left (fun a b -> a + b) 0

(** Input and execution **)

let read_input channel f_item =
  let rec read_lines items =
    match input_line channel with
    | exception End_of_file -> items
    | line -> read_lines (f_item line :: items)
  in
  read_lines []

let () =
  let entries = read_input stdin entry_of_string in
  solve_part1 entries |> Printf.printf "The answer to part 1 is %d\n";
  solve_part2 entries |> Printf.printf "The answer to part 2 is %d\n";
