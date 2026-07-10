pcall(function()

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local animator  = humanoid:WaitForChild("Animator")


local ANIM_ID    = "rbxassetid://70883871260184"
local FRAME_STEP = 1/30

local SPEEDS = {
    { name = "0.0001", val = 0.0001, desc = "Freeze-ish"   },
    { name = "0.01",   val = 0.01,   desc = "Sehr Langsam" },
    { name = "0.1",    val = 0.1,    desc = "Langsam"      },
    { name = "0.5",    val = 0.5,    desc = "Halb"         },
    { name = "1.0",    val = 1.0,    desc = "Normal"       },
    { name = "1.5",    val = 1.5,    desc = "Schnell"      },
    { name = "2.0",    val = 2.0,    desc = "Sehr Schnell" },
    { name = "5.0",    val = 5.0,    desc = "Ultra"        },
}

local PANEL_W = 620
local PANEL_H = 310
local PAD     = 12
local COL_W   = math.floor((PANEL_W - PAD * 3) / 2)
local COL1_X  = PAD
local COL2_X  = PAD * 2 + COL_W


local C = {
    bg          = Color3.fromRGB(10, 10, 10),
    panel       = Color3.fromRGB(20, 20, 20),
    surface     = Color3.fromRGB(28, 28, 28),
    elevated    = Color3.fromRGB(38, 38, 44),
    accent      = Color3.fromRGB(99, 102, 241),
    ACCENT      = Color3.fromRGB(99, 102, 241),
    borderSub   = Color3.fromRGB(55, 55, 65),
    text        = Color3.fromRGB(255, 255, 255),
    textSub     = Color3.fromRGB(156, 156, 156),
    CLOSE_HOVER = Color3.fromRGB(200, 30, 30),
    red         = Color3.fromRGB(200, 50, 65),
    green       = Color3.fromRGB(60, 200, 100),
    greenDark   = Color3.fromRGB(35, 60, 40),
    yellow      = Color3.fromRGB(255, 200, 60),
    yellowDark  = Color3.fromRGB(80, 70, 25),
    blue        = Color3.fromRGB(60, 100, 200),
    blueDark    = Color3.fromRGB(25, 35, 70),
}


local function corner(inst, r)
    if type(r) == "number" then r = UDim.new(0, r) end
    Instance.new("UICorner", inst).CornerRadius = r or UDim.new(0, 10)
end

local function stroke(inst, col, thick, trans)
    local s = Instance.new("UIStroke", inst)
    s.Color        = col   or C.borderSub
    s.Thickness    = thick or 1
    s.Transparency = trans or 0
    return s
end

local _tiPool = {}
local function getTI(t, s, d)
    s = s or Enum.EasingStyle.Quad; d = d or Enum.EasingDirection.Out
    local k = string.format("%s_%s_%s", tostring(t), s.Name, d.Name)
    if not _tiPool[k] then _tiPool[k] = TweenInfo.new(t, s, d) end
    return _tiPool[k]
end
local TI = {
    _008 = getTI(0.08), _012 = getTI(0.12), _016 = getTI(0.16),
    _025 = getTI(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}
local function tw(obj, info, props) return TweenService:Create(obj, info, props):Play() end

local function getPopScale(f)
    local s = f:FindFirstChild("PopScale")
    if not s then s = Instance.new("UIScale", f); s.Name = "PopScale" end
    return s
end


local runtime = { connections = {}, instances = {}, destroyed = false }
runtime.cleanup = function()
    if runtime.destroyed then return end; runtime.destroyed = true
    for _, c in ipairs(runtime.connections) do pcall(function() c:Disconnect() end) end
    runtime.connections = {}
    for i = #runtime.instances, 1, -1 do
        pcall(function() local inst = runtime.instances[i]; if inst and inst.Parent then inst:Destroy() end end)
    end
    runtime.instances = {}
end
local function regInst(inst) table.insert(runtime.instances, inst); return inst end
local function bind(sig, fn) local c = sig:Connect(fn); table.insert(runtime.connections, c); return c end


local anim = Instance.new("Animation")
anim.AnimationId = ANIM_ID

local track
local trackLoaded = false

local function loadTrack()
    local ok = pcall(function()
        track         = animator:LoadAnimation(anim)
        track.Looped  = true
        track.Priority = Enum.AnimationPriority.Action4
    end)
    trackLoaded = ok and track ~= nil
    return trackLoaded
end

loadTrack()


local playing      = false
local frozen       = false
local currentSpeed = 0.0001
local looping      = true
local pingPong     = false
local pingPongDir  = 1
local markers      = {}


local function clamp01(v) return math.clamp(v, 0, 1) end

local function safeLen()
    if not trackLoaded or not track then return 1 end
    local l = track.Length
    return (l and l > 0) and l or 1
end

local function safeTime()
    if not trackLoaded or not track then return 0 end
    local ok, t = pcall(function() return track.TimePosition end)
    return ok and t or 0
end

local function setTime(t)
    if not trackLoaded or not track then return end
    pcall(function()
        if not playing then track:Play(); track:AdjustSpeed(0) end
        track.TimePosition = math.clamp(t, 0, safeLen())
    end)
end


local function mkBtn(parent, text, x, y, w, h, bg, tc)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0, w, 0, h)
    b.Position         = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = bg or C.surface
    b.BackgroundTransparency = 0
    b.Text             = text
    b.TextColor3       = tc or C.text
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 11
    b.AutoButtonColor  = false
    b.BorderSizePixel  = 0
    b.Parent           = parent
    corner(b, 8)
    stroke(b, C.borderSub, 1, 0.55)

    local _bg = bg or C.surface
    local _tc = tc or C.text
    local sc = getPopScale(b)
    bind(b.MouseEnter, function()
        tw(b, TI._008, { BackgroundColor3 = _bg, BackgroundTransparency = 0.12 })
        tw(sc, TI._008, { Scale = 1.03 })
    end)
    bind(b.MouseLeave, function()
        tw(b, TI._012, { BackgroundColor3 = _bg, BackgroundTransparency = 0 })
        tw(sc, TI._012, { Scale = 1 })
    end)
    bind(b.MouseButton1Down, function() tw(sc, TI._008, { Scale = 0.94 }) end)
    bind(b.MouseButton1Up, function() tw(sc, TI._025, { Scale = 1 }) end)
    return b
end

local function mkLabel(parent, text, x, y, w, h, col, sz, xalign)
    local l = Instance.new("TextLabel")
    l.Size               = UDim2.new(0, w, 0, h)
    l.Position           = UDim2.new(0, x, 0, y)
    l.BackgroundTransparency = 1
    l.Text               = text
    l.TextColor3         = col or C.textSub
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = sz or 10
    l.TextXAlignment     = xalign or Enum.TextXAlignment.Left
    l.TextWrapped        = true
    l.Parent             = parent
    return l
end

local function mkSep(parent, x, y, w)
    local s = Instance.new("Frame")
    s.Size             = UDim2.new(0, w, 0, 1)
    s.Position         = UDim2.new(0, x, 0, y)
    s.BackgroundColor3 = C.borderSub
    s.BackgroundTransparency = 0.5
    s.BorderSizePixel  = 0
    s.Parent           = parent
    return s
end

local function mkVSep(parent, y, h)
    local s = Instance.new("Frame")
    s.Size             = UDim2.new(0, 1, 0, h)
    s.Position         = UDim2.new(0, COL2_X - PAD, 0, y)
    s.BackgroundColor3 = C.borderSub
    s.BackgroundTransparency = 0.5
    s.BorderSizePixel  = 0
    s.Parent           = parent
    return s
end


local existing = CoreGui:FindFirstChild("AnimExplorer")
if existing then existing:Destroy() end

local gui = regInst(Instance.new("ScreenGui"))
gui.Name         = "AnimExplorer"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local frame = regInst(Instance.new("Frame"))
frame.Size             = UDim2.new(0, PANEL_W, 0, PANEL_H)
frame.Position         = UDim2.new(0.5, -PANEL_W/2, 0, 160)
frame.BackgroundColor3 = C.bg
frame.BorderSizePixel  = 0
frame.ClipsDescendants = true
frame.Parent           = gui
corner(frame, 14)
stroke(frame, C.borderSub, 1.2, 0.2)


local Header = Instance.new("Frame", frame)
Header.Name                = "Header"
Header.Size                = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3    = C.panel
Header.BorderSizePixel     = 0
Header.ZIndex              = 20
Header.ClipsDescendants    = true
corner(Header, UDim.new(0, 14))

local headerCornerFix = Instance.new("Frame", Header)
headerCornerFix.Size                 = UDim2.new(1, 0, 0, 10)
headerCornerFix.Position             = UDim2.new(0, 0, 1, -10)
headerCornerFix.BackgroundColor3     = C.panel
headerCornerFix.BorderSizePixel      = 0
headerCornerFix.ZIndex               = 21

local headerLine = Instance.new("Frame", Header)
headerLine.Size                 = UDim2.new(1, 0, 0, 1)
headerLine.Position             = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3     = C.ACCENT
headerLine.BackgroundTransparency = 0.86
headerLine.BorderSizePixel      = 0
headerLine.ZIndex               = 22

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size                 = UDim2.new(0, 20, 0, 20)
TitleIcon.Position             = UDim2.new(0, 10, 0.5, -10)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text                 = "\u{25B6}"
TitleIcon.TextColor3           = C.accent
TitleIcon.TextSize             = 12
TitleIcon.Font                 = Enum.Font.GothamBold
TitleIcon.ZIndex               = 21
TitleIcon.Parent               = Header

local headerTitle = Instance.new("TextLabel", Header)
headerTitle.Name                 = "TitleLabel"
headerTitle.Size                 = UDim2.new(1, -158, 1, 0)
headerTitle.Position             = UDim2.fromOffset(34, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text                 = "OUTFIT EXPAND"
headerTitle.TextColor3           = C.text
headerTitle.Font                 = Enum.Font.GothamBold
headerTitle.TextSize             = 13
headerTitle.TextXAlignment       = Enum.TextXAlignment.Left
headerTitle.ZIndex               = 22


local btnSize = 26
local btnPad  = 4

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Name                 = "MinBtn"
MinBtn.Size                 = UDim2.fromOffset(btnSize, btnSize)
MinBtn.Position             = UDim2.new(1, -(btnSize * 2 + btnPad + 6), 0.5, 0)
MinBtn.AnchorPoint          = Vector2.new(0, 0.5)
MinBtn.BackgroundColor3     = C.surface
MinBtn.Text                 = "-"
MinBtn.TextColor3           = C.textSub
MinBtn.Font                 = Enum.Font.GothamBold
MinBtn.TextSize             = 14
MinBtn.AutoButtonColor      = false
MinBtn.BorderSizePixel      = 0
MinBtn.ZIndex               = 24
corner(MinBtn, 6)
stroke(MinBtn, C.borderSub, 1, 0.4)
bind(MinBtn.MouseEnter, function() tw(MinBtn, TI._008, {BackgroundColor3=C.elevated, TextColor3=C.text}) end)
bind(MinBtn.MouseLeave, function() tw(MinBtn, TI._012, {BackgroundColor3=C.surface, TextColor3=C.textSub}) end)
bind(MinBtn.MouseButton1Down, function() tw(getPopScale(MinBtn), TI._008, {Scale=0.88}) end)
bind(MinBtn.MouseButton1Up, function() tw(getPopScale(MinBtn), TI._016, {Scale=1}) end)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Name                 = "CloseBtn"
CloseBtn.Size                 = UDim2.fromOffset(btnSize, btnSize)
CloseBtn.Position             = UDim2.new(1, -6, 0.5, 0)
CloseBtn.AnchorPoint          = Vector2.new(1, 0.5)
CloseBtn.BackgroundColor3     = C.surface
CloseBtn.Text                 = "x"
CloseBtn.TextColor3           = C.textSub
CloseBtn.Font                 = Enum.Font.GothamBold
CloseBtn.TextSize             = 12
CloseBtn.AutoButtonColor      = false
CloseBtn.BorderSizePixel      = 0
CloseBtn.ZIndex               = 24
corner(CloseBtn, 6)
stroke(CloseBtn, C.borderSub, 1, 0.4)
bind(CloseBtn.MouseEnter, function() tw(CloseBtn, TI._008, {BackgroundColor3=C.CLOSE_HOVER, TextColor3=C.text}) end)
bind(CloseBtn.MouseLeave, function() tw(CloseBtn, TI._012, {BackgroundColor3=C.surface, TextColor3=C.textSub}) end)
bind(CloseBtn.MouseButton1Down, function() tw(getPopScale(CloseBtn), TI._008, {Scale=0.88}) end)
bind(CloseBtn.MouseButton1Up, function() tw(getPopScale(CloseBtn), TI._016, {Scale=1}) end)


local FULL_SIZE   = UDim2.new(0, PANEL_W, 0, PANEL_H)
local isMinimized = false

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        tw(frame, TI._016, { Size = UDim2.new(0, PANEL_W, 0, 38) })
        MinBtn.Text = "+"
        headerCornerFix.Visible = false
        headerLine.Visible      = false
    else
        tw(frame, TI._016, { Size = FULL_SIZE })
        MinBtn.Text = "-"
        headerCornerFix.Visible = true
        headerLine.Visible      = true
    end
end

bind(MinBtn.MouseButton1Click, toggleMinimize)
bind(CloseBtn.MouseButton1Click, function() runtime.cleanup() end)


local dragging = false
local dragOX, dragOY = 0, 0
local startPX, startPY = 0, 0
local startSX, startSY = 0, 0

Header.InputBegan:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    dragging = true
    dragOX, dragOY = inp.Position.X, inp.Position.Y
    local p = frame.Position
    startSX, startPX = p.X.Scale, p.X.Offset
    startSY, startPY = p.Y.Scale, p.Y.Offset
    inp.Changed:Connect(function()
        if inp.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end)

UserInputService.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    frame.Position = UDim2.new(startSX, startPX + inp.Position.X - dragOX,
                                startSY, startPY + inp.Position.Y - dragOY)
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)


local CONTENT_Y = 38
local CONTENT_H = PANEL_H - CONTENT_Y

mkVSep(frame, CONTENT_Y + PAD, CONTENT_H - PAD * 2)


local LY = CONTENT_Y + PAD   

mkLabel(frame, "PLAYBACK", COL1_X, LY, COL_W, 13, C.textSub, 9)
LY = LY + 15   


local playBtn = mkBtn(frame, "PLAY", COL1_X, LY, COL_W, 34, C.accent, C.text)
LY = LY + 34 + 6   

local function updatePlayBtn()
    if playing then
        playBtn.Text = "STOP"
        playBtn.TextColor3 = C.text
        tw(playBtn, TI._016, { BackgroundColor3 = C.red })
    else
        playBtn.Text = "PLAY"
        playBtn.TextColor3 = C.text
        tw(playBtn, TI._016, { BackgroundColor3 = C.accent })
    end
end

bind(playBtn.MouseButton1Click, function()
    if not trackLoaded then return end
    if playing then
        track:Stop(); playing = false; frozen = false
    else
        track:Play(); track:AdjustSpeed(currentSpeed); playing = true; frozen = false
    end
    updatePlayBtn()
end)


local halfW = math.floor((COL_W - 4) / 2)
local loopBtn = mkBtn(frame, "LOOP: ON",  COL1_X,            LY, halfW, 26, C.surface, C.text)
local ppBtn   = mkBtn(frame, "PING-PONG", COL1_X + halfW + 4, LY, halfW, 26, C.surface, C.textSub)
LY = LY + 26 + 6   

bind(loopBtn.MouseButton1Click, function()
    looping = not looping
    if trackLoaded then track.Looped = looping end
    pingPong = false
    tw(ppBtn, TI._016, { BackgroundColor3 = C.surface })
    ppBtn.TextColor3 = C.textSub; ppBtn.Text = "PING-PONG"
    loopBtn.Text = looping and "LOOP: ON" or "LOOP: OFF"
    loopBtn.TextColor3 = looping and C.accent or C.text
    tw(loopBtn, TI._016, { BackgroundColor3 = looping and C.surface or C.surface })
end)
bind(ppBtn.MouseButton1Click, function()
    pingPong = not pingPong
    if pingPong then
        looping = true
        if trackLoaded then track.Looped = false end
        loopBtn.TextColor3 = C.accent; loopBtn.Text = "LOOP: ON"
        tw(loopBtn, TI._016, { BackgroundColor3 = C.surface })
    end
    ppBtn.TextColor3 = pingPong and C.yellow or C.textSub
    ppBtn.Text = pingPong and "PING-PONG: ON" or "PING-PONG"
    tw(ppBtn, TI._016, { BackgroundColor3 = pingPong and C.yellowDark or C.surface })
end)


mkSep(frame, COL1_X, LY, COL_W); LY = LY + 8   


local thirdW = math.floor((COL_W - 8) / 3)
local stepBackBtn = mkBtn(frame, "< Frame", COL1_X,                     LY, thirdW, 26, C.surface, C.textSub)
local freezeBtn   = mkBtn(frame, "FREEZE",  COL1_X + thirdW + 4,       LY, thirdW, 26, C.surface, C.textSub)
local stepFwdBtn  = mkBtn(frame, "Frame >", COL1_X + (thirdW + 4) * 2, LY, thirdW, 26, C.surface, C.textSub)
LY = LY + 26 + 6   

local function doStep(delta)
    frozen = true
    setTime(safeTime() + delta)
end

bind(stepBackBtn.MouseButton1Click, function() doStep(-FRAME_STEP) end)
bind(stepFwdBtn.MouseButton1Click, function()  doStep( FRAME_STEP) end)

bind(freezeBtn.MouseButton1Click, function()
    if not trackLoaded then return end
    frozen = not frozen
    if frozen then
        pcall(function() track:AdjustSpeed(0) end)
        freezeBtn.Text = "FROZEN"
        freezeBtn.TextColor3 = C.text
        tw(freezeBtn, TI._016, { BackgroundColor3 = C.blueDark })
    else
        if playing then pcall(function() track:AdjustSpeed(currentSpeed) end) end
        freezeBtn.Text = "FREEZE"
        freezeBtn.TextColor3 = C.textSub
        tw(freezeBtn, TI._016, { BackgroundColor3 = C.surface })
    end
end)


mkSep(frame, COL1_X, LY, COL_W); LY = LY + 8   
mkLabel(frame, "MOTOR6DS", COL1_X, LY, COL_W, 13, C.textSub, 9)
LY = LY + 15   

local partsLabel = Instance.new("TextLabel")
partsLabel.Size               = UDim2.new(0, COL_W, 0, PANEL_H - LY - PAD)
partsLabel.Position           = UDim2.new(0, COL1_X, 0, LY)
partsLabel.BackgroundTransparency = 1
partsLabel.Text               = "Scanning..."
partsLabel.TextColor3         = C.textSub
partsLabel.Font               = Enum.Font.Gotham
partsLabel.TextSize           = 10
partsLabel.TextWrapped        = true
partsLabel.TextXAlignment     = Enum.TextXAlignment.Left
partsLabel.TextYAlignment     = Enum.TextYAlignment.Top
partsLabel.Parent             = frame

local function scanMotors()
    local names = {}
    for _, obj in ipairs(character:GetDescendants()) do
        local ok, is = pcall(function() return obj:IsA("Motor6D") end)
        if ok and is then table.insert(names, obj.Name) end
    end
    partsLabel.Text = #names > 0 and table.concat(names, "  ·  ") or "No Motor6Ds found"
end
scanMotors()


local RY = CONTENT_Y + PAD   

mkLabel(frame, "SPEED", COL2_X, RY, COL_W, 13, C.textSub, 9)
RY = RY + 15   

local speedLabel = mkLabel(frame, "Speed: 0.0001  (Freeze-ish)", COL2_X, RY, COL_W, 13, C.text, 10)
RY = RY + 15   


local SBTN_W = math.floor((COL_W - 3 * 4) / 4)
local SBTN_H = 24
local speedBtns = {}
local speedBtnStrokes = {}

for i, spd in ipairs(SPEEDS) do
    local col = (i - 1) % 4
    local row = math.floor((i - 1) / 4)
    local bx  = COL2_X + col * (SBTN_W + 4)
    local by  = RY      + row * (SBTN_H + 4)
    local isA = (spd.val == currentSpeed)

    local btn = mkBtn(frame, spd.name, bx, by, SBTN_W, SBTN_H,
                      C.surface, isA and C.accent or C.text)
    btn.TextSize = 10
    speedBtns[spd.val] = btn

    
    local btnStroke = btn:FindFirstChildOfClass("UIStroke")
    if isA and btnStroke then btnStroke.Color = C.accent; btnStroke.Transparency = 0.3 end
    speedBtnStrokes[spd.val] = btnStroke

    bind(btn.MouseButton1Click, function()
        currentSpeed = spd.val
        speedLabel.Text = "Speed: " .. spd.name .. "  (" .. spd.desc .. ")"
        if playing and not frozen and trackLoaded then
            pcall(function() track:AdjustSpeed(currentSpeed) end)
        end
        for val, b in pairs(speedBtns) do
            local a = (val == spd.val)
            b.TextColor3 = a and C.accent or C.text
            local s = speedBtnStrokes[val]
            if s then tw(s, TI._016, { Color = a and C.accent or C.borderSub, Transparency = a and 0.3 or 0.55 }) end
        end
    end)
end

RY = RY + 2 * (SBTN_H + 4) + 2   


local customBox = Instance.new("TextBox")
customBox.Size             = UDim2.new(0, COL_W - 64 - 4, 0, 24)
customBox.Position         = UDim2.new(0, COL2_X, 0, RY)
customBox.BackgroundColor3 = C.surface
customBox.BackgroundTransparency = 0
customBox.Text             = ""
customBox.PlaceholderText  = "Custom speed..."
customBox.PlaceholderColor3 = C.textSub
customBox.TextColor3       = C.text
customBox.Font             = Enum.Font.Code
customBox.TextSize         = 10
customBox.ClearTextOnFocus = true
customBox.TextXAlignment   = Enum.TextXAlignment.Left
customBox.BorderSizePixel  = 0
customBox.Parent           = frame
corner(customBox, 6)
stroke(customBox, C.borderSub, 1, 0.4)

local customApply = mkBtn(frame, "Apply", COL2_X + COL_W - 60, RY, 60, 24, C.surface, C.textSub)
customApply.TextSize = 10

bind(customApply.MouseButton1Click, function()
    local val = tonumber(customBox.Text)
    if not val then return end
    val = math.clamp(val, -20, 20)
    currentSpeed = val
    speedLabel.Text = string.format("Speed: %.4f  (custom)", val)
    if playing and not frozen and trackLoaded then
        pcall(function() track:AdjustSpeed(val) end)
    end
end)

RY = RY + 24 + 6   


mkSep(frame, COL2_X, RY, COL_W); RY = RY + 8   


mkLabel(frame, "TIMELINE", COL2_X, RY, COL_W, 13, C.textSub, 9)
RY = RY + 15   

local scrubLabel = mkLabel(frame, "Time: 0.00 / 0.00s", COL2_X, RY, COL_W, 13, C.text, 10)
RY = RY + 15   


local sliderBg = Instance.new("TextButton")
sliderBg.Size             = UDim2.new(0, COL_W, 0, 12)
sliderBg.Position         = UDim2.new(0, COL2_X, 0, RY)
sliderBg.BackgroundColor3 = C.surface
sliderBg.BackgroundTransparency = 0
sliderBg.Text             = ""
sliderBg.AutoButtonColor  = false
sliderBg.ClipsDescendants = true
sliderBg.BorderSizePixel  = 0
sliderBg.Parent           = frame
corner(sliderBg, 6)
stroke(sliderBg, C.borderSub, 1, 0.3)

local sliderFill = Instance.new("Frame")
sliderFill.Size             = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = C.accent
sliderFill.BorderSizePixel  = 0
sliderFill.Parent           = sliderBg
corner(sliderFill, 6)

local markerLayer = Instance.new("Frame")
markerLayer.Size             = UDim2.new(1, 0, 1, 0)
markerLayer.BackgroundTransparency = 1
markerLayer.ZIndex           = 4
markerLayer.Parent           = sliderBg

local sliderKnob = Instance.new("Frame")
sliderKnob.Size             = UDim2.new(0, 10, 0, 10)
sliderKnob.AnchorPoint      = Vector2.new(0.5, 0.5)
sliderKnob.Position         = UDim2.new(0, 0, 0.5, 0)
sliderKnob.BackgroundColor3 = C.accent
sliderKnob.BorderSizePixel  = 0
sliderKnob.ZIndex           = 6
sliderKnob.Parent           = sliderBg
corner(sliderKnob, 5)

local sliderKnobDot = Instance.new("Frame")
sliderKnobDot.Size             = UDim2.new(0, 4, 0, 4)
sliderKnobDot.AnchorPoint      = Vector2.new(0.5, 0.5)
sliderKnobDot.Position         = UDim2.new(0.5, 0, 0.5, 0)
sliderKnobDot.BackgroundColor3 = C.text
sliderKnobDot.BorderSizePixel  = 0
sliderKnobDot.ZIndex           = 7
sliderKnobDot.Parent           = sliderKnob
corner(sliderKnobDot, 2)

RY = RY + 12 + 6   

local sliderDragging = false

local function updateSlider(pct)
    pct = clamp01(pct)
    sliderKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    sliderFill.Size     = UDim2.new(pct, 0, 1, 0)
end

local function scrubTo(pct)
    if not trackLoaded then return end
    local t = pct * safeLen()
    setTime(t)
    updateSlider(pct)
    scrubLabel.Text = string.format("Time: %.2f / %.2fs", t, safeLen())
end

bind(sliderBg.InputBegan, function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    sliderDragging = true
    frozen = true
    if playing then pcall(function() track:AdjustSpeed(0) end) end
    scrubTo(clamp01((inp.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X))
end)

UserInputService.InputChanged:Connect(function(inp)
    if not sliderDragging then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    scrubTo(clamp01((inp.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X))
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not sliderDragging then return end
    sliderDragging = false
    if playing then pcall(function() track:AdjustSpeed(currentSpeed) end); frozen = false end
end)


mkSep(frame, COL2_X, RY, COL_W); RY = RY + 8   


mkLabel(frame, "MARKERS", COL2_X, RY, COL_W, 13, C.textSub, 9)
RY = RY + 15   

local markerListLabel = mkLabel(frame, "No markers", COL2_X, RY, COL_W, 13, C.textSub, 9)
RY = RY + 15   

local mBtnW = math.floor((COL_W - 4 * 2) / 3)
local addMarkBtn  = mkBtn(frame, "+ Mark",  COL2_X,                    RY, mBtnW, 24, C.greenDark, C.green)
local jumpMarkBtn = mkBtn(frame, "Next >",  COL2_X + mBtnW + 4,       RY, mBtnW, 24, C.surface, C.textSub)
local clrMarkBtn  = mkBtn(frame, "Clear",   COL2_X + (mBtnW + 4) * 2, RY, mBtnW, 24, C.surface, C.red)

addMarkBtn.TextSize  = 10
jumpMarkBtn.TextSize = 10
clrMarkBtn.TextSize  = 10

local function rebuildMarkers()
    for _, c in ipairs(markerLayer:GetChildren()) do c:Destroy() end
    local texts = {}
    for _, m in ipairs(markers) do
        local pct = m / safeLen()
        local dot = Instance.new("Frame")
        dot.Size             = UDim2.new(0, 3, 0, 12)
        dot.Position         = UDim2.new(pct, -1, 0, 0)
        dot.BackgroundColor3 = C.yellow
        dot.BorderSizePixel  = 0
        dot.ZIndex           = 5
        dot.Parent           = markerLayer
        table.insert(texts, string.format("%.2fs", m))
    end
    markerListLabel.Text = #markers > 0 and (table.concat(texts, "  ·  ")) or "No markers"
end

bind(addMarkBtn.MouseButton1Click, function()
    table.insert(markers, safeTime())
    rebuildMarkers()
end)

bind(clrMarkBtn.MouseButton1Click, function()
    markers = {}
    rebuildMarkers()
end)

bind(jumpMarkBtn.MouseButton1Click, function()
    if #markers == 0 then return end
    local cur    = safeTime()
    local target = nil
    for _, m in ipairs(markers) do
        if m > cur + 0.01 then
            if not target or m < target then target = m end
        end
    end
    if not target then target = markers[1] end
    scrubTo(target / safeLen())
end)


bind(RunService.RenderStepped, function(dt)
    if not trackLoaded then return end
    local t   = safeTime()
    local len = safeLen()
    local pct = clamp01(t / len)

    if not sliderDragging then
        updateSlider(pct)
        scrubLabel.Text = string.format("Time: %.2f / %.2fs", t, len)
    end

    if pingPong and playing and not frozen then
        if pingPongDir == 1 and t >= len - 0.02 then
            pingPongDir = -1
            pcall(function() track:AdjustSpeed(-math.abs(currentSpeed)) end)
        elseif pingPongDir == -1 and t <= 0.02 then
            pingPongDir = 1
            pcall(function() track:AdjustSpeed(math.abs(currentSpeed)) end)
        end
    end
end)


bind(player.CharacterAdded, function(newChar)
    task.wait(1)
    character = newChar
    humanoid  = newChar:WaitForChild("Humanoid")
    animator  = humanoid:WaitForChild("Animator")
    loadTrack()
    scanMotors()
    playing = false; frozen = false
    updatePlayBtn()
end)

end) 
