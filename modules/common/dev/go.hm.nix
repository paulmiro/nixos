{
  config,
  lib,
  ...
}:
let
  enable = config.paul.dev.go;
in
{
  options.paul.dev.go = lib.mkEnableOption "enable go";

  config = lib.mkIf enable {
    programs.go = {
      enable = true;
    };
  };
}
