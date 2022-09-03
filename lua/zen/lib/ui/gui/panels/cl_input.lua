local ui, gui = zen.Import("ui", "gui")

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