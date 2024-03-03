module("zen", package.seeall)

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

    save.SetCachedPlayerValue(PID, key, value1, value2, value3, value4, value5)

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

function save.GetPlayerCachedValueList(PID)
    local sid64 = getSteamID64(PID)

    local tCached = save.t_CachedPlayerValues[sid64]

    if tCached == nil then
        save.CachePlayerValues()
    end

    save.t_CachedPlayerValues[sid64] = save.t_CachedPlayerValues[sid64] or {}

    return save.t_CachedPlayerValues[sid64]
end


function save.SetCachedPlayerValue(PID, key, value1, value2, value3, value4, value5)
    local tCached = save.GetPlayerCachedValueList(PID)

    tCached[key] = {value1, value2, value3, value4, value5}
end

function save.GetCachedPlayerValue(PID, key)
    local sid64 = getSteamID64(PID)

    local tCached = save.GetPlayerCachedValueList(PID)

    if tCached[key] != nil then
        return unpack(tCached[key])
    end
end

function save.CachePlayerValues(PID)
    local sid64 = getSteamID64(PID)

    save.t_CachedPlayerValues[sid64] = {}
    local _, data = save.GetPlayerValueListAll(sid64)

    local dat = data[sid64] and data[sid64].PlayerValue
    if dat then
        for k, v in pairs(dat) do
            save.t_CachedPlayerValues[sid64][k] = table.Copy(v.v)
        end
    end
end

function META.PLAYER:zen_SetPData(key, value1, value2, value3, value4, value5)
    save.SetPlayerValue(self, key, value1, value2, value3, value4, value5)
end

function META.PLAYER:zen_GetPData(key)
    local sid64 = getSteamID64(self)

    if not save.t_CachedPlayerValues[sid64] then save.CachePlayerValues(sid64) end

    local tCache = save.t_CachedPlayerValues[sid64]

    if tCache[key] then
        return unpack(tCache[key])
    end
end