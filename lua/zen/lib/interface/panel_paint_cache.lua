module("zen")

local PANEL = FindMetaTable("Panel") --[[@class Panel]]

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

local TEXTURE_PATTERN = "panel_paint_cache/%s_%d_%d_%d_%d_%d_%d_%d"
local TEXTURE_MATERIAL_PATTERN = "materials/%s"

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

function PANEL:CachePaint(renderEachDelay)
    assert(type(self.Paint) == "function", "Panel:CachePaint - Panel has no Paint function to cache!")

    self.CachePaintRenderID = self.CachePaintRenderID or string.format("%p", {})
    self.__OriginalPaint = self.__OriginalPaint or self.Paint


    self.__LastCachePaintWidth = self.__LastCachePaintWidth or 0
    self.__LastCachePaintHeight = self.__LastCachePaintHeight or 0

    self.CachePaintRenderDelay = renderEachDelay
    self.CachePaintLastRenderTime = self.CachePaintLastRenderTime or 0

    self.Paint = function(pnl, w, h)
        local bNeedToUpdate = false

        if self.CachePaintMaterial == nil or self.__LastCachePaintWidth ~= w or self.__LastCachePaintHeight ~= h then
            self.__LastCachePaintWidth = w
            self.__LastCachePaintHeight = h
            bNeedToUpdate = true
        end

        if self.CachePaintRenderDelay then
            local curTime = SysTime()
            if curTime - self.CachePaintLastRenderTime >= self.CachePaintRenderDelay then
                self.CachePaintLastRenderTime = curTime
                bNeedToUpdate = true
            end
        end

        if bNeedToUpdate then
            self.CachePaintTexture, self.CachePaintMaterial = GetTextureMaterial(self.CachePaintRenderID, w, h)

            render_PushRenderTarget(self.CachePaintTexture)
            local oldClip = DisableClipping(true)

            cam_Start2D()

            render_Clear(0, 0, 0, 0)
            render_ClearDepth()

            render_SetWriteDepthToDestAlpha(false)

            self:__OriginalPaint(w, h)

            cam_End2D()

            DisableClipping(oldClip)

            render_PopRenderTarget()
        end

        surface_SetDrawColor(255, 255, 255, 255)
        surface_SetMaterial(self.CachePaintMaterial)
        surface_DrawTexturedRect(0, 0, w, h)
    end
end

-- Concommand to create test panel with cached paint
concommand.Add("zen_test_cached_paint_panel", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 600)
    frame:Center()
    frame:SetTitle("Cached Paint Panel Test")
    frame:MakePopup()

    do -- DPanel Example

        local CurrentPanelHolder = vgui.Create("EditablePanel", frame)
        CurrentPanelHolder:Dock(TOP)
        CurrentPanelHolder:SetTall(100)


        local panel = vgui.Create("DPanel", CurrentPanelHolder)
        panel:Dock(LEFT)
        panel.Paint = function(self, w, h)
            -- Example complex paint operation
            for i = 1, 1000 do
                surface.SetDrawColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
                surface.DrawRect(math.random(0, w), math.random(0, h), math.random(1, 50), math.random(1, 50))
            end

            -- Draw current time
            draw.SimpleText(os.date("%H:%M:%S"), "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local cached_panel = vgui.Create("DPanel", CurrentPanelHolder)
        cached_panel:Dock(RIGHT)
        cached_panel.Paint = function(self, w, h)
            -- Example complex paint operation
            for i = 1, 1000 do
                surface.SetDrawColor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
                surface.DrawRect(math.random(0, w), math.random(0, h), math.random(1, 50), math.random(1, 50))
            end

            -- Draw current time
            draw.SimpleText(os.date("%H:%M:%S"), "DermaDefault", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        cached_panel:CachePaint(1)

    end

    do -- DButton Example

        local CurrentButtonHolder = vgui.Create("EditablePanel", frame)
        CurrentButtonHolder:Dock(TOP)
        CurrentButtonHolder:SetTall(100)

        local button = vgui.Create("DButton", CurrentButtonHolder)
        button:Dock(LEFT)
        button:SetText("Regular Button")

        local cached_button = vgui.Create("DButton", CurrentButtonHolder)
        cached_button:Dock(RIGHT)
        cached_button:SetText("Cached Paint Button")
        cached_button:CachePaint()


    end

    do -- DModelPanel Example

        local CurrentModelHolder = vgui.Create("EditablePanel", frame)
        CurrentModelHolder:Dock(TOP)
        CurrentModelHolder:SetTall(100)

        local model_panel = vgui.Create("DModelPanel", CurrentModelHolder)
        model_panel:Dock(LEFT)
        model_panel:SetModel("models/props_phx/huge/tower.mdl")

        local cached_model_panel = vgui.Create("DModelPanel", CurrentModelHolder)
        cached_model_panel:Dock(RIGHT)
        cached_model_panel:SetModel("models/props_phx/huge/tower.mdl")
        cached_model_panel:CachePaint(1)


    end

end)