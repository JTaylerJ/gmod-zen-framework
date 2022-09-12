izen.permission.command = izen.permission.command or {}
zen.permission.command = izen.permission.command
icmd = zen.permission.command

icmd.mt_listCommands = {}
function icmd.registerCommand(cmd, types, func, permissionReplace)
    assertStringNice(cmd, "cmd")
    assertTable(types, "types")
    assertFunction(func, "func")
    assert(isstring(permissionReplace) or permissionReplace == nil, "permissionReplace shoulde be string|nil")

    local perm = permissionReplace and permissionReplace or "izen.cmd." .. cmd

    icmd.mt_listCommands[cmd] = {
        func = func,
        types = types,
        perm = perm,
    }
end

function icmd.Receive(ply, cmd, data)
    local tCommand = icmd.mt_listCommands[cmd]

    local bSuccess = true
    local sLastError

    if bSuccess and not tCommand then
        bSuccess = false
        sLastError = "This command not exists!"
    end

    local fCallBack = tCommand.func
    local sPerm = tCommand.perm

    if bSuccess and not ply:zen_HasPerm(sPerm) then
        bSuccess = false
        sLastError = "You don't have permission to this command!"
    end

    local types = tCommand.types

    local tResult = {}
    if bSuccess then
        local res, iCounterOrError, tData = util.CheckTypeTableWithDataTable(types, data)
        if res then
            tResult = tData
        else
            bSuccess = false
            sLastError = string.Interpolate("${s:1} (${s:2}): ${s:3}", {cmd, table.concat(types, ","), iCounterOrError})
        end
    end

    if not bSuccess then
        return false, sLastError
    end

    return fCallBack(ply, unpack(tResult))
end


ihook.Listen("zen.console.command", "zen.permission", function(ply, cmd, args, argsStr)
    return icmd.Receive(ply, cmd, args)
end)

