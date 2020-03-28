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
#include "mixer.h"
#include "jlua.h"

#include "jmedia/jplayermanager.h"
#include "jmedia/jaudiomixercontrol.h"

static const std::string
  METATABLE = "luaL_mixer";

static jmedia::Player * MixerInstance()
{
  static jmedia::Player *instance = jmedia::PlayerManager::CreatePlayer("mixer://");

  return instance;
}

static int lua_Mixer_new(lua_State *l)
{
  if (lua_gettop(l) == 1) { // INFO:(size): create a new mixer using the size parameter
    const char
      *path = luaL_checkstring(l, 1);

    Mixer
      **udata = (Mixer **)lua_newuserdata(l, sizeof(Mixer *));

    *udata = new Mixer(path);
  }

	luaL_getmetatable(l, METATABLE.c_str());
	lua_setmetatable(l, -2);

	return 1;
}

static int lua_Mixer_gc(lua_State *l)
{
	Mixer 
		*mixer = Mixer::Check(l, 1);

	delete mixer;

	return 0;
}

static int lua_Mixer_start(lua_State *l)
{
  Mixer 
    *mixer = Mixer::Check(l, 1);

  if (lua_gettop(l) == 1) { // INFO:():
    jmedia::AudioMixerControl 
      *control = dynamic_cast<jmedia::AudioMixerControl *>(MixerInstance()->GetControl("audio.mixer"));

    if (control != nullptr) {
      control->StartSound(mixer->audio);
    }

		return 0;
  }
	
  lua_dump(l, "mixer:start() => invalid parameters");

	return 0;
}

static int lua_Mixer_stop(lua_State *l)
{
  Mixer 
    *mixer = Mixer::Check(l, 1);

  if (lua_gettop(l) == 1) { // INFO:():
		return 0;
  }
	
  lua_dump(l, "mixer:stop() => invalid parameters");

	return 0;
}

static int lua_Mixer_pause(lua_State *l)
{
  Mixer 
    *mixer = Mixer::Check(l, 1);

  if (lua_gettop(l) == 1) { // INFO:():
		return 0;
  }
	
  lua_dump(l, "mixer:pause() => invalid parameters");

	return 0;
}

static int lua_Mixer_loop(lua_State *l)
{
  Mixer 
    *mixer = Mixer::Check(l, 1);

  if (lua_gettop(l) == 1) { // INFO:():
    bool
      flag = lua_toboolean(l, 2);

    mixer->audio->SetLoopEnabled(flag);

		return 0;
  }
	
  lua_dump(l, "mixer:loop() => invalid parameters");

	return 0;
}

static int lua_Mixer_volume(lua_State *l)
{
  Mixer 
    *mixer = Mixer::Check(l, 1);

  if (lua_gettop(l) == 1) { // INFO:():
    bool
      level = luaL_checknumber(l, 2);

    mixer->audio->SetVolume(level);

		return 0;
  }
	
  lua_dump(l, "mixer:volume() => invalid parameters");

	return 0;
}

Mixer::Mixer(std::string path)
{
  if (MixerInstance() == nullptr) {
    throw std::runtime_error("Audio mixer is not avaiable !");
  }

  jmedia::AudioMixerControl 
    *control = dynamic_cast<jmedia::AudioMixerControl *>(MixerInstance()->GetControl("audio.mixer"));

  if (control == nullptr) {
    throw std::runtime_error("Audio mixer control is not avaiable !");
  }

  this->audio = control->CreateAudio(jLua::Instance().base + "/" + path);

  this->audio->SetLoopEnabled(false);
}

Mixer::~Mixer()
{
	delete audio;
	audio = nullptr;
}

Mixer * Mixer::Check(lua_State *l, int n)
{
	return *(Mixer **)luaL_checkudata(l, n, METATABLE.c_str());
}

void Mixer::Register(lua_State *l)
{
	luaL_Reg 
		sMixerRegs[] = {
			{ "new", lua_Mixer_new },
			{ "__gc", lua_Mixer_gc },
			{ "start", lua_Mixer_start },
			{ "stop", lua_Mixer_stop },
			{ "pause", lua_Mixer_pause },
			{ "loop", lua_Mixer_loop },
			{ "volume", lua_Mixer_volume },
			{ NULL, NULL }
		};

	luaL_newmetatable(l, METATABLE.c_str());
	luaL_setfuncs(l, sMixerRegs, 0);
	lua_pushvalue(l, -1);
	lua_setfield(l, -1, "__index");
	lua_setglobal(l, METATABLE.substr(5).c_str());
}

