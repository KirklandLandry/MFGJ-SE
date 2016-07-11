keys = {}


gameButtons = {}
gameButtons.up = "up"
gameButtons.down = "down"
gameButtons.left = "left"
gameButtons.right = "right"

local input_debug = true

function love.keypressed(key)
    if input_debug then 
        if key == "escape" then
            love.event.quit()
        end
        print(key)
    end
    keys[key] = {down = true} 
end

function love.keyreleased(key)
    keys[key] = {down = false} 
end

function initInput()
    keys[gameButtons.up] = {down = false }
    keys[gameButtons.down] = {down = false }
    keys[gameButtons.left] = {down = false }
    keys[gameButtons.right] = {down = false }
end 

function getKeyDown(key)
	if not keys[key] then 
		keys[key] = {down = false}
	elseif keys[key].down then 
		return true
	end
	return false
end

function getKeyPress(key)
	if not keys[key] then 
		keys[key] = {down = false}
	elseif keys[key].down then 
		keys[key].down = false
		return true
	end
	return false
end