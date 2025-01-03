{
  userCfg,
  lib,
  ...
}:
lib.mkIf (! userCfg.isDarwin) {
  programs = {
    thunderbird = {
      enable = true;
      profiles = {
        "${userCfg.username}" = {
          isDefault = true;
          userChrome = builtins.readFile ./chrome/userChrome.css;
          withExternalGnupg = true;
          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "mail.openpgp.allow_external_gnupg" = true;
          };
        };
      };
    };
  };
}
