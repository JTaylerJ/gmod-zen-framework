module("zen", package.seeall)

---@class zen_TOOL
local TOOL = {}
TOOL.id = "move"
TOOL.Name = "Move"
TOOL.Icon = "zen/map_edit/open_with.png"
TOOL.Description = "Move Entity"

function TOOL:Init()
end

function TOOL:Think(rendermode, priority, vw)
    local bGrabbingActive = IsValid(self.eGrabbedEntity)
    if bGrabbingActive then
        self.vNewPosition = map_edit.GetHoverOrigin()

        self:CallServerAction{
            action = "update_pos",
            pos = self.vNewPosition,
            ang = self.vNewAngle
        }
    end
end

function TOOL:Reload()
end

function TOOL:GrabEntity()
    local ent = map_edit.GetHoverEntity()
    if !IsValid(ent) then return end

    self.eGrabbedEntity = ent
    print("Grabbed Entity: ", ent)

    self:CallServerAction{
        action = "grab",
        ent = ent
    }

    self.vGrabOffset = self.eGrabbedEntity:GetPos() - map_edit.GetHoverOrigin()
    self.iLastMoveType = self.iLastMoveType or ent:GetMoveType()
    self.iLastSolid = self.iLastSolid or ent:GetSolid()
    ent:SetMoveType(MOVETYPE_CUSTOM)
    ent:SetSolid(SOLID_NONE)

    self.vStartPos = self.eGrabbedEntity:GetPos()
    self.aStartAngle = self.eGrabbedEntity:GetAngles()

    self.vNewAngle = self.aStartAngle
    self.vNewPosition = map_edit.GetHoverOrigin()
end

function TOOL:UnGrabEntity()
    if !self.eGrabbedEntity then return end
    if !IsValid(self.eGrabbedEntity) then return end

    local ent = self.eGrabbedEntity
    local movetype = self.iLastMoveType
    local solid = self.iLastSolid

    self.vGrabOffset = nil
    self.eGrabbedEntity = nil
    self.iLastMoveType = nil
    self.iLastSolid = nil
    print("UnGrabbed Entity: ", ent)

    self:CallServerAction{
        action = "ungrab",
        solid = solid,
        movetype = movetype
    }
end

function TOOL:ResetAngle()
    self.vNewAngle = Angle(0,0,0)
end

function TOOL:OnButtonPress(but, in_key, bind_name, vw)
    if bind_name == "+attack" then
        self:GrabEntity()
    end

    if bind_name == "+walk" then
        self.bAngleRotaing = true
    end
end

function TOOL:OnButtonUnPress(but, in_key, bind_name, vw)
    if bind_name == "+attack" then
        self:UnGrabEntity()
    end

    if bind_name == "+reload" then
        self:ResetAngle()
    end

    if bind_name == "+walk" then
        self.bAngleRotaing = false
    end

end

map_edit.tool_mode.Register(TOOL)