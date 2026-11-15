{
  lib,
  stdenvNoCC,
  writeShellApplication,
  wl-clipboard,
  xclip,
  coreutils,

  waylandSupport ? stdenvNoCC.hostPlatform.isLinux,
  x11Support ? false,
  pbcopySupport ? stdenvNoCC.hostPlatform.isDarwin,
}:

writeShellApplication {
  name = "copy";
  inheritPath = pbcopySupport;

  runtimeInputs = [
    coreutils
  ]
  ++ lib.optional waylandSupport wl-clipboard
  ++ lib.optional x11Support xclip;

  text = ''
    getText() {
      local text
      text="$(cat "$@")"
      printf '%s' "''${text%$'\n'}" # Remove trailing newline
    }

    osc52() {
      printf '\e]52;c;%s\e'\\\\ "$(getText "$@" | base64 -w 0)"
    }

    if [[ -n "''${SSH_CLIENT:-}" ]] || [[ -n "''${SSH_TTY:-}" ]]; then
      osc52 "$@"
      exit 0
    fi

    ${lib.optionalString (waylandSupport || x11Support) ''
      case "''${XDG_SESSION_TYPE:-}" in
        ${lib.optionalString waylandSupport ''wayland) exec wl-copy --trim-newline "$(cat "$@")" ;;''}
        ${lib.optionalString x11Support ''x11) exec xclip -in -rmlastnl -selection clipboard "$@" ;;''}
        *) ;;
      esac
    ''}

    ${lib.optionalString pbcopySupport ''
      if command -v pbcopy >/dev/null 2>&1; then
        exec pbcopy < "$(getText "$@")"
      fi
    ''}

    osc52 "$@"
  '';

  meta.description = "Copy stdin or the contents of files to the system clipboard using Wayland, X11, pbcopy, or OSC52";
}
