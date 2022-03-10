{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/master;
    flake-utils.url = github:numtide/flake-utils;

    vpp.url = github:FDio/vpp/stable/2202;
    vpp.flake = false;

    flake-compat.url = github:edolstra/flake-compat;
    flake-compat.flake = false;
    flake-compat-ci.url = github:hercules-ci/flake-compat-ci;
  };
  outputs = { self, nixpkgs, flake-compat, flake-compat-ci, flake-utils, vpp }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.vpp = pkgs.callPackage ./vpp.nix { vppSource = vpp; };
        defaultPackage = self.packages.${system}.vpp;
      }
    )) // {
      ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
        flake = self;
        systems = [ "x86_64-linux" ];
      };
    };
}
