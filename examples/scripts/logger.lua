logger = {
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	DEBUG = 4,
	_level = 1,
	_enabled = true
}

function logger.level(level)
	if (level == nil) then
		return level
	end

	_level = level
end

function logger.enable(e)
	if (e == nil) then
		return logger._enabled;
	end

	logger._enabled = e;
end

function logger.error(...)
	return io.write(string.format(...))
end

function logger.warn(...)
	return io.write(string.format(...))
end

function logger.info(...)
	return io.write(string.format(...))
end

function logger.debug(...)
	return io.write(string.format(...))
end

function logger.trace()
	local level = 1

	while true do
		local info = debug.getinfo(level, "Sl")
		
		if not info then 
			break 
		end

		if info.what == "C" then   -- is a C function?
			print(level, "C function")
		else
			print(string.format("[%s]:%d", utils.suball(info.short_src, '%./', ''), info.currentline))
		end

		level = level + 1
	end
end

function logger.log(level, content, ...)
	if (logger._enabled == false) then
		return
	end

	if (level >= logger._level) then
		local info = debug.getinfo(2, "Sl")

		if not info or not info.short_src then 
			info = {
				["short_src"] = "unknown",
				["currentline"] = -1
			}
		else
			info.short_src = utils.suball(info.short_src, '%./', '')
		end

		if (level == logger.ERROR) then
			logger.debug("ERROR:[%s:%d]: ", info.short_src, info.currentline)
		elseif (level == logger.WARN) then
			logger.debug("WARN:[%s:%d]: ", info.short_src, info.currentline)
		elseif (level == logger.INFO) then
			logger.debug("INFO:[%s:%d]: ", info.short_src, info.currentline)
		elseif (level == logger.DEBUG) then
			logger.debug("DEBUG:[%s:%d]: ", info.short_src, info.currentline)
		end

		logger.debug(content, ...)
	end
end
