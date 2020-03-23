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
#ifndef LUA_JLUA_H
#define LUA_JLUA_H

#include "jgui/jwindow.h"

#include <mutex>

class Canvas;

class jLua : public jgui::Window, jevent::WindowListener {

	private:
    jgui::Graphics
      *_graphicLayer;
		std::mutex
			_lua_mutex;

	private:
		virtual bool KeyPressed(jevent::KeyEvent *event);
		virtual bool KeyReleased(jevent::KeyEvent *event);
		virtual bool MousePressed(jevent::MouseEvent *event);
		virtual bool MouseReleased(jevent::MouseEvent *event);
		virtual bool MouseMoved(jevent::MouseEvent *event);

    virtual void WindowOpened(jevent::WindowEvent *event);
    virtual void WindowClosing(jevent::WindowEvent *event);
    virtual void WindowClosed(jevent::WindowEvent *event);
    virtual void WindowResized(jevent::WindowEvent *event);
    virtual void WindowMoved(jevent::WindowEvent *event);
    virtual void WindowPainted(jevent::WindowEvent *event);
    virtual void WindowEntered(jevent::WindowEvent *event);
    virtual void WindowLeaved(jevent::WindowEvent *event);

		virtual void Paint(jgui::Graphics *g);

  public:
    std::string
      base;

	public:
		jLua();

		virtual ~jLua();

		static jLua & Instance();

    void Initialize();

    bool Load(std::string path);

		jgui::Graphics * GetGraphicLayer();

};

#endif
