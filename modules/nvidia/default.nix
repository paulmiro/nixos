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
    laptop = lib.mkEnableOption "activate nvidia laptop mode";
    intelBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:0:2:0";
      description = "Bus ID of the Intel GPU";
    };
    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:58:0:0";
      description = "Bus ID of the Nvidia GPU";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
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
            package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.beta;
          };
          nvidia-container-toolkit.enable = lib.mkIf config.virtualisation.docker.enable true;
        };
      }

      (lib.mkIf cfg.laptop {
        hardware = {
          graphics = {
            extraPackages = with pkgs; [
              libva-vdpau-driver
            ];
          };

          nvidia = {

            # Modesetting is required for the unfree driver.
            modesetting.enable = true;

            # Use the NVidia open source kernel module (not to be confused with the
            # independent third-party "nouveau" open source driver).
            # Support is limited to the Turing and later architectures. Full list of
            # supported GPUs is at:
            # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
            # Only available from driver 515.43.04+
            # Do not disable this unless your GPU is unsupported or if you have a good reason to.
            open = false;

            prime = {
              intelBusId = cfg.intelBusId;
              nvidiaBusId = cfg.nvidiaBusId;
              offload.enable = true;
            };
          };
        };
      })
    ]
  );
}
