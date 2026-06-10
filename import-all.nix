{ lib, inputs, ... }:
let
  inherit (inputs) import-tree;
  inherit (lib)
    assertMsg
    filter
    hasSuffix
    length
    listToAttrs
    nameValuePair
    removeSuffix
    seq
    unique
    ;

  findDuplicates = list: filter (x: length (filter (y: y == x) list) > 1) (unique list);

  assertAllUnique =
    list: msg:
    let
      duplicates = findDuplicates list;
    in
    assert assertMsg (duplicates == [ ]) (msg + " duplicates: " + (toString duplicates));
    list;

  checkedListToAttrs = msg: list: seq (assertAllUnique (map (x: x.name) list) msg) (listToAttrs list);

  import-all =
    type:
    let
      suffix = ".${type}.nix";
    in
    import-tree

      (i: i.withLib lib)
      (i: i.initFilter (hasSuffix suffix))
      (i: i.map (path: nameValuePair (removeSuffix suffix (baseNameOf path)) path))
      (i: i.pipeTo (checkedListToAttrs "All \"*${suffix}\" files must have unique names."))
      ./modules;
in
import-all
