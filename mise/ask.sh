# shellcheck shell=bash
# mise topic: which languages and CLI tools to install globally.
# Sourced by script/ask. Each list is parallel arrays (name, description,
# default version, default on); see resolve_choice in script/lib/common.sh.
#
# Projects override these with .tool-versions / mise.toml / .ruby-version /
# .node-version; these are just the global defaults.

LANG_NAMES=(ruby node python go rust java elixir)
LANG_DESCS=(
  "Baseline for all our applications"
  "JavaScript runtime"
  "Python"
  "Go"
  "Rust"
  "Java (JDK)"
  "Elixir (also installs Erlang; first build is slow)"
)
LANG_VERS=(4.0.6 lts latest latest latest lts latest)
LANG_ON=(1 1 0 0 0 0 0)

TOOL_NAMES=(aws-cli aws-vault consul direnv fzf gh git-lfs gron jq nomad ripgrep terraform vault yarn zoxide)
TOOL_DESCS=(
  "AWS CLI"
  "Credential manager for AWS profiles"
  "HashiCorp Consul"
  "Per-directory environment variables"
  "Fuzzy finder"
  "GitHub CLI (replaces hub)"
  "Git large file storage"
  "Make JSON greppable"
  "JSON processor"
  "HashiCorp Nomad"
  "Fast grep (replaces ag/ack)"
  "Terraform (replaces tfenv)"
  "HashiCorp Vault"
  "Yarn package manager"
  "Smarter cd that learns your directories (z); enabled by the zoxide zsh plugin"
)
TOOL_VERS=()
TOOL_ON=(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)

ask_mise() {
  resolve_choice MISE_LANGUAGES LANG "Languages (installed globally via mise):" 1 1
  resolve_choice MISE_TOOLS     TOOL "CLI tools (installed globally via mise):" 0 1
}
