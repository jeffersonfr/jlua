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
#include "canvas.h"

#include "jcanvas/core/japplication.h"

int main(int argc, char **argv)
{
  if (argc != 2) {
    std::cout << "usage: " << argv[0] << " <file.lua>" << std::endl;

    return 1;
  }

	jcanvas::Application::Init(argc, argv);

	jLua &app = jLua::Instance();

	app.SetTitle("jLua");

  if (app.Load(argv[1]) == false) {
    std::cout << "file '" << argv[1] << "' not found !" << std::endl;

    return 1;
  }

	app.Exec();

	jcanvas::Application::Loop();

	return 0;
}

