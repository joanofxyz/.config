#!/bin/bash

################################################################################
# options ######################################################################
HISTFILE=~/.zsh_history
setopt INC_APPEND_HISTORY AUTO_LIST AUTO_MENU NOMATCH MENU_COMPLETE

export ZDOTDIR="$HOME/.config/zsh"
[ -f "$ZDOTDIR/.secrets" ] && source "$ZDOTDIR/.secrets"
[ -f "$ZDOTDIR/.functions" ] && source "$ZDOTDIR/.functions"
ulimit -n 4096
################################################################################



################################################################################
# zinit setup ##################################################################
export ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
    print -P "%F{33} %F{34}Installation successful.%f%b" || \
    print -P "%F{160} The clone has failed.%f%b"
fi
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
################################################################################



################################################################################
# exports ######################################################################
export HISTSIZE=1000000
export SAVEHIST=1000000
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export GPG_TTY=$(tty)
export BAT_CONFIG_PATH="$HOME/.config/bat/bat.conf"
export EDITOR="nvim"
export DOTFILES_DIR="$HOME/.config/.cfg"
export DOTFILES_TREE="$HOME"

# path
export PATH="$HOME/bin":$PATH
export PATH="$HOME/.local/bin":$PATH
export PATH="/opt/homebrew/bin":$PATH
export PATH="/.local/share/nvim/mason/bin":$PATH
export PATH="/.local/share/nvim/mason/packages":$PATH

# go
export PATH="$HOME/.local/share/go/bin":$PATH
export GOPATH="$HOME/.local/share/go"

# python
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin":$PATH
eval "$(pyenv init -)"
export PIPENV_VENV_IN_PROJECT=1

# mysql
export PATH="/opt/homebrew/opt/mysql-client/bin":$PATH

# # node
# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# export PATH="./node_modules/.bin":$PATH
# export PATH="$(npm config get prefix)":$PATH
################################################################################



################################################################################
# aliases ######################################################################
alias la="ls -la --color=auto"

alias nv="nvim"
alias lg='lazygit'
alias d2ux='find . -type f -print0 | xargs -0 dos2unix'

alias python='python3'
alias pip='pip3'

alias cf="caffeinate -dims"
alias laj="tmuxpopup &!"
alias ldj='pkill -f "bash.*tmuxpopup|sleep 10"'

alias wfuzz="docker run --rm -it -v $(pwd)/wordlist:/wordlist/ ghcr.io/xmendez/wfuzz wfuzz"
alias hydra="docker run --rm -it docker.io/vanhauser/hydra"
################################################################################



################################################################################
# completions ##################################################################
autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zmodload zsh/complist
_comp_options+=(globdots)
compinit
zinit cdreplay -q
################################################################################



################################################################################
# plugins ######################################################################
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)

zinit lucid wait for "Aloxaf/fzf-tab"
zinit lucid wait for "zsh-users/zsh-autosuggestions"
zinit lucid wait for "zdharma-continuum/fast-syntax-highlighting"

zinit light "jeffreytse/zsh-vi-mode"

export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
################################################################################



################################################################################
# colorscheme ##################################################################
autoload -Uz colors && colors
export FZF_DEFAULT_OPTS='--color=fg:-1,bg:-1,hl:#52665f
--color=fg+:#ababab,bg+:#303030,hl+:#3d6658
--color=info:#665f52,prompt:#663d4b,pointer:#5f5266
--color=marker:#4b663d,spinner:#665258,header:#525866
--color=preview-fg:#ababab,preview-bg:#262626'
################################################################################



################################################################################
# prompt #######################################################################
autoload -Uz vcs_info
autoload -U colors && colors
zstyle ':vcs_info:*' enable git
precmd_vcs_info() { vcs_info; }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
+vi-git-untracked(){
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
    git status --porcelain | grep '??' &> /dev/null ; then
    # This will show the marker if there are any untracked files in repo.
    # If instead you want to show the marker only if there are untracked
    # files in $PWD, use:
    #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
    hook_com[staged]+='!' # signify new files with a bang
  fi
}
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:git:*' formats " %{$fg[blue]%}(%{$fg[red]%}%m%u%c%{$fg[yellow]%}%{$fg[magenta]%} %b%{$fg[blue]%})"
PROMPT="%B%{$fg[blue]%}[%{$fg[cyan]%}%n%{$fg[red]%}@%{$fg[blue]%}%m%{$fg[blue]%}] %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%} %c%{$reset_color%}"
PROMPT+="\$vcs_info_msg_0_ "
################################################################################
