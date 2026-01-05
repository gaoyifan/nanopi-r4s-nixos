{ config, pkgs, lib, nixpkgsPath ? <nixpkgs>, ... }:
let
  extlinux-conf-builder =
    import "${nixpkgsPath}/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix" {
      lib = lib;
      pkgs = pkgs.buildPackages;
    };
in {
  imports = [
    ./baseline.nix
    "${nixpkgsPath}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];

  # building with emulation
  nixpkgs.system = "aarch64-linux";

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    consoleLogLevel = lib.mkDefault 7;
    kernelPackages = pkgs.linuxPackagesNanopiR4S;
    kernelParams = ["cma=32M" "console=ttyS2,115200n8" "console=tty0"];
  };
  sdImage = {
    # bzip2 compression takes loads of time with emulation, skip it.
    compressImage = false;
    populateFirmwareCommands = '''';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  # Enable OpenSSH
  services.sshd.enable = true;

  # root autologin etc
  users.users.root.password = "root";
  services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";
  services.getty.autologinUser = lib.mkDefault "root";

  #users.extraUsers.root.openssh.authorizedKeys.keys = [
  #   ""
  #];

  networking.firewall.enable = false;
}
