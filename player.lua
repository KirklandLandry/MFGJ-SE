
Player = {body = nil, invincibilityTimer = nil, attack = nil, playerQuads = nil,  playerTileset = nil, animationIndex = 1}
	
-- this needs to be calculated
local recoilAmount = 70	

function Player:new(x, y, width, height)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.body = Body:new(x, y, width, height, 3,1, 0.14)
	
	o.facingDirection = Directions.down
	o.moveState = MoveStates.neutral 
	o.bodyState = BodyStates.neutral
	
	o.invincibilityTimer = Timer:new(1, "single")
	
	o.attack = Attack:new(0.25, 12)
	
	o.playerTilesetImage = love.graphics.newImage("assets/tilesets/player.png")
	o.playerTilesetImage:setFilter("nearest", "nearest")
	
	local tilesetWidth = o.playerTilesetImage:getWidth()
	local tilesetHeight = o.playerTilesetImage:getHeight()
	
	o.playerQuads = {}
	o.playerQuads.neutral = {}
	o.playerQuads.neutral[1] = love.graphics.newQuad(0,0,12, globalTileSize, tilesetWidth, tilesetHeight)
	o.playerQuads.neutral[2] = love.graphics.newQuad(12*1,0,12, globalTileSize, tilesetWidth, tilesetHeight)
	o.playerQuads.neutral[3] = love.graphics.newQuad(12*2,0,12, globalTileSize, tilesetWidth, tilesetHeight)
	o.playerQuads.neutral[4] = love.graphics.newQuad(12*3,0,12, globalTileSize, tilesetWidth, tilesetHeight)
	
	return o
end


function Player:update(dt)	
	local topLeft = self:getTopLeft()
	local bottomRight = self:getBottomRight()
	
	-- debug change health. remove later
	if getKeyPress("q") then self.body.currentHealth = self.body.currentHealth - 0.25 end 
	if getKeyPress("e") then self.body.currentHealth = self.body.currentHealth + 0.25 end 	

	local attackButtonPressed = getKeyPress("h")
	
	if self.body.bodyState == BodyStates.invincible then 
		if self.invincibilityTimer:isComplete(dt) then 
			self.body.bodyState = BodyStates.neutral
		end
	end
	
	if self.body.moveState == MoveStates.recoil then 
		if self.body.recoilTimer:isComplete(dt) then 
			if self.body.moveState == MoveStates.recoil then 
				self.body.moveState = MoveStates.neutral 
			end
		end	
		-- move the player
		self.body.box:scalarMove(self.body.recoilX * dt, self.body.recoilY * dt)
	end 
	
	if getKeyPress("y") then 
		self.body.maxHealth = self.body.maxHealth + 1 
	end
	
	local impulse = 40
	self.body.vel.x = 0
	self.body.vel.y = 0
	
	local inputDirectionVector = Vector:new(0,0)
	if getKeyDown("up") then 
		inputDirectionVector.y = -1 
	elseif getKeyDown("down") then 
		inputDirectionVector.y = 1 
	end
	if getKeyDown("left") then 
		inputDirectionVector.x = -1 
	elseif getKeyDown("right") then 
		inputDirectionVector.x = 1 
	end
	
	if attackButtonPressed and self.body.moveState ~= MoveStates.attacking and self.body.moveState ~= MoveStates.recoil then 
		-- attack
		self.body.moveState = MoveStates.attacking
		self.attack:reset()
		
		if self.body.facingDirection == Directions.right then 
			self.attack.box = AABB:new(bottomRight.x, topLeft.y,16,16)
		elseif self.body.facingDirection == Directions.left then 
			self.attack.box = AABB:new(topLeft.x - 16, topLeft.y,16,16)
		elseif self.body.facingDirection == Directions.up then 
			self.attack.box = AABB:new(topLeft.x, topLeft.y - 16,16,16)
		elseif self.body.facingDirection == Directions.down then 
			self.attack.box = AABB:new(topLeft.x, bottomRight.y,16,16)
		end	
	end
	
	if self.body.moveState ~= MoveStates.attacking then 
		if inputDirectionVector.y == -1 then 
			self.body.vel.y = -impulse * dt
			self.body.facingDirection = Directions.up
			self.animationIndex = 4
		elseif  inputDirectionVector.y == 1 then 
			self.body.vel.y = impulse * dt
			self.body.facingDirection = Directions.down
			self.animationIndex = 1
		end	
		if inputDirectionVector.x == -1  then 
			self.body.vel.x = -impulse * dt
			self.body.facingDirection = Directions.left
			self.animationIndex = 2
		elseif inputDirectionVector.x == 1  then 
			self.body.vel.x = impulse * dt
			self.body.facingDirection = Directions.right
			self.animationIndex = 3
		end
	end

	if self.body.moveState == MoveStates.attacking then 
		if self.attack:isComplete() then 
			self.body.moveState = MoveStates.neutral
		end
	elseif self.body.moveState ~= MoveStates.recoil then 
		-- move the player
		self.body.box:scalarMove(self.body.vel.x, self.body.vel.y)
	end 
	
	local collisionInfo = self.body:checkEntityCollisions()
	-- check for collisions with enemies on the current tilemap
	if collisionInfo ~= nil and self.body.moveState ~= MoveStates.recoil and self.body.bodyState ~= BodyStates.invincible then 	
		self.body.box:scalarMove(collisionInfo.normal.x * collisionInfo.penetration, collisionInfo.normal.y * collisionInfo.penetration)
		
		self.body.moveState = MoveStates.recoil
		self.body.bodyState = BodyStates.invincible
		
		self.invincibilityTimer:reset()
		self.body.recoilTimer:reset()
		
		self.body.recoilX = collisionInfo.normal.x * recoilAmount
		self.body.recoilY = collisionInfo.normal.y * recoilAmount

		self.body.currentHealth = self.body.currentHealth - 0.25
	end
	
	
	if self.body.currentHealth <= 0 then 
		gameState = GameStates.gameOver
	end
	
	-- get the player's tile coordinates
	local playerTileCoordsMin = getTileCoordinate(topLeft.x, topLeft.y)
	local playerTileCoordsMax = getTileCoordinate(bottomRight.x, bottomRight.y)

	
	-- check for moving to the next tilemap
	local shiftVector = (checkIfMovedToNextTileMap(self.body.box, playerTileCoordsMin.x, playerTileCoordsMin.y, playerTileCoordsMax.x, playerTileCoordsMax.y))
	self.body.box:vectorMove(shiftVector)
	
	self.body:tilemapCollisions()
end


function Player:drawPlayer(screenShiftX, screenShiftY)

	if self.body.bodyState == BodyStates.invincible then 
		love.graphics.setColor(200,200,200,170)
	end

	if 
	gameState == GameStates.neutral or 
	math.floor(screenShiftX) == math.floor(self.body.box.minVec.x) or 
	math.floor(screenShiftY) == math.floor(self.body.box.minVec.y) then
	
		love.graphics.draw(self.playerTilesetImage, self.playerQuads.neutral[self.animationIndex], self.body.box.minVec.x, self.body.box.minVec.y)
	elseif gameState == GameStates.scrollingRight then 
		love.graphics.draw(self.playerTilesetImage, self.playerQuads.neutral[self.animationIndex], baseScreenWidth + screenShiftX, self.body.box.minVec.y)
	elseif gameState == GameStates.scrollingLeft then 
		love.graphics.draw(self.playerTilesetImage, self.playerQuads.neutral[self.animationIndex], screenShiftX, self.body.box.minVec.y)
	elseif gameState == GameStates.scrollingUp then 
		love.graphics.draw(self.playerTilesetImage, self.playerQuads.neutral[self.animationIndex], self.body.box.minVec.x, screenShiftY)
	elseif gameState == GameStates.scrollingDown then 
		love.graphics.draw(self.playerTilesetImage, self.playerQuads.neutral[self.animationIndex], self.body.box.minVec.x, baseScreenHeight - globalTileSize + screenShiftY)	
	end
	
	-- put in a sword anim or something 
	if self.body.moveState == MoveStates.attacking then 
		love.graphics.rectangle("fill", self.attack.box.minVec.x, self.attack.box.minVec.y, self.attack.box.width, self.attack.box.height)
	end 
		
	love.graphics.setColor(255,255,255)
	
end

function Player:drawDebug()
	self.body.box:drawCorners()
end


function Player:getPlayerHealth()
	return self.body.currentHealth
end

-- getPlayermaxHealth
function Player:getPlayerHeartContainers()
	return self.body.maxHealth
end


function Player:getPlayerAttack()
	if self.body.moveState == MoveStates.attacking then 
		return self.attack
	else 
		return nil 
	end
end

-- debug. remove later.
function Player:getPlayerCoord()
	return Vector:new(self.body.box.minVec.x, self.body.box.minVec.y)
end

function Player:getTopLeft()
	return self.body.box:getTopLeft()
end

function Player:getBottomRight()
	return self.body.box:getBottomRight()
end



