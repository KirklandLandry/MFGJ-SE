

local player = {box = AABB:new(110, 60, 12, 16), vel = Vector:new(0,0), heartContainers = 13, currentHealth = 4.50, facingDirection = nil}

local playerQuads = nil
local playerTileset = nil


function loadPlayer() 
	player.facingDirection = directions.down

	playerTilesetImage = love.graphics.newImage("assets/tilesets/player.png")
	playerTilesetImage:setFilter("nearest", "nearest")

	playerQuads = {}
	playerQuads.neutral = {}
	playerQuads.neutral[1] = love.graphics.newQuad(0,0,12, 16, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
	playerQuads.neutral[2] = love.graphics.newQuad(12*1,0,12, 16, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
	playerQuads.neutral[3] = love.graphics.newQuad(12*2,0,12, 16, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
	playerQuads.neutral[4] = love.graphics.newQuad(12*3,0,12, 16, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
	
end 

local animationIndex = 1
--[[local animationTimerValue = 0 
local animationTimerMax = 1
function animationTimer(dt)
	animationTimerValue = animationTimerValue + dt 
	if animationTimerValue > animationTimerMax then 
		animationTimerValue = 0 
		animationIndex = animationIndex + 1 
		if animationIndex > 2 then animationIndex = 1 end
	end
end]]


function updatePlayer(dt)
	
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
	
	if getKeyPress("q") then player.currentHealth = player.currentHealth - 0.25 end 
	if getKeyPress("e") then player.currentHealth = player.currentHealth + 0.25 end 

	
	player.box:scalarMove(player.vel.x, player.vel.y)
	
 
	local playerMapCoords = getTileCoordinate(player.box.minVec.x, player.box.minVec.y)
 
	local shiftVector = (checkIfMovedToNextTileMap(player.box, playerMapCoords.x, playerMapCoords.y))
	player.box:vectorMove(shiftVector)
	
	if (checkTileMapCollision(player.box, playerMapCoords.x, playerMapCoords.y)) then player.box:scalarMove(-player.vel.x, -player.vel.y) end

	--[[if shiftVector ~= nil then 
		
	else 
	
	end]]
	--shiftDestinationVector = checkIfMovedToNextTileMap(player.box, playerMapX, playerMapY)
	--checkIfMovedToNextTileMap(player.box, playerMapX, playerMapY)
	
	
	--animationTimer(dt)
end

function shiftPlayer(dtShiftX, dtShiftY)
	--player.box:scalarMove(dtShiftX, dtShiftY)
	--player.box:scalarReposition(88, player.box.minVec.y)
end

function shiftPlayerComplete()
	--player.box:scalarReposition(88, player.box.minVec.y)
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
		love.graphics.draw(playerTilesetImage, playerQuads.neutral[animationIndex], player.box.minVec.x, baseScreenHeight - 16 + screenShiftY)	
	end
end


function getPlayerHealth()
	return player.currentHealth
end

function getPlayerHeartContainers()
	return player.heartContainers
end
