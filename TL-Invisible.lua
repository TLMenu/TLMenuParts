local ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_InvisRuntime"
local prev = ENV[RUNTIME_KEY]
if type(prev) == "table" and type(prev.cleanup) == "function" then 
    pcall(prev.cleanup) 
end

local runtime = { connections = {}, instances = {}, destroyed = false }
runtime.cleanup = function()
    if runtime.destroyed then return end
    runtime.destroyed = true
    for _, c in ipairs(runtime.connections) do pcall(function() c:Disconnect() end) end
    runtime.connections = {}
    for i = #runtime.instances, 1, -1 do
        pcall(function() 
            local inst = runtime.instances[i]
            if inst and inst.Parent then inst:Destroy() end 
        end)
    end
    runtime.instances = {}
    
    pcall(function() game:GetService("RunService"):UnbindFromRenderStep("__TL_InvisRender") end)
    
    if ENV[RUNTIME_KEY] == runtime then ENV[RUNTIME_KEY] = nil end
end
ENV[RUNTIME_KEY] = runtime

local function regInst(inst) table.insert(runtime.instances, inst); return inst end
local function bind(sig, fn) local c = sig:Connect(fn); table.insert(runtime.connections, c); return c end

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")

local lp = Players.LocalPlayer

local invisActive     = false
local invisParts      = {}
local invisHeartConn  = nil
local _invisHL        = nil
local _invisSavedCF   = nil

-- Movement tracking: capture input before teleport so movement works
local _lastMoveDir    = Vector3.zero
local _lastVelocity   = Vector3.zero

local function makeInvisSelfHL(ch)
    local PlayerGui = lp:FindFirstChild("PlayerGui")
    if not PlayerGui then return nil end
    local ok, hl = pcall(function()
        local h               = Instance.new("Highlight")
        h.Adornee             = ch
        h.FillColor           = Color3.fromRGB(220, 235, 255)
        h.OutlineColor        = Color3.fromRGB(255, 255, 255)
        h.FillTransparency    = 0.85
        h.OutlineTransparency = 1.0
        h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent              = PlayerGui
        return h
    end)
    if ok and hl and hl.Parent then return hl end
    local ok2, sb = pcall(function()
        local s               = Instance.new("SelectionBox")
        s.Adornee             = ch:FindFirstChild("HumanoidRootPart") or ch
        s.Color3              = Color3.fromRGB(255, 255, 255)
        s.LineThickness       = 0.0
        s.SurfaceTransparency = 0.85
        s.SurfaceColor3       = Color3.fromRGB(220, 235, 255)
        s.Parent              = PlayerGui
        return s
    end)
    if ok2 and sb and sb.Parent then return sb end
    return nil
end

local function invisSetupParts()
    if invisActive and #invisParts > 0 then return end
    
    invisParts = {}
    local ch = lp.Character
    if not ch then return end
    for _, d in ipairs(ch:GetDescendants()) do
        if d:IsA("BasePart") and d.Transparency < 0.9 then
            table.insert(invisParts, { part = d, origTransp = d.Transparency })
        end
    end
end

local function startInvisHeartbeat()
    local cachedChar = lp.Character
    local cachedHum  = cachedChar and cachedChar:FindFirstChildOfClass("Humanoid")
    local cachedRoot = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
    
    local targetCF = nil
    local origOff  = Vector3.zero
    local isDesynced = false
    local savedRealCF = nil
    
    RunService:BindToRenderStep("__TL_InvisRender", Enum.RenderPriority.Camera.Value - 1, function()
        if isDesynced and cachedRoot and cachedRoot.Parent and cachedHum and cachedHum.Parent then
            -- Restore visual position for local player
            cachedRoot.CFrame       = targetCF
            cachedHum.CameraOffset  = origOff
            isDesynced = false
        end
    end)

    invisHeartConn = RunService.Heartbeat:Connect(function(dt)
        local c = lp.Character
        if c ~= cachedChar then
            cachedChar = c
            cachedHum  = c and c:FindFirstChildOfClass("Humanoid")
            cachedRoot = c and c:FindFirstChild("HumanoidRootPart")
        end
        local h = cachedHum
        local r = cachedRoot
        if not (invisActive and h and r) then return end

        if h.Health <= 0 or not c.Parent then
            h.CameraOffset = Vector3.zero
            return
        end

        if h.SeatPart ~= nil then return end

        for _, entry in ipairs(invisParts) do
            local part = entry.part
            if part and part.Parent and part.Transparency < 0.98 then
                part.Transparency = 0.99
            end
        end

        local curCF = r.CFrame
        if curCF.Position.Y > -100000 then
            _invisSavedCF = curCF
        end

        -- CAPTURE movement input BEFORE teleport
        -- At extreme Y the Humanoid can't process input, so read it while still at normal pos
        local moveDir  = h.MoveDirection
        local vel      = r.AssemblyLinearVelocity

        -- Use MoveDirection if available, otherwise keep last known
        if moveDir.Magnitude > 0.05 then
            _lastMoveDir = moveDir
        end

        -- If we have savedRealCF (from previous frame's restore), calculate actual movement
        if savedRealCF and savedRealCF.Position.Y > -100000 then
            -- Apply movement to saved position
            local speed = h.WalkSpeed or 16
            local moveOffset = _lastMoveDir * speed * dt
            savedRealCF = savedRealCF + moveOffset
        end

        origOff  = h.CameraOffset
        targetCF = savedRealCF or curCF
        savedRealCF = targetCF

        if r.Parent and h.Parent then
            r.CFrame       = CFrame.new(curCF.Position.X, -200000, curCF.Position.Z)
            h.CameraOffset = Vector3.new(0, curCF.Position.Y + 200000, 0)
            isDesynced     = true
        end
    end)
end

local function setInvis(on)
    invisActive = on

    if invisHeartConn then pcall(function() invisHeartConn:Disconnect() end); invisHeartConn = nil end
    if _invisHL and _invisHL.Parent then pcall(function() _invisHL:Destroy() end); _invisHL = nil end
    
    pcall(function() RunService:UnbindFromRenderStep("__TL_InvisRender") end)

    local ch   = lp.Character
    local hum  = ch and ch:FindFirstChildOfClass("Humanoid")
    local root = ch and ch:FindFirstChild("HumanoidRootPart")

    if not on then
        if root and _invisSavedCF and root.Parent then
            root.CFrame = _invisSavedCF
            root.AssemblyLinearVelocity = Vector3.zero
        end
        if hum and hum.Parent then
            hum.CameraOffset = Vector3.zero
        end

        _lastMoveDir  = Vector3.zero
        _lastVelocity = Vector3.zero

        task.spawn(function()
            task.wait(0.05)
            for _, entry in ipairs(invisParts) do
                local part = entry.part
                if part and part.Parent then
                    part.Transparency = entry.origTransp
                end
            end
            invisParts = {}
            _invisSavedCF = nil
        end)
        return
    end

    if not ch then return end
    invisSetupParts()
    _invisHL = makeInvisSelfHL(ch)

    local initCF = root and root.CFrame
    if initCF then _invisSavedCF = initCF end

    _lastMoveDir  = Vector3.zero
    _lastVelocity = Vector3.zero

    task.spawn(function()
        if not invisActive then return end
        for _, entry in ipairs(invisParts) do
            local p = entry.part
            if p and p.Parent then p.Transparency = 0.99 end
        end
        startInvisHeartbeat()
    end)
end

bind(lp.CharacterAdded, function(newChar)
    if invisHeartConn then pcall(function() invisHeartConn:Disconnect() end); invisHeartConn = nil end
    if _invisHL and _invisHL.Parent then pcall(function() _invisHL:Destroy() end); _invisHL = nil end
    pcall(function() RunService:UnbindFromRenderStep("__TL_InvisRender") end)

    for _, entry in ipairs(invisParts) do
        if entry.part and entry.part.Parent then
            entry.part.Transparency = entry.origTransp
        end
    end
    invisParts    = {}
    _invisSavedCF = nil

    task.spawn(function()
        local newHum  = newChar:WaitForChild("Humanoid", 5)
        local newRoot = newChar:WaitForChild("HumanoidRootPart", 5)
        
        if not (newHum and newRoot) then return end
        newHum.CameraOffset = Vector3.zero
        
        task.wait(0.3)
        
        if invisActive then
            invisSetupParts()
            _invisHL = makeInvisSelfHL(newChar)
            setInvis(true)
        else
            invisSetupParts()
        end
    end)
end)

runtime.start       = function() setInvis(true) end
runtime.stop        = function() setInvis(false) end
runtime.isActive    = function() return invisActive end
runtime.setupParts  = invisSetupParts

ENV._TL_Runtime     = runtime
ENV._TL_setInvis    = setInvis
ENV._TL_invisActive = function() return invisActive end

return runtime
