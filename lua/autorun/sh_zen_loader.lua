AddCSLuaFile("zen/main.lua")
include("zen/main.lua")

concommand.Add("zen_reload", function(ply)
    if SERVER and IsValid(ply) then return end
    include("zen/main.lua")
end)

concommand.Add("zen_reload_full", function(ply)
    if SERVER and IsValid(ply) then return end

    zen = nil
    izen = nil
    include("zen/main.lua")
end)