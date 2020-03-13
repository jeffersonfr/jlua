----------------------------------------------------------------------
-- TargetRobot
----------------------------------------------------------------------
TargetRobot = class(Robot, 
	function(c, name)
		Robot.init(c, name)
	end

)
	
function TargetRobot:main()
end

arena:add(TargetRobot("Target"))
