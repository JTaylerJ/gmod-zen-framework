module("zen", package.seeall)

meeting = _GET("meeting")



---@alias zen.MeetingKickType
---| '"disconnect"'
---| '"kick"'
---| '"by_self"'
---| '"timeout"'
---| '"close"'

/*
    Meeting system for garry's mod.
    Allow you to start event/meeting where player can fun and play games.

    Mining system contain:
    Start() - Start the meeting
    Close() - Close the meeting
    PlayerJoin(ply)  - Called when player join the meeting
    PlayerLeave(ply) - Called when player leave the meeting

    Every call shoud call hook.Run

*/

---@class zen.Meeting
---@field package isMeeting boolean
---@field package isInfinity boolean
---@field package duration number|0
---@field package startTime number
---@field package endTime? number
---@field package players table<string, Player> SteamID/Player
---@field OnStart? fun()
---@field OnClose? fun()
---@field OnPlayerJoin? fun(self, ply: Player)
---@field OnPlayerLeave? fun(self, ply: Player, type: zen.MeetingKickType)
---@field OnThink? fun(self)
local META = {}

META.__index = META

function META:Init()
    self.isMeeting = false
    self.isInfinity = false
    self.duration = 0
    self.startTime = 0
    self.endTime = 0
    self.players = {}
end

-- Meta IsValid for hooks
---@package
---@return boolean
function META:IsValid()
    return self.isMeeting
end

-- Meta Is Player in meeting
---@param ply Player
---@return boolean
function META:IsPlayerInMeeting(ply)
    local userID = ply:UserID()

    return self.players[userID] ~= nil
end

-- Kick Player from meeting
---@param ply Player
---@param type? zen.MeetingKickType
function META:KickPlayer(ply, type)
    type = type or "kick"
    if not self:IsPlayerInMeeting(ply) then
        return
    end

    self:PlayerLeave(ply, type)

    -- Call the hook
    hook.Run("zen.OnPlayerKick", self, ply, type)
end

---@package
--- Init hooks
function META:InitHooks()
    -- Add think hooks
    hook.Add("Think", self, function()
        if self.isMeeting then
            if not self.isInfinity and CurTime() >= self.endTime then
                self:Close()
            end
        end

        if self.isMeeting then
            if self.OnThink then
                self:OnThink()
            end
        end
    end)

    -- Kick player from event if player disconnect
    hook.Add("PlayerDisconnected", self, function(ply)
        if self.isMeeting then
            self:KickPlayer(ply, "disconnect")
        end
    end)
end


---@package
-- Start the meeting
---@param duration? number|0 -- In munites, 0 for infinity
function META:Start(duration)
    self.isMeeting = true
    self.startTime = CurTime()

    -- Check infinity
    if duration == 0 then
        self.isInfinity = true
    else
        self.endTime = CurTime() + self.duration
    end

    self.players = {}

    --Check if exists
    if self.OnStart then
        self:OnStart()
    end

    self:InitHooks()

    -- Call the hook
    hook.Run("zen.OnMeetingStart", self)
end

---@package
-- Close the meeting
function META:Close()
    self.isMeeting = false
    self.endTime = CurTime()

    -- Check if exists
    if self.OnClose then
        self:OnClose()
    end

    -- Kick all player from event
    for _, ply in ipairs(self.players) do
        self:KickPlayer(ply, "close")
    end

    -- Call the hook
    hook.Run("zen.OnMeetingClose", self)
end


--- Called when player join the meeting
---@package
---@param ply Player
function META:PlayerJoin(ply)
    -- Insert Player to players
    local userID = ply:UserID()
    self.players[userID] = ply

    -- Call OnPlayerJoin
    if self.OnPlayerJoin then
        self:OnPlayerJoin(ply)
    end

    -- Call the hook
    hook.Run("zen.PlayerJoin", self, ply)
end

--- Called when player leave the meeting
---@package
---@param ply Player
---@param type zen.MeetingKickType
function META:PlayerLeave(ply, type)
    -- Remove Player from players
    local userID = ply:UserID()
    self.players[userID] = nil

    -- Call OnPlayerLeave
    if self.OnPlayerLeave then
        self:OnPlayerLeave(ply, type)
    end

    -- Call the hook
    hook.Run("zen.PlayerLeave", self, ply)
end