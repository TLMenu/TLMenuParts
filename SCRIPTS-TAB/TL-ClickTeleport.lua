local M = {}
local _cfg = {}
local _active = false
local _conn = nil
local _hoverConn = nil
local _rp = nil
local _dot = nil

local function createDot()
    if _dot and _dot.Parent then return end
    _dot = Instance.new("Part")
    _dot.Name = "TLClickTeleportDot"
    _dot.Shape = Enum.PartType.Ball
    _dot.Size = Vector3.new(0.5, 0.5, 0.5)
    _dot.Material = Enum.Material.Neon
    _dot.Color = Color3.fromRGB(255, 40, 40)
    _dot.CanCollide = false
    _dot.CastShadow = false
    _dot.Transparency = 0.15
    _dot.Parent = workspace
    local _dotT = 0
    task.spawn(function()
        while _dot and _dot.Parent and _active do
            _dotT = _dotT + task.wait()
            local pulse = 0.10 + math.abs(math.sin(_dotT * 3)) * 0.25
            if _dot and _dot.Parent then
                _dot.Transparency = pulse
            end
        end
    end)
end

local function destroyDot()
    if _dot then
        pcall(function() _dot:Destroy() end)
        _dot = nil
    end
end

local function rayFromMouse()
    local LP = _cfg.LocalPlayer
    local char = LP.Character
    local cam = workspace.CurrentCamera
    if not char or not cam then return nil end
    local UIS = _cfg.UserInputService
    local screenPos
    pcall(function() screenPos = UIS:GetMouseLocation() end)
    if not screenPos then return nil end
    local ray = cam:ViewportPointToRay(screenPos.X, screenPos.Y)
    _rp.FilterDescendantsInstances = { char }
    return workspace:Raycast(ray.Origin, ray.Direction * 2000, _rp)
end

local function stopHover()
    if _hoverConn then
        _hoverConn:Disconnect(); _hoverConn = nil
    end
    destroyDot()
end

local function startHover()
    stopHover()
    createDot()
    local RS = _cfg.RunService
    _hoverConn = RS.Heartbeat:Connect(function()
        if not _active then
            stopHover(); return
        end
        local result = rayFromMouse()
        if result and _dot and _dot.Parent then
            local tp = result.Position + result.Normal * 2.5
            _dot.CFrame = CFrame.new(tp)
            _dot.Visible = true
        elseif _dot and _dot.Parent then
            _dot.Visible = false
        end
    end)
end

local function stop()
    _active = false
    if _conn then
        _conn:Disconnect(); _conn = nil
    end
    stopHover()
end

local function start()
    stop()
    _active = true
    _rp = RaycastParams.new()
    _rp.FilterType = Enum.RaycastFilterType.Exclude
    startHover()
    local LP = _cfg.LocalPlayer
    local UIS = _cfg.UserInputService
    _conn = UIS.InputBegan:Connect(function(inp, gpe)
        if not _active then return end
        if gpe then return end
        local isMouse = inp.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = inp.UserInputType == Enum.UserInputType.Touch
        if not isMouse and not isTouch then return end

        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local result
        if isMouse then
            result = rayFromMouse()
        else
            local cam = workspace.CurrentCamera
            if cam then
                local sp = Vector2.new(inp.Position.X, inp.Position.Y)
                local ray = cam:ViewportPointToRay(sp.X, sp.Y)
                _rp.FilterDescendantsInstances = { char }
                result = workspace:Raycast(ray.Origin, ray.Direction * 2000, _rp)
            end
        end

        if result then
            local tp = result.Position + result.Normal * 2.5
            pcall(function() hrp.CFrame = CFrame.new(tp) end)
        end
    end)
end

function M.init(cfg)
    _cfg = cfg or {}
end

function M.start()
    start()
end

function M.stop()
    stop()
end

function M.isActive()
    return _active
end

return M
