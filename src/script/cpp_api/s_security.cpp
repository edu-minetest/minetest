/*
Minetest
Copyright (C) 2013 celeron55, Perttu Ahola <celeron55@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

#include "cpp_api/s_security.h"
#include "lua_api/l_base.h"
#include "filesys.h"
#include "porting.h"
#include "server.h"
#include "client/client.h"
#include "settings.h"

#include <cerrno>
#include <string>
#include <algorithm>
#include <iostream>


#define SECURE_API(lib, name) \
	lua_pushcfunction(L, sl_##lib##_##name); \
	lua_setfield(L, -2, #name);


static inline void copy_safe(lua_State *L, const char *list[], unsigned len, int from=-2, int to=-1)
{
	if (from < 0) from = lua_gettop(L) + from + 1;
	if (to   < 0) to   = lua_gettop(L) + to   + 1;
	for (unsigned i = 0; i < (len / sizeof(list[0])); i++) {
		lua_getfield(L, from, list[i]);
		lua_setfield(L, to,   list[i]);
	}
}

static void shallow_copy_table(lua_State *L, int from=-2, int to=-1)
{
	if (from < 0) from = lua_gettop(L) + from + 1;
	if (to   < 0) to   = lua_gettop(L) + to   + 1;
	lua_pushnil(L);
	while (lua_next(L, from) != 0) {
		assert(lua_type(L, -1) != LUA_TTABLE);
		// duplicate key and value for lua_rawset
		lua_pushvalue(L, -2);
		lua_pushvalue(L, -2);
		lua_rawset(L, to);
		lua_pop(L, 1);
	}
}

// Pushes the original version of a library function on the stack, from the old version
static inline void push_original(lua_State *L, const char *lib, const char *func)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, CUSTOM_RIDX_GLOBALS_BACKUP);
	lua_getfield(L, -1, lib);
	lua_remove(L, -2);  // Remove globals_backup
	lua_getfield(L, -1, func);
	lua_remove(L, -2);  // Remove lib
}


void ScriptApiSecurity::initializeSecurity()
{
	static const char *whitelist[] = {
		"assert",
		"core",
		"collectgarbage",
		"DIR_DELIM",
		"error",
		"getfenv",
		"getmetatable",
		"ipairs",
		"next",
		"pairs",
		"pcall",
		"print",
		"rawequal",
		"rawget",
		"rawset",
		"select",
		"setfenv",
		"setmetatable",
		"tonumber",
		"tostring",
		"type",
		"unpack",
		"_VERSION",
		"xpcall",
	};
	static const char *whitelist_tables[] = {
		// These libraries are completely safe BUT we need to duplicate their table
		// to ensure the sandbox can't affect the insecure env
		"coroutine",
		"string",
		"table",
		"math",
		"bit"
	};
	static const char *io_whitelist[] = {
		"close",
		"flush",
		"read",
		"type",
		"write",
	};
	static const char *os_whitelist[] = {
		"clock",
		"date",
		"difftime",
		"getenv",
		"time",
	};
	static const char *debug_whitelist[] = {
		"gethook",
		"traceback",
		"getinfo",
		"upvalueid",
		"sethook",
		"debug",
	};
	static const char *package_whitelist[] = {
		"config",
		"cpath",
		"path",
		"searchpath",
	};
#if USE_LUAJIT
	static const char *jit_whitelist[] = {
		"arch",
		"flush",
		"off",
		"on",
		"opt",
		"os",
		"status",
		"version",
		"version_num",
	};
#endif
	m_secure = true;

	lua_State *L = getStack();

	// Backup globals to the registry
	lua_getglobal(L, "_G");
	lua_rawseti(L, LUA_REGISTRYINDEX, CUSTOM_RIDX_GLOBALS_BACKUP);

	// Replace the global environment with an empty one
	int thread = getThread(L);
	createEmptyEnv(L);
	setLuaEnv(L, thread);

	// Get old globals
	lua_rawgeti(L, LUA_REGISTRYINDEX, CUSTOM_RIDX_GLOBALS_BACKUP);
	int old_globals = lua_gettop(L);


	// Copy safe base functions
	lua_getglobal(L, "_G");
	copy_safe(L, whitelist, sizeof(whitelist));

	// And replace unsafe ones
	SECURE_API(g, dofile);
	SECURE_API(g, load);
	SECURE_API(g, loadfile);
	SECURE_API(g, loadstring);
	SECURE_API(g, require);
	lua_pop(L, 1);


	// Copy safe libraries
	for (const char *libname : whitelist_tables) {
		lua_getfield(L, old_globals, libname);
		lua_newtable(L);
		shallow_copy_table(L);

		lua_setglobal(L, libname);
		lua_pop(L, 1);
	}


	// Copy safe IO functions
	lua_getfield(L, old_globals, "io");
	lua_newtable(L);
	copy_safe(L, io_whitelist, sizeof(io_whitelist));

	// And replace unsafe ones
	SECURE_API(io, open);
	SECURE_API(io, input);
	SECURE_API(io, output);
	SECURE_API(io, lines);

	lua_setglobal(L, "io");
	lua_pop(L, 1);  // Pop old IO


	// Copy safe OS functions
	lua_getfield(L, old_globals, "os");
	lua_newtable(L);
	copy_safe(L, os_whitelist, sizeof(os_whitelist));

	// And replace unsafe ones
	SECURE_API(os, remove);
	SECURE_API(os, rename);
	SECURE_API(os, setlocale);

	lua_setglobal(L, "os");
	lua_pop(L, 1);  // Pop old OS


	// Copy safe debug functions
	lua_getfield(L, old_globals, "debug");
	lua_newtable(L);
	copy_safe(L, debug_whitelist, sizeof(debug_whitelist));
	lua_setglobal(L, "debug");
	lua_pop(L, 1);  // Pop old debug


	// Copy safe package fields
	lua_getfield(L, old_globals, "package");
	lua_newtable(L);
	copy_safe(L, package_whitelist, sizeof(package_whitelist));
	lua_setglobal(L, "package");
	lua_pop(L, 1);  // Pop old package

#if USE_LUAJIT
	// Copy safe jit functions, if they exist
	lua_getfield(L, -1, "jit");
	if (!lua_isnil(L, -1)) {
		lua_newtable(L);
		copy_safe(L, jit_whitelist, sizeof(jit_whitelist));
		lua_setglobal(L, "jit");
	}
	lua_pop(L, 1);  // Pop old jit
#endif

	// Get rid of 'core' in the old globals, we don't want anyone thinking it's
	// safe or even usable.
	lua_pushnil(L);
	lua_setfield(L, old_globals, "core");

	lua_pop(L, 1); // Pop globals_backup


	/*
	 * In addition to copying the tables in whitelist_tables, we also need to
	 * replace the string metatable. Otherwise old_globals.string would
	 * be accessible via getmetatable("").__index from inside the sandbox.
	 */
	lua_pushliteral(L, "");
	lua_newtable(L);
	lua_getglobal(L, "string");
	lua_setfield(L, -2, "__index");
	lua_setmetatable(L, -2);
	lua_pop(L, 1); // Pop empty string
}

void ScriptApiSecurity::initializeSecurityClient()
{
	static const char *whitelist[] = {
		"assert",
		"core",
		"collectgarbage",
		"DIR_DELIM",
		"error",
		"getfenv",
		"ipairs",
		"next",
		"pairs",
		"pcall",
		"print",
		"rawequal",
		"rawget",
		"rawset",
		"select",
		"setfenv",
		"getmetatable",
		"setmetatable",
		"tonumber",
		"tostring",
		"type",
		"unpack",
		"_VERSION",
		"xpcall",
		// Completely safe libraries
		"coroutine",
		"string",
		"table",
		"math",
		"bit",
	};
	static const char *os_whitelist[] = {
		"clock",
		"date",
		"difftime",
		"time"
	};
	static const char *debug_whitelist[] = {
		"getinfo", // used by builtin and unset before mods load
		"traceback"
	};

#if USE_LUAJIT
	static const char *jit_whitelist[] = {
		"arch",
		"flush",
		"off",
		"on",
		"opt",
		"os",
		"status",
		"version",
		"version_num",
	};
#endif

	m_secure = true;

	lua_State *L = getStack();
	int thread = getThread(L);

	// create an empty environment
	createEmptyEnv(L);

	// Copy safe base functions
	lua_getglobal(L, "_G");
	lua_getfield(L, -2, "_G");
	copy_safe(L, whitelist, sizeof(whitelist));

	// And replace unsafe ones
	SECURE_API(g, dofile);
	SECURE_API(g, load);
	SECURE_API(g, loadfile);
	SECURE_API(g, loadstring);
	SECURE_API(g, require);
	lua_pop(L, 2);



	// Copy safe OS functions
	lua_getglobal(L, "os");
	lua_newtable(L);
	copy_safe(L, os_whitelist, sizeof(os_whitelist));
	lua_setfield(L, -3, "os");
	lua_pop(L, 1);  // Pop old OS


	// Copy safe debug functions
	lua_getglobal(L, "debug");
	lua_newtable(L);
	copy_safe(L, debug_whitelist, sizeof(debug_whitelist));
	lua_setfield(L, -3, "debug");
	lua_pop(L, 1);  // Pop old debug

#if USE_LUAJIT
	// Copy safe jit functions, if they exist
	lua_getglobal(L, "jit");
	lua_newtable(L);
	copy_safe(L, jit_whitelist, sizeof(jit_whitelist));
	lua_setfield(L, -3, "jit");
	lua_pop(L, 1);  // Pop old jit
#endif

	// Set the environment to the one we created earlier
	setLuaEnv(L, thread);
}

int ScriptApiSecurity::getThread(lua_State *L)
{
#if LUA_VERSION_NUM <= 501
	int is_main = lua_pushthread(L);  // Push the main thread
	FATAL_ERROR_IF(!is_main, "Security: ScriptApi's Lua state "
		"isn't the main Lua thread!");
	return lua_gettop(L);
#endif
	return 0;
}

void ScriptApiSecurity::createEmptyEnv(lua_State *L)
{
	lua_newtable(L);  // Create new environment
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "_G");  // Create the _G loop
}

void ScriptApiSecurity::setLuaEnv(lua_State *L, int thread)
{
#if LUA_VERSION_NUM >= 502  // Lua >= 5.2
	// Set the global environment
	lua_rawseti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
#else  // Lua <= 5.1
	// Set the environment of the main thread
	FATAL_ERROR_IF(!lua_setfenv(L, thread), "Security: Unable to set "
		"environment of the main Lua thread!");
	lua_pop(L, 1);  // Pop thread
#endif
}

bool ScriptApiSecurity::isSecure(lua_State *L)
{
#ifndef SERVER
	auto script = ModApiBase::getScriptApiBase(L);
	// CSM keeps no globals backup but is always secure
	if (script->getType() == ScriptingType::Client)
		return true;
#endif
	lua_rawgeti(L, LUA_REGISTRYINDEX, CUSTOM_RIDX_GLOBALS_BACKUP);
	bool secure = !lua_isnil(L, -1);
	lua_pop(L, 1);
	if (secure) secure = !checkWhitelisted(L, "secure.trusted_mods");
	return secure;
}

bool ScriptApiSecurity::safeLoadString(lua_State *L, const std::string &code, const char *chunk_name)
{
	if (code.size() > 0 && code[0] == LUA_SIGNATURE[0]) {
		lua_pushliteral(L, "Bytecode prohibited when mod security is enabled.");
		return false;
	}
	if (luaL_loadbuffer(L, code.data(), code.size(), chunk_name))
		return false;
	return true;
}

bool ScriptApiSecurity::safeLoadFile(lua_State *L, const char *path, const char *display_name)
{
	FILE *fp;
	char *chunk_name;
	if (!display_name)
		display_name = path;
	if (!path) {
		fp = stdin;
		chunk_name = const_cast<char *>("=stdin");
	} else {
		fp = fopen(path, "rb");
		if (!fp) {
			lua_pushfstring(L, "%s: %s", path, strerror(errno));
			return false;
		}
		size_t len = strlen(display_name) + 2;
		chunk_name = new char[len];
		snprintf(chunk_name, len, "@%s", display_name);
	}

	size_t start = 0;
	int c = std::getc(fp);
	if (c == '#') {
		// Skip the shebang line (but keep line-ending)
		while (c != EOF && c != '\n')
			c = std::getc(fp);
		start = std::ftell(fp) - 1;
	}

	// Read the file
	int ret = std::fseek(fp, 0, SEEK_END);
	if (ret) {
		lua_pushfstring(L, "%s: %s", path, strerror(errno));
		if (path) {
			std::fclose(fp);
			delete [] chunk_name;
		}
		return false;
	}

	size_t size = std::ftell(fp) - start;
	std::string code(size, '\0');
	ret = std::fseek(fp, start, SEEK_SET);
	if (ret) {
		lua_pushfstring(L, "%s: %s", path, strerror(errno));
		if (path) {
			std::fclose(fp);
			delete [] chunk_name;
		}
		return false;
	}

	size_t num_read = std::fread(&code[0], 1, size, fp);
	if (path)
		std::fclose(fp);
	if (num_read != size) {
		lua_pushliteral(L, "Error reading file to load.");
		if (path)
			delete [] chunk_name;
		return false;
	}

	bool result = safeLoadString(L, code, chunk_name);
	if (path)
		delete [] chunk_name;
	return result;
}

std::string inline _get_mod_name_from_debug(lua_Debug *info)
{
	std::string mod_name;
	std::string src = info->source;
	// warningstream << "Mod security:: _get_mod_name_from_debug "<< src << std::endl;

	if (src.empty()) return mod_name;
	// if (src == "=[C]" || src == "=(load)") {
	if (src[0] != '@') {
		mod_name = BUILTIN_MOD_NAME;
		return mod_name;
	}

#ifdef __ANDROID__
	std::string BUILTIN_DIR = Server::getBuiltinLuaPath();
	std::string MOD_DIR = porting::path_user + DIR_DELIM + "mods" + DIR_DELIM;
	std::string GAME_DIR = porting::path_user + DIR_DELIM + "games" + DIR_DELIM;

	size_t found = src.find(GAME_DIR);
	if (found != std::string::npos) {
		std::string t = src.substr(found + GAME_DIR.length());
		found = t.find(DIR_DELIM_CHAR);
		if (found != std::string::npos) {
			t = t.substr(found + 6); // length of "mods/"
			found = t.find(DIR_DELIM_CHAR);
			if (found != std::string::npos) mod_name = t.substr(0, found);
		}
	}

	if (mod_name.empty()) {
		found = src.find(MOD_DIR);
		if (found != std::string::npos) {
			mod_name = src.substr(found+MOD_DIR.length());
			found = mod_name.find(DIR_DELIM_CHAR);
			if (found != std::string::npos) mod_name = mod_name.substr(0, found);
		}
	}
#else
	std::string BIN_DIR = std::string(DIR_DELIM) + "bin" + DIR_DELIM;
	std::string MOD_DIR = BIN_DIR + ".." + DIR_DELIM + "mods" + DIR_DELIM;
	std::string BUILTIN_DIR = BIN_DIR + ".." + DIR_DELIM + "builtin" + DIR_DELIM;
	std::string GAME_DIR = BIN_DIR + ".." + DIR_DELIM + "games" + DIR_DELIM;


	// Find the first "/bin/" string posistion.
	size_t bin_pos = src.find(BIN_DIR);
	if (bin_pos == 	std::string::npos) {
		errorstream << "Mod security:: Can not find 'bin/' in the script filename: " << src << std::endl;
		return mod_name;
	}
	// Find the first "/bin/../builtin/" string posistion.
	size_t found = src.find(BUILTIN_DIR);
	if (found != std::string::npos) {
		// Check the path whether be faked.
		// the found position should be different from bin_pos if it's faked
		// eg, "/bin/../mods/faked_mod/bin/../builtin/"
		if (bin_pos == found) {
			mod_name = BUILTIN_MOD_NAME;
		}
	}

	if (mod_name.empty()) {
		found = src.find(GAME_DIR);
		if (bin_pos == found) {
			std::string t = src.substr(found + GAME_DIR.length());
			found = t.find(DIR_DELIM_CHAR);
			if (found != std::string::npos) {
				t = t.substr(found + 6); // length of "mods/"
				found = t.find(DIR_DELIM_CHAR);
				if (found != std::string::npos) mod_name = t.substr(0, found);
			}
		}
	}

	if (mod_name.empty()) {
		found = src.find(MOD_DIR);
		if (found != std::string::npos) {
			// Check the path whether be faked.
			if (bin_pos == found) {
				mod_name = src.substr(found+MOD_DIR.length());
				found = mod_name.find(DIR_DELIM_CHAR);
				if (found != std::string::npos) mod_name = mod_name.substr(0, found);
			} else {
				warningstream << "Mod security:: fake "<< MOD_DIR << " folder found in mod " << src.substr(found+MOD_DIR.length()) << std::endl;
			}
		}
	}
#endif

	return mod_name;
}

std::vector<std::string> inline _get_caller_mod_names(lua_State *L) {
	lua_Debug info;
	std::vector<std::string> result;
	int level = 1;
	std::string mod_name;
	while (lua_getstack(L, level, &info)) {
		FATAL_ERROR_IF(!lua_getinfo(L, "S", &info), "lua_getinfo() failed");
		mod_name = _get_mod_name_from_debug(&info);
		if (mod_name.empty()) break;
		if ((result.size() == 0) || (result.back() != mod_name)) {
			result.push_back(mod_name);
		}
		level++;
	}
	return result;
}

bool inline _is_in_whitelist(const std::string &setting, const std::string &mod_name)
{
	std::string value = g_settings->get(setting);
	value.erase(std::remove(value.begin(), value.end(), ' '), value.end());
	auto mod_list = str_split(value, ',');
	return CONTAINS(mod_list, mod_name);
}

std::string inline _get_real_caller_mod_name(lua_State *L)
{
	std::string result;
	// Get gamedef from registry
	ScriptApiBase *script = ModApiBase::getScriptApiBase(L);
	const IGameDef *gamedef = script->getGameDef();
	if (gamedef) {
		std::vector<std::string> caller_mods = _get_caller_mod_names(L);
		if (caller_mods.empty()) return result;

		std::size_t iMin = 0;
		std::string executor_mod_name;
		while (iMin < caller_mods.size()) {
			executor_mod_name = caller_mods.at(iMin);
			if (executor_mod_name != BUILTIN_MOD_NAME) break;
			iMin++;
		}
		if (iMin >= caller_mods.size()) return executor_mod_name;
		const ModSpec *executor_mod = gamedef->getModSpec(executor_mod_name);
		if (executor_mod) {
			bool ok = false;
			std::string prev_mod_name;
			std::size_t i = caller_mods.size() - 1;
			if (i == iMin) return executor_mod_name;

			// get the first event trigger
			// Sometimes, the initiator of the action is not a builtin module, but an event trigger from a third-party module. For example, triggered by `formspecs`.
			// And it should be in the prev_mod's dependencies or optional dependencies.
			while (i>iMin) {
				result = caller_mods.at(i);
				prev_mod_name = caller_mods.at(i-1);
				if (prev_mod_name == BUILTIN_MOD_NAME) {
					break;
				}
				if (result != BUILTIN_MOD_NAME) {
					const ModSpec *prev_mod = gamedef->getModSpec(prev_mod_name);
					if (prev_mod && !CONTAINS(prev_mod->depends, result) && !CONTAINS(prev_mod->optdepends, result)) {
						break;
					}
				}
				i--;
				if (prev_mod_name == executor_mod_name) {
					ok = true;
					// this means the second is the trigger, the first is caller for no more callers
					if (i == iMin) result = executor_mod_name;
					break;
				}
			}
			const ModSpec *mod;
			// get real caller
			while (i>iMin) {
				const std::string mod_name = caller_mods.at(i);
				if (mod_name != BUILTIN_MOD_NAME) {
					mod = gamedef->getModSpec(mod_name);
					prev_mod_name = caller_mods.at(i-1);
					if (prev_mod_name == BUILTIN_MOD_NAME) break;
					// check the whole depends chain
					if (mod && (CONTAINS(mod->depends, prev_mod_name) || CONTAINS(mod->optdepends, prev_mod_name))) {
						ok = true;
					} else {
						executor_mod_name = prev_mod_name;
						ok = false;
						break;
					}
				}
				i--;
			}
			if (!ok) {
				if (executor_mod_name != BUILTIN_MOD_NAME) {
					if (_is_in_whitelist("secure.trusted_mods", executor_mod_name)) {
						warningstream << "Mod security:: The function used by mod "<< result << " is hooked by trusted mod:" << executor_mod_name << std::endl;
					} else {
						errorstream << "Mod security:: FAKE(MAYBE) the function used by mod "<< result << " is hooked by " << executor_mod_name << ". Add it in secure.trusted_mods to allow hooking IO operation." << std::endl;
						result.clear();
					}
				}
			}
		}
	}
	return result;
}

std::string ScriptApiSecurity::get_current_modname(lua_State *L)
{
	std::string result;
	lua_rawgeti(L, LUA_REGISTRYINDEX, CUSTOM_RIDX_CURRENT_MOD_NAME);
	if (lua_isstring(L, -1)) {
		result = readParam<std::string>(L, -1);
	} else {
		result = _get_real_caller_mod_name(L);
	}
	lua_pop(L, 1);
	return result;
}

int ScriptApiSecurity::l_get_current_modname(lua_State *L)
{
	lua_rawgeti(L, LUA_REGISTRYINDEX, CUSTOM_RIDX_CURRENT_MOD_NAME);
	if (!lua_isstring(L, -1)) {
		std::string mod_name = _get_real_caller_mod_name(L);
		if (!mod_name.empty()) {
			lua_pop(L, 1);  // Pop rawgeti
			lua_pushstring(L, mod_name.c_str());
		}
	}
	return 1;
}

bool ScriptApiSecurity::checkPath(lua_State *L, const char *path,
		bool write_required, bool *write_allowed)
{
	if (write_allowed)
		*write_allowed = false;

	std::string str;  // Transient

	std::string abs_path = fs::AbsolutePath(path);

	if (!abs_path.empty()) {
		// Don't allow accessing the settings file
		str = fs::AbsolutePath(g_settings_path);
		if (str == abs_path) return false;
	}

	// If we couldn't find the absolute path (path doesn't exist) then
	// try removing the last components until it works (to allow
	// non-existent files/folders for mkdir).
	std::string cur_path = path;
	std::string removed;
	while (abs_path.empty() && !cur_path.empty()) {
		std::string component;
		cur_path = fs::RemoveLastPathComponent(cur_path, &component);
		if (component == "..") {
			// Parent components can't be allowed or we could allow something like
			// /home/user/minetest/worlds/foo/noexist/../../../../../../etc/passwd.
			// If we have previous non-relative elements in the path we might be
			// able to remove them so that things like worlds/foo/noexist/../auth.txt
			// could be allowed, but those paths will be interpreted as nonexistent
			// by the operating system anyways.
			return false;
		}
		removed.append(component).append(removed.empty() ? "" : DIR_DELIM + removed);
		abs_path = fs::AbsolutePath(cur_path);
	}
	if (abs_path.empty())
		return false;
	// Add the removed parts back so that you can't, eg, create a
	// directory in worldmods if worldmods doesn't exist.
	if (!removed.empty())
		abs_path += DIR_DELIM + removed;

	// Get gamedef from registry
	ScriptApiBase *script = ModApiBase::getScriptApiBase(L);
	const IGameDef *gamedef = script->getGameDef();
	if (!gamedef)
		return false;

	// Get mod name
	std::string mod_name;
	lua_rawgeti(L, LUA_REGISTRYINDEX, CUSTOM_RIDX_CURRENT_MOD_NAME);
	if (lua_isstring(L, -1)) {
		mod_name = readParam<std::string>(L, -1);
	} else {
		mod_name = _get_real_caller_mod_name(L);
	}
	lua_pop(L, 1);  // Pop mod name

	if (!mod_name.empty()) {

		// Builtin can access anything
		if (mod_name == BUILTIN_MOD_NAME) {
			if (write_allowed) *write_allowed = true;
			return true;
		}

		// Allow paths in mod path
		// Don't bother if write access isn't important, since it will be handled later
		if (write_required || write_allowed != NULL) {
			const ModSpec *mod = gamedef->getModSpec(mod_name);
			if (mod) {
				str = fs::AbsolutePath(mod->path);
				if (!str.empty() && fs::PathStartsWith(abs_path, str)) {
					if (write_allowed) *write_allowed = true;
					return true;
				}
			}
		}
	}

	// Allow read-only access to game directory
	if (!write_required) {
		const SubgameSpec *game_spec = gamedef->getGameSpec();
		if (game_spec && !game_spec->path.empty()) {
			str = fs::AbsolutePath(game_spec->path);
			if (!str.empty() && fs::PathStartsWith(abs_path, str)) {
				return true;
			}
		}
	}

	// Allow read-only access to all mod directories
	if (!write_required) {
		const std::vector<ModSpec> &mods = gamedef->getMods();
		for (const ModSpec &mod : mods) {
			str = fs::AbsolutePath(mod.path);
			if (!str.empty() && fs::PathStartsWith(abs_path, str)) {
				return true;
			}
		}
	}

	str = fs::AbsolutePath(gamedef->getWorldPath());
	if (!str.empty()) {
		// Don't allow access to other paths in the world mod/game path.
		// These have to be blocked so you can't override a trusted mod
		// by creating a mod with the same name in a world mod directory.
		// We add to the absolute path of the world instead of getting
		// the absolute paths directly because that won't work if they
		// don't exist.
		if (fs::PathStartsWith(abs_path, str + DIR_DELIM + "worldmods") ||
				fs::PathStartsWith(abs_path, str + DIR_DELIM + "game")) {
			return false;
		}
		// Allow all other paths in world path
		if (fs::PathStartsWith(abs_path, str)) {
			if (write_allowed) *write_allowed = true;
			return true;
		}
	}

	// Default to disallowing
	return false;
}

bool ScriptApiSecurity::isInWhitelist(const std::string &setting, const std::string &mod_name)
{
	return _is_in_whitelist(setting, mod_name);
}

bool ScriptApiSecurity::checkWhitelisted(lua_State *L, const std::string &setting)
{
	assert(str_starts_with(setting, "secure."));

	// Mod must be listed in secure.http_mods or secure.trusted_mods
	std::string mod_name;
	lua_rawgeti(L, LUA_REGISTRYINDEX, CUSTOM_RIDX_CURRENT_MOD_NAME);
	if (lua_isstring(L, -1)) {
		mod_name = readParam<std::string>(L, -1);
	} else {
		mod_name = _get_real_caller_mod_name(L);
	}
	lua_pop(L, 1);  // Pop mod name
	if (mod_name.empty()) return false;

	return isInWhitelist(setting, mod_name);
}


int ScriptApiSecurity::sl_g_dofile(lua_State *L)
{
	int nret = sl_g_loadfile(L);
	if (nret != 1) {
		lua_error(L);
		// code after this function isn't executed
	}
	int top_precall = lua_gettop(L);
	lua_call(L, 0, LUA_MULTRET);
	// Return number of arguments returned by the function,
	// adjusting for the function being poped.
	return lua_gettop(L) - (top_precall - 1);
}


int ScriptApiSecurity::sl_g_load(lua_State *L)
{
	size_t len;
	const char *buf;
	std::string code;
	const char *chunk_name = "=(load)";

	luaL_checktype(L, 1, LUA_TFUNCTION);
	if (!lua_isnone(L, 2)) {
		luaL_checktype(L, 2, LUA_TSTRING);
		const char *_chunk_name = lua_tostring(L, 2);
		std::string BIN_DIR = std::string(DIR_DELIM) + "bin" + DIR_DELIM;
		if (!strstr(_chunk_name, BIN_DIR.c_str()) || !isSecure(L)) chunk_name = _chunk_name;
	}

	while (true) {
		lua_pushvalue(L, 1);
		lua_call(L, 0, 1);
		int t = lua_type(L, -1);
		if (t == LUA_TNIL) {
			break;
		}

		if (t != LUA_TSTRING) {
			lua_pushnil(L);
			lua_pushliteral(L, "Loader didn't return a string");
			return 2;
		}
		buf = lua_tolstring(L, -1, &len);
		code += std::string(buf, len);
		lua_pop(L, 1); // Pop return value
	}
	if (!safeLoadString(L, code, chunk_name)) {
		lua_pushnil(L);
		lua_insert(L, -2);
		return 2;
	}
	return 1;
}


int ScriptApiSecurity::sl_g_loadfile(lua_State *L)
{
#ifndef SERVER
	ScriptApiBase *script = ModApiBase::getScriptApiBase(L);

	// Client implementation
	if (script->getType() == ScriptingType::Client) {
		std::string path = readParam<std::string>(L, 1);
		const std::string *contents = script->getClient()->getModFile(path);
		if (!contents) {
			std::string error_msg = "Coudln't find script called: " + path;
			lua_pushnil(L);
			lua_pushstring(L, error_msg.c_str());
			return 2;
		}

		std::string chunk_name = "@" + path;
		if (!safeLoadString(L, *contents, chunk_name.c_str())) {
			lua_pushnil(L);
			lua_insert(L, -2);
			return 2;
		}
		return 1;
	}
#endif

	// Server implementation
	const char *path = NULL;
	if (lua_isstring(L, 1)) {
		path = lua_tostring(L, 1);
		CHECK_SECURE_PATH_INTERNAL(L, path, false, NULL);
	}

	if (!safeLoadFile(L, path)) {
		lua_pushnil(L);
		lua_insert(L, -2);
		return 2;
	}

	return 1;
}


int ScriptApiSecurity::sl_g_loadstring(lua_State *L)
{
	const char *chunk_name = "=(load)";

	luaL_checktype(L, 1, LUA_TSTRING);
	if (!lua_isnone(L, 2)) {
		luaL_checktype(L, 2, LUA_TSTRING);
		chunk_name = lua_tostring(L, 2);
		const char *_chunk_name = lua_tostring(L, 2);
		std::string BIN_DIR = std::string(DIR_DELIM) + "bin" + DIR_DELIM;
		if (!strstr(_chunk_name, BIN_DIR.c_str()) || !isSecure(L)) chunk_name = _chunk_name;
	}

	size_t size;
	const char *code = lua_tolstring(L, 1, &size);
	std::string code_s(code, size);

	if (!safeLoadString(L, code_s, chunk_name)) {
		lua_pushnil(L);
		lua_insert(L, -2);
		return 2;
	}
	return 1;
}


int ScriptApiSecurity::sl_g_require(lua_State *L)
{
	lua_pushliteral(L, "require() is disabled when mod security is on.");
	return lua_error(L);
}


int ScriptApiSecurity::sl_io_open(lua_State *L)
{
	bool with_mode = lua_gettop(L) > 1;

	luaL_checktype(L, 1, LUA_TSTRING);
	const char *path = lua_tostring(L, 1);

	bool write_requested = false;
	if (with_mode) {
		luaL_checktype(L, 2, LUA_TSTRING);
		const char *mode = lua_tostring(L, 2);
		write_requested = strchr(mode, 'w') != NULL ||
			strchr(mode, '+') != NULL ||
			strchr(mode, 'a') != NULL;
	}
	CHECK_SECURE_PATH(L, path, write_requested);

	push_original(L, "io", "open");
	lua_pushvalue(L, 1);
	if (with_mode) {
		lua_pushvalue(L, 2);
	}

	lua_call(L, with_mode ? 2 : 1, 2);
	return 2;
}


int ScriptApiSecurity::sl_io_input(lua_State *L)
{
	if (lua_isstring(L, 1)) {
		const char *path = lua_tostring(L, 1);
		CHECK_SECURE_PATH(L, path, false);
	}

	push_original(L, "io", "input");
	lua_pushvalue(L, 1);
	lua_call(L, 1, 1);
	return 1;
}


int ScriptApiSecurity::sl_io_output(lua_State *L)
{
	if (lua_isstring(L, 1)) {
		const char *path = lua_tostring(L, 1);
		CHECK_SECURE_PATH(L, path, true);
	}

	push_original(L, "io", "output");
	lua_pushvalue(L, 1);
	lua_call(L, 1, 1);
	return 1;
}


int ScriptApiSecurity::sl_io_lines(lua_State *L)
{
	if (lua_isstring(L, 1)) {
		const char *path = lua_tostring(L, 1);
		CHECK_SECURE_PATH(L, path, false);
	}

	int top_precall = lua_gettop(L);
	push_original(L, "io", "lines");
	lua_pushvalue(L, 1);
	lua_call(L, 1, LUA_MULTRET);
	// Return number of arguments returned by the function,
	// adjusting for the function being poped.
	return lua_gettop(L) - top_precall;
}


int ScriptApiSecurity::sl_os_rename(lua_State *L)
{
	luaL_checktype(L, 1, LUA_TSTRING);
	const char *path1 = lua_tostring(L, 1);
	CHECK_SECURE_PATH(L, path1, true);

	luaL_checktype(L, 2, LUA_TSTRING);
	const char *path2 = lua_tostring(L, 2);
	CHECK_SECURE_PATH(L, path2, true);

	push_original(L, "os", "rename");
	lua_pushvalue(L, 1);
	lua_pushvalue(L, 2);
	lua_call(L, 2, 2);
	return 2;
}


int ScriptApiSecurity::sl_os_remove(lua_State *L)
{
	luaL_checktype(L, 1, LUA_TSTRING);
	const char *path = lua_tostring(L, 1);
	CHECK_SECURE_PATH(L, path, true);

	push_original(L, "os", "remove");
	lua_pushvalue(L, 1);
	lua_call(L, 1, 2);
	return 2;
}


int ScriptApiSecurity::sl_os_setlocale(lua_State *L)
{
	const bool cat = lua_gettop(L) > 1;
	// Don't allow changes
	if (!lua_isnoneornil(L, 1)) {
		lua_pushnil(L);
		return 1;
	}

	push_original(L, "os", "setlocale");
	lua_pushnil(L);
	if (cat)
		lua_pushvalue(L, 2);
	lua_call(L, cat ? 2 : 1, 1);
	return 1;
}
