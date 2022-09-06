if [[ "$SSH_AGENT_PID" == "" ]]; then
    eval "$(<~/.ssh-agent-thing)" > /dev/null
fi



# Added by Toolbox App
export PATH="$PATH:/home/marcus/.local/share/JetBrains/Toolbox/scripts"