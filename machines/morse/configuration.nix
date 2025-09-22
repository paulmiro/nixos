{
  config,
  lib,
  pkgs,
  ...
}:
{
  ######## TEMPORARY CONFIG DURING TURING MIGRATION ########

  services.nginx.virtualHosts =
    lib.mkMerge
      (map (serviceName: {
        ${config.paul.private.domains.${serviceName}} =
          let
            web-root-dir = pkgs.writeTextFile {
              name = "web-root";
              text = ''
                <!DOCTYPE html>
                <html>
                <head><meta charset="utf-8"/></head>
                <body style="font-family: sans-serif; color: #ddd; background-color: #111">
                  <div style="text-align: center; margin-top: 20%">
                    <p style="font-size: 5em; margin: 0">🚧</p>
                    <h1>Server is under Maintenance</h1>
                    <p>The page you are looking for is temporarily unavailable due to maintenance work.</p>
                    <p>It may take several weeks to get up and running again.</p>
                    <p>
                      You can check
                      <a style="color: #a75ebd" href="https://${config.paul.private.domains.uptime-kuma}">${config.paul.private.domains.uptime-kuma}</a>
                      for the current status.
                    </p>
                    <p style="font-size: 5em; margin: 0">🚧</p>
                  </div>
                </body>
                </html>
              '';
              destination = "/errors/503.html";
            };
          in
          {
            enableACME = true;
            forceSSL = true;
            enableDyndns = true;
            root = "${web-root-dir}";
            extraConfig = ''
              error_page 503 /errors/503.html;
            '';
            locations."/" = {
              return = "503";
            };
            locations."/errors/" = {
              root = "${web-root-dir}";
            };
          };
      })
      [
        "jellyseerr"
        #"jellyfin"
        #"immich"
        #"stirling-pdf"
        #"kanidm"
        "hedgedoc"
        "karakeep"
        #"librespeedtest"
        "filebrowser"
      ]);

  ######### END TEMPORARY CONFIG #######

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
    firewall = {
      allowedTCPPorts = [ ];
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--operator=paulmiro"
      "--advertise-exit-node"
    ];
  };

  # TODO: temporarily disabled because of the Turing Migration
  # services.nginx.virtualHosts."paulmiro.de" = {
  #   enableACME = true;
  #   forceSSL = true;
  #   enableDyndns = true;
  #   locations."/" = {
  #     return = "301 https://github.com/paulmiro";
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
