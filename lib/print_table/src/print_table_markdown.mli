(*_***************************************************************************)
(*_  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*_  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: ISC                                            *)
(*_***************************************************************************)

(** Implement the rendering of print tables using the GitHub Flavored Markdown
    syntax. *)

type t = Print_table_ast.t

val to_string : t -> string
