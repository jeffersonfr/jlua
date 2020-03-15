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
#include "utils.h"

#include <iostream>

void lua_dump(lua_State *l, std::string msg)
{
  std::cout << "----------------- Stack Dump ----------------" << std::endl;

  for (int i=lua_gettop(l); i>=0; i--) {
    int 
      type = lua_type(l, i);
    std::string
      name = lua_typename(l, type);

    if (type == LUA_TSTRING) {
      std::cout << "[" << i << "]:<" << name << ">: " << lua_tostring(l, i) << std::endl;
    } else if (type == LUA_TBOOLEAN) {
      std::cout << "[" << i << "]:<" << name << ">: " << (bool)lua_toboolean(l, i) << std::endl;
    } else if (type == LUA_TNUMBER) {
      std::cout << "[" << i << "]:<" << name << ">: " << lua_tonumber(l, i) << std::endl;
    } else if (type == LUA_TNIL) {
      std::cout << "[" << i << "]:<" << name << ">: " << "nil" << std::endl;
    } else {
      std::string
        metatable = "<unknown>";

      if (lua_getmetatable(l, i) != 0) {
        lua_pushstring(l, "__name");
        lua_rawget(l, -2);

        metatable = luaL_checkstring(l, -1);
      }

      std::cout << "[" << i << "]:<" << name << ">: " << metatable << std::endl;
    }
  }

  std::cout << "------------------ End Dump -----------------" << std::endl;
  
  luaL_error(l, msg.c_str());
}

