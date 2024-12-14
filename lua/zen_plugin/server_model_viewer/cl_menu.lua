module("zen", package.seeall)

-- icmd.Register("menu_models", function(QCMD, who, cmd, args, tags)
--     local pnlFrame = gui.CreateStyled("frame", nil, "menu_models")

-- end, {}, {
--     perm = "menu_models",
--     help = "Hello World"
-- })

local function CreatePanel()
    local pnlFrame = gui.CreateFrame("menu_models", "Model Manager")

    local pnlScroll = gui.CreateStyled("scroll_list", pnlFrame, {"dock_fill"})
    local pnlLayout = gui.CreateStyled("layout", pnlScroll, {"dock_fill"})

    local models = file.Find("models/*.mdl", "GAME")

    local wide = pnlScroll:GetWide()
    local items_per_row = 10


    local item_wide = wide/items_per_row

    if models then
        for k, mdl in pairs(models) do
            local pnlModel = gui.CreateStyled("DPanel", pnlLayout)
            pnlModel:SetSize(item_wide, 50)
            -- pnlModel:SetModel("models/" .. mdl)
        end
    end

end
-- CreatePanel()