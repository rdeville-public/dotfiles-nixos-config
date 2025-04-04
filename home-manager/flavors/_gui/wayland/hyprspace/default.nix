{
  config,
  lib,
  pkgs,
  ...
}: let
  name = builtins.baseNameOf ../../.;
  subname = builtins.baseNameOf ../.;
  subsubname = builtins.baseNameOf ./.;
  cfg = config.hm.flavors.${name}.${subname}.${subsubname};
in {
  options = {
    hm = {
      flavors = {
        ${name} = {
          ${subname} = {
            ${subsubname} = {
              enable =
                lib.mkDependEnabledOption ''
                  Install ${name}.${subname}.${subsubname} Home-Manager flavor.
                ''
                (
                  config.hm.flavors.${name}.enable
                  && config.hm.flavors.${name}.${subname}.enable
                  && config.hm.flavors.${name}.${subname}.hyprland.enable
                );
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    wayland = {
      windowManager = {
        hyprland = {
          plugins = [
            pkgs.hyprlandPlugins.hyprspace
          ];

          settings = {
            bind = [
              "$mod $shift, E, overview:toggle"
            ];
          };
        };
      };
    };
  };
}
