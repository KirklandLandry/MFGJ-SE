SimpleEnemy = {body = nil, moveTimer = nil, invincibilityFrames = 0}

local recoilAmount = 100

function SimpleEnemy:new(x, y, width, height)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.body = Body:new(x,y,width,height, 2.5,2.5, 0.09)
	o.moveTimer = Timer:new(1, TimerModes.repeating)
	o.invincibilityFrames = 0
	return o
end
 
 function SimpleEnemy:getAABB()
	return self.body.box
 end
 
 function SimpleEnemy:update(dt)
	assert(dt~=nil, "don't pass an empty dt, dummy")
	
	
	if self.body.moveState == MoveStates.recoil then 
		if self.body.recoilTimer:isComplete(dt) then 
			if self.body.moveState == MoveStates.recoil then 
				self.body.moveState = MoveStates.neutral 
				
			end
		end	
		self.body.box:scalarMove(self.body.recoilX * dt, self.body.recoilY * dt)
	elseif self.moveTimer:isComplete(dt) then 
		if self.body.moveState == MoveStates.neutral then 
			self.body.moveState = MoveStates.walking
			self.body.facingDirection = getRandomDirection()
		elseif self.body.moveState == MoveStates.walking then 
			self.body.moveState = MoveStates.neutral
		end
	end
	
	if self.invincibilityFrames ~= 0 then self.invincibilityFrames = self.invincibilityFrames - 1 end
	
	self:move(dt)
	
	-- check to see if it went off the edge and move based on the correction that gets returned 
	self.body.box:vectorMove(AABBvsScreenEdge(self.body.box))
	
	local enemyMapCoords = getTileCoordinate(self.body.box.minVec.x, self.body.box.minVec.y)
	-- check if a collision occurs with the map 
	if checkTileMapCollision(self.body.box, enemyMapCoords.x, enemyMapCoords.y) then 
		
	end
end

function SimpleEnemy:isInvincible()
	if self.invincibilityFrames ~= 0 then 
		return true 
	else 
		return false 
	end
end

function SimpleEnemy:changeHealth(amount, recoilVector)
	self.body.currentHealth = self.body.currentHealth + amount
	self.body.recoilX = recoilVector.x * recoilAmount
	self.body.recoilY = recoilVector.y * recoilAmount 
	self.body.moveState = MoveStates.recoil
	self.body.recoilTimer:reset()
end

function SimpleEnemy:getHealth() 
	return self.body.currentHealth
end

function SimpleEnemy:draw(i)
	love.graphics.setColor(99,165,33)
	love.graphics.rectangle("fill", self.body.box.minVec.x, self.body.box.minVec.y, self.body.box.width, self.body.box.height)
	self.body.box:drawCorners()
	
	-- print out the enemies array index and health
	love.graphics.setColor(0,0,0)
	love.graphics.print(i,self.body.box.minVec.x, self.body.box.minVec.y, 0, 0.5, 0.5)
	love.graphics.print("hp:"..self.body.currentHealth, self.body.box.minVec.x, self.body.box.minVec.y + 5, 0, 0.4, 0.4)
end


local moveAmount = 10
function SimpleEnemy:move(dt)
	self.body.vel.x = 0 
	self.body.vel.y = 0
	if self.body.moveState == MoveStates.walking then 
		if self.body.facingDirection == Directions.up  then 
			self.body.vel.y = -(moveAmount * dt)
		elseif self.body.facingDirection == Directions.down  then 
			self.body.vel.y = (moveAmount * dt)
		elseif self.body.facingDirection == Directions.left then 
			self.body.vel.x = -(moveAmount * dt)
		elseif self.body.facingDirection == Directions.right then 
			self.body.vel.x = (moveAmount * dt)
		end
		self.body.box:scalarMove(self.body.vel.x, self.body.vel.y)
	end
end
