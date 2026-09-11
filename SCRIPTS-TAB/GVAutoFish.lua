--!nocheck
--============================================================
-- TLMenu Module: GVAutoFish (German Voice Auto Fishing)
-- Direct-State Controller: schreibt IsReeling direkt in den
-- FishingController (kein VirtualInput, keine Maus-Klicks).
-- HUD-less / Headless: Reine Hintergrundlogik gesteuert über TLMenu.
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
    status = "Bereit.",
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

local function setEnabled(on)
    local stateOn = on and true or false
    if S.enabled == stateOn then return end
    S.enabled = stateOn
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
end

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
                    local gained = (rewardFresh and S.lastRewardAmt or 0)
                    S.earned = S.earned + gained
                    S.lastWasCatch = true
                    if _deps.sendNotif and gained > 0 then
                        pcall(_deps.sendNotif, "AutoFish", string.format("Fisch gefangen! +$%d (Gesamt: %d)", gained, S.catches), 2)
                    end
                else
                    S.lastWasCatch = false
                end
                S.lastEnd = os.clock()
                S.lastProg = 0
            end
            S.prevActive = active
        end
        task.wait(0.2)
    end
end)

--================ Module API ================
function M.init(deps)
    _deps = deps or {}
end

function M.start()
    setEnabled(true)
end

function M.stop()
    setEnabled(false)
end

function M.toggle()
    setEnabled(not S.enabled)
end

function M.set(on)
    setEnabled(on)
end

function M.isActive()
    return S.enabled
end

function M.getStatus()
    return S.status, S.catches, S.earned
end

function M.shutdown()
    _G.__BreadFishV2Token = ((_G.__BreadFishV2Token or 0) + 1)
    pcall(function() if controlConn then controlConn:Disconnect() end end)
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
