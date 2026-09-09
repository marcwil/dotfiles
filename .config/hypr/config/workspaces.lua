-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
--
-- i3-style model:
--   * one global pool of numbered workspaces; each lives on exactly one monitor
--   * Super + N          -> go to workspace N wherever it is (a new one is born on the
--                           monitor you're focused on)
--   * Super + Alt + N    -> pull workspace N onto the monitor you're focused on
--   * Super + Shift + N  -> send the focused window to workspace N
--   * Super + Ctrl + 1/2         -> focus prev/next monitor
--   * Super + Ctrl + Shift + 1/2 -> move the window to prev/next monitor
--   * Super + Ctrl + Alt + 1/2   -> move the whole workspace to prev/next monitor
--
-- Workspaces 1-3 are pinned to the built-in panel (eDP-1). That connector never changes
-- on a laptop, so this is safe and it's the one anchor that makes dock/undock predictable:
-- 1-3 always come back to the laptop screen. Everything else (4+) is dynamic and lands on
-- whatever monitor you create it on - habit becomes "low numbers = laptop, higher = external".

hl.workspace_rule({ workspace = "1", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1", persistent = true, layout = "scrolling" })

-- Per-workspace layout example (see the scrolling / master layout pages):
-- hl.workspace_rule({ workspace = "4", layout = "master" })
