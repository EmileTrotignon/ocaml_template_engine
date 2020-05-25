open Template_engine

let t = Template.of_filename "template.ote"

let model =
  Model.
    [
      ("title", value_of_string "This is my title");
      ( "section",
        List
          [
            [
              ("title", value_of_string "first");
              ("content", value_of_string "first content");
              ("link", value_of_string "https://ocaml.org/");
            ];
            [
              ("title", value_of_string "second");
              ("content", value_of_string "second content");
              ("link", value_of_string "https://www.haskell.org/");
            ];
            [
              ("title", value_of_string "third");
              ("content", value_of_string "last content");
              ("link", value_of_string "https://ocaml.org/");
            ];
          ] );
      ("url", Lambda (Array.append (Ustring.of_string "URL : ")));
    ]

let () =
  match t with
  | Some template -> Ustring.print (render template model)
  | None -> failwith "syntax error in template.ote"
