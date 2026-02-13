{
  createScript,
}:

createScript "dotfiles" ./dotfiles.sh {
  meta.description = "shortcuts for NixOS system management";
}
