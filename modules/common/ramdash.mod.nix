{
  config,
  lib,
  pkgs,

  private,
  ...
}:
let
  baseUrl = "https://${private.domains.ramdash}/api";
  username = "Paul";
  token = builtins.head private.misc.ramdash-keys;
  interval = "1min";

  cfg = config.paul.ramdash;

  serverPackage = pkgs.rustPlatform.buildRustPackage {
    pname = "ram-altman";
    version = "0.1.0-unstable-2026-11-17";
    src = pkgs.fetchFromGitHub {
      owner = "Tondorf";
      repo = "ram-altman";
      rev = "86904c84a6837b76ec7fde27bdad0cc196708877";
      hash = "sha256-1m/+1oOME8gP/mG3/FaRYN9EAXx/AqSOSFc2rYAZsWo=";
    };
    cargoHash = "sha256-/tebqpev4ZpcirPoVoEBigDiZLFSHJGgtzmtXjWeS0k=";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.sqlite ];
    doCheck = false;
  };

  clientPackage = pkgs.writeShellApplication {
    name = "ramdash-report";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.gawk
      pkgs.jq
    ];
    text = ''
      base_url=${lib.escapeShellArg baseUrl}
      username=${lib.escapeShellArg username}
      token=${lib.escapeShellArg token}
      hostname=${lib.escapeShellArg config.networking.hostName}

      # /proc/meminfo reports KiB
      total_kib=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
      free_kib=$(awk '/^MemAvailable:/ { print $2 }' /proc/meminfo)

      body=$(jq -n -c \
        --argjson total "$((total_kib * 1024))" \
        --argjson free "$((free_kib * 1024))" \
        '{total_ram_bytes: $total, free_ram_bytes: $free, memory_type: "${cfg.client.memoryType}"}')

      user_enc=$(jq -rn --arg v "$username" '$v | @uri')
      host_enc=$(jq -rn --arg v "$hostname" '$v | @uri')

      curl --silent --show-error --fail-with-body \
        --max-time 30 \
        --request PUT \
        --header "Content-Type: application/json" \
        --header "Authorization: Bearer $token" \
        --data "$body" \
        "$base_url/v1/report/$user_enc/$host_enc"
      echo
    '';
  };
in
{
  options.paul.ramdash = {
    server.enable = lib.mkEnableOption "the RAM dashboard server";

    client = {
      enable = lib.mkEnableOption "the RAM dashboard reporting client";
      memoryType = lib.mkOption {
        type = lib.types.str;
        default = "system";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.client.enable {
      systemd.services.ramdash-client = {
        description = "Report memory usage to the RAM dashboard";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe clientPackage;
          DynamicUser = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };

      systemd.timers.ramdash-client = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitActiveSec = interval;
          AccuracySec = "1s";
        };
      };
    })
    (lib.mkIf cfg.server.enable {
      services.nginx.virtualHosts.${private.domains.ramdash} = {
        forceSSL = true;
        enableACME = true;
        enableGeoIP = true;
        geoIpCountries = [ "DE" ];
        locations."/" = {
          proxyPass = "http://localhost:19115";
        };
      };

      systemd.services.ram-altman = {
        description = "RAM dashboard";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        environment = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = "19115";
          ROCKET_DATABASE_PATH = "/var/lib/ram-altman/data.sqlite";
          ROCKET_API_TOKENS = "[${lib.concatMapStringsSep ", " (k: ''"${k}"'') private.misc.ramdash-keys}]";
          ROCKET_STALE_AFTER_SECS = "600";
          ROCKET_LOG_LEVEL = "critical";
          ROCKET_CLI_COLORS = "false";
        };
        serviceConfig = {
          ExecStart = "${serverPackage}/bin/ram-dashboard";
          DynamicUser = true;
          StateDirectory = "ram-altman";
          Restart = "on-failure";
        };
      };
    })
  ];
}
