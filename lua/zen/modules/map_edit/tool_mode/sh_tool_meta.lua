module("zen", package.seeall)

local ui, gui, draw, map_edit = zen.Init("ui", "gui", "ui.draw", "map_edit")

---@class zen_TOOL
---@field id string
---@field Name string
---@field Description? string
---@field Icon? string
---@field FirstAction? fun(self:zen_TOOL, data:table)
---@field SecondAction? fun(self:zen_TOOL, data:table)
---@field Reload? fun(self:zen_TOOL, data:table)
---@field Init fun(self:zen_TOOL, data:table)
---@field HUDDraw? fun(self:zen_TOOL, data:table)

local META = {}
map_edit.TOOL_META = META

function META:_Setup()

    if self.Init then
        self:Init(self)
    end
end

