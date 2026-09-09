-- Input configuration

hl.config({
    input = {
        sensitivity = 0.15,
        accel_profile = "adaptive",
	kb_layout = "de,de,us",
	kb_variant = "neo,,",
	kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        emulate_discrete_scroll = 2,  -- make trackpoint / touchpad scroll drive scroll binds like a real wheel (0 off, 1 non-standard only, 2 all)
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            tap_and_drag = true,
            drag_lock = true,
            disable_while_typing = true,
            clickfinger_behavior = true,  -- 1/2/3-finger click = left/right/middle (set false for a bottom-right corner right-click zone instead)
            -- scroll_factor = 0.6,       -- uncomment and tune if two-finger scroll feels too fast
        },
    },
    -- Software cursors — hardware cursor plane fails to come back after hyprlock/unlock
    -- on this Intel GPU (aquamarine "atomic drm request: Device or resource busy"),
    -- leaving the pointer invisible. Software cursors avoid that.
    cursor = {
        no_hardware_cursors = 1,
    },
})

hl.device({
    name        = "tpps/2-elan-trackpoint",
    sensitivity = 0.6,   -- pick an absolute value: per-device sensitivity REPLACES the
                         -- global for this device, it does not add to it
})


hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

-- 3 fingers (any direction) = move the focused window; SUPER + 3 fingers = resize it
hl.gesture({ fingers = 3, direction = "swipe",                 action = "move" })
hl.gesture({ fingers = 3, direction = "swipe", mods = "SUPER", action = "resize" })

-- SUPER + 4 fingers horizontal = scroll the tape (scrolling layout only; no-op elsewhere)
hl.gesture({ fingers = 4, direction = "horizontal", mods = "SUPER", action = "scroll_move" })

-- Old 3-finger gestures — commented out, they conflicted with move/resize above.
-- Equivalent keybinds still exist: Super+Q (close), Super+F (fullscreen), Super+Alt+Space (float).
-- hl.gesture({ fingers = 3, direction = "down",       action = "close" })
-- hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
-- hl.gesture({ fingers = 3, direction = "left",       action = "float" })
