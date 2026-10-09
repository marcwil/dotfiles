local mainMod = "SUPER"
local noctCall = "noctalia msg "
local launchPrefix = "uwsm app -- " -- if you are not using UWSM, make this empty (e.g. "")
local modal = require("lib.modalmap")

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- Window manipulation
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("hyprctl kill"))  -- arms click-to-kill mode
hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + CONTROL + Space", hl.dsp.window.float({ action = "toggle" }))
-- Super+M: "smart maximize". On the scrolling layout, real maximize hides the
-- tape, so instead widen the column to the full viewport (colresize 1.0) and
-- toggle back to the column's previous width on the next press. Elsewhere (and
-- for floating windows) it's the normal maximize toggle. Super+Shift+M = always
-- the real maximize.
local prev_col_width = {}  -- window address -> width fraction before widening
local function smart_maximize()
    local w = hl.get_active_window()
    local ws = hl.get_active_workspace()
    if not w or not ws or ws.tiled_layout ~= "scrolling" or w.floating then
        hl.dispatch(hl.dsp.window.fullscreen({ mode = 1 }))
        return
    end
    local mon = hl.get_active_monitor()
    local prev = prev_col_width[w.address]
    if prev then
        prev_col_width[w.address] = nil
        hl.dispatch(hl.dsp.layout("colresize " .. prev))
    else
        -- remember current width as a fraction of the monitor's logical width
        local frac = 0.5
        if mon and mon.width and mon.scale then
            frac = math.min(1, w.size.x / (mon.width / mon.scale))
        end
        prev_col_width[w.address] = string.format("%.3f", frac)
        hl.dispatch(hl.dsp.layout("colresize 1.0"))
    end
end
hl.bind(mainMod .. " + M",           smart_maximize)
hl.bind(mainMod .. " + SHIFT + M",   hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen())
-- Super+J: layout-aware "rearrange". Dwindle flips the split direction; master
-- swaps the focused window with the master (awesome's Mod+Ctrl+Return).
local function smart_rearrange()
    local ws = hl.get_active_workspace()
    if ws and ws.tiled_layout == "master" then
        hl.dispatch(hl.dsp.layout("swapwithmaster"))
    elseif ws and ws.tiled_layout == "dwindle" then
        hl.dispatch(hl.dsp.layout("togglesplit"))
    end
    -- scrolling (or any other layout): do nothing
end
hl.bind(mainMod .. " + J",           smart_rearrange)

-- Change focus
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))
-- Neo layer-4 arrow cluster (i/l/a/e), Shift moves the window. Bound by keysym,
-- so these only exist under neo: by keycode they'd land on S/F in de/us and
-- collide with the scratchpad and fullscreen binds.
local neoArrows = { I = "left", L = "up", A = "down", E = "right" }
for key, dir in pairs(neoArrows) do
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ direction = dir }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir:sub(1, 1) }))
end
hl.bind("ALT + Tab",           hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + Tab",   hl.dsp.exec_cmd(noctCall .. "window-switcher"))

-- Move active window around workspaces & monitors
hl.bind(mainMod .. " + SHIFT + Up",                   hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + Right",                hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + Left",                 hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + Down",                 hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + O",                            hl.dsp.window.move({ monitor = "+1" }))  -- window -> next monitor
hl.bind(mainMod .. " + SHIFT + O",                    hl.dsp.window.move({ monitor = "-1" }))  -- window -> prev monitor
hl.bind(mainMod .. " + SHIFT + mouse_up",             hl.dsp.window.move({ monitor   = "-1" }))
hl.bind(mainMod .. " + SHIFT + mouse_down",           hl.dsp.window.move({ monitor   = "+1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Right",      hl.dsp.window.move({ workspace = "m+1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + Left",       hl.dsp.window.move({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "m+1" }))
for i = 1, NUM_WPM do
    local key = i % 10
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Move & Resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Zoom
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 3.0 then
        hl.config({ cursor = { zoom_factor = 3.0 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
--hl.bind(mainMod .. " + Minus", function() zoomfunction(-0.3) end, { repeating = true})
--hl.bind(mainMod .. " + Plus", function() zoomfunction(0.3) end, { repeating = true })

--# Zoom with keypad
hl.bind(mainMod .. " + code:82", function() zoomfunction(-0.3) end, { repeating = true })
hl.bind(mainMod .. " + code:86", function() zoomfunction(0.3) end, { repeating = true })


------------------
---- LAUNCHER ----
------------------

-- Only the everyday ones are direct binds; the rest live in the app mode
-- (Super+X) and noctalia mode (Super+C), see MODES below.
hl.bind(mainMod .. " + Return",     hl.dsp.exec_cmd(launchPrefix .. TERMINAL))
hl.bind("XF86Calculator",           hl.dsp.exec_cmd(launchPrefix .. CALCULATOR))
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"))
hl.bind(mainMod .. " + Space",      hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"))
-- Lenovo BT keyboard's lock key: keyd turns its ⊞+L combo into XF86ScreenSaver
-- (/etc/keyd/lenovo-bt.conf). Bound with and without Super in case the modifier
-- is still held when the key arrives.
hl.bind("XF86ScreenSaver",                 hl.dsp.exec_cmd(noctCall .. "session lock"))
hl.bind(mainMod .. " + XF86ScreenSaver",   hl.dsp.exec_cmd(noctCall .. "session lock"))
-- Laptop keyboard: the hang-up key (XF86HangupPhone) doubles as a one-key lock.
hl.bind("XF86HangupPhone",                 hl.dsp.exec_cmd(noctCall .. "session lock"))

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctCall .. "volume-up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctCall .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(noctCall .. "volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(noctCall .. "mic-mute"),    { locked = true })

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(noctCall .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctCall .. "media toggle"),   { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(noctCall .. "media next"),     { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(noctCall .. "media previous"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(noctCall .. "brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctCall .. "brightness-down"), { locked = true, repeating = true })

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture
hl.bind(mainMod .. " + P",     hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind("Print",               hl.dsp.exec_cmd(noctCall .. "screenshot-region"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen"))

-------------------------------
---- WORKSPACES & MONITORS ----
-------------------------------

-- Focus on monitors (relative: cycles through however many are connected)
hl.bind(mainMod .. " + CONTROL + J", hl.dsp.focus({ monitor = "+1" }))  -- focus next monitor
hl.bind(mainMod .. " + CONTROL + K", hl.dsp.focus({ monitor = "-1" }))  -- focus prev monitor

-- Move the whole current workspace to the other monitor (i3 "move workspace to output")
hl.bind(mainMod .. " + CONTROL + O",         hl.dsp.workspace.move({ monitor = "+1" }))  -- workspace -> next monitor
hl.bind(mainMod .. " + CONTROL + SHIFT + O", hl.dsp.workspace.move({ monitor = "-1" }))  -- workspace -> prev monitor

-- Focus on workspace number (i3 model)
-- Super + number: go to workspace N. It shows on whichever monitor it lives on (focus
--   follows there). A workspace that doesn't exist yet is created on the focused monitor.
for i = 1, NUM_WPM do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
end
-- Super + Alt + number: pull workspace N onto the monitor you're focused on (escape hatch
--   for "I want it *here*, not where it currently is")
for i = 1, NUM_WPM do
    local key = i % 10
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.focus({ workspace = i, on_current_monitor = true }))
end

-- Move to adjacent workspaces and next empty on a given monitor
hl.bind(mainMod .. " + CONTROL + Right",       hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + CONTROL + Left",        hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + Down",        hl.dsp.focus({ workspace = "emptym" }))

-- Back to the workspace you came from (awesome's tag-history restore).
hl.bind(mainMod .. " + Escape", hl.dsp.focus({ workspace = "previous" }))

-- Scroll through existing workspaces & monitors
hl.bind(mainMod .. " + mouse_down",           hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + mouse_up",             hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + CONTROL + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + CONTROL + mouse_down", hl.dsp.focus({ workspace = "m+1" }))

-- Scroll the tape one column at a time (scrolling layout only; no-op elsewhere)
hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + ALT + mouse_up",   hl.dsp.layout("move +col"))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special())

-- Per-workspace "minimize" stash
-- Each normal workspace N has a companion special workspace `special:minN`,
-- created lazily on first use. The target is resolved when the key is pressed,
-- so one set of keys serves every workspace.
--
-- Done in Lua on purpose: `hyprctl dispatch` is evaluated as Lua by this config
-- parser, so a shell script calling `hyprctl dispatch movetoworkspacesilent ...`
-- fails silently (same family as `hyprctl keyword` not working here).
local function stash_target()
    local ws = hl.get_active_workspace()  -- stays the NORMAL ws even while a special is shown
    if not ws or ws.special then return nil, nil end
    return "special:min" .. ws.id, ws.id
end

local function stash_window()
    local name = stash_target()
    if not name then return end
    -- follow = false keeps focus here instead of chasing the window into the stash
    hl.dispatch(hl.dsp.window.move({ workspace = name, follow = false }))
end

local function restore_window()
    local name, id = stash_target()
    if not name then return end
    local best
    for _, w in ipairs(hl.get_workspace_windows(name) or {}) do
        -- lowest focus_history_id = most recently focused = last one stashed
        if not best or w.focus_history_id < best.focus_history_id then best = w end
    end
    if not best then return end
    -- window.move takes no target-window option (passing one silently no-ops),
    -- so focus it first and move it as the active window. That makes the focus
    -- step load-bearing: if it ever fails, an unguarded move would drag whatever
    -- IS active out of the stash instead. So confirm the target actually took
    -- focus, and only then move it.
    local function focused_is_target()
        local a = hl.get_active_window()
        return a ~= nil and a.address == best.address
    end
    hl.dispatch(hl.dsp.focus({ window = best }))
    if not focused_is_target() then
        -- Fallback: surface the stash, which makes its windows focusable, retry.
        hl.dispatch(hl.dsp.workspace.toggle_special("min" .. id))
        hl.dispatch(hl.dsp.focus({ window = best }))
        if not focused_is_target() then return end  -- give up rather than move the wrong window
    end
    hl.dispatch(hl.dsp.window.move({ workspace = id }))
end

local function peek_stash()
    local ws = hl.get_active_workspace()
    if not ws or ws.special then return end
    hl.dispatch(hl.dsp.workspace.toggle_special("min" .. ws.id))  -- name, no "special:" prefix
end

hl.bind(mainMod .. " + N",           stash_window)    -- hide the active window
hl.bind(mainMod .. " + CONTROL + N", restore_window)  -- bring back the last one
hl.bind(mainMod .. " + SHIFT + N",   peek_stash)      -- peek at the stash

hl.bind(mainMod .. " + code:49", hl.dsp.exec_cmd("kitten quick-access-terminal"))

-------------------------
---- MODES (SUBMAPS) ----
-------------------------

-- Modal keymaps, like awesome's modal keygrabbers. The mechanism (hint
-- notifications, leave keys, one-shot entries) is in lib/modalmap.lua; this
-- section only defines the modes.

local function is_master()
    local ws = hl.get_active_workspace()
    return ws and ws.tiled_layout == "master"
end

-- Run the master layoutmsg on master workspaces, otherwise resize the focused
-- window by (dx, dy) pixels.
local function master_or_resize(msg, dx, dy)
    return function()
        if is_master() then
            hl.dispatch(hl.dsp.layout(msg))
        else
            hl.dispatch(hl.dsp.window.resize({ x = dx, y = dy, relative = true }))
        end
    end
end

-- Super+V: layout mode. Master: mfact/nmaster/orientation. Elsewhere (dwindle,
-- scrolling): the arrows resize the focused window.
local function layout_hint()
    if is_master() then
        return table.concat({
            "-- LAYOUT (master) --",
            "←/→  master width -/+",
            "↑/↓  masters +/-",
            "J    swap with master",
            "O    cycle master orientation",
            "Esc/␣ leave",
        }, "\n")
    end
    return table.concat({
        "-- LAYOUT (resize) --",
        "←/→  narrower / wider",
        "↑/↓  shorter / taller",
        "J    toggle split",
        "Esc/␣ leave",
    }, "\n")
end

local step = 40  -- px per resize keypress
modal.mode("layout", {
    key   = mainMod .. " + V",
    hint  = layout_hint,
    leave = { "Escape", "Return", "Space" },
    binds = function()
        -- Each direction also on its Neo2 home-row key (i/e/l/a = left/right/up/
        -- down), bound by keycode (QWERTZ s/f/e/d) so it works in every xkb layout.
        local dirs = {
            { keys = { "Left",  "code:39" }, fn = master_or_resize("mfact -0.05",  -step, 0) },
            { keys = { "Right", "code:41" }, fn = master_or_resize("mfact +0.05",   step, 0) },
            { keys = { "Up",    "code:26" }, fn = master_or_resize("addmaster",     0, -step) },
            { keys = { "Down",  "code:40" }, fn = master_or_resize("removemaster",  0,  step) },
        }
        for _, d in ipairs(dirs) do
            for _, key in ipairs(d.keys) do
                hl.bind(key, d.fn, { repeating = true })
            end
        end
        hl.bind("J", smart_rearrange)
        hl.bind("O", hl.dsp.layout("orientationcycle"))
    end,
})

-- One-shot modes: each key runs its action and leaves the mode right away.
-- Keys are bound by keysym (mnemonic letters follow the active xkb layout).

-- Super+Shift+V: pick the current workspace's layout (Super+V tunes it).
-- Runtime only: workspaces.lua is re-applied on every config reload, which
-- discards a pick made here.
local layout_key = { dwindle = "1", master = "2", scrolling = "3" }
local function set_layout(name)
    return function()
        local ws = hl.get_active_workspace()  -- stays the NORMAL ws even while a special is shown
        if not ws or ws.special then return end
        -- only workspace + layout: rules merge, so monitor/persistent pinning is kept
        hl.workspace_rule({ workspace = tostring(ws.id), layout = name })
    end
end
modal.oneshot("layoutpick", {
    key    = mainMod .. " + SHIFT + V",
    title  = "PICK LAYOUT",
    active = function()
        local ws = hl.get_active_workspace()
        return ws and layout_key[ws.tiled_layout]
    end,
    entries = {
        { "1", "dwindle",   set_layout("dwindle") },
        { "2", "master",    set_layout("master") },
        { "3", "scrolling", set_layout("scrolling") },
    },
})

-- Super+X: app mode
modal.oneshot("apps", {
    key   = mainMod .. " + X",
    title = "APPS",
    entries = {
        { "Return",    "terminal",    launchPrefix .. TERMINAL },
        { "E",         "files",       launchPrefix .. FILE_MANAGER },
        { "F",         "Firefox",     launchPrefix .. BROWSER },
        { "T",         "editor",      launchPrefix .. EDITOR },
        { "C",         "calculator",  launchPrefix .. CALCULATOR },
        { "K",         "keepassxc",   launchPrefix .. PASSWORDS },
        { "D",         "discord",     launchPrefix .. CHAT },
        { "M",         "thunderbird", launchPrefix .. MAIL },
        { "S",         "signal",      launchPrefix .. SIGNAL },
        { "SHIFT + T", "telegram",    launchPrefix .. TELEGRAM },
        { "L",         "slack",       launchPrefix .. SLACK },
        { "SHIFT + S", "steam",       launchPrefix .. STEAM },
        { "B",         "btop",        launchPrefix .. TERMINAL .. " -e btop" },
    },
})

-- Super+C: noctalia mode
modal.oneshot("noctalia", {
    key   = mainMod .. " + C",
    title = "NOCTALIA",
    entries = {
        { "C",         "control center", noctCall .. "panel-toggle control-center" },
        { "A",         "audio",          noctCall .. "panel-toggle control-center audio" },
        { "D",         "displays",       noctCall .. "panel-toggle control-center monitor" },
        { "W",         "wifi",           noctCall .. "panel-toggle control-center network" },
        { "B",         "bluetooth",      noctCall .. "panel-toggle control-center bluetooth" },
        { "N",         "notifications",  noctCall .. "panel-toggle control-center notifications" },
        { "S",         "settings",       noctCall .. "settings-toggle" },
        { "V",         "clipboard",      noctCall .. "panel-toggle clipboard" },
        { "SHIFT + W", "wallpaper",      noctCall .. "panel-toggle wallpaper" },
        { "E",         "emoji",          noctCall .. "panel-toggle launcher /emo" },
        { "P",         "power profile",  modal.enter("power") },
        { "X",         "session",        noctCall .. "panel-toggle session" },
    },
})

-- Power profile mode, entered from noctalia mode (P). power-profiles-daemon
-- drives the ACPI platform profile, so sysfs says which one is active without
-- a D-Bus round-trip; map it back to this mode's key for the hint marker.
local platform_profile_key = { ["low-power"] = "1", balanced = "2", performance = "3" }
local function active_power_key()
    local f = io.open("/sys/firmware/acpi/platform_profile")
    if not f then return nil end
    local p = f:read("l")
    f:close()
    return platform_profile_key[p]
end
modal.oneshot("power", {
    title  = "POWER PROFILE",
    active = active_power_key,
    entries = {
        { "1", "power saver", noctCall .. "power-set power-saver" },
        { "2", "balanced",    noctCall .. "power-set balanced" },
        { "3", "performance", noctCall .. "power-set performance" },
    },
})

-- Cycle keyboard layouts (neo -> de -> us). Bound by keycode, not keysym: the
-- key right of Ü produces a different symbol in each layout, so a keysym bind
-- would stop working as soon as it switched away from the layout it matched.
-- code:35 = xkb keycode (evdev KEY_RIGHTBRACE 27 + 8).
hl.bind(mainMod .. " + code:35", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
