SimpleEnemy = {body = nil, moveTimer = nil, invincibilityFrames = 0}

local recoilAmount = 100

function SimpleEnemy:new(x, y, width, height)	
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.body = Body:new(x,y,width,height, 2.5,2.5, 0.09)
	o.moveTimer = Timer:new(math.random(0,100) * 0.01, TimerModes.repeating)
	o.imagePath = "assets/tilesets/SimpleEnemy.png"
	o.image = nil
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
				self.body.moveState = MoveStates.walking 
				
			end
		end	
		self.body.box:scalarMove(self.body.recoilX * dt, self.body.recoilY * dt)
	end
	if self.moveTimer:isComplete(dt) then 
		if self.body.moveState == MoveStates.neutral then 
			self.moveTimer.timerMax = math.random(50,350) * 0.01
			self.body.moveState = MoveStates.walking
			self.body.facingDirection = getRandomDirection()
		elseif self.body.moveState == MoveStates.walking then 
			self.moveTimer.timerMax = math.random(0,100) * 0.01
			self.body.moveState = MoveStates.neutral
		end
	end
	
	if self.invincibilityFrames ~= 0 then self.invincibilityFrames = self.invincibilityFrames - 1 end
	
	self:move(dt)
	
	-- check to see if it went off the edge and move based on the correction that gets returned 
	self.body.box:vectorMove(AABBvsScreenEdge(self.body.box, globalTileSize))
	
	self.body:tilemapCollisions()
	
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

function SimpleEnemy:draw()
	if self.image == nil then 
		self:loadImage()
	end
	love.graphics.draw(self.image, self.body.box.minVec.x, self.body.box.minVec.y)
end

function SimpleEnemy:loadImage()
	self.image = love.graphics.newImage("assets/tilesets/SimpleEnemy.png")
	self.image:setFilter("nearest", "nearest")
end

-- when an enemy goes off screen or dies, the image should be unloaded so that it doesn't waste mem.
function SimpleEnemy:unloadImage()
	self.image = nil 
end

function SimpleEnemy:drawDebug(i)
	self.body.box:drawCorners()
	-- print out the enemies array index and health
	love.graphics.setColor(0,0,0)
	love.graphics.print(i,self.body.box.minVec.x, self.body.box.minVec.y, 0, 0.5, 0.5)
	love.graphics.print("hp:"..self.body.currentHealth, self.body.box.minVec.x, self.body.box.minVec.y + 5, 0, 0.4, 0.4)
	love.graphics.setColor(255,255,255,255)
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
