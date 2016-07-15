local PlayerStates = {walking = "walking", recoil = "recoil", neutral = "neutral", invincible = "invincible", dead = "dead", lowHealth = "lowHealth", attacking = "attacking"}

local player = {box = AABB:new(110, 60, 12, 16), vel = Vector:new(0,0), heartContainers = 13, currentHealth = 4.50, 
				facingDirection = nil, moveState = PlayerStates.neutral, bodyState = PlayerStates.neutral, 
				invincibilityTimer = nil, recoilTimer = nil, attack = nil }

local playerQuads = nil
local playerTileset = nil

-- debug. remove later.
function getPlayerCoord()
	return Vector:new(player.box.minVec.x, player.box.minVec.y)
end

function loadPlayer() 
	player.facingDirection = directions.down

	player.invincibilityTimer = Timer:new(1, "single")
	player.recoilTimer = Timer:new(0.14, "single")
	
	player.attack = Attack:new(0.25, 12)
	
	playerTilesetImage = love.graphics.newImage("assets/tilesets/player.png")
	playerTilesetImage:setFilter("nearest", "nearest")
	
	playerQuads = {}
	playerQuads.neutral = {}
	playerQuads.neutral[1] = love.graphics.newQuad(0,0,12, globalTileSize, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
	playerQuads.neutral[2] = love.graphics.newQuad(12*1,0,12, globalTileSize, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
	playerQuads.neutral[3] = love.graphics.newQuad(12*2,0,12, globalTileSize, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
	playerQuads.neutral[4] = love.graphics.newQuad(12*3,0,12, globalTileSize, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
end 

local animationIndex = 1


-- this needs to be calculated
local recoilAmount = 70
local recoilX = 10 
local recoilY = 10
function updatePlayer(dt)
	
	if player.bodyState == PlayerStates.invincible then 
		if player.invincibilityTimer:isComplete(dt) then 
			player.bodyState = PlayerStates.neutral
		end
	end
	
	if player.moveState == PlayerStates.recoil then 
		if player.recoilTimer:isComplete(dt) then 
			if player.moveState == PlayerStates.recoil then 
				player.moveState = PlayerStates.neutral 
			end
		end	
		-- move the player
		player.box:scalarMove(recoilX * dt, recoilY * dt)
	else 
		local impulse = 40
		player.vel.x = 0
		player.vel.y = 0
		
		if getKeyPress("h") and player.moveState ~= PlayerStates.attacking then 
			-- attack
			player.moveState = PlayerStates.attacking
			player.attack:reset()
			
			if player.facingDirection == directions.right then 
				player.attack.box = AABB:new(player.box.maxVec.x, player.box.minVec.y,16,16)
			elseif player.facingDirection == directions.left then 
				player.attack.box = AABB:new(player.box.minVec.x - 16, player.box.minVec.y,16,16)
			elseif player.facingDirection == directions.up then 
				player.attack.box = AABB:new(player.box.minVec.x, player.box.minVec.y - 16,16,16)
			elseif player.facingDirection == directions.down then 
				player.attack.box = AABB:new(player.box.minVec.x, player.box.maxVec.y,16,16)
			end	
		end
		
		if player.moveState ~= PlayerStates.attacking then 
			if getKeyDown("up") then 
				player.vel.y = -impulse * dt
				player.facingDirection = directions.up
				animationIndex = 4
			elseif  getKeyDown("down") then 
				player.vel.y = impulse * dt
				player.facingDirection = directions.down
				animationIndex = 1
			end	
			if getKeyDown("left") then 
				player.vel.x = -impulse * dt
				player.facingDirection = directions.left
				animationIndex = 2
			elseif getKeyDown("right") then 
				player.vel.x = impulse * dt
				player.facingDirection = directions.right
				animationIndex = 3
			end
		end
		
		-- debug change health 
		if getKeyPress("q") then player.currentHealth = player.currentHealth - 0.25 end 
		if getKeyPress("e") then player.currentHealth = player.currentHealth + 0.25 end 	

		if player.moveState == PlayerStates.attacking then 
			if player.attack:isComplete() then 
				player.moveState = PlayerStates.neutral
			end
		else 
			-- move the player
			player.box:scalarMove(player.vel.x, player.vel.y)
		end 
	end
	
	local collisionInfo = playerVsEnemiesCollisions(player.box)
	-- check for collisions with enemies on the current tilemap
	if collisionInfo ~= nil and player.moveState ~= PlayerStates.recoil and player.bodyState ~= PlayerStates.invincible then 	
		-- draw a recoil animation
		player.box:scalarMove(collisionInfo.normal.x * collisionInfo.penetration, collisionInfo.normal.y * collisionInfo.penetration)
		
		player.moveState = PlayerStates.recoil
		player.bodyState = PlayerStates.invincible
		
		player.invincibilityTimer:reset()
		player.recoilTimer:reset()
		
		recoilX = collisionInfo.normal.x * recoilAmount
		recoilY = collisionInfo.normal.y * recoilAmount

		player.currentHealth = player.currentHealth - 0.25
	end
	
	-- get the player's tile coordinates
	local playerMapCoords = getTileCoordinate(player.box.minVec.x, player.box.minVec.y)
	
	-- check for moving to the next tilemap
	local shiftVector = (checkIfMovedToNextTileMap(player.box, playerMapCoords.x, playerMapCoords.y))
	player.box:vectorMove(shiftVector)
	
	-- check for collisions against the tilemap 
	-- this is very cheap, it only reverses the player's velocity on collision 
	-- this shouldn't be needed once the collision method below works properly 
	if (checkTileMapCollision(player.box, playerMapCoords.x, playerMapCoords.y)) then player.box:scalarMove(-player.vel.x, -player.vel.y) end
	
	
	-- runs twice. once for x and once for y. 
	-- this could be collapsed into one thing, do that later 
	local tilemapCorrectionInfo = checkTileMapCollision(player.box, playerMapCoords.x, playerMapCoords.y)
	if tilemapCorrectionInfo ~= nil then 
		player.box:scalarMove(tilemapCorrectionInfo.normal.x * tilemapCorrectionInfo.penetration, tilemapCorrectionInfo.normal.y * tilemapCorrectionInfo.penetration)
	end
	
	local tilemapCorrectionInfo = checkTileMapCollision(player.box, playerMapCoords.x, playerMapCoords.y)
	if tilemapCorrectionInfo ~= nil then 
		player.box:scalarMove(tilemapCorrectionInfo.normal.x * tilemapCorrectionInfo.penetration, tilemapCorrectionInfo.normal.y * tilemapCorrectionInfo.penetration)
	end
	

end

function getPlayerAttack()
	if player.moveState == PlayerStates.attacking then 
		return player.attack
	else 
		return nil 
	end
end


function drawPlayer(screenShiftX, screenShiftY)

	if player.bodyState == PlayerStates.invincible then 
		love.graphics.setColor(200,200,200,170)
	end

	if gameState == GameStates.neutral or 
	math.floor(screenShiftX) == math.floor(player.box.minVec.x) or 
	math.floor(screenShiftY) == math.floor(player.box.minVec.y) then
	
		love.graphics.draw(playerTilesetImage, playerQuads.neutral[animationIndex], player.box.minVec.x, player.box.minVec.y)
	elseif gameState == GameStates.scrollingRight then 
		love.graphics.draw(playerTilesetImage, playerQuads.neutral[animationIndex], baseScreenWidth + screenShiftX, player.box.minVec.y)
	elseif gameState == GameStates.scrollingLeft then 
		love.graphics.draw(playerTilesetImage, playerQuads.neutral[animationIndex], screenShiftX, player.box.minVec.y)
	elseif gameState == GameStates.scrollingUp then 
		love.graphics.draw(playerTilesetImage, playerQuads.neutral[animationIndex], player.box.minVec.x, screenShiftY)
	elseif gameState == GameStates.scrollingDown then 
		love.graphics.draw(playerTilesetImage, playerQuads.neutral[animationIndex], player.box.minVec.x, baseScreenHeight - globalTileSize + screenShiftY)	
	end
	
	-- put in a sword anim or something 
	if player.moveState == PlayerStates.attacking then 
		love.graphics.rectangle("fill", player.attack.box.minVec.x, player.attack.box.minVec.y, player.attack.box.width, player.attack.box.height)
	end 
		
	love.graphics.setColor(255,255,255)
	player.box:drawCorners()
end

function getPlayerHealth()
	return player.currentHealth
end

function getPlayerHeartContainers()
	return player.heartContainers
end
