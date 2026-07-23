local ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_InvisRuntime"

-- Altes Runtime-Cleanup
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
    if ENV[RUNTIME_KEY] == runtime then ENV[RUNTIME_KEY] = nil end
end
ENV[RUNTIME_KEY] = runtime

local function regInst(inst) table.insert(runtime.instances, inst); return inst end
local function bind(sig, fn) local c = sig:Connect(fn); table.insert(runtime.connections, c); return c end

-- [Punkt 3] CoreGui entfernt (wurde nie verwendet)
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")

local lp = Players.LocalPlayer

local _hasRenderStepped = pcall(function()
    local c = RunService.RenderStepped:Connect(function() end); c:Disconnect()
end)

local invisActive     = false
local invisParts      = {}
local invisHeartConn  = nil
local _invisHL        = nil
local _invisSavedCF   = nil
-- [Punkt 3 & 4] _invGhostConn und _invisHealthConn komplett entfernt

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
    -- [Punkt 5] Schutz vor Überschreiben der Originalwerte, wenn Unsichtbarkeit bereits aktiv ist
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
    
    invisHeartConn = RunService.Heartbeat:Connect(function()
        local c = lp.Character
        if c ~= cachedChar then
            cachedChar = c
            cachedHum  = c and c:FindFirstChildOfClass("Humanoid")
            cachedRoot = c and c:FindFirstChild("HumanoidRootPart")
        end
        local h = cachedHum
        local r = cachedRoot
        if not (invisActive and h and r) then return end

        -- [Punkt 2] pcall entfernt, direkte Prüfung auf Parent & Health
        if h.Health <= 0 or not c.Parent then
            h.CameraOffset = Vector3.zero
            return
        end

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

        -- [Punkt 2] pcalls durch schnelle Existenzprüfungen (Parent) im Loop ersetzt
        local origOff = h.CameraOffset
        if r.Parent and h.Parent then
            r.CFrame       = CFrame.new(curCF.Position.X, -200000, curCF.Position.Z)
            h.CameraOffset = Vector3.new(0, curCF.Position.Y + 200000, 0)
        end

        task.spawn(function()
            if _hasRenderStepped then
                RunService.RenderStepped:Wait()
            else
                task.wait()
            end
            -- [Punkt 2] pcall im Render-Frame entfernt
            if r and r.Parent and h and h.Parent then
                r.CFrame       = curCF
                h.CameraOffset = origOff
            end
        end)
    end)
end

local function setInvis(on)
    invisActive = on

    if invisHeartConn then pcall(function() invisHeartConn:Disconnect() end); invisHeartConn = nil end
    if _invisHL and _invisHL.Parent then pcall(function() _invisHL:Destroy() end); _invisHL = nil end

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

    -- [Punkt 4] Der nutzlose clientseitige Health-Loop wurde hier komplett entfernt

    local initCF = root and root.CFrame
    if initCF then _invisSavedCF = initCF end

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

    for _, entry in ipairs(invisParts) do
        if entry.part and entry.part.Parent then
            entry.part.Transparency = entry.origTransp
        end
    end
    invisParts    = {}
    _invisSavedCF = nil

    task.defer(function()
        local newHum = newChar:FindFirstChildOfClass("Humanoid")
        if newHum then newHum.CameraOffset = Vector3.zero end
    end)

    task.wait(0.5)
    if invisActive then
        invisSetupParts()
        _invisHL = makeInvisSelfHL(newChar)
        setInvis(true)
    else
        task.wait(0.5)
        invisSetupParts()
    end
end)

-- [Punkt 9] Sauberes, einheitliches Environment-Binding über eine zentrale Tabelle
runtime.start      = function() setInvis(true) end
runtime.stop       = function() setInvis(false) end
runtime.isActive   = function() return invisActive end
runtime.setupParts = invisSetupParts

ENV._TL_Runtime    = runtime
ENV._TL_setInvis   = setInvis
ENV._TL_invisActive = function() return invisActive end

return runtime
