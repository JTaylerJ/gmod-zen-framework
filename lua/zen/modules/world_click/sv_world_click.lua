nt.RegisterChannel("zen.worldclick.onPress")
nt.RegisterChannel("zen.worldclick.onRelease")

local worldclick = zen.worldclick


nt.Receive("zen.worldclick.onPress", {"uint7", "vector", "vector"}, function(ply, code, start_pos, normal)
    if not ply:izen_HasPerm("zen.worldclick") then return end

    local tr = worldclick.Trace(ply, start_pos, normal )

    hook.Run("zen.worldclick.onPress", ply, code, tr)
    if IsValid(tr.Entity) then
        hook.Run("zen.worldclick.onPressEntity", ply, tr.Entity, code, tr)
    end
end)

nt.Receive("zen.worldclick.onRelease", {"uint7", "vector", "vector"}, function(ply, code, start_pos, normal)
    if not ply:izen_HasPerm("zen.worldclick") then return end

    local tr = worldclick.Trace(ply, start_pos, normal )

    hook.Run("zen.worldclick.onRelease", ply, code, tr)
    if IsValid(tr.Entity) then
        hook.Run("zen.worldclick.onReleaseEntity", ply, tr.Entity, code, tr)
    end
end)


