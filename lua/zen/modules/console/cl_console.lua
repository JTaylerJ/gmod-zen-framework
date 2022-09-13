zen.console = zen.console or {}
local iconsole = zen.console
iconsole.INPUT_MODE = false
iconsole.phrase = ""
local _I = table.concat
if IsValid(iconsole.dentry) then iconsole.dentry:Remove() end
iconsole.InitEntry = function()
	if IsValid(iconsole.dentry) then iconsole.dentry:Remove() end
	iconsole.dentry = vgui.Create("DTextEntry")
	iconsole.dentry:ParentToHUD()

	iconsole.dentry:MakePopup()
	iconsole.dentry:RequestFocus()
	iconsole.dentry:SetKeyboardInputEnabled(true)
	iconsole.dentry:SetMouseInputEnabled(false)
	iconsole.dentry:SetAlpha(0)

	iconsole.dentry.AllowInput = function(self, char)
		local new_but = input.GetKeyCode(char)
		ihook.Run("PlayerButtonPress", LocalPlayer(), new_but, char, true)
		ihook.Run("PlayerButtonUnPress", LocalPlayer(), new_but, char, true)
		return true
	end
	iconsole.dentry.OnKeyCode = function(self, new_but)
		ihook.Run("PlayerButtonPress", LocalPlayer(), new_but, "")
		ihook.Run("PlayerButtonUnPress", LocalPlayer(), new_but, "")
	end
end

iconsole.SetPhrase = function(str)
	local len = utf8.len(str)

	if len > 100 then
		str = utf8.sub(str, 1, 100)
	end

    iconsole.phrase = str
    if IsValid(iconsole.dentry) then
        iconsole.dentry:SetText(str)
    end
end

local MODE_DEFAULT = 0
local MODE_CLIENT = 1
local MODE_SERVER = 2

iconsole.mode = MODE_DEFAULT


local KeyReplace = {}
KeyReplace[KEY_SPACE] = " "
KeyReplace[KEY_TAB] = "  "


local KeyStart = KEY_SEMICOLON
local KeyDefault = KEY_D
local KeyServer = KEY_V
local KeyClient = KEY_C

local IS_EPOE=	2^0
local IS_ERROR=	2^1
local IS_PRINT=	2^2
local IS_MSG=   2^3

local IS_MSGN=	2^4
local IS_SEQ=		2^5
local IS_CERROR=	2^6
local IS_MSGC=	2^7

local FlagsWithNewLine = {
	[IS_ERROR] = true,
	[IS_PRINT] = true,
	[IS_MSGN] = true,
	[IS_CERROR] = true,
	[IS_EPOE] = true,
}

iconsole.ServerConsoleLog = iconsole.ServerConsoleLog or ""
function iconsole.AddConsoleLog(flags, str, clr)
	if flags and bit.band(flags, IS_ERROR) == IS_ERROR then
		clr = COLOR.RED
	end
	
	iconsole.ServerConsoleLog = iconsole.ServerConsoleLog .. str
	
	if not flags or FlagsWithNewLine[flags] then
		str = string.gsub(str, "%c", "")
		iconsole.ServerConsoleLog = iconsole.ServerConsoleLog .. "\n"
	end
end

local last_console_log
local last_result
function iconsole.GetConsoleLog(Wide)
	if last_console_log == iconsole.ServerConsoleLog then return last_result end

	last_console_log = iconsole.ServerConsoleLog

	local console_obj = markup.Parse("<font=DebugOverlay>" .. iconsole.ServerConsoleLog .. "</font>", Wide)

	local blocks = console_obj.blocks
	local block_count = #blocks
	local start = math.max(1, block_count - 15)

	local source = ""

	for i = start, block_count do
		local block = blocks[i]

		local add_text = block.text

		source = source .. add_text .. "\n"
	end
	last_result = source

	return last_result
end

iconsole.IsKeyDown = function(but)
    return input.IsKeyDown(but) or input.IsKeyPressed(but)
end

ihook.Listen("PlayerButtonPress", "fast_console_phrase", function(ply, but, char, isCharInput)
	if not iconsole.INPUT_MODE then
		if iconsole.IsKeyDown(KEY_LCONTROL) and iconsole.IsKeyDown(KEY_LALT) and but == KeyStart then
			nt.Send("zen.console.console_status", {"bool"}, {true})
			iconsole.INPUT_MODE = true
			iconsole.SetPhrase("")
			iconsole.InitEntry()

			iconsole.IsEntryValid = IsValid(iconsole.dentry)
    		iconsole.IsEntryInput = iconsole.IsEntryValid and iconsole.dentry:IsEditing()

			if not iconsole.IsEntryInput then
				input.StartKeyTrapping()
			end
		end
		
		return
	end

	if iconsole.IsKeyDown(but) then
		gui.InternalKeyCodePressed(but)
	end

	local trapping_key = input.CheckKeyTrapping()
	but = trapping_key or but

    iconsole.IsEntryValid = IsValid(iconsole.dentry)
    iconsole.IsEntryInput = iconsole.IsEntryValid and iconsole.dentry:IsEditing()
	
	if iconsole.IsKeyDown(KEY_LCONTROL) and iconsole.IsKeyDown(KEY_C) then goto stop end
	if iconsole.IsKeyDown(KEY_ESCAPE) then goto stop end

    if iconsole.IsKeyDown(KEY_LALT) then
		if but == KeyDefault then 
			iconsole.mode = MODE_DEFAULT
			nt.Send("zen.console.console_mode", {"uint8"}, {iconsole.mode})
			goto next
		end
		if but == KeyServer then 
			iconsole.mode = MODE_SERVER
			nt.Send("zen.console.console_mode", {"uint8"}, {iconsole.mode})
			goto next
		end
		if but == KeyClient then 
			iconsole.mode = MODE_CLIENT
			nt.Send("zen.console.console_mode", {"uint8"}, {iconsole.mode})
			goto next
		end
	end

	if iconsole.IsKeyDown(KEY_LCONTROL) then
		if but == KEY_BACKSPACE then
			local args = string.Split(iconsole.phrase, " ")
			local lastargs = #args
			if lastargs > 0 then table.remove(args, lastargs) end
			
            iconsole.SetPhrase(table.concat(args, " "))
			goto next
		end
		if but == KEY_V then
		end
	else
		if but == KEY_BACKSPACE then
			local lenght = utf8.len(iconsole.phrase)
			local new_lenght = math.max(0, lenght-1)
            iconsole.SetPhrase(utf8.sub(iconsole.phrase, 0, new_lenght))
			goto next
		end
	end

	if but == KEY_ENTER then
		ihook.Run("OnFastConsoleCommand", iconsole.phrase, iconsole.mode)
		iconsole.SetPhrase("")
		goto next
	end

	if (iconsole.IsEntryInput and isCharInput) then
		if utf8.len(iconsole.phrase) >= 100 then return end
        iconsole.SetPhrase(iconsole.phrase .. char)
        goto next
    elseif (not iconsole.IsEntryInput) then
		if utf8.len(iconsole.phrase) >= 100 then return end
        local char
        local char_replace = KeyReplace[but]
        if char_replace then
            char = char_replace
        else
            char = input.GetKeyName(but)
            if #char != 1 then goto next end
            if iconsole.IsKeyDown(KEY_LSHIFT) then
                char = string.upper(char) or char
            end
        end

        iconsole.SetPhrase(iconsole.phrase .. char)
		goto next
	end

	
	do return end
	::stop::
	iconsole.INPUT_MODE = false
	nt.Send("zen.console.console_status", {"bool"}, {false})
    if IsValid(iconsole.dentry) then
	    iconsole.dentry:Remove()
    end
	iconsole.SetPhrase("")
	do return end
	::next::
    if not iconsole.IsEntryInput then
	    input.StartKeyTrapping()
    end
end)

ihook.Listen("DrawOverlay", "fast_console_phrase", function()
	if not iconsole.INPUT_MODE then return end
	local w, h = ScrW(), ScrH()
	local SX, SY = 100, 100
	local Wide = w - SX*2
	
	local text = ""
	
	local IA = function(dat)
		text = text .. _I{table.concat(dat)}
	end
    local IAN = function(dat)
		text = text .. _I{table.concat(dat), "\n"}
	end

	IAN{"============================================================================================================================="}

	IAN{"DataTime: " .. os.date("%X - %x", os.time())}
	IAN{"CurTime: " .. math.floor(CurTime())}
	IAN{"SysTime: " .. math.floor(SysTime())}
	IAN{}
	
	
	if iconsole.mode == MODE_DEFAULT then
		IA{"<colour=125,255,125>"}
		IAN{"================="}
		IAN{"=-----=ZEN=-----="}
		IAN{"================="}
		IA{"</colour>"}
	elseif iconsole.mode == MODE_SERVER then
		IA{"<colour=125,125,255>"}
		IAN{"================"}
		IAN{"=---=SERVER=---="}
		IAN{"================"}
		IA{"</colour>"}
	elseif iconsole.mode == MODE_CLIENT then
		IA{"<colour=255,255,125>"}
		IAN{"================"}
		IAN{"=---=CLIENT=---=" }
		IAN{"================"}
		IA{"</colour>"}
	end
	
	IAN{}
	
	IAN{"Welcome to debug console"}
	IAN{"ENTER - To Apply"}
	IAN{"CTRL + C or ESC - To Exit"}
	IAN{"ALT + D for Zen Mode"}
	IAN{"ALT + V for Server Mode"}
	IAN{"ALT + C for Client Mode"}

	local alpha = math.floor(math.abs(math.sin(CurTime() * 5) * 50))

	IAN{}

	IAN{"--- Console ---"}

	do
		text = text .. iconsole.GetConsoleLog(Wide)
    end

	if text[#text] != "\n" then
		IAN{}
	end

	IA{":",iconsole.phrase}
	
	if alpha > 25 then
		IA{"<colour=255,255,255," .. alpha .. ">" .. "|" .. "</colour>"}
	end
	
	IA{""}
	
	local object = markup.Parse(text, Wide)
	local x, y = object:Size()
	
	
	surface.SetDrawColor(iclr.main.r, iclr.main.g, iclr.main.b, 200)
	surface.DrawRect(0,0,w,h)
	
	surface.SetDrawColor(0, 125, 0, 255)
	surface.DrawRect(SX-10,SY-10,x+20,y+20)
	
	surface.SetDrawColor(45, 45, 45, 255)
	surface.DrawRect(SX-5,SY-5,x+10,y+10)

	object:Draw(SX,SY)
end)


ihook.Listen("OnFastConsoleCommand", "fast_console_phrase", function(str, mode)
	if str == "clear" then iconsole.ServerConsoleLog = "" return end
    if not str or str == "" then str = "zen_null" end
	iconsole.AddConsoleLog(IS_MSGN, ":" .. str)
    if mode == MODE_DEFAULT then
        nt.Send("zen.console.command", {"string"}, {str})
    elseif mode == MODE_SERVER then
        nt.Send("zen.console.server_console", {"string"}, {str})
    elseif mode == MODE_CLIENT then
        local args = str:Split(" ")
        local cmd = args[1]
        table.remove(args, 1)
        RunConsoleCommand(args[1], unpack(args))
	end
end)

nt.Receive("zen.console.console_status", {"player", "bool"}, function(ply, bool)
	ply.zen_bConsoleStatus = bool
end)

nt.Receive("zen.console.console_mode", {"player", "uint8"}, function(ply, mode)
	ply.zen_bConsoleMode = mode
end)

local clr_def = Color(125,255,125)
local clr_ser = Color(125,125,255)
local clr_client = Color(255,255,125)

local mode_colors = {
	[MODE_DEFAULT] = clr_def,
	[MODE_CLIENT] = clr_client,
	[MODE_SERVER] = clr_ser,
}

local clr_black = Color(0,0,0)
local clr_blue = Color(0,0,255)
ihook.Listen("PostDrawOpaqueRenderables", "npc_info", function()
	for k, ply in pairs(ents.FindByClass("player")) do
		if ply == LocalPlayer() then continue end
		if not ply.zen_bConsoleStatus then continue end
		local mode = ply.zen_bConsoleMode or MODE_DEFAULT

		local min, max = ply:GetModelBounds()
		local pos = ply:GetPos()
		pos.z = pos.z + max.z * 1.2

		local clr = mode_colors[mode]
		
		--local ang = Angle(CurTime()%10,CurTime()%10,CurTime()%10)
		local ang = (ply:GetPos() - LocalPlayer():EyePos()):Angle()
		ang.p = 0
		ang.r = 90
		ang.y = ang.y - 90
		
		local sc = pos:ToScreen()
		local x, y = sc.x, sc.y
		
		cam.Start3D2D(pos, ang, 0.2)
			--ui.Box(-50,-50,50,50,clr.white)
			draw.SimpleText("In Console", "DebugOverlay", 0, 0, clr, 1,1)
		cam.End3D2D()
	end
end)

nt.Receive("zen.console.message", {"string"}, function(var)
    iconsole.AddConsoleLog(IS_MSGN, var)
end)

if epoe then
	ihook.Listen(epoe.TagHuman, "zen.console_log", function(msg, flags, color)
		iconsole.AddConsoleLog(flags, msg, color)
	end)
end