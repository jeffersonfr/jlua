/***************************************************************************
 *   Copyright (C) 2005 by Jeff Ferr                                       *
 *   root@sat                                                              *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#include "display.h"
#include "jlua.h"

static const std::string
  METATABLE = "luaL_display";

static int lua_Display_size(lua_State *l)
{
  jgui::jsize_t<int>
    size = jLua::Instance().GetGraphicLayer()->GetSize();
		
	if (lua_gettop(l) == 0) {
		lua_pushinteger(l, size.width);
		lua_pushinteger(l, size.height);

		return 2;
	} else if (lua_gettop(l) == 2) {
    const int
      w = luaL_checknumber(l, 1),
      h = luaL_checknumber(l, 2);
    
		jLua::Instance().SetSize({w, h});

		return 0;
	}

	lua_dump(l, "display:size() => invalid parameters");

	return 0;
}

Display::Display()
{
}

Display::~Display()
{
}

Display * Display::Check(lua_State *l, int n)
{
	return *(Display **)luaL_checkudata(l, n, METATABLE.c_str());
}

void Display::Register(lua_State *l)
{
	luaL_Reg 
		sDisplayRegs[] = {
			{ "size", lua_Display_size},
			{ NULL, NULL }
		};

	luaL_newmetatable(l, METATABLE.c_str());
	luaL_setfuncs(l, sDisplayRegs, 0);
	lua_pushvalue(l, -1);
	lua_setfield(l, -1, "__index");
	lua_setglobal(l, METATABLE.substr(5).c_str());
}

