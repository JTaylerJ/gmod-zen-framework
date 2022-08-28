nt.Receive(icfg.net_permUpdate, {"string", "bool", "string", "string"}, function(sid64, isAdd, permName, tags)
    if not iperm.mt_listLoadedPermissions[sid64] then iperm.mt_listLoadedPermissions[sid64] = {} end

    if isAdd then
        iperm.mt_listLoadedPermissions[sid64][permName] = tags
    else
        iperm.mt_listLoadedPermissions[sid64][permName] = nil
    end
end)