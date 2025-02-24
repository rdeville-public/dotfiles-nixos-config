{
  config,
  pkgs,
  lib,
  ...
}: let
  nixIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
  hidden = {
    metaData = {
      hidden = true;
    };
  };
  alias = alias: {
    metaData = {
      alias = alias;
    };
  };
  engines = {
    "Nix Packages" = {
      urls = [
        {
          template = "https://mynixos.com/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = nixIcon;
      definedAliases = ["@np" "np"];
    };
    "Home Manager" = {
      urls = [
        {
          template = "https://home-manager-options.extranix.com/";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
            {
              name = "release";
              value = "master";
            }
          ];
        }
      ];
      icon = nixIcon;
      definedAliases = ["@hm" "hm"];
    };
  };
  settings = {
    "browser.backspace_action" = 0;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };
  search = {
    default = "DuckDuckGo";
    privateDefault = "DuckDuckGo";
    engines =
      engines
      // {
        "DuckDuckGo" = alias "d";
        "Google" = alias "g";
        "Wikipedia (en)" = alias "w";
        "Bookmarks" = alias "b";
        "Tabs" = alias "t";
        "History" = alias "h";
        "Bing" = hidden;
        "Qwant" = hidden;
      };
    force = true;
    order = [
      "DuckDuckGo"
      "Wikipedia (en)"
      "Nix Packages"
      "Home Manager"
      "Google"
    ];
  };
  userChrome = builtins.readFile ./chrome/userChrome.css;
in {
  config = lib.mkIf (! config.hm.isDarwin) {
    programs = {
      firefox = {
        profiles =
          if config.hm.isWork
          then {
            pro = {
              id = 1;
              isDefault = config.hm.isWork;
              name = "pro";
              userContent = "";
              settings = settings // {};
              inherit
                search
                userChrome
                ;
            };
          }
          else {
            perso = {
              id = 0;
              isDefault = ! config.hm.isWork;
              name = "perso";
              userContent = "";
              settings = settings // {};
              inherit
                search
                userChrome
                ;
            };
          };
      };
    };
  };
}
