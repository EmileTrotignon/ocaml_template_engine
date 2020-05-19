let template = Template_builder.of_string "hey <% coucou %> lalal "

let _ =
  match template with
  | Some t ->
      Ustring.print
        (Model.render t
           [
             ("coucou", Model.Value (Ustring.of_string "ceci remplace coucou"));
           ])
  | None -> ()
