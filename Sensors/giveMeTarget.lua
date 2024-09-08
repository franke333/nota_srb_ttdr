local sensorInfo = {
	name = "giveMeTarget",
	desc = "Returns a non reserved non atlas unit to be transported to safe area",
	author = "Fanda333",
	date = "2024-09-03",
	license = "MIT",
}

local EVAL_PERIOD_DEFAULT = -1

function getInfo()
	return {
		period = EVAL_PERIOD_DEFAULT
	}
end


-- @description
return function(atlasID,safeArea,bannedAreas)

    local safeAreaCenter = safeArea.center
    local safeAreaRadius = safeArea.radius
    -- find all units which are not atlases
    local units = Spring.GetTeamUnits(Spring.GetMyTeamID())
    local nonAtlasUnits = {}
    for i = 1, #units do
        local unitID = units[i]
        local unitDefID = Spring.GetUnitDefID(unitID)
        local unitDef = UnitDefs[unitDefID]
        if unitDef.name == "armmllt" or unitDef.name == "armbox" or unitDef.name == "armham"
            or unitDef.name == "armbull" or unitDef.name == "armrock" then
            table.insert(nonAtlasUnits, unitID)
        end
    end
    
    -- find closest non-atlas that is not reserved by alive atlas
    local closestUnitID = nil
    local closestUnitDist = math.huge
    for i = 1, #nonAtlasUnits do
        local unitID = nonAtlasUnits[i]
        local unitX, unitY, unitZ = Spring.GetUnitPosition(unitID)
        
        local skip = false
        -- check if unit is reserved by different atlas
        if bb.resSys[unitID] ~= nil then
            local resAtlasID = bb.resSys[unitID]
            -- if atlas is dead, unreserve it
            if not Spring.ValidUnitID(resAtlasID) then
                bb.resSys[unitID] = nil
            else
                -- if atlas is alive, skip this unit
                skip = true
            end
        end

        -- check if unit is in safe area
        local distToSafeAreaCenter = math.sqrt((unitX - safeAreaCenter.x)^2 + (unitZ - safeAreaCenter.z)^2)
        if distToSafeAreaCenter < safeAreaRadius then
            -- unit is in safe area, skip it
            skip = true
        end

        --check if unit in banned area
        for i = 1, #bannedAreas do
            local bannedArea = bannedAreas[i]
            local minX, minZ = bannedArea.minX, bannedArea.minZ
            local maxX, maxZ = bannedArea.maxX, bannedArea.maxZ
            if unitX > minX and unitX < maxX and unitZ > minZ and unitZ < maxZ then
                skip = true
                break
            end
        end

        if not skip then
            local dist = Spring.GetUnitSeparation(atlasID, unitID, true)
            if dist < closestUnitDist then
                closestUnitID = unitID
                closestUnitDist = dist
            end
        end
    end
    bb.resSys[closestUnitID] = atlasID
    return closestUnitID
end