module("zen", package.seeall)

---@class zen_TOOL
---@field id string
---@field Name string
---@field Description? string
---@field Icon? string
---@field ServerAction? fun(self:zen_TOOL, data:table)
---@field Reload? fun(self:zen_TOOL)
---@field Init fun(self:zen_TOOL)
---@field Render? fun(self:zen_TOOL, rendermode:number, priority:number, vw:table)
---@field CallServerAction? fun(self:zen_TOOL, data:table)
---@field OnButtonPress? fun(self:zen_TOOL, data:table)
---@field OnButtonUnPress? fun(self:zen_TOOL, data:table)
---@field OnDie? fun(self:zen_TOOL) Called when the tool data is destroyed
---@field OnCreated? fun(self:zen_TOOL) Called when the tool copied to use!
---@field DisableHooks? fun(self:zen_TOOL) Use can use it to safety disable your hooks
---@field EnableHooks? fun(self:zen_TOOL) Use can use it to safety enabled your hooks
---@field OnActivate? fun(self:zen_TOOL) Called when the tool is selected
---@field OnDeactivate? fun(self:zen_TOOL) Called when the tool is deselected

map_edit.TOOL_META = map_edit.TOOL_META or {}

local META = map_edit.TOOL_META
META.__index = META

function META:CallServerAction(data)
    assertTable(data)

    nt.Send("map_edit.tool_mode.ServerAction", {"string", "table"}, {self.id, data})
end

function META:_Die()
    if self.OnDie then self:OnDie() end
    if self.DisableHooks then self:DisableHooks() end
end

function META:_Created()
    if self.OnCreated then self:OnCreated() end
end

function META:_Selected()
    if self.EnableHooks then self:EnableHooks() end
    if self.OnActivate then self:OnActivate() end
end

function META:_UnSelected()
    if self.DisableHooks then self:DisableHooks() end
    if self.OnDeactivate then self:OnDeactivate() end
end