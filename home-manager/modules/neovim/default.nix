{ lib
, pkgs
, wayland
, nixvim
, ...
}:

let
  # A hacky way to add packages to neovims environment if they are not already in $PATH, using `makeWrapper --suffix`.
  # Needed to allow projects to overwrite tools bundled with neovim, for example using a nightly rust toolchain.
  # Note that we cannot use `extraPackages`, as those packages would take priority over installations from the environment.
  nvimWithDefaultPackages = packages:
    pkgs.runCommand "neovim-wrapped"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      } ''
      # Symlinking is being a bit painful here, another derivation attempts to mutate the output.
      mkdir -p $out
      cp -r ${pkgs.neovim-unwrapped}/* $out
      chmod -R +w $out
      makeWrapper ${pkgs.neovim-unwrapped}/bin/nvim $out/bin/nvim --suffix PATH : ${lib.makeBinPath packages}
    '';
in
{
  imports = [
    nixvim.homeManagerModules.nixvim
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

    # See `plugins/lspconfig.lua` for the configuration of the language servers.
    package = with pkgs; nvimWithDefaultPackages ([
      taplo-lsp # TOML
      yaml-language-server # YAML
      nodePackages.typescript-language-server # Typescript/Javascript
      nodePackages.vscode-json-languageserver # JSON
      nodePackages.vscode-html-languageserver-bin # HTML
      python3Packages.python-lsp-server # Python
      sumneko-lua-language-server # Lua
      cmake-language-server # CMake

      # C/C++
      clang-tools
      clang

      # C#
      dotnet-sdk_6
      omnisharp-roslyn

      # Bash
      shellcheck
      nodePackages.bash-language-server

      # Nix
      nil-language-server
      nixpkgs-fmt

      # Rust
      cargo
      rustfmt
      rustc
      clippy
      rust-analyzer
    ] ++ lib.optionals pkgs.stdenvNoCC.isLinux [
      (if wayland then wl-clipboard else xclip) # Required for system clipboard support
      glslls # GLSL language server, does not support Darwin.
    ]);

    options = {
      syntax = "enable";
      termguicolors = true;

      # Line numbers
      number = true;
      relativenumber = true;

      # Always show the signcolumn, otherwise text would be shifted when displaying error icons
      signcolumn = "yes";

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

      # Time (in milliseconds) between CursorHold event updates, used by signature hints
      updatetime = 200;
    };

    keymaps = [
      # Space mappings break without this
      { mode = "n"; key = "<space>"; action = "<nop>"; }

      # Add a newline without going into insert mode
      { mode = "n"; key = "<enter>"; action = "o<esc>"; }

      # Start a case-sensitive (\C) regex substitution
      # \V selects "very nomagic" mode (never change, vim) so that everything is literal unless explicitly escaped
      { mode = "n"; key = "gs"; action = ":%s/\\C\\V"; }
      { mode = "v"; key = "gs"; action = ":s/\\C\\%V\\V"; } # %V matches the selection instead of the whole line

      # Capture something in a regex group, for substitutions
      { mode = "c"; key = "<C-o>"; action = "\\(\\.\\*\\)"; } # Group matching anything
      { mode = "c"; key = "<C-S-o>"; action = "\\(\\)<Left><Left>"; } # Empty group with cursor inside
      { mode = "c"; key = "<C-.>"; action = "\\.\\*"; } # Match anything

      # Stay in visual mode after indenting a block
      { mode = "v"; key = ">"; action = ">gv"; }
      { mode = "v"; key = "<"; action = "<gv"; }

      # Jump between diagnostics
      { mode = "n"; key = "<space>dn"; options.silent = true; action = ":lua vim.diagnostic.goto_next({ float = false })<cr>"; }
      { mode = "n"; key = "<space>dN"; options.silent = true; action = ":lua vim.diagnostic.goto_prev({ float = false })<cr>"; }

      # Use `Control+Alt+{h,j,k,l}` to resize buffers from normal mode
      { mode = "n"; key = "<C-A-h>"; options.silent = true; action = ":vertical resize -2<cr>"; }
      { mode = "n"; key = "<C-A-j>"; options.silent = true; action = ":resize +2<cr>"; }
      { mode = "n"; key = "<C-A-k>"; options.silent = true; action = ":resize -2<cr>"; }
      { mode = "n"; key = "<C-A-l>"; options.silent = true; action = ":vertical resize +2<cr>"; }

      # Use `Alt+{h,j,k,l}` to navigate buffers from normal mode
      { mode = "n"; key = "<A-h>"; action = "<C-w>h"; }
      { mode = "n"; key = "<A-j>"; action = "<C-w>j"; }
      { mode = "n"; key = "<A-k>"; action = "<C-w>k"; }
      { mode = "n"; key = "<A-l>"; action = "<C-w>l"; }

      # Use `Alt+{h,j,k,l}` to navigate buffers from terminal mode
      { mode = "t"; key = "<A-h>"; action = "<C-\\><C-N><C-w>h"; }
      { mode = "t"; key = "<A-j>"; action = "<C-\\><C-N><C-w>j"; }
      { mode = "t"; key = "<A-k>"; action = "<C-\\><C-N><C-w>k"; }
      { mode = "t"; key = "<A-l>"; action = "<C-\\><C-N><C-w>l"; }

      # Mimic normal mode mappings from insert mode using Alt as a modifier
      { mode = "i"; key = "<A-h>"; action = "<Left>"; }
      { mode = "i"; key = "<A-j>"; action = "<Down>"; }
      { mode = "i"; key = "<A-k>"; action = "<Up>"; }
      { mode = "i"; key = "<A-l>"; action = "<Right>"; }
      # Word motions
      { mode = "i"; key = "<A-w>"; action = "<C-\\><C-o>w"; }
      { mode = "i"; key = "<A-e>"; action = "<C-\\><C-o>e<Right>"; }
      { mode = "i"; key = "<A-b>"; action = "<C-\\><C-o>b"; }
      # Start a delete motion
      { mode = "i"; key = "<A-d>"; action = "<C-\\><C-o>d"; }
    ];

    autoCmd =
      let
        setFileType = ext: ft: {
          desc = "Set the file type for '.${ext}' files to ${ft}";
          event = [ "BufRead" "BufNewFile" ];
          pattern = "*.${ext}";
          command = "set filetype=${ft}";
        };
      in
      [
        (setFileType "ll" "llvm")
        (setFileType "wgsl" "wgsl")
        (setFileType "vert" "glsl")
        (setFileType "tesc" "glsl")
        (setFileType "tese" "glsl")
        (setFileType "frag" "glsl")
        (setFileType "geom" "glsl")
        (setFileType "comp" "glsl")

        {
          desc = "Change the working directory to a git repository's root";
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
          desc = "Disable insertion of a comment character when starting a new line";
          event = [ "FileType" ];
          pattern = "*";
          command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o";
        }
      ];
  };
}

