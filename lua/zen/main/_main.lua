local Autorun = Autorun

module("zen")

_L = getfenv()
_L.zen = _L.zen or {}

zen.Autorun = Autorun

zen.SEND_CLIENT_FILES = true
zen.SERVER_SIDE_ACTIVATED = false

---@param path string
---@param include_state? `CLIENT`|`SERVER`|`CLIENT_DLL`|`MENU_DLL`
function zen.INC(path, include_state)
    assert(type(path) == "string", "path not is string")

    if SERVER and (include_state == CLIENT or include_state == CLIENT_DLL) then
        AddCSLuaFile(path)
    end

    local bShouldInclude = (include_state == nil) or (include_state == true)

    if !bShouldInclude then return end


    if type(Autorun) == "table" and type(Autorun.require) == "function" then
        return Autorun.require(path)
    else
        local res, a1, a2, a3, a4, a5, a6, a7 = xpcall(include, ErrorNoHaltWithStack, path)
        if res then
            return a1, a2, a3, a4, a5, a6, a7
        end
    end
end


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

zen.INC("zen/main/main.lua")

concommand.Add("zen_reload", function(ply)
    if SERVER and IsValid(ply) then return end

    zen.INC("zen/main/main.lua")
end)

concommand.Add("zen_reload_full", function(ply)
    if SERVER and IsValid(ply) then return end

    nt = nil // Should be in zen
    zen = nil
    zen.INC("zen/main/main.lua")
end)