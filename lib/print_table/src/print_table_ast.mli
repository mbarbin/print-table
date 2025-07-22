(*_***************************************************************************)
(*_  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*_  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: ISC                                            *)
(*_***************************************************************************)

(** Private underlying representation to manipulate print tables.

    This is the AST that is built under the hood by the EDSL, and used to
    implement the printers. *)

module Style : sig
  type t =
    | Default
    | Fg_green
    | Fg_red
    | Fg_yellow
end

module Cell : sig
  type t =
    { style : Style.t
    ; text : string
    }
end

module Align : sig
  type t =
    | Left
    | Center
    | Right
end

module Column : sig
  (** A type for a column extractor, parameterized by the type of the lines.
      Each ['row] represents one single row of the table. *)
  type 'row t =
    { header : string
    ; align : Align.t
    ; make_cell : 'row -> Cell.t
    }
end

type t =
  | T :
      { columns : 'a Column.t list
      ; rows : 'a list
      }
      -> t
