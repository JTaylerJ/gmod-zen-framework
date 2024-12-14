module("zen")

nt.RegisterChannel("zen.console.command")
nt.RegisterChannel("zen.console.message")

iperm.RegisterPermission("zen.console.server_console", iperm.flags.NO_TARGET, "Access to server console")
iperm.RegisterPermission("zen.console.server_log", iperm.flags.NO_TARGET, "Access to view server server after epoe")

function META.PLAYER:zen_console_log(...)
    local args = {...}
    nt.Send("zen.console.message", {"array:any"}, {args})
end

nt.Receive("zen.console.command", {"string"}, function(ply, str)
    local args = str:Split(" ")
    local cmd = args[1]
    table.remove(args, 1)

    ply:EmitSound("buttons/combine_button5.wav")

    local res, com = ihook.Run("zen.console.command", ply, cmd, args, str)
    if res == true or res == nil then
        ply:zen_console_log(com or "Successful ran")
    else
        ply:zen_console_log(com or "Command not ran!")
    end
end)