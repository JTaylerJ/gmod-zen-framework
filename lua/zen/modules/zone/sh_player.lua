module("zen")

zone.t_ZonesPlayers = zone.t_ZonesPlayers or {}
zone.t_ZonesPlayers_Name = zone.t_ZonesPlayers_Name or {}
zone.t_ZonesPlayers_UniqueIDs = zone.t_ZonesPlayers_UniqueIDs or {}
local zones_list = zone.t_ZonesPlayers_UniqueIDs

local GetPos = META.ENTITY.GetPos
local IsValid = IsValid

function zone.GetPlayerZoneUniqueID(ply, uniqueID)
    local cache_zone_name = zone.t_ZonesPlayers_Name[ply] and zone.t_ZonesPlayers_Name[ply][uniqueID]
    if cache_zone_name then return cache_zone_name end

    uniqueID = uniqueID or "default"
    local zone_name = "player.zone." .. ply:UserID() .. "." .. uniqueID
    zone.t_ZonesPlayers_Name[ply] = zone.t_ZonesPlayers_Name[ply] or {}
    zone.t_ZonesPlayers_Name[ply][uniqueID] = zone_name
    return zone_name
end

function zone.InitPlayerZone(ply, radius, uniqueID)
    local zone_name = zone.GetPlayerZoneUniqueID(ply, uniqueID)

    zone.t_ZonesPlayers[ply] = zone.t_ZonesPlayers[ply] or {}
    local ZONE = zone.InitSphere(zone_name, GetPos(ply), radius)
    ZONE.ply = ply

    zone.t_ZonesPlayers[ply][uniqueID] = ZONE
    zone.t_ZonesPlayers_UniqueIDs[zone_name] = ZONE

    return ZONE
end

function zone.RemovePlayerZone(ply, uniqueID)
    local zone_name = zone.GetPlayerZoneUniqueID(ply, uniqueID)

    zone.RemoveZone(zone_name)
    if zone.t_ZonesPlayers[ply] then
        zone.t_ZonesPlayers[ply][uniqueID] = nil
    end
    zone.t_ZonesPlayers_UniqueIDs[zone_name] = nil
end

ihook.Handler("Think", "zen.zone.player.ChangePos", function()
    for ply, zones in pairs(zone.t_ZonesPlayers) do
        for uniqueID, ZONE in pairs(zones) do
            if not IsValid(ply) then
                zone.RemovePlayerZone(ply, uniqueID)
                continue
            end

            local ply_pos = GetPos(ply)
            if ply_pos != ZONE.origin then
                ZONE.origin = ply_pos
            end
        end
    end
end)

ihook.Listen("shared.PlayerDisconnected", "zen.zone.AutoDelete", function(ply)
    local zones = zone.t_ZonesPlayers[ply]
    if zones then
        for uniqueID, zoneData in pairs(zones) do
            zone.RemovePlayerZone(ply, uniqueID)
        end
    end
end)

ihook.Listen("zen.zone.OnEntityJoin", "zen.zone.player.OnEntityJoin", function(uniqueID, ply)
    local ZONE = zones_list[uniqueID]
    if not ZONE or not ZONE.OnEntityJoin then return end

    ZONE.OnEntityJoin(ply)
end)

ihook.Listen("zen.zone.OnEntityExit", "zen.zone.player.OnEntityExit", function(uniqueID, ply)
    local ZONE = zones_list[uniqueID]
    if not ZONE or not ZONE.OnEntityExit then return end

    ZONE.OnEntityExit(ply)
end)