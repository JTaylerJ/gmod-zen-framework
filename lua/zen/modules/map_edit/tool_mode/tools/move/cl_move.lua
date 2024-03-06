module("zen", package.seeall)

---@class zen_TOOL
local TOOL = {}
TOOL.id = "move"
TOOL.Name = "Move"
TOOL.Icon = "zen/map_edit/open_with.png"
TOOL.Description = "Move Entity"

function TOOL:Init()
end

function TOOL:Render(rendermode, priority, vw)
    local bGrabbingActive = IsValid(self.eGrabbedEntity)
    if bGrabbingActive then


    end
end

function TOOL:Reload()
end

function TOOL:GrabEntity()
    local ent = map_edit.GetHoverEntity()
    if !IsValid(ent) then return end

    self:CallServerAction{
        action = "grab",
        ent = ent
    }

    self.eGrabbedEntity = ent

    self.vStartPos = self.eGrabbedEntity:GetPos()
    self.aStartAngle = self.eGrabbedEntity:GetAngles()
end

function TOOL:UnGrabEntity()
    if !self.eGrabbedEntity then return end
    if !IsValid(self.eGrabbedEntity) then return end

    self:CallServerAction{
        action = "ungrab",
    }

    self.eGrabbedEntity = nil
end

function TOOL:OnButtonPress(but, in_key, bind_name, vw)
    if bind_name == "+attack" then
        self:GrabEntity()
    end
end

function TOOL:OnButtonUnPress(but, in_key, bind_name, vw)
    if bind_name == "+attack" then
        self:UnGrabEntity()
    end
end

map_edit.tool_mode.Register(TOOL)