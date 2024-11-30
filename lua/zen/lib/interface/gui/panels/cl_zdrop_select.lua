module("zen", package.seeall)

---@class zen.panel.zdrop_select: zen.panel.zpanelbase
local PANEL = {}

function PANEL:Init()
    self:SetCursor("hand")
end

function PANEL:OpenSelectBox()
    self.pnlSelect = gui.Create("zpanelbase")
    self.pnlSelect:SetAutoReSizeToChildren(true)
    self.pnlSelect:SetLayoutScheme(true)

    function self.pnlSelect:PaintOnce(w, h)
        draw.BoxRounded(5 ,0, 0, w, h, "181818")
    end

    local x, y = self.pnlSelect:GetGlobalPos()

    local w, h = self:GetSize()

    print(h)

    self.pnlSelect:SetPos(x, y + h * 2)

    if type(self.GenerateSelectBoxContent) == "function" then
        self:GenerateSelectBoxContent(self.pnlSelect)
    end
end

---@param pnlSelect zen.panel.zpanelbase
function PANEL:GenerateSelectBoxContent(pnlSelect) end

function PANEL:PostRemove()
    if IsValid(self.pnlSelect) then self.pnlSelect:Remove() end
end

function PANEL:DoClick()
    self:OpenSelectBox()
end


vgui.Register("zdrop_select", PANEL, "zpanelbase")