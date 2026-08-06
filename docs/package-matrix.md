# Package Matrix

This is the **shared contract** for a **ready-to-work Kalkomey developer machine** on
macOS (Apple Silicon) and Ubuntu 24.04. It exists so that "which tool, installed how, on
which OS, owned by whom" is a documented agreement instead of an argument re-litigated in
every PR.

The goal is a machine that's ready to work, not strict symmetry. Most capabilities are
**cross-platform** (parity on both OSes). Some are **macOS-only** because the platform
dictates it (iOS/Swift builds) — those carry `n/a` on the Ubuntu side, and that's
intentional, not a gap. And some tools are **deliberately out of scope** (legacy
Windows-only stacks, Dockerized legacy runtimes, per-project toolchains) — recorded below
so the omission is a decision, not an oversight.

**Parity, where it applies, is defined by capability, not by package manager.** The two
platforms do not use the same package manager and are not expected to. Where a capability
exists on both, they should end up with compatible versions via documented per-OS paths.

## Package ownership rules

- **macOS** uses **Homebrew** for CLI tools, GUI apps, and services where already established.
- **Ubuntu** uses **apt** for distro packages.
- **Ubuntu** uses **vendor apt repositories** for tools whose official Linux install path
  requires them (Docker, HashiCorp tools, GitHub CLI).
- **Ubuntu** uses **official binary installers** when apt is stale, unavailable, or
  known-bad (e.g. AWS CLI v2).
- **Language runtimes** stay in their topic installers, not the OS package layer: Ruby via
  `ruby-install`/`chruby`, Node via `nvm`/Corepack, Python via `pyenv`.
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
| GNU make | Homebrew `make` (+ gnubin PATH) | apt `build-essential` | base | latest | KELP et al. expect GNU make ≥4; macOS ships 3.81 — gnubin makes `make` the brew one |
| pre-commit | Homebrew `pre-commit` | `pipx install pre-commit` | base | major | Orchestrates terraform_fmt/validate/tflint/tfsec/terraform-docs hooks org-wide |
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
| Packer | Homebrew `packer` | HashiCorp apt repo | infra | major | Same HashiCorp repo as the above |
| tflint | Homebrew `tflint` | official install script | infra | major | `~/.tflint.hcl` + `tflint-ruleset-aws`; plugins via per-repo `tflint --init` |
| tfsec | Homebrew `tfsec` | install script | infra | major | **Maintenance mode** — kept for repos whose pre-commit still calls it |
| Trivy | Homebrew `trivy` | install script | infra | major | tfsec's successor; `trivy config` covers the ruleset. Installed alongside tfsec during migration |
| terraform-docs | Homebrew `terraform-docs` | binary release | infra | major | Generates module docs in pre-commit |
| Ansible | Homebrew `ansible` | `pipx install ansible` | infra | major | `ansible-ke` pins `ansible@2.18.7`; pin via pipx |
| Docker | Docker Desktop cask | Docker Engine apt repo | docker | major | Linux needs `docker` group / new login |
| Ruby build deps | Homebrew deps | apt `*-dev` deps | ruby | major | Native build prerequisites |
| Ruby runtime | `ruby-install` / `chruby` | `ruby-install` / `chruby` | ruby | exact | Same manager both OSes; pin via `.ruby-version` |
| Node runtime | `nvm` | `nvm` | node | exact | Pin via `.nvmrc` (org standard; 22 repos) |
| Yarn | Corepack | Corepack | node | major | **Avoid** `apt install yarn` (installs `cmdtest`) |
| Python runtime | `pyenv` | `pyenv` (+ build deps) | python | exact | Pin via `.python-version`; mirrors the chruby/nvm pattern |
| JDK | Homebrew `openjdk@17` | apt `openjdk-17-jdk` | jvm | major | Gradle 8.x (hw-android) needs JDK 17+; Gradle bootstraps via wrapper |
| PHP | Homebrew `php@8.2` | apt `php8.2` | php | major | eRegulations (Craft CMS 4) pins 8.2; legacy PHP stays Dockerized (see below) |
| Composer | Homebrew `composer` | official installer | php | latest | PHP dependency manager; pairs with the PHP row |
| .NET SDK | Homebrew `dotnet-sdk` | Microsoft apt repo `dotnet-sdk-8.0` | dotnet | major | **Opt-in / niche** — only the modern cross-platform console/GIS tools; legacy .NET Framework is out (Windows-only) |
| Xcode | Mac App Store / `xcode-select` | n/a | ios | latest | macOS-only; required for any iOS build |
| CocoaPods | Homebrew `cocoapods` (or gem) | n/a | ios | major | macOS-only; rides the Ruby runtime |
| SwiftLint | Homebrew `swiftlint` | n/a | ios | major | macOS-only |
| Fastlane | gem via Bundler (per-repo) | n/a | ios | major | macOS-only; pinned per-repo in the app's Gemfile, not system-wide |
| MySQL | Homebrew `mysql` | apt `mysql-server` or MySQL vendor repo | databases | major | In practice apps run it via Docker Compose; native install is for local tooling |
| PostgreSQL | Homebrew `postgresql` | apt `postgresql` | databases | major | Usually Docker Compose in app boot; native is optional |
| Redis | Homebrew `redis` | apt `redis-server` | databases | major | Usually Docker Compose in app boot; native is optional |
| Memcached | Homebrew `memcached` | apt `memcached` | databases | major | Usually Docker Compose in app boot; native is optional |
| Clipboard copy | native `pbcopy` | `wl-copy` / `xclip` / stdout | system | n/a | Abstracted in `system/clipboard.zsh` |
| Clipboard paste | native `pbpaste` | `wl-paste` / `xclip` / message | system | n/a | Abstracted in `system/clipboard.zsh` |

## Out of scope: per-repo toolchains (devbox)

Several infra repos (`terraform-ke-modules`, `numenor`, `atlantis`, `ansible-ke`) use
[devbox](https://www.jetify.com/devbox) (Nix-based) to pin a per-repo toolchain
(awscli2, jq, tflint, tfsec, terraform-docs, vault, ansible, packer, …).

**devbox is sanctioned but out of scope for these dotfiles.** It solves a different
problem — a *reproducible per-repo toolchain*, pinned in `devbox.json` and entered with
`devbox shell` — than the dotfiles solve, which is the *per-developer OS-native baseline*.
The two compose: the dotfiles give you a working machine; a repo may layer devbox on top
for its exact tool versions. The dotfiles do not install, wrap, or depend on devbox, and
devbox is **not** the "Homebrew-on-Linux / cross-platform cleverness" the ownership rules
push back against — it is deliberately scoped to individual repos, not the shared baseline.

## Out of scope: legacy and single-platform stacks

Recorded so these are decisions, not gaps someone re-litigates later:

- **Legacy .NET Framework** (v4.x — WPF, WinForms, IIS-hosted web: `pos`, `ke_vdp`,
  FreshAir, `temp_*`) — Windows-only; no macOS/Ubuntu story. Only the modern
  cross-platform `Microsoft.NET.Sdk` console/GIS tools are covered (the opt-in .NET SDK row).
- **Legacy PHP** (CakePHP 2.x `register_ed`/`dtx_server`; Symfony `cc-lms`/`cc-csr`/`cc-rest`
  on PHP ≥5.x floors; WordPress course sites on PHP 7.x) — runs in Docker / legacy hosting.
  The PHP row targets the modern, actively-maintained line (eRegulations, PHP 8.2) only.
- **Per-project toolchains** ride their project's package manager, not the shared baseline:
  PHP `php-cs-fixer`/`PHPUnit` (Composer dev-deps), iOS `fastlane` (Bundler, per-repo
  Gemfile), Android `gradle` (the wrapper bootstraps itself per-repo), and SDK pins like
  `global.json`/`.tool-versions` where a repo sets them.
- **Android SDK command-line tools** — installable cross-platform but app-specific; the
  JDK row covers the shared system dependency. Add per-project if/when Android dev is local.

## Keeping this current

Update the matrix in the same PR whenever a shared tool is **added, removed, or moved
between sources**. A change to `homebrew/Brewfile` or an Ubuntu installer that adds or
drops a capability should not merge without a matching row change here. Treat a drift
between this table and the installers as a bug in whichever lags.
