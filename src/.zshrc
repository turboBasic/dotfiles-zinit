
##  Zsh vars and options
setopt interactive_comments
skip_global_compinit=1


##  Zsh key bindings
bindkey -e
bindkey '^U' push-input


##  Zsh aliases
alias history='builtin fc -il'
alias ls='command gls --color=auto --time-style=long-iso --group-directories-first'
alias ll='command gls --color=auto --time-style=long-iso --group-directories-first --almost-all --classify --format=long'
alias l='command exa --all --long --time-style=long-iso --group --classify --links --group-directories-first'
alias d-i-f='command docker images --format="{{.ID}}・{{if gt (len .Repository) 35}}…{{slice .Repository (slice .Repository 34|len)}}{{else}}{{printf \"%-35s\" .Repository}}{{end}}・{{if gt (len .Tag) 15}}{{slice .Tag 14}}…{{else}}{{.Tag}}{{end}}"'
# Workaround for too wide table
alias bat='command bat --terminal-width=-2'


##  Zsh history
HISTFILE=${HISTFILE:-"$HOME/.zsh_history"}
HISTSIZE=999999999
SAVEHIST=$HISTSIZE
setopt extended_history \
       share_history \
       hist_find_no_dups \
       hist_ignore_space \
       hist_ignore_dups \
       hist_no_store \
       hist_reduce_blanks \
       hist_verify \


##  Zinit
() {
    ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
    [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

    local homebrew_prefix=${HOMEBREW_PREFIX-/opt/homebrew}
    [[ -d "$homebrew_prefix/share/zsh/site-functions" ]] && fpath+=( "$homebrew_prefix/share/zsh/site-functions" )

    # Fix for macOS where native realpath utility does not support options used by Zinit
    path[1,0]="$homebrew_prefix/opt/coreutils/libexec/gnubin"

    source "${ZINIT_HOME}/zinit.zsh"

    # Revert macOS fix
    path=( "${(@)path:#$homebrew_prefix/opt/coreutils/libexec/gnubin}" )

    manpath+=( "$ZPFX/man" /usr/share/man )
}


##  Homebrew install
() {
    local homebrew_prefix=${HOMEBREW_PREFIX-/opt/homebrew}
    zinit light-mode lucid for \
            id-as='brew' \
            pick='brew.zsh' \
            nocompile='!' \
            atclone='
                if [[ ! -x "$homebrew_prefix/bin/brew" ]]; then
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                fi
                $homebrew_prefix/bin/brew shellenv > brew.zsh
            ' \
            atpull='brew update' \
            run-atpull \
        zdharma-continuum/null

    ##  Homebrew install essential packages
    (( $+commands[brew] )) &&
    zinit light-mode lucid for \
            id-as='brew-essential-formulae' \
            nocompile='!' \
            atclone=$'
                (( $+commands[grealpath] )) || brew install coreutils
                (( $+commands[gawk] )) || brew install gawk
                (( $+commands[gfind] )) || brew install findutils
                (( $+commands[ggrep] )) || brew install grep
                (( $+commands[gsed] )) || brew install gnu-sed
                (( $+commands[gtar] )) || brew install gnu-tar
                (( $+commands[aws] )) || brew install awscli
                (( $+commands[docker] )) || brew install --cask docker
                (( $+commands[exa] )) || brew install exa
                (( $+commands[jq] )) || brew install jq
                (( $+commands[nvim] )) || brew install neovim
                (( $+commands[pkg-config] )) || brew install pkg-config
                (( $+commands[rg] )) || brew install ripgrep
                (( $+commands[tldr] )) || brew install tldr
                (( $+commands[tree] )) || brew install tree
                (( $+commands[zstd] )) || brew install zstd
                brew list curl &> /dev/null || brew install curl
                brew list font-fira-code-nerd-font &> /dev/null || {
                    brew tap homebrew/cask-fonts
                    brew install font-fira-code-nerd-font
                }
                brew list visual-studio-code &> /dev/null || brew install visual-studio-code

                local homebrew_prefix=${HOMEBREW_PREFIX-$(brew --prefix)}
                local i j files symlinks
                symlinks=( $homebrew_prefix/opt/*/libexec/gnubin )
                for i in $symlinks; do
                    files=( $(find "$i" -mindepth 1 -not -type d) )
                    for j in $files; do
                        ln -sfv "$j" $HOME/.local/bin/"$(basename "$j")"
                    done
                done

                cat <<-\'EOF\' > brew-essential-formulae.zsh
                    for i in $homebrew_prefix/opt/*/libexec/gnuman(N) $homebrew_prefix/opt/curl/share/man(N); do
                        manpath[1,0]=$i
                    done
				EOF
            ' \
            atload='ZINIT[LIST_COMMAND]="exa --color=always --tree --icons -L3"' \
        zdharma-continuum/null
}


##  Zinit lightweight plugins, loaded synchronously
() {
    # Enable these when required
    #   OMZP::invoke \
    #   OMZP::jfrog \
    #   OMZP::pip \
    #   OMZP::aws \
    zinit light-mode lucid for \
        zdharma-continuum/z-a-meta-plugins \
        zdharma-continuum/zinit-annex-unscope \
        zdharma-continuum/zinit-annex-readurl \
        zdharma-continuum/zinit-annex-patch-dl \
        zdharma-continuum/zinit-annex-submods \
        zdharma-continuum/zinit-annex-bin-gem-node \
        @sharkdp \
            id-as='generate-ls-colors' \
            pick='colors.sh' \
            nocompile='!' \
            atclone='zsh --no-rcs generate-ls-colors molokai > colors.sh' \
            atpull='%atclone' \
            atload='zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"' \
        https://gist.githubusercontent.com/turboBasic/26d0b94957864767a07f18e7c689a0ce/raw/generate.sh \
            \
            compile='(pure|async).zsh' pick='async.zsh' src='pure.zsh' \
        sindresorhus/pure \
            \
            atload='unfunction uninstall_oh_my_zsh upgrade_oh_my_zsh' \
        OMZL::functions.zsh \
            \
        OMZL::clipboard.zsh \
        OMZL::git.zsh \
            \
            as='null' \
            id-as='idea' \
            sbin='idea' sbin='pycharm' \
            atclone='
                local idea_scripts_path="$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
                if [[ -d "$idea_scripts_path" ]]; then
                    cp "$idea_scripts_path"/* ./
                else
                    +zi-log "{b}{u-warn}ERROR{b-warn}:{rst} Directory {cmd}$idea_scripts_path{rst} does not exist"
                    false
                fi
            ' \
        zdharma-continuum/null
}


##  Heavy Zinit plugins, loaded asynchronously in Turbo mode
() {
    zinit light-mode lucid wait for \
            pack='bgn-binary+keys' \
        fzf \
            \
            from='gh-r' \
            as='program' \
            mv='direnv* -> direnv' \
            pick='direnv' \
            src='zhook.zsh' \
            atclone='./direnv hook zsh > zhook.zsh' \
            atpull='%atclone' \
        direnv/direnv \
            \
            wait='1a' \
            as='null' \
            nocompile='!' \
            submods='pyenv/pyenv-virtualenv -> plugins/pyenv-virtualenv' \
            src='install.zsh' \
            sbin='bin/pyenv' \
            atinit='export PYENV_ROOT="$PWD"' \
            atclone=$'
                PYENV_ROOT="$PWD" ./libexec/pyenv init - > install.zsh
                echo \'eval "$(pyenv virtualenv-init -)"\' >> install.zsh
            ' \
            atpull='%atclone' \
        pyenv/pyenv \
            \
            wait='1b' \
            as='null' \
            id-as='sdkman' \
            cp='$ZPFX/sdkman/bin/sdkman-init.sh -> sdkman-init.zsh' \
            compile='sdkman-init.zsh' \
            atinit='export SDKMAN_DIR=$ZPFX/sdkman' \
            atclone='
                curl --output scr.sh "https://get.sdkman.io/?rcupdate=false"
                SDKMAN_DIR=$ZPFX/sdkman bash scr.sh
            ' \
            atpull='SDKMAN_DIR=$ZPFX/sdkman sdk selfupdate || true' \
            run-atpull \
            atload='SDKMAN_DIR=$ZPFX/sdkman source sdkman-init.zsh' \
        zdharma-continuum/null \
            \
            if='[[ -x $HOME/anaconda3/bin/conda ]]' \
            wait \
            id-as='conda' \
            nocompile='!' \
            atclone=$'
                $HOME/anaconda3/bin/conda shell.zsh hook 2>/dev/null >conda.zsh
                cat <<-\'EOF\' >>conda.zsh
                    conda deactivate
                    path=( "${(@)path:#$HOME/anaconda3/condabin}" )
                    path+=( "$HOME/anaconda3/bin" )
				EOF
            ' \
            atpull='%atclone' \
        zdharma-continuum/null

    zinit lucid for \
            wait \
            as='none' \
            has='pkg-config' \
            pick='misc/quitcd/quitcd.bash_sh_zsh' \
            sbin='nnn -> nnn' \
            make \
        jarun/nnn
}


##  Zinit Zsh completion plugins
() {
    zinit light-mode lucid wait for \
            as='completion' \
            is-snippet \
        $HOMEBREW_PREFIX/share/zsh/site-functions/_brew \
            \
            id-as='_bw' \
            as='completion' \
            is-snippet \
            nocompile='!' \
            atclone='cp "$(realpath _bw)" _bw_tmp; rm -f _bw; mv _bw_tmp _bw' \
        $HOMEBREW_PREFIX/share/zsh/site-functions/_bitwarden-cli \
            \
            as='completion' \
            is-snippet \
        $HOMEBREW_PREFIX/opt/curl/share/zsh/site-functions/_curl \
            \
            as='completion' \
            is-snippet \
        https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker \
            \
            as='completion' \
            is-snippet \
        https://raw.githubusercontent.com/johan/zsh/master/Completion/Unix/Command/_gpg \
            \
            as='completion' \
            is-snippet \
        $HOMEBREW_PREFIX/share/zsh/site-functions/_rg \
            \
            id-as='kubectl' \
            as='completion' \
            nocompile='!' \
            pick='_kubectl' \
            atclone='
                touch _kubectl
                if [[ $commands[kubectl] ]]; then
                    kubectl completion zsh > _kubectl
                fi
            ' \
            run-atpull \
            atpull='%atclone' \
        zdharma-continuum/null
}


##  Plugins which should be loaded the last
() {
    zinit light-mode lucid for \
            wait \
            atload='!_zsh_autosuggest_start' \
        zsh-users/zsh-autosuggestions \
            \
            wait='1z' \
            atinit='ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay' \
        zdharma-continuum/fast-syntax-highlighting \
            \
            wait='1' \
            if='[[ -d $HOME/.local/bin ]]' \
            id-as='local-gnu-utils' \
            nocompile='!' \
            atclone=$'cat <<-\'EOF\' > local-gnu-utils.zsh
                path[1,0]=$HOME/.local/bin
			EOF' \
        zdharma-continuum/null
}


# vim: set fileformat=unix tabstop=4 shiftwidth=4 expandtab:
