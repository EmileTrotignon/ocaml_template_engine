open Template
open Parser.MenhirInterpreter
module S = MenhirLib.General

let pp_pos out { Ppxlib.pos_lnum; pos_cnum; pos_bol; _ } =
  Format.fprintf out "line %d:%d" pos_lnum (pos_cnum - pos_bol)

let handle_syntax_error lexbuf checkpoint =
  let message = "Syntax error" in
  Format.fprintf Format.err_formatter "%s %a\n%!" message pp_pos
    (fst @@ Sedlexing.lexing_positions lexbuf)

let state checkpoint : int =
  match Lazy.force (stack checkpoint) with
  | S.Nil ->
      (* Hmm... The parser is in its initial state. Its number is
         usually 0. This is a BIG HACK. TEMPORARY *)
      0
  | S.Cons (Element (s, _, _, _), _) -> number s

let rec loop next_token lexbuf (checkpoint : Template.t checkpoint) =
  match checkpoint with
  | InputNeeded _env ->
      let token = next_token () in
      let checkpoint = offer checkpoint token in
      loop next_token lexbuf checkpoint
  | Shifting _ | AboutToReduce _ ->
      let checkpoint = resume checkpoint in
      loop next_token lexbuf checkpoint
  | HandlingError env ->
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
