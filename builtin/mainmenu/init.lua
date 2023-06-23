--Minetest
--Copyright (C) 2014 sapier
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

mt_color_grey  = "#AAAAAA"
mt_color_blue  = "#6389FF"
mt_color_lightblue  = "#99CCFF"
mt_color_green = "#72FF63"
mt_color_dark_green = "#25C191"
mt_color_orange  = "#FF8800"
mt_color_red = "#FF3300"

local menupath = core.get_mainmenu_path()
local basepath = core.get_builtin_path()
defaulttexturedir = core.get_texturepath_share() .. DIR_DELIM .. "base" ..
					DIR_DELIM .. "pack" .. DIR_DELIM

dofile(basepath .. "common" .. DIR_DELIM .. "filterlist.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "buttonbar.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "dialog.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "tabview.lua")
dofile(basepath .. "fstk" .. DIR_DELIM .. "ui.lua")
dofile(menupath .. DIR_DELIM .. "async_event.lua")
dofile(menupath .. DIR_DELIM .. "common.lua")
dofile(menupath .. DIR_DELIM .. "pkgmgr.lua")
dofile(menupath .. DIR_DELIM .. "serverlistmgr.lua")
dofile(menupath .. DIR_DELIM .. "game_theme.lua")
dofile(menupath .. DIR_DELIM .. "teacher_config.lua")

dofile(menupath .. DIR_DELIM .. "dlg_config_world.lua")
dofile(menupath .. DIR_DELIM .. "dlg_settings_advanced.lua")
dofile(menupath .. DIR_DELIM .. "dlg_contentstore.lua")
dofile(menupath .. DIR_DELIM .. "dlg_create_world.lua")
dofile(menupath .. DIR_DELIM .. "dlg_delete_content.lua")
dofile(menupath .. DIR_DELIM .. "dlg_delete_world.lua")
dofile(menupath .. DIR_DELIM .. "dlg_register.lua")
dofile(menupath .. DIR_DELIM .. "dlg_rename_modpack.lua")
dofile(menupath .. DIR_DELIM .. "dlg_version_info.lua")
dofile(menupath .. DIR_DELIM .. "dlg_input_passwd.lua")
dofile(menupath .. DIR_DELIM .. "dlg_change_passwd.lua")
dofile(menupath .. DIR_DELIM .. "dlg_play_game.lua")

local tabs = {}

tabs.settings = dofile(menupath .. DIR_DELIM .. "tab_settings.lua")
tabs.content  = dofile(menupath .. DIR_DELIM .. "tab_content.lua")
tabs.about    = dofile(menupath .. DIR_DELIM .. "tab_about.lua")
tabs.local_game = dofile(menupath .. DIR_DELIM .. "tab_local.lua")
tabs.play_online = dofile(menupath .. DIR_DELIM .. "tab_online.lua")
tabs.teacher = dofile(menupath .. DIR_DELIM .. "tab_teacher.lua")

--------------------------------------------------------------------------------
local function main_event_handler(tabview, event)
	if event == "MenuQuit" then
		core.close()
	end
	return true
end

--------------------------------------------------------------------------------
local function init_globals()
	-- Init gamedata
	gamedata.worldindex = 0

	menudata.worldlist = filterlist.create(
		core.get_worlds,
		compare_worlds,
		-- Unique id comparison function
		function(element, uid)
			return element.name == uid
		end,
		-- Filter function
		function(element, gameid)
			return element.gameid == gameid
		end
	)

	menudata.worldlist:add_sort_mechanism("alphabetic", sort_worlds_alphabetic)
	menudata.worldlist:set_sortmode("alphabetic")

	local gameid = core.settings:get("menu_last_game")
	local game = gameid and pkgmgr.find_by_gameid(gameid)
	if not game then
		gameid = core.settings:get("default_game") or "minetest"
		game = pkgmgr.find_by_gameid(gameid)
		core.settings:set("menu_last_game", gameid)
	end

	mm_game_theme.init()

	-- Create main tabview
	local tv_main = tabview_create("maintab", {x = 12, y = 5.4}, {x = 0, y = 0})
	-- note: size would be 15.5,7.1 in real coordinates mode

	tv_main:set_autosave_tab(true)
	tv_main:add(tabs.teacher)
	tv_main:add(tabs.local_game)
	tv_main:add(tabs.play_online)

	tv_main:add(tabs.content)
	tv_main:add(tabs.settings)
	tv_main:add(tabs.about)

	tv_main:set_global_event_handler(main_event_handler)
	tv_main:set_fixed_size(false)

	local last_tab = core.settings:get("maintab_LAST")
	if last_tab and tv_main.current_tab ~= last_tab then
		tv_main:set_tab(last_tab)
	end

	-- In case the folder of the last selected game has been deleted,
	-- display "Minetest" as a header
--[[
	if tv_main.current_tab == "local" and not game then
		mm_game_theme.reset()
	end
--]]
	ui.set_default("maintab")
	check_new_version()
	-- tv_main:show()
	local dlg = create_play_game_dlg()
	dlg:set_parent(tv_main)
	-- tv_main:hide()
	dlg:show()

	ui.update()

--[[
	core.sound_play("main_menu", true)
--]]
	if not core.settings:get_bool("mute_sound", false) then
		menudata.sound_handler = core.sound_play("main_menu", true)
	end
end

init_globals()
