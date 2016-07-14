Timer = {timerValue = 0, timerMax = 0}


function SimpleEnemy:new(timerMax)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.timerValue = 0
	o.timerMax = timerMax
	return o
end
 