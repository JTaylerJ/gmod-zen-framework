iperm.RegisterPermission("fl.IsSuperAdmin", iperm.flags.NO_TARGET, "Access to META.Player:IsSuperAdmin")
iperm.RegisterPermission("fl.IsAdmin", iperm.flags.NO_TARGET, "Access to META.Player:IsAdmin")
iperm.RegisterPermission("fl.Perms", iperm.flags.NO_TARGET, "Check access with next argument!")
iperm.RegisterPermission("fl.CanTouch", nil, "Check can player target!")
iperm.RegisterPermission("fl.IsHidenAdmin", iperm.flags.NO_TARGET, "Hide you from admin list!")


hook.Add("fl.IsSuperAdmin", "zen.integration", function(ply)
    if ply:zen_HasPerm("fl.IsSuperAdmin") then 
        if CLIENT and ply:zen_HasPerm("fl.IsHidenAdmin") and LocalPlayer() != ply then return end

        return true
    end
end)

hook.Add("fl.IsAdmin", "zen.integration", function(ply)
    if ply:zen_HasPerm("fl.IsAdmin") then 
        if CLIENT and ply:zen_HasPerm("fl.IsHidenAdmin") and LocalPlayer() != ply then return end

        return true
    end
end)

hook.Add("fl.HavePerm", "zen.integration", function(ply, perm)
    if not IsValid(ply) then return end

    if ply:zen_HasPerm("fl.Perms." .. perm) then 
        if CLIENT and ply:zen_HasPerm("fl.IsHidenAdmin") and LocalPlayer() != ply then return end

        return true
    end

end)

hook.Add("fl.CanTouch", "zen.integration", function(ply, target)
    if ply:zen_HasPerm("fl.CanTouch", target) then return true end
    if IsValid(target) then
        if target:zen_HasPerm("fl.AbsoluteSecure") then return false end
    end
end)

hook.Add("fl.IsHidenAdmin", "zen.integration", function(ply)
    if ply:zen_HasPerm("fl.IsHidenAdmin") then return true end
end)

-- hook.Add("fl.GetUserGroup", "zen.integration", function(ply)
--     -- Disabled
-- end)