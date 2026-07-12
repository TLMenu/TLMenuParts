local M = {}
local _cfg = {}

local _mfloor, _mrandom, _mcos, _msin = math.floor, math.random, math.cos, math.sin
local _mmax, _mmin, _mpi = math.max, math.min, math.pi

local visualSettingsPage = nil
local _vpY = 0
local _vpPAD = 8
local twP = nil

local CURSOR_IMAGE = "rbxassetid://72906199197416"
local CURSOR_SIZE = 32
local CURSOR_HOTSPOT = Vector2.new(3, 2)
local FX_ORDER_CUR = 1000100

local fxEnabled = false
local fxColor = nil
local fxEffect = "smoke"
local fxSize = 6
local fxParticleAmount = 1.00
local fxSmoothness = 0.70
local fxSpeed = 1.00
local cursorTheme = "minimal"
local fxGui = nil
local fxRoot = nil
local fxParticles = {}
local fxConn = nil
local fxInputConn = nil
local cursorSyncConn = nil
local textFocusedConn = nil
local textReleasedConn = nil
local cursorGui_ = nil
local cursorImage_ = nil
local cursorShadow_ = nil
local cursorScale_ = 1
local cursorShadowScale_ = 1.12
local lastMousePos_ = Vector2.new(0, 0)
local mouseVel_ = Vector2.new(0, 0)
local spawnAccum_ = 0
local cachedUseOrig_ = false
local lastCheckPos_ = Vector2.new(-9999, -9999)
local lastCheckTime_ = 0

local EFFECT_ORDER = { "none", "smoke", "trail", "rainbow", "spark", "burst",
    "pulse", "orbit", "wave", "spiral", "fire", "snow", "glitch", "neon" }
local THEME_ORDER = { "default", "minimal", "vector", "glass", "neon", "dark",
    "light", "cyber", "pastel", "gold", "ghost" }

local function _VCOL() return _cfg.C.accent end

local function _curCleanupGlobals()
    for _, k in ipairs({ "_TLNativeCursorFxGui", "_TLNativeCursorFxSettings", "_TLNativeCursorFxConn",
        "_TLNativeCursorFxInputConn", "_TLNativeCursorFxToggleConn", "_TLNativeCursorFxCursorConn",
        "_TLNativeCursorFxTextFocusedConn", "_TLNativeCursorFxTextReleasedConn", "_TLNativeCursorVisualGui" }) do
        if _G[k] then pcall(function() if _G[k].Disconnect then _G[k]:Disconnect() elseif _G[k].Destroy then
                    _G[k]:Destroy() end end) end
        _G[k] = nil
    end
end
_curCleanupGlobals()

local UIS2   = nil
local RS2    = nil
local GS2    = nil
local Mouse_ = nil

local function _isTextInput(obj)
    while obj do
        if obj:IsA("TextBox") then return true end; obj = obj.Parent
    end
    return false
end

local function _shouldUseOrig(mp)
    if UIS2:GetFocusedTextBox() then return true end
    local ok, obs = pcall(function() return GS2:GetGuiObjectsAtPosition(mp.X, mp.Y) end)
    if ok and obs then for _, o in ipairs(obs) do if _isTextInput(o) then return true end end end
    return false
end

local applyCursorTheme_
applyCursorTheme_ = function()
    if not cursorImage_ or not cursorShadow_ then return end
    local styles = {
        default = { scale = 1.00, shadowScale = 1.08, shadowTransparency = 0.80, shadowColor = Color3.fromRGB(0, 0, 0) },
        minimal = { scale = 0.92, shadowScale = 1.00, shadowTransparency = 1.00, shadowColor = Color3.fromRGB(0, 0, 0) },
        vector  = { scale = 1.00, shadowScale = 1.04, shadowTransparency = 0.84, shadowColor = fxColor:Lerp(Color3.new(1, 1, 1), 0.35) },
        glass   = { scale = 1.03, shadowScale = 1.14, imageTransparency = 0.20, shadowTransparency = 0.82, shadowColor = Color3.fromRGB(220, 240, 255) },
        neon    = { scale = 1.05, shadowScale = 1.24, shadowTransparency = 0.48, shadowColor = fxColor },
        dark    = { scale = 1.00, shadowScale = 1.12, shadowTransparency = 0.68, shadowColor = Color3.fromRGB(0, 0, 0), mode = "dark" },
        light   = { scale = 1.00, shadowScale = 1.10, shadowTransparency = 0.78, shadowColor = Color3.fromRGB(255, 255, 255), mode = "light" },
        cyber   = { scale = 1.08, shadowScale = 1.25, shadowTransparency = 0.55, shadowColor = Color3.fromRGB(0, 255, 230) },
        pastel  = { scale = 0.98, shadowScale = 1.12, shadowTransparency = 0.72, shadowColor = fxColor:Lerp(Color3.new(1, 1, 1), 0.55) },
        gold    = { scale = 1.04, shadowScale = 1.18, shadowTransparency = 0.60, shadowColor = Color3.fromRGB(255, 205, 80), tintColor = Color3.fromRGB(255, 235, 160) },
        ghost   = { scale = 1.06, shadowScale = 1.22, imageTransparency = 0.28, shadowTransparency = 0.84, shadowColor = Color3.fromRGB(210, 240, 255) },
    }
    local s = styles[cursorTheme] or styles.minimal
    cursorScale_ = s.scale or 1; cursorShadowScale_ = s.shadowScale or cursorScale_
    local tint = fxColor
    if s.mode == "dark" then
        tint = fxColor:Lerp(Color3.fromRGB(28, 28, 36), 0.45)
    elseif s.mode == "light" then
        tint = fxColor:Lerp(Color3.fromRGB(255, 255, 255), 0.35)
    elseif s.tintColor then
        tint = s.tintColor:Lerp(fxColor, 0.45)
    end
    local sz = math.floor(CURSOR_SIZE * cursorScale_ + 0.5); local szSh = math.floor(CURSOR_SIZE *
    cursorShadowScale_ + 0.5)
    cursorImage_.Size = UDim2.fromOffset(sz, sz); cursorImage_.Image = CURSOR_IMAGE
    cursorImage_.ImageColor3 = tint; cursorImage_.ImageTransparency = s.imageTransparency or 0
    cursorShadow_.Size = UDim2.fromOffset(szSh, szSh); cursorShadow_.Image = CURSOR_IMAGE
    cursorShadow_.ImageColor3 = s.shadowColor or fxColor; cursorShadow_.ImageTransparency = s
    .shadowTransparency or 0.75
end

local function _destroyCursorGui()
    if cursorGui_ then
        pcall(function() cursorGui_:Destroy() end); cursorGui_ = nil
    end
    cursorImage_ = nil; cursorShadow_ = nil
    _G._TLNativeCursorVisualGui = nil
end

local function _ensureCursorGui()
    if cursorGui_ and cursorGui_.Parent and cursorImage_ and cursorShadow_ then return end
    if cursorGui_ then pcall(function() cursorGui_:Destroy() end) end
    cursorGui_ = Instance.new("ScreenGui"); cursorGui_.Name = "TLNativeCursorVisual"; cursorGui_.ResetOnSpawn = false
    cursorGui_.IgnoreGuiInset = true; cursorGui_.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; cursorGui_.DisplayOrder =
    FX_ORDER_CUR + 20
    _cfg._tryParentGui(cursorGui_); _G._TLNativeCursorVisualGui = cursorGui_
    cursorShadow_ = Instance.new("ImageLabel"); cursorShadow_.Name = "CursorShadow"
    cursorShadow_.Size = UDim2.fromOffset(CURSOR_SIZE, CURSOR_SIZE); cursorShadow_.BackgroundTransparency = 1
    cursorShadow_.BorderSizePixel = 0; cursorShadow_.Image = CURSOR_IMAGE; cursorShadow_.Visible = false; cursorShadow_.ZIndex = 998; cursorShadow_.Parent =
    cursorGui_
    cursorImage_ = Instance.new("ImageLabel"); cursorImage_.Name = "CursorImage"
    cursorImage_.Size = UDim2.fromOffset(CURSOR_SIZE, CURSOR_SIZE); cursorImage_.BackgroundTransparency = 1
    cursorImage_.BorderSizePixel = 0; cursorImage_.Image = CURSOR_IMAGE; cursorImage_.ImageColor3 =
    fxColor
    cursorImage_.Visible = false; cursorImage_.ZIndex = 999; cursorImage_.Parent = cursorGui_
    applyCursorTheme_()
end

local function _setCursorVisual(mp, visible)
    if not fxEnabled then
        if cursorImage_ then cursorImage_.Visible = false end
        if cursorShadow_ then cursorShadow_.Visible = false end
        return
    end
    _ensureCursorGui(); if not cursorImage_ then return end
    if mp then
        cursorImage_.Position = UDim2.fromOffset(
        math.floor(mp.X - (CURSOR_HOTSPOT.X * cursorScale_) + 0.5),
            math.floor(mp.Y - (CURSOR_HOTSPOT.Y * cursorScale_) + 0.5))
        if cursorShadow_ then cursorShadow_.Position = UDim2.fromOffset(
            math.floor(mp.X - (CURSOR_HOTSPOT.X * cursorShadowScale_) + 0.5),
                math.floor(mp.Y - (CURSOR_HOTSPOT.Y * cursorShadowScale_) + 0.5)) end
    end
    cursorImage_.Visible = visible == true
    if cursorShadow_ then cursorShadow_.Visible = visible == true and
        (cursorShadow_.ImageTransparency < 0.98) end
end

local function _setNativeCursorVisible(visible)
    if not fxEnabled then return end

    local isLocked = false
    pcall(function() isLocked = (UIS2.MouseBehavior == Enum.MouseBehavior.LockCenter or UIS2.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition) end)
    local mp; pcall(function() mp = UIS2:GetMouseLocation() end)

    if isLocked then
        _setCursorVisual(mp, false)
        return
    end

    local now = tick()
    if mp and (((mp - lastCheckPos_).Magnitude > 0.5) or ((now - lastCheckTime_) > 0.08)) then
        cachedUseOrig_ = visible and _shouldUseOrig(mp); lastCheckTime_ = now; lastCheckPos_ = mp
    elseif not visible then
        cachedUseOrig_ = false
    end
    local useOrig = visible and cachedUseOrig_
    pcall(function() if UIS2.MouseIconEnabled ~= useOrig then UIS2.MouseIconEnabled = useOrig end end)
    if Mouse_ then pcall(function() if Mouse_.Icon ~= "" then Mouse_.Icon = "" end end) end
    if visible and not useOrig then _setCursorVisual(mp, true) else _setCursorVisual(mp, false) end
end

local function _startCursorSync()
    _ensureCursorGui()
    if not textFocusedConn then
        textFocusedConn = UIS2.TextBoxFocused:Connect(function()
            pcall(function() UIS2.MouseIconEnabled = true end)
            if Mouse_ then pcall(function() Mouse_.Icon = "" end) end
            _setCursorVisual(nil, false)
        end); _G._TLNativeCursorFxTextFocusedConn = textFocusedConn
    end
    if not textReleasedConn then
        textReleasedConn = UIS2.TextBoxFocusReleased:Connect(function() _setNativeCursorVisible(true) end)
        _G._TLNativeCursorFxTextReleasedConn = textReleasedConn
    end
    if cursorSyncConn then return end
    local _csLastSync = 0
    cursorSyncConn = RS2.Heartbeat:Connect(function()
        local _csNow = tick()
        if _csNow - _csLastSync < 0.05 then return end
        _csLastSync = _csNow
        _setNativeCursorVisible(true)
    end)
    _G._TLNativeCursorFxCursorConn = cursorSyncConn
end

local function _buildFxGui()
    if fxGui then return end
    fxParticles = {}
    fxGui = Instance.new("ScreenGui"); fxGui.Name = "TLNativeCursorFX"; fxGui.ResetOnSpawn = false
    fxGui.IgnoreGuiInset = true; fxGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; fxGui.DisplayOrder =
    FX_ORDER_CUR
    _cfg._tryParentGui(fxGui); _G._TLNativeCursorFxGui = fxGui
    fxRoot = Instance.new("Frame"); fxRoot.Name = "FxRoot"; fxRoot.Size = UDim2.new(1, 0, 1, 0)
    fxRoot.BackgroundTransparency = 1; fxRoot.BorderSizePixel = 0; fxRoot.Parent = fxGui
    for i = 1, 28 do
        local dot = Instance.new("Frame"); dot.Name = "P" .. i; dot.Size = UDim2.new(0, fxSize, 0,
            fxSize)
        dot.AnchorPoint = Vector2.new(0.5, 0.5); dot.BackgroundColor3 = fxColor; dot.BackgroundTransparency = 0.3
        dot.BorderSizePixel = 0; dot.Visible = false; dot.ZIndex = 20; dot.Parent = fxRoot; _cfg.corner(
        dot, 999)
        fxParticles[i] = { frame = dot, life = 0, maxLife = 0.35 + i * 0.03, x = 0, y = 0, dx = 0, dy = 0, size =
        fxSize, angle = 0, spin = 0, radius = 0, seed = math.random() * math.pi * 2 }
    end
end

local function _destroyFxGui()
    if fxGui then
        pcall(function() fxGui:Destroy() end); fxGui = nil; fxRoot = nil; fxParticles = {}
    end
    if fxConn then
        pcall(function() fxConn:Disconnect() end); fxConn = nil
    end
    if fxInputConn then
        pcall(function() fxInputConn:Disconnect() end); fxInputConn = nil
    end
    _G._TLNativeCursorFxConn = nil; _G._TLNativeCursorFxInputConn = nil
end

local function _updateFxBurst(mx, my, dt)
    if fxEffect == "none" or fxEffect == "rainbow" or fxEffect == "orbit" or fxEffect == "pulse" then return end
    local pf = math.clamp(fxParticleAmount, 0.35, 2.50); local sf = math.clamp(fxSpeed, 0.40, 1.80)
    local speed = mouseVel_.Magnitude; local spawnRate, spread, baseAngle, speedMin, speedMax, lifeBase =
    0.02, 0.8, _mrandom() * _mpi * 2, 8, 20, 0.35
    local ac = 0; for _, p in ipairs(fxParticles) do if p.life > 0 then ac = ac + 1 end end
    local cap = _mmax(4, _mfloor(#fxParticles * math.clamp(0.18 + pf * 0.32, 0.18, 1))); if ac >= cap then return end
    if fxEffect == "trail" then
        spawnRate = _mmax(0.008, 0.024 - speed * 0.00003); spread = 0.18; baseAngle = math.atan2(
        -mouseVel_.Y, -mouseVel_.X); speedMin, speedMax, lifeBase = 10, 20, 0.32
    elseif fxEffect == "spark" then
        spawnRate = 0.008; spread = 0.45; speedMin, speedMax, lifeBase = 20, 38, 0.20
    elseif fxEffect == "burst" then
        spawnRate = 0.012; spread = _mpi * 2; speedMin, speedMax, lifeBase = 18, 32, 0.25
    elseif fxEffect == "wave" then
        spawnRate = 0.010; spread = 0.35; baseAngle = os.clock() * 6; speedMin, speedMax, lifeBase = 10,
            18, 0.45
    elseif fxEffect == "spiral" then
        spawnRate = 0.010; spread = 0.25; baseAngle = os.clock() * 7; speedMin, speedMax, lifeBase = 8,
            14, 0.55
    elseif fxEffect == "fire" then
        spawnRate = 0.009; spread = 0.60; baseAngle = -_mpi / 2; speedMin, speedMax, lifeBase = 8,
            20, 0.35
    elseif fxEffect == "snow" then
        spawnRate = 0.018; spread = 0.25; baseAngle = _mpi / 2; speedMin, speedMax, lifeBase = 2,
            6, 0.70
    elseif fxEffect == "glitch" then
        spawnRate = 0.010; spread = _mpi * 2; speedMin, speedMax, lifeBase = 1, 6, 0.16
    elseif fxEffect == "neon" then
        spawnRate = 0.008; spread = 0.10; baseAngle = math.atan2(-mouseVel_.Y, -mouseVel_.X); speedMin, speedMax, lifeBase =
        6, 12, 0.28
    else
        spawnRate = math.max(0.012, 0.040 - speed * 0.00004); spread = 1.00; speedMin, speedMax, lifeBase =
        8, 16, 0.45
    end
    spawnRate = spawnRate / pf; speedMin = speedMin * sf; speedMax = speedMax * sf
    spawnAccum_ = spawnAccum_ + (dt or 0.016); if spawnAccum_ < spawnRate then return end; spawnAccum_ = 0
    for i, p in ipairs(fxParticles) do
        if p.life <= 0 then
            local angle = baseAngle + (_mrandom() - 0.5) * spread; local mag = speedMin +
            _mrandom() * (speedMax - speedMin)
            p.maxLife = lifeBase + (i % 3) * 0.03; p.life = p.maxLife; p.x = mx; p.y = my; p.dx =
            _mcos(angle) * mag; p.dy = _msin(angle) * mag
            p.size = _mmax(2, fxSize - 2 + _mrandom() * 5); p.angle = angle; p.spin = (_mrandom() - 0.5) *
            8; p.radius = 4 + _mrandom() * 12; p.seed = _mrandom() * _mpi * 2
            p.frame.Visible = true
            if fxEffect == "fire" then
                p.frame.BackgroundColor3 = Color3.fromRGB(255, 170 + _mrandom(0, 60), 40)
            elseif fxEffect == "snow" then
                p.frame.BackgroundColor3 = Color3.fromRGB(230, 245, 255)
            elseif fxEffect == "glitch" then
                p.frame.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 0, 170) or Color3.fromRGB(0, 255, 255)
            elseif fxEffect == "neon" then
                p.frame.BackgroundColor3 = Color3.fromHSV((os.clock() * 0.6 + i / #fxParticles) % 1, 1, 1)
            else
                p.frame.BackgroundColor3 = fxColor
            end
            break
        end
    end
end

local function _startFxLoop()
    if fxConn then return end
    pcall(function()
        local pos = UIS2:GetMouseLocation()
        lastMousePos_ = Vector2.new(pos.X, pos.Y)
    end)
    local _fxFrameAcc = 0
    local _COL_WHITE_FX   = Color3.new(1, 1, 1)
    local _COL_SNOW_FX    = Color3.fromRGB(230, 245, 255)
    local _COL_GLITCH1_FX = Color3.fromRGB(255, 0, 170)
    local _COL_GLITCH2_FX = Color3.fromRGB(0, 255, 255)
    fxConn = RS2.Heartbeat:Connect(function(dt)
        _fxFrameAcc = _fxFrameAcc + dt
        if _fxFrameAcc < 0.0167 then return end
        dt = _fxFrameAcc; _fxFrameAcc = 0
        local pos; pcall(function() pos = UIS2:GetMouseLocation() end); if not pos then return end
        local cur = Vector2.new(pos.X, pos.Y)
        local alpha = math.clamp(1 - fxSmoothness, 0.05, 0.65)
        local vx = (cur.X - lastMousePos_.X) / math.max(dt, 0.001); local vy = (cur.Y - lastMousePos_.Y) /
        math.max(dt, 0.001)
        mouseVel_ = mouseVel_ * (1 - alpha) + Vector2.new(vx, vy) * alpha; lastMousePos_ = cur
        _updateFxBurst(cur.X, cur.Y, dt)
        local now = tick(); local hue = (now * 0.25) % 1; local animDt = dt * math.clamp(fxSpeed, 0.40, 1.80)
        local fxN = #fxParticles
        local _COL_WHITE  = _COL_WHITE_FX
        local _COL_SNOW   = _COL_SNOW_FX
        local _COL_GLITCH1= _COL_GLITCH1_FX
        local _COL_GLITCH2= _COL_GLITCH2_FX
        for i, p in ipairs(fxParticles) do
            if p.life > 0 and (fxEffect == "rainbow" or fxEffect == "orbit" or fxEffect == "pulse") then
                p.life = 0; p.frame.Visible = false
            end
            if p.life > 0 then
                p.life = p.life - animDt
                if p.life <= 0 then
                    p.life = 0; p.frame.Visible = false
                else
                local t = 1 - _mmax(0, p.life / _mmax(p.maxLife, 0.001))
                local px = p.x + p.dx * t; local py = p.y + p.dy * t; local sz_ = p.size *
                (0.65 + t * 0.75); local col = fxColor
                if fxEffect == "smoke" then
                    px = p.x + p.dx * t * 0.7; py = p.y + p.dy * t * 0.7 - t * 4; sz_ = p.size *
                    (0.9 + t); col = fxColor:Lerp(Color3.fromRGB(170, 170, 170), 0.35)
                elseif fxEffect == "spark" then
                    sz_ = _mmax(2, p.size * (1 - t * 0.35)); col = fxColor:Lerp(_COL_WHITE, 0.35)
                elseif fxEffect == "burst" then
                    sz_ = p.size * (0.8 + t * 0.45); col = Color3.fromHSV((hue + t * 0.2) % 1, 0.9, 1)
                elseif fxEffect == "wave" then
                    px = p.x + _mcos(p.seed + t * 8) * (6 + t * 18); py = p.y +
                    _msin(p.seed * 0.5 + t * 10) * 10; sz_ = p.size * (0.9 + 0.5 * t); col =
                    Color3.fromHSV((hue + i / fxN * 0.05) % 1, 0.8, 1)
                elseif fxEffect == "spiral" then
                    local ang = p.angle + t * 10 + p.spin * 0.2; local rad = p.radius + t * 16; px =
                    p.x + _mcos(ang) * rad; py = p.y + _msin(ang) * rad; sz_ = p.size *
                    (0.85 + 0.3 * t); col = Color3.fromHSV((hue + t * 0.15) % 1, 1, 1)
                elseif fxEffect == "fire" then
                    px = p.x + _msin(p.seed + t * 9) * 4; py = p.y - t * (20 + p.radius); sz_ = p
                    .size * (1 - t * 0.4); col = Color3.fromRGB(255, _mfloor(150 + 70 * (1 - t)),
                        40)
                elseif fxEffect == "snow" then
                    px = p.x + _msin(p.seed + t * 6) * 8; py = p.y + t * (12 + p.radius); sz_ = p
                    .size * (0.9 + 0.2 * _msin(t * _mpi)); col = _COL_SNOW
                elseif fxEffect == "glitch" then
                    px = cur.X + _mrandom(-8, 8); py = cur.Y + _mrandom(-8, 8); sz_ = _mmax(
                    2, p.size + _mrandom(-1, 2)); col = (i % 2 == 0) and _COL_GLITCH1 or _COL_GLITCH2
                elseif fxEffect == "neon" then
                    px = p.x + p.dx * t * 0.8; py = p.y + p.dy * t * 0.8; sz_ = p.size * (1 + t * 0.35); col =
                    Color3.fromHSV((hue + i / fxN * 0.08) % 1, 1, 1)
                elseif fxEffect == "trail" then
                    sz_ = p.size * (0.65 + t * 0.55)
                end
                p.frame.Position = UDim2.new(0, px, 0, py); p.frame.Size = UDim2.new(0, sz_, 0, sz_)
                p.frame.BackgroundColor3 = col; p.frame.BackgroundTransparency = math.clamp(t * 1.05,
                    0.10, 1); p.frame.Visible = true
                end
            elseif fxEffect == "rainbow" then
                local ang = ((i - 1) / fxN) * _mpi * 2 + now * 2.5; local rad = 7 +
                _msin(now * 3 + i) * 3
                p.frame.Position = UDim2.new(0, cur.X + _mcos(ang) * rad, 0,
                    cur.Y + _msin(ang) * rad)
                p.frame.Size = UDim2.new(0, _mmax(2, fxSize + 1), 0, _mmax(2, fxSize + 1))
                p.frame.BackgroundColor3 = Color3.fromHSV((hue + i / fxN) % 1, 1, 1); p.frame.BackgroundTransparency = 0.15; p.frame.Visible = true
            elseif fxEffect == "orbit" then
                local ang = ((i - 1) / fxN) * _mpi * 2 + now * (1.8 + (i % 3) * 0.2); local rad = 10 +
                (i % 3) * 4
                p.frame.Position = UDim2.new(0, cur.X + _mcos(ang) * rad, 0,
                    cur.Y + _msin(ang) * rad)
                p.frame.Size = UDim2.new(0, _mmax(2, fxSize), 0, _mmax(2, fxSize))
                p.frame.BackgroundColor3 = fxColor:Lerp(_COL_WHITE, 0.2); p.frame.BackgroundTransparency = 0.22; p.frame.Visible = true
            elseif fxEffect == "pulse" then
                local pulse = (now * 2.6 + (i / fxN)) % 1; local ang = ((i - 1) / fxN) *
                _mpi * 2
                local rad = 2 + pulse * 16; local psz = _mmax(2, fxSize + (1 - pulse) * 4)
                p.frame.Position = UDim2.new(0, cur.X + _mcos(ang) * rad, 0,
                    cur.Y + _msin(ang) * rad)
                p.frame.Size = UDim2.new(0, psz, 0, psz); p.frame.BackgroundColor3 = fxColor:Lerp(
                _COL_WHITE, 0.3)
                p.frame.BackgroundTransparency = math.clamp(0.15 + pulse * 0.75, 0.15, 0.95); p.frame.Visible = true
            else
                p.frame.Visible = false
            end
        end
    end); _G._TLNativeCursorFxConn = fxConn
end

local function _setFxEnabled(enabled)
    fxEnabled = enabled
    if enabled then
        _startCursorSync()
        _setNativeCursorVisible(true)
        _buildFxGui()
        _startFxLoop()
    else
        local wasActive = (cursorSyncConn ~= nil)

        if cursorSyncConn then
            pcall(function() cursorSyncConn:Disconnect() end)
            cursorSyncConn = nil
            _G._TLNativeCursorFxCursorConn = nil
        end
        if textFocusedConn then
            pcall(function() textFocusedConn:Disconnect() end)
            textFocusedConn = nil
            _G._TLNativeCursorFxTextFocusedConn = nil
        end
        if textReleasedConn then
            pcall(function() textReleasedConn:Disconnect() end)
            textReleasedConn = nil
            _G._TLNativeCursorFxTextReleasedConn = nil
        end
        _destroyFxGui()
        _destroyCursorGui()
        _setCursorVisual(nil, false)

        if wasActive then
            pcall(function() UIS2.MouseIconEnabled = true end)
            if Mouse_ then pcall(function() Mouse_.Icon = "" end) end
        end
    end
end

local function _makeVslider(label, sublabel, vMin, vMax, vDef, col, onSlide)
    local CARD_H_V = 64
    local card = Instance.new("Frame", visualSettingsPage); card.Size = UDim2.new(1, 0, 0, CARD_H_V); card.Position =
    UDim2.new(0, 0, 0, _vpY); card.BackgroundColor3 = Color3.fromRGB(255, 255, 255); card.BackgroundTransparency = 0.94; card.BorderSizePixel = 0; _cfg.corner(
    card, 14)
    local cStr = _cfg._makeDummyStroke(card); cStr.Thickness = 1; cStr.Color = _cfg.C.bg3; cStr.Transparency = 0.3
    local cdot = Instance.new("Frame", card); cdot.Size = UDim2.new(0, 3, 0, CARD_H_V - 20); cdot.Visible = false; cdot.Position =
    UDim2.new(0, 0, 0.5, -(CARD_H_V - 20) / 2); cdot.BackgroundColor3 = col; cdot.BackgroundTransparency = 0.4; cdot.BorderSizePixel = 0; _cfg.corner(
    cdot, 99)
    local nameLbl = Instance.new("TextLabel", card); nameLbl.Size = UDim2.new(0, 140, 0, 18); nameLbl.Position =
    UDim2.new(0, 14, 0, 8); nameLbl.BackgroundTransparency = 1; nameLbl.Text = label; nameLbl.Font =
    Enum.Font.GothamBold; nameLbl.TextSize = 13; nameLbl.TextColor3 = _cfg.C.text; nameLbl.TextXAlignment =
    Enum.TextXAlignment.Left
    local subLbl = Instance.new("TextLabel", card); subLbl.Size = UDim2.new(0, 140, 0, 13); subLbl.Position =
    UDim2.new(0, 14, 0, 26); subLbl.BackgroundTransparency = 1; subLbl.Text = sublabel; subLbl.Font =
    Enum.Font.GothamBold; subLbl.TextSize = 9; subLbl.TextColor3 = _cfg.C.sub; subLbl.TextXAlignment =
    Enum.TextXAlignment.Left
    local valLbl = Instance.new("TextLabel", card); valLbl.Size = UDim2.new(0, 52, 0, 18); valLbl.Position =
    UDim2.new(1, -64, 0, 8); valLbl.BackgroundTransparency = 1; valLbl.Font = Enum.Font.GothamBlack; valLbl.TextSize = 13; valLbl.TextColor3 =
    col; valLbl.TextXAlignment = Enum.TextXAlignment.Right
    local track = Instance.new("Frame", card); track.Size = UDim2.new(1, -28, 0, 4); track.Position =
    UDim2.new(0, 14, 1, -14); track.BackgroundColor3 = _cfg.C.bg3; track.BackgroundTransparency = 0.2; track.BorderSizePixel = 0; _cfg.corner(
    track, 99)
    local fill = Instance.new("Frame", track); fill.BackgroundColor3 = col; fill.BackgroundTransparency = 0; fill.BorderSizePixel = 0; _cfg.corner(
    fill, 99)
    local knob = Instance.new("Frame", track); knob.Size = UDim2.new(0, 12, 0, 12); knob.BackgroundColor3 =
    _cfg._C3_WHITE; knob.BackgroundTransparency = 0; knob.BorderSizePixel = 0; knob.ZIndex = 5; _cfg.corner(
    knob, 99)
    local kStr = _cfg._makeDummyStroke(knob); kStr.Thickness = 1.5; kStr.Color = col; kStr.Transparency = 0
    local function applyRatio(r)
        r = math.clamp(r, 0, 1); local v = vMin + r * (vMax - vMin)
        fill.Size = UDim2.new(r, 0, 1, 0); knob.Position = UDim2.new(r, -6, 0.5, -6)
        onSlide(v, r, valLbl)
    end
    applyRatio((vDef - vMin) / (vMax - vMin))
    local dragging = false
    local sBtn = Instance.new("TextButton", track); sBtn.Size = UDim2.new(1, 12, 1, 12); sBtn.Position =
    UDim2.new(0, -6, 0, -4); sBtn.BackgroundTransparency = 1; sBtn.Text = ""; sBtn.ZIndex = 6
    sBtn.MouseButton1Down:Connect(function(x)
        dragging = true; applyRatio((x - track.AbsolutePosition.X) / track.AbsoluteSize.X)
    end)
    sBtn.MouseMoved:Connect(function(x) if dragging then applyRatio((x - track.AbsolutePosition.X) /
            track.AbsoluteSize.X) end end)
    sBtn.MouseButton1Up:Connect(function() dragging = false end)
                                            _cfg._panelColorHooks[#_cfg._panelColorHooks + 1] = function()
        local nc = _cfg.C.accent
        pcall(function() fill.BackgroundColor3 = nc end)
        pcall(function() kStr.Color = nc end)
        pcall(function() valLbl.TextColor3 = nc end)
    end
    _vpY = _vpY + CARD_H_V + _vpPAD; return card, valLbl
end

local function _makeVtoggle(label, sublabel, col, initOn, onToggle)
    local ROW_H = 46
    local card = Instance.new("Frame", visualSettingsPage); card.Size = UDim2.new(1, 0, 0, ROW_H); card.Position =
    UDim2.new(0, 0, 0, _vpY); card.BackgroundColor3 = Color3.fromRGB(255, 255, 255); card.BackgroundTransparency = 0.94; card.BorderSizePixel = 0; _cfg.corner(
    card, 14)
    local cStr = _cfg._makeDummyStroke(card); cStr.Thickness = 1; cStr.Color = _cfg.C.bg3; cStr.Transparency = 0.3
    local cdot = Instance.new("Frame", card); cdot.Size = UDim2.new(0, 3, 0, ROW_H - 16); cdot.Visible = false; cdot.Position =
    UDim2.new(0, 0, 0.5, -(ROW_H - 16) / 2); cdot.BackgroundColor3 = col; cdot.BackgroundTransparency = 0.4; cdot.BorderSizePixel = 0; _cfg.corner(
    cdot, 99)
    local lbl = Instance.new("TextLabel", card); lbl.Size = UDim2.new(1, -60, 0, 18); lbl.Position =
    UDim2.new(0, 14, 0, 6); lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.Font = Enum.Font
    .GothamBold; lbl.TextSize = 13; lbl.TextColor3 = _cfg.C.text; lbl.TextXAlignment = Enum
    .TextXAlignment.Left
    local sub = Instance.new("TextLabel", card); sub.Size = UDim2.new(1, -60, 0, 13); sub.Position =
    UDim2.new(0, 14, 0, 24); sub.BackgroundTransparency = 1; sub.Text = sublabel; sub.Font = Enum
    .Font.GothamBold; sub.TextSize = 9; sub.TextColor3 = _cfg.C.sub; sub.TextXAlignment = Enum
    .TextXAlignment.Left
    local togTrack = Instance.new("Frame", card); togTrack.Size = UDim2.new(0, 32, 0, 18); togTrack.Position =
    UDim2.new(1, -46, 0.5, -9); togTrack.BorderSizePixel = 0; _cfg.corner(togTrack, 99)
    local togKnob = Instance.new("Frame", togTrack); togKnob.Size = UDim2.new(0, 12, 0, 12); togKnob.BorderSizePixel = 0; _cfg.corner(
    togKnob, 99)
    local state = initOn or false
    local function refresh()
        if state then
            twP(togTrack, 0.15, { BackgroundColor3 = col, BackgroundTransparency = 0.55 }); twP(
            togKnob, 0.15,
                { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -14, 0.5,
                    -6) }); twP(cStr, 0.15, { Color = col, Transparency = 0.5 })
        else
            twP(togTrack, 0.15, { BackgroundColor3 = _cfg.C.bg3, BackgroundTransparency = 0.2 }); twP(
            togKnob, 0.15,
                { BackgroundColor3 = Color3.fromRGB(100, 100, 100), Position = UDim2.new(0, 2, 0.5,
                    -6) }); twP(cStr, 0.15, { Color = _cfg.C.bg3, Transparency = 0.3 })
        end
    end
    refresh()
    local btn = Instance.new("TextButton", card); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text =
    ""; btn.ZIndex = 5
    local function activate()
        state = not state; onToggle(state); refresh()
    end
    btn.MouseButton1Click:Connect(function()
        if _cfg._isMobile or _cfg._isTablet then return end; activate()
    end)
    btn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then
            activate() end end)
                                            _cfg._panelColorHooks[#_cfg._panelColorHooks + 1] = function()
        local nc = _cfg.C.accent
        pcall(function() cdot.BackgroundColor3 = nc end)
        if state then
            pcall(function() togTrack.BackgroundColor3 = nc end)
        else
            pcall(function() togTrack.BackgroundColor3 = _cfg.C.bg3 end)
        end
    end
    _vpY = _vpY + ROW_H + _vpPAD; return card
end

local function _makeChipRow(sectionLabel, items, onSelect, getActive)
    if not items or #items == 0 then return end
    local CHIP_H = 52; local CHIP_GAP = 8
    local hasLabel = (sectionLabel and sectionLabel ~= "")
    local headerH = hasLabel and 26 or 0
    local yOff = hasLabel and 22 or 0
    local CHIP_W = math.floor((_cfg.PANEL_W - 32 - CHIP_GAP * (#items - 1)) / #items)
    local wrap = Instance.new("Frame", visualSettingsPage); wrap.Size = UDim2.new(1, 0, 0,
        CHIP_H + headerH); wrap.Position = UDim2.new(0, 0, 0, _vpY); wrap.BackgroundTransparency = 1; wrap.BorderSizePixel = 0
    if hasLabel then
        local secLbl = Instance.new("TextLabel", wrap); secLbl.Size = UDim2.new(1, -16, 0, 18); secLbl.Position =
        UDim2.new(0, 8, 0, 0); secLbl.BackgroundTransparency = 1; secLbl.Text = sectionLabel; secLbl.Font =
        Enum.Font.GothamBold; secLbl.TextSize = 12; secLbl.TextColor3 = _cfg.C.sub; secLbl.TextXAlignment =
        Enum.TextXAlignment.Left
    end
    local chips = {}
    local function refresh()
        local act = getActive()
        for _, ch in ipairs(chips) do
            local isA = ch.id == act
            twP(ch.card, 0.15,
                { BackgroundColor3 = isA and _cfg.C.bg3 or _cfg.C.bg2, BackgroundTransparency = isA and 0.1 or
                0 })
            ch.str.Transparency = isA and 0.3 or 0.65; ch.str.Color = isA and _VCOL() or _cfg.C.bg3
            twP(ch.lbl, 0.15, { TextColor3 = isA and _VCOL() or _cfg.C.sub }); twP(ch.sub, 0.15,
                { TextColor3 = isA and _cfg.C.text or _cfg.C.sub })
        end
    end
    for i, item in ipairs(items) do
        local xOff = 16 + (i - 1) * (CHIP_W + CHIP_GAP)
        local chip = Instance.new("Frame", wrap); chip.Size = UDim2.new(0, CHIP_W, 0, CHIP_H); chip.Position =
        UDim2.new(0, xOff, 0, yOff); chip.BackgroundColor3 = Color3.fromRGB(255, 255, 255); chip.BackgroundTransparency = 0.94; chip.BorderSizePixel = 0; _cfg.corner(
        chip, 14)
        local cStr = _cfg._makeDummyStroke(chip); cStr.Thickness = 1.5; cStr.Color = _cfg.C.bg3; cStr.Transparency = 0.65; cStr.ApplyStrokeMode =
        Enum.ApplyStrokeMode.Border
        local lbl = Instance.new("TextLabel", chip); lbl.Size = UDim2.new(1, -4, 0, 16); lbl.Position =
        UDim2.new(0, 2, 0, 10); lbl.BackgroundTransparency = 1; lbl.Text = item.label; lbl.Font =
        Enum.Font.GothamBold; lbl.TextSize = 11; lbl.TextColor3 = _cfg.C.sub; lbl.TextXAlignment = Enum
        .TextXAlignment.Center
        local subL = Instance.new("TextLabel", chip); subL.Size = UDim2.new(1, -4, 0, 12); subL.Position =
        UDim2.new(0, 2, 1, -18); subL.BackgroundTransparency = 1; subL.Text = item.sub or ""; subL.Font =
        Enum.Font.GothamBold; subL.TextSize = 9; subL.TextColor3 = _cfg.C.sub; subL.TextXAlignment = Enum
        .TextXAlignment.Center
        local btn = Instance.new("TextButton", chip); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text =
        ""; btn.ZIndex = 8
        table.insert(chips, { id = item.id, card = chip, str = cStr, lbl = lbl, sub = subL })
        local captId = item.id
        local function activate()
            onSelect(captId); refresh()
        end
        btn.MouseButton1Click:Connect(function()
            if _cfg._isMobile or _cfg._isTablet then return end; activate()
        end)
        btn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then
                activate() end end)
        btn.MouseEnter:Connect(function()
            _cfg._sc._playHoverSound(); if getActive() ~= captId then twP(chip, 0.1,
                    { BackgroundColor3 = _cfg.C.bg3 }) end
        end)
        btn.MouseLeave:Connect(function() if getActive() ~= captId then twP(chip, 0.1,
                    { BackgroundColor3 = _cfg.C.bg2 }) end end)
    end
    refresh(); _vpY = _vpY + CHIP_H + headerH + _vpPAD
    return refresh
end

function M.init(cfg)
    _cfg = cfg or {}
    fxColor = _cfg.C.accent
    UIS2   = _cfg._SvcUIS
    RS2    = _cfg._SvcRS
    GS2    = game:GetService("GuiService")
    Mouse_ = _cfg.LocalPlayer and _cfg.LocalPlayer:GetMouse()
end

function M.applyTheme()
    fxColor = _cfg.C.accent
    applyCursorTheme_()
end

function M.buildSettingsUI(parentPage, extraCfg)
    twP = extraCfg and extraCfg.twP
    _vpY = 0

    local _ok_visualPage = pcall(function()
        visualSettingsPage = Instance.new("Frame", parentPage)
        visualSettingsPage.BackgroundTransparency = 1; visualSettingsPage.BorderSizePixel = 0
        visualSettingsPage.Visible = false

        _cfg._panelColorHooks[#_cfg._panelColorHooks + 1] = function()
            fxColor = _cfg.C.accent
            applyCursorTheme_()
        end

        _makeVtoggle("Custom Cursor", "native cursor FX", _VCOL(), false,
            function(on)
                fxEnabled = on; _setFxEnabled(on)
            end)

        _makeVslider("Cursor Size", "pixel", 16, 64, CURSOR_SIZE, _VCOL(), function(v, _, lbl)
            CURSOR_SIZE = math.floor(v + 0.5); lbl.Text = tostring(CURSOR_SIZE)
            if cursorImage_ then cursorImage_.Size = UDim2.fromOffset(
                math.floor(CURSOR_SIZE * cursorScale_ + 0.5), math.floor(CURSOR_SIZE * cursorScale_ + 0.5)) end
            if cursorShadow_ then cursorShadow_.Size = UDim2.fromOffset(
                math.floor(CURSOR_SIZE * cursorShadowScale_ + 0.5),
                    math.floor(CURSOR_SIZE * cursorShadowScale_ + 0.5)) end
        end)

        pcall(function()
            local EFF_ITEMS = {}
            for _, id in ipairs(EFFECT_ORDER) do
                table.insert(EFF_ITEMS, { id = id, label = id:sub(1, 1):upper() .. id:sub(2), sub = id })
            end

            local R1 = {}
            local R2 = {}

            for i, e in ipairs(EFF_ITEMS) do
                if i <= 7 then
                    R1[#R1 + 1] = e
                else
                    R2[#R2 + 1] = e
                end
            end

            local effRefreshFuncs = {}
            local function onEff(id)
                fxEffect = id
                if fxEnabled then
                    _startFxLoop()
                end
                for _, f in ipairs(effRefreshFuncs) do pcall(f) end
            end

            table.insert(effRefreshFuncs,
                _makeChipRow("FX Effect", R1, onEff, function() return fxEffect end))
            if #R2 > 0 then
                table.insert(effRefreshFuncs, _makeChipRow("", R2, onEff, function() return fxEffect end))
            end
        end)

        pcall(function()
            local THM = {}; for _, id in ipairs(THEME_ORDER) do table.insert(THM,
                    { id = id, label = id:sub(1, 1):upper() .. id:sub(2), sub = id }) end
            local T1, T2, T3 = {}, {}, {}
            for i, e in ipairs(THM) do if i <= 4 then table.insert(T1, e) elseif i <= 8 then table.insert(T2,
                        e) else table.insert(T3, e) end end

            local thmRefreshFuncs = {}
            local function onThm(id)
                cursorTheme = id; applyCursorTheme_()
                for _, f in ipairs(thmRefreshFuncs) do pcall(f) end
            end
            table.insert(thmRefreshFuncs,
                _makeChipRow("Cursor Theme", T1, onThm, function() return cursorTheme end))
            table.insert(thmRefreshFuncs, _makeChipRow("", T2, onThm, function() return cursorTheme end))
            table.insert(thmRefreshFuncs, _makeChipRow("", T3, onThm, function() return cursorTheme end))
        end)

        _makeVslider("Partikelmenge", "particle count", 0.35, 2.50, fxParticleAmount, _VCOL(),
            function(v, _, lbl)
                fxParticleAmount = math.clamp(v, 0.35, 2.50); lbl.Text = string.format("%d%%",
                    math.floor(v * 100 + 0.5))
            end)

        _makeVslider("Smoothness", "motion blur", 0.35, 0.92, fxSmoothness, _VCOL(),
            function(v, _, lbl)
                fxSmoothness = math.clamp(v, 0.35, 0.92); lbl.Text = string.format("%d%%",
                    math.floor(v * 100 + 0.5))
            end)

        _makeVslider("Tempo", "animation speed", 0.40, 1.80, fxSpeed, _VCOL(),
            function(v, _, lbl)
                fxSpeed = math.clamp(v, 0.40, 1.80); lbl.Text = string.format("%d%%", math.floor(v * 100 +
                0.5))
            end)

        pcall(function()
            local FX_COLORS = {
                { id = "white", label = "White", color = Color3.fromRGB(255, 255, 255) },
                { id = "lgray", label = "Silver", color = Color3.fromRGB(180, 185, 195) },
                { id = "gray", label = "Gray", color = Color3.fromRGB(110, 115, 125) },
                { id = "black", label = "Black", color = Color3.fromRGB(30, 30, 35) },
                { id = "red",  label = "Red",  color = Color3.fromRGB(255, 55, 80) },
                { id = "orange", label = "Orange", color = Color3.fromRGB(255, 140, 40) },
                { id = "yellow", label = "Yellow", color = Color3.fromRGB(255, 230, 40) },
                { id = "lime", label = "Lime", color = Color3.fromRGB(140, 255, 0) },
                { id = "green", label = "Green", color = _cfg.C.accent or Color3.fromRGB(0, 200, 255) },
                { id = "mint", label = "Mint", color = Color3.fromRGB(80, 255, 185) },
                { id = "cyan", label = "Cyan", color = Color3.fromRGB(0, 230, 230) },
                { id = "sky",  label = "Sky",  color = Color3.fromRGB(80, 190, 255) },
                { id = "blue", label = "Blue", color = Color3.fromRGB(60, 120, 255) },
                { id = "indigo", label = "Indigo", color = Color3.fromRGB(100, 100, 255) },
                { id = "purple", label = "Purple", color = Color3.fromRGB(185, 75, 255) },
                { id = "violet", label = "Violet", color = Color3.fromRGB(220, 80, 220) },
                { id = "rose", label = "Rose", color = Color3.fromRGB(255, 100, 160) },
                { id = "pink", label = "Pink", color = Color3.fromRGB(255, 155, 200) },
                { id = "gold", label = "Gold", color = Color3.fromRGB(255, 200, 0) },
                { id = "peach", label = "Peach", color = Color3.fromRGB(255, 175, 100) },
            }
            local activeFxColorId = "green"
            local secLbl = Instance.new("TextLabel", visualSettingsPage)
            secLbl.Size = UDim2.new(1, -16, 0, 16); secLbl.Position = UDim2.new(0, 8, 0, _vpY)
            secLbl.BackgroundTransparency = 1; secLbl.Text = "FX COLOR"
            secLbl.Font = Enum.Font.GothamBold; secLbl.TextSize = 11
            secLbl.TextColor3 = _cfg.C.sub; secLbl.TextXAlignment = Enum.TextXAlignment.Left
            _vpY = _vpY + 20
            local CHIP_W = math.floor((_cfg.PANEL_W - 16) / 5)
            local CHIP_H2 = 28
            local chipBtns = {}
            local function refreshChips()
                for _, cb in ipairs(chipBtns) do
                    local isActive = (cb.id == activeFxColorId)
                    cb.frame.BackgroundTransparency = isActive and 0.0 or 0.5
                    cb.stroke.Transparency = isActive and 0.15 or 0.7
                    cb.lbl.Font = isActive and Enum.Font.GothamBlack or Enum.Font.Gotham
                end
            end
            for row = 0, 3 do
                local rowFrame = Instance.new("Frame", visualSettingsPage)
                rowFrame.Size = UDim2.new(1, 0, 0, CHIP_H2)
                rowFrame.Position = UDim2.new(0, 0, 0, _vpY)
                rowFrame.BackgroundTransparency = 1; rowFrame.BorderSizePixel = 0
                for col = 0, 4 do
                    local idx = row * 5 + col + 1
                    local item = FX_COLORS[idx]
                    if not item then break end
                    local f = Instance.new("Frame", rowFrame)
                    f.Size = UDim2.new(0, CHIP_W - 4, 0, CHIP_H2 - 4)
                    f.Position = UDim2.new(0, col * (CHIP_W) + 2, 0, 2)
                    f.BackgroundColor3 = item.color
                    f.BackgroundTransparency = 0.5; f.BorderSizePixel = 0; _cfg.corner(f, 6)
                    local fs = _cfg._makeDummyStroke(f)
                    fs.Thickness = 1.5; fs.Color = item.color; fs.Transparency = 0.7
                    fs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    local fl = Instance.new("TextLabel", f)
                    fl.Size = UDim2.new(1, 0, 1, 0); fl.BackgroundTransparency = 1
                    fl.Text = item.label; fl.Font = Enum.Font.Gotham; fl.TextSize = 9
                    fl.TextColor3 = Color3.fromRGB(240, 242, 248); fl.TextXAlignment = Enum.TextXAlignment
                    .Center
                    local fb = Instance.new("TextButton", f)
                    fb.Size = UDim2.new(1, 0, 1, 0); fb.BackgroundTransparency = 1; fb.Text = ""; fb.ZIndex = 8
                    local capId = item.id; local capColor = item.color
                    local function activate()
                        activeFxColorId = capId
                        fxColor = capColor
                        applyCursorTheme_()
                        refreshChips()
                    end
                    fb.MouseButton1Click:Connect(activate)
                    fb.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then activate() end
                    end)
                    fb.MouseEnter:Connect(function()
                        _cfg._sc._playHoverSound(); f.BackgroundTransparency = 0.15
                    end)
                    fb.MouseLeave:Connect(function()
                        f.BackgroundTransparency = (activeFxColorId == capId) and 0.0 or 0.5
                    end)
                    table.insert(chipBtns, { id = item.id, frame = f, stroke = fs, lbl = fl })
                end
                _vpY = _vpY + CHIP_H2 + 4
            end
            refreshChips()
        end)

        visualSettingsPage.Size = UDim2.new(1, 0, 0, _vpY)
    end)
end

return M
