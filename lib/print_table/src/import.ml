(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

module Array = struct
  include ArrayLabels
end

module List = struct
  include ListLabels

  let is_empty = function
    | [] -> true
    | _ :: _ -> false
  ;;
end
