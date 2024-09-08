local sensorInfo = {
	name = "BFS",
	desc = "Return a danger map.",
	author = "Fanda333",
	date = "2024-09-03",
	license = "MIT",
}

local EVAL_PERIOD_DEFAULT = 0

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end


-- @description
return function(enemiesID, safePosition, scale)

    local enemyDangerRadius = 25
	local width = Game.mapSizeX/Game.squareSize
    local height = Game.mapSizeZ/Game.squareSize

    -- dangermap, unknown are is -1, safe area is 0, danger area is -2
    local map = {}
    for x = 1,width/scale do
        map[x] = {}
        for y = 1,height/scale do
            map[x][y] = -1
        end
    end

    --mark danger areas
    for i = 1,table.getn(enemiesID) do
        local ex,ey,ez = Spring.GetUnitPosition(enemiesID[i])
        local enemyX = math.floor(ex/Game.squareSize/scale)
        local enemyY = math.floor(ez/Game.squareSize/scale)
        for x = math.floor(enemyX - enemyDangerRadius/scale), math.floor(enemyX + enemyDangerRadius/scale) do
            for y = math.floor(enemyY - enemyDangerRadius/scale), math.floor(enemyY + enemyDangerRadius/scale) do
                if x >= 1 and x < width/scale and y >= 1 and y < height/scale then
                    map[x][y] = -2
                end
            end
        end
    end

    --safe area
    local safeX = math.floor(safePosition.x/(Game.squareSize*scale))
    local safeZ = math.floor(safePosition.z/(Game.squareSize*scale))

    --bfs
    local queue = {{safeX,safeZ,0}}
    local i = 1
    while table.getn(queue) >= i do
        local front = queue[i]
        local x = front[1]
        local y = front[2]
        local distance = front[3]
        if x >= 1 and x < width/scale and y >= 1 and y < height/scale and map[x][y] == -1 then
            map[x][y] = distance
            table.insert(queue, {x-1, y, distance+1})
            table.insert(queue, {x+1, y, distance+1})
            table.insert(queue, {x, y-1, distance+1})
            table.insert(queue, {x, y+1, distance+1})
        end
        i = i + 1
    end

    return map
end