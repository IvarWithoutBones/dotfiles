{
  self,
  inputs,
}:

let
  username = "ivv";

  common = {
    inherit username;

    commonSpecialArgs.ivar-dotfiles = {
      inherit inputs;
      flake = self;
    };

    modules = [
      ./modules/nix.nix
      (
        { ... }:
        {
          nix.settings = {
            trusted-users = [ username ];
            allowed-users = [ username ];
          };
        }
      )
    ];

    home-manager = {
      enable = true;
      inherit username;

      modules = [
        ./home-manager/default.nix
        ./home-manager/packages.nix
        ./home-manager/modules/alacritty.nix
        ./home-manager/modules/vivid.nix
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
        ./home-manager/modules/mpv.nix
        ./home-manager/modules/qutebrowser.nix
        ./home-manager/modules/fonts.nix
      ];
    };

    extraConfig = {
      nixpkgs.overlays = [ self.overlays.default ];
    };
  };
in
{
  linux = common // {
    modules = [
      (
        { config, pkgs, ... }:
        {
          users.users."${username}" = {
            isNormalUser = true;
            shell = pkgs.zsh;
            extraGroups = [
              "wheel"
              "plugdev"
              "netdev"
              "dialout"
              "docker"
              config.services.transmission.group
            ];
          };
        }
      )

      ./modules/linux/system.nix
      ./modules/linux/keyring.nix
      ./modules/linux/polkit.nix
      ./modules/linux/flatpak.nix
      ./modules/linux/networking.nix
      ./modules/linux/gpg.nix
      ./modules/linux/docker.nix
      ./modules/linux/udev.nix
      ./modules/linux/zerotierone.nix
      ./modules/linux/hardware/audio.nix
      ./modules/linux/desktop/lockscreen.nix
      ./modules/linux/desktop/sessions.nix
      ./modules/linux/desktop/tuigreet.nix
      ./modules/linux/transmission.nix
    ]
    ++ common.modules;

    home-manager = common.home-manager // {
      modules = [
        ./home-manager/modules/linux/cursor.nix
        ./home-manager/modules/linux/gtk.nix
        ./home-manager/modules/linux/xresources.nix
        ./home-manager/modules/linux/dunst.nix
        ./home-manager/modules/linux/keyring.nix
        ./home-manager/modules/linux/xdg.nix
        ./home-manager/modules/linux/monitor-layout.nix
      ]
      ++ common.home-manager.modules;
    };
  };

  darwin = common // {
    commonSpecialArgs = common.commonSpecialArgs // {
      inherit username; # TODO: Stop passing this with specialArgs.
    };

    modules = [
      ./modules/darwin
      ./modules/darwin/applications.nix
      ./modules/darwin/yabai
      ./modules/darwin/skhd
      ./modules/darwin/nixos-builder.nix
    ]
    ++ common.modules;

    home-manager = common.home-manager // {
      modules = [
        ./home-manager/modules/darwin/swiftbar
      ]
      ++ common.home-manager.modules;
    };
  };
}
