if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<~/.ssh-agent-thing)" > /dev/null
fi

export EDITOR=vim

# Added by Toolbox App
export PATH="$PATH:/home/marcus/.local/share/JetBrains/Toolbox/scripts"
export PATH="$PATH:/home/marcus/.config/emacs/bin"

#export LUA_PATH="/usr/share/texmf-dist/scripts/digestif/?.lua;;${LUA_PATH}"

# Install Ruby Gems to ~/.gems
export GEM_HOME="$HOME/.gems"
export PATH="$HOME/.gems/bin:$PATH"
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
