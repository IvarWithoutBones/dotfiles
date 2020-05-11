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

  # Note that indentation is fucked, qutebrowser doesn't accept it any other way so now its backwards.
  extraConfig = " 
c.downloads.location.directory = '/home/ivar/downloads'\n

# Required for youtube
config.set('content.headers.user_agent', 'Mozilla/5.0 (X11; Linux x86_64; rv:57.0) Gecko/20100101 Firefox/77.0', 'https://accounts.google.com/*')\n 

# Colorscheme

completion = c.colors.completion\n
downloads = c.colors.downloads\n
hints = c.colors.hints\n
keyhint = c.colors.keyhint\n
messages = c.colors.messages\n
prompts = c.colors.prompts\n
statusbar = c.colors.statusbar\n
tabs = c.colors.tabs\n

completion.fg = '#eceff4'\n
completion.odd.bg = '#434c5e'\n
completion.even.bg = '#434c5e'\n
completion.category.fg = '#eceff4'\n
completion.category.bg = '#3b4252'\n
completion.category.border.top = '#3b4252'\n
completion.category.border.bottom = '#3b4252'\n
completion.item.selected.fg = '#eceff4'\n
completion.item.selected.bg = '#8fbcbb'\n
completion.item.selected.border.top = '#8fbcbb'\n
completion.item.selected.border.bottom = '#8fbcbb'\n
completion.match.fg = '#eee8d5'\n
completion.scrollbar.fg = '#eee8d5'\n
completion.scrollbar.bg = '#4c566a'\n

downloads.bar.bg = '#3b4252'\n
downloads.start.fg = '#eceff4'\n
downloads.error.fg = '#eceff4'\n
downloads.error.bg = '#bf616a'\n

hints.fg = '#eceff4'\n
hints.bg = '#2f343f'\n
hints.match.fg = '#eee8d5'\n

keyhint.fg = '#eceff4'\n
keyhint.suffix.fg = '#ebcb8b'\n

messages.error.fg = '#eceff4'\n
messages.error.bg = '#bf616a'\n
messages.error.border = '#bf616a'\n
messages.warning.fg = '#eceff4'\n
messages.warning.bg = '#2f3333'\n
messages.warning.border = '#ebcb8b'\n
messages.info.fg = '#eceff4'\n
messages.info.bg = '#3b4252'\n
messages.info.border = '#3b4252'\n

prompts.fg = '#eceff4'\n
prompts.border = '1px solid #eceff4'\n
prompts.bg = '#434c5e'\n
prompts.selected.bg = '#e5e9f0'\n

statusbar.normal.fg = '#eceff4'\n
statusbar.normal.bg = '#3b4252'\n
statusbar.insert.fg = '#eceff4'\n
statusbar.insert.bg = '#5e81ac'\n
statusbar.passthrough.fg = '#eceff4'\n
statusbar.passthrough.bg = '#000000'\n
statusbar.private.fg = '#eceff4'\n
statusbar.private.bg = '#e5e9f0'\n
statusbar.command.fg = '#eceff4'\n
statusbar.command.bg = '#3b4252'\n
statusbar.command.private.fg = '#eceff4'\n
statusbar.command.private.bg = '#e5e9f0'\n
statusbar.caret.fg = '#eceff4'\n
statusbar.caret.bg = '#5e81ac'\n
statusbar.caret.selection.fg = '#eceff4'\n
statusbar.caret.selection.bg = '#5e81ac'\n
statusbar.progress.bg = '#eceff4'\n
statusbar.url.fg = '#eceff4'\n
statusbar.url.error.fg = '#bf616a'\n
statusbar.url.hover.fg = '#eee8d5'\n
statusbar.url.success.http.fg = '#eceff4'\n
statusbar.url.success.https.fg = '#eceff4'\n
statusbar.url.warn.fg = '#000000'\n

tabs.indicator.start = '#8fbcbb'\n
tabs.indicator.stop = '#ebcb8b'\n
tabs.indicator.error = '#bf616a'\n
tabs.odd.bg = '#4b5151'\n
tabs.even.bg = '#4b5151'\n
tabs.selected.odd.bg = '#2f343f'\n
tabs.selected.even.bg = '#2f343f'\n
  ";
}
