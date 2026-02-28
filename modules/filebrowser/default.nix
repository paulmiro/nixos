{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.filebrowser;
  serviceName = "filebrowser-quantum";
  package = pkgs.paulmiro.filebrowser-quantum;
  configFile = pkgs.writeText "config.yaml" (lib.generators.toYAML { } cfg.config);
in
{
  imports = [
    ./config.nix
  ];

  options.paul.filebrowser = {
    enable = lib.mkEnableOption "activate filebrowser";
    enableNginx = lib.mkEnableOption "activate nginx proxy for filebrowser";
  };

  config = lib.mkIf cfg.enable {
    users.users.filebrowser = {
      description = "FileBrowser Quantum";
      isSystemUser = true;
      group = "filebrowser";
      extraGroups = lib.mkIf config.paul.group.transmission.enable [
        config.users.groups.transmission.name
      ];
    };

    users.groups.filebrowser = { };

    systemd.services.${serviceName} = {
      # TODO: take (most of) the setup from the official nixos module
      description = "FileBrowser Quantum";
      wantedBy = [
        "multi-user.target"
      ];
      after = [
        "network.target"
      ]
      ++ lib.optionals (config.paul.zfs.enable) [
        "zfs.target"
      ];
      serviceConfig = {
        Type = "simple";
        User = config.users.users.filebrowser.name;
        Group = config.users.groups.filebrowser.name;
        CacheDirectory = "filebrowser";
        StateDirectory = "filebrowser";
        WorkingDirectory = "/var/lib/filebrowser";
        ExecStart = "${package}/bin/filebrowser -c ${configFile}";
        Restart = "on-failure";
      };
    };

    clan.core.vars.generators.filebrowser = {
      prompts.admin-password.description = "filebrowser Admin Password (see bw)";
      prompts.admin-password.type = "hidden";
      prompts.admin-password.persist = false;

      files.env.secret = true;
      files.env.owner = "filebrowser"; # TODO: make filebrowser run as paulmiro?

      script = ''
        echo "
        FILEBROWSER_ADMIN_PASSWORD="$(cat $prompts/admin-password)"
        " > $out/env
      '';
    };

    clan.core.state.filebrowser = {
      useZfsSnapshots = true;
      folders = [
        "/var/lib/filebrowser"
        # TODO: more?
      ];
      servicesToStop = [ "${serviceName}.service" ];
    };

    services.nginx.virtualHosts."${config.paul.private.domains.filebrowser}" =
      lib.mkIf cfg.enableNginx
        {
          enableACME = true;
          forceSSL = true;
          enableDyndns = cfg.enableDyndns;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.config.server.port}";
            geo-ip = true;
            proxyWebsockets = true;
          };
        };
  };

}
