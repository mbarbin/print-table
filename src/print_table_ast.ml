(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

module Style = struct
  type t =
    | Default
    | Fg_green
    | Fg_red
    | Fg_yellow
    | Dim
    | Underscore
end

module Cell = struct
  type t =
    { style : Style.t
    ; text : string
    }
end

module Align = struct
  type t =
    | Left
    | Center
    | Right
end

module Column = struct
  type 'a t =
    { header : string
    ; align : Align.t
    ; make_cell : 'a -> Cell.t
    }
end

type t =
  | T :
      { columns : 'a Column.t list
      ; rows : 'a list
      }
      -> t
