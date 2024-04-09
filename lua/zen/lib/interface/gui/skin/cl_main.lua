module("zen", package.seeall)

local SKIN = {}

SKIN.Colors = {
    -- button
    buttonBGColor = Color(120, 120, 120),
    buttonText = Color(255,255,255),
    buttonBGText = Color(0,0,0),
    -- frame
    frameBGColor = Color(100, 100, 100),
}

SKIN.Fonts = {
    -- button
    buttonText = ui.font("zen_buttonText", 10, "Roboto")
}

gui.RegisterSkin("Default", SKIN)