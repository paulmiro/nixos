{
  config,
  lib,
  pkgs,
  ...
}:
{
  ################### KANI TEST ###################
  # Make sure to delete state folders when done:
  # - /var/lib/kanidm
  # - /var/lib/acme/*.kani-test.*
  #################################################
  # kanidm/kanidm/discussions/3349

  services.kanidm = {
    enableServer = true;
    enableClient = true;

    package = pkgs.kanidm_1_7;

    serverSettings = {
      version = "2";
      origin = "https://kanidm.kani-test.morse.${config.paul.private.domains.base}";
      domain = "kanidm.kani-test.morse.${config.paul.private.domains.base}";
      bindaddress = "[::1]:8443";
      ldapbindaddress = "[::]:636";
      http_client_address_info.x-forward-for = [ "::1" ];
      tls_chain = "/var/lib/kanidm/cert.pem";
      tls_key = "/var/lib/kanidm/key.pem";
      # TODO: stolen from https://git.dblsaiko.net/systems/tree/configurations/vineta/kanidm.nix
    };

    clientSettings = {
      uri = config.services.kanidm.serverSettings.origin;
    };
  };

  services.nginx.virtualHosts."kanidm.kani-test.morse.${config.paul.private.domains.base}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://${config.services.kanidm.serverSettings.bindaddress}";
    };
  };

  security.acme.certs."kanidm.kani-test.morse.${config.paul.private.domains.base}" = {
    postRun = ''
      cp -Lv {cert,key,chain}.pem /var/lib/kanidm
      chown kanidm:kanidm /var/lib/kanidm/{cert,key,chain}.pem
      chmod 400 /var/lib/kanidm/{cert,key,chain}.pem
    '';
    reloadServices = [ "services.kanidm" ];
  };

  networking.firewall.allowedTCPPorts = [ 636 ];

  services.jellyfin = {
    enable = true;
  };

  services.nginx.virtualHosts."jellyfin.kani-test.morse.${config.paul.private.domains.base}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:8096";
      proxyWebsockets = true;
    };
  };

  paul.dyndns.domains = [
    "paulmiro.de"
    "jellyfin.kani-test.morse.${config.paul.private.domains.base}"
    "kanidm.kani-test.morse.${config.paul.private.domains.base}"
  ];

  ################### END KANI TEST ###################

  paul = {
    common-server.enable = true;

    nginx = {
      enable = true;
      enableGeoIP = true;
    };

    uptime-kuma = {
      enable = true;
      enableNginx = true;
    };

    gotify = {
      enable = true;
      enableNginx = true;
    };

    microsocks = {
      enable = true;
      openFirewall = true;
    };

  };

  imports = [
    ./hardware-configuration.nix
  ];

  clan.core.networking.targetHost = "morse.${config.paul.private.domains.base}";

  # enable all the firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking = {
    hostName = "morse";
    tempAddresses = "disabled";
  };

  # Configure console keymap
  console.keyMap = "de";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--accept-dns=true"
      "--advertise-exit-node"
    ];
  };

  services.nginx.virtualHosts."paulmiro.de" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      return = "301 https://github.com/paulmiro";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
