{ config
, lib
, pkgs
, ...
}:

let
  gdbearlyinit = ''
    set startup-quietly on
    set prompt ${"> "/* Prevents my editor from removing the trailing space */}
  '';

  gdbinit = ''
    set disassembly-flavor intel
    set max-value-size unlimited
    set disassemble-next-line on
    set history save on
    set confirm off
    set pagination off

    set print address on
    set print symbol-filename on
    set print array on
    set print pretty on
    set print demangle on
    set print asm-demangle on
    set print object on
    set print static-members on
    set print vtbl on

    set tui active-border-mode normal
    set tui compact-source on

    tui new-layout regs-horizontal {-horizontal asm 1 regs 1} 2 status 0 cmd 1
    tui new-layout full {-horizontal asm 1 src 1} 2 status 0 cmd 1

    define lasm
        layout regs-horizontal
    end

    define lfull
        layout full
    end

    define lsrc
        layout src
    end

    define lempty
        tui disable
    end

    define qa
        kill
        exit
    end

    define clear
      shell clear
    end

    define connect-remote
      echo connecting to localhost:9001\n
      target remote localhost:9001
    end

    define hook-stop
      # Manually refresh the TUI as writes to stdout/stderror will break it otherwise.
      source ${pkgs.writeText "refresh-tui.py" ''
        import gdb
        # Refreshing the tui will automatically switch to it, so we need to check if was enabled prior.
        if "(has focus)" in gdb.execute("info win", to_string=True):
          gdb.execute("tui refresh")
      ''}
    end

    # Load the extra configuration file, if it exists.
    source ${pkgs.writeText "maybe-source-extra-config.py" ''
      import gdb
      import os
      if os.path.isfile("${extraConfigFile}"):
        gdb.execute("source ${extraConfigFile}")
    ''}
  '';

  extraConfigFile =
    if pkgs.stdenvNoCC.isLinux then "${config.xdg.configHome}/gdb/gdbinit-extra"
    else if pkgs.stdenvNoCC.isDarwin then "${config.home.homeDirectory}/.gdbinit-extra"
    else throw "gdb: unsupported platform ${pkgs.stdenvNoCC.system}";
in
{
  xdg.configFile = lib.mkIf pkgs.stdenvNoCC.isLinux {
    "gdb/gdbinit".text = gdbinit;
    "gdb/gdbearlyinit".text = gdbearlyinit;
  };

  # Unfortunately gdb does not look in $XDG_CONFIG_HOME on Darwin, so we have to pollute the home directory there instead :/
  home.file = lib.mkIf pkgs.stdenvNoCC.isDarwin {
    ".gdbinit".text = gdbinit;
    ".gdbearlyinit".text = gdbearlyinit;
  };
}
