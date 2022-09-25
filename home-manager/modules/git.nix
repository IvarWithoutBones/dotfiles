{ config
, pkgs
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
      co = "!git for-each-ref --format='%(refname:short)' refs/heads | ${pkgs.fzf}/bin/fzf -0 | xargs git checkout";
      # `git restore --staged` with fuzzy matching
      rs = "!git diff --name-only --cached | ${pkgs.fzf}/bin/fzf -0 --multi | xargs git restore --staged";
      # `git add` with fuzzy matching. Derivation is a script from my overlay
      af = "!${pkgs.git-add-fuzzy}/bin/git-add-fuzzy";
      # Fetch a branch from a remote and rebase it on the current branch
      frb = "!git fetch $1 && git rebase $1/$2 && :";

      new = "checkout -b";
      rb = "rebase --interactive";
      last = "show HEAD";
      cim = "commit --amend";
      cimn = "commit --amend --no-edit";
      st = "status";
      br = "branch";
      ci = "commit";
      df = "diff";
      ps = "push";
      fp = "push --force";
    };

    signing = {
      signByDefault = true;
      key = null; # Let the gpg agent handle it
    };

    extraConfig = {
      pull.rebase = true;
      push.autoSetupRemote = "main";
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
