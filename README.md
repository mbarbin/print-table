# print-table

[![CI Status](https://github.com/mbarbin/print-table/workflows/ci/badge.svg)](https://github.com/mbarbin/print-table/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/mbarbin/print-table/badge.svg?branch=main)](https://coveralls.io/github/mbarbin/print-table?branch=main)
[![OCaml-CI Build Status](https://img.shields.io/endpoint?url=https://ocaml.ci.dev/badge/mbarbin/print-table/main&logo=ocaml)](https://ocaml.ci.dev/github/mbarbin/print-table)

Print_table provides a minimal library for rendering text tables with Unicode box-drawing characters and optional ANSI colors:

```ocaml
# let columns =
  Print_table.O.
    [ Column.make ~header:"Name" (fun (name, _) -> Cell.text name)
    ; Column.make ~header:"Score" ~align:Right (fun (_, score) ->
        Cell.text (Int.to_string score))
    ]
val columns : (string * int) Print_table.Column.t list = [<abstr>; <abstr>]

# let rows = [ "Alice", 10; "Bob", 3 ] ;;
val rows : (string * int) list = [("Alice", 10); ("Bob", 3)]

# print_endline (Print_table.to_string_text (Print_table.make ~columns ~rows))
┌───────┬───────┐
│ Name  │ Score │
├───────┼───────┤
│ Alice │    10 │
│ Bob   │     3 │
└───────┴───────┘

- : unit = ()
```

Or as GitHub-flavored Markdown:

```ocaml
# print_endline (Print_table.to_string_markdown (Print_table.make ~columns ~rows))
| Name  | Score |
|:------|------:|
| Alice |    10 |
| Bob   |     3 |

- : unit = ()
```

which is rendered natively by GitHub like this:

| Name  | Score |
|:------|------:|
| Alice |    10 |
| Bob   |     3 |

## Code Documentation

The code documentation of the latest release is built with `odoc` and published to `GitHub` pages [here](https://mbarbin.github.io/print-table).

## Acknowledgments

This library has taken some inspiration from 2 existing and more feature-complete libraries, which we link to here for more advanced usages.

- [Printbox](https://github.com/c-cube/printbox)
- [Ascii_table](https://github.com/janestreet/textutils)
