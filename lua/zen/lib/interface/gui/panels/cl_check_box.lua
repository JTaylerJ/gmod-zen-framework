module("zen")

local PANEL = {} --[[@class zen.panel.check_box: EditablePanel]]

function PANEL:Init()
    self:SetMouseInputEnabled(true)

    self.colorBG = Color(70,70,70,255)
    self.colorActive = Color(255,255,255,255)
    self.bActive = false
    self:SetCursor("hand")
end

function PANEL:OnMousePressed(mouse)
    if mouse == MOUSE_LEFT then
        self:Toogle()
    end

    if mouse == MOUSE_RIGHT then
        mouse:SetActive(false)
    end
end

---@param bActive boolean
function PANEL:SetActive(bActive)
    if self.bActive != bActive then
        self.bActive = bActive
        self:OnChange(bActive)
    end
end

function PANEL:SetValue(value)
    self.bActive = value
end

function PANEL:Toogle()
    self:SetActive(!self.bActive)
end

function PANEL:OnChange(bNewvalue) end

function PANEL:Paint(w, h)
    draw.Box(0,0,w,h,self.colorBG)

    local size = math.min(w, h)*0.5

    if self.bActive then
        draw.Box(w/2-size/2, h/2-size/2, size, size, self.colorActive)
    end
end

gui.RegisterStylePanel("check_box", PANEL, "EditablePanel")