type elt = Value of Ustring.t | List of t list | Object of t | Lambda of (Template.t -> Ustring.t)

and t = (string * elt) list

val render: Template.t -> t -> Ustring.t