self: super:
{
  # Use nixpkgs' latest kernel; R4S patches are no longer needed.
  linuxPackagesNanopiR4S = self.linuxPackages_latest;

  uboot_NanopiR4S = self.buildUBoot {
    defconfig = "nanopi-r4s-rk3399_defconfig";
    extraPatches = [ ];
    extraMeta = {
      platforms = [ "aarch64-linux" ];
      #license = lib.licenses.unfreeRedistributableFirmware;
    };
    BL31 = "${self.armTrustedFirmwareRK3399}/bl31.elf";
    filesToInstall = [ "spl/u-boot-spl.bin" "u-boot.itb" "idbloader.img"];
  };
}
