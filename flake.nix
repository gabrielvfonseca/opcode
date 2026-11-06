{
  description = "OPCODE local-first voice dictation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      package = pkgs: self.packages.${pkgs.stdenv.hostPlatform.system}.opcode;
    in
    {
      packages = forSystems (
        pkgs:
        let
          opcode = pkgs.callPackage ./nix/package.nix { };
        in
        {
          inherit opcode;
          default = opcode;
        }
      );

      overlays.default = final: _prev: {
        opcode = final.callPackage ./nix/package.nix { };
      };

      nixosModules.opcode =
        { pkgs, ... }:
        {
          imports = [ ./nix/module.nix ];
          programs.opcode.package = nixpkgs.lib.mkDefault (package pkgs);
        };
      nixosModules.default = self.nixosModules.opcode;

      homeManagerModules.opcode =
        { pkgs, ... }:
        {
          imports = [ ./nix/hm-module.nix ];
          programs.opcode.package = nixpkgs.lib.mkDefault (package pkgs);
        };
      homeManagerModules.default = self.homeManagerModules.opcode;

      devShells = forSystems (pkgs: {
        default = (package pkgs).devShell;
      });
      checks = forSystems (pkgs: import ./nix/checks.nix { inherit self pkgs; });
      formatter = forSystems (pkgs: pkgs.nixfmt);
    };
}
