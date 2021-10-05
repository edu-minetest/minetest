--Minetest Edu
--Copyright (C) 2021 Riceball LEE<snowyu.lee@gmail.com>
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

--------------------------------------------------------------------------------

local function change_password_formspec(data)
  local hint = ""
  local content = data.content
  if content.ok == false then
    hint = fgettext("Password wrong")
    content.ok = nil
  end
  local retval = {
    "size[11.5,4.5,true]",
  }
  if content.oldPasswd then
    table.insert(retval, table.concat({"pwdfield[2,1;5,;oldPassword;" , fgettext("Old Password") , "]"}, ""))
  end

  table.insert(retval, table.concat({
    "pwdfield[2,2;5,;password;", fgettext("New Password") , "]",
    "style[dlg_change_password_confirm;bgcolor=blue]",
    "label[2, 2.8;", hint , "]",
    "button[3.25,3.5;2.5,0.5;dlg_change_password_confirm;" , fgettext("Ok") , "]",
    "button[5.75,3.5;2.5,0.5;dlg_change_password_cancel;" , fgettext("Cancel") , "]"
  }, ""))

  return table.concat(retval, "")
end

--------------------------------------------------------------------------------
local function change_password_buttonhandler(this, fields)
  if fields["dlg_change_password_confirm"] ~= nil or fields["key_enter_field"] == "password" then
    local content = this.data.content
    local handler = this.data.handler
    local parent = this.parent
    local originalPasswd = content.oldPasswd
    local newPasswd = fields["password"]
    local oldPasswd = fields["oldPassword"]
    if originalPasswd and originalPasswd ~= "" then
      if (oldPasswd and oldPasswd ~= "") then oldPasswd = core.encode_base64(oldPasswd) end
      if (oldPasswd ~= originalPasswd) then
        content.ok = false
        return true
      end
    end
    if (newPasswd and newPasswd ~= "") then
      newPasswd = core.encode_base64(newPasswd)
    end

    if (type(handler) == "function") then
      handler(newPasswd, parent, true)
      this.data.ok = true
    end
    this:delete()
    return true
  end

  if fields["dlg_change_password_cancel"] then
    this:delete()
    return true
  end

  return false
end

--------------------------------------------------------------------------------
function create_change_password_dlg(content, handler)
  local retval = dialog_create("dlg_change_password",
    change_password_formspec,
    change_password_buttonhandler,
    nil
  )
  retval.data.content = content
  retval.data.handler = handler
  return retval
end
