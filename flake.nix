{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
  };
  outputs = { self, nixpkgs, ... }@inputs:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in with pkgs;
      { # We have to give a dummy package or nix complains
        packages.x86_64-linux.default = hello;
        devShells.x86_64-linux.default = mkShell {
          packages = [
            texstudio
            texlive.combined.scheme-full
            imagemagick
          ];
        };
      };
}
