{
  userCfg,
  pkgs,
  lib,
  ...
}: let
  cfg =
    if userCfg.flavors ? kubernetes-client
    then userCfg.flavors.kubernetes-client
    else {
      enable = false;
    };
in {
  options = {
    kubernetes-client = {
      enable = lib.mkEnableOption "Install kubernetes Related Packages";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        age
        kubectl
        kubectx
        kubernetes-helm
        kubernetes-helmPlugins.helm-diff
        kubernetes-helmPlugins.helm-git
        kubernetes-helmPlugins.helm-secrets
        kubernetes-helmPlugins.helm-mapkubeapis
        sops
        stern
      ];
    };

    programs = {
      k9s = {
        enable = true;
      };
    };
  };
}
