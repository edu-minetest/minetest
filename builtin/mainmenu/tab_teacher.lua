--Minetest Edu
--Copyright (C) 2021 Riceball LEE(snowyu.lee@gmail.com)
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

local esc = core.formspec_escape
local escDefaultTexturedir = esc(defaulttexturedir)

local function indexOf(list, value)
  for i, v in ipairs(list) do
    if v == value then return i end
  end
end

local function loadTeacherSettings()
  local allowLocalPlay = getTeacherConf("teacher_allow_local_play", true, "bool")
  local allowRemotePlay = getTeacherConf("teacher_allow_remote_play", false, "bool")
  local teacherName = core.settings:get("teacher_name") or "teacher"
  local host = core.settings:get("teacher_host") or ""
  local port = core.settings:get("teacher_port") or "30000"
  local langs = core.settings:get("teacher_langs") or ",zh_CN,zh_TW,en"
  local lang = core.settings:get("language") or ""
  local langIndex = indexOf(string.split(langs, ","), lang)
  if langIndex == nil then
    if lang ~= "" then
      langs = langs .. "," .. lang
      langIndex = indexOf(string.split(langs, ","), lang)
    else
      langIndex = 1
    end
  end
  local password = getTeacherPasswd()

  return {
    allowLocalPlay = allowLocalPlay,
    allowRemotePlay = allowRemotePlay,
    teacherName = teacherName,
    password = password,
    host = host,
    port = port,
    langs = langs,
    lang = lang,
    langIndex = langIndex,
  }
end

local function saveTeacherSettings(fields)
  local settings = loadTeacherSettings()
  local v
  v = fields["allowLocalPlay"]
  if v ~= nil and v ~= settings.allowLocalPlay then
    setTeacherConf("teacher_allow_local_play", v, "bool")
  end

  v = fields["allowRemotePlay"]
  if v ~= nil and v ~= settings.allowRemotePlay then
    setTeacherConf("teacher_allow_remote_play", v, "bool")
  end

  v = fields["teacherName"]
  if v ~= nil and v ~= "" then
    gamedata.playername = v
    core.settings:set("teacher_name", v)
    core.settings:set("name", v)
  end
  v = fields["host"]
  if v ~= nil and v ~= settings.host then
    core.settings:set("teacher_host", v)
  end
  v = fields["port"]
  if v ~= nil and v ~= "" then
    core.settings:set("teacher_port", v)
  end
  v = fields["lang"]
  if v ~= nil and v ~= "" then
    core.settings:set("language", v)
  end
end

local currentSettings = loadTeacherSettings()

local function get_formspec(tabview, name, tabdata)
  local settings = loadTeacherSettings()
  -- local allowLocalPlay = core.settings:get_bool("allow_local_play", false)
  -- local teacherName = core.settings:get("teacher_name") or ""
  -- local host = core.settings:get("teacher_host") or ""
  -- local port = core.settings:get("teacher_port") or "30000"
  local langHint = fgettext("Set the language. Leave empty to use the system language.\nA restart is required after changing this."):gsub("\n", "")

  local retval =
    "field[0.1,0.5;3,0.6;teacherName;"..fgettext("Teacher Name") ..";".. esc(settings.teacherName) .."]" ..
    "button[2.65,0.2;3,0.6;btnChangePwd;"..fgettext("Change Password").."]" ..
    "field[0.1,1.6;4.2,0.6;address;".. fgettext("Server address") ..";".. esc(settings.host) .. "]" ..
    "field[4.1,1.6;1.8,0.6;port;"..fgettext("Port")..";".. esc(settings.port) .. "]" ..
    "checkbox[0,1.7;allowLocalPlay;"..fgettext("Allow Local Play") ..";".. dump(settings.allowLocalPlay) .. "]" ..
    "checkbox[0,2.2;allowRemotePlay;"..fgettext("Allow Remote Play") ..";".. dump(settings.allowRemotePlay) .. "]" ..
    "label[0,2.9;" .. fgettext("Language") .."]" ..
    "dropdown[0.8,3;1;lang;".. settings.langs ..";".. settings.langIndex .. ";false]" ..
    "label[1.8,2.9;" .. langHint .."]" ..
    "button[8.9,5;3,0.8;btnStudentMode;".. fgettext("Student Mode") .."]" ..
    "button[5.9,5;3,0.8;btnSave;".. fgettext("Save") .."]"

  return retval
end

local function main_button_handler(this, fields, name, tabdata)
  local settings = loadTeacherSettings()
  local v

  v = fields["allowLocalPlay"]
  if v ~= nil and v ~= settings.allowLocalPlay then
    currentSettings.allowLocalPlay = core.is_yes(v)
  end

  v = fields["allowRemotePlay"]
  if v ~= nil and v ~= settings.allowRemotePlay then
    currentSettings.allowRemotePlay = core.is_yes(v)
  end

  v = fields["address"]
  if v ~= nil and v ~= settings.host then
    currentSettings.host = v
  end

  v = fields["port"]
  if v ~= nil and v ~= settings.port then
    currentSettings.port = v
  end

  v = fields["lang"]
  if v ~= nil and v ~= settings.lang then
    currentSettings.lang = v
  end

  v = fields["teacherName"]
  if v ~= nil and v ~= settings.teacherName then
    local valid, msg = isPlayerNameValid(v)
    if valid then
      currentSettings.teacherName = v
    else
      messagebox("teacher", msg, this)
      return true
    end
  end

  if fields.btnSave ~= nil then
    saveTeacherSettings(currentSettings)
  elseif fields.btnChangePwd ~= nil then
    local vPassword = getTeacherPasswd()
    local content = {oldPasswd = vPassword}
    local function handler(pass)
      setTeacherPasswd(pass)
    end
    local dlgPassword = create_change_password_dlg(content, handler)
    dlgPassword:set_parent(this)
    this:hide()
    dlgPassword:show()
    return true
  elseif fields.btnStudentMode ~= nil then
    local gamebar = ui.find_by_name("game_button_bar")
    if gamebar then
      gamebar:hide()
    end

    local maintab = ui.find_by_name("maintab")
    local dlg = create_play_game_dlg()
    dlg:set_parent(maintab)
    maintab:hide()
    dlg:show()
    return true
  end

end

--------------------------------------------------------------------------------
return {
  name = "teacher",
  caption = fgettext("Teacher"),
  cbf_formspec = get_formspec,
  cbf_button_handler = main_button_handler,
}
