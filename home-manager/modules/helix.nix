{ config
, pkgs
, ...
}:

{
  programs.helix = {
    enable = true;

    package = pkgs.buildEnv {
      name = "helix-with-deps";
      paths = with pkgs; [
        helix
        clippy
      ];
    };

    settings = {
      theme = "catppuccin_mocha";

      keys.normal = {
        C-f = ":format";
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
            "spinner"
            "file-name"
            "diagnostics"
          ];

          right = [
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

    languages = [
      {
        name = "nix";
        language-server.command = "${pkgs.nil-language-server}/bin/nil";
        formatter.command = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt";
        auto-format = false;
      }
      {
        name = "rust";
        language-server = {
          command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          config = {
            checkOnSave.command = "clippy";
          };
        };
      }
      {
        name = "bash";
        language-server = {
          command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
          args = [ "start" ];
        };
      }
    ];
  };
}
