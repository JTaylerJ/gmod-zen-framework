local map_edit = zen.Init("map_edit")

local gui, ui, draw, draw3d, draw3d2d = zen.Import("gui", "ui", "ui.draw", "ui.draw3d", "ui.draw3d2d")
local GetVectorString, GetAngleString = zen.Import("map_edit.GetVectorString", "map_edit.GetVectorString")

local MODE_DEFAULT = map_edit.RegisterMode("Default")

local clr_white_alpha = Color(255,255,255,100)
hook.Add("zen.map_edit.Render", "paticle_viewer", function(rendermode, priority, vw)
end)

hook.Add("zen.map_edit.OnModeChange", "paticle_viewer", function(vw, old, new)
end)


hook.Add("zen.map_edit.OnButtonPress", "paticle_viewer", function(ply, but, bind, vw)
end)


map_edit.t_ParticleViewers = {}
function map_edit.CreateParticleViewer(pnlContext, vw)
    if not vw.t_ParticleViewers then vw.t_ParticleViewers = {} end

    local particle_id = newproxy()

    vw.t_ParticleViewers[particle_id] = {}
    local tViewer = vw.t_ParticleViewers[particle_id]

    tViewer.EffectData = EffectData()


    local nav = gui.SuperCreate({
        {{
            {"main", "frame"};
            {parent = pnlContext, popup = gui.proxySkip, size = {300, 500}};
            {};
            {
                {"content", "content"};
                {};
                {};
                {
                    {
                        {"items", "list"};
                        {};
                        {};
                        {
                            {{"eff_name", "input_arg"}, {"dock_top", tall = 25, text = "Start"}};
                            {{"var_start", "input_vector"}, {"dock_top", tall = 25, text = "Start"}};
                            {{"var_origin", "input_vector"}, {"dock_top", tall = 25, text = "Origin"}};
                            {{"var_normal", "input_vector"}, {"dock_top", tall = 25, text = "Normal"}};
                            {{"var_color", "input_color"}, {"dock_top", tall = 25, text = "Color"}};
                            {{"var_magnitude", "input_number"}, {"dock_top", tall = 25, text = "Magnitude"}};
                            {{"var_radius", "input_number"}, {"dock_top", tall = 25, text = "Radius"}};
                            {{"var_scale", "input_number"}, {"dock_top", tall = 25, text = "Scale"}};
                            {{"var_entity", "input_entity"}, {"dock_top", tall = 25, text = "Entity"}};
                        };
                    };
                    {{"particle_id", "text"}, {"dock_top"}};
                    {{"but_emit", "button"}, {"dock_bottom", text = "Emit"}}
                }
            }
        }}
    })

    tViewer.nav = nav

    nav.main.OnRemove = function()
        vw.t_ParticleViewers[particle_id] = nil
    end

    nav.but_emit.DoClick = function()
        tViewer.EffectData:SetStart(nav.var_start:GetValue())
        tViewer.EffectData:SetOrigin(nav.var_origin:GetValue())
        tViewer.EffectData:SetNormal(nav.var_normal:GetValue())
        tViewer.EffectData:SetColor(nav.var_color:GetValue())
        tViewer.EffectData:SetMagnitude(nav.var_magnitude:GetValue())
        tViewer.EffectData:SetRadius(nav.var_radius:GetValue())
        tViewer.EffectData:SetScale(nav.var_scale:GetValue())
        tViewer.EffectData:SetEntity(nav.var_entity:GetValue())

        util.Effect(nav.eff_name:GetValue(), tViewer.EffectData)
    end

end


hook.Add("zen.map_edit.GenerateGUI", "paticle_viewer", function(nav, pnlContext, vw)
    nav.items:zen_AddStyled("button", {"dock_top", text = "Create Particle Viewer", cc = {
        DoClick = function()
            map_edit.CreateParticleViewer(pnlContext, vw)
        end
    }})
end)