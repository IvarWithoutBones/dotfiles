{ pkgs
, ...
}:

{
  programs.git = {
    enable = true;
    userName = "Ivar Scholten";
    userEmail = "ivar.scholten@protonmail.com";

    aliases = {
      # Prettier `git log`
      lg = "log --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      # `git checkout` with fuzzy matching
      co = "!git for-each-ref --format='%(refname:short)' refs/heads | ${pkgs.fzf}/bin/fzf -0 | xargs -I {} git checkout {}";
      # `git restore --staged` with fuzzy matching
      rs = "!git diff --name-only --cached | ${pkgs.fzf}/bin/fzf -0 --multi | xargs git restore --staged";
      # `git add` with fuzzy matching. Derivation is a script from my overlay
      af = "!${pkgs.git-add-fuzzy}/bin/git-add-fuzzy";
      # Fetch a branch from a remote and rebase it on the current branch
      frb = ''!git fetch $1 && git rebase $1/''${2:-HEAD} && :'';
      # Create a new branch and check it out, optionally from a given starting point.
      new = ''!''${2+git fetch $2} && git checkout -b $1 ''${2+$2/''${3:-HEAD}} --no-track --no-guess && :'';
      # Create an empty file and add it to git
      touch-add = ''![ ! -e "$1" ] && (touch "$1" && git add "$1") || (echo "path '$1' already exists" && exit 1) && :'';

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
      ignore = "update-index --skip-worktree";
      unignore = "update-index --no-skip-worktree";
      # Show `--skip-worktree` files (prefixed with `S`), and remove the prefix
      ignored = "!git ls-files -v | grep '^S' | cut -d ' ' -f 2-";
    };

    signing = {
      signByDefault = false;
      key = null; # Let the gpg agent handle it
    };

    extraConfig = {
      rerere.enabled = true;
      init.defaultBranch = "main";
      diff.colorMoved = "zebra";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };

    # Prettier pager, adds syntax highlighting and line numbers
    delta = {
      enable = true;

      options = {
        navigate = true;
        line-numbers = true;
        conflictstyle = "diff3";
      };
    };
  };
}
