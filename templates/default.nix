# Note that these are not for using this dotfiles repository, only for creating flakes for new projects.
{
  rust = {
    path = ./rust;
    description = "An opinionated flake for new Rust/Cargo workspaces";
    welcomeText = ''
      # Things left to do manually:

      ## Update dependencies to the latest version.
      * The Rust compiler in `rust-toolchain.toml` and `Cargo.toml`:
        - https://github.com/rust-lang/rust/releases
      * The GitHub actions in `.github/workflows/build.yml`:
        - https://github.com/actions/checkout/releases
        - https://github.com/cachix/install-nix-action/releases

      ## Prepare and enter a development shell.
      ```sh
      chmod +x ./scripts/* && mkdir crates && direnv allow
      ```

      ## Configure the package name in `flake.nix` and create a new Cargo crate.
      ```sh
      NAME="$(basename "$(readlink -f .)")"; sed -i "s/rust-app/''${NAME}/" ./flake.nix && cargo new --vcs none "./crates/''${NAME}" && cargo build
      ```

      ## Create a Git repository.
      ```sh
      git init && git add --all && git commit --message "initial commit"
      ```
    '';
  };
}
