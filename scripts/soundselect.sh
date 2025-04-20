#!/bin/bash

list_devices() {
    local type=$1
    local detailed=$2
    local pactl_type=""

    if [[ "$type" == "input" ]]; then
        pactl_type="source"
    elif [[ "$type" == "output" ]]; then
        pactl_type="sink"
    else
        echo "Invalid type: use 'input' or 'output'"
        exit 1
    fi

    if command -v pactl &>/dev/null; then
        default_device=$(pactl get-default-"$pactl_type")

        pactl list short "${pactl_type}s" | while read -r id name rest; do
            is_default=""
            [[ "$name" == "$default_device" ]] && is_default="*"

            description=$(pactl list "${pactl_type}s" | awk -v name="$name" '
                $0 ~ "Name: " name { found = 1 }
                found && /Description:/ {
                    sub(/^[^:]+: /, "", $0); print $0; exit
                }
            ')

            plugged_in=$(pactl list "${pactl_type}s" | awk -v name="$name" '
                $0 ~ "Name: " name { found = 1 }
                found && /Active Port:/ {
                    if (index($NF, "unplugged") > 0) print "Unplugged";
                    else print $NF;
                    exit
                }
            ')

            volume=$(pactl list "${pactl_type}s" | awk -v name="$name" '
                $0 ~ "Name: " name { found = 1 }
                found && /Volume:/ { print $5 " (" $7 ")"; exit }
            ')

            if [[ "$detailed" == "--detailed" ]]; then
                echo -e "${is_default}${id}\t$name\t[$description]\tPlugged: $plugged_in\tVolume: ${volume:-N/A}"
            else
                echo -e "${is_default}${id}\tPlugged: $description\tVolume: ${volume:-N/A}"
            fi
        done
    elif command -v wpctl &>/dev/null; then
        wpctl status | awk -v type="$type" '
            BEGIN { found = 0; }
            /Audio/{ found = 0; }
            /\* / { found = 1; }
            found && (type == "input" && /input/ || type == "output" && /output/) {
                gsub(/\* /, "*", $0);
                print NR-1, $0;
            }
        '
    else
        echo "Neither pactl nor wpctl found."
        exit 1
    fi
}

set_device() {
    local type=$1
    local target=$2
    local pactl_type=""
    local found_device=""

    if [[ "$type" == "input" ]]; then
        pactl_type="source"
    elif [[ "$type" == "output" ]]; then
        pactl_type="sink"
    else
        echo "Invalid type: use 'input' or 'output'"
        exit 1
    fi

    if command -v pactl &>/dev/null; then
        found_device=$(pactl list short "${pactl_type}s" | awk -v target="$target" '
            $1 == target || index($2, target) > 0 { print $1; exit; }
        ')

        if [[ -n "$found_device" ]]; then
            if [[ "$pactl_type" == "sink" ]]; then
                pactl set-default-sink "$found_device"
            else
                pactl set-default-source "$found_device"
            fi
            echo "Set default $type to $found_device"
        else
            echo "No matching device found for '$target'"
            exit 1
        fi
    elif command -v wpctl &>/dev/null; then
        found_device=$(wpctl status | awk -v type="$type" -v target="$target" '
            /Audio/{ found = 0; }
            /\* / { found = 1; }
            found && (type == "input" && /input/ || type == "output" && /output/) {
                gsub(/\* /, "", $0);
                if ($1 == target || index($0, target) > 0) {
                    print $1;
                    exit;
                }
            }
        ')

        if [[ -n "$found_device" ]]; then
            wpctl set-default "$found_device"
            echo "Set default $type to $found_device"
        else
            echo "No matching device found for '$target'"
            exit 1
        fi
    else
        echo "Neither pactl nor wpctl found."
        exit 1
    fi
}

if [[ "$1" == "list" ]]; then
    if [[ "$2" == "input" || "$2" == "output" ]]; then
        list_devices "$2" "$3"
    else
        echo "Usage: $0 list [input|output] [--detailed]"
        exit 1
    fi
elif [[ "$1" == "set" ]]; then
    if [[ "$2" == "input" || "$2" == "output" ]] && [[ -n "$3" ]]; then
        set_device "$2" "$3"
    else
        echo "Usage: $0 set [input|output] <id_or_name>"
        exit 1
    fi
else
    echo "Usage:"
    echo "  $0 list [input|output] [--detailed]   # List active sound inputs or outputs"
    echo "  $0 set [input|output] <id_or_name>    # Set default input or output"
    exit 1
fi
