#! /usr/bin/env bash

OUT=out

mkdir $OUT

nix-build '<nixpkgs/nixos>' --argstr system aarch64-linux -A config.system.build.sdImage -I nixos-config=sd-image.nix
IMG=$(basename result/sd-image/*)
cp result/sd-image/$IMG $OUT/

nix-build '<nixos/nixpkgs>' --argstr system aarch64-linux -A uboot_NanopiR4S
cp result/* $OUT/

dd if=$OUT/idbloader.img of=$OUT/$IMG conv=fsync,notrunc bs=512 seek=64
dd if=$OUT/u-boot.itb of=$OUT/$IMG conv=fsync,notrunc bs=512 seek=16384

#sfdisk --dump $OUT/$IMG

echo "Image built successfully?!"
echo ""
echo "Now burn the image with:"
echo "dd if=$OUT/$IMG of=/dev/mydev iflag=direct oflag=direct bs=16M status=progress"
echo "or compress it with:"
echo "tar -c -I 'xz -9 -T0' -f nanopi-nixos-$(date --rfc-3339=date).img.xz $OUT/$IMG"
