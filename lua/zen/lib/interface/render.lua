module("zen")

---@class zen.render
render = _GET("render", render)


local TEXTURE = FindMetaTable("ITexture") --[[@class ITexture]]
local TEXTURE_GetName = TEXTURE.GetName

local format = string.format
local GetRenderTargetEx = GetRenderTargetEx

local render_PushRenderTarget = render.PushRenderTarget
local render_PopRenderTarget = render.PopRenderTarget

local cam_Start2D = cam.Start2D
local cam_End2D = cam.End2D

local render_Clear = render.Clear
local render_ClearDepth = render.ClearDepth

local render_SetWriteDepthToDestAlpha = render.SetWriteDepthToDestAlpha

local render_OverrideBlend = render.OverrideBlend

local BLENDFUNC_MIN = BLENDFUNC_MIN
local BLENDFUNC_ADD = BLENDFUNC_ADD
local BLEND_SRC_COLOR = BLEND_SRC_COLOR
local BLEND_SRC_ALPHA = BLEND_SRC_ALPHA

local surface_SetDrawColor = surface.SetDrawColor
local surface_SetMaterial = surface.SetMaterial
local surface_DrawTexturedRect = surface.DrawTexturedRect

local TEXTURE_PATTERN = "png_generation_texture/%s_%d_%d_%d_%d_%d_%d_%d"
local TEXTURE_MATERIAL_PATTERN = "png_generation_materials/%s"

local TEXTURE_FLAGS = bit.bor(4, 8, 16, 32, 512, 8192, 32768)
local IMAGE_FORMAT = bit.bor(IMAGE_FORMAT_RGBA8888)

local SIZE_MODE = RT_SIZE_NO_CHANGE
local DEPTH_MODE = MATERIAL_RT_DEPTH_SEPARATE
local TEXTURE_FLAGS = TEXTURE_FLAGS
local RT_FLAGS = 0

local function GetTextureRT(textureID, width, height, size_mode, depth_mode, texture_flags, rt_flags, image_format)

    local full_textureID = format(TEXTURE_PATTERN, textureID, width, height, size_mode or SIZE_MODE, depth_mode or DEPTH_MODE, texture_flags or TEXTURE_FLAGS, rt_flags or RT_FLAGS, image_format or IMAGE_FORMAT)

    local texture = GetRenderTargetEx(full_textureID,
        width, height,
        SIZE_MODE,
        DEPTH_MODE,
        TEXTURE_FLAGS,
        RT_FLAGS,
        IMAGE_FORMAT
    )

    return texture, full_textureID
end


local function GetTextureMaterial(textureID, width, height, size_mode, depth_mode, texture_flags, rt_flags, image_format)
    local texture, full_textureID = GetTextureRT(textureID, width, height, size_mode, depth_mode, texture_flags, rt_flags, image_format)

    local MaterialName = format(TEXTURE_MATERIAL_PATTERN, full_textureID)

    local MAT_FROM_TEXTURE = CreateMaterial(MaterialName, "UnlitGeneric", {
        ["$basetexture"] = TEXTURE_GetName(texture),
        ["$ignorez"] = "1",
        ["$translucent"] = "1",
        ["$vertexcolor"] = "1",
        ["$vertexalpha"] = "1",
    })

    return texture, MAT_FROM_TEXTURE
end


-- Create translucent material with translucent mask, example usage below
---@param textureID string -- Just unique name for RenderTarget
---@param width number
---@param height number
---@param bSaveDrawTexture boolean -- Set true to use texture from draw_func, false for colors
---@param draw_func fun(width: number, height: number) -- Don't use X, Y. Only width and height exists
---@param mask_func fun(width: number, height: number) -- Don't use X, Y. Only width and height exists
/*

```
-- Example
local maskMaterial = Material("vgui/notices/generic")
local drawMaterial = Material("effects/ar2_altfire1")

hook.Add("HUDPaint", "DrawTransparentMask", function ()

    local width, height = 128, 128

    local textureRT, materialRT = CreateTranslucentMaterialWithMask("Example8", width, height, true, function ()
        surface.SetMaterial(drawMaterial)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(0,0,width, width)
    end, function ()
        surface.SetMaterial(maskMaterial)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(0,0,width, width)
    end)

    -- Draw input:
    surface.SetMaterial(drawMaterial)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawTexturedRect(0,0,width, width)
    draw.SimpleText("drawMaterial", "Default", width/2, height + 25, color_white, 1, 1)

    surface.SetMaterial(maskMaterial)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawTexturedRect(width,0,width, width)
    draw.SimpleText("maskMaterial", "Default", width + width/2, height + 25, color_white, 1, 1)

    draw.SimpleText("+", "DermaLarge", width, height/2, color_white, 1, 1)

    -- Draw example: 2 - material with translucent
    render.SetMaterial(materialRT)
    render.DrawScreenQuadEx(width*2, 0, width, width)
    draw.SimpleText("=", "DermaLarge", width*2, height/2, color_white, 1, 1)

    draw.SimpleText("materialRT", "Default", width*2 + width/2, height + 25, color_white, 1, 1)

end)
```
*/
function render.CreateTranslucentMaterialWithMask(textureID, width, height, bSaveDrawTexture, draw_func, mask_func)
    local textureID_mask, materialRT_mask = GetTextureMaterial(textureID .. "_mask", width, height, nil, nil, TEXTURE_FLAGS, nil, nil)
    render_PushRenderTarget( textureID_mask )
    cam_Start2D()
        render_Clear( 0, 0, 0, 0 )
        render_ClearDepth( true )

        mask_func(width, height)
    cam_End2D()
    render_PopRenderTarget()



    local textureRT, materialRT = GetTextureMaterial(textureID, width, height)

    render_PushRenderTarget( textureRT )
    cam_Start2D()
        render_Clear( 0, 0, 0, 0 )
        render_ClearDepth( true )

        draw_func(width, height)

        -- Draw the actual mask
        render_SetWriteDepthToDestAlpha( false )
            local blendfunc = bSaveDrawTexture and BLENDFUNC_MIN or BLENDFUNC_ADD
            render_OverrideBlend( true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, blendfunc )
                surface_SetMaterial(materialRT_mask)
                surface_SetDrawColor(255,255,255,255)
                surface_DrawTexturedRect(0,0,width, height)
            render_OverrideBlend( false )
        render_SetWriteDepthToDestAlpha( true )

    cam_End2D()
    render_PopRenderTarget()

    return textureRT, materialRT
end
local _CreateTranslucentMaterialWithMask = render.CreateTranslucentMaterialWithMask

-- Draw with mask_func
---@param textureID string -- Just unique name for RenderTarget
---@param x number
---@param y number
---@param width number
---@param height number
---@param bSaveDrawTexture boolean -- Set true to use texture from draw_func, false for colors
---@param draw_func fun(width: number, height: number) -- Don't use X, Y. Only width and height exists
---@param mask_func fun(width: number, height: number) -- Don't use X, Y. Only width and height exists
/*
```lua
-- Example
local maskMaterial = Material("vgui/notices/generic")
local drawMaterial = Material("effects/ar2_altfire1")

hook.Add("HUDPaint", "example_translucent_mask2", function ()

    DrawTrasparentMaterialWithMask("Example9", 100, 100, 128, 128, true, function (w, h)
        surface.SetMaterial(drawMaterial)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(0,0,w, h)
    end, function (w, h)
        surface.SetMaterial(maskMaterial)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(0,0,w, h)
    end)
end)
```
*/
function render.DrawTrasparentMaterialWithMask(textureID, x, y, width, height, bSaveDrawTexture, draw_func, mask_func)

    local _, materialRT = _CreateTranslucentMaterialWithMask(textureID, width, height, bSaveDrawTexture, function ()
        draw_func(width, height)
    end, function ()
        mask_func(width, height)
    end)

    surface_SetDrawColor(255,255,255)
    surface_SetMaterial(materialRT)
    surface_DrawTexturedRect(x, y, width, height)
end


concommand.Add("example_translucent_mask", function()
    if hook.GetTable()["HUDPaint"] and hook.GetTable()["HUDPaint"]["example_translucent_mask"] then
        hook.Remove("HUDPaint", "example_translucent_mask")
        return
    end

    local table_insert = table.insert
    local math_rad = math.rad
    local math_sin = math.sin
    local math_cos = math.cos
    local surface_DrawPoly = surface.DrawPoly

    -- es_ui draw circle
    local function draw_Circle( x, y, radius, seg, seg_start, seg_end )
        seg_start = seg_start or 0
        seg_end = seg_end or seg

        local cir = {}

        table_insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
        for i = 0, seg do
            if i < seg_start or i > seg_end then continue end
            local a = math_rad( ( i / seg ) * -360 )
            table_insert( cir, { x = x + math_sin( a ) * radius, y = y + math_cos( a ) * radius, u = math_sin( a ) / 2 + 0.5, v = math_cos( a ) / 2 + 0.5 } )
        end

        local a = math_rad( 0 ) -- This is needed for non absolute segment counts
        table_insert( cir, { x = x + math_sin( a ) * radius, y = y + math_cos( a ) * radius, u = math_sin( a ) / 2 + 0.5, v = math_cos( a ) / 2 + 0.5 } )

        draw.NoTexture()
        surface_DrawPoly( cir )
    end



    local maskMaterial = Material("vgui/resource/icon_vac_new")
    local drawMaterial = Material("effects/ar2_altfire1")
    local maskMaterial2 = Material("vgui/notices/generic")

    hook.Add("HUDPaint", "example_translucent_mask", function ()

        local x, y = 0, 50
        local width, height = 128, 128

        -- First Mask

        local _, materialRT = render.CreateTranslucentMaterialWithMask("Example1", width, height, true, function ()
            surface.SetMaterial(drawMaterial)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRect(0, 0,width, width)
        end, function ()
            surface.SetMaterial(maskMaterial)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRect(0, 0,width, width)
        end)

        surface.SetMaterial(drawMaterial)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(x, y,width, width)

        surface.SetMaterial(maskMaterial)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(x + width,y,width, width)

        surface.SetMaterial(materialRT)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(x + width*2,y,width, width)

        draw.SimpleText("drawMaterial1", "Default", x +width/2, y+ height + 25, color_white, 1, 1)
        draw.SimpleText("maskMaterial1", "Default", x + width + width/2, y + height + 25, color_white, 1, 1)
        draw.SimpleText("+", "DermaLarge", x + width, y + height/2, color_white, 1, 1)
        draw.SimpleText("=", "DermaLarge", x + width*2, y + height/2, color_white, 1, 1)
        draw.SimpleText("materialRT1", "Default", x + width*2 + width/2, y + height + 25, color_white, 1, 1)

        -- Second Mask

        local _, materialRT2 = render.CreateTranslucentMaterialWithMask("Example2", width, height, true, function ()
            surface.SetMaterial(materialRT)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRect(0, 0,width, width)
        end, function ()
            surface.SetMaterial(maskMaterial2)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRect(0, 0,width, width)
        end)

        surface.SetMaterial(maskMaterial2)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(x + width*3,y,width, width)


        surface.SetMaterial(materialRT2)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(x + width*4,y,width, width)

        draw.SimpleText("+", "DermaLarge", x + width*3, y + height/2, color_white, 1, 1)
        draw.SimpleText("=", "DermaLarge", x + width*4, y + height/2, color_white, 1, 1)
        draw.SimpleText("maskMaterial2", "Default", x + width*3 + width/2, y + height + 25, color_white, 1, 1)
        draw.SimpleText("materialRT2", "Default", x + width*4 + width/2, y + height + 25, color_white, 1, 1)

        -- Third Mask

        local _, materialRT3 = render.CreateTranslucentMaterialWithMask("Example3", width, height, true, function ()
            draw_Circle(width/2, height/2, width/2, 100, 70 - SysTime() % 1 * 40, 70 + SysTime() % 1 * 10 )
        end, function ()
            surface.SetMaterial(materialRT2)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRect(0, 0,width, width)
        end)

        draw_Circle(x + width*5 + width/2, y + height/2, width/2, 100, 70 - SysTime() % 1 * 40, 70 + SysTime() % 1 * 10 )

        surface.SetMaterial(materialRT3)
        surface.SetDrawColor(255,255,255,255)
        surface.DrawTexturedRect(x + width*6,y,width, width)

        draw.SimpleText("+", "DermaLarge", x + width*5, y + height/2, color_white, 1, 1)
        draw.SimpleText("=", "DermaLarge", x + width*6, y + height/2, color_white, 1, 1)
        draw.SimpleText("draw_Circle", "Default", x + width*5 + width/2, y + height + 25, color_white, 1, 1)
        draw.SimpleText("materialRT3", "Default", x + width*6 + width/2, y + height + 25, color_white, 1, 1)

    end)
end)