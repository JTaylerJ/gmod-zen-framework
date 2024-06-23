module("zen", package.seeall)

player_mode = _GET("player_mode")

---@type table<string, zen.player_mode>
player_mode.mt_ModeList = player_mode.mt_ModeList or {}

---@type table<Player, zen.player_mode>
player_mode.mt_PlayerMode = player_mode.mt_PlayerMode or {}
player_mode.iPlayerCounter = player_mode.iPlayerCounter or 0

---@type table<string, table<string, zen.player_mode>
player_mode.mt_TeamsPlayer = player_mode.mt_TeamsPlayer or {}

---@type table<string, table<string, string>
player_mode.mt_ModeHooks = player_mode.mt_ModeHooks or {}

local MODE_LIST = player_mode.mt_ModeList
local PLAYER_MODE = player_mode.mt_PlayerMode
local TEAM_LIST = player_mode.mt_TeamsPlayer
local MODE_HOOKS = player_mode.mt_ModeHooks


---@class zen.player_mode_meta: table
local META = {}

---@class zen.player_mode_meta.hook_data
---@field name string
---@field unique string
---@field callback fun(self, ...): any?
---@field canApply? fun(self, ply): boolean
---@field tag string

---@type table<string, zen.player_mode_meta.hook_data>
META.mt_Hooks = {}

---@type table<string, string>
META.mt_OwnerHooks_Activated = {}
META.mt_PlayerCooldown       = {}

---@package
---@param hook_name string
---@param hook_unique string
---@param callback fun(self, ...): any?
---@param canApply? fun(self, ply?: Player): boolean
---@param tag? string
function META:__AddHook(hook_name, hook_unique, callback, canApply, tag)
    local hook_hash = hook_name  .. "." .. hook_unique

    self.mt_Hooks[hook_hash] = {
        name = hook_name,
        unique = hook_unique,
        callback = callback,
        canApply = canApply,
        tag = tag,
    }
end

---@param hook_name string
---@param callback fun(self: zen.player_mode, ...): any?
function META:Hook(hook_name, callback)
    self:__AddHook(
        hook_name,
        self.hookID,
        function(...) return callback(self, ...) end,
        nil,
        "shared"
    )
end

--- Create hook for server only
---@param hook_name string
---@param callback fun(self: zen.player_mode, ...): any?
function META:HookServer(hook_name, callback)
    self:__AddHook(
        hook_name,
        self.hookID,
        function(...) return callback(self, ...) end,
        function() return SERVER end,
        "server"
    )
end

--- Create hook for all clients
---@param hook_name string
---@param callback fun(self: zen.player_mode, ...): any?
function META:HookClient(hook_name, callback)
    self:__AddHook(
        hook_name,
        self.hookID,
        function(...) return callback(self, ...) end,
        function() return CLIENT end,
        "client"
    )
end

--- Create hook for client owner only
---@param hook_name string
---@param callback fun(self: zen.player_mode, ...): any?
function META:HookOwner(hook_name, callback)
    self:__AddHook(
        hook_name,
        self.hookID,
        function(...) return callback(self, ...) end,
        function(self, ply) return CLIENT and ply == LocalPlayer() end,
        "client_owner"
    )
end

---@param ply Player
---@return boolean
function META:IsTeamMate(ply)
    return TEAM_LIST[self.id][ply]
end

---@param ply Player
---@param uniqueID string
---@param cooldown number
---@return boolean
function META:PlayerCooldown(ply,  uniqueID, cooldown)
    if !self.mt_PlayerCooldown[ply] then
        self.mt_PlayerCooldown[ply] = {}
    end

    local t_CoolDown = self.mt_PlayerCooldown[ply]

    local last_use = t_CoolDown[uniqueID]
    if last_use and (last_use + cooldown) > CurTime() then return false end

    t_CoolDown[uniqueID] = CurTime()

    return true
end


---@param ply Player
function player_mode.SetupHooks(ply)
    local MODE = PLAYER_MODE[ply]

    if !MODE_HOOKS[MODE.id] then MODE_HOOKS[MODE.id] = {} end
    local TEAM_HOOKS = MODE_HOOKS[MODE.id]

    if MODE.mt_Hooks then
        for hook_hash, hook_data in pairs(MODE.mt_Hooks) do
            if hook_data.canApply then
                if hook_data.canApply(MODE, ply) != true then continue end
            end

            if hook_data.tag == "client_owner" then
                MODE.mt_OwnerHooks_Activated[hook_data.name] = hook_data.unique
            else
                TEAM_HOOKS[hook_data.name] = hook_data.unique
            end

            ihook.Handler(hook_data.name, hook_data.unique, hook_data.callback)
        end
    end
end

---@param ply Player
function player_mode.ClearPlayerMode(ply)
    local MODE = PLAYER_MODE[ply]
    if !MODE then return end

    PLAYER_MODE[ply] = nil

    if MODE.OnExit then
        MODE:OnExit(ply)
    end

    if MODE.mt_OwnerHooks_Activated then
        for name, unique in pairs(MODE.mt_OwnerHooks_Activated) do
            ihook.Remove(name, unique)
            MODE.mt_OwnerHooks_Activated[name] = nil
        end
    end

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



---@class zen.player_mode: zen.player_mode_meta
---@field id string
---@field package hookID string
---@field package hookID_unique string hookID_unique for hooks
---@field Owner Player
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


---@param mode_name string
---@return zen.player_mode
function player_mode.GetClass(mode_name)
    if !MODE_LIST[mode_name] then MODE_LIST[mode_name] = table.Copy(META) end
    local MODE = MODE_LIST[mode_name]

    table.Merge(MODE, META)

    MODE.id = mode_name
    MODE.hookID = tostring("zen.player_mode."  ..  MODE.id)

    if !TEAM_LIST[MODE.id] then TEAM_LIST[MODE.id] = {} end

    return MODE
end

---@param ply Player
---@return string|nil
function player_mode.GetPlayerModeName(ply)
    local MODE = PLAYER_MODE[ply]
    if !MODE then return end
    return MODE.id
end

---@param ply Player
---@param mode_name string
---@return boolean
function player_mode.IsPlayerMode(ply, mode_name)
    local TEAM_MATES = TEAM_LIST[mode_name]
    if !TEAM_MATES then return false end

    return TEAM_MATES[ply]
end


---@param MODE zen.player_mode
function player_mode.Register(MODE)
    assert(MODE.id, "MODE.id not exists")

    MODE_LIST[MODE.id] = MODE

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
    print("SetupPlayerMode", mode_name)
    if mode_name == nil or mode_name == "default" then
        if PLAYER_MODE[ply] then
            player_mode.ClearPlayerMode(ply)
        end


        if SERVER then
            player_mode.iPlayerCounter = table.Count(PLAYER_MODE)

            nt.SendToChannel("player_mode.UpdatePlayerMode", nil, ply, "default")
        end

        return
    end

    ---------------------------
    ----- REMOVE LAST MODE ----
    ---------------------------

    if PLAYER_MODE[ply] then
        player_mode.ClearPlayerMode(ply)
    end

    ----------------------------
    ------ SETUP NEW MODE ------
    ----------------------------


    local MODE = MODE_LIST[mode_name]
    assert(MODE, "MODE not exists")

    --- local copy for player only
    ---@type zen.player_mode
    ---@diagnostic disable-next-line: assign-type-mismatch
    MODE = table.Copy(MODE)

    MODE.Owner = ply

    MODE.hookID_unique = tostring("zen.player_mode."  ..  MODE.id .. "." .. ply:SteamID64())

    PLAYER_MODE[ply] = MODE

    if SERVER then
        player_mode.iPlayerCounter = table.Count(PLAYER_MODE)
    end

    player_mode.SetupHooks(ply)

    if MODE.OnJoin then
        MODE.OnJoin(MODE, ply)
    end

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
