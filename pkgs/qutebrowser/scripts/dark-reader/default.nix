{ writeText }:

# Dark mode for pages that do not natively support it

writeText "dark-reader.js" ''
  // ==UserScript==
  // @name          Dark Reader (Unofficial)
  // @icon          https://darkreader.org/images/darkreader-icon-256x256.png
  // @namespace     DarkReader
  // @description	  Inverts the brightness of pages to reduce eye strain
  // @version       4.9.52
  // @author        https://github.com/darkreader/darkreader#contributors
  // @homepageURL   https://darkreader.org/ | https://github.com/darkreader/darkreader
  // @require       https://cdn.jsdelivr.net/npm/darkreader/darkreader.min.js
  // @run-at        document-end
  // @grant         none
  // @include       http*
  // @exclude       *://*google*.*/*
  // @exclude       *://ko-fi.com/*
  // @exclude       *://clang.llvm.org/*
  // @noframes
  // ==/UserScript==

  DarkReader.enable({
    brightness: 100,
    contrast: 100,
    sepia: 0
  });
''
