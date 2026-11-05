# default apps
(( ${+PAGER} )) || export PAGER='less'
(( ${+EDITOR} )) || export EDITOR='vim'

export PSQL_EDITOR='vim -c"set syntax=sql"'

# ripgrep config (system/ripgreprc.symlink -> ~/.ripgreprc)
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
