-- align shortcuts
function IpeletByName(name)
   for _, ipelet in pairs(_G.ipelets) do
      if ipelet.name == name then
         return(ipelet)
      end
   end
end

IpeletByName("align").skip = 8.0
-- align top to bottom
shortcuts.ipelet_14_align = "Alt+Shift+T"
-- set skip
shortcuts.ipelet_19_align = "Alt+Shift+S"

-- custom settings
prefs.developer = true
prefs.auto_run_latex = true
prefs.trackpad_scroll.direction.x = -1
prefs.scroll.direction.x = -1
prefs.keyboard = "onboard &"
prefs.styles = { "basic", "kit-colors", "nicecolors" }

-- prefs.external_editor = "emacsclient -c %s"
-- prefs.external_editor = "emacs %s -f TeX-mode"
prefs.external_editor = "emacsclient -c -e '(progn (find-file \"%s\") (TeX-mode))'"
