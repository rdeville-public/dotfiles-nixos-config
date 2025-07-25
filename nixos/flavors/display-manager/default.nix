{
  config,
  lib,
  ...
}: let
  name = builtins.baseNameOf ./.;
  cfg = config.os.flavors.${name};
in {
  options = {
    os = {
      flavors = {
        ${name} = {
          enable = lib.mkEnableOption "Install ${name} NixOS flavors.";

          gdm = {
            enable = lib.mkEnableOption "Install gdm as display manager.";
          };

          ly = {
            enable =
              lib.mkDependEnabledOption ''
                Install ly as display manager.
              ''
              config.os.flavors.${name}.enable;

            settings = lib.mkOption {
              type = lib.types.attrs;
              description = "Settings for ly display manager.";
              default = {
                animation = "matrix";
              };
            };
          };

          xkb = {
            layout = lib.mkOption {
              type = lib.types.str;
              description = "Layout to apply with x11.";
              default = config.os.console.keyMap;
            };
            options = lib.mkOption {
              type = lib.types.str;
              description = "X keyboard option to apply.";
              default = "caps:escape";
            };
          };
        };
      };
    };
  };

  config = lib.mkIf (! config.os.isDarwin && cfg.enable) {
    services = {
      xserver =
        {
          inherit (cfg) xkb;
          enable = true;
        }
        // lib.optionalAttrs config.os.isProd {
          displayManager = {
            gdm = {
              inherit (cfg.gdm) enable;
            };
          };
        };
      displayManager =
        {
          ly = {
            inherit (cfg.ly) enable settings;
          };
        }
        // lib.optionalAttrs (! config.os.isProd) {
          gdm = {
            inherit (cfg.gdm) enable;
          };
        };
    };
  };
}
