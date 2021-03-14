{ config, pkgs, lib, ... }:
let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      pkgs = pkgs.buildPackages;
    };
in {
  imports = [
    ./baseline.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  boot.kernelPackages = pkgs.linuxPackagesNanopiR4S;

  sdImage = {
    populateFirmwareCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        # 'fixes' serial console
        dtoverlay=disable-bt
      '';
      in ''
        cp ${configTxt} config.txt
      '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

}
