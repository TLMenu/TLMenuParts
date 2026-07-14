-- ════════════════════════════════════════════════════════════════════════════
--  TLEX ByteBreaker V2 — Refactored Attach System
--  • Unified state management
--  • Performance-optimized caching
--  • Modular oscillator system
--  • Proper error handling & logging
-- ════════════════════════════════════════════════════════════════════════════

local M = {}

-- ════════════════════════════════════════════════════════════════════════════
--  CONFIGURATION
-- ════════════════════════════════════════════════════════════════════════════

local CFG = {
	VOID_Y = -200,
	RESCUE_Y = 50,
	DETACH_DISTANCE = 28,
	HEALTH_CHECK_INTERVAL = 0.08,
	CACHE_REFRESH_INTERVAL = 0.25,
	POSITION_UPDATE_THROTTLE = 0,
	VELOCITY_THRESHOLD = 0.5,
	ANIMATION_RETRY_DELAY = 0.1,
	RESPAWN_WAIT = 0.5,
}

local ANIM_IDS = {
	bb_carry = "95469914338674",
	bb_carryshoulder = "101003999980390",
	bb_carry2 = "73126126731268",
	bb_hug = "93667149408515",
	bb_backshots = "101003999980390",
	bb_licking = "86345507952689",
	bb_hug2 = "101809619267911",
	bb_layfuck = "95678189010798",
	bb_backpack = "73500261613116",
	bb_stomach = "105895909040298",
	bb_kiss = "102367337136163",
	bb_sucking = "74402438715168",
	bb_suck_it = "79294534752809",
	bb_doggy = "101856096472698",
	bb_pussyspread = "120754278085861",
	bb_soh = "119898270336796",
	bb_shouldersit = "119898270336796",
	bb_friend = "182435933",
	bb_bangv2 = "107300675038850",
	bb_cuffing = "137809930492090",
	bb_attach = "101003999980390",
}

local ATTACH_MODES = {
	bb_attach = {
		x = 0, y = -0.85, z = -2.0,
		rotX = 20, rotY = 0, rotZ = 0,
		osc = 1.5, oscSpeed = 10
	},
	bb_orbit = {
		distance = 8, speed = 1.5, type = "orbit"
	},
	bb_frontwalk = {
		distance = 5, facing = "front", type = "follow"
	},
	bb_behind = {
		distance = 5, facing = "back", type = "follow"
	},
	bb_cuffing = {
		distance = 1.5, facing = "back", type = "follow"
	},
	bb_headsit = {
		x = 0, y = 1.4, z = 0,
		rotX = 90, headRelative = true
	},
	bb_copy = { x = 4, y = 0, z = 0 },
	bb_piggyback = { x = 0, y = 0.2, z = 1.1 },
	bb_backpack = { x = 0, y = 2.5, z = 1.2 },
	bb_piggyback2 = { x = 0, y = 0.2, z = 1.1 },
	bb_carry = { x = 0.5, y = -0.5, z = -1.2 },
	bb_carryshoulder = { x = 1.8, y = 0.2, z = 0.9 },
	bb_carry2 = { x = 0.5, y = 1.0, z = -1.2 },
	bb_hug = {
		x = 0, y = 0.05, z = -1.35,
		rotY = 180, osc = 0.04, oscSpeed = 10
	},
	bb_hug2 = { x = 0, y = 0, z = 1.1 },
	bb_stand = { x = -0.8, y = 2, z = 2.2 },
	bb_layfuck = {
		x = 0, y = 0.1, z = 0.9,
		osc = 0.9, oscSpeed = 12
	},
	bb_headstand = { x = 0.2, y = 4, z = 0.2 },
	bb_licking = {
		x = 0, y = -1.7, z = -2.5,
		rotY = 180, osc = 0.4, oscSpeed = 15
	},
	bb_bangv2 = {
		x = 0, y = 0.2, z = 3.5,
		osc = 3, oscSpeed = 10, useOscTimer = true
	},
	bb_stomach = {
		x = 0, y = 0, z = 3.0, rotY = 180
	},
	bb_kiss = {
		x = 0, y = 1.5, z = -1.2,
		rotY = 180, osc = 0.08, oscSpeed = 10
	},
	bb_sucking = {
		x = 0, y = -0.4, z = -3.1,
		rotY = 180, osc = 0.5, oscSpeed = 20
	},
	bb_suck_it = {
		x = 0, y = -1.2, z = -2.0,
		rotY = 180, osc = 1.0, oscSpeed = 12
	},
	bb_backshots = {
		x = 0, y = -3.2, z = -2.0,
		rotX = 20, osc = 1.5, oscSpeed = 10
	},
	bb_doggy = {
		x = 0, y = -4.7, z = -0.8, rotX = -90
	},
	bb_pussyspread = {
		x = 0, y = -2.45, z = -2.0,
		osc = 1.5, oscSpeed = 10
	},
	bb_soh = { y = 1, headRelative = true },
	bb_shouldersit = { x = 1.8, y = 2.2, z = 0 },
	bb_friend = { x = 3, y = 0, z = 0 },
}

-- ════════════════════════════════════════════════════════════════════════════
--  STATE CONTAINER
-- ════════════════════════════════════════════════════════════════════════════

local State = {
	active = false,
	mode = nil,
	target = nil,
	
	-- cached references
	myChar = nil,
	myHRP = nil,
	myHum = nil,
	targetChar = nil,
	targetHRP = nil,
	targetHead = nil,
	targetTorso = nil,
	
	-- timers
	healthCheckAcc = 0,
	cacheCheckAcc = 0,
	oscTime = 0,
	lastSafeY = 0,
	lastDetachFix = 0,
	
	-- physics objects
	bodyMovers = {},
	
	-- connections
	connections = {},
	
	-- animation
	animTracks = {},
	
	-- misc
	rakHooked = false,
	rakHookFn = nil,
	lastError = nil,
}

-- ════════════════════════════════════════════════════════════════════════════
--  DEPENDENCIES (injected via init)
-- ════════════════════════════════════════════════════════════════════════════

local Deps = {
	LocalPlayer = nil,
	RunService = nil,
	Players = nil,
	sethiddenproperty = nil,
	raknet = nil,
	sendNotif = nil,
	getHumanoid = nil,
	safeStand = nil,
	_AF = {},
	_TL_refs = {},
}

-- ════════════════════════════════════════════════════════════════════════════
--  UTILITIES
-- ════════════════════════════════════════════════════════════════════════════

local function logError(context, err)
	State.lastError = { ctx = context, err = tostring(err), time = tick() }
	warn("[BB] " .. context .. ": " .. tostring(err))
end

local function safe(fn, context)
	local ok, err = pcall(fn)
	if not ok then logError(context or "safe", err) end
	return ok
end

local function getHRP(player)
	local char = player and player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHead(player)
	local char = player and player.Character
	return char and char:FindFirstChild("Head")
end

local function getHumanoid(char)
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function clearTable(t)
	for k in pairs(t) do t[k] = nil end
end

-- ════════════════════════════════════════════════════════════════════════════
--  CACHE MANAGEMENT
-- ════════════════════════════════════════════════════════════════════════════

local function refreshMyCache()
	local char = Deps.LocalPlayer.Character
	if char ~= State.myChar then
		State.myChar = char
		State.myHRP = char and char:FindFirstChild("HumanoidRootPart")
		State.myHum = getHumanoid(char)
		if State.myHRP then State.lastSafeY = State.myHRP.Position.Y end
	end
end

local function refreshTargetCache()
	if not State.target then return end
	local char = State.target.Character
	if char ~= State.targetChar or not State.targetHRP or not State.targetHRP.Parent then
		State.targetChar = char
		State.targetHRP = char and char:FindFirstChild("HumanoidRootPart")
		State.targetHead = char and char:FindFirstChild("Head")
		State.targetTorso = char and (
			char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
		)
		
		if State.myHRP and State.targetHRP then
			safe(function()
				Deps.sethiddenproperty(State.myHRP, "PhysicsRepRootPart", State.targetHRP)
			end, "refreshTargetCache:PhysicsRepRootPart")
		end
	end
end

-- ════════════════════════════════════════════════════════════════════════════
--  PHYSICS HELPERS
-- ════════════════════════════════════════════════════════════════════════════

local function createBodyVelocity(parent)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(0, 1e6, 0)
	bv.Velocity = Vector3.zero
	bv.Parent = parent
	State.bodyMovers[#State.bodyMovers + 1] = bv
	return bv
end

local function destroyBodyMovers()
	for _, obj in ipairs(State.bodyMovers) do
		safe(function() obj:Destroy() end, "destroyBodyMovers")
	end
	clearTable(State.bodyMovers)
end

local function clearVelocity(hrp)
	if not hrp then return end
	safe(function()
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
		hrp.Velocity = Vector3.zero
		hrp.RotVelocity = Vector3.zero
	end, "clearVelocity")
end

local function disableCollision(char)
	safe(function()
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end, "disableCollision")
end

local function enableCollision(char)
	safe(function()
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end, "enableCollision")
end

-- ════════════════════════════════════════════════════════════════════════════
--  OSCILLATOR SYSTEM
-- ════════════════════════════════════════════════════════════════════════════

local Oscillator = {
	timers = {},
}

function Oscillator.reset(key)
	Oscillator.timers[key] = 0
end

function Oscillator.update(key, dt)
	Oscillator.timers[key] = (Oscillator.timers[key] or 0) + dt
	local t = Oscillator.timers[key]
	if t > 86400 then Oscillator.timers[key] = t % 6.28319 end
	return Oscillator.timers[key]
end

function Oscillator.get(key, amplitude, speed, dt)
	local t = Oscillator.update(key, dt)
	return math.sin(t * (speed or 10)) * (amplitude or 1)
end

-- ════════════════════════════════════════════════════════════════════════════
--  ANIMATION SYSTEM
-- ════════════════════════════════════════════════════════════════════════════

local function stopAllAnimations()
	for _, track in pairs(State.animTracks) do
		safe(function()
			if track.track then
				track.track:AdjustSpeed(1)
				track.track:Stop()
			end
			if track.conn then track.conn:Disconnect() end
		end, "stopAllAnimations")
	end
	clearTable(State.animTracks)
end

local function loadAnimation(humanoid, animId, animName)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator", humanoid)
	end
	
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://" .. animId
	anim.Name = animName or "BBAnimation"
	
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action4
	
	task.delay(0.5, function() safe(function() anim:Destroy() end, "loadAnimation:cleanup") end)
	
	return track
end

local function playAnimation(mode, opts)
	opts = opts or {}
	local animId = ANIM_IDS[mode]
	if not animId or not State.myHum then return end
	
	local function playFn(char)
		if not char or not State.active then return end
		local hum = getHumanoid(char)
		if not hum then return end
		
		if opts.r6Only and hum.RigType ~= Enum.HumanoidRigType.R6 then return end
		
		local track = loadAnimation(hum, animId, mode .. "Anim")
		if not track then return end
		
		if opts.speed then safe(function() track:AdjustSpeed(opts.speed) end, "playAnimation:speed") end
		if opts.timePos then
			track:AdjustSpeed(0)
			track.TimePosition = opts.timePos
		end
		
		local slot = State.animTracks[mode] or {}
		slot.track = track
		
		if slot.conn then safe(function() slot.conn:Disconnect() end, "playAnimation:disconnectOld") end
		
		slot.conn = track.Stopped:Connect(function()
			if State.active and State.mode == mode then
				task.wait(CFG.ANIMATION_RETRY_DELAY)
				playFn(char)
			end
		end)
		
		State.animTracks[mode] = slot
		track:Play()
	end
	
	playFn(State.myChar)
end

-- ════════════════════════════════════════════════════════════════════════════
--  POSITION CALCULATION
-- ════════════════════════════════════════════════════════════════════════════

local function calculateTargetCFrame(mode, modeData, dt)
	local tHRP = State.targetHRP
	if not tHRP then return nil end
	
	-- Orbit mode
	if modeData.type == "orbit" then
		local dist = modeData.distance or 8
		local speed = modeData.speed or 1.5
		local angle = State.oscTime * speed
		local pos = Vector3.new(
			tHRP.Position.X + math.cos(angle) * dist,
			tHRP.Position.Y,
			tHRP.Position.Z + math.sin(angle) * dist
		)
		return CFrame.new(pos, tHRP.Position)
	end
	
	-- Follow mode (front/back)
	if modeData.type == "follow" then
		local look = tHRP.CFrame.LookVector
		local mult = modeData.facing == "front" and 1 or -1
		local dist = modeData.distance or 5
		local pos = tHRP.Position + look * (dist * mult)
		return CFrame.new(pos, pos + look)
	end
	
	-- Head-relative mode
	if modeData.headRelative then
		local head = State.targetHead
		local base = head and head.CFrame or (tHRP.CFrame * CFrame.new(0, 3, 0))
		local rx = modeData.rotX and math.rad(modeData.rotX) or 0
		local ry = modeData.rotY and math.rad(modeData.rotY) or 0
		local rz = modeData.rotZ and math.rad(modeData.rotZ) or 0
		
		return CFrame.new(
			base.Position + Vector3.new(modeData.x or 0, modeData.y or 0, modeData.z or 0)
		) * CFrame.fromEulerAnglesXYZ(rx, select(2, tHRP.CFrame:ToEulerAnglesXYZ()), rz)
	end
	
	-- Standard offset mode
	local x = modeData.x or 0
	local y = modeData.y or 0
	local z = modeData.z or 0
	
	-- Apply oscillation
	if modeData.osc and modeData.oscSpeed then
		local oscKey = mode .. "_osc"
		if modeData.useOscTimer then
			z = z - Oscillator.get(oscKey, modeData.osc, modeData.oscSpeed, dt)
		else
			z = z - math.sin(State.oscTime * modeData.oscSpeed) * modeData.osc
		end
	end
	
	local rx = modeData.rotX and math.rad(modeData.rotX) or 0
	local ry = modeData.rotY and math.rad(modeData.rotY) or 0
	local rz = modeData.rotZ and math.rad(modeData.rotZ) or 0
	
	return tHRP.CFrame * CFrame.new(x, y, z) * CFrame.Angles(rx, ry, rz)
end

-- ════════════════════════════════════════════════════════════════════════════
--  HEALTH & SAFETY SYSTEM
-- ════════════════════════════════════════════════════════════════════════════

local function setupHealthProtection()
	local hum = State.myHum
	if not hum then return end
	
	safe(function()
		hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end, "setupHealthProtection:states")
	
	local diedConn = hum.Died:Connect(function()
		if State.active then
			safe(function() hum.Health = hum.MaxHealth end, "healthProtection:died")
		end
	end)
	State.connections[#State.connections + 1] = diedConn
end

local function checkVoidRescue()
	local hrp = State.myHRP
	if not hrp then return end
	
	if hrp.Position.Y > CFG.VOID_Y then
		State.lastSafeY = hrp.Position.Y
		return
	end
	
	local tHRP = State.targetHRP
	local rescueCF = tHRP and (tHRP.CFrame * CFrame.new(0, CFG.RESCUE_Y, 0))
		or CFrame.new(hrp.Position.X, math.max(State.lastSafeY, CFG.RESCUE_Y), hrp.Position.Z)
	
	safe(function()
		hrp.CFrame = rescueCF
		clearVelocity(hrp)
		if State.myHum then State.myHum.Health = State.myHum.MaxHealth end
	end, "checkVoidRescue")
end

local function checkDetachDistance()
	local myHRP = State.myHRP
	local tHRP = State.targetHRP
	if not myHRP or not tHRP then return end
	
	local dist = (myHRP.Position - tHRP.Position).Magnitude
	if dist > CFG.DETACH_DISTANCE and tick() - State.lastDetachFix > 0.65 then
		State.lastDetachFix = tick()
		safe(function()
			clearVelocity(myHRP)
			myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 2.25, 2.25)
		end, "checkDetachDistance")
	end
end

-- ════════════════════════════════════════════════════════════════════════════
--  RAKNET HOOK (optional)
-- ════════════════════════════════════════════════════════════════════════════

local function setupRaknetHook()
	if not Deps.raknet or State.rakHooked then return end
	
	safe(function()
		State.rakHookFn = function(packet)
			if packet.PacketId == 0x1B then
				local buf = packet.AsBuffer
				buffer.writeu32(buf, 1, 0xFFFFFFFF)
				packet:SetData(buf)
			end
		end
		Deps.raknet.add_send_hook(State.rakHookFn)
		State.rakHooked = true
	end, "setupRaknetHook")
end

local function removeRaknetHook()
	if State.rakHooked and State.rakHookFn and Deps.raknet then
		safe(function()
			Deps.raknet.remove_send_hook(State.rakHookFn)
		end, "removeRaknetHook")
		State.rakHooked = false
		State.rakHookFn = nil
	end
end

-- ════════════════════════════════════════════════════════════════════════════
--  RESPAWN HANDLING
-- ════════════════════════════════════════════════════════════════════════════

local function bindRespawnHandlers()
	-- My respawn
	local myRespawn = Deps.LocalPlayer.CharacterAdded:Connect(function(char)
		if not State.active then return end
		task.wait(CFG.RESPAWN_WAIT)
		refreshMyCache()
		disableCollision(char)
		setupHealthProtection()
		
		local savedMode = State.mode
		local savedTarget = State.target
		if savedMode and savedTarget then
			playAnimation(savedMode, {})
		end
	end)
	State.connections[#State.connections + 1] = myRespawn
	
	-- Target respawn
	if not State.target then return end
	
	local targetRespawn = State.target.CharacterAdded:Connect(function()
		if not State.active then return end
		task.wait(CFG.RESPAWN_WAIT)
		refreshTargetCache()
	end)
	State.connections[#State.connections + 1] = targetRespawn
	
	-- Target died
	local targetChar = State.target.Character
	if targetChar then
		local targetHum = getHumanoid(targetChar)
		if targetHum then
			local diedConn = targetHum.Died:Connect(function()
				if State.active then
					task.wait(0.3)
					refreshTargetCache()
				end
			end)
			State.connections[#State.connections + 1] = diedConn
		end
	end
end

-- ════════════════════════════════════════════════════════════════════════════
--  MAIN UPDATE LOOP
-- ════════════════════════════════════════════════════════════════════════════

local function onHeartbeat(dt)
	if not State.active then return end
	
	State.oscTime = State.oscTime + dt
	if State.oscTime > 86400 then State.oscTime = State.oscTime % 6.28319 end
	
	-- Cache refresh
	State.cacheCheckAcc = State.cacheCheckAcc + dt
	if State.cacheCheckAcc >= CFG.CACHE_REFRESH_INTERVAL then
		State.cacheCheckAcc = 0
		refreshMyCache()
		refreshTargetCache()
		checkDetachDistance()
	end
	
	-- Health check
	State.healthCheckAcc = State.healthCheckAcc + dt
	if State.healthCheckAcc >= CFG.HEALTH_CHECK_INTERVAL then
		State.healthCheckAcc = 0
		checkVoidRescue()
		
		local hum = State.myHum
		if hum then
			safe(function()
				hum.PlatformStand = true
				if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
				if hum.SeatPart then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
			end, "onHeartbeat:health")
		end
	end
	
	local myHRP = State.myHRP
	local tHRP = State.targetHRP
	if not myHRP or not tHRP or not tHRP.Parent then return end
	
	-- Velocity control
	local vel = myHRP.AssemblyLinearVelocity
	if vel.Magnitude > CFG.VELOCITY_THRESHOLD then
		clearVelocity(myHRP)
	end
	
	-- Position update
	local modeData = ATTACH_MODES[State.mode]
	if not modeData then return end
	
	local targetCF = calculateTargetCFrame(State.mode, modeData, dt)
	if targetCF then
		safe(function()
			myHRP.CFrame = targetCF
		end, "onHeartbeat:position")
	end
	
	-- PhysicsRepRootPart refresh
	safe(function()
		Deps.sethiddenproperty(myHRP, "PhysicsRepRootPart", tHRP)
	end, "onHeartbeat:PhysicsRepRootPart")
end

-- ════════════════════════════════════════════════════════════════════════════
--  PUBLIC API
-- ════════════════════════════════════════════════════════════════════════════

function M.startBB(targetPlayer, modeKey)
	M.stopBB()
	
	if not targetPlayer or not targetPlayer.Character then
		if Deps.sendNotif then Deps.sendNotif("ByteBreaker", "No target character", 2) end
		return
	end
	
	if not ATTACH_MODES[modeKey] then
		if Deps.sendNotif then Deps.sendNotif("ByteBreaker", "Invalid mode: " .. tostring(modeKey), 2) end
		return
	end
	
	State.active = true
	State.mode = modeKey
	State.target = targetPlayer
	
	refreshMyCache()
	refreshTargetCache()
	
	if not State.myHRP or not State.myHum then
		M.stopBB()
		if Deps.sendNotif then Deps.sendNotif("ByteBreaker", "Missing HRP/Humanoid", 2) end
		return
	end
	
	-- Setup
	setupRaknetHook()
	disableCollision(State.myChar)
	setupHealthProtection()
	
	safe(function()
		State.myHum.PlatformStand = true
		State.myHum.WalkSpeed = 0
	end, "startBB:humanoid")
	
	createBodyVelocity(State.myHRP)
	
	-- Animation
	local animOpts = {}
	if modeKey == "bb_kiss" then animOpts.r6Only = true end
	if modeKey == "bb_sucking" then animOpts.speed = 2 end
	if modeKey == "bb_suck_it" then animOpts.speed = 1.5 end
	if modeKey == "bb_doggy" then animOpts.speed = 1.5 end
	if modeKey == "bb_bangv2" then
		animOpts.speed = 2
		Oscillator.reset(modeKey .. "_osc")
	end
	if modeKey == "bb_soh" or modeKey == "bb_shouldersit" then
		animOpts.timePos = 2
	end
	
	playAnimation(modeKey, animOpts)
	
	-- Heartbeat
	local hbConn = Deps.RunService.Heartbeat:Connect(onHeartbeat)
	State.connections[#State.connections + 1] = hbConn
	
	-- Respawn handling
	bindRespawnHandlers()
	
	if Deps.sendNotif then
		Deps.sendNotif("ByteBreaker", "🎬 " .. modeKey .. ": " .. targetPlayer.Name, 3)
	end
	
	-- External hook
	if Deps._AF then Deps._AF.bbActive = true end
end

function M.stopBB()
	if not State.active then return end
	
	State.active = false
	
	-- Disconnect all
	for _, conn in ipairs(State.connections) do
		safe(function() conn:Disconnect() end, "stopBB:disconnect")
	end
	clearTable(State.connections)
	
	-- Stop animations
	stopAllAnimations()
	
	-- Destroy body movers
	destroyBodyMovers()
	
	-- Cleanup raknet
	removeRaknetHook()
	
	-- Restore character
	local myChar = State.myChar
	local myHRP = State.myHRP
	local myHum = State.myHum
	
	if myHRP then
		safe(function()
			Deps.sethiddenproperty(myHRP, "PhysicsRepRootPart", nil)
			clearVelocity(myHRP)
			myHRP.Anchored = false
		end, "stopBB:cleanup HRP")
	end
	
	if myHum then
		safe(function()
			myHum.PlatformStand = false
			myHum.WalkSpeed = 16
			myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			myHum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
			myHum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end, "stopBB:cleanup Humanoid")
	end
	
	if myChar then
		enableCollision(myChar)
	end
	
	-- Reset state
	State.mode = nil
	State.target = nil
	State.oscTime = 0
	State.healthCheckAcc = 0
	State.cacheCheckAcc = 0
	State.lastSafeY = 0
	State.lastDetachFix = 0
	
	-- External hook
	if Deps._AF then Deps._AF.bbActive = false end
	
	-- Safe stand
	task.delay(0.08, function()
		if Deps.safeStand then safe(Deps.safeStand, "stopBB:safeStand") end
	end)
	
	if Deps.sendNotif then
		Deps.sendNotif("ByteBreaker", "👋 Stopped", 1)
	end
end

function M.initBB(cfg)
	Deps.LocalPlayer = cfg.LocalPlayer or game:GetService("Players").LocalPlayer
	Deps.RunService = cfg.RunService or game:GetService("RunService")
	Deps.Players = cfg.Players or game:GetService("Players")
	Deps.sethiddenproperty = cfg.sethiddenproperty or sethiddenproperty
	Deps.raknet = cfg.raknet
	Deps.sendNotif = cfg.sendNotif
	Deps.getHumanoid = cfg.getHumanoid
	Deps.safeStand = cfg.safeStand
	Deps._AF = cfg._AF or {}
	Deps._TL_refs = cfg._TL_refs or {}
end

function M.isActive()
	return State.active
end

function M.getState()
	return {
		active = State.active,
		mode = State.mode,
		target = State.target and State.target.Name,
		lastError = State.lastError,
	}
end

M._bbMode_ = function() return State.mode end
M._bbTarget_ = function() return State.target end

-- Legacy stubs: old TLMenu.lua calls these; V2 has no QABar
M.initQABar = function(_cfg) end
M.startQABar = function() end
M.stopQAAction = function() end
M.activateQAAction = function() return false end
M.qaStartNoSit = function() end
M.qaStopNoSit = function() end

return M
