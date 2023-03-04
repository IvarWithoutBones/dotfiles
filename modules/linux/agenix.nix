{ config
, pkgs
, agenix
, username
, system
, ...
}:

{
  imports = [ agenix.nixosModules.default ];

  environment.systemPackages = [
    agenix.packages.${system}.default

    (pkgs.runCommand "cachix-configured"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      } ''
      mkdir -p $out/bin

      makeWrapper ${pkgs.cachix}/bin/cachix $out/bin/cachix \
        --add-flags "--config ${config.age.secrets.cachix-config.path}"
    '')
  ];

  age.secrets = {
    cachix-config = {
      name = "cachix-config";
      file = ../../secrets/cachix-config.age;
      owner = username;
    };
  };
}
