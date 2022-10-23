{ self
, nixpkgs
, agenix
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
        inherit username nixpkgs;
      };

      modules = [
        ./modules/nix.nix
      ];

      home-manager = {
        enable = true;
        inherit username;

        modules = [
          ./home-manager/default.nix
          ./home-manager/packages.nix
          ./home-manager/modules/nix-index.nix
          ./home-manager/modules/mpv.nix
          ./home-manager/modules/fzf.nix
          ./home-manager/modules/git.nix
          ./home-manager/modules/zsh.nix
          ./home-manager/modules/neovim
          ./home-manager/modules/bat.nix
          ./home-manager/modules/discord.nix
          ./home-manager/modules/qutebrowser.nix
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
      ./modules/linux/graphical.nix
      ./modules/linux/flatpak.nix
      ./modules/linux/networking.nix
      ./modules/linux/gpg.nix
      ./modules/linux/agenix.nix
      ./modules/linux/docker.nix
      #./modules/linux/android.nix
    ] ++ ivv.modules;

    home-manager = ivv.home-manager // {
      enable = true;

      modules = [
        ./home-manager/modules/linux/alacritty.nix
        ./home-manager/modules/linux/dunst.nix
        ./home-manager/modules/linux/gtk.nix
        ./home-manager/modules/linux/i3-sway
      ] ++ ivv.home-manager.modules;
    };

    # TODO: enable networking config for darwin too
    extraConfig = {
      networking.extraHosts = ''
        192.168.1.44 pc
        192.168.1.37 laptop
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
    ] ++ ivv.modules;

    home-manager = ivv.home-manager // {
      modules = [
        ./home-manager/modules/darwin/applications.nix
        ./home-manager/modules/darwin/swiftbar
      ] ++ ivv.home-manager.modules;
    };

    commonSpecialArgs = ivv.commonSpecialArgs // {
      wayland = false;
    };
  };
}
