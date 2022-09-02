local ui = zen.Init("ui")
local gui = ui.Init("gui")
local draw = ui.Init("draw")

gui.RegisterStylePanel("frame", {}, "DFrame", {title = "zen.frame", size = {300, 300}}, {"frame"})
gui.RegisterStylePanel("text", {}, "DLabel", {text = "zen.text", content_align = 5, text_color = COLOR.WHITE, font = ui.ffont(8)}, {})

gui.RegisterStylePanel("footer", {}, "EditablePanel", {}, {"footer"})
gui.RegisterStylePanel("header", {}, "EditablePanel", {}, {"header"})
gui.RegisterStylePanel("nav_left", {}, "EditablePanel", {"input", "dock_left", wide = 50}, {})
gui.RegisterStylePanel("nav_right", {}, "EditablePanel", {"input", "dock_right", wide = 50}, {})

gui.RegisterStylePanel("content", {}, "EditablePanel", {"dock_fill", "input"}, {})
gui.RegisterStylePanel("list", {}, "DScrollPanel", {"dock_fill", "input"}, {})

gui.RegisterStylePanel("input_text", {}, "DTextEntry", {"input"}, {})
gui.RegisterStylePanel("input_bool", {}, "DCheckBoxLabel", {"input", text = "zen.input_bool"}, {})
gui.RegisterStylePanel("input_number", {}, "DNumSlider", {"input", text = "zen.input_number"}, {})
gui.RegisterStylePanel("input_arg", {}, "DComboBox", {"input", text = "zen.input_arg"}, {})


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