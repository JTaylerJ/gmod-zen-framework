local _I = table.concat
local clr_red = Color(255, 0, 0)

function nt.Send(channel_name, types, data)
    assertString(channel_name, "channel_name")
    types = types or {}
    data = data or {}
    assertTable(types, "types")
    assertTable(data, "data")

    local channel_id = nt.GetChannelID(channel_name)
    local tChannel = nt.mt_Channels[channel_name]

    local bSuccess = true
    local sLastError

    if bSuccess and not channel_id then
        bSuccess = false
        sLastError = "SEND: channel_id not exists"
    end

    local iCounter = 0
    if bSuccess then
        local res, iCounterOrError = util.CheckTypeTableWithDataTable(types, data, function(net_type, value, type_id, id)
            if not nt.mt_listWriter[net_type] then
                return false, "Type-Writer not exists: " .. net_type
            end
        end, nt.mt_listExtraTypes)
        if res then
            iCounter = iCounterOrError
        else
            bSuccess = false
            sLastError = iCounterOrError
        end
    end

    if not bSuccess then
        MsgC(clr_red, "[NT-Predicted-Error] ", channel_name, "\n", sLastError, "\n")
        return
    end

    if nt.i_debug_lvl >= 2 then
        zen.print("[nt.debug] Start \"",channel_name,"\"")
    end
    if tChannel and tChannel.customNetworkString then
        net.Start(tChannel.customNetworkString)
    else
        net.Start(nt.channels.sendMessage)
        net.WriteUInt(channel_id, 12)
    end

        if iCounter > 0 then
            for id = 1, iCounter do
                local net_type = types[id]
                local fWriter = nt.mt_listWriter[net_type]
                local value = data[id]

                if nt.i_debug_lvl >= 2 then
                    zen.print("[nt.debug] Write \"",net_type,"\"", " \"",tostring(value),"\"")
                end

                fWriter(value)
            end
        end

    net.SendToServer()

    if nt.i_debug_lvl >= 2 then
        zen.print("[nt.debug] End \"",channel_name,"\"")
    end

    if nt.i_debug_lvl >= 1 then
        zen.print("[nt.debug] Sent network \"",channel_name,"\" to server")
    end
end

nt.mt_listReceivers = nt.mt_listReceivers or {}
function nt.Receive(channel_name, data, postFunction)
    data = data or {}
    assertTable(data, "data")

    local bSuccess = true
    local sLastError

    if bSuccess then
        for id, word in pairs(data) do
            if not word then
                bSuccess = false
                sLastError = _I{"GET: Word is nil, id: ", id}
                break
            end


            if bSuccess then
                if not nt.mt_listReader[word] then
                    bSuccess = false
                    sLastError = _I{"GET: Reader not exists: ", word}
                    break
                end
            end
        end
    end

    if not bSuccess then
        MsgC(clr_red, "[NT-Predicted-Error] ", channel_name, "\n", sLastError, "\n")
        return
    end

    nt.mt_listReceivers[channel_name] = {
        tFuncs = {},
        postFunc = postFunction
    }

    for _, word in pairs(data) do
        table.insert(nt.mt_listReceivers[channel_name].tFuncs, nt.mt_listReader[word])
    end
end

net.Receive(nt.channels.sendMessage, function(len)
    local channel_id = net.ReadUInt(12)
    local channel_name = nt.GetChannelName(channel_id)

    local bSuccess = true
    local sLastError

    if not channel_name then
        bSuccess = false
        sLastError = _I{"GET: Received unknown message name ", channel_id, "\n", debug.traceback(), "\n"}
    end

    local tChannel = nt.mt_Channels[channel_name]
    local tReceiverData = nt.mt_listReceivers[channel_name]
    local bWaitingInspect = true

    if bSuccess and bWaitingInspect and tChannel and (tChannel.fReader or tChannel.types) then
        local result = {}

        if nt.i_debug_lvl >= 2 then
            zen.print("[nt.debug] Start Read \"",channel_name,"\"")
        end

        if tChannel.fReader then
            result = {tChannel.fReader(tChannel)}

            if nt.i_debug_lvl >= 2 then
                for k, v in pairs(result) do
                    zen.print("[nt.debug] Read \"",type(v),"\"", " \"",tostring(v),"\"")
                end
            end
        elseif tChannel.types then
            for _, net_type in ipairs(tChannel.types) do
                local fReader = nt.mt_listReader[net_type]

                if not fReader then
                    bSuccess = false
                    sLastError = _I{"GET: Reader not exists: ", net_type}
                    goto result
                end


                local read_result = fReader()
                table.insert(result, read_result)

                if nt.i_debug_lvl >= 2 then
                    zen.print("[nt.debug] Read \"",net_type,"\"", " \"",tostring(read_result),"\"")
                end

                if net_type == "next" and read_result == false then break end
            end
        end

        if nt.i_debug_lvl >= 2 then
            zen.print("[nt.debug] End Read \"",channel_name,"\"")
        end

        if nt.i_debug_lvl >= 1 then
            zen.print("[nt.debug] GET: Received network \"",channel_name,"\" from server")
        end

        if CLIENT and tChannel.fSaving then
            tChannel.fSaving(tChannel, tChannel.tContent, unpack(result))
        end

        if tChannel.fPostReader then
            tChannel.fPostReader(tChannel, unpack(result))
        end

        hook.Run("nt.Receive", channel_name, unpack(result))
        bWaitingInspect = false
    end

    if bSuccess and bWaitingInspect then
        if not tReceiverData then
            bSuccess = false
            sLastError = _I{"GET: Received data not exists"}
            goto result
        end

        if nt.i_debug_lvl >= 2 then
            zen.print("[nt.debug] Start Read \"",channel_name,"\"")
        end

        local result = {}
        for net_type, fReader in pairs(tReceiverData.tFuncs) do
            local read_result = fReader()
            table.insert(result, read_result)

            if nt.i_debug_lvl >= 2 then
                zen.print("[nt.debug] Read \"",net_type,"\"", " \"",tostring(read_result),"\"")
            end

            if net_type == "next" and read_result == false then break end
        end

        if nt.i_debug_lvl >= 2 then
            zen.print("[nt.debug] End Read \"",channel_name,"\"")
        end

        hook.Run("nt.Receive", channel_name, unpack(result))

        if tReceiverData.postFunc then
            tReceiverData.postFunc(unpack(result))
        end

        if nt.i_debug_lvl >= 1 then
            zen.print("[nt.debug] GET: Received network \"",channel_name,"\" from server")
        end
        bWaitingInspect = false
    end

    if bWaitingInspect then
        bSuccess = false
        sLastError = "network not inspected"
    end

    ::result::

    if not bSuccess then
        MsgC(clr_red, "[NT-Predicted-Error] ", channel_name, "\n", sLastError, "\n")
        return
    end
end)

net.Receive(nt.channels.pullChannels, function()
    local channel_id = net.ReadUInt(32)
    local channel_name = nt.GetChannelName(channel_id)

    local bSuccess = true
    local sLastError

    if not channel_name then
        bSuccess = false
        sLastError = _I{"GET PULL: Received unknown message name ", channel_id, "\n", debug.traceback(), "\n"}
    end

    local tChannel = nt.mt_Channels[channel_name]
    local tContent = nt.mt_ChannelsContent[channel_name]

    if not tChannel then
        bSuccess = false
        sLastError = _I{"GET PULL: Chanell not exists ", channel_name, "\n", debug.traceback(), "\n"}
    end

    if bSuccess then
        if tChannel.fPullReader then
            local tResult = {}

            tChannel.fPullReader(tChannel, tContent, tResult)
            
            if CLIENT and tChannel.fSaving then
                for k, result in pairs(tResult) do
                    tChannel.fSaving(tChannel, tContent, unpack(result))
                end
            end

            if tChannel.fPostReader then
                for k, result in pairs(tResult) do
                    hook.Run("nt.Receive", channel_name, unpack(result))
                    tChannel.fPostReader(tChannel, unpack(result))
                end
            else
                for k, result in pairs(tResult) do
                    hook.Run("nt.Receive", channel_name, unpack(result))
                end
            end
        end
    end

    if not bSuccess then
        MsgC(clr_red, "[NT-Predicted-Error] ", channel_name, "\n", sLastError, "\n")
        return
    end

end)


ihook.Listen("InitPostEntity", "nt.ReadyForNetwork", function()
    hook.Run("ReadyForNetwork")
    net.Start(nt.channels.clientReady)
    net.SendToServer()
end)

ihook.Listen("nt.Receive", "zen.Channels", function(channel_name, v1, v2)
    if channel_name == "channels" then
        zen.print("NetworkChannel Received: ", v1, v2)
    end
end)