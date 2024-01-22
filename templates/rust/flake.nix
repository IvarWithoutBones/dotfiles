{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , naersk
    , rust-overlay
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import rust-overlay) ];
      };

      rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

      naerskLib = pkgs.callPackage naersk {
        cargo = rustToolchain;
        rustc = rustToolchain;
      };

      rustApp = naerskLib.buildPackage {
        pname = "rustApp";
        version =
          let
            year = lib.substring 0 4 self.lastModifiedDate;
            month = lib.substring 4 2 self.lastModifiedDate;
            day = lib.substring 6 2 self.lastModifiedDate;
          in
          "0.pre+date=${year}-${month}-${day}";

        src = lib.cleanSource ./.;
      };
    in
    {
      packages = {
        default = rustApp;
        inherit rustApp;
      };

      devShells.default = pkgs.mkShell {
        packages = [ rustToolchain ];
      };
    });
}
