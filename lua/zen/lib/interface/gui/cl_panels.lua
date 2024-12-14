module("zen")

gui.RegisterStylePanel("base", {}, "EditablePanel", {}, {})
gui.RegisterStylePanel("frame", {}, "DFrame", {title = "zen.frame", size = {300, 300}}, {"frame"})
gui.RegisterStylePanel("text", {}, "DLabel", {text = "zen.text", content_align = 5, text_color = COLOR.WHITE, font = ui.ffont(18)}, {})

gui.RegisterStylePanel("footer", {}, "EditablePanel", {}, {"footer"})
gui.RegisterStylePanel("header", {}, "EditablePanel", {}, {"header"})
gui.RegisterStylePanel("nav_left", {}, "EditablePanel", {"dock_left", wide = 50}, {})
gui.RegisterStylePanel("nav_right", {}, "EditablePanel", {"dock_right", wide = 50}, {})

gui.RegisterStylePanel("content", {}, "EditablePanel", {"dock_fill"}, {})
gui.RegisterStylePanel("list", {}, "DScrollPanel", {"dock_fill"}, {})

gui.RegisterStylePanel("button", {}, "DButton", {text = "zen.button"}, {})
gui.RegisterStylePanel("entry", {}, "DTextEntry", {font = ui.ffont(18)}, {})

gui.RegisterStylePanel("html", {}, "DHTML", {}, {})

gui.RegisterStylePanel("func_panel", {}, "EditablePanel", {mouse_input = false})


gui.RegisterStylePanel("white_fill", {
    Paint = function(self, w, h)
        draw.Box(0,0,w,h,COLOR.WHITE)
    end
}, "EditablePanel", {"dock_fill"}, {})


gui.RegisterStylePanel("collapse_down", {
    zen_PreInit = function(self)
        self.pnl_Collapse = self:zen_AddStyled("base", {
            "dock_top", tall = 10,
            cc = {
                bCollapse = true,
                Paint = function(self, w, h)
                    if self:IsHovered() then draw.Box(0,0,w,h,COLOR.G) end
                    draw.Text("Collapse", 16, w/2, h/2, COLOR.W, 1, 1, COLOR.BLACK)
                end,
                OnMousePressed = function(self)
                    owner = self:GetParent()
                    self.bCollapse = !self.bCollapse
                    if self.bCollapse then
                        owner:SizeTo(-1, 10, 0.5)
                    else
                        local _, h = owner:ChildrenSize()
                        owner:SizeTo(-1, owner.lH, 0.5)
                    end
                end,
            }
        })
    end,
    PerformLayout = function(self, w, h)
        self.lW = w
        self.lH = math.max(h, self.lH or 0)
    end,
    zen_PostInit = function(self)
        self.lH = math.max(self:GetTall(), self.lH or 0)
        self:SetTall(10)
    end
}, "EditablePanel", {font = ui.ffont(8)}, {})