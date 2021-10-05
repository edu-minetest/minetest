local menupath = core.get_mainmenu_path()
local default_mods = dofile(menupath .. DIR_DELIM .. "default_mods.lua")
local enable_mods = dofile(menupath .. DIR_DELIM .. "enable_mods.lua")

local function enable_default_mods(worldname, enabled)
  return enable_mods(worldname, default_mods, enabled)
end

return enable_default_mods
