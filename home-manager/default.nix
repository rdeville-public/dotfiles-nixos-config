{
  config,
  lib,
  ...
}: let
  cfg = config.hm;
in {
  imports = builtins.map (item: ./${item}) (lib.importDir ./.);

  options = {
    hm = {
      system = lib.mkOption {
        type = lib.types.str;
        description = "Arch system where config will be applied.";
        default = "x86-64_linux";
      };

      hostname = lib.mkOption {
        type = lib.types.str;
        description = "Hostname where config will be applied.";
      };

      username = lib.mkOption {
        type = lib.types.str;
        description = "Username to apply.";
      };

      stateVersion = lib.mkOption {
        type = lib.types.str;
        description = "Version of HM to follow";
        default = "24.11";
      };

      homeDirectory = lib.mkOption {
        type = lib.types.str;
        description = "Path to the home directory.";
        default =
          if cfg.isDarwin
          then "/Users/${cfg.username}"
          else "/home/${cfg.username}";
      };

      wrapGL = lib.mkOption {
        type = lib.types.bool;
        description = "Boolean, set to true to specify OS is darwin.";
        default = false;
      };

      isDarwin = lib.mkOption {
        type = lib.types.bool;
        description = "Boolean, set to true to specify OS is darwin.";
        default = false;
      };

      isWork = lib.mkOption {
        type = lib.types.bool;
        description = "Boolean, set to true to host is my professional computer.";
        default = false;
      };

      isGui = lib.mkOption {
        type = lib.types.bool;
        description = "If true, setup GUI environnement.";
        default = false;
      };

      isMain = lib.mkOption {
        type = lib.types.bool;
        description = "If true, setup Main environnement.";
        default = false;
      };

      sessionPath = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Set user session path";
        default = [
          "$HOME/.local/share/bin"
          "$HOME/.local/bin"
        ];
      };

      sessionVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Set user session variables.";
        default = {
          HOST = cfg.hostname;
          EDITOR = "nvim";
        };
      };
    };
  };

  config = {
    home = {
      stateVersion = cfg.stateVersion;

      username = cfg.username;

      homeDirectory = cfg.homeDirectory;

      sessionPath = cfg.sessionPath;
      sessionVariables = cfg.sessionVariables;

      preferXdgDirectories = true;
    };
  };
}
