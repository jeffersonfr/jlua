----------------------------------------------------------------------
-- KamikazeRobot
----------------------------------------------------------------------
KamikazeRobot = class(Robot, 
	function(c, name)
		Robot.init(c, name)
	end
)

function KamikazeRobot:main()
	while (true) do
		self:move(1)
		self:fire()
	end
end

arena:add(KamikazeRobot("Kamikaze"))
