module("zen")


-- Add to sandbox c menu
list.Set( "DesktopWindows", "ZenFrameWork", {

	title		= "Zen Framework",
	icon		= "zen/zen_framework_properties.png",
	init		= function( widgetIcon, window )
        OpenZenMenu()
    end
})

concommand.Add("zen_menu_open", OpenZenMenu)





function OpenZenMenu()
    log("Opening Zen Framework menu")

    if IsValid(zen.PanelZenMenu) then
        zen.PanelZenMenu:Remove()
    end


    zen.PanelZenMenu = gui.CreateFrame("ZenMenu", "Zen FrameWork")

    local NavBar = gui.CreateStyled("nav_page", zen.PanelZenMenu, {
        dock_fill = true
    })

    local WelcomePage = NavBar:AddPage("pageID1", "Welcome")
    local WelcomePage = NavBar:AddPage("pageID2", "DataBase")


    hook.Add("ZEN.UpdateMainMenu", zen.PanelZenMenu, function (s, html)
        OpenZenMenu()
    end)
end

hook.Run("ZEN.UpdateMainMenu")