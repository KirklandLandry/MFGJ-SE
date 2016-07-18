Body = {box = nil, vel =nil, maxHealth = nil, currentHealth = nil, facingDirection = nil, moveState = nil, bodyState = nil, recoilX = 0, recoilY = 0, recoilTimer = nil}


function Body:new(x,y,width,height, maxHealth, currentHealth, recoilTime)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.box = AABB:new(x,y,width,height)
	o.vel = Vector:new(0,0)
	o.maxHealth = maxHealth 
	o.currentHealth = currentHealth
	o.facingDirection = Directions.up
	o.moveState = MoveStates.neutral 
	o.bodyState = BodyStates.neutral
	o.recoilX = 0
	o.recoilY = 0
	o.recoilTimer = Timer:new(recoilTime, "single")
	return o
end


function Body:checkEntityCollisions()
	local collisionInfo = AABBvsEnemiesCollisions(self.box)
	return collisionInfo
end
