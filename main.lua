require "input"
require "vector"
require "aabb"
require "map"
require "framerateLock"
require "player"
require "game"

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

function love.load(arg)
	--for i=1,#arg do print(arg[i]) end
	love.graphics.setDefaultFilter("nearest", "nearest")
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	loadGame()
	loadFramerateLock()
end

function love.update(dt)
	updateFramerateLock()
	updateGame(dt)
end 

function love.draw()
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
