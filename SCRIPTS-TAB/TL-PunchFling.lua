local M = {}
local _cfg = {}
local _tool = nil
local _active = false
local _flingActive = false
local _loopRunning = false
local _cleanupList = {}
local _diedConn = nil

local function addToCleanup(obj)
    table.insert(_cleanupList, obj)
end

local function loadAnimation(humanoid, animId)
    if not humanoid then return nil end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
        addToCleanup(animator)
    end
    local resolvedId = "rbxassetid://" .. animId
    pcall(function()
        local objects = game:GetObjects("rbxassetid://" .. animId)
        if objects and objects[1] then
            local obj = objects[1]
            if obj:IsA("Animation") then
                resolvedId = obj.AnimationId
            else
                local child = obj:FindFirstChildOfClass("Animation")
                if child then
                    resolvedId = child.AnimationId
                end
            end
            obj.Parent = workspace
            addToCleanup(obj)
            task.delay(2, function()
                pcall(function() obj:Destroy() end)
            end)
        end
    end)
    local anim = Instance.new("Animation")
    anim.AnimationId = resolvedId
    addToCleanup(anim)
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = false
    return track
end

local function findPart(p3, p4, p5)
    local u6 = nil
    pcall(function()
        for _, v11 in pairs(p3:GetChildren()) do
            if v11.Name == p4 and v11:IsA(p5) then
                u6 = v11
                break
            end
        end
    end)
    return u6
end

local function dash(hrp)
    if hrp then
        local dir = hrp.CFrame.LookVector
        hrp.Velocity = dir * 120
        hrp.CFrame = hrp.CFrame + (dir * 2)
    end
end

local function cleanup()
    _loopRunning = false
    _flingActive = false
    if _tool then
        pcall(function() _tool:Destroy() end); _tool = nil
    end
    if _diedConn then
        pcall(function() _diedConn:Disconnect() end); _diedConn = nil
    end
    for _, obj in ipairs(_cleanupList) do
        pcall(function() obj:Destroy() end)
    end
    _cleanupList = {}
end

local function startTool()
    if _tool then return end
    local LP = _cfg.Players.LocalPlayer
    local char = LP.Character
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 3)
    local hrp = char:WaitForChild("HumanoidRootPart", 3)
    if not hum or not hrp then return end

    _tool = Instance.new("Tool")
    _tool.RequiresHandle = false
    _tool.Name = "TLPunchFling"
    _tool.TextureId = "rbxassetid://139541574667160"
    _tool.Parent = LP.Backpack

    _loopRunning = true
    _flingActive = false

    task.spawn(function()
        local v20 = nil
        local v21 = nil
        local v22 = 0.1
        while _loopRunning do
            _cfg.RunService.Heartbeat:Wait()
            if _flingActive then
                while _flingActive and _loopRunning and not (v20 and v20.Parent and v21 and v21.Parent) do
                    _cfg.RunService.Heartbeat:Wait()
                    v20 = LP.Character
                    if v20 then
                        v21 = findPart(v20, "HumanoidRootPart", "BasePart")
                            or findPart(v20, "Torso", "BasePart")
                            or findPart(v20, "UpperTorso", "BasePart")
                    end
                end
                if _loopRunning and _flingActive and v21 and v21.Parent then
                    local _Velocity = v21.Velocity
                    v21.AssemblyLinearVelocity = _Velocity * 100 +
                    Vector3.new(99999999, 99999999, 99999999)
                    v21.CFrame = v21.CFrame * CFrame.new(0, 0.001, 0)
                    _cfg.RunService.RenderStepped:Wait()
                    if v20 and v20.Parent and v21 and v21.Parent then
                        v21.Velocity = _Velocity
                    end
                    _cfg.RunService.Stepped:Wait()
                    if v20 and v20.Parent and v21 and v21.Parent then
                        v21.Velocity = _Velocity + Vector3.new(0, v22, 0)
                        v22 = v22 * -1
                    end
                end
            end
        end
    end)

    _tool.Activated:Connect(function()
        if _flingActive then return end
        local track1 = loadAnimation(hum, "116450987409557")
        local track2 = loadAnimation(hum, "75981039646929")
        if track1 then
            track1:Play()
            track1.Stopped:Wait()
        end
        dash(hrp)
        if track2 then track2:Play() end
        _flingActive = true
        task.wait(1.5)
        _flingActive = false
    end)

    _diedConn = hum.Died:Connect(function()
        cleanup()
    end)
end

function M.init(cfg)
    _cfg = cfg or {}
end

function M.start()
    _active = true
    startTool()
end

function M.stop()
    cleanup()
end

function M.isActive()
    return _active
end

return M
