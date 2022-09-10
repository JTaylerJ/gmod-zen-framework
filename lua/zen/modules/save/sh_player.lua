local save = zen.Init("zen.Save")
save.t_CachedPlayerValues = {}

local getSteamID64 = function(PID)
    local sid64 = util.GetPlayerSteamID64(PID)
    assert(sid64, "PID expected Player|SteamID64|SteamID (got " .. tostring(PID) .. ")")
    return sid64
end

function save.GetPlayerValue(PID, key)
    local sid64 = getSteamID64(PID)

    return save.GetSaveValue(sid64, "PlayerValue", nil, nil, nil, true)
end

function save.SetPlayerValue(PID, key, value1, value2, value3, value4, value5)
    local sid64 = getSteamID64(PID)

    return save.SetSaveValue(sid64, "PlayerValue", key, nil, nil, value1, value2, value3, value4, value5)
end


function save.GetPlayerValueListAll(PID)
    local sid64 = getSteamID64(PID)

    return save.GetSaveValue(sid64, "PlayerValue", nil, nil, nil)
end

function save.GetPlayerValueList(PID, key)
    local sid64 = getSteamID64(PID)

    return save.GetSaveValue(sid64, "PlayerValue", key, nil, nil)
end

function save.CachePlayerValues(PID)
    local sid64 = getSteamID64(PID)

    save.t_CachedPlayerValues[sid64] = {}
    local _, data = save.GetPlayerValueListAll(sid64)

    table.Merge(save.t_CachedPlayerValues, data)
end

-- save.SetPlayerValue("76561198272243731", "UserGround", true)
-- save.SetPlayerValue("76561198272243731", "UserGround.Hiden", "superadmin", "local")
-- -- save.SetPlayerValue("76561198272243731", "AllPerms", "testing2")
-- -- save.SetPlayerValue("76561198272243731", "TestingVar", 10)

-- save.CachePlayerValues("76561198272243731")