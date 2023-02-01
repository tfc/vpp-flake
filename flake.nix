{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/master;
    vpp.url = github:FDio/vpp/stable/2202;
    vpp.flake = false;
  };
  outputs = inputs@{ flake-parts, vpp, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          libmemif = pkgs.callPackage ./libmemif.nix {
            libmemifSource = vpp + "/extras/libmemif";
          };
          vpp = pkgs.callPackage ./vpp.nix {
            vppSource = vpp;
          };
        };
      };
    };
}
