local icmd = zen.Import("command")
local save = zen.Init("zen.Save")

icmd.Register("go", function(QCMD, who, cmd, args, tags)



end, {
    {type = "string_id", name = "go.point"},
}, {
    perm = "go",
    help = "Teleport to point"
})

icmd.Register("go.set", function(QCMD, who, cmd, args, tags)



end, {
    {type = "string_id", name = "go.point"},
    {type = "vector", name = "position"},
    {type = "angle", name = "position"},
}, {
    perm = "go.set",
    help = "Teleport to point"
})

