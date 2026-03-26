(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

(* @mdexp

   # print-table

   [![CI Status](https://github.com/mbarbin/print-table/workflows/ci/badge.svg)](https://github.com/mbarbin/print-table/actions/workflows/ci.yml)
   [![Coverage Status](https://coveralls.io/repos/github/mbarbin/print-table/badge.svg?branch=main)](https://coveralls.io/github/mbarbin/print-table?branch=main)
   [![OCaml-CI Build Status](https://img.shields.io/endpoint?url=https://ocaml.ci.dev/badge/mbarbin/print-table/main&logo=ocaml)](https://ocaml.ci.dev/github/mbarbin/print-table)

   Print_table provides a minimal library for rendering text tables with Unicode
   box-drawing characters and optional ANSI colors: *)

(* @mdexp.code *)

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

(* @mdexp

   Tables can be printed as Github-flavored Markdown: *)

(* @mdexp.code *)

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

(* @mdexp

   which is rendered natively by GitHub like this: *)

let%expect_test "snapshot" =
  print_endline (Print_table.to_string_markdown table);
  (* @mdexp.snapshot *)
  [%expect
    {|
    | Name  | Score |
    |:------|------:|
    | Alice |    10 |
    | Bob   |     3 |
    |}];
  ()
;;

(* @mdexp

   ## Code Documentation

   The code documentation of the latest release is built with `odoc` and
   published to `GitHub` pages [here](https://mbarbin.github.io/print-table).

   ## Acknowledgments

   This library has taken some inspiration from 2 existing and more
   feature-complete libraries, which we link to here for more advanced usages.

   - [Printbox](https://github.com/c-cube/printbox)
   - [Ascii_table](https://github.com/janestreet/textutils)
*)
