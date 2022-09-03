nt.RegisterChannel("channels", nt.t_ChannelFlags.PUBLIC + nt.t_ChannelFlags.SAVING, {
    id = 1,
    priority = 1,
    types = {"string", "int32"},
    fSaving = function(tChannel, tContent, network_name, network_id)
        if not tContent[network_name] then
            tChannel.iCounter = tChannel.iCounter + 1
        end
        tContent[network_name] = network_id
    end,
    fPostReader = function(tChannel, network_name, network_id)
        if CLIENT then
            nt.mt_ChannelsIDS[network_name] = network_id
            nt.mt_ChannelsNames[network_id] = network_name
            
            nt.RegisterChannel(network_name)
        end
    end,
    fPullWriter = function(tChannel, tContent, ply)
        net.WriteUInt(tChannel.iCounter, 16)
        for k, v in pairs(tContent) do
            nt.Write(tChannel.types, {k, v})
        end
    end,
    fPullReader = function(tChannel, tContent, tResult)
        tChannel.iCounter = net.ReadUInt(16)
        for k = 1, tChannel.iCounter do
            local k, v = nt.Read(tChannel.types)
            table.insert(tResult, { k, v })
        end
    end,
})