{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ftb-server-installer";
  version = "1.0.49";

  src = fetchurl {
    url = "https://github.com/FTBTeam/FTB-Server-Installer/releases/download/v${finalAttrs.version}/ftb-server-linux-amd64";
    hash = "sha256-tkVL6bD+I+IMbJ2Y/x8RYhzvBvlPuCRPyTf7bsVvx50=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/ftb-server-installer
    runHook postInstall
  '';

  meta = {
    description = "FTB modpack server installer";
    homepage = "https://github.com/FTBTeam/FTB-Server-Installer";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "ftb-server-installer";
  };
})
