typeset -U FPATH fpath
typeset -U PATH path
typeset -U MANPATH manpath
typeset -U CDPATH cdpath

cdpath=( $HOME/daimler $HOME/tmp )

export ACCOUNT_ID=
export AWS_REGION=eu-central-1
export CLUSTER_NAME=

export LESS='--buffers=128 --HILITE-UNREAD --ignore-case --LONG-PROMPT --max-back-scroll=15 --no-init --quiet --quit-at-eof --quit-if-one-screen --RAW-CONTROL-CHARS --status-column --tabs=4 --window=-4'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--height 50% --ansi --info=inline'
export EDITOR='nvim'


# vim: set fileformat=unix tabstop=4 shiftwidth=4 expandtab:
