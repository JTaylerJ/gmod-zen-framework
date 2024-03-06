module("zen", package.seeall)

---@class zen_TOOL
local TOOL = {}
TOOL.id = "move"
TOOL.Name = "Move"
TOOL.Description = "Move"

function TOOL:Init()

end

function TOOL:UpdateViewPos(data)
    
end

function TOOL:Grab(data)
    local ent = data.ent
    if !IsValid(ent) then return end
end

function TOOL:Ungrab(data)
    
end


function TOOL:ServerAction(data)
    local action = data.action
    if !action then return end

    if action == "update_viewpos"then
        self:UpdateViewPos(data)
    end

    if action == "grab" then
        self:Grab(data)
    end

    if action == "ungrab" then
        self:Ungrab(data)
    end

end

map_edit.tool_mode.Register(TOOL)