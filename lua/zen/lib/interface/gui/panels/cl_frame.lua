module("zen", package.seeall)

local PANEL = {}

function PANEL:Init()


end

function PANEL:DoClick()
    -- Base DoClick stuff
end


function PANEL:OnMousePressed(code)
    if code == MOUSE_LEFT then
        if self.DoClick then
            self:DoClick()
        end
    end
end

gui.RegisterStylePanel("frame",
    PANEL,
    "EditablePanel",
    {
        mouse_input = true
    }
)