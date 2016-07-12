
local player = {box = AABB:new(40, 40, 12, 16), vel = Vector:new(0,0)}

local playerQuads = nil
local playerTileset = nil


function loadPlayer() 

	playerTilesetImage = love.graphics.newImage("assets/tilesets/player.png")
	playerTilesetImage:setFilter("nearest", "nearest")

	playerQuads = {}
	playerQuads.neutral = {}
	playerQuads.neutral[1] = love.graphics.newQuad(0,0,12, 16, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
	playerQuads.neutral[2] = love.graphics.newQuad(12,0,12, 16, playerTilesetImage:getWidth(), playerTilesetImage:getHeight())
		
end 

function updatePlayer(dt)
	
	local impulse = 60

	player.vel.x = 0
	player.vel.y = 0
	
	if getKeyDown("up") then 
		player.vel.y = -impulse * dt
	elseif  getKeyDown("down") then 
		player.vel.y = impulse * dt
	end	
	if getKeyDown("left") then 
		player.vel.x = -impulse * dt
	elseif getKeyDown("right") then 
		player.vel.x = impulse * dt
	end

	player.box:scalarMove(player.vel.x, player.vel.y)
	
	local tileSize = getTileSize()
	
	local playerMapX = math.floor(player.box.minVec.x / tileSize) + 1
	local playerMapY = math.floor(player.box.minVec.y / tileSize) + 1
 
	player.box:vectorMove(checkIfMovedToNextTileMap(playerMapX, playerMapY))
	
	if (checkTileMapCollision(player.box, playerMapX, playerMapY)) then player.box:scalarMove(-player.vel.x, -player.vel.y) end
	
	animationTimer(dt)
end


local animationTimerValue = 0 
local animationIndex = 1
local animationTimerMax = 1
function animationTimer(dt)
	animationTimerValue = animationTimerValue + dt 
	if animationTimerValue > animationTimerMax then 
		animationTimerValue = 0 
		animationIndex = animationIndex + 1 
		if animationIndex > 2 then animationIndex = 1 end
	end
end


function drawPlayer()
	love.graphics.draw(playerTilesetImage, playerQuads.neutral[animationIndex], player.box.minVec.x, player.box.minVec.y)
end