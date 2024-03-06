module("zen", package.seeall)

ihook.Listen("PlayerInitialSpawn", "zen.permission", function(ply)
    local sid64 = util.GetPlayerSteamID64(ply)

    if _CFG.Admin_AuthorizationRequire == false and _CFG.Admins[sid64] then
        ply:zen_SetVar("auth", true)
    end
end)