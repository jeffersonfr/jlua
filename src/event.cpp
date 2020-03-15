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
#include "event.h"
#include "jlua.h"
#include "utils.h"

#include "jgui/jbufferedimage.h"

std::string
  Event::global_name = "event";

std::map<std::string, Event::key_state_t>
	Event::keys;
std::map<std::string, Event::pointer_state_t>
	Event::pointers;

static const std::string
  local_name = std::string("luaL_") + Event::global_name;

Event * l_CheckEvent(lua_State *l, int n)
{
	return *(Event **)luaL_checkudata(l, n, local_name.c_str());
}

int lua_Event_key(lua_State *l)
{
	std::chrono::steady_clock::time_point
		now = std::chrono::steady_clock::now();

  if (lua_gettop(l) == 1) { // INFO:("key"): returns the key state
    std::string
      key = luaL_checkstring(l, 1);

		lua_createtable(l, 0, 2);

		lua_pushstring(l, Event::keys[key].state.c_str());
		lua_setfield(l, -2, "state");
	
		lua_pushnumber(l, (now - Event::keys[key].timestamp).count());
		lua_setfield(l, -2, "interval");
	
		Event::keys[key].timestamp = now;

		return 1;
  }
	
  lua_dump(l, "event:key() => invalid parameters");

	return 0;
}

int lua_Event_pointer(lua_State *l)
{
  if (lua_gettop(l) == 1) { // INFO:("button"): returns the pointer state
	/*
    std::string
      path = luaL_checkstring(l, 1);

    Event
      **udata = (Event **)lua_newuserdata(l, sizeof(Event *));

    *udata = new Event(new jgui::BufferedImage(path));
		*/
  }
	
	luaL_getmetatable(l, local_name.c_str());
	lua_setmetatable(l, -2);

	return 1;
}

Event::Event()
{
}

Event::~Event()
{
}

void Event::Register(lua_State *l)
{
	luaL_Reg 
		sEventRegs[] = {
			{ "key", lua_Event_key },
			{ "pointer", lua_Event_pointer },
			{ NULL, NULL }
		};

	luaL_newmetatable(l, local_name.c_str());
	luaL_setfuncs(l, sEventRegs, 0);
	lua_pushvalue(l, -1);
	lua_setfield(l, -1, "__index");
	lua_setglobal(l, Event::global_name.c_str());
}

