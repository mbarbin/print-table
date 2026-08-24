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

(* The number of terminal columns [s] occupies, as opposed to
   [String.length]'s byte count: a UTF-8 character outside of ASCII (a
   checkmark, an accented letter, ...) encodes as 2-4 bytes but still
   occupies a single column in a monospace terminal. Continuation bytes
   (the [0b10xxxxxx] ones) don't start a new codepoint, so counting the
   bytes that aren't continuation bytes counts codepoints instead.

   This doesn't account for East-Asian wide characters (which occupy two
   columns), combining marks (which occupy zero), or multi-codepoint
   grapheme clusters such as ZWJ-joined emoji -- see the "Encoding" section
   of [Print_table]'s top-level doc comment for what is and isn't measured
   correctly.

   We considered depending on [uucp] for [Uucp.Break.tty_width_hint], which
   does read the East-Asian-width and combining-mark properties and would
   narrow the first two gaps above. We didn't: it doesn't segment grapheme
   clusters either, so ZWJ emoji stay unsupported regardless, and its own
   documentation describes it as "mostly wrong" -- terminals disagree with
   each other on it. Given it can't turn "not supported" into a guarantee,
   it isn't worth the two extra dependencies (plus [uucp]'s compiled
   Unicode Character Database) for a table-borders library; [Cell.text]'s
   [~width] escape hatch covers the cases that matter to a caller without
   that. *)
let utf8_length s =
  let count = ref 0 in
  String.iter s ~f:(fun c ->
    if Char.code c land 0b1100_0000 <> 0b1000_0000 then incr count);
  !count
;;

(* [cell.width], the escape hatch documented on [Print_table.Cell.text],
   overrides [utf8_length cell.text] when the caller supplied one. *)
let cell_width (cell : Print_table_ast.Cell.t) =
  match cell.width with
  | Some width -> width
  | None -> utf8_length cell.text
;;

let of_print_table (Print_table_ast.T { columns; rows }) =
  let columns =
    List.filter_map columns ~f:(fun { Print_table_ast.Column.header; align; make_cell } ->
      let cells = List.map rows ~f:(fun row -> make_cell row) in
      let length =
        List.fold_left cells ~init:0 ~f:(fun len cell -> Int.max len (cell_width cell))
      in
      if length = 0
      then None
      else (
        let length = Int.max length (utf8_length header) in
        let cells = Array.of_list cells in
        Some { Column.header; align; cells; length }))
    |> Array.of_list
  in
  { columns }
;;

let pad ?ansi_code ?width text ~len ~align =
  let slen =
    match width with
    | Some width -> width
    | None -> utf8_length text
  in
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
