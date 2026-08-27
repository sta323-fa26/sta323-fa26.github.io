# shell.nix — per-project R / RStudio environment (kara-thesis)
#
# Usage:
#   cd into this directory, then:
#     nix-shell            # builds + enters the environment
#     rstudio              # launches the wrapped RStudio (alias adds --disable-gpu)
#
{ pkgs ? import <nixpkgs> {
    # RStudio pulls in an Electron build nixpkgs flags as EOL/insecure;
    # allow just that one package so evaluation doesn't refuse.
    config.permittedInsecurePackages = [ "electron-38.8.4" ];
  }
}:

let
  # Shared base library, maintained once in /etc/nixos/r-packages.nix.
  # That file's header is `{ rPackages }:`, so it must be called with an
  # attrset — NOT `import ./r-packages.nix pkgs.rPackages`.
  # (Adjust the path if the file lives elsewhere, or copy it into this
  #  project directory and use ./r-packages.nix to make the project portable.)
  basePackages = import /etc/nixos/r-packages.nix { inherit (pkgs) rPackages; };

  # A GitHub-only package (not on CRAN), built the NixOS-native way with
  # buildRPackage + fetchFromGitHub — this is the declarative replacement for
  # devtools::install_github(), which doesn't work cleanly on NixOS.
  #
  # weatherStats' DESCRIPTION declares no dependencies beyond base R, and its
  # NAMESPACE imports only from grDevices / graphics / utils (all bundled with
  # R), so propagatedBuildInputs is intentionally empty.
  weatherStats = pkgs.rPackages.buildRPackage {
    name = "weatherStats";
    src = pkgs.fetchFromGitHub {
      owner = "pdhoff";
      repo  = "weatherStats";
      # Pin a commit for reproducibility. "master" builds fine but can drift;
      # replace it with the exact 40-char SHA (see notes below the file).
      rev  = "master";
      # Placeholder. Nix will print the real hash on the first build; paste it
      # in here and rebuild. lib.fakeHash is the idiomatic stand-in.
      hash = "sha256-YuOC/sOwrD1hgp9Kh+KAtMiNWFScR7J8f+xh3aM6lsM="; #pkgs.lib.fakeHash;
    };
    propagatedBuildInputs = [ ];
  };

  # Packages specific to THIS project, layered on top of the base set.
  # Duplicates in the list are harmless.
  projectPackages = with pkgs.rPackages; [
    countdown
  ];

  rEnv = pkgs.rstudioWrapper.override {
    packages = basePackages ++ projectPackages ++ [ weatherStats ];
  };
in
pkgs.mkShell {
  buildInputs = [ rEnv ];

  # Electron on NixOS often can't initialize a GPU/GL backend, so default
  # to software rendering when launching RStudio from within this shell.
  shellHook = ''
    alias rstudio="rstudio --disable-gpu"
  '';
}
