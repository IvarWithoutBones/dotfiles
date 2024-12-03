{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , crane
    , rust-overlay
    }:
    {
      overlays.default = final: prev: {
        inherit (self.packages.${final.system}) rust-app;
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
    let
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };

      craneLib = (crane.mkLib pkgs).overrideToolchain (pkgs:
        # Note that the `rust-bin` package comes from the `rust-overlay` input.
        pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml
      );

      rust-app = pkgs.callPackage ./package.nix {
        pname = "rust-app";
        version =
          let
            year = lib.substring 0 4 self.lastModifiedDate;
            month = lib.substring 4 2 self.lastModifiedDate;
            day = lib.substring 6 2 self.lastModifiedDate;
          in
          "${year}-${month}-${day}-${self.shortRev or "no-git"}";

        src = craneLib.cleanCargoSource ./.;
        inherit craneLib;
      };

      # Run a command supplied with each file with the given extension as an argument.
      runCommandWithFileExt = { name, extension, command }:
        let
          src = lib.sources.sourceFilesBySuffices (lib.cleanSource ./.) [ extension ];
        in
        pkgs.runCommand name { inherit src; } ''
          readarray -d "" files < <(${lib.getExe pkgs.fd} --print0 --hidden --base-directory $src --absolute-path --type file --extension "${extension}")
          ${command} "''${files[@]}"
          touch $out
        '';
    in
    {
      checks = rust-app.tests // {
        nix-fmt = runCommandWithFileExt {
          name = "nix-fmt";
          extension = ".nix";
          command = "${lib.getExe pkgs.nixpkgs-fmt} --check";
        };

        yaml-fmt = runCommandWithFileExt {
          name = "yaml-fmt";
          extension = ".yml";
          command = "${lib.getExe pkgs.yamlfmt} -lint -conf $src/.yamlfmt.yml";
        };

        sh-fmt = runCommandWithFileExt {
          name = "sh-fmt";
          extension = ".sh";
          command = "${lib.getExe pkgs.shfmt} --simplify --diff";
        };

        shellcheck = runCommandWithFileExt {
          name = "shellcheck";
          extension = ".sh";
          command = "${lib.getExe pkgs.shellcheck} --enable=all";
        };
      };

      packages = {
        default = rust-app;
        inherit rust-app;
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ rust-app ];

        packages = with pkgs; [
          nixpkgs-fmt
          taplo
          shfmt
          yamlfmt
          fd
          shellcheck
        ];
      };
    }));
}
