module("zen")

---@class zen.panel.zlabel: zen.panel.zpanelbase
local PANEL = {}

function PANEL:Init()
    self.sFont = "14:DejaVu Sans"
    self.sText = "ExampleText"
    self.cTextColor = color_white
    self.cTextColorBG = color_black
    self:SetCursor("hand")
end

function PANEL:GetText() return self.sText end
function PANEL:SetText(text)
    self.sText = text

    self:CalcPaintOnce_Internal()
end

function PANEL:SetFont(font)
    self.sFont = font
    self:CalcPaintOnce_Internal()
end

---@param w number
---@param h number
function PANEL:PaintOnce(w, h)
    draw.Text(self.sText, self.sFont, w/2, h/2, self.cTextColor, 1, 1, color_black)
end

vgui.Register("zlabel", PANEL, "zpanelbase")