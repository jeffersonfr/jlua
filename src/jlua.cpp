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
	if (param == jcanvas::jkeyevent_symbol_t::Space) {
		return "space";
	} else if (param == jcanvas::jkeyevent_symbol_t::Enter) {
		return "enter";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number1) {
		return "1";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number2) {
		return "2";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number3) {
		return "3";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number4) {
		return "4";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number5) {
		return "5";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number6) {
		return "6";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number7) {
		return "7";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number8) {
		return "8";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number9) {
		return "9";
	} else if (param == jcanvas::jkeyevent_symbol_t::Number0) {
		return "0";
	} else if (param == jcanvas::jkeyevent_symbol_t::A) {
		return "A";
	} else if (param == jcanvas::jkeyevent_symbol_t::B) {
		return "B";
	} else if (param == jcanvas::jkeyevent_symbol_t::C) {
		return "C";
	} else if (param == jcanvas::jkeyevent_symbol_t::D) {
		return "D";
	} else if (param == jcanvas::jkeyevent_symbol_t::E) {
		return "E";
	} else if (param == jcanvas::jkeyevent_symbol_t::F) {
		return "F";
	} else if (param == jcanvas::jkeyevent_symbol_t::G) {
		return "G";
	} else if (param == jcanvas::jkeyevent_symbol_t::H) {
		return "H";
	} else if (param == jcanvas::jkeyevent_symbol_t::I) {
		return "I";
	} else if (param == jcanvas::jkeyevent_symbol_t::J) {
		return "J";
	} else if (param == jcanvas::jkeyevent_symbol_t::K) {
		return "K";
	} else if (param == jcanvas::jkeyevent_symbol_t::L) {
		return "L";
	} else if (param == jcanvas::jkeyevent_symbol_t::M) {
		return "M";
	} else if (param == jcanvas::jkeyevent_symbol_t::N) {
		return "N";
	} else if (param == jcanvas::jkeyevent_symbol_t::O) {
		return "O";
	} else if (param == jcanvas::jkeyevent_symbol_t::P) {
		return "P";
	} else if (param == jcanvas::jkeyevent_symbol_t::Q) {
		return "Q";
	} else if (param == jcanvas::jkeyevent_symbol_t::R) {
		return "R";
	} else if (param == jcanvas::jkeyevent_symbol_t::S) {
		return "S";
	} else if (param == jcanvas::jkeyevent_symbol_t::T) {
		return "T";
	} else if (param == jcanvas::jkeyevent_symbol_t::U) {
		return "U";
	} else if (param == jcanvas::jkeyevent_symbol_t::V) {
		return "V";
	} else if (param == jcanvas::jkeyevent_symbol_t::W) {
		return "W";
	} else if (param == jcanvas::jkeyevent_symbol_t::X) {
		return "X";
	} else if (param == jcanvas::jkeyevent_symbol_t::Y) {
		return "Y";
	} else if (param == jcanvas::jkeyevent_symbol_t::Z) {
		return "Z";
	} else if (param == jcanvas::jkeyevent_symbol_t::a) {
		return "a";
	} else if (param == jcanvas::jkeyevent_symbol_t::b) {
		return "b";
	} else if (param == jcanvas::jkeyevent_symbol_t::c) {
		return "c";
	} else if (param == jcanvas::jkeyevent_symbol_t::d) {
		return "d";
	} else if (param == jcanvas::jkeyevent_symbol_t::e) {
		return "e";
	} else if (param == jcanvas::jkeyevent_symbol_t::f) {
		return "f";
	} else if (param == jcanvas::jkeyevent_symbol_t::g) {
		return "g";
	} else if (param == jcanvas::jkeyevent_symbol_t::h) {
		return "h";
	} else if (param == jcanvas::jkeyevent_symbol_t::i) {
		return "i";
	} else if (param == jcanvas::jkeyevent_symbol_t::j) {
		return "j";
	} else if (param == jcanvas::jkeyevent_symbol_t::k) {
		return "k";
	} else if (param == jcanvas::jkeyevent_symbol_t::l) {
		return "l";
	} else if (param == jcanvas::jkeyevent_symbol_t::m) {
		return "m";
	} else if (param == jcanvas::jkeyevent_symbol_t::n) {
		return "n";
	} else if (param == jcanvas::jkeyevent_symbol_t::o) {
		return "o";
	} else if (param == jcanvas::jkeyevent_symbol_t::p) {
		return "p";
	} else if (param == jcanvas::jkeyevent_symbol_t::q) {
		return "q";
	} else if (param == jcanvas::jkeyevent_symbol_t::r) {
		return "r";
	} else if (param == jcanvas::jkeyevent_symbol_t::s) {
		return "s";
	} else if (param == jcanvas::jkeyevent_symbol_t::t) {
		return "t";
	} else if (param == jcanvas::jkeyevent_symbol_t::u) {
		return "u";
	} else if (param == jcanvas::jkeyevent_symbol_t::v) {
		return "v";
	} else if (param == jcanvas::jkeyevent_symbol_t::w) {
		return "w";
	} else if (param == jcanvas::jkeyevent_symbol_t::x) {
		return "x";
	} else if (param == jcanvas::jkeyevent_symbol_t::y) {
		return "y";
	} else if (param == jcanvas::jkeyevent_symbol_t::z) {
		return "z";
	} else if (param == jcanvas::jkeyevent_symbol_t::CursorLeft) {
		return "left";
	} else if (param == jcanvas::jkeyevent_symbol_t::CursorRight) {
		return "right";
	} else if (param == jcanvas::jkeyevent_symbol_t::CursorUp) {
		return "up";
	} else if (param == jcanvas::jkeyevent_symbol_t::CursorDown) {
		return "down";
	} else if (param == jcanvas::jkeyevent_symbol_t::Shift) {
		return "shift";
	} else if (param == jcanvas::jkeyevent_symbol_t::Alt) {
		return "alt";
	} else if (param == jcanvas::jkeyevent_symbol_t::Control) {
		return "ctrl";
  }

	return "unknown";
}

static std::string MouseButtonToString(jcanvas::jmouseevent_button_t param) 
{
	if (param == jcanvas::jmouseevent_button_t::Button1) {
		return "0";
	} else if (param == jcanvas::jmouseevent_button_t::Button2) {
		return "1";
	} else if (param == jcanvas::jmouseevent_button_t::Button3) {
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
	Event::pointers[MouseButtonToString(jcanvas::jmouseevent_button_t::Button1)] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	Event::pointers[MouseButtonToString(jcanvas::jmouseevent_button_t::Button2)] = {
		"moved", std::chrono::steady_clock::now(), event->GetLocation(), event->GetClicks()
	};

	Event::pointers[MouseButtonToString(jcanvas::jmouseevent_button_t::Button3)] = {
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

  g->SetCompositeFlags(jcanvas::jcomposite_flags_t::SrcOver);

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
