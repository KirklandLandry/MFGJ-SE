require "input"
require "vector"
require "aabb"
require "map"
require "framerateLock"
require "player"
require "game" 
require "queue"
require "ui"

screenWidth = nil
screenHeight = nil

-- for later...
-- a lua state system
--[[
State = {one = "waiting", two = "active"}
local state = State.one 
local state2 = State.two 
if state = State.one then 
	print("currently waiting")
end

a note on equality ...
	local test = {one = "one"}
	test.two = "two"
	test["three"] = "three"
	print(test.one, test.two, test.three, test["one"], test["two"], test["three"])
	-- all assignments should print properly and are all equivalent.
]]

-- NOTE: 
-- try to get the scroll to the next screen working 
-- it should work like...
-- detect move to next screen
-- stop doing everything else
-- draw current screen and next screen 
-- shift screens until positions are swapped
-- should last ~ 1 second or less 
-- no spritebatch updating should be done. should just be 2 screen size png's that're being moved 

-- will need to implement a z coordinate for going up / down 
-- if you go into a house, how will that work 
-- is that a seperate world 
-- does it exist on another z plane. does it exist on it's own z plane 
-- same idea for caves and dungeons 

directions = {up = "up", down = "down", left = "left", right = "right"}

local scaleValue = 4

function love.load(arg)
	--for i=1,#arg do print(arg[i]) end
	local success = love.window.setMode(160 * scaleValue, 144 * scaleValue)
	if not success then error("failed to set window size") end 
	
	love.graphics.setDefaultFilter("nearest", "nearest")
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	
	loadGame(scaleValue)
	loadFramerateLock()
end

function love.update(dt)
	updateFramerateLock()
	updateGame(dt)
end 

function love.draw()
	love.graphics.scale(scaleValue)
	drawGame()
	love.graphics.reset()
	drawFramerateLock()
end

-------------- additional math functions --------------
function math.getSign(x)
	if x < 0 then
 		return -1
	elseif x > 0 then
		return 1
	else
		return 0
	end
end

function math.round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end
-------------------------------------------------------
