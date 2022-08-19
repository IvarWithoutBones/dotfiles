{ createScript
, git
, fzf
, delta
, bat
, file
}:

createScript "git-add-fuzzy" ./git-add-fuzzy.sh {
  dependencies = [
    git
    fzf
    delta
    bat
    file
  ];

  meta.description = "a wrapper around `git add` that uses fzf to select files with unstaged changes";
}
