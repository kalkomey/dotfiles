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

Personal settings and secrets (API keys, tokens, your own aliases) go in
`~/.zshrc.local`, which `zshrc.symlink` loads last and which is never committed.
Start from the template:

```sh
cp ~/.dotfiles/zsh/zshrc.local.example ~/.zshrc.local
```

Never put tokens in a tracked file. Git settings work the same way, in
`~/.gitconfig.local`.

`dot` is a simple script that installs some dependencies, sets sane OS X
defaults, and so on. Tweak this script, and occasionally run `dot` from
time to time to keep your environment fresh and up-to-date. You can find
this script in `bin/`.

### languages, tools, and zsh plugins

Languages and CLI tools are managed by [mise](https://mise.jdx.dev). `dot`
first runs `script/ask`, which asks everything up front (and offers sensible
defaults), then runs one installer per topic (`mise/`, `fonts/`, `neovim/`,
`zsh/`) from your answers. The questions cover:

- **languages** — Ruby 4.0.6 (our baseline) and Node LTS are on by default;
  Python, Go, Rust, Java and Elixir are available, and you can type any other
  mise tool as `name@version` (or `name@latest`). Entries are checked against
  mise before anything installs.
- **CLI tools** — aws-cli, gh, jq, ripgrep, terraform, vault, etc.
- **oh-my-zsh plugins** — `git` and friends. With the `zoxide` plugin on, you
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
paid subscription. After installing, run `colima start` once (and
`brew services start colima` to start it at login).

## custom install

If you are using an alternative shell like fish, or alternative version manager software, some of the commands might not be a good fit for you. You might also want to ignore certain aliases or osx configuration changes to fit your preferences. As a bare minimum you will need to have the `.dotfiles/bin` files in your path to set up a lot of repositories. You can accomplish this by cloning the repository and using whatever method your shell supports to add that folder to your path, for example `fish_add_path .dotfiles/bin`.
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
