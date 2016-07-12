--local shine = require "libraries/shine"
-- shine uses canvases so to get any of it to work with scale I either have to use canvases or change shine
-- look here instead https://github.com/mindreframer/love2d-games/blob/master/mari0/shaders/CRT-Simple.frag
-- and here for more info https://love2d.org/forums/viewtopic.php?t=80354


-- scale value should be decided based on screen size
-- should be able to set screen resolutions by menu (multiples of 160x144)

-- have a state for things
-- menu state or game state or cutscene state. something like that



local effects = nil
function loadGame(scaleValue)
	loadPlayer()	
	loadInput()
	loadMap(16, love.graphics.getWidth() / scaleValue, love.graphics.getHeight() / scaleValue)
	-- first 2 functions are in map. they shouldn't really be, should be more general
	loadUi(getTilesDisplayWidth(), getTilesDisplayHeight(), 16, getPlayerHeartContainers(), getPlayerHealth())
end

function updateGame(dt)
	updateMap()
	updatePlayer(dt)
	updateUi(dt , getPlayerHeartContainers(), getPlayerHealth())
end

function drawGame()
	drawTileSetBatch()
	drawPlayer()

	drawUi()
	--[[effects:draw(function()
		drawTileSetBatch()
		drawPlayer()
    end)]]

end 