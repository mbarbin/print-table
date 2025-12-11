(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

let () =
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
