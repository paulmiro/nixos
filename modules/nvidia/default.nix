{ pkgs, config, lib, ... }:
with lib;
let cfg = config.paul.nvidia;
in
{
  options.paul.nvidia = {
    enable = mkEnableOption "activate nvidia";
    laptop = mkEnableOption "activate nvidia laptop mode";
    intelBusId = mkOption {
      type = types.str;
      default = "PCI:0:2:0";
      description = "Bus ID of the Intel GPU";
    };
    nvidiaBusId = mkOption {
      type = types.str;
      default = "PCI:58:0:0";
      description = "Bus ID of the Nvidia GPU";
    };
  };
  config = mkIf cfg.enable {

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];


    hardware = {

      # Enable OpenGL
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; mkIf cfg.laptop [
          vaapiVdpau
        ];
      };

      nvidia = {
        # Modesetting is required.
        modesetting.enable = mkIf cfg.laptop true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = false;

        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of 
        # supported GPUs is at: 
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
        # Only available from driver 515.43.04+
        # Do not disable this unless your GPU is unsupported or if you have a good reason to.
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

    };

    hardware.nvidia.prime = mkIf cfg.laptop {
      intelBusId = cfg.intelBusId;
      nvidiaBusId = cfg.nvidiaBusId;
      offload.enable = true;
    };

  };
}
