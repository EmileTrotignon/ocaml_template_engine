open Uutf
open Core
open Containers
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

let token_list_of_buffer buffer =
  let tokens = ref [] in
  let append token = tokens := token :: !tokens in
  let text_buffer = ref None in
  let empty_buffer () =
    match !text_buffer with
    | None -> ()
    | Some vector ->
        append (Text (CCVector.to_array vector));
        text_buffer := None
  in
  let update_buffer ustring =
    match !text_buffer with
    | None -> text_buffer := Some (CCVector.of_array ustring)
    | Some vector -> CCVector.append_array vector ustring
  in
  let rec aux buffer =
    match%sedlex buffer with
    | "<%#" ->
        empty_buffer ();
        append LeftParSection;
        aux buffer
    | "<%$" ->
        empty_buffer ();
        append LeftParLambda;
        aux buffer
    | "<%>" ->
        empty_buffer ();
        append CloseTag;
        aux buffer
    | "<%" ->
        empty_buffer ();
        append LeftPar;
        aux buffer
    | "%>" ->
        empty_buffer ();
        append RightPar;
        aux buffer
    | eof -> empty_buffer ()
    | any ->
        update_buffer (Sedlexing.lexeme buffer);
        aux buffer
    | _ -> assert false
  in
  aux buffer;
  List.rev !tokens

(*

let lexer ustring =
  buffer_lexer (Sedlexing.from_uchar_array ustring)


let lexer_for_parser buffer =
  let tokens = ref (buffer_lexer buffer)

  let aux 
*)
