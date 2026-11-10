{
  pkgs,

  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
  ];

  paul = {
    common-desktop.enable = true;
    gnome.enable = true;
    grub.enable = true;
    syncthing.enable = true;
    docker.enable = true;
    gaming.enable = true;
    kanidm.enableClient = true;
    tor-client.enable = true;
    qmk.enable = true;
  };

  clan.core.networking.targetHost = "newton";

  clan.core.state.home = {
    folders = map (path: "/home/paulmiro/" + path) [
      "Documents"
      "Downloads"
      "Desktop"
      "Pictures"
      "Videos"
      "Music"
    ];
  };

  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
  };

  # being able to build aarm64 stuff
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--accept-routes"
      "--operator=paulmiro"
    ];
  };

  boot.loader.grub.configurationLimit = 25;

  boot.zswap.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  # disabled for closure size
  # specialisation = {
  #   jovian.configuration = {
  #     paul.jovian.enable = true;
  #   };

  #   niri.configuration = {
  #     paul.gnome.enable = pkgs.lib.mkForce false;
  #     paul.niri.enable = true;
  #   };
  # };
}
