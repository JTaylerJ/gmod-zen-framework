module("zen", package.seeall)

local PANEL = {}

function PANEL:Init()
    self.pnlClose = gui.CreateStyled("button", self)

end

function PANEL:DoClick()
    -- Base DoClick stuff
end

function PANEL:PerformLayout(w, h)
    -- print(w, h)
end

function PANEL:Paint(w, h)
    -- draw.Box(0, 0, w, h, _COLOR.W)
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