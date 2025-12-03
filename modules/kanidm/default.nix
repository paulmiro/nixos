{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.kanidm;
  domain = config.paul.private.domains.kanidm; # not set as an option because it should never be changed
  origin = "https://${domain}";
  package = pkgs.kanidm_1_8;
in
{
  options.paul.kanidm = {
    enableServer = lib.mkEnableOption "enable kanidm server";
    enableClient = lib.mkEnableOption "enable kanidm client";
    enablePam = lib.mkEnableOption "enable kanidm PAM integration";
    enablePamSsh = lib.mkEnableOption "enable ssh via kanidm PAM integration";

    disableLdaps = lib.mkEnableOption "disable ldaps in kandim";
    openHttpsFirewall = lib.mkEnableOption "open kanidm https port in the firewall";
    openLdapsFirewall = lib.mkEnableOption "open kanidm ldaps port in the firewall";

    httpsPort = lib.mkOption {
      description = "internal https port for kanidm";
      type = lib.types.port;
      default = 8443; # pretty much arbitrary
    };

    ldapsPort = lib.mkOption {
      description = "ldaps port for kanidm";
      type = lib.types.port;
      default = 636;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enableServer || cfg.enableClient || cfg.enablePam) {
      services.kanidm = {
        inherit package;
      };
    })
    (lib.mkIf cfg.enableServer {
      services.kanidm = {
        enableServer = true;
        serverSettings = {
          version = "2";
          inherit origin domain;
          bindaddress = (if cfg.openHttpsFirewall then "[::]" else "[::1]") + ":" + toString cfg.httpsPort;
          ldapbindaddress = lib.mkIf (!cfg.disableLdaps) (
            (if cfg.openLdapsFirewall then "[::]" else "[::1]") + ":" + toString cfg.ldapsPort
          );
          http_client_address_info.x-forward-for = [ "::1" ];
          tls_chain = "/var/lib/kanidm/cert.pem";
          tls_key = "/var/lib/kanidm/key.pem";
          db_fs_type = if config.paul.zfs.enable then "zfs" else "other";
        };
      };

      services.nginx.virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        enableDyndns = true;
        locations."/" = {
          proxyPass = "https://[::1]:${toString cfg.httpsPort}";
        };
      };

      security.acme.certs.${domain} = {
        postRun = ''
          cp -Lv {cert,key}.pem /var/lib/kanidm
          chown root:kanidm /var/lib/kanidm/{cert,key}.pem
          chmod 040 /var/lib/kanidm/{cert,key}.pem
        '';
        reloadServices = [ "kanidm.service" ];
      };

      networking.firewall.allowedTCPPorts = [
        (lib.mkIf cfg.openHttpsFirewall cfg.httpsPort)
        (lib.mkIf cfg.openLdapsFirewall cfg.ldapsPort)
      ];

      clan.core.state.kanidm = {
        useZfsSnapshots = true;
        folders = [ "/var/lib/kanidm" ];
        servicesToStop = [ "kanidm.service" ];
      };
    })

    (lib.mkIf cfg.enableClient {
      services.kanidm = {
        enableClient = true;
        clientSettings = {
          uri = origin;
        };
      };
    })

    (lib.mkIf cfg.enablePam {
      services.kanidm = {
        enablePam = true;
        unixSettings = {
          pam_allowed_login_groups = [ "pam_${config.networking.hostName}_users" ];
          default_shell = "${pkgs.shadow}/bin/nologin";
          home_prefix = "/home/";
          home_attr = "uuid";
          home_alias = "name";
          home_mount_prefix = "/mnt/kanidm_home/";
        };

        clientSettings = {
          uri = origin;
        };
      };

      # ensure home directory creation works (/home is included by default)
      systemd.services.kanidm-unixd-tasks = {
        serviceConfig = {
          BindPaths = [
            (lib.removeSuffix "/" config.services.kanidm.unixSettings.home_mount_prefix)
          ];
        };
      };

      # workaround for "/bin/bash does not exist" error
      systemd.services.kanidm-unixd = {
        serviceConfig = {
          BindReadOnlyPaths = [
            "/bin"
          ];
        };
      };
      system.activationScripts.link-shells-to-bin = ''
        ln -sf ${pkgs.bash}/bin/bash /bin/bash
        ln -sf ${pkgs.zsh}/bin/zsh /bin/zsh
      '';

      # workaround for nixpkgs/issues/94653 (error: Unsafe AuthorizedKeysCommand "/nix/store/[...]": bad ownership or modes for directory /nix/store)
      security.wrappers."kanidm_ssh_authorizedkeys" = {
        source = "${package}/bin/kanidm_ssh_authorizedkeys";
        owner = "root";
        group = "root";
      };
      services.openssh = {
        authorizedKeysCommand = "/run/wrappers/bin/kanidm_ssh_authorizedkeys %u";
        authorizedKeysCommandUser = "nobody";
      };
    })
  ];
}
