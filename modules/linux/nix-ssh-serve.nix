{ ... }:

# Allows using the local Nix store as a subsituter via SSH.

{
  nix.sshServe = {
    enable = true;
    trusted = true;

    keys = [
      # Keys that are allowed to connect to the subsituter.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMVaz8EkVmKttJr7NbFE9YEg4LbnIZ6/jtg5kT2vTRFE ivv@nixos-macbook"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsUXX7QBy1rIw9kLKhm4oQXpNpbrl4s+cHPjR9ouaRB root@macbook-linux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFgXhfWfT6qaPXhpzUyeJPI6SJg7JJgbNtv1OcZod6mw root@nixos-macbook"

      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzp7kYG8wHjoU1Ski/hABNuT3puOT3icW9DYnweJdR0 ivv@nixos-pc"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq5SRfDXbFH9/fol7s/frJ+uU70Q/9bu0izPLuJ1mps root@nixos-pc"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCgsEHANTAqqugefYR3e00Zfl7ra8ORQRykqf3OQUzxwLplLl542YdwHbo1Y9OQCozm1PhCXx6SnCFppaBeOxJGWxDX1mUaH0Y1eNMo5a8eyiRTamirfnPO3kjf+70s6XFfwMgGMqD7rv2GFSf6IHD0CYzLJnhBqUTnTaRZUanzfiyr4zzm2IB5lkFtEVaxPP2bP/pnT6Vsuget0090FhAR+stq6GzYJHqHFY3A1Xi5lwN6rfaZM/3oK3Wn/b+WM8JzelaeJ8JhXiIXa9hnPY+9GaojPtG2abN2/5hwGH5SERO805Iq2hYjMczQcc/75vRmbAF0viJ/mz7kr2xyUxYmFSea4vdrxB3AvkYPLoLBFcTN7qKbeIDFxJKlWou7JR4euQ1366oWpZgAro1YjawrA2uKhkYONl1HyQxVtAQ8pXjZCR3DKl6UcLDGLMrxhd/VkH3NdnCg4LhZ/A7K0M2KsjbS+i66A+i7kpIzQB2qzo/GnUNK8DpppOj0iFXOGQ8= root@nixos-pc"
    ];
  };
}
