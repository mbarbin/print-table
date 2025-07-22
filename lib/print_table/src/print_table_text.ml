(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

open! Import

type t = Print_table_ast.t

let repeat c n = List.init ~len:n ~f:(fun _ -> c) |> String.concat ""

let to_string_non_empty ?(enable_style = true) t =
  let box = Box.of_print_table t in
  let buffer = Buffer.create 128 in
  let columns = box.columns in
  let columns_count = Array.length columns in
  let draw_line left sep right fill =
    Buffer.add_string buffer left;
    Array.iteri columns ~f:(fun i (column : Box.Column.t) ->
      if i > 0 then Buffer.add_string buffer sep;
      Buffer.add_string buffer (repeat fill (column.length + 2)));
    Buffer.add_string buffer right;
    Buffer.add_char buffer '\n'
  in
  (* Top border *)
  draw_line "┌" "┬" "┐" "─";
  (* Header row *)
  Buffer.add_string buffer "│";
  Array.iter columns ~f:(fun { Box.Column.header; align; cells = _; length } ->
    Buffer.add_char buffer ' ';
    Buffer.add_string buffer (Box.pad header ~len:length ~align);
    Buffer.add_char buffer ' ';
    Buffer.add_string buffer "│");
  Buffer.add_char buffer '\n';
  (* Header separator *)
  draw_line "├" "┼" "┤" "─";
  (* Rows *)
  let num_rows =
    if columns_count = 0
    then assert false [@coverage off]
    else Array.length columns.(0).cells
  in
  for i = 0 to num_rows - 1 do
    Buffer.add_string buffer "│";
    Array.iter columns ~f:(fun { Box.Column.header = _; align; cells; length } ->
      (* Thanks to invariant from Box: all cells have the same length. *)
      let { Print_table_ast.Cell.text; style } = cells.(i) in
      Buffer.add_char buffer ' ';
      let add_colored_text color_code =
        Buffer.add_string buffer color_code;
        Buffer.add_string buffer (Box.pad text ~len:length ~align);
        Buffer.add_string buffer "\027[0m"
      in
      (match if enable_style then style else Print_table_ast.Style.Default with
       | Default -> Buffer.add_string buffer (Box.pad text ~len:length ~align)
       | Fg_red -> add_colored_text "\027[31m"
       | Fg_green -> add_colored_text "\027[32m"
       | Fg_yellow -> add_colored_text "\027[33m"
       | Dim -> add_colored_text "\027[2m"
       | Underscore -> add_colored_text "\027[4m");
      Buffer.add_char buffer ' ';
      Buffer.add_string buffer "│");
    Buffer.add_char buffer '\n'
  done;
  (* Bottom border *)
  draw_line "└" "┴" "┘" "─";
  Buffer.contents buffer
;;

let to_string ?enable_style (Print_table_ast.T { rows; columns } as t) =
  if List.is_empty columns || List.is_empty rows
  then ""
  else to_string_non_empty ?enable_style t
;;
