(*_***************************************************************************)
(*_  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*_  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: ISC                                            *)
(*_***************************************************************************)

(** Implement the rendering of text tables using unicode and ansi encoding for
    the terminal. *)

type t = Print_table_ast.t

(** Use [enable_style=false] to disable the production of ANSI codes for styles,
    such as colors. By default [enable_style=true]. *)
val to_string : ?enable_style:bool -> t -> string
