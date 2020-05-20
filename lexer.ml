open Core
open Parser

let get_text buffer first =
  let text = CCVector.of_array first in
  let rec aux () =
    match%sedlex buffer with
    | "<%#" -> Sedlexing.rollback buffer
    | "<%$" -> Sedlexing.rollback buffer
    | "<%>" -> Sedlexing.rollback buffer
    | "<%" -> Sedlexing.rollback buffer
    | "%>" -> Sedlexing.rollback buffer
    | eof -> ()
    | any ->
        CCVector.append_array text (Sedlexing.lexeme buffer);
        aux ()
    | _ -> assert false
  in
  aux ();
  CCVector.to_array text

let token buffer =
  match%sedlex buffer with
  | "<%#" ->
      print_endline "LeftParSection";
      LeftParSection
  | "<%$" ->
      print_endline "LeftParLambda";
      LeftParLambda
  | "<%>" ->
      print_endline "CloseTag";
      CloseTag
  | "<%" ->
      print_endline "LeftPar";
      LeftPar
  | "%>" ->
      print_endline "RightPar";
      RightPar
  | eof ->
      print_endline "EOF";
      EOF
  | any ->
      let text = get_text buffer (Sedlexing.lexeme buffer) in
      print_string "Text(";
      Ustring.print text;
      print_endline ")";
      Text text
  | _ -> assert false

let lexer buffer = Sedlexing.with_tokenizer token buffer
