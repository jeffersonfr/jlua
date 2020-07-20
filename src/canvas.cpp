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
#include "font.h"
#include "jlua.h"

#include "jcommon/jstringutils.h"
#include "jgui/jbufferedimage.h"

static const std::string
  METATABLE = "luaL_canvas";

int lua_Canvas_new(lua_State *l)
{
  if (lua_gettop(l) == 1) { // INFO:(path): loads the image and render in a image buffer
    std::string
      path = luaL_checkstring(l, 1);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(new jgui::BufferedImage(jLua::Instance().base + "/" + path));
	
		(*udata)->image->GetGraphics()->SetFont(&jgui::Font::NORMAL);
  } else if (lua_gettop(l) == 2) { // INFO:(w, h): create a image buffer to be used during the execution
    const int
      w = luaL_checknumber(l, 1),
      h = luaL_checknumber(l, 2);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(new jgui::BufferedImage(jgui::JPF_ARGB, {w, h}));
		
		(*udata)->image->GetGraphics()->SetFont(&jgui::Font::NORMAL);
  }

	luaL_getmetatable(l, METATABLE.c_str());
	lua_setmetatable(l, -2);

	return 1;
}

int lua_Canvas_gc(lua_State *l)
{
	Canvas 
		*canvas = Canvas::Check(l, 1);

	delete canvas;

	return 0;
}

static int lua_Canvas_size(lua_State *l)
{
	Canvas 
		*canvas = Canvas::Check(l, 1);
  jgui::jsize_t<int>
    size = canvas->image->GetSize();

	if (lua_gettop(l) == 1) {
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
    *canvas = Canvas::Check(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 1) { // INFO:: canvas:clear()
	  g->Clear();

		return 0;
  } else if (lua_gettop(l) == 5) { // INFO:: canvas:clear(r, g, b, a)
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3),
      w = (int)luaL_checknumber(l, 4),
      h = (int)luaL_checknumber(l, 5);

	  g->Clear({x, y, w, h});

		return 0;
	}

  lua_dump(l, "canvas:clear() => invalid parameters");

	return 0;
}

static int lua_Canvas_color(lua_State *l)
{
  Canvas 
    *canvas = Canvas::Check(l, 1);
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
    *canvas = Canvas::Check(l, 1);
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
    *canvas = Canvas::Check(l, 1);
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
    *canvas = Canvas::Check(l, 1);
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
    *canvas = Canvas::Check(l, 1);
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
      sy = (int)luaL_checknumber(l, 6);
    float
      arc0 = (float)luaL_checknumber(l, 7),
      arc1 = (float)luaL_checknumber(l, 8);

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
    *canvas = Canvas::Check(l, 1);
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
    *canvas = Canvas::Check(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 3) { // INFO:: canvas:pixels(x, y) returns the argb at the {x, y} [r, g, b, a]
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3);
    uint32_t
      color = g->GetRGB({x, y});
    
    lua_pushinteger(l, color);
    // lua_pushinteger(l, (color >> 16) & 0xff);
    // lua_pushinteger(l, (color >> 8) & 0xff);
    // lua_pushinteger(l, (color >> 0) & 0xff);
    // lua_pushinteger(l, (color >> 24) & 0xff);

		return 1;
  } else if (lua_gettop(l) == 4) { // INFO:: canvas:pixels(x, y, argb)
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3);
    uint32_t
      color = (uint32_t)luaL_checknumber(l, 4);

    g->SetCompositeFlags(jgui::JCF_SRC);
    g->SetRGB(color, {x, y});
    g->SetCompositeFlags(jgui::JCF_SRC_OVER);

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
  } else if (lua_gettop(l) == 6) { // INFO:: canvas:pixels(x, y, w, h, {pixels})
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3),
      w = (int)luaL_checknumber(l, 4),
      h = (int)luaL_checknumber(l, 5);
    uint32_t
      buffer[w*h],
      *ptr = buffer,
      *end = ptr + w*h;

    lua_pushnil(l);

    while (lua_next(l, -2)) {
      uint32_t
        pixel = (uint32_t)luaL_checknumber(l, -1);

      *ptr++ = pixel;

      lua_pop(l, 1);
      
      if (ptr == end) {
        break;
      }
    }
      
    lua_pop(l, 1);

    g->SetCompositeFlags(jgui::JCF_SRC);
    g->SetRGBArray(buffer, {x, y, w, h});
    g->SetCompositeFlags(jgui::JCF_SRC_OVER);

    return 0;
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

extern int lua_Font_new(lua_State *l);

static int lua_Canvas_font(lua_State *l)
{
  Canvas 
    *canvas = Canvas::Check(l, 1);
  jgui::Graphics
    *g = canvas->image->GetGraphics();
	
  if (lua_gettop(l) == 1) { // INFO:: canvas:font()
    if (g->GetFont() == nullptr) {
      lua_pushnil(l);

      return 1;
    }

    Font
      **udata = (Font **)lua_newuserdata(l, sizeof(Font *));

    *udata = new Font(g->GetFont()->GetSize());

    luaL_getmetatable(l, "luaL_font");
    lua_setmetatable(l, -2);

    return 1;
  } else if (lua_gettop(l) == 2) { // INFO:: canvas:font(font)
		Font
			*font = Font::Check(l, 2);

		g->SetFont(font->font);

		return 0;
	}

  lua_dump(l, "canvas:font() => invalid parameters");

	return 0;
}

static int lua_Canvas_text(lua_State *l)
{
  Canvas 
    *canvas = Canvas::Check(l, 1);
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
    *canvas = Canvas::Check(l, 1);
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
    *canvas = Canvas::Check(l, 1);
	
  if (lua_gettop(l) == 3) { // INFO:: canvas:scale(w, h)
    int 
      w = (int)luaL_checknumber(l, 2),
      h = (int)luaL_checknumber(l, 3);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    canvas->image->GetGraphics()->SetAntialias(jgui::JAM_NONE);

    *udata = new Canvas(canvas->image->Scale({w, h}));

    luaL_getmetatable(l, METATABLE.c_str());
    lua_setmetatable(l, -2);

		return 1;
	}

  lua_dump(l, "canvas:scale() => invalid parameters");

	return 0;
}

static int lua_Canvas_rotate(lua_State *l)
{
  Canvas 
    *canvas = Canvas::Check(l, 1);
	
  if (lua_gettop(l) == 2) { // INFO:: canvas:rotate(radians)
    int 
      degrees = (int)luaL_checknumber(l, 2);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(canvas->image->Rotate(degrees*M_PI/180.0f, false));

    luaL_getmetatable(l, METATABLE.c_str());
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

    luaL_getmetatable(l, METATABLE.c_str());
    lua_setmetatable(l, -2);

		return 1;
	}

  lua_dump(l, "canvas:rotate() => invalid parameters");

	return 0;
}

static int lua_Canvas_crop(lua_State *l)
{
  Canvas 
    *canvas = Canvas::Check(l, 1);
	
  if (lua_gettop(l) == 5) { // INFO:: canvas:crop(w, h)
    int 
      x = (int)luaL_checknumber(l, 2),
      y = (int)luaL_checknumber(l, 3),
      w = (int)luaL_checknumber(l, 4),
      h = (int)luaL_checknumber(l, 5);

    Canvas
      **udata = (Canvas **)lua_newuserdata(l, sizeof(Canvas *));

    *udata = new Canvas(canvas->image->Crop({x, y, w, h}));

    luaL_getmetatable(l, METATABLE.c_str());
    lua_setmetatable(l, -2);

		return 1;
	}

  lua_dump(l, "canvas:crop() => invalid parameters");

	return 0;
}

static int lua_Canvas_compose(lua_State *l)
{
  Canvas 
    *canvas = nullptr;
	jgui::Graphics
		*g = nullptr;
	int
		offset = 0;
	
	if (lua_gettop(l)%2 == 0) {
		canvas = Canvas::Check(l, 1);

    g = canvas->image->GetGraphics();
	} else {
		g = jLua::Instance().GetGraphicLayer();

		offset = 1;
	}

  if (g == nullptr) {
    L(WARN, "canvas:compose(): this method must be called inside of render(tick) method");

    return 0;
  }

  g->SetBlittingFlags(jgui::JBF_NEAREST);

  if (lua_gettop(l) == 4 - offset) { // INFO:: canvas:compose(src, dx, dy)
    Canvas 
      *src = Canvas::Check(l, 2 - offset);
    int 
      dx = (int)luaL_checknumber(l, 3 - offset),
      dy = (int)luaL_checknumber(l, 4 - offset);

    g->DrawImage(src->image, jgui::jpoint_t<int>{dx, dy});

		return 0;
  } else if (lua_gettop(l) == 6 - offset) { // INFO:: canvas:compose(src, dx, dy, dw, dh)
    Canvas 
      *src = Canvas::Check(l, 2 - offset);
    int 
      dx = (int)luaL_checknumber(l, 3 - offset),
      dy = (int)luaL_checknumber(l, 4 - offset),
      dw = (int)luaL_checknumber(l, 5 - offset),
      dh = (int)luaL_checknumber(l, 6 - offset);

    g->DrawImage(src->image, jgui::jrect_t<int>{dx, dy, dw, dh});

		return 0;
  } else if (lua_gettop(l) == 8 - offset) { // INFO:: canvas:compose(src, sx, sy, sw, sh, dx, dy)
    Canvas 
      *src = Canvas::Check(l, 2 - offset);
    int 
      sx = (int)luaL_checknumber(l, 3 - offset),
      sy = (int)luaL_checknumber(l, 4 - offset),
      sw = (int)luaL_checknumber(l, 5 - offset),
      sh = (int)luaL_checknumber(l, 6 - offset),
      dx = (int)luaL_checknumber(l, 7 - offset),
      dy = (int)luaL_checknumber(l, 8 - offset);

    g->DrawImage(src->image, jgui::jrect_t<int>{sx, sy, sw, sh}, jgui::jpoint_t<int>{dx, dy});

		return 0;
  } else if (lua_gettop(l) == 10 - offset) { // INFO:: canvas:compose(src, sx, sy, sw, sh, dx, dy, dw, dh)
    Canvas 
      *src = Canvas::Check(l, 2 - offset);
    int 
      sx = (int)luaL_checknumber(l, 3 - offset),
      sy = (int)luaL_checknumber(l, 4 - offset),
      sw = (int)luaL_checknumber(l, 5 - offset),
      sh = (int)luaL_checknumber(l, 6 - offset),
      dx = (int)luaL_checknumber(l, 7 - offset),
      dy = (int)luaL_checknumber(l, 8 - offset),
      dw = (int)luaL_checknumber(l, 9 - offset),
      dh = (int)luaL_checknumber(l, 10 - offset);

    g->DrawImage(src->image, jgui::jrect_t<int>{sx, sy, sw, sh}, jgui::jrect_t<int>{dx, dy, dw, dh});

		return 0;
	}

  lua_dump(l, "canvas:compose() => invalid parameters");

	return 0;
}

Canvas::Canvas(jgui::Image *image):
  image(image)
{
  if (image == nullptr) {
    throw std::runtime_error("Image must be valid");
  }

	visible = true;
}

Canvas::~Canvas()
{
	delete image;
  image = nullptr;
}

Canvas * Canvas::Check(lua_State *l, int n)
{
	return *(Canvas **)luaL_checkudata(l, n, METATABLE.c_str());
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
			{ "text", lua_Canvas_text},
			{ "pixels", lua_Canvas_pixels},
			{ "pen", lua_Canvas_pen},
			{ "scale", lua_Canvas_scale},
			{ "rotate", lua_Canvas_rotate},
			{ "crop", lua_Canvas_crop},
			{ "font", lua_Canvas_font},
			{ "compose", lua_Canvas_compose},
			{ NULL, NULL }
		};

	luaL_newmetatable(l, METATABLE.c_str());
	luaL_setfuncs(l, sCanvasRegs, 0);
	lua_pushvalue(l, -1);
	lua_setfield(l, -1, "__index");
	lua_setglobal(l, METATABLE.substr(5).c_str());
}

