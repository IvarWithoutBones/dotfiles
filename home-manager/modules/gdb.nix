{ config
, lib
, pkgs
, ...
}:

# Projects sometimes ship their own gdbinit file, to automatically load these you need to manually approve it.
# Since the directory is dependent on the directory structure of the host, we dont configure it here.
# These should be manually added to the `gdbearlyinit` file seeing how `gdbinit` is managed by nix.

let
  gdbConfig = ''
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

    ${lib.optionalString (extraConfigFile != null) ''
      # Load the extra configuration file if it exists.
      shell test ! -f "${extraConfigFile}"
      if $_shell_exitcode
        source ${extraConfigFile}
      end
    ''}
  '';

  # Extra initialisation commands that cannot be apart of the general configuration, e.g. for loading symbol files.
  # Unfortunately gdb does not look in $XDG_CONFIG_HOME on MacOS, so we have to pollute the home directory there instead. :/
  extraConfigFile =
    if pkgs.stdenvNoCC.isLinux then "${config.xdg.configHome}/gdb/gdbinit-extra"
    else if pkgs.stdenvNoCC.isDarwin then "${config.home.homeDirectory}/.gdbinit-extra"
    else null;
in
{
  xdg = lib.mkIf pkgs.stdenvNoCC.isLinux {
    configFile."gdb/gdbinit".text = gdbConfig;
  };

  home = lib.mkIf pkgs.stdenvNoCC.isDarwin {
    file.".gdbinit".text = gdbConfig;
  };
}
