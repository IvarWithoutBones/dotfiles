{ config
, lib
, pkgs
, wayland
, ...
}:

let
  mkLua = lua: ''
    lua << EOF
      ${lua}
    EOF
  '';
in
{
  imports = [
    ./language-server.nix
    ./plugins.nix
  ];

  home.sessionVariables = rec {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Clipboard support
    extraPackages = lib.mkIf pkgs.stdenvNoCC.isLinux (with pkgs;
      lib.optional wayland wl-clipboard
      ++ lib.optional (!wayland) xclip);

    extraConfig = lib.mkBefore (mkLua ''
      local opt = vim.opt
      local api = vim.api

      function map(mode, shortcut, command)
        api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
      end

      function nmap(shortcut, command)
        map("n", shortcut, command)
      end

      function imap(shortcut, command)
        map("i", shortcut, command)
      end

      function tmap(shortcut, command)
        map("t", shortcut, command)
      end

      opt.syntax = "enable"               -- Syntax highlighting
      opt.mouse = "a"                     -- Mouse support
      opt.clipboard = "unnamedplus"       -- System clipboard support, needs xclip/wl-clipboard
      vim.cmd("set ignorecase smartcase") -- Ignore case when searching if there is no upper case character
      opt.ruler = true                    -- Show line and column number when searching

      -- Line numbers
      opt.number = true
      opt.relativenumber = true

      -- Better tab defaults
      opt.tabstop = 4
      opt.shiftwidth = 4
      opt.softtabstop = 0
      opt.expandtab = true
      opt.smarttab = true

      -- Insert a newline without going into insert mode
      nmap("<Enter>", "o<Esc>")

      -- Without this space mappings do not work
      nmap("<SPACE>", "<Nop>")

      -- use `Alt+Shift+{h,j,k,l}` to resize splits
      nmap("<A-J>", ":resize +2<CR>")
      nmap("<A-K>", ":resize -2<CR>")
      nmap("<A-L>", ":vertical resize +2<CR>")
      nmap("<A-H>", ":vertical resize -2<CR>")

      -- Find and replace a string in the current buffer based on user input
      nmap("<A-f>", ":luafile ${./scripts/find-and-replace.lua}<CR>")

      -- use `ALT+{h,j,k,l}` to navigate windows from any mode
      ${lib.concatStringsSep "\n" (map (key: ''
        tmap("<A-${key}>", "<C-\\><C-N><C-w>${key}")
        imap("<A-${key}>", "<C-\\><C-N><C-w>${key}")
        nmap("<A-${key}>", "<C-w>${key}")
      '') [ "h" "j" "k" "l" ])}

      -- Some languages automatically insert a comment when creating a newline if the current line has one. Disable that.
      api.nvim_create_autocmd("FileType", {
        pattern = "*",
        command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
      })

      -- Automatically change the working directory to a git repository's root
      api.nvim_create_autocmd("VimEnter", {
        pattern = "*",
        callback = function()
          local gitRoot = vim.fn.system("${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null")
          if (gitRoot ~= nil and gitRoot ~= "") then
            vim.cmd("cd " .. gitRoot)
          end
        end
      })
    '');
  };
}
