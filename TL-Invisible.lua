-- ════════════════════════════════════════════════════════════════
--  TL-Invisible.lua (TLMenu Module)
--  Client-Clone Server-Side Invisibility System
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- Global runtime tracking for clean TLMenu unloads
local GLOBAL_ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_InvisRuntime"

if GLOBAL_ENV then
	local prev = GLOBAL_ENV[RUNTIME_KEY]
	if type(prev) == "table" and type(prev.cleanup) == "function" then
		pcall(prev.cleanup)
	end
end

local invisRunning = false
local IsInvis = false
local RealCharacter = nil
local InvisibleCharacter = nil
local invisFixConnection = nil
local invisDiedConnection = nil

local function setupParts()
	pcall(function()
		local ch = InvisibleCharacter or (IsInvis and Player.Character)
		if not ch then return end
		for _, v in ipairs(ch:GetDescendants()) do
			if v:IsA("BasePart") then
				if v.Name == "HumanoidRootPart" then
					v.Transparency = 1
				else
					v.Transparency = 0.5
				end
			end
		end
	end)
end

local function Respawn()
	pcall(function()
		if invisFixConnection then invisFixConnection:Disconnect(); invisFixConnection = nil end
		if invisDiedConnection then invisDiedConnection:Disconnect(); invisDiedConnection = nil end

		if RealCharacter and RealCharacter.Parent then
			Player.Character = RealCharacter
			task.wait()
			RealCharacter.Parent = workspace
			local hum = RealCharacter:FindFirstChildWhichIsA("Humanoid")
			if hum then
				hum:Destroy()
			end
		end

		if InvisibleCharacter and InvisibleCharacter.Parent then
			InvisibleCharacter:Destroy()
		end
		InvisibleCharacter = nil
		IsInvis = false
		invisRunning = false
	end)
end

local function start()
	if invisRunning or IsInvis then return end
	invisRunning = true

	local ch = Player.Character or Player.CharacterAdded:Wait()
	if not ch then
		invisRunning = false
		return
	end

	RealCharacter = ch
	RealCharacter.Archivable = true

	local okClone, clone = pcall(function() return RealCharacter:Clone() end)
	if not (okClone and clone) then
		invisRunning = false
		return
	end

	InvisibleCharacter = clone
	InvisibleCharacter.Name = ""
	pcall(function() InvisibleCharacter.Parent = Lighting end)

	local Void = workspace.FallenPartsDestroyHeight or -500

	invisFixConnection = RunService.Stepped:Connect(function()
		pcall(function()
			if not IsInvis then return end
			local char = Player.Character
			local hrp = char and (char:FindFirstChild("HumanoidRootPart") or (char:FindFirstChildWhichIsA("Humanoid") and char:FindFirstChildWhichIsA("Humanoid").RootPart))
			if hrp then
				local isInteger = tostring(Void):find("-") ~= nil
				local Y = hrp.Position.Y
				if isInteger and Y <= Void then
					Respawn()
				elseif not isInteger and Y >= Void then
					Respawn()
				end
			end
		end)
	end)

	setupParts()

	local cloneHum = InvisibleCharacter:FindFirstChildWhichIsA("Humanoid")
	if cloneHum then
		invisDiedConnection = cloneHum.Died:Connect(function()
			if invisDiedConnection then invisDiedConnection:Disconnect(); invisDiedConnection = nil end
			Respawn()
		end)
	end

	local realHrp = RealCharacter:FindFirstChild("HumanoidRootPart")
	local targetCFrame = realHrp and realHrp.CFrame or RealCharacter:GetPivot()

	-- Teleport real character out of render range
	pcall(function() RealCharacter:MoveTo(Vector3.new(0, math.pi * 1000000, 0)) end)

	pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	end)
	task.wait(0.2)
	pcall(function()
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)

	pcall(function() RealCharacter.Parent = Lighting end)
	pcall(function() InvisibleCharacter.Parent = workspace end)

	local cloneHrp = InvisibleCharacter:FindFirstChild("HumanoidRootPart")
	if cloneHrp then
		cloneHrp.CFrame = targetCFrame
	else
		pcall(function() InvisibleCharacter:PivotTo(targetCFrame) end)
	end

	Player.Character = InvisibleCharacter
	IsInvis = true

	local cam = workspace.CurrentCamera
	if cam then
		local subjectHum = InvisibleCharacter:FindFirstChildWhichIsA("Humanoid")
		if subjectHum then
			cam.CameraSubject = subjectHum
		end
		cam.CameraType = Enum.CameraType.Custom
	end

	pcall(function()
		Player.CameraMinZoomDistance = 0.5
		Player.CameraMaxZoomDistance = 400
		Player.CameraMode = Enum.CameraMode.Classic
	end)

	local head = InvisibleCharacter:FindFirstChild("Head")
	if head then
		head.Anchored = false
	end

	local anim = InvisibleCharacter:FindFirstChild("Animate")
	if anim and anim:IsA("LocalScript") then
		pcall(function()
			anim.Disabled = true
			anim.Disabled = false
		end)
	end
end

local function stop()
	if not IsInvis then return end

	if invisFixConnection then
		invisFixConnection:Disconnect()
		invisFixConnection = nil
	end
	if invisDiedConnection then
		invisDiedConnection:Disconnect()
		invisDiedConnection = nil
	end

	local curChar = Player.Character or InvisibleCharacter
	local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
	local targetCFrame = curHrp and curHrp.CFrame

	if InvisibleCharacter then
		pcall(function() InvisibleCharacter:Destroy() end)
		InvisibleCharacter = nil
	end

	if RealCharacter then
		pcall(function()
			RealCharacter.Parent = workspace
			local rHrp = RealCharacter:FindFirstChild("HumanoidRootPart")
			if rHrp and targetCFrame then
				rHrp.CFrame = targetCFrame
			end
			Player.Character = RealCharacter
		end)

		local cam = workspace.CurrentCamera
		if cam then
			local rHum = RealCharacter:FindFirstChildWhichIsA("Humanoid")
			if rHum then cam.CameraSubject = rHum end
			cam.CameraType = Enum.CameraType.Custom
		end

		local realAnim = RealCharacter:FindFirstChild("Animate")
		if realAnim and realAnim:IsA("LocalScript") then
			pcall(function()
				realAnim.Disabled = true
				realAnim.Disabled = false
			end)
		end

		local realHum = RealCharacter:FindFirstChildWhichIsA("Humanoid")
		if realHum then
			invisDiedConnection = realHum.Died:Connect(function()
				if invisDiedConnection then invisDiedConnection:Disconnect(); invisDiedConnection = nil end
				Respawn()
			end)
		end
	end

	IsInvis = false
	invisRunning = false
end

local function isActive()
	return IsInvis
end

local function toggle()
	if IsInvis then
		stop()
	else
		start()
	end
end

-- Auto-cleanup on character respawn
Player.CharacterAdded:Connect(function(newChar)
	if invisFixConnection then invisFixConnection:Disconnect(); invisFixConnection = nil end
	if invisDiedConnection then invisDiedConnection:Disconnect(); invisDiedConnection = nil end
	if InvisibleCharacter and InvisibleCharacter.Parent then
		pcall(function() InvisibleCharacter:Destroy() end)
	end
	InvisibleCharacter = nil
	RealCharacter = newChar
	IsInvis = false
	invisRunning = false
end)

local module = {
	start      = start,
	stop       = stop,
	isActive   = isActive,
	setupParts = setupParts,
	toggle     = toggle,
	cleanup    = stop,
}

if GLOBAL_ENV then
	GLOBAL_ENV[RUNTIME_KEY] = module
end

return module