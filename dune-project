(lang dune 3.17)

(name print-table)

(generate_opam_files)

(license ISC)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/print-table))

(documentation "https://mbarbin.github.io/print-table/")

(using mdx 0.4)

;; The value for the [implicit_transtive_deps] option is set during the CI
;; depending on the OCaml compiler version.
;;
;; This will be set to [false] iif [ocaml-version >= 5.2].
;;
;; For packaging purposes with older ocaml, it is simpler atm if the option is
;; set to [true] in the main branch.
;;
;; See: [.github/workflows/edit_dune_project_dot_ml].

(implicit_transitive_deps true)

(package
 (name print-table)
 (synopsis "Simple Unicode/ANSI and Markdown text table rendering")
 (depends
  (ocaml
   (>= 4.14))))

(package
 (name print-table-tests)
 (synopsis "Tests for print-table")
 (depends
  (ocaml
   (>= 4.14))
  (ppx_expect
   (>= v0.16))
  (ppxlib
   (>= 0.33))
  (print-table
   (= :version))
  (printbox
   (>= 0.12))
  (printbox-md
   (>= 0.12))
  (printbox-text
   (>= 0.12))
  (uutf
   (>= 1.0.4))))

(package
 (name print-table-dev)
 (synopsis "Package to regroup dev targets, documentation, and more")
 (allow_empty)
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (= 0.28.1))
  (bisect_ppx
   (>= 2.8.3))
  (mdx
   (>= 2.4))
  (ppx_expect
   (>= v0.17))
  (ppx_js_style
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (print-table
   (= :version))
  (print-table-tests
   (= :version))
  (printbox
   (>= 0.12))
  (printbox-md
   (>= 0.12))
  (printbox-text
   (>= 0.12))
  (uutf
   (>= 1.0.4))
  (sherlodoc
   (>= 0.2))))
