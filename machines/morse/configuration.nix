{
  config,
  lib,
  ...
}:
{
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
      "--accept-dns=true"
      "--advertise-exit-node"
    ];
  };

  services.nginx.virtualHosts."paulmiro.de" = {
    enableACME = true;
    forceSSL = true;
    enableDyndns = true;
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
