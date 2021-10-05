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

local function input_password_formspec(data)
  local hint = ""
  local content = data.content
  if content.ok == false then
    hint = fgettext("Password wrong")
    content.ok = nil
  end
  local retval =
    "size[10,4.5]" ..
    "pwdfield[2,2;5,;password;".. fgettext("Password") .."]" ..
    "style[dlg_input_password_confirm;bgcolor=blue]" ..
    "label[2, 2.8;".. hint .. "]" ..
    "button[3.25,3.5;2.5,0.5;dlg_input_password_confirm;" .. fgettext("Ok") .. "]" ..
    "button[5.75,3.5;2.5,0.5;dlg_input_password_cancel;" .. fgettext("Cancel") .. "]"

  return retval
end

--------------------------------------------------------------------------------
local function input_password_buttonhandler(this, fields)
  if fields["dlg_input_password_confirm"] ~= nil or fields["key_enter_field"] == "password" then
    local content = this.data.content
    local handler = this.data.handler
    local parent = this.parent
    content.password = fields["password"]
    if (type(handler) == "function") then
      if not handler(parent, fields, true) then
        content.ok = false
        fields["password"] = ""
        return true
      end
      this.data.ok = true
    end
    this:delete()
    return true
  end

  if fields["dlg_input_password_cancel"] then
    this:delete()
    return true
  end

  return false
end

--------------------------------------------------------------------------------
function create_input_password_dlg(content, handler)
  local retval = dialog_create("dlg_input_password",
          input_password_formspec,
          input_password_buttonhandler,
          nil)
  retval.data.content = content
  retval.data.handler = handler
  return retval
end
