# Kalkomey Dotfiles

Welcome to the Kalkomey dotfiles repository! This repository contains configurations, scripts, and aliases that standardize and enhance the development environment for all Software Engineers at Kalkomey. It includes settings for various tools like Ruby, Vim, Git, tmux, and more.

## Table of Contents

1. [Introduction](#introduction)
2. [Installation Guide](#installation-guide)
3. [Configurations](#configurations)
   - [Ruby](#ruby)
   - [Databases](#databases)
   - [Docker](#docker)
   - [Git](#git)
   - [Zsh](#zsh)
   - [Vim](#vim)
   - [tmux](#tmux)
   - [Homebrew](#homebrew)
4. [Contributing](#contributing)
5. [License](#license)

## Introduction

Kalkomey's dotfiles are designed to ensure a consistent and efficient development experience. They include system configurations, development tools, text editors, and terminal utilities.

## Installation Guide

To install the dotfiles, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/kalkomey/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the `script/bootstrap` command to create symlinks:
   
   ```bash
   script/bootstrap
   ```

3. Run the `script/install` script to run all installers:
   
   ```bash
   script/install
   ```

## Configurations

### Ruby

- **Aliases**: Shortcuts for common Rails commands.
- **IRB Configuration**: Enhancements for the Interactive Ruby shell.
- **Gem Configuration**: Settings for RubyGems, including performance optimizations.
- **Ruby Installation**: Script to install specific Ruby versions.

### Databases

- **Database Installation**: Script to install databases using Homebrew.

### Docker

- **Docker Installation**: Script to set up Docker on macOS.

### Git

- **Aliases**: Shortcuts for common Git commands.
- **Global Configuration**: Standardized global Git settings and ignore patterns.

### Zsh

- **Main Configuration**: Defines shortcuts and primary Zsh settings.
- **Aliases**: Shortcuts for common shell commands.
- **Completion**: Customizes tab completion behavior.
- **Custom Functions**: Organizes shell functions and configurations.

### Vim

- **Main Configuration**: Sets up Vim, including plugins.
- **Plugin Installation**: Script to install specific Vim plugins.
- **Plugins**: Additional Vim-related configurations and plugins.

### tmux

- **Aliases**: Defines tmux-related aliases and functions.
- **Main Configuration**: Enhancements for tmux, including key bindings and color support.

### Homebrew

- **Brewfile**: Defines Homebrew packages, including text editors, terminal tools, and various development utilities.

## Contributing

Contributions to this repository are welcome. Please follow the standard GitHub pull request process, and ensure that your changes are well-documented.
