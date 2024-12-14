module("zen")

local PANEL = {}

local _SizeToChildren = META.PANEL.SizeToChildren

function PANEL:Init()
    self.bChangeWide = false
    self.bChangeTall = true
end

---@param updateWide boolean
---@param updateTall boolean
function PANEL:AutoSize(updateWide, updateTall)
    self.bChangeWide = updateWide
    self.bChangeTall = updateTall
end

-- function PANEL:Think()
--     _SizeToChildren(self, self.bChangeWide, self.bChangeTall)
-- end

function PANEL:PerformLayout(w, h)
    local cw, ch = self:ChildrenSize()

    if (self.bChangeWide and w < cw) or (self.bChangeTall and h < ch) then
        _SizeToChildren(self, self.bChangeWide, self.bChangeTall)
    end
end

gui.RegisterStylePanel("content", PANEL, "EditablePanel")