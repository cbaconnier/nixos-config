# nixos-config

NixOS flake, Home Manager and a rabbit hole. 

## Add a new host

1. Install NixOS with the installer.
2. Clone this repo over https into `~/nixos-config`.
3. Copy `/etc/nixos/hardware-configuration.nix` to `hosts/<host>/hardware-configuration.nix`.
4. Create `hosts/<host>/configuration.nix` that imports `./hardware-configuration.nix` and `../../modules/nixos/common.nix`, and sets `networking.hostName`.
5. Create `hosts/<host>/clement.nix` that imports `../../modules/home/common.nix`.
6. Add `"<host>"` to the `hosts` list in `flake.nix`.
7. Run `git add hosts/<host>`.
8. Replace `/etc/nixos` with a symlink to the repo: `sudo mv /etc/nixos /etc/nixos.bak && sudo ln -s ~/nixos-config /etc/nixos`.
9. Run the rebuild command, then add the host's key to the secrets as described below and rebuild again.

## Secrets (agenix)

Secrets are stored encrypted in `secrets/`, using [agenix](https://github.com/ryantm/agenix). 

To edit or create a secret:
```sh
cd secrets && agenix -e <name>.age -i <personal-key>
```

To use the new secret:

1. Add `"<name>.age".publicKeys = keys;` to `secrets/agenix-rules.nix`.
2. Declare it in `modules/nixos/<service>.nix` with `age.secrets.<name>.file = ../../secrets/<name>.age;`.
3. Pass `config.age.secrets.<name>.path` to the service (e.g. with [`EnvironmentFile`](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Environment), or [`LoadCredential`](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Credentials)).
4. Run `git add` on the `.age` file before rebuilding.

To add a new host:

1. Add the content of its `/etc/ssh/ssh_host_ed25519_key.pub` to `secrets/agenix-rules.nix`
2. Re-encrypt every secret for it with `cd secrets && agenix -r -i <personal-key>`
