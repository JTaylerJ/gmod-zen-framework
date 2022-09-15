ihook.Listen("PlayerInitialSpawn", "zen.permission", function(ply)
    local sid64 = util.GetPlayerSteamID64(ply)

    if icfg.Admin_AuthorizationRequire == false and icfg.Admins[sid64] then
        ply:zen_SetVar("auth", true)
    end
end)