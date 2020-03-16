package.path = package.path .. ";" .. jlua.base .. "/?.lua"

dofile("scripts/class.lua")
dofile("scripts/logger.lua")
dofile("scripts/persistent.lua")
dofile("scripts/utf8.lua")
dofile("scripts/utils.lua")

package.path = package.path .. ";" .. jlua.base .. "/?.lua"

function __getpath(file)
	file = utils.suball(file, '%.%.\\', '%.%./')
	file = utils.suball(file, '%.\\', '%./')
	file = utils.suball(file, '\\', '/')
	file = utils.suball(file, '//', '/')
	--file = utils.suball(file, '%.%./', '')
	--file = utils.suball(file, '%./', '')

	local file_table = utils.split(file, "/");
	local path_table = {}

	for k,v in pairs(file_table) do
		if (v == "..") then
			-- remove current and previous element
			table.remove(path_table, #path_table)
			table.remove(path_table, #path_table)
		elseif (v ~= ".") then
			-- add a new element
			if (v ~= nil and v:len() > 0) then
				path_table[#path_table+1] = v
			end
		end
	end

	local path = ""

	for k,v in pairs(path_table) do
		path = path .. "/" .. v
	end

	local index = string.find(path, '/')

	if index == 1 then
		path = string.sub(path, 2)
	end

	return path
end

function __setting_basedirectory(dir)
	dir = dir .. "/"
	
	dir = utils.suball(dir, '%.%.\\', '%.%./')
	dir = utils.suball(dir, '%.\\', '%./')
	dir = utils.suball(dir, '\\', '/')
	dir = utils.suball(dir, '//', '/')

	__old_io_open = io.open 
	function __new_io_open(filename, mode) 
		
		if (filename) then
			filename = dir .. __getpath(filename) 
		end

		return __old_io_open(filename, mode) 
	end
	io.open = __new_io_open

	__old_io_lines = io.lines 
	function __new_io_lines(filename, mode) 
		if (filename) then
			filename = dir .. __getpath(filename)
		end

		return __old_io_lines(filename, mode)
	end 
	io.lines = __new_io_lines

	__old_io_input = io.input 
	function __new_io_input(filename)
		if (filename) then 
			filename = dir .. __getpath(filename)
		end
			
		return __old_io_input(filename) 
	end 
	io.input = __new_io_input

	--[[
	__old_canvas_create = canvas.create 
	function __new_canvas_create(...)
		local args = {...}

		if (#args > 0 and type(args[1] == "string")) then
			args[1] = __getpath(args[1])
		end

		return __old_canvas_create(table.unpack(args))
	end 
	canvas.create = __new_canvas_create

	__old_media_create = media.create 
	function __new_media_create(...)
		local args = {...}

		if (#args > 0 and type(args[1] == "string")) then
			args[1] = __getpath(args[1])
		end

		return __old_media_create(table.unpack(args))
	end 
	media.create = __new_media_create
	]]

	__old_dofile = dofile 
	function __new_dofile(filename)
		if (filename) then
			filename = dir .. __getpath(filename)
		end
			
		return __old_dofile(filename)
	end
	dofile = __new_dofile
end

__setting_basedirectory(jlua.base)
