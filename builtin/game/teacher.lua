local function revokePriv(playerName)
  local grant = core.string_to_privs(core.settings:get("default_privs") or "interact,shout")
  core.set_player_privs(playerName, grant)
end

core.register_on_joinplayer(function(player)
  local playerName = player:get_player_name()
  local is_singleplayer = core.is_singleplayer()
  if is_singleplayer then
    local is_teacher = core.settings:get_bool("is_teacher", false)
    if not is_teacher then
      revokePriv(playerName)
    end
  end
end)