type elt =
  | Value of Ustring.t
  | List of t list
  | Object of t
  | Lambda of (Template.t -> Ustring.t)

and t = (string * elt) list

let find model key =
  let is_found (key', _) = key = key' in
  List.find_opt is_found model

let map_concat f string_list =
  List.fold_left Array.append [||] (List.map f string_list)

let rec render template model =
  Template.(
    let render_item item =
      match item with
      | String s -> s
      | Key key -> (
          match find model key with
          | Some (_, Value s) -> s
          | _ -> failwith "A key need a value associated to it" )
      | Section (key, template') -> (
          match find model key with
          | Some (_, List values) -> map_concat (render template') values
          | _ -> failwith "Section needs a list" )
      | Call (key, template) -> (
          match find model key with
          | Some (_, Lambda f) -> f template
          | _ -> failwith "Call needs a lambda" )
    in
    map_concat render_item template)
