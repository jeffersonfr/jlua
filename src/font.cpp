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
#include "font.h"
#include "jlua.h"

static const std::string
  METATABLE = "luaL_font";

static int lua_Font_new(lua_State *l)
{
  if (lua_gettop(l) == 1) { // INFO:(size): create a new font using the size parameter
    int
      size = luaL_checknumber(l, 1);

    Font
      **udata = (Font **)lua_newuserdata(l, sizeof(Font *));

    *udata = new Font(size);
  }

	luaL_getmetatable(l, METATABLE.c_str());
	lua_setmetatable(l, -2);

	return 1;
}

static int lua_Font_gc(lua_State *l)
{
	Font 
		*font = Font::Check(l, 1);

	delete font;

	return 0;
}

static int lua_Font_size(lua_State *l)
{
  Font 
    *font = Font::Check(l, 1);

  if (lua_gettop(l) == 1) { // INFO:(): returns the font size
		lua_pushnumber(l, font->font->GetSize());

		return 1;
  }
	
  lua_dump(l, "font:size() => invalid parameters");

	return 0;
}

static int lua_Font_extends(lua_State *l)
{
  Font 
    *font = Font::Check(l, 1);
	
  if (lua_gettop(l) == 2) { // INFO:: font:extends(str)
    std::string
      text = luaL_checkstring(l, 2);
    jcanvas::jpoint_t<int>
      size {0, 0};

    if (font != nullptr) {
      jcanvas::jfont_extends_t 
        t = font->font->GetStringExtends(text);

      size = jcanvas::jpoint_t<float>{t.size.x - t.bearing.x - (t.advance.x - t.size.x), t.size.y - t.bearing.y};
    }

		lua_pushnumber(l, size.x);
		lua_pushnumber(l, size.y);

		return 2;
	}

  lua_dump(l, "font:extends() => invalid parameters");

	return 0;
}

Font::Font(int size)
{
	font = std::make_shared<jcanvas::Font>("default", (jcanvas::jfont_attributes_t)(jcanvas::jfont_attributes_t::None), size);
}

Font::~Font()
{
	font = nullptr;
}

Font * Font::Check(lua_State *l, int n)
{
	return *(Font **)luaL_checkudata(l, n, METATABLE.c_str());
}

void Font::Register(lua_State *l)
{
	luaL_Reg 
		sFontRegs[] = {
			{ "new", lua_Font_new },
			{ "__gc", lua_Font_gc },
			{ "size", lua_Font_size },
			{ "extends", lua_Font_extends },
			{ NULL, NULL }
		};

	luaL_newmetatable(l, METATABLE.c_str());
	luaL_setfuncs(l, sFontRegs, 0);
	lua_pushvalue(l, -1);
	lua_setfield(l, -1, "__index");
	lua_setglobal(l, METATABLE.substr(5).c_str());
}

