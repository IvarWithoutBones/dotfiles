{ config, ... }: {
  nixpkgs.overlays = [ (self.overlays.default) ];
  services.nix-daemon.enable = true;
  users.users.ivv = {
    name = "ivv";
    home = "/Users/ivv";
  };
  # This line is required; otherwise, on shell startup, you won't have Nix stuff in the PATH.
  programs.zsh.enable = true;

  modules = [

    home-manager.darwinModule
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.ivv.imports = [
          ({ config, self, ... }: {
            home.stateVersion = "21.11";
          })
          ./home-manager/modules/zsh.nix
          ./home-manager/modules/nvim.nix
          ./home-manager/packages.nix
        ];
      };
    }
  ];

}
