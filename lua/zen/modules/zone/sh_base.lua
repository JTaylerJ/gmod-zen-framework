local zone = zen.Init("zone")

zone.t_Zones = zone.t_Zones or {}
zone.t_ZonesBoxes = zone.t_ZonesBoxes or {}
zone.t_ZonesSphere = zone.t_ZonesSphere or {}
local zones = zone.t_Zones
local box_zones = zone.t_ZonesBoxes
local sphere_zones = zone.t_ZonesSphere

local ents_FindInSphere = ents.FindInSphere
local ents_FindInBox = ents.FindInBox
local SysTime = SysTime
local IsPlayer = META.ENTITY.IsPlayer
local GetClass = META.ENTITY.GetClass
local pairs = pairs
local GetSolid = META.ENTITY.GetSolid
local GetCollisionGroup = META.ENTITY.GetCollisionGroup
local SOLID_NONE = SOLID_NONE
local SysTime = SysTime

function zone.RemoveZone(uniqueID)
    local ZONE = zones[uniqueID]
    if ZONE then
        local entities = ZONE.entities
        local players = ZONE.players

        for ent in pairs(entities) do
            zone.OnEntityExit(ZONE, uniqueID, ent)
        end

        for ent in pairs(players) do
            zone.OnPlayerExit(ZONE, uniqueID, ent)
        end

        ZONE = nil
        zone.t_ZonesBoxes[uniqueID] = nil
        zone.t_ZonesSphere[uniqueID] = nil
    end
end

function zone.InitEmpty(uniqueID)
    zone.t_Zones[uniqueID] = {
        uniqueID = uniqueID,
        entities = {},
        class_entities = {},
        class_counter = {},
        solid_entities = {},
        collision_entities = {},
        onJoin = function() end,
        onExit = function() end,
    }
    return zone.t_Zones[uniqueID]
end

function zone.InitBox(uniqueID, vec_min, vec_max)
    local ZONE = zone.InitEmpty(uniqueID)
    ZONE.vec_min = vec_min
    ZONE.vec_max = vec_max

    zone.t_ZonesBoxes[uniqueID] = ZONE
    zone.t_ZonesSphere[uniqueID] = nil

    return ZONE
end

function zone.InitSphere(uniqueID, origin , radius)
    local ZONE = zone.InitEmpty(uniqueID)
    ZONE.origin = origin
    ZONE.radius = radius

    zone.t_ZonesBoxes[uniqueID] = nil
    zone.t_ZonesSphere[uniqueID] = ZONE

    return ZONE
end

local RunSecure = ihook.RunSecure

function zone.OnEntityJoin(ZONE, uniqueID, ent)
    local ent_class = GetClass(ent)
    local ent_solid = GetSolid(ent)
    local ent_collision = GetCollisionGroup(ent)

    local class_entities = ZONE.class_entities
    local class_counter = ZONE.class_counter
    local solid_entities = ZONE.solid_entities
    local collision_entities = ZONE.collision_entities

    local zone_collision = ZONE.CollisionGroup

    if not class_entities[ent_class] then
        class_entities[ent_class] = {}
        class_counter[ent_class] = 0
    end
    class_entities[ent_class][ent] = SysTime()
    class_counter[ent_class] = class_counter[ent_class] + 1

    local isSolid
    if ent_solid != SOLID_NONE then
        solid_entities[ent] = SysTime()
        isSolid = true
    end

    local isCollision
    if zone_collision == ent_collision then
        collision_entities[ent] = SysTime()
        isCollision = true
    end

    RunSecure('zen.zone.OnEntityJoin', ZONE, uniqueID, ent, ent_class)
    RunSecure('zen.zone.OnEntityJoin.' .. uniqueID, ZONE, uniqueID, ent, ent_class)
    RunSecure('zen.zone.OnEntityJoinClass', ZONE, uniqueID, ent, ent_class)
    RunSecure('zen.zone.OnEntityJoinClass.' .. uniqueID, ZONE, uniqueID, ent, ent_class)
    if isSolid then
        RunSecure('zen.zone.OnEntityJoinSolid', ZONE, uniqueID, ent, ent_class)
        RunSecure('zen.zone.OnEntityJoinSolid.' .. uniqueID, ZONE, uniqueID, ent, ent_class)
    end
    if isCollision then
        RunSecure('zen.zone.OnEntityJoinCollision', ZONE, uniqueID, ent, ent_class)
        RunSecure('zen.zone.OnEntityJoinCollision.' .. uniqueID, ZONE, uniqueID, ent, ent_class)
    end

    ZONE.onJoin(ZONE, ent, ent_class)
end

function zone.OnEntityExit(ZONE, uniqueID, ent)
    local ent_class = GetClass(ent)

    local class_entities = ZONE.class_entities
    local class_counter = ZONE.class_counter
    local solid_entities = ZONE.solid_entities
    local collision_entities = ZONE.collision_entities

    class_entities[ent_class][ent] = nil
    class_counter[ent_class] = class_counter[ent_class] - 1

    local isSolid
    if solid_entities[ent] then
        solid_entities = nil
    end

    local isCollision
    if collision_entities[ent] then
        isCollision = true
    end


    RunSecure('zen.zone.OnEntityExit', ZONE, uniqueID, ent, ent_class)
    RunSecure('zen.zone.OnEntityExit.' .. uniqueID, ZONE, uniqueID, ent, ent_class)
    RunSecure('zen.zone.OnEntityExitClass', ZONE, uniqueID, ent, ent_class)
    RunSecure('zen.zone.OnEntityExitClass.' .. ent_class, ZONE, uniqueID, ent, ent_class)
    if isSolid then
        RunSecure('zen.zone.OnEntityExitSolid', ZONE, uniqueID, ent, ent_class)
        RunSecure('zen.zone.OnEntityExitSolid.' .. uniqueID, ZONE, uniqueID, ent, ent_class)
    end
    if isCollision then
        RunSecure('zen.zone.OnEntityJoinCollision', ZONE, uniqueID, ent, ent_class)
        RunSecure('zen.zone.OnEntityJoinCollision.' .. uniqueID, ZONE, uniqueID, ent, ent_class)
    end

    ZONE.onExit(ZONE, ent, ent_class)
end

ihook.Handler("Think", "zen.Zones.Box", function()
    for k, ZONE in pairs(box_zones) do
        local zone_entities = ZONE.entities
        local uniqueID = ZONE.uniqueID

        local result = ents_FindInBox(ZONE.vec_min, ZONE.vec_max)

        local done = {}

        for k, ent in pairs(result) do
            done[ent] = true
            if zone_entities[ent] then continue end

            zone.OnEntityJoin(ZONE, uniqueID, ent)
            zone_entities[ent] = SysTime()
        end

        for ent in pairs(zone_entities) do
            if done[ent] then continue end

            zone.OnEntityExit(ZONE, uniqueID, ent)
            zone_entities[ent] = nil
        end
    end
end)

ihook.Handler("Think", "zen.Zones.Sphere", function()
    for k, ZONE in pairs(sphere_zones) do
        local zone_entities = ZONE.entities
        local uniqueID = ZONE.uniqueID

        local result = ents_FindInSphere(ZONE.origin, ZONE.radius)

        local done = {}

        for k, ent in pairs(result) do
            done[ent] = true
            if zone_entities[ent] then continue end

            zone.OnEntityJoin(ZONE, uniqueID, ent)
            zone_entities[ent] = SysTime()
        end

        for ent in pairs(zone_entities) do
            if done[ent] then continue end

            zone.OnEntityExit(ZONE, uniqueID, ent)
            zone_entities[ent] = nil
        end
    end
end)

