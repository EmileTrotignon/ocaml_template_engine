type elt = String of Ustring.t | Key of string | Section of (string * t) | Call of (string * t)

and t = elt list

val print : t -> unit