

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local systemActive = false
local flingActive  = false
local ATTACH_OFFSET = Vector3.new(0, 0, -4)

local flingMode      = "nearest"
local specificTarget = nil
local blacklist      = {}

local FLING_CFG = {
    APPROACH_RADIUS = 5,
    IMPACT_DISTANCE = 2.5,
    IMPACT_COOLDOWN = 0.08,
    IMPULSE_POWER   = 80000,
    IMPULSE_UPWARD  = 80000,
    APPROACH_SPEED  = 90000,
    ANGULAR_SPEED   = 99999,
    DENSITY         = 100,
    FRICTION        = 0,
    ELASTICITY      = 0,
}


local function isBlacklisted(player) return blacklist[player] == true end


local TrackingAI = {}
local _trackDot  = nil

function TrackingAI.setDot(hrp)
    if _trackDot then
        if _trackDot.Adornee == hrp then return end
        _trackDot:Destroy(); _trackDot = nil
    end
    if not hrp then return end
    local old = hrp:FindFirstChild("TLEXDot")
    if old then old:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name        = "TLEXDot"
    bb.Size        = UDim2.new(0, 16, 0, 16)
    bb.StudsOffset = Vector3.new(0, 0.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee     = hrp
    bb.Parent      = hrp
    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(1, 0, 1, 0)
    dot.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
    dot.BorderSizePixel  = 0
    dot.Parent           = bb
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local g = Instance.new("UIStroke")
    g.Color        = Color3.fromRGB(255, 100, 100)
    g.Thickness    = 2.5
    g.Transparency = 0.2
    g.Parent       = dot
    _trackDot = bb
end

function TrackingAI.clearDot()
    if _trackDot then _trackDot:Destroy(); _trackDot = nil end
end

function TrackingAI.track(ball, targetHRP, dt)
    if not ball or not targetHRP then return end

    local rx = (math.random() - 0.5) * 0.3
    local ry = (math.random() - 0.5) * 0.3
    local rz = (math.random() - 0.5) * 0.3

    ball.CFrame = targetHRP.CFrame
        * CFrame.new(rx, ry, rz)
        * CFrame.Angles(
            math.rad(math.random(0, 360)),
            math.rad(math.random(0, 360)),
            math.rad(math.random(0, 360))
        )

    local force  = FLING_CFG.IMPULSE_POWER
    local upward = FLING_CFG.IMPULSE_UPWARD
    local spin   = FLING_CFG.ANGULAR_SPEED

    ball.AssemblyLinearVelocity = Vector3.new(
        math.random(-force, force),
        upward + math.random(0, force),
        math.random(-force, force)
    )
    ball.AssemblyAngularVelocity = Vector3.new(
        math.random() > 0.5 and spin or -spin,
        math.random() > 0.5 and spin or -spin,
        math.random() > 0.5 and spin or -spin
    )
end


local guiName = "TLEXFlingUI"
if game.CoreGui:FindFirstChild(guiName) then
    game.CoreGui[guiName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name         = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent       = game.CoreGui

local C = {
    bg        = Color3.fromRGB(9,   9,  11),
    panel     = Color3.fromRGB(13,  13, 16),
    surface   = Color3.fromRGB(17,  17, 21),
    elevated  = Color3.fromRGB(22,  22, 27),
    borderSub = Color3.fromRGB(55,  55, 65),
    white     = Color3.fromRGB(255,255,255),
    text      = Color3.fromRGB(240,240,245),
    textSub   = Color3.fromRGB(120,120,135),
    textMuted = Color3.fromRGB(55,  55, 68),
}

local function corner(inst, r)
    Instance.new("UICorner", inst).CornerRadius = r or UDim.new(0, 10)
end
local function stroke(inst, col, thick, trans)
    local s = Instance.new("UIStroke", inst)
    s.Color        = col   or C.borderSub
    s.Thickness    = thick or 1
    s.Transparency = trans or 0
    return s
end
local function pad(inst, v, h)
    local p = Instance.new("UIPadding", inst)
    local vv = UDim.new(0, v or 0)
    local hh = UDim.new(0, h or v or 0)
    p.PaddingTop = vv; p.PaddingBottom = vv
    p.PaddingLeft = hh; p.PaddingRight = hh
end
local function listLayout(parent, pad_, dir)
    local l = Instance.new("UIListLayout", parent)
    l.Padding       = UDim.new(0, pad_ or 0)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    return l
end


local Main = Instance.new("Frame", ScreenGui)
Main.Name                = "TLEXPanel"
Main.Size                = UDim2.new(0, 310, 0, 490)
Main.Position            = UDim2.new(0.5, -155, 0.5, -245)
Main.BackgroundTransparency = 1
Main.BorderSizePixel     = 0
corner(Main, UDim.new(0, 14))
stroke(Main, C.borderSub, 1, 0.3)

local InnerClip = Instance.new("Frame", Main)
InnerClip.Size               = UDim2.new(1, 0, 1, 0)
InnerClip.BackgroundColor3   = C.bg
InnerClip.BorderSizePixel    = 0
InnerClip.ClipsDescendants   = true
corner(InnerClip, UDim.new(0, 14))


local Header = Instance.new("Frame", InnerClip)
Header.Size             = UDim2.new(1, 0, 0, 46)
Header.BackgroundColor3 = C.panel
Header.BorderSizePixel  = 0

local HeaderAccent = Instance.new("Frame", Header)
HeaderAccent.Size             = UDim2.new(0, 3, 1, 0)
HeaderAccent.BackgroundColor3 = C.white
HeaderAccent.BorderSizePixel  = 0
HeaderAccent.ZIndex           = 3

local TitleWrap = Instance.new("Frame", Header)
TitleWrap.Size               = UDim2.new(1, 0, 1, 0)
TitleWrap.BackgroundTransparency = 1
TitleWrap.ZIndex             = 2

local TitleLbl = Instance.new("TextLabel", TitleWrap)
TitleLbl.Size               = UDim2.new(1, 0, 1, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text               = "TLEX  FLING"
TitleLbl.TextColor3         = C.text
TitleLbl.Font               = Enum.Font.GothamBlack
TitleLbl.TextSize           = 13
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Center

local WinCtrlRow = Instance.new("Frame", Header)
WinCtrlRow.Size                 = UDim2.new(0, 54, 0, 12)
WinCtrlRow.Position             = UDim2.new(1, -62, 0.5, -6)
WinCtrlRow.BackgroundTransparency = 1
WinCtrlRow.ZIndex               = 4
listLayout(WinCtrlRow, 6, Enum.FillDirection.Horizontal)

local function winDot(parent, col)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(0, 10, 0, 10)
    btn.BackgroundColor3 = col
    btn.Text             = ""
    btn.AutoButtonColor  = false
    btn.BorderSizePixel  = 0
    corner(btn, UDim.new(1, 0))
    stroke(btn, Color3.fromRGB(255,255,255), 0.5, 0.82)
    return btn
end

local CloseBtn = winDot(WinCtrlRow, Color3.fromRGB(200,200,200))
local MinBtn   = winDot(WinCtrlRow, Color3.fromRGB(100,100,100))
local MaxBtn   = winDot(WinCtrlRow, Color3.fromRGB(60, 60, 60))

local HDivider = Instance.new("Frame", Header)
HDivider.Size                 = UDim2.new(1, 0, 0, 1)
HDivider.Position             = UDim2.new(0, 0, 1, -1)
HDivider.BackgroundColor3     = C.borderSub
HDivider.BackgroundTransparency = 0.4
HDivider.BorderSizePixel      = 0


local TabOuter = Instance.new("Frame", InnerClip)
TabOuter.Size             = UDim2.new(1, -24, 0, 28)
TabOuter.Position         = UDim2.new(0, 12, 0, 54)
TabOuter.BackgroundColor3 = C.panel
TabOuter.BorderSizePixel  = 0
corner(TabOuter, UDim.new(0, 8))
stroke(TabOuter, C.borderSub, 1, 0.35)

local TabInner = Instance.new("Frame", TabOuter)
TabInner.Size                 = UDim2.new(1, -4, 1, -4)
TabInner.Position             = UDim2.new(0, 2, 0, 2)
TabInner.BackgroundTransparency = 1
listLayout(TabInner, 3, Enum.FillDirection.Horizontal)

local ContentClip = Instance.new("Frame", InnerClip)
ContentClip.Size                 = UDim2.new(1, 0, 1, -92)
ContentClip.Position             = UDim2.new(0, 0, 0, 92)
ContentClip.BackgroundTransparency = 1
ContentClip.ClipsDescendants     = false

local tabs     = {}
local tabPages = {}
local tabNames = {"Main", "Fling Target", "Blacklist", "Config"}

local function setTab(name)
    for _, t in pairs(tabs) do
        local on = t.name == name
        TweenService:Create(t.btn, TweenInfo.new(0.18), {
            BackgroundColor3 = on and C.white or C.panel,
            TextColor3       = on and C.bg    or C.textSub,
        }):Play()
    end
    for n, pg in pairs(tabPages) do pg.Visible = n == name end
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", TabInner)
    btn.Size             = UDim2.new(1/#tabNames, i < #tabNames and -3 or 0, 1, 0)
    btn.BackgroundColor3 = i == 1 and C.white or C.panel
    btn.Text             = name
    btn.TextColor3       = i == 1 and C.bg    or C.textSub
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextSize         = 10
    btn.AutoButtonColor  = false
    btn.BorderSizePixel  = 0
    corner(btn, UDim.new(0, 6))

    local pg = Instance.new("Frame", ContentClip)
    pg.Size                 = UDim2.new(1, 0, 1, 0)
    pg.BackgroundTransparency = 1
    pg.Visible              = i == 1
    tabPages[name]          = pg

    table.insert(tabs, {name = name, btn = btn})
    btn.MouseButton1Click:Connect(function() setTab(name) end)
end


local function card(parent, h, yOff)
    local f = Instance.new("Frame", parent)
    f.Size             = UDim2.new(1, -24, 0, h)
    f.Position         = UDim2.new(0, 12, 0, yOff)
    f.BackgroundColor3 = C.surface
    f.BorderSizePixel  = 0
    corner(f, UDim.new(0, 10))
    stroke(f, C.borderSub, 1, 0.45)
    return f
end

local function eyebrow(parent, txt, yOff)
    local l = Instance.new("TextLabel", parent)
    l.Size               = UDim2.new(1, -24, 0, 14)
    l.Position           = UDim2.new(0, 12, 0, yOff)
    l.BackgroundTransparency = 1
    l.Text               = txt
    l.TextColor3         = C.textMuted
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = 9
    l.TextXAlignment     = Enum.TextXAlignment.Left
    return l
end

local function makeToggle(parent, yOff, mainTxt, subTxt, initOn)
    local f = card(parent, 52, yOff)

    local left = Instance.new("Frame", f)
    left.Size                 = UDim2.new(0.7, 0, 1, 0)
    left.BackgroundTransparency = 1
    pad(left, 0, 14)

    local lStack = Instance.new("Frame", left)
    lStack.Size                 = UDim2.new(1, 0, 1, 0)
    lStack.BackgroundTransparency = 1
    listLayout(lStack, 3, Enum.FillDirection.Vertical)
    Instance.new("UIPadding", lStack).PaddingTop = UDim.new(0, 10)

    local m = Instance.new("TextLabel", lStack)
    m.Size               = UDim2.new(1, 0, 0, 16)
    m.BackgroundTransparency = 1
    m.Text               = mainTxt
    m.TextColor3         = C.text
    m.Font               = Enum.Font.GothamSemibold
    m.TextSize           = 12
    m.TextXAlignment     = Enum.TextXAlignment.Left

    if subTxt then
        local s = Instance.new("TextLabel", lStack)
        s.Size               = UDim2.new(1, 0, 0, 12)
        s.BackgroundTransparency = 1
        s.Text               = subTxt
        s.TextColor3         = C.textMuted
        s.Font               = Enum.Font.Gotham
        s.TextSize           = 9
        s.TextXAlignment     = Enum.TextXAlignment.Left
    end

    local track = Instance.new("TextButton", f)
    track.Size             = UDim2.new(0, 36, 0, 18)
    track.Position         = UDim2.new(1, -50, 0.5, -9)
    track.BackgroundColor3 = initOn and C.white or C.elevated
    track.Text             = ""
    track.AutoButtonColor  = false
    track.BorderSizePixel  = 0
    corner(track, UDim.new(1, 0))
    stroke(track, C.borderSub, 1, 0.3)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 12, 0, 12)
    knob.Position         = initOn and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = initOn and C.bg or C.textSub
    knob.BorderSizePixel  = 0
    corner(knob, UDim.new(1, 0))

    local state = initOn
    local cbs   = {}

    track.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.16), {
            BackgroundColor3 = state and C.white or C.elevated,
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position         = state and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),
            BackgroundColor3 = state and C.bg or C.textSub,
        }):Play()
        for _, cb in ipairs(cbs) do cb(state) end
    end)

    return {
        getState  = function() return state end,
        setState  = function(v)
            state = v
            TweenService:Create(track, TweenInfo.new(0.16), {
                BackgroundColor3 = v and C.white or C.elevated,
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position         = v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6),
                BackgroundColor3 = v and C.bg or C.textSub,
            }):Play()
        end,
        onChanged = function(cb) table.insert(cbs, cb) end,
    }
end

local function makePill(parent, yOff, initTxt)
    local f = card(parent, 26, yOff)

    local dot = Instance.new("Frame", f)
    dot.Size             = UDim2.new(0, 5, 0, 5)
    dot.Position         = UDim2.new(0, 12, 0.5, -2.5)
    dot.BackgroundColor3 = C.textMuted
    dot.BorderSizePixel  = 0
    corner(dot, UDim.new(1, 0))

    local lbl = Instance.new("TextLabel", f)
    lbl.Size                 = UDim2.new(1, -26, 1, 0)
    lbl.Position             = UDim2.new(0, 24, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = initTxt
    lbl.TextColor3           = C.textSub
    lbl.Font                 = Enum.Font.GothamMedium
    lbl.TextSize             = 10
    lbl.TextXAlignment       = Enum.TextXAlignment.Left

    return {
        setText  = function(t) lbl.Text = t end,
        setColor = function(c)
            dot.BackgroundColor3 = c
            lbl.TextColor3       = c
        end,
    }
end

local function makeSearch(parent, yOff, hint)
    local f = card(parent, 30, yOff)

    local icon = Instance.new("TextLabel", f)
    icon.Size                 = UDim2.new(0, 26, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text                 = "⌕"
    icon.TextColor3           = C.textMuted
    icon.Font                 = Enum.Font.GothamMedium
    icon.TextSize             = 14
    icon.TextXAlignment       = Enum.TextXAlignment.Center

    local box = Instance.new("TextBox", f)
    box.Size               = UDim2.new(1, -30, 1, -2)
    box.Position           = UDim2.new(0, 26, 0, 1)
    box.BackgroundTransparency = 1
    box.PlaceholderText    = hint or "Suche..."
    box.PlaceholderColor3  = C.textMuted
    box.Text               = ""
    box.TextColor3         = C.text
    box.Font               = Enum.Font.Gotham
    box.TextSize           = 11
    box.TextXAlignment     = Enum.TextXAlignment.Left
    box.ClearTextOnFocus   = false
    return box
end

local function makePlayerList(parent, yOff, height, btnTxt, onAction)
    local outer  = card(parent, height, yOff)
    local scroll = Instance.new("ScrollingFrame", outer)
    scroll.Size                    = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency  = 1
    scroll.BorderSizePixel         = 0
    scroll.ScrollBarThickness      = 2
    scroll.ScrollBarImageColor3    = C.borderSub
    scroll.CanvasSize              = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize     = Enum.AutomaticSize.Y
    listLayout(scroll, 4)
    pad(scroll, 4, 4)

    local rows = {}

    local function addRow(player)
        if rows[player] then return end

        local row = Instance.new("Frame", scroll)
        row.Size             = UDim2.new(1, 0, 0, 40)
        row.BackgroundColor3 = C.elevated
        row.BorderSizePixel  = 0
        corner(row, UDim.new(0, 8))
        stroke(row, C.borderSub, 1, 0.55)

        local av = Instance.new("ImageLabel", row)
        av.Size             = UDim2.new(0, 26, 0, 26)
        av.Position         = UDim2.new(0, 8, 0.5, -13)
        av.BackgroundColor3 = C.panel
        av.BorderSizePixel  = 0
        corner(av, UDim.new(1, 0))
        stroke(av, C.borderSub, 1, 0.5)
        pcall(function()
            av.Image = Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size48x48
            )
        end)

        local dispN = Instance.new("TextLabel", row)
        dispN.Size             = UDim2.new(0.46, 0, 0, 14)
        dispN.Position         = UDim2.new(0, 42, 0, 6)
        dispN.BackgroundTransparency = 1
        dispN.Text             = player.DisplayName
        dispN.TextColor3       = C.text
        dispN.Font             = Enum.Font.GothamSemibold
        dispN.TextSize         = 11
        dispN.TextXAlignment   = Enum.TextXAlignment.Left
        dispN.TextTruncate     = Enum.TextTruncate.AtEnd

        local userN = Instance.new("TextLabel", row)
        userN.Size             = UDim2.new(0.46, 0, 0, 11)
        userN.Position         = UDim2.new(0, 42, 0, 21)
        userN.BackgroundTransparency = 1
        userN.Text             = "@" .. player.Name
        userN.TextColor3       = C.textMuted
        userN.Font             = Enum.Font.Gotham
        userN.TextSize         = 9
        userN.TextXAlignment   = Enum.TextXAlignment.Left
        userN.TextTruncate     = Enum.TextTruncate.AtEnd

        local ab = Instance.new("TextButton", row)
        ab.Size             = UDim2.new(0, 60, 0, 22)
        ab.Position         = UDim2.new(1, -68, 0.5, -11)
        ab.BackgroundColor3 = C.elevated
        ab.Text             = btnTxt
        ab.TextColor3       = C.text
        ab.Font             = Enum.Font.GothamSemibold
        ab.TextSize         = 9
        ab.AutoButtonColor  = false
        ab.BorderSizePixel  = 0
        corner(ab, UDim.new(0, 8))
        stroke(ab, C.borderSub, 1, 0.3)

        ab.MouseButton1Click:Connect(function()
            onAction(player, row, ab)
        end)

        rows[player] = {frame = row, btn = ab}
    end

    local function removeRow(player)
        if rows[player] then
            rows[player].frame:Destroy()
            rows[player] = nil
        end
    end

    local function refreshFilter(q)
        q = q:lower()
        for p, d in pairs(rows) do
            d.frame.Visible = q == ""
                or p.DisplayName:lower():find(q, 1, true)
                or p.Name:lower():find(q, 1, true)
        end
    end

    return {addRow = addRow, removeRow = removeRow, refreshFilter = refreshFilter, rows = rows}
end


local MainPage = tabPages["Main"]

eyebrow(MainPage, "KONTROLLE", 8)

local sysToggle = makeToggle(MainPage, 26, "System aktivieren", "Ball-Kontrolle & Schutz", false)
sysToggle.onChanged(function(v) systemActive = v end)

local flingToggle = makeToggle(MainPage, 84, "Precision Fling", "Ball flingt Ziele", false)
flingToggle.onChanged(function(v) flingActive = v end)

eyebrow(MainPage, "STATUS", 146)

local statusBadge = makePill(MainPage, 164, "Offline")
local targetBadge = makePill(MainPage, 196, "Kein Ziel")

local infoCard = card(MainPage, 56, 232)

local iTitle = Instance.new("TextLabel", infoCard)
iTitle.Size                 = UDim2.new(1, -24, 0, 16)
iTitle.Position             = UDim2.new(0, 14, 0, 10)
iTitle.BackgroundTransparency = 1
iTitle.Text                 = "TLEX ENGINE"
iTitle.TextColor3           = C.text
iTitle.Font                 = Enum.Font.GothamBold
iTitle.TextSize             = 10
iTitle.TextXAlignment       = Enum.TextXAlignment.Left

local iSub = Instance.new("TextLabel", infoCard)
iSub.Size                 = UDim2.new(1, -24, 0, 12)
iSub.Position             = UDim2.new(0, 14, 0, 28)
iSub.BackgroundTransparency = 1
iSub.Text                 = "Approach + Impact Hybrid Fling"
iSub.TextColor3           = C.textMuted
iSub.Font                 = Enum.Font.Gotham
iSub.TextSize             = 9
iSub.TextXAlignment       = Enum.TextXAlignment.Left

local verTag = Instance.new("TextLabel", infoCard)
verTag.Size                 = UDim2.new(0, 40, 0, 14)
verTag.Position             = UDim2.new(1, -50, 0, 10)
verTag.BackgroundTransparency = 1
verTag.Text                 = "v3.0"
verTag.TextColor3           = C.textMuted
verTag.Font                 = Enum.Font.GothamBold
verTag.TextSize             = 9
verTag.TextXAlignment       = Enum.TextXAlignment.Right


local FlingPage = tabPages["Fling Target"]

eyebrow(FlingPage, "MODUS", 8)

local modeCard  = card(FlingPage, 32, 26)
local modeInner = Instance.new("Frame", modeCard)
modeInner.Size                 = UDim2.new(1, -8, 1, -8)
modeInner.Position             = UDim2.new(0, 4, 0, 4)
modeInner.BackgroundTransparency = 1
listLayout(modeInner, 4, Enum.FillDirection.Horizontal)

local modes    = {"Nearest", "Random", "Specific"}
local modeKeys = {"nearest", "random",  "specific"}
local modeBtns = {}

local function setMode(idx)
    flingMode = modeKeys[idx]
    if flingMode ~= "specific" then specificTarget = nil end
    for i, b in ipairs(modeBtns) do
        local on = i == idx
        TweenService:Create(b, TweenInfo.new(0.16), {
            BackgroundColor3 = on and C.white or C.elevated,
            TextColor3       = on and C.bg    or C.textSub,
        }):Play()
    end
end

for i, m in ipairs(modes) do
    local mb = Instance.new("TextButton", modeInner)
    mb.Size             = UDim2.new(1/#modes, i < #modes and -4 or 0, 1, 0)
    mb.BackgroundColor3 = i == 1 and C.white or C.elevated
    mb.Text             = m
    mb.TextColor3       = i == 1 and C.bg    or C.textSub
    mb.Font             = Enum.Font.GothamSemibold
    mb.TextSize         = 10
    mb.AutoButtonColor  = false
    mb.BorderSizePixel  = 0
    corner(mb, UDim.new(0, 6))
    modeBtns[i] = mb
    mb.MouseButton1Click:Connect(function() setMode(i) end)
end

eyebrow(FlingPage, "SPIELER", 68)

local targetSearch = makeSearch(FlingPage, 86, "Spieler suchen...")

local selectedIndicator = Instance.new("TextLabel", FlingPage)
selectedIndicator.Size                 = UDim2.new(1, -24, 0, 14)
selectedIndicator.Position             = UDim2.new(0, 12, 0, 122)
selectedIndicator.BackgroundTransparency = 1
selectedIndicator.Text                 = "Kein Ziel ausgewählt"
selectedIndicator.TextColor3           = C.textMuted
selectedIndicator.Font                 = Enum.Font.Gotham
selectedIndicator.TextSize             = 9
selectedIndicator.TextXAlignment       = Enum.TextXAlignment.Left

local targetListApi = nil
targetListApi = makePlayerList(
    FlingPage, 140, 218, "Wählen",
    function(player, row, btn)
        if specificTarget == player then
            specificTarget = nil
            btn.Text = "Wählen"
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=C.elevated, TextColor3=C.text}):Play()
            selectedIndicator.Text      = "Kein Ziel ausgewählt"
            selectedIndicator.TextColor3 = C.textMuted
            setMode(1)
        else
            if specificTarget and targetListApi.rows[specificTarget] then
                local prev = targetListApi.rows[specificTarget].btn
                prev.Text = "Wählen"
                TweenService:Create(prev, TweenInfo.new(0.15), {BackgroundColor3=C.elevated, TextColor3=C.text}):Play()
            end
            specificTarget = player
            btn.Text = "Aktiv"
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=C.white, TextColor3=C.bg}):Play()
            selectedIndicator.Text       = "▸  " .. player.DisplayName .. "  ·  @" .. player.Name
            selectedIndicator.TextColor3 = C.white
            setMode(3)
        end
    end
)

targetSearch:GetPropertyChangedSignal("Text"):Connect(function()
    targetListApi.refreshFilter(targetSearch.Text)
end)


local BlacklistPage = tabPages["Blacklist"]

eyebrow(BlacklistPage, "SCHUTZ", 8)

local friendsAutoToggle = makeToggle(
    BlacklistPage, 26, "Alle Friends schützen", "Auto-Blacklist", false
)

eyebrow(BlacklistPage, "SPIELER", 86)

local blSearch = makeSearch(BlacklistPage, 104, "Spieler suchen...")

local blCountLbl = Instance.new("TextLabel", BlacklistPage)
blCountLbl.Size                 = UDim2.new(1, -24, 0, 12)
blCountLbl.Position             = UDim2.new(0, 12, 0, 140)
blCountLbl.BackgroundTransparency = 1
blCountLbl.Text                 = "0 Spieler auf der Blacklist"
blCountLbl.TextColor3           = C.textMuted
blCountLbl.Font                 = Enum.Font.Gotham
blCountLbl.TextSize             = 9
blCountLbl.TextXAlignment       = Enum.TextXAlignment.Left

local function updateBlCount()
    local c = 0
    for _ in pairs(blacklist) do c += 1 end
    blCountLbl.Text = c .. " Spieler auf der Blacklist"
end

local blListApi = makePlayerList(
    BlacklistPage, 156, 210, "Blacklist",
    function(player, row, btn)
        if blacklist[player] then
            blacklist[player] = nil
            btn.Text = "Blacklist"
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=C.elevated, TextColor3=C.text}):Play()
            TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3=C.elevated}):Play()
        else
            blacklist[player] = true
            btn.Text = "Geschützt"
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=C.white, TextColor3=C.bg}):Play()
            TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3=C.panel}):Play()
        end
        updateBlCount()
    end
)

blSearch:GetPropertyChangedSignal("Text"):Connect(function()
    blListApi.refreshFilter(blSearch.Text)
end)


local function onPlayerAdded(player)
    if player == lp then return end
    task.defer(function()
        if not ScreenGui.Parent then return end
        targetListApi.addRow(player)
        blListApi.addRow(player)
        if blacklist[player] and blListApi.rows[player] then
            local br = blListApi.rows[player]
            br.btn.Text = "Geschützt"
            TweenService:Create(br.btn, TweenInfo.new(0), {BackgroundColor3=C.white, TextColor3=C.bg}):Play()
            br.frame.BackgroundColor3 = C.panel
        end
    end)
end

local function onPlayerRemoving(player)
    if specificTarget == player then
        specificTarget                = nil
        selectedIndicator.Text        = "Ziel hat verlassen"
        selectedIndicator.TextColor3  = C.textSub
        setMode(1)
    end
    blacklist[player] = nil
    targetListApi.removeRow(player)
    blListApi.removeRow(player)
    updateBlCount()
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end

friendsAutoToggle.onChanged(function(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local ok, isFriend = pcall(function() return lp:IsFriendsWith(p.UserId) end)
            if ok and isFriend then
                if state then
                    blacklist[p] = true
                    if blListApi.rows[p] then
                        local r = blListApi.rows[p]
                        r.btn.Text = "Geschützt"
                        TweenService:Create(r.btn, TweenInfo.new(0), {BackgroundColor3=C.white, TextColor3=C.bg}):Play()
                        r.frame.BackgroundColor3 = C.panel
                    end
                else
                    blacklist[p] = nil
                    if blListApi.rows[p] then
                        local r = blListApi.rows[p]
                        r.btn.Text = "Blacklist"
                        TweenService:Create(r.btn, TweenInfo.new(0), {BackgroundColor3=C.elevated, TextColor3=C.text}):Play()
                        r.frame.BackgroundColor3 = C.elevated
                    end
                end
            end
        end
    end
    updateBlCount()
end)



local ConfigPage = tabPages["Config"]

eyebrow(ConfigPage, "FLING ENGINE", 8)


local function makeSlider(parent, yOff, label, minVal, maxVal, initVal, decimals, onChanged)
    local f = card(parent, 48, yOff)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size                 = UDim2.new(0.6, 0, 0, 14)
    lbl.Position             = UDim2.new(0, 12, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = label
    lbl.TextColor3           = C.text
    lbl.Font                 = Enum.Font.GothamSemibold
    lbl.TextSize             = 10
    lbl.TextXAlignment       = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", f)
    valLbl.Size                 = UDim2.new(0.35, 0, 0, 14)
    valLbl.Position             = UDim2.new(0.6, 0, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text                 = tostring(initVal)
    valLbl.TextColor3           = C.textSub
    valLbl.Font                 = Enum.Font.GothamBold
    valLbl.TextSize             = 10
    valLbl.TextXAlignment       = Enum.TextXAlignment.Right

    local trackBg = Instance.new("Frame", f)
    trackBg.Size             = UDim2.new(1, -24, 0, 5)
    trackBg.Position         = UDim2.new(0, 12, 0, 30)
    trackBg.BackgroundColor3 = C.elevated
    trackBg.BorderSizePixel  = 0
    corner(trackBg, UDim.new(1, 0))

    local initPct = (initVal - minVal) / (maxVal - minVal)

    local fill = Instance.new("Frame", trackBg)
    fill.Size             = UDim2.new(initPct, 0, 1, 0)
    fill.BackgroundColor3 = C.white
    fill.BorderSizePixel  = 0
    corner(fill, UDim.new(1, 0))

    local knob = Instance.new("Frame", trackBg)
    knob.Size             = UDim2.new(0, 11, 0, 11)
    knob.Position         = UDim2.new(initPct, -5, 0.5, -5)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 3
    corner(knob, UDim.new(1, 0))

    local sliding = false

    local function updateSlider(inputPos)
        local relX = inputPos.X - trackBg.AbsolutePosition.X
        local pct  = math.clamp(relX / trackBg.AbsoluteSize.X, 0, 1)
        local raw  = minVal + (maxVal - minVal) * pct
        local mult = 10 ^ (decimals or 0)
        local val  = math.floor(raw * mult + 0.5) / mult
        pct = (val - minVal) / (maxVal - minVal)

        fill.Size     = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -5, 0.5, -5)
        valLbl.Text   = tostring(val)
        onChanged(val)
    end

    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            updateSlider(input.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
end


local yC = 26

eyebrow(ConfigPage, "FLING FORCE", yC)
yC += 18

makeSlider(ConfigPage, yC, "Impulse Power", 1000, 150000, FLING_CFG.IMPULSE_POWER, 0, function(v)
    FLING_CFG.IMPULSE_POWER = v
end)
yC += 54

makeSlider(ConfigPage, yC, "Impulse Upward", 1000, 150000, FLING_CFG.IMPULSE_UPWARD, 0, function(v)
    FLING_CFG.IMPULSE_UPWARD = v
end)
yC += 54

makeSlider(ConfigPage, yC, "Angular Speed", 1000, 999999, FLING_CFG.ANGULAR_SPEED, 0, function(v)
    FLING_CFG.ANGULAR_SPEED = v
end)
yC += 54

eyebrow(ConfigPage, "PHYSICS", yC)
yC += 18

makeSlider(ConfigPage, yC, "Density", 1, 100, FLING_CFG.DENSITY, 0, function(v)
    FLING_CFG.DENSITY = v
end)
yC += 54

makeSlider(ConfigPage, yC, "Friction", 0, 1, FLING_CFG.FRICTION, 2, function(v)
    FLING_CFG.FRICTION = v
end)
yC += 54

makeSlider(ConfigPage, yC, "Elasticity", 0, 1, FLING_CFG.ELASTICITY, 2, function(v)
    FLING_CFG.ELASTICITY = v
end)
yC += 54

eyebrow(ConfigPage, "APPROACH", yC)
yC += 18

makeSlider(ConfigPage, yC, "Approach Speed", 1000, 200000, FLING_CFG.APPROACH_SPEED, 0, function(v)
    FLING_CFG.APPROACH_SPEED = v
end)
yC += 54

makeSlider(ConfigPage, yC, "Impact Distance", 0.5, 10, FLING_CFG.IMPACT_DISTANCE, 1, function(v)
    FLING_CFG.IMPACT_DISTANCE = v
end)
yC += 54

makeSlider(ConfigPage, yC, "Impact Cooldown", 0.01, 1, FLING_CFG.IMPACT_COOLDOWN, 2, function(v)
    FLING_CFG.IMPACT_COOLDOWN = v
end)
yC += 54


local resetCard = card(ConfigPage, 32, yC)

local resetBtn = Instance.new("TextButton", resetCard)
resetBtn.Size             = UDim2.new(1, -20, 0, 20)
resetBtn.Position         = UDim2.new(0, 10, 0.5, -10)
resetBtn.BackgroundColor3 = C.elevated
resetBtn.Text             = "Reset to Default"
resetBtn.TextColor3       = C.textSub
resetBtn.Font             = Enum.Font.GothamSemibold
resetBtn.TextSize         = 10
resetBtn.AutoButtonColor  = false
resetBtn.BorderSizePixel  = 0
corner(resetBtn, UDim.new(0, 6))
stroke(resetBtn, C.borderSub, 1, 0.3)

resetBtn.MouseButton1Click:Connect(function()
    FLING_CFG.IMPULSE_POWER   = 80000
    FLING_CFG.IMPULSE_UPWARD  = 80000
    FLING_CFG.ANGULAR_SPEED   = 99999
    FLING_CFG.DENSITY         = 100
    FLING_CFG.FRICTION        = 0
    FLING_CFG.ELASTICITY      = 0
    FLING_CFG.APPROACH_SPEED  = 90000
    FLING_CFG.IMPACT_DISTANCE = 2.5
    FLING_CFG.IMPACT_COOLDOWN = 0.08

    
    TweenService:Create(resetBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = C.white,
        TextColor3       = C.bg,
    }):Play()
    task.delay(0.4, function()
        TweenService:Create(resetBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = C.elevated,
            TextColor3       = C.text,
        }):Play()
        resetBtn.Text = "Reset to Default"
    end)
    resetBtn.Text = "✓ Reset"
end)


local dragging, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = Main.Position
    end
end)
Header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)


local minimized = false

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(Main,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = minimized and UDim2.new(0,310,0,46) or UDim2.new(0,310,0,490)}
    ):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    systemActive = false
    flingActive  = false
    ScreenGui:Destroy()
end)

MaxBtn.MouseButton1Click:Connect(function()
    local big = Main.Size.Y.Offset > 500
    TweenService:Create(Main,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = big and UDim2.new(0,310,0,490) or UDim2.new(0,350,0,550)}
    ):Play()
end)


local function applyGodModeAntiFling(targetBall)
    if not targetBall or not lp.Character then return end
    for _, child in ipairs(targetBall:GetChildren()) do
        if child:IsA("NoCollisionConstraint") and child.Name:match("^GodAntiFling_") then
            if not child.Part0 or not child.Part0.Parent
            or not child.Part1 or not child.Part1.Parent then
                child:Destroy()
            end
        end
    end
    for _, part in ipairs(lp.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            local nccName = "GodAntiFling_" .. part.Name
            if not targetBall:FindFirstChild(nccName) then
                local ncc = Instance.new("NoCollisionConstraint")
                ncc.Name  = nccName
                ncc.Part0 = part
                ncc.Part1 = targetBall
                ncc.Parent = targetBall
            end
        end
    end
end

local function getNearestPlayer(myPos)
    local nearest, nearestName = nil, "Niemand"
    local dist = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and not isBlacklisted(p) then
            local c   = p.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (myPos - hrp.Position).Magnitude
                if d < dist then
                    dist        = d
                    nearest     = hrp
                    nearestName = p.DisplayName
                end
            end
        end
    end
    return nearest, nearestName
end

local function getRandomPlayer()
    local candidates = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and not isBlacklisted(p) then
            local c   = p.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                table.insert(candidates, p)
            end
        end
    end
    if #candidates == 0 then return nil, "Niemand" end
    local chosen = candidates[math.random(1, #candidates)]
    return chosen.Character.HumanoidRootPart, chosen.DisplayName
end

local function getSpecificPlayer()
    if not specificTarget then return nil, "Niemand" end
    if isBlacklisted(specificTarget) then return nil, "Blacklisted" end
    local c   = specificTarget.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChild("Humanoid")
    if hrp and hum and hum.Health > 0 then
        return hrp, specificTarget.DisplayName
    end
    return nil, specificTarget.DisplayName .. " (offline)"
end


local randomSwitchTimer   = 0
local currentRandomTarget = nil
local currentRandomName   = "Niemand"
local physicsApplied      = false
local lastPhysicsReapply  = 0
local lastBallCheckTime   = 0
local lastBallPos         = nil

local PHYSICS_REAPPLY_INTERVAL = 2
local BALL_CHECK_INTERVAL      = 1


local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

lp.CharacterAdded:Connect(function(char)
    myHRP          = char:WaitForChild("HumanoidRootPart", 10)
    physicsApplied = false
    lastBallPos    = nil
end)
lp.CharacterRemoving:Connect(function()
    myHRP = nil
end)


local cachedBall = workspace:FindFirstChild("Ball")

workspace.ChildAdded:Connect(function(child)
    if child.Name == "Ball" then
        cachedBall     = child
        physicsApplied = false
    end
end)
workspace.ChildRemoved:Connect(function(child)
    if child == cachedBall then
        cachedBall     = nil
        physicsApplied = false
        lastBallPos    = nil
    end
end)

local function getActiveBall()
    if cachedBall and cachedBall.Parent then return cachedBall end
    cachedBall = workspace:FindFirstChild("Ball")
    return cachedBall
end


local _lastSysState  = nil
local _lastBallFound = nil


RunService.Heartbeat:Connect(function(dt)

    
    if not systemActive then
        if _lastSysState ~= false then
            _lastSysState = false
            statusBadge.setText("Offline")
            statusBadge.setColor(C.textMuted)
            targetBadge.setText("Kein Ziel")
            targetBadge.setColor(C.textMuted)
            TrackingAI.clearDot()
        end
        return
    end

    if not myHRP then return end

    local ball = getActiveBall()

    if not ball then
        if _lastBallFound ~= false then
            _lastBallFound = false
            statusBadge.setText("Ball fehlt")
            statusBadge.setColor(C.textMuted)
            TrackingAI.clearDot()
        end
        physicsApplied = false
        return
    end

    
    if _lastSysState ~= true then
        _lastSysState = true
        statusBadge.setText("Aktiv")
        statusBadge.setColor(C.white)
    end
    if _lastBallFound ~= true then
        _lastBallFound = true
    end

    applyGodModeAntiFling(ball)

    sethiddenproperty(lp, "SimulationRadius", math.huge)
sethiddenproperty(lp, "MaxSimulationRadius", math.huge)
sethiddenproperty(ball, "NetworkOwnershipRule", 2)
sethiddenproperty(myHRP, "PhysicsRepRootPart", ball)
sethiddenproperty(ball, "RootPriority", 127)

    local now = tick()

    
    if not physicsApplied or (now - lastPhysicsReapply) >= PHYSICS_REAPPLY_INTERVAL then
        pcall(function()
            ball.CustomPhysicalProperties = PhysicalProperties.new(
                FLING_CFG.DENSITY,   FLING_CFG.FRICTION,   FLING_CFG.ELASTICITY,
                FLING_CFG.DENSITY,   FLING_CFG.FRICTION
            )
            ball:SetNetworkOwner(lp)
        end)
        physicsApplied    = true
        lastPhysicsReapply = now
    end

    ball.CanCollide = true

    
    if (now - lastBallCheckTime) >= BALL_CHECK_INTERVAL then
        lastBallCheckTime = now
        if lastBallPos and (ball.Position - lastBallPos).Magnitude > 50 then
            pcall(function() ball:SetNetworkOwner(lp) end)
            physicsApplied = false
        end
        lastBallPos = ball.Position
    end

    
    if flingActive then
        local targetHRP, tName = nil, "Niemand"

        if flingMode == "nearest" then
            targetHRP, tName = getNearestPlayer(myHRP.Position)
        elseif flingMode == "random" then
            randomSwitchTimer += dt
            if randomSwitchTimer >= 3 or currentRandomTarget == nil then
                randomSwitchTimer     = 0
                currentRandomTarget, currentRandomName = getRandomPlayer()
            end
            
            if currentRandomTarget then
                local c   = currentRandomTarget.Parent
                local hum = c and c:FindFirstChild("Humanoid")
                if not c or not hum or hum.Health <= 0 then
                    currentRandomTarget, currentRandomName = getRandomPlayer()
                end
            end
            targetHRP = currentRandomTarget
            tName     = currentRandomName
        elseif flingMode == "specific" then
            targetHRP, tName = getSpecificPlayer()
        end

        if targetHRP then
            targetBadge.setText("▸  " .. tName)
            targetBadge.setColor(C.white)
            TrackingAI.setDot(targetHRP)
            
            for _ = 1, 3 do
                TrackingAI.track(ball, targetHRP, dt)
            end
        else
            targetBadge.setText("Suche...")
            targetBadge.setColor(C.textSub)
            TrackingAI.clearDot()
            ball.CFrame = CFrame.new(
                (myHRP.CFrame * CFrame.new(ATTACH_OFFSET)).Position
            ) * ball.CFrame.Rotation
            ball.AssemblyAngularVelocity = Vector3.new(
                FLING_CFG.ANGULAR_SPEED,
                FLING_CFG.ANGULAR_SPEED,
                FLING_CFG.ANGULAR_SPEED
            )
            ball.AssemblyLinearVelocity = Vector3.new(0, 200, 0)
        end

    else
        
        targetBadge.setText("Schild aktiv")
        targetBadge.setColor(C.white)
        TrackingAI.clearDot()
        ball.CFrame = CFrame.new(
            (myHRP.CFrame * CFrame.new(ATTACH_OFFSET)).Position
        ) * ball.CFrame.Rotation
        ball.AssemblyAngularVelocity = Vector3.new(
            FLING_CFG.ANGULAR_SPEED,
            FLING_CFG.ANGULAR_SPEED,
            FLING_CFG.ANGULAR_SPEED
        )
        ball.AssemblyLinearVelocity = Vector3.new(0, 200, 0)
    end
end)