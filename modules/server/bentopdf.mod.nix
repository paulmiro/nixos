{
  config,
  lib,

  private,
  ...
}:
let
  cfg = config.paul.bentopdf;
  domain = private.domains.bentopdf;
in
{
  options.paul.bentopdf = {
    enable = lib.mkEnableOption "BentoPDF";
  };

  config = lib.mkIf cfg.enable {
    services.bentopdf = {
      enable = true;
      domain = domain;
      nginx = {
        enable = true;
      };
    };

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      enableDyndns = true;
    };
  };
}
