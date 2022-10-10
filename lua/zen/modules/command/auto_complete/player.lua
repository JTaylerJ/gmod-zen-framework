local icmd, iconsole = zen.Init("command", "console")

local find = string.find
local concat = table.concat

local function get_sid(typen, ply)
    if typen == TYPE.STEAMID then
        return ply:SteamID()
    elseif typen == TYPE.STEAMID64 then
        return ply:SteamID64()
    end
end

local function sid_search(typen, text, text_next, addSelect)

    if !text or text == "" or text == " " then
        for k, ply in pairs(player.GetHumans()) do
            local sid = get_sid(typen, ply)
            addSelect {
                text = concat{sid, " - ", ply:Nick()},
                value = sid
            }
        end
    else
        local text_lower = util.StringLower(text)
        for k, ply in pairs(player.GetHumans()) do
            local name_lower = util.StringLower(ply:Nick())
            if !find(name_lower, text_lower) then continue end
            local sid = get_sid(typen, ply)

            addSelect {
                text = concat{sid, " - ", ply:Nick()},
                value = sid
            }
        end
    end
end

icmd.RegisterAutoCompleteTypeN(TYPE.STEAMID, sid_search)
icmd.RegisterAutoCompleteTypeN(TYPE.STEAMID64, sid_search)

