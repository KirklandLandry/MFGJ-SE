Attack = {box = nil, damage = 0, currentFrame = 0, totalFrames = 0}

-- should later be able to pass in spritesheet
-- box should be sized seperate from the sprite

function Attack:new(damage, totalFrames)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.box = AABB:new(0,0,0,0)
	o.damage = damage
	o.totalFrames = totalFrames
	o.currentFrame = 0
	return o
end

function Attack:isComplete(dt)
	self.currentFrame = self.currentFrame + 1
	if self.currentFrame >= self.totalFrames then 
		self.currentFrame = self.totalFrames 
		return true
	end
	return false
end

function Attack:remainingFrames()
	return self.totalFrames - self.currentFrame
end

function Attack:reset()
	self.currentFrame = 0
end