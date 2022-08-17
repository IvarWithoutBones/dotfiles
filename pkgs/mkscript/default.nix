{ createScript
}:

createScript "mkscript" ./mkscript.sh {
  meta.description = "quickly create an executable script with a nix-shell shebang";
}
