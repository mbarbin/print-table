(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

open! Import

type t = Print_table_ast.t

let to_string_non_empty t =
  let buffer = Buffer.create 128 in
  let box = Box.of_print_table t in
  let columns = box.columns in
  let columns_count = Array.length columns in
  (* Header row *)
  Buffer.add_char buffer '|';
  Array.iter columns ~f:(fun { Box.Column.header; align; cells = _; length } ->
    Buffer.add_char buffer ' ';
    Buffer.add_string buffer (Box.pad header ~len:length ~align);
    Buffer.add_char buffer ' ';
    Buffer.add_char buffer '|');
  Buffer.add_char buffer '\n';
  (* Alignment row *)
  Buffer.add_char buffer '|';
  Array.iter columns ~f:(fun { Box.Column.header = _; align; cells = _; length } ->
    let spec =
      match align with
      | Left -> ":" ^ String.make (length + 1) '-'
      | Right -> String.make (length + 1) '-' ^ ":"
      | Center -> ":" ^ String.make length '-' ^ ":"
    in
    Buffer.add_string buffer spec;
    Buffer.add_char buffer '|');
  Buffer.add_char buffer '\n';
  (* Rows *)
  let n_rows =
    if columns_count = 0
    then assert false [@coverage off]
    else Array.length columns.(0).cells
  in
  for i = 0 to n_rows - 1 do
    Buffer.add_char buffer '|';
    Array.iter columns ~f:(fun { Box.Column.header = _; align; cells; length } ->
      (* Thanks to invariant from Box: all cells have the same length. *)
      let { Print_table_ast.Cell.text; style } = cells.(i) in
      let () =
        match style with
        | Default | Fg_green | Fg_red | Fg_yellow ->
          (* There is no support for controlling colors in the GitHub Markdown
             syntax. We simply do not render them. *)
          ()
      in
      Buffer.add_char buffer ' ';
      Buffer.add_string buffer (Box.pad text ~len:length ~align);
      Buffer.add_char buffer ' ';
      Buffer.add_char buffer '|');
    Buffer.add_char buffer '\n'
  done;
  Buffer.contents buffer
;;

let to_string (Print_table_ast.T { rows; columns } as t) =
  if List.is_empty columns || List.is_empty rows then "" else to_string_non_empty t
;;
