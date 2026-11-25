{ ... }:

# Use `nix-ld` as the default dynamic loader. This makes it possible to run binaries that link to shared objects in FHS directories,
# which includes most binaries compiled for other Linux distributions. Useful for e.g. Bazel which downloads compiler toolchains.

{
  programs.nix-ld = {
    enable = true;
  };
}
