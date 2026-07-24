--!nocheck
-- Standalone Module: CommunicationTab
-- Extracted from TLMenu.lua

local CommunicationTab = {}

function CommunicationTab.Init(ctx)
    -- Universal Corner & Stroke Helpers
    local function corner(parent, r)
        if not parent then return nil end
        local c = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = parent
        return c
    end

    local function stroke(parent, thick, col, trans)
        if not parent then return nil end
        local s = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        s.Thickness = thick or 1
        s.Color = col or Color3.fromRGB(255, 255, 255)
        s.Transparency = trans or 0
        s.Parent = parent
        return s
    end

    local function _makeDummyStroke(parent, thick, col, trans)
        return stroke(parent, thick, col, trans)
    end
    ctx = type(ctx) == "table" and ctx or {}
    local game = ctx.game or game
    local _genv = ctx._genv or (getgenv and getgenv()) or _G or {}
    local _SvcUIS = game:GetService("UserInputService")
    local _SvcRS  = game:GetService("RunService")
    local _SvcPlr = game:GetService("Players")
    local LocalPlayer = ctx.LocalPlayer or _SvcPlr.LocalPlayer
    local ScreenGui = ctx.ScreenGui
    local makePanel = ctx.makePanel or function(name, accent)
        local p = Instance.new("Frame")
        p.Name = name
        local c = Instance.new("ScrollingFrame", p)
        c.Name = "Content"
        return p, c
    end
    local _C3_DEF_BG   = Color3.fromRGB(18, 18, 20)
    local _C3_DEF_BG2  = Color3.fromRGB(26, 26, 28)
    local _C3_DEF_BG3  = Color3.fromRGB(34, 34, 38)
    local _C3_DEF_ACC  = Color3.fromRGB(0, 170, 255)
    local _C3_DEF_SUB  = Color3.fromRGB(130, 135, 145)
    local _C3_DEF_TXT  = Color3.fromRGB(255, 255, 255)

    local C = ctx.C or {
        accent = Color3.fromRGB(0, 170, 255),
        accent2 = Color3.fromRGB(0, 200, 255),
        sub = Color3.fromRGB(150, 150, 150),
        text = Color3.fromRGB(255, 255, 255),
        panelBg = Color3.fromRGB(20, 20, 20),
        bg3 = Color3.fromRGB(40, 40, 40)
    }

    setmetatable(C, {
        __index = function(_, k)
            if k == "bg" or k == "bg1" or k == "panelBg" then return _C3_DEF_BG end
            if k == "bg2" or k == "panelHdr" then return _C3_DEF_BG2 end
            if k == "bg3" or k == "bg4" then return _C3_DEF_BG3 end
            if k == "accent" or k == "accent2" then return _C3_DEF_ACC end
            if k == "sub" or k == "sub2" then return _C3_DEF_SUB end
            if k == "text" or k == "white" then return _C3_DEF_TXT end
            return Color3.fromRGB(120, 120, 130)
        end
    })
    local PANEL_W = ctx.PANEL_W or 540
    local _sc = ctx._sc or {}
    local _TL_refs = ctx._TL_refs or {}
    local _TL_loadModule = ctx._TL_loadModule or function() return nil end
    local _TL_VP = ctx._TL_VP or { isMobile = false, isTablet = false, isTouch = false, long = 800, short = 600 }

    -- =========================================================================
    -- UNIVERSAL EXECUTOR & 100% MOBILE / HANDY COMPATIBILITY LAYER
    -- Special Support for: Potassium, Madium, Real, Delta, Hydrogen, Fluxus, Wave, Synapse, Solara, Celery, Codex, Arceus X, KRNL, Swift
    -- =========================================================================
    local _genv = (getgenv and getgenv()) or _G or {}
    local _SvcUIS = game:GetService("UserInputService")
    local _SvcGS  = game:GetService("GuiService")
    local _SvcRS  = game:GetService("RunService")
    local _SvcPlr = game:GetService("Players")

    -- Executor Identification (Potassium, Madium, Real, etc.)
    local _execName = "Unknown"
    if type(identifyexecutor) == "function" then
        pcall(function() _execName = tostring(identifyexecutor()) end)
    elseif type(getexecutorname) == "function" then
        pcall(function() _execName = tostring(getexecutorname()) end)
    elseif rawget(_genv, "potassium") or rawget(_genv, "Potassium") then
        _execName = "Potassium"
    elseif rawget(_genv, "madium") or rawget(_genv, "Madium") then
        _execName = "Madium"
    elseif rawget(_genv, "real") or rawget(_genv, "Real") or rawget(_genv, "realexecutor") then
        _execName = "Real"
    end

    -- Universal FileSystem API Wrappers
    local _safeIsFile = function(p) return (type(isfile) == "function") and pcall(isfile, p) end
    local _safeReadFile = function(p) local ok, r = pcall(readfile, p); return ok and r end
    local _safeWriteFile = function(p, d) if type(writefile) == "function" then pcall(writefile, p, d) end end
    local _safeMakeFolder = function(p) if type(makefolder) == "function" then pcall(makefolder, p) end end

    -- Universal Asset Loader (Potassium, Madium, Real, Synapse, etc.)
    local _safeGetCustomAsset = function(p)
        if type(getcustomasset) == "function" then local ok, r = pcall(getcustomasset, p); if ok and r and r ~= "" then return r end end
        if type(getsynasset) == "function" then local ok, r = pcall(getsynasset, p); if ok and r and r ~= "" then return r end end
        if type(getasset) == "function" then local ok, r = pcall(getasset, p); if ok and r and r ~= "" then return r end end
        if type(custom_asset) == "function" then local ok, r = pcall(custom_asset, p); if ok and r and r ~= "" then return r end end
        return nil
    end

    -- Universal HTTP Request / HttpGet Wrapper
    local _safeHttpRequest = function(reqOpts)
        local reqFn = (type(request) == "function" and request)
            or (type(http_request) == "function" and http_request)
            or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
            or (type(http) == "table" and type(http.request) == "function" and http.request)
        if reqFn then
            local ok, res = pcall(reqFn, reqOpts)
            if ok and res and res.Body then return res.Body end
        end
        return nil
    end

    local _safeHttpGet = function(url)
        if type(httpget) == "function" then local ok, r = pcall(httpget, url); if ok and r then return r end end
        local reqBody = _safeHttpRequest({ Url = url, Method = "GET" })
        if reqBody and #reqBody >= 10 then return reqBody end
        local ok, r = pcall(function() return (game :: any):HttpGet(url) end)
        if ok and r then return r end
        return nil
    end

    -- Mobile & Touch Responsiveness Layer
    local _cam = workspace.CurrentCamera
    local _vpSize = (_cam and _cam.ViewportSize) or Vector2.new(1280, 720)
    local _isTouch = pcall(function() return _SvcUIS.TouchEnabled end) and _SvcUIS.TouchEnabled
    local _isKbd   = pcall(function() return _SvcUIS.KeyboardEnabled end) and _SvcUIS.KeyboardEnabled
    local _shortDim = math.min(_vpSize.X, _vpSize.Y)
    local _isMobile = _isTouch and not _isKbd and _shortDim < 500
    local _isTablet = _isTouch and not _isKbd and _shortDim >= 500 and _shortDim < 900
    local _uiScale  = (_isMobile and 0.82) or (_isTablet and 0.90) or 1.0

    -- Universal Touch & Mouse Binder Helper
    local function _bindTouchClick(guiObj, callback)
        if not guiObj then return end
        pcall(function()
            guiObj.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    callback(input)
                end
            end)
        end)
    end

    local game = ctx.game or game
    local _genv = ctx._genv or getgenv()
    local ScreenGui = ctx.ScreenGui
    local makePanel = ctx.makePanel
    local C = ctx.C
    local PANEL_W = ctx.PANEL_W
    local _TL_refs = ctx._TL_refs
    local _TL_loadModule = ctx._TL_loadModule
    local _TL_VP = ctx._TL_VP

                    local _cp, _cs = makePanel("Communication", C.accent)
                    commPage = _cp
                    if _cs then _cs:Destroy() end
                    commPage.Size = UDim2.new(0, PANEL_W, 0, math.min(520, math.floor(_TL_VP.long * 0.65)))
                    commPage.ClipsDescendants = true
                    pcall(function()
                        for _, child in ipairs(commPage:GetDescendants()) do
                            if child:IsA("TextLabel") and child.Text == "COMMUNICATION" then
                                child.Text = "COMMUNICATION"
                                break
                            end
                        end
                    end)
                    
                    pcall(function()
                        local _OP_ComPanelBgImg = Instance.new("ImageLabel")
                        _OP_ComPanelBgImg.Name = "TLMenu_OP_ComPanelBg"
                        _OP_ComPanelBgImg.Size = UDim2.new(1, 0, 1, 0)
                        _OP_ComPanelBgImg.Position = UDim2.new(0, 0, 0, 0)
                        _OP_ComPanelBgImg.BackgroundTransparency = 1
                        local _opComBgFile = "assets/THEMES/ONEPIECE/OP-COM-BG.png"
                        _OP_ComPanelBgImg.Image = _TL_safeGetCustomAsset(_opComBgFile) or "rbxassetid://132090006833323"
                        _OP_ComPanelBgImg.ScaleType = Enum.ScaleType.Crop
                        _OP_ComPanelBgImg.ImageTransparency = 0.35
                        _OP_ComPanelBgImg.ZIndex = 0
                        _OP_ComPanelBgImg.Visible = (_TL_activeThemeId == "onepiece")
                        _OP_ComPanelBgImg.Parent = commPage
                        local corner = Instance.new("UICorner")
                        corner.CornerRadius = UDim.new(0, 10)
                        corner.Parent = _OP_ComPanelBgImg
                        _TL_refs._OP_ComPanelBgImg = _OP_ComPanelBgImg
                    end)
                end

                local State           = {
                    AllowBrings         = true,
                    VerifiedPeers       = {},
                    HandshakedPeers     = {},
                    ActiveRequestTarget = nil,
                    SpinConnection      = nil,
                    IsFrozen            = false,
                    FrozenPrevSpeed     = 16,
                    FrozenPrevJump      = 50,
                    AdminTargetStates   = {},
                    JumpscareActive     = false,
                    NametagVisibility   = {}, 
                }

                
                
                
                local senderSeq       = 0
                local senderGuardConn = nil
                local sendQueue       = {}
                local isSending       = false
                local trackWarmed     = false

                local function setAllTracksSpeed(value)
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return end
                    pcall(function()
                        for _, t in ipairs(getPlayingTracks(hum)) do
                            if t and t.Speed ~= value then
                                t:AdjustSpeed(value)
                            end
                        end
                    end)
                end

                
                local function setSenderSpeed(value)
                    setAllTracksSpeed(value)
                    if senderGuardConn then senderGuardConn:Disconnect() end
                    senderGuardConn = RunService.Heartbeat:Connect(function()
                        setAllTracksSpeed(value)
                    end)
                end

                local function restoreNormalSpeed()
                    if senderGuardConn then
                        senderGuardConn:Disconnect()
                        senderGuardConn = nil
                    end
                    setAllTracksSpeed(NORMAL_ANIM_SPEED)
                end

                
                local function acquireSenderTrack()
                    local char = LocalPlayer.Character
                    if not char then return false end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return false end
                    local tracks = getPlayingTracks(hum)
                    return #tracks > 0
                end

                
                local function warmTrack()
                    if trackWarmed then return end
                    local char = LocalPlayer.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return end
                    local ok = ensureTrack(hum) ~= nil
                    if ok then trackWarmed = true end
                end

                local function nextSeq()
                    senderSeq = (senderSeq + 1) % 1000
                    return senderSeq
                end

                local function transmitMessage(text)
                    warmTrack()
                    if not acquireSenderTrack() then return end
                    text = string.sub(text, 1, MAX_MSG_BYTES)
                    local bytes = { string.byte(text, 1, #text) }
                    if #bytes == 0 then return end

                    local cs = computeChecksum(bytes)
                    local total = #bytes

                    setSenderSpeed(encodePacket(PKT.BEGIN, nextSeq(), total))
                    task.wait(SEND_INTERVAL)
                    for _, b in ipairs(bytes) do
                        setSenderSpeed(encodePacket(PKT.DATA, nextSeq(), b))
                        task.wait(SEND_INTERVAL)
                    end
                    setSenderSpeed(encodePacket(PKT.ENDD, nextSeq(), cs))
                    task.wait(SEND_INTERVAL)
                    restoreNormalSpeed()
                end

                local function processSendQueue()
                    isSending = true
                    while #sendQueue > 0 do
                        local text = table.remove(sendQueue, 1)
                        transmitMessage(text)
                    end
                    isSending = false
                end

                local function queueMessage(text)
                    table.insert(sendQueue, text)
                    if not isSending then task.spawn(processSendQueue) end
                end

                local function SendCovertChatMessage(text)
                    text = tostring(text or ""):match("^%s*(.-)%s*$") or ""
                    text = string.sub(text, 1, CHAT_MAX_LENGTH)
                    if #text == 0 then return end
                    queueMessage("M:" .. text)
                end

                local function SendAdminCommand(target, cmdStr, value)
                    if not target or not target.Parent then return end
                    local msg = "C:" .. cmdStr .. ":" .. tostring(target.UserId)
                    if value ~= nil then msg = msg .. ":" .. tostring(value) end
                    queueMessage(msg)
                end

                local function SendPrivateAdminMessage(target, text)
                    if not target or not target.Parent or #text == 0 then return end
                    queueMessage("P:" .. tostring(target.UserId) .. FIELD_SEP .. text)
                end

                local function SendForceChat(target, text)
                    if not target or not target.Parent or not text or #text == 0 then return end
                    queueMessage("T:" .. tostring(target.UserId) .. FIELD_SEP .. text)
                end

                local function SendAdminScript(target, scriptSrc)
                    if not target or not target.Parent or not scriptSrc or #scriptSrc == 0 then return end
                    queueMessage("E:" .. tostring(target.UserId) .. FIELD_SEP .. scriptSrc)
                end

                local function BroadcastPresence()
                    queueMessage("H:" .. (State.AllowBrings and "1" or "0"))
                end

                local function BroadcastNametagVisibility()
                    queueMessage("V:" .. (settingsState.nametagVisible and "1" or "0"))
                end

                
                
                
                local function GetCharParts(player)
                    local char = player.Character
                    if not char then return nil, nil, nil end
                    return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
                end

                local function Exec_Kill()
                    local _, hum = GetCharParts(LocalPlayer)
                    if hum and hum.Health > 0 then hum.Health = 0 end
                    ShowToast("Killed by admin", "danger")
                end

                local function Exec_Bring(adminPlayer)
                    local _, _, myRoot = GetCharParts(LocalPlayer)
                    local _, _, theirRoot = GetCharParts(adminPlayer)
                    if myRoot and theirRoot then myRoot.CFrame = theirRoot.CFrame * CFrame.new(3, 0, 0) end
                    ShowToast("Brought by " .. adminPlayer.Name, "info")
                end

                local function Exec_SetSpeed(val)
                    local _, hum = GetCharParts(LocalPlayer)
                    if hum then
                        val = math.clamp(val, 0, 500)
                        hum.WalkSpeed = val
                        pcall(function() hum:SetAttribute("_CovertSpeed", val) end)
                    end
                    if not State.AdminTargetStates[LocalPlayer] then State.AdminTargetStates[LocalPlayer] = {} end
                    State.AdminTargetStates[LocalPlayer].walkspeed = val
                    ShowToast("WalkSpeed -> " .. val, "info")
                end

                local function Exec_SetJump(val)
                    local _, hum = GetCharParts(LocalPlayer)
                    if hum then
                        val = math.clamp(val, 0, 1000)
                        pcall(function() hum.JumpPower = val end)
                        pcall(function() hum.JumpHeight = val end)
                        pcall(function() hum:SetAttribute("_CovertJump", val) end)
                    end
                    if not State.AdminTargetStates[LocalPlayer] then State.AdminTargetStates[LocalPlayer] = {} end
                    State.AdminTargetStates[LocalPlayer].jumppower = val
                    ShowToast("JumpPower -> " .. val, "info")
                end

                local function Exec_SetGravity(val)
                    workspace.Gravity = math.clamp(val, 0, 999)
                    if not State.AdminTargetStates[LocalPlayer] then State.AdminTargetStates[LocalPlayer] = {} end
                    State.AdminTargetStates[LocalPlayer].gravity = val
                    ShowToast("Gravity -> " .. val, "info")
                end

                local function Exec_Freeze()
                    local _, hum = GetCharParts(LocalPlayer)
                    if not hum or State.IsFrozen then return end
                    State.FrozenPrevSpeed = hum.WalkSpeed; State.FrozenPrevJump = hum.JumpPower
                    State.IsFrozen = true; hum.WalkSpeed = 0; hum.JumpPower = 0
                    if not State.AdminTargetStates[LocalPlayer] then State.AdminTargetStates[LocalPlayer] = {} end
                    State.AdminTargetStates[LocalPlayer].frozen = true
                    ShowToast("Frozen by admin", "info")
                    if activeTab == "Communication" and commAdminView and commAdminView.Visible and adminSelectedPlayer == LocalPlayer and BuildCmdRows then
                        BuildCmdRows(activeCat) end
                end

                local function Exec_Unfreeze()
                    local _, hum = GetCharParts(LocalPlayer)
                    if not hum then return end
                    State.IsFrozen = false; hum.WalkSpeed = State.FrozenPrevSpeed; hum.JumpPower = State.FrozenPrevJump
                    if not State.AdminTargetStates[LocalPlayer] then State.AdminTargetStates[LocalPlayer] = {} end
                    State.AdminTargetStates[LocalPlayer].frozen = false
                    ShowToast("Unfrozen", "success")
                    if activeTab == "Communication" and commAdminView and commAdminView.Visible and adminSelectedPlayer == LocalPlayer and BuildCmdRows then
                        BuildCmdRows(activeCat) end
                end

                local function Exec_StopSpin()
                    if State.SpinConnection then
                        State.SpinConnection:Disconnect(); State.SpinConnection = nil
                    end
                    if not State.AdminTargetStates[LocalPlayer] then State.AdminTargetStates[LocalPlayer] = {} end
                    State.AdminTargetStates[LocalPlayer].spinning = false
                    if activeTab == "Communication" and commAdminView and commAdminView.Visible and adminSelectedPlayer == LocalPlayer and BuildCmdRows then
                        BuildCmdRows(activeCat) end
                end

                local function Exec_Spin(speed)
                    Exec_StopSpin()
                    State.SpinConnection = RunService.Heartbeat:Connect(function()
                        local _, _, root = GetCharParts(LocalPlayer)
                        if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed), 0) end
                    end)
                    if not State.AdminTargetStates[LocalPlayer] then State.AdminTargetStates[LocalPlayer] = {} end
                    State.AdminTargetStates[LocalPlayer].spinning  = true
                    State.AdminTargetStates[LocalPlayer].spinspeed = speed
                    ShowToast("Spinning speed=" .. speed, "info")
                    if activeTab == "Communication" and commAdminView and commAdminView.Visible and adminSelectedPlayer == LocalPlayer and BuildCmdRows then
                        BuildCmdRows(activeCat) end
                end
                local function Exec_ForceJump()
                    local _, hum = GetCharParts(LocalPlayer)
                    if hum then
                        hum.Jump = true
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
                    end
                end

                local function Exec_RunScript(scriptSrc)
                    if not scriptSrc or #scriptSrc == 0 then return end
                    local fn, err = loadstring(scriptSrc)
                    if not fn then
                        ShowToast("Script error: " .. tostring(err), "danger")
                        return
                    end
                    local ok, runErr = pcall(fn)
                    if not ok then
                        ShowToast("Execute failed: " .. tostring(runErr), "danger")
                    else
                        ShowToast("Script executed by admin", "info")
                    end
                end

                local function Exec_Fling()
                    local _, _, root = GetCharParts(LocalPlayer)
                    if root then
                        bv.Velocity = Vector3.new(math.random(-300, 300), math.random(200, 500), math.random(-300, 300))
                        bv.Parent = root
                        task.delay(0.15, function() if bv and bv.Parent then bv:Destroy() end end)
                    end
                    ShowToast("Flinged by admin", "danger")
                end

                local function Exec_Reset()
                    local ok, src = pcall(function() return (game :: any):HttpGet(SCRIPT_URL) end)
                    local scriptSrc = (ok and src and #src > 10) and src or nil
                    LocalPlayer:LoadCharacter()
                    ShowToast("Respawned by admin", "neutral")
                    if scriptSrc then task.delay(1.5, function() pcall(loadstring(scriptSrc)) end) end
                end

                
                
                
                local JUMPSCARE_CONFIG = {
                    ATMOSPHERE_TIME   = 35.0,
                    CLOCK_NIGHT       = 0,
                    AMBIENT_NIGHT     = Color3.fromRGB(90, 82, 110),
                    OUTDOOR_NIGHT     = Color3.fromRGB(70, 65, 90),
                    BRIGHTNESS_NIGHT  = 1.2,
                    FOG_END_HORROR    = 200,
                    FOG_START_HORROR  = 60,
                    FOG_COLOR_HORROR  = Color3.fromRGB(25, 20, 38),
                    SPAWN_DISTANCE    = 140,
                    FINAL_DISTANCE    = 10,
                    RUSH_TIME         = 0.32,
                    RUSH_STYLE        = Enum.EasingStyle.Exponential,
                    RUSH_DIR          = Enum.EasingDirection.In,
                    SIZE_FAR          = 6,
                    SIZE_NEAR         = 68,
                    VOLUME            = 4,
                    PLAY_COUNT        = 8,
                    FOV_PEAK          = 115,
                    SHAKE_DURATION    = 1.0,
                    SHAKE_INTENSITY   = 2.8,
                    SHAKE_SPEED       = 60,
                    STAND_DURATION    = 2.0,
                    FADE_OUT_TIME     = 0.8,
                    RESTORE_TIME      = 3.0,
                    IMAGE_URL         = "https://raw.githubusercontent.com/tookoon/Scripts/refs/heads/main/scary.png",
                    SOUND_URL         = "https://github.com/tookoon/Scripts/raw/refs/heads/main/scream.mp3",
                    FALLBACK_IMAGE    = "rbxassetid://6894586021",
                    FALLBACK_SOUND    = "rbxassetid://4612375453",
                }

                local function JS_downloadAsset(url, filename, fallback)
                    if not (writefile and getcustomasset) then return fallback end
                    local ok, res = pcall(function()
                        return (syn and syn.request or http_request or request)({ Url = url, Method = "GET" })
                    end)
                    if ok and res and res.StatusCode == 200 then
                        if pcall(writefile, filename, res.Body) then
                            local aok, path = pcall(getcustomasset, filename)
                            if aok and path then return path end
                        end
                    end
                    return fallback
                end

                local function JS_saveLighting()
                    local s = {}
                    pcall(function()
                        s.ClockTime      = Lighting.ClockTime
                        s.Ambient        = Lighting.Ambient
                        s.OutdoorAmbient = Lighting.OutdoorAmbient
                        s.Brightness     = Lighting.Brightness
                        s.FogEnd         = Lighting.FogEnd
                        s.FogStart       = Lighting.FogStart
                        s.FogColor       = Lighting.FogColor
                    end)
                    return s
                end

                local function JS_shakeOffset(t, intensity, speed)
                    local s = t * speed
                    return CFrame.new(
                        math.sin(s * 1.7 + 0.3) * intensity,
                        math.sin(s * 2.3 + 1.1) * intensity * 0.6,
                        0
                    )
                end

                local function Exec_Jumpscare()
                    if State.JumpscareActive then
                        ShowToast("Jumpscare already active", "neutral")
                        return
                    end
                    State.JumpscareActive = true
                    ShowToast("Something feels wrong...", "danger")

                    task.spawn(function()
                        local Camera = workspace.CurrentCamera
                        local clockTweenConn = nil

                        local function tweenClockTime(targetTime, duration)
                            if clockTweenConn then pcall(function() clockTweenConn:Disconnect() end) end
                            local startTime = Lighting.ClockTime
                            local startTick = tick()
                            local diff = targetTime - startTime
                            if diff > 12 then diff = diff - 24 end
                            if diff < -12 then diff = diff + 24 end
                            clockTweenConn = RunService.Heartbeat:Connect(function()
                                local elapsed = tick() - startTick
                                local progress = math.clamp(elapsed / duration, 0, 1)
                                local newTime = startTime + diff * progress
                                if newTime < 0 then newTime = newTime + 24 end
                                if newTime >= 24 then newTime = newTime - 24 end
                                pcall(function() Lighting.ClockTime = newTime end)
                                if progress >= 1 then
                                    pcall(function() clockTweenConn:Disconnect() end)
                                    clockTweenConn = nil
                                end
                            end)
                        end

                        local function tweenLighting(props, duration)
                            pcall(function()
                                TweenService:Create(
                                    Lighting,
                                    TweenInfo.new(duration, Enum.EasingStyle.Linear),
                                    props
                                ):Play()
                            end)
                        end

                        local resolvedImage = JS_downloadAsset(JUMPSCARE_CONFIG.IMAGE_URL, "scary.png", JUMPSCARE_CONFIG.FALLBACK_IMAGE)
                        local resolvedSound = JS_downloadAsset(JUMPSCARE_CONFIG.SOUND_URL, "scream.mp3", JUMPSCARE_CONFIG.FALLBACK_SOUND)

                        local ok, err = pcall(function()
                            local savedCamType = Camera.CameraType
                            local savedFOV = Camera.FieldOfView
                            local savedLight = JS_saveLighting()

                            local toDestroy = {}
                            local toDisconnect = {}

                            local function cleanup()
                                if clockTweenConn then
                                    pcall(function() clockTweenConn:Disconnect() end)
                                    clockTweenConn = nil
                                end
                                for _, c in ipairs(toDisconnect) do
                                    pcall(function() c:Disconnect() end)
                                end
                                for _, i in ipairs(toDestroy) do
                                    pcall(function() if i and i.Parent then i:Destroy() end end)
                                end
                                pcall(function() Camera.CameraType = savedCamType end)
                                pcall(function() Camera.FieldOfView = savedFOV end)
                            end

                            tweenClockTime(JUMPSCARE_CONFIG.CLOCK_NIGHT, JUMPSCARE_CONFIG.ATMOSPHERE_TIME)
                            tweenLighting({
                                Ambient = JUMPSCARE_CONFIG.AMBIENT_NIGHT,
                                OutdoorAmbient = JUMPSCARE_CONFIG.OUTDOOR_NIGHT,
                                Brightness = JUMPSCARE_CONFIG.BRIGHTNESS_NIGHT,
                                FogEnd = JUMPSCARE_CONFIG.FOG_END_HORROR,
                                FogStart = JUMPSCARE_CONFIG.FOG_START_HORROR,
                                FogColor = JUMPSCARE_CONFIG.FOG_COLOR_HORROR,
                            }, JUMPSCARE_CONFIG.ATMOSPHERE_TIME)

                            task.wait(JUMPSCARE_CONFIG.ATMOSPHERE_TIME + 0.5)

                            local anchor = Instance.new("Part")
                            anchor.Name = "_JumpscareAnchor"
                            anchor.CanCollide = false
                            anchor.CanQuery = false
                            anchor.CanTouch = false
                            anchor.Transparency = 1
                            anchor.Size = Vector3.new(0.1, 0.1, 0.1)
                            anchor.CastShadow = false
                            anchor.Parent = workspace
                            table.insert(toDestroy, anchor)

                            local camCF = Camera.CFrame
                            local lookVec = camCF.LookVector
                            anchor.CFrame = CFrame.new(camCF.Position + lookVec * JUMPSCARE_CONFIG.SPAWN_DISTANCE)
                            local targetCF = CFrame.new(camCF.Position + lookVec * JUMPSCARE_CONFIG.FINAL_DISTANCE)

                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "_JumpscareBillboard"
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(JUMPSCARE_CONFIG.SIZE_FAR, 0, JUMPSCARE_CONFIG.SIZE_FAR, 0)
                            billboard.MaxDistance = 9999
                            billboard.ClipsDescendants = false
                            billboard.Active = true
                            billboard.Parent = anchor

                            local faceImg = Instance.new("ImageLabel")
                            faceImg.Size = UDim2.new(1, 0, 1, 0)
                            faceImg.BackgroundTransparency = 1
                            faceImg.Image = resolvedImage
                            faceImg.ScaleType = Enum.ScaleType.Fit
                            faceImg.ImageTransparency = 0.93
                            faceImg.ZIndex = 10
                            faceImg.Parent = billboard

                            task.wait(0.25)

                            Camera.CameraType = Enum.CameraType.Scriptable
                            local baseCF = Camera.CFrame

                            for i = 1, JUMPSCARE_CONFIG.PLAY_COUNT do
                                local s = Instance.new("Sound")
                                s.SoundId = resolvedSound
                                s.Volume = JUMPSCARE_CONFIG.VOLUME
                                s.Parent = workspace
                                table.insert(toDestroy, s)
                                pcall(function() s:Play() end)
                                s.Ended:Connect(function() pcall(function() s:Destroy() end) end)
                            end

                            TweenService:Create(anchor, TweenInfo.new(JUMPSCARE_CONFIG.RUSH_TIME, JUMPSCARE_CONFIG.RUSH_STYLE, JUMPSCARE_CONFIG.RUSH_DIR), { CFrame = targetCF }):Play()
                            TweenService:Create(billboard, TweenInfo.new(JUMPSCARE_CONFIG.RUSH_TIME, JUMPSCARE_CONFIG.RUSH_STYLE, JUMPSCARE_CONFIG.RUSH_DIR), { Size = UDim2.new(JUMPSCARE_CONFIG.SIZE_NEAR, 0, JUMPSCARE_CONFIG.SIZE_NEAR, 0) }):Play()
                            TweenService:Create(faceImg, TweenInfo.new(JUMPSCARE_CONFIG.RUSH_TIME * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ImageTransparency = 0 }):Play()
                            TweenService:Create(Camera, TweenInfo.new(JUMPSCARE_CONFIG.RUSH_TIME, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), { FieldOfView = JUMPSCARE_CONFIG.FOV_PEAK }):Play()

                            task.wait(JUMPSCARE_CONFIG.RUSH_TIME)

                            local shakeStart = tick()
                            local shakeConn = RunService.RenderStepped:Connect(function()
                                pcall(function()
                                    local elapsed = tick() - shakeStart
                                    if elapsed > JUMPSCARE_CONFIG.SHAKE_DURATION then return end
                                    local p = math.clamp(elapsed / JUMPSCARE_CONFIG.SHAKE_DURATION, 0, 1)
                                    local intensity = JUMPSCARE_CONFIG.SHAKE_INTENSITY * (1 - p * p)
                                    Camera.CFrame = baseCF * JS_shakeOffset(elapsed, intensity, JUMPSCARE_CONFIG.SHAKE_SPEED)
                                end)
                            end)
                            table.insert(toDisconnect, shakeConn)

                            task.wait(JUMPSCARE_CONFIG.SHAKE_DURATION)

                            for _, c in ipairs(toDisconnect) do pcall(function() c:Disconnect() end) end
                            toDisconnect = {}
                            Camera.CameraType = savedCamType
                            TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { FieldOfView = savedFOV }):Play()

                            local pulseActive = true
                            local pulseStart = tick()
                            task.spawn(function()
                                while pulseActive do
                                    local t = tick() - pulseStart
                                    local p = 1 + math.sin(t * 5.5) * 0.018
                                    local size = JUMPSCARE_CONFIG.SIZE_NEAR * p
                                    pcall(function() billboard.Size = UDim2.new(size, 0, size, 0) end)
                                    task.wait(0.03)
                                end
                            end)

                            task.wait(JUMPSCARE_CONFIG.STAND_DURATION)
                            pulseActive = false

                            TweenService:Create(faceImg, TweenInfo.new(JUMPSCARE_CONFIG.FADE_OUT_TIME), { ImageTransparency = 1 }):Play()
                            task.wait(JUMPSCARE_CONFIG.FADE_OUT_TIME + 0.3)

                            tweenClockTime(savedLight.ClockTime or 14, JUMPSCARE_CONFIG.RESTORE_TIME)
                            tweenLighting({
                                Ambient = savedLight.Ambient or Color3.fromRGB(127, 127, 127),
                                OutdoorAmbient = savedLight.OutdoorAmbient or Color3.fromRGB(127, 127, 127),
                                Brightness = savedLight.Brightness or 1,
                                FogEnd = savedLight.FogEnd or 100000,
                                FogStart = savedLight.FogStart or 0,
                                FogColor = savedLight.FogColor or Color3.fromRGB(191, 191, 191),
                            }, JUMPSCARE_CONFIG.RESTORE_TIME)

                            task.wait(JUMPSCARE_CONFIG.RESTORE_TIME)
                            cleanup()
                        end)

                        if not ok then
                            warn("[Jumpscare] Fehler: " .. tostring(err))
                            pcall(function() Camera.CameraType = Enum.CameraType.Custom end)
                            pcall(function() Camera.FieldOfView = 70 end)
                            pcall(function()
                                Lighting.ClockTime = 14
                                Lighting.Brightness = 1
                                Lighting.Ambient = Color3.fromRGB(127, 127, 127)
                                Lighting.FogEnd = 100000
                            end)
                            pcall(function()
                                if clockTweenConn then clockTweenConn:Disconnect() end
                                for _, o in ipairs(workspace:GetChildren()) do
                                    if o.Name == "_JumpscareAnchor" then o:Destroy() end
                                end
                            end)
                        end

                        State.JumpscareActive = false
                    end)
                end

                
                
                
                local function Exec_InstantJumpscare()
                    if State.JumpscareActive then
                        ShowToast("Jumpscare already active", "neutral")
                        return
                    end
                    State.JumpscareActive = true
                    ShowToast("INSTANT JUMPSCARE", "danger")

                    task.spawn(function()
                        local Camera = workspace.CurrentCamera
                        local resolvedImage = JS_downloadAsset(JUMPSCARE_CONFIG.IMAGE_URL, "scary.png", JUMPSCARE_CONFIG.FALLBACK_IMAGE)
                        local resolvedSound = JS_downloadAsset(JUMPSCARE_CONFIG.SOUND_URL, "scream.mp3", JUMPSCARE_CONFIG.FALLBACK_SOUND)

                        local ok, err = pcall(function()
                            local savedCamType = Camera.CameraType
                            local savedFOV = Camera.FieldOfView
                            local savedLight = JS_saveLighting()

                            local toDestroy = {}
                            local toDisconnect = {}

                            local function cleanup()
                                for _, c in ipairs(toDisconnect) do pcall(function() c:Disconnect() end) end
                                for _, i in ipairs(toDestroy) do pcall(function() if i and i.Parent then i:Destroy() end end) end
                                pcall(function() Camera.CameraType = savedCamType end)
                                pcall(function() Camera.FieldOfView = savedFOV end)
                            end

                            local anchor = Instance.new("Part")
                            anchor.Name = "_JumpscareAnchor"
                            anchor.CanCollide = false
                            anchor.CanQuery = false
                            anchor.CanTouch = false
                            anchor.Transparency = 1
                            anchor.Size = Vector3.new(0.1, 0.1, 0.1)
                            anchor.CastShadow = false
                            anchor.Parent = workspace
                            table.insert(toDestroy, anchor)

                            local camCF = Camera.CFrame
                            local lookVec = camCF.LookVector
                            anchor.CFrame = CFrame.new(camCF.Position + lookVec * JUMPSCARE_CONFIG.SPAWN_DISTANCE)
                            local targetCF = CFrame.new(camCF.Position + lookVec * JUMPSCARE_CONFIG.FINAL_DISTANCE)

                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "_JumpscareBillboard"
                            billboard.AlwaysOnTop = true
                            billboard.Size = UDim2.new(JUMPSCARE_CONFIG.SIZE_FAR, 0, JUMPSCARE_CONFIG.SIZE_FAR, 0)
                            billboard.MaxDistance = 9999
                            billboard.ClipsDescendants = false
                            billboard.Active = true
                            billboard.Parent = anchor

                            local faceImg = Instance.new("ImageLabel")
                            faceImg.Size = UDim2.new(1, 0, 1, 0)
                            faceImg.BackgroundTransparency = 1
                            faceImg.Image = resolvedImage
                            faceImg.ScaleType = Enum.ScaleType.Fit
                            faceImg.ImageTransparency = 0.93
                            faceImg.ZIndex = 10
                            faceImg.Parent = billboard

                            Camera.CameraType = Enum.CameraType.Scriptable
                            local baseCF = Camera.CFrame

                            for i = 1, JUMPSCARE_CONFIG.PLAY_COUNT do
                                local s = Instance.new("Sound")
                                s.SoundId = resolvedSound
                                s.Volume = JUMPSCARE_CONFIG.VOLUME
                                s.Parent = workspace
                                table.insert(toDestroy, s)
                                pcall(function() s:Play() end)
                                s.Ended:Connect(function() pcall(function() s:Destroy() end) end)
                            end

                            TweenService:Create(anchor, TweenInfo.new(JUMPSCARE_CONFIG.RUSH_TIME, JUMPSCARE_CONFIG.RUSH_STYLE, JUMPSCARE_CONFIG.RUSH_DIR), { CFrame = targetCF }):Play()
                            TweenService:Create(billboard, TweenInfo.new(JUMPSCARE_CONFIG.RUSH_TIME, JUMPSCARE_CONFIG.RUSH_STYLE, JUMPSCARE_CONFIG.RUSH_DIR), { Size = UDim2.new(JUMPSCARE_CONFIG.SIZE_NEAR, 0, JUMPSCARE_CONFIG.SIZE_NEAR, 0) }):Play()
                            TweenService:Create(faceImg, TweenInfo.new(JUMPSCARE_CONFIG.RUSH_TIME * 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { ImageTransparency = 0 }):Play()
                            TweenService:Create(Camera, TweenInfo.new(JUMPSCARE_CONFIG.RUSH_TIME, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), { FieldOfView = JUMPSCARE_CONFIG.FOV_PEAK }):Play()

                            task.wait(JUMPSCARE_CONFIG.RUSH_TIME)

                            local shakeStart = tick()
                            local shakeConn = RunService.RenderStepped:Connect(function()
                                pcall(function()
                                    local elapsed = tick() - shakeStart
                                    if elapsed > JUMPSCARE_CONFIG.SHAKE_DURATION then return end
                                    local p = math.clamp(elapsed / JUMPSCARE_CONFIG.SHAKE_DURATION, 0, 1)
                                    local intensity = JUMPSCARE_CONFIG.SHAKE_INTENSITY * (1 - p * p)
                                    Camera.CFrame = baseCF * JS_shakeOffset(elapsed, intensity, JUMPSCARE_CONFIG.SHAKE_SPEED)
                                end)
                            end)
                            table.insert(toDisconnect, shakeConn)

                            task.wait(JUMPSCARE_CONFIG.SHAKE_DURATION)

                            for _, c in ipairs(toDisconnect) do pcall(function() c:Disconnect() end) end
                            toDisconnect = {}
                            Camera.CameraType = savedCamType
                            TweenService:Create(Camera, TweenInfo.new(0.4, Enum.EasingStyle.Quad), { FieldOfView = savedFOV }):Play()

                            local pulseActive = true
                            local pulseStart = tick()
                            task.spawn(function()
                                while pulseActive do
                                    local t = tick() - pulseStart
                                    local p = 1 + math.sin(t * 5.5) * 0.018
                                    local size = JUMPSCARE_CONFIG.SIZE_NEAR * p
                                    pcall(function() billboard.Size = UDim2.new(size, 0, size, 0) end)
                                    task.wait(0.03)
                                end
                            end)

                            task.wait(JUMPSCARE_CONFIG.STAND_DURATION)
                            pulseActive = false

                            TweenService:Create(faceImg, TweenInfo.new(JUMPSCARE_CONFIG.FADE_OUT_TIME), { ImageTransparency = 1 }):Play()
                            task.wait(JUMPSCARE_CONFIG.FADE_OUT_TIME + 0.3)

                            cleanup()
                        end)

                        if not ok then
                            warn("[InstantJumpscare] Fehler: " .. tostring(err))
                            pcall(function() Camera.CameraType = Enum.CameraType.Custom end)
                            pcall(function() Camera.FieldOfView = 70 end)
                            pcall(function()
                                for _, o in ipairs(workspace:GetChildren()) do
                                    if o.Name == "_JumpscareAnchor" then o:Destroy() end
                                end
                            end)
                        end

                        State.JumpscareActive = false
                    end)
                end

                Track(LocalPlayer.CharacterAdded:Connect(function()
                    Exec_StopSpin(); State.IsFrozen = false
                    trackWarmed = false
                    task.delay(1.5, function() BroadcastPresence(); BroadcastNametagVisibility() end)
                end))

                
                
                
                
                local function _NT_getInitials(name)
                    local parts = {}
                    for word in name:gmatch("%u%l*") do table.insert(parts, word:sub(1,1)) end
                    if #parts >= 2 then return (parts[1] .. parts[2]):upper() end
                    return name:sub(1,2):upper()
                end

                
                
                
                

                
                local _NT_FONT_FALLBACK = Enum.Font.GothamBold
                local function _NT_safeFont(enumName)
                    local ok, result = pcall(function() return Enum.Font[enumName] end)
                    return ok and result or _NT_FONT_FALLBACK
                end
                local _NT_FONT_MAP = {
                    ["GothamBold"]       = _NT_safeFont("GothamBold"),
                    ["Gotham"]           = _NT_safeFont("Gotham"),
                    ["GothamMedium"]     = _NT_safeFont("GothamMedium"),
                    ["GothamBlack"]      = _NT_safeFont("GothamBlack"),
                    ["GothamLight"]      = _NT_safeFont("GothamLight"),
                    ["GothamThin"]       = _NT_safeFont("GothamThin"),
                    ["SourceSans"]       = _NT_safeFont("SourceSans"),
                    ["SourceSansBold"]   = _NT_safeFont("SourceSansBold"),
                    ["SourceSansLight"]  = _NT_safeFont("SourceSansLight"),
                    ["SourceSansSemibold"]= _NT_safeFont("SourceSansSemibold"),
                    ["Cartoon"]          = _NT_safeFont("Cartoon"),
                    ["Highway"]          = _NT_safeFont("Highway"),
                    ["SciFi"]            = _NT_safeFont("SciFi"),
                    ["Arial"]            = _NT_safeFont("Arial"),
                    ["ArialBold"]        = _NT_safeFont("ArialBold"),
                    ["Ubuntu"]           = _NT_safeFont("Ubuntu"),
                    ["UbuntuBold"]       = _NT_safeFont("UbuntuBold"),
                    ["Code"]             = _NT_safeFont("Code"),
                    ["CartoonBold"]      = _NT_safeFont("CartoonBold"),
                }

                local _NT_EASING_MAP = {
                    ["Quad"] = Enum.EasingStyle.Quad,
                    ["Linear"] = Enum.EasingStyle.Linear,
                    ["Sine"] = Enum.EasingStyle.Sine,
                    ["Expo"] = Enum.EasingStyle.Exponential,
                    ["Exponential"] = Enum.EasingStyle.Exponential,
                    ["Back"] = Enum.EasingStyle.Back,
                    ["Bounce"] = Enum.EasingStyle.Bounce,
                    ["Elastic"] = Enum.EasingStyle.Elastic,
                }

                local _NT_DEFAULTS = {
                    enabled = true,
                    themes = {
                        user = {
                            bg = "#1A1A22", avatarBg = "#1F1F2C", avatarText = "#A0A0C0",
                            divider = "#A0A0C0", border = "#A0A0B4", nameText = "#E6E6F0", roleText = "#7878A0",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#1A1A22", "#0E0E18"}, bgGradientAngle = 0,
                            bgGradientStart = "#1A1A22", bgGradientEnd = "#0E0E18", bgGradientRotation = 0,
                        },
                        admin = {
                            bg = "#220E0E", avatarBg = "#2A1212", avatarText = "#FF6464",
                            divider = "#FF6464", border = "#DC5050", nameText = "#FF8C8C", roleText = "#C83C3C",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#220E0E", "#150808"}, bgGradientAngle = 0,
                            bgGradientStart = "#220E0E", bgGradientEnd = "#150808", bgGradientRotation = 0,
                        },
                        owner = {
                            bg = "#160E1E", avatarBg = "#1B1226", avatarText = "#B87CFF",
                            divider = "#B87CFF", border = "#AA64FF", nameText = "#DDB8FF", roleText = "#8850CC",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#160E1E", "#0D0814"}, bgGradientAngle = 0,
                            bgGradientStart = "#160E1E", bgGradientEnd = "#0D0814", bgGradientRotation = 0,
                        },
                        developer = {
                            bg = "#0C1428", avatarBg = "#101A34", avatarText = "#64B4FF",
                            divider = "#64B4FF", border = "#50A0F0", nameText = "#8CD2FF", roleText = "#3C82DC",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#0C1428", "#060A18"}, bgGradientAngle = 0,
                            bgGradientStart = "#0C1428", bgGradientEnd = "#060A18", bgGradientRotation = 0,
                        },
                        advertising = {
                            bg = "#1C0E24", avatarBg = "#24122E", avatarText = "#C878FF",
                            divider = "#C878FF", border = "#B464F0", nameText = "#E6AAFF", roleText = "#A050D2",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#1C0E24", "#100818"}, bgGradientAngle = 0,
                            bgGradientStart = "#1C0E24", bgGradientEnd = "#100818", bgGradientRotation = 0,
                        },
                        moderator = {
                            bg = "#221C0A", avatarBg = "#2A220C", avatarText = "#FFC83C",
                            divider = "#FFC83C", border = "#F0B428", nameText = "#FFDC64", roleText = "#DCA01E",
                            bgGradient = false, bgGradientType = "linear", bgGradientColors = {"#221C0A", "#141006"}, bgGradientAngle = 0,
                            bgGradientStart = "#221C0A", bgGradientEnd = "#141006", bgGradientRotation = 0,
                        },
                    },
                    layout = {
                        billboardWidth = 240, billboardHeight = 44, studsOffsetY = 3.4,
                        avatarWidth = 44, cornerRadius = 8, innerCornerRadius = 5,
                        borderThickness = 1, dividerWidth = 1, dividerHeightPct = 0.6,
                        dividerTransparency = 0.75, nameTextSize = 13, nameFont = "GothamBold",
                        roleTextSize = 9, roleFont = "GothamBold", initialsTextSize = 11,
                        avatarTextGap = 10, textPaddingRight = 4,
                        nameLabelHeight = 20, nameLabelY = 4,
                        roleLabelHeight = 12, roleLabelY = 26,
                        roleTextTransform = "upper",
                        avatarImagePadding = 3,
                        distanceScaleEnabled = true,
                        distanceScaleNear = 10,
                        distanceScaleFar = 60,
                        distanceScaleMin = 0.35,
                    },
                    animations = {
                        fadeInDuration = 0.3, fadeInEasing = "Quad",
                        cardTransparency = 0, borderTransparency = 0.3,
                    },
                    particles = {
                        enabled = true, count = 4, minSize = 2, maxSize = 4,
                        transparency = 0.5, moveDurationMin = 3, moveDurationMax = 5,
                        colors = { "#B87CFF", "#A064F0", "#C896FF", "#8C50DC", "#DDB8FF" },
                    },
                    roleKeywords = {
                        owner = { "owner", "vip" },
                        developer = { "developer", "entwickler" },
                        moderator = { "moderator", "mod" },
                        admin = { "admin", "administrator" },
                        staff = { "staff" },
                        advertising = { "advertising", "werbung" },
                    },
                    roleUsers = {
                        owner = {},
                        admin = {},
                        developer = {},
                        moderator = {},
                        staff = {},
                        advertising = {},
                        user = {},
                    },
                    profilePictures = {
                        owner = { url = ownerProfilePicUrl, file = ownerProfilePicFileName },
                        user = { url = userProfilePicUrl, file = userProfilePicFileName },
                        admin = { url = "", file = "" },
                        developer = { url = "", file = "" },
                        moderator = { url = "", file = "" },
                        staff = { url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-STAFF.png", file = "assets/ROLE-ICONS/TL-STAFF.png" },
                        advertising = { url = "", file = "" },
                    },
                    customAvatars = {},
                    tagImages = {
                        staff = { url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-STAFF.png", file = "assets/ROLE-ICONS/TL-STAFF.png" },
                    },
                    roleLabels = {},
                    displayNames = {},
                    roleDisplayNames = {},
                    userColorOverrides = {},
                    userGradientOverrides = {},
                    gradients = {
                        cardGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#B87CFF", "#1A1A22" },
                            transparency = { 0, 0 },
                            rotation = 90,
                            offset = { 0, 0 },
                        },
                        avatarGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#B87CFF", "#160E1E" },
                            transparency = { 0, 0 },
                            rotation = 180,
                            offset = { 0, 0 },
                        },
                        nameGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#FFFFFF", "#B87CFF" },
                            transparency = { 0, 0 },
                            rotation = 0,
                            offset = { 0, 0 },
                        },
                        roleGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#B87CFF", "#8850CC" },
                            transparency = { 0, 0 },
                            rotation = 0,
                            offset = { 0, 0 },
                        },
                        borderGradient = {
                            enabled = false,
                            type = "Linear",
                            colors = { "#B87CFF", "#AA64FF" },
                            transparency = { 0, 0 },
                            rotation = 0,
                            offset = { 0, 0 },
                        },
                    },
                }

                
                local _NT_CONFIG = {}

                local function _NT_deepCopy(orig)
                    if type(orig) ~= "table" then return orig end
                    local copy = {}
                    for k, v in pairs(orig) do
                        copy[k] = _NT_deepCopy(v)
                    end
                    return copy
                end

-- =========================================================================
-- UNIVERSAL WEB COLOR & MULTI-STOP GRADIENT ENGINE
-- Accurate sRGB, Hex (#RGB, #RRGGBB, #RRGGBBAA), RGB/RGBA, HSL/HSLA & Multi-Color Keypoint Support
-- =========================================================================
local function _NT_hexToColor3(hex)
    if typeof(hex) == "Color3" then return hex end
    if type(hex) == "table" then
        local r = hex.r or hex[1] or 255
        local g = hex.g or hex[2] or 255
        local b = hex.b or hex[3] or 255
        if r <= 1 and g <= 1 and b <= 1 and (hex.r or hex[1]) then
            return Color3.new(r, g, b)
        end
        return Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
    end
    if type(hex) ~= "string" then return Color3.new(1, 1, 1) end

    local str = hex:gsub("%s+", "")

    -- rgb(r, g, b) or rgba(r, g, b, a)
    local r, g, b = str:match("^rgba?%((%d+),(%d+),(%d+)")
    if r and g and b then
        return Color3.fromRGB(tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255)
    end

    -- hsl(h, s%, l%) or hsla(h, s%, l%, a)
    local h, s, l = str:match("^hsla?%((%d+),(%d+)%%?,(%d+)%%?")
    if h and s and l then
        local fh = (tonumber(h) or 0) / 360
        local fs = (tonumber(s) or 0) / 100
        local fl = (tonumber(l) or 0) / 100
        return Color3.fromHSV(fh, fs, fl)
    end

    -- Clean hex string
    local clean = str:gsub("^#", "")

    -- 3-char hex #RGB -> #RRGGBB
    if #clean == 3 then
        local r1, g1, b1 = clean:sub(1, 1), clean:sub(2, 2), clean:sub(3, 3)
        clean = r1 .. r1 .. g1 .. g1 .. b1 .. b1
    -- 4-char hex #RGBA -> #RRGGBB
    elseif #clean == 4 then
        local r1, g1, b1 = clean:sub(1, 1), clean:sub(2, 2), clean:sub(3, 3)
        clean = r1 .. r1 .. g1 .. g1 .. b1 .. b1
    -- 8-char hex #RRGGBBAA -> #RRGGBB
    elseif #clean == 8 then
        clean = clean:sub(1, 6)
    end

    if #clean == 6 then
        local cr = tonumber(clean:sub(1, 2), 16) or 255
        local cg = tonumber(clean:sub(3, 4), 16) or 255
        local cb = tonumber(clean:sub(5, 6), 16) or 255
        return Color3.fromRGB(cr, cg, cb)
    end

    return Color3.new(1, 1, 1)
end

local function _NT_parseColor(val)
    return _NT_hexToColor3(val)
end

-- Multi-Color Gradient Engine (Supports multi-stop Web JSON arrays and position keypoints)
local function _NT_buildColorSeq(rawColors, rawTransparencies)
    local csPairs = {}
    local nsPairs = {}

    if type(rawColors) ~= "table" or #rawColors == 0 then
        return ColorSequence.new(Color3.new(1, 1, 1)), NumberSequence.new(0)
    end

    -- Parse color keypoints
    local rawKeypoints = {}
    for i, item in ipairs(rawColors) do
        local cVal, pos
        if type(item) == "table" and item.color then
            cVal = _NT_parseColor(item.color)
            pos = tonumber(item.pos or item.offset or item.position) or ((i - 1) / math.max(1, #rawColors - 1))
        else
            cVal = _NT_parseColor(item)
            pos = (i - 1) / math.max(1, #rawColors - 1)
        end
        table.insert(rawKeypoints, { t = math.clamp(pos, 0, 1), color = cVal })
    end

    -- Sort keypoints by position
    table.sort(rawKeypoints, function(a, b) return a.t < b.t end)

    -- Force start at 0 and end at 1 with strictly increasing time
    if #rawKeypoints == 1 then
        local c = rawKeypoints[1].color
        csPairs = { ColorSequenceKeypoint.new(0, c), ColorSequenceKeypoint.new(1, c) }
    else
        local lastT = -0.0001
        for i, kp in ipairs(rawKeypoints) do
            local t = kp.t
            if i == 1 then t = 0 end
            if i == #rawKeypoints then t = 1 end
            if t <= lastT then
                t = math.min(1, lastT + 0.001)
            end
            lastT = t
            table.insert(csPairs, ColorSequenceKeypoint.new(t, kp.color))
        end
    end

    -- Parse transparency keypoints
    if type(rawTransparencies) == "table" and #rawTransparencies > 0 then
        if #rawTransparencies == 1 then
            local tr = tonumber(rawTransparencies[1]) or 0
            nsPairs = { NumberSequenceKeypoint.new(0, tr), NumberSequenceKeypoint.new(1, tr) }
        else
            local lastT = -0.0001
            for i, trVal in ipairs(rawTransparencies) do
                local t = (i - 1) / math.max(1, #rawTransparencies - 1)
                local tr = math.clamp(tonumber(trVal) or 0, 0, 1)
                if i == 1 then t = 0 end
                if i == #rawTransparencies then t = 1 end
                if t <= lastT then t = math.min(1, lastT + 0.001) end
                lastT = t
                table.insert(nsPairs, NumberSequenceKeypoint.new(t, tr))
            end
        end
    else
        nsPairs = { NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) }
    end

    local finalCS = pcall(function() return ColorSequence.new(csPairs) end) and ColorSequence.new(csPairs) or ColorSequence.new(Color3.new(1, 1, 1))
    local finalNS = pcall(function() return NumberSequence.new(nsPairs) end) and NumberSequence.new(nsPairs) or NumberSequence.new(0)

    return finalCS, finalNS
end
                    local csPairs, nsPairs = {}, {}
                    for i = 1, #colors do
                        local t = (i - 1) / math.max(1, #colors - 1)
                        csPairs[#csPairs + 1] = ColorSequenceKeypoint.new(t, _NT_parseColor(colors[i]))
                        local tr = (type(transparencies) == "table" and transparencies[i]) or 0
                        nsPairs[#nsPairs + 1] = NumberSequenceKeypoint.new(t, math.clamp(tonumber(tr) or 0, 0, 1))
                    end
                    return ColorSequence.new(csPairs), NumberSequence.new(nsPairs)
                end

                local function _NT_applyGradient(target, gradCfg)
                    if not target or not gradCfg or not gradCfg.enabled then return nil, {} end
                    
                    local _GRAD_TYPE_MAP = {
                        linear = "Linear", radial = "Radial", conic = "Conic", angular = "Angular",
                        mesh = "Mesh", color = "Color", blend = "Blend", colorblend = "Blend",
                        duotone = "Duotone", multicolor = "Multicolor", smooth = "Smooth",
                        soft = "Soft", glass = "Glass", neon = "Neon", metallic = "Metallic",
                        iridescent = "Iridescent", holographic = "Holographic", aurora = "Aurora",
                        sunset = "Sunset", spectrum = "Spectrum", liquid = "Liquid",
                        dynamic = "Dynamic", fluid = "Fluid", chromatic = "Chromatic",
                        ombre = "Ombre", fade = "Fade", transition = "ColorTransition",
                        colortransition = "ColorTransition", overlay = "Overlay",
                        gradmesh = "Mesh", flow = "Flow", wave = "Wave",
                    }
                    local rawType = tostring(gradCfg.type or "Linear"):lower()
                    local gType = _GRAD_TYPE_MAP[rawType] or "Linear"
                    local colors = gradCfg.colors or { "#FFFFFF", "#000000" }
                    local trans = gradCfg.transparency or { 0, 0 }
                    local rot = tonumber(gradCfg.rotation) or 0
                    local cs, ns = _NT_buildColorSeq(colors, trans)
                    local conns = {}

                    if gType == "Linear" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot
                        ug.Offset = Vector2.new(gradCfg.offset and gradCfg.offset[1] or 0, gradCfg.offset and gradCfg.offset[2] or 0)
                        return ug, conns

                    elseif gType == "Radial" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot; ug.Style = Enum.GradientStyle.Radial
                        return ug, conns

                    elseif gType == "Conic" or gType == "Angular" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot; ug.Style = Enum.GradientStyle.Radial
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.5
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 360) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Mesh" then
                        local layers = gradCfg.layers
                        if type(layers) ~= "table" or #layers == 0 then
                            layers = {
                                { colors = colors, transparency = trans, rotation = rot },
                                { colors = { colors[#colors] or "#000000", colors[1] or "#FFFFFF" }, transparency = { 0.5, 0.5 }, rotation = (rot + 90) % 360 },
                            }
                        end
                        for _, layer in ipairs(layers) do
                            local lcs, lns = _NT_buildColorSeq(layer.colors, layer.transparency)
                            local lug = Instance.new("UIGradient", target)
                            lug.Color = lcs; lug.Transparency = lns
                            lug.Rotation = layer.rotation or rot
                            lug.Offset = Vector2.new(0.5, 0.5)
                        end
                        return nil, conns

                    elseif gType == "Color" or gType == "ColorTransition" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot; ug.Style = Enum.GradientStyle.Linear
                        return ug, conns

                    elseif gType == "Blend" then
                        local ug = Instance.new("UIGradient", target)
                        local blendT = gradCfg.transparency or { 0, 0.5 }
                        local blendNS = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, math.clamp(blendT[1] or 0, 0, 0.9)),
                            NumberSequenceKeypoint.new(0.5, math.clamp(blendT[2] or 0.3, 0, 0.9)),
                            NumberSequenceKeypoint.new(1, math.clamp(blendT[1] or 0, 0, 0.9)),
                        })
                        ug.Color = cs; ug.Transparency = blendNS
                        ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Duotone" then
                        local c1 = _NT_parseColor(colors[1] or "#FFFFFF")
                        local c2 = _NT_parseColor(colors[2] or "#000000")
                        target.BackgroundColor3 = c1
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = ColorSequence.new(c2, c1)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.5, 0.3),
                            NumberSequenceKeypoint.new(1, 0),
                        })
                        ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Multicolor" or gType == "Spectrum" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.3
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 120) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Smooth" then
                        local smoothT = trans
                        if #smoothT == 2 then
                            smoothT = { smoothT[1], (smoothT[1] + smoothT[2]) / 2, smoothT[2] }
                        end
                        local smoothCS = {}
                        for i = 1, #colors do
                            local t = (i - 1) / math.max(1, #colors - 1)
                            smoothCS[#smoothCS + 1] = ColorSequenceKeypoint.new(t, _NT_parseColor(colors[i]))
                        end
                        if #smoothCS == 2 then
                            local mid = _NT_parseColor(colors[1]):Lerp(_NT_parseColor(colors[2]), 0.5)
                            smoothCS = {
                                ColorSequenceKeypoint.new(0, _NT_parseColor(colors[1])),
                                ColorSequenceKeypoint.new(0.5, mid),
                                ColorSequenceKeypoint.new(1, _NT_parseColor(colors[2])),
                            }
                        end
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = ColorSequence.new(smoothCS)
                        ug.Transparency = ns; ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Soft" then
                        local ug = Instance.new("UIGradient", target)
                        local softColors = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i]):Lerp(Color3.new(1, 1, 1), 0.2)
                            softColors[#softColors + 1] = ColorSequenceKeypoint.new((i - 1) / math.max(1, #colors - 1), c)
                        end
                        if #softColors == 2 then
                            local c1 = _NT_parseColor(colors[1]):Lerp(Color3.new(1, 1, 1), 0.2)
                            local c2 = _NT_parseColor(colors[2]):Lerp(Color3.new(1, 1, 1), 0.2)
                            local mid = c1:Lerp(c2, 0.5)
                            softColors = {
                                ColorSequenceKeypoint.new(0, c1),
                                ColorSequenceKeypoint.new(0.35, mid),
                                ColorSequenceKeypoint.new(0.65, mid),
                                ColorSequenceKeypoint.new(1, c2),
                            }
                        end
                        ug.Color = ColorSequence.new(softColors)
                        ug.Transparency = ns; ug.Rotation = rot
                        ug.Style = Enum.GradientStyle.Radial
                        return ug, conns

                    elseif gType == "Glass" then
                        local ug = Instance.new("UIGradient", target)
                        local glassNS = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.3),
                            NumberSequenceKeypoint.new(0.3, 0),
                            NumberSequenceKeypoint.new(0.6, 0.15),
                            NumberSequenceKeypoint.new(1, 0.5),
                        })
                        ug.Color = cs; ug.Transparency = glassNS
                        ug.Rotation = rot + 45
                        return ug, conns

                    elseif gType == "Neon" then
                        local ug = Instance.new("UIGradient", target)
                        local neonCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local brightC = c:Lerp(Color3.new(1, 1, 1), 0.5)
                            local softC = c:Lerp(Color3.new(1, 1, 1), 0.2)
                            local base = (i - 1) / #colors
                            neonCS[#neonCS + 1] = ColorSequenceKeypoint.new(math.clamp(base, 0, 1), softC)
                            neonCS[#neonCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.2 / #colors, 0, 1), brightC)
                            neonCS[#neonCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.4 / #colors, 0, 1), softC)
                        end
                        neonCS[#neonCS + 1] = ColorSequenceKeypoint.new(1, neonCS[1].Value)
                        ug.Color = ColorSequence.new(neonCS)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.25, 0.1),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(0.75, 0.1),
                            NumberSequenceKeypoint.new(1, 0),
                        })
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 1
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 60) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Metallic" then
                        local ug = Instance.new("UIGradient", target)
                        local metCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local metDark = c:Lerp(Color3.new(0, 0, 0), 0.45)
                            local metMid = c:Lerp(Color3.new(1, 1, 1), 0.15)
                            local metLight = c:Lerp(Color3.new(1, 1, 1), 0.5)
                            local base = (i - 1) / #colors
                            metCS[#metCS + 1] = ColorSequenceKeypoint.new(math.clamp(base, 0, 1), metDark)
                            metCS[#metCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.15 / #colors, 0, 1), metMid)
                            metCS[#metCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.35 / #colors, 0, 1), metLight)
                            metCS[#metCS + 1] = ColorSequenceKeypoint.new(math.clamp(base + 0.5 / #colors, 0, 1), metMid)
                        end
                        metCS[#metCS + 1] = ColorSequenceKeypoint.new(1, metCS[1].Value)
                        ug.Color = ColorSequence.new(metCS)
                        ug.Transparency = ns; ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Iridescent" or gType == "Holographic" then
                        local ug = Instance.new("UIGradient", target)
                        local iriCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local brightC = c:Lerp(Color3.new(1, 1, 1), 0.3)
                            local t = (i - 1) / math.max(1, #colors - 1)
                            iriCS[#iriCS + 1] = ColorSequenceKeypoint.new(t, brightC)
                        end
                        if #iriCS < 4 then
                            local c1 = _NT_parseColor(colors[1])
                            local c2 = _NT_parseColor(colors[2] or colors[1])
                            local c3 = _NT_parseColor(colors[3] or colors[2] or colors[1])
                            local mid1 = c1:Lerp(c2, 0.33):Lerp(Color3.new(1,1,1), 0.2)
                            local mid2 = c2:Lerp(c3, 0.66):Lerp(Color3.new(1,1,1), 0.2)
                            iriCS = {
                                ColorSequenceKeypoint.new(0, c1:Lerp(Color3.new(1,1,1), 0.3)),
                                ColorSequenceKeypoint.new(0.33, mid1),
                                ColorSequenceKeypoint.new(0.66, mid2),
                                ColorSequenceKeypoint.new(1, (c2 or c1):Lerp(Color3.new(1,1,1), 0.3)),
                            }
                        end
                        ug.Color = ColorSequence.new(iriCS)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.25, 0.05),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(0.75, 0.05),
                            NumberSequenceKeypoint.new(1, 0),
                        })
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.4
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 90) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Aurora" then
                        local ug = Instance.new("UIGradient", target)
                        local auCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local t = (i - 1) / math.max(1, #colors - 1)
                            auCS[#auCS + 1] = ColorSequenceKeypoint.new(t, c)
                        end
                        if #auCS < 3 then
                            local c1 = _NT_parseColor(colors[1])
                            local c2 = _NT_parseColor(colors[2] or colors[1])
                            local mid = c1:Lerp(c2, 0.5)
                            auCS = {
                                ColorSequenceKeypoint.new(0, c1),
                                ColorSequenceKeypoint.new(0.5, mid),
                                ColorSequenceKeypoint.new(1, c2),
                            }
                        end
                        ug.Color = ColorSequence.new(auCS)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.1),
                            NumberSequenceKeypoint.new(0.3, 0),
                            NumberSequenceKeypoint.new(0.7, 0),
                            NumberSequenceKeypoint.new(1, 0.1),
                        })
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.3
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Rotation = (rot + t * speed * 50) % 360 end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Sunset" then
                        local ug = Instance.new("UIGradient", target)
                        local ssCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            local t = (i - 1) / math.max(1, #colors - 1)
                            ssCS[#ssCS + 1] = ColorSequenceKeypoint.new(t, c)
                        end
                        ug.Color = ColorSequence.new(ssCS)
                        ug.Transparency = ns; ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Liquid" or gType == "Fluid" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs
                        ug.Style = Enum.GradientStyle.Radial
                        ug.Transparency = ns; ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.5
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function()
                                    ug.Rotation = (rot + math.sin(t * speed) * 45) % 360
                                    ug.Offset = Vector2.new(math.sin(t * speed * 0.7) * 0.15, math.cos(t * speed * 0.5) * 0.15)
                                end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Dynamic" or gType == "Flow" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs; ug.Transparency = ns; ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 1
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function()
                                    ug.Rotation = (rot + t * speed * 30) % 360
                                    ug.Offset = Vector2.new(math.sin(t * speed * 0.4) * 0.2, 0)
                                end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Chromatic" then
                        local ug = Instance.new("UIGradient", target)
                        local chCS = {}
                        for i = 1, #colors do
                            local c = _NT_parseColor(colors[i])
                            chCS[#chCS + 1] = ColorSequenceKeypoint.new((i - 1) / math.max(1, #colors - 1), c)
                        end
                        if #chCS < 3 then
                            local extra = _NT_parseColor(colors[1] or "#FFFFFF"):Lerp(_NT_parseColor(colors[2] or "#000000"), 0.5)
                            table.insert(chCS, 2, ColorSequenceKeypoint.new(0.5, extra))
                        end
                        ug.Color = ColorSequence.new(chCS)
                        ug.Transparency = ns; ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.6
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function()
                                    local shift = (t * speed * 0.3) % 1
                                    ug.Offset = Vector2.new(shift - 0.5, 0)
                                end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Ombre" or gType == "Fade" then
                        local ug = Instance.new("UIGradient", target)
                        local oC1 = _NT_parseColor(colors[1] or "#000000")
                        local oC2 = _NT_parseColor(colors[2] or "#FFFFFF")
                        ug.Color = ColorSequence.new(oC1, oC1, oC2, oC2)
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.4, 0),
                            NumberSequenceKeypoint.new(0.6, 0.4),
                            NumberSequenceKeypoint.new(1, 0.8),
                        })
                        ug.Rotation = rot
                        return ug, conns

                    elseif gType == "Wave" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs
                        local waveNS = {}
                        local freq = gradCfg.frequency or 4
                        local amp = gradCfg.amplitude or 0.3
                        for i = 0, 10 do
                            local t = i / 10
                            local baseT = trans[1] or 0
                            waveNS[#waveNS + 1] = NumberSequenceKeypoint.new(t, baseT + amp * math.abs(math.sin(t * freq * math.pi)))
                        end
                        ug.Transparency = NumberSequence.new(waveNS)
                        ug.Rotation = rot
                        if not _NT_canAnimateGradient() then return ug, conns end
                        local alive = { alive = true, parent = target }
                        _NT_GRADIENT_ANIM_ALIVE[#_NT_GRADIENT_ANIM_ALIVE + 1] = alive
                        local speed = gradCfg.speed or 0.5
                        task.spawn(function()
                            local t = 0
                            while alive.alive and target and target.Parent do
                                t = t + task.wait(_NT_GRADIENT_ANIM_INTERVAL)
                                pcall(function() ug.Offset = Vector2.new(math.sin(t * speed) * 0.2, 0) end)
                            end
                        end)
                        return ug, conns

                    elseif gType == "Overlay" then
                        local ug = Instance.new("UIGradient", target)
                        ug.Color = cs
                        ug.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.2),
                            NumberSequenceKeypoint.new(0.5, 0),
                            NumberSequenceKeypoint.new(1, 0.2),
                        })
                        ug.Rotation = rot + 45
                        return ug, conns
                    end

                    return nil, conns
                end

-- Multi-Target Website Gradient Resolver (Per-Player Overrides > Per-Role Theme Gradients > Global Gradients)
local function _NT_resolveGradientSet(playerName, roleKey, theme)
    local resolved = {}
    local targets = { "cardGradient", "avatarGradient", "nameGradient", "roleGradient", "borderGradient" }

    local userGrads = _NT_CONFIG.userGradientOverrides and _NT_CONFIG.userGradientOverrides[playerName]
    local themeGrads = (theme and theme.gradients) or (_NT_CONFIG.themes and _NT_CONFIG.themes[roleKey] and _NT_CONFIG.themes[roleKey].gradients)
    local globalGrads = _NT_CONFIG.gradients or {}
    local defaultGrads = _NT_DEFAULTS and _NT_DEFAULTS.gradients or {}

    for _, targetKey in ipairs(targets) do
        local g = (userGrads and userGrads[targetKey])
               or (themeGrads and themeGrads[targetKey])
               or (globalGrads and globalGrads[targetKey])
               or (defaultGrads and defaultGrads[targetKey])
        if g then
            resolved[targetKey] = _NT_deepCopy(g)
        end
    end
    return resolved
end

                local function _NT_applyAllGradients(billboard, card, avatar, nameLabel, roleTxt, cardBorder, gradCfg)
                    if type(gradCfg) ~= "table" then return end
                    if gradCfg.cardGradient and gradCfg.cardGradient.enabled then
                        _NT_applyGradient(card, gradCfg.cardGradient)
                    end
                    if gradCfg.avatarGradient and gradCfg.avatarGradient.enabled then
                        _NT_applyGradient(avatar, gradCfg.avatarGradient)
                    end
                    if gradCfg.nameGradient and gradCfg.nameGradient.enabled then
                        _NT_applyGradient(nameLabel, gradCfg.nameGradient)
                    end
                    if gradCfg.roleGradient and gradCfg.roleGradient.enabled then
                        _NT_applyGradient(roleTxt, gradCfg.roleGradient)
                    end
                    if gradCfg.borderGradient and gradCfg.borderGradient.enabled and cardBorder then
                        _NT_applyGradient(cardBorder, gradCfg.borderGradient)
                    end
                end

                local creatingNametag = {}
                local function CreateCustomNametag(character, playerName, isAdmin)
                    if not character then return end
                    if creatingNametag[playerName] then return end
                    creatingNametag[playerName] = true

                    local player = Players:FindFirstChild(playerName)
                    local playerUserId = player and tostring(player.UserId) or nil

                    local override = NameOverrides[playerName]
                    if not override and playerUserId then
                        override = NameOverrides[playerUserId]
                    end

                    local displayName  = _NT_CONFIG.displayNames and _NT_CONFIG.displayNames[playerName]
                        or (override and override.display or playerName)
                    local roleLabel    = _NT_CONFIG.roleLabels and _NT_CONFIG.roleLabels[playerName]
                        or (override and override.role or nil)

                    
                    local roleLower    = (roleLabel or (isAdmin and "TL Admin" or "TL User")):lower()
                    local displayLower = (override and override.display or ""):lower()
                    local themeKey     = "user"

                    
                    
                    local _NT_ROLE_PRIO = { owner=7, developer=6, admin=5, moderator=4, staff=3, advertising=2, user=1 }
                    local _ntHighestPrio = 0
                    for role, users in pairs(_NT_CONFIG.roleUsers) do
                        for _, u in ipairs(users) do
                            if u:lower() == playerName:lower() then
                                local prio = _NT_ROLE_PRIO[role] or 0
                                if prio > _ntHighestPrio then
                                    _ntHighestPrio = prio
                                    themeKey = role
                                end
                                break
                            end
                        end
                    end

                    
                    if themeKey == "user" then
                        for tk, keywords in pairs(_NT_CONFIG.roleKeywords) do
                            if themeKey == "user" then
                                for _, kw in ipairs(keywords) do
                                    if roleLower:find(kw) or displayLower:find(kw) then
                                        themeKey = tk
                                        break
                                    end
                                end
                            end
                        end
                    end

                    
                    if themeKey == "user" and isAdmin then
                        themeKey = "admin"
                    end

                    
                    if themeKey == "user" and displayName == playerName and player then
                        local robloxDisplayName = player:FindFirstChild("DisplayName")
                        if robloxDisplayName and robloxDisplayName.Value ~= "" then
                            displayName = robloxDisplayName.Value
                        end
                    end

                    
                    
                    
                    
                    
                    if not roleLabel then
                        local _NT_ROLE_DEFAULTS = { user="TL User", admin="TL Admin", owner="TL Owner", developer="TL Developer", advertising="TL Advertising", moderator="TL Moderator" }
                        roleLabel = (_NT_CONFIG.roleDisplayNames and _NT_CONFIG.roleDisplayNames[themeKey])
                            or _NT_ROLE_DEFAULTS[themeKey]
                            or "TL User"
                    end

                    local theme = _NT_CONFIG.themes[themeKey] or _NT_DEFAULTS.themes.user
                    local customAvatar = _NT_CONFIG.customAvatars[playerName] or customUserAvatars[playerName]

                    
                    local _userColorOvr = _NT_CONFIG.userColorOverrides and _NT_CONFIG.userColorOverrides[playerName]
                    if _userColorOvr and _userColorOvr.__enabled then
                        theme = _NT_deepCopy(theme)
                        for k, v in pairs(_userColorOvr) do
                            if k ~= "__enabled" and v ~= nil then
                                if v == "transparent" then
                                    theme[k] = Color3.new(1, 1, 1)
                                    theme[k .. "_transparent"] = true
                                else
                                    theme[k] = v
                                end
                            end
                        end
                    end

                    
                    local _userGradOvr = _NT_CONFIG.userGradientOverrides and _NT_CONFIG.userGradientOverrides[playerName]
                    local _savedGrads = nil
                    if _userGradOvr then
                        _savedGrads = _NT_deepCopy(_NT_CONFIG.gradients)
                        for gradKey, gradData in pairs(_userGradOvr) do
                            if _NT_CONFIG.gradients[gradKey] then
                                _NT_CONFIG.gradients[gradKey] = _NT_deepCopy(gradData)
                            end
                        end
                    end

                    local head = character:WaitForChild("Head", 5)
                    if not head then
                        creatingNametag[playerName] = nil; return
                    end

                    local guiParentBB = CoreGui
                    local existingBB  = guiParentBB:FindFirstChild("CovertPeerTag_" .. playerName)
                    if existingBB then existingBB:Destroy() end

                    local billboard             = Instance.new("BillboardGui")
                    billboard.Name              = "CovertPeerTag_" .. playerName
                    billboard.Adornee           = head
                    billboard.Size              = UDim2.new(0, _NT_CONFIG.layout.billboardWidth, 0, _NT_CONFIG.layout.billboardHeight)
                    billboard.StudsOffset       = Vector3.new(0, _NT_CONFIG.layout.studsOffsetY, 0)
                    billboard.AlwaysOnTop       = true
                    billboard.LightInfluence    = 0

                    
                    local card                       = Instance.new("Frame")
                    card.Size                        = UDim2.new(1, 0, 1, 0)
                    
                    
                    
                    card.AnchorPoint                 = Vector2.new(0.5, 0.5)
                    card.Position                     = UDim2.new(0.5, 0, 0.5, 0)
                    card.BorderSizePixel             = 0
                    card.Parent                      = billboard

                    
                    
                    local cardBaseColor              = theme.bg
                    if theme.bgGradient and theme.bgGradientColors and #theme.bgGradientColors >= 2 then
                        cardBaseColor               = _NT_parseColor(theme.bgGradientColors[1])
                    end
                    card.BackgroundColor3            = cardBaseColor
                    card.BackgroundTransparency      = 1

                    
                    local cardScale                  = Instance.new("UIScale")
                    cardScale.Scale                  = 1
                    cardScale.Parent                 = card

                    
                    if theme.bgGradient then
                        card.BackgroundTransparency = 1
                        local gradCfg = {
                            enabled = true,
                            type = theme.bgGradientType or "Linear",
                            colors = theme.bgGradientColors or { "#1A1A22", "#0E0E18" },
                            transparency = { 0, 0 },
                            rotation = theme.bgGradientAngle or theme.bgGradientRotation or 0,
                            offset = { 0, 0 },
                        }
                        _NT_applyGradient(card, gradCfg)
                    end

                    local cardCorner                 = Instance.new("UICorner")
                    cardCorner.CornerRadius          = UDim.new(0, _NT_CONFIG.layout.cornerRadius)
                    cardCorner.Parent                = card

                    local cardBorder                 = Instance.new("UIStroke")
                    cardBorder.Color                 = theme.border
                    cardBorder.Thickness             = _NT_CONFIG.layout.borderThickness
                    cardBorder.Transparency          = 1
                    cardBorder.ApplyStrokeMode       = Enum.ApplyStrokeMode.Border
                    cardBorder.Parent                = card
                    if customAvatar and customAvatar.strokeColor then
                        cardBorder.Color             = Color3.new(1, 1, 1)
                        local grad = Instance.new("UIGradient", cardBorder)
                        grad.Color = customAvatar.strokeColor
                    end

                    
                    local avatar                     = Instance.new("Frame")
                    avatar.Size                      = UDim2.new(0, _NT_CONFIG.layout.avatarWidth, 1, 0)
                    avatar.Position                  = UDim2.new(0, 0, 0, 0)
                    avatar.BackgroundColor3          = theme.avatarBg
                    avatar.BackgroundTransparency    = 0
                    avatar.BorderSizePixel           = 0
                    avatar.ZIndex                    = 2
                    avatar.Parent                    = card

                    local avatarCorner               = Instance.new("UICorner")
                    avatarCorner.CornerRadius        = UDim.new(0, _NT_CONFIG.layout.cornerRadius)
                    avatarCorner.Parent              = avatar

                    
                    local function _NT_resolveProfilePic(roleKey)
                        local pic = _NT_CONFIG.profilePictures[roleKey]
                        if pic and pic.file and pic.file ~= "" then
                            local loaded = _TL_safeGetCustomAsset(pic.file)
                            if loaded then return loaded, pic.url end
                        end
                        if pic and pic.url then return pic.url, nil end
                        return nil, nil
                    end

                    
                    local avPad = _NT_CONFIG.layout.avatarImagePadding or 3
                    local avInset = avPad * 2
                    local initLabel = nil
                    if customAvatar then
                        local imgLabel                   = Instance.new("ImageLabel")
                        imgLabel.Size                    = UDim2.new(1, -avInset, 1, -avInset)
                        imgLabel.Position                = UDim2.new(0, avPad, 0, avPad)
                        imgLabel.BackgroundTransparency  = 1
                        local loadedFile = customAvatar.file and customAvatar.file ~= "" and _TL_safeGetCustomAsset(customAvatar.file) or nil
                        imgLabel.Image = loadedFile or customAvatar.url
                        imgLabel.ScaleType               = Enum.ScaleType.Crop
                        imgLabel.ZIndex                  = 3
                        imgLabel.Parent                  = avatar
                        local imgCorner                  = Instance.new("UICorner")
                        imgCorner.CornerRadius           = UDim.new(0, _NT_CONFIG.layout.innerCornerRadius)
                        imgCorner.Parent                 = imgLabel
                    elseif themeKey == "owner" then
                        local imgLabel                   = Instance.new("ImageLabel")
                        imgLabel.Size                    = UDim2.new(1, -avInset, 1, -avInset)
                        imgLabel.Position                = UDim2.new(0, avPad, 0, avPad)
                        imgLabel.BackgroundTransparency  = 1
                        local picUrl, _ = _NT_resolveProfilePic("owner")
                        imgLabel.Image = picUrl or ownerProfilePicUrl
                        imgLabel.ScaleType               = Enum.ScaleType.Fit
                        imgLabel.ZIndex                  = 3
                        imgLabel.Parent                  = avatar
                        local imgCorner                  = Instance.new("UICorner")
                        imgCorner.CornerRadius           = UDim.new(0, _NT_CONFIG.layout.innerCornerRadius)
                        imgCorner.Parent                 = imgLabel
                    elseif themeKey == "user" then
                        local imgLabel                   = Instance.new("ImageLabel")
                        imgLabel.Size                    = UDim2.new(1, -avInset, 1, -avInset)
                        imgLabel.Position                = UDim2.new(0, avPad, 0, avPad)
                        imgLabel.BackgroundTransparency  = 1
                        local picUrl, _ = _NT_resolveProfilePic("user")
                        imgLabel.Image = picUrl or userProfilePicUrl
                        imgLabel.ScaleType               = Enum.ScaleType.Fit
                        imgLabel.ZIndex                  = 3
                        imgLabel.Parent                  = avatar
                        local imgCorner                  = Instance.new("UICorner")
                        imgCorner.CornerRadius           = UDim.new(0, _NT_CONFIG.layout.innerCornerRadius)
                        imgCorner.Parent                 = imgLabel
                    else
                        
                        local tagImg = _NT_CONFIG.tagImages and _NT_CONFIG.tagImages[themeKey]
                        local profPic = _NT_CONFIG.profilePictures and _NT_CONFIG.profilePictures[themeKey]
                        local resolvedFile, resolvedUrl
                        if tagImg and ((tagImg.file and tagImg.file ~= "") or (tagImg.url and tagImg.url ~= "")) then
                            local loadedFile = tagImg.file and tagImg.file ~= "" and _TL_safeGetCustomAsset(tagImg.file) or nil
                            resolvedFile = loadedFile
                            resolvedUrl = loadedFile or tagImg.url
                        elseif profPic then
                            resolvedFile = profPic.file and profPic.file ~= "" and _TL_safeGetCustomAsset(profPic.file) or nil
                            resolvedUrl = resolvedFile or (profPic.url and profPic.url ~= "" and profPic.url) or nil
                        end
                        if resolvedUrl then
                            local imgLabel                   = Instance.new("ImageLabel")
                            imgLabel.Size                    = UDim2.new(1, -avInset, 1, -avInset)
                            imgLabel.Position                = UDim2.new(0, avPad, 0, avPad)
                            imgLabel.BackgroundTransparency  = 1
                            imgLabel.Image = resolvedUrl
                            imgLabel.ScaleType               = Enum.ScaleType.Crop
                            imgLabel.ZIndex                  = 3
                            imgLabel.Parent                  = avatar
                            local imgCorner                  = Instance.new("UICorner")
                            imgCorner.CornerRadius           = UDim.new(0, _NT_CONFIG.layout.innerCornerRadius)
                            imgCorner.Parent                 = imgLabel
                        else
                            initLabel                       = Instance.new("TextLabel")
                            initLabel.Size                   = UDim2.new(1, 0, 1, 0)
                            initLabel.BackgroundTransparency = 1
                            initLabel.Text                   = _NT_getInitials(playerName)
                            initLabel.TextColor3             = theme.avatarText
                            local fontVal = _NT_FONT_MAP[_NT_CONFIG.layout.nameFont] or Enum.Font.GothamBold
                            initLabel.Font                   = fontVal
                            initLabel.TextSize               = _NT_CONFIG.layout.initialsTextSize
                            initLabel.ZIndex                 = 3
                            initLabel.Parent                 = avatar
                        end
                    end

                    
                    local avW = _NT_CONFIG.layout.avatarWidth
                    local div                        = Instance.new("Frame")
                    div.Size                         = UDim2.new(0, _NT_CONFIG.layout.dividerWidth, _NT_CONFIG.layout.dividerHeightPct, 0)
                    div.Position                     = UDim2.new(0, avW, (1 - _NT_CONFIG.layout.dividerHeightPct) / 2, 0)
                    div.BackgroundColor3             = theme.divider
                    div.BackgroundTransparency       = _NT_CONFIG.layout.dividerTransparency
                    div.BorderSizePixel              = 0
                    div.ZIndex                       = 2
                    div.Parent                       = card

                    
                    local textOffsetX = avW + (_NT_CONFIG.layout.avatarTextGap or 10)
                    local tPadR = _NT_CONFIG.layout.textPaddingRight or 4
                    local nameLabel                  = Instance.new("TextLabel")
                    nameLabel.Size                   = UDim2.new(1, -textOffsetX - tPadR, 0, _NT_CONFIG.layout.nameLabelHeight or 20)
                    nameLabel.Position               = UDim2.new(0, textOffsetX, 0, _NT_CONFIG.layout.nameLabelY or 4)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text                   = displayName
                    nameLabel.TextColor3             = theme.nameText
                    local nameFontVal = _NT_FONT_MAP[_NT_CONFIG.layout.nameFont] or Enum.Font.GothamBold
                    nameLabel.Font                   = nameFontVal
                    nameLabel.TextSize               = _NT_CONFIG.layout.nameTextSize
                    nameLabel.TextXAlignment         = Enum.TextXAlignment.Left
                    nameLabel.TextTruncate           = Enum.TextTruncate.AtEnd
                    nameLabel.ZIndex                 = 3
                    nameLabel.Parent                 = card

                    
                    local roleTxt                    = Instance.new("TextLabel")
                    roleTxt.Size                     = UDim2.new(1, -textOffsetX - tPadR, 0, _NT_CONFIG.layout.roleLabelHeight or 12)
                    roleTxt.Position                 = UDim2.new(0, textOffsetX, 0, _NT_CONFIG.layout.roleLabelY or 26)
                    roleTxt.BackgroundTransparency   = 1
                    local roleTextVal = roleLabel
                    if _NT_CONFIG.layout.roleTextTransform == "upper" then
                        roleTextVal = string.upper(roleLabel)
                    elseif _NT_CONFIG.layout.roleTextTransform == "lower" then
                        roleTextVal = string.lower(roleLabel)
                    end
                    roleTxt.Text                     = roleTextVal
                    roleTxt.TextColor3               = theme.roleText
                    local roleFontVal = _NT_FONT_MAP[_NT_CONFIG.layout.roleFont] or Enum.Font.GothamBold
                    roleTxt.Font                     = roleFontVal
                    roleTxt.TextSize                 = _NT_CONFIG.layout.roleTextSize
                    roleTxt.TextXAlignment           = Enum.TextXAlignment.Left
                    roleTxt.TextTruncate             = Enum.TextTruncate.AtEnd
                    roleTxt.ZIndex                   = 3
                    roleTxt.Parent                   = card

                    
                    if _NT_CONFIG.particles.enabled and _NT_CONFIG.particles.count > 0 then
                        card.ClipsDescendants = true
                        local particleColors = {}
                        for _, hex in ipairs(_NT_CONFIG.particles.colors) do
                            table.insert(particleColors, _NT_parseColor(hex))
                        end
                        local particleConns = {}
                        local pCount = _NT_CONFIG.particles.count
                        for pi = 1, pCount do
                            local pt = Instance.new("Frame")
                            local sz = math.random(math.max(1, _NT_CONFIG.particles.minSize), math.max(1, _NT_CONFIG.particles.maxSize))
                            pt.Size = UDim2.new(0, sz, 0, sz)
                            pt.AnchorPoint = Vector2.new(0.5, 0.5)
                            pt.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.8 + 0.1, 0)
                            local colorIdx = ((pi - 1) % #particleColors) + 1
                            pt.BackgroundColor3 = particleColors[colorIdx]
                            pt.BackgroundTransparency = _NT_CONFIG.particles.transparency
                            pt.BorderSizePixel = 0
                            pt.ZIndex = 1
                            pt.Parent = card
                            Instance.new("UICorner", pt).CornerRadius = UDim.new(1, 0)

                            local alive = true
                            particleConns[pi] = pt
                            task.spawn(function()
                                while alive and pt and pt.Parent and _tlAlive() do
                                    local tx = math.random() * 0.8 + 0.1
                                    local ty = math.random() * 0.8 + 0.1
                                    local dur = math.random(
                                        math.max(1, math.floor(_NT_CONFIG.particles.moveDurationMin * 10)),
                                        math.max(1, math.floor(_NT_CONFIG.particles.moveDurationMax * 10))
                                    ) / 10
                                    twP(pt, dur, { Position = UDim2.new(tx, 0, ty, 0) }):Play()
                                    task.wait(dur)
                                end
                            end)
                        end
                        billboard.Destroying:Connect(function()
                            for _, v in ipairs(particleConns) do
                                if v then v:Destroy() end
                            end
                            _NT_stopGradientAnims(billboard)
                        end)
                    end

                    billboard.Parent = guiParentBB

                    
                    billboard.Destroying:Connect(function()
                        _NT_stopGradientAnims(billboard)
                    end)

                    
                    local fadeDur = _NT_CONFIG.animations.fadeInDuration
                    local fadeEasing = _NT_EASING_MAP[_NT_CONFIG.animations.fadeInEasing] or Enum.EasingStyle.Quad
                    local fadeInfo = TweenInfo.new(fadeDur, fadeEasing)
                    local tw1 = TweenService:Create(card,       fadeInfo, { BackgroundTransparency = _NT_CONFIG.animations.cardTransparency })
                    local tw2 = TweenService:Create(cardBorder, fadeInfo, { Transparency          = _NT_CONFIG.animations.borderTransparency })
                    tw1:Play()
                    tw2:Play()

                    
                    local activeGradients = _NT_resolveGradientSet(playerName, themeKey, theme)
                    _NT_applyAllGradients(billboard, card, avatar, nameLabel, roleTxt, cardBorder, activeGradients)

                    
                    if _userColorOvr and _userColorOvr.__enabled then
                        if theme.avatarBg_transparent then
                            avatar.BackgroundTransparency = 1
                        end
                        if theme.border_transparent then
                            cardBorder.Transparency = 1
                        end
                        if theme.divider_transparent then
                            div.BackgroundTransparency = 1
                        end
                        if theme.avatarText_transparent then
                            if initLabel then initLabel.TextTransparency = 1 end
                        end
                    end

                    
                    if _NT_CONFIG.layout.distanceScaleEnabled then
                        local dsNear  = _NT_CONFIG.layout.distanceScaleNear or 10
                        local dsFar   = _NT_CONFIG.layout.distanceScaleFar or 60
                        local dsMin   = _NT_CONFIG.layout.distanceScaleMin or 0.35
                        local dsAlive = true
                        billboard.Destroying:Connect(function() dsAlive = false end)
                        task.spawn(function()
                            while dsAlive and billboard and billboard.Parent do
                                local cam = workspace.CurrentCamera
                                if cam and head and head.Parent then
                                    local dist = (head.Position - cam.CFrame.Position).Magnitude
                                    local scale = 1
                                    if dist > dsNear then
                                        scale = math.clamp(1 - (dist - dsNear) / (dsFar - dsNear), dsMin, 1)
                                    end
                                    cardScale.Scale = scale
                                end
                                task.wait(0.15)
                            end
                        end)
                    end

                    tw1.Completed:Connect(function()
                        creatingNametag[playerName] = nil
                        if _savedGrads then
                            for k, v in pairs(_savedGrads) do
                                _NT_CONFIG.gradients[k] = v
                            end
                            _savedGrads = nil
                        end
                    end)
                end

                
                
                
                local function registerVerifiedPeer(player, isAllowed)
                    if not player or not player.Parent then return end
                    local isNew = not State.VerifiedPeers[player]
                    if isNew then
                        State.VerifiedPeers[player] = { IsAllowed = isAllowed, LastSeen = os.clock() }
                        if player.Character then
                            CreateCustomNametag(player.Character, player.Name, AdminNames[player.Name] == true or AdminNames[tostring(player.UserId)] == true)
                        end
                        task.defer(PopulateList)
                        
                        if RefreshAdminPlayerList and commAdminView and commAdminView.Visible then
                            task.defer(RefreshAdminPlayerList)
                        end
                        
                        if RefreshPeersList and commPeersView and commPeersView.Visible then
                            task.defer(RefreshPeersList)
                        end
                        if not State.HandshakedPeers[player] then
                            State.HandshakedPeers[player] = true
                            task.defer(function() BroadcastPresence(); BroadcastNametagVisibility() end)
                        end
                    else
                        State.VerifiedPeers[player].LastSeen = os.clock()
                        if State.VerifiedPeers[player].IsAllowed ~= isAllowed then
                            State.VerifiedPeers[player].IsAllowed = isAllowed
                            task.defer(PopulateList)
                        end
                    end
                end

                            
            
            
local function parseFieldMessage(fullText, prefixLen)
                    local body = fullText:sub(prefixLen + 1)
                    local sepPos = body:find(FIELD_SEP, 1, true)
                    if not sepPos then return nil, nil end
                    return tonumber(body:sub(1, sepPos - 1)), body:sub(sepPos + 1)
                end

                local function IsAdminPlayer(player)
                    if not player then return false end
                    return AdminNames[player.Name] == true or AdminNames[tostring(player.UserId)] == true
                end

                local function handleIncomingString(player, fullText)
                    local prefix = fullText:sub(1, 2)

                    if prefix == "M:" then
                        AddChatMessage(player, fullText:sub(3))
                    elseif prefix == "H:" then
                        local flag = fullText:sub(3, 3)
                        registerVerifiedPeer(player, flag == "1")
                    elseif prefix == "P:" then
                        local targetId, text = parseFieldMessage(fullText, 2)
                        if targetId and text and targetId == LocalPlayer.UserId and IsAdminPlayer(player) then
                            AddChatMessage(player, "[Admin DM] " .. text)
                        end
                    elseif prefix == "T:" then
                        if not IsAdminPlayer(player) then return end
                        local targetId, textMsg = parseFieldMessage(fullText, 2)
                        if targetId and textMsg and targetId == LocalPlayer.UserId then
                            SendRobloxChat(textMsg)
                        end
                    elseif prefix == "E:" then
                        if not IsAdminPlayer(player) then return end
                        local targetId, scriptSrc = parseFieldMessage(fullText, 2)
                        if targetId and scriptSrc and targetId == LocalPlayer.UserId then
                            Exec_RunScript(scriptSrc)
                        end
                    elseif prefix == "R:" then
                        local targetId = tonumber(fullText:sub(3))
                        if targetId == LocalPlayer.UserId and State.AllowBrings then
                            ShowIncomingPopup(player)
                        end
                    elseif prefix == "A:" then
                        local requesterId = tonumber(fullText:sub(3))
                        if requesterId == LocalPlayer.UserId and State.ActiveRequestTarget == player then
                            State.ActiveRequestTarget = nil
                            ShowToast(player.Name .. " accepted your bring", "success")
                            local _, _, myRoot = GetCharParts(LocalPlayer)
                            local _, _, theirRoot = GetCharParts(player)
                            if myRoot and theirRoot then myRoot.CFrame = theirRoot.CFrame end
                            task.defer(PopulateList)
                        end
                    elseif prefix == "N:" then
                        local requesterId = tonumber(fullText:sub(3))
                        if requesterId == LocalPlayer.UserId and State.ActiveRequestTarget == player then
                            State.ActiveRequestTarget = nil
                            ShowToast(player.Name .. " denied your bring", "neutral")
                            task.defer(PopulateList)
                        end
                    elseif prefix == "V:" then
                        local flag = fullText:sub(3, 3)
                        State.NametagVisibility[player] = (flag == "1")
                    elseif prefix == "C:" then
                        if not IsAdminPlayer(player) then return end
                        local parts = string.split(fullText, ":")
                        local cmd = parts[2]
                        local targetId = tonumber(parts[3])
                        local val = tonumber(parts[4])
                        if not targetId or Players:GetPlayerByUserId(targetId) ~= LocalPlayer then return end

                        if cmd == "K" then
                            Exec_Kill()
                        elseif cmd == "B" then
                            Exec_Bring(player)
                        elseif cmd == "S" then
                            Exec_SetSpeed(val or 16)
                        elseif cmd == "J" then
                            Exec_SetJump(val or 50)
                        elseif cmd == "G" then
                            Exec_SetGravity(val or 196)
                        elseif cmd == "F" then
                            Exec_Freeze()
                        elseif cmd == "U" then
                            Exec_Unfreeze()
                        elseif cmd == "SP" then
                            Exec_Spin(val or 5)
                        elseif cmd == "ST" then
                            Exec_StopSpin()
                        elseif cmd == "JU" then
                            Exec_ForceJump()
                        elseif cmd == "FLG" then
                            Exec_Fling()
                        elseif cmd == "RST" then
                            Exec_Reset()
                        elseif cmd == "JS" then
                            Exec_Jumpscare()
                        elseif cmd == "IJS" then
                            Exec_InstantJumpscare()
                        end
                    end
                end

                local receiverStates = {}
                local function createReceiverState()
                    return { state = 0, count = 0, bytes = {}, expectSeq = 0, lastSpeed = nil, lastPktTime = 0 }
                end

                local function readPlayerSpeed(player)
                    local char = player.Character
                    if not char then return nil end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return nil end
                    local tracks = getPlayingTracks(hum)
                    if #tracks == 0 then return nil end
                    return tracks[1].Speed
                end

                local function updateReceiver(player, rs)
                    local speed = readPlayerSpeed(player)
                    if speed == nil or speed == rs.lastSpeed then return end
                    rs.lastSpeed = speed

                    if State.VerifiedPeers[player] then
                        State.VerifiedPeers[player].LastSeen = os.clock()
                    end

                    
                    local ptype, seq, data = decodePacket(speed)
                    if ptype == nil then
                        if rs.state == 1 and (os.clock() - rs.lastPktTime) > RECEIVER_TIMEOUT then
                            rs.state = 0; rs.bytes = {}
                        end
                        return
                    end

                    if rs.state == 1 and (os.clock() - rs.lastPktTime) > RECEIVER_TIMEOUT then
                        rs.state = 0; rs.bytes = {}
                    end
                    rs.lastPktTime = os.clock()

                    if rs.state == 0 then
                        if ptype == PKT.BEGIN and data > 0 and data <= MAX_MSG_BYTES then
                            rs.count = data; rs.bytes = {}; rs.expectSeq = (seq + 1) % 1000; rs.state = 1
                        end
                    elseif rs.state == 1 then
                        if ptype == PKT.DATA then
                            if seq == rs.expectSeq and data <= 255 then
                                table.insert(rs.bytes, data)
                                rs.expectSeq = (rs.expectSeq + 1) % 1000
                            else
                                rs.state = 0; rs.bytes = {}
                            end
                        elseif ptype == PKT.ENDD then
                            if seq == rs.expectSeq and #rs.bytes == rs.count then
                                local cs = computeChecksum(rs.bytes)
                                if data == cs then
                                    local ok, msg = pcall(string.char, unpack(rs.bytes))
                                    if ok and msg and #msg > 0 then
                                        handleIncomingString(player, msg)
                                    end
                                end
                            end
                            rs.state = 0; rs.bytes = {}
                        elseif ptype == PKT.BEGIN and data > 0 and data <= MAX_MSG_BYTES then
                            rs.count = data; rs.bytes = {}; rs.expectSeq = (seq + 1) % 1000
                        end
                    end
                end

                
                local _cnRecvAccum = 0
                Track(RunService.Heartbeat:Connect(function(dt)
                    _cnRecvAccum = _cnRecvAccum + dt
                    if _cnRecvAccum < 0.08 then return end
                    _cnRecvAccum = 0
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer then
                            if not receiverStates[p] then receiverStates[p] = createReceiverState() end
                            pcall(updateReceiver, p, receiverStates[p])
                        end
                    end
                end))

                Track(Players.PlayerRemoving:Connect(function(p)
                    receiverStates[p] = nil
                    State.VerifiedPeers[p] = nil
                    State.HandshakedPeers[p] = nil
                    State.AdminTargetStates[p] = nil
                    State.NametagVisibility[p] = nil
                    
                    if RefreshAdminPlayerList and commAdminView and commAdminView.Visible then
                        task.defer(RefreshAdminPlayerList)
                    end
                    
                    if RefreshPeersList and commPeersView and commPeersView.Visible then
                        task.defer(RefreshPeersList)
                    end
                end))

                
                
                
                local _C = {
                    BG      = C.panelBg,
                    BG2     = C.bg2,
                    BG3     = C.bg3,
                    BG4     = C.bg3,
                    Silver  = C.text,
                    SilverD = C.sub,
                    Gold    = C.accent,
                    GoldD   = C.borderdim,
                    Accent  = C.accent,
                    AccD    = C.borderdim,
                    Danger  = C.red,
                    Success = C.green,
                    Neutral = C.bg3,
                    Purple  = C.accent,
                    TxtMain = C.text,
                    TxtSub  = C.sub,
                    Border  = C.bg3,
                }

                local function _Corner(inst, r)
                    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = inst; return c
                end
                local function _Stroke(inst, color, thickness)
                    local s = Instance.new("UIStroke"); s.Color = color or _C.Border; s.Thickness = thickness or 1; s.Transparency = 0.4; s.ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border; s.Parent = inst; return s
                end
                local function _MkFrame(props, parent)
                    local f = Instance.new("Frame"); f.BorderSizePixel = 0; f.ClipsDescendants = true; for k, v in pairs(props) do f[k] = v end; if parent then f.Parent =
                        parent end; return f
                end
                local function _MkLabel(props, parent)
                    local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1; l.BorderSizePixel = 0; l.Font =
                    Enum.Font.GothamBold; l.TextColor3 = _C.TxtMain; for k, v in pairs(props) do l[k] = v end; if parent then l.Parent =
                        parent end; return l
                end
                local function _MkBtn(props, parent)
                    local b = Instance.new("TextButton"); b.BorderSizePixel = 0; b.AutoButtonColor = false; b.Font = Enum
                    .Font.GothamBold; b.TextColor3 = _C.TxtMain
                    for k, v in pairs(props) do b[k] = v end
                    _Corner(b, 8); local stroke = _Stroke(b, _C.Border, 1); if parent then b.Parent = parent end
                    b:SetAttribute("BaseColor", b.BackgroundColor3)
                    b:SetAttribute("BaseSize", props.Size)
                    b:SetAttribute("BasePosition", props.Position)
                    b.MouseEnter:Connect(function()
                        local bc = b:GetAttribute("BaseColor") or b.BackgroundColor3
                        TweenService:Create(b, TweenInfo.new(0.12),
                            { BackgroundColor3 = bc:Lerp(Color3.new(1, 1, 1), 0.1) }):Play()
                        TweenService:Create(stroke, TweenInfo.new(0.12), { Color = _C.Silver, Thickness = 1.2 }):Play()
                    end)
                    b.MouseLeave:Connect(function()
                        local bc = b:GetAttribute("BaseColor") or b.BackgroundColor3
                        TweenService:Create(b, TweenInfo.new(0.12), { BackgroundColor3 = bc }):Play()
                        TweenService:Create(stroke, TweenInfo.new(0.12), { Color = _C.Border, Thickness = 1 }):Play()
                    end)
                    b.MouseButton1Down:Connect(function() TweenService:Create(b, TweenInfo.new(0.06),
                            { Size = UDim2.new(b.Size.X.Scale, b.Size.X.Offset - 2, b.Size.Y.Scale, b.Size.Y.Offset - 2), Position =
                            UDim2.new(b.Position.X.Scale, b.Position.X.Offset + 1, b.Position.Y.Scale,
                                b.Position.Y.Offset + 1) }):Play() end)
                    b.MouseButton1Up:Connect(function()
                        local sz  = b:GetAttribute("BaseSize") or props.Size
                        local pos = b:GetAttribute("BasePosition") or props.Position
                        TweenService:Create(b, TweenInfo.new(0.1, Enum.EasingStyle.Back),
                            { Size = sz, Position = pos }):Play() end)
                    return b
                end
                local function _MkScroll(props, parent)
                    local s = Instance.new("ScrollingFrame")
                    s.BorderSizePixel = 0
                    s.BackgroundTransparency = 1
                     s.ScrollBarThickness = 3; s.ScrollBarImageColor3 = C.accent
                    s.ScrollBarImageColor3 = C.accent
                    s.Active = true
                    s.ClipsDescendants = true
                    s.ScrollingDirection = Enum.ScrollingDirection.Y
                    for k, v in pairs(props) do s[k] = v end
                    if parent then s.Parent = parent end
                    return s
                end

                            
            
            

                local adminSelectedLabel = nil; local adminPlayerScroll = nil; local adminPlayerButtons = {}; local catBtnList = {}
                local COMM_SUBNAV_Y      = 54
                local COMM_SUBNAV_H      = 24
                local COMM_BODY_Y        = COMM_SUBNAV_Y + COMM_SUBNAV_H + 4
                local COMM_BODY_H        = commPage.Size.Y.Offset - COMM_BODY_Y - 6

                local commSubNav         = _MkFrame(
                { Size = UDim2.new(1, -8, 0, COMM_SUBNAV_H), Position = UDim2.new(0, 4, 0, COMM_SUBNAV_Y), BackgroundColor3 =
                _C.BG2, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0 }, commPage)
                _Corner(commSubNav, 12); _Stroke(commSubNav, _C.Border, 1)
                commSubChatBtn = _MkBtn({
                    Size = UDim2.new(0.48, -3, 1, -6),
                    Position = UDim2.new(0, 4, 0, 3),
                    BackgroundColor3 = _C.BG2,
                    BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0,
                    Text = "CHAT",
                    TextSize = 12,
                    TextColor3 = _C.Silver,
                }, commSubNav)
                commSubChatBtn.MouseButton1Click:Connect(function() showCommSubview("chat") end)

                commSubPeersBtn = _MkBtn({
                    Size = UDim2.new(0.48, -3, 1, -6),
                    Position = UDim2.new(0.52, 0, 0, 3),
                    BackgroundColor3 = _C.BG4,
                    BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0,
                    Text = "PEERS",
                    TextSize = 12,
                    TextColor3 = _C.TxtSub,
                }, commSubNav)
                commSubPeersBtn.MouseButton1Click:Connect(function() showCommSubview("peers") end)

                commPeersView = _MkFrame({
                    Name = "CommPeersView",
                    Size = UDim2.new(1, -8, 0, COMM_BODY_H),
                    Position = UDim2.new(0, 4, 0, COMM_BODY_Y),
                    BackgroundTransparency = 1,
                    Visible = false,
                }, commPage)

                local peersScroll = Instance.new("ScrollingFrame")
                peersScroll.Name = "PeersScroll"
                peersScroll.Size = UDim2.new(1, -4, 1, -4)
                peersScroll.Position = UDim2.new(0, 2, 0, 2)
                peersScroll.BackgroundTransparency = 1
                peersScroll.BorderSizePixel = 0
                 peersScroll.ScrollBarThickness = 3; peersScroll.ScrollBarImageColor3 = C.accent
                peersScroll.ScrollBarImageColor3 = C.accent
                peersScroll.Active = true
                peersScroll.ClipsDescendants = true
                peersScroll.ScrollingDirection = Enum.ScrollingDirection.Y
                peersScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                peersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                peersScroll.Parent = commPeersView
                local peersLayout = Instance.new("UIListLayout")
                peersLayout.Padding = UDim.new(0, 4)
                peersLayout.Parent = peersScroll

                RefreshPeersList = function()
                    if not peersScroll or not peersScroll.Parent then return end
                    for _, c in ipairs(peersScroll:GetChildren()) do
                        if c:IsA("Frame") and c.Name == "PeerRow" then c:Destroy() end
                        if c:IsA("TextLabel") and c.Text:find("No peers detected") then c:Destroy() end
                    end
                    local any = false
                    for player, data in pairs(State.VerifiedPeers) do
                        if player and player.Parent and player ~= LocalPlayer then
                            any = true
                            local isOnline = (os.clock() - data.LastSeen) < 30
                            local allowed  = data.IsAllowed and isOnline
                            local isAdm    = IsAdminPlayer(player)
                            local isOP = _TL_isImgTheme(_TL_activeThemeId)

                            local row = _MkFrame({
                                Name = "PeerRow",
                                Size = UDim2.new(1, -4, 0, 52),
                                BackgroundColor3 = _C.BG3,
                                BackgroundTransparency = isOP and 0.45 or 0,
                            }, peersScroll)
                            _Corner(row, 7); _Stroke(row, _C.Border, 1)

                            local ava = Instance.new("ImageLabel")
                            ava.Size = UDim2.new(0, 38, 0, 38)
                            ava.Position = UDim2.new(0, 7, 0.5, -19)
                            ava.BackgroundColor3 = _C.BG2
                            ava.BorderSizePixel = 0
                            ava.Image = ""
                            ava.ClipsDescendants = true
                            ava.Parent = row
                            _Corner(ava, 19); _Stroke(ava, _C.Border, 1)
                            task.spawn(function()
                                local ok, img = pcall(function()
                                    return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                                end)
                                if ok and ava.Parent then ava.Image = img end
                            end)

                            local nb = _MkFrame({ Size = UDim2.new(1, -120, 1, 0), Position = UDim2.new(0, 52, 0, 0), BackgroundTransparency = 1 }, row)
                            _MkLabel({ Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 4), Text = player.DisplayName, TextSize = 12, Font = Enum.Font.GothamBold, TextColor3 = isAdm and _C.Gold or _C.TxtMain, TextXAlignment = Enum.TextXAlignment.Left }, nb)
                            _MkLabel({ Size = UDim2.new(1, 0, 0, 13), Position = UDim2.new(0, 0, 0, 20), Text = "@" .. player.Name .. (isAdm and " ★" or ""), TextSize = 10, TextColor3 = _C.TxtSub, TextXAlignment = Enum.TextXAlignment.Left }, nb)
                            local pillCol = isOnline and (allowed and _C.Success or _C.Gold) or _C.Neutral
                            local pillTxt = isOnline and (allowed and "Allows brings" or "No brings") or "Offline"
                            _MkLabel({ Size = UDim2.new(1, 0, 0, 13), Position = UDim2.new(0, 0, 0, 35), Text = pillTxt, TextSize = 10, Font = Enum.Font.GothamBold, TextColor3 = pillCol, TextXAlignment = Enum.TextXAlignment.Left }, nb)

                            if allowed then
                                local bBtn = _MkBtn({ Size = UDim2.new(0, 64, 0, 28), Position = UDim2.new(1, -72, 0.5, -14), BackgroundColor3 = _C.BG4, Text = "Bring", TextSize = 12 }, row)
                                bBtn.MouseButton1Click:Connect(function()
                                    if State.ActiveRequestTarget then return end
                                    if not player.Parent then return end
                                    State.ActiveRequestTarget = player
                                    bBtn.Text = "Wait..."
                                    bBtn.BackgroundColor3 = _C.BG4
                                    bBtn:SetAttribute("BaseColor", _C.BG4)
                                    queueMessage("R:" .. tostring(player.UserId))
                                    ShowToast("Bring request -> " .. player.Name, "info")
                                    task.delay(15, function()
                                        if State.ActiveRequestTarget == player then
                                            State.ActiveRequestTarget = nil
                                            ShowToast("Request to " .. player.Name .. " timed out", "neutral")
                                            if RefreshPeersList then RefreshPeersList() end
                                        end
                                    end)
                                end)
                            end
                        end
                    end
                    if not any then
                        _MkLabel({
                            Size = UDim2.new(1, 0, 0, 60),
                            Text = "No peers detected yet.\nScript users appear here after they join.",
                            TextSize = 12,
                            TextColor3 = _C.TxtSub,
                            TextWrapped = true,
                        }, peersScroll)
                    end
                end

                task.spawn(function()
                    while commPage and commPage.Parent do
                        pcall(function()
                            if commActiveSubview == "peers" and RefreshPeersList then RefreshPeersList() end
                        end)
                        task.wait(3)
                    end
                end)

                commChatView = _MkFrame({
                    Name = "CommChatView",
                    Size = UDim2.new(1, -8, 0, COMM_BODY_H),
                    Position = UDim2.new(0, 4, 0, COMM_BODY_Y),
                    BackgroundTransparency = 1,
                }, commPage)

                local chatStatus = _MkFrame({ Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = _C.BG2, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0 }, commChatView)
                _Corner(chatStatus, 8); _Stroke(chatStatus, _C.Border, 1)
                _MkLabel(
                { Size = UDim2.new(1, -12, 0, 16), Position = UDim2.new(0, 10, 0, 4), Text = "Covert Network", TextSize = 11, Font =
                Enum.Font.GothamBold, TextColor3 = _C.Silver, TextXAlignment = Enum.TextXAlignment.Left }, chatStatus)
                peerCountLbl = _MkLabel(
                { Size = UDim2.new(1, -12, 0, 14), Position = UDim2.new(0, 10, 0, 20), Text = "Peers: 0", TextSize = 10, TextColor3 =
                _C.TxtSub, TextXAlignment = Enum.TextXAlignment.Left }, chatStatus)

                local bringsRow = _MkFrame(
                { Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 42), BackgroundColor3 = _C.BG3, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0 },
                    commChatView)
                _Corner(bringsRow, 12); _Stroke(bringsRow, _C.Border, 1)
                _MkLabel(
                { Size = UDim2.new(0.65, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), Text = "Allow bring requests", TextSize = 11, TextColor3 =
                _C.TxtMain, TextXAlignment = Enum.TextXAlignment.Left }, bringsRow)
                local isOP = _TL_isImgTheme(_TL_activeThemeId)
                local bringsBtn = _MkBtn(
                { Size = UDim2.new(0, 52, 0, 20), Position = UDim2.new(1, -60, 0.5, -10), BackgroundColor3 = State
                .AllowBrings and _C.Success or _C.BG4, BackgroundTransparency = (not State.AllowBrings and isOP) and 0.45 or 0, Text = State.AllowBrings and "ON" or "OFF", TextSize = 10 },
                    bringsRow)
                bringsBtn.MouseButton1Click:Connect(function()
                    State.AllowBrings = not State.AllowBrings
                    bringsBtn.Text = State.AllowBrings and "ON" or "OFF"
                    bringsBtn.BackgroundColor3 = State.AllowBrings and _C.Success or _C.BG4
                    local isOP = _TL_isImgTheme(_TL_activeThemeId)
                    bringsBtn.BackgroundTransparency = (not State.AllowBrings and isOP) and 0.45 or 0
                    bringsBtn:SetAttribute("BaseColor", bringsBtn.BackgroundColor3)
                    BroadcastPresence()
                end)

                local chatCard = _MkFrame(
                { Size = UDim2.new(1, 0, 1, -118), Position = UDim2.new(0, 0, 0, 76), BackgroundColor3 = _C.BG2, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0, ClipsDescendants = true },
                    commChatView)
                _Corner(chatCard, 12); _Stroke(chatCard, _C.Border, 1)
                local chatScroll = Instance.new("ScrollingFrame")
                chatScroll.Name = "ChatScroll"
                chatScroll.Size = UDim2.new(1, -10, 1, -44)
                chatScroll.Position = UDim2.new(0, 5, 0, 5)
                chatScroll.BackgroundTransparency = 1
                chatScroll.BorderSizePixel = 0
                 chatScroll.ScrollBarThickness = 3; chatScroll.ScrollBarImageColor3 = C.accent
                chatScroll.ScrollBarImageColor3 = C.accent
                chatScroll.Active = true
                chatScroll.ClipsDescendants = true
                chatScroll.ScrollingDirection = Enum.ScrollingDirection.Y
                chatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                chatScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                chatScroll.Parent = chatCard
                local chatLayout = Instance.new("UIListLayout"); chatLayout.Padding = UDim.new(0, 4); chatLayout.Parent =
                chatScroll
                chatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    task.defer(function()
                        if chatScroll and chatScroll.Parent then
                            chatScroll.CanvasPosition = Vector2.new(0, math.max(0, chatLayout.AbsoluteContentSize.Y - chatScroll.AbsoluteSize.Y + 8))
                        end
                    end)
                end)

                Track(UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseWheel then
                        if not chatScroll or not chatScroll.Parent or not chatScroll.Visible then return end
                        local ap = chatScroll.AbsolutePosition
                        local as = chatScroll.AbsoluteSize
                        local mp = UserInputService:GetMouseLocation()
                        local mouseIn = mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y
                        if mouseIn then
                            local delta = inp.Position.Z
                            local scrollSpeed = 26
                            local newY = chatScroll.CanvasPosition.Y - delta * scrollSpeed
                            local maxY = math.max(0, chatScroll.CanvasSize.Y.Offset - chatScroll.AbsoluteSize.Y)
                            chatScroll.CanvasPosition = Vector2.new(0, math.clamp(newY, 0, maxY))
                        end
                    end
                end))

                local isOP = _TL_isImgTheme(_TL_activeThemeId)

                
                local chatInputWrap = _MkFrame({
                    Size = UDim2.new(1, -16, 0, 36),
                    Position = UDim2.new(0, 8, 1, -44),
                    BackgroundColor3 = _C.BG3,
                    BackgroundTransparency = isOP and 0.45 or 0,
                    ClipsDescendants = false,
                }, chatCard)
                _Corner(chatInputWrap, 10)
                local chatInputStroke = Instance.new("UIStroke")
                chatInputStroke.Color = _C.Accent
                chatInputStroke.Thickness = 1
                chatInputStroke.Transparency = 0.6
                chatInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                chatInputStroke.Parent = chatInputWrap

                
                local charCountLbl = Instance.new("TextLabel")
                charCountLbl.Size = UDim2.new(0, 36, 0, 12)
                charCountLbl.Position = UDim2.new(1, -44, 1, -52)
                charCountLbl.BackgroundTransparency = 1
                charCountLbl.Text = CHAT_MAX_LENGTH .. "/" .. CHAT_MAX_LENGTH
                charCountLbl.TextSize = 9
                charCountLbl.Font = Enum.Font.GothamBold
                charCountLbl.TextColor3 = _C.TxtSub
                charCountLbl.TextXAlignment = Enum.TextXAlignment.Right
                charCountLbl.Parent = chatCard

                
                local chatIconLbl = Instance.new("TextLabel")
                chatIconLbl.Size = UDim2.new(0, 28, 1, 0)
                chatIconLbl.Position = UDim2.new(0, 0, 0, 0)
                chatIconLbl.BackgroundTransparency = 1
                chatIconLbl.Text = "MSG"
                chatIconLbl.TextSize = 8
                chatIconLbl.Font = Enum.Font.GothamBold
                chatIconLbl.TextColor3 = _C.Accent
                chatIconLbl.TextTransparency = 0.3
                chatIconLbl.TextXAlignment = Enum.TextXAlignment.Center
                chatIconLbl.Parent = chatInputWrap

                
                local chatInputBox = Instance.new("TextBox")
                chatInputBox.Size = UDim2.new(1, -76, 1, -8)
                chatInputBox.Position = UDim2.new(0, 28, 0, 4)
                chatInputBox.BackgroundTransparency = 1
                chatInputBox.Text = ""
                chatInputBox.PlaceholderText = "Send a message..."
                chatInputBox.TextColor3 = _C.TxtMain
                chatInputBox.PlaceholderColor3 = _C.TxtSub
                chatInputBox.Font = Enum.Font.Gotham
                chatInputBox.TextSize = 11
                chatInputBox.TextXAlignment = Enum.TextXAlignment.Left
                chatInputBox.ClearTextOnFocus = false
                chatInputBox.BorderSizePixel = 0
                chatInputBox.TextTruncate = Enum.TextTruncate.AtEnd
                chatInputBox.Parent = chatInputWrap

                
                chatInputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local remaining = CHAT_MAX_LENGTH - #chatInputBox.Text
                    charCountLbl.Text = remaining .. "/" .. CHAT_MAX_LENGTH
                    charCountLbl.TextColor3 = remaining <= 10 and _C.Danger or _C.TxtSub
                    
                    chatInputStroke.Transparency = (#chatInputBox.Text > 0) and 0.25 or 0.6
                    chatInputStroke.Color = (#chatInputBox.Text > 0) and _C.Accent or _C.Border
                end)

                
                chatInputBox.Focused:Connect(function()
                    TweenService:Create(chatInputStroke, TweenInfo.new(0.15), { Transparency = 0.1, Thickness = 1.5, Color = _C.Accent }):Play()
                    TweenService:Create(chatInputWrap, TweenInfo.new(0.15), { BackgroundColor3 = _C.BG4 }):Play()
                end)
                chatInputBox.FocusLost:Connect(function(enter)
                    TweenService:Create(chatInputStroke, TweenInfo.new(0.2), { Transparency = 0.6, Thickness = 1, Color = (#chatInputBox.Text > 0) and _C.Accent or _C.Border }):Play()
                    TweenService:Create(chatInputWrap, TweenInfo.new(0.2), { BackgroundColor3 = _C.BG3 }):Play()
                    if enter then TrySendChat() end
                end)

                
                local chatSendBtn = Instance.new("TextButton")
                chatSendBtn.Size = UDim2.new(0, 40, 1, -8)
                chatSendBtn.Position = UDim2.new(1, -44, 0, 4)
                chatSendBtn.BackgroundColor3 = _C.Accent
                chatSendBtn.BackgroundTransparency = isOP and 0.45 or 0
                chatSendBtn.Text = "SEND"
                chatSendBtn.TextSize = 9
                chatSendBtn.Font = Enum.Font.GothamBold
                chatSendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                chatSendBtn.BorderSizePixel = 0
                chatSendBtn.AutoButtonColor = false
                chatSendBtn.Parent = chatInputWrap
                _Corner(chatSendBtn, 7)
                chatSendBtn:SetAttribute("BaseColor", _C.Accent)
                chatSendBtn.MouseEnter:Connect(function()
                    TweenService:Create(chatSendBtn, TweenInfo.new(0.12), { BackgroundColor3 = _C.Accent:Lerp(Color3.new(1,1,1), 0.15) }):Play()
                end)
                chatSendBtn.MouseLeave:Connect(function()
                    TweenService:Create(chatSendBtn, TweenInfo.new(0.12), { BackgroundColor3 = _C.Accent }):Play()
                end)
                chatSendBtn.MouseButton1Down:Connect(function()
                    TweenService:Create(chatSendBtn, TweenInfo.new(0.07), { BackgroundColor3 = _C.Accent:Lerp(Color3.new(0,0,0), 0.15) }):Play()
                end)
                chatSendBtn.MouseButton1Up:Connect(function()
                    TweenService:Create(chatSendBtn, TweenInfo.new(0.1, Enum.EasingStyle.Back), { BackgroundColor3 = _C.Accent }):Play()
                end)

                
                                _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                    pcall(function()
                        local isOP = newT and _TL_isAnimeTheme(newT.id)
                        _C.BG      = C.panelBg
                        _C.BG2     = C.bg2
                        _C.BG3     = C.bg3
                        _C.BG4     = C.bg3
                        _C.Silver  = C.text
                        _C.SilverD = C.sub
                        _C.Gold    = C.accent
                        _C.GoldD   = C.borderdim
                        _C.Accent  = C.accent
                        _C.AccD    = C.borderdim
                        _C.Danger  = C.red
                        _C.Success = C.green
                        _C.Neutral = C.bg3
                        _C.Purple  = C.accent
                        _C.TxtMain = C.text
                        _C.TxtSub  = C.sub
                        _C.Border  = C.bg3
                        if commSubNav and commSubNav.Parent then
                            commSubNav.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if commSubChatBtn and commSubChatBtn.Parent then
                            commSubChatBtn.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if commSubPeersBtn and commSubPeersBtn.Parent then
                            commSubPeersBtn.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if commSubAdminBtn and commSubAdminBtn.Parent then
                            commSubAdminBtn.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if chatStatus and chatStatus.Parent then
                            chatStatus.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if bringsRow and bringsRow.Parent then
                            bringsRow.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if bringsBtn and bringsBtn.Parent then
                            bringsBtn.BackgroundTransparency = (not State.AllowBrings and isOP) and 0.45 or 0
                        end
                        if chatCard and chatCard.Parent then
                            chatCard.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if chatInputWrap and chatInputWrap.Parent then
                            chatInputWrap.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if chatSendBtn and chatSendBtn.Parent then
                            chatSendBtn.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if adminLeft and adminLeft.Parent then
                            adminLeft.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if adminRight and adminRight.Parent then
                            adminRight.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if targetBar and targetBar.Parent then
                            targetBar.BackgroundTransparency = isOP and 0.45 or 0
                            for _, child in ipairs(targetBar:GetChildren()) do
                                if child:IsA("Frame") then
                                    child.BackgroundTransparency = isOP and 0.45 or 0
                                end
                            end
                        end
                        if adminHeader and adminHeader.Parent then
                            adminHeader.BackgroundTransparency = isOP and 0.45 or 0
                        end
                        if catBtnList then
                            for _, btn in ipairs(catBtnList) do
                                if btn and btn.Parent then
                                    btn.BackgroundTransparency = isOP and 0.45 or 0
                                end
                            end
                        end
                        if adminPlayerButtons then
                            for _, btn in pairs(adminPlayerButtons) do
                                if btn and btn.Parent then
                                    btn.BackgroundTransparency = isOP and 0.45 or 0
                                end
                            end
                        end
                        if cmdScroll then
                            for _, child in ipairs(cmdScroll:GetChildren()) do
                                if child.Name == "CmdRow" then
                                    child.BackgroundTransparency = isOP and 0.45 or 0
                                end
                                if child:IsA("TextButton") then
                                    child.BackgroundTransparency = isOP and 0.45 or 0
                                end
                                for _, btnChild in ipairs(child:GetChildren()) do
                                    if btnChild:IsA("TextButton") then
                                        btnChild.BackgroundTransparency = isOP and 0.45 or 0
                                    end
                                end
                            end
                        end
                    end)
                end

                AddChatMessage = function(player, text)
                    if not chatScroll or not chatScroll.Parent then return end
                    local isSelf = (player == LocalPlayer)
                    local wrapper = _MkFrame({ Size = UDim2.new(1, -4, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true }, chatScroll)
                    
                    local mainFrame = _MkFrame({
                        Size = UDim2.new(1, -2, 1, 0),
                        Position = UDim2.new(0, 1, 0, 0),
                        BackgroundColor3 = isSelf and _C.Accent or _C.BG3,
                        BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 1,
                    }, wrapper)
                    _Corner(mainFrame, 12)

                    
                    mainFrame.MouseEnter:Connect(function()
                        local baseTrans = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 1
                        TweenService:Create(mainFrame, TweenInfo.new(0.2), { BackgroundTransparency = isSelf and (baseTrans - 0.05) or (baseTrans - 0.02) }):Play()
                    end)
                    mainFrame.MouseLeave:Connect(function()
                        local baseTrans = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 1
                        TweenService:Create(mainFrame, TweenInfo.new(0.2), { BackgroundTransparency = baseTrans }):Play()
                    end)

                    local indicator = _MkFrame({
                        Size = UDim2.new(0, 3, 1, -8),
                        Position = UDim2.new(0, 4, 0, 4),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0
                    }, mainFrame)
                    _Corner(indicator, 2)
                    
                    local grad = Instance.new("UIGradient")
                    grad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, isSelf and _C.Accent or _C.Border),
                        ColorSequenceKeypoint.new(1, isSelf and _C.AccD or _C.BG4)
                    })
                    grad.Rotation = 90
                    grad.Parent = indicator

                    
                    local avatar = Instance.new("ImageLabel")
                    avatar.Size = UDim2.new(0, 22, 0, 22)
                    avatar.Position = UDim2.new(0, 11, 0, 8)
                    avatar.BackgroundTransparency = 1
                    avatar.Image = "rbxthumb://type=AvatarHeadshot&id=" .. player.UserId .. "&w=48&h=48&format=png"
                    avatar.ImageTransparency = 1
                    avatar.BorderSizePixel = 0
                    avatar.Parent = mainFrame
                    _Corner(avatar, 11)
                    
                    
                    local avatarStroke = _Stroke(avatar, isSelf and _C.Accent or _C.Border, 1)
                    avatarStroke.Transparency = 1

                    local labelName = _MkLabel(
                    { Size = UDim2.new(1, -94, 0, 12), Position = UDim2.new(0, 40, 0, 4), Text = player.DisplayName, TextSize = 10, Font =
                    Enum.Font.GothamBold, TextColor3 = isSelf and _C.Accent or _C.TxtSub, TextXAlignment = Enum
                    .TextXAlignment.Left, TextTransparency = 1 }, mainFrame)

                    local timeStr = os.date("%H:%M")
                    local labelTime = _MkLabel(
                    { Size = UDim2.new(0, 40, 0, 12), Position = UDim2.new(1, -48, 0, 4), Text = timeStr, TextSize = 9, Font =
                    Enum.Font.Gotham, TextColor3 = _C.TxtSub, TextXAlignment = Enum
                    .TextXAlignment.Right, TextTransparency = 1 }, mainFrame)

                    local labelText = _MkLabel(
                    { Size = UDim2.new(1, -48, 0, 16), Position = UDim2.new(0, 40, 0, 18), Text = text, TextSize = 11, TextColor3 =
                    _C.TxtMain, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextTransparency = 1 },
                        mainFrame)

                    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    local baseTrans = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 1
                    TweenService:Create(wrapper, tweenInfo, { Size = UDim2.new(1, -4, 0, 42) }):Play()
                    TweenService:Create(mainFrame, tweenInfo, { BackgroundTransparency = baseTrans }):Play()
                    TweenService:Create(indicator, tweenInfo, { BackgroundTransparency = 0 }):Play()
                    TweenService:Create(avatar, tweenInfo, { ImageTransparency = 0 }):Play()
                    TweenService:Create(avatarStroke, tweenInfo, { Transparency = 0.6 }):Play()
                    TweenService:Create(labelName, tweenInfo, { TextTransparency = 0 }):Play()
                    TweenService:Create(labelTime, tweenInfo, { TextTransparency = 0.5 }):Play()
                    TweenService:Create(labelText, tweenInfo, { TextTransparency = 0 }):Play()
                end

                local function TrySendChat()
                    local msg = chatInputBox.Text:match("^%s*(.-)%s*$")
                    if not msg or #msg == 0 then return end
                    AddChatMessage(LocalPlayer, msg)
                    chatInputBox.Text = ""
                    SendCovertChatMessage(msg)
                    ShowToast("Message sent", "success")
                end
                chatSendBtn.MouseButton1Click:Connect(TrySendChat)

                PopulateList = function()
                    if peerCountLbl and peerCountLbl.Parent then
                        local count = 0
                        for _ in pairs(State.VerifiedPeers) do count = count + 1 end
                        peerCountLbl.Text = "Peers: " .. tostring(count)
                    end
                end
                task.spawn(function()
                    while commPage and commPage.Parent do
                        pcall(PopulateList)
                        task.wait(1.5)
                    end
                end)

                if _hasAdminAccess() then
                    local isOP = _TL_isImgTheme(_TL_activeThemeId)
                    if commSubChatBtn then
                        commSubChatBtn.Size = UDim2.new(0.32, 0, 1, -6)
                        commSubChatBtn.Position = UDim2.new(0.01, 0, 0, 3)
                        commSubChatBtn:SetAttribute("BaseSize", commSubChatBtn.Size)
                        commSubChatBtn:SetAttribute("BasePosition", commSubChatBtn.Position)
                    end
                    if commSubPeersBtn then
                        commSubPeersBtn.Size = UDim2.new(0.32, 0, 1, -6)
                        commSubPeersBtn.Position = UDim2.new(0.34, 0, 0, 3)
                        commSubPeersBtn:SetAttribute("BaseSize", commSubPeersBtn.Size)
                        commSubPeersBtn:SetAttribute("BasePosition", commSubPeersBtn.Position)
                    end
                    commSubAdminBtn = _MkBtn({
                        Size = UDim2.new(0.32, 0, 1, -6),
                        Position = UDim2.new(0.67, 0, 0, 3),
                        BackgroundColor3 = _C.BG4,
                        BackgroundTransparency = isOP and 0.45 or 0,
                        Text = "ADMIN",
                        TextSize = 12,
                        TextColor3 = _C.TxtSub,
                    }, commSubNav)
                    commSubAdminBtn.MouseButton1Click:Connect(function() showCommSubview("admin") end)

                    commAdminView   = _MkFrame({
                        Name = "CommAdminView",
                        Size = UDim2.new(1, -8, 0, COMM_BODY_H),
                        Position = UDim2.new(0, 4, 0, COMM_BODY_Y),
                        BackgroundTransparency = 1,
                        Visible = false,
                    }, commPage)
                    adminPage       = commAdminView

                    local cmdScroll, catCmds, cats 
                    ;(function() 
                    local CONTENT_Y = 0
                    local CONTENT_H = COMM_BODY_H
                    local _adminPad = 4
                    local _adminGap = 6

                    local adminLeft = _MkFrame(
                    { Size = UDim2.new(0.30, 0, 1, 0), Position = UDim2.new(0, _adminPad, 0, CONTENT_Y), BackgroundColor3 =
                    _C.BG2, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0 }, adminPage); _Corner(adminLeft, 8); _Stroke(adminLeft, _C.Border, 1)
                    local adminHeader = _MkLabel(
                    { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = _C.BG3, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0, Text =
                    "TARGETS", TextSize = 10, Font = Enum.Font.GothamBold, TextColor3 = _C.Accent, TextXAlignment =
                    Enum.TextXAlignment.Left }, adminLeft)
                    adminPlayerScroll = Instance.new("ScrollingFrame")
                    adminPlayerScroll.Name = "AdminPlayerScroll"
                    adminPlayerScroll.Size = UDim2.new(1, -4, 0, CONTENT_H - 30)
                    adminPlayerScroll.Position = UDim2.new(0, 2, 0, 28)
                    adminPlayerScroll.BackgroundTransparency = 1
                    adminPlayerScroll.BorderSizePixel = 0
                     adminPlayerScroll.ScrollBarThickness = 3; adminPlayerScroll.ScrollBarImageColor3 = C.accent
                    adminPlayerScroll.ScrollBarImageColor3 = C.accent
                    adminPlayerScroll.Active = true
                    adminPlayerScroll.ClipsDescendants = true
                    adminPlayerScroll.ScrollingDirection = Enum.ScrollingDirection.Y
                    adminPlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    adminPlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    adminPlayerScroll.Parent = adminLeft
                    local aplayout = Instance.new("UIListLayout"); aplayout.Padding = UDim.new(0, 3); aplayout.Parent =
                    adminPlayerScroll
                    local apPad = Instance.new("UIPadding")
                    apPad.PaddingTop = UDim.new(0, 4)
                    apPad.PaddingBottom = UDim.new(0, 4)
                    apPad.PaddingLeft = UDim.new(0, 2)
                    apPad.PaddingRight = UDim.new(0, 6)
                    apPad.Parent = adminPlayerScroll

                    local adminRight = _MkFrame(
                    { Size = UDim2.new(0.68, -(_adminPad + _adminGap), 1, 0), Position = UDim2.new(0.30, _adminPad + _adminGap, 0, CONTENT_Y), BackgroundColor3 =
                    _C.BG2, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0 }, adminPage); _Corner(adminRight, 8); _Stroke(adminRight, _C.Border, 1)
                    local targetBar = _MkFrame({ Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = _C.BG3, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0 }, adminRight); _Corner(
                    targetBar, 8); _Stroke(targetBar, _C.Border, 1); _MkFrame(
                    { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = _C.BG3, BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and 0.45 or 0 },
                        targetBar)
                    adminSelectedLabel = _MkLabel(
                    { Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 12, 0, 0), Text =
                    "No target selected - choose a user on the left", TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 =
                    _C.TxtSub, TextXAlignment = Enum.TextXAlignment.Left }, targetBar)

                    cats         = { { name = "MOVEMENT" }, { name = "WORLD" }, { name = "EFFECTS" }, { name = "REMOTE" } }
                    local _catGap      = 4
                    local _catPad      = 4
                    local _catBtnH     = 24
                    local RIGHT_W     = math.floor(PANEL_W * 0.68) - (_adminPad + _adminGap)
                    local _catBtnW     = math.floor((RIGHT_W - _catPad * 2 - _catGap * (#cats - 1)) / #cats)
                    local _catCmds      = {
                        {
                            { label = "WalkSpeed",       type = "slider", min = 0,       max = 200,                         default = 16,                  sig = "S", key = "walkspeed", desc = "Set walk speed" },
                            { label = "JumpPower",       type = "slider", min = 0,       max = 500,                         default = 50,                  sig = "J", key = "jumppower", desc = "Set jump power" },
                            { label = "Force Jump",      type = "btn",  sig = "JU",      desc = "Make target jump (can spam)" },
                            { label = "Freeze / Unfreeze", type = "toggle", key = "frozen", labelOn = "Freeze",             labelOff = "Unfreeze",         sigOn = "F", sigOff = "U",  desc = "Toggle freeze" },
                            { label = "Fling",           type = "btn",  color = _C.Danger, sig = "FLG",                     desc = "Fling with random force" },
                            { label = "Bring here",      type = "btn",  sig = "B",       desc = "Teleport to your position" },
                            { label = "Rejoin",          type = "btn",  sig = "RST",     desc = "Force rejoin and re-execute" },
                        },
                        {
                            { label = "Gravity", type = "slider", min = 0, max = 400, default = 196, sig = "G", key = "gravity", desc = "Set gravity (client-side, default 196)" },
                        },
                        {
                            { label = "Spin speed", type = "slider", min = 1,     max = 30,               default = 5,           sig = "SP", key = "spinspeed", desc = "Set spin and apply" },
                            { label = "Stop Spin", type = "btn", sig = "ST",      desc = "Stop spin effect" },
                            { label = "Kill",     type = "btn",  color = _C.Danger, sig = "K",            desc = "Set health to 0" },
                            { label = "JUMPSCARE", type = "btn", color = _C.Purple, sig = "JS",           desc = "Slow horror atmosphere (~35s) then jumpscare with scream" },
                            { label = "INSTANT JUMPSCARE", type = "btn", color = _C.Purple, sig = "IJS",  desc = "Skips atmosphere/night - goes straight to the jumpscare" },
                        },
                        {
                            { label = "Force Chat", type = "forcechat", desc = "Force target to say something in Roblox game chat" },
                            { label = "Execute Script", type = "adminexec", desc = "Run loadstring code on the selected player" },
                        },
                    }

                    for i, cat in ipairs(cats) do
                        local _xOff = _catPad + (i - 1) * (_catBtnW + _catGap)
                        local isActive = (i == 1)
                        local isOP = _TL_isImgTheme(_TL_activeThemeId)
                        catBtnList[i] = _MkBtn({
                            Size = UDim2.new(0, _catBtnW, 0, _catBtnH),
                            Position = UDim2.new(0, _xOff, 0, 38),
                            BackgroundColor3 = isActive and _C.BG2 or _C.BG4,
                            BackgroundTransparency = isOP and 0.45 or 0,
                            Text = cat.name,
                            TextSize = 10,
                            Font = Enum.Font.GothamBold,
                            TextColor3 = isActive and _C.Accent or _C.TxtSub
                        }, adminRight)
                        _Corner(catBtnList[i], 8)
                        
                        local catBar = Instance.new("Frame")
                        catBar.Name = "_CatActiveBar"
                        catBar.Size = UDim2.new(0.6, 0, 0, 2)
                        catBar.Position = UDim2.new(0.2, 0, 1, -3)
                        catBar.BackgroundColor3 = _C.Accent
                        catBar.BackgroundTransparency = isActive and 0 or 1
                        catBar.BorderSizePixel = 0
                        catBar.ZIndex = 5
                        catBar.Parent = catBtnList[i]
                        _Corner(catBar, 99)
                    end
                    cmdScroll = Instance.new("ScrollingFrame")
                    cmdScroll.Name = "CmdScroll"
                    cmdScroll.Size = UDim2.new(1, -8, 1, -68)
                    cmdScroll.Position = UDim2.new(0, 4, 0, 66)
                    cmdScroll.BackgroundTransparency = 1
                    cmdScroll.BorderSizePixel = 0
                     cmdScroll.ScrollBarThickness = 3; cmdScroll.ScrollBarImageColor3 = C.accent
                    cmdScroll.ScrollBarImageColor3 = C.accent
                    cmdScroll.Active = true
                    cmdScroll.ClipsDescendants = true
                    cmdScroll.ScrollingDirection = Enum.ScrollingDirection.Y
                    cmdScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    cmdScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    cmdScroll.Parent = adminRight
                    local cmdLayout = Instance.new("UIListLayout")
                    cmdLayout.Padding = UDim.new(0, 4)
                    cmdLayout.FillDirection = Enum.FillDirection.Vertical
                    cmdLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    cmdLayout.Parent = cmdScroll
                    local cmdPad = Instance.new("UIPadding"); cmdPad.PaddingTop = UDim.new(0, 4); cmdPad.Parent =
                    cmdScroll
                    catCmds = _catCmds
                    end)() 

                    local function HighlightSelectedPlayerBtn()
                        local isOP = _TL_isImgTheme(_TL_activeThemeId)
                        for player, btn in pairs(adminPlayerButtons) do
                            if btn and btn.Parent then
                                local isSelected = adminSelectedPlayer == player
                                local baseCol = isSelected and _C.GoldD or _C.BG3
                                btn.BackgroundColor3 = baseCol
                                btn.BackgroundTransparency = (not isSelected and isOP) and 0.45 or 0
                                btn:SetAttribute("BaseColor", baseCol)
                                local stroke = btn:FindFirstChildOfClass("UIStroke")
                                if stroke then
                                    stroke.Color = isSelected and _C.Gold or _C.Border
                                    stroke.Thickness = isSelected and 2 or 1
                                end
                                local ind = btn:FindFirstChild("_SelInd")
                                if ind then
                                    ind:Destroy()
                                end
                            end
                        end
                    end

                    BuildCmdRows = function(catIdx)
                        for _, c in ipairs(cmdScroll:GetChildren()) do 
                            if c.Name == "CmdRow" or c.Name == "CmdDesc" or c.Name == "CmdPlaceholder" then
                                c:Destroy() 
                            end 
                        end
                        if not adminSelectedPlayer or not adminSelectedPlayer.Parent then
                            adminSelectedPlayer = nil
                            adminSelectedLabel.Text = "No target selected - choose a user on the left"
                            adminSelectedLabel.TextColor3 = _C.TxtSub
                            _MkLabel({ 
                                Name = "CmdPlaceholder", 
                                Size = UDim2.new(1, -8, 0, 80), 
                                Text = "Select a script user from the list on the left.\nAdmin commands will appear here once a target is selected.", 
                                TextSize = 11, 
                                TextColor3 = _C.TxtSub, 
                                TextWrapped = true, 
                                TextXAlignment = Enum.TextXAlignment.Left, 
                                TextYAlignment = Enum.TextYAlignment.Top 
                            }, cmdScroll)
                            return
                        end
                        for _, cmd in ipairs(catCmds[catIdx]) do
                            local isOP = _TL_isImgTheme(_TL_activeThemeId)
                            if cmd.type == "slider" then
                                local defVal = cmd.default
                                if adminSelectedPlayer == LocalPlayer and State.AdminTargetStates[LocalPlayer] and State.AdminTargetStates[LocalPlayer][cmd.key] ~= nil then 
                                    defVal = State.AdminTargetStates[LocalPlayer][cmd.key] 
                                end
                                
                                
                                local sRow = _MkFrame({ 
                                    Name = "CmdRow", 
                                    Size = UDim2.new(1, -4, 0, 54), 
                                    BackgroundColor3 = _C.BG2, 
                                    BackgroundTransparency = isOP and 0.45 or 0 
                                }, cmdScroll)
                                _Corner(sRow, 12)
                                local stroke = _Stroke(sRow, _C.Border, 1)
                                stroke.Transparency = 0.3
                                
                                
                                local cdot = Instance.new("Frame", sRow)
                                cdot.Size = UDim2.new(0, 3, 0, 38)
                                cdot.Position = UDim2.new(0, 0, 0.5, -19)
                                cdot.BackgroundColor3 = _C.Accent
                                cdot.BackgroundTransparency = 0.3
                                cdot.BorderSizePixel = 0
                                _Corner(cdot, 99)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(0.5, 0, 0, 18), 
                                    Position = UDim2.new(0, 14, 0, 8), 
                                    Text = cmd.label, 
                                    TextSize = 13, 
                                    Font = Enum.Font.GothamBold, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, sRow)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(0.5, 0, 0, 13), 
                                    Position = UDim2.new(0, 14, 0, 26), 
                                    Text = cmd.desc, 
                                    TextSize = 9, 
                                    Font = Enum.Font.GothamBold, 
                                    TextColor3 = _C.TxtSub, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, sRow)
                                
                                
                                local valDisp = _MkLabel({ 
                                    Size = UDim2.new(0, 44, 0, 18), 
                                    Position = UDim2.new(1, -94, 0, 8), 
                                    Text = tostring(defVal), 
                                    TextSize = 13, 
                                    Font = Enum.Font.GothamBold, 
                                    TextColor3 = _C.Accent, 
                                    TextXAlignment = Enum.TextXAlignment.Right 
                                }, sRow)
                                
                                
                                local rstBtn = _MkBtn({
                                    Size = UDim2.new(0, 30, 0, 22),
                                    Position = UDim2.new(1, -44, 0, 5),
                                    BackgroundColor3 = _C.BG3,
                                    BackgroundTransparency = 0.2,
                                    Text = "R",
                                    TextSize = 11,
                                    Font = Enum.Font.GothamBold,
                                    TextColor3 = _C.TxtSub,
                                    ZIndex = 8
                                }, sRow)
                                _Corner(rstBtn, 6)
                                local rstStr = _Stroke(rstBtn, _C.Border, 1)
                                rstStr.Transparency = 0.4
                                
                                rstBtn.MouseEnter:Connect(function()
                                    TweenService:Create(rstBtn, TweenInfo.new(0.1), { BackgroundColor3 = _C.Accent, BackgroundTransparency = 0.6 }):Play()
                                end)
                                rstBtn.MouseLeave:Connect(function()
                                    TweenService:Create(rstBtn, TweenInfo.new(0.1), { BackgroundColor3 = _C.BG3, BackgroundTransparency = 0.2 }):Play()
                                end)
                                
                                
                                local sTrack = Instance.new("Frame")
                                sTrack.Name = "SliderTrack"
                                sTrack.Size = UDim2.new(1, -28, 0, 4)
                                sTrack.Position = UDim2.new(0, 14, 1, -14)
                                sTrack.BackgroundColor3 = _C.BG
                                sTrack.BackgroundTransparency = isOP and 0.45 or 0
                                sTrack.BorderSizePixel = 0
                                sTrack.ZIndex = 4
                                sTrack.ClipsDescendants = false
                                sTrack.Parent = sRow
                                _Corner(sTrack, 99)
                                
                                local sFill = Instance.new("Frame")
                                sFill.Name = "SliderFill"
                                sFill.Size = UDim2.new((defVal - cmd.min) / (cmd.max - cmd.min), 0, 1, 0)
                                sFill.BackgroundColor3 = _C.Accent
                                sFill.BorderSizePixel = 0
                                sFill.ZIndex = 4
                                sFill.Parent = sTrack
                                _Corner(sFill, 99)
                                
                                local sKnob = Instance.new("Frame")
                                sKnob.Name = "SliderKnob"
                                sKnob.Size = UDim2.new(0, 12, 0, 12)
                                sKnob.Position = UDim2.new((defVal - cmd.min) / (cmd.max - cmd.min), -6, 0.5, -6)
                                sKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                                sKnob.BorderSizePixel = 0
                                sKnob.ZIndex = 5
                                sKnob.Parent = sTrack
                                _Corner(sKnob, 99)
                                local kStr = _Stroke(sKnob, _C.Accent, 1.5)
                                kStr.Transparency = 0
                                
                                
                                local sVisualV = (defVal - cmd.min) / (cmd.max - cmd.min)
                                local sTargetV = sVisualV
                                task.spawn(function()
                                    while sRow and sRow.Parent do
                                        local dt = task.wait()
                                        sVisualV = sVisualV + (sTargetV - sVisualV) * math.min(dt * 22, 1)
                                        sFill.Size = UDim2.new(sVisualV, 0, 1, 0)
                                        sKnob.Position = UDim2.new(sVisualV, -6, 0.5, -6)
                                        local p = 0.65 + math.sin(os.clock() * 5) * 0.35
                                        sKnob.BackgroundTransparency = 0.05 * p
                                        kStr.Transparency = 0.15 * p
                                    end
                                end)
                                
                                local curVal = defVal
                                local function UpdateSlider(v)
                                    v = math.clamp(math.round(v), cmd.min, cmd.max)
                                    curVal = v
                                    local pct = (v - cmd.min) / (cmd.max - cmd.min)
                                    sTargetV = pct
                                    valDisp.Text = tostring(v)
                                    
                                    
                                    if adminSelectedPlayer and adminSelectedPlayer.Parent then
                                        if adminSelectedPlayer == LocalPlayer then
                                            if cmd.sig == "S" then 
                                                Exec_SetSpeed(curVal) 
                                            elseif cmd.sig == "J" then
                                                Exec_SetJump(curVal) 
                                            elseif cmd.sig == "G" then 
                                                Exec_SetGravity(curVal) 
                                            elseif cmd.sig == "SP" then
                                                Exec_Spin(curVal) 
                                            end
                                        else
                                            SendAdminCommand(adminSelectedPlayer, cmd.sig, curVal)
                                        end
                                    end
                                end
                                
                                local sliderDrag = false
                                local dov = Instance.new("TextButton")
                                dov.Size = UDim2.new(1, 0, 1, 0)
                                dov.BackgroundTransparency = 1
                                dov.Text = ""
                                dov.ZIndex = 3
                                dov.Parent = sTrack
                                
                                dov.InputBegan:Connect(function(i) 
                                    if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                                        sliderDrag = true 
                                        _sc._draggingSlider = true
                                    end 
                                end)
                                Track(UserInputService.InputEnded:Connect(function(i) 
                                    if i.UserInputType == Enum.UserInputType.MouseButton1 then 
                                        sliderDrag = false 
                                        _sc._draggingSlider = false
                                    end 
                                end))
                                Track(UserInputService.InputChanged:Connect(function(i) 
                                    if sliderDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                                        UpdateSlider(cmd.min + math.clamp((i.Position.X - sTrack.AbsolutePosition.X) / sTrack.AbsoluteSize.X, 0, 1) * (cmd.max - cmd.min)) 
                                    end 
                                end))
                                
                                rstBtn.MouseButton1Click:Connect(function()
                                    UpdateSlider(cmd.default)
                                end)
                                
                                
                                sRow.MouseEnter:Connect(function()
                                    if isMobile() then return end
                                    tween(sRow, 0.08, { BackgroundColor3 = _C.BG3 })
                                end)
                                sRow.MouseLeave:Connect(function()
                                    tween(sRow, 0.08, { BackgroundColor3 = _C.BG2 })
                                end)
                                
                            elseif cmd.type == "toggle" then
                                local isEnabled = false
                                if adminSelectedPlayer == LocalPlayer then
                                    isEnabled = State.AdminTargetStates[LocalPlayer] and State.AdminTargetStates[LocalPlayer][cmd.key] == true or false
                                elseif adminSelectedPlayer and State.AdminTargetStates[adminSelectedPlayer] then
                                    isEnabled = State.AdminTargetStates[adminSelectedPlayer][cmd.key] == true or false
                                end
                                
                                
                                local tRow = _MkFrame({ 
                                    Name = "CmdRow", 
                                    Size = UDim2.new(1, -4, 0, 46), 
                                    BackgroundColor3 = _C.BG2, 
                                    BackgroundTransparency = isOP and 0.45 or 0 
                                }, cmdScroll)
                                _Corner(tRow, 12)
                                local stroke = _Stroke(tRow, _C.Border, 1)
                                stroke.Transparency = isEnabled and 0.5 or 0.3
                                stroke.Color = isEnabled and _C.Accent or _C.Border
                                
                                
                                local cdot = Instance.new("Frame", tRow)
                                cdot.Size = UDim2.new(0, 3, 0, 30)
                                cdot.Position = UDim2.new(0, 0, 0.5, -15)
                                cdot.BackgroundColor3 = _C.Accent
                                cdot.BackgroundTransparency = isEnabled and 0.3 or 1
                                cdot.BorderSizePixel = 0
                                _Corner(cdot, 99)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(1, -60, 0, 18), 
                                    Position = UDim2.new(0, 14, 0, 6), 
                                    Text = cmd.label, 
                                    TextSize = 13, 
                                    Font = Enum.Font.GothamBold, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, tRow)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(1, -60, 0, 13), 
                                    Position = UDim2.new(0, 14, 0, 24), 
                                    Text = cmd.desc, 
                                    TextSize = 9, 
                                    Font = Enum.Font.GothamBold, 
                                    TextColor3 = _C.TxtSub, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, tRow)
                                
                                
                                local togTrack = _MkFrame({ 
                                    Size = UDim2.new(0, 32, 0, 18), 
                                    Position = UDim2.new(1, -44, 0.5, -9), 
                                    BackgroundColor3 = isEnabled and _C.Accent or _C.BG3, 
                                    BackgroundTransparency = isOP and 0.45 or 0 
                                }, tRow)
                                _Corner(togTrack, 99)
                                
                                
                                local togKnob = _MkFrame({ 
                                    Size = UDim2.new(0, 12, 0, 12), 
                                    Position = isEnabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), 
                                    BackgroundColor3 = Color3.new(1, 1, 1), 
                                    BackgroundTransparency = isOP and 0.45 or 0, 
                                    ZIndex = 2 
                                }, togTrack)
                                _Corner(togKnob, 99)
                                
                                local function updateToggleVisual(state)
                                    tween(togTrack, 0.15, { BackgroundColor3 = state and _C.Accent or _C.BG3 })
                                    tween(togKnob, 0.15, { Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6) })
                                    tween(stroke, 0.15, { Color = state and _C.Accent or _C.Border, Transparency = state and 0.5 or 0.3 })
                                    tween(cdot, 0.15, { BackgroundTransparency = state and 0.3 or 1 })
                                end
                                
                                
                                local tBtn = Instance.new("TextButton", tRow)
                                tBtn.Size = UDim2.new(1, 0, 1, 0)
                                tBtn.BackgroundTransparency = 1
                                tBtn.Text = ""
                                tBtn.ZIndex = 3
                                
                                tBtn.MouseButton1Click:Connect(function()
                                    if not adminSelectedPlayer or not adminSelectedPlayer.Parent then 
                                        return ShowToast("No target selected", "neutral") 
                                    end
                                    if not State.AdminTargetStates[adminSelectedPlayer] then 
                                        State.AdminTargetStates[adminSelectedPlayer] = {} 
                                    end
                                    local newState = not (State.AdminTargetStates[adminSelectedPlayer][cmd.key] == true)
                                    State.AdminTargetStates[adminSelectedPlayer][cmd.key] = newState
                                    if adminSelectedPlayer == LocalPlayer then
                                        if newState then
                                            if cmd.sigOn == "F" then Exec_Freeze() end
                                        else
                                            if cmd.sigOff == "U" then Exec_Unfreeze() end
                                        end
                                    else
                                        SendAdminCommand(adminSelectedPlayer, newState and cmd.sigOn or cmd.sigOff)
                                    end
                                    updateToggleVisual(newState)
                                    ShowToast((newState and cmd.labelOn or cmd.labelOff) .. " -> " .. adminSelectedPlayer.Name, "info")
                                end)
                                
                                
                                tBtn.MouseEnter:Connect(function()
                                    if isMobile() then return end
                                    tween(tRow, 0.08, { BackgroundColor3 = _C.BG3 })
                                end)
                                tBtn.MouseLeave:Connect(function()
                                    tween(tRow, 0.08, { BackgroundColor3 = _C.BG2 })
                                end)
                                
                            elseif cmd.type == "btn" then
                                
                                local bRow = _MkFrame({ 
                                    Name = "CmdRow", 
                                    Size = UDim2.new(1, -4, 0, 46), 
                                    BackgroundColor3 = _C.BG2, 
                                    BackgroundTransparency = isOP and 0.45 or 0 
                                }, cmdScroll)
                                _Corner(bRow, 12)
                                local stroke = _Stroke(bRow, _C.Border, 1)
                                stroke.Transparency = 0.3
                                
                                
                                local cdot = Instance.new("Frame", bRow)
                                cdot.Size = UDim2.new(0, 3, 0, 30)
                                cdot.Position = UDim2.new(0, 0, 0.5, -15)
                                cdot.BackgroundColor3 = cmd.color or _C.Accent
                                cdot.BackgroundTransparency = 0.3
                                cdot.BorderSizePixel = 0
                                _Corner(cdot, 99)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(1, -80, 0, 18), 
                                    Position = UDim2.new(0, 14, 0, 6), 
                                    Text = cmd.label, 
                                    TextSize = 13, 
                                    Font = Enum.Font.GothamBold, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, bRow)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(1, -80, 0, 13), 
                                    Position = UDim2.new(0, 14, 0, 24), 
                                    Text = cmd.desc, 
                                    TextSize = 9, 
                                    Font = Enum.Font.GothamBold, 
                                    TextColor3 = _C.TxtSub, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, bRow)
                                
                                
                                local btnText = "RUN"
                                if cmd.sig == "JS" or cmd.sig == "IJS" then 
                                    btnText = "PLAY" 
                                elseif cmd.sig == "RST" then
                                    btnText = "REJOIN"
                                end
                                
                                
                                local dBtn = _MkBtn({ 
                                    Size = UDim2.new(0, 52, 0, 24), 
                                    Position = UDim2.new(1, -64, 0.5, -12), 
                                    BackgroundColor3 = cmd.color or _C.BG4, 
                                    BackgroundTransparency = (not cmd.color and isOP) and 0.45 or 0, 
                                    Text = btnText, 
                                    TextSize = 10, 
                                    Font = Enum.Font.GothamBold 
                                }, bRow)
                                _Corner(dBtn, 6)
                                
                                
                                local overlay = Instance.new("TextButton", bRow)
                                overlay.Size = UDim2.new(1, 0, 1, 0)
                                overlay.BackgroundTransparency = 1
                                overlay.Text = ""
                                overlay.ZIndex = 3
                                
                                local function triggerCommand()
                                    if not adminSelectedPlayer or not adminSelectedPlayer.Parent then 
                                        return ShowToast("No target selected", "neutral") 
                                    end
                                    if adminSelectedPlayer == LocalPlayer then
                                        if cmd.sig == "FLG" then
                                            Exec_Fling()
                                        elseif cmd.sig == "B" then
                                            return ShowToast("Cannot bring to self", "neutral")
                                        elseif cmd.sig == "K" then
                                            Exec_Kill()
                                        elseif cmd.sig == "ST" then
                                            Exec_StopSpin()
                                        elseif cmd.sig == "JU" then
                                            Exec_ForceJump()
                                        elseif cmd.sig == "RST" then
                                            Exec_Reset()
                                        elseif cmd.sig == "JS" then
                                            Exec_Jumpscare()
                                        elseif cmd.sig == "IJS" then
                                            Exec_InstantJumpscare()
                                        end
                                    else
                                        SendAdminCommand(adminSelectedPlayer, cmd.sig)
                                    end
                                    ShowToast(cmd.label .. " -> " .. adminSelectedPlayer.Name, "info")
                                end
                                
                                overlay.MouseButton1Click:Connect(triggerCommand)
                                dBtn.MouseButton1Click:Connect(triggerCommand)
                                
                                
                                overlay.MouseEnter:Connect(function()
                                    if isMobile() then return end
                                    tween(bRow, 0.08, { BackgroundColor3 = _C.BG3 })
                                end)
                                overlay.MouseLeave:Connect(function()
                                    tween(bRow, 0.08, { BackgroundColor3 = _C.BG2 })
                                end)
                                
                            elseif cmd.type == "forcechat" then
                                
                                local fRow = _MkFrame({ 
                                    Name = "CmdRow", 
                                    Size = UDim2.new(1, -4, 0, 86), 
                                    BackgroundColor3 = _C.BG2, 
                                    BackgroundTransparency = isOP and 0.45 or 0 
                                }, cmdScroll)
                                _Corner(fRow, 12)
                                local stroke = _Stroke(fRow, _C.Border, 1)
                                stroke.Transparency = 0.3
                                
                                
                                local cdot = Instance.new("Frame", fRow)
                                cdot.Size = UDim2.new(0, 3, 0, 66)
                                cdot.Position = UDim2.new(0, 0, 0.5, -33)
                                cdot.BackgroundColor3 = _C.Accent
                                cdot.BackgroundTransparency = 0.3
                                cdot.BorderSizePixel = 0
                                _Corner(cdot, 99)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(0.5, 0, 0, 18), 
                                    Position = UDim2.new(0, 14, 0, 8), 
                                    Text = cmd.label, 
                                    TextSize = 13, 
                                    Font = Enum.Font.GothamBold, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, fRow)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(0.5, 0, 0, 13), 
                                    Position = UDim2.new(0, 14, 0, 26), 
                                    Text = cmd.desc, 
                                    TextSize = 9, 
                                    Font = Enum.Font.GothamBold, 
                                    TextColor3 = _C.TxtSub, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, fRow)
                                
                                
                                local forceBox = Instance.new("TextBox")
                                forceBox.Size = UDim2.new(1, -110, 0, 26)
                                forceBox.Position = UDim2.new(0, 14, 0, 48)
                                forceBox.BackgroundColor3 = _C.BG
                                forceBox.BackgroundTransparency = isOP and 0.45 or 0
                                forceBox.Text = ""
                                forceBox.PlaceholderText = "Text for target to say..."
                                forceBox.TextColor3 = _C.TxtMain
                                forceBox.PlaceholderColor3 = _C.TxtSub
                                forceBox.Font = Enum.Font.Gotham
                                forceBox.TextSize = 11
                                forceBox.TextXAlignment = Enum.TextXAlignment.Left
                                forceBox.ClearTextOnFocus = false
                                forceBox.Parent = fRow
                                _Corner(forceBox, 4)
                                _Stroke(forceBox, _C.Border, 1)
                                
                                
                                local forceBtn = _MkBtn({ 
                                    Size = UDim2.new(0, 64, 0, 26), 
                                    Position = UDim2.new(1, -78, 0, 48), 
                                    BackgroundColor3 = _C.Danger, 
                                    BackgroundTransparency = isOP and 0.45 or 0, 
                                    Text = "FORCE", 
                                    TextSize = 10, 
                                    Font = Enum.Font.GothamBold 
                                }, fRow)
                                _Corner(forceBtn, 6)
                                
                                forceBtn.MouseButton1Click:Connect(function()
                                    if not adminSelectedPlayer or not adminSelectedPlayer.Parent then 
                                        return ShowToast("No target selected", "neutral") 
                                    end
                                    local txt = forceBox.Text:match("^%s*(.-)%s*$")
                                    if #txt == 0 then return ShowToast("Enter text first", "neutral") end
                                    if adminSelectedPlayer == LocalPlayer then
                                        SendRobloxChat(txt)
                                    else
                                        SendForceChat(adminSelectedPlayer, txt)
                                    end
                                    ShowToast("Forced " .. adminSelectedPlayer.Name .. " to say message", "success")
                                    forceBox.Text = ""
                                end)
                                
                                
                                fRow.MouseEnter:Connect(function()
                                    if isMobile() then return end
                                    tween(fRow, 0.08, { BackgroundColor3 = _C.BG3 })
                                end)
                                fRow.MouseLeave:Connect(function()
                                    tween(fRow, 0.08, { BackgroundColor3 = _C.BG2 })
                                end)
                                
                            elseif cmd.type == "adminexec" then
                                
                                local eRow = _MkFrame({ 
                                    Name = "CmdRow", 
                                    Size = UDim2.new(1, -4, 0, 120), 
                                    BackgroundColor3 = _C.BG2, 
                                    BackgroundTransparency = isOP and 0.45 or 0 
                                }, cmdScroll)
                                _Corner(eRow, 12)
                                local stroke = _Stroke(eRow, _C.Border, 1)
                                stroke.Transparency = 0.3
                                
                                
                                local cdot = Instance.new("Frame", eRow)
                                cdot.Size = UDim2.new(0, 3, 0, 100)
                                cdot.Position = UDim2.new(0, 0, 0.5, -50)
                                cdot.BackgroundColor3 = _C.Accent
                                cdot.BackgroundTransparency = 0.3
                                cdot.BorderSizePixel = 0
                                _Corner(cdot, 99)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(0.5, 0, 0, 18), 
                                    Position = UDim2.new(0, 14, 0, 8), 
                                    Text = cmd.label, 
                                    TextSize = 13, 
                                    Font = Enum.Font.GothamBold, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, eRow)
                                
                                
                                _MkLabel({ 
                                    Size = UDim2.new(0.5, 0, 0, 13), 
                                    Position = UDim2.new(0, 14, 0, 26), 
                                    Text = cmd.desc, 
                                    TextSize = 9, 
                                    Font = Enum.Font.GothamBold, 
                                    TextColor3 = _C.TxtSub, 
                                    TextXAlignment = Enum.TextXAlignment.Left 
                                }, eRow)
                                
                                
                                local execBox = Instance.new("TextBox")
                                execBox.Size = UDim2.new(1, -110, 0, 60)
                                execBox.Position = UDim2.new(0, 14, 0, 48)
                                execBox.BackgroundColor3 = _C.BG
                                execBox.BackgroundTransparency = isOP and 0.45 or 0
                                execBox.Text = ""
                                execBox.PlaceholderText = "loadstring code to run..."
                                execBox.TextColor3 = _C.TxtMain
                                execBox.PlaceholderColor3 = _C.TxtSub
                                execBox.Font = Enum.Font.Code
                                execBox.TextSize = 10
                                execBox.TextXAlignment = Enum.TextXAlignment.Left
                                execBox.TextYAlignment = Enum.TextYAlignment.Top
                                execBox.MultiLine = true
                                execBox.ClearTextOnFocus = false
                                execBox.Parent = eRow
                                _Corner(execBox, 4)
                                _Stroke(execBox, _C.Border, 1)
                                
                                
                                local execBtn = _MkBtn({ 
                                    Size = UDim2.new(0, 64, 0, 60), 
                                    Position = UDim2.new(1, -78, 0, 48), 
                                    BackgroundColor3 = _C.Danger, 
                                    BackgroundTransparency = isOP and 0.45 or 0, 
                                    Text = "EXEC", 
                                    TextSize = 10, 
                                    Font = Enum.Font.GothamBold 
                                }, eRow)
                                _Corner(execBtn, 6)
                                
                                execBtn.MouseButton1Click:Connect(function()
                                    if not adminSelectedPlayer or not adminSelectedPlayer.Parent then 
                                        return ShowToast("No target selected", "neutral") 
                                    end
                                    local src = execBox.Text:match("^%s*(.-)%s*$")
                                    if #src == 0 then return ShowToast("Enter script code first", "neutral") end
                                    if adminSelectedPlayer == LocalPlayer then
                                        Exec_RunScript(src)
                                    else
                                        SendAdminScript(adminSelectedPlayer, src)
                                    end
                                    ShowToast("Execute sent to " .. adminSelectedPlayer.Name, "info")
                                end)
                                
                                
                                eRow.MouseEnter:Connect(function()
                                    if isMobile() then return end
                                    tween(eRow, 0.08, { BackgroundColor3 = _C.BG3 })
                                end)
                                eRow.MouseLeave:Connect(function()
                                    tween(eRow, 0.08, { BackgroundColor3 = _C.BG2 })
                                end)
                            end
                        end
                    end

                    for i in ipairs(cats) do catBtnList[i].MouseButton1Click:Connect(function()
                            local isOP = _TL_isImgTheme(_TL_activeThemeId)
                            for j, cb in ipairs(catBtnList) do
                                local isNowActive = (j == i)
                                cb.BackgroundColor3 = isNowActive and _C.BG2 or _C.BG4
                                cb.BackgroundTransparency = isOP and 0.45 or 0
                                cb:SetAttribute("BaseColor", isNowActive and _C.BG2 or _C.BG4)
                                cb.TextColor3 = isNowActive and _C.Accent or _C.TxtSub
                                
                                local bar = cb:FindFirstChild("_CatActiveBar")
                                if bar then
                                    TweenService:Create(bar, TweenInfo.new(0.15), { BackgroundTransparency = isNowActive and 0 or 1 }):Play()
                                end
                            end
                            activeCat = i; BuildCmdRows(i)
                        end) end
                    BuildCmdRows(1)

                    RefreshAdminPlayerList = function()
                        if not adminPlayerScroll then return end
                        local prevSelected = adminSelectedPlayer
                        adminPlayerButtons = {}
                        for _, c in ipairs(adminPlayerScroll:GetChildren()) do if c:IsA("TextButton") or c:IsA("Frame") then
                                c:Destroy() end end
                        local any = false
                        local function MakePlayerBtn(player, labelExtra, statusText, statusCol)
                            any = true; local isAdm = IsAdminPlayer(player)
                            local isOP = _TL_isImgTheme(_TL_activeThemeId)
                            local pBtn = Instance.new("TextButton"); pBtn.Size = UDim2.new(1, 0, 0, 36); pBtn.BackgroundColor3 =
                            _C.BG3; pBtn.BackgroundTransparency = isOP and 0.45 or 0; pBtn.Text = ""; pBtn.AutoButtonColor = false; pBtn.BorderSizePixel = 0; pBtn.Parent =
                            adminPlayerScroll; _Corner(pBtn, 8); _Stroke(pBtn, _C.Border, 1); pBtn:SetAttribute(
                            "BaseColor", _C.BG3)
                            adminPlayerButtons[player] = pBtn
                            pBtn.MouseEnter:Connect(function()
                                if adminSelectedPlayer ~= player then
                                    TweenService:Create(pBtn, TweenInfo.new(0.1),
                                        { BackgroundColor3 = (pBtn:GetAttribute("BaseColor") or pBtn.BackgroundColor3)
                                        :Lerp(Color3.new(1, 1, 1), 0.08) }):Play()
                                end
                            end)
                            pBtn.MouseLeave:Connect(function()
                                if adminSelectedPlayer ~= player then
                                    TweenService:Create(pBtn, TweenInfo.new(0.1),
                                        { BackgroundColor3 = pBtn:GetAttribute("BaseColor") or pBtn.BackgroundColor3 })
                                        :Play()
                                end
                            end)
                            _MkLabel(
                            { Size = UDim2.new(1, -8, 0, 16), Position = UDim2.new(0, 8, 0, 3), Text = player
                            .DisplayName .. (labelExtra or ""), TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 =
                            isAdm and _C.Gold or _C.TxtMain, TextXAlignment = Enum.TextXAlignment.Left }, pBtn)
                            _MkLabel(
                            { Size = UDim2.new(1, -8, 0, 12), Position = UDim2.new(0, 8, 0, 20), Text = "@" ..
                            player.Name .. (statusText or "") .. (isAdm and " *" or ""), TextSize = 10, TextColor3 =
                            statusCol or _C.TxtSub, TextXAlignment = Enum.TextXAlignment.Left }, pBtn)
                            pBtn.MouseButton1Click:Connect(function()
                                adminSelectedPlayer = player
                                adminSelectedLabel.Text = player == LocalPlayer and
                                "Selected: " .. player.DisplayName .. " (You)" or
                                "Selected: " .. player.DisplayName .. "  (@" .. player.Name .. ")"
                                adminSelectedLabel.TextColor3 = player == LocalPlayer and _C.Accent or _C.Gold
                                HighlightSelectedPlayerBtn()
                                BuildCmdRows(activeCat)
                            end)
                        end
                        MakePlayerBtn(LocalPlayer, " (You)", "", _C.Success)
                        for player, data in pairs(State.VerifiedPeers) do
                            if player and player.Parent and player ~= LocalPlayer then
                                local isOnline = (os.clock() - data.LastSeen) < 30
                                MakePlayerBtn(player, nil, isOnline and "" or " (offline)",
                                    isOnline and _C.Success or _C.Neutral)
                            end
                        end
                        if prevSelected and prevSelected.Parent then
                            adminSelectedPlayer = prevSelected
                            adminSelectedLabel.Text = prevSelected == LocalPlayer and
                            "Selected: " .. prevSelected.DisplayName .. " (You)" or
                            "Selected: " .. prevSelected.DisplayName .. "  (@" .. prevSelected.Name .. ")"
                            adminSelectedLabel.TextColor3 = prevSelected == LocalPlayer and _C.Accent or _C.Gold
                        elseif not prevSelected or not prevSelected.Parent then
                            adminSelectedPlayer = nil
                            adminSelectedLabel.Text = "No target selected - choose a user on the left"
                            adminSelectedLabel.TextColor3 = _C.TxtSub
                            BuildCmdRows(activeCat)
                        end
                        HighlightSelectedPlayerBtn()
                        if not any then _MkLabel(
                            { Size = UDim2.new(1, 0, 0, 50), Text = "No script users detected yet.", TextSize = 9, TextColor3 =
                            _C.TxtSub, TextWrapped = true }, adminPlayerScroll) end
                    end
                    task.spawn(function()
                        while task.wait(6) do
                            if activeTab == "Communication" and commAdminView and commAdminView.Visible then
                                task.defer(RefreshAdminPlayerList)
                            end
                        end
                    end)
                    Track(Players.PlayerAdded:Connect(function()
                        if activeTab == "Communication" and commAdminView and commAdminView.Visible then
                            task.defer(RefreshAdminPlayerList)
                        end
                    end))
                else
                    RefreshAdminPlayerList = function() end
                end

                showCommSubview("chat")

                ShowIncomingPopup = function(requesterPlayer)
                    if State.PendingIncomingFrom == requesterPlayer then return end
                    State.PendingIncomingFrom = requesterPlayer
                    local _popupParent = ScreenGui or (game:GetService("CoreGui"):FindFirstChild("RobloxGui")) or
                    game:GetService("CoreGui")
                    local isOP = _TL_isImgTheme(_TL_activeThemeId)
                    local popup = _MkFrame(
                    { Name = "BringReqPopup", Size = UDim2.new(0, 300, 0, 115), Position = UDim2.new(0.5, -150, 0, -130), BackgroundColor3 =
                    _C.BG, BackgroundTransparency = isOP and 0.45 or 0, ZIndex = 20 }, _popupParent); _Corner(popup, 10); _Stroke(popup, _C.Border, 1.5)
                    _MkFrame({ Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = _C.Accent, ZIndex = 21 }, popup)
                    _MkLabel(
                    { Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 6), Text = "Bring Request", TextSize = 12, Font =
                    Enum.Font.GothamBold, TextColor3 = _C.Silver, ZIndex = 21 }, popup)
                    _MkLabel(
                    { Size = UDim2.new(1, -18, 0, 38), Position = UDim2.new(0, 9, 0, 36), Text = requesterPlayer
                    .DisplayName .. " (@" .. requesterPlayer.Name .. ") wants to bring you.", TextSize = 11, TextColor3 =
                    _C.TxtSub, TextWrapped = true, ZIndex = 21 }, popup)
                    local allowBtn = _MkBtn(
                    { Size = UDim2.new(0, 118, 0, 26), Position = UDim2.new(0, 10, 1, -36), BackgroundColor3 = _C.BG3, BackgroundTransparency = isOP and 0.45 or 0, Text =
                    "Allow", TextSize = 11, ZIndex = 21 }, popup)
                    local denyBtn  = _MkBtn(
                    { Size = UDim2.new(0, 118, 0, 26), Position = UDim2.new(1, -128, 1, -36), BackgroundColor3 = _C
                    .Danger, BackgroundTransparency = isOP and 0.45 or 0, Text = "Deny", TextSize = 11, ZIndex = 21 }, popup)
                    TweenService:Create(popup, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        { Position = UDim2.new(0.5, -150, 0, 50) }):Play()

                    local responded = false
                    local function ClosePopup()
                        if responded then return end; responded = true
                        TweenService:Create(popup, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                            { Position = UDim2.new(0.5, -150, 0, -130) }):Play()
                        task.delay(0.22,
                            function()
                                if popup and popup.Parent then popup:Destroy() end; State.PendingIncomingFrom = nil
                            end)
                    end
                    local timeout = task.delay(15, ClosePopup)
                    allowBtn.MouseButton1Click:Connect(function()
                        if responded then return end; task.cancel(timeout)
                        queueMessage("A:" .. tostring(requesterPlayer.UserId))
                        local _, _, myRoot = GetCharParts(LocalPlayer); local _, _, theirRoot = GetCharParts(
                        requesterPlayer)
                        if myRoot and theirRoot then myRoot.CFrame = theirRoot.CFrame end
                        ShowToast("Bring accepted from " .. requesterPlayer.Name, "success"); ClosePopup()
                    end)
                    denyBtn.MouseButton1Click:Connect(function()
                        if responded then return end; task.cancel(timeout)
                        queueMessage("N:" .. tostring(requesterPlayer.UserId))
                        ShowToast("Bring denied", "neutral"); ClosePopup()
                    end)
                end

                Track(UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    
                    if input.KeyCode == Enum.KeyCode.F4 then
                        pcall(function()
                            local _selTab = _TL_refs._TL_selectTab
                            if not _selTab then return end
                            _selTab("Communication")
                        end)
                    end
                end))

                
                
                
                if LocalPlayer.Character then CreateCustomNametag(LocalPlayer.Character, LocalPlayer.Name, IsLocalAdmin) end

                local function DoesPlayerQualifyForNametag(p)
                    if not _NT_CONFIG.enabled then return false end
                    if not p then return false end
                    
                    local tgt = _NT_CONFIG.targetUser
                    if type(tgt) == "string" and tgt ~= "" then
                        if p == LocalPlayer then return true end
                        if p.Name:lower() == tgt:lower() then return true end
                        return false
                    end
                    if p == LocalPlayer then return true end
                    if State.VerifiedPeers[p] ~= nil then return true end
                    local pUserId = tostring(p.UserId)
                    if AdminNames[p.Name] == true or AdminNames[pUserId] == true then return true end
                    if NameOverrides[p.Name] ~= nil or NameOverrides[pUserId] ~= nil then return true end
                    
                    for _, users in pairs(_NT_CONFIG.roleUsers) do
                        for _, u in ipairs(users) do
                            if u:lower() == p.Name:lower() then return true end
                        end
                    end
                    return false
                end

                local lastNametagCheck = 0
                Track(RunService.Heartbeat:Connect(function()
                    local now = os.clock()
                    if now - lastNametagCheck < 0.25 then return end
                    lastNametagCheck = now

                    for _, p in ipairs(Players:GetPlayers()) do
                        local qualifies = DoesPlayerQualifyForNametag(p)
                        
                        
                        if qualifies and p ~= LocalPlayer and State.NametagVisibility[p] == false and not IsLocalAdmin then
                            qualifies = false
                        end
                        
                        if qualifies and p == LocalPlayer and settingsState.removeNametag then
                            qualifies = false
                        end
                        local char = p.Character
                        if qualifies and char and char.Parent then
                            local head = char:FindFirstChild("Head")
                            if head then
                                local guiParentBB = CoreGui
                                local tag = guiParentBB:FindFirstChild("CovertPeerTag_" .. p.Name)

                                
                                if not creatingNametag[p.Name] then
                                    local needsRecreate = false
                                    if not tag then
                                        needsRecreate = true
                                    elseif tag.Adornee ~= head then
                                        needsRecreate = true
                                    elseif not tag.Enabled then
                                        tag.Enabled = true
                                    end

                                    if needsRecreate then
                                        local isAdmin = (p == LocalPlayer and IsLocalAdmin) or (AdminNames[p.Name] == true) or (AdminNames[tostring(p.UserId)] == true)
                                        task.spawn(CreateCustomNametag, char, p.Name, isAdmin)
                                    end
                                end
                            end
                        else
                            
                            local guiParentBB = CoreGui
                            local tag = guiParentBB:FindFirstChild("CovertPeerTag_" .. p.Name)
                            if tag then
                                pcall(function() tag:Destroy() end)
                            end
                        end
                    end
                end))

                
                restoreNormalSpeed()

                task.delay(2, function() BroadcastPresence(); BroadcastNametagVisibility() end)

                local function PerformCleanup()
                    pcall(function() for _, c in ipairs(_ScriptConnections) do if c and c.Connected then c:Disconnect() end end end)
                    pcall(function() if senderGuardConn then senderGuardConn:Disconnect() end end)
                    pcall(function() restoreNormalSpeed() end)
                    pcall(function() if State.SpinConnection then State.SpinConnection:Disconnect() end end)
                    pcall(function()
                        for _, parent in ipairs({ CoreGui, LocalPlayer:WaitForChild("PlayerGui", 3) }) do
                            if parent then
                                local g = parent:FindFirstChild(guiName); if g then g:Destroy() end
                                for _, desc in ipairs(parent:GetDescendants()) do if (desc.Name == "CovertPeerTag" or desc.Name:sub(1, 14) == "CovertPeerTag_") and desc:IsA("BillboardGui") then
                                        desc:Destroy() end end
                            end
                        end
                    end)
                    pcall(function()
                        for _, player in ipairs(Players:GetPlayers()) do
                            local char = player.Character
                            if char then
                                local att = char:FindFirstChild("CovertPeerTag_Attachment"); if att then att:Destroy() end
                            end
                        end
                    end)
                end
                local cleanupBindable = Instance.new("BindableEvent"); cleanupBindable.Name = cleanupEventName; cleanupBindable.Parent =
                CoreGui
                Track(cleanupBindable.Event:Connect(function()
                    PerformCleanup(); cleanupBindable:Destroy()
                end))

                

                end)
                if not _ok_covertNet then warn("[TL] CovertNet crashed inside Settings: " .. tostring(_err_covertNet)) end

                recalculateThemeSizes()

                
                local musicPage
                musicPage = (function() 
                local _musicVol         = 0.80
                local _activeMusicSound = nil 
                local _activeMusicRow   = nil 
                local _nowPlayingLabel  = nil 
                local _currentTrackIdx  = nil 
                local _currentTracks    = nil 
                local _musicPlaying     = false
                local _cmActions        = {}
                local function _stopMusic()
                    if _activeMusicSound then
                        pcall(function()
                            _activeMusicSound:Stop(); _activeMusicSound:Destroy()
                        end)
                        _activeMusicSound = nil
                    end
                    _musicPlaying = false
                    if _nowPlayingLabel then
                        _nowPlayingLabel.Text = "No tracks found"
                        pcall(function() _nowPlayingLabel.TextColor3 = C.sub or _C3_SUB end)
                    end
                end
                local function _playMusicId(id, vol, trackName)
                    _stopMusic()
                    local snd              = Instance.new("Sound", workspace)
                    if type(id) == "string" and id:sub(1, 4) == "http" then
                        snd.SoundId = id
                    elseif type(id) == "string" and type(isfile) == "function" and type(getcustomasset) == "function" and isfile(id) then
                        local ok, _asset = pcall(function() return getcustomasset(id) end)
                        snd.SoundId = (ok and _asset) or id
                    elseif type(id) == "string" and type(_TL_safeGetCustomAsset) == "function" and id:sub(1, 7) == "assets/" and isfile(id) then
                        local _asset = _TL_safeGetCustomAsset(id)
                        snd.SoundId = _asset or id
                    else
                        snd.SoundId            = "rbxassetid://" .. tostring(id)
                    end
                    snd.Volume             = vol or 0.8
                    snd.RollOffMaxDistance = 1e9
                    snd:Play()
                    _activeMusicSound = snd
                    _musicPlaying = true
                    if _nowPlayingLabel and trackName then
                        _nowPlayingLabel.Text = "▶  " .. tostring(trackName)
                        pcall(function() _nowPlayingLabel.TextColor3 = C.accent or _C3_ACC end)
                    end
                end
                local _ok_musicPage = pcall(function()
                    musicPage                        = Instance.new("Frame", subArea)
                    musicPage.BackgroundTransparency = 1; musicPage.BorderSizePixel = 0
                    musicPage.Visible                = false
                    local MUSIC_BASE_H               = 218 
                    
                    local musicHint                  = Instance.new("TextLabel", musicPage)
                    musicHint.Size                   = UDim2.new(1, -16, 0, 20)
                    musicHint.Position               = UDim2.new(0, 8, 0, 12)
                    musicHint.BackgroundTransparency = 1
                    musicHint.Text                   = "No tracks found"
                    musicHint.Font                   = Enum.Font.GothamBold
                    musicHint.TextSize               = 13
                    musicHint.TextColor3             = C.sub or _C3_SUB
                    musicHint.TextXAlignment         = Enum.TextXAlignment.Center
                    _nowPlayingLabel                 = musicHint

                    local loadBtn = Instance.new("TextButton", musicPage)
                    loadBtn.Size = UDim2.new(1, -16, 0, 30)
                    loadBtn.Position = UDim2.new(0, 8, 0, 34)
                    loadBtn.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255) or _C3_ACC
                    loadBtn.BackgroundTransparency = 0.7
                    loadBtn.BorderSizePixel = 0
                    loadBtn.Font = Enum.Font.GothamBold; loadBtn.TextSize = 12
                    loadBtn.Text = "Load tracks"
                    loadBtn.TextColor3 = C.text or _C3_TEXT
                    corner(loadBtn, 10)
                    local loadBtnS = _makeDummyStroke(loadBtn)
                    loadBtnS.Thickness = 1; loadBtnS.Color = C.accent or _C3_ACC; loadBtnS.Transparency = 0.5
                    loadBtn.MouseButton1Click:Connect(function()
                        if _sc._playClickSound then _sc._playClickSound() end
                        if _cmActions.load then _cmActions.load() end
                    end)

                    local copyBtn = Instance.new("TextButton", musicPage)
                    copyBtn.Size = UDim2.new(1, -16, 0, 28)
                    copyBtn.Position = UDim2.new(0, 8, 0, 68)
                    copyBtn.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3
                    copyBtn.BackgroundTransparency = 0.5
                    copyBtn.BorderSizePixel = 0
                    copyBtn.Font = Enum.Font.Gotham; copyBtn.TextSize = 11
                    copyBtn.Text = "Copy path"
                    copyBtn.TextColor3 = C.sub or _C3_SUB
                    corner(copyBtn, 8)
                    local copyBtnS = _makeDummyStroke(copyBtn)
                    copyBtnS.Thickness = 1; copyBtnS.Color = C.bg3 or _C3_BG3; copyBtnS.Transparency = 0.6
                    copyBtn.MouseButton1Click:Connect(function()
                        if _sc._playClickSound then _sc._playClickSound() end
                        local path = _cmEnsureFolder() or "Custom-Music"
                        pcall(function() setclipboard(path) end)
                        copyBtn.Text = "Copied!"
                        task.delay(1.5, function() copyBtn.Text = "Copy path" end)
                    end)
                    
                    local volCard                    = Instance.new("Frame", musicPage)
                    volCard.Size                     = UDim2.new(1, -16, 0, 52)
                    volCard.Position                 = UDim2.new(0, 8, 0, 100)
                    volCard.BackgroundColor3         = Color3.fromRGB(255, 255, 255)
                    volCard.BackgroundTransparency   = 0.94
                    volCard.BorderSizePixel          = 0
                    corner(volCard, 14)
                    local volCard_Stroke = _makeDummyStroke(volCard)
                    volCard_Stroke.Thickness = 1; volCard_Stroke.Color = C.bg3 or _C3_BG3; volCard_Stroke.Transparency = 0.4
                    local volLbl = Instance.new("TextLabel", volCard)
                    volLbl.Size = UDim2.new(0, 70, 0, 14); volLbl.Position = UDim2.new(0, 12, 0, 8)
                    volLbl.BackgroundTransparency = 1; volLbl.Text = "🔊 Volume"
                    volLbl.Font = Enum.Font.GothamBold; volLbl.TextSize = 12
                    volLbl.TextColor3 = C.text or _C3_TEXT; volLbl.TextXAlignment = Enum.TextXAlignment.Left
                    local volPct = Instance.new("TextLabel", volCard)
                    volPct.Size = UDim2.new(0, 40, 0, 14); volPct.Position = UDim2.new(1, -50, 0, 8)
                    volPct.BackgroundTransparency = 1; volPct.Text = "80%"
                    volPct.Font = Enum.Font.GothamBold; volPct.TextSize = 12
                    volPct.TextColor3 = C.accent or _C3_ACC; volPct.TextXAlignment = Enum.TextXAlignment.Right
                    
                    local slTrack = Instance.new("Frame", volCard)
                    slTrack.Size = UDim2.new(1, -24, 0, 6); slTrack.Position = UDim2.new(0, 12, 0, 34)
                    slTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3; slTrack.BackgroundTransparency = 0.3
                    slTrack.BorderSizePixel = 0; corner(slTrack, 99)
                    local slFill = Instance.new("Frame", slTrack)
                    slFill.Size = UDim2.new(0.80, 0, 1, 0); slFill.Position = UDim2.new(0, 0, 0, 0)
                    slFill.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255) or _C3_ACC; slFill.BackgroundTransparency = 0
                    slFill.BorderSizePixel = 0; corner(slFill, 99)
                    local slKnob = Instance.new("Frame", slTrack)
                    slKnob.Size = UDim2.new(0, 14, 0, 14); slKnob.Position = UDim2.new(0.80, -7, 0.5, -7)
                    slKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); slKnob.BackgroundTransparency = 0
                    slKnob.BorderSizePixel = 0; corner(slKnob, 99)
                    local slKnob_Stroke = _makeDummyStroke(slKnob)
                    slKnob_Stroke.Thickness = 2; slKnob_Stroke.Color = C.accent or _C3_ACC; slKnob_Stroke.Transparency = 0.3
                    local slBtn = Instance.new("TextButton", slTrack)
                    slBtn.Size = UDim2.new(1, 0, 0, 20); slBtn.Position = UDim2.new(0, 0, 0.5, -10)
                    slBtn.BackgroundTransparency = 1; slBtn.Text = ""
                    local _slDrag = false
                    local function _setVolume(v)
                        v = math.clamp(v, 0, 1)
                        _musicVol = v
                        if _activeMusicSound then pcall(function() _activeMusicSound.Volume = v end) end
                        local pct = math.floor(v * 100)
                        volPct.Text = pct .. "%"
                        volPct.TextColor3 = (v == 0) and (C.sub or _C3_SUB) or (C.accent or _C3_ACC)
                        twP(slFill, 0.08, { Size = UDim2.new(v, 0, 1, 0) })
                        twP(slKnob, 0.08, { Position = UDim2.new(v, -7, 0.5, -7) })
                    end
                    local function _sliderFromInput(inp)
                        local absX = slTrack.AbsolutePosition.X
                        local absW = slTrack.AbsoluteSize.X
                        local relX = inp.Position.X - absX
                        _setVolume(relX / absW)
                    end
                    slBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1
                            or inp.UserInputType == Enum.UserInputType.Touch then
                            _slDrag = true; _sliderFromInput(inp)
                        end
                    end)
                    slBtn.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1
                            or inp.UserInputType == Enum.UserInputType.Touch then
                            _slDrag = false
                        end
                    end)
                    _SvcUIS.InputChanged:Connect(function(inp)
                        if not _slDrag then return end
                        if inp.UserInputType == Enum.UserInputType.MouseMovement
                            or inp.UserInputType == Enum.UserInputType.Touch then
                            _sliderFromInput(inp)
                        end
                    end)
                    
                    local tCard = Instance.new("Frame", musicPage)
                    tCard.Size = UDim2.new(1, -16, 0, 52)
                    tCard.Position = UDim2.new(0, 8, 0, 156)
                    tCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    tCard.BackgroundTransparency = 0.94
                    tCard.BorderSizePixel = 0
                    corner(tCard, 14)
                    local tCard_Stroke = _makeDummyStroke(tCard)
                    tCard_Stroke.Thickness = 1; tCard_Stroke.Color = C.bg3 or _C3_BG3; tCard_Stroke.Transparency = 0.4
                    local BTN_W, BTN_H = 44, 34
                    local BTN_GAP = 8
                    local BTN_TOTAL = 3 * BTN_W + 2 * BTN_GAP
                    
                    local function _mkTBtn(imgId, xOff, isAccent, iconSize)
                        local btn = Instance.new("ImageButton", tCard)
                        btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
                        btn.Position = UDim2.new(0.5, -math.floor(BTN_TOTAL / 2) + xOff, 0.5, -math.floor(BTN_H / 2))
                        btn.BackgroundColor3 = isAccent and (C.accent or _C3_ACC) or (C.bg3 or _C3_BG3)
                        btn.BackgroundTransparency = isAccent and 0.25 or 0.45
                        btn.BorderSizePixel = 0
                        btn.AutoButtonColor = false
                        btn.Image = "rbxassetid://" .. tostring(imgId)
                        btn.ImageColor3 = isAccent and Color3.fromRGB(255, 255, 255) or (C.text or _C3_TEXT)
                        btn.ScaleType = Enum.ScaleType.Fit
                        btn.ImageRectSize = Vector2.new(0, 0) 
                        corner(btn, 10)
                        local s = _makeDummyStroke(btn)
                        s.Thickness = 1.2
                        s.Color = isAccent and (C.accent or _C3_ACC) or (C.bg3 or _C3_BG3)
                        s.Transparency = 0.55
                        
                        return btn, btn, s
                    end
                    local backBtn, backImg, backS = _mkTBtn(131323738229242, 0, false, 20)
                    local playBtn, playImg, playS = _mkTBtn(109215952992723, BTN_W + BTN_GAP, true, 20)
                    local skipBtn, skipImg, skipS = _mkTBtn(115665337119894, (BTN_W + BTN_GAP) * 2, false, 20)
                    playBtn.BackgroundTransparency = 1
                    local function _navigateTrack(delta)
                        if not _currentTracks or not _currentTrackIdx then return end
                        local n = #_currentTracks
                        if n == 0 then return end
                        local newIdx = ((_currentTrackIdx - 1 + delta) % n) + 1
                        local target = _plRowFrames[newIdx]
                        if not target then return end
                        
                        if _activeMusicRow then
                            for _, rf in ipairs(_plRowFrames) do
                                if rf.row == _activeMusicRow then
                                    twP(rf.row, 0.12, { BackgroundTransparency = 0.92 })
                                    twP(rf.nameL, 0.12, { TextColor3 = C.text or _C3_TEXT })
                                end
                            end
                        end
                        
                        local track = _currentTracks[newIdx]
                        _currentTrackIdx = newIdx
                        _playMusicId(track.id, _musicVol, track.name)
                        _activeMusicRow = target.row
                        twP(target.row, 0.15, { BackgroundTransparency = 0.75 })
                        twP(target.nameL, 0.15, { TextColor3 = target.col })
                        playBtn.Image = "rbxassetid://" .. tostring(_STOP_IMG)
                        twP(playImg, 0.10, { ImageColor3 = C.accent or _C3_ACC })
                    end
                    backBtn.MouseButton1Click:Connect(function()
                        if _sc._playClickSound then _sc._playClickSound() end
                        twP(backBtn, 0.06, { BackgroundTransparency = 0.10 })
                        task.delay(0.12, function() twP(backBtn, 0.12, { BackgroundTransparency = 0.45 }) end)
                        _navigateTrack(-1)
                    end)
                    skipBtn.MouseButton1Click:Connect(function()
                        if _sc._playClickSound then _sc._playClickSound() end
                        twP(skipBtn, 0.06, { BackgroundTransparency = 0.10 })
                        task.delay(0.12, function() twP(skipBtn, 0.12, { BackgroundTransparency = 0.45 }) end)
                        _navigateTrack(1)
                    end)
                    local _PLAY_IMG = 109215952992723
                    local _STOP_IMG = 129830110201524 
                    playBtn.MouseButton1Click:Connect(function()
                        if _sc._playClickSound then _sc._playClickSound() end
                        if not _activeMusicSound then return end
                        _musicPlaying = not _musicPlaying
                        if _musicPlaying then
                            pcall(function() _activeMusicSound:Resume() end)
                            playBtn.Image = "rbxassetid://" .. tostring(_STOP_IMG)
                            if _nowPlayingLabel and _currentTracks and _currentTrackIdx then
                                local t = _currentTracks[_currentTrackIdx]
                                if t then _nowPlayingLabel.Text = "▶  " .. t.name end
                                pcall(function() _nowPlayingLabel.TextColor3 = C.accent or _C3_ACC end)
                            end
                        else
                            pcall(function() _activeMusicSound:Pause() end)
                            playBtn.Image = "rbxassetid://" .. tostring(_PLAY_IMG)
                            if _nowPlayingLabel and _currentTracks and _currentTrackIdx then
                                local t = _currentTracks[_currentTrackIdx]
                                if t then _nowPlayingLabel.Text = "⏸  " .. t.name end
                                pcall(function() _nowPlayingLabel.TextColor3 = C.sub or _C3_SUB end)
                            end
                        end
                        twP(playImg, 0.10,
                            { ImageColor3 = _musicPlaying and (C.accent or _C3_ACC) or Color3.fromRGB(255, 255, 255) })
                    end)
                    
                    local THEME_PLAYLISTS = {
                        onepiece = {
                            col    = Color3.fromRGB(255, 195, 0),
                            label  = "☠  One Piece OST",
                            tracks = {
                                { name = "Three Blades, One Dream", id = 71344313076885 },
                                { name = "Share The World",         id = 77799837126623 },
                            },
                        },
                        theboys = {
                            col    = Color3.fromRGB(220, 30, 30),
                            label  = "🩸  The Boys Theme Music",
                            tracks = {
                                { name = "Homelander Theme", id = "assets/TL-MP3-FILES/Theme-TheBoys-Music.mp3" },
                            },
                        },
                    }
                    local TRACK_ROW_H     = 40
                    local PL_HEADER_H     = 44
                    local PL_PAD_TOP      = 8 
                    local _plOpen         = false
                    local _plCard         = nil
                    local _plChevron      = nil
                    local _plCurTheme     = nil
                    local _plRowFrames    = {}
                    local _plInnerH       = 0 
                    
                    local function _refreshMusicPanelH()
                        if activeCat ~= "Music" then return end
                        local pgH   = musicPage.Size.Y.Offset
                        local newPH = math.min(SET_BASE_H + pgH + 8, SET_MAX_H)
                        tw(subArea, 0.24, { Size = UDim2.new(1, 0, 0, pgH) },
                            Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
                        tw(p, 0.24, { Size = UDim2.new(0, PANEL_W, 0, newPH) },
                            Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
                        task.delay(0.26, function()
                            if _updateSubAreaCanvas then _updateSubAreaCanvas() end
                        end)
                    end
                    local function _buildPlaylistCard(themeId)
                        local pl = THEME_PLAYLISTS[themeId]
                        if not pl then return end
                        if _plCard then pcall(function() _plCard:Destroy() end) end
                        _plCard                     = nil; _plChevron = nil; _plRowFrames = {}
                        _plOpen                     = false; _plCurTheme = themeId

                        local nTracks               = #pl.tracks
                        local MAX_VISIBLE_ROWS      = 3
                        local useScroll             = nTracks > MAX_VISIBLE_ROWS
                        local visibleRows           = math.min(nTracks, MAX_VISIBLE_ROWS)
                        
                        
                        
                        local rowContainerH         = visibleRows * TRACK_ROW_H 
                        local fullRowH              = nTracks * TRACK_ROW_H 
                        local clampedInnerH         = 4 + rowContainerH + 4 
                        _plInnerH                   = clampedInnerH

                        local cardY                 = MUSIC_BASE_H + PL_PAD_TOP

                        
                        local card                  = Instance.new("Frame", musicPage)
                        card.Size                   = UDim2.new(1, -16, 0, PL_HEADER_H)
                        card.Position               = UDim2.new(0, 8, 0, cardY)
                        card.BackgroundColor3       = pl.col
                        card.BackgroundTransparency = 0.88
                        card.BorderSizePixel        = 0
                        card.ClipsDescendants       = false
                        corner(card, 14)
                        local cStr                      = _makeDummyStroke(card)
                        cStr.Thickness                  = 1.2; cStr.Color = pl.col; cStr.Transparency = 0.5
                        _plCard                         = card

                        
                        local clipWrap                  = Instance.new("Frame", card)
                        clipWrap.Size                   = UDim2.new(1, 0, 0, 0)
                        clipWrap.Position               = UDim2.new(0, 0, 0, PL_HEADER_H)
                        clipWrap.BackgroundTransparency = 1
                        clipWrap.BorderSizePixel        = 0
                        clipWrap.ClipsDescendants       = true

                        
                        local sep                       = Instance.new("Frame", clipWrap)
                        sep.Size                        = UDim2.new(1, -20, 0, 1); sep.Position = UDim2.new(0, 10, 0, 2)
                        sep.BackgroundColor3            = pl.col; sep.BackgroundTransparency = 0.65; sep.BorderSizePixel = 0

                        
                        local rowContainer
                        if useScroll then
                            local sf                      = Instance.new("ScrollingFrame", clipWrap)
                            sf.Size                       = UDim2.new(1, 0, 0, rowContainerH)
                            sf.Position                   = UDim2.new(0, 0, 0, 4)
                            sf.CanvasSize                 = UDim2.new(0, 0, 0, fullRowH)
                            sf.BackgroundTransparency     = 1
                            sf.BorderSizePixel            = 0
                             sf.ScrollBarThickness         = 3; sf.ScrollBarImageColor3 = C.accent
                            sf.ScrollBarImageColor3       = pl.col
                            sf.ScrollBarImageTransparency = 0.4
                            sf.ElasticBehavior            = Enum.ElasticBehavior.Never
                            rowContainer                  = sf
                        else
                            local plain                  = Instance.new("Frame", clipWrap)
                            plain.Size                   = UDim2.new(1, 0, 0, rowContainerH)
                            plain.Position               = UDim2.new(0, 0, 0, 4)
                            plain.BackgroundTransparency = 1
                            plain.BorderSizePixel        = 0
                            rowContainer                 = plain
                        end

                        
                        local hBtn = Instance.new("TextButton", card)
                        hBtn.Size = UDim2.new(1, 0, 0, PL_HEADER_H)
                        hBtn.Position = UDim2.new(0, 0, 0, 0)
                        hBtn.BackgroundTransparency = 1; hBtn.Text = ""; hBtn.ZIndex = 4

                        
                        local hIcon = Instance.new("TextLabel", card)
                        hIcon.Size = UDim2.new(0, 28, 0, 28); hIcon.Position = UDim2.new(0, 10, 0, 8)
                        hIcon.BackgroundTransparency = 1; hIcon.Text = "🎵"
                        hIcon.Font = Enum.Font.GothamBlack; hIcon.TextSize = 18
                        hIcon.TextColor3 = pl.col; hIcon.TextXAlignment = Enum.TextXAlignment.Center

                        local hLbl = Instance.new("TextLabel", card)
                        hLbl.Size = UDim2.new(1, -60, 0, 16); hLbl.Position = UDim2.new(0, 42, 0, 8)
                        hLbl.BackgroundTransparency = 1; hLbl.Text = pl.label
                        hLbl.Font = Enum.Font.GothamBold; hLbl.TextSize = 13
                        hLbl.TextColor3 = pl.col; hLbl.TextXAlignment = Enum.TextXAlignment.Left

                        local hSub = Instance.new("TextLabel", card)
                        hSub.Size = UDim2.new(1, -60, 0, 14); hSub.Position = UDim2.new(0, 42, 0, 26)
                        hSub.BackgroundTransparency = 1
                        hSub.Text = nTracks .. " Track" .. (nTracks ~= 1 and "s" or "")
                        hSub.Font = Enum.Font.Gotham; hSub.TextSize = 11
                        hSub.TextColor3 = C.sub or _C3_SUB; hSub.TextXAlignment = Enum.TextXAlignment.Left

                        local chev = Instance.new("ImageLabel", card)
                        chev.Size = UDim2.new(0, 16, 0, 16); chev.Position = UDim2.new(1, -26, 0, 14)
                        chev.BackgroundTransparency = 1
                        chev.Image = "rbxassetid://125463592889179"
                        chev.ImageColor3 = pl.col
                        chev.ScaleType = Enum.ScaleType.Fit
                        _plChevron = chev

                        
                        local function _unhighlightRow(r)
                            for _, rf in ipairs(_plRowFrames) do
                                if rf.row == r then
                                    twP(rf.row, 0.12, { BackgroundTransparency = 0.92 })
                                    twP(rf.nameL, 0.12, { TextColor3 = C.text or _C3_TEXT })
                                end
                            end
                        end

                        
                        for i, track in ipairs(pl.tracks) do
                            local ry                   = (i - 1) * TRACK_ROW_H + 4
                            local row                  = Instance.new("Frame", rowContainer)
                            row.Size                   = UDim2.new(1, -8, 0, TRACK_ROW_H - 4)
                            row.Position               = UDim2.new(0, 4, 0, ry)
                            row.BackgroundColor3       = pl.col; row.BackgroundTransparency = 0.92
                            row.BorderSizePixel        = 0; corner(row, 10)

                            local rowBtn = Instance.new("TextButton", row)
                            rowBtn.Size = UDim2.new(1, 0, 1, 0)
                            rowBtn.BackgroundTransparency = 1; rowBtn.Text = ""; rowBtn.ZIndex = 5

                            local noteL = Instance.new("TextLabel", row)
                            noteL.Size = UDim2.new(0, 24, 1, 0); noteL.Position = UDim2.new(0, 6, 0, 0)
                            noteL.BackgroundTransparency = 1; noteL.Text = "♪"
                            noteL.Font = Enum.Font.GothamBold; noteL.TextSize = 14
                            noteL.TextColor3 = pl.col; noteL.TextXAlignment = Enum.TextXAlignment.Center

                            local nameL = Instance.new("TextLabel", row)
                            nameL.Size = UDim2.new(1, -50, 0, 16); nameL.Position = UDim2.new(0, 32, 0.5, -8)
                            nameL.BackgroundTransparency = 1; nameL.Text = track.name
                            nameL.Font = Enum.Font.GothamBold; nameL.TextSize = 12
                            nameL.TextColor3 = C.text or _C3_TEXT; nameL.TextXAlignment = Enum.TextXAlignment.Left

                            table.insert(_plRowFrames,
                                { row = row, nameL = nameL, id = track.id, col = pl.col, name = track.name })

                            local trackId  = track.id
                            local rowRef   = row
                            local nameLRef = nameL

                            rowBtn.MouseButton1Click:Connect(function()
                                if _activeMusicRow == rowRef then
                                    _stopMusic(); _activeMusicRow = nil
                                    _currentTrackIdx = nil
                                    _unhighlightRow(rowRef)
                                    playBtn.Image = "rbxassetid://" .. tostring(_PLAY_IMG)
                                    twP(playImg, 0.10, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
                                    return
                                end
                                if _activeMusicRow then _unhighlightRow(_activeMusicRow) end
                                _currentTracks = pl.tracks
                                _currentTrackIdx = i
                                _playMusicId(trackId, _musicVol, track.name)
                                _activeMusicRow = rowRef
                                twP(rowRef, 0.15, { BackgroundTransparency = 0.75 })
                                twP(nameLRef, 0.15, { TextColor3 = pl.col })
                                playBtn.Image = "rbxassetid://" .. tostring(_STOP_IMG)
                                twP(playImg, 0.10, { ImageColor3 = C.accent or _C3_ACC })
                                twP(playBtn, 0.10, { BackgroundTransparency = 0.05 })
                            end)
                            rowBtn.MouseEnter:Connect(function()
                                if _activeMusicRow ~= rowRef then
                                    twP(rowRef, 0.08, { BackgroundTransparency = 0.82 })
                                end
                            end)

    return _cp, _cs
end

return CommunicationTab