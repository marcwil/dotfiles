# Permanent delete, bypassing the `rm` → trash-put abbreviation in config.fish.
function realrm --wraps rm --description 'rm for real (no trash)'
    command rm $argv
end
