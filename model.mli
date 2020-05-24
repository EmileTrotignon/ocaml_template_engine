type elt = Value of Ustring.t | List of t list | Object of t | Lambda of (Ustring.t -> Ustring.t)

and t = (string * elt) list

val value_of_string : string -> elt

val find: t -> string -> (string * elt) option