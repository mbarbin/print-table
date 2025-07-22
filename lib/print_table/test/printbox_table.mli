(*_***************************************************************************)
(*_  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*_  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: ISC                                            *)
(*_***************************************************************************)

(** Render a PrintBox in GitHub Flavored Markdown table syntax. *)

type t = PrintBox.t

val of_print_table : Print_table.t -> t

(** This is implemented as post-process that expects the table to be in a
    box-drawing style as produced by PrintBox when rendered into ansi. Not
    suitable for all-purposes. *)
val to_string_markdown : t -> string
