(*_***************************************************************************)
(*_  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*_  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: ISC                                            *)
(*_***************************************************************************)

module Array : sig
  include module type of ArrayLabels
end

module List : sig
  include module type of ListLabels

  val is_empty : _ t -> bool
end
