<div align="center">

# dotfiles

My NixOS configuration, using nix flakes and home-manager.

</div>

This repository most notably configures my window manager, i3-gaps/sway, and my editor, neovim. This is done entirely in the user environment using home-manager as to seperate user-dependant configuration from the host system itself. This means that for example NixOS is not aware of what desktop environment is being used, it simply executes a script in the users home directory.

This implements both my laptop and desktop machines, using a completely shared configuration. A wrapper function around `nixosSystem` exists in [`lib.nix`](https://github.com/IvarWithoutBones/dotfiles/blob/main/lib.nix) to make this process as simple as possible, and hardware specific configuration is done in [`flake.nix`](https://github.com/IvarWithoutBones/dotfiles/blob/main/flake.nix) in an attempt to make this repository (mostly) system independant.

The functions `./lib.nix` implements are available as the flake output `lib`, and any packages found in `./pkgs` are available in the flakes default overlay. If you have any questions on how to use them, please don't hesistate to open up an issue.
