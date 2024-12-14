module("zen")

---@class zen.panel_manager
panel_manager = _GET("panel_manager")


color_delete = Color(255, 0, 0, 100)
function panel_manager.DrawOverlay()
    local pnlHover = vgui.GetHoveredPanel()
    if !IsValid(pnlHover) then return end

    local x, y = vgui.GetWorldPanel():GetChildPosition(pnlHover)
    local w, h = pnlHover:GetSize()

    draw.Box(x, y, w, h, color_delete)

    draw.Text(tostring(pnlHover), "8:Default", 10, 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, COLOR.BLACK)
end

function panel_manager.TryRemovePanel()
    local pnlHover = vgui.GetHoveredPanel()
    if !IsValid(pnlHover) then return end

    pnlHover:Remove()
end


function panel_manager.Enable()
    panel_manager.bEnabled = true

    ihook.Listen("DrawOverlay", "zen.panel_manager.remove", panel_manager.DrawOverlay)
end

function panel_manager.Disable()
    panel_manager.bEnabled = false

    ihook.Remove("DrawOverlay", "zen.panel_manager.remove", panel_manager.DrawOverlay)

end



function panel_manager.CheckActivate(ply, but, in_key, bind_name, char, isKeyFree)
    local bShouldActivate = input.IsKeyPressed(KEY_LCONTROL) and input.IsKeyPressed(KEY_LALT) and input.IsKeyPressed(KEY_LSHIFT)
    if bShouldActivate then
        panel_manager.Enable()
        if panel_manager.bEnabled and but == MOUSE_LEFT then
            panel_manager.TryRemovePanel()
        end
    end
end
ihook.Listen("PlayerButtonPress", "zen.panel_manager.remove", panel_manager.CheckActivate)


function panel_manager.CheckDeactivate(ply, but, in_key, bind_name, char, isKeyFree)
    local bShouldActivate = input.IsKeyPressed(KEY_LCONTROL) and input.IsKeyPressed(KEY_LALT) and input.IsKeyPressed(KEY_LSHIFT)
    if !bShouldActivate then
        panel_manager.Disable()
    end
end
ihook.Listen("PlayerButtonUnPress", "zen.panel_manager.remove", panel_manager.CheckDeactivate)

