open Parser.MenhirInterpreter
open Core
module S = MenhirLib.General

let pp_pos out { Ppxlib.pos_lnum; pos_cnum; pos_bol; _ } =
  Format.fprintf out "line %d:%d" pos_lnum (pos_cnum - pos_bol)

let handle_syntax_error lexbuf _ =
  let message = "Syntax error" in
  Format.fprintf Format.err_formatter "%s %a\n%!" message pp_pos
    (fst @@ Sedlexing.lexing_positions lexbuf)

let rec loop next_token lexbuf (checkpoint : Template.t checkpoint) =
  match checkpoint with
  | InputNeeded _env ->
      let token = next_token () in
      let checkpoint = offer checkpoint token in
      loop next_token lexbuf checkpoint
  | Shifting _ | AboutToReduce _ ->
      let checkpoint = resume checkpoint in
      loop next_token lexbuf checkpoint
  | HandlingError _ ->
      handle_syntax_error lexbuf checkpoint;
      None
  | Accepted template -> Some template
  | Rejected ->
      (* Cannot happen as we stop at syntax error immediatly *)
      assert false

let of_lexing_buffer lexbuf =
  let lexer = Lexer.lexer lexbuf in
  loop lexer lexbuf
    (Parser.Incremental.template (fst @@ Sedlexing.lexing_positions lexbuf))

let of_ustring ustring = of_lexing_buffer (Sedlexing.from_uchar_array ustring)

let of_string string = of_ustring (Ustring.of_string string)

let of_filename filename = of_string (In_channel.read_all filename)

let%test "Template.of_string" =
  let s = "before key<%key%>after key" in
  let t =
    Template.
      [
        String (Ustring.of_string "before key");
        Key "key";
        String (Ustring.of_string "after key");
      ]
  in
  match of_string s with Some t' -> t = t' | None -> false

let%test "Template.of_file" =
  let t =
    Template.
      [
        String
          (Ustring.of_string
             "ahahahahahah ¡ªº¡£€£º€ïº£ïö€£€");
        Key "my_first_key";
        Key "my_second_key";
        Section
          ( "my first section",
            [
              String (Ustring.of_string "section header");
              Key "section_key";
              String (Ustring.of_string "section footer");
            ] );
        Call
          ( "my_lambda",
            [
              String (Ustring.of_string "my name is lambda"); Key "my_third_key";
            ] );
      ]
  in
  match of_filename "test.ote" with
  | Some t' -> t = t'
  | None ->
      print_endline "Template was not correct";
      false
