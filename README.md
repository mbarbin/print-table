# print-table

[![CI Status](https://github.com/mbarbin/print-table/workflows/ci/badge.svg)](https://github.com/mbarbin/print-table/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/mbarbin/print-table/badge.svg?branch=main)](https://coveralls.io/github/mbarbin/print-table?branch=main)
[![OCaml-CI Build Status](https://img.shields.io/endpoint?url=https://ocaml.ci.dev/badge/mbarbin/print-table/main&logo=ocaml)](https://ocaml.ci.dev/github/mbarbin/print-table)

Print_table provides a minimal library for rendering text tables with Unicode
box-drawing characters and optional ANSI colors:

```ocaml
type row = string * int

let columns : row Print_table.Column.t list =
  Print_table.O.
    [ Column.make ~header:"Name" (fun (name, _) -> Cell.text name)
    ; Column.make ~header:"Score" ~align:Right (fun (_, score) ->
        Cell.text (Int.to_string score))
    ]
;;

let rows : row list = [ "Alice", 10; "Bob", 3 ]
let table : Print_table.t = Print_table.make ~columns ~rows

let%expect_test "to_string_text" =
  print_endline (Print_table.to_string_text table);
  [%expect
    {|
    ┌───────┬───────┐
    │ Name  │ Score │
    ├───────┼───────┤
    │ Alice │    10 │
    │ Bob   │     3 │
    └───────┴───────┘
    |}]
;;
```

Tables can be printed as Github-flavored Markdown:

```ocaml
let%expect_test "to_string_markdown" =
  print_endline (Print_table.to_string_markdown table);
  [%expect
    {|
    | Name  | Score |
    |:------|------:|
    | Alice |    10 |
    | Bob   |     3 |
    |}]
;;
```

which is rendered natively by GitHub like this:

| Name  | Score |
|:------|------:|
| Alice |    10 |
| Bob   |     3 |

## Encoding

Cell and header text is expected to be valid UTF-8. Column widths are
computed by counting Unicode codepoints, on the assumption that each
codepoint occupies exactly one column in a monospace font or terminal.
This holds for ASCII, accented Latin letters, Greek and Cyrillic letters,
and narrow symbols such as `✓`, `★`, `→` or `€`, but not for East-Asian
"fullwidth" characters, combining marks, or multi-codepoint grapheme
clusters such as some emoji sequences -- see the `print_table.mli` for
details, and `test/expect/test__print_table.ml` for examples of what is,
and isn't, correctly measured.

This caveat is about the literal characters produced by `to_string_text`
and by `to_string_markdown`'s source, as read verbatim in a monospace
font. It doesn't apply to how `to_string_markdown`'s output looks once
rendered by a Markdown engine: GitHub (and other conformant renderers)
lay out table columns from the parsed cell contents rather than from the
padding in the source, so wide characters, combining marks and
multi-codepoint emoji are typically displayed correctly there regardless
of this library's own column measurement.

For example, here's a two-column table using two of the "not supported"
samples above, handwritten directly into this README as raw Markdown
with no padding at all -- not produced by print-table:

```markdown
|Symbol|Rendering|
|-|-|
|日|✅|
|é|✅|
```

GitHub still renders it perfectly, because it lays out the columns
itself from the parsed cells, padding or no padding:

|Symbol|Rendering|
|-|-|
|日|✅|
|é|✅|

For `to_string_text` (or a fenced-code-block `to_string_markdown`), where
this does matter, `Cell.text`'s optional `~width` argument is an escape
hatch: pass the on-screen column count yourself and it overrides the
automatic measurement for that cell.

## Code Documentation

The code documentation of the latest release is built with `odoc` and
published to `GitHub` pages [here](https://mbarbin.github.io/print-table).

## Acknowledgments

This library has taken some inspiration from 2 existing and more
feature-complete libraries, which we link to here for more advanced usages.

- [Printbox](https://github.com/c-cube/printbox)
- [Ascii_table](https://github.com/janestreet/textutils)
