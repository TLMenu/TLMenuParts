local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local invisRunning = false
local IsInvis = false
local RealCharacter = nil
local InvisibleCharacter = nil
local invisFixConnection = nil
local invisDiedConnection = nil

local function cleanupConnections()
	if invisFixConnection then
		invisFixConnection:Disconnect()
		invisFixConnection = nil
	end
	if invisDiedConnection then
		invisDiedConnection:Disconnect()
		invisDiedConnection = nil
	end
end

local function setCharacterTransparency(char, alpha)
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = alpha
			end
		elseif v:IsA("Accessory") then
			local handle = v:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				handle.Transparency = alpha
			end
		end
	end
end

local function stop()
	if not IsInvis then
		return
	end

	cleanupConnections()

	if InvisibleCharacter then
		local root = InvisibleCharacter:FindFirstChild("HumanoidRootPart")
		if root and RealCharacter and RealCharacter:FindFirstChild("HumanoidRootPart") then
			RealCharacter.HumanoidRootPart.CFrame = root.CFrame
		end
		InvisibleCharacter:Destroy()
		InvisibleCharacter = nil
	end

	if RealCharacter then
		Player.Character = RealCharacter
		RealCharacter.Parent = workspace

		local animate = RealCharacter:FindFirstChild("Animate")
		if animate then
			animate.Disabled = true
			animate.Disabled = false
		end
	end

	IsInvis = false
	invisRunning = false
end

local function start()
	if invisRunning or IsInvis then
		return
	end
	invisRunning = true

	local char = Player.Character or Player.CharacterAdded:Wait()
	RealCharacter = char
	RealCharacter.Archivable = true

	InvisibleCharacter = RealCharacter:Clone()
	InvisibleCharacter.Name = ""
	InvisibleCharacter.Parent = Lighting

	setCharacterTransparency(InvisibleCharacter, 0.5)

	-- Fast void check without string searching inside the loop
	local voidHeight = workspace.FallenPartsDestroyHeight

	cleanupConnections()

	invisFixConnection = RunService.Stepped:Connect(function()
		if not InvisibleCharacter or not InvisibleCharacter:FindFirstChild("HumanoidRootPart") then
			return
		end
		local yPos = InvisibleCharacter.HumanoidRootPart.Position.Y

		-- Direct numeric comparison instead of string manipulation
		if yPos <= voidHeight then
			stop()
		end
	end)

	local cloneHum = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
	if cloneHum then
		invisDiedConnection = cloneHum.Died:Connect(function()
			stop()
		end)
	end

	local targetCFrame = RealCharacter.HumanoidRootPart.CFrame
	RealCharacter:MoveTo(Vector3.new(0, 500000, 0))

	RealCharacter.Parent = Lighting
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.HumanoidRootPart.CFrame = targetCFrame
	Player.Character = InvisibleCharacter

	local cam = workspace.CurrentCamera
	cam.CameraSubject = cloneHum
	cam.CameraType = Enum.CameraType.Custom

	Player.CameraMinZoomDistance = 0.5
	Player.CameraMaxZoomDistance = 400
	Player.CameraMode = Enum.CameraMode.Classic

	IsInvis = true
	invisRunning = false
end

return {
	start = start,
	stop = stop,
	isActive = function()
		return IsInvis
	end,
	setupParts = function()
		if IsInvis and InvisibleCharacter then
			setCharacterTransparency(InvisibleCharacter, 0.5)
		end
	end,
}
