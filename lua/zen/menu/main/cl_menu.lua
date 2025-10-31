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


end

