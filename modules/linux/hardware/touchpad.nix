{ ... }:

{
  services.libinput = {
    enable = true;

    touchpad = {
      tapping = false;
      naturalScrolling = true;
    };
  };
}
