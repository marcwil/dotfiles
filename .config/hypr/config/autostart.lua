-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    -- hl.exec_cmd("noctalia")  -- now ~/.config/systemd/user/noctalia.service (auto-restart + journal logs)
    hl.exec_cmd("xhost +SI:localuser:root")
    -- kwalletd6/ksecretd: unlocked via ~/.config/systemd/user/kwallet-pam-unlock.service, otherwise D-Bus activated
    -- nextcloud: XDG autostart (~/.config/autostart/Nextcloud.desktop), ordered after the kwallet unlock
end)
