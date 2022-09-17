local ui, gui = zen.Init("ui", "gui")

gui.RegisterPreset("base", nil, {})

gui.RegisterPreset("header", "base", {
    "dock_top",
    tall = 50,
})

gui.RegisterPreset("footer", "base", {
    "dock_top",
    tall = 50,
})

gui.RegisterPreset("frame", "base", {
    "center",
    min_size = {150, 100},
})