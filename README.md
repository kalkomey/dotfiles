## dotfiles

Kalkomey's dotfiles based on [Zach Holman](https://github.com/holman)'s [dotfiles](https://github.com/holman/dotfiles) philosophy. However, there's plenty of stuff from [Hashrocket](https://github.com/hashrocket)'s [dotmatrix](https://github.com/hashrocket/dotmatrix).

## install

Run this:

```sh
git clone https://github.com/kalkomey/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

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
- **oh-my-zsh plugins** — `git` and friends.
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
