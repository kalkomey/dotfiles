# Package Matrix

This is the **shared contract** for cross-platform parity between macOS (Apple Silicon)
and Ubuntu 24.04. It exists so that "which tool, installed how, on which OS, owned by
whom" is a documented agreement instead of an argument re-litigated in every PR.

**Parity is defined by capability, not by package manager.** The two platforms do not use
the same package manager and are not expected to. They are expected to end up with the
same core capabilities, compatible runtime versions, and documented platform-specific
installation paths.

## Package ownership rules

- **macOS** uses **Homebrew** for CLI tools, GUI apps, and services where already established.
- **Ubuntu** uses **apt** for distro packages.
- **Ubuntu** uses **vendor apt repositories** for tools whose official Linux install path
  requires them (Docker, HashiCorp tools, GitHub CLI).
- **Ubuntu** uses **official binary installers** when apt is stale, unavailable, or
  known-bad (e.g. AWS CLI v2).
- **Language runtimes** stay in their topic installers, not the OS package layer: Ruby via
  `ruby-install`/`chruby`, Node via `nvm`/Corepack.
- **Personal tools do not go in shared installers** — they belong in `.local` files
  (`~/.zshrc.local`, etc.).
- **Homebrew-on-Linux is allowed only as an explicit exception**, when no acceptable apt,
  vendor apt, or official binary path exists. It is not the default.
- **Prefer boring OS-native defaults over cross-platform cleverness.**
- **Installers may upgrade existing packages, but must not overwrite user-owned local
  config without an explicit prompt.**

## Version-match column

The **Version** column states how closely the two platforms must track each other:

- **exact** — the same version must be installed on both (pinned). Used for language
  runtimes and anything where a minor drift breaks local/CI parity.
- **major** — the same major (or compatible) line is sufficient; minor/patch may differ
  by what each source ships.
- **latest** — whatever the source's current stable is; drift is acceptable.

## The matrix

| Capability | macOS (Apple Silicon) | Ubuntu 24.04 | Owner | Version | Notes |
|---|---|---|---|---|---|
| Git | Homebrew `git` | apt `git` | base | major | Required before most tooling |
| GitHub CLI | Homebrew `gh` | GitHub official apt repo | base | major | Avoid distro lag |
| ShellCheck | Homebrew `shellcheck` | apt `shellcheck` | base | major | Used for script review |
| ripgrep | Homebrew `ripgrep` | apt `ripgrep` | base | major | Shared CLI |
| fd | Homebrew `fd` | apt `fd-find` (+ `fd` alias) | base | major | Ubuntu binary is `fdfind` |
| fzf | Homebrew `fzf` | apt `fzf` | shell | major | Shell integration may differ |
| jq | Homebrew `jq` | apt `jq` | base | major | Shared CLI |
| yq | Homebrew `yq` | apt or binary release | base | major | Confirm version behavior |
| AWS CLI v2 | Homebrew `awscli` | AWS official v2 installer | cloud | major | **Do not** use Ubuntu apt (ships v1) |
| aws-vault | Homebrew formula/cask | release binary or documented manual | cloud | major | Confirm supported Linux path |
| Terraform | Homebrew `terraform` (or `tfenv`) | HashiCorp apt repo | infra | exact | Pin to match deployed version |
| Vault | Homebrew `vault` | HashiCorp apt repo | infra | major | Client; server behavior differs |
| Nomad | Homebrew `nomad` | HashiCorp apt repo | infra | major | Client; server behavior differs |
| Consul | Homebrew `consul` | HashiCorp apt repo | infra | major | Client; server behavior differs |
| Docker | Docker Desktop cask | Docker Engine apt repo | docker | major | Linux needs `docker` group / new login |
| Ruby build deps | Homebrew deps | apt `*-dev` deps | ruby | major | Native build prerequisites |
| Ruby runtime | `ruby-install` / `chruby` | `ruby-install` / `chruby` | ruby | exact | Same manager both OSes; pin via `.ruby-version` |
| Node runtime | `nvm` | `nvm` | node | exact | Pin via `.node-version` |
| Yarn | Corepack | Corepack | node | major | **Avoid** `apt install yarn` (installs `cmdtest`) |
| MySQL | Homebrew `mysql` | apt `mysql-server` or MySQL vendor repo | databases | major | Confirm app compatibility |
| PostgreSQL | Homebrew `postgresql` | apt `postgresql` | databases | major | Native service management |
| Redis | Homebrew `redis` | apt `redis-server` | databases | major | Native service management |
| Memcached | Homebrew `memcached` | apt `memcached` | databases | major | Native service management |
| Clipboard copy | native `pbcopy` | `wl-copy` / `xclip` / stdout | system | n/a | Abstracted in `system/clipboard.zsh` |
| Clipboard paste | native `pbpaste` | `wl-paste` / `xclip` / message | system | n/a | Abstracted in `system/clipboard.zsh` |

## Keeping this current

Update the matrix in the same PR whenever a shared tool is **added, removed, or moved
between sources**. A change to `homebrew/Brewfile` or an Ubuntu installer that adds or
drops a capability should not merge without a matching row change here. Treat a drift
between this table and the installers as a bug in whichever lags.
