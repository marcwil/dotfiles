# Run Ipe natively on Wayland at 1:1 physical pixels: Qt's pixel ratio is
# monitor scale × QT_SCALE_FACTOR, so a factor of 1/scale cancels it out.
# The scale is read once at launch from the focused monitor.
function ipe_scaled --wraps ipe
    set -l scale (hyprctl monitors -j | jq '.[] | select(.focused) | .scale')
    QT_SCALE_FACTOR=(math 1 / $scale) command ipe $argv
end
