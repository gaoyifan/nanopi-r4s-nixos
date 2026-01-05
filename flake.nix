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
        image = pkgsAarch64.runCommand "nanopi-r4s-sd-image" { } ''
          mkdir -p "$out"
          img=$(ls ${nixosR4S.config.system.build.sdImage}/sd-image/*.img)
          cp "$img" "$out/nanopi-r4s.img"
          chmod u+w "$out/nanopi-r4s.img"
          dd if=${pkgsAarch64.uboot_NanopiR4S}/idbloader.img of=$out/nanopi-r4s.img conv=fsync,notrunc bs=512 seek=64
          dd if=${pkgsAarch64.uboot_NanopiR4S}/u-boot.itb of=$out/nanopi-r4s.img conv=fsync,notrunc bs=512 seek=16384
        '';
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.image);

      nixosConfigurations.nanopi-r4s = nixosR4S;
    };
}
