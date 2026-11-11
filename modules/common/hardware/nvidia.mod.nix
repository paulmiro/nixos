{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.nvidia;
in
{
  options.paul.nvidia = {
    enable = lib.mkEnableOption "activate nvidia";
    driverVersion = lib.mkOption {
      type = lib.types.str;
      default = "stable";
    };
  };

  config = lib.mkIf cfg.enable {
    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    environment.systemPackages = with pkgs; [
      nvitop
    ];

    hardware = {
      # Enable OpenGL
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      nvidia = {
        open = lib.mkDefault true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = false;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;
        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.${cfg.driverVersion};
      };
      nvidia-container-toolkit.enable = lib.mkIf config.virtualisation.docker.enable true;
    };
  };
}
