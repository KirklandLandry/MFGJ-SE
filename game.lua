local scaleValue = 4
-- scale value should be decided based on screen size
-- should be able to set screen resolutions by menu (multiples of 160x144)

function loadGame()
	loadPlayer()	
	loadInput()
	loadMap(love.graphics.getWidth() / scaleValue, love.graphics.getHeight() / scaleValue)
end

function updateGame(dt)
	updateMap()
	updatePlayer(dt)
end

function drawGame()
	love.graphics.scale(scaleValue)
	drawTileSetBatch()
	drawPlayer()
end