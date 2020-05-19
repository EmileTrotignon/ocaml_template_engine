open Core

type elt = String of Ustring.t | Key of string | Section of (string * t) | Call of (string * t)

and t = elt list

let rec print_elt elt =
  match elt with
  | String us -> Ustring.print us
  | Key s -> print_string "<%" ; print_string s ; print_string "%>"
  | Section (s, t) -> print_string "<%#" ; print_string s ; print_string "%>" ; print t ; print_string "<%>"
  | Call (s, t) -> print_string "<%$" ; print_string s ; print_string "%>" ; print t ; print_string "<%>"

and print template =
  List.iter template print_elt
