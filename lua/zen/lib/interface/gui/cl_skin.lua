module("zen")

gui.t_Skins = gui.t_Skins or {}

---Return skin table
---@param name string
---@return table
function gui.GetSkinTable(name)
    return gui.t_Skins[name]
end

---Register skin to skin's table
---@param name string
---@param SKIN table
function gui.RegisterSkin(name, SKIN)
    gui.t_Skins[name] = SKIN

    SKIN.Colors = SKIN.Colors or {}
    SKIN.Fonts = SKIN.Fonts or {}

    return SKIN
end

---Return color from skin
---@param skinName string
---@param colorName string
---@return Color
function gui.GetSkinColor(skinName, colorName)
    local SKIN = gui.GetSkinTable(skinName)
    local clr = SKIN.Colors[colorName]
    assert(clr, "Color not exists in skin!")

    return clr
end

---Return font from skin
---@param skinName string
---@param fontName string
---@return string
function gui.GetSkinFont(skinName, fontName)
    local SKIN = gui.GetSkinTable(skinName)
    local font = SKIN.Fonts[fontName]
    assert(font, "Font not exists in skin!")

    return font
end


---Return color from panel skin
---@param name string
---@return Color
function META.PANEL:zen_GetSkinColor(name)
    local skin = self.zen_s_Skin or "Default"

    return gui.GetSkinColor(skin, name)
end


---Return font from panel skin
---@param name string
---@return string
function META.PANEL:zen_GetSkinFont(name)
    local skin = self.zen_s_Skin or "Default"

    return gui.GetSkinFont(skin, name)
end