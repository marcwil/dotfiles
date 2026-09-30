-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Layouts are remembered per *combination* of connected screens instead of
-- being hardcoded here (different desks, different monitors every day):
--   1. arrange the screens at runtime (e.g. wdisplays)
--   2. SUPER + ALT + M saves the live layout for the current combination
--      (until saved, a wdisplays change is temporary: any reload or rule
--      re-apply reverts it)
--   3. on every config load and hotplug, the saved layout for whatever is
--      connected gets re-applied
-- Combinations never saved fall back to defaults (see default_scale).
-- Saved profiles live outside the dotfiles, in ~/.local/state/hypr/.
--
-- Two facts this relies on (verified with `hyprctl eval`):
--  * every config reload starts a fresh Lua state, so the hl.on handlers
--    below are re-registered, never stacked
--  * hl.monitor() applies immediately when called at runtime, so hotplug
--    needs no config reload

local state_dir    = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"
local profile_file = state_dir .. "/monitor-profiles.lua"

-- Catch-all, so a brand-new screen gets something sane in the moment before
-- apply_profile() runs.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })

local function load_profiles()
    local chunk = loadfile(profile_file)
    if not chunk then return {} end
    local ok, profiles = pcall(chunk)
    return (ok and type(profiles) == "table") and profiles or {}
end

-- Order-independent: the same screens give the same key whichever port they're on
local function combo_key(monitors)
    local descs = {}
    for _, m in ipairs(monitors) do descs[#descs + 1] = m.description end
    table.sort(descs)
    return table.concat(descs, " | ")
end

-- Laptop panel 1.33; external monitors 1 unless they are 4K-wide
local function default_scale(m)
    if m.name:match("^eDP") or m.width >= 3840 then return "1.25" end
    return "1"
end

-- A screen saved in some other combination keeps its scale in a new one
local function remembered_scale(profiles, desc)
    for _, rules in pairs(profiles) do
        for _, r in ipairs(rules) do
            if r.desc == desc then return r.scale end
        end
    end
end

local function apply_profile()
    local monitors = hl.get_monitors()
    if #monitors == 0 then return end
    local profiles = load_profiles()

    local rules = profiles[combo_key(monitors)]
    if rules then
        for _, r in ipairs(rules) do
            hl.monitor({ output = "desc:" .. r.desc, mode = r.mode, position = r.position,
                         scale = r.scale, transform = r.transform })
        end
        return
    end

    for _, m in ipairs(monitors) do
        hl.monitor({ output = "desc:" .. m.description, mode = "preferred", position = "auto",
                     scale = remembered_scale(profiles, m.description) or default_scale(m) })
    end
end

local function write_profiles(profiles)
    local keys = {}
    for key in pairs(profiles) do keys[#keys + 1] = key end
    table.sort(keys)  -- stable file, readable diffs

    local out = { "-- Written by SUPER + ALT + M (hypr/config/monitors.lua). Safe to edit or delete.\nreturn {\n" }
    for _, key in ipairs(keys) do
        out[#out + 1] = string.format("  [%q] = {\n", key)
        for _, r in ipairs(profiles[key]) do
            out[#out + 1] = string.format(
                "    { desc = %q, mode = %q, position = %q, scale = %q, transform = %d },\n",
                r.desc, r.mode, r.position, r.scale, r.transform)
        end
        out[#out + 1] = "  },\n"
    end
    out[#out + 1] = "}\n"

    os.execute("mkdir -p '" .. state_dir .. "'")
    local f = io.open(profile_file, "w")
    if not f then return false end
    f:write(table.concat(out))
    f:close()
    return true
end

local function save_profile()
    local monitors = hl.get_monitors()
    local rules = {}
    for _, m in ipairs(monitors) do
        rules[#rules + 1] = {
            desc      = m.description,
            mode      = string.format("%dx%d@%.3f", m.width, m.height, m.refresh_rate),
            position  = string.format("%dx%d", m.x, m.y),
            -- full precision on purpose: a rounded 1.3333 isn't a clean divisor
            -- of the resolution, which Hyprland rejects
            scale     = tostring(m.scale),
            transform = m.transform,
        }
    end

    local profiles = load_profiles()
    profiles[combo_key(monitors)] = rules
    local ok = write_profiles(profiles)
    -- Register the saved layout as Hyprland's monitor rules right away. Until
    -- then the rules are still whatever the last load produced (e.g. fallback
    -- "auto" positions), and anything that makes Hyprland re-apply its rules
    -- (like a runtime workspace_rule from layout-switch.sh) would snap back to
    -- those. No visible change: the rules match what's on screen.
    apply_profile()
    hl.notification.create({
        text     = ok and ("Monitor layout saved for " .. #monitors .. " screen(s)")
                      or ("Could not write " .. profile_file),
        duration = 3000,
    })
end

apply_profile()

-- Deferred a moment so the monitor list has settled (a removed screen may
-- still be listed while its own event fires).
local function apply_soon()
    hl.timer(apply_profile, { timeout = 250, type = "oneshot" })
end
hl.on("monitor.added",   apply_soon)
hl.on("monitor.removed", apply_soon)

hl.bind("SUPER + ALT + M", save_profile)
