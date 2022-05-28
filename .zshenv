export PYTHONSTARTUP=~/.pythonrc
export EDITOR=/usr/bin/nvim
export TERMINAL=/usr/bin/xfce4-terminal

PATH=$PATH:/home/marcus/bin
PATH=$PATH:/home/marcus/.local/bin
PATH=$PATH:/home/marcus/.emacs.d/bin

export HISTFILE="/home/marcus/.zhistory"  # History filepath
export HISTSIZE=10000          # Maximum events for internal history
export SAVEHIST=10000          # Maximum events in history file


# Gurobi
export GUROBI_HOME="/home/marcus/Software/gurobi911/linux64"
export PATH="${PATH}:${GUROBI_HOME}/bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
. "$HOME/.cargo/env"
