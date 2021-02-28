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
#include "mixer.h"
#include "utils.h"

#include "jcanvas/core/japplication.h"
#include "jcanvas/core/jbufferedimage.h"

#include <filesystem>

extern "C" {
  #include <lua.h>
  #include <lauxlib.h>
  #include <lualib.h>
}

static lua_State 
	*l = nullptr;

jLua::jLua():
	jcanvas::Window({1280, 720})
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

static std::string KeySymbolToString(jcanvas::jkeyevent_symbol_t param) 
{
	if (param == jcanvas::JKS_SPACE) {
		return "space";
	} else if (param == jcanvas::JKS_ENTER) {
		return "enter";
	} else if (param == jcanvas::JKS_1) {
		return "1";
	} else if (param == jcanvas::JKS_2) {
		return "2";
	} else if (param == jcanvas::JKS_3) {
		return "3";
	} else if (param == jcanvas::JKS_4) {
		return "4";
	} else if (param == jcanvas::JKS_5) {
		return "5";
	} else if (param == jcanvas::JKS_6) {
		return "6";
	} else if (param == jcanvas::JKS_7) {
		return "7";
	} else if (param == jcanvas::JKS_8) {
		return "8";
	} else if (param == jcanvas::JKS_9) {
		return "9";
	} else if (param == jcanvas::JKS_0) {
		return "0";
	} else if (param == jcanvas::JKS_A) {
		return "A";
	} else if (param == jcanvas::JKS_B) {
		return "B";
	} else if (param == jcanvas::JKS_C) {
		return "C";
	} else if (param == jcanvas::JKS_D) {
		return "D";
	} else if (param == jcanvas::JKS_E) {
		return "E";
	} else if (param == jcanvas::JKS_F) {
		return "F";
	} else if (param == jcanvas::JKS_G) {
		return "G";
	} else if (param == jcanvas::JKS_H) {
		return "H";
	} else if (param == jcanvas::JKS_I) {
		return "I";
	} else if (param == jcanvas::JKS_J) {
		return "J";
	} else if (param == jcanvas::JKS_K) {
		return "K";
	} else if (param == jcanvas::JKS_L) {
		return "L";
	} else if (param == jcanvas::JKS_M) {
		return "M";
	} else if (param == jcanvas::JKS_N) {
		return "N";
	} else if (param == jcanvas::JKS_O) {
		return "O";
	} else if (param == jcanvas::JKS_P) {
		return "P";
	} else if (param == jcanvas::JKS_Q) {
		return "Q";
	} else if (param == jcanvas::JKS_R) {
		return "R";
	} else if (param == jcanvas::JKS_S) {
		return "S";
	} else if (param == jcanvas::JKS_T) {
		return "T";
	} else if (param == jcanvas::JKS_U) {
		return "U";
	} else if (param == jcanvas::JKS_V) {
		return "V";
	} else if (param == jcanvas::JKS_W) {
		return "W";
	} else if (param == jcanvas::JKS_X) {
		return "X";
	} else if (param == jcanvas::JKS_Y) {
		return "Y";
	} else if (param == jcanvas::JKS_Z) {
		return "Z";
	} else if (param == jcanvas::JKS_a) {
		return "a";
	} else if (param == jcanvas::JKS_b) {
		return "b";
	} else if (param == jcanvas::JKS_c) {
		return "c";
	} else if (param == jcanvas::JKS_d) {
		return "d";
	} else if (param == jcanvas::JKS_e) {
		return "e";
	} else if (param == jcanvas::JKS_f) {
		return "f";
	} else if (param == jcanvas::JKS_g) {
		return "g";
	} else if (param == jcanvas::JKS_h) {
		return "h";
	} else if (param == jcanvas::JKS_i) {
		return "i";
	} else if (param == jcanvas::JKS_j) {
		return "j";
	} else if (param == jcanvas::JKS_k) {
		return "k";
	} else if (param == jcanvas::JKS_l) {
		return "l";
	} else if (param == jcanvas::JKS_m) {
		return "m";
	} else if (param == jcanvas::JKS_n) {
		return "n";
	} else if (param == jcanvas::JKS_o) {
		return "o";
	} else if (param == jcanvas::JKS_p) {
		return "p";
	} else if (param == jcanvas::JKS_q) {
		return "q";
	} else if (param == jcanvas::JKS_r) {
		return "r";
	} else if (param == jcanvas::JKS_s) {
		return "s";
	} else if (param == jcanvas::JKS_t) {
		return "t";
	} else if (param == jcanvas::JKS_u) {
		return "u";
	} else if (param == jcanvas::JKS_v) {
		return "v";
	} else if (param == jcanvas::JKS_w) {
		return "w";
	} else if (param == jcanvas::JKS_x) {
		return "x";
	} else if (param == jcanvas::JKS_y) {
		return "y";
	} else if (param == jcanvas::JKS_z) {
		return "z";
	} else if (param == jcanvas::JKS_CURSOR_LEFT) {
		return "left";
	} else if (param == jcanvas::JKS_CURSOR_RIGHT) {
		return "right";
	} else if (param == jcanvas::JKS_CURSOR_UP) {
		return "up";
	} else if (param == jcanvas::JKS_CURSOR_DOWN) {
		return "down";
	} else if (param == jcanvas::JKS_SHIFT) {
		return "shift";
	} else if (param == jcanvas::JKS_ALT) {
		return "alt";
	} else if (param == jcanvas::JKS_CONTROL) {
		return "ctrl";
  }

	return "unknown";
}

static std::string MouseButtonToString(jcanvas::jmouseevent_button_t param) 
{
	if (param == jcanvas::JMB_BUTTON1) {
		return "0";
	} else if (param == jcanvas::JMB_BUTTON2) {
		return "1";
	} else if (param == jcanvas::JMB_BUTTON3) {
		return "2";
	}

	return "unknown";
}

bool jLua::KeyPressed(jcanvas::KeyEvent *event)
{
	Event::keys[KeySymbolToString(event->GetSymbol())] = {
		"pressed", std::chrono::steady_clock::now()
	};

	return true;
}

bool jLua::KeyReleased(jcanvas::KeyEvent *event)
{
	Event::keys[KeySymbolToString(event->GetSymbol())] = {
		"released", std::chrono::steady_clock::now()
	};

	return true;
}

bool jLua::MousePressed(jcanvas::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(event->GetButton())] = {
		"pressed", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	return true;
}

bool jLua::MouseReleased(jcanvas::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(event->GetButton())] = {
		"released", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	return true;
}

bool jLua::MouseMoved(jcanvas::MouseEvent *event)
{
	Event::pointers[MouseButtonToString(jcanvas::JMB_BUTTON1)] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	Event::pointers[MouseButtonToString(jcanvas::JMB_BUTTON2)] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	Event::pointers[MouseButtonToString(jcanvas::JMB_BUTTON3)] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	return true;
}

void jLua::WindowOpened(jcanvas::WindowEvent *event)
{
}

void jLua::WindowClosing(jcanvas::WindowEvent *event)
{
}

void jLua::WindowClosed(jcanvas::WindowEvent *event)
{
}

void jLua::WindowResized(jcanvas::WindowEvent *event)
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

void jLua::WindowMoved(jcanvas::WindowEvent *event)
{
}

void jLua::WindowPainted(jcanvas::WindowEvent *event)
{
}

void jLua::WindowEntered(jcanvas::WindowEvent *event)
{
}

void jLua::WindowLeaved(jcanvas::WindowEvent *event)
{
}

void jLua::Paint(jcanvas::Graphics *g)
{
  jcanvas::Window::Paint(g);

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

  g->SetCompositeFlags(jcanvas::JCF_SRC_OVER);

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
	Mixer::Register(l);
	
  Initialize();

	if (luaL_dofile(l, path.c_str())) {
    std::cout << luaL_checkstring(l, -1) << std::endl;
    
    return false;
	}

  return true;
}

jcanvas::Graphics * jLua::GetGraphicLayer()
{
	return _graphicLayer;
}
