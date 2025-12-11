(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

open! Import

module Column = struct
  type t =
    { header : string
    ; align : Print_table_ast.Align.t
    ; cells : Print_table_ast.Cell.t array
    ; length : int
    }
end

type t = { columns : Column.t array }

let of_print_table (Print_table_ast.T { columns; rows }) =
  let columns =
    List.filter_map columns ~f:(fun { Print_table_ast.Column.header; align; make_cell } ->
      let cells = List.map rows ~f:(fun row -> make_cell row) in
      let length =
        List.fold_left cells ~init:0 ~f:(fun len (cell : Print_table_ast.Cell.t) ->
          Int.max len (String.length cell.text))
      in
      if length = 0
      then None
      else (
        let length = Int.max length (String.length header) in
        let cells = Array.of_list cells in
        Some { Column.header; align; cells; length }))
    |> Array.of_list
  in
  { columns }
;;

let pad ?ansi_code text ~len ~align =
  let slen = String.length text in
  let text =
    match ansi_code with
    | None -> text
    | Some ansi_code -> Printf.sprintf "\027[%dm%s\027[0m" ansi_code text
  in
  if slen >= len
  then text
  else (
    let pad = String.make (len - slen) ' ' in
    match (align : Print_table_ast.Align.t) with
    | Left -> text ^ pad
    | Right -> pad ^ text
    | Center ->
      let left = (len - slen) / 2 in
      let right = len - slen - left in
      String.make left ' ' ^ text ^ String.make right ' ')
;;
