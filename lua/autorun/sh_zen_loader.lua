module("zen", package.seeall)

zen.SEND_CLIENT_FILES = true
zen.SERVER_SIDE_ACTIVATED = false


if SERVER then
    if zen.SERVER_SIDE_ACTIVATED then
        util.AddNetworkString("zen.ping")
    end
end

if CLIENT_DLL then
    local NetworkID = util.NetworkStringToID("zen.ping")

    if !NetworkID or NetworkID <= 0 then
        print("ZEN: Looks like server don't have ZEN. Enabled client-only mode")
        zen.SERVER_SIDE_ACTIVATED = false
    else
        zen.SERVER_SIDE_ACTIVATED = true
    end
end

AddCSLuaFile("zen/main/main.lua")
include("zen/main/main.lua")

concommand.Add("zen_reload", function(ply)
    if SERVER and IsValid(ply) then return end
    include("zen/main/main.lua")
end)

concommand.Add("zen_reload_full", function(ply)
    if SERVER and IsValid(ply) then return end

    nt = nil
    zen = nil
    include("zen/main/main.lua")
end)