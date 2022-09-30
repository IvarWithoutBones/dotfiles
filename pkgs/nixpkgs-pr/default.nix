{ createScript
, nix
, curl
, git
, pandoc
, gnused
, jq
, coreutils
, python3
, xdg-utils
}:

createScript "nixpkgs-pr" ./nixpkgs-pr.sh {
  dependencies = [
    nix
    git
    gnused
    pandoc
    jq
    coreutils
    python3
    curl
    xdg-utils
  ];

  meta.description = "automatically open a PR to nixpkgs and ping maintainers of the modified package";
}
