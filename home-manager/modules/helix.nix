{ lib
, pkgs
, ...
}:

let
  packages = with pkgs; [
    taplo-lsp # TOML
    nodePackages.vscode-json-languageserver # JSON
    yaml-language-server # YAML
    typescript-language-server # Typescript/Javascript
    vscode-langservers-extracted # HTML/CSS
    sumneko-lua-language-server # Lua
    glsl_analyzer # GLSL
    cmake-language-server # CMake

    # C/C++
    clang-tools
    clang

    # C#
    dotnet-sdk
    omnisharp-roslyn

    # Bash
    shellcheck
    nodePackages.bash-language-server
    shfmt

    # Python
    python3Packages.python-lsp-server # Python
    ruff

    # Nix
    nil-language-server
    nixpkgs-fmt

    # Rust
    cargo
    rustfmt
    rustc
    clippy
    rust-analyzer
  ];

  # A hacky way to add packages to helix's environment if they are not already present in $PATH.
  # Needed to allow projects to overwrite tools we bundle with the editor, for example when we want to use nightly Rust for one project.
  # Note that we cannot use `extraPackages` as the defaults would take priority over packages from the environment.
  helixWithDefaultPackages = pkgs.runCommand "helix-with-default-packages"
    {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe pkgs.helix} $out/bin/hx --suffix PATH : ${lib.makeBinPath packages}
  '';
in
{
  programs.helix = {
    enable = true;
    package = helixWithDefaultPackages;

    settings = {
      theme = "catppuccin_mocha";

      keys.normal = {
        C-f = ":format"; # Format the current buffer
        A-q = ":buffer-close"; # Close the current buffer

        "A-]" = ":buffer-next"; # Jump to the next buffer
        "A-[" = ":buffer-previous"; # Jump to the previous buffer

        # Navigate between views using Alt+{h,j,k,l}
        A-h = "jump_view_left";
        A-j = "jump_view_down";
        A-k = "jump_view_up";
        A-l = "jump_view_right";
      };

      editor = {
        cursorline = true;
        color-modes = true;
        line-number = "relative";
        bufferline = "always";

        lsp = {
          display-messages = true;
        };

        indent-guides = {
          render = true;
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
        };

        statusline = {
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";

          left = [
            "mode"
            "spacer"
            "diagnostics"
            "spinner"
            "file-name"
          ];

          right = [
            "version-control"
            "separator"
            "workspace-diagnostics"
            "separator"
            "selections"
            "separator"
            "position"
            "position-percentage"
            "spacer"
          ];
        };
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          formatter.command = "nixpkgs-fmt";
        }

        {
          name = "bash";
          formatter = {
            command = "shfmt";
            args = [
              "--binary-next-line"
              "--space-redirects"
              "--case-indent"
              "--simplify"
              "--case-indent"
              "--apply-ignore"
              "-" # Use standard input/output
            ];
          };
        }
      ];

      language-server = {
        rust-analyzer = {
          config.checkOnSave.command = "clippy";
        };
      };
    };
  };
}
