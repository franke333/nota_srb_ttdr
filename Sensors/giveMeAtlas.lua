local sensorInfo = {
	name = "giveMeAtlas",
	desc = "Returns a free atlas",
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
return function(atlases)
    -- for each atlas in array, go one by one
    -- 
    for i = 1, #atlases do
        local atlasID = atlases[i]
        -- if atlas is not reserved, reserve it and return its ID
        if bb.resSys[atlasID] == nil then
            bb.resSys[atlasID] = true
            return atlasID
        end
    end
    return nil
end