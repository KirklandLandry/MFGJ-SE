require "simpleEnemy"

local enemyList = {} 

function loadEnemyManager()
	
end

function updateEnemyManager()

end

function drawEnemyManager()

end

function clearEnemyManager()
	for k,v in pairs(enemyList) do 
		enemyList[k]=nil 
	end
	enemyList = {}
end