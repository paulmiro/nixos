{ lib, pkgs, config, ... }:
with lib;
let cfg = config.paul.programs.development;
in
{
  options.paul.programs.development = {
    android = mkEnableOption "enable Android";
    c_cpp = mkEnableOption "enable C/C++";
    go = mkEnableOption "enable Go";
    godot = mkEnableOption "enable Godot";
    java = mkEnableOption "enable Java";
    javascript = mkEnableOption "enable JavaScript";
    lua = mkEnableOption "enable Lua";
    python = mkEnableOption "enable Python";

  };

  config = mkMerge [
    (mkIf cfg.android {
      home.sessionVariables = {
        ANDROID_HOME = "~/.android/sdk"; # because fuck whoever decided to name that folder "Android" instead of ".android"
      };

      home.packages = with pkgs; [
        android-studio
        android-tools
      ];
    })
    (mkIf cfg.c_cpp {
      home.packages = with pkgs; [
        clang
        cmake
      ];
    })
    (mkIf cfg.go {
      programs.go = {
        enable = true;
        # https://rycee.gitlab.io/home-manager/options.html#opt-programs.go.packages
        packages = { };
      };
    })
    (mkIf cfg.godot {
      home.packages = with pkgs; [
        godot_4
      ];
    })
    (mkIf cfg.java {
      home.packages = with pkgs; [
        jdk21
      ];
    })
    (mkIf cfg.javascript {
      home.packages = with pkgs; [
        bun
        nodejs
        nodePackages.pnpm
        nodePackages.eas-cli
      ];
    })
    (mkIf cfg.lua {
      home.packages = with pkgs; [
        lua
        stylua
      ];
    })
    (mkIf cfg.python {
      home.packages = with pkgs; [
        (python3.withPackages (ps: with ps; [
          requests
          numpy
          jupyter
        ]))
      ];
    })
  ];
}
