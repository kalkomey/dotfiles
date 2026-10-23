# ~/aliases.zsh
# vim:set ft=sh sw=2 sts=2:

muxable_paths=(${SOURCE_DIR}/trm ${SOURCE_DIR}/itts ${SOURCE_DIR}/ke)
aios_worktrees="${AIOS_WORKTREES:-${HOME}/aios/worktrees}"

# `cdpath` (set in ~/.zshrc.local) expands muxable_paths as static search
# roots, so `cd slash` finds ~/src/ke/slash in one hop — cdpath can't express
# "search under any ~/aios/worktrees/*/" since that needs a glob, not a fixed
# root list. This overrides cd to check aios worktrees first — an exact
# project id, then any project's leaf of that name (newest-modified wins if
# more than one project has it checked out) — and falls through to the real
# builtin (still honoring cdpath) for everything else, including a bare name
# with no aios match at all.
cd() {
  local target="$1"

  if [[ $# -eq 1 && -n "$target" && "$target" != -* && "$target" != /* \
        && "$target" != .* && "$target" != ~* ]]; then
    local aios_worktrees="${AIOS_WORKTREES:-${HOME}/aios/worktrees}"
    local -a matches

    if [[ -d "${aios_worktrees}/${target}" ]]; then
      builtin cd "${aios_worktrees}/${target}"
      return
    fi

    matches=(${aios_worktrees}/*/${target}(/N))
    if (( ${#matches} == 1 )); then
      builtin cd "${matches[1]}"
      return
    elif (( ${#matches} > 1 )); then
      builtin cd "$(ls -dt ${matches[@]} | head -1)"
      return
    fi
  fi

  # With zoxide replacing cd (ZOXIDE_CMD_OVERRIDE=cd, see zsh/install.sh), this function
  # shadows the `cd` zoxide defines, since our aliases are sourced after it. Hand off to
  # zoxide's own function so `cd` keeps learning and jumping.
  if [[ "${ZOXIDE_CMD_OVERRIDE:-}" == cd ]] && (( $+functions[__zoxide_z] )); then
    __zoxide_z "$@"
    return
  fi

  builtin cd "$@"
}

# mux <path>                   legacy: cd into a plain repo checkout,
#                                session named for its basename
# mux <project_id> [<leaf>]     aios: cd into ~/aios/worktrees/<project_id>[/<leaf>],
#                                session named "<project_id>/<leaf>" so it
#                                can't collide across projects the way a bare
#                                basename can. With no leaf, falls back to the
#                                project's sole repo if it only has one.
mux() {
  local project="$1" leaf="$2"
  local name mux_file target

  if [[ -f "${aios_worktrees}/${project}/.project.yml" ]]; then
    if [ -n "$leaf" ]; then
      target="${aios_worktrees}/${project}/${leaf}"
      name="${project}/${leaf}"
    else
      target="${aios_worktrees}/${project}"
      local sole_repo
      sole_repo="$(awk '/^- name:/{print $3; exit}' "${target}/.project.yml")"
      name="${sole_repo:+${project}/${sole_repo}}"
      name="${name:-$project}"
    fi
  else
    target="$1"
    name="$(basename "${target:-$PWD}" | sed -e 's/\./-/g')"
  fi

  [ -n "$target" ] && { cd "$target" || return 1 }

  mux_file="${PWD}/.mux"
  [ -f ${mux_file} ] || mux_file="${HOME}/.mux"

  if ! tmux has-session -t "=$name" &>/dev/null; then
    local cols="$(tput cols)"
    tmux new-session -d -n code -s ${name} -x${cols-150} -y50 'zsh'
    echo "Creating tmux session for ${name}"
    name="${name}" source "${mux_file}"
  fi

  tmux attach-session -t "$name"
}
