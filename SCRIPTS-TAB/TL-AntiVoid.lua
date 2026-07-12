local M = {}
local _cfg = {}
local _active = false
local _conn = nil
local _charConn = nil
local _lastCF = nil
local _rescuing = false
local _lastRescue = 0
local _char = nil
local _hrp = nil
local _hum = nil
local _acc = 0
local VOID_Y = -200

local function stop()
    _active = false
    _rescuing = false
    if _conn then _conn:Disconnect(); _conn = nil end
    if _charConn then _charConn:Disconnect(); _charConn = nil end
end

local function start()
    stop()
    _active = true
    _lastCF = nil
    _rescuing = false
    _acc = 0
    local LP = _cfg.LocalPlayer
    _charConn = LP.CharacterAdded:Connect(function()
        _lastCF = nil
        _rescuing = false
    end)
    _char = LP.Character
    _hrp = _char and _char:FindFirstChild("HumanoidRootPart")
    _hum = _char and _char:FindFirstChildOfClass("Humanoid")
    local RS = _cfg.RunService
    _conn = RS.Heartbeat:Connect(function(dt)
        if not _active then return end
        if _rescuing then return end
        _acc = _acc + dt
        if _acc < 0.1 then return end
        _acc = 0
        local char = LP.Character
        if not char then return end
        if char ~= _char then
            _char = char
            _hrp = char:FindFirstChild("HumanoidRootPart")
            _hum = char:FindFirstChildOfClass("Humanoid")
            _acc = 0
        end
        local root = _hrp
        local hum = _hum
        if not root or not hum then return end
        if hum.Health <= 0 then return end
        local pos = root.Position
        if pos.Y > -100 then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Running
                or state == Enum.HumanoidStateType.RunningNoPhysics
                or state == Enum.HumanoidStateType.Landed
                or state == Enum.HumanoidStateType.Seated then
                _lastCF = root.CFrame + Vector3.new(0, 3, 0)
            end
            return
        end
        if pos.Y >= VOID_Y then return end
        local now = os.clock()
        if now - _lastRescue < 2 then return end
        _lastRescue = now
        _rescuing = true
        local target = _lastCF
        if not target then
            local spawnLoc = workspace:FindFirstChildOfClass("SpawnLocation")
            target = spawnLoc and spawnLoc.CFrame * CFrame.new(0, 8, 0)
                or CFrame.new(0, 10, 0)
        end
        pcall(function()
            root.CFrame = target
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
        if _cfg.sendNotif then _cfg.sendNotif("Anti-Void", " Void detected Saved!", 2) end
        task.delay(0.5, function()
            _rescuing = false
        end)
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

return M
