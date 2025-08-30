{ ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    pulse.enable = true;
    jack.enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
}
