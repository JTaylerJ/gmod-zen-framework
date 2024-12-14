module("zen")

player_mode.mt_PlayerMode = player_mode.mt_PlayerMode or {}
player_mode.iPlayerCounter = player_mode.iPlayerCounter or 0

nt.RegisterChannel("player_mode.UpdatePlayerMode", nt.t_ChannelFlags.PUBLIC, {
    types = {"player", "string"},
    OnRead = function(self, target, ply, mode_name)
        if CLIENT then
            player_mode.SetMode(ply, mode_name)
        end
    end,
    WritePull = function(self, target)
        if SERVER then
            local count = player_mode.iPlayerCounter
            net.WriteUInt(count, 16)

            for ply, MODE in pairs(player_mode.mt_PlayerMode) do
                net.WriteEntity(ply)
                net.WriteString(MODE.id)
            end
        end
    end,
    ReadPull = function(self, addResult)
        if CLIENT then
            self.iCounter = net.ReadUInt(16)
            for k = 1, self.iCounter do
                local ply = net.ReadEntity()
                local mode_name = net.ReadString()

                addResult(ply, mode_name)
            end
        end
    end,
})