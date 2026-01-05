{
  description = "NanoPi R4S NixOS image";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      pkgsAarch64 = import nixpkgs {
        system = "aarch64-linux";
        overlays = [ (import ./overlay.nix) ];
        config.allowUnfree = true;
      };

      nixosR4S = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        pkgs = pkgsAarch64;
        specialArgs = { nixpkgsPath = nixpkgs; };
        modules = [ ./sd-image.nix ];
      };
    in
    {
      packages = forAllSystems (_: {
        sdImage = nixosR4S.config.system.build.sdImage;
        uboot = pkgsAarch64.uboot_NanopiR4S;
      });

      nixosConfigurations.nanopi-r4s = nixosR4S;
    };
}
