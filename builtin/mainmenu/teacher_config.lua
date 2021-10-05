local clientmod_path = core.get_clientmodpath()

local settings = Settings(clientmod_path .. DIR_DELIM .. "teacher", true)

function getTeacherConf(key, default, type)
  if type == 'bool' then
    return settings:get_bool(key, default)
  else
    return settings:get(key) or default
  end
end

function setTeacherConf(key, value, type)
  if value == nil then settings:remove(key) end
  if type == 'bool' then
    settings:set_bool(key, value)
  else
    settings:set(key, value)
  end
  settings:write()
end

function getTeacherPasswd()
  local vPassword = settings:get("teacher_pass") or "Nzc4ODk5"
  return vPassword
end

function setTeacherPasswd(pass)
  if pass and pass ~= '' then
    settings:set("teacher_pass", pass)
  else
    settings:remove('teacher_pass')
  end
  settings:write()
end

function getPasswd(name)
  local vPassword = settings:get(name .. ".pass")
  return vPassword
end

function setPasswd(name, pass)
  if pass and pass ~= '' then
    settings:set(name .. ".pass", pass)
  else
    settings:remove(name .. ".pass")
  end
  settings:write()
end
