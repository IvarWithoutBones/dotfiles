# Note that these are not for using this dotfiles repository, only for creating flakes for new projects.
{
  devshell = {
    path = ./devshell;
    description = "A bare-bones flake containing the skeleton of a development shell";
  };

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

      ## Configure the package name in `flake.nix` and create a new Cargo workspace.
      ```sh
      NAME="$(basename "$(readlink -f .)")"; sed -i "s/rust-app/''${NAME}/" ./flake.nix && cargo new --vcs none "./crates/''${NAME}" && cargo build
      ```

      ## Create a Git repository.
      ```sh
      git init && git add --all && git commit --message "initial commit"
      ```
    '';
  };

  rust-shell = {
    path = ./rust-shell;
    description = "A flake providing a bare-bones Rust/Cargo development shell";
    welcomeText = ''
      # Things left to do manually:

      ## Create a Git repository and enter a development shell.
      ```sh
      git init && git add --all && git commit --message "initial commit" && direnv allow
      ```

      ## When using this shell for an external repository that doesn't use Nix, add that repository as a submodule.
      A flake has to be included in the Git index for Nix to recognize it, even though you might only want to use it locally.
      Creating a new repository for the flake which includes the external repository as a submodule allows you to do that.

      ```sh
      git submodule add URL ./src
      ```
    '';
  };
}
