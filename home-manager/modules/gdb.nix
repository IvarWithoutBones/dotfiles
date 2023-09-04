{ config
, lib
, dotfiles-lib
, pkgs
, ...
}:

let
  gdbearlyinit = ''
    set startup-quietly on
    set prompt ${"> " /* Prevents my editor from removing the trailing space */ }
  '';

  gdbinit = ''
    set disassembly-flavor intel
    set max-value-size unlimited
    set disassemble-next-line on
    set confirm off
    set pagination off
    set step-mode on

    set history save on
    set history remove-duplicates 20

    set print address on
    set print symbol-filename on
    set print array on
    set print pretty on
    set print demangle on
    set print asm-demangle on
    set print object on
    set print static-members on
    set print vtbl on

    set tui compact-source on
    set tui border-mode normal
    set tui active-border-mode bold
    set style tui-border foreground magenta
    set style tui-active-border foreground magenta

    tui new-layout regs-horizontal {-horizontal asm 1 regs 1} 2 status 0 cmd 1
    tui new-layout full {-horizontal asm 1 src 1} 2 status 0 cmd 1

    define xn
      # TODO: allow this to be an expression
      x $arg1
      set $i = 0
      while $i < $arg0
        x $__
        set $i = $i + 1
      end
    end

    define xx
      xn 1 $arg0
    end

    define connect-remote
      echo connecting to localhost:9001\n
      target remote localhost:9001
    end

    define clear
      source ${pkgs.writeText "clear-command-output.py" ''
        import gdb
        tuiEnabled = False
        for line in gdb.execute("info win", to_string=True).splitlines():
          if "(has focus)" in line:
            # A hack to clear the cmd window in TUI mode. Surely there is a better way, but I can't find it.
            tuiEnabled = True
            win = line.split()[0]
            gdb.execute(f"tui window height {win} +1")
            gdb.execute(f"tui window height {win} -1")
            gdb.execute("echo")
            break
        if not tuiEnabled:
          gdb.execute("shell clear")
      ''}
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

  # Keybindings are configured through readline.
  bindings =
    let
      # This is a pretty nasty workaround for readline not accepting more than one command per binding:
      # We assign a placeholder shortcut to the command we want to execute, and then "press" it in a macro.
      clearLine = ''\xBA\xDD\x06\xFA\xCE\xF0\x0D\xCA\xFE'';
      # Enters the given command by clearing the current line, entering insert mode, and then entering the command.
      insertCommand = cmd: ''"${clearLine}\ei${cmd}\n"'';
    in
    dotfiles-lib.readlineBindingsAllModes ''
      "${clearLine}": kill-whole-line # See the comment above

      # Step one instruction/line
      Meta-p: ${insertCommand "step"}
      Control-p: ${insertCommand "stepi"}
      # Step one instruction/line, but step over function calls
      Meta-o: ${insertCommand "next"}
      Control-o: ${insertCommand "nexti"}

      # Cycle between register groups
      Control-g: ${insertCommand "tui reg next"}

      # Switch to various layouts
      "\C-wa": ${insertCommand "layout asm"}
      "\C-wr": ${insertCommand "layout regs-horizontal"}
      "\C-ws": ${insertCommand "layout src"}
      "\C-wf": ${insertCommand "layout full"}

      # The default TUI bindings are not active in vi-mode, so we have to manually set them.
      "\C-xa": tui-switch-mode          # Toggle the TUI
      "\C-xo": tui-other-window         # Change focus between windows
      "\C-xs": next-keymap              # Toggle single-key mode
      "\C-x1": tui-delete-other-windows # Switch to TUI with one window (source, assembly)
      "\C-x2": tui-change-windows       # Switch to TUI with two windows (split, registers)
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

  programs.readline.extraConfig = ''
    $if Gdb
    ${bindings}
    $endif # Gdb
  '';
}
