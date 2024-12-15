{
  userCfg,
  config,
  pkgs,
  lib,
  ...
}: let
  moduleCfg =
    if userCfg.flavors ? glab
    then userCfg.flavors.glab
    else {
      enable = false;
    };
in {
  options = {
    glab = {
      enable = lib.mkEnableOption "Install glab (GitLab CLI) Related Packages";
    };
  };

  config = lib.mkIf moduleCfg.enable {
    home = {
      packages = with pkgs; [
        glab
      ];
    };

    xdg = {
      configFile = {
        # Workaround while watiing a fix allowing to set xdg chmod
        # See: https://github.com/nix-community/home-manager/issues/3090
        "glab-cli/HMInit_config.yml" = {
          enable = with pkgs; builtins.elem glab config.home.packages;
          text = pkgs.lib.generators.toYAML {} {
            git_protocol = "ssh";
            glamour_style = "dark";
            check_update = "false";
          };
          onChange = ''
            rm -f ${config.xdg.configHome}/glab-cli/config.yml
            cp ${config.xdg.configHome}/glab-cli/HMInit_config.yml ${config.xdg.configHome}/glab-cli/config.yml
            chmod 0600 ${config.xdg.configHome}/glab-cli/config.yml
          '';
        };
        "glab-cli/HMInit_aliases.yml" = {
          enable = with pkgs; builtins.elem glab config.home.packages;
          text = pkgs.lib.generators.toYAML {} {
            ci = "pipeline ci";
            co = "mr checkout";
          };
          onChange = ''
            rm -f ${config.xdg.configHome}/glab-cli/aliases.yml
            cp ${config.xdg.configHome}/glab-cli/HMInit_aliases.yml ${config.xdg.configHome}/glab-cli/aliases.yml
            chmod 0600 ${config.xdg.configHome}/glab-cli/aliases.yml
          '';
        };
      };
    };
  };
}
