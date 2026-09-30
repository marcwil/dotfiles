source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="vim"

zoxide init fish | source

# rm goes to the trash (undo with trash-restore); real delete: `realrm`
# ~/.local/bin/trash-reminder (daily timer) nags when trash is >30 days old or >3 GB
if status is-interactive
    abbr -a rm trash-put
end
