keys = {}

local gameButtons = {}
gameButtons.up = "up"
gameButtons.down = "down"
gameButtons.left = "left"
gameButtons.right = "right"

local input_debug = true

-- key press callback
function love.keypressed(key)
    if input_debug then 
        if key == "escape" then
            love.event.quit()
        end
        print(key)
    end
    keys[key] = {down = true} 
end

-- key released callback
function love.keyreleased(key)
    keys[key] = {down = false} 
end

function loadInput()
    keys[gameButtons.up] = {down = false }
    keys[gameButtons.down] = {down = false }
    keys[gameButtons.left] = {down = false }
    keys[gameButtons.right] = {down = false }
end 

-- just check if a key is down
function getKeyDown(key)
	if not keys[key] then 
		keys[key] = {down = false}
	elseif keys[key].down then 
		return true
	end
	return false
end

-- checking if a key is pressed. key will be set as released once checked
function getKeyPress(key)
	if not keys[key] then 
		keys[key] = {down = false}
	elseif keys[key].down then 
		keys[key].down = false
		return true
	end
	return false
end