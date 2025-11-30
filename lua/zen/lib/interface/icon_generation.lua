---@meta
icon_generation = icon_generation or {}

local weapon_material = "models/debug/debugwhite"

local wireframe_mat = Material(weapon_material)

-- Generate PNG Data for a given entity class
---@overload fun(weapon_class: string, callback: fun(success: true, png_data: IMaterial))
---@overload fun(weapon_class: string, callback: fun(success: false, err: string))
function icon_generation.generateWeapon(weapon_class, callback, GenerationSettings)
    callback = callback or function(succ, data)
        if !succ then
            print("icon_generation.generateWeapon: Failed to generate icon for weapon class " .. tostring(weapon_class) .. ": " .. tostring(data))
        end
    end

    local SWEP = weapons.GetStored(weapon_class)
    if !SWEP then
        callback(false, "Weapon table not found for class " .. tostring(weapon_class))
        return
    end

    local WorldModel = SWEP.WorldModel
    if type(WorldModel) != "string" or WorldModel == "" then
        callback(false, "WorldModel not defined for weapon class " .. tostring(weapon_class))
        return
    end

    local CSEnt

    if GenerationSettings.CSEnt then
        CSEnt = GenerationSettings.CSEnt
    else
        CSEnt = ents.CreateClientProp(WorldModel)
        if IsValid(CSEnt) then
            SafeRemoveEntityDelayed(CSEnt, 10)

            local phys = CSEnt:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
            end

            -- CSEnt:SetPos(Vector(0,0,0))
            -- CSEnt:SetAngles(AngleRand(-360, 360))

            CSEnt:DrawShadow(false)
            CSEnt:SetupBones()
            CSEnt:SetNoDraw(true)
        end
    end

    GenerationSettings = GenerationSettings or {}

    GenerationSettings.fov = GenerationSettings.fov or 70

    if GenerationSettings.AddFOV then
        GenerationSettings.fov = GenerationSettings.fov - GenerationSettings.AddFOV
    end


    local DEBUG = GenerationSettings.bThisDebug == true
    local SETUP = GenerationSettings.bThisSetup == true
    local DEBUG_OR_SETUP = DEBUG or SETUP


    local render_id = "icon_generation_rt_" .. weapon_class

    local save_path = string.format("es_closet/generated_icon/%s.png", weapon_class)
    png_generation.Generate(save_path, 500, 300, false, function (w, h)

        if !IsValid(CSEnt) then
            hook.Remove("PostRender", render_id)
            callback(false, "Failed to create clientside entity for model " .. tostring(WorldModel))
            return
        end

        local _mins, _maxs = CSEnt:GetRenderBounds()
        local _middle = (_mins + _maxs) / 2

        local wep_origin = CSEnt:GetPos()
        local wep_angles = CSEnt:GetAngles()

        local size = 0
        for i = 1, 3 do
            size = math.max(size, math.abs(_mins[i]) + math.abs(_maxs[i]) + math.abs(_middle[i]))
        end

        size = math.max(size, 50)

        local DefaultRotate = Angle(wep_angles)

        if GenerationSettings.RotateRight then
            DefaultRotate:RotateAroundAxis(DefaultRotate:Right(), GenerationSettings.RotateRight)
        end
        if GenerationSettings.RotateUp then
            DefaultRotate:RotateAroundAxis(DefaultRotate:Up(), GenerationSettings.RotateUp)
        end
        if GenerationSettings.RotateForward then
            DefaultRotate:RotateAroundAxis(DefaultRotate:Forward(), GenerationSettings.RotateForward)
        end

        local custom_middle_position = Vector(wep_origin)
        if GenerationSettings.OffsetRight then
            custom_middle_position = custom_middle_position + wep_angles:Right() * GenerationSettings.OffsetRight
        end
        if GenerationSettings.OffsetUp then
            custom_middle_position = custom_middle_position + wep_angles:Up() * GenerationSettings.OffsetUp
        end
        if GenerationSettings.OffsetForward then
            custom_middle_position = custom_middle_position + wep_angles:Forward() * GenerationSettings.OffsetForward
        end

        local cam_pos = (custom_middle_position) + DefaultRotate:Right() * 50

        local cam_ang = (custom_middle_position - cam_pos):AngleEx(wep_angles:Up())

        local CAM = {}
        CAM.type = "3D"
        CAM.fov = GenerationSettings.fov
        CAM.znear = 1
        CAM.zfar = 1000
        CAM.origin = cam_pos
        CAM.angles = cam_ang
        CAM.subrect = false

        CAM.x = 0
        CAM.y = 0
        CAM.w = w
        CAM.h = h

        CAM.aspect = CAM.w / CAM.h


        cam.Start(CAM)

            render.SuppressEngineLighting( true )
            render.OverrideAlphaWriteEnable(true, true)
            render.SetWriteDepthToDestAlpha( false )

            render.ModelMaterialOverride(wireframe_mat)



            CSEnt:SetMaterial(weapon_material)
            CSEnt:DrawModel()
            CSEnt:FrameAdvance()

            if SETUP then
                render.SetColorMaterial()
                render.DrawSphere(custom_middle_position, 2, 20, 20, Color(0,255,0,200))
                render.DrawWireframeSphere(custom_middle_position, 5, 20, 20, Color(255,0,0,200))
            end

            render.SuppressEngineLighting( false )
            render.OverrideAlphaWriteEnable(false, false)
            render.ModelMaterialOverride(nil)
            render.SetWriteDepthToDestAlpha(true)

        cam.End()

    end, function (material)
        callback(true, material)
    end)

    /*
    hook.Add("PostRender", render_id, function()
        if gui.IsGameUIVisible() then return end

        if !GenerationSettings.bThisDebug then
            hook.Remove("PostRender", render_id)
        end

        if !IsValid(CSEnt) then
            hook.Remove("PostRender", render_id)
            callback(false, "Failed to create clientside entity for model " .. tostring(WorldModel))
            return
        end

        local _mins, _maxs = CSEnt:GetRenderBounds()
        local _middle = (_mins + _maxs) / 2

        local wep_origin = CSEnt:GetPos()
        local wep_angles = CSEnt:GetAngles()

        local size = 0
        for i = 1, 3 do
            size = math.max(size, math.abs(_mins[i]) + math.abs(_maxs[i]) + math.abs(_middle[i]))
        end

        size = math.max(size, 50)

        local DefaultRotate = Angle(wep_angles)

        if GenerationSettings.RotateRight then
            DefaultRotate:RotateAroundAxis(DefaultRotate:Right(), GenerationSettings.RotateRight)
        end
        if GenerationSettings.RotateUp then
            DefaultRotate:RotateAroundAxis(DefaultRotate:Up(), GenerationSettings.RotateUp)
        end
        if GenerationSettings.RotateForward then
            DefaultRotate:RotateAroundAxis(DefaultRotate:Forward(), GenerationSettings.RotateForward)
        end

        local custom_middle_position = Vector(wep_origin)
        if GenerationSettings.OffsetRight then
            custom_middle_position = custom_middle_position + wep_angles:Right() * GenerationSettings.OffsetRight
        end
        if GenerationSettings.OffsetUp then
            custom_middle_position = custom_middle_position + wep_angles:Up() * GenerationSettings.OffsetUp
        end
        if GenerationSettings.OffsetForward then
            custom_middle_position = custom_middle_position + wep_angles:Forward() * GenerationSettings.OffsetForward
        end

        local cam_pos = (custom_middle_position) + DefaultRotate:Right() * 50

        local cam_ang = (custom_middle_position - cam_pos):AngleEx(wep_angles:Up())

        local CAM = {}
        CAM.type = "3D"
        CAM.fov = GenerationSettings.fov
        CAM.znear = 1
        CAM.zfar = 1000
        CAM.origin = cam_pos
        CAM.angles = cam_ang
        CAM.subrect = false

        CAM.x = 0
        CAM.y = 0
        CAM.w = 500
        CAM.h = 300

        CAM.aspect = CAM.w / CAM.h


        local texture = GetRenderTargetEx("icon_generation_rt_",
            CAM.w, CAM.h,
            RT_SIZE_NO_CHANGE, -- Just no touch anything
            MATERIAL_RT_DEPTH_SHARED, -- Alpha use multiply alpha object. If any bags then change to --> MATERIAL_RT_DEPTH_SEPARATE --> MATERIAL_RT_DEPTH_ONLY
            1 + 256, -- Best Combo to enable high-equility screenshot
            0, -- Dont tested
            IMAGE_FORMAT_RGBA16161616 -- Allow use more colors in game. Default game colors is restricted!
        )

        local DEBUG = GenerationSettings.bThisDebug == true
        local SETUP = GenerationSettings.bThisSetup == true
        local DEBUG_OR_SETUP = DEBUG or SETUP


        if DEBUG then
            cam.Start3D()
        else
            render.PushRenderTarget(texture)
            cam.Start(CAM)
            render.Clear(0,0,0, 0, true, true)
        end
                render.SuppressEngineLighting( true )
                render.OverrideAlphaWriteEnable(true, true)
                render.SetWriteDepthToDestAlpha( false )

                render.ModelMaterialOverride(wireframe_mat)



                CSEnt:SetMaterial(weapon_material)
                CSEnt:DrawModel()
                CSEnt:FrameAdvance()

                if DEBUG_OR_SETUP then
                    render.DrawWireframeSphere(custom_middle_position, 2, 20, 20, Color(0,255,0,100), true)
                    render.DrawWireframeSphere(custom_middle_position, 5, 20, 20, Color(255,0,0,100), true)
                end


                if DEBUG then
                    render.DrawWireframeSphere(cam_pos, 5, 4, 4, color_white, true)
                    render.DrawLine(cam_pos, custom_middle_position)

                    -- Draw Cam Angles
                    render.DrawLine(cam_pos, cam_pos + cam_ang:Forward() * 20, Color(255,0,0))
                    render.DrawLine(cam_pos, cam_pos + cam_ang:Right() * 20, Color(0,255,0))
                    render.DrawLine(cam_pos, cam_pos + cam_ang:Up() * 20, Color(0,0,255))
                end

                local PNG
                if !DEBUG then
                    PNG = render.Capture({
                        format = "png",
                        quality = 100,
                        x = 0,
                        y = 0,
                        w = CAM.w,
                        h = CAM.h,
                    })
                end

                render.SuppressEngineLighting( false )
                render.OverrideAlphaWriteEnable(false, false)
                render.ModelMaterialOverride(nil)
                render.SetWriteDepthToDestAlpha(true)
            if DEBUG then
                cam.End()
            else
                cam.End()
                render.PopRenderTarget()
            end

        if !PNG then
            callback(false, "Failed to capture render for weapon class " .. tostring(weapon_class))
        else
            callback(true, PNG)
        end

    end)
    */

end

---@param weapon_class string
---@param callback fun(mat: IMaterial?)
function icon_generation.CreateMaterialForWeapon(weapon_class, callback, GenerationSettings, RefreshIcon)
    local mat_path = "icon_generation/" .. weapon_class .. ".png"

    GenerationSettings = GenerationSettings or {}

    if RefreshIcon then
        GenerationSettings.LifeTime = -1
    end

    icon_generation.generateWeapon(weapon_class, function(succ, mat)
        if succ then
            callback( mat )
        else
            print("Failed to generate icon for weapon class " .. tostring(weapon_class))
            callback(nil)
        end
    end, GenerationSettings)
end

/* Debug
icon_generation.generateWeapon("arccw_go_m1014", function (success, png_data)

end, {
    OffsetForward = 20,
    OffsetRight = 5,
    OffsetUp = -4,
    RotateForward = 0,
    RotateRight = 0,
    RotateUp = 0,
    bThisDebug = true
})

*/

hook.Run("icon_generation_loaded")