ihook = ihook or {}

local ErrorNoHaltWithStack = ErrorNoHaltWithStack

-- Add new hook receiver with access to return value
function ihook.Handler(hook_name, hook_id, func, level)
    if hook.Handler then
        hook.Handler(hook_name, hook_id, func, level)
    else
        hook.Add(hook_name, hook_id, func, level)
    end
end

-- Add new hook receiver with no return access
function ihook.Listen(hook_name, hook_id, func, level)
    local no_return_func = function(...) func(...) end
    if hook.Listen then
        hook.Listen(hook_name, hook_id, no_return_func, level)
    else
        hook.Add(hook_name, hook_id, no_return_func, level)
    end
end

-- Run hook with
function ihook.Run(hook_name, ...)
    return hook.Run(hook_name, ...)
end

-- Run hook with pcall
function ihook.RunSecure(hook_name, ...)
    local res, a1, a2, a3, a4, a5 = pcall(ihook.Run, hook_name, ...)
    if res == false then
        ErrorNoHaltWithStack(a1)
    else
        return a1, a2, a3, a4, a5
    end
end

-- Remove hook receiver
function ihook.Remove(hook_name, ...)
    return hook.Remove(hook_name, ...)
end

-- Call hook, analog ihook.Run
function ihook.Call(hook_name, gm, ...)
    return hook.Call(hook_name, gm, ...)
end

-- Get hooks table
function ihook.GetTable()
    return hook.GetTable()
end