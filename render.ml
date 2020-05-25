open Model
open Core

let map_concat ~f string_list =
  List.fold_left ~f:Array.append ~init:[||] (List.map ~f string_list)

let rec find_in_models models key =
  match models with
  | model :: models' -> (
      match find model key with
      | Some elt -> Some elt
      | None -> find_in_models models' key )
  | [] -> None

let render template model =
  let rec render_from_model_list template models =
    Template.(
      let render_item item =
        match item with
        | String s -> s
        | Key key -> (
            match find_in_models models key with
            | Some (_, Value s) -> s
            | _ ->
                failwith (sprintf "Key '%s' need a value associated to it" key)
            )
        | Section (key, template') -> (
            match find_in_models models key with
            | Some (_, List values) ->
                map_concat
                  ~f:(render_from_model_list template')
                  (List.map ~f:(fun v -> v :: models) values)
            | _ -> failwith (sprintf "Section '%s' need a list" key) )
        | Call (key, template') -> (
            match find_in_models models key with
            | Some (_, Lambda f) -> f (render_from_model_list template' models)
            | _ -> failwith (sprintf "Lambda call '%s' need a lambda" key) )
      in
      map_concat ~f:render_item template)
  in
  render_from_model_list template [ model ]

let test_template template model expected_result =
  let t = render template model in
  (* Ustring.print t ;
     Out_channel.newline stdout; *)
  t = expected_result

let%test "key" =
  let template =
    [
      Template.String (Ustring.of_string "first bit a of text");
      Template.Key "test_key";
    ]
  in
  let model =
    [ ("test_key", Model.Value (Ustring.of_string "remplacement string")) ]
  in
  test_template template model
    (Ustring.of_string "first bit a of textremplacement string")

let%test "section" =
  let template =
    [
      Template.String (Ustring.of_string "first bit a of text");
      Template.Section
        ( "test_section",
          [
            Template.String (Ustring.of_string "section header");
            Template.Key "section_key";
            Template.String (Ustring.of_string "section footer");
          ] );
    ]
  in
  let model =
    [
      ( "test_section",
        Model.List
          [
            [ ("section_key", Model.Value (Ustring.of_string "value 1")) ];
            [ ("section_key", Model.Value (Ustring.of_string "value 2")) ];
            [ ("section_key", Model.Value (Ustring.of_string "value 3")) ];
          ] );
    ]
  in
  test_template template model
    (Ustring.of_string
       "first bit a of textsection headervalue 1section footersection \
        headervalue 2section footersection headervalue 3section footer")
