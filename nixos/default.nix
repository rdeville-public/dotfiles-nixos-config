{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.os;
in {
  imports = [
    ../modules
    ./flavors
    ./users.nix
  ];

  options = {
    os = lib.mkOption {
      description = ''
        My custom `os` module to setup NixOS using my own flavors
      '';
      default = {};
      type = lib.types.submodule {
        options = {
          # BASE CONFIGURATION
          hostName = lib.mkOption {
            type = lib.types.str;
            description = "Hostname where config will be applied.";
          };

          parentName = lib.mkOption {
            type = lib.types.str;
            description = "If OS is a container or a VM, this store the name of the host OS";
            default = "";
          };

          stateVersion = lib.mkOption {
            type = lib.types.str;
            description = "Version of HM to follow";
            default = "25.05";
          };

          system = lib.mkOption {
            type = lib.types.str;
            description = "Arch system where config will be applied.";
            default = "x86_64-linux";
          };

          timeZone = lib.mkOption {
            type = lib.types.str;
            description = "The timezone of the host.";
            default = "Europe/Paris";
          };

          defaultLocale = lib.mkOption {
            type = lib.types.str;
            description = "i18n local default value.";
            default = "en_US.UTF-8";
          };

          extraLocaleSettings = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            description = "i18n extra local values, like LC_MONETARY.";
            default = {
              LC_MONETARY = "fr_FR.UTF-8";
            };
          };

          console = {
            keyMap = lib.mkOption {
              type = lib.types.either lib.types.str lib.types.path;
              description = "The keyboard mapping table for the virtual consoles.";
              default = "fr";
            };

            font = lib.mkOption {
              type = lib.types.either lib.types.str lib.types.path;
              description = "The font to use in the console.";
              default = "Lat2-Terminus16";
            };
          };

          # BOOLEAN TO PARAMETERIZE SOME FLAVORS
          isDarwin = lib.mkEnableOption "Boolean, set to true to specify OS is darwin.";
          isMain = lib.mkEnableOption "Main computer.";
          isGui = lib.mkEnableOption "GUI computer.";
          isProd = lib.mkEnableOption "Prod computer.";
        };
      };
    };
  };

  config = {
    # NIXOS BASE CONFIGURATION
    system = {
      inherit (cfg) stateVersion;
    };

    networking = {
      inherit (cfg) hostName;
    };

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      package = pkgs.nixVersions.latest;

      settings = {
        accept-flake-config = true;
        auto-optimise-store = lib.mkDefault true;
        extra-experimental-features = [
          "flakes"
          "nix-command"
          "auto-allocate-uids"
        ];
        keep-outputs = true;
        keep-derivations = true;
        show-trace = true;
        trusted-users = [
          "root"
          "@wheel"
          "@sudo"
        ];
      };
    };

    nixpkgs = {
      hostPlatform = cfg.system;
    };

    console = {
      inherit (cfg.console) keyMap font;
    };

    i18n = {
      inherit (cfg) defaultLocale extraLocaleSettings;
    };

    time = {
      inherit (cfg) timeZone;
    };

    security = {
      rtkit = {
        enable = true;
      };
      polkit = {
        enable = true;
      };
      sudo = {
        enable = true;
        execWheelOnly = true;
        extraConfig = ''
          # Ask for root password when doing sudo
          Defaults rootpw
        '';
      };
    };
  };
}
