{
  config,
  pkgs,
  lib,
  ...
}:

let
  git = lib.getExe config.programs.git.package;
in
{
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";
      diff.colorMoved = "zebra";
      merge.conflictstyle = "diff3";
      rerere.enabled = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
      advice.skippedCherryPicks = false;

      user = {
        name = "Ivar Scholten";
        email = "ivar.scholten@protonmail.com";
      };

      alias = {
        # Prettier `git log`
        lg = "log --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        # `git restore --staged` with fuzzy matching
        rs = "!${git} diff --name-only --cached | ${pkgs.fzf}/bin/fzf -0 --multi | xargs git restore --staged";
        # Fetch a branch from a remote and rebase it on the current branch
        frb = "!${git} fetch $1 && ${git} rebase $1/\${2:-HEAD} && :";
        # Create a new branch and check it out, optionally from a given starting point.
        new = "!\${2+${git} fetch $2} && ${git} checkout -b $1 \${2+$2/\${3:-HEAD}} --no-track --no-guess && :";

        # Create an empty file and add it to git
        touch-add =
          let
            path = "\${GIT_PREFIX:-}$1"; # Allow using paths relative to the current working directory.
          in
          ''![ ! -e "${path}" ] && (touch "${path}" && ${git} add "${path}") || (echo "path '${path}' already exists" && exit 1) && :'';

        # `git add` with fuzzy matching. The package is a script from my overlay.
        af = "!${lib.getExe (pkgs.git-add-fuzzy.override { inherit git; })}";
        # `git checkout` with fuzzy matching. The package is a script from my overlay.
        co = "!${lib.getExe (pkgs.git-checkout-fuzzy.override { inherit git; })}";

        # Reset submodule(s) to their state in the containing project's last commit. Package is a script from my overlay.
        submodule-reset = "!${lib.getExe (pkgs.git-submodule-reset.override { inherit git; })}";
        # Update submodule(s) to their latest commit by fetching and rebasing them.
        submodule-pull = "submodule update --init --checkout --rebase --remote";

        fup = "commit --message fixup";
        rb = "rebase --interactive";
        br = "branch";
        brm = "branch --delete";
        cim = "commit --amend";
        cimn = "commit --amend --no-edit";
        st = "status";
        ci = "commit";
        df = "diff";
        ap = "add --patch";
      };
    };

    signing = {
      signByDefault = true;
      format = "openpgp";
      key = null; # Let the gpg agent handle it
    };
  };

  programs = {
    # Prettier pager for diffs, adds syntax highlighting and line numbers
    delta = {
      enable = true;
      enableGitIntegration = true;

      options = {
        navigate = true;
        line-numbers = true;
        conflictstyle = "diff3";
      };
    };

    # Syntax aware merge conflict resolution
    mergiraf = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
