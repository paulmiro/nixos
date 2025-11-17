{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.filebrowser-quantum;
  serviceName = "filebrowser-quantum";
  package = pkgs.paulmiro.filebrowser-quantum;
  configFile = pkgs.writeText "config.yaml" (lib.generators.toYAML cfg.config);
in
{
  # TODO: rename to filebrowser?

  imports = [
    ./config.nix
  ];

  options.paul.filebrowser-quantum = {
    enable = lib.mkEnableOption "activate filebrowser-quantum";
    enableNginx = lib.mkEnableOption "activate nginx proxy for filebrowser-quantum";
    openTailscaleFirewall = lib.mkEnableOption "open firewall for filebrowser-quantum";
  };

  config = lib.mkIf cfg.enable {
    users.users.filebrowser-quantum = {
      description = "filebrowser-quantum user";
      group = "filebrowser-quantum";
      extraGroups = lib.mkIf config.paul.groups.transmission.enable [
        config.paul.groups.transmission.name
      ];
    };

    users.groups.filebrowser-quantum = { };

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
        User = config.users.users.filebrowser-quantum.name;
        Group = config.users.groups.filebrowser-quantum.name;
        StateDirectory = "filebrowser-quantum";
        ExecStart = "${package}/bin/filebrowser -c ${configFile}";
        Restart = "on-failure";
      };
    };

    clan.core.vars.generators.filebrowser-quantum = {
      prompts.admin-password.description = "filebrowser-quantum Admin Password (see bw)";
      prompts.admin-password.type = "hidden";
      prompts.admin-password.persist = false;

      files.env.secret = true;
      files.env.owner = "filebrowser-quantum"; # TODO: make filebrowser-quantum run as paulmiro?

      script = ''
        echo "
        FILEBROWSER_ADMIN_PASSWORD="$(cat $prompts/admin-password)"
        " > $out/env
      '';
    };

    clan.core.state.filebrowser-quantum = {
      useZfsSnapshots = true;
      folders = [
        "/var/lib/filebrowser-quantum"
        # TODO: more?
      ];
      servicesToStop = [ "${serviceName}.service" ];
    };

    networking.firewall.interfaces."tailscale".allowedTCPPorts = lib.mkIf cfg.openTailscaleFirewall [
      cfg.config.server.port
    ];

    services.nginx.virtualHosts."${cfg.config.server.externalDomain}" = lib.mkIf cfg.enableNginx {
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
