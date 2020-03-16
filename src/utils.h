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
#include <string>

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
	#include <lualib.h>
}

#define LOG "\033[1m\033[30m"
#define INFO "\033[42m\033[30m"
#define WARN "\033[43m\033[30m"
#define ERR "\033[41m\033[30m"

#define L(id, msg) { \
    std::ios_base::fmtflags flags(std::cout.flags()); \
    std::cout << id << "[" << __FILE__ << ":" << __LINE__ << "] \033[1m" << __PRETTY_FUNCTION__ << "\033[0m " << msg << std::endl; \
    std::cout.flags(flags); \
  }

void lua_dump(lua_State *l, std::string msg);
