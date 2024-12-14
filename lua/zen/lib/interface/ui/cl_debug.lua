module("zen")

local SysTime = SysTime

ui.t_DebugInfo = {}

function ui.DebugInfo(text, delay_time, clr_out, font)
    font = font or 12
    local w, h = ui.GetTextSize(text, font)

    local dat = {
        font = font,
        text = text,
        time_end = SysTime() + (delay_time or 5),
        alpha = 255,
        color_box = Color(80,80,80,150),
        color_box_outline = clr_out or Color(255,255,255,255),
        box_outline_x = 5,
        box_outline_y = 2,
        color = Color(255,255,255),
        color_bg = Color(0,0,0),
        text_w = w,
        text_h = h,
    }

    dat.ReCompute = function()
        local w, h = ui.GetTextSize(dat.text, dat.font)
        dat.text_w = w
        dat.text_h = h
    end

    table.insert(ui.t_DebugInfo, dat)
    return dat
end
zen.DebugInfo = ui.DebugInfo


ihook.Listen("DrawOverlay", "zen.ui.DebugInfo", function()
    local y = 20
    local time = SysTime()
    local x = ScrW() - 20
    for id, dat in pairs(ui.t_DebugInfo) do
        local time_left = dat.time_end - time
        local isExpired = time_left <= 0

        local ax, ay = dat.box_outline_x, dat.box_outline_y

        if isExpired then
            dat.alpha = dat.alpha - 1
            dat.color.a = dat.alpha
            dat.color_bg.a = dat.alpha
            dat.color_box.a = dat.alpha - 100
            dat.color_box_outline.a = dat.alpha
        end

        local isVisible = dat.alpha > 100
        if not isVisible then
            table.remove(ui.t_DebugInfo, id)
            continue
        end

        if isVisible then
            y = y + dat.text_h/2
            local bx, by, bw, bh = x-dat.text_w-ax,y-dat.text_h/2-ay,dat.text_w+ax*2, dat.text_h+ay*2
            draw.Box(bx, by, bw, bh, dat.color_box)
            draw.BoxOutlined(1, bx, by, bw, bh, dat.color_box_outline)
            draw.TextN(dat.text, dat.font, x, y, dat.color, 2, 1, dat.color_bg)
            y = y + dat.text_h/2

            y = y + ay*2 + 2
        end
    end
end)