local M = {}
local _cfg = {}
local _active = false
local _speed = 50
local _mode = "Dash Fling"
local _anims = {
    ["Dash Fling"]    = "130847442125893",
    ["Tornado Fling"] = "83769457908471",
    ["Mini-Train"]    = "75460531474787",
}
local _modeList = { "Dash Fling", "Tornado Fling", "Mini-Train" }
local _track = nil
local _conn = nil
local _noCol = {}
local _origWS, _origJP = 16, 50

local function playAnim()
    local LP = _cfg.LocalPlayer
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if _track then
        pcall(function() _track:Stop() end); _track = nil
    end
    local animId = _anims[_mode]
    pcall(function()
        if _cfg._AF_loadAndPlayAnimation then
            _track = _cfg._AF_loadAndPlayAnimation(hum, animId)
        end
        if _track then
            _track:AdjustSpeed(_speed / 16)
            _track:Play()
        end
    end)
end

local function stop()
    _active = false
    if _conn then
        _conn:Disconnect(); _conn = nil
    end
    if _track then
        pcall(function() _track:Stop() end); _track = nil
    end
    local LP = _cfg.LocalPlayer
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and _origWS then
        hum.WalkSpeed = _origWS; hum.JumpPower = _origJP
    end
    _noCol = {}
    for _, p in ipairs(_cfg.Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end
            end
        end
    end
end

local function step(dt)
    local LP = _cfg.LocalPlayer
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.WalkSpeed = _speed
    hum.JumpPower = _speed * 1.5
    if not _track or not _track.IsPlaying then playAnim() end
    if _track then _track:AdjustSpeed(_speed / 16) end

    local vel = hrp.Velocity
    hrp.Velocity = vel * 9e9 + Vector3.new(0, 9e9, 0)
    _cfg.RunService.RenderStepped:Wait()
    hrp.Velocity = vel
end

task.spawn(function()
    while task.wait(0.25) do
        if not _active then continue end
        pcall(function()
            for _, p in ipairs(_cfg.Players:GetPlayers()) do
                if p ~= _cfg.LocalPlayer and p.Character then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    end
end)

function M.init(cfg)
    _cfg = cfg or {}
end

function M.start()
    _active = true
    local LP = _cfg.LocalPlayer
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        _origWS = hum.WalkSpeed; _origJP = hum.JumpPower
    end
    if _cfg.flyMuteSoundsFn then _cfg.flyMuteSoundsFn(true) end
    _conn = _cfg.RunService.Heartbeat:Connect(step)
end

function M.stop()
    stop()
    if _cfg.flyMuteSoundsFn then _cfg.flyMuteSoundsFn(false) end
end

function M.getMode()
    return _mode
end

function M.getModes()
    return _modeList
end

function M.setMode(m)
    _mode = m
    if _active then playAnim() end
end

function M.isActive()
    return _active
end

return M
