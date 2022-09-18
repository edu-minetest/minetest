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


local menupath = core.get_mainmenu_path()
local esc = core.formspec_escape
local escDefaultTexturedir = esc(defaulttexturedir)

local default_worlds = {
  {name = "default", game = "minetest", mg_name = "v7", seed = "15823438331521897617", fixed_map_seed = "15823438331521897617", mgv7_spflags = "caverns,floatlands,ridges,mountains"},
  {name = "tutorial", game = "tutorial", mg_name = "singlenode"},
  -- {name = "World 2", mg_name = "v7", seed = "1841722166046826822"},
  -- {name = "World 3", mg_name = "v7", seed = "CC"},
  -- {name = "World 4", mg_name = "valleys", seed = "8572"},
  -- {name = "World 5 Flat", mg_name = "flat", seed = "2"}
}

local enable_default_mods = dofile(menupath .. DIR_DELIM .. "enable_default_mods.lua")

local function get_formspec(data)
  local allowLocalPlay = getTeacherConf("teacher_allow_local_play", true, 'bool')
  local allowRemotePlay = getTeacherConf("teacher_allow_remote_play", false, 'bool')
  -- local passwd = core.settings:get("passwd") or ""
  -- if #passwd > 0 then passwd = core.decode_base64(passwd) end
  local retval = ""
  local y = 0.5
  local muteSound = core.settings:get_bool("mute_sound", false)

  retval = retval ..
    "formspec_version[3]" ..
    "size[16, 8]" ..

    "style[btnPlay,btnPlayLocal;font_size=*2.1;border=false;halign=left]" ..
    "style[btnTeacher;font_size=*1.8;border=false]" ..
    "style[name,mute,btnPasswd;font_size=*1.2]" ..

    "image_button[12, 7.1;1,0.8;".. escDefaultTexturedir .."teacher.png;btnTeacher;]" ..
    "button[13,7.1;3,0.8;btnTeacher;".. fgettext("Teacher") .."]" ..
    "tooltip[btnTeacher;".. fgettext("Enter Teacher Mode") .. "]"

    if allowRemotePlay then
      retval = retval ..
      "image_button[0.5,".. y ..";1,1;".. escDefaultTexturedir .."play.png;btnPlay;]" ..
      "button[1.38,".. (y) ..";6,1;btnPlay;".. fgettext("Play(online)") .."]" ..
      "tooltip[btnPlay;".. fgettext("Play Remote Game") .. "]"
      y = y + 1.2
    end

    if allowLocalPlay then
    retval = retval ..
      "image_button[0.5,"..y..";1,1;".. escDefaultTexturedir .."play.png;btnPlayLocal;]" ..
      "button[1.38,".. (y) ..";6,1;btnPlayLocal;".. fgettext("Play(local)") .."]" ..
      "tooltip[btnPlayLocal;".. fgettext("Play Local Game") .. "]"
  end
  retval = retval ..
  " field[10.2,0.8;3,0.8;name;".. fgettext("Name") ..";".. esc(core.settings:get("student_name") or "student") ..
  "]" ..
  "button[13.28,0.8;2.48,0.8;btnPasswd;".. fgettext("Password") .. "]" ..
  "tooltip[btnPasswd;"..fgettext("Change Password").."]"

  retval = retval ..
  "checkbox[10.2,2;mute;"..fgettext("Mute sound")..";" ..dump(muteSound).. "]"

  return retval
end

local function verifyTeacherPassword(this, password)
  if password == nil then password = "" end
  -- local vTeacher = core.settings:get("teacher_name") or ""
  local vPassword = getTeacherPasswd()
  local result = core.encode_base64(password) == vPassword
  if result then
    this:delete()
  end
  return result
end

local function dialog_button_handler(this, fields, confirmPass)
  local password = this.data.content.password -- or fields["password"]
  local name = fields["name"]
  local oldName = core.settings:get("student_name")
  local teacherName = core.settings:get("teacher_name")

  local v = fields["mute"]
  if v ~= nil then
    local handler = menudata.sound_handler
    if handler then
      core.sound_stop(handler)
      menudata.sound_handler = nil
    end
    if v == "true" then
      core.settings:set_bool("mute_sound", true)
    else
      core.settings:set_bool("mute_sound", false)
      menudata.sound_handler = core.sound_play("main_menu", true)
    end
  end

  if (name and name ~= "" and oldName ~= name) then
    local valid, msg = isPlayerNameValid(name)
    if valid then
      if name == teacherName then
        messagebox("teacher", fgettext("Student name should not be same as the teacher"), this)
        return true
      end
      core.settings:set("student_name", name)
    else
      messagebox("teacher", msg, this)
      return true
    end
  else
    name = oldName or "student"
  end

  if confirmPass then
    return verifyTeacherPassword(this, password)
  elseif fields["btnPlay"] ~= nil then
    gamedata.playername = name
    local host = core.settings:get("teacher_host")
    local port = core.settings:get("teacher_port") or "30000"
    local pass = getPasswd(name)
    if host and host ~= "" then
      gamedata.address    = host
      gamedata.port       = port
      gamedata.selected_world = 0
      if pass and pass ~= "" then gamedata.password = core.decode_base64(pass) end
      core.start()
    else
      messagebox("teacher", fgettext("Ask the teacher to configure the game server address"), this)
    end
    return true
  elseif fields["btnPlayLocal"] ~= nil then
    core.settings:set_bool("is_teacher", false)
    if name ~= "singleplayer" then
      local pass = getPasswd(name)
      if pass and pass ~= "" then gamedata.password = core.decode_base64(pass) end
    end
    gamedata.playername = name
    local worldidx = tonumber(core.settings:get("mainmenu_last_selected_world"))
    if worldidx < 1 then
      worldidx = menudata.worldlist:raw_index_by_uid(default_worlds[1].name)
    end
    gamedata.selected_world = worldidx
    gamedata.singleplayer = true
    core.start()
    return true
  elseif fields["btnTeacher"] ~= nil then
    if not verifyTeacherPassword(this, password) then
      local dlgPassword = create_input_password_dlg(this.data.content, dialog_button_handler)
      dlgPassword:set_parent(this)
      this:hide()
      dlgPassword:show()
    end
    return true
  elseif fields.btnPasswd ~= nil then
    local vPassword = getPasswd(name)
    local content = {oldPasswd = vPassword}
    local function handler(pass)
      setPasswd(name, pass)
    end
    local dlgPassword = create_change_password_dlg(content, handler)
    dlgPassword:set_parent(this)
    this:hide()
    dlgPassword:show()
    return true
  end
  return false
end

local function dialog_event_handler(event)
  if event == "MenuQuit" then
    core.close()
    -- return true means already processed
    return true
  end
end

local function create_default_worlds()

  -- Preserve the old map seed and mapgen values
  local old_map_seed = core.settings:get("fixed_map_seed")
  local old_mapgen = core.settings:get("mg_name")

  -- Create the worlds
  for _, world in ipairs(default_worlds) do
    local _, gameindex = pkgmgr.find_by_gameid(world.game)
    if gameindex ~= nil and not menudata.worldlist:uid_exists_raw(world.name) then
      if world.seed ~= nil then core.settings:set("fixed_map_seed", world.seed) end
      core.settings:set("mg_name", world.mg_name)
      local msg = core.create_world(world.name, world.game, world)
      if msg ~= nil then
        gamedata.errormessage = msg
        break
      else
        menudata.worldlist:refresh()
        if world.game ~= 'tutorial' then
          enable_default_mods(world.name)
        end
      end
    end
  end

  -- Restore the old values
  if old_map_seed then
    core.settings:set("fixed_map_seed", old_map_seed)
  else
    core.settings:remove("fixed_map_seed")
  end
  if old_mapgen then
    core.settings:set("mg_name", old_mapgen)
  else
    core.settings:remove("mg_name")
  end

  local last_selected_world = tonumber(core.settings:get("mainmenu_last_selected_world") or 0)
  if last_selected_world < 1 then
    local worldidx = menudata.worldlist:raw_index_by_uid(default_worlds[1].name)
    if worldidx > 0 then
      core.settings:set("mainmenu_last_selected_world", worldidx)
    end
  end
end

local checked_worlds = false
local function check_default_worlds()
  -- menudata.worldlist:set_filtercriteria("minetest")

  -- Only check the worlds once (on restart)
  -- if not checked_worlds and #menudata.worldlist:get_list() == 0 then
  if not checked_worlds then
    create_default_worlds()
  end
  checked_worlds = true
end

function create_play_game_dlg(content)
  check_default_worlds()
  local gamebar = ui.find_by_name("game_button_bar")
  if gamebar then
    gamebar:hide()
  end

  if not content then content = {} end
  local retval = dialog_create("dlg_play_game",
    get_formspec,
    dialog_button_handler,
    dialog_event_handler
  )
  retval.data.content = content
  return retval
end

function isPlayerNameValid(name)
  if (name and name ~= "") then
    if (#name > 20) then
      return false,
        fgettext("User name length cannot exceed 20")
    end
    if string.find(name, "^[a-zA-Z%d%-_]+$") then
      return true
    else
      return false,
        fgettext("Please check that name only contains allowed characters: 'a' to 'z', 'A' to 'Z', '0' to '9', '-', '_'")
    end
  else
    return false, fgettext("name is empty")
  end
end
