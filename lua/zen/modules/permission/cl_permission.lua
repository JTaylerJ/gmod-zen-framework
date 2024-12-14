module("zen")

nt.Receive(_CFG.net_permUpdate, {"string", "bool", "string", "string"}, function(_, sid64, isAdd, permName, tags)
    if not iperm.mt_listLoadedPermissions[sid64] then iperm.mt_listLoadedPermissions[sid64] = {} end

    if isAdd then
        iperm.mt_listLoadedPermissions[sid64][permName] = tags
    else
        iperm.mt_listLoadedPermissions[sid64][permName] = nil
    end
end)

ihook.Listen("InitPostEntity", "zen.permission", function()
    local ply = LocalPlayer()
    local sid64 = util.GetPlayerSteamID64(ply)

    if _CFG.Admin_AuthorizationRequire == false and _CFG.Admins[sid64] then
        ply:zen_SetVar("auth", true)
    end
end)