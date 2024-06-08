module("zen", package.seeall)

local string_find = string.find

icmd.Register("menu_permissions", function(QCMD, who, cmd, args, tags)
    local pnlFrame = gui.CreateStyled("frame", nil, "menu_permissions")
    pnlFrame:SetTitle("Permissions")

    local FEATURES = {}

    do
        local t_SearchPlayerTable = {}


        local pnlEntry = gui.CreateStyled("input_text", pnlFrame, nil, {
            tall = 30,
            "dock_top",
        })

        local pnlPlayers = gui.Create("DScrollPanel", pnlFrame, {
            "dock_fill"
        })

        pnlEntry:Setup({
            type = TYPE.STRING
        }, function(value)
            value = value or ""
            local search_text = string.lower(value)

            local t_Founded = {}

            for sid64, dat in pairs(t_SearchPlayerTable) do
                local bFounded = string_find(dat.text, search_text, 1, true)
                t_Founded[sid64] = true
                dat.panel:SetVisible(bFounded)
            end

            local sid64_value
            if util.IsSteamID(value) then
                sid64_value = util.SteamIDTo64(value)
            end

            if util.IsSteamID64(value) then
                sid64_value = value
            end

            if sid64_value and !t_Founded[sid64_value] then
                FEATURES.CreatePlayer(sid64_value)
            end


            pnlPlayers:InvalidateLayout(true)
        end)

        FEATURES.CreatePlayer = function(sid64, nick)
            local sid = util.SteamIDFrom64(sid64)
            local pnlPlayer = gui.Create("EditablePanel", pnlPlayers, {
                "dock_top", tall = 30, cursor = "hand", margin = {0,0,0,2}, cc = {
                    Paint = function(self, w, h)
                        if self:IsHovered() then
                            surface.SetDrawColor(255,255,255,10)
                            surface.DrawRect(0,0,w,h)
                        end
                    end
                }
            })

            local pnlAvatar = gui.Create("AvatarImage", pnlPlayer, {
                "dock_left", wide = 30, input = false
            })
            pnlAvatar:SetSteamID(sid64, 32)

            local pnlName = gui.Create("DLabel", pnlPlayer, {
                "dock_fill", margin = {5,0,0,0}, font = ui.ffont(8)
            })
            pnlName:SetText(sid64)

            local search_text = sid64 .. "/" .. sid

            if nick then
                search_text = search_text .. "/" .. tostring(nick)
                pnlName:SetText(nick)
            end


            t_SearchPlayerTable[sid64] = {
                text = util.StringLower(search_text),
                panel = pnlPlayer
            }

            if !nick then
                steamworks.RequestPlayerInfo(sid64, function(steam_name)
                    pnlName:SetText(steam_name)
                    t_SearchPlayerTable[sid64].text = util.StringLower(t_SearchPlayerTable[sid64].text .. "/" .. steam_name)
                end)
            end
        end

        for k, ply in player.Iterator() do
            FEATURES.CreatePlayer(ply:SteamID64(), ply:Nick())
        end

        pnlEntry.pnl_Value:SetPlaceholderText("Nick / SteamID / SteamID64")
    end


end, {}, {
    perm = "menu_permissions",
    help = "Hello World"
})