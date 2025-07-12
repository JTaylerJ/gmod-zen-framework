-- ZEN Library
---@meta

module("zen", function(MODULE)
    --- Init global vartiable
    MODULE._L = MODULE
    MODULE.zen = MODULE
    MODULE.MODULE = MODULE
    MODULE.Autorun = Autorun

    --- Setup main metatable
    setmetatable(MODULE, {
        __index = _G
    })
end)

zen = zen or {}

zen.bAutoRunEnabled = type(Autorun) == "table" and type(Autorun.require) == "function"

if SERVER then zen.SERVER_SIDE_ACTIVATED = true end

if zen.bAutoRunEnabled then
    zen.SERVER_SIDE_ACTIVATED = false
end

---@param path string
function zen.INC(path)
    assert(type(path) == "string", "path not is string")

    if zen.bAutoRunEnabled then
        return Autorun.require(path)
    else
        local res, a1, a2, a3, a4, a5, a6, a7 = xpcall(include, ErrorNoHaltWithStack, path)
        if res then
            return a1, a2, a3, a4, a5, a6, a7
        end
    end
end

local SERVER = SERVER
local CLIENT_DLL = CLIENT_DLL
local CLIENT = CLIENT

local assert = assert
local type = type


-- Function to include sh_files with from ...
---@param pathes string[]|string
function zen.IncludeSH(pathes)
    if type(pathes) == "string" then pathes = {pathes} end
    assert(type(pathes) == "table", "zen.IncludeSH expects a table of paths")

    for _, path in ipairs(pathes) do
        AddCSLuaFile(path)
        xpcall(zen.INC, ErrorNoHaltWithStack, path)
    end
end

-- Function to include cl_files with from pathes
---@param pathes string[]|string
function zen.IncludeCL(pathes)
    if type(pathes) == "string" then pathes = {pathes} end
    assert(type(pathes) == "table", "zen.IncludeCL expects a table of paths")

    for _, path in ipairs(pathes) do
        AddCSLuaFile(path)
        if CLIENT then
            xpcall(zen.INC, ErrorNoHaltWithStack, path)
        end
    end
end

-- Function to include sv_files with from pathes
---@param pathes string[]|string
function zen.IncludeSV(pathes)
    if !SERVER then return end
    if type(pathes) == "string" then pathes = {pathes} end
    assert(type(pathes) == "table", "zen.IncludeSV expects a table of paths")

    for _, path in ipairs(pathes) do
        xpcall(zen.INC, ErrorNoHaltWithStack, path)
    end
end


if SERVER then
    util.AddNetworkString("zen.ping")
end

if CLIENT_DLL then
    local NetworkID = util.NetworkStringToID("zen.ping")

    if !NetworkID or NetworkID <= 0 then
        print("ZEN: Looks like server don't have ZEN. Enabled client-only mode")
        zen.SERVER_SIDE_ACTIVATED = false
    else
        zen.SERVER_SIDE_ACTIVATED = true
    end
end

concommand.Add("zen_reload", function(ply)
    if SERVER and IsValid(ply) then return end

    zen.IncludeSH("zen/__main__.lua")
end)


zen.IncludeSH("zen/main/main.lua")

------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------


-- Initialize zen submodules
zen.config = {}
zen.modules = {}

-- Alises
_MODULE = zen.modules
_CFG = zen.config

_CFG.colors = _CFG.colors or {}
_COLOR = _CFG.colors
_COLOR.WHITE = color_white

_COLOR.main = Color(0, 255, 0, 255)
_COLOR.console_default = Color(200, 200, 200)

_COLOR.client = Color(255, 125, 0)
_COLOR.server = Color(0, 125, 255)

_CFG.console_space = " "


local _sub = string.sub
_print = _L._print or print
do
    local i, lastcolor
    local MsgC = MsgC
    local IsColor = IsColor
    function print(...)
        local args = {...}
        local count = #args

        local text_color = CLIENT and _COLOR.client or _COLOR.server

        i = 0

        MsgC(text_color, "z> ", _COLOR.console_default)
        if count > 0 then
            while i < count do
                i = i + 1
                local dat = args[i]
                if type(dat) == "string" and _sub(dat, 1, 1) == "#" and lang and lang.L then
                    dat = lang.L(dat)
                end
                if IsColor(dat) then
                    lastcolor = dat
                    continue
                end
                if lastcolor then
                    MsgC(lastcolor, dat)
                    lastcolor = nil
                else
                    MsgC(dat)
                end
            end
        end
        MsgC("\n", _COLOR.WHITE)
    end
end

---@generic T
---@param name zen.`T`
---@param default? any
---@return zen.`T`
function zen.module(name, default)
    assert(type(default) == "table" or default == nil, "`default` not is table")

    if !_MODULE[name] then _MODULE[name] = (default) and (table.Copy(default)) or {} end
    return _MODULE[name]
end
_GET = zen.module


---@param plugin_name string
function zen.IncludePlugin(plugin_name)
    print("include plugin: ", plugin_name)
    return zen.IncludeSH("zen_plugin/" .. plugin_name .. "/browser.lua")
end

zen.IncludeSH("zen/browser.lua")