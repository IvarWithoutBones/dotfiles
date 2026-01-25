{ config
, lib
, ...
}:

# Set certain monitor layouts if the appropriate monitors are connected

let
  outputs = {
    desktop-iiyama = {
      model = "Iiyama North America PL3490WQ 0x00000101";
      edid = "00ffffffffffff0026cd047601010000041d0103805022782aca95a6554ea1260f5054bd4b00d1c081808140950f9500b30081c00101dea370e0d4a0355000703a50204f3100001cef5170e0d4a0355000703a50204f3100001c000000fc00504c3334393057510a20202020000000fd0017501e632d000a20202020202001fc020335f155101f0413031202110105140706161544454b4c595a23090707830100006a030c001000393c20000067d85dc401788803565e00a0a0a0295030203500204f3100001eb33900a080381f4030203a00204f3100001eef51b87062a0355080b83a00204f3100001c000000000000000000000000000000000000000055";
      mode = "3440x1440";
      refreshRate = "59.936";
    };

    desktop-philips = {
      model = "Philips Consumer Electronics Company 27E1N1600AE UHB2432014658";
      edid = "00ffffffffffff00410c28c34239000020220103803c22782e88d5a95350a2240c5054bfef00d1c0b3009500818081c03168456861686a5e00a0a0a029503020350055502100001e000000ff0055484232343332303134363538000000fc00323745314e3136303041450a20000000fd0030641e9628000a202020202020014f020345f14e101f0514041303120211015d5e5f23090707830100006d030c001000384420006001020367d85dc401788003e305e301e6060701626200681a000001013064e6769b0078a0a02d503020350055502100001e057600a0a0a029503020980455502100001af03c00d051a0355060883a0055502100001c00000000e6";
      mode = "2560x1440";
      refreshRate = "100";
      adaptiveSync = true;
    };

    macbook = {
      model = "Apple Computer Inc Color LCD Unknown";
      mode = "2880x1800";
      refreshRate = "60";
      scale = 2.0;
    };

    dco-samsung = {
      model = "Samsung Electric Company C27F390 H4ZT201711";
      mode = "1920x1080";
      refreshRate = "60";
    };

    dco-philips = {
      model = "Philips Consumer Electronics Company PHL27E1N1100A UHB2412030590";
      mode = "1920x1080";
      refreshRate = "60";
    };
  };

  customProfiles = {
    desktop-dual = [
      {
        output = outputs.desktop-philips;
        position = { x = 0; y = 0; };
      }
      {
        output = outputs.desktop-iiyama;
        position = { x = 2560; y = 0; };
        primary = true;
      }
    ];

    dco-macbook-triple = [
      {
        output = outputs.dco-samsung;
        position = { x = 0; y = 142; };
      }
      {
        output = outputs.dco-philips;
        position = { x = 1920; y = 0; };
        primary = true;
      }
      {
        output = outputs.macbook;
        position = { x = 3840; y = 936; };
      }
    ];

    dco-macbook-philips = [
      {
        output = outputs.dco-philips;
        position = { x = 0; y = 0; };
        primary = true;
      }
      {
        output = outputs.macbook;
        position = { x = 1920; y = 936; };
      }
    ];

    dco-macbook-samsung = [
      {
        output = outputs.dco-samsung;
        position = { x = 0; y = 0; };
        primary = true;
      }
      {
        output = outputs.macbook;
        position = { x = 1920; y = 794; };
      }
    ];
  };

  profiles = (lib.concatMapAttrs
    (name: attrs: {
      "${name}-single" = [{
        output = attrs;
        position = { x = 0; y = 0; };
        primary = true;
      }];
    })
    outputs) // customProfiles;
in
{
  # The layout manager for Wayland sessions
  services.kanshi = lib.mkIf config.wayland.windowManager.sway.enable {
    enable = true;
    settings = lib.mapAttrsToList
      (name: outputs: {
        profile = {
          inherit name;
          outputs = lib.map
            (outputAttrs: {
              criteria = outputAttrs.output.model;
              mode = "${outputAttrs.output.mode}@${outputAttrs.output.refreshRate}Hz";
              position = "${toString outputAttrs.position.x},${toString outputAttrs.position.y}";
              adaptiveSync = outputAttrs.output.adaptiveSync or null;
              scale = outputAttrs.output.scale or null;
            })
            outputs;
        };
      })
      profiles;
  };

  # Workaround for https://gitlab.freedesktop.org/emersion/kanshi/-/issues/35
  wayland.windowManager.sway = lib.mkIf (config.services.kanshi.enable && config.wayland.windowManager.sway.enable) {
    config.startup = [{
      command = "${lib.getExe' config.services.kanshi.package "kanshictl"} reload";
      always = true;
    }];
  };

  # The layout manager for X11 sessions. This only generates the configuration files.
  programs.autorandr = lib.mkIf config.services.autorandr.enable {
    enable = true;
    profiles = lib.concatMapAttrs
      (name: outputs:
        let
          forEachOutput = f: lib.listToAttrs (lib.filter (x: x.value != null) (lib.imap0
            (i: outputAttrs: {
              name = "HDMI-${toString i}"; # Dummy name, only the EDID is matched
              value = if lib.hasAttr "edid" outputAttrs.output then f outputAttrs else null;
            })
            outputs));
        in
        lib.optionalAttrs (lib.any (outputAttrs: lib.hasAttr "edid" outputAttrs.output) outputs) {
          ${name} = {
            fingerprint = forEachOutput (outputAttrs: outputAttrs.output.edid);
            config = forEachOutput (outputAttrs: {
              inherit (outputAttrs.output) mode;
              rate = outputAttrs.output.refreshRate;
              position = "${toString outputAttrs.position.x}x${toString outputAttrs.position.y}";
              primary = outputAttrs.primary or false;
              scale =
                if lib.hasAttr "scale" outputAttrs.output
                then { x = outputAttrs.output.scale; y = outputAttrs.output.scale; }
                else null;
            });
          };
        })
      profiles;
  };

  # This creates the autorandr service that applies configuration from `programs.autorandr`.
  services.autorandr = lib.mkIf config.xsession.enable {
    enable = true;
    matchEdid = true;
  };

  systemd.user.services.autorandr = lib.mkIf config.services.autorandr.enable {
    # Ensure autorandr only starts in X11 sessions, and ignores Wayland environment variables.
    Unit.ConditionEnvironment = "XAUTHORITY";
    Service.Environment = "WAYLAND_DISPLAY=";
  };
}
