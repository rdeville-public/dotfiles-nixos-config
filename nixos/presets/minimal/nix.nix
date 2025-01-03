{pkgs, ...}: {
  # Nix Package Manager Settings
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Nix Settings
  nix = {
    # Garbage Collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    package = pkgs.nixVersions.latest;

    settings = {
      accept-flake-config = true;
      auto-optimise-store = true;

      extra-experimental-features = [
        "flakes"
        "nix-command"
        "auto-allocate-uids"
      ];
      keep-outputs = true;
      keep-derivations = true;
      show-trace = true;
      trusted-users = [
        "root"
        "@wheel"
        "@sudo"
      ];
    };
  };
}
