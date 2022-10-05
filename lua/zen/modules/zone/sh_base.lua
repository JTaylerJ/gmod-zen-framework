local zone = zen.Init("zone")

zone.t_Zones = zone.t_Zones or {}
zone.t_ZonesBoxes = zone.t_ZonesBoxes or {}
zone.t_ZonesSphere = zone.t_ZonesSphere or {}
local box_zones = zone.t_ZonesBoxes
local sphere_zones = zone.t_ZonesSphere

function zone.RemoveZone(uniqueID)
    if zone.t_ZonesBoxes[uniqueID] then
        local entities = zone.t_ZonesBoxes[uniqueID].entities
        local players = zone.t_ZonesBoxes[uniqueID].players

        for ent in pairs(entities) do
            zone.OnEntityExit(uniqueID, ent)
        end

        for ent in pairs(players) do
            zone.OnPlayerExit(uniqueID, ent)
        end

        zone.t_ZonesBoxes[uniqueID] = nil
    end

    if zone.t_ZonesSphere[uniqueID] then
        local entities = zone.t_ZonesSphere[uniqueID].entities
        local players = zone.t_ZonesSphere[uniqueID].players

        for ent in pairs(entities) do
            zone.OnEntityExit(uniqueID, ent)
        end

        for ent in pairs(players) do
            zone.OnPlayerExit(uniqueID, ent)
        end

        zone.t_ZonesSphere[uniqueID] = nil
    end
end

function zone.InitBox(uniqueID, vec_min, vec_max)
    zone.t_ZonesBoxes[uniqueID] = {
        id = uniqueID,
        vec_min = vec_min,
        vec_max = vec_max,
        entities = {},
        players = {},
    }

    return zone.t_ZonesBoxes[uniqueID]
end

function zone.InitSphere(uniqueID, origin , radius)
    zone.t_ZonesSphere[uniqueID] = {
        id = uniqueID,
        origin = origin,
        radius = radius,
        entities = {},
        players = {},
    }

    return zone.t_ZonesSphere[uniqueID]
end

function zone.OnEntityJoin(uniqueID, ent)
    ihook.Run('zen.zone.OnEntityJoin', uniqueID, ent)
    ihook.Run('zen.zone.OnEntityJoin.' .. uniqueID, uniqueID, ent)
end

function zone.OnEntityExit(uniqueID, ent)
    ihook.Run('zen.zone.OnEntityExit', uniqueID, ent)
    ihook.Run('zen.zone.OnEntityExit.' .. uniqueID, uniqueID, ent)
end

function zone.OnPlayerJoin(uniqueID, ent)
    ihook.Run('zen.zone.OnPlayerJoin', uniqueID, ent)
    ihook.Run('zen.zone.OnPlayerJoin.' .. uniqueID, uniqueID, ent)
end

function zone.OnPlayerExit(uniqueID, ent)
    ihook.Run('zen.zone.OnPlayerExit', uniqueID, ent)
    ihook.Run('zen.zone.OnPlayerExit.' .. uniqueID, uniqueID, ent)
end

local ents_FindInSphere = ents.FindInSphere
local ents_FindInBox = ents.FindInBox
local SysTime = SysTime
local IsPlayer = META.ENTITY.IsPlayer
local pairs = pairs
ihook.Handler("Think", "zen.Zones.Box", function()
    for k, zone in pairs(box_zones) do
        local zone_entities = zone.entities
        local zone_players = zone.players
        local uniqueID = zone.uniqueID

        local result = ents_FindInBox(zone.vec_min, zone.vec_max)

        local done = {}

        for k, ent in pairs(result) do
            done[ent] = true
            if zone_entities[ent] then continue end

            zone.OnEntityJoin(uniqueID, ent)
            zone_entities[ent] = SysTime()
            if IsPlayer(ent) then
                zone.OnPlayerJoin(uniqueID, ent)
                zone_players[ent] = SysTime()
            end
        end

        for ent in pairs(zone_entities) do
            if done[ent] then continue end

            zone.OnEntityExit(uniqueID, ent)
            zone_entities[ent] = nil
            if IsPlayer(ent) then
                zone.OnPlayerExit(uniqueID, ent)
                zone_players[ent] = nil
            end
        end
    end
end)

ihook.Handler("Think", "zen.Zones.Sphere", function()
    for k, zone in pairs(sphere_zones) do
        local zone_entities = zone.entities
        local zone_players = zone.players
        local uniqueID = zone.uniqueID

        local result = ents_FindInSphere(zone.origin, zone.radius)

        local done = {}

        for k, ent in pairs(result) do
            done[ent] = true
            if zone_entities[ent] then continue end

            zone.OnEntityJoin(uniqueID, ent)
            zone_entities[ent] = SysTime()
            if IsPlayer(ent) then
                zone.OnPlayerJoin(uniqueID, ent)
                zone_players[ent] = SysTime()
            end
        end

        for ent in pairs(zone_entities) do
            if done[ent] then continue end

            zone.OnEntityExit(uniqueID, ent)
            zone_entities[ent] = nil
            if IsPlayer(ent) then
                zone.OnPlayerExit(uniqueID, ent)
                zone_players[ent] = nil
            end
        end
    end
end)

