{ createScript
, git
, fzf
}:

createScript "git-checkout-fuzzy" ./git-checkout-fuzzy.sh {
  dependencies = [ git fzf ];

  meta.description = "List all branches on a remote (`origin` by default) and checkout the one picked with fzf";
}
