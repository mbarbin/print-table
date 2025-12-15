(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

module List = struct
  include ListLabels

  let filter_map t ~f = filter_map ~f t
  let for_all t ~f = for_all ~f t
  let map t ~f = map ~f t
end

module String = struct
  include StringLabels

  let is_empty t = String.length t = 0
end

let require cond = if not cond then failwith "Required condition does not hold."
