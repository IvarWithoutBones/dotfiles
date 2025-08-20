{ ... }:

{
  # Required for some GTK programs.
  programs.dconf.enable = true;

  services.xserver = {
    enable = true;
    enableTearFree = true; # Reduce screen tearing.
  };
}
