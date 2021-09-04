{ pkgs, ... }: {

programs.qutebrowser = {
  enable = true;

  searchEngines = {
    DEFAULT = "https://duckduckgo.com/?q={}";
    git = "https://github.com/search?q={}";
    kat = "https://katcr.co/katsearch/page/1/{}";
    nix = "https://search.nixos.org/packages?query={}&sort=relevance&channel=unstable";
    pip = "https://pypi.org/search/?q={}";
    proton = "https://www.protondb.com/search?q={}";
    yt = "https://www.youtube.com/results?search_query={}";
  };

  quickmarks = {
    youtube = "https://www.youtube.com/";
    deepl = "https://www.deepl.com/translator";
    protonmail = "https://mail.protonmail.com/inbox";
    github = "https://github.com/";
    github-gists = "https://gist.github.com";
    dotfiles = "https://github.com/ivarWithoutBones/dotfiles";
    home-manager-manual = "https://nix-community.github.io/home-manager/";
    home-manager-options = "https://rycee.gitlab.io/home-manager/options.html";
    nixos-options = "https://nixos.org/nixos/options.html#";
    nixos-manual = "https://nixos.org/nixos/manual/";
    nixpkgs-manual = "https://nixos.org/manual/nixpkgs/stable/";
    nixpkgs = "https://github.com/NixOS/nixpkgs";
    nur-actions = "https://github.com/IvarWithoutBones/NUR/actions";
    yuzu = "https://github.com/yuzu-emu/yuzu";
    ryujinx = "https://github.com/ryujinx/ryujinx";
  };

  settings = {
    downloads.location.directory = "${builtins.getEnv "HOME"}/downloads";

    colors = {
      completion = {
        fg = "#eceff4";
        odd.bg = "#434c5e";
        even.bg = "#434c5e";
        match.fg = "#eee8d5";
        category = {
          fg = "#eceff4";
          bg = "#2f343f";
          border = {
            top = "#2f343f";
            bottom = "#2f343f";
          };
        };
        item.selected = {
          fg = "#eceff4";
          bg = "#8fbcbb";
          border = {
            top = "#8fbcbb";
            bottom = "#8fbcbb";
          };
        };
        scrollbar = {
          fg = "#eee8d5";
          bg = "#4c566a";
        };
      };

      downloads = {
        bar.bg = "#3b4252";
        start.fg = "#eceff4";
        error = {
          fg = "#eceff4";
          bg = "#bf616a";
        };
      };

      hints = {
        fg = "#eceff4";
        bg = "#2f343f";
        match.fg = "#eee8d5";
      };

      keyhint = {
        fg = "#eceff4";
        suffix.fg = "#ebcb8b";
      };

      messages = {
        error = {
          fg = "#eceff4";
          bg = "#bf616a";
          border = "#bf616a";
        };
        warning = {
          fg = "#eceff4";
          bg = "#2f3333";
          border = "#ebcb8b";
        };
        info = {
          fg = "#eceff4";
          bg = "#3b4252";
          border = "#3b4252";
        };
      };

      prompts = {
        fg = "#eceff4";
        border = "1px solid eceff4";
        bg = "#434c5e";
        selected.bg = "#e5e9f0";
      };

      statusbar = {
        progress.bg = "#eceff4";
        normal = {
          fg = "#eceff4";
          bg = "#3b4252";
        };
        insert = {
          fg = "#eceff4";
          bg = "#5e81ac";
        };
        command = {
          fg = "#eceff4";
          bg = "#3b4252";
          private = {
            fg = "#ffffff";
            bg = "#202020";
          };
        };
        caret = {
          fg = "#eceff4";
          bg = "#5e81ac";
          selection = {
            fg = "#eceff4";
            bg = "#5e81ac";
          };
        };
        url = {
          fg = "#eceff4";
          error.fg = "#bf616a";
          hover.fg = "#eee8d5";
          warn.fg = "#000000";
          success = {
            http.fg = "#eceff4";
            https.fg = "#eceff4";
          };
        };
      };

      tabs = {
        indicator = {
          start = "#8fbcbb";
          stop = "#ebcb8b";
          error = "#bf616a";
        };
        selected = {
          odd.bg = "#2f343f";
          even.bg = "#2f343f";
        };
        even.bg = "#4b5151";
        odd.bg = "#4b5151";
      };
    };
  };
}; }
