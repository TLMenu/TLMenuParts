local GLOBAL_ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_FlyRuntime"

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
local function regInst(inst) table.insert(runtime.instances, inst); return inst end
local function bind(sig, fn) local c = sig:Connect(fn); table.insert(runtime.connections, c); return c end

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local Camera        = workspace.CurrentCamera
local lp            = Players.LocalPlayer


local _FALLBACK_C = {
    bg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20),
    bg2 = Color3.fromRGB(20, 20, 20), bg3 = Color3.fromRGB(28, 28, 28),
    accent = Color3.fromRGB(0, 200, 255), accent2 = Color3.fromRGB(0, 160, 220),
    text = Color3.fromRGB(210, 235, 255), sub = Color3.fromRGB(0, 135, 195),
}
local function getC()
    local g = (typeof(getgenv) == "function" and getgenv()) or _G
    return (g and g.C) or _FALLBACK_C
end
local C = getC()


local function corner(obj, r)
    local c = Instance.new("UICorner", obj); c.CornerRadius = UDim.new(0, r); return c
end

local function makeDummyStroke(obj)
    local s = Instance.new("UIStroke", obj)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = C.accent; s.Thickness = 1.2; s.Transparency = 0.35
    return s
end

local function loadTrackFromId(id)
    if not id or tostring(id) == "" or tostring(id) == "nil" then return nil end
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    local resolvedId = "rbxassetid://" .. id
    pcall(function()
        local objects = game:GetObjects(resolvedId)
        if objects and objects[1] then
            if objects[1]:IsA("Animation") then
                resolvedId = objects[1].AnimationId
            elseif objects[1]:FindFirstChildOfClass("Animation") then
                resolvedId = objects[1]:FindFirstChildOfClass("Animation").AnimationId
            end
            objects[1].Parent = workspace; task.delay(0.5,
                function() pcall(function() objects[1]:Destroy() end) end)
        end
    end)
    local anim = Instance.new("Animation"); anim.AnimationId = resolvedId
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action4
    track.Looped = true
    return track
end


local controlModule = nil
pcall(function()
    local PlayerScripts = lp:WaitForChild("PlayerScripts", 4)
    if PlayerScripts then
        local PM = PlayerScripts:FindFirstChild("PlayerModule")
        if PM then
            local CM = require(PM)
            if CM and CM.GetControls then
                controlModule = CM:GetControls()
            elseif CM and CM.GetMoveVector then
                controlModule = CM
            end
        end
    end
end)


local speedLevels = {
    { name = "GLIDE",  speed = 55,  accel = 4.0,  decel = 1.1, rampUp = 3.0, rampDown = 1.8, boostKick = 0.12, color = Color3.fromRGB(100, 200, 255), bar = 0.3 },
    { name = "NORMAL", speed = 110, accel = 8.0,  decel = 2.2, rampUp = 4.0, rampDown = 2.0, boostKick = 0.18, color = Color3.fromRGB(120, 200, 255), bar = 0.5 },
    { name = "FAST",   speed = 140, accel = 5.5,  decel = 3.5, rampUp = 2.8, rampDown = 2.4, boostKick = 0.15, color = Color3.fromRGB(255, 150, 100), bar = 0.7 },
    { name = "TURBO",  speed = 250, accel = 10.0, decel = 6.5, rampUp = 3.2, rampDown = 2.8, boostKick = 0.20, color = Color3.fromRGB(255, 80, 80),   bar = 1.0 },
}
local function getSpeedData(i) return speedLevels[i] end


local animSets = {
    { name = "TLFly",       idle = "89068086839142", fwd = "101570135818967", glide = "85697950221122", fwd2 = "115638214618522" },
    { name = "Mysterious",  idle = "121818495967360", fwd = "138488768673643", glide = "101573394483995" },
    { name = "Villain Fly", idle = "89068086839142", fwd = "134861929761233", glide = "89369893784562" },
    { name = "Superman",    idle = "107357050902519", fwd = "83739357666592", glide = "135720178713765", fwd2 = "106493972274585" },
    { name = "Halloween Fly", idle = "132315093859677", fwd = "94684994062212", glide = "131408449832678", fwd2 = "123347895201748" },
}


local _FLY_ANIM_FILE = "TLCACHE/FlyAnimSet.json"
local function _saveFlyAnimSet(idx)
    pcall(function()
        if not isfolder("TLCACHE") then makefolder("TLCACHE") end
        writefile(_FLY_ANIM_FILE, tostring(idx))
    end)
end
local function _loadFlyAnimSet()
    local ok, val = pcall(function()
        if isfile and isfile(_FLY_ANIM_FILE) then
            return tonumber(readfile(_FLY_ANIM_FILE))
        end
    end)
    return (ok and val) and math.clamp(val, 1, #animSets) or nil
end

local _flyCache = workspace:FindFirstChild("_TL_FlyCache")
local _wsWasFresh = false
if not _flyCache then
    _flyCache = Instance.new("Folder"); _flyCache.Name = "_TL_FlyCache"; _flyCache.Parent = workspace; _wsWasFresh = true
end
local _cacheAnimIdx = _flyCache:FindFirstChild("AnimSetIndex")
if not _cacheAnimIdx then
    _cacheAnimIdx = Instance.new("NumberValue"); _cacheAnimIdx.Name = "AnimSetIndex"; _cacheAnimIdx.Value = 1; _cacheAnimIdx.Parent = _flyCache; _wsWasFresh = true
end
if _wsWasFresh then
    local saved = _loadFlyAnimSet()
    if saved then _cacheAnimIdx.Value = saved else _cacheAnimIdx.Value = 1 end
end
local currentAnimSet = math.clamp(_cacheAnimIdx.Value, 1, #animSets)
local animSetButtons = {}


task.spawn(function()
    for _, _ in ipairs(animSets) do
        pcall(function()
            local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:LoadAnimation(Instance.new("Animation")):Destroy() end
        end)
    end
end)


local flying       = false
local flyActive    = false
local noclipFly    = false
local hasBoosted   = false
local speedIndex   = 1
local ctrl         = { f = 0, b = 0, l = 0, r = 0, u = 0, d = 0 }
local bg, bv, updateFlyPanel = nil, nil, nil


C = getC()  
local flyScreenGui = regInst(Instance.new("ScreenGui"))
flyScreenGui.Name = "TL_Fly_Gui"
pcall(function() flyScreenGui.Parent = game:GetService("CoreGui") end)
if not flyScreenGui.Parent then pcall(function() flyScreenGui.Parent = lp:WaitForChild("PlayerGui") end) end
flyScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
flyScreenGui.ResetOnSpawn   = false


-- ================================================================
--  MODERN FLOATING CYBER-GLASS FLY HUD BAR
-- ================================================================

local Wrapper = Instance.new("Frame")
Wrapper.Name = "Wrapper"
Wrapper.Size = UDim2.new(0, 620, 0, 44)
Wrapper.AnchorPoint = Vector2.new(0.5, 0)
Wrapper.Position = UDim2.new(0.5, 0, 0, 14)
Wrapper.BackgroundTransparency = 1
Wrapper.BorderSizePixel = 0
Wrapper.Active = true
Wrapper.Draggable = false
Wrapper.Parent = flyScreenGui
Wrapper.Visible = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 13, 19)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 2
MainFrame.Parent = Wrapper
corner(MainFrame, 14)

local mGrad = Instance.new("UIGradient", MainFrame)
mGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 27, 38)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(14, 15, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 10, 14))
})
mGrad.Rotation = 90

local mStroke = Instance.new("UIStroke", MainFrame)
mStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mStroke.Color = C.accent
mStroke.Thickness = 1.3
mStroke.Transparency = 0.35

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Size = UDim2.new(1, 0, 1, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.ZIndex = 3
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ButtonContainer

local UIPad = Instance.new("UIPadding")
UIPad.PaddingLeft = UDim.new(0, 10)
UIPad.PaddingRight = UDim.new(0, 10)
UIPad.Parent = ButtonContainer

-- -- 1. DRAG HANDLE --
local DragHandle = Instance.new("TextButton")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(0, 14, 0, 26)
DragHandle.BackgroundTransparency = 1
DragHandle.Text = ""
DragHandle.LayoutOrder = 0
DragHandle.ZIndex = 4
DragHandle.Parent = ButtonContainer

local gripBar1 = Instance.new("Frame", DragHandle)
gripBar1.Name = "GripBar1"
gripBar1.Size = UDim2.new(0, 2, 0, 14)
gripBar1.Position = UDim2.new(0.5, -3, 0.5, -7)
gripBar1.BackgroundColor3 = Color3.fromRGB(80, 85, 105)
gripBar1.BorderSizePixel = 0
gripBar1.ZIndex = 5
corner(gripBar1, 1)

local gripBar2 = Instance.new("Frame", DragHandle)
gripBar2.Name = "GripBar2"
gripBar2.Size = UDim2.new(0, 2, 0, 14)
gripBar2.Position = UDim2.new(0.5, 1, 0.5, -7)
gripBar2.BackgroundColor3 = Color3.fromRGB(80, 85, 105)
gripBar2.BorderSizePixel = 0
gripBar2.ZIndex = 5
corner(gripBar2, 1)

local isDragging = false
local dragStart = Vector3.zero
local startPos = Wrapper.Position
local targetPos = Wrapper.Position

local function startDrag(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = inp.Position
        startPos = Wrapper.Position
        targetPos = Wrapper.Position
    end
end

bind(DragHandle.InputBegan, startDrag)
bind(MainFrame.InputBegan, startDrag)

bind(UIS.InputChanged, function(inp)
    if isDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        local vp = Camera.ViewportSize
        local newX = math.clamp(startPos.X.Offset + delta.X, -(vp.X / 2) + 310, (vp.X / 2) - 310)
        local newY = math.clamp(startPos.Y.Offset + delta.Y, 5, vp.Y - 60)
        targetPos = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
    end
end)

bind(UIS.InputEnded, function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

bind(RunService.RenderStepped, function(dt)
    if isDragging or (Wrapper.Position.X.Offset ~= targetPos.X.Offset or Wrapper.Position.Y.Offset ~= targetPos.Y.Offset) then
        local factor = math.clamp(1 - math.exp(-28 * dt), 0, 1)
        Wrapper.Position = Wrapper.Position:Lerp(targetPos, factor)
    end
end)
bind(DragHandle.MouseEnter, function()
    TweenService:Create(gripBar1, TweenInfo.new(0.15), { BackgroundColor3 = C.accent }):Play()
    TweenService:Create(gripBar2, TweenInfo.new(0.15), { BackgroundColor3 = C.accent }):Play()
end)
bind(DragHandle.MouseLeave, function()
    TweenService:Create(gripBar1, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(80, 85, 105) }):Play()
    TweenService:Create(gripBar2, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(80, 85, 105) }):Play()
end)

-- -- 2. BRAND & STATUS BADGE --
local InfoCont = Instance.new("Frame")
InfoCont.Name = "InfoCont"
InfoCont.Size = UDim2.new(0, 112, 0, 32)
InfoCont.BackgroundColor3 = Color3.fromRGB(18, 20, 29)
InfoCont.BackgroundTransparency = 0.2
InfoCont.BorderSizePixel = 0
InfoCont.LayoutOrder = 1
InfoCont.ZIndex = 4
InfoCont.Parent = ButtonContainer
corner(InfoCont, 9)

local infoStroke = Instance.new("UIStroke", InfoCont)
infoStroke.Color = Color3.fromRGB(45, 50, 70)
infoStroke.Thickness = 1
infoStroke.Transparency = 0.5

local PulsingDot = Instance.new("Frame")
PulsingDot.Name = "PulsingDot"
PulsingDot.Size = UDim2.new(0, 6, 0, 6)
PulsingDot.Position = UDim2.new(0, 8, 0.5, -3)
PulsingDot.BackgroundColor3 = Color3.fromRGB(34, 211, 238)
PulsingDot.BorderSizePixel = 0
PulsingDot.ZIndex = 5
PulsingDot.Parent = InfoCont
corner(PulsingDot, 99)

task.spawn(function()
    while not runtime.destroyed do
        TweenService:Create(PulsingDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.7 }):Play()
        task.wait(0.9)
        if runtime.destroyed then break end
        TweenService:Create(PulsingDot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 }):Play()
        task.wait(0.9)
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 48, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TL FLY"
Title.TextColor3 = Color3.fromRGB(240, 245, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 5
Title.Parent = InfoCont

local StatusBadge = Instance.new("Frame")
StatusBadge.Name = "StatusBadge"
StatusBadge.Size = UDim2.new(0, 40, 0, 18)
StatusBadge.Position = UDim2.new(1, -44, 0.5, -9)
StatusBadge.BackgroundColor3 = Color3.fromRGB(24, 30, 45)
StatusBadge.BorderSizePixel = 0
StatusBadge.ZIndex = 5
StatusBadge.Parent = InfoCont
corner(StatusBadge, 5)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "GLIDE"
StatusLabel.TextColor3 = Color3.fromRGB(34, 211, 238)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 8
StatusLabel.ZIndex = 6
StatusLabel.Parent = StatusBadge

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(18, 20, 29)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(220, 230, 245)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.RichText = true
    btn.ZIndex = 4
    corner(btn, 9)

    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Color3.fromRGB(45, 50, 70)
    bStroke.Thickness = 1
    bStroke.Transparency = 0.6

    local popS = Instance.new("UIScale")
    popS.Parent = btn

    bind(btn.MouseEnter, function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundTransparency = 0.05, BackgroundColor3 = Color3.fromRGB(24, 28, 40) }):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.12), { Transparency = 0.2, Color = C.accent }):Play()
    end)
    bind(btn.MouseLeave, function()
        TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(18, 20, 29) }):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.15), { Transparency = 0.6, Color = Color3.fromRGB(45, 50, 70) }):Play()
    end)
    bind(btn.MouseButton1Down, function()
        TweenService:Create(popS, TweenInfo.new(0.08), { Scale = 0.94 }):Play()
    end)
    bind(btn.MouseButton1Up, function()
        TweenService:Create(popS, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end)
    bind(btn.InputBegan, function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            callback()
        end
    end)
    return btn, bStroke
end

-- -- 3. SPEED CONTROLLER (with 4-Tier LEDs & [Q] Hotkey) --
local SpeedGroup = Instance.new("Frame")
SpeedGroup.Size = UDim2.new(0, 134, 0, 32)
SpeedGroup.BackgroundColor3 = Color3.fromRGB(18, 20, 29)
SpeedGroup.BackgroundTransparency = 0.2
SpeedGroup.BorderSizePixel = 0
SpeedGroup.LayoutOrder = 2
SpeedGroup.ZIndex = 4
SpeedGroup.Parent = ButtonContainer
corner(SpeedGroup, 9)

local sgStroke = Instance.new("UIStroke", SpeedGroup)
sgStroke.Color = Color3.fromRGB(45, 50, 70)
sgStroke.Thickness = 1
sgStroke.Transparency = 0.6

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, 0, 1, 0)
SpeedBtn.BackgroundTransparency = 1
SpeedBtn.Text = ""
SpeedBtn.ZIndex = 5
SpeedBtn.Parent = SpeedGroup

local SpeedBtnScale = Instance.new("UIScale", SpeedGroup)

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(1, -40, 0, 14)
SpeedTitle.Position = UDim2.new(0, 10, 0, 4)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "NORMAL"
SpeedTitle.TextColor3 = Color3.fromRGB(240, 245, 255)
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextSize = 10
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.ZIndex = 5
SpeedTitle.Parent = SpeedGroup

local KeyTag = Instance.new("TextLabel")
KeyTag.Size = UDim2.new(0, 26, 0, 14)
KeyTag.Position = UDim2.new(1, -32, 0, 4)
KeyTag.BackgroundTransparency = 1
KeyTag.Text = "[Q]"
KeyTag.TextColor3 = Color3.fromRGB(110, 115, 135)
KeyTag.Font = Enum.Font.GothamBold
KeyTag.TextSize = 8
KeyTag.TextXAlignment = Enum.TextXAlignment.Right
KeyTag.ZIndex = 5
KeyTag.Parent = SpeedGroup

local PipCont = Instance.new("Frame")
PipCont.Size = UDim2.new(1, -20, 0, 4)
PipCont.Position = UDim2.new(0, 10, 1, -8)
PipCont.BackgroundTransparency = 1
PipCont.ZIndex = 5
PipCont.Parent = SpeedGroup

local pipLayout = Instance.new("UIListLayout", PipCont)
pipLayout.FillDirection = Enum.FillDirection.Horizontal
pipLayout.Padding = UDim.new(0, 4)

local pips = {}
for pi = 1, 4 do
    local pip = Instance.new("Frame")
    pip.Size = UDim2.new(0.25, -3, 1, 0)
    pip.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    pip.BorderSizePixel = 0
    pip.ZIndex = 5
    pip.Parent = PipCont
    corner(pip, 2)
    pips[pi] = pip
end

bind(SpeedBtn.MouseButton1Click, function()
    speedIndex = (speedIndex % #speedLevels) + 1
    hasBoosted = true
    TweenService:Create(SpeedBtnScale, TweenInfo.new(0.08), { Scale = 0.94 }):Play()
    task.delay(0.09, function()
        TweenService:Create(SpeedBtnScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end)
    updateFlyPanel()
end)
bind(SpeedBtn.MouseEnter, function()
    TweenService:Create(SpeedGroup, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(24, 28, 40) }):Play()
    TweenService:Create(sgStroke, TweenInfo.new(0.12), { Transparency = 0.2, Color = C.accent }):Play()
end)
bind(SpeedBtn.MouseLeave, function()
    TweenService:Create(SpeedGroup, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(18, 20, 29) }):Play()
    TweenService:Create(sgStroke, TweenInfo.new(0.15), { Transparency = 0.6, Color = Color3.fromRGB(45, 50, 70) }):Play()
end)

-- -- 4. NOCLIP SWITCH BUTTON --
local NoclipBtn, ncStroke = createButton("", function()
    noclipFly = not noclipFly
    updateFlyPanel()
end)
NoclipBtn.Size = UDim2.new(0, 106, 0, 32)
NoclipBtn.LayoutOrder = 3
NoclipBtn.Parent = ButtonContainer

local ncLabel = Instance.new("TextLabel")
ncLabel.Size = UDim2.new(0, 52, 1, 0)
ncLabel.Position = UDim2.new(0, 10, 0, 0)
ncLabel.BackgroundTransparency = 1
ncLabel.Text = "NOCLIP"
ncLabel.TextColor3 = Color3.fromRGB(220, 230, 245)
ncLabel.Font = Enum.Font.GothamBold
ncLabel.TextSize = 10
ncLabel.TextXAlignment = Enum.TextXAlignment.Left
ncLabel.ZIndex = 5
ncLabel.Parent = NoclipBtn

local NcTag = Instance.new("Frame")
NcTag.Name = "NcTag"
NcTag.Size = UDim2.new(0, 34, 0, 18)
NcTag.Position = UDim2.new(1, -40, 0.5, -9)
NcTag.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
NcTag.BorderSizePixel = 0
NcTag.ZIndex = 5
NcTag.Parent = NoclipBtn
corner(NcTag, 5)

local NcTagText = Instance.new("TextLabel")
NcTagText.Size = UDim2.new(1, 0, 1, 0)
NcTagText.BackgroundTransparency = 1
NcTagText.Text = "OFF"
NcTagText.TextColor3 = Color3.fromRGB(120, 125, 140)
NcTagText.Font = Enum.Font.GothamBold
NcTagText.TextSize = 8
NcTagText.ZIndex = 6
NcTagText.Parent = NcTag

-- -- 5. ANIMATION STYLE DROPDOWN BUTTON --
local AnimBtn, animStroke = createButton("", function() end)
AnimBtn.Size = UDim2.new(0, 154, 0, 32)
AnimBtn.LayoutOrder = 4
AnimBtn.Parent = ButtonContainer

local AnimPrefix = Instance.new("TextLabel")
AnimPrefix.Size = UDim2.new(0, 32, 1, 0)
AnimPrefix.Position = UDim2.new(0, 10, 0, 0)
AnimPrefix.BackgroundTransparency = 1
AnimPrefix.Text = "STYLE"
AnimPrefix.TextColor3 = Color3.fromRGB(110, 115, 135)
AnimPrefix.Font = Enum.Font.GothamBold
AnimPrefix.TextSize = 8
AnimPrefix.TextXAlignment = Enum.TextXAlignment.Left
AnimPrefix.ZIndex = 5
AnimPrefix.Parent = AnimBtn

local AnimNameLabel = Instance.new("TextLabel")
AnimNameLabel.Name = "AnimNameLabel"
AnimNameLabel.Size = UDim2.new(1, -50, 1, 0)
AnimNameLabel.Position = UDim2.new(0, 44, 0, 0)
AnimNameLabel.BackgroundTransparency = 1
AnimNameLabel.Text = animSets[currentAnimSet].name:upper()
AnimNameLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
AnimNameLabel.Font = Enum.Font.GothamBold
AnimNameLabel.TextSize = 10
AnimNameLabel.TextXAlignment = Enum.TextXAlignment.Left
AnimNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
AnimNameLabel.ZIndex = 5
AnimNameLabel.Parent = AnimBtn

local DropArrow = Instance.new("TextLabel")
DropArrow.Name = "DropArrow"
DropArrow.AnchorPoint = Vector2.new(0.5, 0.5)
DropArrow.Size = UDim2.new(0, 14, 0, 14)
DropArrow.Position = UDim2.new(1, -12, 0.5, 0)
DropArrow.BackgroundTransparency = 1
DropArrow.Text = "v"
DropArrow.TextColor3 = C.accent
DropArrow.Font = Enum.Font.GothamBold
DropArrow.TextSize = 10
DropArrow.ZIndex = 5
DropArrow.Parent = AnimBtn

-- -- DROPDOWN CARD (PILL OUTER) --
local PILL_EXPANDED_H, PILL_GAP = 224, 8
local dropOpen = false

local PillOuter = Instance.new("Frame")
PillOuter.Size = UDim2.new(0, 160, 0, 0)
PillOuter.AnchorPoint = Vector2.new(0.5, 0)
PillOuter.Position = UDim2.new(0, 479, 0, 44 + PILL_GAP)
PillOuter.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
PillOuter.BackgroundTransparency = 0.05
PillOuter.BorderSizePixel = 0
PillOuter.ClipsDescendants = true
PillOuter.ZIndex = 50
PillOuter.Parent = Wrapper
corner(PillOuter, 12)

local pillStroke = Instance.new("UIStroke", PillOuter)
pillStroke.Color = C.accent
pillStroke.Thickness = 1.2
pillStroke.Transparency = 1
pillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local PillHdr = Instance.new("Frame", PillOuter)
PillHdr.Size = UDim2.new(1, 0, 0, 28)
PillHdr.BackgroundColor3 = Color3.fromRGB(18, 20, 29)
PillHdr.BorderSizePixel = 0
PillHdr.ZIndex = 51
corner(PillHdr, 12)

local PillTit = Instance.new("TextLabel", PillHdr)
PillTit.Size = UDim2.new(1, -20, 1, 0)
PillTit.Position = UDim2.new(0, 12, 0, 0)
PillTit.BackgroundTransparency = 1
PillTit.Text = "FLYING STYLES"
PillTit.TextColor3 = Color3.fromRGB(140, 150, 175)
PillTit.Font = Enum.Font.GothamBold
PillTit.TextSize = 9
PillTit.TextXAlignment = Enum.TextXAlignment.Left
PillTit.ZIndex = 52

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -28)
ScrollFrame.Position = UDim2.new(0, 0, 0, 28)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = C.accent
ScrollFrame.ScrollBarImageTransparency = 0.4
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ZIndex = 51
ScrollFrame.Parent = PillOuter

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 4)
scrollLayout.Parent = ScrollFrame

local scrollPadding = Instance.new("UIPadding")
scrollPadding.PaddingTop = UDim.new(0, 6)
scrollPadding.PaddingBottom = UDim.new(0, 6)
scrollPadding.PaddingLeft = UDim.new(0, 8)
scrollPadding.PaddingRight = UDim.new(0, 8)
scrollPadding.Parent = ScrollFrame

local function refreshAnimRows()
    for i, btn in ipairs(animSetButtons) do
        local isActive = (i == currentAnimSet)
        TweenService:Create(btn, TweenInfo.new(0.08), { BackgroundTransparency = isActive and 0.25 or 0.6 }):Play()
        local label = btn:FindFirstChild("NameLabel")
        if label then label.TextColor3 = isActive and C.accent or Color3.fromRGB(220, 230, 245) end
        local dot = btn:FindFirstChild("ActiveDot")
        if dot then dot.Visible = isActive end
    end
    local arrow = AnimBtn:FindFirstChild("DropArrow")
    if arrow then
        TweenService:Create(arrow, TweenInfo.new(0.2), { Rotation = dropOpen and 180 or 0 }):Play()
    end
    if AnimNameLabel then
        AnimNameLabel.Text = animSets[currentAnimSet].name:upper()
    end
end

local flyTrack, flyFwdTrack, flyGlideTrack, flyFwd2Track = nil, nil, nil, nil
local lastPlayedTrack = nil
local _isFwdAnim, _isGlideIdle = false, false

local function switchAnimSet(index)
    currentAnimSet = index
    if _cacheAnimIdx then _cacheAnimIdx.Value = currentAnimSet end
    task.spawn(function() _saveFlyAnimSet(currentAnimSet) end)
    refreshAnimRows()
    if flying then
        if flyTrack then flyTrack:Stop(0.35); flyTrack = nil end
        if flyFwdTrack then flyFwdTrack:Stop(0.35); flyFwdTrack = nil end
        if flyGlideTrack then flyGlideTrack:Stop(0.35); flyGlideTrack = nil end
        local s = animSets[currentAnimSet]
        flyTrack = loadTrackFromId(s.idle)
        flyFwdTrack = loadTrackFromId(s.fwd)
        flyGlideTrack = loadTrackFromId(s.glide)
        lastPlayedTrack = flyTrack
        if flyTrack then flyTrack:Play(0.35) end
    end
end

for i, set in ipairs(animSets) do
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -4, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
    row.BackgroundTransparency = 0.6
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    row.Text = ""
    row.ZIndex = 53
    row.Parent = ScrollFrame
    corner(row, 8)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "NameLabel"
    nameLbl.Size = UDim2.new(1, -30, 1, 0)
    nameLbl.Position = UDim2.new(0, 12, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = set.name
    nameLbl.TextColor3 = Color3.fromRGB(220, 230, 245)
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 10
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 54
    nameLbl.Parent = row

    local dot = Instance.new("Frame")
    dot.Name = "ActiveDot"
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.Position = UDim2.new(1, -12, 0.5, -2)
    dot.BackgroundColor3 = C.accent
    dot.BorderSizePixel = 0
    dot.Visible = (i == currentAnimSet)
    dot.ZIndex = 54
    dot.Parent = row
    corner(dot, 99)

    bind(row.MouseEnter, function()
        TweenService:Create(row, TweenInfo.new(0.1), { BackgroundTransparency = 0.2, BackgroundColor3 = Color3.fromRGB(28, 32, 48) }):Play()
        if i ~= currentAnimSet then TweenService:Create(nameLbl, TweenInfo.new(0.1), { TextColor3 = C.accent }):Play() end
    end)
    bind(row.MouseLeave, function()
        local isActive = (i == currentAnimSet)
        TweenService:Create(row, TweenInfo.new(0.1), { BackgroundTransparency = isActive and 0.25 or 0.6, BackgroundColor3 = Color3.fromRGB(20, 22, 32) }):Play()
        if not isActive then TweenService:Create(nameLbl, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(220, 230, 245) }):Play() end
    end)
    bind(row.InputBegan, function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            switchAnimSet(i)
        end
    end)
    animSetButtons[i] = row
end

refreshAnimRows()

bind(AnimBtn.MouseButton1Click, function()
    dropOpen = not dropOpen
    local arrow = AnimBtn:FindFirstChild("DropArrow")
    if arrow then
        TweenService:Create(arrow, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Rotation = dropOpen and 180 or 0 }):Play()
    end
    local targetH = dropOpen and PILL_EXPANDED_H or 0
    local targetT = dropOpen and 0.05 or 1
    TweenService:Create(PillOuter, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 160, 0, targetH),
            BackgroundTransparency = targetT
        }):Play()
    if pillStroke then
        TweenService:Create(pillStroke, TweenInfo.new(0.3), { Transparency = dropOpen and 0.4 or 1 }):Play()
    end
end)

updateFlyPanel = function()
    local data = getSpeedData(speedIndex)
    if not data then return end
    
    if SpeedTitle then SpeedTitle.Text = data.name end
    if StatusLabel then
        StatusLabel.Text = data.name
        StatusLabel.TextColor3 = data.color
    end
    if StatusBadge then
        TweenService:Create(StatusBadge, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(
            math.floor(data.color.R * 40),
            math.floor(data.color.G * 40),
            math.floor(data.color.B * 40)
        ) }):Play()
    end
    
    for pi = 1, 4 do
        local pip = pips[pi]
        if pip then
            local isLit = (pi <= speedIndex)
            TweenService:Create(pip, TweenInfo.new(0.18), {
                BackgroundColor3 = isLit and data.color or Color3.fromRGB(40, 45, 60),
                BackgroundTransparency = isLit and 0.0 or 0.5
            }):Play()
        end
    end
    
    TweenService:Create(mStroke, TweenInfo.new(0.25), { Color = data.color }):Play()
    TweenService:Create(pillStroke, TweenInfo.new(0.25), { Color = data.color }):Play()

    if NoclipBtn and NcTag and NcTagText then
        if noclipFly then
            NcTagText.Text = "ON"
            NcTagText.TextColor3 = Color3.fromRGB(34, 211, 238)
            TweenService:Create(NcTag, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(15, 45, 55) }):Play()
            TweenService:Create(ncStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(34, 211, 238), Transparency = 0.3 }):Play()
        else
            NcTagText.Text = "OFF"
            NcTagText.TextColor3 = Color3.fromRGB(120, 125, 140)
            TweenService:Create(NcTag, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(26, 28, 38) }):Play()
            TweenService:Create(ncStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(45, 50, 70), Transparency = 0.6 }):Play()
        end
    end

    if speedIndex == 4 and flying then
        local flash = regInst(Instance.new("Frame", flyScreenGui))
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Color3.new(1, 1, 1)
        flash.BackgroundTransparency = 0.9
        TweenService:Create(flash, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
        task.delay(0.2, function() flash:Destroy() end)
    end
end


local function startFly()
    flying = true; updateFlyPanel()
    local s = animSets[currentAnimSet]
    flyTrack = loadTrackFromId(s.idle); flyFwdTrack = loadTrackFromId(s.fwd); flyGlideTrack = loadTrackFromId(s.glide)
    flyFwd2Track = loadTrackFromId(s.fwd2)
    lastPlayedTrack = flyTrack
    if flyTrack then flyTrack:Play(0.35) end
    _isFwdAnim = false; _isGlideIdle = false

    local myChar = lp.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then flying = false; return end
    myHum.PlatformStand = true

    local origRunSoundId = nil
    local runSound = myHRP:FindFirstChild("Running")
    if runSound and runSound:IsA("Sound") then
        origRunSoundId = runSound.SoundId; runSound.SoundId = ""; runSound:Stop()
    end

    bg = Instance.new("BodyGyro", myHRP); bg.P = 1.2e4; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = myHRP.CFrame
    bv = Instance.new("BodyVelocity", myHRP); bv.Velocity = Vector3.new(0, 0.1, 0); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    
    
    
    local _BRAKE_TILT_MAX            = 42
    local _BRAKE_TILT_RECOVERY       = 3.8
    local _BRAKE_DETECTION_THRESHOLD = 0.35
    local _BRAKE_DECEL_MULTIPLIER    = 2.8
    local _BRAKE_TILT_SMOOTHING      = 6.0
    local _SIDE_BRAKE_TILT_MAX       = 25
    local _MODE_TRANSITION_SPEED     = 2.5
    local _EASE_POWER                = 2.2
    local _DIRECTION_CHANGE_DECAY    = 0.92
    local _IDLE_HOVER_DRAG           = 2.5
    local _MIN_VEL_THRESHOLD         = 0.3
    local _INPUT_DEADZONE            = 0.08
    local _GYRO_SMOOTH_RATE          = 6.0
    local _TILT_RECOVERY_RATE        = 4.5

    local _currentMaxSpeed = speedLevels[speedIndex].speed
    local _currentSpeedMag = 0
    local currentVel   = Vector3.new(0, 0, 0)
    local prevVel      = Vector3.new(0, 0, 0)
    local prevInputDir = Vector3.new(0, 0, 0)
    local smoothTilt   = 0
    local smoothRoll   = 0
    local smoothYaw    = 0
    local brakeTiltX   = 0
    local brakeTiltZ   = 0
    local brakeForce   = 0
    local driftTime    = 0
    local _flyRayParams = RaycastParams.new()
    _flyRayParams.FilterType = Enum.RaycastFilterType.Exclude
    local _flyNoclipParts = {}; local _prevNoclipFly = false

    local psConn = bind(RunService.Heartbeat,
        function() if flying and myHum then myHum.PlatformStand = true end end)

    local function _easeCurve(t)
        t = math.clamp(t, 0, 1)
        return 1 - (1 - t) ^ _EASE_POWER
    end

    while flying do
        local dt = RunService.Heartbeat:Wait()
        if dt > 0.1 then dt = 0.016 end
        driftTime = driftTime + dt
        local cam = Camera.CFrame
        local _lvl = getSpeedData(speedIndex); if not _lvl then break end

        local targetMaxSpeed = _lvl.speed
        local rampUp         = _lvl.rampUp   or (_lvl.accel * 0.5)
        local rampDown       = _lvl.rampDown or (_lvl.decel * 0.5)
        local boostKick      = _lvl.boostKick or 0.12
        local isGlide        = (speedIndex == 1)

        
        
        
        if _currentMaxSpeed ~= targetMaxSpeed then
            local diff = targetMaxSpeed - _currentMaxSpeed
            local tRate = _MODE_TRANSITION_SPEED * dt * math.abs(diff) * 0.02
            tRate = math.max(tRate, _MODE_TRANSITION_SPEED * dt * 15)
            if math.abs(diff) < 1 then
                _currentMaxSpeed = targetMaxSpeed
            else
                _currentMaxSpeed = _currentMaxSpeed + math.sign(diff) * math.min(math.abs(diff), tRate)
            end
        end

        
        
        
        local speedRatioForAnim = _currentSpeedMag / math.max(_currentMaxSpeed, 1)
        local targetTrack = flyTrack
        if isGlide then
            targetTrack = flyGlideTrack or flyTrack
        elseif speedIndex >= 3 then
            if _isFwdAnim then
                if speedRatioForAnim > 0.45 then
                    if speedIndex == 4 and flyFwd2Track and speedRatioForAnim > 0.8 then
                        targetTrack = flyFwd2Track
                    else
                        targetTrack = flyFwdTrack or flyTrack
                    end
                end
            else
                if speedRatioForAnim > 0.7 then
                    if speedIndex == 4 and flyFwd2Track and speedRatioForAnim > 0.8 then
                        targetTrack = flyFwd2Track
                    else
                        targetTrack = flyFwdTrack or flyTrack
                    end
                end
            end
        end

        if lastPlayedTrack ~= targetTrack then
            local fadeTime = 0.6 + (1 - speedRatioForAnim) * 0.4
            if lastPlayedTrack then lastPlayedTrack:Stop(fadeTime) end
            if targetTrack then targetTrack:Play(fadeTime) end
            lastPlayedTrack = targetTrack
            _isFwdAnim  = (targetTrack == flyFwdTrack or targetTrack == flyFwd2Track)
            _isGlideIdle = (targetTrack == flyGlideTrack)
        end

        
        
        
        local cF = ctrl.f; local cB = ctrl.b; local cL = ctrl.l; local cR = ctrl.r
        local cU = ctrl.u or 0; local cD = ctrl.d or 0

        local md = (myHum and myHum.MoveDirection) or Vector3.zero
        if md.Magnitude > 0.05 then
            local camRight   = cam.RightVector
            local camForward = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z).Unit
            local dotF = md:Dot(camForward); local dotR = md:Dot(camRight)
            if dotF >  0.05 then cF = math.max(cF, dotF) end
            if dotF < -0.05 then cB = math.min(cB, dotF) end
            if dotR < -0.05 then cL = math.min(cL, dotR) end
            if dotR >  0.05 then cR = math.max(cR, dotR) end
        end
        if controlModule then
            local ok, mv = pcall(function() return controlModule:GetMoveVector() end)
            if ok and mv and mv.Magnitude > 0.05 then
                if mv.Z < 0 then cF = math.max(cF, -mv.Z) end
                if mv.Z > 0 then cB = math.min(cB, -mv.Z) end
                if mv.X < 0 then cL = math.min(cL, mv.X) end
                if mv.X > 0 then cR = math.max(cR, mv.X) end
            end
        end

        local hasHorizontal = (cL + cR ~= 0 or cF + cB ~= 0)
        local hasVertical   = (cU ~= 0 or cD ~= 0)
        local hasInput      = hasHorizontal or hasVertical

        if hasInput then
            local rawMag = math.abs(cF) + math.abs(cB) + math.abs(cL) + math.abs(cR) + math.abs(cU) + math.abs(cD)
            if rawMag < _INPUT_DEADZONE then
                cF = 0; cB = 0; cL = 0; cR = 0; cU = 0; cD = 0
                hasHorizontal = false; hasVertical = false; hasInput = false
            end
        end

        local inputDir = Vector3.new(0, 0, 0)
        if hasHorizontal then
            inputDir = ((cam.LookVector * (cF + cB))
                + ((cam * CFrame.new(cL + cR, (cF + cB) * 0.18, 0)).Position - cam.Position))
            if inputDir.Magnitude > 0.01 then inputDir = inputDir.Unit end
        elseif hasVertical then
            inputDir = Vector3.new(0, 1, 0) * math.sign(cU - cD)
        end

        
        
        
        local dirChangeFactor = 1
        if hasHorizontal and prevInputDir.Magnitude > 0.1 then
            local dirDot = inputDir:Dot(prevInputDir)
            if dirDot < 0.3 then
                local sharpness = math.clamp(1 - dirDot, 0, 1)
                dirChangeFactor = _DIRECTION_CHANGE_DECAY - (sharpness * (1 - _DIRECTION_CHANGE_DECAY))
                dirChangeFactor = math.clamp(dirChangeFactor, 0.5, 1)
            end
        end
        if hasHorizontal then prevInputDir = inputDir end

        
        
        
        local velDirFlat   = Vector3.new(currentVel.X, 0, currentVel.Z)
        local inputDirFlat = inputDir * (hasHorizontal and 1 or 0)
        local isBraking    = false
        local brakeIntensity = 0

        if _currentSpeedMag > 8 and inputDirFlat.Magnitude > 0.1 and velDirFlat.Magnitude > 0.1 then
            local dotProduct = velDirFlat.Unit:Dot(inputDirFlat.Unit)
            if dotProduct < -_BRAKE_DETECTION_THRESHOLD then
                isBraking = true
                local speedRatio = math.clamp(_currentSpeedMag / _currentMaxSpeed, 0, 1)
                brakeIntensity = speedRatio * math.clamp(-dotProduct, 0, 1)
            end
        end
        if not hasInput and _currentSpeedMag > _currentMaxSpeed * 0.25 then
            local speedRatio = math.clamp(_currentSpeedMag / _currentMaxSpeed, 0, 1)
            if speedRatio > _BRAKE_DETECTION_THRESHOLD then
                isBraking = true
                brakeIntensity = math.max(brakeIntensity, speedRatio * 0.5)
            end
        end

        
        
        
        if hasInput then
            _currentSpeedMag = _currentSpeedMag * dirChangeFactor
            local progress      = math.clamp(_currentSpeedMag / _currentMaxSpeed, 0, 1)
            local curvedProgress = _easeCurve(progress)
            local remainingRatio = 1 - curvedProgress
            local rampForce      = rampUp * (0.4 + remainingRatio * 0.6)
            local increment      = rampForce * _currentMaxSpeed * dt
            if dirChangeFactor < 0.95 then
                increment = increment + boostKick * _currentMaxSpeed
            end
            if isBraking then
                local brakeDecel = rampDown * _BRAKE_DECEL_MULTIPLIER * (1 + brakeIntensity)
                _currentSpeedMag = math.max(0, _currentSpeedMag - brakeDecel * _currentMaxSpeed * dt)
            else
                _currentSpeedMag = math.min(_currentMaxSpeed, _currentSpeedMag + increment)
            end
        else
            local coastDecel = _IDLE_HOVER_DRAG
            if isBraking then coastDecel = rampDown * _BRAKE_DECEL_MULTIPLIER * 0.6 end
            _currentSpeedMag = math.max(0, _currentSpeedMag - coastDecel * _currentMaxSpeed * dt * 0.3)
            if _currentSpeedMag < _MIN_VEL_THRESHOLD then _currentSpeedMag = 0 end
        end
        _currentSpeedMag = math.min(_currentSpeedMag, _currentMaxSpeed)

        
        
        
        local targetVel = Vector3.new(0, 0, 0)
        if hasHorizontal and _currentSpeedMag > 0 then
            targetVel = inputDir * _currentSpeedMag
        end
        if hasVertical then
            local vertSpeed = math.min(_currentSpeedMag > 0 and _currentSpeedMag or _currentMaxSpeed * 0.5, _currentMaxSpeed)
            targetVel = Vector3.new(targetVel.X, (cU - cD) * vertSpeed, targetVel.Z)
        end

        local velBlendRate = isBraking and (rampDown * _BRAKE_DECEL_MULTIPLIER * 1.2) or (rampUp * 2.0)
        currentVel = currentVel:Lerp(targetVel, 1 - math.exp(-velBlendRate * dt))

        if not hasInput and _currentSpeedMag < _MIN_VEL_THRESHOLD then
            currentVel = currentVel:Lerp(
                Vector3.new(0, 0.08 + math.sin(driftTime * 0.6) * 0.06, 0),
                1 - math.exp(-2.0 * dt)
            )
        end

        
        
        
        local decelVec = prevVel - currentVel
        if isBraking and decelVec.Magnitude > 1 then
            local camFwd   = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z)
            if camFwd.Magnitude > 0.01 then camFwd = camFwd.Unit end
            local camRight = Vector3.new(cam.RightVector.X, 0, cam.RightVector.Z)
            if camRight.Magnitude > 0.01 then camRight = camRight.Unit end
            local decelFlat = Vector3.new(decelVec.X, 0, decelVec.Z)
            local fwdDecel  = decelFlat:Dot(camFwd)
            local sideDecel = decelFlat:Dot(camRight)
            local tBX = math.clamp(
                (fwdDecel / _currentMaxSpeed) * _BRAKE_TILT_MAX * (1 + brakeIntensity),
                -_BRAKE_TILT_MAX, _BRAKE_TILT_MAX)
            local tBZ = math.clamp(
                (sideDecel / _currentMaxSpeed) * _SIDE_BRAKE_TILT_MAX * (1 + brakeIntensity),
                -_SIDE_BRAKE_TILT_MAX, _SIDE_BRAKE_TILT_MAX)
            brakeTiltX = brakeTiltX + (tBX - brakeTiltX) * math.min(1, _BRAKE_TILT_SMOOTHING * dt)
            brakeTiltZ = brakeTiltZ + (tBZ - brakeTiltZ) * math.min(1, _BRAKE_TILT_SMOOTHING * dt)
        else
            brakeTiltX = brakeTiltX * math.max(0, 1 - _TILT_RECOVERY_RATE * dt)
            brakeTiltZ = brakeTiltZ * math.max(0, 1 - _TILT_RECOVERY_RATE * dt)
            if math.abs(brakeTiltX) < 0.3 then brakeTiltX = 0 end
            if math.abs(brakeTiltZ) < 0.3 then brakeTiltZ = 0 end
        end
        brakeForce = math.clamp(brakeIntensity, 0, 1)
        prevVel = currentVel

        if not noclipFly then
            _flyRayParams.FilterDescendantsInstances = { myChar }
            local ray = workspace:Raycast(myHRP.Position, Vector3.new(0, -3.2, 0), _flyRayParams)
            if ray then
                local hoverY = ray.Position.Y + 3.0
                if myHRP.Position.Y < hoverY then
                    currentVel = Vector3.new(currentVel.X,
                        math.max(currentVel.Y, (hoverY - myHRP.Position.Y) * 8), currentVel.Z)
                end
            end
        end

        
        
        
        if noclipFly then
            local needRescan = (#_flyNoclipParts == 0)
                or (_flyNoclipParts[1] and _flyNoclipParts[1].Parent ~= myChar)
            if not needRescan then
                local curCount = 0
                for _, p in ipairs(myChar:GetDescendants()) do
                    if p:IsA("BasePart") then curCount = curCount + 1 end
                end
                if curCount ~= #_flyNoclipParts then needRescan = true end
            end
            if needRescan then
                _flyNoclipParts = {}
                for _, p in ipairs(myChar:GetDescendants()) do
                    if p:IsA("BasePart") then _flyNoclipParts[#_flyNoclipParts + 1] = p end
                end
            end
            for _, p in ipairs(_flyNoclipParts) do
                if p.Parent and p.CanCollide then p.CanCollide = false end
            end
            _prevNoclipFly = true
        elseif _prevNoclipFly then
            for _, p in ipairs(_flyNoclipParts) do pcall(function() p.CanCollide = true end) end
            _flyNoclipParts = {}
            _prevNoclipFly = false
        end

        
        
        
        if bv then
            bv.Velocity = currentVel
            myHRP.AssemblyLinearVelocity = currentVel
        end

        
        
        
        local speedPct = math.clamp(_currentSpeedMag / math.max(_currentMaxSpeed, 1), 0, 1)

        local speedLeanFwd = 0
        if hasHorizontal and _currentSpeedMag > 5 then
            if cF > 0 then
                speedLeanFwd = speedPct * 22
            elseif cB < 0 then
                speedLeanFwd = speedPct * -10
            end
        end
        local targetTilt = cF * 18 + cB * -8 + speedLeanFwd
        local targetRoll = (cL + cR) * -(18 + speedPct * 10)
        local targetYaw  = (cL + cR) * 6 * speedPct

        smoothTilt = smoothTilt + (targetTilt - smoothTilt) * math.min(1, _GYRO_SMOOTH_RATE * dt)
        smoothRoll = smoothRoll + (targetRoll - smoothRoll) * math.min(1, (_GYRO_SMOOTH_RATE + 1) * dt)
        smoothYaw  = smoothYaw + (targetYaw - smoothYaw) * math.min(1, _GYRO_SMOOTH_RATE * dt)

        if bg then
            local baseCF = cam * CFrame.Angles(
                -math.rad(smoothTilt * 0.55),
                math.rad(smoothYaw),
                math.rad(smoothRoll * 0.7)
            )
            bg.CFrame = baseCF * CFrame.Angles(math.rad(brakeTiltX), 0, -math.rad(brakeTiltZ))
        end
    end

    
    if psConn then psConn:Disconnect() end
    local _fadeOut = 0.3 + (1 - math.clamp(_currentSpeedMag / math.max(_currentMaxSpeed, 1), 0, 1)) * 0.2
    if flyTrack then flyTrack:Stop(_fadeOut) end
    if flyFwdTrack then flyFwdTrack:Stop(_fadeOut) end
    if flyGlideTrack then flyGlideTrack:Stop(_fadeOut) end
    if flyFwd2Track then flyFwd2Track:Stop(_fadeOut) end
    if runSound and origRunSoundId then runSound.SoundId = origRunSoundId end
    if bg then bg:Destroy(); bg = nil end
    if bv then bv:Destroy(); bv = nil end
    if myHum then myHum.PlatformStand = false end
end

local function stopFly() flying = false end

local function setFly(on)
    if on then
        if not flying then
            flying    = true
            flyActive = true
            task.spawn(startFly)
            if Wrapper then Wrapper.Visible = true end
        end
    else
        if flying then
            flying    = false
            flyActive = false
            stopFly()
            if dropOpen then
                dropOpen = false
                PillOuter.Size = UDim2.new(0, 160, 0, 0)
                PillOuter.BackgroundTransparency = 1
                if pillStroke then pillStroke.Transparency = 1 end
                local arrow = AnimBtn:FindFirstChild("DropArrow")
                if arrow then arrow.Rotation = 0 end
            end
            if Wrapper then Wrapper.Visible = false end
        end
    end
end


bind(UIS.InputBegan, function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Enum.KeyCode.Q and flyActive then
        speedIndex = (speedIndex % #speedLevels) + 1
        hasBoosted = true
        updateFlyPanel()
    end
    
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1 end
    if input.KeyCode == Enum.KeyCode.S then ctrl.b = -1 end
    if input.KeyCode == Enum.KeyCode.A then ctrl.l = -1 end
    if input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
end)

bind(UIS.InputEnded, function(input)
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0 end
    if input.KeyCode == Enum.KeyCode.S then ctrl.b = 0 end
    if input.KeyCode == Enum.KeyCode.A then ctrl.l = 0 end
    if input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
end)

bind(lp.CharacterAdded, function()
    if flyActive then setFly(false) end
end)

Wrapper.Visible = false


if GLOBAL_ENV then
    GLOBAL_ENV._TL_setFly    = setFly
    GLOBAL_ENV._TL_flyActive = function() return flyActive end
end

runtime.start = function() setFly(true) end
runtime.stop  = function() setFly(false) end
runtime.isActive = function() return flyActive end

return runtime
