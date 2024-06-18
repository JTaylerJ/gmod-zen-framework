module("zen", package.seeall)

player_mode = _GET("player_mode")

---@type table<string, zen.player_mode>
player_mode.mt_ModeList = player_mode.mt_ModeList or {}

---@type table<Player, zen.player_mode>
player_mode.mt_PlayerMode = player_mode.mt_PlayerMode or {}
player_mode.iPlayerCounter = player_mode.iPlayerCounter or 0
local MODE_LIST = player_mode.mt_ModeList
local PLAYER_MODE = player_mode.mt_PlayerMode

---@class zen.player_mode: table
---@field id string
---@field package uniqueID string uniqueID for hooks
---@field package mt_Hooks table<string, boolean>
---@field StartCommand? fun(self, ply:Player, cmd:CUserCmd)
---@field SetupMove? fun(self, ply:Player, mv:CMoveData, cmd:CUserCmd)
---@field Move? fun(self, ply:Player, mv:CMoveData): boolean? predict
---@field FinishMove? fun(self, ply:Player, mv:CMoveData): boolean? predict
---@field CalcMainActivity? fun(self, ply:Player, vel:Vector): number, number
---@field OnDeath? fun(self, victim:Player, inflictor:Player, attacker:Entity)
---@field OnSpawn? fun(self, ply:Player)
---@field OnJoin? fun(self, ply:Player) -- Called when player switch player_mode to this
---@field OnExit? fun(self, ply:Player) -- Called when player switch player_mode from this
---@field AddHandler? fun(self, hook_name:string, callback:function) -- Add hook for listen. Auto-remove after change player mode. BE CERAFUL. Use LocalPlayer() == ply for only-single-owner hook
---@field RemoveHandler? fun(self, hook_name:string) -- Remove hook for listen

---@param MODE zen.player_mode
function player_mode.Register(MODE)
    MODE_LIST[MODE.id] = MODE

    MODE.mt_Hooks = {}
    function MODE:AddHandler(hook_name, callback)
        self.mt_Hooks[hook_name] = true
        ihook.Handler(hook_name, self.uniqueID, callback)
    end

    function MODE:RemoveHandler(hook_name)
        self.mt_Hooks[hook_name] = nil
        ihook.Remove(hook_name, self.uniqueID)
    end


    ---Auto-refresh for lua-refresh
    for ply, OLD_MODE in pairs(PLAYER_MODE) do
        if OLD_MODE.id == MODE.id then
            player_mode.SetMode(ply, "default")
        end

        player_mode.SetMode(ply, MODE.id)
    end
end

---@param ply Player
---@param mode_name string|nil|"default"
function player_mode.SetMode(ply, mode_name)
    if mode_name == nil or mode_name == "default" then
        if PLAYER_MODE[ply] then
            player_mode.iPlayerCounter = player_mode.iPlayerCounter - 1

            local OLD_MODE = PLAYER_MODE[ply]

            if OLD_MODE.OnExit then
                OLD_MODE.OnExit(OLD_MODE, ply)
            end

            if OLD_MODE.mt_Hooks then
                for hook_name in pairs(OLD_MODE.mt_Hooks) do
                    ihook.Remove(hook_name, OLD_MODE.uniqueID)
                end
            end
        end
        PLAYER_MODE[ply] = nil

        if SERVER then
            nt.SendToChannel("player_mode.UpdatePlayerMode", nil, ply, "default")
        end

        return
    end

    local MODE = MODE_LIST[mode_name]
    assert(MODE, "MODE not exists")

    --- local copy for player only
    ---@type zen.player_mode
    ---@diagnostic disable-next-line: assign-type-mismatch
    MODE = table.Copy(MODE)

    MODE.uniqueID = tostring("zen.player_mode."  ..  MODE.id .. "." .. ply:SteamID64())

    if !PLAYER_MODE[ply] then
        player_mode.iPlayerCounter = player_mode.iPlayerCounter + 1
    end

    local OLD_MODE = PLAYER_MODE[ply]
    if OLD_MODE then
        if OLD_MODE.OnExit then
            OLD_MODE:OnExit(ply)
        end
    end

    PLAYER_MODE[ply] = MODE

    if MODE.OnJoin then
        MODE.OnJoin(MODE, ply)
    end

    if SERVER then
        nt.SendToChannel("player_mode.UpdatePlayerMode", nil, ply, mode_name)
    end
end

function player_mode.DisableHooks()
    player_mode.bHooksEnabled = false

    ihook.Remove("StartCommand", "zen.player_mode")
    ihook.Remove("SetupMove", "zen.player_mode")
    ihook.Remove("Move", "zen.player_mode")
    ihook.Remove("FinishMove", "zen.player_mode")
    ihook.Remove("CalcMainActivity", "zen.player_mode")
    ihook.Remove("shared.PlayerDeath", "zen.player_mode")
    ihook.Remove("shared.PlayerSpawn", "zen.player_mode")
end

function player_mode.ActivateHooks()
    player_mode.bHooksEnabled = true

    _HANDLER("StartCommand", "zen.player_mode", function(ply, cmd)
        local MODE = PLAYER_MODE[ply]
        if !MODE or !MODE.StartCommand then return end

        MODE:StartCommand(ply, cmd)
    end)

    _HANDLER("SetupMove", "zen.player_mode", function(ply, mv, cmd)
        local MODE = PLAYER_MODE[ply]
        if !MODE or !MODE.SetupMove then return end

        MODE:SetupMove(ply, mv, cmd)
    end)

    _HANDLER("Move", "zen.player_mode", function(ply, mv)
        local MODE = PLAYER_MODE[ply]
        if !MODE or !MODE.Move then return end

        return MODE:Move(ply, mv)
    end)

    _HANDLER("FinishMove", "zen.player_mode", function(ply, mv)
        local MODE = PLAYER_MODE[ply]
        if !MODE or !MODE.FinishMove then return end

        return MODE:FinishMove(ply, mv)
    end)

    _HANDLER("CalcMainActivity", "zen.player_mode", function(ply, vel)
        local MODE = PLAYER_MODE[ply]
        if !MODE or !MODE.CalcMainActivity then return end

        return MODE:CalcMainActivity(ply, vel)
    end)

    _HANDLER("shared.PlayerDeath", "zen.player_mode", function(victim, inflictor, attacker)
        local MODE = PLAYER_MODE[victim]
        if !MODE or !MODE.OnDeath then return end

        return MODE:OnDeath(victim, inflictor, attacker)
    end)

    _HANDLER("shared.PlayerSpawn", "zen.player_mode", function(victim, inflictor, attacker)
        local MODE = PLAYER_MODE[victim]
        if !MODE or !MODE.OnSpawn then return end

        return MODE:OnSpawn(victim)
    end)
end


-- PlayerDisconnected is shared
_HANDLER("shared.PlayerDisconnected", "zen.player_mode", function(ply)
    if PLAYER_MODE[ply] then
        player_mode.SetMode(ply, nil)
    end
end)

_HANDLER("Think", "zen.player_mode", function(ply)
    if player_mode.bHooksEnabled == true then
        if !next(PLAYER_MODE) then
            player_mode.DisableHooks()
        end
    else
        if next(PLAYER_MODE) then
            player_mode.ActivateHooks()
        end
    end
end)