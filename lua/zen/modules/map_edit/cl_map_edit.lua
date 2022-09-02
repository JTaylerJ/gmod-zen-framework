local map_edit = zen.Init("map_edit")

map_edit.hookName = "zen.map_edit"
map_edit.ViewData = {}
map_edit.t_Panels = map_edit.t_Panels or {}
map_edit.t_Positions = {}
local viewdata = map_edit.ViewData

local ui, draw, draw3d, draw3d2d = zen.Import("ui", "ui.draw", "ui.draw3d", "ui.draw3d2d")

local mat_user = Material("icon16/user_suit.png")

local lastOrigin, lastAngles, lastTrace
local nextOriginUpdate = CurTime()
local hoverEntity, hoverOrigin
local nearPosition, nearPositionID

local MODE_DEFAULT = 0
local MODE_EDIT_POINT = 1

local hoverPadPosition_4
local hoverPadPosition_6
local hoverPadPosition_8
local hoverPadPosition_2

viewdata.mode = MODE_DEFAULT

ui.CreateFont("map_edit.Button", 6, "Roboto", {underline = true, extended = 300})

local clr_white_alpha = Color(255,255,255,100)


local function getAngleString(ang)
	return table.concat({math.Round(ang.p, 2), math.Round(ang.y, 2), math.Round(ang.r, 2)}, " ")
end

local function getVectorString(vec)
	return table.concat({math.Round(vec.x, 2), math.Round(vec.y, 2), math.Round(vec.z, 2)}, " ")
end

function map_edit.Render(mode, priority)
	local origin, normal = util.GetPlayerTraceSource(nil)
	lastTrace = util.TraceLine({start = origin, endpos = origin + normal * 1024})

	hoverEntity = lastTrace.Entity
	hoverOrigin = lastTrace.HitPos

	local hitpos = lastTrace.HitPos

	if mode == RENDER_3D and priority == RENDER_POST then
		local y = 0
		y = y - 5
		draw3d2d.Text(hitpos, nil, 0.1, true, "v", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)

		y = y - 35
		draw3d2d.Text(hitpos, nil, 0.1, true, getVectorString(hitpos), 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)

		local ent = lastTrace.Entity

		if IsValid(ent) then

			y = y - 35
			draw3d2d.Text(hitpos, nil, 0.1, true, tostring(ent:GetClass()), 20, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)

			local name = ent.GetName and ent:GetName()

			if name then
				y = y - 35
				draw3d2d.Text(hitpos, nil, 0.1, true, tostring(ent:GetName()), 20, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
			end
		end

		if viewdata.mode == MODE_EDIT_POINT then
			y = y - 50
			if viewdata.edit_point then
				draw3d2d.Text(hitpos, nil, 0.1, true, "---- MODE: Point Edit (" .. viewdata.edit_point .. ") ----", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
			else
				draw3d2d.Text(hitpos, nil, 0.1, true, "---- MODE: Point Edit ----", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
			end
			
			y = y - 35
			draw3d2d.Text(hitpos, nil, 0.1, true, "Default Mode", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
			draw3d2d.Text(hitpos, nil, 0.1, true, "IN_RELOAD", "map_edit.Button", 0, y-15, COLOR.WHITE, 1, 1, COLOR.BLUE)

			if viewdata.edit_point then
				y = y - 40
				draw3d2d.Text(hitpos, nil, 0.1, true, "Setup New Point", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
				draw3d2d.Text(hitpos, nil, 0.1, true, "IN_ATTACK", "map_edit.Button", 0, y-15, COLOR.WHITE, 1, 1, COLOR.BLUE)
			else
				y = y - 40
				draw3d2d.Text(hitpos, nil, 0.1, true, "Add Point", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
				draw3d2d.Text(hitpos, nil, 0.1, true, "IN_ATTACK", "map_edit.Button", 0, y-15, COLOR.WHITE, 1, 1, COLOR.BLUE)
			end

			if viewdata.edit_point then
				y = y - 40
				draw3d2d.Text(hitpos, nil, 0.1, true, "Cancel Editing ", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
				draw3d2d.Text(hitpos, nil, 0.1, true, "IN_ATTACK2/IN_USE", "map_edit.Button", 0, y-15, COLOR.WHITE, 1, 1, COLOR.BLUE)
			else
				if nearPositionID then
					y = y - 40
					local add_text = nearPositionID and "(" .. nearPositionID .. ")" or "(unknown)"
					draw3d2d.Text(hitpos, nil, 0.1, true, "Delete Near Position " .. add_text, 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
					draw3d2d.Text(hitpos, nil, 0.1, true, "IN_ATTACK2", "map_edit.Button", 0, y-15, COLOR.WHITE, 1, 1, COLOR.BLUE)

					y = y - 40
					draw3d2d.Text(hitpos, nil, 0.1, true, "Edit Point " .. add_text, 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
					draw3d2d.Text(hitpos, nil, 0.1, true, "IN_USE", "map_edit.Button", 0, y-15, COLOR.WHITE, 1, 1, COLOR.BLUE)

					local clr = input.IsButtonPressedIN(IN_WALK) and COLOR_BLUE or COLOR_WHITE

					y = y - 40
					draw3d2d.Text(hitpos, nil, 0.1, true, "Start With Point " .. add_text, 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)
					draw3d2d.Text(hitpos, nil, 0.1, true, "IN_WALK + IN_USE", "map_edit.Button", 0, y-15, COLOR.WHITE, 1, 1, clr)
				end
			end
		end
	end

	if priority == RENDER_POST then

		if viewdata.IsDrawPlayers then
			for k, v in pairs(player.GetAll()) do
				local pos = v:EyePos()
				pos.z = pos.z + 15
				local w = draw3d2d.Text(pos, nil, 0.1, true, v:GetName(), 20, 0, 0, COLOR.WHITE, 1, 1, COLOR.BLACK)

				pos.z = pos.z + 5
				draw3d.Texture(pos, mat_user, -10, -10, 20, 20)
			end
		end
	end


	if mode == RENDER_3D and priority == RENDER_POST then
		local tDistance = {}

		local minDistance
		for k, pos in pairs(map_edit.t_Positions) do
			local distance = math.floor(pos:DistToSqr(hoverOrigin))
			if distance < 10000 then
				tDistance[distance] = k

				if not minDistance then
					minDistance = distance
				else
					minDistance = math.min(minDistance, distance)
				end
			end
		end

		nearPositionID = tDistance[minDistance]
		nearPosition = map_edit.t_Positions[nearPositionID]

		for k, pos in pairs(map_edit.t_Positions) do

			if viewdata.edit_point == k then
				pos = hoverOrigin
			end

			local y = 0
			y = y - 5
			draw3d2d.Text(pos, nil, 0.1, true, "v", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)

			y = y - 35
			draw3d2d.Text(pos, nil, 0.1, true, getVectorString(pos), 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)

			y = y - 35
			draw3d2d.Text(pos, nil, 0.1, true, k, 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLACK)

			if nearPositionID == k then
				y = y - 35
				draw3d2d.Text(pos, nil, 0.1, true, "NearPoint", 10, 0, y, COLOR.WHITE, 1, 1, COLOR.BLUE)


				if viewdata.mode == MODE_EDIT_POINT then
					local middle = (pos + hoverOrigin)*0.5

					render.DrawLine(pos, hoverOrigin, COLOR.BLUE, true)
				end
			end



			local next_k = next(map_edit.t_Positions, k)
			next_k = next_k or 1
			nextpos = map_edit.t_Positions[next_k]

			if viewdata.edit_point and viewdata.edit_point == next_k then
				nextpos = hoverOrigin
			end

			render.DrawLine(pos, nextpos, COLOR.WHITE, true)
		end
	end

	if viewdata.mode == MODE_EDIT_POINT and viewdata.edit_point == nil then
		local iPoints = #map_edit.t_Positions

		if input.IsButtonPressedIN(IN_WALK) then
			local hitNormal = lastTrace.HitNormal
			local hitAngle = hitNormal:Angle()
			local up = hitAngle:Up()
			local down = -up
			local right = hitAngle:Right()
			local left = -right

			local trace_up = util.TraceLine({start = hoverOrigin, endpos = hoverOrigin + up*100})
			local trace_down = util.TraceLine({start = hoverOrigin, endpos = hoverOrigin + down*100})
			local trace_right = util.TraceLine({start = hoverOrigin, endpos = hoverOrigin + right*100})
			local trace_left = util.TraceLine({start = hoverOrigin, endpos = hoverOrigin + left*100})

			local trace_up_back = util.TraceLine({start = trace_up.HitPos - hitNormal, endpos = trace_up.StartPos - hitNormal})
			local trace_down_back = util.TraceLine({start = trace_down.HitPos - hitNormal, endpos = trace_down.StartPos - hitNormal})
			local trace_right_back = util.TraceLine({start = trace_right.HitPos - hitNormal, endpos = trace_right.StartPos - hitNormal})
			local trace_left_back = util.TraceLine({start = trace_left.HitPos - hitNormal, endpos = trace_left.StartPos - hitNormal})

			if mode == RENDER_2D then
				draw3d.Line(hoverOrigin, hoverOrigin + up * 2, clr_white_alpha)
				draw3d.Line(hoverOrigin, hoverOrigin + down * 2, clr_white_alpha)
				draw3d.Line(hoverOrigin, hoverOrigin + right * 2, clr_white_alpha)
				draw3d.Line(hoverOrigin, hoverOrigin + left * 2, clr_white_alpha)


				local up_hitpos = (trace_up.Hit) and (trace_up.HitPos) or (trace_up_back.Hit and trace_up_back.HitPos != trace_up_back.StartPos and trace_up_back.HitPos + hitNormal or nil)
				local down_hitpos = (trace_down.Hit) and (trace_down.HitPos) or (trace_down_back.Hit and trace_down_back.HitPos != trace_down_back.StartPos and trace_down_back.HitPos + hitNormal or nil)
				local right_hitpos = (trace_right.Hit) and (trace_right.HitPos) or (trace_right_back.Hit and trace_right_back.HitPos != trace_right_back.StartPos and trace_right_back.HitPos + hitNormal or nil)
				local left_hitpos = (trace_left.Hit) and (trace_left.HitPos) or (trace_left_back.Hit and trace_left_back.HitPos != trace_left_back.StartPos and trace_left_back.HitPos + hitNormal or nil)


				if up_hitpos then
					draw3d.Line(hoverOrigin, up_hitpos, clr_white_alpha)
				end

				if down_hitpos then
					draw3d.Line(hoverOrigin, down_hitpos, clr_white_alpha)
				end

				if right_hitpos then
					draw3d.Line(hoverOrigin, right_hitpos, clr_white_alpha)
				end

				if left_hitpos then
					draw3d.Line(hoverOrigin, left_hitpos, clr_white_alpha)
				end


				hoverPadPosition_8 = up_hitpos
				hoverPadPosition_2 = down_hitpos
				hoverPadPosition_6 = left_hitpos
				hoverPadPosition_4 = right_hitpos
			end
		end
		

		if iPoints == 1 then
			local firstPos = map_edit.t_Positions[1]
			local firstDir = (hoverOrigin - firstPos):Angle():Forward()

			local add = math.min(firstPos:Distance(hoverOrigin) or 10, 10)

			if mode == RENDER_2D then
				draw3d.Line(hoverOrigin, firstPos, clr_white_alpha)

				draw3d.Line(hoverOrigin, hoverOrigin + firstDir * -add, COLOR.WHITE)
				draw3d.Line(firstPos, firstPos + firstDir * add, COLOR.WHITE)
			end
		elseif iPoints > 1 then
			local firstPos = map_edit.t_Positions[1]
			local lastPos = map_edit.t_Positions[iPoints]

			local add_first = math.min(firstPos:Distance(hoverOrigin) or 10, 20)
			local add_last = math.min(lastPos:Distance(hoverOrigin) or 10, 20)


			local firstAng = (hoverOrigin - firstPos):Angle()
			local lastAng = (hoverOrigin - lastPos):Angle()

			local firstDir = firstAng:Forward()
			local lastDir =  lastAng:Forward()

			local firstMinPos = hoverOrigin + firstDir * -add_first
			local lastMinPos = hoverOrigin + lastDir * -add_last

			if mode == RENDER_2D then
				draw3d.Line(hoverOrigin, firstPos, clr_white_alpha)
				draw3d.Line(hoverOrigin, lastPos, clr_white_alpha)

				draw3d.Line(hoverOrigin, firstMinPos, COLOR.RED)
				draw3d.Line(hoverOrigin, lastMinPos, COLOR.BLUE)

				draw3d.Line(firstPos, firstPos + firstDir * add_first, COLOR.RED)
				draw3d.Line(lastPos, lastPos + lastDir * add_last, COLOR.BLUE)
			end
			if mode == RENDER_3D then
				local mid = (firstMinPos + lastMinPos)*0.5
				local new_ang = firstAng - lastAng

				draw3d2d.Text((firstMinPos + Vector(2,2,2)), nil, 0.1, true, getAngleString(firstAng), 8, 0, 0, COLOR.RED, 1, 1, COLOR.BLACK)
				draw3d2d.Text((lastMinPos + Vector(-2,-2,-2)), nil, 0.1, true, getAngleString(lastAng), 8, 0, 0, COLOR.BLUE, 1, 1, COLOR.BLACK)

				local tbl = {}

				if new_ang.p != 0 then
					table.insert(tbl, math.Round(math.abs(new_ang.p), 2))
				end

				if new_ang.y != 0 then
					table.insert(tbl, math.Round(math.abs(new_ang.y), 2))
				end

				if new_ang.r != 0 then
					table.insert(tbl, math.Round(math.abs(new_ang.r), 2))
				end

				local ang_str = table.concat(tbl, " ")
				draw3d2d.Text(mid, nil, 0.1, true, ang_str, 8, 0, 0, COLOR.WHITE, 1, 1, COLOR.BLACK)
			end
		end
	end
end


function map_edit.HUDShouldDraw()
	return false
end

function map_edit.GenerateGUI(pnlContext, mark_panels)
	local pnlFrame = pnlContext:Add("DFrame")
	pnlFrame:SetSize(300, 400)
	pnlFrame:SetPos(100, 100)
	pnlFrame:SetSizable(true)
	pnlFrame:SetTitle("MapEdit")
	pnlFrame:SetMouseInputEnabled(true)
	table.insert(mark_panels, pnlFrame)

	local pnlList = pnlFrame:Add("EditablePanel")
	pnlList:Dock(FILL)
	pnlList:InvalidateParent(true)


	local addButton = function(tall)
		local pnlButton = pnlList:Add("EditablePanel")
		pnlButton:SetTall(tall or 50)
		pnlButton:Dock(TOP)
		pnlButton:InvalidateParent(true)

		return pnlButton
	end

	do
		local pnlDrawEntities = addButton(20)
		local pnl = pnlDrawEntities:Add("DCheckBoxLabel")
		pnl:SetText("DrawPlayers")
		pnl:Dock(FILL)
		pnl.OnChange = function(self, value)
			viewdata.IsDrawPlayers = value
		end
	end

	do
		local pnlDrawEntities = addButton(20)
		local pnlButton = pnlDrawEntities:zen_AddStyled("button", {"dock_fill", text = "EmitSound"})
		pnlButton.DoClick = function(self)
			EmitSound("garrysmod/save_load1.wav", hoverOrigin, 0)
		end
	end

	do
		local pnlDrawEntities = addButton(20)
		local pnlButton = pnlDrawEntities:zen_AddStyled("button", {"dock_fill", text = "Edit Points"})
		pnlButton.DoClick = function(self)
			viewdata.mode = MODE_EDIT_POINT
		end
	end
end


function map_edit.Toggle()
	local ply = LocalPlayer()
	map_edit.IsActive = not map_edit.IsActive

	if not map_edit.IsActive then
		hook.Remove("CalcView", map_edit.hookName)
		hook.Remove("StartCommand", map_edit.hookName)
		hook.Remove("PlayerSwitchWeapon", map_edit.hookName)
		hook.Remove("Render", map_edit.hookName)
		hook.Remove("HUDShouldDraw", map_edit.hookName)

		for k, v in pairs(map_edit.t_Panels) do
			if IsValid(v) then v:Remove() end
			map_edit.t_Panels[k] = nil
		end

		map_edit.t_Positions = {}
		map_edit.ViewData = {}
		viewdata = map_edit.ViewData
		nt.Send("map_edit.status", {"bool"}, {false})
		return
	end

	map_edit.GenerateGUI(g_ContextMenu, map_edit.t_Panels)


	hook.Add("CalcView", map_edit.hookName, map_edit.CalcView)
	hook.Add("StartCommand", map_edit.hookName, map_edit.StartCommand)
	hook.Add("PlayerSwitchWeapon", map_edit.hookName, map_edit.PlayerSwitchWeapon)
	hook.Add("Render", map_edit.hookName, map_edit.Render)
	hook.Add("HUDShouldDraw", map_edit.hookName, map_edit.HUDShouldDraw)

	nt.Send("map_edit.status", {"bool"}, {true})

	viewdata.Angle = ply:EyeAngles()
	viewdata.Origin = ply:EyePos()
	viewdata.StartAngles = ply:EyeAngles()
end

function map_edit.PlayerSwitchWeapon(ply, wep)
	return true
end

function map_edit.CalcView(ply, origin, angles, fov, znear, zfar)
	local new_view = {
		origin = viewdata.Origin,
		angles = viewdata.Angle,
		fov = 80,
		drawviewer = true,
	}

	return new_view
end

function map_edit.StartCommand(ply, cmd)
	local add_x = -(cmd:GetMouseX() * 0.03)
	local add_y = -(cmd:GetMouseY() * 0.03)

	if add_x != 0 then
		if viewdata.Angle.p < -90 or viewdata.Angle.p > 90 then
			viewdata.Angle.y = viewdata.Angle.y - add_x
		else
			viewdata.Angle.y = viewdata.Angle.y + add_x
		end
	end

	if add_y != 0 then
		viewdata.Angle.p = viewdata.Angle.p - add_y
	end


	viewdata.Angle:Normalize()
	viewdata.Angle.r = 0

	local speed = 2
	if cmd:KeyDown(IN_SPEED) then
		speed = 10
	elseif cmd:KeyDown(IN_DUCK) then
		speed = 0.1
	end

	local add_origin = Vector()

	if cmd:KeyDown(IN_FORWARD) then
		add_origin = add_origin + viewdata.Angle:Forward() * speed
	end

	if cmd:KeyDown(IN_MOVERIGHT) then
		add_origin = add_origin + viewdata.Angle:Right() * speed
	end

	if cmd:KeyDown(IN_BACK) then
		add_origin = add_origin - viewdata.Angle:Forward() * speed
	end

	if cmd:KeyDown(IN_MOVELEFT) then
		add_origin = add_origin - viewdata.Angle:Right() * speed
	end

	if cmd:KeyDown(IN_JUMP) then
		add_origin = add_origin + Vector(0,0,1) * speed
	end

	viewdata.Origin = viewdata.Origin + add_origin

	-- ply:SetNetworkOrigin(viewdata.Origin)
	-- ply:SetPos(viewdata.Origin)

	if lastOrigin != viewdata.Origin and nextOriginUpdate <= CurTime() then
		nextOriginUpdate = nextOriginUpdate + 0.5
		lastOrigin = viewdata.Origin
		nt.Send("map_edit.update.pos", {"vector"}, {lastOrigin})
	end

	if lastAngles != viewdata.Angle then
		lastAngles = viewdata.Angle
	end

	cmd:SetImpulse(0)
	cmd:ClearButtons()
	cmd:ClearMovement()
	cmd:SetViewAngles(viewdata.StartAngles)
end

hook.Add("PlayerButtonPress", "zen.map_edit", function(ply, but)
	if input.IsKeyDown(KEY_LCONTROL) and input.IsKeyDown(KEY_LALT) and but == KEY_APOSTROPHE then
		map_edit.Toggle()
	end

	local bind = input.GetButtonIN(but)

	if not map_edit.IsActive then return end

	if bind == IN_ATTACK then
		if viewdata.mode == MODE_EDIT_POINT then
			if viewdata.edit_point then
				map_edit.t_Positions[viewdata.edit_point] = hoverOrigin
				viewdata.edit_point = nil
			else
				table.insert(map_edit.t_Positions, hoverOrigin)
			end
		end
	elseif bind == IN_ATTACK2 then
		if viewdata.mode == MODE_EDIT_POINT then
			if viewdata.edit_point then
				viewdata.edit_point = nil
			else
				if nearPositionID then
					table.remove(map_edit.t_Positions, nearPositionID)
				end
			end
		end

	elseif bind == IN_USE then
		if viewdata.mode == MODE_EDIT_POINT then
			if input.IsButtonPressedIN(IN_WALK) then
				if nearPositionID then
					local newTable = {}

					for k = nearPositionID + 1, #map_edit.t_Positions do
						local pos = map_edit.t_Positions[k]
						table.insert(newTable, pos)
					end

					for k = 1, nearPositionID - 1 do
						local pos = map_edit.t_Positions[k]
						table.insert(newTable, pos)
					end

					table.insert(newTable, nearPosition)

					map_edit.t_Positions = newTable
				end
			else
				if viewdata.edit_point then
					viewdata.edit_point = nil
				else
					if nearPositionID then
						viewdata.edit_point = nearPositionID
					end
				end
			end
		end
	elseif bind == IN_RELOAD then
		viewdata.mode = MODE_DEFAULT
		viewdata.edit_point = nil
	end


	if but == KEY_PAD_4 and hoverPadPosition_4 then
		viewdata.Angle = (hoverPadPosition_4 - lastOrigin):Angle()
		hoverOrigin = hoverPadPosition_4
	elseif but == KEY_PAD_6 and hoverPadPosition_6 then
		viewdata.Angle = (hoverPadPosition_6 - lastOrigin):Angle()
		hoverOrigin = hoverPadPosition_6
	elseif but == KEY_PAD_8 and hoverPadPosition_8 then
		viewdata.Angle = (hoverPadPosition_8 - lastOrigin):Angle()
		hoverOrigin = hoverPadPosition_8
	elseif but == KEY_PAD_2 and hoverPadPosition_2 then
		viewdata.Angle = (hoverPadPosition_2 - lastOrigin):Angle()
		hoverOrigin = hoverPadPosition_2
	end

	if IsValid(hoverEntity) then
		if input.IsButtonIN(but, IN_USE) then
			nt.Send("map_edit.use", {"entity"}, {hoverEntity})
		end

		if input.IsButtonIN(but, IN_ATTACK) then
			nt.Send("map_edit.set.view.entity", {"entity"}, {hoverEntity})
		end
	end
end)
