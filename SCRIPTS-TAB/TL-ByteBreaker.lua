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
local bbMainBV_                 = nil
local bbBP6_                    = nil
local bbBG6_                    = nil
local bbPCP6_                   = nil
local bbBP7_                    = nil
local bbBG7_                    = nil
local bbPCP7_                   = nil
local bbBP8_                    = nil
local bbBG8_                    = nil
local bbPCP8_                   = nil
local bbBP9_                    = nil
local bbBG9_                    = nil
local bbPCP9_                   = nil
local bbBP10_                   = nil
local bbBG10_                   = nil
local bbPCP10_                  = nil
local bbBP11_                   = nil
local bbBG11_                   = nil
local bbPCP11_                  = nil
local bbBP12_                   = nil
local bbBG12_                   = nil
local bbPCP12_                  = nil
local bbOsc6_                   = 0
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
local bbRespAnimConn_           = nil
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

local bbAnimSlots = {}

local function bbStopAnim()
    for _, slot in pairs(bbAnimSlots) do
        if slot.conn then pcall(function() slot.conn:Disconnect() end); slot.conn = nil end
        if slot.track then pcall(function() slot.track:AdjustSpeed(1); slot.track:Stop() end); slot.track = nil end
    end
end

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
        pcall(function()
            for _, p in ipairs(myChar:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
            end
        end)
    end
    if _cfg.setFreeze then pcall(function() _cfg.setFreeze(false) end) end
    if wasActive then _cfg.sendNotif("ByteBreaker", _cfg.T.qa_stopped, 1) end
    pcall(function()
        local hum = _cfg.getHumanoid(); if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end
    end)

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
    do
        local _c = _cfg.LocalPlayer.Character
        local _tc = targetPlayer and targetPlayer.Character
        local _tH = _tc and _tc:FindFirstChild("HumanoidRootPart")
        if _c then
            local _h = _c:FindFirstChild("HumanoidRootPart")
            if _h then
                pcall(function() _cfg.sethiddenproperty(_h, "PhysicsRepRootPart", _tH) end)
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
    for _, p in ipairs(myChar:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
    pcall(function()
        myHRP.AssemblyLinearVelocity  = Vector3.zero
        myHRP.AssemblyAngularVelocity = Vector3.zero
    end)
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
    local _bbCachedTHRP  = nil
    local _bbCachedTChar = false
    local _bbCachedTorso = nil

    local function _guardHum()
        local mHum = _bbMHum
        if mHum then mHum.PlatformStand = true end
    end

    bbConn = _cfg.RunService.Heartbeat:Connect(function(dt)
        if not _cfg._AF.bbActive then return end
        if bbAcc_ == 0 then bbAcc_ = bbAcc_ + dt; return end
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
        local tChar = bbTarget_.Character
        if tChar ~= _bbCachedTChar or not _bbCachedTHRP then
            _bbCachedTChar = tChar
            _bbCachedTHRP  = tChar and tChar:FindFirstChild("HumanoidRootPart")
            _bbCachedTorso = tChar and
            (tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso"))
            if _bbCachedTHRP then
                pcall(_cfg.sethiddenproperty, mHRP, "PhysicsRepRootPart", _bbCachedTHRP)
            end
        end
        local tHRP = _bbCachedTHRP
        if not tHRP or not tHRP.Parent then return end
        local _torso = _bbCachedTorso or tHRP
        local vel = mHRP.AssemblyLinearVelocity
        if vel.Magnitude > 0.5 then
            mHRP.Velocity = Vector3.zero
        end
        if _charChanged and curChar then
            for _, p in ipairs(curChar:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        if not bbMainBV_ or not bbMainBV_.Parent then
            bbMainBV_          = Instance.new("BodyVelocity")
            bbMainBV_.MaxForce = Vector3.new(0, 1e6, 0)
            bbMainBV_.Velocity = _cfg.V3_ZERO
            bbMainBV_.Parent   = mHRP
        end
        bbAcc_ = bbAcc_ + dt
        local key = _bbMode_
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
        local savedMode = _bbMode_
        local savedTarget = bbTarget_
        if savedTarget and savedMode then
            pcall(function()
                M.startBB(savedTarget, savedMode)
            end)
        end
    end)
    local function hookTargetDied(targetChar)
        if not targetChar then return end
        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
        if not targetHum then return end
        if _bbTargetDiedConn then pcall(function() _bbTargetDiedConn:Disconnect() end) end
        _bbTargetDiedConn = targetHum.Died:Connect(function()
            if not _cfg._AF.bbActive then return end
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

function M.initBB(cfg)
    _cfg = cfg or {}
    bbAnimFns.bb_piggyback  = bbMakePlayFn("bb_piggyback",  _cfg.PIGGYBACK_ANIM_ID,        "BBPiggybackAnim")
    bbAnimFns.bb_piggyback2 = bbMakePlayFn("bb_piggyback2", _cfg.PIGGYBACK2_ANIM_ID,       "BBPiggyback2Anim")
end

M._bbMode_ = function() return _bbMode_ end
M._bbTarget_ = function() return bbTarget_ end


local RUNTIME_KEY = "__TL_QABarRuntime"
local _qb            = {}
local _qaInitialized   = false
local _qaStarted       = false

local P = setmetatable({}, {
    __index = function(_, k)
        local _C = _qb.C or _G.C or {}
        local stops = {
            _P_STOP_BG  = Color3.fromRGB(35, 10, 12),
            _P_STOP_BRD = Color3.fromRGB(180, 45, 45),
            _P_STOP_TXT = Color3.fromRGB(224, 72, 72),
        }

        local literals = {
            stopBg  = stops._P_STOP_BG,
            stopBrd = stops._P_STOP_BRD,
            stopTxt = stops._P_STOP_TXT,
        }
        if literals[k] then return literals[k] end

        local map = {
            panel    = "bg2",
            hdr      = "bg3",
            hdrBrd   = "sub",
            panelBrd = "accent2",
            icoBox   = "accent2",
            title    = "text",
            tgtBg    = "bg2",
            tgtBrd   = "borderdim",
            tgtTxt   = "sub",
            tgtDot   = "accent",
            card     = "bg2",
            cardHov  = "bg3",
            cardBrd  = "borderdim",
            cardBrdH = "accent2",
            lblOff   = "sub",
            lblOn    = "text",
            foot     = "bg2",
            footBrd  = "borderdim",
            badge    = "bg2",
            badgeTxt = "sub",
        }
        local cKey = map[k]
        if cKey and _C[cKey] then return _C[cKey] end
        return nil
    end,
})
local API = {}

function M.initQABar(deps)
    do
        local _genvC = deps._genv or (getgenv and getgenv()) or {}
        _qb.C = deps.C or _genvC.C or _G.C or _qb.C
    end

    if _qaInitialized then return end
    _qaInitialized = true

    local _TL_refs = deps._TL_refs or {}
    local _genv    = deps._genv or (getgenv and getgenv()) or {}

    _qb.g               = _TL_refs
    _TL_refs._TL_qb     = _qb
    _qb.env             = _genv
    _qb.ScreenGui       = _TL_refs._TL_ScreenGui or _genv._TL_ScreenGui
    _qb.tw              = _TL_refs._TL_tw or _genv._TL_tw
    _qb.tlHitbox        = _TL_refs._TL_tlHitbox or _genv._TL_tlHitbox
    _qb.tlLbl           = _TL_refs._TL_tlLbl or _genv._TL_tlLbl
    _qb.tlArrow         = _TL_refs._TL_tlArrow or _genv._TL_tlArrow
    _qb.tlArrowBig      = _TL_refs._TL_tlArrowBig or _genv._TL_tlArrowBig
    _qb.FW_W            = _TL_refs._TL_FW_W or _genv._TL_FW_W or 230
    _qb.FW_H            = _TL_refs._TL_FW_H or _genv._TL_FW_H or 34
    _qb.FW_X_OFFSET     = _TL_refs._TL_FW_X_OFFSET or _genv._TL_FW_X_OFFSET or -5
    _qb.VL_ICON_W       = _TL_refs._TL_VL_ICON_W or _genv._TL_VL_ICON_W or 58
    _qb.sendNotif       = _TL_refs._TL_sendNotif or _genv._TL_sendNotif
    _qb.getRootPart     = _TL_refs._TL_getRootPart or _genv._TL_getRootPart
    _qb.safeStand       = _TL_refs._TL_safeStand or _genv._TL_safeStand
    _qb.AF              = _TL_refs._TL_AF or _genv._TL_AF
    _qb.SOH             = _TL_refs._TL_SOH or _genv._TL_SOH
    _qb.act_stopFollow  = _TL_refs._TL_act_stopFollow or _genv._TL_act_stopFollow
    _qb.stopBB          = function() pcall(function() M.stopBB() end) end
    _qb.startBB         = function(target, mode) pcall(function() M.startBB(target, mode) end) end
    _qb.qaDispatch      = _TL_refs._TL_qaDispatch
    _qb.stopGhost       = _TL_refs._TL_stopGhost or _genv._TL_stopGhost
    _qb.stopSitOnHead   = _TL_refs._TL_stopSitOnHead or _genv._TL_stopSitOnHead
    _qb.stopPiggyback   = _TL_refs._TL_stopPiggyback or _genv._TL_stopPiggyback
    _qb.stopPiggyback2  = _TL_refs._TL_stopPiggyback2 or _genv._TL_stopPiggyback2
    _qb.stopKiss        = _TL_refs._TL_stopKiss or _genv._TL_stopKiss
    _qb.stopBackpack    = _TL_refs._TL_stopBackpack or _genv._TL_stopBackpack
    _qb.stopOrbit       = _TL_refs._TL_stopOrbit or _genv._TL_stopOrbit
    _qb.stopUpsideDown  = _TL_refs._TL_stopUpsideDown or _genv._TL_stopUpsideDown
    _qb.stopCrossUD     = _TL_refs._TL_stopCrossUD or _genv._TL_stopCrossUD
    _qb.stopFriend      = _TL_refs._TL_stopFriend or _genv._TL_stopFriend
    _qb.stopSpinning    = _TL_refs._TL_stopSpinning or _genv._TL_stopSpinning
    _qb.stopLicking     = _TL_refs._TL_stopLicking or _genv._TL_stopLicking
    _qb.stopSucking     = _TL_refs._TL_stopSucking or _genv._TL_stopSucking
    _qb.stopSuckIt      = _TL_refs._TL_stopSuckIt or _genv._TL_stopSuckIt
    _qb.stopBackshots   = _TL_refs._TL_stopBackshots or _genv._TL_stopBackshots
    _qb.stopDoggy       = _TL_refs._TL_stopDoggy or _genv._TL_stopDoggy
    _qb.stopLayFuck     = _TL_refs._TL_stopLayFuck or _genv._TL_stopLayFuck
    _qb.stopFacefuck    = _TL_refs._TL_stopFacefuck or _genv._TL_stopFacefuck
    _qb.stopPussySpread = _TL_refs._TL_stopPussySpread or _genv._TL_stopPussySpread
    _qb.stopHug         = _TL_refs._TL_stopHug or _genv._TL_stopHug
    _qb.stopHug2        = _TL_refs._TL_stopHug2 or _genv._TL_stopHug2
    _qb.stopCarry       = _TL_refs._TL_stopCarry or _genv._TL_stopCarry
    _qb.stopShoulderSit = _TL_refs._TL_stopShoulderSit or _genv._TL_stopShoulderSit
    _qb.act_following   = false
    _qb.ppActive        = false
    _qb.QA_W            = _qb.FW_W
    _qb.QA_PAD          = 10
    _qb.QA_COLS         = 3
    _qb.QA_GAP          = 5
    _qb.QA_INSET        = 3
    _qb.QA_CW           = math.floor((_qb.QA_W - _qb.QA_PAD * 2 - _qb.QA_GAP * 2 - _qb.QA_INSET * 2) / _qb.QA_COLS)
    _qb.QA_CH           = 68
    _qb.HDR_H           = 38
    _qb.SEC_H           = 20
    _qb.FOOT_H          = 30
    _qb.SCROLL_MAX      = 320
    _qb._panelColorHooks = deps._panelColorHooks or {}
    _qb._makeRealStroke  = deps._makeRealStroke or function(p, t, c, a)
        local s = Instance.new("UIStroke", p)
        s.Thickness = t or 1
        s.Color = c or Color3.new(1, 1, 1)
        s.Transparency = a or 0
        return s
    end
    _qb._tlAlive         = deps._tlAlive or function() return true end
    _qb.twP              = deps.twP or function(obj, t, props)
        if _qb.tw then
            local tw = _qb.tw(obj, t, props)
            if tw then tw:Play() end
        end
    end
    _qb.getNearestPlayer = deps.getNearestPlayer or function() return nil end
    _qb._handleError     = deps._handleError or function(msg) warn("[QABar] " .. tostring(msg)) end
    _qb.stopStand        = deps.stopStand or function() end
    _qb.standStopAnim    = deps.standStopAnim or function() end
    _qb.closeBar         = deps.closeBar or function() end
    _qb.LocalPlayer      = deps.LocalPlayer or (game and game:GetService("Players").LocalPlayer)
    _qb.RunService       = deps.RunService or (game and game:GetService("RunService"))
    _qb._SvcUIS          = deps._SvcUIS or (game and game:GetService("UserInputService"))
    _qb._TL_VP           = deps._TL_VP or { mobScl = 1 }
    _qb._sc              = deps._sc or {}
    _qb._AF              = deps._AF or _qb.AF
    _qb.stopQA74         = deps.stopQA74 or function() end
    _qb._registerResetFn = deps.registerResetFn or function() end
    _qb.tlArrow    = _qb.tlArrow or _qb.g._TL_tlArrow
    _qb.tlArrowBig = _qb.tlArrowBig or _qb.g._TL_tlArrowBig
end

local QA_CATS = {{
    label = "Freaky",
    col = Color3.fromRGB(255, 80, 160),
    actions = {
        { key = "licking",     label = "Licking",      imageId = "rbxassetid://72579312094126" },
        { key = "kiss",        label = "Kiss",         imageId = "rbxassetid://86857269527024" },
        { key = "sucking",     label = "Sucking 2",    imageId = "rbxassetid://72579312094126" },
        { key = "suck_it",     label = "Suck It",      imageId = "rbxassetid://72579312094126" },
        { key = "layfuck",     label = "Lay Fuck",     imageId = "rbxassetid://72579312094126" },
        { key = "backshots",   label = "Backshots",    imageId = "rbxassetid://112450246602990" },
        { key = "doggy",       label = "Doggy",        imageId = "rbxassetid://72579312094126" },
        { key = "pussyspread", label = "Pussy Spread", imageId = "rbxassetid://72579312094126" },
    }
}, {
    label = "1X Action",
    col = Color3.fromRGB(180, 80, 255),
    actions = {
        { key = "headbutt",     label = "Headbutt",     imageId = "rbxassetid://81011129131522" },
        { key = "1x_kiss",      label = "Kiss",         imageId = "rbxassetid://110391423694838" },
        { key = "1x_slap",      label = "Slap",         imageId = "rbxassetid://110482161478246" },
        { key = "1x_hug",       label = "Hug",          imageId = "rbxassetid://78323512869606" },
        { key = "jumpscare_vr", label = "Jumpscare VR", imageId = "rbxassetid://102559848050770" },
    }
}, {
    label = "Annoying",
    col = Color3.fromRGB(55, 195, 255),
    actions = {
        { key = "orbit",      label = "Orbit TP",    imageId = "rbxassetid://139840976938907" },
        { key = "spinning",   label = "Spinning",    imageId = "rbxassetid://113740413795794" },
        { key = "upsidedown", label = "Upside Down", imageId = "rbxassetid://89009236995193" },
        { key = "crossud",    label = "Cross UD",    imageId = "rbxassetid://77458828386203" },
        { key = "ghost",      label = "Ghost",       imageId = "rbxassetid://77104113506431" },
    }
}, {
    label = "Roleplay",
    col = Color3.fromRGB(255, 175, 55),
    actions = {
        { key = "soh",           label = "On Head",           imageId = "rbxassetid://86857269527024" },
        { key = "piggyback",     label = "Piggyback",         imageId = "rbxassetid://119518980113353" },
        { key = "piggyback2",    label = "Piggyback2",        imageId = "rbxassetid://119518980113353" },
        { key = "backpack",      label = "Backpack",          imageId = "rbxassetid://135716031985311" },
        { key = "friend",        label = "Friend",            imageId = "rbxassetid://79735988088948" },
        { key = "hug",           label = "Hug",               imageId = "rbxassetid://86857269527024" },
        { key = "hug2",          label = "Hug 2",             imageId = "rbxassetid://86857269527024" },
        { key = "carry",         label = "Carry",             imageId = "rbxassetid://86857269527024" },
        { key = "carryshoulder", label = "Carry on shoulder", imageId = "rbxassetid://86857269527024" },
        { key = "shouldersit",   label = "Shouldersit",       imageId = "rbxassetid://86857269527024" },
        { key = "stand",         label = "Stand",             imageId = "rbxassetid://86857269527024" },
        { key = "headstand",     label = "Head Stand",        imageId = "rbxassetid://86857269527024" },
    }
}}

local QA_ACTIONS = {}
for _, cat in ipairs(QA_CATS) do
    for _, a in ipairs(cat.actions) do
        a.catCol = cat.col
        QA_ACTIONS[#QA_ACTIONS + 1] = a
    end
end

local QA_CARD_STROKE = Color3.new(1, 1, 1)
local function _qaSetCardStroke(st, alpha, thick)
    if not st then return end
    st.Enabled = true
    st.Color = QA_CARD_STROKE
    st.Transparency = alpha or 0.65
    st.Thickness = thick or 1.2
end

local function _qaWaitForCharacterReady(player, timeoutSec)
    if not player then return nil end
    local deadline = tick() + (timeoutSec or 4)
    local char = player.Character
    while tick() < deadline do
        char = player.Character
        if char and char.Parent and char:FindFirstChild("HumanoidRootPart") then
            return char
        end
        task.wait(0.05)
    end
    return char
end

local _qaToBB = {
    licking = "bb_licking", kiss = "bb_kiss", sucking = "bb_sucking",
    suck_it = "bb_suck_it", layfuck = "bb_layfuck", backshots = "bb_backshots",
    doggy = "bb_doggy", pussyspread = "bb_pussyspread",
    soh = "bb_soh", piggyback = "bb_piggyback", piggyback2 = "bb_piggyback2",
    backpack = "bb_backpack", friend = "bb_friend",
    hug = "bb_hug", hug2 = "bb_hug2", carry = "bb_carry",
    carryshoulder = "bb_carryshoulder", shouldersit = "bb_shouldersit",
    stand = "bb_stand", headstand = "bb_headstand",
}

local function mkF(parent, sz, pos, col, alpha, r)
    local f = Instance.new("Frame")
    f.Size = sz; f.Position = pos; f.BackgroundColor3 = col
    f.BackgroundTransparency = alpha; f.BorderSizePixel = 0
    if r then
        local c = Instance.new("UICorner", f); c.CornerRadius = UDim.new(0, r)
    end
    f.Parent = parent
    return f
end

local function mkTxt(parent, sz, pos, text, font, tsz, col, xAlign)
    local l = Instance.new("TextLabel")
    l.Size = sz; l.Position = pos; l.BackgroundTransparency = 1; l.Text = text
    l.Font = font; l.TextSize = tsz; l.TextColor3 = col
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent
    return l
end

local function mkStroke(parent, thick, col, alpha)
    local s = _qb._makeRealStroke(parent, thick, col, alpha)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end


local _q = {}
_q.statusDot = nil
_q.statusTxt = nil


local _connections = {}
local _tasks        = {}

local function _conn(c)
    if c then _connections[#_connections + 1] = c end
    return c
end

_qb.qaStopNoSit = function(keepRespawn)
    if _qb.qaNoSitConn then
        pcall(function() _qb.qaNoSitConn:Disconnect() end)
        _qb.qaNoSitConn = nil
    end
    if not keepRespawn and _qb.qaRespawnConn then
        pcall(function() _qb.qaRespawnConn:Disconnect() end)
        _qb.qaRespawnConn = nil
    end
    if _qb.qaDiedConn then
        pcall(function() _qb.qaDiedConn:Disconnect() end)
        _qb.qaDiedConn = nil
    end
    if _qb.qaNoSitSeatedConn then
        pcall(function() _qb.qaNoSitSeatedConn:Disconnect() end)
        _qb.qaNoSitSeatedConn = nil
    end
    pcall(function()
        local LocalPlayer = _qb.LocalPlayer
        local hum = LocalPlayer.Character and
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local restoreDead = _qb.qaDeadRestore
            if restoreDead == nil then restoreDead = true end
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, restoreDead)
        end
        _qb.qaDeadRestore = nil
    end)
    _qb.AF.onStopAction()
end

_qb.qaStartNoSit = function()
    _qb.qaStopNoSit()
    _qb.AF.onStartAction()
    local LocalPlayer = _qb.LocalPlayer
    local RunService  = _qb.RunService
    local _nsChar       = nil
    local _nsHum        = nil
    local _qaLastSafeCF = nil
    local _QA_VOID_Y    = -200
    local _QA_RESCUE_Y  = 8
    local function lockNoSit(hum)
        if not hum then return end
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)
        if hum.Sit then hum.Sit = false end
        if hum.SeatPart or hum:GetState() == Enum.HumanoidStateType.Seated then
            pcall(function() hum.Sit = false end)
            pcall(function() hum.Jump = true end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
        end
    end
    local function lockNoDeath(char, hum)
        if not char or not hum then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
        if hum.MaxHealth > 0 and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
        if not root then return end
        if root.Position.Y > _QA_VOID_Y then
            _qaLastSafeCF = root.CFrame
            return
        end
        local rescueCF = nil
        local target = _qb.qaActiveTarget
        local targetChar = target and target.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            rescueCF = targetRoot.CFrame * CFrame.new(0, _QA_RESCUE_Y, 0)
        elseif _qaLastSafeCF then
            rescueCF = _qaLastSafeCF * CFrame.new(0, _QA_RESCUE_Y, 0)
        else
            rescueCF = CFrame.new(root.Position.X, _QA_RESCUE_Y, root.Position.Z)
        end
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = rescueCF
            hum.Sit = false
            hum.Health = hum.MaxHealth
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end)
    end
    _conn(RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        if char ~= _nsChar then
            _nsChar           = char
            _nsHum            = char:FindFirstChildOfClass("Humanoid")
            _qb.qaDeadRestore = nil
            if _nsHum then
                pcall(function() _nsHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
                pcall(function() _qb.qaDeadRestore = _nsHum:GetStateEnabled(Enum.HumanoidStateType.Dead) end)

                if _qb.qaDiedConn then pcall(function() _qb.qaDiedConn:Disconnect() end) end
                _qb.qaDiedConn = _nsHum.Died:Connect(function()
                    if _qb.qaActiveKey and _qb.qaActiveTarget then
                        _qb.stopQAAction(true)
                    end
                end)
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then _qaLastSafeCF = root.CFrame end
            if _qb.qaNoSitSeatedConn then
                pcall(function() _qb.qaNoSitSeatedConn:Disconnect() end)
                _qb.qaNoSitSeatedConn = nil
            end
            if _nsHum then
                lockNoSit(_nsHum)
                lockNoDeath(char, _nsHum)
                _qb.qaNoSitSeatedConn = _nsHum.Seated:Connect(function(active)
                    if active then lockNoSit(_nsHum) end
                end)
            end
        end
        lockNoSit(_nsHum)
        lockNoDeath(char, _nsHum)
    end))

    if _qb.qaRespawnConn then pcall(function() _qb.qaRespawnConn:Disconnect() end) end
    _qb.qaRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        if _qb.qaActiveKey and _qb.qaActiveTarget then
            local _k = _qb.qaActiveKey
            local _t = _qb.qaActiveTarget
            task.spawn(function()
                _qb.activateQAAction(_k, _t)
            end)
        end
    end)
end

_qb.stopQAAction = function(keepRespawn)
    pcall(function()
        local LocalPlayer = _qb.LocalPlayer
        local myChar = LocalPlayer.Character
        local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end
    end)
    _qb.qaStopNoSit(keepRespawn)
    if not keepRespawn then
        _qb.qaActiveKey = nil; _qb.qaActiveTarget = nil
        if _qb.qaTargetRespawnConn then
            pcall(function() _qb.qaTargetRespawnConn:Disconnect() end)
            _qb.qaTargetRespawnConn = nil
        end
        if _qb.qaTargetWatchConn then
            pcall(function() _qb.qaTargetWatchConn:Disconnect() end)
            _qb.qaTargetWatchConn = nil
        end
    end
    pcall(function()
        local _af = _qb.AF or {}
        if _qb.act_following then
            _qb.act_stopFollow(); _qb.act_following = false
        end
        if _qb.SOH and _qb.SOH.active then
            _qb.stopSitOnHead(); _qb.SOH.active = false
        end
        if _qb.ppActive then
            _qb.stopPiggyback(); _qb.ppActive = false
        end
        if _af.pp2Active then
            _qb.stopPiggyback2(); _af.pp2Active = false
        end
        if _af.kissActive then
            _qb.stopKiss(); _af.kissActive = false
        end
        if _af.backpackActive then
            _qb.stopBackpack(); _af.backpackActive = false
        end
        if _af.orbitActive then
            _qb.stopOrbit(); _af.orbitActive = false
        end
        if _af.upsideDownActive then
            _qb.stopUpsideDown(); _af.upsideDownActive = false
        end
        if _af.crossUDActive then
            _qb.stopCrossUD(); _af.crossUDActive = false
        end
        if _af.friendActive then
            _qb.stopFriend(); _af.friendActive = false
        end
        if _af.spinningActive then
            _qb.stopSpinning(); _af.spinningActive = false
        end
        if _af.lickingActive then
            _qb.stopLicking(); _af.lickingActive = false
        end
        if _af.suckingActive then
            _qb.stopSucking(); _af.suckingActive = false
        end
        if _af.suckItActive then
            _qb.stopSuckIt(); _af.suckItActive = false
        end
        if _af.backshotsActive then
            _qb.stopBackshots(); _af.backshotsActive = false
        end
        if _af.doggyActive then
            _qb.stopDoggy(); _af.doggyActive = false
        end
        if _af.layFuckActive then
            _qb.stopLayFuck(); _af.layFuckActive = false
        end
        if _af.facefuckActive then
            _qb.stopFacefuck(); _af.facefuckActive = false
        end
        if _af.pussySpreadActive then
            _qb.stopPussySpread(); _af.pussySpreadActive = false
        end
        if _af.hugActive then
            _qb.stopHug(); _af.hugActive = false
        end
        if _af.hug2Active then
            _qb.stopHug2(); _af.hug2Active = false
        end
        if _af.carryActive then
            _qb.stopCarry(); _af.carryActive = false
        end
        if _af.shoulderSitActive then
            _qb.stopShoulderSit(); _af.shoulderSitActive = false
        end
        if _af.standActive then
            pcall(_qb.stopStand); _af.standActive = false
        end
        if _af.bbActive then
            _qb.stopBB()
            if type(_qb.standStopAnim) == "function" then _qb.standStopAnim() end
            _af.bbActive = false
        end
        if _af.ghostActive then
            _qb.stopGhost(); _af.ghostActive = false
        end
        if _af.qa74Active then
            pcall(_qb.stopQA74); _af.qa74Active = false
        end
        pcall(_qb.safeStand)
    end)
end

local function _qaBindTargetRespawn()
    if _qb.qaTargetRespawnConn then
        pcall(function() _qb.qaTargetRespawnConn:Disconnect() end)
        _qb.qaTargetRespawnConn = nil
    end
    if _qb.qaTargetWatchConn then
        pcall(function() _qb.qaTargetWatchConn:Disconnect() end)
        _qb.qaTargetWatchConn = nil
    end

    local target = _qb.qaActiveTarget
    if not target then return end
    local lastChar = target.Character
    local lastRoot = lastChar and lastChar:FindFirstChild("HumanoidRootPart")
    local rebinding = false
    local lastDetachFix = 0
    local detachDistance = _qb.qaAttachDetachDistance or 28

    local function rebindSameTarget()
        if rebinding then return end
        local key = _qb.qaActiveKey
        if not key or _qb.qaActiveTarget ~= target then return end
        rebinding = true
        task.spawn(function()
            _qaWaitForCharacterReady(target, 5)
            if _qb.qaActiveKey ~= key or _qb.qaActiveTarget ~= target then
                rebinding = false
                return
            end

            _qb.stopQAAction(true)
            _qb.qaActiveKey = key
            _qb.qaActiveTarget = target
            _qb.qaStartNoSit()

            task.wait(0.08)
            if _qb.qaActiveKey ~= key or _qb.qaActiveTarget ~= target then
                rebinding = false
                return
            end

            local _rbKey = _qaToBB[key] or key
            if _rbKey:sub(1, 3) == "bb_" and type(_qb.startBB) == "function" then
                pcall(function() _qb.startBB(target, _rbKey) end)
            elseif type(_qb.qaDispatch) == "function" then
                pcall(function() _qb.qaDispatch(key, target) end)
            end

            lastChar = target.Character
            lastRoot = lastChar and lastChar:FindFirstChild("HumanoidRootPart")
            task.wait(0.4)
            rebinding = false
        end)
    end

    _qb.qaTargetRespawnConn = target.CharacterAdded:Connect(function()
        rebindSameTarget()
    end)

    local lastCheck = 0
    local LocalPlayer = _qb.LocalPlayer
    local RunService  = _qb.RunService
    _qb.qaTargetWatchConn = RunService.Heartbeat:Connect(function()
        if tick() - lastCheck < 0.25 then return end
        lastCheck = tick()
        if not _qb.qaActiveKey or _qb.qaActiveTarget ~= target then return end

        local char = target.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and root and (char ~= lastChar or root ~= lastRoot) then
            lastChar = char
            lastRoot = root
            rebindSameTarget()
        end
        if root then
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot and (myRoot.Position - root.Position).Magnitude > detachDistance and tick() - lastDetachFix > 0.65 then
                lastDetachFix = tick()
                pcall(function()
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero
                    myRoot.CFrame = root.CFrame * CFrame.new(0, 2.25, 2.25)
                end)
                rebindSameTarget()
            end
        end
    end)
end

_qb.activateQAAction = function(key, forcedTarget)
    local target = forcedTarget or _qb.getNearestPlayer()
    if not target then
        _qb.sendNotif("QuickActions", "No player nearby!", 2)
        return false
    end

    _qb.stopQAAction()
    _qb.qaActiveKey = key
    _qb.qaActiveTarget = target
    _qb.qaStartNoSit()
    _qaBindTargetRespawn()

    local _capturedKey    = key
    local _capturedTarget = target

    task.spawn(function()
        task.wait(0.05)
        if _qb.qaActiveKey ~= _capturedKey then return end

        local bbKey = _qaToBB[_capturedKey] or _capturedKey

        local ok, err = xpcall(function()
            if bbKey:sub(1, 3) == "bb_" and type(_qb.startBB) == "function" then
                _qb.startBB(_capturedTarget, bbKey)
            elseif type(_qb.qaDispatch) == "function" then
                _qb.qaDispatch(_capturedKey, _capturedTarget)
            else
                warn("[QA] No dispatcher available for key: " .. tostring(_capturedKey) ..
                    " (bbKey: " .. tostring(bbKey) ..
                    ", startBB type: " .. type(_qb.startBB) ..
                    ", qaDispatch type: " .. type(_qb.qaDispatch) .. ")")
            end
        end, function(e)
            warn("[QA] Runtime Error in activateQAAction callback:", tostring(e))
            warn(debug.traceback())
        end)
    end)
    return true
end

_qb.resetAllCards = function()
    local twP = _qb.twP
    for _, r in ipairs(_qb.qaCardRefs) do
        pcall(function()
            twP(r.bg, .12, { BackgroundColor3 = P.card, BackgroundTransparency = 0 })
            twP(r.lbl, .12, { TextColor3 = P.lblOff })
            twP(r.bar, .12, { BackgroundTransparency = 1 })
            _qaSetCardStroke(r.stroke, 0.65, 1.2)
        end)
    end
end

function M.startQABar()
    if _qaStarted then return end
    if not _qaInitialized then
        warn("[QABar] Must call initQABar(deps) before startQABar()")
        return
    end
    _qaStarted = true

    local LocalPlayer = _qb.LocalPlayer
    local RunService  = _qb.RunService
    local _TL_refs    = _qb.g
    local _TL_VP      = _qb._TL_VP
    local _SvcUIS     = _qb._SvcUIS

    _qb.qaBarOpen         = false
    _qb.qaActiveKey       = nil
    _qb.qaActiveTarget    = nil
    _qb.qaCardRefs        = {}
    _qb.qaNoSitConn       = nil
    _qb.qaNoSitSeatedConn = nil
    _qb.qaDeadRestore     = nil
    _qb.qaGlobalLock      = false
    _qb.qaTargetRespawnConn = nil
    _qb.qaTargetWatchConn = nil
    _qb.qaAttachDetachDistance = 28

    task.spawn(function()
        local _ok_QABar, _err_QABar = xpcall(function()
            local _vp    = workspace.CurrentCamera.ViewportSize
            local _touch = pcall(function() return _SvcUIS.TouchEnabled end) and _SvcUIS.TouchEnabled
            local _kbd   = pcall(function() return _SvcUIS.KeyboardEnabled end) and _SvcUIS.KeyboardEnabled
            local _short = math.min(_vp.X, _vp.Y)
            local _isMob = _touch and not _kbd and _short < 500
            local _isTab = _touch and not _kbd and _short >= 500

            local _QA_RIGHT_OFFSET = -5
            local _VL_ICON_H = _TL_refs._TL_VL_ICON_H or 58
            local _QA_TOP_Y = 5 + _VL_ICON_H + 4
            _qb.qaBar = mkF(_qb.ScreenGui,
                UDim2.new(0, _qb.QA_W, 0, 0),
                UDim2.new(1, _QA_RIGHT_OFFSET, 0, _QA_TOP_Y),
                P.panel, 0, 8)
            local qaBar = _qb.qaBar
            qaBar.Name = "TLQuickActionsBar"
            qaBar.AnchorPoint = Vector2.new(1, 0)
            qaBar.ClipsDescendants = true
            qaBar.Visible = false; qaBar.ZIndex = 9

            pcall(function() if getgenv then _qb.env._TL_qaBar = qaBar end end)
            pcall(function() _TL_refs._TL_qaBar = qaBar end)
            _qb._qaBarStroke = mkStroke(_qb.qaBar, 1, P.panelBrd, 0.7)

            if _isMob or _isTab then
                local _qaScale    = Instance.new("UIScale", qaBar)
                _qaScale.Scale    = _TL_VP.mobScl
                qaBar.AnchorPoint = Vector2.new(1, 0)
                qaBar.Position    = UDim2.new(1, _QA_RIGHT_OFFSET, 0, _QA_TOP_Y)
            end

            local HDR_H = _qb.HDR_H
            _qb.hdr = mkF(_qb.qaBar, UDim2.new(1, 0, 0, HDR_H),
                UDim2.new(0, 0, 0, 0), P.hdr, 0, 14)
            local hdr = _qb.hdr
            hdr.ZIndex = 10
            mkF(hdr, UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 1, -14), P.hdr, 0, 0)
            mkF(qaBar, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, HDR_H), P.hdrBrd, 0.75, 0).ZIndex = 9
            local icoBox = mkF(hdr,
                UDim2.new(0, 22, 0, 22), UDim2.new(0, 8, 0.5, -11), P.icoBox, 1, 4)
            local icoLbl = Instance.new("ImageLabel", icoBox)
            icoLbl.Size = UDim2.new(1, 0, 1, 0)
            icoLbl.Position = UDim2.new(0, 0, 0, 0)
            icoLbl.BackgroundTransparency = 1
            icoLbl.Image = "rbxassetid://77458828386203"
            icoLbl.ImageColor3 = Color3.new(1, 1, 1)
            icoLbl.ScaleType = Enum.ScaleType.Fit
            icoLbl.ZIndex = 12
            _qb.titleLbl = mkTxt(hdr,
                UDim2.new(0, 125, 0, 18), UDim2.new(0, 32, 0.5, -9),
                "Quick Actions", Enum.Font.GothamBlack, 13, Color3.new(1, 1, 1))
            _qb.titleLbl.ZIndex = 12; _qb.titleLbl.TextXAlignment = Enum.TextXAlignment.Left

            _qb.tgtBadge = mkF(hdr,
                UDim2.new(0, 90, 0, 18), UDim2.new(1, -98, 0.5, -9), P.tgtBg, 0.1, 20)
            local tgtBadge = _qb.tgtBadge
            _qb._tgtBadgeStroke = mkStroke(tgtBadge, 1.5, (_qb.C and _qb.C.accent2), 0); tgtBadge.ZIndex = 11
            local tgtDot = mkF(tgtBadge,
                UDim2.new(0, 5, 0, 5), UDim2.new(0, 6, 0.5, -2), P.tgtDot, 0, 99)
            tgtDot.ZIndex = 13
            _qb.tgtNameLbl = mkTxt(
                tgtBadge, UDim2.new(1, -16, 1, 0), UDim2.new(0, 14, 0, 0),
                "◈", Enum.Font.GothamBold, 9, Color3.new(1, 1, 1), Enum.TextXAlignment.Left)
            local tgtNameLbl = _qb.tgtNameLbl
            tgtNameLbl.ZIndex = 12

            task.spawn(function()
                local _tdTw = nil
                while qaBar and qaBar.Parent and _qb._tlAlive() do
                    if qaBar.Visible then
                        if _tdTw then pcall(_tdTw.Cancel, _tdTw) end
                        if type(_qb.tw) ~= "function" then task.wait(1.7); continue end
                        _tdTw = _qb.tw(tgtDot, 0.8, { BackgroundTransparency = 0.6 }); if _tdTw then _tdTw:Play() end
                        task.wait(1.7)
                        if _tdTw then pcall(_tdTw.Cancel, _tdTw) end
                        _tdTw = _qb.tw(tgtDot, 0.8, { BackgroundTransparency = 0 }); if _tdTw then _tdTw:Play() end
                        task.wait(1.7)
                    else
                        task.wait(0.5)
                    end
                end
            end)

            local QA_W     = _qb.QA_W
            local QA_PAD   = _qb.QA_PAD
            local BODY_TOP = HDR_H + 1
            local INNER_W  = QA_W - QA_PAD * 2
            local FOOT_H   = _qb.FOOT_H
            local SCROLL_MAX = _qb.SCROLL_MAX
            local SEC_H    = _qb.SEC_H
            local QA_COLS  = _qb.QA_COLS
            local QA_CW    = _qb.QA_CW
            local QA_GAP   = _qb.QA_GAP
            local QA_INSET = _qb.QA_INSET or 0
            local QA_CH    = _qb.QA_CH
            _qb.qaScroll = Instance.new("ScrollingFrame", _qb.qaBar)
            local qaScroll = _qb.qaScroll
            qaScroll.Position = UDim2.new(0, QA_PAD, 0, BODY_TOP + QA_PAD)
            qaScroll.BackgroundTransparency = 1; qaScroll.BorderSizePixel = 0
            qaScroll.ScrollBarThickness = 3; qaScroll.ScrollBarImageColor3 = P.panelBrd
            qaScroll.ScrollBarImageTransparency = 0.5
            qaScroll.ScrollingDirection = Enum.ScrollingDirection.Y
            qaScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            qaScroll.ElasticBehavior = Enum.ElasticBehavior.Never
            qaScroll.ClipsDescendants = true; qaScroll.ZIndex = 10

            _qb._footStroke    = nil
            _qb._stopBtnStroke = nil

            _qb._panelColorHooks[#_qb._panelColorHooks + 1] = function(_newT)
                pcall(function() _qb.qaScroll.ScrollBarImageColor3 = P.panelBrd end)
                pcall(function() if _qb._qaBarStroke then _qb._qaBarStroke.Color = P.panelBrd end end)
                pcall(function() if _qb._tgtBadgeStroke then _qb._tgtBadgeStroke.Color = (_qb.C and _qb.C.accent2) end end)
                pcall(function() if _qb._footStroke then _qb._footStroke.Color = P.footBrd end end)
                pcall(function() if _qb._stopBtnStroke then _qb._stopBtnStroke.Color = P.stopBrd end end)
                pcall(function() if tgtDot then tgtDot.BackgroundColor3 = P.tgtDot end end)
                for _, r in ipairs(_qb.qaCardRefs) do
                    pcall(function()
                        if _qb.qaActiveKey == r.key then
                            _qaSetCardStroke(r.stroke, 0.08, 1.8)
                        else
                            _qaSetCardStroke(r.stroke, 0.65, 1.2)
                        end
                    end)
                end
            end

            local curY = 0
            local _qaLastGlobalClick = 0
            local _qaCardLastClick = {}
            local _QA_GLOBAL_COOLDOWN = 0.35
            local _QA_CARD_COOLDOWN = 0.7
            local _isMobile = _isMob or _isTab
            local twP = _qb.twP

            for _, cat in ipairs(QA_CATS) do
                if curY > 0 then curY = curY + 4 end
                local secRow = mkF(qaScroll, UDim2.new(0, INNER_W, 0, _qb.SEC_H),
                    UDim2.new(0, 0, 0, curY), P.panel, 1, 0)
                secRow.ZIndex = 11
                local secBar = mkF(secRow, UDim2.new(0, 4, 0, 14), UDim2.new(0, 0, 0.5, -7), cat.col, 0, 99)
                secBar.ZIndex = 12
                local secName = mkTxt(secRow, UDim2.new(1, -36, 1, 0), UDim2.new(0, 14, 0, 0),
                    cat.label:upper(), Enum.Font.GothamBlack, 10, cat.col)
                secName.ZIndex = 12; secName.TextXAlignment = Enum.TextXAlignment.Left
                local badge = mkF(secRow, UDim2.new(0, 24, 0, 14), UDim2.new(1, -26, 0.5, -7), cat.col, 0.82, 99)
                badge.ZIndex = 12
                local badgeTxt = mkTxt(badge, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0),
                    tostring(#cat.actions), Enum.Font.GothamBlack, 10, cat.col, Enum.TextXAlignment.Center)
                badgeTxt.ZIndex = 13
                curY = curY + _qb.SEC_H + 5
                local rowStartY = curY
                for ci, act in ipairs(cat.actions) do
                    local col_i = (ci - 1) % _qb.QA_COLS
                    local row_i = math.floor((ci - 1) / _qb.QA_COLS)
                    local xPos  = QA_INSET + col_i * (_qb.QA_CW + _qb.QA_GAP)
                    local yPos  = rowStartY + row_i * (_qb.QA_CH + _qb.QA_GAP)
                    local bg    = mkF(qaScroll, UDim2.new(0, _qb.QA_CW, 0, _qb.QA_CH),
                        UDim2.new(0, xPos, 0, yPos), P.card, 0, 8)
                    bg.ZIndex = 11
                    local stroke = mkStroke(bg, 1.2, Color3.new(1, 1, 1), 0.65)
                    _qaSetCardStroke(stroke, 0.65, 1.2)
                    local bar = mkF(bg, UDim2.new(0, _qb.QA_CW - 12, 0, 2),
                        UDim2.new(0, 6, 1, -2), cat.col, 1, 99)
                    bar.ZIndex = 13
                    local icoL
                    if act.imageId then
                        icoL = Instance.new("ImageLabel", bg)
                        icoL.Size = UDim2.new(0, 30, 0, 30); icoL.Position = UDim2.new(0.5, -15, 0, 8)
                        icoL.BackgroundTransparency = 1; icoL.Image = act.imageId
                        icoL.ImageColor3 = Color3.new(1, 1, 1); icoL.ImageTransparency = 0
                        icoL.ScaleType = Enum.ScaleType.Fit; icoL.ZIndex = 12
                    else
                        icoL = mkTxt(bg, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 8),
                            act.icon, Enum.Font.GothamBold, 20, Color3.new(1, 1, 1),
                            Enum.TextXAlignment.Center)
                        icoL.ZIndex = 12
                    end
                    local lbl = mkTxt(bg, UDim2.new(1, -2, 0, 12), UDim2.new(0, 1, 1, -14),
                        act.label, Enum.Font.GothamBlack, 11, P.lblOff, Enum.TextXAlignment.Center)
                    lbl.ZIndex = 12
                    local btn = Instance.new("TextButton", bg)
                    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1
                    btn.Text = ""; btn.ZIndex = 15; btn.Active = true
                    local ci2 = #_qb.qaCardRefs + 1
                    _qb.qaCardRefs[ci2] = { bg = bg, lbl = lbl, bar = bar, stroke = stroke, key = act.key, col = cat.col }
                    btn.MouseEnter:Connect(function()
                        if _isMobile then return end
                        pcall(function() if type(_qb._sc._playHoverSound) == "function" then _qb._sc._playHoverSound() end end)
                        if _qb.qaActiveKey == act.key then return end
                        twP(bg, .1, { BackgroundColor3 = P.cardHov })
                        _qaSetCardStroke(stroke, 0.3, 1.2)
                    end)
                    btn.MouseLeave:Connect(function()
                        if _qb.qaActiveKey == act.key then return end
                        twP(bg, .1, { BackgroundColor3 = P.card })
                        _qaSetCardStroke(stroke, 0.65, 1.2)
                    end)
                    local function qaCardActivate()
                        local ok, err = xpcall(function()
                            local now = tick()
                            if now - _qaLastGlobalClick < _QA_GLOBAL_COOLDOWN then return end
                            local lastClick = _qaCardLastClick[act.key] or 0
                            if now - lastClick < _QA_CARD_COOLDOWN then return end
                            _qaLastGlobalClick = now
                            _qaCardLastClick[act.key] = now
                            local wasActive = (_qb.qaActiveKey == act.key)
                            _qb.resetAllCards()
                            if wasActive then
                                _qb.stopQAAction()
                                if _q.statusTxt then
                                    _q.statusTxt.Text = "Stopped"; _q.statusTxt.TextColor3 = P.tgtTxt
                                end
                                if _q.statusDot then _q.statusDot.BackgroundColor3 = P.tgtTxt end
                            else
                                local ok = _qb.activateQAAction(act.key)
                                if ok ~= false then
                                    pcall(function() if P.cardHov then twP(bg, .12, { BackgroundColor3 = P.cardHov }) end end)
                                    pcall(function() if P.lblOn then twP(lbl, .12, { TextColor3 = P.lblOn }) end end)
                                    pcall(function() twP(bar, .12, { BackgroundTransparency = 0 }) end)
                                    _qaSetCardStroke(stroke, 0.08, 1.8)
                                    task.spawn(function()
                                        task.wait(0.2); pcall(function()
                                            local tgt = _qb.qaActiveTarget
                                            if _q.statusTxt then
                                                _q.statusTxt.Text = act.label ..
                                                    (tgt and (" → " .. tgt.Name) or "")
                                                _q.statusTxt.TextColor3 = cat.col
                                            end
                                            if _q.statusDot then _q.statusDot.BackgroundColor3 = cat.col end
                                        end)
                                    end)
                                else
                                    if _q.statusTxt then
                                        _q.statusTxt.Text = "◈ No Target"; _q.statusTxt.TextColor3 = P.stopTxt
                                    end
                                    if _q.statusDot then _q.statusDot.BackgroundColor3 = P.stopTxt end
                                end
                            end
                        end, function(e)
                            warn("[QA] Error in qaCardActivate for " ..
                                tostring(act.key) .. ": " .. tostring(e))
                            warn(debug.traceback())
                        end)
                    end
                    btn.MouseButton1Click:Connect(qaCardActivate)
                    btn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                            qaCardActivate()
                        end
                    end)
                    if act.key == "sucking" then
                        local function qaSuckPause()
                            if _qb.qaActiveKey == "sucking" and _qb._AF and _qb._AF.suckingActive then
                                pcall(function() if _G._TLSuckingTrack then _G._TLSuckingTrack:AdjustSpeed(0) end end)
                            end
                        end
                        local function qaSuckResume()
                            if _qb.qaActiveKey == "sucking" and _qb._AF and _qb._AF.suckingActive then
                                pcall(function() if _G._TLSuckingTrack then _G._TLSuckingTrack:AdjustSpeed(1) end end)
                            end
                        end
                        btn.MouseButton1Down:Connect(qaSuckPause)
                        btn.MouseButton1Up:Connect(qaSuckResume)
                        btn.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then qaSuckPause() end
                        end)
                        btn.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then qaSuckResume() end
                        end)
                    end
                end
                local rows = math.ceil(#cat.actions / QA_COLS)
                curY = rowStartY + rows * (QA_CH + QA_GAP) + 6
            end

            task.spawn(function()
                while _qb.qaBar and _qb.qaBar.Parent and _qb._tlAlive() do
                    pcall(function()
                        for _, r in ipairs(_qb.qaCardRefs) do
                            if r.key and (r.key:find("bb_") or r.key:find("bytebreaker")) then
                                if _qb.qaActiveKey == r.key then continue end
                                pcall(function()
                                    if r.bg and r.bg.Parent then
                                        r.bg.BackgroundColor3 = P.card
                                        r.bg.BackgroundTransparency = 0
                                    end
                                    if r.lbl and r.lbl.Parent then
                                        r.lbl.TextColor3 = P.lblOff
                                    end
                                    if r.bar and r.bar.Parent then
                                        r.bar.BackgroundTransparency = 1
                                    end
                                    if r.stroke and r.stroke.Parent then
                                        _qaSetCardStroke(r.stroke, 0.65, 1.2)
                                    end
                                end)
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)

            local TOTAL_H  = curY
            local SCROLL_H = math.min(TOTAL_H, SCROLL_MAX)
            qaScroll.Size       = UDim2.new(0, INNER_W, 0, SCROLL_H)
            qaScroll.CanvasSize = UDim2.new(0, 0, 0, TOTAL_H)
            local FOOT_Y = BODY_TOP + QA_PAD + SCROLL_H + 4
            local FULL_H = FOOT_Y + FOOT_H + QA_PAD
            local foot   = mkF(qaBar, UDim2.new(0, INNER_W, 0, FOOT_H),
                UDim2.new(0, QA_PAD, 0, FOOT_Y), P.foot, 0, 8)
            foot.ZIndex = 10; _qb._footStroke = mkStroke(foot, 1, P.footBrd, 0.2)
            _q.statusDot = mkF(foot, UDim2.new(0, 5, 0, 5), UDim2.new(0, 9, 0.5, -2), P.tgtTxt, 0, 99)
            _q.statusDot.ZIndex = 12

            task.spawn(function()
                local _sdTw = nil
                while foot and foot.Parent and _qb._tlAlive() do
                    if qaBar and qaBar.Visible then
                        if _sdTw then pcall(_sdTw.Cancel, _sdTw) end
                        if type(_qb.tw) ~= "function" then task.wait(1.5); continue end
                        _sdTw = _qb.tw(_q.statusDot, 0.7, { BackgroundTransparency = 0.6 }); if _sdTw then _sdTw:Play() end
                        task.wait(1.5)
                        if _sdTw then pcall(_sdTw.Cancel, _sdTw) end
                        _sdTw = _qb.tw(_q.statusDot, 0.7, { BackgroundTransparency = 0 }); if _sdTw then _sdTw:Play() end
                        task.wait(1.5)
                    else
                        task.wait(0.5)
                    end
                end
            end)

            _q.statusTxt = mkTxt(foot, UDim2.new(1, -58, 1, 0), UDim2.new(0, 20, 0, 0),
                "Idle – Select an action", Enum.Font.GothamBold, 11, P.tgtTxt)
            _q.statusTxt.ZIndex = 12

            local stopBtn = Instance.new("TextButton", foot)
            stopBtn.Size = UDim2.new(0, 38, 0, 20); stopBtn.Position = UDim2.new(1, -42, 0.5, -10)
            stopBtn.BackgroundColor3 = P.stopBg; stopBtn.BackgroundTransparency = 0.1
            stopBtn.BorderSizePixel = 0; stopBtn.Text = "STOP"
            stopBtn.Font = Enum.Font.GothamBlack; stopBtn.TextSize = 9
            stopBtn.TextColor3 = P.stopTxt; stopBtn.ZIndex = 13; stopBtn.Active = true
            do
                local c = Instance.new("UICorner", stopBtn); c.CornerRadius = UDim.new(0, 5)
            end
            _qb._stopBtnStroke = mkStroke(stopBtn, 1, P.stopBrd, 0.6)
            stopBtn.MouseEnter:Connect(function()
                pcall(function() if type(_qb._sc._playHoverSound) == "function" then _qb._sc._playHoverSound() end end)
                twP(stopBtn, .1, { BackgroundColor3 = Color3.fromRGB(55, 14, 18) })
            end)
            stopBtn.MouseLeave:Connect(function()
                twP(stopBtn, .1, { BackgroundColor3 = P.stopBg })
            end)
            _qb.qaDoStop = function()
                _qb.resetAllCards(); _qb.stopQAAction()
                if _q.statusTxt then
                    _q.statusTxt.Text = "Stopped"; _q.statusTxt.TextColor3 = P.tgtTxt
                end
                if _q.statusDot then _q.statusDot.BackgroundColor3 = P.tgtTxt end
            end
            stopBtn.MouseButton1Click:Connect(_qb.qaDoStop)
            stopBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then _qb.qaDoStop() end
            end)

            _qb.qaBarTween = nil
            _qb.openQABar = function()
                if _qb.qaBarTween then
                    pcall(function() _qb.qaBarTween:Cancel() end); _qb.qaBarTween = nil
                end
                if type(_qb.closeBar) == "function" then _qb.closeBar() end
                local np = _qb.getNearestPlayer()
                _qb.tgtNameLbl.Text = np and np.Name or "?"
                tgtDot.BackgroundColor3 = np and P.tgtDot or P.tgtTxt
                _qb.qaBarOpen = true; _qb.qaBar.Visible = true
                _qb.qaBar.Size = UDim2.new(0, _qb.QA_W, 0, 0)
                _qb.qaBarTween = type(_qb.tw) == "function" and _qb.tw(_qb.qaBar, .28, { Size = UDim2.new(0, _qb.QA_W, 0, FULL_H) },
                    Enum.EasingStyle.Quart, Enum.EasingDirection.Out) or nil
                if _qb.qaBarTween then _qb.qaBarTween:Play() end
                if _qb.tlArrow then _qb.tlArrow.Image = "rbxassetid://125463592889179" end
            end
            _qb.closeQABar = function()
                if _qb.qaBarTween then
                    pcall(function() _qb.qaBarTween:Cancel() end); _qb.qaBarTween = nil
                end
                _qb.qaBarOpen = false
                if _qb.tlArrow then _qb.tlArrow.Image = "rbxassetid://119926812103560" end
                _qb.qaBarTween = type(_qb.tw) == "function" and _qb.tw(_qb.qaBar, .2, { Size = UDim2.new(0, _qb.QA_W, 0, 0) },
                    Enum.EasingStyle.Quart, Enum.EasingDirection.In) or nil
                if _qb.qaBarTween then _qb.qaBarTween:Play() end
                if _qb.qaBarTween then
                    _qb.qaBarTween.Completed:Connect(function()
                        if not _qb.qaBarOpen then _qb.qaBar.Visible = false end
                    end)
                else
                    if not _qb.qaBarOpen then _qb.qaBar.Visible = false end
                end
            end
            _TL_refs._TL_closeQABar = _qb.closeQABar

            _qb._tlHitboxLastClick = 0
            _qb.tlHitboxActivate = function()
                local now = tick()
                if now - _qb._tlHitboxLastClick < 0.3 then return end
                _qb._tlHitboxLastClick = now
                if _qb.qaBarOpen then _qb.closeQABar() else _qb.openQABar() end
            end
            if _qb.tlHitbox then
                _qb.tlHitbox.MouseButton1Click:Connect(_qb.tlHitboxActivate)
                _qb.tlHitbox.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then _qb.tlHitboxActivate() end
                end)
                _qb.tlHitbox.MouseEnter:Connect(function()
                    pcall(function() if type(_qb._sc._playHoverSound) == "function" then _qb._sc._playHoverSound() end end)
                    twP(_qb.tlLbl, .1, { ImageTransparency = 0.3 })
                    twP(_qb.tlArrow, .1, { ImageTransparency = 0.3 })
                end)
                _qb.tlHitbox.MouseLeave:Connect(function()
                    twP(_qb.tlLbl, .1, { ImageTransparency = 0 })
                    twP(_qb.tlArrow, .1, { ImageTransparency = 0 })
                end)
            end
            if _qb.tlArrow then _qb.tlArrow.Image = "rbxassetid://119926812103560" end
            if _qb.tlArrowBig then _qb.tlArrowBig.Image = "rbxassetid://119926812103560" end

            _qb._FULL_H = FULL_H
        end, function(e) return debug.traceback(tostring(e), 2) end); if not _ok_QABar then
            warn("[TL] QABar:error " .. tostring(_err_QABar))
            _qb._handleError("[QABar] " .. tostring(_err_QABar))
        end
    end)
end

function M.stopQABar()
    if not _qaStarted then return end
    _qaStarted = false

    pcall(function() _qb.stopQAAction() end)
    if _qb.qaBar then
        pcall(function() _qb.qaBar.Visible = false end)
        pcall(function() _qb.qaBar.Size = UDim2.new(0, _qb.QA_W, 0, 0) end)
    end
    _qb.qaBarOpen = false
    if _qb.tlArrow then
        pcall(function() _qb.tlArrow.Image = "rbxassetid://119926812103560" end)
    end
end

function M.isQABarActive()
    return _qb.qaBarOpen == true
end

function M.cleanupQABar()
    M.stopQABar()

    for _, c in ipairs(_connections) do
        pcall(function() c:Disconnect() end)
    end
    _connections = {}

    if _qb.qaBar then
        pcall(function() _qb.qaBar:Destroy() end)
        _qb.qaBar = nil
    end

    _qb.qaCardRefs = {}
    pcall(function() _qb.g._TL_qb = nil end)
    pcall(function() _qb.g._TL_closeQABar = nil end)
    pcall(function() _qb.g._TL_qaBar = nil end)
    pcall(function() _qb.env._TL_qaBar = nil end)

    pcall(function() _G.TLQA_ResetUI = nil end)
    pcall(function() _G._TL_setQABar = nil end)
    pcall(function() _G._TL_qaBarActive = nil end)

    _qaInitialized = false
    _qaStarted = false
end


_G._TL_setQABar = function(frame)
    if frame then
        _qb.qaBar = frame
    end
    return _qb.qaBar
end

_G._TL_qaBarActive = function()
    return _qb.qaBarOpen == true
end

_G.TLQA_ResetUI = function()
    pcall(function()
        _qb.resetAllCards()
        _qb.stopQAAction()
    end)
end

if _qaInitialized and _qb._registerResetFn then
    _qb._registerResetFn(_G.TLQA_ResetUI)
end

M.openQABar      = function() if _qb.openQABar then _qb.openQABar() end end
M.closeQABar     = function() if _qb.closeQABar then _qb.closeQABar() end end
M.stopQAAction   = function(kr) if _qb.stopQAAction then _qb.stopQAAction(kr) end end
M.activateQAAction = function(key, tgt) if _qb.activateQAAction then return _qb.activateQAAction(key, tgt) end return false end
M.resetAllCards  = function() if _qb.resetAllCards then _qb.resetAllCards() end end
M.qaStartNoSit   = function() if _qb.qaStartNoSit then _qb.qaStartNoSit() end end
M.qaStopNoSit    = function(kr) if _qb.qaStopNoSit then _qb.qaStopNoSit(kr) end end

return M
