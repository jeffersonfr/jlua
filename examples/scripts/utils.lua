utils = {
}

function utils.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function utils.ltrim(s)
  return (s:gsub("^%s*", ""))
end

function utils.rtrim(s)
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end

function utils.split(str, pattern)
	local fpath = '(.-)' .. tostring(pattern)
	local last_end = 1 
	local s,e,cap = string.find(str, fpath)
	local dirs = {}

	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(dirs, cap)
		end 
	
		last_end = e + 1 

		s,e,cap = string.find(str, fpath, last_end)
	end 
	
	if last_end <= #str then
		cap = string.sub(str, last_end)
		table.insert(dirs, cap)
	end 

	return dirs
end

--[[
utils.split = function(s, p)
	local temp = {}
	local index = 0
	local last_index = string.len(s)

	while true do
		local i, e = string.find(s, p, index)

		if i and e then
			local next_index = e + 1
			local word_bound = i - 1
			table.insert(temp, string.sub(s, index, word_bound))
			index = next_index
		else            
			if index > 0 and index <= last_index then
				table.insert(temp, string.sub(s, index, last_index))
			elseif index == 0 then
				temp = nil
			end
			break
		end
	end

	return temp
end
]]

function utils.subchr(str, pos, char)
	return str:sub(1, pos-1) .. char .. str:sub(pos+1)
end

function utils.substr(str, pattern, char)
	return string.gsub(str, pattern, char, str:len())
end

function utils.suball(str, pattern, char)
	local rep
	
	if (str == nil) then
		return nil;
	end

	repeat
		str, rep = string.gsub(str, pattern, char, str:len())
	until rep == 0

	return str
end

