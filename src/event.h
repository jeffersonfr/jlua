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
#ifndef LUA_EVENT_H
#define LUA_EVENT_H

#include "jgui/jimage.h"

#include "utils.h"

#include <chrono>

class Event {

	public:
		struct key_state_t {
			std::string
				state;
			std::chrono::steady_clock::time_point
				timestamp;
		};

		struct pointer_state_t {
			std::string
				state;
			std::chrono::steady_clock::time_point
				timestamp;
			jgui::jpoint_t<int>
				position;
			int
				count;
		};

	public:
		static std::map<std::string, key_state_t>
			keys;
		static std::map<std::string, pointer_state_t>
			pointers;

	public:
		Event();

		~Event();

		static Event * Check(lua_State *l, int n);

		static void Register(lua_State *l);

};

#endif
