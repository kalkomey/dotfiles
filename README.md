## dotfiles

Kalkomey's dotfiles based on [Zach Holman](https://github.com/holman)'s [dotfiles](https://github.com/holman/dotfiles) philosophy. However, there's plenty of stuff from [Hashrocket](https://github.com/hashrocket)'s [dotmatrix](https://github.com/hashrocket/dotmatrix).

## install

Run this in Terminal:

```sh
curl -fsSL https://raw.githubusercontent.com/kalkomey/dotfiles/master/setup.sh | bash
```

It installs the Xcode Command Line Tools if needed, clones this repo into
`~/.dotfiles` (or fast-forwards an existing clean checkout), and runs
`script/bootstrap`. To preview without changing anything, add `-s -- --dry-run`
after `bash`. If you would rather read the script first:

```sh
curl -fsSL https://raw.githubusercontent.com/kalkomey/dotfiles/master/setup.sh -o setup.sh
less setup.sh && bash setup.sh
```

Or do it by hand:

```sh
git clone https://github.com/kalkomey/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

Bootstrap will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

`dot` is a simple script that installs dependencies, and so on. Tweak this script, and occasionally run `dot` from
time to time to keep your environment fresh and up-to-date. You can find
this script in `bin/`.

### already have dotfiles (or use stow)?

Nothing you have is overwritten without asking. For each file that already
exists (including symlinks into your own dotfiles repo) you are asked to
**keep** yours, use the **new** one, **merge** (a two-pane `vimdiff`, or set
`MERGE_TOOL`), or **diff** them. Choosing new or merge moves your original into
`~/.dotfiles-backup/<timestamp>/` first; nothing is deleted, and your stow
directory is never written to. Preview with `script/bootstrap --dry-run`. With
no terminal to ask on, your files are kept (`DOTFILES_LINK=new` to override).
If you keep your `~/.zshrc`, the installer prints the lines to add so mise and
the oh-my-zsh plugins load.

### customizing

Your own settings go in `.local` files in your home directory. The repo's files
load them last, so they win, and they are never committed, so updates never
touch them. Making one takes a minute.

| File | Loaded by | Good for |
|---|---|---|
| `~/.zshrc.local` | `.zshrc`, last | API keys and tokens, your aliases, functions, `cdpath` |
| `~/.gitconfig.local` | `[include]` in `.gitconfig` | name, email, signing key, personal git settings |
| `~/.vimrc.local` | `.vimrc`, last | your vim settings |
| `~/.tmux.conf.local` | `.tmux.conf` | your tmux settings |
| `~/.pryrc.local` | `.pryrc` | your pry settings |

Bootstrap creates `~/.gitconfig.local` from the name and email it asks for, and
`~/.zshrc.local` from [`zsh/zshrc.local.example`](zsh/zshrc.local.example) (a
template with sections for env variables, aliases and functions). The others are
optional: create one when you need it, for example

```sh
echo 'alias gs="git status -sb"' >> ~/.zshrc.local
```

then open a new terminal (or run `source ~/.zshrc`). Never put tokens in a
tracked file; `~/.zshrc.local` is the place for them. Two things do not belong
there: oh-my-zsh plugins (it reads them when it loads, before `.zshrc.local`; change
them with `RECONFIGURE=1`, see below) and anything you want every engineer to
have (change the repo instead).

### Claude Code status line

If you use [Claude Code](https://claude.com/claude-code), `claude/install.sh` links
`claude/statusline.sh` to `~/.claude/statusline.sh` and adds a `statusLine` entry
to `~/.claude/settings.json`. The status line shows the model, a context-usage
bar, the session cost and its duration, for example
`[Sonnet] ▓▓▓░░░░░░░ 37% ctx | $1.23 | 12m 34s`. It needs `jq` (macOS 15 and
later include one; otherwise mise's). It is skipped when Claude Code is not
installed, and it never overwrites: an existing `statusline.sh`, an existing
`statusLine` setting, or a `settings.json` that is a symlink or not valid JSON is
left as it is. Before it edits `settings.json` it saves a copy in
`~/.dotfiles-backup/`.

The same installer adds a small mod, `kalkomey-statusbar` (in `claude/mods`), that
draws the same line above the prompt in the **Claude desktop app** (Code tab). It
installs as a Claude Code plugin from a local marketplace, `kalkomey-dotfiles`,
at user scope, so the terminal and the app share it; restart the app (or run
`/reload-plugins`) to see it. It needs the `claude` command, so the installer
skips it with a note when that is missing. Manage it with `/plugin`, or
`claude plugin uninstall kalkomey-statusbar@kalkomey-dotfiles`. Keep `~/.dotfiles` in
place, since the marketplace points at it. Run both steps on their own with
`bash ~/.dotfiles/claude/install.sh`.

### languages, tools, and zsh plugins

Languages and CLI tools are managed by [mise](https://mise.jdx.dev). `dot`
first runs `script/ask`, which asks everything up front (and offers sensible
defaults), then runs one installer per topic (`mise/`, `fonts/`, `apps/`, `neovim/`,
`zsh/`) from your answers. The questions cover:

- **languages** — Ruby 4.0.6 (our baseline) and Node LTS are on by default;
  Python, Go, Rust, Java and Elixir are available, and you can type any other
  mise tool as `name@version` (or `name@latest`). Entries are checked against
  mise before anything installs.
- **CLI tools** — aws-cli, gh, jq, ripgrep, terraform, vault, etc.
- **oh-my-zsh** — optional (on by default). Answer no and the plugin question is
  skipped, oh-my-zsh is not installed, and `.zshrc` does not load one you already
  have. Set `OHMYZSH=0` to skip the question, or `OHMYZSH=1` to say yes.
- **oh-my-zsh plugins** — `git` and friends (asked only if you chose oh-my-zsh).
  With the `zoxide` plugin on, you
  are also asked whether to replace `cd` with zoxide; if so,
  `export ZOXIDE_CMD_OVERRIDE=cd` is appended to `~/.zshenv` (created if
  missing). `z` and `zi` work either way.
- **Nerd Fonts** — FiraCode and DejaVu Sans Mono are listed and on by default;
  type `m` to scroll through every other Nerd Font Homebrew offers (read from
  Homebrew). Preview them at https://www.nerdfonts.com/font-downloads. JetBrains
  Mono, Cascadia (Caskaydia Cove), Monaspace and others have ligatures. Set your
  terminal font to the family name, e.g. "FiraCode Nerd Font", and turn on
  ligatures if your terminal has a setting (iTerm2 does; Terminal.app has no
  ligature support).
- **Applications** — Homebrew casks, listed by cask name: cmux, ghostty, kitty,
  obsidian, rectangle, sequel-ace, sublime-text, tldraw and zed. None is on by default,
  because IT's machine image already installs the standard apps. Type any
  other cask name (for example `raycast`) to add it; it is
  checked against Homebrew before anything installs. An app already in
  `/Applications` is adopted by Homebrew rather than reinstalled. Set
  `APPS="obsidian zed"` to skip the question, or `APPS=none` for no apps.
- **Neovim + LazyVim** — optional (off by default). Installs Neovim, `fd`,
  `lazygit`, and the LazyVim starter into `~/.config/nvim` (skipped if that
  directory already exists). LazyVim wants a Nerd Font, so pick one above. Run
  with `nvim`; your vim setup is untouched.

The zsh installer also appends one marked block to `~/.zprofile` (Homebrew's
`shellenv`, then mise shims) so login shells, scripts and IDE tasks use the same
mise-managed ruby and node as your interactive terminal. Delete the block to undo it.

Answers are saved in `~/.config/dotfiles/install-choices` and reused on later
runs. To be asked again, run `RECONFIGURE=1 bin/dot`. Anything can also be
set non-interactively, e.g. `MISE_LANGUAGES="ruby@4.0.6 node@lts" bin/dot`.
To preview without installing anything, run `script/ask --dry-run`: it asks
the questions, prints your choices, and stops (nothing is installed or saved).
Projects pick their own versions with `.tool-versions`, `mise.toml`,
`.ruby-version` or `.node-version`.

### docker

`docker/install.sh` installs the open-source Docker CLI, Colima (the VM that
runs containers), `docker compose` and `docker buildx` as CLI plugins, and
lazydocker. **We do not use Docker Desktop**: at our size its license requires a
paid subscription. The installer starts Colima and registers it to start at
login (`brew services`); check it with `colima status`.

## custom install

If you are using an alternative shell like fish, or alternative version manager software, some of the commands might not be a good fit for you. You might also want to ignore certain aliases to fit your preferences. As a bare minimum you will need to have the `.dotfiles/bin` files in your path to set up a lot of repositories. You can accomplish this by cloning the repository and using whatever method your shell supports to add that folder to your path, for example `fish_add_path .dotfiles/bin`.
## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## what's inside

A lot of what's inside is just aliases: `gst` for `git status`, `gpr` for `git
pull --rebase --prune`, for example. You can browse the `aliases.zsh` files in
each topic directory. There's also a collection of scripts in `bin` you can
browse.

## thanks

I forked [Zach Holman](http://github.com/holman)'s
[dotfiles](http://github.com/holman/dotfiles) and basically adopted his philosophy
but made it work with my preferred environment tools.
A decent amount of the code in these dotfiles stems either from Hashrocket's Dotmatrix, Holman's dotfiles or by extension,
Ryan Bates' original dotfiles.
