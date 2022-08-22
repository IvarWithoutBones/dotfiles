rec {
  laptop = {
    touchpad = true;
    battery = true;
    bluetooth = true;
  };

  ivv = rec {
    username = "ivv";

    commonSpecialArgs = {
      inherit username;
    };

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
        ./home-manager/modules/nvim.nix
        ./home-manager/modules/bat.nix
        ./home-manager/modules/gtk.nix
      ];

      extraConfig = {
        home.stateVersion = "21.11";
      };
    };
  };

  ivv-linux = ivv // {
    modules = [
      ./modules/hardware.nix
      ./modules/nix.nix
      ./modules/system.nix
      ./modules/steam.nix
      ./modules/graphical.nix
      ./modules/networking.nix
      ./modules/gpg.nix
      ./modules/agenix.nix
      ./modules/docker.nix
    ];

    home-manager = ivv.home-manager // {
      enable = true;

      modules = [
        ./home-manager/modules/alacritty.nix
        ./home-manager/modules/discord.nix
        ./home-manager/modules/qutebrowser.nix
        ./home-manager/modules/dunst.nix
        ./home-manager/modules/i3-sway
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
    };
  };

  ivv-darwin = ivv // {
    modules = [
      ./modules/darwin
      ./modules/darwin/yabai.nix
    ];

    commonSpecialArgs = ivv.commonSpecialArgs // {
      wayland = false;
    };
  };
}
