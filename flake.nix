{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/master;
    flake-utils.url = github:numtide/flake-utils;

    vpp.url = github:FDio/vpp/stable/2202;
    vpp.flake = false;
  };
  outputs = { self, nixpkgs, flake-utils, vpp }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.vpp = pkgs.callPackage ./vpp.nix { vppSource = vpp; };
        defaultPackage = self.packages.${system}.vpp;
      }
    ));
}
