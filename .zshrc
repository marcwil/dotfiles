# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e ~/.zsh/manjaro-zsh-prompt ]]; then
    source ~/.zsh/manjaro-zsh-prompt
fi

export PYTHONSTARTUP=~/.pythonrc
export EDITOR=nvim
if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<~/.ssh-agent-thing)" > /dev/null
fi

alias l="ls -lah"
alias ll="ls -lh"
alias ...="cd ../.."
alias ....="cd ../../.."
alias gst="git status"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
