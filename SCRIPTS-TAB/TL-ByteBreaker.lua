-- ════════════════════════════════════════════════════════════════════════════
--  TLEX ByteBreaker V3.2 — Kinematic-Sync + Jump/Fly/Rotation Fix
-- ════════════════════════════════════════════════════════════════════════════

local M = {}

local CFG = {
    VOID_Y                   = -200,
    RESCUE_Y                 = 50,
    DETACH_DISTANCE          = 28,
    HEALTH_CHECK_INTERVAL    = 0.08,
    CACHE_REFRESH_INTERVAL   = 0.25,
    VELOCITY_THRESHOLD       = 0.5,
    ANIMATION_RETRY_DELAY    = 0.1,
    RESPAWN_WAIT             = 0.5,
    MATCH_TARGET_VELOCITY    = false,
    VELOCITY_MATCH_FACTOR    = 0.8,

    ARB_ENABLED              = true,
    ARB_MAX_CORRECTION       = 8,
    ARB_HISTORY_SIZE         = 8,
    ARB_VELOCITY_DAMP        = 0.12,
    ARB_FREEZE_DURATION      = 0.2,
    ARB_MAX_FREEZES          = 4,
    ARB_RESET_COOLDOWN       = 1.5,
    ARB_STOP_VEL_THRESHOLD   = 0.8,
    ARB_STOP_FRAMES          = 3,

    PID_KP                   = 28.0,
    PID_KI                   = 0.0,
    PID_KD                   = 4.5,
    PID_MAX_FORCE            = 1e5,
    PID_POSITION_DEADZONE    = 0.008,

    LOOKAHEAD_FRAMES         = 2,
    LOOKAHEAD_MAX_OFFSET     = 3.0,

    ANIM_SPEED_IDLE          = 1.0,
    ANIM_SPEED_MAX           = 2.2,
    ANIM_SPEED_VEL_SCALE     = 0.12,
    ANIM_SPEED_SMOOTH        = 0.08,

    COLLISION_GROUP_NAME     = "BBAttach_V3",
    PHYSREP_EVERY_N_FRAMES   = 1,

    -- Kinematic Sync (neue Methode)
    KS_DEADZONE              = 0.006,
    KS_SNAP_DIST             = 6,
    KS_STOP_VEL_XZ           = 0.8,
    KS_STOP_VEL_Y            = 1.2,
    KS_STOP_FRAMES           = 3,
    KS_ROT_STOP_THRESHOLD    = 0.3,
    KS_ROT_STOP_FRAMES       = 3,
    KS_FLY_VEL_Y_MIN         = 4,
    KS_FLY_FRAMES_REQ        = 8,
    KS_FLY_SPEED_THRESHOLD   = 20,
    KS_JUMP_VEL_Y            = 8,
    KS_JUMP_Y_DELTA          = 0.5,
    KS_JUMP_COOLDOWN         = 0.3,
    KS_LV_RESIDUAL           = 8,

    HARD_ATTACH_MODES        = {
        bb_carry         = true,
        bb_carryshoulder = true,
        bb_carry2        = true,
        bb_piggyback     = true,
        bb_piggyback2    = true,
        bb_backpack      = true,
        bb_headsit       = true,
        bb_shouldersit   = true,
    },
}

local ANIM_IDS = {
    bb_carry         = "95469914338674",
    bb_carryshoulder = "101003999980390",
    bb_carry2        = "73126126731268",
    bb_hug           = "93667149408515",
    bb_backshots     = "101003999980390",
    bb_licking       = "86345507952689",
    bb_hug2          = "101809619267911",
    bb_layfuck       = "95678189010798",
    bb_backpack      = "73500261613116",
    bb_stomach       = "105895909040298",
    bb_kiss          = "102367337136163",
    bb_sucking       = "74402438715168",
    bb_suck_it       = "79294534752809",
    bb_doggy         = "101856096472698",
    bb_pussyspread   = "120754278085861",
    bb_soh           = "119898270336796",
    bb_shouldersit   = "119898270336796",
    bb_friend        = "182435933",
    bb_bangv2        = "107300675038850",
    bb_cuffing       = "137809930492090",
    bb_attach        = "101003999980390",
    bb_piggyback     = "108744973494490",
    bb_piggyback2    = "92706401579816",
    bb_stand         = "133594786690861",
}

local ATTACH_MODES = {
    bb_attach        = { x = 0,    y = -0.85, z = -2.0,  rotX = 20,  rotY = 0,   rotZ = 0,  osc = 1.5, oscSpeed = 10 },
    bb_orbit         = { distance = 8, speed = 1.5, type = "orbit" },
    bb_frontwalk     = { distance = 5, facing = "front",  type = "follow" },
    bb_behind        = { distance = 5, facing = "back",   type = "follow" },
    bb_cuffing       = { distance = 1.5, facing = "back", type = "follow" },
    bb_headsit       = { x = 0,    y = 1.4,   z = 0,     rotX = 90,  headRelative = true },
    bb_copy          = { x = 4,    y = 0,     z = 0 },
    bb_piggyback     = { x = 0,    y = 0.2,   z = 1.1 },
    bb_backpack      = { x = 0,    y = 2.5,   z = 1.2 },
    bb_piggyback2    = { x = 0,    y = 0.2,   z = 1.1 },
    bb_carry         = { x = 0.5,  y = -0.5,  z = -1.2 },
    bb_carryshoulder = { x = 1.8,  y = 0.2,   z = 0.9 },
    bb_carry2        = { x = 0.5,  y = 1.0,   z = -1.2 },
    bb_hug           = { x = 0,    y = 0.05,  z = -1.35, rotY = 180, osc = 0.04, oscSpeed = 10 },
    bb_hug2          = { x = 0,    y = 0,     z = 1.1 },
    bb_stand         = { x = -0.8, y = 2,     z = 2.2 },
    bb_layfuck       = { x = 0,    y = 0.1,   z = 0.9,   osc = 0.9,  oscSpeed = 12 },
    bb_headstand     = { x = 0.2,  y = 4,     z = 0.2 },
    bb_licking       = { x = 0,    y = -1.7,  z = -2.5,  rotY = 180, osc = 0.4,  oscSpeed = 15 },
    bb_bangv2        = { x = 0,    y = 0.2,   z = 3.5,   osc = 3,    oscSpeed = 10, useOscTimer = true },
    bb_stomach       = { x = 0,    y = 0,     z = 3.0,   rotY = 180 },
    bb_kiss          = { x = 0,    y = 1.5,   z = -1.2,  rotY = 180, osc = 0.08, oscSpeed = 10 },
    bb_sucking       = { x = 0,    y = -0.4,  z = -3.1,  rotY = 180, osc = 0.5,  oscSpeed = 20 },
    bb_suck_it       = { x = 0,    y = -1.2,  z = -2.0,  rotY = 180, osc = 1.0,  oscSpeed = 12 },
    bb_backshots     = { x = 0,    y = -3.2,  z = -2.0,  rotX = 20,  osc = 1.5,  oscSpeed = 10 },
    bb_doggy         = { x = 0,    y = -4.7,  z = -0.8,  rotX = -90 },
    bb_pussyspread   = { x = 0,    y = -2.45, z = -2.0,  osc = 1.5,  oscSpeed = 10 },
    bb_soh           = { y = 1,    headRelative = true },
    bb_shouldersit   = { x = 1.8,  y = 2.2,   z = 0 },
    bb_friend        = { x = 3,    y = 0,     z = 0 },
}

-- ════════════════════════════════════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════════════════════════════════════

local State = {
    active              = false,
    mode                = nil,
    target              = nil,

    myChar              = nil,
    myHRP               = nil,
    myHum               = nil,
    targetChar          = nil,
    targetHRP           = nil,
    targetHead          = nil,
    targetTorso         = nil,

    healthCheckAcc      = 0,
    cacheCheckAcc       = 0,
    oscTime             = 0,
    lastSafeY           = 0,
    lastDetachFix       = 0,

    physAttachment      = nil,
    linearVelocity      = nil,
    alignOrientation    = nil,
    bodyVelocity        = nil,

    connections         = {},
    animTracks          = {},

    rakHooked           = false,
    rakHookFn           = nil,
    lastError           = nil,
    ownershipSet        = false,
    collisionGroupSetup = false,

    pid = {
        integral  = Vector3.zero,
        lastError = Vector3.zero,
        lastTime  = 0,
    },

    animSpeed = {
        current = 1.0,
    },

    arb = {
        positionHistory   = {},
        lastConfirmedCF   = nil,
        frozenUntil       = 0,
        freezeCount       = 0,
        lastResetAt       = 0,
        lastServerPushVel = Vector3.zero,
        stopFrames        = 0,
    },

    -- Kinematic Sync per-mode state
    ks = {
        stopFramesXZ  = 0,
        stopFramesY   = 0,
        rotStopFrames = 0,
        flyFrames     = 0,
        initialized   = false,
        lastTargetY   = 0,
        jumpCooldown  = 0,
    },
}

-- ════════════════════════════════════════════════════════════════════════════
--  DEPENDENCIES
-- ════════════════════════════════════════════════════════════════════════════

local Deps = {
    LocalPlayer                = nil,
    RunService                 = nil,
    Players                    = nil,
    PhysicsService             = nil,
    sethiddenproperty          = nil,
    raknet                     = nil,
    sendNotif                  = nil,
    safeStand                  = nil,
    _AF                        = {},
    _AF_getReliableActionTrack = nil,
}

-- ════════════════════════════════════════════════════════════════════════════
--  UTILITIES
-- ════════════════════════════════════════════════════════════════════════════

local function logError(ctx, err)
    State.lastError = { ctx = ctx, err = tostring(err), time = tick() }
    warn("[BB] " .. ctx .. ": " .. tostring(err))
end

local function safe(fn, ctx)
    local ok, err = pcall(fn)
    if not ok then logError(ctx or "safe", err) end
    return ok
end

local function getHumanoid(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function clearTable(t)
    for k in pairs(t) do t[k] = nil end
end

local function clearVelocity(hrp)
    if not hrp then return end
    safe(function()
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end, "clearVelocity")
end

local function resetKS()
    State.ks.stopFramesXZ  = 0
    State.ks.stopFramesY   = 0
    State.ks.rotStopFrames = 0
    State.ks.flyFrames     = 0
    State.ks.initialized   = false
    State.ks.lastTargetY   = 0
    State.ks.jumpCooldown  = 0
end

-- ════════════════════════════════════════════════════════════════════════════
--  PHYSICS STACK
-- ════════════════════════════════════════════════════════════════════════════

local function buildPhysicsStack(hrp)
    if State.physAttachment then
        pcall(function() State.physAttachment:Destroy() end)
    end
    if State.bodyVelocity then
        pcall(function() State.bodyVelocity:Destroy() end)
    end

    local att = Instance.new("Attachment")
    att.Name   = "BBKinematicRoot"
    att.Parent = hrp
    State.physAttachment = att

    -- BodyVelocity: full-axis gravity cancel
    local bv = Instance.new("BodyVelocity")
    bv.Name      = "BBBodyVel"
    bv.MaxForce  = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity  = Vector3.zero
    bv.P         = 1e4
    bv.Parent    = hrp
    State.bodyVelocity = bv

    -- LinearVelocity: residual correction
    local lv = Instance.new("LinearVelocity")
    lv.Name                   = "BBLinearVel"
    lv.Attachment0            = att
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.MaxForce               = 1e6
    lv.RelativeTo             = Enum.ActuatorRelativeTo.World
    lv.VectorVelocity         = Vector3.zero
    lv.Parent                 = hrp
    State.linearVelocity      = lv

    -- AlignOrientation: sole rotation owner, non-rigid for smooth rotation
    local ao = Instance.new("AlignOrientation")
    ao.Name               = "BBAlignOri"
    ao.Attachment0        = att
    ao.Mode               = Enum.OrientationAlignmentMode.OneAttachment
    ao.MaxTorque          = 1e6
    ao.MaxAngularVelocity = 1000
    ao.Responsiveness     = 500
    ao.RigidityEnabled    = false
    ao.Parent             = hrp
    State.alignOrientation = ao
end

local function destroyPhysicsStack()
    for _, key in ipairs({ "physAttachment", "linearVelocity", "alignOrientation", "bodyVelocity" }) do
        if State[key] then
            pcall(function() State[key]:Destroy() end)
            State[key] = nil
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════
--  PID CONTROLLER
-- ════════════════════════════════════════════════════════════════════════════

local PID = {}

function PID.reset()
    State.pid.integral  = Vector3.zero
    State.pid.lastError = Vector3.zero
    State.pid.lastTime  = tick()
end

function PID.compute(current, desired, dt)
    if dt <= 0 then return Vector3.zero end
    local err = desired - current
    if err.Magnitude < CFG.PID_POSITION_DEADZONE then
        State.pid.integral  = Vector3.zero
        State.pid.lastError = Vector3.zero
        return Vector3.zero
    end
    local p = err * CFG.PID_KP
    State.pid.integral = State.pid.integral + err * dt
    if State.pid.integral.Magnitude > 10 then
        State.pid.integral = State.pid.integral.Unit * 10
    end
    local i = State.pid.integral * CFG.PID_KI
    local d = ((err - State.pid.lastError) / dt) * CFG.PID_KD
    State.pid.lastError = err
    local output = p + i + d
    if output.Magnitude > CFG.PID_MAX_FORCE then
        output = output.Unit * CFG.PID_MAX_FORCE
    end
    return output
end

-- ════════════════════════════════════════════════════════════════════════════
--  LOOK-AHEAD PROJECTION
-- ════════════════════════════════════════════════════════════════════════════

local function getLookAheadCF(baseCF, dt)
    local tHRP = State.targetHRP
    if not tHRP then return baseCF end
    local vel   = tHRP.AssemblyLinearVelocity
    local speed = vel.Magnitude
    if speed < CFG.ARB_STOP_VEL_THRESHOLD then return baseCF end
    local offset = vel * (dt * CFG.LOOKAHEAD_FRAMES)
    if offset.Magnitude > CFG.LOOKAHEAD_MAX_OFFSET then
        offset = offset.Unit * CFG.LOOKAHEAD_MAX_OFFSET
    end
    return baseCF + offset
end

-- ════════════════════════════════════════════════════════════════════════════
--  COLLISION GROUP
-- ════════════════════════════════════════════════════════════════════════════

local function buildCollisionGroup()
    if State.collisionGroupSetup or not Deps.PhysicsService then return end
    safe(function()
        local PS  = Deps.PhysicsService
        local grp = CFG.COLLISION_GROUP_NAME
        local exists = pcall(function() PS:GetCollisionGroupId(grp) end)
        if not exists then
            PS:CreateCollisionGroup(grp)
            PS:CollisionGroupSetCollidable(grp, grp, false)
            PS:CollisionGroupSetCollidable(grp, "Default", false)
        end
        if State.myChar then
            for _, p in ipairs(State.myChar:GetDescendants()) do
                if p:IsA("BasePart") then PS:SetPartCollisionGroup(p, grp) end
            end
        end
        State.collisionGroupSetup = true
    end, "buildCollisionGroup")
end

local function destroyCollisionGroup()
    if not State.collisionGroupSetup or not Deps.PhysicsService then return end
    safe(function()
        if State.myChar then
            for _, p in ipairs(State.myChar:GetDescendants()) do
                if p:IsA("BasePart") then
                    Deps.PhysicsService:SetPartCollisionGroup(p, "Default")
                end
            end
        end
        State.collisionGroupSetup = false
    end, "destroyCollisionGroup")
end

-- ════════════════════════════════════════════════════════════════════════════
--  ADAPTIVE ANIMATION SPEED
-- ════════════════════════════════════════════════════════════════════════════

local function updateAnimationSpeed()
    local tHRP = State.targetHRP
    if not tHRP then return end
    local speed  = tHRP.AssemblyLinearVelocity.Magnitude
    local target = math.clamp(
        CFG.ANIM_SPEED_IDLE + speed * CFG.ANIM_SPEED_VEL_SCALE,
        CFG.ANIM_SPEED_IDLE,
        CFG.ANIM_SPEED_MAX
    )
    local current = State.animSpeed.current
    local new     = current + (target - current) * CFG.ANIM_SPEED_SMOOTH
    if math.abs(new - current) < 0.01 then return end
    State.animSpeed.current = new
    for _, slot in pairs(State.animTracks) do
        if slot.track and slot.track.IsPlaying then
            safe(function() slot.track:AdjustSpeed(new) end, "updateAnimSpeed")
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════
--  ARB SYSTEM
-- ════════════════════════════════════════════════════════════════════════════

local ARB = {}

function ARB.recordPosition(cf)
    local h = State.arb.positionHistory
    table.insert(h, 1, cf)
    if #h > CFG.ARB_HISTORY_SIZE then table.remove(h, #h) end
    State.arb.lastConfirmedCF = cf
end

function ARB.detectRubberBand(myHRP, desiredCF)
    if not myHRP or not desiredCF then return false end
    return (myHRP.CFrame.Position - desiredCF.Position).Magnitude > CFG.ARB_MAX_CORRECTION
end

function ARB.detectVelocitySpike(myHRP)
    if not myHRP then return false end
    local vel   = myHRP.AssemblyLinearVelocity
    local spike = (vel - State.arb.lastServerPushVel).Magnitude
    State.arb.lastServerPushVel = vel
    return spike > 18
end

function ARB.dampVelocity(myHRP)
    if not myHRP then return end
    safe(function()
        myHRP.AssemblyLinearVelocity  = myHRP.AssemblyLinearVelocity * CFG.ARB_VELOCITY_DAMP
        myHRP.AssemblyAngularVelocity = Vector3.zero
    end, "ARB.dampVelocity")
end

function ARB.freeze(myHRP, desiredCF)
    local now = tick()
    if now < State.arb.frozenUntil then return end
    State.arb.freezeCount = State.arb.freezeCount + 1
    State.arb.frozenUntil = now + CFG.ARB_FREEZE_DURATION
    safe(function()
        myHRP.CFrame                  = desiredCF
        myHRP.AssemblyLinearVelocity  = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero
    end, "ARB.freeze")
end

function ARB.forceReset(myHRP)
    local now = tick()
    if now - State.arb.lastResetAt < CFG.ARB_RESET_COOLDOWN then return end
    State.arb.lastResetAt = now
    State.arb.freezeCount = 0
    State.arb.frozenUntil = 0
    local cf = State.arb.lastConfirmedCF
        or (State.targetHRP and State.targetHRP.CFrame * CFrame.new(0, 2, 2))
    if cf and myHRP then
        safe(function()
            myHRP.CFrame                  = cf
            myHRP.AssemblyLinearVelocity  = Vector3.zero
            myHRP.AssemblyAngularVelocity = Vector3.zero
        end, "ARB.forceReset")
    end
    warn("[BB-ARB] Force reset")
end

local function updateStopDetection()
    local tHRP = State.targetHRP
    if not tHRP then State.arb.stopFrames = 0; return false end
    if tHRP.AssemblyLinearVelocity.Magnitude < CFG.ARB_STOP_VEL_THRESHOLD then
        State.arb.stopFrames = (State.arb.stopFrames or 0) + 1
    else
        State.arb.stopFrames = 0
    end
    return State.arb.stopFrames >= CFG.ARB_STOP_FRAMES
end

-- ════════════════════════════════════════════════════════════════════════════
--  CACHE MANAGEMENT
-- ════════════════════════════════════════════════════════════════════════════

local function refreshMyCache()
    local char = Deps.LocalPlayer.Character
    if char ~= State.myChar then
        State.myChar  = char
        State.myHRP   = char and char:FindFirstChild("HumanoidRootPart")
        State.myHum   = getHumanoid(char)
        if State.myHRP then State.lastSafeY = State.myHRP.Position.Y end
        State.ownershipSet        = false
        State.collisionGroupSetup = false
        clearTable(State.arb.positionHistory)
        State.arb.lastConfirmedCF   = nil
        State.arb.frozenUntil       = 0
        State.arb.freezeCount       = 0
        State.arb.stopFrames        = 0
        State.arb.lastServerPushVel = Vector3.zero
        PID.reset()
        resetKS()
    end
end

local function refreshTargetCache()
    if not State.target then return end
    local char = State.target.Character
    if char ~= State.targetChar or not State.targetHRP or not State.targetHRP.Parent then
        State.targetChar  = char
        State.targetHRP   = char and char:FindFirstChild("HumanoidRootPart")
        State.targetHead  = char and char:FindFirstChild("Head")
        State.targetTorso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
        if State.myHRP and State.targetHRP then
            safe(function()
                Deps.sethiddenproperty(State.myHRP, "PhysicsRepRootPart", State.targetHRP)
            end, "refreshTargetCache:PhysicsRep")
        end
    end
end

local function ensureNetworkOwnership()
    if State.ownershipSet or not State.myHRP then return end
    local ok = safe(function()
        State.myHRP:SetNetworkOwner(Deps.LocalPlayer)
    end, "ensureNetworkOwnership")
    if ok then State.ownershipSet = true end
end

-- ════════════════════════════════════════════════════════════════════════════
--  OSCILLATOR
-- ════════════════════════════════════════════════════════════════════════════

local Oscillator = { timers = {} }

function Oscillator.reset(key) Oscillator.timers[key] = 0 end

function Oscillator.update(key, dt)
    Oscillator.timers[key] = (Oscillator.timers[key] or 0) + dt
    local t = Oscillator.timers[key]
    if t > 86400 then Oscillator.timers[key] = t % 6.28319 end
    return Oscillator.timers[key]
end

function Oscillator.get(key, amplitude, speed, dt)
    return math.sin(Oscillator.update(key, dt) * (speed or 10)) * (amplitude or 1)
end

-- ════════════════════════════════════════════════════════════════════════════
--  ANIMATION SYSTEM
-- ════════════════════════════════════════════════════════════════════════════

local function stopAllAnimations()
    for _, slot in pairs(State.animTracks) do
        safe(function()
            if slot.track then slot.track:AdjustSpeed(1); slot.track:Stop() end
            if slot.conn  then slot.conn:Disconnect() end
        end, "stopAllAnimations")
    end
    clearTable(State.animTracks)
end

local function loadAnimation(humanoid, animId, animName)
    local animator = humanoid:FindFirstChildOfClass("Animator")
        or Instance.new("Animator", humanoid)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId
    anim.Name        = animName or "BBAnim"
    local track      = animator:LoadAnimation(anim)
    track.Priority   = Enum.AnimationPriority.Action4
    task.delay(0.5, function() safe(function() anim:Destroy() end, "loadAnim:cleanup") end)
    return track
end

local function playAnimation(mode, opts)
    opts = opts or {}
    local animId = ANIM_IDS[mode]
    if not animId or not State.myHum then return end
    local animRunning = false
    local function playFn(char)
        if not char or not State.active or animRunning then return end
        animRunning = true
        local hum = getHumanoid(char)
        if not hum then animRunning = false; return end
        if opts.r6Only and hum.RigType ~= Enum.HumanoidRigType.R6 then
            animRunning = false; return
        end
        local track
        if type(Deps._AF_getReliableActionTrack) == "function" then
            track = Deps._AF_getReliableActionTrack(hum, animId, mode .. "Anim")
        else
            track = loadAnimation(hum, animId, mode .. "Anim")
        end
        if not track then animRunning = false; return end
        if opts.speed   then safe(function() track:AdjustSpeed(opts.speed) end, "playAnim:speed") end
        if opts.timePos then track:AdjustSpeed(0); track.TimePosition = opts.timePos end
        local slot = State.animTracks[mode] or {}
        if slot.conn then safe(function() slot.conn:Disconnect() end, "playAnim:oldConn") end
        slot.track = track
        slot.conn  = track.Stopped:Connect(function()
            animRunning = false
            if State.active and State.mode == mode then
                task.wait(CFG.ANIMATION_RETRY_DELAY)
                playFn(char)
            end
        end)
        State.animTracks[mode] = slot
        track:Play()
        animRunning = false
    end
    playFn(State.myChar)
end

-- ════════════════════════════════════════════════════════════════════════════
--  POSITION CALCULATION
-- ════════════════════════════════════════════════════════════════════════════

local function calculateTargetCFrame(mode, modeData, dt)
    local tHRP = State.targetHRP
    if not tHRP then return nil end

    if modeData.type == "orbit" then
        local angle = State.oscTime * (modeData.speed or 1.5)
        local dist  = modeData.distance or 8
        local pos   = Vector3.new(
            tHRP.Position.X + math.cos(angle) * dist,
            tHRP.Position.Y,
            tHRP.Position.Z + math.sin(angle) * dist
        )
        return CFrame.new(pos, tHRP.Position)
    end

    if modeData.type == "follow" then
        local look = tHRP.CFrame.LookVector
        local mult = modeData.facing == "front" and 1 or -1
        local pos  = tHRP.Position + look * ((modeData.distance or 5) * mult)
        return CFrame.new(pos, pos + look)
    end

    if modeData.headRelative then
        local head = State.targetHead
        local base = head and head.CFrame or (tHRP.CFrame * CFrame.new(0, 3, 0))
        local rx   = modeData.rotX and math.rad(modeData.rotX) or 0
        local _, ry, rz = tHRP.CFrame:ToEulerAnglesXYZ()
        if modeData.rotZ then rz = math.rad(modeData.rotZ) end
        return CFrame.new(
            base.Position + Vector3.new(modeData.x or 0, modeData.y or 0, modeData.z or 0)
        ) * CFrame.fromEulerAnglesXYZ(rx, ry, rz)
    end

    local x, y, z = modeData.x or 0, modeData.y or 0, modeData.z or 0

    -- Detect if target is in a floor emote (lying down, sitting, etc.)
    -- Check UpperTorso Y offset relative to HRP — large negative = lying on ground
    local groundCorrection = 0
    local targetChar = State.targetChar
    if targetChar and State.targetHRP then
        local upperTorso = targetChar:FindFirstChild("UpperTorso")
            or targetChar:FindFirstChild("Torso")
        if upperTorso then
            local hrpCF = State.targetHRP.CFrame
            local torsoCF = upperTorso.CFrame
            local localOffset = hrpCF:PointToObjectSpace(torsoCF.Position)
            -- Standing R15: localOffset.Y ~= +0.2
            -- Lying down:   localOffset.Y ~= -0.3 to -0.8
            if localOffset.Y < 0 then
                groundCorrection = localOffset.Y * 0.8
            end
        else
            -- R6: no UpperTorso, check if HRP is very close to ground (raycast)
            local rayOrigin = State.targetHRP.Position
            local rayDir = Vector3.new(0, -5, 0)
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {targetChar}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local rayResult = workspace:Raycast(rayOrigin, rayDir, rayParams)
            if rayResult and rayResult.Distance < 1.5 then
                -- HRP is very close to ground — likely a floor emote
                groundCorrection = -math.min(rayResult.Distance * 0.3, 0.8)
            end
        end
        -- Ragdoll state
        local hum = getHumanoid(targetChar)
        if hum then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Ragdoll then
                groundCorrection = groundCorrection - 0.4
            end
        end
    end

    -- Apply ground correction to y offset so attachment stays near ground
    y = y + groundCorrection

    if modeData.osc and modeData.oscSpeed then
        local key = mode .. "_osc"
        if modeData.useOscTimer then
            z = z - Oscillator.get(key, modeData.osc, modeData.oscSpeed, dt)
        else
            z = z - math.sin(State.oscTime * modeData.oscSpeed) * modeData.osc
        end
    end

    local rx = modeData.rotX and math.rad(modeData.rotX) or 0
    local ry = modeData.rotY and math.rad(modeData.rotY) or 0
    local rz = modeData.rotZ and math.rad(modeData.rotZ) or 0

    return tHRP.CFrame * CFrame.new(x, y, z) * CFrame.Angles(rx, ry, rz)
end

-- ════════════════════════════════════════════════════════════════════════════
--  KINEMATIC SYNC APPLIER (neue Methode, ersetzt applyPosition)
-- ════════════════════════════════════════════════════════════════════════════

local function applyPosition(myHRP, desiredCF, dt)
    local tHRP = State.targetHRP
    if not tHRP then return end

    local ks       = State.ks
    local tarPos   = desiredCF.Position
    local myPos    = myHRP.Position
    local errMag   = (tarPos - myPos).Magnitude
    local tarVel   = tHRP.AssemblyLinearVelocity
    local totalSpeed = tarVel.Magnitude

    local velXZ = Vector3.new(tarVel.X, 0, tarVel.Z).Magnitude
    local velY  = math.abs(tarVel.Y)

    -- Y delta tracking
    local yDelta = math.abs(tarPos.Y - ks.lastTargetY)
    ks.lastTargetY = tarPos.Y

    -- Jump detection
    if velY > CFG.KS_JUMP_VEL_Y or yDelta > CFG.KS_JUMP_Y_DELTA then
        ks.jumpCooldown = CFG.KS_JUMP_COOLDOWN
    end
    if ks.jumpCooldown > 0 then ks.jumpCooldown = ks.jumpCooldown - dt end
    local isJumping = ks.jumpCooldown > 0

    -- Fly detection (sustained)
    if velY > CFG.KS_FLY_VEL_Y_MIN or totalSpeed > CFG.KS_FLY_SPEED_THRESHOLD then
        ks.flyFrames = ks.flyFrames + 1
    else
        ks.flyFrames = math.max(0, ks.flyFrames - 2)
    end
    local isFlying = ks.flyFrames >= CFG.KS_FLY_FRAMES_REQ

    -- Stop XZ
    if velXZ < CFG.KS_STOP_VEL_XZ then
        ks.stopFramesXZ = ks.stopFramesXZ + 1
    else
        ks.stopFramesXZ = 0
    end

    -- Stop Y
    if velY < CFG.KS_STOP_VEL_Y and not isJumping and not isFlying then
        ks.stopFramesY = ks.stopFramesY + 1
    else
        ks.stopFramesY = 0
    end

    local isStoppedXZ = ks.stopFramesXZ >= CFG.KS_STOP_FRAMES
    local isStoppedY  = ks.stopFramesY >= CFG.KS_STOP_FRAMES and not isJumping and not isFlying
    local isFullStop  = isStoppedXZ and isStoppedY and not isFlying

    -- Rotation stop
    local rotSpeed = tHRP.AssemblyAngularVelocity.Magnitude
    if rotSpeed < CFG.KS_ROT_STOP_THRESHOLD then
        ks.rotStopFrames = ks.rotStopFrames + 1
    else
        ks.rotStopFrames = 0
    end
    local isRotStopped = ks.rotStopFrames >= CFG.KS_ROT_STOP_FRAMES

    -- ARB: rubber-band & spike check
    local now = tick()
    if now < State.arb.frozenUntil then
        safe(function()
            myHRP.CFrame                 = desiredCF
            myHRP.AssemblyLinearVelocity = Vector3.zero
        end, "applyPosition:frozen")
        return
    end

    if ARB.detectVelocitySpike(myHRP) then ARB.dampVelocity(myHRP) end

    if ARB.detectRubberBand(myHRP, desiredCF) then
        if State.arb.freezeCount >= CFG.ARB_MAX_FREEZES then
            ARB.forceReset(myHRP)
        else
            ARB.freeze(myHRP, desiredCF)
        end
        return
    end

    State.arb.freezeCount = 0

    -- Rotation: sole owner is AlignOrientation
    if State.alignOrientation then
        safe(function()
            State.alignOrientation.CFrame = desiredCF
        end, "applyPosition:alignOri")
    end

    -- Position: direct lock, no lerp (eliminates jitter)
    if not ks.initialized or errMag > CFG.KS_SNAP_DIST then
        safe(function()
            myHRP.CFrame = desiredCF
        end, "applyPosition:init")
        ks.initialized = true
    elseif isFullStop and isRotStopped then
        safe(function()
            myHRP.CFrame = CFrame.new(tarPos) * myHRP.CFrame.Rotation
        end, "applyPosition:fullStop")
    else
        -- Direct position lock for all movement states
        -- No lerp = no oscillation/jitter
        safe(function()
            myHRP.CFrame = CFrame.new(tarPos) * myHRP.CFrame.Rotation
        end, "applyPosition:directLock")
    end

    -- Velocity: always null after CFrame set
    safe(function()
        myHRP.AssemblyLinearVelocity  = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero
        if State.bodyVelocity then State.bodyVelocity.Velocity = Vector3.zero end
    end, "applyPosition:velNull")

    -- LV: minimal residual correction only
    local residual = tarPos - myHRP.Position
    if State.linearVelocity then
        if residual.Magnitude > CFG.KS_DEADZONE and not isFullStop then
            safe(function()
                State.linearVelocity.VectorVelocity = residual * CFG.KS_LV_RESIDUAL
            end, "applyPosition:lv")
        else
            safe(function()
                State.linearVelocity.VectorVelocity = Vector3.zero
            end, "applyPosition:lvZero")
        end
    end

    ARB.recordPosition(myHRP.CFrame)
end

-- ════════════════════════════════════════════════════════════════════════════
--  HEALTH & SAFETY
-- ════════════════════════════════════════════════════════════════════════════

local function setupHealthProtection()
    local hum = State.myHum
    if not hum then return end
    safe(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end, "setupHealthProtection")
    State.connections[#State.connections + 1] = hum.Died:Connect(function()
        if State.active then
            safe(function() hum.Health = hum.MaxHealth end, "healthProtection:died")
        end
    end)
end

local function checkVoidRescue()
    local hrp = State.myHRP
    if not hrp then return end
    if hrp.Position.Y > CFG.VOID_Y then State.lastSafeY = hrp.Position.Y; return end
    local tHRP     = State.targetHRP
    local rescueCF = tHRP and (tHRP.CFrame * CFrame.new(0, CFG.RESCUE_Y, 0))
        or CFrame.new(hrp.Position.X, math.max(State.lastSafeY, CFG.RESCUE_Y), hrp.Position.Z)
    safe(function()
        hrp.CFrame = rescueCF
        clearVelocity(hrp)
        if State.myHum then State.myHum.Health = State.myHum.MaxHealth end
    end, "checkVoidRescue")
end

local function checkDetachDistance()
    local myHRP = State.myHRP
    local tHRP  = State.targetHRP
    if not myHRP or not tHRP then return end
    if (myHRP.Position - tHRP.Position).Magnitude > CFG.DETACH_DISTANCE
        and tick() - State.lastDetachFix > 0.65 then
        State.lastDetachFix = tick()
        safe(function()
            clearVelocity(myHRP)
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 2.25, 2.25)
        end, "checkDetachDistance")
    end
end

-- ════════════════════════════════════════════════════════════════════════════
--  RAKNET HOOK
-- ════════════════════════════════════════════════════════════════════════════

local function setupRaknetHook()
    if not Deps.raknet or State.rakHooked then return end
    safe(function()
        State.rakHookFn = function(packet)
            if packet.PacketId == 0x1B then
                local buf = packet.AsBuffer
                buffer.writeu32(buf, 1, 0xFFFFFFFF)
                packet:SetData(buf)
            end
        end
        Deps.raknet.add_send_hook(State.rakHookFn)
        State.rakHooked = true
    end, "setupRaknetHook")
end

local function removeRaknetHook()
    if State.rakHooked and State.rakHookFn and Deps.raknet then
        safe(function() Deps.raknet.remove_send_hook(State.rakHookFn) end, "removeRaknetHook")
        State.rakHooked = false
        State.rakHookFn = nil
    end
end

-- ════════════════════════════════════════════════════════════════════════════
--  RESPAWN HANDLING
-- ════════════════════════════════════════════════════════════════════════════

local function bindRespawnHandlers()
    State.connections[#State.connections + 1] = Deps.LocalPlayer.CharacterAdded:Connect(function(char)
        if not State.active then return end
        task.wait(CFG.RESPAWN_WAIT)
        refreshMyCache()
        buildCollisionGroup()
        buildPhysicsStack(State.myHRP)
        setupHealthProtection()
        ensureNetworkOwnership()
        PID.reset()
        resetKS()
        if State.mode and State.target then playAnimation(State.mode, {}) end
    end)

    if not State.target then return end

    State.connections[#State.connections + 1] = State.target.CharacterAdded:Connect(function()
        if not State.active then return end
        task.wait(CFG.RESPAWN_WAIT)
        refreshTargetCache()
        resetKS()
    end)

    local targetChar = State.target.Character
    if targetChar then
        local targetHum = getHumanoid(targetChar)
        if targetHum then
            State.connections[#State.connections + 1] = targetHum.Died:Connect(function()
                if State.active then task.wait(0.3); refreshTargetCache() end
            end)
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════
--  MAIN HEARTBEAT
-- ════════════════════════════════════════════════════════════════════════════

local _physRepFrame = 0

local function onHeartbeat(dt)
    if not State.active then return end

    State.oscTime = State.oscTime + dt
    if State.oscTime > 86400 then State.oscTime = State.oscTime % 6.28319 end

    State.cacheCheckAcc = State.cacheCheckAcc + dt
    if State.cacheCheckAcc >= CFG.CACHE_REFRESH_INTERVAL then
        State.cacheCheckAcc = 0
        refreshMyCache()
        refreshTargetCache()
        checkDetachDistance()
        ensureNetworkOwnership()
    end

    State.healthCheckAcc = State.healthCheckAcc + dt
    if State.healthCheckAcc >= CFG.HEALTH_CHECK_INTERVAL then
        State.healthCheckAcc = 0
        checkVoidRescue()
        local hum = State.myHum
        if hum then
            safe(function()
                hum.PlatformStand = true
                if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
                if hum.SeatPart then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
            end, "onHeartbeat:health")
        end
    end

    local myHRP = State.myHRP
    local tHRP  = State.targetHRP
    if not myHRP or not tHRP or not tHRP.Parent then return end

    _physRepFrame = _physRepFrame + 1
    if _physRepFrame >= CFG.PHYSREP_EVERY_N_FRAMES then
        _physRepFrame = 0
        safe(function()
            Deps.sethiddenproperty(myHRP, "PhysicsRepRootPart", tHRP)
        end, "onHeartbeat:PhysicsRep")
    end

    local modeData = ATTACH_MODES[State.mode]
    if not modeData then return end

    local desiredCF = calculateTargetCFrame(State.mode, modeData, dt)
    if not desiredCF then return end

    applyPosition(myHRP, desiredCF, dt)
    updateAnimationSpeed()
end

-- ════════════════════════════════════════════════════════════════════════════
--  PUBLIC API
-- ════════════════════════════════════════════════════════════════════════════

function M.startBB(targetPlayer, modeKey)
    M.stopBB()

    if not targetPlayer or not targetPlayer.Character then
        if Deps.sendNotif then Deps.sendNotif("ByteBreaker", "No target character", 2) end
        return
    end

    if not ATTACH_MODES[modeKey] then
        if Deps.sendNotif then Deps.sendNotif("ByteBreaker", "Invalid mode: " .. tostring(modeKey), 2) end
        return
    end

    State.active = true
    State.mode   = modeKey
    State.target = targetPlayer

    refreshMyCache()
    refreshTargetCache()

    if not State.myHRP or not State.myHum then
        M.stopBB()
        if Deps.sendNotif then Deps.sendNotif("ByteBreaker", "Missing HRP/Humanoid", 2) end
        return
    end

    clearTable(State.arb.positionHistory)
    State.arb.lastConfirmedCF   = State.myHRP.CFrame
    State.arb.frozenUntil       = 0
    State.arb.freezeCount       = 0
    State.arb.lastResetAt       = 0
    State.arb.stopFrames        = 0
    State.arb.lastServerPushVel = Vector3.zero

    PID.reset()
    resetKS()

    if State.targetHRP then
        State.ks.lastTargetY = State.targetHRP.Position.Y
    end

    State.animSpeed.current = 1.0
    _physRepFrame           = 0

    setupRaknetHook()
    buildCollisionGroup()
    buildPhysicsStack(State.myHRP)
    setupHealthProtection()
    ensureNetworkOwnership()

    safe(function()
        State.myHum.PlatformStand = true
        State.myHum.WalkSpeed     = 0
    end, "startBB:humanoid")

    local animOpts = {}
    if modeKey == "bb_kiss"      then animOpts.r6Only  = true end
    if modeKey == "bb_sucking"   then animOpts.speed   = 2    end
    if modeKey == "bb_suck_it"   then animOpts.speed   = 1.5  end
    if modeKey == "bb_doggy"     then animOpts.speed   = 1.5  end
    if modeKey == "bb_bangv2"    then
        animOpts.speed = 2
        Oscillator.reset(modeKey .. "_osc")
    end
    if modeKey == "bb_soh" or modeKey == "bb_shouldersit" then
        animOpts.timePos = 2
    end

    playAnimation(modeKey, animOpts)

    State.connections[#State.connections + 1] = Deps.RunService.Heartbeat:Connect(onHeartbeat)

    bindRespawnHandlers()

    if Deps.sendNotif then
        Deps.sendNotif("ByteBreaker", "🎬 " .. modeKey .. ": " .. targetPlayer.Name, 3)
    end

    if Deps._AF then Deps._AF.bbActive = true end
end

function M.switchMode(newMode)
    if not State.active or not State.target then return end
    if not ATTACH_MODES[newMode] then return end

    State.mode              = newMode
    State.animSpeed.current = 1.0
    PID.reset()
    resetKS()

    if State.targetHRP then
        State.ks.lastTargetY = State.targetHRP.Position.Y
    end

    clearTable(State.arb.positionHistory)
    State.arb.lastConfirmedCF = State.myHRP and State.myHRP.CFrame or nil

    stopAllAnimations()

    local animOpts = {}
    if newMode == "bb_kiss"    then animOpts.r6Only = true end
    if newMode == "bb_sucking" then animOpts.speed  = 2    end
    if newMode == "bb_bangv2"  then
        animOpts.speed = 2
        Oscillator.reset(newMode .. "_osc")
    end

    playAnimation(newMode, animOpts)

    if Deps.sendNotif then Deps.sendNotif("ByteBreaker", "→ " .. newMode, 1) end
end

function M.stopBB()
    if not State.active then return end
    State.active = false

    for _, conn in ipairs(State.connections) do
        safe(function() conn:Disconnect() end, "stopBB:disconnect")
    end
    clearTable(State.connections)

    stopAllAnimations()
    destroyPhysicsStack()
    destroyCollisionGroup()
    removeRaknetHook()

    local myHRP = State.myHRP
    local myHum = State.myHum

    if myHRP then
        safe(function()
            Deps.sethiddenproperty(myHRP, "PhysicsRepRootPart", nil)
            clearVelocity(myHRP)
            myHRP.Anchored = false
        end, "stopBB:HRP")
    end

    if myHum then
        safe(function()
            myHum.PlatformStand = false
            myHum.WalkSpeed     = 16
            myHum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            myHum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            myHum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end, "stopBB:Humanoid")
    end

    State.mode           = nil
    State.target         = nil
    State.oscTime        = 0
    State.healthCheckAcc = 0
    State.cacheCheckAcc  = 0
    State.lastSafeY      = 0
    State.lastDetachFix  = 0
    State.ownershipSet   = false
    _physRepFrame        = 0

    clearTable(State.arb.positionHistory)
    State.arb.lastConfirmedCF   = nil
    State.arb.frozenUntil       = 0
    State.arb.freezeCount       = 0
    State.arb.stopFrames        = 0
    State.arb.lastServerPushVel = Vector3.zero

    PID.reset()
    resetKS()

    if Deps._AF then Deps._AF.bbActive = false end

    task.delay(0.08, function()
        if Deps.safeStand then safe(Deps.safeStand, "stopBB:safeStand") end
    end)

    if Deps.sendNotif then Deps.sendNotif("ByteBreaker", "👋 Stopped", 1) end
end

function M.initBB(cfg)
    assert(cfg, "[BB] initBB: cfg required")
    Deps.LocalPlayer                = cfg.LocalPlayer or game:GetService("Players").LocalPlayer
    Deps.RunService                 = cfg.RunService or game:GetService("RunService")
    Deps.Players                    = cfg.Players or game:GetService("Players")
    Deps.PhysicsService             = cfg.PhysicsService or game:GetService("PhysicsService")
    Deps.sethiddenproperty          = cfg.sethiddenproperty or sethiddenproperty
    assert(type(Deps.sethiddenproperty) == "function", "[BB] initBB: sethiddenproperty required")
    Deps.raknet                     = cfg.raknet
    Deps.sendNotif                  = cfg.sendNotif
    Deps.safeStand                  = cfg.safeStand
    Deps._AF                        = cfg._AF or {}
    Deps._AF_getReliableActionTrack = cfg._AF_getReliableActionTrack
end

function M.isActive() return State.active end

function M.getState()
    return {
        active    = State.active,
        mode      = State.mode,
        target    = State.target and State.target.Name,
        lastError = State.lastError,
        animSpeed = State.animSpeed.current,
        arb = {
            freezeCount = State.arb.freezeCount,
            stopFrames  = State.arb.stopFrames,
        },
        ks = {
            isFlying   = State.ks.flyFrames >= CFG.KS_FLY_FRAMES_REQ,
            isJumping  = State.ks.jumpCooldown > 0,
            stopXZ     = State.ks.stopFramesXZ,
            stopY      = State.ks.stopFramesY,
        }
    }
end

M._bbMode_   = function() return State.mode end
M._bbTarget_ = function() return State.target end

return M
