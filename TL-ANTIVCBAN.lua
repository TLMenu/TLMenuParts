local GLOBAL_ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_AntiVCBAN_Runtime"

local prev = GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY]
if type(prev) == "table" and type(prev.cleanup) == "function" then pcall(prev.cleanup) end

local runtime = { connections = {}, instances = {}, destroyed = false }
runtime.cleanup = function()
    if runtime.destroyed then return end; runtime.destroyed = true
    for _, c in ipairs(runtime.connections) do
        pcall(function() if type(c) ~= "thread" then c:Disconnect() end end)
    end
    runtime.connections = {}
    for i = #runtime.instances, 1, -1 do
        pcall(function() local inst = runtime.instances[i]; if inst and inst.Parent then inst:Destroy() end end)
    end
    runtime.instances = {}
    if GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY] == runtime then GLOBAL_ENV[RUNTIME_KEY] = nil end
end
if GLOBAL_ENV then GLOBAL_ENV[RUNTIME_KEY] = runtime end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VoiceChatService = game:GetService("VoiceChatService")
local VoiceInternal = (pcall(function() return game:GetService("VoiceChatInternal") end) and
    game:GetService("VoiceChatInternal")) or nil

local lp = Players.LocalPlayer
local get_conns = (typeof(getconnections) == "function" and getconnections)
    or (typeof(get_signal_cons) == "function" and get_signal_cons)
    or nil


local _vc_active = false
local _vc_connections = {}
local _vc_currentADI = nil
local _vc_lastADISearch = 0
local _vc_micGui = nil
local _vc_unmutedIcon = nil
local _vc_mutedIcon = nil
local _vc_iconContainer = nil
local _vc_lastMuted = nil
local _vc_clickLock = false
local _vc_lastToggleAt = 0
local _vc_desiredMuted = nil
local _vc_hiddenIcons = setmetatable({}, { __mode = "k" })

local UNMUTED_ASSET = "rbxasset://textures/ui/VoiceChat/MicLight/Unmuted0.png"
local MUTED_ASSET = "rbxasset://textures/ui/VoiceChat/MicLight/Muted.png"


local _sendNotif = nil
local function notify(title, text, duration)
    if _sendNotif then _sendNotif(title, text, duration) return end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3
        })
    end)
end


local function safeIsFile(path)
    if type(isfile) ~= "function" then return false end
    local ok, result = pcall(isfile, path)
    return ok and result == true
end
local function safeIsFolder(path)
    if type(isfolder) ~= "function" then return false end
    local ok, result = pcall(isfolder, path)
    return ok and result == true
end
local function safeMakeFolder(path)
    if type(makefolder) ~= "function" then return false end
    return pcall(makefolder, path)
end
local function safeWriteFile(path, bytes)
    if type(writefile) ~= "function" then return false end
    return pcall(writefile, path, bytes)
end
local function safeGetCustomAsset(path)
    if type(getcustomasset) == "function" then
        local ok, asset = pcall(getcustomasset, path)
        if ok and asset and asset ~= "" then return asset end
    end
    if type(getsynasset) == "function" then
        local ok, asset = pcall(getsynasset, path)
        if ok and asset and asset ~= "" then return asset end
    end
    return nil
end


local _vcCachedTargets, _vcLastFetch = nil, 0
local function _vc_fetchVoiceTargets()
    if _vcCachedTargets and tick() - _vcLastFetch < 15 then return _vcCachedTargets end
    local targets = {}
    if get_conns then
        local signalList = {
            { VoiceInternal, "StateChanged" },
            { VoiceInternal, "Participants" },
            { VoiceChatService, "StateChanged" },
            { VoiceChatService, "PlayerMicStateChanged" },
        }
        for _, entry in pairs(signalList) do
            local inst, evName = entry[1], entry[2]
            if inst then
                pcall(function()
                    local sig = (evName == "Participants")
                        and inst:GetPropertyChangedSignal("Participants")
                        or inst[evName]
                    if sig then
                        local conns = get_conns(sig)
                        if conns and #conns > 0 then
                            targets[#targets + 1] = { connections = conns, conn8 = conns[8] }
                        end
                    end
                end)
            end
        end
    end
    _vcCachedTargets = targets
    _vcLastFetch = tick()
    return targets
end

local function _vc_manageConnections()
    for _, target in pairs(_vc_fetchVoiceTargets()) do
        if target.conn8 and not target.conn8.Enabled then
            pcall(function() target.conn8:Enable() end)
        end
        for i, conn in pairs(target.connections) do
            if i ~= 8 and conn.Enabled then
                pcall(function() conn:Disable() end)
            end
        end
    end
end


local function _vc_getADI()
    if _vc_currentADI and _vc_currentADI.Parent then return _vc_currentADI end
    local now = tick()
    if now - _vc_lastADISearch < 2.0 then return nil end
    _vc_lastADISearch = now
    pcall(function()
        _vc_currentADI = lp:FindFirstChildOfClass("AudioDeviceInput")
        if not _vc_currentADI and lp.Character then
            _vc_currentADI = lp.Character:FindFirstChildOfClass("AudioDeviceInput")
            if not _vc_currentADI then
                for _, v in ipairs(lp.Character:GetDescendants()) do
                    if v.ClassName == "AudioDeviceInput" then _vc_currentADI = v; break end
                end
            end
        end
    end)
    return _vc_currentADI
end


local function _vc_applyIconState(muted)
    muted = muted == true
    _vc_lastMuted = muted
    if _vc_unmutedIcon and _vc_mutedIcon then
        _vc_unmutedIcon.Visible = not muted
        _vc_mutedIcon.Visible = muted
    end
end


local _vc_VOICE_REJOIN_GAP = 0.5
local _vc_FLUSH_ON_UNMUTE  = true
local _vc_FLUSH_MIN_MUTE   = 8
local _vc_mutedAt          = 0
local _vc_flushing         = false
local function _vc_flushVoicePipeline()
    if _vc_flushing then return end
    _vc_flushing = true
    task.spawn(function()
        pcall(function() VoiceChatService:leaveVoice() end)
        task.wait(_vc_VOICE_REJOIN_GAP)
        if not _vc_desiredMuted then
            pcall(function() VoiceChatService:joinVoice() end)
            for _ = 1, 12 do
                task.wait(0.1)
                if _vc_desiredMuted then break end
                local live = false
                pcall(function()
                    if VoiceInternal and VoiceInternal.PublishPause then VoiceInternal:PublishPause(false) end
                    if VoiceInternal and VoiceInternal.IsPublishPaused then live = (VoiceInternal:IsPublishPaused() == false) end
                end)
                if live then break end
            end
            pcall(_vc_manageConnections)
        end
        _vc_flushing = false
    end)
end


local function _vc_toggleMute()
    local adi = _vc_getADI()
    local currentMuted = false
    pcall(function()
        if _vc_desiredMuted ~= nil then currentMuted = _vc_desiredMuted == true
        elseif adi then currentMuted = adi.Muted == true
        elseif _vc_lastMuted ~= nil then currentMuted = _vc_lastMuted == true end
    end)

    local newState = not currentMuted
    _vc_desiredMuted = newState
    _vc_lastToggleAt = tick()
    if newState then _vc_mutedAt = tick() end
    _vc_applyIconState(newState)

    local function applyMutedState()
        local currentAdi = _vc_getADI()
        local apiApplied = false
        if currentAdi then
            pcall(function() currentAdi.Muted = newState end)
        end
        pcall(function()
            if VoiceChatService and VoiceChatService.SetSelfMuted then
                VoiceChatService:SetSelfMuted(newState); apiApplied = true
            end
        end)
        pcall(function()
            if VoiceChatService and VoiceChatService.InternalSetMuted then
                VoiceChatService:InternalSetMuted(newState); apiApplied = true
            end
        end)
        pcall(function()
            if not apiApplied and VoiceChatService and VoiceChatService.ToggleMute and currentAdi and currentAdi.Muted ~= newState then
                VoiceChatService:ToggleMute()
            end
        end)
        pcall(function()
            if VoiceInternal and VoiceInternal.SetSelfMuted then
                VoiceInternal:SetSelfMuted(newState); apiApplied = true
            end
        end)
        pcall(function()
            if VoiceInternal and VoiceInternal.SetMuted then
                VoiceInternal:SetMuted(lp.UserId, newState); apiApplied = true
            end
        end)
        pcall(function()
            if VoiceInternal then
                local speaker = VoiceInternal:GetSpeaker(lp.UserId)
                if speaker then speaker:SetMuted(newState) end
            end
        end)
        pcall(function()
            if VoiceInternal and VoiceInternal.PublishPause then
                VoiceInternal:PublishPause(newState and true or false)
            end
        end)
    end

    applyMutedState()
    if (not newState) and _vc_FLUSH_ON_UNMUTE and _vc_mutedAt > 0
        and (tick() - _vc_mutedAt) >= _vc_FLUSH_MIN_MUTE then
        _vc_flushVoicePipeline()
    end
    task.delay(0.10, applyMutedState)
    task.delay(0.35, applyMutedState)
    task.delay(0.55, function()
        local refreshedAdi = _vc_getADI()
        if refreshedAdi then
            local realMuted = refreshedAdi.Muted == true
            if realMuted == _vc_desiredMuted then
                _vc_desiredMuted = realMuted
                _vc_applyIconState(realMuted)
            end
        end
    end)
end


local _hoverInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local _clickInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function _vc_tweenScale(uiScale, targetScale, info)
    info = info or _hoverInfo
    local tw = TweenService:Create(uiScale, info, { Scale = targetScale })
    tw:Play()
    return tw
end


local function _vc_buildTopBarMic()
    local old = CoreGui:FindFirstChild("TL_TopBarMic")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "TL_TopBarMic"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    gui.Parent = CoreGui
    _vc_micGui = gui
    table.insert(runtime.instances, gui)

    local btn = Instance.new("ImageButton")
    btn.Name = "MicButton"
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.new(0, 165 + 23, 0, 13 + 21)
    btn.Size = UDim2.new(0, 43, 0, 43)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Image = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Selectable = true
    btn.ZIndex = 100
    btn.Parent = gui

    _vc_iconContainer = Instance.new("Frame")
    _vc_iconContainer.Name = "IconContainer"
    _vc_iconContainer.Size = UDim2.new(1, 0, 1, 0)
    _vc_iconContainer.BackgroundTransparency = 1
    _vc_iconContainer.ZIndex = 101
    _vc_iconContainer.Parent = btn

    local uiScale = Instance.new("UIScale")
    uiScale.Name = "ScaleAnim"
    uiScale.Scale = 1
    uiScale.Parent = _vc_iconContainer

    _vc_unmutedIcon = Instance.new("ImageLabel")
    _vc_unmutedIcon.Name = "UnmutedIcon"
    _vc_unmutedIcon.Size = UDim2.new(1, 0, 1, 0)
    _vc_unmutedIcon.BackgroundTransparency = 1
    _vc_unmutedIcon.Image = UNMUTED_ASSET
    _vc_unmutedIcon.ScaleType = Enum.ScaleType.Fit
    _vc_unmutedIcon.Visible = true
    _vc_unmutedIcon.ZIndex = 102
    _vc_unmutedIcon.Parent = _vc_iconContainer

    _vc_mutedIcon = Instance.new("ImageLabel")
    _vc_mutedIcon.Name = "MutedIcon"
    _vc_mutedIcon.Size = UDim2.new(1, 0, 1, 0)
    _vc_mutedIcon.BackgroundTransparency = 1
    _vc_mutedIcon.Image = MUTED_ASSET
    _vc_mutedIcon.ScaleType = Enum.ScaleType.Fit
    _vc_mutedIcon.Visible = false
    _vc_mutedIcon.ZIndex = 102
    _vc_mutedIcon.Parent = _vc_iconContainer

    local function _vc_handleMicClick(targetScale)
        if _vc_clickLock then return end
        _vc_clickLock = true
        _vc_tweenScale(uiScale, 0.85, _clickInfo)
        task.wait(0.08)
        _vc_tweenScale(uiScale, targetScale or 1, _clickInfo)
        _vc_toggleMute()
        task.delay(0.16, function() _vc_clickLock = false end)
    end

    local hitbox = Instance.new("TextButton")
    hitbox.Name = "MicHitbox"
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.AutoButtonColor = false
    hitbox.Active = true
    hitbox.Selectable = true
    hitbox.ZIndex = 103
    hitbox.Parent = btn

    btn.MouseButton1Down:Connect(function() _vc_handleMicClick(1.1) end)
    hitbox.MouseButton1Down:Connect(function() _vc_handleMicClick(1.1) end)
    btn.MouseButton1Click:Connect(function() _vc_handleMicClick(1.1) end)
    hitbox.MouseButton1Click:Connect(function() _vc_handleMicClick(1.1) end)
    btn.TouchTap:Connect(function() _vc_handleMicClick(1) end)
    hitbox.TouchTap:Connect(function() _vc_handleMicClick(1) end)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _vc_handleMicClick(input.UserInputType == Enum.UserInputType.MouseButton1 and 1.1 or 1)
        end
    end)
    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _vc_handleMicClick(input.UserInputType == Enum.UserInputType.MouseButton1 and 1.1 or 1)
        end
    end)
    btn.MouseEnter:Connect(function() _vc_tweenScale(uiScale, 1.1) end)
    btn.MouseLeave:Connect(function() _vc_tweenScale(uiScale, 1) end)
    hitbox.MouseEnter:Connect(function() _vc_tweenScale(uiScale, 1.1) end)
    hitbox.MouseLeave:Connect(function() _vc_tweenScale(uiScale, 1) end)
end


local function _vc_downloadIcons()
    if not safeIsFolder("assets") then safeMakeFolder("assets") end
    if not safeIsFolder("assets/TL-DEFAULT") then safeMakeFolder("assets/TL-DEFAULT") end
    local urls = {
        { "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/TL-DEFAULT/ANTIVCBAN-Unmuted-Icon.png", "assets/TL-DEFAULT/TL_Unmuted.png", "unmuted" },
        { "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/TL-DEFAULT/ANTIVCBAN-Mute-Icon.png", "assets/TL-DEFAULT/TL_Muted.png", "muted" },
    }
    for _, entry in pairs(urls) do
        task.spawn(function()
            pcall(function()
                if not safeIsFile(entry[2]) then
                    local data = (game :: any):HttpGet(entry[1])
                    if data then safeWriteFile(entry[2], data) end
                end
                local asset = safeGetCustomAsset(entry[2])
                if asset then
                    if entry[3] == "unmuted" then
                        UNMUTED_ASSET = asset
                        if _vc_unmutedIcon then _vc_unmutedIcon.Image = asset end
                    else
                        MUTED_ASSET = asset
                        if _vc_mutedIcon then _vc_mutedIcon.Image = asset end
                    end
                end
            end)
        end)
    end
end


local function _vc_hideOriginalTopBarMic()
    for _, sg in ipairs(CoreGui:GetChildren()) do
        if sg:IsA("ScreenGui") and sg.Name ~= "TL_TopBarMic" then
            local n = sg.Name:lower()
            if n:find("voicechat") or n:find("topbarmic") or n:find("inexperiencevoice") then
                for _, v in ipairs(sg:GetDescendants()) do
                    if v:IsA("GuiObject") and not _vc_hiddenIcons[v] then
                        local vn = v.Name:lower()
                        if (vn == "micicon" or vn == "voicechaticon"
                            or vn:find("micbutton") or vn:find("voicebutton")
                            or vn:find("topbar")) then
                            if v:IsA("ImageLabel") or v:IsA("ImageButton") then
                                pcall(function() v.ImageTransparency = 1 end)
                            end
                            if v:IsA("Frame") or v:IsA("ImageButton") or v:IsA("TextButton") then
                                pcall(function() v.BackgroundTransparency = 1 end)
                            end
                            _vc_hiddenIcons[v] = true
                        end
                    end
                end
            end
        end
    end
end


local function _vc_syncMuteState()
    local adi = _vc_getADI()
    if not adi then return end
    local muted = adi.Muted
    if _vc_desiredMuted ~= nil and muted ~= _vc_desiredMuted and (tick() - _vc_lastToggleAt) < 3 then return end
    if _vc_lastMuted == muted then return end
    _vc_desiredMuted = muted
    _vc_applyIconState(muted)
end


local function _vc_executeAntiVCBan()
    pcall(function() VoiceChatService:leaveVoice() end)
    task.wait(2.3)
    pcall(function() VoiceChatService:joinVoice() end)
    task.wait(0.3)

    for _, target in pairs(_vc_fetchVoiceTargets()) do
        if target.conn8 then
            pcall(function() target.conn8:Enable(); target.conn8:Fire() end)
        end
        for i, conn in pairs(target.connections) do
            if i ~= 8 then pcall(function() conn:Disable() end) end
        end
    end

    _vc_buildTopBarMic()
    _vc_downloadIcons()

    task.wait(0.5)
    local adi = _vc_getADI()
    if adi and _vc_unmutedIcon and _vc_mutedIcon then
        _vc_applyIconState(adi.Muted == true)
    end

    
    local _vcLastSync, _vcInSync = 0, false
    table.insert(_vc_connections, RunService.Heartbeat:Connect(function()
        if _vcInSync then return end
        local now = tick()
        if now - _vcLastSync >= 0.1 then
            _vcLastSync = now
            _vcInSync = true
            pcall(_vc_syncMuteState)
            _vcInSync = false
        end
    end))

    
    table.insert(_vc_connections, task.spawn(function()
        while _vc_active do
            pcall(_vc_manageConnections)
            task.wait(3)
        end
    end))

    
    task.spawn(function()
        task.wait(1)
        pcall(_vc_hideOriginalTopBarMic)
        task.wait(2)
        pcall(_vc_hideOriginalTopBarMic)
    end)

    
    table.insert(_vc_connections, CoreGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            local n = child.Name:lower()
            if n:find("voicechat") or n:find("topbarmic") then
                task.delay(0.5, function() pcall(_vc_hideOriginalTopBarMic) end)
            end
        end
    end))
end


local API = {}

function API.start(notifFn)
    if _vc_active then return end
    _sendNotif = notifFn or _sendNotif
    _vc_active = true
    _vc_executeAntiVCBan()
    notify("Voice Chat", "Anti-VC Ban aktiv", 3)
end

function API.stop()
    if not _vc_active then return end
    _vc_active = false
    for _, conn in ipairs(_vc_connections) do
        pcall(function() if type(conn) ~= "thread" then conn:Disconnect() end end)
    end
    _vc_connections = {}
    pcall(function()
        if _vc_micGui and _vc_micGui.Parent then
            _vc_micGui:Destroy(); _vc_micGui = nil
        end
    end)
    notify("Voice Chat", "Anti-VC Ban deaktiviert", 2)
end

function API.toggle(notifFn)
    if _vc_active then API.stop() else API.start(notifFn) end
end

function API.isActive()
    return _vc_active
end

function API.cleanup()
    API.stop()
    runtime.cleanup()
end

if GLOBAL_ENV then
    GLOBAL_ENV.__TL_AntiVCBAN = API
end

return API
