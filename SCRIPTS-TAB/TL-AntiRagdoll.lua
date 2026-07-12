local M = {}
local _cfg = {}
local _enabled = false
local _conn = nil

local function startInternal()
    if _conn then return end
    local _arChar, _arMotor6Ds = nil, {}
    local RS = _cfg.RunService
    local LP = _cfg.LocalPlayer
    _conn = RS.Heartbeat:Connect(function()
        if not _enabled then return end
        local character = LP.Character
        if not character then _arChar = nil; return end
        if character ~= _arChar then
            _arChar = character
            _arMotor6Ds = {}
            for _, v in pairs(character:GetChildren()) do
                if v:IsA("Motor6D") then _arMotor6Ds[#_arMotor6Ds + 1] = v end
            end
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local flyActive = _cfg.flyActiveFn and _cfg.flyActiveFn() or false
        if humanoid.PlatformStand and not flyActive then humanoid.PlatformStand = false end
        if humanoid.Sit and not flyActive then humanoid.Sit = false end
        for _, v in pairs(_arMotor6Ds) do
            if v.Parent ~= character then
                v.Parent = character
            end
        end
    end)
end

local function stopInternal()
    _enabled = false
    if _conn then
        _conn:Disconnect()
        _conn = nil
    end
end

function M.init(cfg)
    _cfg = cfg or {}
end

function M.start()
    _enabled = true
    startInternal()
end

function M.stop()
    stopInternal()
end

return M
