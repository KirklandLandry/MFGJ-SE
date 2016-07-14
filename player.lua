local PlayerStates = {walking = "walking", recoil = "recoil", neutral = "neutral", invincible = "invincible"}

local player = {box = AABB:new(110, 60, 12, 16), vel = Vector:new(0,0), heartContainers = 13, currentHealth = 4.50, facingDirection = nil, moveState = PlayerStates.neutral}

local playerQuads = nil
local playerTileset = nil


function loadPlayer() 
	player.facingDirection = directions.down

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

local timerValue = 0
local timerMax = 0.14
function updatePlayerTimer(dt)
	timerValue = timerValue + dt 
	if timerValue > timerMax then 
		timerValue = 0 
		if player.moveState == PlayerStates.recoil then 
			player.moveState = PlayerStates.neutral 
		end
	end
end

-- this needs to be calculated
-- give him an inivincibility / health state seperate from recoil (movestate)
local recoilAmount = 70
local recoilX = 10 
local recoilY = 10
function updatePlayer(dt)
	
	if player.moveState == PlayerStates.recoil then 
		updatePlayerTimer(dt)
		-- move the player
		player.box:scalarMove(recoilX * dt, recoilY * dt)
	else 
		local impulse = 40
		player.vel.x = 0
		player.vel.y = 0
		
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
		
		-- debug change health 
		if getKeyPress("q") then player.currentHealth = player.currentHealth - 0.25 end 
		if getKeyPress("e") then player.currentHealth = player.currentHealth + 0.25 end 	

		-- move the player
		player.box:scalarMove(player.vel.x, player.vel.y)
	end
	
	
	local collisionInfo = playerVsEnemiesCollisions(player.box)
	-- check for collisions with enemies on the current tilemap
	if collisionInfo ~= nil and player.moveState ~= PlayerStates.recoil then 
		
		-- draw a recoil animation
		player.box:scalarMove(collisionInfo.normal.x * collisionInfo.penetration, collisionInfo.normal.y * collisionInfo.penetration)
		
		player.moveState = PlayerStates.recoil
		
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
	if (checkTileMapCollision(player.box, playerMapCoords.x, playerMapCoords.y)) then player.box:scalarMove(-player.vel.x, -player.vel.y) end
end


function drawPlayer(screenShiftX, screenShiftY)
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
	
	player.box:drawCorners()
end


function getPlayerHealth()
	return player.currentHealth
end

function getPlayerHeartContainers()
	return player.heartContainers
end
