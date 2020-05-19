%token RightPar
%token LeftPar
%token CloseTag
%token LeftParSection
%token LeftParLambda
%token <Ustring.t> Text
%token EOF

%start <Template.t> template
%%

rev_template :
 | (* nothing *) {[]}
 | t = rev_template ; LeftPar ; text = Text ; RightPar {Key (String.trim (Ustring.to_string text)) :: t}
 | t = rev_template ; LeftParLambda ; name = Text ; RightPar ; t2 = rev_template ; CloseTag {Call(String.trim (Ustring.to_string name), List.rev t2) :: t}
 | t = rev_template ; LeftParSection ; name = Text ; RightPar ; t2 = rev_template ; CloseTag {Section(String.trim (Ustring.to_string name), List.rev t2) :: t}
 | t = rev_template ; string = Text {String string :: t}

template:
  | t = rev_template ; EOF {List.rev t}