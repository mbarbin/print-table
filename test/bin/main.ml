(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

let () =
  print_endline "style";
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
  print_string (Print_table.to_string_text print_table);
  ()
;;

(* The three tables below reproduce the "utf8 width - supported", "utf8
   width - not supported" and "utf8 width - manual override" expect-tests in
   [test/expect/test__print_table.ml], so they can be looked at directly in
   a terminal -- unlike the promoted expect-test output, this actually
   exercises how the characters render with your terminal and font. See the
   "Encoding" section of [Print_table]'s top-level doc comment for what this
   is demonstrating.

   Unlike the expect-tests, a ZWJ-joined emoji sample would be fine to
   reproduce here purely for eyeballing (this executable isn't compared
   against a captured snapshot) -- it's left out anyway, to keep this in
   sync with the samples the expect-tests actually cover. *)

let utf8_columns =
  Print_table.O.
    [ Column.make ~header:"Text" (fun (text, _) -> Cell.text text)
    ; Column.make ~header:"Note" ~align:Right (fun (_, note) -> Cell.text note)
    ]
;;

let () =
  print_endline "\nutf8 width - supported";
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
  print_string (Print_table.to_string_text print_table);
  ()
;;

let () =
  print_endline "\nutf8 width - not supported";
  let print_table =
    Print_table.make
      ~columns:utf8_columns
      ~rows:
        [ "日本語", "east-asian wide characters: each codepoint is 2 columns, not 1"
        ; "e" ^ "\u{0301}", "combining mark: 2 codepoints (e + ´) render as 1 column"
        ]
  in
  print_string (Print_table.to_string_text print_table);
  ()
;;

let () =
  print_endline "\nutf8 width - manual override";
  (* The same samples as "utf8 width - not supported" above, but this time
     the caller supplies the on-screen width themselves via [Cell.text]'s
     [~width], which is enough to restore alignment. *)
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
  print_string (Print_table.to_string_text print_table);
  ()
;;
