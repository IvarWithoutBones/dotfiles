{ ...
}:

# Configuration for a NixOS virtual machine on which Nix can perform builds if linux-only packages are needed.

{
  nix = {
    linux-builder = {
      enable = true;
      ephemeral = true; # Do not retain state
    };
  };
}
