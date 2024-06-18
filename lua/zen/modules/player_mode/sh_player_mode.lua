module("zen", package.seeall)

player_mode = _GET("player_mode")

---@type table<string, zen.player_mode>
player_mode.mt_ModeList = player_mode.mt_ModeList or {}

---@type table<Player, zen.player_mode>
player_mode.mt_PlayerMode = player_mode.mt_PlayerMode or {}
player_mode.iPlayerCounter = player_mode.iPlayerCounter or 0

---@type table<string, table<string, zen.player_mode>
player_mode.mt_TeamsPlayer = player_mode.mt_TeamsPlayer or {}

---@type table<string, table<string, true>
player_mode.mt_ModeHooks = player_mode.mt_ModeHooks or {}

local MODE_LIST = player_mode.mt_ModeList
local PLAYER_MODE = player_mode.mt_PlayerMode
local TEAM_LIST = player_mode.mt_TeamsPlayer
local MODE_HOOKS = player_mode.mt_ModeHooks


---@param ply Player
function player_mode.ClearPlayerMode(ply)
    local MODE = PLAYER_MODE[ply]
    if !MODE then return end

    if MODE.OnExit then
        MODE:OnExit(ply)
    end

    if MODE.mt_Hooks then
        for hook_name in pairs(MODE.mt_Hooks) do
            ihook.Remove(hook_name, MODE.hookID_unique)
            MODE.mt_Hooks[hook_name] = nil
        end
    end

    PLAYER_MODE[ply] = nil

    if TEAM_LIST[MODE.id] then
        TEAM_LIST[MODE.id][ply] = nil

        if !next(TEAM_LIST[MODE.id]) then
            player_mode.ClearTeamHooks(MODE.id)
        end
    end
end

function player_mode.ClearTeamHooks(mode_name)
    if MODE_HOOKS[mode_name] then
        for hook_name, hook_uid in pairs(MODE_HOOKS[mode_name]) do
            ihook.Remove(hook_name, hook_uid)
        end
        MODE_HOOKS[mode_name] = nil
    end
end


---@class zen.player_mode: table
---@field id string
---@field package hookID string
---@field package hookID_unique string hookID_unique for hooks
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
---@field AddPersonalHandler? fun(self, hook_name:string, callback:function) -- hook.Handler (personal). Auto-remove after player exit
---@field RemovePersonalHandler? fun(self, hook_name:string) -- Remove hook for listen
---@field Handler? fun(self, hook_name:string, callback:function) -- hook.Handler (team). Auto-remove after player with this class will exit

---@param MODE zen.player_mode
function player_mode.Register(MODE)
    MODE_LIST[MODE.id] = MODE

    MODE.mt_Hooks = {}
    function MODE:AddPersonalHandler(hook_name, callback)
        self.mt_Hooks[hook_name] = true
        ihook.Handler(hook_name, self.hookID_unique, callback)
    end

    function MODE:RemovePersonalHandler(hook_name)
        self.mt_Hooks[hook_name] = nil
        ihook.Remove(hook_name, self.hookID_unique)
    end

    ---

    function MODE:Handler(hook_name, callback)
        if !MODE_HOOKS[MODE.id] then MODE_HOOKS[MODE.id] = {} end
        MODE_HOOKS[MODE.id][hook_name] = self.hookID
        ihook.Handler(hook_name, self.hookID, callback)
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
        end

        if PLAYER_MODE[ply] then
            player_mode.ClearPlayerMode(ply)
        end

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

    MODE.hookID = tostring("zen.player_mode."  ..  MODE.id)
    MODE.hookID_unique = tostring("zen.player_mode."  ..  MODE.id .. "." .. ply:SteamID64())

    if !PLAYER_MODE[ply] then
        player_mode.iPlayerCounter = player_mode.iPlayerCounter + 1
    end

    if PLAYER_MODE[ply] then
        player_mode.ClearPlayerMode(ply)
    end

    PLAYER_MODE[ply] = MODE

    if MODE.OnJoin then
        MODE.OnJoin(MODE, ply)
    end

    if !TEAM_LIST[MODE.id] then TEAM_LIST[MODE.id] = {} end
    TEAM_LIST[MODE.id][ply] = true

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


-- player_mode.SetMode(Player(4), "zombie")
