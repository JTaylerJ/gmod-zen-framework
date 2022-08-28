local KeyCombinations = {}
local KeyCombinationsMass = {}
local KeyPressed = {}

function input.SetupCombination(name, ...)
	KeyCombinations[name] = {}
	for k, v in pairs({...}) do
		KeyCombinations[name][v] = true
	end
	KeyCombinationsMass[name] = 0
end

function input.IsCombinationActive(name)
	return KeyCombinationsMass[name] and KeyCombinationsMass[name] > 0
end

function input.IsKeyPressed(but)
    return KeyPressed[but]
end

hook.Add("PlayerButtonUp", "fast_console_phrase", function(ply, but)
	if KeyPressed[but] then
		KeyPressed[but] = nil
		for name, keys in pairs(KeyCombinations) do
			if keys[but] then
				KeyCombinationsMass[name] = math.max(0, KeyCombinationsMass[name] - 1)
			end
		end
		hook.Run("PlayerButtonUnPress", ply, but)
	end
end)
hook.Add("PlayerButtonDown", "fast_console_phrase", function(ply, but)
	if KeyPressed[but] then return end
	KeyPressed[but] = true
	
	for name, keys in pairs(KeyCombinations) do
		if keys[but] then
			KeyCombinationsMass[name] = KeyCombinationsMass[name] + 1
		end
	end

	hook.Run("PlayerButtonPress", ply, but)
end)

input.SetupCombination("Modificator", KEY_LCONTROL, KEY_RCONTROL, KEY_LSHIFT, KEY_RSHIFT)