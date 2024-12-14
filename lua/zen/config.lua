module("zen")

if !_CFG.bFirstInitialized then
    _CFG.bFirstInitialized = nil

    -- List of admins: SteamID64 [String] = Value [boolean]
    _CFG.Admins = {}

    -- Request autorization before use admin access
    _CFG.Admin_AuthorizationRequire = true
end
