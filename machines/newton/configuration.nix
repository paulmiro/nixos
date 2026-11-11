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
    laptop.enable = true;
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
      device = "/swap/swapfile";
      size = 32 * 1024;
    }
  ];
  boot.kernelParams = [ "resume_offset=116663552" ];
  boot.resumeDevice = "/dev/mapper/luks-43c4b67b-f086-473d-ab86-c7ebea3d96e7";

  boot.loader.grub2-theme.screenSize = "tall2.8k";

  services.intel-lpmd.enable = true;

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
