
-- META.PLAYER.OldIsAdmin = META.PLAYER.OldIsAdmin or META.PLAYER.IsAdmin
-- function META.PLAYER:IsAdmin()
--     return self:zen_HasPerm("IsAdmin") or self:OldIsAdmin()
-- end

-- META.PLAYER.OldIsSuperAdmin = META.PLAYER.OldIsSuperAdmin or META.PLAYER.IsSuperAdmin
-- function META.PLAYER:IsSuperAdmin()
--     return self:zen_HasPerm("IsSuperAdmin") or self:OldIsSuperAdmin()
-- end

hook.Add("FAdmin_CanTarget", "zen", function(ply)
    return ply:zen_HasPerm("canAccess")
end)

hook.Add("CAMI.PlayerHasAccess", "zen", function(ply)
    return ply:zen_HasPerm("canAccess")
end)

hook.Add("HasPermission", "zen", function(ply)
    return ply:zen_HasPerm("canAccess")
end)