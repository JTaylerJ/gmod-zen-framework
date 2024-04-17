module("zen", package.seeall)

icmd.Register("menu_permissions", function(QCMD, who, cmd, args, tags)
    local pnlFrame = gui.CreateStyled("frame", nil, "menu_permissions")

end, {}, {
    perm = "menu_permissions",
    help = "Hello World"
})