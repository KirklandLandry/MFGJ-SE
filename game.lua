--local shine = require "libraries/shine"
-- shine uses canvases so to get any of it to work with scale I either have to use canvases or change shine
-- look here instead https://github.com/mindreframer/love2d-games/blob/master/mari0/shaders/CRT-Simple.frag
-- and here for more info https://love2d.org/forums/viewtopic.php?t=80354


-- scale value should be decided based on screen size
-- should be able to set screen resolutions by menu (multiples of 160x144)

-- have a state for things
-- menu state or game state or cutscene state. something like that
Directions = {up = "up", down = "down", left = "left", right = "right"}
 function getRandomDirection()
	local r = math.random(1,100)
	local result = Directions.up 
	if r <=25 then 
		result = Directions.up 
	elseif r <=50 then 
		result = Directions.down 
	elseif r <= 75 then 
		result = Directions.left
	elseif r <= 100 then 
		result = Directions.right
	end
	return result 
 end

GameStates = {neutral = "neutral", pause = "pause", gameOver = "gameOver", title = "title",
			  scrollingUp = "scrollingUp", scrollingDown = "scrollingDown", scrollingLeft = "scrollingLeft", scrollingRight = "scrollingRight",  scrollComplete = "scrollComplete"}
gameState = nil 

MoveStates = {neutral = "neutral", walking = "walking", recoil = "recoil", attacking = "attacking"}
BodyStates = {neutral = "neutral", invincible = "invincible", dead = "dead", lowHealth = "lowHealth"}

local player1 = nil 

function loadGame(scaleValue)
	gameState = GameStates.neutral

	-- has to happen first.
	loadMap(love.graphics.getWidth() / scaleValue, love.graphics.getHeight() / scaleValue)

	
	local playerPos = getPlayerStartingPosition()
	player1 = Player:new((playerPos.x * globalTileSize)+(globalTileSize/2), (playerPos.y * globalTileSize)+(globalTileSize/2), 12, 16)
	loadInput()
	-- first 2 functions are in map. they shouldn't really be, should be more general
	-- 16 is the tile size 
	loadUi(getTilesDisplayWidth(), getTilesDisplayHeight(), player1:getPlayerHeartContainers(), player1:getPlayerHealth())
end

local screenShiftAmount = 260
--local dtShiftX = 0 
--local dtShiftY = 0
local screenShiftX = 0 
local screenShiftY = 0

function updateGame(dt)
	if gameState == GameStates.scrollComplete then gameState = GameStates.neutral end
	
	if gameState == GameStates.neutral then 
		player1:update(dt)
		updateMap(dt, player1:getPlayerAttack())
		
		updateUi(dt , player1:getPlayerHeartContainers(), player1:getPlayerHealth())
	else
		updateScreenShift(dt)
		--shiftPlayer(dtShiftX, dtShiftY)
		if gameState == GameStates.scrollComplete then 
			--shiftPlayerComplete()
			updateMap(dt)		
		end
	end
end

function drawGame()
	drawTileSetBatch(screenShiftX, screenShiftY)
	debugDrawCollisionMap()
	debugDrawPlayerCollisionBounds(player1:getPlayerCoord())
	
	player1:drawPlayer(screenShiftX, screenShiftY)
	drawUi()
end 

-- idea for shifting the player
-- to draw the player just draw them at the shift x and shift y 
function updateScreenShift(dt)
	if gameState == GameStates.scrollingUp then 
		screenShiftY = screenShiftY + (screenShiftAmount * dt)
		--dtShiftY = (screenShiftAmount * dt)
	elseif gameState == GameStates.scrollingDown then
		screenShiftY = screenShiftY - (screenShiftAmount * dt)
		--dtShiftY = -(screenShiftAmount * dt)
	elseif gameState == GameStates.scrollingLeft then
		screenShiftX = screenShiftX + (screenShiftAmount * dt)
		--dtShiftX = (screenShiftAmount * dt)
	elseif gameState == GameStates.scrollingRight then
		screenShiftX = screenShiftX - (screenShiftAmount * dt)
		--dtShiftX = -(screenShiftAmount * dt)
	end
	
	if math.abs(screenShiftX) >= baseScreenWidth then 
		screenShiftX = 0
		gameState = GameStates.scrollComplete		
	elseif math.abs(screenShiftY) >= baseScreenHeight - globalTileSize then
		screenShiftY = 0
		gameState = GameStates.scrollComplete	
	end
end