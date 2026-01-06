{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.pyload;
  port = 19107;
in
{
  options.paul.pyload = {
    enable = lib.mkEnableOption "enable pyload";
    enableTailscaleService = lib.mkEnableOption "enable tailscale service for pyload";
  };

  config = lib.mkIf cfg.enable {
    services.pyload = {
      enable = true;
      inherit port;
      listenAddress = "127.0.0.1";
      group = "transmission";
      credentialsFile = config.clan.core.vars.generators.pyload.files.env.path;
      downloadDirectory = "/mnt/arr/pyload";
    };

    clan.core.vars.generators.pyload = {
      prompts.password.description = "pyLoad Password (see bw)";
      prompts.password.type = "hidden";
      prompts.password.persist = false;

      files.env.secret = true;

      script = ''
        echo "
        PYLOAD_DEFAULT_USERNAME=admin
        PYLOAD_DEFAULT_PASSWORD="$(cat $prompts/password)"
        " > $out/env
      '';
    };

    paul.tailscale.services.pyload.port = lib.mkIf cfg.enableTailscaleService port;

    clan.core.state.pyload = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/pyload" ];
      servicesToStop = [ "pyload.service" ];
    };
  };
}
