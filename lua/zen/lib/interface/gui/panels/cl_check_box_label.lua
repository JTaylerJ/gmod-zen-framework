module("zen", package.seeall)

---@class zen.panel.check_box_label: Panel
local PANEL = {}

function PANEL:Init()
    self.colorBG = Color(40,40,40,255)

    self.pnlText = self:zen_AddStyled("text", {"dock_fill", text_color = color_white, font = "Default"})
    self.pnlCheckBox  = self:zen_AddStyled("check_box")
    self.pnlCheckBox.OnChange = function(this, bNewValue)
        self:OnChange(bNewValue)
    end
end

function PANEL:Toggle()
    self.pnlCheckBox:Toggle()
end

function PANEL:SetValue(value)
    self.pnlCheckBox:SetValue(value)
end

---@param bActive boolean
function PANEL:SetActive(bActive)
    self.pnlCheckBox:SetActive(bActive)
end

function PANEL:SetText(text)
    self.pnlText:SetText(text)
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.pnlCheckBox) then
        local size = math.min(w, h) - 10

        self.pnlCheckBox:SetSize(size, size)
        self.pnlCheckBox:AlignRight(5)
        self.pnlCheckBox:CenterVertical()
    end
end

function PANEL:OnChange(bNewvalue) end

function PANEL:Paint(w, h)
    draw.Box(0,0,w,h,self.colorBG)
end

gui.RegisterStylePanel("check_box_label", PANEL, "EditablePanel")