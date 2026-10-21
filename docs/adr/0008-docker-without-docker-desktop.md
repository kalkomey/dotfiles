# 0008. Docker without Docker Desktop (Colima)

- Status: Accepted
- Date: 2026-10-14

## Context

`docker/install.sh` ran `brew install docker --cask`, which installs Docker Desktop. Docker Desktop is free only
for small businesses (Docker's terms set limits on headcount and revenue). Our headcount is under the limit, but our
revenue is over it, so we need a paid subscription to use Docker Desktop. We have not purchased one, so using it would
violate the license. (Confirm the current terms with legal if this ever needs revisiting.)

Docker's engine runs only on Linux, so on macOS something must provide a Linux VM. The `docker` Homebrew formula is
only the CLI client.

## Decision

We do not install or use Docker Desktop. `docker/install.sh` installs, from Homebrew:

- `docker`, the CLI;
- `colima`, an open-source VM wrapper that runs the Docker daemon (`colima start`);
- `docker-compose` and `docker-buildx`, linked into `~/.docker/cli-plugins` so `docker compose` and `docker buildx`
  work as plugins;
- `lazydocker`, a terminal UI for containers, images and logs.

The script warns if Docker Desktop is already installed and if `~/.docker/config.json` still has
`"credsStore": "desktop"` (which breaks pulls once Docker Desktop is gone). We removed the Docker Desktop completions
block from `zshrc.symlink`.

## Alternatives considered

- **Docker Desktop**: needs a paid subscription at our size.
- **OrbStack**: polished, but commercial use needs a paid license.
- **Podman** (`podman`, `podman-compose`, `podman-tui`): open source and OCI-compliant, and we tried it. We went back
  to the Docker CLI because our existing `docker-compose.yml` files are written for Docker Compose, and
  `podman-compose` is a separate implementation that can behave differently. It also leaves no `docker` command for
  scripts and tooling that call it, and Homebrew's `podman` formula is Apple Silicon only. Worth revisiting if we want to
  migrate the compose files.
- **Rancher Desktop**: free and open source, but a GUI app with more moving parts than we need. Colima was chosen for
  being a small CLI-first tool that keeps the standard `docker` command working unchanged. Revisit if it proves
  unreliable.
- **Symlinking plugins vs. `cliPluginsExtraDirs`**: Homebrew's caveat edits `~/.docker/config.json`; symlinks give the
  same result without editing the user's JSON.

## Consequences

- No licensing exposure from the default setup.
- `docker/install.sh` runs `brew services start colima`, which registers a login agent: Colima starts now and again at each
  login, so it is back after a reboot once you sign in. If Colima is already running from a manual `colima start`, the script
  leaves it alone and prints the commands to switch (`colima stop && brew services start colima`), since stopping it would
  stop running containers. The service takes no flags; the VM uses the settings saved for its profile.
- Colima uses a VM with its own resource settings; Apple Silicon users who run amd64 images may want
  `--vm-type vz --vz-rosetta`.
- We chose Colima without a trial on every team's workflow; teams with Docker Desktop-specific features (such as its
  Kubernetes) need to use another approach.
- `buildx` and the plugin symlinks are additions beyond a bare `docker` install, to keep modern builds and
  `docker compose` working.
