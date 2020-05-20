module Ustring = Ustring

module Template = struct
  include Template
  include Template_builder
end

module Model = Model

let render : Template.t -> Model.t -> Ustring.t = Render.render
