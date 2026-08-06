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

local function Respawn()
	if IsInvis then
		pcall(function()
			Player.Character = RealCharacter
			task.wait()
			RealCharacter.Parent = workspace
			local hum = RealCharacter:FindFirstChildWhichIsA("Humanoid")
			if hum then
				hum:Destroy()
			end
			IsInvis = false
			if InvisibleCharacter then
				InvisibleCharacter.Parent = nil
			end
			invisRunning = false
		end)
	else
		pcall(function()
			Player.Character = RealCharacter
			task.wait()
			RealCharacter.Parent = workspace
			local hum = RealCharacter:FindFirstChildWhichIsA("Humanoid")
			if hum then
				hum:Destroy()
			end
			local function _invis(s)
				if s == true then
					if invisRunning or IsInvis then return end
					invisRunning = true
					if not Player.Character then Player.CharacterAdded:Wait() end
					RealCharacter = Player.Character
					RealCharacter.Archivable = true
					InvisibleCharacter = RealCharacter:Clone()
					InvisibleCharacter.Parent = Lighting
					InvisibleCharacter.Name = ""
					local Void = workspace.FallenPartsDestroyHeight
					invisFixConnection = RunService.Stepped:Connect(function()
						pcall(function()
							local isInteger = tostring(Void):find("-") ~= nil
							local Pos = Player.Character.Humanoid.RootPart.Position
							local Y = Pos.Y
							if isInteger and Y <= Void then Respawn()
							elseif not isInteger and Y >= Void then Respawn() end
						end)
					end)
					for _, v in pairs(InvisibleCharacter:GetDescendants()) do
						if v:IsA("BasePart") then
							if v.Name == "HumanoidRootPart" then v.Transparency = 1
							else v.Transparency = 0.5 end
						end
					end
					local cloneHum = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
					if cloneHum then
						invisDiedConnection = cloneHum.Died:Connect(function()
							Respawn()
							if invisDiedConnection then invisDiedConnection:Disconnect() end
						end)
					end
					IsInvis = true
					local targetCFrame = RealCharacter.Humanoid.RootPart.CFrame
					RealCharacter:MoveTo(Vector3.new(0, math.pi * 1000000, 0))
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					task.wait(0.2)
					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					RealCharacter.Parent = Lighting
					InvisibleCharacter.Parent = workspace
					InvisibleCharacter.Humanoid.RootPart.CFrame = targetCFrame
					Player.Character = InvisibleCharacter
					local cam = workspace.CurrentCamera
					cam.CameraSubject = Player.Character:FindFirstChildWhichIsA("Humanoid")
					cam.CameraType = Enum.CameraType.Custom
					Player.CameraMinZoomDistance = 0.5
					Player.CameraMaxZoomDistance = 400
					Player.CameraMode = Enum.CameraMode.Classic
					if Player.Character:FindFirstChild("Head") then Player.Character.Head.Anchored = false end
					if Player.Character:FindFirstChild("Animate") then
						Player.Character.Animate.Disabled = true
						Player.Character.Animate.Disabled = false
					end
				elseif s == false then
					if not IsInvis then return end
					if invisFixConnection then invisFixConnection:Disconnect(); invisFixConnection = nil end
					if invisDiedConnection then invisDiedConnection:Disconnect(); invisDiedConnection = nil end
					local targetCFrame = Player.Character.Humanoid.RootPart.CFrame
					RealCharacter.Humanoid.RootPart.CFrame = targetCFrame
					if InvisibleCharacter then InvisibleCharacter:Destroy(); InvisibleCharacter = nil end
					Player.Character = RealCharacter
					RealCharacter.Parent = workspace
					IsInvis = false
					if Player.Character:FindFirstChild("Animate") then
						Player.Character.Animate.Disabled = true
						Player.Character.Animate.Disabled = false
					end
					local realHum = RealCharacter:FindFirstChildOfClass("Humanoid")
					if realHum then
						invisDiedConnection = realHum.Died:Connect(function()
							Respawn()
							if invisDiedConnection then invisDiedConnection:Disconnect() end
						end)
					end
					invisRunning = false
				end
			end
			_invis(false)
		end)
	end
end

local function start()
	if invisRunning or IsInvis then return end
	invisRunning = true

	if not Player.Character then Player.CharacterAdded:Wait() end

	RealCharacter = Player.Character
	RealCharacter.Archivable = true

	InvisibleCharacter = RealCharacter:Clone()
	InvisibleCharacter.Parent = Lighting
	InvisibleCharacter.Name = ""

	local Void = workspace.FallenPartsDestroyHeight

	invisFixConnection = RunService.Stepped:Connect(function()
		pcall(function()
			local isInteger = tostring(Void):find("-") ~= nil
			local Pos = Player.Character.Humanoid.RootPart.Position
			local Y = Pos.Y
			if isInteger and Y <= Void then
				Respawn()
			elseif not isInteger and Y >= Void then
				Respawn()
			end
		end)
	end)

	for _, v in pairs(InvisibleCharacter:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = 0.5
			end
		end
	end

	local cloneHum = InvisibleCharacter:FindFirstChildOfClass("Humanoid")
	if cloneHum then
		invisDiedConnection = cloneHum.Died:Connect(function()
			Respawn()
			if invisDiedConnection then
				invisDiedConnection:Disconnect()
			end
		end)
	end

	IsInvis = true

	local targetCFrame = RealCharacter.Humanoid.RootPart.CFrame
	RealCharacter:MoveTo(Vector3.new(0, math.pi * 1000000, 0))

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	task.wait(0.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	RealCharacter.Parent = Lighting
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.Humanoid.RootPart.CFrame = targetCFrame
	Player.Character = InvisibleCharacter

	local cam = workspace.CurrentCamera
	cam.CameraSubject = Player.Character:FindFirstChildWhichIsA("Humanoid")
	cam.CameraType = Enum.CameraType.Custom

	Player.CameraMinZoomDistance = 0.5
	Player.CameraMaxZoomDistance = 400
	Player.CameraMode = Enum.CameraMode.Classic

	if Player.Character:FindFirstChild("Head") then
		Player.Character.Head.Anchored = false
	end

	if Player.Character:FindFirstChild("Animate") then
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
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

	local targetCFrame = Player.Character.Humanoid.RootPart.CFrame
	RealCharacter.Humanoid.RootPart.CFrame = targetCFrame

	if InvisibleCharacter then
		InvisibleCharacter:Destroy()
		InvisibleCharacter = nil
	end

	Player.Character = RealCharacter
	RealCharacter.Parent = workspace
	IsInvis = false

	if Player.Character:FindFirstChild("Animate") then
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
	end

	local realHum = RealCharacter:FindFirstChildOfClass("Humanoid")
	if realHum then
		invisDiedConnection = realHum.Died:Connect(function()
			Respawn()
			if invisDiedConnection then
				invisDiedConnection:Disconnect()
			end
		end)
	end

	invisRunning = false
end

local function isActive()
	return IsInvis
end

local function setupParts()
	pcall(function()
		if not IsInvis or not InvisibleCharacter then return end
		for _, v in pairs(InvisibleCharacter:GetDescendants()) do
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

return {
	start = start,
	stop = stop,
	isActive = isActive,
	setupParts = setupParts,
}
