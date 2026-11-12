---
name: playground
description: Run and test project code in an isolated VM with the `playground` command: scripts, test suites, Docker or Laravel Sail stacks, headless browsers and screenshots. Use whenever code has to be executed rather than only edited, or when the user mentions the playground or the VM.
---

# Playground

An isolated NixOS VM. You keep editing files on the host. The VM holds a copy of the current project and executes it. Reach it only through `playground`, always run from the project directory.

## Commands

- `playground run '<command>'` syncs the project, then runs the command in its directory in the VM. Pass one quoted string.
- `playground run --no-sync '<command>'` skips the sync. Use it only to repeat a command when nothing changed.
- `playground sync` syncs only.
- `playground get <path>` copies a file or directory out of the VM. See "Getting files back".
- `playground status` prints `playground ok` when the VM answers.
- `playground clean --files` deletes this project's copy in the VM.

## The VM

- User `runner`. The project copy is in `~/work/<owner>/<project>`, built from the last two components of the host path (`~/Projects/others/foo` becomes `~/work/others/foo`). Those components may only contain letters, digits, `.`, `_` and `-`.
- Installed: Docker with Compose, node, git, curl, jq, python3, make, rg, fd, tree, file, unzip, vim. PHP and Composer are not installed: run them inside containers.
- No internet by default. The user turns it on with `playground net on` and off again afterwards. While it is off, nothing leaves the VM, but `run`, `sync` and `get` still work.
- No credentials. A private registry answers `401`: rely on the `vendor/` and `node_modules/` already in the copy.

## Sync

- One way, host to VM, sending only what changed. Files deleted on the host are deleted in the VM.
- `.git` and every `.env*` file are left out, except `.env.example`. A `.env` created in the VM is kept. Create it there with `cp -n .env.example .env`, and never copy a real `.env` by any other route.
- `playground: synced <owner>/<project>` means success. Anything else (error, timeout, `sync FAILED`) means the copy is incomplete: report it. `run` does not run its command after a failed sync.
- Never pipe `playground sync` or `playground run` into `tail` or similar: it hides the exit status.

## Getting files back

`playground get <path>` takes a path inside this project's copy and prints three lines:

- `saved <path>`: the location on the user's machine. Give this path to the user.
- `readable from this sandbox at <path>`: the same file as seen from your sandbox. Read this one to look at it yourself.
- `to open it on your screen, run in your own terminal: <command>`: give this command to the user exactly. Never run it.

Use `get` only for results (screenshots, reports, logs), never to bring back source code. Never write fetched files anywhere else. To show a text file, `playground run 'cat <file>'` is enough.

## Dependencies and Docker images

Anything that needs the network (installing dependencies, `docker pull`, building an image) cannot run while it is off. Before such a step, stop and offer the user these two options with the exact commands, ready to paste. Then wait for their confirmation.

1. Copy the images from the user's own Docker. Read `compose.yaml` and list every `image:` the project needs, including those that are only pulled (database, mail, cache). Offer:
   - `./vendor/bin/sail build` (or `docker compose build`), only if an image is missing or out of date on their machine, so it is optional;
   - `playground load <image> <image> ...`, with every image from the list.
2. Build and pull in the VM: `playground net on`, then `playground net off` once it is done.

## Laravel Sail

- `playground run 'cp -n .env.example .env'`, then `playground run './vendor/bin/sail up -d --no-build'` once the images are loaded. Without `--no-build`, Sail builds the image and needs the network.
- If the app service is not `laravel.test`, set `APP_SERVICE=<name>` before `./vendor/bin/sail` (see `docker compose config --services`).
- Wait until MySQL is healthy (`docker compose ps`) before running `./vendor/bin/sail artisan test`.

## Commands for the user only

They refuse to run from your sandbox. Never look for a way around it. When one is needed, say so, give the exact command, and wait for the user to confirm.

- `playground start`, `stop`, `restart`, `logs` control the VM. `reset` also erases its disk: every image and volume.
- `playground load <image> ...` copies images from the user's Docker into the VM. Offer it as described in the previous section.
- `playground get --open <path>` also opens the file on the user's screen.
- `playground net on | off | status` turns the VM's internet access on or off. It is off by default.

If `playground status` cannot connect, the VM is stopped: ask the user to run `playground start`. If network commands fail (resolution errors, timeouts), the network is off: offer the two options above or just `playground net on`. Do not retry or troubleshoot.

## Rules

- Never call `ssh`, `scp` or `rsync`.
- Never edit project files inside the VM: all changes are made on the host. When the VM generates code (for example `artisan make:…`), read it with `playground run 'cat <file>'` and write it yourself on the host with your normal editing tools.
- Stay inside the current project. Copies of other projects may exist in `~/work`: never read or touch them.
- Run `playground clean --files --all` (every project copy) and `playground clean --docker` (every image and volume) only when the user asks.
- Never send requests from the VM to private addresses (`10.x`, `172.16.x` to `172.31.x`, `192.168.x`, `100.64.x` to `100.127.x`) or to `10.0.2.2`, which is the host.
- Never make requests to an external service (third-party API, webhook, mail or payment provider) from the code you run, unless the user specifically asks. If a test or script would, stop and ask. Installing dependencies and pulling images from public registries is fine.
- Report exactly what you ran and what it printed.
