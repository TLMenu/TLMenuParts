


local GLOBAL_ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_FlingRuntime"

local prev = GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY]
if type(prev) == "table" and type(prev.cleanup) == "function" then pcall(prev.cleanup) end

local runtime = { connections = {}, instances = {}, destroyed = false }
runtime.cleanup = function()
    if runtime.destroyed then return end; runtime.destroyed = true
    for _, c in ipairs(runtime.connections) do pcall(function() c:Disconnect() end) end
    runtime.connections = {}
    for i = #runtime.instances, 1, -1 do
        pcall(function() local inst = runtime.instances[i]; if inst and inst.Parent then inst:Destroy() end end)
    end
    runtime.instances = {}
    if GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY] == runtime then GLOBAL_ENV[RUNTIME_KEY] = nil end
end
if GLOBAL_ENV then GLOBAL_ENV[RUNTIME_KEY] = runtime end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer


local flingActive         = false
local flingConn           = nil
local flingSelectedPlayer = nil
local _flingSavedCFrame   = nil
local _flingThread        = nil


local function _flingDisconnect()
    flingActive = false
    if flingConn then
        pcall(function() flingConn:Disconnect() end)
        flingConn = nil
        pcall(function() if GLOBAL_ENV then GLOBAL_ENV._TLFlingConn = nil end end)
    end
    if _flingThread then
        pcall(function() task.cancel(_flingThread) end)
        _flingThread = nil
    end
end

local function _skidFling(targetPlayer)
    local Character  = lp.Character
    local Humanoid   = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart   = Humanoid and Humanoid.RootPart
    local TCharacter = targetPlayer and targetPlayer.Character
    if not Character or not Humanoid or not RootPart or not TCharacter then return end

    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead     = TCharacter:FindFirstChild("Head")
    local Handle    = (TCharacter:FindFirstChildOfClass("Accessory") or {Handle=nil}).Handle

    local BasePart = TRootPart or THead or Handle
    if not BasePart then return end

    if RootPart.Velocity.Magnitude < 50 then
        _flingSavedCFrame = RootPart.CFrame
    end
    if THumanoid and THumanoid.Sit then return end

    local savedFPDH = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0

    local BV = Instance.new("BodyVelocity")
    BV.Parent   = RootPart
    BV.Velocity = Vector3.new(0,0,0)
    BV.MaxForce = Vector3.new(9e9,9e9,9e9)

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    local FPos = function(bp, pos, ang)
        RootPart.CFrame = CFrame.new(bp.Position) * pos * ang
        pcall(function() Character:SetPrimaryPartCFrame(CFrame.new(bp.Position) * pos * ang) end)
        RootPart.Velocity          = Vector3.new(9e7, 9e7*10, 9e7)
        RootPart.RotVelocity       = Vector3.new(9e8, 9e8, 9e8)
    end

    local deadline = tick() + 2
    local angle    = 0
    repeat
        if not (RootPart and RootPart.Parent and THumanoid and THumanoid.Parent) then break end
        if BasePart.Velocity.Magnitude < 50 then
            angle = angle + 100
            FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,0)+ THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(angle),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(angle),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,0)+ THumanoid.MoveDirection, CFrame.Angles(math.rad(angle),0,0)) task.wait()
        else
            FPos(BasePart, CFrame.new(0,1.5, THumanoid.WalkSpeed),  CFrame.Angles(math.rad(90),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,-THumanoid.WalkSpeed), CFrame.Angles(0,0,0))             task.wait()
            FPos(BasePart, CFrame.new(0,1.5, THumanoid.WalkSpeed),  CFrame.Angles(math.rad(90),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) task.wait()
            FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0))             task.wait()
        end
    until tick() > deadline or not flingActive

    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

    if _flingSavedCFrame and RootPart and RootPart.Parent then
        local tries = 0
        repeat
            pcall(function()
                RootPart.CFrame = _flingSavedCFrame * CFrame.new(0,0.5,0)
                Character:SetPrimaryPartCFrame(_flingSavedCFrame * CFrame.new(0,0.5,0))
                Humanoid:ChangeState("GettingUp")
                for _, part in ipairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity    = Vector3.zero
                        part.RotVelocity = Vector3.zero
                    end
                end
            end)
            task.wait()
            tries = tries + 1
        until (RootPart.Position - _flingSavedCFrame.p).Magnitude < 25 or tries > 30
    end

    workspace.FallenPartsDestroyHeight = savedFPDH
end

local function flingStop()
    _flingDisconnect()
    local savedCF = _flingSavedCFrame
    _flingSavedCFrame = nil
    task.spawn(function()
        task.wait(0.08)
        pcall(function()
            local ch  = lp.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local hrp = hum and hum.RootPart
            if not hum or not hrp then return end
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Running, true) end)
            pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
            hum.PlatformStand = false
            for _, p in ipairs(ch:GetChildren()) do
                if p:IsA("BasePart") then
                    pcall(function() p.Velocity = Vector3.zero end)
                    pcall(function() p.RotVelocity = Vector3.zero end)
                    pcall(function() p.AssemblyLinearVelocity = Vector3.zero end)
                    pcall(function() p.AssemblyAngularVelocity = Vector3.zero end)
                end
            end
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BodyVelocity") or p:IsA("BodyGyro") or p:IsA("BodyPosition") then
                    pcall(function() p:Destroy() end)
                end
            end
            if savedCF then
                for attempt = 1, 15 do
                    pcall(function()
                        hrp.CFrame = savedCF * CFrame.new(0, 0.5, 0)
                        ch:SetPrimaryPartCFrame(savedCF * CFrame.new(0, 0.5, 0))
                    end)
                    task.wait(0.05)
                    if (hrp.Position - savedCF.p).Magnitude < 10 then break end
                end
            end
            task.wait(0.05)
            hum.PlatformStand = false
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            task.wait(0.1)
            hum.PlatformStand = false
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
        end)
    end)
end

local function flingStart(targetPlayer)
    _flingDisconnect()
    if not targetPlayer then return end
    pcall(function()
        local ch  = lp.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then _flingSavedCFrame = hrp.CFrame end
    end)
    flingActive = true
    _flingThread = task.spawn(function()
        while flingActive do
            _skidFling(targetPlayer)
            if flingActive then task.wait(0.1) end
        end
    end)
    pcall(function() if GLOBAL_ENV then GLOBAL_ENV._TLFlingConn = flingConn end end)
end


local API = {}

API.start = function(targetPlayer)
    flingSelectedPlayer = targetPlayer
    flingStart(targetPlayer)
end

API.stop = function()
    flingStop()
end

API.isActive = function() return flingActive end

API.getSelected = function() return flingSelectedPlayer end

API.setSelected = function(player) flingSelectedPlayer = player end

API.cleanup = function()
    flingStop()
    runtime.cleanup()
end


local function onCharacterAdded()
    _flingSavedCFrame = nil
    flingStop()
    flingSelectedPlayer = nil
end
local conn = lp.CharacterAdded:Connect(onCharacterAdded)
table.insert(runtime.connections, conn)


if GLOBAL_ENV then
    GLOBAL_ENV._TL_setFling    = API.start
    GLOBAL_ENV._TL_flingActive = API.isActive
end

runtime.start    = API.start
runtime.stop     = API.stop
runtime.isActive = API.isActive

return API
