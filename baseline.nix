{ config, lib, pkgs, ... }:
{
  # !mui importante!
  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.11";

  boot.loader = {
    grub.enable = false;
  };

  boot.consoleLogLevel = lib.mkDefault 7;
  boot.kernelParams = ["cma=32M" "console=ttyS2,115200n8" "console=ttyACM0,115200n8" "console=tty0"];

  # building with emulation
  nixpkgs.system = "aarch64-linux";
  # compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  # Enable OpenSSH
  services.sshd.enable = true;

  # root autologin etc
  users.users.root.password = "root";
  services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";
  # ??
  #services.mingetty.autologinUser = lib.mkDefault "root";
  services.getty.autologinUser = lib.mkDefault "root";

  #users.extraUsers.root.openssh.authorizedKeys.keys = [
  #   ""
  #];

  networking.firewall.enable = false;
}
