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
#include "canvas.h"
#include "jlua.h"

#include "jgui/jbufferedimage.h"

#define LOG "\033[1m"
#define INFO "\033[42m"
#define WARN "\033[43m"
#define ERR "\033[41m"

#define Log(id, msg) { \
    std::ios_base::fmtflags flags(std::cout.flags()); \
    std::cout << id << "[" << __FILE__ << ":" << __LINE__ << "] \033[1m" << __PRETTY_FUNCTION__ << "\033[0m " << msg << std::endl; \
    std::cout.flags(flags); \
  }

std::string
  Canvas::global_name = "canvas";

static const std::string
  local_name = std::string("luaL_") + Canvas::global_name;

static void lua_dump(lua_State *l, std::string msg)
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

Canvas * l_CheckCanvas(lua_State *l, int n)
{
	return *(Canvas **)luaL_checkudata(l, n, local_name.c_str());
}

int lua_Canvas_new(lua_State *l)
{
  if (lua_gettop(l) == 0) { // INFO:(): get a full canvas that is rendered in main loop
    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas();
	
    jLua::Instance().Add(*udata);
  } else if (lua_gettop(l) == 1) { // INFO:(path): loads the image and render in a image buffer
    std::string
      path = luaL_checkstring(l, 1);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(new jgui::BufferedImage(path));
  } else if (lua_gettop(l) == 2) { // INFO:(w, h): create a image buffer to be used during the execution
    const int
      w = luaL_checknumber(l, 1),
      h = luaL_checknumber(l, 2);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(new jgui::BufferedImage(jgui::JPF_RGB32, {w, h}));
  }

	luaL_getmetatable(l, local_name.c_str());
	lua_setmetatable(l, -2);

	return 1;
}

int lua_Canvas_gc(lua_State *l)
{
	Canvas 
		*canvas = l_CheckCanvas(l, 1);

	jLua::Instance().Remove(canvas);

	delete canvas;

	return 0;
}

static int lua_Canvas_size(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::jsize_t<int>
    size = canvas->image->GetSize();
	
  if (lua_gettop(l) == 1) { // INFO:: canvas:size()
		lua_pushinteger(l, size.width);
		lua_pushinteger(l, size.height);
	
		return 2;
	}

  lua_dump(l, "canvas:size() => invalid parameters");

	return 0;
}

static int lua_Canvas_clear(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 1) { // INFO:: canvas:clear()
    g->SetCompositeFlags(jgui::JCF_SRC);
	  g->Clear();
    g->SetCompositeFlags(jgui::JCF_SRC_OVER);

		return 0;
  } else if (lua_gettop(l) == 5) { // INFO:: canvas:clear(r, g, b, a)
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3),
      w = (int)luaL_checknumber(l, 4),
      h = (int)luaL_checknumber(l, 5);

    g->SetCompositeFlags(jgui::JCF_SRC);
	  g->Clear({x, y, w, h});
    g->SetCompositeFlags(jgui::JCF_SRC_OVER);

		return 0;
	}

  lua_dump(l, "canvas:clear() => invalid parameters");

	return 0;
}

static int lua_Canvas_color(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();

  if (lua_gettop(l) == 1) { // INFO:(): returns the current color [r, g, b, a]
    jgui::jcolor_t<float> 
      color = g->GetColor();

    lua_pushnumber(l, color[2]);
    lua_pushnumber(l, color[1]);
    lua_pushnumber(l, color[0]);
    lua_pushnumber(l, color[3]);

    return 4;
  } else if (lua_gettop(l) == 2) {
    if (lua_type(l, 2) == LUA_TNUMBER) { // INFO:(uint32): sets the argb color value
      uint32_t
        color = luaL_checknumber(l, 2);

      g->SetColor(color);

      return 0;
    } else if (lua_type(l, 2) == LUA_TSTRING) { // INFO:("name"): sets the color name
      std::string
        color = luaL_checkstring(l, 2);

      g->SetColor(color);

      return 0;
    }
  } else if (lua_gettop(l) == 4) { // INFO:(r, g, b): sets the r, g, b color values
    uint8_t
      r0 = (uint8_t)luaL_checknumber(l, 2),
      g0 = (uint8_t)luaL_checknumber(l, 3),
      b0 = (uint8_t)luaL_checknumber(l, 4);

    g->SetColor(0xff000000 | (r0 << 16) | (g0 << 8) | b0);

    return 0;
  } else if (lua_gettop(l) == 5) { // INFO:(r, g, b, a): sets the r, g, b, a color values
    uint8_t
      r0 = (uint8_t)luaL_checknumber(l, 2),
      g0 = (uint8_t)luaL_checknumber(l, 3),
      b0 = (uint8_t)luaL_checknumber(l, 4),
      a0 = (uint8_t)luaL_checknumber(l, 5);

    g->SetColor((a0 << 24) | (r0 << 16) | (g0 << 8) | b0);

    return 0;
  }

  lua_dump(l, "canvas:color() => invalid parameters");

  return 0;
}

static int lua_Canvas_rect(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 6) { // INFO:: canvas:rect(method, x, y, w, h)
    std::string
      method = luaL_checkstring(l, 2);
    int 
      x = (int)luaL_checknumber(l, 3),
      y = (int)luaL_checknumber(l, 4),
      w = (int)luaL_checknumber(l, 5),
      h = (int)luaL_checknumber(l, 6);

    if (method == "draw") {
      g->DrawRectangle({x, y, w, h});
    } else { // if (method == "fill") {
      g->FillRectangle({x, y, w, h});
    }

		return 0;
	}

  lua_dump(l, "canvas:rect() => invalid parameters");

	return 0;
}

static int lua_Canvas_line(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 5) { // INFO:: canvas:line(method, x, y, w, h)
    int 
      x0 = (int)luaL_checknumber(l, 2),
      y0 = (int)luaL_checknumber(l, 3),
      x1 = (int)luaL_checknumber(l, 4),
      y1 = (int)luaL_checknumber(l, 5);

    g->DrawLine({x0, y0}, {x1, y1});

		return 0;
	}

  lua_dump(l, "canvas:line() => invalid parameters");

	return 0;
}

static int lua_Canvas_triangle(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 8) { // INFO:: canvas:triangle(method, x0, y0, x1, y1, x2, y2)
    std::string
      method = luaL_checkstring(l, 2);
    int 
      x0 = (int)luaL_checknumber(l, 3),
      y0 = (int)luaL_checknumber(l, 4),
      x1 = (int)luaL_checknumber(l, 5),
      y1 = (int)luaL_checknumber(l, 6),
      x2 = (int)luaL_checknumber(l, 7),
      y2 = (int)luaL_checknumber(l, 8);

    if (method == "draw") {
			g->DrawTriangle({x0, y0}, {x1, y1}, {x2, y2});
    } else { // if (method == "fill") {
			g->FillTriangle({x0, y0}, {x1, y1}, {x2, y2});
    }

		return 0;
	}

  lua_dump(l, "canvas:triangle() => invalid parameters");

	return 0;
}

static int lua_Canvas_arc(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 5) { // INFO:: canvas:arc(method, x, y, radius)
    std::string
      method = luaL_checkstring(l, 2);
    int 
      x = (int)luaL_checknumber(l, 3),
      y = (int)luaL_checknumber(l, 4),
      radius = (int)luaL_checknumber(l, 5);

    if (method == "draw") {
			g->DrawCircle({x, y}, radius);
    } else { // if (method == "fill") {
			g->FillCircle({x, y}, radius);
    }

		return 0;
  } else if (lua_gettop(l) == 6) { // INFO:: canvas:arc(method, x, y, sx, sy)
    std::string
      method = luaL_checkstring(l, 2);
    int 
      x = (int)luaL_checknumber(l, 3),
      y = (int)luaL_checknumber(l, 4),
      sx = (int)luaL_checknumber(l, 5),
      sy = (int)luaL_checknumber(l, 6);

    if (method == "draw") {
			g->DrawEllipse({x, y}, {sx, sy});
    } else { // if (method == "fill") {
			g->FillEllipse({x, y}, {sx, sy});
    }

		return 0;
  } else if (lua_gettop(l) == 8) { // INFO:: canvas:arc(method, x, y, sx, sy, arc0, arc1)
    std::string
      method = luaL_checkstring(l, 2);
    int 
      x = (int)luaL_checknumber(l, 3),
      y = (int)luaL_checknumber(l, 4),
      sx = (int)luaL_checknumber(l, 5),
      sy = (int)luaL_checknumber(l, 6),
      arc0 = (int)luaL_checknumber(l, 7),
      arc1 = (int)luaL_checknumber(l, 8);

    if (method == "draw") {
			g->DrawArc({x, y}, {sx, sy}, arc0, arc1);
    } else { // if (method == "fill") {
			g->FillArc({x, y}, {sx, sy}, arc0, arc1);
    }

		return 0;
	}

  lua_dump(l, "canvas:arc() => invalid parameters");

	return 0;
}

static int lua_Canvas_polygon(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) >= 4) { // INFO:: canvas:polygon(method, x, y [, x, y]*)
    std::string
      method = luaL_checkstring(l, 2); // open, close, odd, even
    int 
      x = (int)luaL_checknumber(l, 3),
      y = (int)luaL_checknumber(l, 4);
    int
      extra = lua_gettop(l) - 4;

    if (extra%2 == 0) {
      std::vector<jgui::jpoint_t<int>> 
        points;

			for (int i=0; i<extra; i+=2) {
        int 
          x = (int)luaL_checknumber(l, 5 + i + 0),
          y = (int)luaL_checknumber(l, 5 + i + 1);

				points.push_back({x, y});
			}

      if (method == "open") {
        g->DrawPolygon(jgui::jpoint_t<int>{x, y}, points, false);
      } else if (method == "close") {
        g->DrawPolygon(jgui::jpoint_t<int>{x, y}, points, true);
      } else if (method == "odd") {
        g->FillPolygon(jgui::jpoint_t<int>{x, y}, points, false);
      } else { // if (method == "even") {
        g->FillPolygon(jgui::jpoint_t<int>{x, y}, points, true);
      }

      return 0;
    }
	}

  lua_dump(l, "canvas:polygon() => invalid parameters");

	return 0;
}

static int lua_Canvas_pixels(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 3) { // INFO:: canvas:pixels(x, y) returns the argb at the {x, y} [r, g, b, a]
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3);
    uint32_t
      color = g->GetRGB({x, y});

    lua_pushinteger(l, (color >> 16) & 0xff);
    lua_pushinteger(l, (color >> 8) & 0xff);
    lua_pushinteger(l, (color >> 0) & 0xff);
    lua_pushinteger(l, (color >> 24) & 0xff);

		return 4;
  } else if (lua_gettop(l) == 4) { // INFO:: canvas:pixels(x, y, argb)
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3);
    uint32_t
      color = (uint32_t)luaL_checknumber(l, 4);

    g->SetRGB(color, {x, y});

		return 0;
  } else if (lua_gettop(l) == 5) { // INFO:: canvas:pixels(x, y, w, h)
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3),
      w = (int)luaL_checknumber(l, 4),
      h = (int)luaL_checknumber(l, 5);
    uint32_t
      buffer[w*h];

    g->GetRGBArray(buffer, {x, y, w, h});

    lua_newtable(l);

    for (int i=0; i<w*h; i++) {
      uint8_t
        r0 = (buffer[i] >> 0x10) & 0xff,
        g0 = (buffer[i] >> 0x08) & 0xff,
        b0 = (buffer[i] >> 0x00) & 0xff,
        a0 = (buffer[i] >> 0x18) & 0xff;

      lua_pushinteger(l, i*4 + 1);
      lua_pushinteger(l, r0);
      lua_settable(l, -3);

      lua_pushinteger(l, i*4 + 2);
      lua_pushinteger(l, g0);
      lua_settable(l, -3);

      lua_pushinteger(l, i*4 + 3);
      lua_pushinteger(l, b0);
      lua_settable(l, -3);

      lua_pushinteger(l, i*4 + 4);
      lua_pushinteger(l, a0);
      lua_settable(l, -3);
    }

    return 1;
  } else if (lua_gettop(l) == 7) { // INFO:: canvas:pixels(x, y, r, g, b, a)
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3),
      r0 = (int)luaL_checknumber(l, 4),
      g0 = (int)luaL_checknumber(l, 5),
      b0 = (int)luaL_checknumber(l, 6),
      a0 = (int)luaL_checknumber(l, 7);

    g->SetRGB((a0 & 0xff) << 0x18 | (r0 & 0xff) << 0x10 | (g0 & 0xff) << 0x08 | (b0 & 0xff), {x, y});

    return 0;
	}

  lua_dump(l, "canvas:pixels() => invalid parameters");

	return 0;
}

static int lua_Canvas_extends(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Font
    *font = canvas->image->GetGraphics()->GetFont();
	
  if (lua_gettop(l) == 2) { // INFO:: canvas:extends(str)
    std::string
      text = luaL_checkstring(l, 2);
    jgui::jsize_t<int>
      size {0, 0};

    if (font != nullptr) {
      size.width = font->GetStringWidth(text);
      size.height = font->GetSize();
    }

		lua_pushnumber(l, size.width);
		lua_pushnumber(l, size.height);

		return 2;
	}

  lua_dump(l, "canvas:extends() => invalid parameters");

	return 0;
}

static int lua_Canvas_text(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 4) { // INFO:: canvas:text(str, x, y)
    std::string
      text = luaL_checkstring(l, 2);
    int
      x = luaL_checknumber(l, 3),
      y = luaL_checknumber(l, 4);

		g->DrawString(text, jgui::jpoint_t<int>{x, y});

		return 0;
  } else if (lua_gettop(l) == 4) { // INFO:: canvas:text(str, x, y, w, h)
    std::string
      text = luaL_checkstring(l, 2);
    int
      x = luaL_checknumber(l, 3),
      y = luaL_checknumber(l, 4),
      w = luaL_checknumber(l, 5),
      h = luaL_checknumber(l, 6);

		g->DrawString(text, jgui::jrect_t<int>{x, y, w, h});

		return 0;
  } else if (lua_gettop(l) == 4) { // INFO:: canvas:text(str, x, y, w, h, halign, valign)
    std::string
      text = luaL_checkstring(l, 2);
    int
      x = luaL_checknumber(l, 3),
      y = luaL_checknumber(l, 4),
      w = luaL_checknumber(l, 5),
      h = luaL_checknumber(l, 6);
    std::string
      ha = luaL_checkstring(l, 7),
      va = luaL_checkstring(l, 8);
    jgui::jhorizontal_align_t 
      halign = jgui::JHA_LEFT;
    jgui::jvertical_align_t 
      valign = jgui::JVA_TOP;

    if (ha == "left") {
      halign = jgui::JHA_LEFT;
    } else if (ha == "center") {
      halign = jgui::JHA_CENTER;
    } else if (ha == "right") {
      halign = jgui::JHA_RIGHT;
    } else if (ha == "justified") {
      halign = jgui::JHA_JUSTIFY;
    }

    if (va == "top") {
      valign = jgui::JVA_TOP;
    } else if (va == "center") {
      valign = jgui::JVA_CENTER;
    } else if (va == "bottom") {
      valign = jgui::JVA_BOTTOM;
    } else if (va == "justified") {
      valign = jgui::JVA_JUSTIFY;
    }

		g->DrawString(text, jgui::jrect_t<int>{x, y, w, h}, halign, valign);

		return 0;
	}

  lua_dump(l, "canvas:text() => invalid parameters");

	return 0;
}

static int lua_Canvas_pen(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 2) { // INFO:: canvas:pen(size)
    int
      size = luaL_checknumber(l, 2);

    jgui::jpen_t 
      pen = g->GetPen();

    pen.width = size;

    g->SetPen(pen);

		return 0;
	}

  lua_dump(l, "canvas:pen() => invalid parameters");

	return 0;
}

static int lua_Canvas_scale(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
	
  if (lua_gettop(l) == 3) { // INFO:: canvas:scale(w, h)
    int 
      w = (int)luaL_checknumber(l, 2),
      h = (int)luaL_checknumber(l, 3);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(canvas->image->Scale({w, h}));

    luaL_getmetatable(l, local_name.c_str());
    lua_setmetatable(l, -2);

		return 1;
	}

  lua_dump(l, "canvas:scale() => invalid parameters");

	return 0;
}

static int lua_Canvas_rotate(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
	
  if (lua_gettop(l) == 2) { // INFO:: canvas:rotate(radians)
    int 
      degrees = (int)luaL_checknumber(l, 2);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(canvas->image->Rotate(degrees*M_PI/180.0f, true));

    luaL_getmetatable(l, local_name.c_str());
    lua_setmetatable(l, -2);

		return 1;
  } else if (lua_gettop(l) == 3) { // INFO:: canvas:rotate(radians, method)
    int 
      degrees = (int)luaL_checknumber(l, 2);
    std::string
      method = luaL_checkstring(l, 3);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(canvas->image->Rotate(degrees*M_PI/180.0f, method == "contains"?false:true));

    luaL_getmetatable(l, local_name.c_str());
    lua_setmetatable(l, -2);

		return 1;
	}

  lua_dump(l, "canvas:rotate() => invalid parameters");

	return 0;
}

static int lua_Canvas_crop(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
	
  if (lua_gettop(l) == 5) { // INFO:: canvas:crop(w, h)
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3),
      w = (int)luaL_checknumber(l, 4),
      h = (int)luaL_checknumber(l, 5);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(canvas->image->Crop({x, y, w, h}));

    luaL_getmetatable(l, local_name.c_str());
    lua_setmetatable(l, -2);

		return 1;
	}

  lua_dump(l, "canvas:crop() => invalid parameters");

	return 0;
}

static int lua_Canvas_compose(lua_State *l)
{
  Canvas 
    *canvas = l_CheckCanvas(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 4) { // INFO:: canvas:compose(src, dx, dy)
    Canvas 
      *src = l_CheckCanvas(l, 2);
    int 
      dx = (int)luaL_checknumber(l, 3),
      dy = (int)luaL_checknumber(l, 4);

    g->DrawImage(src->image, jgui::jpoint_t<int>{dx, dy});

		return 0;
  } else if (lua_gettop(l) == 6) { // INFO:: canvas:compose(src, dx, dy, dw, dh)
    Canvas 
      *src = l_CheckCanvas(l, 2);
    int 
      dx = (int)luaL_checknumber(l, 3),
      dy = (int)luaL_checknumber(l, 4),
      dw = (int)luaL_checknumber(l, 5),
      dh = (int)luaL_checknumber(l, 6);

    g->DrawImage(src->image, jgui::jrect_t<int>{dx, dy, dw, dh});

		return 0;
  } else if (lua_gettop(l) == 8) { // INFO:: canvas:compose(src, sx, sy, sw, sh, dx, dy)
    Canvas 
      *src = l_CheckCanvas(l, 2);
    int 
      sx = (int)luaL_checknumber(l, 3),
      sy = (int)luaL_checknumber(l, 4),
      sw = (int)luaL_checknumber(l, 5),
      sh = (int)luaL_checknumber(l, 6),
      dx = (int)luaL_checknumber(l, 7),
      dy = (int)luaL_checknumber(l, 8);

    g->DrawImage(src->image, jgui::jrect_t<int>{sx, sy, sw, sh}, jgui::jpoint_t<int>{dx, dy});

		return 0;
  } else if (lua_gettop(l) == 10) { // INFO:: canvas:compose(src, sx, sy, sw, sh, dx, dy, dw, dh)
    Canvas 
      *src = l_CheckCanvas(l, 2);
    int 
      sx = (int)luaL_checknumber(l, 3),
      sy = (int)luaL_checknumber(l, 4),
      sw = (int)luaL_checknumber(l, 5),
      sh = (int)luaL_checknumber(l, 6),
      dx = (int)luaL_checknumber(l, 7),
      dy = (int)luaL_checknumber(l, 8),
      dw = (int)luaL_checknumber(l, 9),
      dh = (int)luaL_checknumber(l, 10);

    g->DrawImage(src->image, jgui::jrect_t<int>{sx, sy, sw, sh}, jgui::jrect_t<int>{dx, dy, dw, dh});

		return 0;
	}

  lua_dump(l, "canvas:compose() => invalid parameters");

	return 0;
}

Canvas::Canvas(jgui::Image *image):
  image(image?image:new jgui::BufferedImage(jgui::JPF_RGB32, jLua::Instance().GetSize()))
{
	visible = true;
}

Canvas::~Canvas()
{
	delete image;
}

void Canvas::Register(lua_State *l)
{
	luaL_Reg 
		sCanvasRegs[] = {
			{ "new", lua_Canvas_new },
			{ "__gc", lua_Canvas_gc },
			{ "size", lua_Canvas_size},
			{ "clear", lua_Canvas_clear},
			{ "color", lua_Canvas_color},
			{ "rect", lua_Canvas_rect},
			{ "line", lua_Canvas_line},
			{ "triangle", lua_Canvas_triangle},
			{ "arc", lua_Canvas_arc},
			{ "polygon", lua_Canvas_polygon},
			{ "extends", lua_Canvas_extends},
			{ "text", lua_Canvas_text},
			{ "pixels", lua_Canvas_pixels},
			{ "pen", lua_Canvas_pen},
			{ "scale", lua_Canvas_scale},
			{ "rotate", lua_Canvas_rotate},
			{ "crop", lua_Canvas_crop},
			{ "compose", lua_Canvas_compose},
			{ NULL, NULL }
		};

	luaL_newmetatable(l, local_name.c_str());
	luaL_setfuncs(l, sCanvasRegs, 0);
	lua_pushvalue(l, -1);
	lua_setfield(l, -1, "__index");
	lua_setglobal(l, Canvas::global_name.c_str());
}
