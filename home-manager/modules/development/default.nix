{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.paul.programs.development;
in
{
  options.paul.programs.development = {
    android = lib.mkEnableOption "enable Android";
    c_cpp = lib.mkEnableOption "enable C/C++";
    go = lib.mkEnableOption "enable Go";
    godot = lib.mkEnableOption "enable Godot";
    java = lib.mkEnableOption "enable Java";
    javascript = lib.mkEnableOption "enable JavaScript";
    lua = lib.mkEnableOption "enable Lua";
    python = lib.mkEnableOption "enable Python";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.android {
      home.sessionVariables = {
        ANDROID_HOME = "~/.android/sdk"; # because fuck whoever decided to name that folder "Android" instead of ".android"
      };

      home.packages = with pkgs; [
        android-studio
        android-tools
      ];
    })
    (lib.mkIf cfg.c_cpp {
      home.packages = with pkgs; [
        clang
        cmake
      ];
    })
    (lib.mkIf cfg.go {
      programs.go = {
        enable = true;
        # https://rycee.gitlab.io/home-manager/options.html#opt-programs.go.packages
        packages = { };
      };
    })
    (lib.mkIf cfg.godot {
      home.packages = with pkgs; [
        godot_4
      ];
    })
    (lib.mkIf cfg.java {
      home.packages = with pkgs; [
        jdk21
      ];
    })
    (lib.mkIf cfg.javascript {
      home.packages = with pkgs; [
        bun
        nodejs
        nodePackages.pnpm
      ];
    })
    (lib.mkIf cfg.lua {
      home.packages = with pkgs; [
        lua
        stylua
      ];
    })
    (lib.mkIf cfg.python {
      home.packages = with pkgs; [
        (python3.withPackages (
          ps: with ps; [
            requests
            numpy
            jupyter
          ]
        ))
      ];
    })
  ];
}
