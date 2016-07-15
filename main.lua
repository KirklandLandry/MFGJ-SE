require "input"
require "vector"
require "aabb"
require "map"
require "framerateLock"
require "player"
require "game" 
require "queue"
require "ui"
require "collision"
require "enemyManager"
require "timer"
require "attack"

-- this is the actual physical window size 
screenWidth = nil
screenHeight = nil

-- this is the gameboy screen size. 
-- The game is scaled up from this, but game values should measure against this 
baseScreenWidth = 160
baseScreenHeight = 144

-- the game draws at 160x144 and is scaled up by scalevalue
local scaleValue = 4
-- default tile sizes are 16x16
globalTileSize = 16

-- NOTE: 
-- work on seperating map and collision / enemy management

-- NOTE: 
-- change attack frames to be more like fighting games 
-- startup, active frames, cooldown  
-- either that, or work on giving attacks (and other stuff) pixel perfect collision
-- also, the player's box should be a bit less than the player sprite probably. it should also be able to change based on 
-- animation (so a bounding box size / position is linked to a frame)

-- NOTE:
-- could enemy and player be collapsed into 1 base type? 
-- most of it is fairly similar and it would make all of the code more generic and 
-- make it easier to work with. Something to consider before things go too far.

-- NOTE: 
-- get enemy bounceback working

-- NOTE: 
-- the structure of stuff has become somewhat wonky 
-- player should be an object that gets created which lets it be handled more easily
-- it's getting kind of weird with bits of collision in map and also in player
-- also, map handles a lot right now, not just being a map 
-- it also handles most of the collision stuff and world stuff (enemies/map)

-- NOTE: 
-- need to change how tilemap switching works
-- when you move right, detect the change based on the player min x 
-- when you move left, detect the change based on the player max x 
-- this makes the map switching look more consistent 

-- WARNING: 
-- player map switching is messy. 
-- the way it's setup you can see the player in their last position for 1 frame 
-- it's setup cheaply and it's not great, but it works 
-- maybe the whole thing should be shifted using love.graphics.translate ?

-- WARNING:
-- need to switch up how tilemap collision works 
-- right now it's just simple reverse the amount moved 
-- the problem with this is if an enemy bumps you into a wall then you're stuck
-- need to do a proper detection and resolution

-- NOTE:
-- tilemaps object should keep info like...
-- enemies
-- chests
-- interactable objects and their states
-- multiple layers / height

-- NOTE:
-- should maybe seperate the map into a collision layer and tile layer. yes, do this.

-- NOTE: 
-- try adding a minimap?

-- NOTE: 
-- don't start enemies too close together. also get enemy-enemy collision detection/resolution going

-- NOTE: 
-- should make a generic spritebatch loop. can't have one for map, but everything else should be generic enough
-- also, think about making a spritebatching class

-- NOTE: 
-- will need to implement a z coordinate for going up / down 
-- if you go into a house, how will that work 
-- is that a seperate world 
-- does it exist on another z plane. does it exist on it's own z plane 
-- same idea for caves and dungeons 


function love.load(arg)
	--for i=1,#arg do print(arg[i]) end
	math.randomseed(os.time())
	math.random()
	math.random()
	
	local success = love.window.setMode(baseScreenWidth * scaleValue, baseScreenHeight * scaleValue)
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
function math.sign(x)
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
