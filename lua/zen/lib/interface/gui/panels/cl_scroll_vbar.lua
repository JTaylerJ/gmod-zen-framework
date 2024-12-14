module("zen")

local PANEL = {}

function PANEL:Init()
    self:SetZPos(32767)
    self:SetSize(5, 10)
    self:SetMouseInputEnabled(true)
    self:SetCursor("hand")
end

function PANEL:SetScrollPanel(pnl)
    self.bActivated = true
    self.pnlScroll = pnl
    self.pnlCanvas = pnl:GetCanvas()
    self.pnlVBar = pnl.VBar
    self.pnlGrip = pnl.VBar.btnGrip

    self.pnlFather = pnl:GetParent()

    self:SetParent(self.pnlFather)
end

function PANEL:OnMousePressed()
    if !self.bActivated then return end

    self.pnlVBar:Grip()
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawRect(0,0,w,h)
end

function PANEL:Think()
    if !self.bActivated then return end

    if !IsValid(self.pnlFather) or !IsValid(self.pnlScroll) then
        self:Remove()
        return
    end

    local w, h = self.pnlScroll:GetSize()
    local inner_tall = self.pnlCanvas:GetTall()

    if inner_tall >= h then
        self:SetVisible(true)
        self:SetTall(self.pnlGrip:GetTall())

        local vx, vy = self.pnlFather:GetChildPosition(self.pnlGrip)

        local gw, gh = self:GetSize()

        self:SetPos(w-gw, vy)
    else
        self:SetVisible(false)
    end
end

gui.RegisterStylePanel("scroll_vbar", PANEL, "EditablePanel")