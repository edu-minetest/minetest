local function enable_mods(worldname, mods, enabled)
  if enabled ~= false then enabled = true end
  local worldidx = menudata.worldlist:raw_index_by_uid(worldname)
  if worldidx > 0 then
    local worldspec = core.get_worlds()[worldidx]
    if worldspec then
      local filename = worldspec.path .. DIR_DELIM .. "world.mt"
      local worldfile = Settings(filename)
      for _, mod in ipairs(mods) do
        enabled = enabled and "true" or "false"
        worldfile:set("load_mod_" .. mod, enabled)
        core.log("info", "enable default mod:"..mod.." ".. enabled)
      end
      worldfile:write()
      return true, worldidx
    end
  end
end

return enable_mods
