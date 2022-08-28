izen.worldclick = izen.worldclick or {}
zen.worldclick = izen.worldclick
local worldclick = zen.worldclick

function worldclick.Trace(ply, eye_pos, eye_normal)
    local filter = {}

    eye_pos = eye_pos or ply:EyePos()
    eye_normal = eye_normal or ply:GetAimVector()

    table.insert(filter, ply)
    table.insert(filter, ply:GetViewEntity())
    table.insert(filter, ply:GetActiveWeapon())
    table.insert(filter, ply:GetVehicle())

    local trace = util.TraceLine( {
        start = eye_pos,
        endpos = eye_pos + eye_normal * 1024,
        filter = filter
    } )

    -- Hit COLLISION_GROUP_DEBRIS and stuff
    if not trace.Hit or not IsValid( trace.Entity ) then
        trace = util.TraceLine( {
            start = eye_pos,
            endpos = eye_pos + eye_normal * 1024,
            filter = filter,
            mask = MASK_ALL
        } )
    end

    return trace
end