local wezterm = require 'wezterm'
local config = wezterm.config_builder()

--------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------
-- rose-pine-moon renders ANSI blue as a pale pastel and ANSI cyan as
-- pink. Override those slots with vivid iTerm-style cyans so `ls`
-- directories and the prompt pop, keeping the rest of the scheme.
local scheme = wezterm.color.get_builtin_schemes()['rose-pine-moon']
scheme.ansi[5]    = '#3fc5da' -- blue (what `ls` uses for directories)
scheme.ansi[7]    = '#4dd0e1' -- cyan (prompt, etc.)
scheme.brights[5] = '#67d9ec' -- bright blue
scheme.brights[7] = '#7ee8f6' -- bright cyan
-- rose-pine-moon's default selection_bg is a low-contrast overlay that all
-- but vanishes over the 0.8-opacity translucent window, so highlighted text
-- looks unselected even though it copies fine. Use an on-theme iris highlight
-- with dark text so selections are clearly visible. Tweak the hex to taste.
scheme.selection_fg = '#232136' -- base background color, used as selected-text color
scheme.selection_bg = '#c4a7e7' -- iris (vivid lavender, distinct from the cyans above)
config.color_schemes = { ['rose-pine-moon'] = scheme }
config.color_scheme = 'rose-pine-moon'
config.font = wezterm.font 'Hack Nerd Font'
config.font_size = 20.0
config.window_background_opacity = 0.80
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'

-- Use macOS native fullscreen (own Space, green-button style).
-- Set to false for WezTerm's faster non-native fullscreen.
config.native_macos_fullscreen_mode = true

-- Auto-unzoom when Cmd+Arrowing to another pane while zoomed
config.unzoom_on_switch_pane = true

--------------------------------------------------------------------
-- Keys
--------------------------------------------------------------------
config.keys = {
  -- Cmd+D: horizontal split (new pane to the right)
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },

  -- Cmd+Shift+D: vertical split (new pane below)
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },

  -- Cmd+W: close the current pane
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },

  -- CMD SHIFT N: open a new window
  {
    key = 'N',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },

  -- Cmd+Arrows: move focus between panes
  { key = 'LeftArrow',  mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Down' },

-- Cmd+Enter: toggle maximize/restore (no macOS fullscreen)
  {
    key = 'Enter',
    mods = 'CMD',
    action = wezterm.action_callback(function(window, pane)
      wezterm.GLOBAL.maximized = wezterm.GLOBAL.maximized or {}
      local id = tostring(window:window_id())
      if wezterm.GLOBAL.maximized[id] then
        window:restore()
        wezterm.GLOBAL.maximized[id] = false
      else
        window:maximize()
        wezterm.GLOBAL.maximized[id] = true
      end
    end),
  },

  -- Cmd+Shift+Enter: zoom current pane to fill the tab (toggle)
  {
    key = 'Enter',
    mods = 'CMD|SHIFT',
    action = wezterm.action.TogglePaneZoomState,
  },

  -- Cmd+K: clear scrollback and screen
  {
    key = 'k',
    mods = 'CMD',
    action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
  },

  -- Opt+Left/Right: jump between words (iTerm-style natural editing)
  { key = 'LeftArrow',  mods = 'OPT', action = wezterm.action.SendString '\x1bb' },
  { key = 'RightArrow', mods = 'OPT', action = wezterm.action.SendString '\x1bf' },
}


--------------------------------------------------------------------
-- Tab titles: show the current folder name instead of just "zsh"
--------------------------------------------------------------------
-- Bare shell names get replaced by the working directory. Claude Code
-- sets its own "✳ Claude Code" title, which hides which project the tab
-- is in — keep its status glyph but swap the name for the folder too.
-- Anything else a program sets (nvim, …) is kept as-is.
local SHELL_TITLES = { zsh = true, bash = true, ['-zsh'] = true, fish = true, [''] = true }

local function cwd_basename(pane)
  local cwd = pane.current_working_dir
  if not cwd then return nil end
  local path
  if type(cwd) == 'userdata' then
    path = cwd.file_path                              -- modern wezterm: Url object
  else
    path = tostring(cwd):gsub('^file://[^/]*', '')    -- legacy: "file://host/path"
  end
  if not path or path == '' then return nil end
  path = path:gsub('/+$', '')                          -- drop trailing slash
  if path == '' then return '/' end
  return path:match('[^/]+$')                          -- last path component
end

wezterm.on('format-tab-title', function(tab)
  local pane = tab.active_pane
  local title = pane.title

  if SHELL_TITLES[title] then
    title = cwd_basename(pane) or title
  else
    -- "✳ Claude Code" -> "✳ academyCRM" (glyph still reflects live status)
    local prefix = title:match('^(.-)Claude Code')
    if prefix then
      title = prefix .. (cwd_basename(pane) or 'Claude Code')
    end
  end

  return string.format(' %d: %s ', tab.tab_index + 1, title)
end)


return config
