# ocaml_template_engine

This is a small runtime template engine for ocaml heavily inspired by mustache.

There is a custom type used to pass ocaml values to the parser.

Here is an example :

```ocaml
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

```
File ```template.ote``` : 
```
#<% title %>


<%# section %>
## <% title %>

<% content %>

<%$ url %><% link %><%>

<%>
```

And the output :

```
#This is my title



## first

first content

URL : https://ocaml.org/


## second

first content

URL : https://ocaml.org/


## third

first content

URL : https://ocaml.org/
```
