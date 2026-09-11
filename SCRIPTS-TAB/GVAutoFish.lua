--!nocheck
--============================================================
-- TLMenu Module: GVAutoFish (German Voice Auto Fishing V2)
-- Direct-State Controller: schreibt IsReeling direkt in den
-- FishingController (kein VirtualInput, keine Maus-Klicks).
-- Standalone-fähig & nahtlos in TLMenu integriert.
--============================================================

local M = {}
local _deps = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

if _G.__BreadFishV2 and _G.__BreadFishV2.shutdown then
    pcall(_G.__BreadFishV2.shutdown)
end
_G.__BreadFishV2Token = ((_G.__BreadFishV2Token or 0) + 1)
local MY = _G.__BreadFishV2Token

local S = {
    enabled = false, hold = false,
    prevFC = nil, fishVel = 0, lastHoldT = 0, blipUntil = 0,
    fishFn = nil, lastFind = 0,
    lastProg = 0, prevActive = false, lastEnd = 0, lastWasCatch = false,
    pendingSince = 0, lastActivate = 0,
    catches = 0, earned = 0,
    lastRewardText = "", lastRewardT = 0, lastRewardAmt = 0,
    status = "Bereit. Schalte AN zum Starten.",
    FC = nil, FU = nil,
}

local function resolveControllers()
    if not S.FC then
        pcall(function()
            S.FC = require(game:GetService("ReplicatedFirst").Controllers.Gameplay.FishingController)
        end)
    end
    if not S.FU then
        pcall(function()
            S.FU = require(game:GetService("ReplicatedStorage").Shared.FishingUtil)
        end)
    end
end
resolveControllers()

local PREDICT, EMA_A = 0.12, 0.35
local DEAD_FRAC, DEAD_MIN = 0.30, 0.012
local VEL_BRAKE = 0.30
local ANTI_IDLE, BLIP = 3.0, 0.12

local function alive() return MY == _G.__BreadFishV2Token end

local function findFishFn()
    local okC, conns = pcall(getconnections, RunService.RenderStepped)
    if not okC or type(conns) ~= "table" then return nil end
    for _, c in ipairs(conns) do
        local f = nil
        pcall(function() f = c.Function end)
        if type(f) == "function" then
            local okI, info = pcall(debug.getinfo, f)
            if okI and type(info) == "table" then
                if tostring(info.short_src or ""):find("FishingController", 1, true) then
                    if tonumber(info.linedefined) == 636 then
                        return f
                    else
                        local okU, ups = pcall(debug.getupvalues, f)
                        if okU and type(ups) == "table" and type(ups[1]) == "table" and ups[1].RegionCenterY ~= nil and type(ups[3]) == "boolean" then
                            return f
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function getUps(fn)
    local ok, ups = pcall(debug.getupvalues, fn)
    if ok and type(ups) == "table" and type(ups[1]) == "table"
        and ups[1].RegionCenterY ~= nil and type(ups[3]) == "boolean" then
        return ups
    end
    return nil
end

local function writeHold(fn, v)
    pcall(debug.setupvalue, fn, 3, v)
end

local function getRod()
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    if char then
        local t = char:FindFirstChild("FishingRod")
        if t and t:IsA("Tool") then return t, true end
    end
    if bp then
        local t = bp:FindFirstChild("FishingRod")
        if t and t:IsA("Tool") then return t, false end
    end
    return nil, false
end

local function fishingPoint()
    resolveControllers()
    if S.FU and S.FU.getFishingPoint then
        local ok, fp = pcall(S.FU.getFishingPoint)
        if ok and fp then return fp end
    end
    local ok, fp = pcall(function()
        return workspace.Environment.PointOfInterest.FishingPoint
    end)
    if ok then return fp end
    return nil
end

local function distToWater()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local fp = fishingPoint()
    if hrp and fp then return (hrp.Position - fp.Position).Magnitude end
    return nil
end

-- Zielt die Maus auf den naechsten Wasserpunkt (mit Offset-Korrektur)
-- und verifiziert den Wurf per Raycast exakt so wie das Spiel
-- (erst HRP->Maus, dann Kamera-Ray). Gibt zurueck: ok, distanz.
local function aimAtWater()
    local fp = fishingPoint()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if not fp or not hrp or not cam then return false, nil end
    local ok, tw, dist = pcall(function()
        local half = fp.Size * 0.5
        local rel = fp.CFrame:PointToObjectSpace(hrp.Position)
        local m = 2
        local cx = math.clamp(rel.X, -half.X + m, half.X - m)
        local cz = math.clamp(rel.Z, -half.Z + m, half.Z - m)
        local p = fp.CFrame:PointToWorldSpace(Vector3.new(cx, half.Y + 0.5, cz))
        return p, (p - hrp.Position).Magnitude
    end)
    if not ok or not tw then return false, nil end
    if dist > 70 then return false, dist end
    local VIM = nil
    pcall(function() VIM = game:GetService("VirtualInputManager") end)
    if not VIM then return false, dist end
    local mouse = player:GetMouse()
    for pass = 1, 3 do
        local okS, sx, sy, on = pcall(function()
            local sp, onScr = cam:WorldToScreenPoint(tw)
            if not onScr then
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, tw)
                sp, onScr = cam:WorldToScreenPoint(tw)
            end
            return sp.X, sp.Y, onScr
        end)
        if not okS or not on then return false, dist end
        if pass >= 2 then
            sx, sy = sx - (S._aimDX or 0), sy - (S._aimDY or 0)
        end
        local vs = cam.ViewportSize
        sx = math.clamp(sx, 0, vs.X - 1)
        sy = math.clamp(sy, 0, vs.Y - 1)
        pcall(function() VIM:SendMouseMoveEvent(sx, sy, game) end)
        task.wait(0.15)
        if pass == 1 then
            S._aimDX, S._aimDY = mouse.X - sx, mouse.Y - sy
        end
        local verified = false
        pcall(function()
            local origin = hrp.Position
            local dir = mouse.Hit.Position - origin
            if dir.Magnitude > 0.0001 then
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Include
                rp.FilterDescendantsInstances = { fp }
                if workspace:Raycast(origin, dir.Unit * 75, rp) then
                    verified = true
                else
                    local ur = cam:ScreenPointToRay(mouse.X, mouse.Y)
                    if workspace:Raycast(ur.Origin, ur.Direction * 75, rp) then
                        verified = true
                    end
                end
            end
        end)
        if verified then return true, dist end
    end
    return false, dist
end

--================ GUI ================
local guiParent = nil
pcall(function()
    if typeof(gethui) == "function" then guiParent = gethui() end
end)
if not guiParent then guiParent = player:WaitForChild("PlayerGui") end

local gui = Instance.new("ScreenGui")
gui.Name = "BreadFishV2"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 500
gui.Parent = guiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 240, 0, 172)
Main.Position = UDim2.new(0, 20, 0.35, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = gui
local mainCorner = Instance.new("UICorner"); mainCorner.CornerRadius = UDim.new(0, 8); mainCorner.Parent = Main
local mainStroke = Instance.new("UIStroke"); mainStroke.Color = Color3.fromRGB(0, 200, 255); mainStroke.Thickness = 1.2; mainStroke.Transparency = 0.3; mainStroke.Parent = Main

local Title = Instance.new("Frame")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 34)
Title.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
Title.BorderSizePixel = 0
Title.Active = true
Title.Parent = Main
local tCorner = Instance.new("UICorner"); tCorner.CornerRadius = UDim.new(0, 8); tCorner.Parent = Title

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -44, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "🎣 GV AutoFish"
TitleLabel.Parent = Title

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 24)
MinBtn.Position = UDim2.new(1, -36, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Text = "–"
MinBtn.AutoButtonColor = true
MinBtn.Parent = Title
local mCorner = Instance.new("UICorner"); mCorner.CornerRadius = UDim.new(0, 6); mCorner.Parent = MinBtn

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Position = UDim2.new(0, 0, 0, 34)
Body.Size = UDim2.new(1, 0, 1, -34)
Body.BackgroundTransparency = 1
Body.Parent = Main

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 42)
ToggleBtn.Position = UDim2.new(0, 10, 0, 6)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "AUTO FISHING: AUS"
ToggleBtn.AutoButtonColor = true
ToggleBtn.Parent = Body
local tgCorner = Instance.new("UICorner"); tgCorner.CornerRadius = UDim.new(0, 7); tgCorner.Parent = ToggleBtn
local tgStroke = Instance.new("UIStroke"); tgStroke.Color = Color3.fromRGB(255, 255, 255); tgStroke.Thickness = 1; tgStroke.Transparency = 0.8; tgStroke.Parent = ToggleBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 56)
StatusLabel.Position = UDim2.new(0, 10, 0, 52)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
StatusLabel.Text = "Bereit."
StatusLabel.Parent = Body

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -20, 0, 20)
StatsLabel.Position = UDim2.new(0, 10, 1, -24)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextSize = 12
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextColor3 = Color3.fromRGB(120, 220, 140)
StatsLabel.Text = "Fänge: 0 • +$0"
StatsLabel.Parent = Body

local FULL_H, MINI_H = 172, 34
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Body.Visible = not minimized
    Main.Size = UDim2.new(0, 240, 0, minimized and MINI_H or FULL_H)
    MinBtn.Text = minimized and "+" or "–"
end)

do -- Dragging (nur über Titelleiste)
    local dragging = false
    local dragStart, startPos, dragInput = nil, nil, nil
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.LeftAlt and alive() then
        gui.Enabled = not gui.Enabled
    end
end)

local _toggleCallbacks = {}
local function fireToggleCallbacks(on)
    for _, cb in ipairs(_toggleCallbacks) do
        pcall(cb, on)
    end
end

local function refreshToggle()
    local acc = (_deps.C and _deps.C.accent) or Color3.fromRGB(0, 200, 255)
    if S.enabled then
        ToggleBtn.Text = "AUTO FISHING: AN"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 150, 70)
        mainStroke.Color = acc
        mainStroke.Transparency = 0.1
    else
        ToggleBtn.Text = "AUTO FISHING: AUS"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
        mainStroke.Color = Color3.fromRGB(60, 60, 75)
        mainStroke.Transparency = 0.4
    end
end

local function setEnabled(on, suppressNotify)
    local stateOn = on and true or false
    if S.enabled == stateOn then return end
    S.enabled = stateOn
    refreshToggle()
    if S.enabled then
        S.prevFC = nil; S.fishVel = 0; S.hold = false
        S.lastHoldT = os.clock(); S.blipUntil = 0
        S.lastEnd = 0; S.pendingSince = 0
        S.status = "Gestartet."
    else
        if S.fishFn then pcall(debug.setupvalue, S.fishFn, 3, false) end
        S.hold = false
        S.status = "Ausgeschaltet."
    end
    if not suppressNotify then
        fireToggleCallbacks(S.enabled)
    end
end
ToggleBtn.MouseButton1Click:Connect(function() setEnabled(not S.enabled) end)

--================ CONTROL (RenderStepped, 60 Hz, normierte States) ================
local controlConn = nil
controlConn = RunService.RenderStepped:Connect(function(dtRaw)
    if not alive() then return end
    if S.FC == nil then resolveControllers() return end
    local dt = math.clamp(dtRaw or 0.016, 0, 0.1)
    local now = os.clock()
    local active = S.FC.IsActive == true

    if not S.enabled or not active then
        if S.hold and S.fishFn then pcall(debug.setupvalue, S.fishFn, 3, false) end
        S.hold = false; S.prevFC = nil; S.fishVel = 0
        if not active then S.fishFn = nil end
        return
    end

    local fn = S.fishFn
    if fn == nil or (now - S.lastFind) > 0.5 and getUps(fn) == nil then
        fn = findFishFn()
        S.fishFn = fn
        S.lastFind = now
        S.prevFC = nil; S.fishVel = 0; S.lastHoldT = now
    end
    if fn == nil then return end
    local ups = getUps(fn)
    if not ups then S.fishFn = nil; return end

    local sess = ups[1]
    local rc, fc, rv = sess.RegionCenterY, sess.FishCenterY, sess.RegionVelocityY
    local rh = sess.RegionHeightScale or 0.31
    local fh = sess.FishHeightScale or 0.08
    if type(rc) ~= "number" or type(fc) ~= "number" then return end
    rv = type(rv) == "number" and rv or 0

    if S.prevFC == nil then S.prevFC = fc; S.fishVel = 0 end
    if dt > 0 then
        local rawV = (fc - S.prevFC) / dt
        if rawV > -3 and rawV < 3 then
            S.fishVel = S.fishVel + (rawV - S.fishVel) * EMA_A
        end
    end
    S.prevFC = fc

    local predFC = math.clamp(fc + S.fishVel * PREDICT, 0.02, 0.98)
    local err = predFC - rc
    local margin = (rh + fh) / 2
    local dead = math.max(margin * DEAD_FRAC, DEAD_MIN)

    local hold
    if err < -dead then
        hold = true
    elseif err > dead then
        hold = false
    else
        if rv > VEL_BRAKE then hold = true
        elseif rv < -VEL_BRAKE then hold = false
        else hold = S.hold end
    end

    if not hold and (now - S.lastHoldT) > ANTI_IDLE then
        hold = true
        S.blipUntil = now + BLIP
    end
    if now < S.blipUntil then hold = true end
    if hold then S.lastHoldT = now end

    if hold ~= S.hold then
        writeHold(fn, hold)
        S.hold = hold
    end
    S.lastProg = S.FC.Progress or 0
end)

--================ EQUIP + CAST + STATS ================
task.spawn(function()
    while alive() do
        if S.enabled then
            local rod, equipped = getRod()
            if rod and not equipped then
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:EquipTool(rod) end) end
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while alive() do
        if S.enabled then
            resolveControllers()
            if S.FC then
                local now = os.clock()
                local rod = getRod()
                if rod == nil then
                    S.status = "Keine Angel gefunden!"
                elseif S.FC.IsActive then
                    S.status = string.format("Fische... %.0f%%", math.clamp(S.FC.Progress or 0, 0, 1) * 100)
                elseif S.FC:IsFishing() then
                    if S.pendingSince > 0 and (now - S.pendingSince) > 12 then
                        pcall(function() S.FC:StopFishing(false) end)
                        S.pendingSince = 0
                        S.lastEnd = now; S.lastWasCatch = false
                    else
                        S.status = "Auswerfen..."
                    end
                else
                    local wait = S.lastWasCatch and 8.5 or 1.5
                    local rest = (S.lastEnd > 0) and (wait - (now - S.lastEnd)) or 0
                    if rest > 0 then
                        S.status = string.format("Cooldown %.0fs...", rest)
                    elseif (now - S.lastActivate) < 2 then
                        S.status = "Warte auf Anbiss..."
                    else
                        local _, equipped = getRod()
                        if not equipped then
                            S.status = "Rüste Angel aus..."
                        else
                            S.status = "Ziele..."
                            local okAim, dAim = aimAtWater()
                            if okAim then
                                pcall(function() rod:Activate() end)
                                S.lastActivate = now
                                S.pendingSince = now
                                S.status = "Ausgeworfen..."
                            else
                                S.lastActivate = now
                                if dAim then
                                    S.status = string.format("Geh zum Teich! (%.0fm)", dAim)
                                else
                                    S.status = "Kein Wasser in Reichweite!"
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while alive() do
        resolveControllers()
        if S.FC then
            local okF, fg = pcall(function()
                return player.PlayerGui.Fishing.Container.RewardLabel
            end)
            if okF and fg then
                local txt = tostring(fg.Text or "")
                if txt ~= S.lastRewardText then
                    S.lastRewardText = txt
                    local amt = txt:match("%$(%d+)")
                    if amt then
                        S.lastRewardT = os.clock()
                        S.lastRewardAmt = tonumber(amt) or 0
                    end
                end
            end
            local active = S.FC.IsActive == true
            if active then
                S.lastProg = S.FC.Progress or 0
            elseif S.prevActive and not active then
                local rewardFresh = (os.clock() - S.lastRewardT) < 2.5
                if rewardFresh or S.lastProg > 0.9 then
                    S.catches = S.catches + 1
                    S.earned = S.earned + (rewardFresh and S.lastRewardAmt or 0)
                    S.lastWasCatch = true
                else
                    S.lastWasCatch = false
                end
                S.lastEnd = os.clock()
                S.lastProg = 0
                pcall(function()
                    StatsLabel.Text = string.format("Fänge: %d • +$%d", S.catches, S.earned)
                end)
            end
            S.prevActive = active
            pcall(function() StatusLabel.Text = S.enabled and S.status or "AUS (AN zum Starten)" end)
        end
        task.wait(0.2)
    end
end)

refreshToggle()

--================ Module API ================
function M.init(deps)
    _deps = deps or {}
    if _deps.C and _deps.C.accent then
        pcall(function()
            mainStroke.Color = _deps.C.accent
        end)
    end
end

function M.start()
    setEnabled(true)
    gui.Enabled = true
end

function M.stop()
    setEnabled(false)
end

function M.toggle()
    setEnabled(not S.enabled)
end

function M.set(on, suppress)
    setEnabled(on, suppress)
end

function M.isActive()
    return S.enabled
end

function M.toggleGui(visible)
    if visible ~= nil then
        gui.Enabled = visible
    else
        gui.Enabled = not gui.Enabled
    end
end

function M.onToggleChanged(fn)
    if type(fn) == "function" then
        table.insert(_toggleCallbacks, fn)
    end
end

function M.shutdown()
    _G.__BreadFishV2Token = ((_G.__BreadFishV2Token or 0) + 1)
    pcall(function() if controlConn then controlConn:Disconnect() end end)
    pcall(function() gui:Destroy() end)
    _G.__BreadFishV2 = nil
end

_G.__BreadFishV2 = {
    set = setEnabled,
    start = M.start,
    stop = M.stop,
    aim = aimAtWater,
    state = S,
    shutdown = M.shutdown,
    module = M,
}

return M
