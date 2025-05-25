{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.paul.nvidia;
in
{
  options.paul.nvidia = with lib; {
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
  config = lib.mkIf cfg.enable {

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = [ "nvidia" ];

    environment.systemPackages = with pkgs; [ nvtopPackages.full ];

    hardware = {

      # Enable OpenGL
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = lib.mkIf cfg.laptop (
          with pkgs;
          [
            vaapiVdpau
          ]
        );
      };

      nvidia = {
        # Modesetting is required.
        modesetting.enable = lib.mkIf cfg.laptop true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = lib.mkIf cfg.laptop false;

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
        nvidiaSettings = lib.mkIf cfg.laptop true;

        # Optionally, you may need to select the appropriate driver version for your specific GPU.
        package = config.boot.kernelPackages.nvidiaPackages.beta;
      };

      nvidia-container-toolkit.enable = lib.mkIf config.virtualisation.docker.enable true;
    };

    hardware.nvidia.prime = lib.mkIf cfg.laptop {
      intelBusId = cfg.intelBusId;
      nvidiaBusId = cfg.nvidiaBusId;
      offload.enable = true;
    };

  };
}
