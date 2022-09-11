iperm.RegisterPermission("luadev.run.clients")
iperm.RegisterPermission("luadev.run.client")
iperm.RegisterPermission("luadev.run.server", iperm.flags.NO_TARGET)
iperm.RegisterPermission("luadev.run.shared", iperm.flags.NO_TARGET)
iperm.RegisterPermission("luadev.view", iperm.flags.NO_TARGET)

local TO_CLIENTS = 1
local TO_CLIENT = 2
local TO_SERVER = 3
local TO_SHARED = 4

local runs = {}
runs[TO_CLIENTS] = function(ply) return ply:zen_HasPerm("luadev.run.clients") end
runs[TO_CLIENT] = function(ply) return ply:zen_HasPerm("luadev.run.client") end
runs[TO_SERVER] = function(ply) return ply:zen_HasPerm("luadev.run.server") end
runs[TO_SHARED] = function(ply) return ply:zen_HasPerm("luadev.run.shared") end

hook.Add("CanLuaDev", "zen.Integration", function(ply, script, command, target, target_ply, extra)
    if IsValid(ply) then
        local checkFunc = runs[target]
        if checkFunc then
            if checkFunc(ply) then
                return true
            end
        else
            if ply:zen_HasPerm("luadev.view") then
                return true
            end
        end
    end
end)
