module("zen")

nt.RegisterChannel("channels", nt.t_ChannelFlags.PUBLIC, {
    id = 1,
    priority = 1,
    types = {"string", "int32"},
    Init = function(self)
        self.tContent = self.tContent or {}
        self.iCounter = self.iCounter or 0
    end,
    OnWrite = function(self, target, network_name, network_id)
        local tContent = self.tContent

        if not tContent[network_name] then
            self.iCounter = self.iCounter + 1
        end
        tContent[network_name] = network_id
    end,
    OnRead = function(self, ply, network_name, network_id)
        if CLIENT then
            nt.mt_ChannelsIDS[network_name] = network_id
            nt.mt_ChannelsNames[network_id] = network_name

            nt.RegisterChannel(network_name)
        end
    end,
    WritePull = function(self, target)
        local tContent = self.tContent

        net.WriteUInt(self.iCounter, 16)
        for k, v in pairs(tContent) do
            nt.Write(self.types, {k, v})
        end
    end,
    ReadPull = function(self, addResult)
        self.iCounter = net.ReadUInt(16)
        for k = 1, self.iCounter do
            local k, v = nt.Read(self.types)
            addResult(k, v)
        end
    end,
})