if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<~/.ssh-agent-thing)" > /dev/null
fi


export EDITOR=vim

# Added by Toolbox App
export PATH="$PATH:/home/marcus/.local/share/JetBrains/Toolbox/scripts"
export PATH="$PATH:/home/marcus/.config/emacs/bin"

#export LUA_PATH="/usr/share/texmf-dist/scripts/digestif/?.lua;;${LUA_PATH}"

