source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"

zoxide init fish | source

# rm goes to the trash (undo with trash-restore); real delete: `realrm`
# ~/.local/bin/trash-reminder (daily timer) nags when trash is >30 days old or >3 GB
if status is-interactive
    abbr -a rm trash-put
end

# vim runs neovim (nvim reads ~/.vimrc via ~/.config/nvim/init.vim); real vim: `command vim`
if status is-interactive
    alias vim nvim
end
