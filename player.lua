

local player = {box = AABB:new(40, 40, 12, 16), vel = Vector:new(0,0), heartContainers = 13, currentHealth = 4.50, facingDirection = nil}

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


local animationTimerValue = 0 
local animationIndex = 1
local animationTimerMax = 1
--[[function animationTimer(dt)
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
	
	local tileSize = getTileSize()
	
	-- + 1 because it'll floor to 0 and tilemaps (really tables) all start at <1,1> 
	local playerMapX = math.floor(player.box.minVec.x / tileSize) + 1
	local playerMapY = math.floor(player.box.minVec.y / tileSize) + 1
 
	player.box:vectorMove(checkIfMovedToNextTileMap(player.box, playerMapX, playerMapY))
	
	if (checkTileMapCollision(player.box, playerMapX, playerMapY)) then player.box:scalarMove(-player.vel.x, -player.vel.y) end
	
	--animationTimer(dt)
end





function drawPlayer()
	love.graphics.draw(playerTilesetImage, playerQuads.neutral[animationIndex], player.box.minVec.x, player.box.minVec.y)
end


function getPlayerHealth()
	return player.currentHealth
end

function getPlayerHeartContainers()
	return player.heartContainers
end
