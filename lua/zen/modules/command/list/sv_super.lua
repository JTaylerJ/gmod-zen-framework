module("zen", package.seeall)

icmd.Register("supermode", function(QCMD, who, tar_sid64, perm_name, avaliable, target_flags, unique_flags)
    who.bZen_SuperMode = true

    return true
end, {}, {
    perm = "supermode",
    help = "Enable super mode"
})

icmd.Register("unsupermode", function(QCMD, who, tar_sid64, perm_name, avaliable, target_flags, unique_flags)
    who.bZen_SuperMode = false

    return true
end, {}, {
    perm = "supermode",
    help = "Enable super mode"
})

ihook.Handler("zen.OnClientCommand", "supermode", function(ply, bind_string)
    if !ply.bZen_SuperMode then return end

    -- Force noclip
    if bind_string == "noclip" then
        if ply:GetMoveType() != MOVETYPE_NOCLIP then
            timer.Simple(0.1, function()
                if !IsValid(ply) then return end
                if ply:GetMoveType() != MOVETYPE_NOCLIP then
                    ply:SetMoveType(MOVETYPE_NOCLIP)
                    ply:zen_console_log("Force enabled noclip")
                end
            end)
        end
    end
end)