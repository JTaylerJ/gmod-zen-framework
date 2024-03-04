module("zen", package.seeall)

local ui, gui, draw, map_edit = zen.Init("ui", "gui", "ui.draw", "map_edit")


ihook.Handler("zen.map_edit.OnButtonPress", "toolmode.Toggle", function(ply, but, in_key, bind_name, vw)
    if bind_name == "+menu_context" then
        map_edit.OpenToolMode()
    end
end)

ihook.Handler("zen.map_edit.OnButtonUnPress", "toolmode.Toggle", function(ply, but, in_key, bind_name, vw)
    if bind_name == "+menu_context" then
        map_edit.CloseToolMode()
    end
end)

function map_edit.OpenToolMode()
    map_edit.IsToolModeEnabled = true

    -- if IsValid(map_edit.pnlToolMenu_Base) then
    --     map_edit.pnlToolMenu_Base:SetVisible(true)
    --     return
    -- end

    map_edit.LoadToolMode()
end

function map_edit.CloseToolMode()
    map_edit.IsToolModeEnabled = false

    if IsValid(map_edit.pnlToolMenu_Base) then
        map_edit.pnlToolMenu_Base:SetVisible(false)
    end
end


map_edit.tToolMode_PanelList = {}
-- Returns the currently selected map edit tool mode.
function map_edit.GetSelectedMode()
    return map_edit.SelectedToolMode
end


function map_edit.LoadToolMode()
    if IsValid(map_edit.pnlToolMenu_Base) then map_edit.pnlToolMenu_Base:Remove() end

    map_edit.pnlToolMenu_Base = gui.Create("EditablePanel", nil, {
        "dock_fill", "popup"
    }, "Tool Menu Settings")

    local pnlModeSelect = gui.Create("EditablePanel", map_edit.pnlToolMenu_Base, {
        wide = 50, "dock_left"
    })
    pnlModeSelect.Paint = function(self, w, h)
        draw.Box(0,0,w,h,COLOR.BLACK)
    end

    local pnlModeSettins = gui.Create("EditablePanel", map_edit.pnlToolMenu_Base, {
        wide = 300, "dock_left"
    })

    local layout = gui.Create("DIconLayout", pnlModeSelect, {"dock_fill"})
    layout:SetSpaceY( 5 )
    layout:SetSpaceX( 5 )


    local function CreateNode(name, icon)
        local new_node = layout:Add("DButton")
        new_node:SetImage(icon)
        new_node:SetText("")
        new_node:SetCursor("hand")
        new_node.Paint = function (self, w, h)
            if self:IsHovered() then
                draw.BoxOutlined(2,0,0,w,h,COLOR.W)
            end
        end
        local tsArray = {}
        local function AddInfo(data) table.insert(tsArray, data) end
        AddInfo{name, 10, 0, 0, COLOR.W}
        new_node:zen_SetHelpTextArray(tsArray)
        new_node:SetSize(50,50)

        return new_node
    end

    local last_node, last_list
    local function CreateMode(name, icon)
        local new_node = CreateNode(name, icon)
        local new_list = gui.Create("EditablePanel", pnlModeSettins, {"dock_fill", visible = false})
        local new_layout = gui.Create("DIconLayout", new_list, {"dock_fill"})

        map_edit.tToolMode_PanelList[name] = {
            node = new_node,
            list = new_list,
            layout = new_layout
        }

        new_node.DoClick = function()
            if last_node and last_list then
                last_node:SetSelected(false)
                last_list:SetVisible(false)
            end

            new_node:SetSelected(true)
            new_list:SetVisible(true)

            last_node = new_node
            last_list = new_list
        end

        return new_node, new_list, new_layout
    end

    CreateMode("Create Entity", "zen/map_edit/ent_create.png")
    CreateMode("Delete Entity", "zen/map_edit/delete.png")
    CreateMode("Create Box", "zen/map_edit/3d_cube.png")
    CreateMode("Hand", "zen/map_edit/hand.png")
    CreateMode("Zone", "zen/map_edit/activity_zone.png")
    CreateMode("Invisible Physics Zone", "zen/map_edit/frame_source.png")
    CreateMode("Perma Props", "zen/map_edit/save_as.png")
end
