(*_***************************************************************************)
(*_  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*_  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: ISC                                            *)
(*_***************************************************************************)

(** An intermediate data structure used in the rendering of text tables. *)

module Column : sig
  (** [length] is the number of characters of the cell within the column that
      takes up the most space. It is used to pad the rest of the cells in the
      column that have a shorter text contents to display in their respective
      cell. *)
  type t = private
    { header : string
    ; align : Print_table_ast.Align.t
    ; cells : Print_table_ast.Cell.t array
    ; length : int
    }
end

(** Due to the type being [private] we can guarantee that each column has the
    same number of cells. *)
type t = private { columns : Column.t array }

val of_print_table : Print_table_ast.t -> t

(** {1 Utils} *)

(** [pad input ~len ~align] returns a new string with spaces either to the left,
    right or both so that it contains the original string at the specified
    alignment. For example [pad "hello" 10 ~align:Right] is equivalent to
    [String.make 5 ' ' ^ "hello"]. *)
val pad : string -> len:int -> align:Print_table_ast.Align.t -> string
