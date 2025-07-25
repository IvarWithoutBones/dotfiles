{ createScript
, git
, coreutils
}:

createScript "git-submodule-reset" ./git-submodule-reset.sh {
  dependencies = [
    git
    coreutils
  ];

  meta.description = "reset git submodules to their state in the containing project's last commit";
}
