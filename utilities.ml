open Core


let unicode_string string = 
  Array.map (String.to_array string) Uchar.of_char
