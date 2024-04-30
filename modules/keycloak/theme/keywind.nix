{ stdenv }:
stdenv.mkDerivation rec {
  name = "keywind";
  version = "1.0";

  src = ./keywind;

  nativeBuildInputs = [ ];
  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp -a login $out
  '';
}
