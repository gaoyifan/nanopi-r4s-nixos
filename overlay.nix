self: super:
let
  r4s-dts = {
    name = "NanoPi-R4S-dts";
    patch = ./patches/rockchip-rk3399-add-support-for-FriendlyARM-NanoPi-R4S.patch;
  };
  r4s-doc = {
    name = "NanoPi-R4S-doc";
    patch = ./patches/dt-bindings-Add-doc-for-FriendlyARM-NanoPi-R4S.patch;
  };

  linux-nanopi-r4s = self.callPackage ./kernel.nix
  {
    kernelPatches = [ ];
    #kernelPatches = [ r4s-dts r4s-doc ];
  };

in
{
  linuxPackagesNanopiR4S = self.linuxPackagesFor linux-nanopi-r4s;

  uboot_NanopiR4S = self.buildUBoot {
    defconfig = "nanopi-r4s-rk3399_defconfig";
    extraPatches = [ ./patches/arm64-rk3399-Add-support-NanoPi-R4s.patch ];
    extraMeta = {
      platforms = [ "aarch64-linux" ];
      #license = lib.licenses.unfreeRedistributableFirmware;
    };
    BL31 = "${self.armTrustedFirmwareRK3399}/bl31.elf";
    filesToInstall = [ "spl/u-boot-spl.bin" "u-boot.itb" "idbloader.img"];
  };
}
