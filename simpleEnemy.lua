SimpleEnemy = {box = AABB:new(0, 0, 16, 16), vel = Vector:new(0,0), currentHealth = 4.50, facingDirection = nil, state = nil, moveTimer = nil, invincibilityFrames = 0}
local EnemyState = {waiting = "waiting", moving = "moving"}

function SimpleEnemy:new(x, y, width, height)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.box = AABB:new(x,y,width,height)
	o.state = EnemyState.waiting
	o.facingDirection = directions.down
	o.moveTimer = Timer:new(1, TimerModes.repeating)
	o.invincibilityFrames = 0
	return o
end
 
 function SimpleEnemy:getAABB()
	return self.box
 end
 
 function SimpleEnemy:update(dt)
	assert(dt~=nil, "don't pass an empty dt, dummy")
	
	if self.moveTimer:isComplete(dt) then 
		if self.state == EnemyState.waiting then 
			self.state = EnemyState.moving
			self.facingDirection = getRandomDirection()
		elseif self.state == EnemyState.moving then 
			self.state = EnemyState.waiting 
		end
	end
	
	if self.invincibilityFrames ~= 0 then self.invincibilityFrames = self.invincibilityFrames - 1 end
	
	self:move(dt)
	
	-- check to see if it went off the edge and move based on the correction that gets returned 
	self.box:vectorMove(AABBvsScreenEdge(self.box))
	
	local enemyMapCoords = getTileCoordinate(self.box.minVec.x, self.box.minVec.y)
	-- check if a collision occurs with the map 
	if checkTileMapCollision(self.box, enemyMapCoords.x, enemyMapCoords.y) then 
		
	end
end

function SimpleEnemy:isInvincible()
	if self.invincibilityFrames ~= 0 then 
		return true 
	else 
		return false 
	end
end

function SimpleEnemy:changeHealth(amount)
	self.currentHealth = self.currentHealth + amount
end

function SimpleEnemy:getHealth() 
	return self.currentHealth
end

function SimpleEnemy:draw(i)
	love.graphics.setColor(99,165,33)
	love.graphics.rectangle("fill", self.box.minVec.x, self.box.minVec.y, self.box.width, self.box.height)
	self.box:drawCorners()
	
	-- print out the enemies array index and health
	love.graphics.setColor(0,0,0)
	love.graphics.print(i,self.box.minVec.x, self.box.minVec.y, 0, 0.5, 0.5)
	love.graphics.print("hp:"..self.currentHealth, self.box.minVec.x, self.box.minVec.y + 5, 0, 0.4, 0.4)
end


local moveAmount = 10
function SimpleEnemy:move(dt)
	self.vel.x = 0 
	self.vel.y = 0
	if self.state == EnemyState.moving then 
		if self.facingDirection == directions.up  then 
			self.vel.y = -(moveAmount * dt)
		elseif self.facingDirection == directions.down  then 
			self.vel.y = (moveAmount * dt)
		elseif self.facingDirection == directions.left then 
			self.vel.x = -(moveAmount * dt)
		elseif self.facingDirection == directions.right then 
			self.vel.x = (moveAmount * dt)
		end
		self.box:scalarMove(self.vel.x, self.vel.y)
	end
end
