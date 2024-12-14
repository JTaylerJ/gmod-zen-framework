module("zen")

local find = string.find
local concat = table.concat

local function sid_search(typen, text, text_next, addSelect)
    addSelect {
        text = "TRUE",
        value = "true"
    }
    addSelect {
        text = "FALSE",
        value = "false"
    }
end

icmd.RegisterAutoCompleteTypeN(TYPE.BOOLEAN, sid_search)

