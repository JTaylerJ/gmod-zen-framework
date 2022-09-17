local iconsole = zen.Import("console")
iconsole.t_Commands = iconsole.t_Commands or {}



function iconsole.RegCommand(cmd_name, cmd_callback, cmd_types)
    iconsole.t_Commands[cmd_name] = {
        callback = cmd_callback,
        cmd_types = cmd_types
    }
end

-- function