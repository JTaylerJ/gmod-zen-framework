ihook.Listen("ReadyForNetwork", "nt.SendAllNetworkChannels", function(ply)

    for _, v in ipairs(nt.mt_ChannelsPublicPriority) do
        local channel_name = v.name
        local channel_id = v.id

        local tChannel = nt.mt_Channels[channel_name]
        local tContent = nt.mt_ChannelsContent[channel_name]
        if not tChannel then continue end

        if nt.i_debug_lvl >= 2 then
            zen.print("[nt.debug] Player ", ply:SteamID64(), " start pull ", channel_name)
        end

        net.Start(nt.channels.pullChannels)
            net.WriteUInt(channel_id, 32)
            if tChannel.fPullWriter then
                tChannel.fPullWriter(tChannel, tContent, ply)
            end
        net.Send(ply)

        if nt.i_debug_lvl >= 2 then
            zen.print("[nt.debug] Player ", ply:SteamID64(), " end pull ", channel_name)
        end
    end

    if nt.i_debug_lvl >= 1 then
        zen.print("[nt.debug] All channels sent to player ", ply:SteamID64())
    end
end)

net.Receive(nt.channels.clientReady, function(len, ply)
    ply.mbReadyForNetwork = true
    ihook.Run("ReadyForNetwork", ply)
end)

local clr_red = Color(255, 0, 0)

function nt.Send(channel_name, types, data, target)
    assertString(channel_name, "channel_name")
    types = types or {}
    data = data or {}
    assertTable(types, "types")
    assertTable(data, "data")

    local channel_id = nt.GetChannelID(channel_name)

    local tChannel = nt.mt_Channels[channel_name]

    local bSuccess = true
    local sLastError

    if bSuccess then
        if target then
            if isentity(target) and not IsValid(target) or not target:IsPlayer() then
                bSuccess = false
                sLastError = "SEND: target entity not is player or not is valid"
            end
        end
    end

    local iCounter = 0
    if bSuccess then
        local res, iCounterOrError = util.CheckTypeTableWithDataTable(types, data, function(net_type, value, type_id, id)
            if SERVER and net_type == "string_id" then
                nt.RegisterStringNumbers(value)
            end
            local fWriter = nt.GetTypeWriterFunc(net_type)
            if not fWriter then
                return false, "Type-Writer not exists: " .. net_type
            end
        end, nt.funcValidCustomType)
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
                local fWriter, isSpecial, a1, a2, a3, a4, a5 = nt.GetTypeWriterFunc(net_type)
                local value = data[id]

                if nt.i_debug_lvl >= 2 then
                    zen.print("[nt.debug] Write \"",net_type,"\"", " \"",tostring(value),"\"")
                end

                fWriter(value, a1, a2, a3, a4, a5)
            end
        end

    if target then
        net.Send(target)
    else
        net.Broadcast()
    end

    if nt.i_debug_lvl >= 2 then
        zen.print("[nt.debug] End \"",channel_name,"\"")
    end

    ihook.Run("nt.Send", {channel_name, types, data, target})

    if nt.i_debug_lvl >= 1 then
        if target then
            zen.print("[nt.debug] Sent network \"",channel_name,"\" to player ", target:SteamID64())
        else
            zen.print("[nt.debug] Broadcast network \"",channel_name,"\"")
        end
    end
end

nt.mt_listReceivers = nt.mt_listReceivers or {}
function nt.Receive(channel_name, types, postFunction)
    types = types or {}
    assertTable(types, "types")

    local bSuccess = true
    local sLastError

    if bSuccess then
        for id, human_type in pairs(types) do
            if not human_type then
                bSuccess = false
                sLastError = _I{"GET: human_type is nil, id: ", id}
                break
            end


            if bSuccess then
                local fReader = nt.GetTypeReaderFunc(human_type)
                if not fReader then
                    bSuccess = false
                    sLastError = _I{"GET: Reader not exists: ", human_type}
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

    for _, human_type in pairs(types) do
        local fReader, isSpecial, a1, a2, a3, a4, a5 = nt.GetTypeReaderFunc(human_type)
        table.insert(nt.mt_listReceivers[channel_name].tFuncs, {
            fReader = fReader,
            args = {a1, a2, a3, a4, a5}
        })
    end
end


net.Receive(nt.channels.sendMessage, function(len, ply)
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

    if bSuccess and tChannel and (tChannel.fReader or tChannel.types) then
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
                local fReader = nt.GetTypeReaderFunc(net_type)

                if not fReader then
                    bSuccess = false
                    sLastError = I{"GET: Reader not exists: ", net_type}
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
            zen.print("[nt.debug] GET: Received network \"",channel_name,"\" from ", ply:SteamID64())
        end

        if tChannel.fPostReader then
            tChannel.fPostReader(tChannel, ply, unpack(result))
        end

        ihook.Run("nt.Receive", channel_name, ply, unpack(result))
    end

    if bSuccess then
        if not tReceiverData then
            bSuccess = false
            sLastError = I{"GET: Received data not exists"}
            goto result
        end

        if nt.i_debug_lvl >= 2 then
            zen.print("[nt.debug] Start Read \"",channel_name,"\"")
        end

        local result = {}
        for net_type, v in pairs(tReceiverData.tFuncs) do
            local read_result = v.fReader(unpack(v.args))
            table.insert(result, read_result)

            if nt.i_debug_lvl >= 2 then
                zen.print("[nt.debug] Read \"",net_type,"\"", " \"",tostring(read_result),"\"")
            end

            if net_type == "next" and read_result == false then break end
        end

        if nt.i_debug_lvl >= 2 then
            zen.print("[nt.debug] End Read \"",channel_name,"\"")
        end

        ihook.Run("nt.Receive", channel_name, ply, unpack(result))

        if tReceiverData.postFunc then
            tReceiverData.postFunc(ply, unpack(result))
        end

        if nt.i_debug_lvl >= 1 then
            zen.print("[nt.debug] GET: Received network \"",channel_name,"\" from ", ply:SteamID64())
        end
    end

    ::result::

    if not bSuccess then
        MsgC(clr_red, "[NT-Predicted-Error] ", channel_name, "\n", sLastError, "\n")
        return
    end
end)

ihook.Listen("nt.Receive", "zen.nt.logs", function(channel_name, ...)
    if nt.i_debug_lvl >= 1 then
        zen.print("[nt.received] ", channel_name)
        print(...)
    end
end)