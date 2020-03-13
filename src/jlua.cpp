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
#include "jlua.h"
#include "canvas.h"

#include "jgui/japplication.h"
#include "jgui/jgraphics.h"

extern "C" {
  #include <lua.h>
  #include <lauxlib.h>
  #include <lualib.h>
}

lua_State *l = nullptr;

jLua::jLua():
	jgui::Window({1280, 720})
{
}

jLua::~jLua()
{
	lua_close(l);
}

jLua & jLua::Instance()
{
	static jLua instance;

	return instance;
}

void jLua::Paint(jgui::Graphics *g)
{
  static std::chrono::steady_clock::time_point
    last = std::chrono::steady_clock::now();

  std::chrono::steady_clock::time_point
    now = std::chrono::steady_clock::now();
  float
    tick = std::chrono::duration<float>(now - last).count();

  last = now;

  // INFO:: call render method in lua
  if (lua_getglobal(l, "render") != LUA_TNIL) {
    lua_pushnumber(l, tick);

    if (lua_pcall(l, 1, 1, 0)) {
      luaL_error(l, luaL_checkstring(l, -1));
    }
  } else {
    lua_pop(l, -1);
  }

  g->SetCompositeFlags(jgui::JCF_SRC_OVER);

	_mutex.lock();

	for (auto object : _objects) {
		if (object->visible == false) {
			continue;
		}

		g->DrawImage(object->image, {{0, 0}, object->image->GetSize()});
	}

	_mutex.unlock();

  Repaint();
}

bool jLua::Load(std::string path)
{
  l = luaL_newstate();

	luaL_openlibs(l);

	Canvas::Register(l);
	
	if (luaL_dofile(l, path.c_str())) {
    std::cout << luaL_checkstring(l, -1) << std::endl;
    
    return false;
	}

  return true;
}

void jLua::Add(Canvas *object)
{
	_mutex.lock();

	_objects.push_back(object);

	_mutex.unlock();
}

void jLua::Remove(Canvas *object)
{
	_mutex.lock();

	decltype(_objects)::iterator 
		i = std::find(_objects.begin(), _objects.end(), object);
		
	if (i != _objects.end()) {
		_objects.erase(i);
	}

	_mutex.unlock();
}
