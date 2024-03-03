module("zen", package.seeall)

local ui, draw, draw3d = zen.Init("ui", "ui.draw", "ui.draw3d")

function draw3d.GetScreenPosition(vec)
    local sc = vec:ToScreen()
    return sc.visible, sc.x, sc.y
end

function draw3d.Line(pos1, pos2, clr)
    local succ1, x1, y1 = draw3d.GetScreenPosition(pos1)
    local succ2, x2, y2 = draw3d.GetScreenPosition(pos2)

    if succ1 or succ2 then
        draw.Line(x1, y1, x2, y2, clr)
    end
end

function draw3d.Box(pos, x, y, w, h, clr)
    local succ, nx, ny = draw3d.GetScreenPosition(pos)

    if succ then
        draw.Box(nx + x, ny + y, w, h, clr)
    end
end

function draw3d.Texture(pos, mat, x, y, w, h, clr)
    local succ, nx, ny = draw3d.GetScreenPosition(pos)

    if succ then
        draw.Texture(mat, nx + x, ny + y, w, h, clr)
    end
end

function draw3d.TextureRotated(pos, mat, rotate, x, y, w, h, clr)
    local succ, nx, ny = draw3d.GetScreenPosition(pos)

    if succ then
        draw.TextureRotated(mat, rotate, nx + x, ny + y, w, h, clr)
    end
end

function draw3d.Text(pos, text, font, x, y, clr, xalign, yalign, clrbg)
    local succ, nx, ny = draw3d.GetScreenPosition(pos)
    if succ then
        draw.Text(text, font, nx+x, ny+y, clr, xalign, yalign, clrbg)
    end
end

function draw3d.Circle(pos, radius, seg, clr, mat)
    local succ, nx, ny = draw3d.GetScreenPosition(pos)
    if succ then
        draw.Circle(nx, ny, radius, seg, clr, mat)
    end
end