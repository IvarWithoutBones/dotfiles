{
  enable = true;

  searchEngines = {
    DEFAULT = "https://duckduckgo.com/?q={}";
    git = "https://github.com/search?q={}";
    kat = "https://katcr.co/katsearch/page/1/{}";
    nix = "https://nixos.org/nixos/packages.html?channel=nixpkgs-unstable&query={}";
    proton = "https://www.protondb.com/search?q={}";
    tweak = "https://tweakers.net/zoeken/?keyword={}";
    yt = "https://www.youtube.com/results?search_query={}";
  };

  settings = {
    downloads.location.directory = "/home/ivar/downloads";

    colors = {
      completion = {
        fg = "#eceff4";
        odd.bg = "#333333";
        even.bg = "#333333";
        category.fg = "#eceff4";
        category.bg = "#202020";
        category.border.top = "#202020";
        category.border.bottom = "#202020";
        item.selected.fg = "#eceff4";
        item.selected.bg = "#8fbcbb";
        item.selected.border.top = "#8fbcbb";
        item.selected.border.bottom = "#8fbcbb";
        match.fg = "#eee8d5";
        scrollbar.fg = "#eee8d5";
        scrollbar.bg = "#4c566a";
      };

      downloads = {
        bar.bg = "#3b4252";
        start.fg = "#eceff4";
        error.fg = "#eceff4";
        error.bg = "#bf616a";
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
        error.fg = "#eceff4";
        error.bg = "#bf616a";
        error.border = "#bf616a";
        warning.fg = "#eceff4";
        warning.bg = "#2f3333";
        warning.border = "#ebcb8b";
        info.fg = "#eceff4";
        info.bg = "#3b4252";
        info.border = "#3b4252";
      };

      prompts = {
        fg = "#eceff4";
        border = "1px solid eceff4";
        bg = "#434c5e";
        selected.bg = "#e5e9f0";
      };

      statusbar = {
        normal.fg = "#eceff4";
        normal.bg = "#3b4252";
        insert.fg = "#eceff4";
        insert.bg = "#5e81ac";
        passthrough.fg = "#eceff4";
        passthrough.bg = "#000000";
        private.fg = "#eceff4";
        private.bg = "#e5e9f0";
        command.fg = "#eceff4";
        command.bg = "#3b4252";
        command.private.fg = "#eceff4";
        command.private.bg = "#e5e9f0";
        caret.fg = "#eceff4";
        caret.bg = "#5e81ac";
        caret.selection.fg = "#eceff4";
        caret.selection.bg = "#5e81ac";
        progress.bg = "#eceff4";
        url.fg = "#eceff4";
        url.error.fg = "#bf616a";
        url.hover.fg = "#eee8d5";
        url.success.http.fg = "#eceff4";
        url.success.https.fg = "#eceff4";
        url.warn.fg = "#000000";
      };

      tabs = {
        indicator.start = "#8fbcbb";
        indicator.stop = "#ebcb8b";
        indicator.error = "#bf616a";
        odd.bg = "#333333";
        even.bg = "#333333";
        selected.odd.bg = "#202020";
        selected.even.bg = "#202020";
      };
    };
  };
}
