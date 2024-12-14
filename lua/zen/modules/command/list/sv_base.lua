module("zen")

icmd.Register("auth", function(QCMD, who)
    if who:zen_GetVar("auth") then
        return false, "You already authed"
    end

    who:zen_SetVar("auth", true)

    return true, "Successful auth"
end, {}, {
    perm = "public",
    help = "auth - Authorize access"
})

icmd.Register("unauth", function(QCMD, who)
    if not who:zen_GetVar("auth") then
        return "You already unauthed"
    end

    who:zen_SetVar("auth", false)

    return true, "Successful unauth"
end, {}, {
    perm = "public",
    help = "unauth - Unauthorize access"
})

icmd.Register("sudo", function(QCMD, who, cmd, args, tags)
    local command = QCMD:Get("command")

    if !command or command == "" then
        return false, "No 'command' exists!"
    end

    game.ConsoleCommand(command .. "\n")

    return true, {"sudo: ", command}
end, {
    {type="string", name="command"}
}, {
    perm = "console.command",
    help = "Run Command on server console"
})