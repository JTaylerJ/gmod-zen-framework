local map_edit = zen.Init("map_edit")

local ui, draw, draw3d, draw3d2d = zen.Import("ui", "ui.draw", "ui.draw3d", "ui.draw3d2d")
local mat_user = Material("icon16/user_suit.png")

hook.Add("zen.map_edit.Render", "draw_entities", function(rendermode, priority, vw)
	if priority == RENDER_POST then

		if vw.IsDrawPlayers then
			for k, v in pairs(player.GetAll()) do
				local pos = v:EyePos()
				pos.z = pos.z + 15
				local w = draw3d2d.Text(pos, nil, 0.1, true, v:GetName(), 20, 0, 0, COLOR.WHITE, 1, 1, COLOR.BLACK)

				pos.z = pos.z + 5
				draw3d.Texture(pos, mat_user, -10, -10, 20, 20)
			end
		end
	end
end)

hook.Add("zen.map_edit.GenerateGUI", "points", function(nav, pnlContext, vw)

    nav.items:zen_AddStyled("input_bool", {"dock_top", text = "Draw Players", cc = {
        OnChange = function(self, value)
            vw.IsDrawPlayers = value
        end
    }})

end)
