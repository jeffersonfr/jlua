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

#include "jcanvas/core/jwindow.h"

#include <mutex>

class Canvas;

class jLua : public jcanvas::Window, public jcanvas::KeyListener, public jcanvas::MouseListener, public jcanvas::WindowListener {

	private:
    jcanvas::Graphics
      *_graphicLayer;
		std::mutex
			_lua_mutex;

	private:
		virtual bool KeyPressed(jcanvas::KeyEvent *event) override;
		virtual bool KeyReleased(jcanvas::KeyEvent *event) override;
		virtual bool MousePressed(jcanvas::MouseEvent *event) override;
		virtual bool MouseReleased(jcanvas::MouseEvent *event) override;
		virtual bool MouseMoved(jcanvas::MouseEvent *event) override;

    virtual void WindowOpened(jcanvas::WindowEvent *event) override;
    virtual void WindowClosing(jcanvas::WindowEvent *event) override;
    virtual void WindowClosed(jcanvas::WindowEvent *event) override;
    virtual void WindowResized(jcanvas::WindowEvent *event) override;
    virtual void WindowMoved(jcanvas::WindowEvent *event) override;
    virtual void WindowPainted(jcanvas::WindowEvent *event) override;
    virtual void WindowEntered(jcanvas::WindowEvent *event) override;
    virtual void WindowLeaved(jcanvas::WindowEvent *event) override;

		virtual void Paint(jcanvas::Graphics *g) override;

  public:
    std::string
      base;

	public:
		jLua();

		virtual ~jLua();

		static jLua & Instance();

    void Initialize();

    bool Load(std::string path);

		jcanvas::Graphics * GetGraphicLayer();

};

#endif
