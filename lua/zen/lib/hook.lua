do return end
local gmod = gmod
local pairs = pairs
local isfunction = isfunction
local isstring = isstring
local isnumber = isnumber
local isbool = isbool
local IsValid = IsValid
local type = type
local ErrorNoHaltWithStack = ErrorNoHaltWithStack

HOOK_LEVEL_EXTERNAL = -1
HOOK_LEVEL_0 = 0
HOOK_LEVEL_1 = 1
HOOK_LEVEL_2 = 2
HOOK_LEVEL_DEFAULT = 999
HOOK_LEVEL_LAST = 9999

hook = hook or {}
hook.mt_listListeners = hook.mt_listListeners or {}
hook.mt_listHandlers = hook.mt_listHandlers or {}

hook.mt_listListenersIdentifier = hook.mt_listListenersIdentifier or {}
hook.mt_listHandlersIdentifier = hook.mt_listHandlersIdentifier or {}

local clr_red = Color(255,0,0)
local clr_white = Color(255,255,255)


hook.mt_listGmodHooks = hook.mt_listGmodHooks or hook.GetTable()
local Hooks = hook.mt_listGmodHooks

--[[---------------------------------------------------------
    Name: GetTable
    Desc: Returns a table of all hooks.
-----------------------------------------------------------]]
function hook.GetTable()
	return Hooks
end

--[[---------------------------------------------------------
    Name: Add
    Args: string hookName, any identifier, function func
    Desc: Add a hook to listen to the specified event.
-----------------------------------------------------------]]
function hook.Add( event_name, name, func )

	if ( !isstring( event_name ) ) then ErrorNoHaltWithStack( "bad argument #1 to 'Add' (string expected, got " .. type( event_name ) .. ")" ) return end
	if ( !isfunction( func ) ) then ErrorNoHaltWithStack( "bad argument #3 to 'Add' (function expected, got " .. type( func ) .. ")" ) return end

	local notValid = name == nil || isnumber( name ) or isbool( name ) or isfunction( name ) or !name.IsValid or !IsValid( name )
	if ( !isstring( name ) and notValid ) then ErrorNoHaltWithStack( "bad argument #2 to 'Add' (string expected, got " .. type( name ) .. ")" ) return end

	if ( Hooks[ event_name ] == nil ) then
		Hooks[ event_name ] = {}
	end

	Hooks[ event_name ][ name ] = func

end


--[[---------------------------------------------------------
    Name: Remove
    Args: string hookName, identifier
    Desc: Removes the hook with the given indentifier.
-----------------------------------------------------------]]
function hook.Remove( event_name, name )

	if ( !isstring( event_name ) ) then ErrorNoHaltWithStack( "bad argument #1 to 'Remove' (string expected, got " .. type( event_name ) .. ")" ) return end

	local notValid = isnumber( name ) or isbool( name ) or isfunction( name ) or !name.IsValid or !IsValid( name )
	if ( !isstring( name ) and notValid ) then ErrorNoHaltWithStack( "bad argument #2 to 'Remove' (string expected, got " .. type( name ) .. ")" ) return end

	if ( !Hooks[ event_name ] ) then return end

	Hooks[ event_name ][ name ] = nil

end


-- hook.mt_listRun = {}
--[[---------------------------------------------------------
    Name: Run
    Args: string hookName, vararg args
    Desc: Calls hooks associated with the hook name.
-----------------------------------------------------------]]
function hook.Run( name, ... )
    -- if not hook.mt_listRun[name] then
    --     print("hook.Run", name, ...)
    --     hook.mt_listRun[name] = true
    -- end

	return hook.Call( name, gmod and gmod.GetGamemode() or nil, ... )
end


-- hook.mt_listLauch = {}
--[[---------------------------------------------------------
    Name: Run
    Args: string hookName, table gamemodeTable, vararg args
    Desc: Calls hooks associated with the hook name.
-----------------------------------------------------------]]
function hook.Call( name, gm, ... )
    -- if not hook.mt_listLauch[name] then
    --     print("hook.Call", name, ...)
    --     hook.mt_listLauch[name] = true
    -- end
    if hook.mt_listListeners[name] or hook.mt_listHandlers[name] then
        -- print("hook.Call_Launch", name, ...)
        local a, b, c, d, e, f = hook.Launch(name, ...)
        if a != nil then return a, b, c, d, e, f end
    end
	--
	-- Run hooks
	--
	local HookTable = Hooks[ name ]
	if ( HookTable != nil ) then

		local a, b, c, d, e, f;

		for k, v in pairs( HookTable ) do

			if ( isstring( k ) ) then

				--
				-- If it's a string, it's cool
				--
				a, b, c, d, e, f = v( ... )

			else

				--
				-- If the key isn't a string - we assume it to be an entity
				-- Or panel, or something else that IsValid works on.
				--
				if ( IsValid( k ) ) then
					--
					-- If the object is valid - pass it as the first argument (self)
					--
					a, b, c, d, e, f = v( k, ... )
				else
					--
					-- If the object has become invalid - remove it
					--
					HookTable[ k ] = nil
				end
			end

			--
			-- Hook returned a value - it overrides the gamemode function
			--
			if ( a != nil ) then
				return a, b, c, d, e, f
			end

		end
	end

	--
	-- Call the gamemode function
	--
	if ( !gm ) then return end

	local GamemodeFunction = gm[ name ]
	if ( GamemodeFunction == nil ) then return end

	return GamemodeFunction( gm, ... )

end


function hook.Listen(name, identify, level, func)
    assert(func, "func not is exists")

    hook.mt_listListeners[name] = hook.mt_listListeners[name] or {}
    hook.mt_listListenersIdentifier[name] = hook.mt_listListenersIdentifier[name] or {}

    local pairsID = hook.mt_listListenersIdentifier[name][identify]

    if not pairsID then
        pairsID = table.insert(hook.mt_listListeners[name], {})
        hook.mt_listListenersIdentifier[name][identify] = pairsID
    end

    local hook_data = hook.mt_listListeners[name][pairsID]
    hook_data.identify = identify
    hook_data.func = func
    hook_data.level = level
    hook_data.pairsID = pairsID

    hook.SortListen(name)
end

function hook.Handler(name, identify, level, func)
    assert(func, "func not is exists")

    hook.mt_listHandlers[name] = hook.mt_listHandlers[name] or {}
    hook.mt_listHandlersIdentifier[name] = hook.mt_listHandlersIdentifier[name] or {}

    local pairsID = hook.mt_listHandlersIdentifier[name][identify]

    if not pairsID then
        pairsID = table.insert(hook.mt_listHandlers[name], {})
        hook.mt_listHandlersIdentifier[name][identify] = pairsID
    end

    local hook_data = hook.mt_listHandlers[name][pairsID]
    hook_data.identify = identify
    hook_data.func = func
    hook_data.level = level
    hook_data.pairsID = pairsID

    hook.SortHandler(name)
end

function hook.SortListen(name)
    if hook.mt_listListeners[name] then
        table.sort(hook.mt_listListeners[name], function(a, b) return a.level < b.level end)
    end
end

function hook.SortHandler(name)
    if hook.mt_listHandlers[name] then
        table.sort(hook.mt_listHandlers[name], function(a, b) return a.level < b.level end)
    end
end

function hook.Error(err, name, identify)
    MsgC(clr_red, "[Hook-Error] ", clr_white, name, ":", identify, "\n")
    ErrorNoHaltWithStack(err)
end

function hook.Launch(name, ...)
    local a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 = unpack{...}
    if hook.mt_listHandlers[name] then
        for pairsID, data in pairs(hook.mt_listHandlers[name]) do
            local identify = data.identify
            local res, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 = pcall(data.func, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
            if res then
                if a1 != nil then return a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 end 
            else
                hook.Error(a1, name, identify)
            end
        end
    end

    if hook.mt_listListeners[name] then
        for pairsID, data in pairs(hook.mt_listListeners[name]) do
            local identify = data.identify
            local res, err = pcall(data.func, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
            if res == false then
                hook.Error(err, name, identify)
            end
        end
    end

end

function hook.Delete(name, identify)
    hook.DeleteListen(name, identify)
    hook.DeleteHandler(name, identify)
end

function hook.DeleteListen(name, identify)
    if hook.mt_listListeners[name] then
        local pairsID = hook.mt_listListeners[name][identify]
        hook.mt_listListeners[name][pairsID] = nil
        hook.mt_listListenersPairs[name][identify] = nil
    end

    hook.SortListen(name)
end

function hook.DeleteHandler(name, identify)
    if hook.mt_listHandlers[name] then
        local pairsID = hook.mt_listHandlers[name][identify]
        hook.mt_listHandlers[name][pairsID] = nil
        hook.mt_listHandlersPairs[name][identify] = nil
    end

    hook.SortHandler(name)
end

local function run_func(func)
    local res, err = pcall(func)
    if res == false then
        ErrorNoHaltWithStack(err)
    end
end

hook.mbInitialize = hook.mbInitialize or false
hook.mt_listRunOnInitialize = hook.mt_listRunOnInitialize or {}
---@param func function
function hook.OnInitialize(func)
    if hook.mbInitialize then
        run_func(func)
    else
        table.insert(hook.mt_listRunOnInitialize, func)
    end
end

hook.Listen("Initialize", "hook.RunOnInitialize", HOOK_LEVEL_EXTERNAL, function()
    for k, func in pairs(hook.mt_listRunOnInitialize) do
        run_func(func)
        hook.mt_listRunOnInitialize[k] = nil
    end
    hook.mbInitialize = true
end) 