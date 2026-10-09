-- Modal keymaps (Hyprland submaps), like awesome's modal keygrabbers: enter a
-- mode with a Super combo, then use bare keys. While a mode is active its hint
-- text is shown as a notification.
--
--   local modal = require("lib.modalmap")
--
--   modal.mode(name, opts)     general mode
--       opts.key    global entry key (optional; omit for modes that are only
--                   reachable from another mode, see modal.enter)
--       opts.hint   hint text, or a function returning it (called on entry)
--       opts.binds  function doing the hl.bind calls for the mode's keys
--       opts.leave  keys that leave the mode (default { "Escape", "Space" })
--
--   modal.oneshot(name, opts)  each key runs one action and leaves the mode
--       opts.key, opts.title
--       opts.entries  { { key, label, action }, ... }; the hint is generated
--                     from them, with modifiers shown as symbols (SHIFT + W -> ⇧W)
--       opts.active   function returning the key of the entry to mark with ●
--                     in the hint (optional; called on entry)
--     action is a shell command string, a Lua function, or modal.enter(other).
--
--   modal.enter(name)          action: switch straight to another mode

local M = {}

local hints = {}  -- mode name -> hint string or function

local mod_symbols = { SHIFT = "⇧", CTRL = "⌃", CONTROL = "⌃", ALT = "⌥" }

local function shown_key(key)
    return (key:gsub("(%u+)%s*%+%s*", function(mod) return mod_symbols[mod] end))
end

local function is_enter(action)
    return type(action) == "table" and action.enter ~= nil
end

function M.enter(name)
    return { enter = name }
end

function M.mode(name, opts)
    hints[name] = opts.hint
    if opts.key then hl.bind(opts.key, hl.dsp.submap(name)) end
    hl.define_submap(name, function()
        if opts.binds then opts.binds() end
        for _, key in ipairs(opts.leave or { "Escape", "Space" }) do
            hl.bind(key, hl.dsp.submap("reset"))
        end
    end)
end

function M.oneshot(name, opts)
    for _, e in ipairs(opts.entries) do
        local a = e[3]
        assert(type(a) == "string" or type(a) == "function" or is_enter(a),
            "modalmap: mode '" .. name .. "', key '" .. e[1] .. "': action must be a "
            .. "command string, a function or modal.enter(...)")
    end

    local function hint(marked)
        local lines = { "-- " .. opts.title .. " --" }
        for _, e in ipairs(opts.entries) do
            local shown = shown_key(e[1])  -- pad by characters, not bytes (⇧ is 3 bytes)
            local line = shown .. string.rep(" ", 7 - utf8.len(shown)) .. e[2]
            if e[1] == marked then line = line .. "  ●" end
            lines[#lines + 1] = line
        end
        lines[#lines + 1] = "Esc/␣  leave"
        return table.concat(lines, "\n")
    end

    M.mode(name, {
        key  = opts.key,
        hint = opts.active and function() return hint(opts.active()) end or hint(),
        binds = function()
            for _, e in ipairs(opts.entries) do
                local action = e[3]
                hl.bind(e[1], function()
                    if is_enter(action) then
                        hl.dispatch(hl.dsp.submap(action.enter))
                        return
                    end
                    -- leave first, so a failing action can't strand us in the mode
                    hl.dispatch(hl.dsp.submap("reset"))
                    if type(action) == "string" then
                        hl.dispatch(hl.dsp.exec_cmd(action))
                    else
                        action()
                    end
                end)
            end
        end,
    })
end

-- Show the active mode's hint; drop it when the mode changes or ends. Registered
-- once per Lua state (require caches the module, and a config reload starts a
-- fresh state).
local note
hl.on("keybinds.submap", function()
    if note then
        note:dismiss()
        note = nil
    end
    local hint = hints[hl.get_current_submap()]
    if type(hint) == "function" then hint = hint() end
    if hint then
        note = hl.notification.create({ text = hint, timeout = 600000 })
    end
end)

return M
