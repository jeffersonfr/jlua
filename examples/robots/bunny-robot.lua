----------------------------------------------------------------------
-- BunnyRobot
----------------------------------------------------------------------
BunnyRobot = class(Robot, 
	function(c, name)
		Robot.init(c, name)
	end
)

function BunnyRobot:main()
	local found = false

	-- self:weapon("gun")

	while (true) do
		-- INFO:: begin code (loadfile)
		self:move(math.random(10))

		if (found == false) then
			if (self:collide() == true) then
				self:move(-1)
				-- self:turn(30)
			end
		end
	
		found = false

		--[[
		enemies = self:scan("radial")
		
		if (enemies ~= nil) then
			for i=1,#enemies do
				print("Enemy: ", enemies[i].angle, enemies[i].distance)
			end

			self:turn(enemies[1].angle)
		
			self:fire()
		end
		]]

		for i=0,10 do
			enemies = self:scan("linear", 36*i)

			if (enemies ~= nil) then
				self:turn(enemies[1].angle)

				self:fire()

				found = true

				break
			end
		end

		-- self:cannon(-30)
		-- INFO:: end code
	end
end

arena:add(BunnyRobot("Bunny"))
