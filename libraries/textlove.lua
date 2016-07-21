

-- fix the way portraits are done.

-- get a new font that's redistributable so I can upload to github
-- or just make my own

-- add support for sending in a script line directly (ie if it's something short / repetitive that can be locked in)
-- or import from file (for long scenes that don't need to be loaded into mem)

-- need to support multiple font sizes and resize based on that

-- allow a code for comments in the script parser
-- once this works with games, make an [ACTION] tag to do stuff. or not. just notify the game what message you're on. idk.

-- show the actors name under the portrait or something. or maybe not

-- look at mmzero https://www.youtube.com/watch?v=_11PyJM3yC8
-- make a generic text area type.
-- that text area can be used for this textbox, textbox without portrait, notification (like at 4:09)

-- allow multiple effects on a set of characters (like colour and wave)

-- asserts are for debug only. shouldn't exist in a final version

-- the actual box containing everything
-- everything should be positioned relative to this
local textBox = nil 

function initTextBox(screenWidth, screenHeight, x, width, y)
	textBox = {}
	textBox.pad = 8
	textBox.x = x or textBox.pad
	textBox.portraitWidth = 128
	textBox.portraitHeight = 128 
	textBox.y = y or (screenHeight - (textBox.pad + textBox.portraitHeight + textBox.pad + textBox.pad))
	textBox.width = width or (screenWidth - (2 * textBox.pad))
	textBox.height = textBox.pad + textBox.portraitHeight + textBox.pad
	textBox.textAreaX = textBox.x + textBox.pad + textBox.portraitWidth + textBox.pad
	textBox.textAreaY = textBox.y + textBox.pad 
	textBox.textAreaWidth =  textBox.width - (3 * textBox.pad) - textBox.portraitWidth
	textBox.textAreaHeight = textBox.height - (2 * textBox.pad)
end


-- an array containing all the messages to be displayed
local message = {}

-- the current message to display
local messageCurrent = nil
local messageEnd = nil

-- for text wave
local sineCounter = 0
local sineAmp = 3
local sineFreq = 3

local done = false

local currentPortraitObject = nil  
local defaultPortrait = nil

-- vars for typewriter effect
local charWidth = nil
local charHeight = nil
local charactersPerLine = nil -- how many characters per line
local linesPerTextBox = nil -- how many lines fit into the textbox
local maxCharsPerTextBox = nil
local nextCharWriteDelay = nil -- time delay between writing characters

local nextCharWriteTimer = nil -- timer for when to write the next character 
local charsToWrite = nil -- how many characters to write 

-- not currently used, could be used if different fonts are used within the same script
--local font = nil

-- alright, so the character has to be ` because (or whatever, really, just not \)
-- when you use \ and try to read from a file it always adds another \
-- to escape so \0 becomes \\0 making nothing work and I'm not sure if you can stop it
local textMods = {}
textMods.reset = "`0"
textMods.shaky = "`1"
textMods.wave = "`2"

local actors = nil

function loadText(fontTTF, fontSize, scriptFile, screenWidth, screenHeight, x, width, y)

	initTextBox(screenWidth, screenHeight, x, width, y)

	-- how to convert font size to font width / height?
	-- sizing depends on all this 
	-- good for 20pt 
	--charWidth = 7 + 3 -- the width of a character
	--charHeight = 25 -- the height of a character
	-- this is for 30pt
	charWidth = 16
	charHeight = 32

	if love.filesystem.exists(fontTTF) then 
		love.graphics.setNewFont(fontTTF, fontSize)
	else
		charWidth = 8
		charHeight = 12
	end
	
	nextCharWriteDelay = 0.05 -- time delay between writing characters
	
	charactersPerLine = math.floor(textBox.textAreaWidth / charWidth)
	linesPerTextBox = math.floor(textBox.textAreaHeight / charHeight)
	maxCharsPerTextBox = (charactersPerLine + 1) * linesPerTextBox

	--print(charactersPerLine, linesPerTextBox, maxCharsPerTextBox)

	local returnObjects = parseFile(scriptFile)
	actors = returnObjects.actors


	message = splitScriptLine(returnObjects.script)
	assert(#message > 1, "message is empty")

	messageCurrent = 1
	messageEnd = #message

	nextCharWriteTimer = 0
	charsToWrite = 0

	done = false
end

function isScriptDone()
	return done
end

function parseFile(file)
	assert(love.filesystem.exists(file), "file to parse doesn't exist")
	local actors = {}
	local script = {}
	local mode = ""
	local scriptLineIterator = 1

	for line in love.filesystem.lines(file) do
		if line:find("%[ACTORS%]") then mode = "ACTORS" 
		elseif line:find("%[LINES%]") then mode = "LINES" 
		elseif line:gsub("%s+", "") == "" then -- do nothing, blank line (replace all spaces with empty char to check)
		else
			local attributes = {}
			local n = 1
			for attribute in line:gmatch("[^=]+") do 
				attributes[n] = attribute
				n = n + 1
			end
			if mode == "ACTORS" then 
				actors[attributes[1]] = attributes[2]
				assert(love.filesystem.exists(attributes[2]), "actor portrait \n"..attributes[2].."\ndoesn't exist")
			elseif mode == "LINES" then 

				-- should check right here to make sure the line starts with an existing actor
				-- and then make sure it's followed by an equals (do this line:gsub("%s+", "") to remove all spaces)
				if actors[attributes[1]] ~= nil then 
					script[scriptLineIterator] = {actor = attributes[1], line = attributes[2]}
					scriptLineIterator = scriptLineIterator + 1
				else
					-- force use a default actor
					-- need to setup a default actor.
					-- if that fails, assert
				end
				
			end 
		end
	end
	local returnObject = {}
	returnObject.script = script
	returnObject.actors = actors
	return returnObject
end


function splitScriptLine(scriptToSplit)
	local result = {}	
	local messageCounter = 1
	for i=1,#scriptToSplit do 

	    local currentLine = 0	
	    local charactersOnCurrentLine = 0 
	    local currentCharIndex = 1
	    local lastIndex = 0
	    -- while the number of characters drawn is less than the maximum and less than amount to be shown
		while(currentCharIndex <= #scriptToSplit[i].line) do 

			-- check for text modifiers
			local charPlusOne = getChar(scriptToSplit[i].line, currentCharIndex)..getChar(scriptToSplit[i].line, currentCharIndex + 1)
			if charPlusOne == textMods.reset or charPlusOne == textMods.shaky or charPlusOne == textMods.wave then 
				currentCharIndex = currentCharIndex + 2
			end 

			local lengthOfCurrentWord = 0

			while getChar(scriptToSplit[i].line, currentCharIndex) ~= " " and currentCharIndex <= #scriptToSplit[i].line do
				currentCharIndex = currentCharIndex + 1
				lengthOfCurrentWord = lengthOfCurrentWord + 1
			end	

			local breakLine = false
			if charactersOnCurrentLine + lengthOfCurrentWord > charactersPerLine then 
				charactersOnCurrentLine = 0 
				currentLine = currentLine + 1 
				breakLine = true
			end
			currentCharIndex = currentCharIndex - lengthOfCurrentWord 

			-- remember, currentline starts at 0
			if currentLine == linesPerTextBox or currentCharIndex >= #scriptToSplit[i].line then 
				
				-- if it goes to a next line, currentCharIndex will be at the first char in the word
				-- so if breakline, then go from the previous character and the last index will be the current char
				-- else, go from the current character and the last index will be the next char
				if breakLine then 
					result[messageCounter] = {line = scriptToSplit[i].line:sub(lastIndex, currentCharIndex-1), actor = scriptToSplit[i].actor}
					lastIndex = currentCharIndex
				else
					result[messageCounter] = {line = scriptToSplit[i].line:sub(lastIndex, currentCharIndex), actor = scriptToSplit[i].actor}
					lastIndex = currentCharIndex + 1
				end

				currentLine = 0
				messageCounter = messageCounter + 1
			end 
			charactersOnCurrentLine = charactersOnCurrentLine + 1
			currentCharIndex = currentCharIndex + 1	
		end 
	end
	assert(#result > 1, "script was split incorrectly")
	return result
end

-- dt and a bool whether or not to advance text
function updateText(dt, advanceText)
	
	if not done then 
		assert(messageEnd > 1, "message end needs to be > 1")

		if messageEnd > 1 then 

			-- typewriter effect 
			if charsToWrite < #message[messageCurrent].line then 
				if nextCharWriteTimer >= nextCharWriteDelay then 
					charsToWrite = charsToWrite + 1
					nextCharWriteTimer = 0
				else
					nextCharWriteTimer = nextCharWriteTimer + dt
				end 
			end		

			if advanceText then 
				if charsToWrite < #message[messageCurrent].line then 
					charsToWrite = #message[messageCurrent].line
				elseif messageCurrent < messageEnd then 
					sineCounter = 0
					messageCurrent = messageCurrent + 1
					charsToWrite = 0
				else
					done = true 
				end
			end
		end
	end
	return done
end 

function drawText()
	if not done then 
		love.graphics.setColor(70, 0, 70, 255)
		love.graphics.rectangle("fill", textBox.x, textBox.y, textBox.width, textBox.height)
		love.graphics.setColor(255, 255, 255, 255)

		-- a simple placeholder "continue" animation
		if #message[messageCurrent].line <= charsToWrite then 
			love.graphics.circle("fill", textBox.x + textBox.width - textBox.pad, textBox.y + textBox.height - textBox.pad, math.sin(sineCounter/12) * textBox.pad /2)
			love.graphics.circle("fill", textBox.x + textBox.width - (textBox.pad * 2), textBox.y + textBox.height - textBox.pad, math.sin(sineCounter/12 + 1) * textBox.pad /2)
			love.graphics.circle("fill", textBox.x + textBox.width - (textBox.pad * 3), textBox.y + textBox.height - textBox.pad, math.sin(sineCounter/12 + 2) * textBox.pad /2)
		end

		-- debug only, to show the bounds of the text area
		--love.graphics.rectangle("line", textBox.textAreaX, textBox.textAreaY, textBox.textAreaWidth, textBox.textAreaHeight)

		-- do this once at the top
		--if love.filesystem.exists(actors[message[messageCurrent].actor]) then 
		-- this is bad. the file needs to be created once at the top
		if type(actors[message[messageCurrent].actor]) == "string" then 
			actors[message[messageCurrent].actor] = love.graphics.newImage(actors[message[messageCurrent].actor])
		end
		love.graphics.draw(actors[message[messageCurrent].actor], textBox.x + textBox.pad, textBox.y + textBox.pad)


		local modifier = nil 
		sineCounter = sineCounter + 1
		-- vars for typewriter effect
		local line = 0 -- current vertical line 	
		local charactersOnCurrentLine = 0 
		local currentCharIndex = 1

		-- while the number of characters drawn is less than the maximum and less than amount to be shown
		while(currentCharIndex <= #message[messageCurrent].line and currentCharIndex <= charsToWrite) do 

			local charPlusOne = getChar(message[messageCurrent].line, currentCharIndex)..getChar(message[messageCurrent].line, currentCharIndex+1)
			if charPlusOne == textMods.shaky then 
				modifier = 1
				currentCharIndex = currentCharIndex + 2
			elseif charPlusOne == textMods.wave then 
				modifier = 2
				currentCharIndex = currentCharIndex + 2
			elseif charPlusOne == textMods.reset then 
				modifier = nil
				currentCharIndex = currentCharIndex + 2
			end 
			
			local lengthOfCurrentWord = 0
			-- this makes sure a word stays on 1 line. iterates from the current character until it finds a space (end of the word)
			while getChar(message[messageCurrent].line, currentCharIndex) ~= " " and currentCharIndex <= #message[messageCurrent].line do
				-- go to the next char
				currentCharIndex = currentCharIndex + 1
				-- increment the length of the current word by 1 
				lengthOfCurrentWord = lengthOfCurrentWord + 1
			end		
			-- this tests to see if the word will go off the end of the line 
			-- if the word is going to go off the line then increment the line by 1 
			if charactersOnCurrentLine + lengthOfCurrentWord > charactersPerLine then 
				-- set current character count for this line to 0 
				charactersOnCurrentLine = 0 
				-- move to the next line vertically 
				line = line + 1 
			end
			
			-- bring i back to it's actual value by removing the length of the current word it's a part of
			currentCharIndex = currentCharIndex - lengthOfCurrentWord 

			if modifier == 1 then	
				love.graphics.print(getChar(message[messageCurrent].line, currentCharIndex), textBox.textAreaX + math.random(-1,1) + (charactersOnCurrentLine * charWidth), textBox.textAreaY + math.random(-1,1) + (charHeight * line))
			elseif modifier == 2 then 
				local so = sineCounter + (currentCharIndex - 1)
				-- putting a dt on the end makes amplitude framerate dependent, but putting it inside makes it jumpy if dt varies too much
				local shift = math.sin(so * sineFreq * math.pi * 0.02) * sineAmp -- love.timer.getDelta()
				love.graphics.print(getChar(message[messageCurrent].line, currentCharIndex), textBox.textAreaX + (charactersOnCurrentLine * charWidth), textBox.textAreaY + (charHeight * line) + (shift))
			else
				love.graphics.print(getChar(message[messageCurrent].line, currentCharIndex), textBox.textAreaX + (charactersOnCurrentLine * charWidth), textBox.textAreaY + (charHeight * line))
			end 
			-- increment the number of characters on the current line and the total number of characters being drawn
			charactersOnCurrentLine = charactersOnCurrentLine + 1
			currentCharIndex = currentCharIndex + 1	
		end 
	end
end

-- simplified sub for getting a single char in a string
function getChar(string, subIndex)
	return string:sub(subIndex, subIndex)
end


