module Template = struct

  type elt = Template.elt

  type t = Template.t

  let of_string = Template_builder.of_string

  let of_ustring = Template_builder.of_ustring
end

val render = Model.render

module Ustring = Ustring

module Model = struct
  type elt = Model.elt

  type t = Model.t