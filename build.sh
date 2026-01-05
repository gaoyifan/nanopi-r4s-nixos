#! /usr/bin/env bash

set -euo pipefail

OUT=out

mkdir -p $OUT

nix build .#sdImage -o result-sd
IMG=$(basename result-sd/sd-image/*)
rm -f "$OUT/$IMG"
cp result-sd/sd-image/$IMG $OUT/
chmod u+w "$OUT/$IMG"

nix build .#uboot -o result-uboot
cp -f result-uboot/idbloader.img result-uboot/u-boot.itb result-uboot/u-boot-spl.bin $OUT/

dd if=$OUT/idbloader.img of=$OUT/$IMG conv=fsync,notrunc bs=512 seek=64
dd if=$OUT/u-boot.itb of=$OUT/$IMG conv=fsync,notrunc bs=512 seek=16384

#sfdisk --dump $OUT/$IMG

echo "Image built successfully?!"
echo ""
echo "Now burn the image with:"
echo "dd if=$OUT/$IMG of=/dev/mydev iflag=direct oflag=direct bs=16M status=progress"
echo "or compress it with:"
echo "tar -c -I 'xz -9 -T0' -f nanopi-nixos-$(date --rfc-3339=date).img.xz $OUT/$IMG"
