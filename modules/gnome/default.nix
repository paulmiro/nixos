{ config, pkgs, lib, ... }:
with lib;
let cfg = config.paul.gnome;
in
{

  options.paul.gnome = {
    enable = mkEnableOption "activate gnome";
  };

  config = mkIf cfg.enable {

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.defaultSession = "gnome"; # this forces gnome to run with wayland instead of x11
    # services.xserver.displayManager.sddm.enable = true;

    services.xserver.desktopManager.gnome.enable = true;
    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      # cheese # webcam tool
      gnome-music
      # gedit # text editor
      epiphany # web browser
      geary # email reader
      # gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
      # gnome-contacts
      gnome-initial-setup
    ]);
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

  };

}
