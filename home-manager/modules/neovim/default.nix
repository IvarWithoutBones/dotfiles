{ lib
, pkgs
, wayland
, nixvim
, ...
}:

{
  imports = [
    nixvim.homeManagerModules.nixvim
    ./language-server.nix
    ./plugins.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.nixvim = {
    enable = true;

    viAlias = true;
    vimAlias = true;

    # Required for system clipboard support
    extraPackages = lib.mkIf pkgs.stdenvNoCC.isLinux (with pkgs;
      lib.optional wayland wl-clipboard
      ++ lib.optional (!wayland) xclip
    );

    options = {
      syntax = "enable";
      termguicolors = true;

      # Line numbers
      number = true;
      relativenumber = true;

      # Search
      ignorecase = true;
      smartcase = true;

      # Tab defaults (might get overwritten by an LSP server)
      tabstop = 4;
      shiftwidth = 4;
      softtabstop = 0;
      expandtab = true;
      smarttab = true;

      # System clipboard support, needs xclip/wl-clipboard
      clipboard = "unnamedplus";

      # Highlight the current line
      cursorline = true;

      # Show line and column when searching
      ruler = true;

      # Global substitution by default
      gdefault = true;

      # Start scrolling when the cursor is X lines away from the top/bottom
      scrolloff = 5;
    };

    maps =
      let
        silent = action: {
          inherit action;
          silent = true;
        };

        # Use `ALT+{h,j,k,l}` to navigate windows from any mode.
        # This generates an attribute set that looks as follows:
        # { normal = { "<A-h>" = "<C-w>h"; "<A-j>" = "<C-w>j"; ... }; insert = { ... }; ... }
        navigate =
          let
            keys = [ "h" "j" "k" "l" ];
            modes = rec {
              normal = "<C-w>";
              insert = "<C-\\><C-N><C-w>";
              terminal = insert;
            };
          in
          lib.mapAttrs
            (mode: escape:
              builtins.listToAttrs (builtins.map
                (key: {
                  name = "<A-${key}>";
                  value = escape + key;
                })
                keys))
            modes;
      in
      lib.recursiveUpdate navigate {
        visual = {
          # Stay in visual mode after indenting a block
          ">" = ">gv";
          "<" = "<gv";
        };

        normal = {
          # Space mappings break without this
          "<space>" = "<nop>";

          # Add a newline without going into insert mode
          "<enter>" = "o<esc>";

          # Find and replace a string in the current buffer
          "rf" = silent ":luafile ${./scripts/find-and-replace.lua}<cr>";

          # Use `Alt+Shift+{h,j,k,l}` to resize splits
          "<A-J>" = silent ":resize +2<CR>";
          "<A-K>" = silent ":resize -2<CR>";
          "<A-L>" = silent ":vertical resize +2<CR>";
          "<A-H>" = silent ":vertical resize -2<CR>";

          # Diagnostics
          "<space>dn" = silent ":lua vim.diagnostic.goto_next({ float = false })<cr>";
          "<space>dN" = silent ":lua vim.diagnostic.goto_prev({ float = false })<cr>";

          # Start a case-sensitive regex substitution
          "gs" = ":%s/\\C";
        };
      };

    autoCmd = [
      {
        description = "Change the working directory to a git repository's root";
        event = [ "VimEnter" ];
        pattern = "*";
        # Unfortunately there is no API to run a lua function directly, so we have to write it to a file
        command = "luafile ${pkgs.writeText "cd-git-root.lua" ''
          local gitRoot = vim.fn.system("${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null")
          if (gitRoot ~= nil and gitRoot ~= "") then
              vim.cmd("cd " .. gitRoot)
          end
        ''}";
      }

      {
        description = "Disable insertion of a comment character when starting a new line";
        event = [ "FileType" ];
        pattern = "*";
        command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o";
      }
    ];
  };
}

