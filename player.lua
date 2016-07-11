
local player = {box = AABB:new(40, 40, 12, 16), vx = 0, vy = 0, }

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

	player.vx = 0
	player.vy = 0
	
	if getKeyDown("up") then 
		player.vy = -impulse * dt
	elseif  getKeyDown("down") then 
		player.vy = impulse * dt
	end	
	if getKeyDown("left") then 
		player.vx = -impulse * dt
	elseif getKeyDown("right") then 
		player.vx = impulse * dt
	end

	player.box:scalarMove(player.vx, player.vy)
	
	local tileSize = getTileSize()
	
	local playerMapX = math.floor(player.box.minVec.x / tileSize) + 1
	local playerMapY = math.floor(player.box.minVec.y / tileSize) + 1
 
	player.box:vectorMove(checkIfMovedToNextTileMap(playerMapX, playerMapY))
	
	if (checkTileMapCollision(player.box, playerMapX, playerMapY)) then player.box:scalarMove(-player.vx, -player.vy) end
	
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