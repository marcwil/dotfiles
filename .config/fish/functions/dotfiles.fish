function dotfiles --wraps git --description 'bare dotfiles repo (~/.dotfiles over $HOME)'
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
end
