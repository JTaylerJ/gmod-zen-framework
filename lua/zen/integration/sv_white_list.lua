hook.Add("CheckPassword", "zen", function(sid64)
    if iperm.PlayerSetPermission(sid64, "ignore_password") then return true end
end)