(*_***************************************************************************)
(*_  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*_  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: ISC                                            *)
(*_***************************************************************************)

module List : sig
  include module type of struct
    include ListLabels
  end

  val filter_map : 'a t -> f:('a -> 'b option) -> 'b t
  val for_all : 'a t -> f:('a -> bool) -> bool
  val map : 'a t -> f:('a -> 'b) -> 'b t
end

module String : sig
  include module type of struct
    include StringLabels
  end

  val is_empty : t -> bool
end

val require : bool -> unit
