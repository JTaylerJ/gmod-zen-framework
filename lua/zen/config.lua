module("zen", package.seeall)

-- List of admins: SteamID64 [String] = Value [boolean]
_CFG.Admins = {
    ["76561198272243731"] = true -- Addon creator: -243 King
}

-- Request autorization before use admin access
_CFG.Admin_AuthorizationRequire = false