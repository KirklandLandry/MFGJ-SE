--[[State = {}

function State:new(listOfInitialStates)	
	local o = {}
	setmetatable(o, self)
	self.__index = self

	for i=1,#listOfInitialStates do 
		
	end
	
	return o
end

function State:add()

end]]