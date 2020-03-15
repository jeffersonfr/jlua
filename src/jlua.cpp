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
#include "event.h"

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

std::string KeySymbolToString(jevent::jkeyevent_symbol_t param) 
{
	if (param == jevent::JKS_SPACE) {
		return "space";
	} else if (param == jevent::JKS_ENTER) {
		return "enter";
	} else if (param == jevent::JKS_1) {
		return "1";
	} else if (param == jevent::JKS_2) {
		return "2";
	} else if (param == jevent::JKS_3) {
		return "3";
	} else if (param == jevent::JKS_4) {
		return "4";
	} else if (param == jevent::JKS_5) {
		return "5";
	} else if (param == jevent::JKS_6) {
		return "6";
	} else if (param == jevent::JKS_7) {
		return "7";
	} else if (param == jevent::JKS_8) {
		return "8";
	} else if (param == jevent::JKS_9) {
		return "9";
	} else if (param == jevent::JKS_0) {
		return "0";
	} else if (param == jevent::JKS_CURSOR_LEFT) {
		return "left";
	} else if (param == jevent::JKS_CURSOR_RIGHT) {
		return "right";
	} else if (param == jevent::JKS_CURSOR_UP) {
		return "up";
	} else if (param == jevent::JKS_CURSOR_DOWN) {
		return "down";
	}

	return "unknown";
}

std::string MouseButtonToString(jevent::jmouseevent_button_t param) 
{
	return "buton1";
}

bool jLua::KeyPressed(jevent::KeyEvent *event)
{
	Event::keys[KeySymbolToString(event->GetSymbol())] = {
		"pressed", std::chrono::steady_clock::now()
	};

	return true;
}

bool jLua::KeyReleased(jevent::KeyEvent *event)
{
	Event::keys[KeySymbolToString(event->GetSymbol())] = {
		"released", std::chrono::steady_clock::now()
	};

	return true;
}

bool jLua::MousePressed(jevent::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(event->GetButton())] = {
		"pressed", std::chrono::steady_clock::now(), event->GetLocation()
	};

	return true;
}

bool jLua::MouseReleased(jevent::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(event->GetButton())] = {
		"released", std::chrono::steady_clock::now(), event->GetLocation()
	};

	return true;
}

bool jLua::MouseMoved(jevent::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(event->GetButton())] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation()
	};

	return true;
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
	Event::Register(l);
	
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
