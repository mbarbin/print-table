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
    }

    {1 Encoding}

    Cell and header text is expected to be valid UTF-8. Column widths are
    computed by counting Unicode codepoints, on the assumption that each
    codepoint occupies exactly one column when displayed in a monospace font
    or terminal. This holds for the text this library is designed to render:
    ASCII, accented Latin letters, Greek and Cyrillic letters, and narrow
    symbols such as [✓], [★], [→] or [€].

    It does not hold for:
    - East-Asian "fullwidth" characters (for example CJK ideographs), which
      occupy two columns per codepoint rather than one;
    - combining marks (for example a base letter followed by a combining
      accent), which occupy zero columns of their own;
    - multi-codepoint grapheme clusters, such as emoji joined with
      zero-width joiners or followed by variation selectors, which render as
      a single glyph made of several codepoints.

    Cells holding such text are still rendered without raising, but the
    resulting columns and borders may not line up. See the ["utf8 width"]
    tests in [test/expect/test__print_table.ml] for examples of what is, and
    isn't, correctly measured.

    This caveat is about the literal characters this library produces, as
    read verbatim in a monospace font (which is what [to_string_text] is
    for, and what [to_string_markdown]'s source looks like e.g. inside a
    fenced code block). It doesn't apply to how [to_string_markdown]'s
    output looks once rendered by a Markdown engine: GitHub (and other
    conformant renderers) lay out table columns from the parsed cell
    contents rather than from the padding in the source, so wide characters,
    combining marks and multi-codepoint emoji are typically displayed
    correctly there regardless of this library's own column measurement.

    For [to_string_text] (or a fenced-code-block [to_string_markdown]),
    where this does matter, [Cell.text]'s optional [~width] argument is an
    escape hatch: pass the on-screen column count yourself and it overrides
    the automatic measurement for that cell. *)

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
    empty string if the table has no columns or no rows. The generated source
    is padded for readability but a Markdown renderer computes its own column
    layout, so the "Encoding" caveats above about literal column alignment do
    not carry over to the rendered table. *)
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

  (** [text ?style ?width contents] is the way to create a cell with the given
      style and contents. [contents] is expected to be valid UTF-8; see the
      "Encoding" section above for what is and isn't correctly measured when
      computing column widths.

      [width], when supplied, is the number of terminal columns [contents]
      occupies, and overrides the library's own codepoint-based measurement
      for this cell. This is an escape hatch for the cases the "Encoding"
      section calls out as unsupported: if [contents] holds, say, East-Asian
      wide characters or an emoji sequence, and the caller can compute (or
      already knows) how many columns it actually takes up on screen, passing
      it here restores correct alignment without this library having to grow
      a dependency on a Unicode width table. Defaults to [None], i.e. the
      automatic measurement described in "Encoding". *)
  val text : ?style:Style.t -> ?width:int -> string -> t
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

  (** [make ~header ?align f] declares a new column with [header]. The alignment
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
    a piece of code that creates the columns. For an example, see the project's
    README.md file. *)

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
