{
  config,
  lib,
  ...
}: let
  name = builtins.baseNameOf ./.;
  subname = "chromium";
  cfg = config.hm.flavors.${name}.${subname};
in {
  options = {
    hm = {
      flavors = {
        ${name} = {
          ${subname} = {
            enable =
              lib.mkDependEnabledOption ''
                Install ${name}.${subname} Home-Manager flavor.
              ''
              config.hm.flavors.${name}.enable;
          };
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable && (! config.hm.isDarwin)) {
    programs = {
      chromium = {
        enable = true;
        dictionaries = [];
        extensions = [
          {id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";} # Dark Reader
          {id = "clngdbkpkpeebahjckkjfobafhncgmne";} # Stylus
          {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # uBlock Origin
          {id = "hfjbmagddngcpeloejdejnfgbamkjaeg";} # Vimium C
          {id = "doojmbjmlfjjnbmnoijecmcbfeoakpjm";} # NoScript
        ];
      };
    };
  };
}
