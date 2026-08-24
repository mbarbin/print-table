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

(* See the "Encoding" section of [Print_table]'s top-level doc comment for
   what is and isn't measured correctly here. *)

let utf8_columns =
  Print_table.O.
    [ Column.make ~header:"Text" (fun (text, _) -> Cell.text text)
    ; Column.make ~header:"Note" ~align:Right (fun (_, note) -> Cell.text note)
    ]
;;

let%expect_test "utf8 width - supported" =
  (* Each of these samples is made of codepoints that are 1 column wide, so
     counting codepoints (rather than bytes) is enough to measure and pad
     them correctly, even though most of them are multi-byte in UTF-8. *)
  print_endline "utf8 width - supported";
  let print_table =
    Print_table.make
      ~columns:utf8_columns
      ~rows:
        [ "cafe", "ascii, for reference"
        ; "café", "latin, accented letter"
        ; "Zürich", "latin, accented letter"
        ; "Привет", "cyrillic"
        ; "Ω", "greek"
        ; "✓", "symbol"
        ; "★", "symbol"
        ; "→", "symbol"
        ; "€", "symbol"
        ]
  in
  print_endline (Print_table.to_string_text print_table);
  [%expect
    {|
    utf8 width - supported
    ┌────────┬────────────────────────┐
    │ Text   │                   Note │
    ├────────┼────────────────────────┤
    │ cafe   │   ascii, for reference │
    │ café   │ latin, accented letter │
    │ Zürich │ latin, accented letter │
    │ Привет │               cyrillic │
    │ Ω      │                  greek │
    │ ✓      │                 symbol │
    │ ★      │                 symbol │
    │ →      │                 symbol │
    │ €      │                 symbol │
    └────────┴────────────────────────┘
    |}];
  ()
;;

let%expect_test "utf8 width - not supported" =
  (* These samples are known limitations: codepoint count still doesn't
     match the number of columns they occupy on screen, so alignment is not
     guaranteed. Kept here so a change in behavior (for better or worse) is
     visible in the diff of this test's expectation.

     A third documented category, multi-codepoint grapheme clusters (e.g.
     ZWJ-joined emoji), is deliberately not reproduced here as a literal
     string: how many columns such a sequence renders as is itself
     terminal/font-dependent (observed both 2 and 8 columns for the same
     family-emoji sequence across different terminals while working on
     this), so this expect-test's captured output would depend on whatever
     the CI machine's toolchain happens to do with it -- undercutting the
     point of pinning down "not supported" as a stable, reviewable
     snapshot. See the "Encoding" section of [Print_table]'s top-level doc
     comment for that category. *)
  print_endline "utf8 width - not supported";
  let print_table =
    Print_table.make
      ~columns:utf8_columns
      ~rows:
        [ "日本語", "east-asian wide characters: each codepoint is 2 columns, not 1"
        ; "e" ^ "\u{0301}", "combining mark: 2 codepoints (e + ´) render as 1 column"
        ]
  in
  print_endline (Print_table.to_string_text print_table);
  [%expect
    {|
    utf8 width - not supported
    ┌──────┬────────────────────────────────────────────────────────────────┐
    │ Text │                                                           Note │
    ├──────┼────────────────────────────────────────────────────────────────┤
    │ 日本語  │ east-asian wide characters: each codepoint is 2 columns, not 1 │
    │ é   │        combining mark: 2 codepoints (e + ´) render as 1 column │
    └──────┴────────────────────────────────────────────────────────────────┘
    |}];
  ()
;;

let%expect_test "utf8 width - manual override" =
  (* The same samples as "utf8 width - not supported" above, but this time
     the caller supplies the on-screen width themselves via [Cell.text]'s
     [~width], which is enough to restore alignment without this library
     having to understand East-Asian width or combining marks itself. (A
     ZWJ-joined emoji sample isn't included in either test: how many
     columns it renders as is itself terminal/font-dependent -- some
     terminals collapse it to a single double-width glyph, others draw each
     of its four components separately -- so there's no one [~width] that
     fixes it everywhere, and no single expected output that would be
     stable across CI machines. See the "Encoding" section of
     [Print_table]'s top-level doc comment for that category.) *)
  print_endline "utf8 width - manual override";
  let columns =
    Print_table.O.
      [ Column.make ~header:"Text" (fun (text, width, _) -> Cell.text ?width text)
      ; Column.make ~header:"Note" ~align:Right (fun (_, _, note) -> Cell.text note)
      ]
  in
  let print_table =
    Print_table.make
      ~columns
      ~rows:
        [ "日本語", Some 6, "east-asian wide: 3 codepoints, but 2 columns each"
        ; "e" ^ "\u{0301}", Some 1, "combining mark: 2 codepoints, but 1 column"
        ]
  in
  print_endline (Print_table.to_string_text print_table);
  [%expect
    {|
    utf8 width - manual override
    ┌────────┬───────────────────────────────────────────────────┐
    │ Text   │                                              Note │
    ├────────┼───────────────────────────────────────────────────┤
    │ 日本語 │ east-asian wide: 3 codepoints, but 2 columns each │
    │ é      │        combining mark: 2 codepoints, but 1 column │
    └────────┴───────────────────────────────────────────────────┘
    |}];
  ()
;;

let%expect_test "utf8 width - override determines the column's width, not just padding" =
  (* [~width] isn't just used to pad a cell's own text: it's what
     [Box.of_print_table] folds over to compute the column's width in the
     first place, so one cell's override can widen (or narrow) the whole
     column, and every other cell -- including ones without an override --
     gets padded against that. Using plain ASCII here keeps the point
     independent of how any terminal or font renders Unicode: ["x"] claims
     to be 20 columns wide despite being 1 character, and ["y"], which
     makes no such claim, still gets padded out to match. *)
  let columns =
    Print_table.O.
      [ Column.make ~header:"Text" (fun (text, width) -> Cell.text ?width text) ]
  in
  let print_table = Print_table.make ~columns ~rows:[ "x", Some 20; "y", None ] in
  print_endline (Print_table.to_string_text print_table);
  [%expect
    {|
    ┌──────────────────────┐
    │ Text                 │
    ├──────────────────────┤
    │ x │
    │ y                    │
    └──────────────────────┘
    |}];
  ()
;;
