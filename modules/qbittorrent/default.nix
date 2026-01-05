{
  config,
  lib,
  ...
}:
let
  cfg = config.paul.qbittorrent;
  webuiPort = 8090;
  privoxyPort = 8118;
  socksPort = 9118;
  serviceName = "qbittorrent-vpn-docker";
in
{
  options.paul.qbittorrent = {
    enable = lib.mkEnableOption "activate qbittorrent";
    containerVersion = lib.mkOption {
      type = lib.types.str;
      default = "5.1.4-1-01";
      description = "qbittorrent container version";
    };

    enableTailscaleService = lib.mkEnableOption "enable tailscale service for qbittorrent";
  };

  config = lib.mkIf cfg.enable {
    paul.docker.enable = true;

    paul.group.transmission.enable = true;

    users.users.transmission = {
      description = "Transmission BitTorrent user";
      uid = config.ids.uids.transmission; # 70
      group = "transmission";
    };

    virtualisation.oci-containers.containers.qbittorrent-vpn = {
      inherit serviceName;
      image = "binhex/arch-qbittorrentvpn:${cfg.containerVersion}";
      volumes = [
        "/etc/localtime:/etc/localtime:ro"

        "/var/lib/qbittorrent/config:/config"
        "/var/lib/qbittorrent/data:/data"

        "/mnt/arr/torrents:/mnt/arr/torrents"
      ];
      ports = [
        "${toString webuiPort}:${toString webuiPort}"
        "${toString privoxyPort}:8118"
        "${toString socksPort}:9118"
        #"58946:58946"
        #"58946:58946/udp"
      ];
      capabilities = {
        NET_ADMIN = true;
      };
      extraOptions = [
        # prevent "too many open files" error (default is 1024:524288)
        "--ulimit"
        "nofile=8192:524288"
      ];
      environment = {
        PUID = toString config.users.users.transmission.uid;
        PGID = toString config.users.groups.transmission.gid;
        UMASK = "000";

        VPN_ENABLED = "yes";
        VPN_USER = "user";
        VPN_PASS = "pass";
        VPN_PROV = "custom";
        VPN_CLIENT = "openvpn";

        LAN_NETWORK = "192.168.178.0/24,100.0.0.0/8,127.0.0.1/32";
        NAME_SERVERS = "1.1.1.1,1.0.0.1";
        WEBUI_PORT = toString webuiPort;

        ENABLE_PRIVOXY = "yes";

        ENABLE_SOCKS = "yes";
        SOCKS_USER = "socks";
        # SOCKS_PASS = "<socks password>"; # in env file

        DEBUG = "false";
        STRICT_PORT_FORWARD = "yes";
        USERSPACE_WIREGUARD = "no";

        # VPN_OPTIONS = "<additional openvpn cli options>";
        # VPN_INPUT_PORTS = "<port number(s)>";
        # VPN_OUTPUT_PORTS = "<port number(s)>";
        # HEALTHCHECK_COMMAND = "<command>";
        # HEALTHCHECK_ACTION = "<action>";
        # HEALTHCHECK_HOSTNAME = "<hostname>";
        # ENABLE_STARTUP_SCRIPTS = "no"; # default no
      };

      environmentFiles = [
        config.clan.core.vars.generators.qbittorrent.files.env.path
      ];
    };

    paul.tailscale.services.qbt.port = lib.mkIf cfg.enableTailscaleService webuiPort;

    clan.core.state.qbittorrent = {
      useZfsSnapshots = true;
      folders = [ "/var/lib/qbittorrent" ];
      servicesToStop = [ "${serviceName}.service" ];
    };

    clan.core.vars.generators.qbittorrent = {
      prompts.socks-password.description = "Password for qbittorrent microsocks user (see bw)";
      prompts.socks-password.type = "hidden";
      prompts.socks-password.persist = false;

      files.env.secret = true;
      files.env.owner = "transmission";

      script = ''
        echo "
        SOCKS_PASS="$(cat $prompts/socks-password)"
        " > $out/env
      '';
    };

    # fix for:
    # iptables v1.8.11 (legacy): can't initialize iptables table `filter': Table does not exist (do you need to insmod?)
    # Perhaps iptables or your kernel needs to be upgraded.
    # [crit] iptables default policies not available, exiting script...
    boot.kernelModules = [
      "iptable_filter"
      "ip6table_filter"
    ];

    # TODO: add qui frontend
  };
}
