--local shine = require "libraries/shine"
-- shine uses canvases so to get any of it to work with scale I either have to use canvases or change shine
-- look here instead https://github.com/mindreframer/love2d-games/blob/master/mari0/shaders/CRT-Simple.frag
-- and here for more info https://love2d.org/forums/viewtopic.php?t=80354


-- scale value should be decided based on screen size
-- should be able to set screen resolutions by menu (multiples of 160x144)

-- have a state for things
-- menu state or game state or cutscene state. something like that
directions = {up = "up", down = "down", left = "left", right = "right"}
 function getRandomDirection()
	local r = math.random(1,100)
	print(r)
	local result = directions.up 
	if r <=25 then 
		result = directions.up 
	elseif r <=50 then 
		result = directions.down 
	elseif r <= 75 then 
		result = directions.left
	elseif r <= 100 then 
		result = directions.right
	end
	return result 
 end

GameStates = {scrollingUp = "scrollingUp", scrollingDown = "scrollingDown", scrollingLeft = "scrollingLeft", scrollingRight = "scrollingRight", neutral = "neutral", scrollComplete = "scrollComplete"}
gameState = nil 

local effects = nil
function loadGame(scaleValue)
	gameState = GameStates.neutral

	loadPlayer()	
	loadInput()
	loadMap(love.graphics.getWidth() / scaleValue, love.graphics.getHeight() / scaleValue)
	-- first 2 functions are in map. they shouldn't really be, should be more general
	-- 16 is the tile size 
	loadUi(getTilesDisplayWidth(), getTilesDisplayHeight(), getPlayerHeartContainers(), getPlayerHealth())
end

local screenShiftAmount = 230
--local dtShiftX = 0 
--local dtShiftY = 0
local screenShiftX = 0 
local screenShiftY = 0

function updateGame(dt)
	if gameState == GameStates.scrollComplete then gameState = GameStates.neutral end
	
	if gameState == GameStates.neutral then 
		updatePlayer(dt)
		updateMap(dt)
		
		updateUi(dt , getPlayerHeartContainers(), getPlayerHealth())
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
	drawPlayer(screenShiftX, screenShiftY)
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