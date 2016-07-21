--local shine = require "libraries/shine"
-- shine uses canvases so to get any of it to work with scale I either have to use canvases or change shine
-- look here instead https://github.com/mindreframer/love2d-games/blob/master/mari0/shaders/CRT-Simple.frag
-- and here for more info https://love2d.org/forums/viewtopic.php?t=80354


-- should be able to set screen resolutions by menu (multiples of 160x144)

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


-- should recoil just be made a bool in body since it overrides all other states?
MoveStates = {neutral = "neutral", walking = "walking", recoil = "recoil", attacking = "attacking"}
BodyStates = {neutral = "neutral", invincible = "invincible", dead = "dead", lowHealth = "lowHealth"}

local player1 = nil 
gameState = nil 

function loadGame(scaleValue)
	--local g1 = collectgarbage('count') * 0.00098
	
	gameState = GameStates.neutral

	-- has to happen first.
	loadMap(love.graphics.getWidth() / scaleValue, love.graphics.getHeight() / scaleValue)

	
	local playerPos = getPlayerStartingPosition()
	-- -1 because, while tables and everything will start at 1, the map physically starts at 0,0
	player1 = nil 
	player1 = Player:new(((playerPos.x-1) * globalTileSize), ((playerPos.y-1) * globalTileSize), 12, 16)
	loadInput()
	-- first 2 functions are in map. they shouldn't really be, should be more general
	-- 16 is the tile size 
	loadUi(getTilesDisplayWidth(), getTilesDisplayHeight(), player1:getPlayerHeartContainers(), player1:getPlayerHealth())
	
	
	--collectgarbage()
	--print("before: "..g1, "after: "..collectgarbage('count') * 0.00098)
end

local screenShiftAmount = 260
--local dtShiftX = 0 
--local dtShiftY = 0
local screenShiftX = 0 
local screenShiftY = 0

local gameOverFade = 0

DRAW_DEBUG = false 

function updateGame(dt)
	
	if getKeyPress("`") then DRAW_DEBUG = not DRAW_DEBUG end
	
	--[[if gameState ~= GameStates.pause and getKeyPress("1") then 
		gameState = GameStates.pause
	end]]

	-- the pause cancels the scrolling and messes everything up 
	-- account for that 
	if gameState == GameStates.pause then 
		--[[if getKeyPress("1") then 
			gameState = GameStates.neutral 
		end]]
	elseif gameState == GameStates.scrollComplete then 
		gameState = GameStates.neutral 
	elseif gameState == GameStates.gameOver then 
		gameOverFade = gameOverFade + (dt*8)
		gameOverFade = math.clamp(gameOverFade, 1)
		if getKeyPress("r") then 
			gameState = GameStates.neutral
			gameOverFade = 0
			loadGame(4)
		end	
	elseif gameState == GameStates.neutral then 
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
	drawEnemies()	
	player1:drawPlayer(screenShiftX, screenShiftY)
	drawUi()
	
	if DRAW_DEBUG then 
		debugDrawCollisionMap()
		debugDrawPlayerCollisionBounds(player1:getPlayerCoord())
		player1:drawDebug()
	end
	
	if gameState == GameStates.gameOver then 		
		love.graphics.setColor(0,0,0,gameOverFade * 255)
		love.graphics.rectangle("fill", 0,0,baseScreenWidth, baseScreenHeight)
		love.graphics.setColor(255,0,0,gameOverFade * 255)
		love.graphics.print("You ded, fam\nr to restart", 40, 50)
		love.graphics.setColor(255,255,255,255)
	end
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
