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
#include "display.h"
#include "canvas.h"
#include "font.h"
#include "event.h"
#include "utils.h"

#include "jgui/japplication.h"
#include "jgui/jbufferedimage.h"

#include <filesystem>

extern "C" {
  #include <lua.h>
  #include <lauxlib.h>
  #include <lualib.h>
}

static lua_State 
	*l = nullptr;

jLua::jLua():
	jgui::Window({1280, 720})
{
	RegisterWindowListener(this);
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

void ModifiersToString(jevent::jkeyevent_modifiers_t param)
{
	Event::keys["alt"] = {
		"released", std::chrono::steady_clock::now()
	};

	Event::keys["ctrl"] = {
		"released", std::chrono::steady_clock::now()
	};

  if ((jevent::jkeyevent_modifiers_t)(param & jevent::JKM_ALT)) {
    Event::keys["alt"] = {
      "pressed", std::chrono::steady_clock::now()
    };
  }
  
  if ((jevent::jkeyevent_modifiers_t)(param & jevent::JKM_CONTROL)) {
    Event::keys["ctrl"] = {
      "pressed", std::chrono::steady_clock::now()
    };
  }
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
	} else if (param == jevent::JKS_a) {
		return "a";
	} else if (param == jevent::JKS_b) {
		return "b";
	} else if (param == jevent::JKS_c) {
		return "c";
	} else if (param == jevent::JKS_d) {
		return "d";
	} else if (param == jevent::JKS_e) {
		return "e";
	} else if (param == jevent::JKS_f) {
		return "f";
	} else if (param == jevent::JKS_g) {
		return "g";
	} else if (param == jevent::JKS_h) {
		return "h";
	} else if (param == jevent::JKS_i) {
		return "i";
	} else if (param == jevent::JKS_j) {
		return "j";
	} else if (param == jevent::JKS_k) {
		return "k";
	} else if (param == jevent::JKS_l) {
		return "l";
	} else if (param == jevent::JKS_m) {
		return "m";
	} else if (param == jevent::JKS_n) {
		return "n";
	} else if (param == jevent::JKS_o) {
		return "o";
	} else if (param == jevent::JKS_p) {
		return "p";
	} else if (param == jevent::JKS_q) {
		return "q";
	} else if (param == jevent::JKS_r) {
		return "r";
	} else if (param == jevent::JKS_s) {
		return "s";
	} else if (param == jevent::JKS_t) {
		return "t";
	} else if (param == jevent::JKS_u) {
		return "u";
	} else if (param == jevent::JKS_v) {
		return "v";
	} else if (param == jevent::JKS_w) {
		return "w";
	} else if (param == jevent::JKS_x) {
		return "x";
	} else if (param == jevent::JKS_y) {
		return "y";
	} else if (param == jevent::JKS_z) {
		return "z";
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
	if (param == jevent::JMB_BUTTON1) {
		return "0";
	} else if (param == jevent::JMB_BUTTON2) {
		return "1";
	} else if (param == jevent::JMB_BUTTON3) {
		return "2";
	}

	return "unknown";
}

bool jLua::KeyPressed(jevent::KeyEvent *event)
{
	Event::keys[KeySymbolToString(event->GetSymbol())] = {
		"pressed", std::chrono::steady_clock::now()
	};

	ModifiersToString(event->GetModifiers());

	return true;
}

bool jLua::KeyReleased(jevent::KeyEvent *event)
{
	Event::keys[KeySymbolToString(event->GetSymbol())] = {
		"released", std::chrono::steady_clock::now()
	};

	ModifiersToString(event->GetModifiers());

	return true;
}

bool jLua::MousePressed(jevent::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(event->GetButton())] = {
		"pressed", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	return true;
}

bool jLua::MouseReleased(jevent::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(event->GetButton())] = {
		"released", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	return true;
}

bool jLua::MouseMoved(jevent::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(jevent::JMB_BUTTON1)] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	Event::pointers[MouseButtonToString(jevent::JMB_BUTTON2)] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	Event::pointers[MouseButtonToString(jevent::JMB_BUTTON3)] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	return true;
}

void jLua::WindowOpened(jevent::WindowEvent *event)
{
}

void jLua::WindowClosing(jevent::WindowEvent *event)
{
}

void jLua::WindowClosed(jevent::WindowEvent *event)
{
}

void jLua::WindowResized(jevent::WindowEvent *event)
{
  // INFO:: call configure method in lua
  if (lua_getglobal(l, "configure") != LUA_TNIL) {
    if (lua_pcall(l, 0, 0, 0)) {
      luaL_error(l, luaL_checkstring(l, -1));
    }
  } else {
    lua_pop(l, -1);
  }
}

void jLua::WindowMoved(jevent::WindowEvent *event)
{
}

void jLua::WindowPainted(jevent::WindowEvent *event)
{
}

void jLua::WindowEntered(jevent::WindowEvent *event)
{
}

void jLua::WindowLeaved(jevent::WindowEvent *event)
{
}

void jLua::Paint(jgui::Graphics *g)
{
  jgui::Window::Paint(g);

	_lua_mutex.lock();

  _graphicLayer = g;

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

    if (lua_pcall(l, 1, 0, 0)) {
      luaL_error(l, luaL_checkstring(l, -1));
    }
  } else {
    lua_pop(l, -1);
  }
	
	_lua_mutex.unlock();

  g->SetCompositeFlags(jgui::JCF_SRC_OVER);

  Repaint();
}

void jLua::Initialize()
{
  lua_createtable(l, 2, 0);

  lua_pushstring(l, R"(
    Copyright (C) 2010 by Jeff Ferr
    
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the
    Free Software Foundation, Inc.,
    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.)");
  lua_setfield(l, -2, "license");

  lua_pushstring(l, "api");
  lua_setfield(l, -2, "type");

  lua_pushstring(l, "jlua");
  lua_setfield(l, -2, "name");

  lua_pushstring(l, "0.0.1");
  lua_setfield(l, -2, "version");

  lua_pushstring(l, "jlua game engine");
  lua_setfield(l, -2, "description");

  lua_pushstring(l, "https://github.com/jlua");
  lua_setfield(l, -2, "url");

  lua_pushstring(l, base.c_str());
  lua_setfield(l, -2, "base");

  lua_setglobal(l, "jlua");
	
  luaL_dofile(l, "scripts/config.lua");
}

bool jLua::Load(std::string path)
{
  // INFO:: set the base directory
  base = std::filesystem::path(path).remove_filename();

  if (base.empty() == true) {
    base = ".";
  }

  // INFO:: create the lua state
  l = luaL_newstate();

	luaL_openlibs(l);

	Display::Register(l);
	Canvas::Register(l);
	Font::Register(l);
	Event::Register(l);
	
  Initialize();

	if (luaL_dofile(l, path.c_str())) {
    std::cout << luaL_checkstring(l, -1) << std::endl;
    
    return false;
	}

  return true;
}

jgui::Graphics * jLua::GetGraphicLayer()
{
	return _graphicLayer;
}
