{ callPackage }:

{
  greasemonkey = {
    dark-reader = callPackage ./dark-reader { };

    youtube-adblock = callPackage ./youtube-adblock { };

    youtube-sponsorblock = callPackage ./youtube-sponsorblock { };
  };

  userscripts = {
    fake-fullscreen = callPackage ./fake-fullscreen { };

    nixpkgs-tracker = callPackage ./nixpkgs-tracker { };
  };
}
