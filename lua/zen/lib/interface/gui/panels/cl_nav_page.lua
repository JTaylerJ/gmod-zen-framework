module("zen")

local PANEL = {} --[[@class zen.panel.nav_page: EditablePanel]]


function PANEL:Init()
    self.NavBarWidth = 150
    self.NavBarButtonHeight = 35

    self.pnlNavigation = self:Add("EditablePanel")
    self.pnlContent = self:Add("EditablePanel")

    self.PagesList = {}
end

---@generic T
---@param class `T`
---@return T   
function PANEL:AddNavigationPanel(class)
    return self.pnlNavigation:Add(class)
end

---@generic T
---@param class `T`
---@return T   
function PANEL:AddContentPanel(class)
    return self.pnlContent:Add(class)
end

---@param text string
---@return DButton
function PANEL:AddNavigationButton(text)
    return self:AddNavigationPanel("DButton")
end

---@param pageID number|string
function PANEL:SelectPage(pageID)
    -- Hide old active page
    if self.SelectedPageID != nil then
        local PAGE = self:GetPage(self.SelectedPageID)
        if PAGE and IsValid(PAGE.pnlContent) then
            PAGE.pnlContent:Hide()
        end
    end

    self.SelectedPageID = pageID

    -- Show new active page
    local PAGE = self:GetPage(self.SelectedPageID)
    if PAGE and IsValid(PAGE.pnlContent) then
        PAGE.pnlContent:Show()
    end
end

---@param pageID string|number
---@param text string
function PANEL:AddPage(pageID, text)
    local PAGE = {}
    PAGE.pnlButton = self:AddNavigationButton(text)
    PAGE.pnlButton:SetText(text)
    PAGE.pnlButton:SetContentAlignment(5)
    PAGE.pnlButton:SetTall(self.NavBarButtonHeight)
    PAGE.pnlButton.DoClick = function()
        self:SelectPage(pageID)
    end
    PAGE.pnlButton:Dock(TOP)
    PAGE.pnlButton:InvalidateParent(true)

    PAGE.pnlContent = self:AddNavigationPanel("EditablePanel")
    PAGE.pnlContent:Dock(FILL)
    PAGE.pnlContent:InvalidateParent(true)
    PAGE.pnlContent:Hide()

    self.PagesList[pageID] = PAGE
    return PAGE
end

function PANEL:GetPage(pageID)
    return self.PagesList[pageID]
end

function PANEL:GetNavigationChildren()
    return self.pnlNavigation:GetChildren()
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.pnlNavigation) and IsValid(self.pnlContent) then
        self.pnlNavigation:SetPos(0, 0)
        self.pnlNavigation:SetSize(self.NavBarWidth, h)

        self.pnlContent:SetPos(self.NavBarWidth, 0)
        self.pnlContent:SetSize(w - self.NavBarWidth, h)
    end
end

gui.RegisterStylePanel("nav_page", PANEL, "EditablePanel")
