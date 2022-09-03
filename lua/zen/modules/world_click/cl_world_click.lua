local worldclick = zen.worldclick

worldclick.tLastTrace = worldclick.tLastTrace or {}
worldclick.objLastEntity = worldclick.objLastEntity or NULL
function worldclick.CheckHover()
    local tr = worldclick.Trace()

    worldclick.tLastTrace = tr

    if worldclick.objLastEntity != tr.Entity then
        worldclick.objLastEntity = tr.Entity
        hook.Run("zen.worldclick.onHoverEntity", worldclick.objLastEntity, tr)
    end
end

function worldclick.CheckClick(ply, code)
    if code < MOUSE_FIRST or code > MOUSE_LAST then return end
    if not ply:izen_HasPerm("zen.worldclick") then return end
    if not vgui.CursorVisible() then return end

    local hover_pnl = vgui.GetHoveredPanel()
    if IsValid(hover_pnl) and hover_pnl != vgui.GetWorldPanel() and hover_pnl != g_ContextMenu then
        if hover_pnl:IsWorldClicker() then
            hook.Run("zen.worldclick.onPress", code, worldclick.tLastTrace)
            if IsValid(worldclick.objLastEntity) then
                hook.Run("zen.worldclick.onPressEntity", worldclick.objLastEntity, code, worldclick.tLastTrace)
            end
        else
            hook.Run("zen.worldclick.panel.onPress", code)
        end
    else
        hook.Run("zen.worldclick.nopanel.onPress", code)
    end
end
hook.Add( "PlayerButtonPress", "zen.worldclick", worldclick.CheckClick)

function worldclick.CheckUnClick(ply, code)
    if code < MOUSE_FIRST or code > MOUSE_LAST then return end
    if not ply:izen_HasPerm("zen.worldclick") then return end
    if not vgui.CursorVisible() then return end


    local hover_pnl = vgui.GetHoveredPanel()
    if IsValid(hover_pnl) and hover_pnl != vgui.GetWorldPanel() and hover_pnl != g_ContextMenu then
        if hover_pnl:IsWorldClicker() then
            hook.Run("zen.worldclick.onRelease", code, worldclick.tLastTrace)
            if IsValid(worldclick.objLastEntity) then
                hook.Run("zen.worldclick.onReleaseEntity", worldclick.objLastEntity, code, worldclick.tLastTrace)
            end
        else
            hook.Run("zen.worldclick.panel.onRelease", code)
        end
    else
        hook.Run("zen.worldclick.nopanel.onRelease", code)
    end
end
hook.Add( "PlayerButtonUnPress", "zen.worldclick", worldclick.CheckUnClick)