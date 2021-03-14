## Patches for Nanopi R4S
This repo is an overlay that can be imported from your configuration like so:
```nix
{
  imports = [
	<path to this repo>/nanopi-r4s.nix
  ];
}
```

### build U-Boot
```
nix-build '<nixos/nixpkgs>' --argstr system aarch64-linux -A uboot_NanopiR4S
```

### build SD-Image
```
nix-build '<nixpkgs/nixos>' --argstr system aarch64-linux -A config.system.build.sdImage -I nixos-config=sd-image.nix
```
