local M = {}
local _cfg = {}
local _aim = {}

function M.init(cfg)
    _cfg = cfg or {}
    _aim.Players = cfg.Players or game:GetService("Players")
    _aim.RunService = cfg.RunService or game:GetService("RunService")
    _aim.UserInputService = cfg.UserInputService or game:GetService("UserInputService")
    _aim.Workspace = cfg.Workspace or game:GetService("Workspace")
    _aim.LocalPlayer = cfg.LocalPlayer or _aim.Players.LocalPlayer
    _aim.Camera = _aim.Workspace.CurrentCamera

    _aim.Config = {
        Enabled = false,
        SilentAim = false,
        Aimlock = false,
        AimlockToggle = false,
        WallCheck = false,
        TeamCheck = false,
        VisibilityCheck = true,
        Smoothness = 0.15,
        FOV = 120,
        AimPart = "Head",
        AutoFire = false,
        TriggerBot = false,
        MultiPoint = false,
        AutoAimDistance = 2000,
        CurrentTarget = nil,
        LastTargetTime = 0,
        TargetLockTime = 1.0,
        ShowFOV = false,
        ShowTargetLine = false,
    }

    pcall(function()
        _aim.FOVCircle = Drawing.new("Circle")
        _aim.FOVCircle.Visible = false
        _aim.FOVCircle.Thickness = 2
        _aim.FOVCircle.Color = Color3.fromRGB(255, 60, 60)
        _aim.FOVCircle.Transparency = 0.8
        _aim.FOVCircle.Filled = false
    end)

    pcall(function()
        _aim.TargetLine = Drawing.new("Line")
        _aim.TargetLine.Visible = false
        _aim.TargetLine.Thickness = 1.5
        _aim.TargetLine.Color = Color3.fromRGB(255, 255, 255)
        _aim.TargetLine.Transparency = 0.6
    end)

    _aim.Cache = {}

    _aim.GetDeltaTime = function()
        return os.clock()
    end

    _aim.GetCharacter = function(player)
        return player and player.Character
    end

    _aim.GetHumanoid = function(character)
        return character and character:FindFirstChildOfClass("Humanoid")
    end

    _aim.GetRootPart = function(character)
        return character and character:FindFirstChild("HumanoidRootPart")
    end

    _aim.GetAimPart = function(character)
        if not character then return nil end
        if _aim.Config.AimPart == "Smart" or _aim.Config.AimPart == "Head" then
            local head = character:FindFirstChild("Head")
            if head and _aim.IsVisible(head) then return head end
            local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
            if torso and _aim.IsVisible(torso) then return torso end
            return head or torso
        elseif _aim.Config.AimPart == "Torso" then
            return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        elseif _aim.Config.AimPart == "Random" then
            local parts = { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }
            local found = {}
            for _, p in ipairs(parts) do if character:FindFirstChild(p) then table.insert(found, character:FindFirstChild(p)) end end
            return #found > 0 and found[math.random(1, #found)] or character:FindFirstChild("HumanoidRootPart")
        end
        return character:FindFirstChild(_aim.Config.AimPart) or character:FindFirstChild("HumanoidRootPart")
    end

    _aim.IsPlayerAlive = function(player)
        local char = _aim.GetCharacter(player)
        local hum = _aim.GetHumanoid(char)
        return hum and hum.Health > 0
    end

    _aim.IsTeammate = function(player)
        if not _aim.Config.TeamCheck then return false end
        return player.Team == _aim.LocalPlayer.Team
    end

    _aim.IsVisible = function(targetPart)
        if not _aim.Config.WallCheck then return true end
        if not targetPart then return false end
        local origin = _aim.Camera.CFrame.Position
        local direction = (targetPart.Position - origin).Unit * 1000
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = { _aim.LocalPlayer.Character, targetPart.Parent }
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.IgnoreWater = true
        local result = _aim.Workspace:Raycast(origin, direction, raycastParams)
        if not result then return true end
        return false
    end

    _aim.GetTargetPosition = function(player, targetPart, dt)
        if not targetPart or not player then return nil end
        local position = targetPart.Position
        local character = _aim.GetCharacter(player)
        local rootPart = _aim.GetRootPart(character)
        if rootPart then
            if not _aim.Cache[player] then
                _aim.Cache[player] = {
                    LastPosition = rootPart.Position,
                    LastUpdate = os.clock(),
                    SmoothedVelocity = Vector3.zero,
                }
            else
                local cache = _aim.Cache[player]
                local currentTime = os.clock()
                local deltaTime = currentTime - cache.LastUpdate
                if deltaTime > 0 then
                    local instantVelocity = (rootPart.Position - cache.LastPosition) / deltaTime
                    local lerpAlpha = math.clamp(deltaTime * 15, 0, 1)
                    cache.SmoothedVelocity = cache.SmoothedVelocity:Lerp(instantVelocity, lerpAlpha)
                    if (instantVelocity - cache.SmoothedVelocity).Magnitude > 20 then
                        cache.SmoothedVelocity = instantVelocity
                    end
                end
                cache.LastPosition = rootPart.Position
                cache.LastUpdate = currentTime
            end
        end
        if _aim.Config.MultiPoint then
            local t = os.clock()
            local offset = Vector3.new(
                math.sin(t * 20) * 0.2,
                math.cos(t * 15) * 0.1,
                math.sin(t * 10) * 0.1
            )
            position = position + offset
        end
        return position
    end

    _aim.GetDistanceToMouse = function(worldPosition)
        local screenPosition, onScreen = _aim.Camera:WorldToViewportPoint(worldPosition)
        if not onScreen then return math.huge end
        local mousePos = _aim.UserInputService:GetMouseLocation()
        return (Vector2.new(screenPosition.X, screenPosition.Y) - mousePos).Magnitude
    end

    _aim.GetBestTarget = function()
        local bestTarget = nil
        local bestScore = math.huge
        local screenCenter = Vector2.new(_aim.Camera.ViewportSize.X / 2, _aim.Camera.ViewportSize.Y / 2)
        local myChar = _aim.LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        for _, player in ipairs(_aim.Players:GetPlayers()) do
            if player == _aim.LocalPlayer then continue end
            if not _aim.IsPlayerAlive(player) then continue end
            if _aim.IsTeammate(player) then continue end
            local character = _aim.GetCharacter(player)
            local rootPart = _aim.GetRootPart(character)
            if not rootPart then continue end
            local worldDist = (myRoot.Position - rootPart.Position).Magnitude
            if worldDist > _aim.Config.AutoAimDistance then continue end
            local targetPart = _aim.GetAimPart(character)
            if not targetPart then continue end
            if _aim.Config.WallCheck and not _aim.IsVisible(targetPart) then continue end
            local screenPos, onScreen = _aim.Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end
            local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
            if distFromCenter > _aim.Config.FOV then continue end
            local score = (distFromCenter * 1.0) + (worldDist * 0.2)
            if score < bestScore then
                bestScore = score
                bestTarget = {
                    Player = player,
                    Part = targetPart,
                    Position = targetPart.Position,
                    ScreenPosition = Vector2.new(screenPos.X, screenPos.Y),
                    Distance = worldDist,
                    Health = _aim.GetHumanoid(character) and _aim.GetHumanoid(character).Health or 100,
                }
            end
        end
        return bestTarget
    end

    _aim.SmoothAim = function(targetPosition, dt)
        if not targetPosition or not dt then return end
        local currentCFrame = _aim.Camera.CFrame
        local targetRotation = CFrame.lookAt(currentCFrame.Position, targetPosition).Rotation
        local s = math.clamp(_aim.Config.Smoothness, 0.0, 0.99)
        if s == 0 then
            _aim.Camera.CFrame = CFrame.new(currentCFrame.Position) * targetRotation
            return
        end
        local speed = 50 * (1 - s)
        local alpha = math.clamp(1 - math.exp(-speed * dt), 0, 1)
        local newRotation = currentCFrame.Rotation:Lerp(targetRotation, alpha)
        _aim.Camera.CFrame = CFrame.new(currentCFrame.Position) * newRotation
    end

    _aim.SilentAim = function(targetPosition)
        if not targetPosition then return nil end
        return targetPosition
    end

    _aim.PerformAimbot = function(dt)
        if not _aim.Config.Enabled then
            _aim.Config.CurrentTarget = nil
            if _aim.FOVCircle then _aim.FOVCircle.Visible = false end
            if _aim.TargetLine then _aim.TargetLine.Visible = false end
            return
        end
        dt = dt or 0.016
        local screenCenter = Vector2.new(_aim.Camera.ViewportSize.X / 2, _aim.Camera.ViewportSize.Y / 2)
        local target = nil
        if _aim.Config.CurrentTarget then
            local player = _aim.Config.CurrentTarget.Player
            if player and player.Parent and _aim.IsPlayerAlive(player) then
                local char = _aim.GetCharacter(player)
                local part = _aim.GetAimPart(char)
                if part and (not _aim.Config.WallCheck or _aim.IsVisible(part)) then
                    local screenPos, onScreen = _aim.Camera:WorldToViewportPoint(part.Position)
                    local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if onScreen and distFromCenter <= _aim.Config.FOV * 2.0 then
                        target = { Player = player, Part = part, Position = part.Position }
                    end
                end
            end
        end
        if not target then
            target = _aim.GetBestTarget()
            if target then
                _aim.Config.CurrentTarget = target
                _aim.Config.LastTargetTime = os.clock()
            end
        end
        if _aim.FOVCircle then
            _aim.FOVCircle.Position = screenCenter
            _aim.FOVCircle.Radius = _aim.Config.FOV
            _aim.FOVCircle.Visible = _aim.Config.ShowFOV
        end
        if target and target.Part then
            local targetPosition = _aim.GetTargetPosition(target.Player, target.Part, dt)
            if targetPosition then
                if _aim.Config.ShowTargetLine and _aim.TargetLine then
                    local screenPos, onScreen = _aim.Camera:WorldToViewportPoint(targetPosition)
                    if onScreen then
                        _aim.TargetLine.From = _aim.UserInputService:GetMouseLocation()
                        _aim.TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                        _aim.TargetLine.Visible = true
                    else
                        _aim.TargetLine.Visible = false
                    end
                elseif _aim.TargetLine then
                    _aim.TargetLine.Visible = false
                end
                if _aim.Config.Aimlock or _aim.Config.AimlockToggle then
                    local isAiming = _aim.Config.AimlockToggle or _aim.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or _aim.Config.AutoFire
                    if isAiming then
                        _aim.SmoothAim(targetPosition, dt)
                    end
                end
            end
        else
            if _aim.TargetLine then _aim.TargetLine.Visible = false end
            _aim.Config.CurrentTarget = nil
        end
    end

    _aim.AimbotConnection = nil

    _aim.StartAimbot = function()
        if _aim.AimbotConnection then return end
        _aim.RunService:BindToRenderStep("TLAimbotMaster", Enum.RenderPriority.Camera.Value + 1, function(dt)
            if _aim.Config.Enabled then
                _aim.PerformAimbot(dt)
            else
                _aim.StopAimbot()
            end
        end)
        _aim.AimbotConnection = true
    end

    _aim.StopAimbot = function()
        if _aim.AimbotConnection then
            _aim.RunService:UnbindFromRenderStep("TLAimbotMaster")
            _aim.AimbotConnection = nil
        end
        if _aim.FOVCircle then _aim.FOVCircle.Visible = false end
        if _aim.TargetLine then _aim.TargetLine.Visible = false end
        _aim.Config.CurrentTarget = nil
    end

    _aim.TriggerBotConnection = nil

    _aim.StartTriggerBot = function()
        if _aim.TriggerBotConnection then return end
        _aim.TriggerBotConnection = _aim.RunService.Heartbeat:Connect(function()
            if not _aim.Config.TriggerBot or not _aim.Config.Enabled then return end
            local target = _aim.GetBestTarget()
            if target and target.Distance < 50 then
            end
        end)
    end

    _aim.StopTriggerBot = function()
        if _aim.TriggerBotConnection then
            _aim.TriggerBotConnection:Disconnect()
            _aim.TriggerBotConnection = nil
        end
    end

    _aim.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 and _aim.Config.Enabled then
            _aim.Config.Aimlock = true
        end
    end)

    _aim.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            _aim.Config.Aimlock = false
        end
    end)
end

function M.getConfig()
    return _aim.Config
end

function M.start()
    _aim.Config.Enabled = true
    _aim.StartAimbot()
end

function M.stop()
    _aim.Config.Enabled = false
    _aim.StopAimbot()
end

function M.setSilentAim(on)
    _aim.Config.SilentAim = on
end

function M.setAimlockToggle(on)
    _aim.Config.AimlockToggle = on
end

function M.setWallCheck(on)
    _aim.Config.WallCheck = on
end

function M.setShowFOV(on)
    _aim.Config.ShowFOV = on
end

function M.setShowTargetLine(on)
    _aim.Config.ShowTargetLine = on
end

function M.setTeamCheck(on)
    _aim.Config.TeamCheck = on
end

function M.setAutoFire(on)
    _aim.Config.AutoFire = on
end

function M.setTriggerBot(on)
    _aim.Config.TriggerBot = on
    if on then _aim.StartTriggerBot() else _aim.StopTriggerBot() end
end

function M.setFOV(fov)
    _aim.Config.FOV = fov
end

function M.setSmoothness(s)
    _aim.Config.Smoothness = s
end

return M
