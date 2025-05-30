{ self
, nixpkgs
, agenix
, nixvim
, lib
, nix-index-database
}:

rec {
  laptop = {
    touchpad = true;
    battery = true;
    bluetooth = true;
  };

  stateVersion = "21.11";

  ivv =
    let
      username = "ivv";
    in
    {
      inherit username;

      commonSpecialArgs = {
        inherit username nixpkgs nixvim nix-index-database;
        dotfiles-flake = self;
      };

      modules = [
        ./modules/nix.nix
      ];

      home-manager = {
        enable = true;
        inherit username;

        modules = [
          ./home-manager/modules/alacritty.nix
          ./home-manager/default.nix
          ./home-manager/packages.nix
          ./home-manager/modules/less.nix
          ./home-manager/modules/nix-index.nix
          ./home-manager/modules/readline.nix
          ./home-manager/modules/fzf.nix
          ./home-manager/modules/git.nix
          ./home-manager/modules/zsh.nix
          ./home-manager/modules/neovim
          ./home-manager/modules/bat.nix
          ./home-manager/modules/discord.nix
          ./home-manager/modules/helix.nix
          ./home-manager/modules/gdb.nix
        ];

        extraConfig = {
          home.stateVersion = stateVersion;
        };
      };

      extraConfig = {
        nixpkgs.overlays = [ self.overlays.default ];
      };
    };

  ivv-linux = ivv // {
    specialArgs = {
      inherit agenix;
    };

    modules = [
      ./modules/linux/hardware.nix
      ./modules/linux/system.nix
      ./modules/linux/steam.nix
      ./modules/linux/keyring.nix
      ./modules/linux/flatpak.nix
      ./modules/linux/networking.nix
      ./modules/linux/gpg.nix
      ./modules/linux/agenix.nix
      ./modules/linux/docker.nix
      ./modules/linux/perf.nix
      ./modules/linux/audio.nix
      ./modules/linux/jellyfin.nix
      ./modules/linux/zerotierone.nix
      ./modules/linux/greetd.nix
      ./modules/linux/sunshine.nix
      ./modules/linux/lockscreen.nix
    ] ++ ivv.modules;

    home-manager = ivv.home-manager // {
      enable = true;

      modules = [
        ./home-manager/modules/linux/dunst.nix
        ./home-manager/modules/linux/xresources.nix
        ./home-manager/modules/linux/gtk.nix
        ./home-manager/modules/linux/keyring.nix
        ./home-manager/modules/linux/i3-sway
        # TODO: re-enable on Darwin once the following issue is fixed: https://github.com/NixOS/nixpkgs/issues/327836
        ./home-manager/modules/mpv.nix
        # TODO: re-enable on Darwin once `pyobjc` is packaged and added to qutebrowser. Without this qutebrowser throws an error upon startup.
        # See the following issue for more information: https://github.com/NixOS/nixpkgs/issues/101360
        ./home-manager/modules/qutebrowser.nix
      ] ++ ivv.home-manager.modules;
    };

    # TODO: enable networking config for darwin too
    extraConfig = {
      networking.extraHosts = ''
        192.168.1.44 pc
        192.168.1.37 laptop
        192.168.7.2 rpi
      '';

      users.users.${ivv.username}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzp7kYG8wHjoU1Ski/hABNuT3puOT3icW9DYnweJdR0 ivv@nixos-pc"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZS38w38lOTIkwTWwnZHFpKIhTKFbj90iDsMjFK7E2G ivv@nixos-laptop"
      ];

      system.stateVersion = stateVersion;
    } // ivv.extraConfig;
  };

  ivv-darwin = ivv // {
    modules = [
      ./modules/darwin
      ./modules/darwin/applications.nix
      ./modules/darwin/yabai
      ./modules/darwin/skhd
      ./modules/darwin/nixos-builder.nix
    ] ++ ivv.modules;

    home-manager = ivv.home-manager // {
      modules = [
        ./home-manager/modules/darwin/swiftbar
      ] ++ ivv.home-manager.modules;
    };

    commonSpecialArgs = ivv.commonSpecialArgs // {
      wayland = false;
    };
  };
}
