(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

open! Import

let%expect_test "no columns!" =
  let print_table = Print_table.make ~columns:[] ~rows:[] in
  (* Ansi *)
  print_endline (Print_table.to_string_text print_table);
  [%expect {||}];
  (* GitHub Markdown *)
  print_endline (Print_table.to_string_markdown print_table);
  [%expect {||}];
  (* Ansi via Printbox. *)
  let printbox = Printbox_table.of_print_table print_table in
  print_endline (PrintBox_text.to_string printbox ^ "\n");
  [%expect
    {|
    ┬
    ┴
    |}];
  (* GitHub Markdown via Printbox. *)
  print_endline (Printbox_table.to_string_markdown printbox);
  [%expect
    {|
    |
    |
    |}];
  let with_md_config ~config =
    let md = PrintBox_md.to_string config printbox in
    print_endline (String.trim md ^ "\n")
  in
  (* Markdown via Printbox - default config. *)
  with_md_config ~config:PrintBox_md.Config.default;
  [%expect {| > |}];
  (* Markdown via Printbox - uniform config. *)
  with_md_config ~config:PrintBox_md.Config.uniform;
  [%expect
    {|
    ```
    ┬
    ┴
    ```
    |}];
  ()
;;

let%expect_test "example" =
  let columns =
    Print_table.O.
      [ Column.make ~header:"Name" (fun (name, _) -> Cell.text name)
      ; Column.make ~header:"Score" ~align:Right (fun (_, score) ->
          Cell.text (Int.to_string score))
      ]
  in
  let test rows =
    let print_table = Print_table.make ~columns ~rows in
    print_endline (Print_table.to_string_text print_table);
    print_endline (Print_table.to_string_markdown print_table)
  in
  test [ "Alice", 10; "Bob", 3 ];
  [%expect
    {|
    ┌───────┬───────┐
    │ Name  │ Score │
    ├───────┼───────┤
    │ Alice │    10 │
    │ Bob   │     3 │
    └───────┴───────┘

    | Name  | Score |
    |:------|------:|
    | Alice |    10 |
    | Bob   |     3 |
    |}]
;;

let%expect_test "style" =
  let columns =
    Print_table.O.
      [ Column.make ~header:"Name" (fun (name, _) -> Cell.text name)
      ; Column.make ~header:"Style" (fun (_, style) -> Cell.text ~style "v")
      ]
  in
  let print_table =
    Print_table.make
      ~columns
      ~rows:
        Print_table.O.
          [ "default", Style.default
          ; "fg_green", Style.fg_green
          ; "fg_rd", Style.fg_red
          ; "fg_yellow", Style.fg_yellow
          ; "dim", Style.dim
          ; "underscore", Style.underscore
          ]
  in
  print_endline (Print_table.to_string_text print_table);
  [%expect
    {|
    ┌────────────┬───────┐
    │ Name       │ Style │
    ├────────────┼───────┤
    │ default    │ v     │
    │ fg_green   │ [32mv[0m     │
    │ fg_rd      │ [31mv[0m     │
    │ fg_yellow  │ [33mv[0m     │
    │ dim        │ [2mv[0m     │
    │ underscore │ [4mv[0m     │
    └────────────┴───────┘
    |}];
  (* GitHub Markdown. *)
  print_endline (Print_table.to_string_markdown print_table);
  [%expect
    {|
    | Name       | Style |
    |:-----------|:------|
    | default    | v     |
    | fg_green   | v     |
    | fg_rd      | v     |
    | fg_yellow  | v     |
    | dim        | v     |
    | underscore | v     |
    |}];
  (* Ansi via Printbox. *)
  let printbox = Printbox_table.of_print_table print_table in
  print_endline (PrintBox_text.to_string printbox ^ "\n");
  [%expect
    {|
    ┌────────────┬───────┐
    │ Name       │ Style │
    ├────────────┼───────┤
    │ default    │ v     │
    │ fg_green   │ [32mv[0m     │
    │ fg_rd      │ [31mv[0m     │
    │ fg_yellow  │ [33mv[0m     │
    │ dim        │ v     │
    │ underscore │ v     │
    └────────────┴───────┘
    |}];
  ()
;;

let%expect_test "cell" =
  let cell = Print_table.Cell.empty in
  require (Print_table.Cell.is_empty cell);
  [%expect {||}];
  let cell = Print_table.Cell.text "" in
  require (Print_table.Cell.is_empty cell);
  [%expect {||}];
  let cell = Print_table.Cell.text "not empty!" in
  require (not (Print_table.Cell.is_empty cell));
  [%expect {||}];
  ()
;;

let%expect_test "print_table" =
  let columns =
    Print_table.O.
      [ Column.make ~header:"Name" (fun (name, _) -> Cell.text name)
      ; Column.make ~header:"Empty" (fun (_, _) -> Cell.empty)
      ; Column.make ~header:"Score" ~align:Right (fun (_, score) ->
          Cell.text
            ~style:(if score < 10 then Style.fg_red else Style.default)
            (Int.to_string score))
      ; Column.make ~header:"Stars" ~align:Center (fun (_, score) ->
          Cell.text (if score > 40 then "***" else if score > 10 then "*" else ""))
      ]
  in
  (* Test empty tables. *)
  let rows = [] in
  let print_table = Print_table.make ~columns ~rows in
  (* Ansi *)
  print_endline (Print_table.to_string_text print_table);
  [%expect {||}];
  (* GitHub Markdown *)
  print_endline (Print_table.to_string_markdown print_table);
  [%expect {||}];
  (* Ansi via Printbox. *)
  let printbox = Printbox_table.of_print_table print_table in
  print_endline (PrintBox_text.to_string printbox ^ "\n");
  [%expect
    {|
    ┬
    ┴
    |}];
  (* GitHub Markdown via Printbox. *)
  print_endline (Printbox_table.to_string_markdown printbox);
  [%expect
    {|
    |
    |
    |}];
  let with_md_config ~config =
    let md = PrintBox_md.to_string config printbox in
    print_endline (String.trim md ^ "\n")
  in
  (* Markdown via Printbox - default config. *)
  with_md_config ~config:PrintBox_md.Config.default;
  [%expect {| > |}];
  (* Markdown via Printbox - uniform config. *)
  with_md_config ~config:PrintBox_md.Config.uniform;
  [%expect
    {|
    ```
    ┬
    ┴
    ```
    |}];
  (* Not empty. *)
  let rows = [ "Alice", 42; "Bob", 7; "Eve", 13 ] in
  let print_table = Print_table.make ~columns ~rows in
  (* Ansi *)
  print_endline (Print_table.to_string_text print_table);
  [%expect
    {|
    ┌───────┬───────┬───────┐
    │ Name  │ Score │ Stars │
    ├───────┼───────┼───────┤
    │ Alice │    42 │  ***  │
    │ Bob   │     [31m7[0m │       │
    │ Eve   │    13 │   *   │
    └───────┴───────┴───────┘
    |}];
  print_endline (Print_table.to_string_text print_table ~enable_style:false);
  [%expect
    {|
    ┌───────┬───────┬───────┐
    │ Name  │ Score │ Stars │
    ├───────┼───────┼───────┤
    │ Alice │    42 │  ***  │
    │ Bob   │     7 │       │
    │ Eve   │    13 │   *   │
    └───────┴───────┴───────┘
    |}];
  (* GitHub Markdown *)
  print_endline (Print_table.to_string_markdown print_table);
  [%expect
    {|
    | Name  | Score | Stars |
    |:------|------:|:-----:|
    | Alice |    42 |  ***  |
    | Bob   |     7 |       |
    | Eve   |    13 |   *   |
    |}];
  (* Ansi via Printbox. *)
  let printbox = Printbox_table.of_print_table print_table in
  print_endline (PrintBox_text.to_string printbox ^ "\n");
  [%expect
    {|
    ┌───────┬───────┬───────┐
    │ Name  │ Score │ Stars │
    ├───────┼───────┼───────┤
    │ Alice │    42 │  ***  │
    │ Bob   │     [31m7[0m │       │
    │ Eve   │    13 │   *   │
    └───────┴───────┴───────┘
    |}];
  (* GitHub Markdown via Printbox. *)
  print_endline (Printbox_table.to_string_markdown printbox);
  [%expect
    {|
    |-------|-------|-------|
    | Name  | Score | Stars |
    |-------|-------|-------|
    | Alice |    42 |  ***  |
    | Bob   |     [31m7[0m |       |
    | Eve   |    13 |   *   |
    |-------|-------|-------|
    |}];
  let with_md_config ~config =
    let md = PrintBox_md.to_string config printbox in
    print_endline (String.trim md ^ "\n")
  in
  (* Markdown via Printbox - default config. *)
  with_md_config ~config:PrintBox_md.Config.default;
  [%expect
    {|
    >
    > ```
    >  Name  │ Score │ Stars
    > ───────┼───────┼───────
    >  Alice │    42 │  ***
    >  Bob   │     7 │
    >  Eve   │    13 │   *
    > ```
    >
    >
    >
    |}];
  (* Markdown via Printbox - uniform config. *)
  with_md_config ~config:PrintBox_md.Config.uniform;
  [%expect
    {|
    ```
    ┌───────┬───────┬───────┐
    │ Name  │ Score │ Stars │
    ├───────┼───────┼───────┤
    │ Alice │    42 │  ***  │
    │ Bob   │     7 │       │
    │ Eve   │    13 │   *   │
    └───────┴───────┴───────┘
    ```
    |}];
  ()
;;
