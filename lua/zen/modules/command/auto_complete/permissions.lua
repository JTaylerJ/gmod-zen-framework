module("zen", package.seeall)

local find = string.find
local concat = table.concat


icmd.RegisterAutoCompleteArgName("perm_name", function(arg_name, text, text_next, addSelect)
    if !text or text == "" or text == " " then
        for perm_name in pairs(iperm.mt_Permissions) do            
            addSelect{
                text = perm_name,
                value = '"' .. perm_name .. '"'
            }
        end
    else
        local text_lower = util.StringLower(text)
        for perm_name in pairs(iperm.mt_Permissions) do
            local perm_name_lower = util.StringLower(perm_name)
            if !find(perm_name_lower, text_lower) then continue end

            addSelect{
                text = perm_name,
                value = '"' .. perm_name .. '"'
            }
        end
    end
end)