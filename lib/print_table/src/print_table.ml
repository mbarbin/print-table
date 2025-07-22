(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

type t = Print_table_ast.t

let to_string_text = Print_table_text.to_string
let to_string_markdown = Print_table_markdown.to_string

module Style = struct
  include Print_table_ast.Style

  let default = Default
  let fg_green = Fg_green
  let fg_red = Fg_red
  let fg_yellow = Fg_yellow
end

module Cell = struct
  include Print_table_ast.Cell

  let empty = { style = Style.default; text = "" }
  let is_empty t = String.length t.text = 0
  let text ?(style = Style.default) text = { style; text }
end

module Align = struct
  include Print_table_ast.Align
end

module Column = struct
  include Print_table_ast.Column

  let make ~header ?(align = Align.Left) make_cell = { header; align; make_cell }
end

let make ~columns ~rows = Print_table_ast.T { columns; rows }

module O = struct
  module Align = Align
  module Cell = Cell
  module Column = Column
  module Style = Style
end

module Private = struct
  module Ast = Print_table_ast

  let to_ast t = t
end
