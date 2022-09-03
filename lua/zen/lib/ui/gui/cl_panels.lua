local ui = zen.Init("ui")
local gui = zen.Init("gui")
local draw = ui.Init("draw")

gui.RegisterStylePanel("base", {}, "EditablePanel", {}, {})
gui.RegisterStylePanel("frame", {}, "DFrame", {title = "zen.frame", size = {300, 300}}, {"frame"})
gui.RegisterStylePanel("text", {}, "DLabel", {text = "zen.text", content_align = 5, text_color = COLOR.WHITE, font = ui.ffont(8)}, {})

gui.RegisterStylePanel("footer", {}, "EditablePanel", {}, {"footer"})
gui.RegisterStylePanel("header", {}, "EditablePanel", {}, {"header"})
gui.RegisterStylePanel("nav_left", {}, "EditablePanel", {"input", "dock_left", wide = 50}, {})
gui.RegisterStylePanel("nav_right", {}, "EditablePanel", {"input", "dock_right", wide = 50}, {})

gui.RegisterStylePanel("content", {}, "EditablePanel", {"dock_fill", "input"}, {})
gui.RegisterStylePanel("list", {}, "DScrollPanel", {"dock_fill", "input"}, {})

local func_def_input_PerformLayout = function(self, w, h)
    if self.pnl_Key and self.pnl_Value then
        self.pnl_Key:SetWide(w/2 - 10)
        self.pnl_Value:SetWide(w/2 - 10)
    end
end

local fun_def_input_SetText = function(self, value)
    self.pnl_Key:SetText(value)
end

gui.RegisterStylePanel("input_text", {
    Init = function(self)
        self.pnl_Key = self:zen_AddStyled("text", {"dock_left"})
        self.pnl_Value = self:zen_Add("DTextEntry", {"dock_right"})
        self.pnl_Value.OnChange = function() self.pnl_Value.Result = self.pnl_Value:GetValue() end
    end,
    SetValue = function(self, value) self.pnl_Value.Result = value end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}}, {})
gui.RegisterStylePanel("input_bool", {
    Init = function(self)
        self.pnl_Key = self:zen_AddStyled("text", {"dock_left"})
        self.pnl_Value = self:zen_Add("DCheckBox", {"dock_right"})
        self.pnl_Value.OnChange = function() self.pnl_Value.Result = tobool(self.pnl_Value:GetValue()) end
    end,
    SetValue = function(self, value) self.pnl_Value.Result = value end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}, text = "zen.input_bool"}, {})
gui.RegisterStylePanel("input_number", {
    Init = function(self)
        self.pnl_Key = self:zen_AddStyled("text", {"dock_left"})
        self.pnl_Value = self:zen_Add("DTextEntry", {"dock_right"})
        self.pnl_Value:SetNumeric(true)
        self.pnl_Value.OnChange = function() self.pnl_Value.Result = self.pnl_Value:GetValue() end
    end,
    SetValue = function(self, value) self.pnl_Value.Result = value end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}, text = "zen.input_number"}, {})
gui.RegisterStylePanel("input_arg", {
    Init = function(self)
        self.pnl_Key = self:zen_AddStyled("text", {"dock_left"})
        self.pnl_Value = self:zen_Add("DComboBox", {"dock_right"})
        self.pnl_Value.OnSelect = function(_, name, value) self.pnl_Value.Result = value != nil and value or name end
        self.AddChoice = self.pnl_Value.AddChoice
    end,
    SetValue = function(self, value) self.pnl_Value.Result = value end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}, text = "zen.input_arg"}, {})
gui.RegisterStylePanel("input_vector", {
    Init = function(self)
        self.pnl_Key = self:zen_AddStyled("text", {"dock_left"})
        self.pnl_Value = self:zen_Add("DTextEntry", {"dock_right"})
        self.pnl_Value.OnEnter = function() self.pnl_Value.Result = util.StringToTYPE(self.pnl_Value:GetValue(), TYPE.VECTOR) end
    end,
    SetValue = function(self, value) self.pnl_Value.Result = value end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}}, {})
gui.RegisterStylePanel("input_color", {
    Init = function(self)
        self.pnl_Key = self:zen_AddStyled("text", {"dock_left"})
        self.pnl_Value = self:zen_Add("DTextEntry", {"dock_right"})
        self.pnl_Value.OnEnter = function() self.pnl_Value.Result = util.StringToTYPE(self.pnl_Value:GetValue(), TYPE.COLOR) end
    end,
    SetValue = function(self, value) self.pnl_Value.Result = value end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}}, {})
gui.RegisterStylePanel("input_entity", {
    Init = function(self)
        self.pnl_Key = self:zen_AddStyled("text", {"dock_left"})
        self.pnl_Value = self:zen_Add("DTextEntry", {"dock_right"})
        self.pnl_Value:SetNumeric(1)
        self.pnl_Value.OnEnter = function() self.pnl_Value.Result = Entity(tonumber(self.pnl_Value:GetValue())) end
    end,
    SetValue = function(self, value) self.pnl_Value.Result = value end,
    GetValue = function(self) return self.pnl_Value.Result end,
    PerformLayout = func_def_input_PerformLayout,
    SetText = fun_def_input_SetText,
}, "EditablePanel", {"input", min_size = {25, 25}}, {})


gui.RegisterStylePanel("button", {}, "DButton", {"input", text = "zen.button"}, {})

gui.RegisterStylePanel("func_panel", {}, "EditablePanel", {key_input = false, mouse_input = false})
gui.RegisterStylePanel("func_save_pos", {
    iNextSave = CurTime(),
    iOwnerLastX = 0,
    iOwnerLastY = 0,
    Think = function(self)
        if self.zen_pnlSavePos and self.iNextSave < CurTime() then
            self.iNextSave = CurTime() + 0.1

            local x, y = self.zen_pnlSavePos:GetPos()
            x = math.floor(x)
            y = math.floor(y)

            if self.iOwnerLastX != x or self.iOwnerLastY != y then
                self.iOwnerLastX = x
                self.iOwnerLastY = y

                local cookie_value = table.concat({x, y}, " ")

                self:SetCookie("zen_LastPos", cookie_value)
            end
        end
    end,
    zen_PostInit = function(self)
        if not IsValid(self.zen_pnlSavePos) then error("self.zen_pnlSavePos not setuped for \"save posing\"") end
        local sPos = self:GetCookie("zen_LastPos")

        if sPos and sPos != "" then
            local pos = string.Split(sPos, " ")
            local x, y = pos[1], pos[2]
            x = tonumber(x)
            y = tonumber(y)
            if x and y then
                local w, h = self.zen_pnlSavePos:GetSize()
                x = math.Clamp(x, 0, ScrW()-w)
                y = math.Clamp(y, 0, ScrH()-h)
                self.zen_pnlSavePos:SetPos(x, y)
            end
        end
    end,
}, "EditablePanel", {
    key_input = false,
    mouse_input = false
}, {})



gui.RegisterStylePanel("white_fill", {
    Paint = function(self, w, h)
        draw.Box(0,0,w,h,COLOR.WHITE)
    end
}, "EditablePanel", {"dock_fill"}, {})