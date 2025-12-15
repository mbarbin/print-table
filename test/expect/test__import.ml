(****************************************************************************)
(*  print-table - Simple Unicode/ANSI and Markdown text table rendering     *)
(*  SPDX-FileCopyrightText: 2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: ISC                                            *)
(****************************************************************************)

open! Import

let%expect_test "require" =
  (match require false with
   | () -> assert false
   | exception exn -> print_endline (Printexc.to_string exn));
  [%expect {| Failure("Required condition does not hold.") |}];
  ()
;;
