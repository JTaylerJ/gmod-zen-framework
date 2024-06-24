module("zen", package.seeall)

local PANEL = {}

function PANEL:Init()
    self.pnlFather = self:GetParent()
    self.pnlGhostVBar = gui.CreateStyled("scroll_vbar", self.pnlFather)
    self.pnlGhostVBar:SetScrollPanel(self)

    self.VBar:SetWide(0)
end

gui.RegisterStylePanel("scroll_list", PANEL, "DScrollPanel")