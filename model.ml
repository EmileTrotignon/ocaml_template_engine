type elt =
  | Value of Ustring.t
  | List of t list
  | Object of t
  | Lambda of (Ustring.t -> Ustring.t)

and t = (string * elt) list

let find model key =
  let is_found (key', _) = key = key' in
  List.find_opt is_found model
