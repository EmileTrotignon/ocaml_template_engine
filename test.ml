let template =
  Template_builder.of_string
    {|hey <% coucou %> lalal 

<%# ma_section %>

voici ma cle :
<%ma_cle%>

<%>

|}

let _ =
  match template with
  | Some t ->
      (*Template.print t*)
      Ustring.print
        (Render.render t
           [
             ("coucou", Model.Value (Ustring.of_string "ceci remplace coucou"));
             ( "ma_section",
               Model.List
                 [
                   [ ("ma_cle", Model.Value (Ustring.of_string "valeur1")) ];
                   [ ("ma_cle", Model.Value (Ustring.of_string "valeur 2")) ];
                   [ ("ma_cle", Model.Value (Ustring.of_string "valeur 3")) ];
                 ] );
           ])
  | None -> ()
