(*_***************************************************************************)
(*_  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*_  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: ISC                                            *)
(*_***************************************************************************)

(** Simple Unicode/ANSI and Markdown text table rendering.

    Example of output:

    {ul
     {- Text:
        {v
         ┌───────┬───────┐
         │ Name  │ Score │
         ├───────┼───────┤
         │ Alice │    10 │
         │ Bob   │     3 │
         └───────┴───────┘
        v}
     }
    }

    {ul
     {- Markdown:
        {v
         | Name  | Score |
         |:------|------:|
         | Alice |    10 |
         | Bob   |     3 |
        v}
     }
    } *)

(** A [t] is an immutable value representing a table ready to be rendered. *)
type t

(** {1 Render}

    The library allows to print tables in several formats, see below. *)

(** Returns a string rendering for a table in text, using Unicode borders and
    ANSI colors for the style contents of the cells. This is suitable for
    printing to the terminal. This returns the empty string if the table has no
    columns or no rows. Use [enable_style=false] to disable the production of
    ANSI codes for styles, such as colors. By default [enable_style=true]. *)
val to_string_text : ?enable_style:bool -> t -> string

(** Returns a string rendering for a table in GitHub-flavored Markdown format.
    Note that because we couldn't find a way to render to GitHub in a way that
    support the color output, this printer ignores all [Style.t] settings and
    behaves as if each cell was created with [Style.default]. This returns the
    empty string if the table has no columns or no rows. *)
val to_string_markdown : t -> string

(** {1 Builders} *)

module Style : sig
  (** This allows to add style, such as coloring, for the contents of the cells.
      Styles are ignored when rendering to markdown. *)

  type t

  (** [default] results in no style. This is what is used by default. *)
  val default : t

  (** {1 Foreground colors} *)

  val fg_green : t
  val fg_red : t
  val fg_yellow : t
  val dim : t
  val underscore : t
end

module Cell : sig
  type t

  (** A cell with no contents. *)
  val empty : t

  (** Returns [true] if the cell has no contents. This means either it is
      [empty] or it was created with [text] on an empty string input. *)
  val is_empty : t -> bool

  (** [text ?style contents] is the way to create a cell with the given style
      and contents. *)
  val text : ?style:Style.t -> string -> t
end

module Align : sig
  (** This controls the alignment of the contents of the cell within a column. *)

  type t =
    | Left
    | Center
    | Right
end

module Column : sig
  (** A type for a column extractor, parameterized by the type of the rows. Each
      ['row] value represents an individual row in the table. *)
  type 'row t

  (** [make ~header ?aligh f] declares a new column with [header]. The alignment
      defaults to [Left]. [f] is the function that should take care and
      encapsulate the knowledge of how the contents for this [column] is
      extracted and created for a given [row]. It is not immediately called but
      rather will be called during rendering (and thus if [f] raises, these
      exceptions will happen during the rendering part). *)
  val make : header:string -> ?align:Align.t -> ('a -> Cell.t) -> 'a t
end

val make : columns:'a Column.t list -> rows:'a list -> t

(** {2 Scope manipulation}

    The intended usage is for the module [Print_table.O] to be open locally near
    a piece of code that creates the columns. For example:

    {[
      let columns : (string * int) Print_table.Column.t list =
        Print_table.O.
          [ Column.make ~header:"Name" (fun (name, _) -> Cell.text name)
          ; Column.make ~header:"Score" ~align:Right (fun (_, score) ->
              Cell.text (Int.to_string score))
          ]
      ;;
    ]} *)

module O : sig
  module Align = Align
  module Cell = Cell
  module Column = Column
  module Style = Style
end

(** {1 Private}

    This module is exported to be used by tests and libraries with strong ties
    to [print_table]. Its signature may change in breaking ways at any time
    without prior notice, and outside of the guidelines set by semver. Do not
    use. *)

module Private : sig
  module Ast = Print_table_ast

  val to_ast : t -> Ast.t
end
