{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.claude;
in
{
  options.paul.claude = {
    enable = lib.mkEnableOption "claude-code";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.claude-code ];
  };
}
