local M = {}
local _cfg = {}

local bbConn                    = nil
local bbRespConn                = nil
local bbTarget_                 = nil
local _bbMode_                  = nil
local bbAcc_                    = 0
local BB_CFG                    = {
    bb_orbit         = { distance = 8, speed = 1.5 },
    bb_frontwalk     = { distance = 5 },
    bb_behind        = { distance = 5 },
    bb_copy          = { distance = 4 },
    bb_piggyback     = {},
    bb_piggyback2    = {},
    bb_attach        = {},
    bb_cuffing       = { distance = 1.5 },
    bb_bangv2        = { speed = 10.0 },
    bb_carryshoulder = {},
    bb_carry2        = {},
    bb_hug           = {},
    bb_hug2          = {},
    bb_layfuck       = {},
    bb_licking       = { speed = 3.0 },
    bb_stomach       = { offset = Vector3.new(0, 0, 3.0), rotation = 180 },
    bb_kiss          = { speed = 10.0 },
    bb_sucking       = { speed = 20.0 },
    bb_suck_it       = { speed = 12.0 },
    bb_backshots     = { speed = 10.0 },
    bb_doggy         = {},
    bb_pussyspread   = { speed = 10.0 },
    bb_soh           = {},
    bb_shouldersit   = {},
    bb_friend        = {},
}
local bbBP_                     = nil
local bbBG_                     = nil
local bbPCP_                    = nil
local bbBP2_                    = nil
local bbBG2_                    = nil
local bbPCP2_                   = nil
local bbBP3_                    = nil
local bbBG3_                    = nil
local bbPCP3_                   = nil
local bbSBP_                    = nil
local bbSBG_                    = nil
local bbSPCP_                   = nil
local bbBP4_                    = nil
local bbBG4_                    = nil
local bbPCP4_                   = nil
local bbBP5_                    = nil
local bbBG5_                    = nil
local bbPCP5_                   = nil
local bbOsc5_                   = 0
local bbMainBV_                 = nil -- shared Y-only BodyVelocity
local bbBP6_                    = nil -- Hug BodyPosition
local bbBG6_                    = nil -- Hug BodyGyro
local bbPCP6_                   = nil -- Hug lerp pos
local bbBP7_                    = nil -- Licking BodyPosition
local bbBG7_                    = nil -- Licking BodyGyro
local bbPCP7_                   = nil -- Licking lerp pos
local bbBP8_                    = nil -- Carry
local bbBG8_                    = nil
local bbPCP8_                   = nil
local bbBP9_                    = nil -- Carry2
local bbBG9_                    = nil
local bbPCP9_                   = nil
local bbBP10_                   = nil -- Hug2
local bbBG10_                   = nil
local bbPCP10_                  = nil
local bbBP11_                   = nil -- Orbit
local bbBG11_                   = nil
local bbPCP11_                  = nil
local bbBP12_                   = nil -- Frontwalk/Behind/Headsit/Copy
local bbBG12_                   = nil
local bbPCP12_                  = nil
local bbOsc6_                   = 0 -- Hug oscillator
local BB_CARRY_ANIM_ID          = "95469914338674"
local BB_CARRY_SHOULDER_ANIM_ID = "101003999980390"
local BB_CARRY2_ANIM_ID         = "73126126731268"
local BB_HUG_ANIM_ID            = "93667149408515"
local BB_BACKSHOTS_ANIM_ID      = "101003999980390"
local BB_LICKING_ANIM_ID        = "86345507952689"
local BB_HUG2_ANIM_ID           = "101809619267911"
local BB_LAYFUCK_ANIM_ID        = "95678189010798"
local BB_BACKPACK_ANIM_ID       = "73500261613116"
local BB_STOMACH_ANIM_ID        = "105895909040298"
local BB_KISS_ANIM_ID           = "102367337136163"
local BB_SUCKING_ANIM_ID        = "74402438715168"
local BB_SUCK_IT_ANIM_ID        = "79294534752809"
local BB_DOGGY_ANIM_ID          = "101856096472698"
local BB_PUSSYSPREAD_ANIM_ID    = "120754278085861"
local BB_SOH_ANIM_ID            = "119898270336796"
local BB_SHOULDERSIT_ANIM_ID    = "119898270336796"
local BB_FRIEND_ANIM_ID         = "182435933"
local BB_BANGV2_ANIM_ID         = "107300675038850"
local BB_CUFFING_ANIM_ID        = "137809930492090"
local bbHealthConn_             = nil
local bbRespAnimConn_           = nil -- CharacterAdded conn for anim-restart on respawn (separate from bbAnimConn[N]_ track.Stopped slots)
local _bbTargetDiedConn         = nil
local _bbRakHooked = false
local _bbRakHookFn = nil

local function bbGetHRP(pl)
    local c = pl and pl.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function bbGetHead(pl)
    local c = pl and pl.Character
    return c and c:FindFirstChild("Head")
end
-- ============================================================
--  BB ANIMATION SYSTEM — Data-driven (replaces 23 duplicate functions)
--  bbAnimSlots[modeKey] = { track = AnimationTrack, conn = RBXScriptConnection }
-- ============================================================
local bbAnimSlots = {}

local function bbStopAnim()
    for _, slot in pairs(bbAnimSlots) do
        if slot.conn then pcall(function() slot.conn:Disconnect() end); slot.conn = nil end
        if slot.track then pcall(function() slot.track:AdjustSpeed(1); slot.track:Stop() end); slot.track = nil end
    end
end

-- Factory: creates a play-function for a given BB animation mode
local function bbMakePlayFn(modeKey, animId, animName, opts)
    opts = opts or {}
    local fn
    fn = function(char)
        if not char or not _cfg._AF.bbActive then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        if opts.r6Only and hum.RigType == Enum.HumanoidRigType.R6 then return end
        local track = _cfg._AF_getReliableActionTrack(hum, animId, animName)
        if not track then return end
        if opts.speed then pcall(function() track:AdjustSpeed(opts.speed) end) end
        if opts.timePos then track:AdjustSpeed(0); track.TimePosition = opts.timePos end
        local slot = bbAnimSlots[modeKey] or { track = nil, conn = nil }
        slot.track = track
        if slot.conn then slot.conn:Disconnect() end
        slot.conn = track.Stopped:Connect(function()
            if _cfg._AF.bbActive and _bbMode_ == modeKey then
                task.wait(0.1); fn(char)
            end
        end)
        bbAnimSlots[modeKey] = slot
    end
    return fn
end

-- Register all BB animation play-functions
local bbAnimFns = {
    bb_piggyback  = nil,
    bb_piggyback2 = nil,
    bb_attach     = bbMakePlayFn("bb_attach",     BB_BACKSHOTS_ANIM_ID,     "BBBackshotsAnim"),
    bb_carry      = bbMakePlayFn("bb_carry",      BB_CARRY_ANIM_ID,         "BBCarryAnim"),
    bb_bangv2     = bbMakePlayFn("bb_bangv2",     BB_BANGV2_ANIM_ID,        "BBBangV2Anim",    { speed = 2 }),
    bb_carry2     = bbMakePlayFn("bb_carry2",     BB_CARRY2_ANIM_ID,        "BBCarry2Anim"),
    bb_hug        = bbMakePlayFn("bb_hug",        BB_HUG_ANIM_ID,           "BBHugAnim"),
    bb_licking    = bbMakePlayFn("bb_licking",    BB_LICKING_ANIM_ID,       "BBLickingAnim"),
    bb_hug2       = bbMakePlayFn("bb_hug2",       BB_HUG2_ANIM_ID,          "BBHug2Anim"),
    bb_layfuck    = bbMakePlayFn("bb_layfuck",    BB_LAYFUCK_ANIM_ID,       "BBLayFuckAnim"),
    bb_backpack   = bbMakePlayFn("bb_backpack",   BB_BACKPACK_ANIM_ID,      "BBBackpackAnim"),
    bb_carryshoulder = bbMakePlayFn("bb_carryshoulder", BB_CARRY_SHOULDER_ANIM_ID, "BBCarryShoulderAnim"),
    bb_cuffing    = bbMakePlayFn("bb_cuffing",    BB_CUFFING_ANIM_ID,       "BBCuffingAnim"),
    bb_stomach    = bbMakePlayFn("bb_stomach",    BB_STOMACH_ANIM_ID,       "BBStomachAnim"),
    bb_kiss       = bbMakePlayFn("bb_kiss",       BB_KISS_ANIM_ID,          "BBKissAnim",      { r6Only = true }),
    bb_sucking    = bbMakePlayFn("bb_sucking",    BB_SUCKING_ANIM_ID,       "BBSuckingAnim",   { speed = 2 }),
    bb_suck_it    = bbMakePlayFn("bb_suck_it",    BB_SUCK_IT_ANIM_ID,       "BBSuckItAnim",    { speed = 1.5 }),
    bb_backshots  = bbMakePlayFn("bb_backshots",  BB_BACKSHOTS_ANIM_ID,     "BBBackshotsAnim2"),
    bb_doggy      = bbMakePlayFn("bb_doggy",      BB_DOGGY_ANIM_ID,         "BBDoggyAnim",     { speed = 1.5 }),
    bb_pussyspread = bbMakePlayFn("bb_pussyspread", BB_PUSSYSPREAD_ANIM_ID, "BBPussySpreadAnim"),
    bb_soh        = bbMakePlayFn("bb_soh",        BB_SOH_ANIM_ID,           "BBSitOnHeadAnim", { timePos = 2 }),
    bb_shouldersit = bbMakePlayFn("bb_shouldersit", BB_SHOULDERSIT_ANIM_ID, "BBShoulderSitAnim", { timePos = 2 }),
    bb_friend     = bbMakePlayFn("bb_friend",     BB_FRIEND_ANIM_ID,        "BBFriendAnim"),
}

function M.stopBB()
    local wasActive = _cfg._AF.bbActive
    _cfg._AF.bbActive = false
    if bbConn then
        bbConn:Disconnect(); bbConn = nil
    end
    if bbRespConn then
        bbRespConn:Disconnect(); bbRespConn = nil
    end
    if bbHealthConn_ then
        bbHealthConn_:Disconnect(); bbHealthConn_ = nil
    end
    if bbRespAnimConn_ then
        bbRespAnimConn_:Disconnect(); bbRespAnimConn_ = nil
    end
    if _bbTargetDiedConn then
        _bbTargetDiedConn:Disconnect(); _bbTargetDiedConn = nil
    end
    bbTarget_ = nil; _bbMode_ = nil; bbAcc_ = 0
    if bbBP_ then
        pcall(function() bbBP_:Destroy() end); bbBP_ = nil
    end
    if bbBG_ then
        pcall(function() bbBG_:Destroy() end); bbBG_ = nil
    end
    if bbBP2_ then
        pcall(function() bbBP2_:Destroy() end); bbBP2_ = nil
    end
    if bbBG2_ then
        pcall(function() bbBG2_:Destroy() end); bbBG2_ = nil
    end
    if bbBP3_ then
        pcall(function() bbBP3_:Destroy() end); bbBP3_ = nil
    end
    if bbBG3_ then
        pcall(function() bbBG3_:Destroy() end); bbBG3_ = nil
    end
    if bbBP4_ then
        pcall(function() bbBP4_:Destroy() end); bbBP4_ = nil
    end
    if bbBG4_ then
        pcall(function() bbBG4_:Destroy() end); bbBG4_ = nil
    end
    if bbBP5_ then
        pcall(function() bbBP5_:Destroy() end); bbBP5_ = nil
    end
    if bbBG5_ then
        pcall(function() bbBG5_:Destroy() end); bbBG5_ = nil
    end
    if bbMainBV_ then
        pcall(function() bbMainBV_:Destroy() end); bbMainBV_ = nil
    end
    if bbBP6_ then
        pcall(function() bbBP6_:Destroy() end); bbBP6_ = nil
    end
    if bbBG6_ then
        pcall(function() bbBG6_:Destroy() end); bbBG6_ = nil
    end
    if bbBP7_ then
        pcall(function() bbBP7_:Destroy() end); bbBP7_ = nil
    end
    if bbBG7_ then
        pcall(function() bbBG7_:Destroy() end); bbBG7_ = nil
    end
    if bbBP8_ then
        pcall(function() bbBP8_:Destroy() end); bbBP8_ = nil
    end
    if bbBG8_ then
        pcall(function() bbBG8_:Destroy() end); bbBG8_ = nil
    end
    if bbBP9_ then
        pcall(function() bbBP9_:Destroy() end); bbBP9_ = nil
    end
    if bbBG9_ then
        pcall(function() bbBG9_:Destroy() end); bbBG9_ = nil
    end
    if bbBP10_ then
        pcall(function() bbBP10_:Destroy() end); bbBP10_ = nil
    end
    if bbBG10_ then
        pcall(function() bbBG10_:Destroy() end); bbBG10_ = nil
    end
    if bbBP11_ then
        pcall(function() bbBP11_:Destroy() end); bbBP11_ = nil
    end
    if bbBG11_ then
        pcall(function() bbBG11_:Destroy() end); bbBG11_ = nil
    end
    if bbBP12_ then
        pcall(function() bbBP12_:Destroy() end); bbBP12_ = nil
    end
    if bbBG12_ then
        pcall(function() bbBG12_:Destroy() end); bbBG12_ = nil
    end
    bbPCP6_ = nil; bbPCP7_ = nil; bbPCP8_ = nil; bbPCP9_ = nil
    bbPCP10_ = nil; bbPCP11_ = nil; bbPCP12_ = nil
    if bbSBP_ then
        pcall(function() bbSBP_:Destroy() end); bbSBP_ = nil
    end
    if bbSBG_ then
        pcall(function() bbSBG_:Destroy() end); bbSBG_ = nil
    end
    bbPCP4_ = nil
    bbPCP5_ = nil
    bbOsc6_ = 0
    bbSPCP_ = nil
    bbOsc5_ = 0
    bbPCP_ = nil
    bbPCP2_ = nil
    bbPCP3_ = nil
    bbStopAnim()
    local myChar = _cfg.LocalPlayer.Character
    if myChar then
        local hrp = myChar:FindFirstChild("HumanoidRootPart")
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        if hrp then
            pcall(function() _cfg.sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end)
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
            pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
            pcall(function() hrp.Anchored = false end)
            -- destroy all remaining mover instances by class
            pcall(function()
                for _, o in ipairs(hrp:GetChildren()) do
                    if o:IsA("BodyVelocity") or o:IsA("BodyAngularVelocity")
                        or o:IsA("BodyPosition") or o:IsA("BodyGyro") then
                        pcall(function() o:Destroy() end)
                    end
                end
            end)
        end
        if hum then
            pcall(function() if not _cfg.flyActive() then hum.PlatformStand = false end end)
            pcall(function() hum.WalkSpeed = 16 end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
        -- restore collisions for every BasePart in character
        pcall(function()
            for _, p in ipairs(myChar:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
            end
        end)
    end
    if _cfg.setFreeze then pcall(function() _cfg.setFreeze(false) end) end
    if wasActive then _cfg.sendNotif("ByteBreaker", _cfg.T.qa_stopped, 1) end
    -- Re-enable sitting when ByteBreaker stops
    pcall(function()
        local hum = _cfg.getHumanoid(); if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
    end)

    -- Robust delayed cleanup
    task.delay(0.08, function()
        local c2 = _cfg.LocalPlayer.Character
        local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
        local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
        if r2 then
            pcall(function() _cfg.sethiddenproperty(r2, "PhysicsRepRootPart", nil) end)
            r2.Velocity = Vector3.zero
            pcall(function()
                for _, o in ipairs(r2:GetChildren()) do
                    if o:IsA("BodyVelocity") or o:IsA("BodyAngularVelocity")
                        or o:IsA("BodyPosition") or o:IsA("BodyGyro") then
                        o:Destroy()
                    end
                end
            end)
        end
        if h2 then
            pcall(function() h2.Sit = false end)
            if not _cfg.flyActive() then pcall(function() h2.PlatformStand = false end) end
            pcall(function() h2:ChangeState(Enum.HumanoidStateType.Running) end)
        end
        pcall(_cfg.safeStand)
    end)
end

function M.startBB(targetPlayer, modeKey)
    _cfg._TL_refs._TL_startBB = M.startBB
    _G.startBB = M.startBB
    M.stopBB()
    -- bb_attach.lua cleanup on start
    do
        local _c = _cfg.LocalPlayer.Character
        local _tc = targetPlayer and targetPlayer.Character
        local _tH = _tc and _tc:FindFirstChild("HumanoidRootPart")
        if _c then
            local _h = _c:FindFirstChild("HumanoidRootPart")
            if _h then
                pcall(function() _cfg.sethiddenproperty(_h, "PhysicsRepRootPart", _tH) end)
                -- No-Jitter: RakNet hook to prevent server position override
                pcall(function()
                    if not _cfg.raknet then return end
                    task.spawn(function()
                        _bbRakHookFn = function(packet)
                            if packet.PacketId == 0x1B then
                                local buf = packet.AsBuffer
                                buffer.writeu32(buf, 1, 0xFFFFFFFF)
                                packet:SetData(buf)
                            end
                        end
                        if _bbRakHooked then
                            _cfg.raknet.remove_send_hook(_bbRakHookFn)
                        end
                        _cfg.raknet.add_send_hook(_bbRakHookFn)
                        _bbRakHooked = true
                    end)
                end)
                pcall(function() _h.AssemblyLinearVelocity = Vector3.zero end)
                pcall(function() _h.AssemblyAngularVelocity = Vector3.zero end)
                pcall(function() _h.Anchored = false end)
                pcall(function()
                    for _, _o in ipairs(_h:GetChildren()) do
                        if _o:IsA("BodyVelocity") or _o:IsA("BodyAngularVelocity")
                            or _o:IsA("BodyPosition") or _o:IsA("BodyGyro") then
                            pcall(function() _o:Destroy() end)
                        end
                    end
                end)
            end
        end
    end
    if not targetPlayer or not targetPlayer.Character then
        _cfg.sendNotif("ByteBreaker", _cfg.T.gb_no_target_char, 2); return
    end
    local myChar = _cfg.LocalPlayer.Character
    if not myChar then
        _cfg.sendNotif("ByteBreaker", _cfg.T.gb_no_own_char, 2); return
    end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then
        _cfg.sendNotif("ByteBreaker", _cfg.T.gb_missing_parts, 2); return
    end
    local tHRP_init = bbGetHRP(targetPlayer)
    if not tHRP_init then
        _cfg.sendNotif("ByteBreaker", _cfg.T.gb_no_target_char, 2); return
    end
    _cfg._AF.bbActive        = true
    bbTarget_           = targetPlayer
    _bbMode_            = modeKey
    bbAcc_              = 0
    myHum.PlatformStand = true
    myHum.WalkSpeed     = 0
    pcall(function() myHRP:SetNetworkOwner(_cfg.LocalPlayer) end)
    -- Prevent sitting on benches/chairs during ByteBreaker
    pcall(function()
        local hum = _cfg.getHumanoid(); if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
    end)
    if bbHealthConn_ then
        bbHealthConn_:Disconnect(); bbHealthConn_ = nil
    end
    local VOID_Y      = -200
    local RESCUE_Y    = 50
    local _lastSafeY  = myHRP.Position.Y
    local _bbDiedConn = nil
    local function hookDied(hm2)
        if _bbDiedConn then pcall(function() _bbDiedConn:Disconnect() end) end
        _bbDiedConn = hm2.Died:Connect(function()
            if not _cfg._AF.bbActive then return end
            pcall(function() hm2.Health = hm2.MaxHealth end)
            task.wait()
            pcall(function() hm2.Health = hm2.MaxHealth end)
        end)
    end
    hookDied(myHum)
    _cfg.LocalPlayer.CharacterAdded:Connect(function(newChar)
        if not _cfg._AF.bbActive then
            return
        end
        local newHum = newChar:WaitForChild("Humanoid", 5)
        if newHum then hookDied(newHum) end
    end)
    local _bbHAcc    = 0
    local _bbHC_char = _cfg.LocalPlayer.Character
    local _bbHC_hrp  = _bbHC_char and _bbHC_char:FindFirstChild("HumanoidRootPart")
    local _bbHC_hm   = _bbHC_char and _bbHC_char:FindFirstChildOfClass("Humanoid")
    local _bbHAcc2   = 0
    bbHealthConn_    = _cfg.RunService.Heartbeat:Connect(function(dt)
        if not _cfg._AF.bbActive then return end
        _bbHAcc2 = _bbHAcc2 + dt
        if _bbHAcc2 < 0.08 then return end
        _bbHAcc2 = 0
        local c = _cfg.LocalPlayer.Character
        if c ~= _bbHC_char then
            _bbHC_char = c
            _bbHC_hrp  = c and c:FindFirstChild("HumanoidRootPart")
            _bbHC_hm   = c and c:FindFirstChildOfClass("Humanoid")
        end
        local hrp = _bbHC_hrp
        local hm  = _bbHC_hm
        if not hrp or not hrp.Parent or not hm then return end
        if hrp.Position.Y > VOID_Y then
            _lastSafeY = hrp.Position.Y
        end
        if hm.Health < hm.MaxHealth then hm.Health = hm.MaxHealth end
        _bbHAcc = _bbHAcc + dt
        if _bbHAcc >= 0.5 then
            _bbHAcc = 0
            if hm.SeatPart then pcall(function() hm:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end) end
            pcall(function() hm:ChangeState(Enum.HumanoidStateType.Physics) end)
        end
        if hrp.Position.Y < VOID_Y then
            local tHRP2 = bbGetHRP(bbTarget_)
            local rescueCF = tHRP2
                and (tHRP2.CFrame * CFrame.new(0, RESCUE_Y, 0))
                or CFrame.new(hrp.Position.X, math.max(_lastSafeY, RESCUE_Y), hrp.Position.Z)
            pcall(function()
                hrp.CFrame = rescueCF
                hrp.AssemblyLinearVelocity = Vector3.zero
                hm.Health = hm.MaxHealth
            end)
        end
    end)
    if (modeKey == "bb_stand" or modeKey == "bb_headstand") and type(_cfg.standStartAnim) == "function" then
        if type(_cfg.standSetAnim) == "function" then _cfg.standSetAnim(modeKey == "bb_headstand" and
            "71483261700852" or nil) end
        _cfg.standStartAnim()
    end
    pcall(_cfg.sethiddenproperty, myHRP, "PhysicsRepRootPart", tHRP_init)
    -- disable collisions for every BasePart in character (mirrors setCollisions(false))
    for _, p in ipairs(myChar:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
    -- Zero velocity and pre-position before loop starts (prevents initial bounce)
    pcall(function()
        myHRP.AssemblyLinearVelocity  = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero
    end)
    -- BodyVelocity Y-only: counteracts gravity for all direct-CFrame modes
    if bbMainBV_ then
        pcall(function() bbMainBV_:Destroy() end); bbMainBV_ = nil
    end
    bbMainBV_            = Instance.new("BodyVelocity")
    bbMainBV_.MaxForce   = Vector3.new(0, 1e6, 0)
    bbMainBV_.Velocity   = Vector3.zero
    bbMainBV_.Parent     = myHRP
    local _bbMyCharCache = myChar
    local _bbMHRP        = myChar:FindFirstChild("HumanoidRootPart")
    local _bbMHum        = myChar:FindFirstChildOfClass("Humanoid")
    -- cache tHRP so FindFirstChild isn't called every frame
    local _bbCachedTHRP  = nil
    local _bbCachedTChar = false -- false sentinel forces cache on first frame
    local _bbCachedTorso = nil

    local function _guardHum()
        local mHum = _bbMHum
        if mHum then mHum.PlatformStand = true end
    end

    bbConn = _cfg.RunService.Heartbeat:Connect(function(dt)
        if not _cfg._AF.bbActive then return end
        -- Ersten Frame überspringen damit Physik stabilisiert
        if bbAcc_ == 0 then bbAcc_ = bbAcc_ + dt; return end
        -- update my char cache
        local curChar = _cfg.LocalPlayer.Character
        local _charChanged = (curChar ~= _bbMyCharCache)
        if _charChanged then
            _bbMyCharCache = curChar
            _bbMHRP = curChar and curChar:FindFirstChild("HumanoidRootPart")
            _bbMHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
        end
        local mHRP = _bbMHRP
        local mHum = _bbMHum
        if not bbTarget_ or not bbTarget_.Parent then
            M.stopBB(); return
        end
        if not mHRP or not mHRP.Parent then return end
        -- cache target HRP: only re-lookup when target char changes
        local tChar = bbTarget_.Character
        if tChar ~= _bbCachedTChar or not _bbCachedTHRP then
            _bbCachedTChar = tChar
            _bbCachedTHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
            _bbCachedTorso = tChar and
            (tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso"))
            -- PhysicsRepRootPart nur bei Char-Wechsel setzen, nicht jedes Frame
            if _bbCachedTHRP then
                pcall(_cfg.sethiddenproperty, mHRP, "PhysicsRepRootPart", _bbCachedTHRP)
            end
        end
        local tHRP = _bbCachedTHRP
        if not tHRP or not tHRP.Parent then return end
        -- torso is cached with tChar (same change detection as tHRP)
        local _torso = _bbCachedTorso or tHRP -- guaranteed non-nil
        -- Velocity-Reset nur bei großen Werten (verhindert Physics-Konflikte)
        local vel = mHRP.AssemblyLinearVelocity
        if vel.Magnitude > 0.5 then
            mHRP.Velocity = Vector3.zero
        end
        -- disable collisions: only re-sweep when character instance changed (avoids per-frame Descendants scan)
        if _charChanged and curChar then
            for _, p in ipairs(curChar:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        -- Refresh shared BodyVelocity only if genuinely lost (no destroy-loop, no GetChildren scan)
        if not bbMainBV_ or not bbMainBV_.Parent then
            bbMainBV_          = Instance.new("BodyVelocity")
            bbMainBV_.MaxForce = Vector3.new(0, 1e6, 0)
            bbMainBV_.Velocity = _cfg.V3_ZERO
            bbMainBV_.Parent   = mHRP
        end
        bbAcc_ = bbAcc_ + dt
        local key = _bbMode_
        -- Zero-Delay: PhysicsRepRootPart reapply + PlatformStand + velocity each frame
        pcall(function() _cfg.sethiddenproperty(mHRP, "PhysicsRepRootPart", tHRP) end)
        if mHum then mHum.PlatformStand = true end
        mHRP.Velocity = Vector3.zero
        mHRP.RotVelocity = Vector3.zero
        mHRP.AssemblyLinearVelocity = Vector3.zero
        mHRP.AssemblyAngularVelocity = Vector3.zero
        if key == "bb_attach" then
            local offset = -2.0 - math.sin(bbAcc_ * 10.0) * 1.5
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, -0.85, offset) *
            CFrame.Angles(math.rad(20) + 0.03, 0, 0)
        elseif key == "bb_orbit" then
            local dist = BB_CFG.bb_orbit.distance
            local spd = BB_CFG.bb_orbit.speed
            local angle = bbAcc_ * spd
            local pos = Vector3.new(
                tHRP.Position.X + math.cos(angle) * dist,
                tHRP.Position.Y,
                tHRP.Position.Z + math.sin(angle) * dist)
            mHRP.CFrame = CFrame.new(pos, tHRP.Position)
        elseif key == "bb_frontwalk" then
            local look = tHRP.CFrame.LookVector
            local pos = tHRP.Position + look * BB_CFG.bb_frontwalk.distance
            mHRP.CFrame = CFrame.new(pos, pos + look)
        elseif key == "bb_cuffing" then
            local look = tHRP.CFrame.LookVector
            local pos = tHRP.Position - look * BB_CFG.bb_cuffing.distance
            mHRP.CFrame = CFrame.new(pos, pos + look)
        elseif key == "bb_behind" then
            local look = tHRP.CFrame.LookVector
            local pos = tHRP.Position - look * BB_CFG.bb_behind.distance
            mHRP.CFrame = CFrame.new(pos, pos + look)
        elseif key == "bb_headsit" then
            local head = tChar and tChar:FindFirstChild("Head")
            local base = head and head.CFrame or (tHRP.CFrame * CFrame.new(0, 3, 0))
            mHRP.CFrame = CFrame.new(base.Position + Vector3.new(0, 1.4, 0))
                * CFrame.fromEulerAnglesXYZ(math.rad(90), select(2, tHRP.CFrame:ToEulerAnglesXYZ()), 0)
        elseif key == "bb_copy" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(BB_CFG.bb_copy.distance, 0, 0)
        elseif key == "bb_piggyback" then
            if bbBP_ then pcall(function() bbBP_:Destroy() end); bbBP_ = nil end
            if bbBG_ then pcall(function() bbBG_:Destroy() end); bbBG_ = nil end
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0.2, 1.1)
        elseif key == "bb_backpack" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 2.5, 1.2)
        elseif key == "bb_piggyback2" then
            if bbBP2_ then pcall(function() bbBP2_:Destroy() end); bbBP2_ = nil end
            if bbBG2_ then pcall(function() bbBG2_:Destroy() end); bbBG2_ = nil end
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0.2, 1.1)
        elseif key == "bb_carry" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0.5, -0.5, -1.2)
        elseif key == "bb_carryshoulder" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(1.8, 0.2, 1)
        elseif key == "bb_carry2" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0.5, 1.0, -1.2)
        elseif key == "bb_hug" then
            local offset = -1.35 - math.sin(bbAcc_ * 10.0) * 0.04
            mHRP.CFrame = tHRP.CFrame
                * CFrame.new(0, 0.05, offset)
                * CFrame.Angles(0, math.rad(180), 0)
        elseif key == "bb_hug2" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1.1)
        elseif key == "bb_stand" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(-0.8, 2, 2.2)
        elseif key == "bb_layfuck" then
            local zOff = 1.1 + math.sin(bbAcc_ * 12.0) * 0.9
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0.1, zOff)
        elseif key == "bb_headstand" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0.2, 4, 0.2)
        elseif key == "bb_licking" then
            local offset = -2.5 - math.sin(bbAcc_ * 15.0) * 0.4
            mHRP.CFrame = tHRP.CFrame
                * CFrame.new(0, -1.7, offset)
                * CFrame.Angles(0, math.rad(180), 0)
        elseif key == "bb_bangv2" then
            bbOsc5_ = bbOsc5_ + dt * BB_CFG.bb_bangv2.speed
            local oscOffset = 3.5 - math.sin(bbOsc5_) * 3
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0.2, oscOffset)
        elseif key == "bb_stomach" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3.0) * CFrame.Angles(0, math.rad(180), 0)
        elseif key == "bb_kiss" then
            local offset = -1.2 - math.sin(bbAcc_ * 10.0) * 0.08
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, 1.5, offset) * _cfg.CF_ROT180Y
        elseif key == "bb_sucking" then
            local offset = -3.1 - math.sin(bbAcc_ * 20.0) * 0.5
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, -0.4, offset) * _cfg.CF_ROT180Y
        elseif key == "bb_suck_it" then
            local offset = -2.0 - math.sin(bbAcc_ * 12.0) * 1.0
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, -1.2, offset) * _cfg.CF_ROT180Y
        elseif key == "bb_backshots" then
            local offset = -2.0 - math.sin(bbAcc_ * 10.0) * 1.5
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, -3.2, offset) *
            CFrame.Angles(math.rad(20) + 0.03, 0, 0)
        elseif key == "bb_doggy" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, -4.7, -0.8) *
            CFrame.Angles(math.rad(-90), 0, 0)
        elseif key == "bb_pussyspread" then
            local offset = -2.0 - math.sin(bbAcc_ * 10.0) * 1.5
            mHRP.CFrame = tHRP.CFrame * CFrame.new(0, -2.45, offset)
        elseif key == "bb_soh" then
            local head = tChar and tChar:FindFirstChild("Head")
            local hPos = head and head.Position or (tHRP.Position + Vector3.new(0, 3, 0))
            mHRP.CFrame = CFrame.new(hPos + Vector3.new(0, 1, 0))
        elseif key == "bb_shouldersit" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(1.8, 2.2, 0)
        elseif key == "bb_friend" then
            mHRP.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0)
        end
    end)
    -- Dispatch: table lookup replaces 23-branch if/elseif
    local _bbAnimFn = bbAnimFns[modeKey]
    if modeKey == "bb_bangv2" then bbOsc5_ = 0 end
    if _bbAnimFn then
        task.spawn(function() _bbAnimFn(_cfg.LocalPlayer.Character) end)
        if bbRespAnimConn_ then bbRespAnimConn_:Disconnect() end
        bbRespAnimConn_ = _cfg.LocalPlayer.CharacterAdded:Connect(function(char)
            if _cfg._AF.bbActive and _bbAnimFn then
                task.wait(0.5); task.spawn(function() _bbAnimFn(char) end)
            end
        end)
    end
    bbRespConn = targetPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not _cfg._AF.bbActive then return end
        -- Re-attach when target respawns (outfit change)
        local savedMode = _bbMode_
        local savedTarget = bbTarget_
        if savedTarget and savedMode then
            pcall(function()
                M.startBB(savedTarget, savedMode)
            end)
        end
    end)
    -- Handle target death to re-attach
    local function hookTargetDied(targetChar)
        if not targetChar then return end
        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
        if not targetHum then return end
        if _bbTargetDiedConn then pcall(function() _bbTargetDiedConn:Disconnect() end) end
        _bbTargetDiedConn = targetHum.Died:Connect(function()
            if not _cfg._AF.bbActive then return end
            -- Target died, wait for respawn and re-attach
            task.wait(0.5)
            local savedMode = _bbMode_
            local savedTarget = bbTarget_
            if savedTarget and savedMode then
                pcall(function()
                    M.startBB(savedTarget, savedMode)
                end)
            end
        end)
    end
    hookTargetDied(targetPlayer.Character)
    targetPlayer.CharacterAdded:Connect(function(newChar)
        if _cfg._AF.bbActive then
            hookTargetDied(newChar)
        end
    end)
    local bbRemConn
    bbRemConn = _cfg._tlTrackConn(_cfg.Players.PlayerRemoving:Connect(function(pl)
        if pl == bbTarget_ and _cfg._AF.bbActive then
            bbRemConn:Disconnect()
            M.stopBB()
            _cfg.sendNotif("ByteBreaker", "👋 " .. pl.Name .. " has left", 2)
        end
    end))
    local modeNames = {
        bb_attach = "ByteBackshots",
        bb_orbit = "Orbit",
        bb_frontwalk = "Front",
        bb_behind = "Behind",
        bb_headsit = "Head Sit",
        bb_copy = "Copy",
        bb_piggyback = "Piggyback",
        bb_piggyback2 = "Piggyback2",
        bb_carry = "Carry",
        bb_carryshoulder = "Carry on shoulder",
        bb_headstand = "Head Stand",
        bb_bangv2 = "BangV2",
        bb_carry2 = "Carry2",
        bb_hug = "Hug",
        bb_hug2 = "Hug2",
        bb_layfuck = "LayFuck",
        bb_licking = "Licking",
        bb_backpack = "Backpack",
        bb_stomach = "Stomach",
        bb_cuffing = "Cuffing",
        bb_kiss = "Kiss",
        bb_sucking = "Sucking",
        bb_suck_it = "Suck It",
        bb_backshots = "Backshots",
        bb_doggy = "Doggy",
        bb_pussyspread = "Pussy Spread",
        bb_soh = "On Head",
        bb_shouldersit = "Shouldersit",
        bb_friend = "Friend",
    }
    _cfg.sendNotif("ByteBreaker", "🎬 " .. (modeNames[modeKey] or modeKey) .. ": " .. targetPlayer.Name, 3)
end

function M.init(cfg)
    _cfg = cfg or {}

    bbAnimFns.bb_piggyback  = bbMakePlayFn("bb_piggyback",  _cfg.PIGGYBACK_ANIM_ID,        "BBPiggybackAnim")
    bbAnimFns.bb_piggyback2 = bbMakePlayFn("bb_piggyback2", _cfg.PIGGYBACK2_ANIM_ID,       "BBPiggyback2Anim")
end

M._bbMode_ = function() return _bbMode_ end
M._bbTarget_ = function() return bbTarget_ end

return M
