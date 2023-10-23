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
    # services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.sddm.enable = true;

    services.xserver.desktopManager.gnome.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

  };

}
