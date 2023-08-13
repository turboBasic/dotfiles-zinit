Dotfiles for Zinit
==================

Scripts install Zinit, Homebrew and small set of essential packages.

GNU versions of common commands are installed and PATH is modified so that GNU 
utils can be invoked without `g` prefix.

Additionally they provide fast loading of utilities which are otherwise
make Zsh startup slow and bloated: Pyenv, Sdkman, Conda, small set of Oh-My-Zsh
plugins and command-line completions.

These dotfiles are developed for macOS platform. Despite GNU packages are
deployed, the bootstrap sequence has not been tested on naked Linux platform,
so full compatibility with Linux should be investigated.


## Installation

```zsh
make
```
