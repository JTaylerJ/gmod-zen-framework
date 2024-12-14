if SERVER then
    AddCSLuaFile("zen/main/_main.lua")
    include("zen/main/_main.lua")
end

if CLIENT_DLL then
    concommand.Add("+zen_tools", function()
        include("zen/main/_main.lua")
    end)
end