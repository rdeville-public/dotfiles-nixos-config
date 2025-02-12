{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.os.users;

  defaultGroup = [
    "networkmanager"
  ];
  sudoGroup = user:
    if user.isSudo
    then [
      "wheel"
    ]
    else [];
in {
  options = {
    os = {
      users = {
        defaultUserShell = lib.mkOption {
          type = lib.types.package;
          description = "The default shell all users.";
          default = pkgs.zsh;
        };

        mutableUsers = lib.mkOption {
          type = lib.types.bool;
          description = "Set is users are mutables.";
          default = false;
        };

        users = lib.mkOption {
          description = "Configure NixOS users.";
          default = {};
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                isSudo = lib.mkOption {
                  type = lib.types.bool;
                  description = "Set to true if the user can be sudo.";
                  default = false;
                };

                shell = lib.mkOption {
                  type = lib.types.str;
                  description = "The shell for the user.";
                  default = "zsh";
                };

                openssh = {
                  authorizedKeys = {
                    keyFiles = lib.mkOption {
                      type = lib.types.listOf lib.types.path;
                      description = ''
                        Keyfiles to authorized keys to connect to this user
                      '';
                      default = [];
                    };
                  };
                };

                extraGroups = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  description = "List of extra group for the user";
                  default = [];
                };

                password = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  description = ''
                    Text clear password of the user.
                    Do not use it on production, mainly for Bootable USB creation
                  '';
                  default = null;
                };

                hashedPassword = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  description = "Hashed string of the user password";
                  default = null;
                };

                hashedPasswordFile = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  description = "Path to file storing user hashedPasswordFile";
                  default = null;
                };
              };
            }
          );
        };
      };
    };
  };

  config = {
    users = {
      inherit
        (cfg)
        defaultUserShell
        mutableUsers
        ;
      users =
        builtins.mapAttrs (
          name: user: {
            inherit
              (user)
              openssh
              password
              hashedPassword
              ;
            shell = pkgs.${user.shell};
            isNormalUser = name != "root";
            hashedPasswordFile =
              if user.hashedPasswordFile != null
              then user.hashedPasswordFile
              else if config ? sops.secrets."users/${name}/password".path
              then config.sops.secrets."users/${name}/password".path
              else null;
            extraGroups =
              defaultGroup
              ++ user.extraGroups
              ++ (sudoGroup user);
          }
        )
        cfg.users;
    };

    programs = builtins.listToAttrs (
      builtins.map (
        name: let
          shell = cfg.users.${name}.shell;
        in {
          name = shell;
          value = {
            enable = true;
          };
        }
      ) (builtins.attrNames cfg.users)
    );
  };
}
