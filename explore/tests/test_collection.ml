(* open Core *)
open Explore
module W = Collection.Workflow

let relation =
  let module E = struct
    type t = [ `Msg of string ]

    let pp ppf = function
      | `Msg m -> Format.pp_print_string ppf m
      | _ -> assert false

    let equal a b =
      match (a, b) with `Msg m, `Msg n -> String.equal m n | _ -> false
  end in
  (module E : Alcotest.TESTABLE with type t = E.t)

let test_getters () =
  let yaml = Alcotest.testable Yaml.pp Yaml.equal in
  let pp_res ppf (p : W.resource) =
    Format.pp_print_string ppf
      (p.title ^ " " ^ p.description ^ " " ^ p.url ^ " ")
  in
  let equal_res = Stdlib.( = ) in
  let resource = Alcotest.testable pp_res equal_res in
  let path = "adding-unit-tests-to-your-project.md" in
  let s = Files.read_file path in
  let v = Collection.Workflow.v ~path ~content:s in
  Alcotest.(check string)
    "get title" "Adding Unit Tests to your Project" (W.get_title v);
  Alcotest.(check string)
    "get date non textual" "2020-07-27 09:35:49 +00:00"
    (W.get_date ~textual:false v);
  Alcotest.(check string)
    "get date non textual" "27, July 2020 at 09:35:49"
    (W.get_date ~textual:true v);
  Alcotest.(check string)
    "get description" "Add unit tests" (W.get_description v);
  Alcotest.(check (result (list yaml) relation))
    "failed prop"
    (Ok [ `String "Library Authors"; `String "Application Developers" ])
    (W.get_relations "users" v);
  Alcotest.(check (list resource))
    "get resources"
    [ { title = "OCaml"; description = "abcd"; url = "https://ocaml.org" } ]
    (W.get_resources v)

let tests = [ ("test_getters", `Quick, test_getters) ]
