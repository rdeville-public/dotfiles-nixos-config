{
  # Inspiration sources : https://github.com/jonringer/nixpkgs-config.git
  description = "My NixOS and Home Manager configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
    };
    awesome = {
      url = "github:awesomeWM/awesome/master";
      flake = false;
    };
    hyprswitch = {
      url = "github:h3rmt/hyprswitch/release";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {self, ...}: let
    mkLib = nixpkgs: context:
      nixpkgs.lib.extend
      (final: prev:
        (
          import ./lib/default.nix inputs final
        )
        // (
          if inputs ? ${context}.lib
          then inputs.${context}.lib
          else {}
        ));

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = inputs.nixpkgs.lib.genAttrs allSystems;

    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    # Function to manage Home Manager modules list for nixosConfigurations and
    # homeManageConfigurations both at once
    hmModules = hostname: user: [
      # Local Modules
      ./machines/${hostname}/${user}
      ./home-manager
      # External Modules
      inputs.sops-nix.homeManagerModules.sops
      inputs.nix-index-database.hmModules.nix-index
    ];
  in {
    # TOOLING
    # ========================================================================
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (
      system: let
        pkgs = self.nixosModules.lib.pkgsForSystem system;
      in
        pkgs.alejandra
    );

    # PACKAGES
    # ========================================================================
    packages = forAllSystems (
      system: let
        pkgs = self.nixosModules.lib.pkgsForSystem system;
      in {
        default = import ./scripts {inherit pkgs;};
        scripts = import ./scripts {inherit pkgs;};
      }
    );

    # HOME MANAGER MODULES
    # ========================================================================
    homeManagerModules = {
      hm = import ./home-manager;
      lib = mkLib inputs.nixpkgs "home-manager";
    };
    homeManagerModule = self.homeManagerModules.hm;

    # NIXOS MODULES
    # ========================================================================
    nixosModules = {
      os = import ./nixos;
      lib = mkLib inputs.nixpkgs "nixos";
    };
    nixosModule = self.nixosModules.os;

    # NIXOS CONFIGURATIONS
    # ========================================================================
    nixosConfigurations = let
      lib = mkLib inputs.nixpkgs "nixos";
    in
      builtins.foldl' (acc: host:
        {
          "${host}" = inputs.nixpkgs.lib.nixosSystem {
            modules = [
              # Local Modules
              ./machines/${host}
              # External Modules
              inputs.home-manager.nixosModules.home-manager
              # Internal Modules
              self.nixosModules.os
              (
                {
                  inputs,
                  config,
                  lib,
                  ...
                }: {
                  config = {
                    home-manager = {
                      useGlobalPkgs = false;
                      useUserPackages = true;
                      extraSpecialArgs = {
                        # Here the magic happens with inputs into home-manager
                        inherit inputs;
                      };
                      users = builtins.foldl' (acc: user:
                        {
                          # Here is the magic to manage both HM/Nixos in a clean homogeneous way
                          "${user}" = {...}: {
                            imports = hmModules host user;
                          };
                        }
                        // acc) {} (
                        builtins.filter (host: (
                          host != "keys" && host != "assets"
                        )) (lib.listDirs ./machines/${host})
                      );
                    };
                  };
                }
              )
            ];
            specialArgs = {
              inherit inputs lib;
            };
          };
        }
        // acc) {} (builtins.filter (host: (
        # I usually store :
        # * Host SSH/AGE keys in machines/${host}/keys
        # * Host assets in machines/${host}/keys
        host != "keys" && host != "assets"
      )) (lib.listDirs ./machines));

    # HOME MANAGER
    # ------------------------------------------------------------------------
    homeConfigurations = let
      lib = mkLib inputs.nixpkgs "home-manager";
    in
      builtins.foldl' (
        accHost: host: let
          pkgs =
            self.homeManagerModules.lib.pkgsForSystem
            (import ./machines/${host}/base.nix).system;
        in
          (
            builtins.foldl' (accUser: user:
              {
                "${user}@${host}" = inputs.home-manager.lib.homeManagerConfiguration {
                  inherit pkgs;
                  modules = hmModules host user;
                  extraSpecialArgs = {
                    inherit inputs lib;
                  };
                };
              }
              // accUser)
            {}
            (builtins.filter (user: (
              # I usually store :
              # * Host SSH/AGE keys in machines/${host}/${user}/keys
              # * Host assets in machines/${host}/${user}/keys
              user != "keys" && user != "assets"
            )) (lib.listDirs ./machines/${host}))
          )
          // accHost
      )
      {}
      (
        builtins.filter (host: (
          # I usually store :
          # * Host SSH/AGE keys in machines/${host}/keys
          # * Host assets in machines/${host}/keys
          host != "keys" && host != "assets"
        )) (lib.listDirs ./machines)
      );
  };
}
