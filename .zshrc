# Source manjaro-zsh-configuration
if [[ -e ~/.zsh/manjaro-zsh-config ]]; then
  source ~/.zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e ~/.zsh/manjaro-zsh-prompt ]]; then
    source ~/.zsh/manjaro-zsh-prompt
fi

# Directory Stack
setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# Aliases
alias ls="ls --color=auto"
alias l="ls -lah"
alias ll="ls -lh"

alias grep='grep --color=auto'

alias ...="cd ../.."
alias ....="cd ../../.."

alias gst="git status"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

#Config
setopt share_history
unsetopt HIST_SAVE_NO_DUPS       # Write a duplicate event to the history file

# Plugins
source ~/.zsh/plugins/completion.zsh
source ~/.zsh/plugins/bd.zsh
