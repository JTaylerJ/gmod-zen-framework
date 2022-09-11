local ui, gui, draw = zen.Import("ui", "gui", "ui.draw")


local color_disable = Color(100,100,100,255)
local color_focus = Color(150,255,150,255)
local color_nofocus = Color(150,150,150,200)
local color_bg = Color(80,80,80,255)
local color_text = Color(255,255,255)

local color_bg_succ = Color(80,125,80, 255)
local color_bg_err = Color(125,80,80, 255)

gui.RegisterStylePanel("input_help", {
    Init = function(self)
        self.sText = "zen.input_help1--------------1\nTello------\n310---"
        self.iFont = 8
        self.iTextAddW = 10
        self.iTextAddH = 10
    end,
    SetPanel = function(self, pnl)
        self.pnlTarget = pnl
    end,
    Paint = function(self, w, h)
        if not self.bActive then return end
        draw.BoxOutlined(1, 0,0,w,h,color_focus)
        draw.Box(0,0,w,h,color_bg)
        draw.TextN(self.sText, self.iFont, w/2, h/2, color_text, 1, 1, COLOR_BLACK)
    end,
    CalcSize = function(self)
        local mw, mh = self.pnlTarget:GetSize()
        local tw, th = ui.GetTextSize(self.sText, self.iFont)
        tw = tw + self.iTextAddW
        th = th + self.iTextAddH

        

        local w, h = math.max(mw, tw), math.max(mh, th)
        return w, h, mw,  mh
    end,
    Think = function(self)
        if not IsValid(self.pnlTarget) then self:Remove() return end

        if self.pnlTarget:HasFocus() or self.pnlTarget:IsHovered() then
            local w, h, ow, oh = self:CalcSize()
            self:SetSize(w, h)

            local x, y = vgui.GetWorldPanel():GetChildPosition(self.pnlTarget)
            
            local x, y = x-w/2+ow/2, y+oh

            self:SetPos(x, y)
            self.bActive = true
        else
            self.bActive = false
        end
    end
}, "EditablePanel", {key_input = false, mouse_input = false, draw_on_top = true}, {})

gui.RegisterStylePanel("input_entry", {
    Init = function(self)
        self.clr_bg = color_bg
        self.iType = TYPE.STRING
        self:SetFont(ui.ffont(6))
        self.pnlHelp = gui.CreateStyled("input_help")
        self.pnlHelp:SetPanel(self)
    end,
    SetType = function(self, type)
        self.iType = type
    end,
    OnChange = function(self, value)
        self:CheckValue()
    end,
    CheckValue = function(self)
        local value = self:GetValue()
        local new_value = util.StringToTYPE(value, self.iType)

        if value == nil or value == "" or value == " " then
            self.clr_bg = color_bg
        else

            if new_value != nil then
                self.clr_bg = color_bg_succ
            else
                self.clr_bg = color_bg_err
            end
        end
    end,
    Paint = function(self, w, h)
        if ( self.m_bBackground ) then

            if ( self:GetDisabled() ) then
                draw.Box(0,0,w,h,self.clr_bg)
                draw.BoxOutlined(1,0,0,w,h,color_disable)
            elseif ( self:HasFocus() ) then
                draw.Box(0,0,w,h,self.clr_bg)
                draw.BoxOutlined(1,0,0,w,h,color_focus)
            else
                draw.Box(0,0,w,h,self.clr_bg)
                draw.BoxOutlined(1,0,0,w,h,color_nofocus)
            end
        end
    
        -- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
        if ( self.GetPlaceholderText && self.GetPlaceholderColor && self:GetPlaceholderText() && self:GetPlaceholderText():Trim() != "" && self:GetPlaceholderColor() && ( !self:GetText() || self:GetText() == "" ) ) then
    
            local oldText = self:GetText()
    
            local str = self:GetPlaceholderText()
            if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
            str = language.GetPhrase( str )
    
            self:SetText( str )
            self:DrawTextEntryText( self:GetPlaceholderColor(), self:GetHighlightColor(), self:GetCursorColor() )
            self:SetText( oldText )
    
            return
        end
    
        self:DrawTextEntryText( color_text, self:GetHighlightColor(), color_text )

        if self.sHelpText and self.sHelpText != "" and (self:IsHovered() or self:HasFocus()) then
            local aw, ah = ui.GetTextSize(self.sHelpText, 6)

            local bx, by = w/2-aw/2, h+1

            draw.Box(bx,by,aw,ah,self.clr_bg)

            local tx, ty = bx + aw/2, by + ah/2

            draw.Text(self.sHelpText, 6, tx, ty, color_text, 1, 1, COLOR.BLACK)
        end
    end,
}, "DTextEntry", {"input", min_size = {25, 25}}, {})

local func_InitBase = function(self, type)
    self.pnl_Key = self:zen_AddStyled("text", {"dock_left"})
    self.pnl_Value = self:zen_AddStyled("input_entry", {"dock_right", "input"})

    if type and self.pnl_Value.SetType then
        self.pnl_Value:SetType(type)
    end
end

local func_get_valueString = function(value, value_type, old_value)
    if value == nil then return old_value end

    value = util.TYPEToString(value, value_type)
    if value == nil then return old_value end

    return value
end

local func_def_input_PerformLayout = function(self, w, h)
    if self.pnl_Key and self.pnl_Value then
        self.pnl_Key:SetWide(w/2 - 10)
        self.pnl_Value:SetWide(w/2 - 10)
    end
end

local fun_def_input_SetText = function(self, value)
    self.pnl_Key:SetText(value)
end

-- Text Input
gui.RegisterStylePanel("input_text", {
    Init = function(self)
        func_InitBase(self, TYPE.STRING)
    end,
    SetValue = function(self, value)
        self.pnl_Value.Result = value
        self.pnl_Value:SetText(tostring(value))
    end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}}, {})

-- Bool Input
gui.RegisterStylePanel("input_bool", {
    Init = function(self)
        func_InitBase(self, TYPE.BOOL)
    end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}, text = "zen.input_bool"}, {})

-- Number Input
gui.RegisterStylePanel("input_number", {
    Init = function(self)
        func_InitBase(self, TYPE.NUMBER)
    end,
    SetValue = function(self, value)
        self.pnl_Value.Result = value
        self.pnl_Value:SetText(tostring(value))
    end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}, text = "zen.input_number"}, {})

-- Arg Input
gui.RegisterStylePanel("input_arg", {
    Init = function(self)
        func_InitBase(self, TYPE.ANY)
        self.pnl_Change = self.pnl_Value:zen_Add("DComboBox", {"dock_fill"})
    end,
    AddChoice = function(self, ...)
        self.pnl_Change:AddChoice(...)
    end,
    ChangeMode = function(self)
        local value = self.pnl_Value.Result
        if value != nil then self.pnl_Change:SetValue(value) end
        self.pnl_Change.OnSelect = function(_, name, value)
            local value = value or name
            if value != nil then self:SetValue(value) end
        end
    end,
    SetValue = function(self, value)
        self.pnl_Value.Result = value
        self.pnl_Value:SetText(tostring(value))
    end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}, text = "zen.input_arg"}, {})

-- Vector Input
gui.RegisterStylePanel("input_vector", {
    Init = function(self)
        func_InitBase(self, TYPE.VECTOR)
    end,
    SetValue = function(self, value)
        self.pnl_Value.Result = value
        self.pnl_Value:SetText(util.TYPEToString(value, TYPE.VECTOR))
    end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}}, {})

-- Color Input
gui.RegisterStylePanel("input_color", {
    Init = function(self)
        func_InitBase(self, TYPE.COLOR)
    end,
    SetValue = function(self, value)
        self.pnl_Value.Result = value
        self.pnl_Value:SetText(util.TYPEToString(value, TYPE.COLOR))
    end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}}, {})

-- Entity Input
gui.RegisterStylePanel("input_entity", {
    Init = function(self)
        func_InitBase(self, TYPE.ENTITY)
    end,
    SetValue = function(self, value) 
        self.pnl_Value.Result = value 
        self.pnl_Value:SetText(tostring(value))
    end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}}, {})