{ config
, lib
, dotfiles-flake
, pkgs
, ...
}:

let
  # An extra (mutable) configuration file for stuff we cannot configure with home-manager,
  # used mainly for shortcut `define`s to load symbol files from locally compiled projects.
  extraConfigFile =
    if pkgs.stdenvNoCC.isLinux then "${config.xdg.configHome}/gdb/gdbinit-extra"
    else if pkgs.stdenvNoCC.isDarwin then "${config.home.homeDirectory}/.gdbinit-extra"
    else throw "gdb: unsupported platform ${pkgs.stdenvNoCC.system}";

  cacheDir = "${config.xdg.cacheHome}/gdb";

  gdbearlyinit = ''
    set startup-quietly on
    set prompt ${"> " /* Prevents my editor from removing the trailing space */ }
  '';

  gdbinit =
    let
      refreshTui = pkgs.writeText "refresh-tui.py" ''
        import gdb
        # Refreshing the tui will automatically switch to it, so we need to check if was enabled prior.
        if "(has focus)" in gdb.execute("info win", to_string=True):
          gdb.execute("tui refresh")
      '';
    in
    ''
      set disassembly-flavor intel
      set max-value-size unlimited
      set disassemble-next-line on
      set confirm off
      set pagination off
      set step-mode on

      set history save on
      set history filename ${cacheDir}/history
      set history size 10000
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
      tui new-layout full {-horizontal src 1 asm 1} 2 status 0 cmd 1

      define xn
        # TODO: allow this to be an expression
        x $arg1
        set $i = 0
        while $i < $arg0
          x $__
          set $i = $i + 1
        end
      end

      ${lib.concatMapStringsSep "\n" (amount: let
        # Generate shorthands to follow pointer indirection, for example "xxx" -> dereference 3 times
        name = lib.fixedWidthString (amount + 1) "x" "x";
      in ''
        define ${name}
          xn ${toString amount} $arg0
        end
      '') (lib.range 1 10)}

      define less
        || ${pkgs.less}/bin/less
        # Giving less access to the terminal breaks the TUI, so we need to manually refresh it
        source ${refreshTui}
      end

      define connect-remote
        if $argc == 0
          init-if-undefined $connectRemoteAddress = "localhost:9001"
          set $_connectRemoteAddress = $connectRemoteAddress
        end
        if $argc == 1
          set $_connectRemoteAddress = $arg0
        end

        eval "echo connecting to \"%s\"\n", $_connectRemoteAddress
        eval "target remote %s", $_connectRemoteAddress
      end

      define hook-stop
        # Manually refresh the TUI as writes to stdout/stderror will break it otherwise.
        source ${refreshTui}
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
      changeActiveWindowSize = dimension: amount: pkgs.writeText "change-active-window-${dimension}.py" ''
        import gdb
        for line in gdb.execute("info win", to_string=True).splitlines():
          if "(has focus)" in line:
            win = line.split()[0]
            gdb.execute(f"tui window ${dimension} {win} ${amount}")
            break
      '';

      # This is a pretty nasty workaround for readline not accepting more than one command per binding:
      # We assign a placeholder shortcut to the command we want to execute, and then "press" it in a macro.
      clearLine = ''\xBA\xDD\x06\xFA\xCE\xF0\x0D\xCA\xFE'';
      # Enters the given command by clearing the current line, entering insert mode, and then entering the command.
      insertCommand = cmd: ''"${clearLine}\ei${cmd}\n"'';
    in
    dotfiles-flake.lib.readlineBindingsAllModes ''
      "${clearLine}": kill-whole-line # See the comment above

      # Step one instruction/line
      Meta-p: ${insertCommand "step"}
      Control-p: ${insertCommand "stepi"}

      # Step one instruction/line, but step over function calls
      Meta-o: ${insertCommand "next"}
      Control-o: ${insertCommand "nexti"}

      # Continue execution until the current function returns
      Control-f: ${insertCommand "finish"}

      # View the output of the previous command in less
      Control-k: ${insertCommand "less"}

      # Switch settings for displaying the current file name, as it can be too long to fit in the TUI windows.
      "\C-gff": ${insertCommand "set print symbol-filename on\\nset filename-display relative"}
      "\C-gfs": ${insertCommand "set print symbol-filename on\\nset filename-display basename"}
      "\C-gfo": ${insertCommand "set print symbol-filename off"}

      # Change the size of the currently focused window
      Meta-s: ${insertCommand "source ${changeActiveWindowSize "height" "+2"}"}
      Meta-w: ${insertCommand "source ${changeActiveWindowSize "height" "-2"}"}
      Meta-d: ${insertCommand "source ${changeActiveWindowSize "width" "+2"}"}
      Meta-a: ${insertCommand "source ${changeActiveWindowSize "width" "-2"}"}

      # Cycle between register groups
      "\C-w\C-r": ${insertCommand "tui reg next"}

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
in
{
  xdg.configFile = lib.mkIf pkgs.stdenvNoCC.isLinux {
    "gdb/gdbinit".text = gdbinit;
    "gdb/gdbearlyinit".text = gdbearlyinit;
  };

  home = {
    packages = [ pkgs.gdb ];

    # Unfortunately GDB does not look in $XDG_CONFIG_HOME on Darwin, so we have to pollute the home directory instead.
    file = lib.mkIf pkgs.stdenvNoCC.isDarwin {
      ".gdbinit".text = gdbinit;
      ".gdbearlyinit".text = gdbearlyinit;
    };

    activation.gdbCacheDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create the cache directory, if it does already exist.
      $DRY_RUN_CMD mkdir $VERBOSE_ARG -p ${cacheDir}
    '';
  };

  programs.readline.extraConfig = ''
    $if Gdb
    ${bindings}
    $endif # Gdb
  '';
}
