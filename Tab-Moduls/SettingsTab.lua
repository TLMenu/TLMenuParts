--!nocheck
-- Standalone Module: SettingsTab
-- Extracted from TLMenu.lua

local SettingsTab = {}

function SettingsTab.Init(ctx)
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

                local p, c           = makePanel("Settings", C.sub)
                local settingsPage         = p 
                local _settingsPanel       = p 
                local _settingsScroll      = c 
                
                local SET_HDR_H            = 58 
                local SET_BASE_H           = SET_HDR_H + 80 + 16 
                local SET_MAX_H            = 490 
                p.Size               = UDim2.new(0, PANEL_W, 0, SET_BASE_H)
                c.Size               = UDim2.new(1, -12, 1, -SET_HDR_H)
                c.ScrollBarThickness = 0 
                c.ScrollingEnabled   = true
                c.CanvasSize         = UDim2.new(0, 0, 0, 0)
                
                do
                    local _ok2, _vp2 = pcall(function() return workspace.CurrentCamera.ViewportSize end)
                    local _touch     = pcall(function() return _SvcUIS.TouchEnabled end)
                        and _SvcUIS.TouchEnabled
                    local _kb        = pcall(function() return _SvcUIS.KeyboardEnabled end)
                        and _SvcUIS.KeyboardEnabled
                    
                    _                = _touch; _ = _kb
                end
                local CATS                           = {
                    { id = "General", icon = "⚙", img = "rbxassetid://117318347375651", col = Color3.fromRGB(160, 80, 255), iconSize = 28 },
                    { id = "Keybinds", icon = "⌨", img = "rbxassetid://77626648521931", col = Color3.fromRGB(160, 80, 255), iconSize = 28 },
                    { id = "Colors", icon = "🎨", img = "rbxassetid://82124356614946", col = Color3.fromRGB(160, 80, 255), iconSize = 28 },
                    { id = "Theme", icon = "🎭", img = "rbxassetid://101141137166858", col = Color3.fromRGB(160, 80, 255), iconSize = 28 },
                    { id = "C-CURSOR", icon = "👁", img = "rbxassetid://136959112324947", col = Color3.fromRGB(160, 80, 255), iconSize = 35 },
                    { id = "Music", icon = "🎵", img = "rbxassetid://120388484536699", col = Color3.fromRGB(160, 80, 255), iconSize = 28 },
                    { id = "Nametag", icon = "🏷", img = "rbxassetid://117318347375651", col = Color3.fromRGB(160, 80, 255), iconSize = 28 },
                }
                local CARD_GAP                       = 6
                local _CATS_COUNT                    = #CATS
                local _totalGridW              = PANEL_W - 32
                local _allGaps                 = CARD_GAP * (_CATS_COUNT - 1)
                local CARD_W_S                       = math.floor((_totalGridW - _allGaps) / _CATS_COUNT)
                local _GRID_USED_W                   = _CATS_COUNT * CARD_W_S + _allGaps
                local CARD_H_S                       = 80
                local catBtns                        = {}
                local subPages                       = {}
                local activeCat                      = nil
                local grid                           = Instance.new("Frame", c)
                grid.Size                      = UDim2.new(0, _GRID_USED_W, 0, CARD_H_S)
                grid.Position                  = UDim2.new(0.5, -math.floor(_GRID_USED_W / 2), 0, 0)
                grid.BackgroundTransparency    = 1
                grid.BorderSizePixel           = 0
                local subArea                        = Instance.new("Frame", c)
                subArea.Size                   = UDim2.new(1, 0, 0, 0)
                subArea.Position               = UDim2.new(0, 0, 0, CARD_H_S + 12)
                subArea.BackgroundTransparency = 1
                subArea.BorderSizePixel        = 0
                subArea.ClipsDescendants       = false
                local function subRow(parent, yPos, label, badge, badgeCol, initOn, cb)
                    local row, setFn = cleanRow(parent, yPos, label, badge, badgeCol, initOn, cb)
                    return row, setFn
                end
                local settingToggleSetters = {}
                local genPage
                local _ok_genPage = pcall(function()
                    genPage = Instance.new("Frame", subArea)
                    genPage.BackgroundTransparency = 1; genPage.BorderSizePixel = 0
                    genPage.Visible = false
                    local _, notifSet = subRow(genPage, 0, T.settings_notif, T.settings_notif_badge, C.accent,
                        settingsState.notifications, function(on)
                        settingsState.notifications = on
                        task.spawn(saveData)
                    end)
                    settingToggleSetters["notifications"] = notifSet
                    local _, autoSet = subRow(genPage, 54, T.settings_auto, T.settings_auto_badge, C.accent2,
                        settingsState.autoOpen, function(on)
                        settingsState.autoOpen = on
                        setupAutoReinject(on)
                        task.spawn(saveData)
                    end)
                    settingToggleSetters["autoOpen"] = autoSet
                    local _, menuSoundsSet = subRow(genPage, 108, T.settings_menusounds, T.settings_menusounds_badge,
                        C.accent, settingsState.menuSounds, function(on)
                        settingsState.menuSounds = on
                        task.spawn(saveData)
                    end)
                    settingToggleSetters["menuSounds"] = menuSoundsSet

                    
                    do
                        local POS_Y = 162
                        local POS_H = 46
                        local _posCard = Instance.new("Frame", genPage)
                        _posCard.Size = UDim2.new(1, 0, 0, POS_H)
                        _posCard.Position = UDim2.new(0, 0, 0, POS_Y)
                        _posCard.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28)
                        _posCard.BackgroundTransparency = 0
                        _posCard.BorderSizePixel = 0
                        corner(_posCard, 12)
                        local _posStroke = _makeDummyStroke(_posCard); _posStroke.Thickness = 1; _posStroke.Color = C.bg3; _posStroke.Transparency = 0.3

                        local _posNameLbl = Instance.new("TextLabel", _posCard)
                        _posNameLbl.Size = UDim2.new(0.5, 0, 0, 18)
                        _posNameLbl.Position = UDim2.new(0, 14, 0, 8)
                        _posNameLbl.BackgroundTransparency = 1
                        _posNameLbl.Text = "GUI Position"
                        _posNameLbl.Font = Enum.Font.GothamBold
                        _posNameLbl.TextSize = 13
                        _posNameLbl.TextColor3 = C.text
                        _posNameLbl.TextXAlignment = Enum.TextXAlignment.Left

                        local _posSubLbl = Instance.new("TextLabel", _posCard)
                        _posSubLbl.Size = UDim2.new(0.5, 0, 0, 13)
                        _posSubLbl.Position = UDim2.new(0, 14, 0, 26)
                        _posSubLbl.BackgroundTransparency = 1
                        _posSubLbl.Text = "panel alignment"
                        _posSubLbl.Font = Enum.Font.GothamBold
                        _posSubLbl.TextSize = 9
                        _posSubLbl.TextColor3 = C.sub
                        _posSubLbl.TextXAlignment = Enum.TextXAlignment.Left

                        local _posLabels = { [0] = "Left", "Center", "Right" }
                        local _posBtns = {}
                        local _currentPos = settingsState.guiPosition or 1

                        local function applyGuiPosition(pos)
                            settingsState.guiPosition = pos
                            task.spawn(saveData)
                            for i, btn in pairs(_posBtns) do
                                if i == pos then
                                    btn.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                                    btn.TextColor3 = Color3.new(1, 1, 1)
                                else
                                    btn.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38)
                                    btn.TextColor3 = C.sub
                                end
                            end
                            
                            task.defer(function()
                                if _TL_refs._TL_applyGuiPosition then
                                    pcall(function() _TL_refs._TL_applyGuiPosition(pos) end)
                                end
                            end)
                        end

                        for i = 0, 2 do
                            local btn = Instance.new("TextButton", _posCard)
                            btn.Size = UDim2.new(0, 60, 0, 22)
                            btn.Position = UDim2.new(1, -210 + (i) * 66, 0.5, -11)
                            btn.BackgroundColor3 = i == _currentPos and C.accent or C.bg3
                            btn.Text = _posLabels[i]
                            btn.Font = Enum.Font.GothamBold
                            btn.TextSize = 10
                            btn.TextColor3 = i == _currentPos and Color3.new(1, 1, 1) or C.sub
                            btn.BorderSizePixel = 0
                            corner(btn, 8)
                            _posBtns[i] = btn
                            btn.MouseButton1Click:Connect(function()
                                applyGuiPosition(i)
                            end)
                        end

                        _panelColorHooks[#_panelColorHooks + 1] = function()
                            pcall(function()
                                _posCard.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28)
                                _posNameLbl.TextColor3 = C.text
                                _posSubLbl.TextColor3 = C.sub
                                for i, btn in pairs(_posBtns) do
                                    if i == settingsState.guiPosition then
                                        btn.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                                    else
                                        btn.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38)
                                    end
                                    btn.TextColor3 = i == settingsState.guiPosition and Color3.new(1, 1, 1) or C.sub
                                end
                            end)
                        end
                    end

                    
                    do
                        local SLIDER_Y = 212
                        local SLIDER_H = 80
                        local _gsCard = Instance.new("Frame", genPage)
                        _gsCard.Size = UDim2.new(1, 0, 0, SLIDER_H)
                        _gsCard.Position = UDim2.new(0, 0, 0, SLIDER_Y)
                        _gsCard.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28)
                        _gsCard.BackgroundTransparency = 0
                        _gsCard.BorderSizePixel = 0
                        corner(_gsCard, 12)
                        local _gsStroke = _makeDummyStroke(_gsCard); _gsStroke.Thickness = 1; _gsStroke.Color = C.bg3; _gsStroke.Transparency = 0.3

                        local _gsNameLbl = Instance.new("TextLabel", _gsCard)
                        _gsNameLbl.Size = UDim2.new(0.5, 0, 0, 18)
                        _gsNameLbl.Position = UDim2.new(0, 14, 0, 8)
                        _gsNameLbl.BackgroundTransparency = 1
                        _gsNameLbl.Text = "GUI Size"
                        _gsNameLbl.Font = Enum.Font.GothamBold
                        _gsNameLbl.TextSize = 13
                        _gsNameLbl.TextColor3 = C.text
                        _gsNameLbl.TextXAlignment = Enum.TextXAlignment.Left

                        local _gsSubLbl = Instance.new("TextLabel", _gsCard)
                        _gsSubLbl.Size = UDim2.new(0.5, 0, 0, 13)
                        _gsSubLbl.Position = UDim2.new(0, 14, 0, 26)
                        _gsSubLbl.BackgroundTransparency = 1
                        _gsSubLbl.Text = "scale (0 = auto)"
                        _gsSubLbl.Font = Enum.Font.GothamBold
                        _gsSubLbl.TextSize = 9
                        _gsSubLbl.TextColor3 = C.sub
                        _gsSubLbl.TextXAlignment = Enum.TextXAlignment.Left

                        local _gsValLbl = Instance.new("TextLabel", _gsCard)
                        _gsValLbl.Size = UDim2.new(0, 52, 0, 18)
                        _gsValLbl.Position = UDim2.new(1, -64, 0, 8)
                        _gsValLbl.BackgroundTransparency = 1
                        _gsValLbl.Font = Enum.Font.GothamBlack
                        _gsValLbl.TextSize = 13
                        _gsValLbl.TextColor3 = C.accent
                        _gsValLbl.TextXAlignment = Enum.TextXAlignment.Right

                        local _gsTrack = Instance.new("Frame", _gsCard)
                        _gsTrack.Size = UDim2.new(1, -28, 0, 4)
                        _gsTrack.Position = UDim2.new(0, 14, 0, 46)
                        _gsTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38)
                        _gsTrack.BackgroundTransparency = 0.2
                        _gsTrack.BorderSizePixel = 0
                        corner(_gsTrack, 99)

                        local _gsFill = Instance.new("Frame", _gsTrack)
                        _gsFill.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                        _gsFill.BackgroundTransparency = 0
                        _gsFill.BorderSizePixel = 0
                        corner(_gsFill, 99)

                        local _gsKnob = Instance.new("Frame", _gsTrack)
                        _gsKnob.Size = UDim2.new(0, 12, 0, 12)
                        _gsKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                        _gsKnob.BackgroundTransparency = 0
                        _gsKnob.BorderSizePixel = 0
                        _gsKnob.ZIndex = 5
                        corner(_gsKnob, 99)
                        local _gsKnobStr = _makeDummyStroke(_gsKnob); _gsKnobStr.Thickness = 1.5; _gsKnobStr.Color = C.accent; _gsKnobStr.Transparency = 0

                        
                        local _gsApplyBtn = Instance.new("TextButton", _gsCard)
                        _gsApplyBtn.Size = UDim2.new(0, 56, 0, 20)
                        _gsApplyBtn.Position = UDim2.new(1, -68, 0, 55)
                        _gsApplyBtn.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                        _gsApplyBtn.Text = "Apply"
                        _gsApplyBtn.Font = Enum.Font.GothamBold
                        _gsApplyBtn.TextSize = 11
                        _gsApplyBtn.TextColor3 = Color3.new(1, 1, 1)
                        _gsApplyBtn.BorderSizePixel = 0
                        _gsApplyBtn.Visible = false
                        corner(_gsApplyBtn, 6)

                        local _gsResetBtn = Instance.new("TextButton", _gsCard)
                        _gsResetBtn.Size = UDim2.new(0, 56, 0, 20)
                        _gsResetBtn.Position = UDim2.new(1, -130, 0, 55)
                        _gsResetBtn.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38)
                        _gsResetBtn.Text = "Reset"
                        _gsResetBtn.Font = Enum.Font.GothamBold
                        _gsResetBtn.TextSize = 11
                        _gsResetBtn.TextColor3 = C.text
                        _gsResetBtn.BorderSizePixel = 0
                        _gsResetBtn.Visible = false
                        corner(_gsResetBtn, 6)

                        
                        local GS_MIN = 0.55
                        local GS_MAX = 1.15
                        local _gsSavedScale = settingsState.guiScale or 0
                        local _gsCurrentScale = _gsSavedScale
                        local _gsResetTimer = nil

                        local function gsApplyRatio(r)
                            r = math.clamp(r, 0, 1)
                            local v = GS_MIN + r * (GS_MAX - GS_MIN)
                            _gsFill.Size = UDim2.new(r, 0, 1, 0)
                            _gsKnob.Position = UDim2.new(r, -6, 0.5, -6)
                            _gsCurrentScale = v
                            if v == 0 then
                                _gsValLbl.Text = "AUTO"
                            else
                                _gsValLbl.Text = string.format("%d%%", math.floor(v * 100 + 0.5))
                            end
                            
                            if _TL_GUIScale then
                                if v == 0 then
                                    local vp = workspace.CurrentCamera.ViewportSize
                                    _TL_GUIScale.Scale = math.clamp(math.min(vp.X / 1920, vp.Y / 1080), 0.55, 1.15)
                                else
                                    _TL_GUIScale.Scale = v
                                end
                            end
                        end

                        
                        local function gsInitRatio()
                            if _gsCurrentScale == 0 then
                                local vp = workspace.CurrentCamera.ViewportSize
                                _gsCurrentScale = math.clamp(math.min(vp.X / 1920, vp.Y / 1080), 0.55, 1.15)
                                _gsValLbl.Text = "AUTO"
                                return 0
                            else
                                _gsValLbl.Text = string.format("%d%%", math.floor(_gsCurrentScale * 100 + 0.5))
                                return (_gsCurrentScale - GS_MIN) / (GS_MAX - GS_MIN)
                            end
                        end
                        gsApplyRatio(gsInitRatio())

                        
                        local _gsDragging = false
                        local _gsBtn = Instance.new("TextButton", _gsTrack)
                        _gsBtn.Size = UDim2.new(1, 12, 1, 12)
                        _gsBtn.Position = UDim2.new(0, -6, 0, -4)
                        _gsBtn.BackgroundTransparency = 1
                        _gsBtn.Text = ""
                        _gsBtn.ZIndex = 6

                        local function startResetTimer()
                            if _gsResetTimer then task.cancel(_gsResetTimer) end
                            _gsApplyBtn.Visible = true
                            _gsResetBtn.Visible = true
                            _gsResetTimer = task.delay(5, function()
                                _gsApplyBtn.Visible = false
                                _gsResetBtn.Visible = false
                                
                                _gsCurrentScale = _gsSavedScale
                                if _TL_GUIScale then
                                    if _gsSavedScale == 0 then
                                        local vp = workspace.CurrentCamera.ViewportSize
                                        _TL_GUIScale.Scale = math.clamp(math.min(vp.X / 1920, vp.Y / 1080), 0.55, 1.15)
                                    else
                                        _TL_GUIScale.Scale = _gsSavedScale
                                    end
                                end
                                
                                gsApplyRatio(gsInitRatio())
                            end)
                        end

                        _gsBtn.MouseButton1Down:Connect(function(x)
                            _gsDragging = true
                            gsApplyRatio((x - _gsTrack.AbsolutePosition.X) / _gsTrack.AbsoluteSize.X)
                        end)
                        _gsBtn.MouseMoved:Connect(function(x)
                            if _gsDragging then
                                gsApplyRatio((x - _gsTrack.AbsolutePosition.X) / _gsTrack.AbsoluteSize.X)
                            end
                        end)
                        _gsBtn.MouseButton1Up:Connect(function()
                            if _gsDragging then
                                _gsDragging = false
                                startResetTimer()
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if _gsDragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
                                _gsDragging = false
                                startResetTimer()
                            end
                        end)

                        _gsApplyBtn.MouseButton1Click:Connect(function()
                            _gsSavedScale = _gsCurrentScale
                            settingsState.guiScale = _gsCurrentScale
                            task.spawn(saveData)
                            _gsApplyBtn.Visible = false
                            _gsResetBtn.Visible = false
                            if _gsResetTimer then task.cancel(_gsResetTimer); _gsResetTimer = nil end
                        end)

                        _gsResetBtn.MouseButton1Click:Connect(function()
                            _gsCurrentScale = _gsSavedScale
                            if _TL_GUIScale then
                                if _gsSavedScale == 0 then
                                    local vp = workspace.CurrentCamera.ViewportSize
                                    _TL_GUIScale.Scale = math.clamp(math.min(vp.X / 1920, vp.Y / 1080), 0.55, 1.15)
                                else
                                    _TL_GUIScale.Scale = _gsSavedScale
                                end
                            end
                            gsApplyRatio(gsInitRatio())
                            _gsApplyBtn.Visible = false
                            _gsResetBtn.Visible = false
                            if _gsResetTimer then task.cancel(_gsResetTimer); _gsResetTimer = nil end
                        end)

                        
                        _panelColorHooks[#_panelColorHooks + 1] = function()
                            pcall(function()
                                _gsCard.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28)
                                _gsNameLbl.TextColor3 = C.text
                                _gsSubLbl.TextColor3 = C.sub
                                _gsValLbl.TextColor3 = C.accent
                                _gsFill.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                                _gsKnobStr.Color = C.accent
                                _gsTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38)
                                _gsApplyBtn.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                                _gsResetBtn.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38)
                                _gsResetBtn.TextColor3 = C.text
                            end)
                        end
                    end

                    settingToggleSetters["antiVcBan"] = function(val)
                        if val and _G._TL_vcSetToggle then
                            _G._TL_vcSetToggle(true)
                            settingsState.antiVcBan = true
                        end
                    end
                    _G.settingToggleSetters = settingToggleSetters
                    genPage.Size = UDim2.new(1, 0, 0, 108 + 54 + 46 + 80 + 8 + 34)
                end) 
                local kbPage
                local _ok_kbPage = pcall(function()
                    kbPage = Instance.new("Frame", subArea)
                    kbPage.BackgroundTransparency = 1; kbPage.BorderSizePixel = 0
                    kbPage.Visible = false
                    local kbHint = Instance.new("TextLabel", kbPage)
                    kbHint.Size = UDim2.new(1, -16, 0, 18)
                    kbHint.Position = UDim2.new(0, 8, 0, 4)
                    kbHint.BackgroundTransparency = 1
                    kbHint.Text = T.kb_hint
                    kbHint.Font = Enum.Font.Gotham
                    kbHint.TextSize = 11
                    kbHint.TextColor3 = C.sub or _C3_SUB
                    kbHint.TextXAlignment = Enum.TextXAlignment.Left
                    local kbContainer = Instance.new("Frame", kbPage)
                    kbContainer.Size = UDim2.new(1, 0, 0, 0)
                    kbContainer.Position = UDim2.new(0, 0, 0, 26)
                    kbContainer.BackgroundTransparency = 1
                    kbContainer.BorderSizePixel = 0
                    local keybindEntries = {
                        { "Toggle SmartBar", Enum.KeyCode.K, function()
                            if tabCardsHolder and tabCardsHolder.Visible then closeBar() else openBar() end
                        end },
                        { "Toggle Fly", Enum.KeyCode.F, function()
                            local newState = not flyActive
                            if _flyPanelSetFn then
                                pcall(_flyPanelSetFn, newState)
                            else
                                flyActive = newState
                                setFly(newState)
                            end
                        end },
                        { "Toggle Noclip", nil, function()
                            noclipActive = not noclipActive
                            setNoclip(noclipActive)
                        end },
                        { "Toggle ESP", nil, function()
                            local anyActive = espMod and espMod.isActive() or false
                            if anyActive then setESP(false) else setESP(true) end
                        end },
                        { "Toggle Invisible", nil, function()
                            invisActive = not invisActive
                            if invisActive and _G.TLActions then pcall(function() _G.TLActions.stopAll() end) end
                            setInvis(invisActive)
                        end },
                        { "Toggle Aimbot", nil, function()
                            _aim.Config.Enabled = not _aim.Config.Enabled
                            if _aim.Config.Enabled then
                                _aim.StartAimbot()
                                sendNotif("Aimbot", "Aimbot ACTIVATED - Hold RMB to aim", 3)
                            else
                                _aim.StopAimbot()
                                sendNotif("Aimbot", "Aimbot DEACTIVATED", 2)
                            end
                        end },
                    }
                    local totalKbRows = 0
                    for i, entry in ipairs(keybindEntries) do
                        local yPos = (i - 1) * 62
                        if entry[2] == "fixed" then
                            local row = Instance.new("Frame", kbContainer)
                            row.Size = UDim2.new(1, 0, 0, 52)
                            row.Position = UDim2.new(0, 0, 0, yPos)
                            row.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2
                            row.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                            1 or 0; row.BorderSizePixel = 0
                            corner(row, 14)
                            local rowStr = _makeDummyStroke(row)
                            rowStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                            1.5 or 1
                            rowStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                            Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                            rowStr.Transparency = 0.3
                            if _panelColorHooks then
                                _panelColorHooks[#_panelColorHooks + 1] = function()
                                    pcall(function()
                                        row.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                                        1 or 0
                                        rowStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                                        1.5 or 1
                                        rowStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                                        Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                                        rowStr.Transparency = 0.3
                                    end)
                                end
                            end
                            local rowDot = Instance.new("Frame", row)
                            rowDot.Size = UDim2.new(0, 4, 0, 28); rowDot.Visible = false; rowDot.Position = UDim2.new(0,
                                0, 0.5, -14)
                            rowDot.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255) or C.accent2; rowDot.BackgroundTransparency = 0.3
                            rowDot.BorderSizePixel = 0; corner(rowDot, 99)
                            local lbl = Instance.new("TextLabel", row)
                            lbl.Size = UDim2.new(0, 160, 1, 0)
                            lbl.Position = UDim2.new(0, 16, 0, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = entry[1]
                            lbl.Font = Enum.Font.GothamBold
                            lbl.TextSize = 14
                            lbl.TextColor3 = C.text
                            lbl.TextXAlignment = Enum.TextXAlignment.Left
                            local descLbl = Instance.new("TextLabel", row)
                            descLbl.Size = UDim2.new(0, 100, 1, 0)
                            descLbl.Position = UDim2.new(0, 176, 0, 0)
                            descLbl.BackgroundTransparency = 1
                            descLbl.Text = "Cannot be changed"
                            descLbl.Font = Enum.Font.Gotham
                            descLbl.TextSize = 11
                            descLbl.TextColor3 = C.sub or _C3_SUB
                            descLbl.TextXAlignment = Enum.TextXAlignment.Left
                            local keyCard = Instance.new("Frame", row)
                            keyCard.Size = UDim2.new(0, 90, 0, 36)
                            keyCard.Position = UDim2.new(1, -100, 0.5, -18)
                            keyCard.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3
                            keyCard.BackgroundTransparency = 0.3
                            keyCard.BorderSizePixel = 0
                            corner(keyCard, 10)
                            local keyCardStroke = _makeDummyStroke(keyCard)
                            keyCardStroke.Thickness = 1.5; keyCardStroke.Color = C.accent2 or C.accent; keyCardStroke.Transparency = 0.7
                            local keyIcon = Instance.new("TextLabel", keyCard)
                            keyIcon.Size = UDim2.new(0, 20, 0, 20)
                            keyIcon.Position = UDim2.new(0, 6, 0.5, -10)
                            keyIcon.BackgroundTransparency = 1
                            keyIcon.Text = "🔑"
                            keyIcon.Font = Enum.Font.GothamBold
                            keyIcon.TextSize = 16
                            keyIcon.TextColor3 = C.accent2 or C.accent
                            keyIcon.TextXAlignment = Enum.TextXAlignment.Center
                            local function keyName(kc)
                                if kc == nil then return "None" end
                                local n = tostring(kc):gsub("Enum.KeyCode.", "")
                                return n
                            end
                            local kl = Instance.new("TextLabel", keyCard)
                            kl.Size = UDim2.new(1, -26, 1, 0)
                            kl.Position = UDim2.new(0, 26, 0, 0)
                            kl.BackgroundTransparency = 1
                            kl.Text = keyName(entry[2])
                            kl.Font = Enum.Font.GothamBold
                            kl.TextSize = 14
                            kl.TextColor3 = C.text
                            kl.TextXAlignment = Enum.TextXAlignment.Center
                            keybindLabelUpdaters[entry[1]] = function(kc)
                                pcall(function() kl.Text = keyName(kc) end)
                            end
                        else
                            makeKeybindWidget(kbContainer, yPos, entry[1], entry[2], entry[3])
                        end
                        totalKbRows = totalKbRows + 1
                    end
                    kbContainer.Size = UDim2.new(1, 0, 0, totalKbRows * 62)
                    kbPage.Size = UDim2.new(1, 0, 0, 26 + totalKbRows * 62 + 8)
                end) 

                
                local colorsPage
                local _ok_colorsPage = pcall(function()
                    colorsPage = Instance.new("Frame", subArea)
                    colorsPage.BackgroundTransparency = 1; colorsPage.BorderSizePixel = 0
                    colorsPage.Visible = false
                    do
                        local cpY                    = 0
                        local cpLbl                  = Instance.new("TextLabel", colorsPage)
                        cpLbl.Size                   = UDim2.new(1, -16, 0, 18); cpLbl.Position = UDim2.new(0, 8, 0, cpY)
                        cpLbl.BackgroundTransparency = 1; cpLbl.Text = "GUI COLOR THEME"
                        cpLbl.Font                   = Enum.Font.GothamBold; cpLbl.TextSize = 12
                        cpLbl.TextColor3             = C.sub; cpLbl.TextXAlignment = Enum.TextXAlignment.Left
                        cpY                          = cpY + 26
                        local CHIP_W                 = math.floor((PANEL_W - 48) / 3)
                        local CHIP_H                 = 52
                        local CHIP_GAP               = 8
                        local _themeChipBtns         = {}
                        
                        local CHIP_BG_INACTIVE       = Color3.fromRGB(0, 0, 0) 
                        local CHIP_BG_ACTIVE         = Color3.fromRGB(5, 5, 5)
                        local function updateThemeChips(activeId)
                            local isCustomThemeActive = _TL_isAnimeTheme(activeId)
                            for _, ch in ipairs(_themeChipBtns) do
                                local isActive = (ch.id == activeId) and not isCustomThemeActive
                                ch.card.BackgroundColor3 = isActive and CHIP_BG_ACTIVE or CHIP_BG_INACTIVE
                                ch.card.BackgroundTransparency = isCustomThemeActive and 0.6 or
                                (isActive and 0.15 or 0.25)
                                ch.str.Transparency = isActive and 0.2 or 0.8
                                ch.str.Color = ch.col or C.accent
                                if ch.dot then
                                    ch.dot.BackgroundColor3 = ch.col
                                    ch.dot.BackgroundTransparency = isCustomThemeActive and 0.6 or 0
                                end
                                if ch.tlbl then
                                    ch.tlbl.TextColor3 = ch.col
                                    ch.tlbl.TextTransparency = isCustomThemeActive and 0.6 or 0
                                end
                                
                                if ch.btn then
                                    ch.btn.Active = not isCustomThemeActive
                                    ch.btn.AutoButtonColor = not isCustomThemeActive
                                end
                            end
                        end
                        local colIdx = 0
                        for _, theme in ipairs(_TL_THEMES) do
                            if not _TL_isAnimeTheme(theme.id) then
                                local row                   = math.floor(colIdx / 3)
                                local c2                    = colIdx % 3
                                local cx                    = 16 + c2 * (CHIP_W + CHIP_GAP)
                                local cy                    = cpY + row * (CHIP_H + CHIP_GAP)
                                local card                  = Instance.new("Frame", colorsPage)
                                card.Size                   = UDim2.new(0, CHIP_W, 0, CHIP_H)
                                card.Position               = UDim2.new(0, cx, 0, cy)
                                card.BackgroundColor3       = CHIP_BG_INACTIVE; card.BackgroundTransparency = 0
                                card.BorderSizePixel        = 0; corner(card, 10)
                                local cStr2 = _makeDummyStroke(card)
                                cStr2.Thickness = 1.5; cStr2.Color = theme.accent; cStr2.Transparency = 0.6
                                cStr2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                                
                                local dot = Instance.new("Frame", card)
                                dot.Size = UDim2.new(0, 16, 0, 16); dot.Position = UDim2.new(0.5, -8, 0, 8)
                                dot.BackgroundColor3 = theme.accent; dot.BackgroundTransparency = 0
                                dot.BorderSizePixel = 0; corner(dot, 99)
                                local tlbl = Instance.new("TextLabel", card)
                                tlbl.Size = UDim2.new(1, -4, 0, 14); tlbl.Position = UDim2.new(0, 2, 1, -18)
                                tlbl.BackgroundTransparency = 1; tlbl.Text = theme.name:upper()
                                tlbl.Font = Enum.Font.GothamBold; tlbl.TextSize = 9
                                tlbl.TextColor3 = theme.accent; tlbl.TextXAlignment = Enum.TextXAlignment.Center
                                local themeBtn = Instance.new("TextButton", card)
                                themeBtn.Size = UDim2.new(1, 0, 1, 0); themeBtn.BackgroundTransparency = 1
                                themeBtn.Text = ""; themeBtn.ZIndex = 8
                                local captId = theme.id
                                themeBtn.MouseButton1Click:Connect(function()
                                    if _TL_isImgTheme(_TL_activeThemeId) then return end
                                    _TL_applyTheme(captId)
                                    task.defer(function()
                                        updateThemeChips(captId)
                                    end)
                                end)
                                themeBtn.MouseEnter:Connect(function()
                                    if _TL_isImgTheme(_TL_activeThemeId) then return end
                                    _sc._playHoverSound()
                                    twP(card, 0.1, { BackgroundColor3 = CHIP_BG_ACTIVE })
                                end)
                                themeBtn.MouseLeave:Connect(function()
                                    if _TL_isImgTheme(_TL_activeThemeId) then return end
                                    if _TL_activeThemeId ~= captId then
                                        twP(card, 0.1, { BackgroundColor3 = CHIP_BG_INACTIVE })
                                    end
                                end)
                                table.insert(_themeChipBtns,
                                    { id = theme.id, card = card, str = cStr2, col = theme.accent, dot = dot, tlbl = tlbl, btn =
                                    themeBtn })
                                colIdx = colIdx + 1
                            end
                        end
                        local rows = math.ceil(colIdx / 3)
                        cpY = cpY + rows * (CHIP_H + CHIP_GAP) + 8
                        colorsPage.Size = UDim2.new(1, 0, 0, cpY)
                        updateThemeChips(_TL_activeThemeId)
                        
                        task.defer(function()
                            pcall(function() updateThemeChips(_TL_activeThemeId) end)
                        end)

                        
                        local env = _genv
                        pcall(function()
                            env._TL_FixThemeChips = function(themeId)
                                task.defer(function()
                                    pcall(function() updateThemeChips(themeId or _TL_activeThemeId) end)
                                end)
                            end
                        end)

                        
                                                table.insert(_panelColorHooks, function(newT)
                            pcall(function()
                                if p and p.Parent then p.BackgroundColor3 = newT.panelBg or C.panelBg end
                            end)
                        end)
                    end
                end) 

                
                
                
                
                local function _VCOL() return C.accent end
                local visualSettingsPage
                local _ok_visualPage = pcall(function()
                    visualSettingsPage                        = Instance.new("Frame", subArea)
                    visualSettingsPage.BackgroundTransparency = 1; visualSettingsPage.BorderSizePixel = 0
                    visualSettingsPage.Visible                = false

                    local _curMod = _TL_loadModule("C-CURSOR")
                    if _curMod then
                        _curMod.init({
                            _SvcUIS = _SvcUIS,
                            _SvcRS = _SvcRS,
                            _tryParentGui = _tryParentGui,
                            corner = corner,
                            _makeDummyStroke = _makeDummyStroke,
                            _sc = _sc,
                            C = C,
                            _panelColorHooks = _panelColorHooks,
                            _isMobile = _isMobile,
                            _isTablet = _isTablet,
                            LocalPlayer = LocalPlayer,
                            _C3_WHITE = _C3_WHITE,
                            PANEL_W = PANEL_W,
                        })
                        _panelColorHooks[#_panelColorHooks + 1] = function()
                            _curMod.applyTheme()
                        end
                        _curMod.buildSettingsUI(visualSettingsPage, { twP = twP })
                    end
                end) 

                task.wait(0.05)
                            
            
            
local themePage = Instance.new("Frame", subArea)
                themePage.Size = UDim2.new(1, 0, 0, 218)
                themePage.BackgroundTransparency = 1; themePage.Visible = false

                local themeList = Instance.new("UIListLayout", themePage)
                themeList.SortOrder = Enum.SortOrder.LayoutOrder
                themeList.Padding = UDim.new(0, 6)

                local themePad = Instance.new("UIPadding", themePage)
                themePad.PaddingTop = UDim.new(0, 8)
                themePad.PaddingBottom = UDim.new(0, 8)
                themePad.PaddingLeft = UDim.new(0, 8)
                themePad.PaddingRight = UDim.new(0, 8)

                local cardsData = {
                    { name = "Anime",  order = 1 },
                    { name = "Movies", order = 2 },
                    { name = "Series", order = 3 },
                    { name = "Music",  order = 4 },
                    { name = "Custom", order = 5 }
                }

                local cards = {}

                local function recalculateThemeSizes()
                    local totalH = 16 
                    for i, cData in ipairs(cardsData) do
                        local cardObj = cards[cData.name]
                        if cardObj then
                            local cardH = cardObj.IsOpen() and (cardObj.TargetHeight or 160) or 46
                            totalH = totalH + cardH
                        end
                    end
                    totalH = totalH + (#cardsData - 1) * 6 

                    twP(themePage, 0.25, { Size = UDim2.new(1, 0, 0, totalH) }, Enum.EasingStyle.Quart,
                        Enum.EasingDirection.Out)

                    if activeCat == "Theme" then
                        local newPH = math.min(SET_BASE_H + totalH + 8, SET_MAX_H)
                        twP(subArea, 0.25, { Size = UDim2.new(1, 0, 0, totalH) }, Enum.EasingStyle.Quart,
                            Enum.EasingDirection.Out)
                        twP(p, 0.25, { Size = UDim2.new(0, PANEL_W, 0, newPH) }, Enum.EasingStyle.Quart,
                            Enum.EasingDirection.Out)
                        
                        task.delay(0.27, function()
                            pcall(function()
                                local canvasTotal = (CARD_H_S + 12) + totalH + 8
                                local scrollH = newPH - SET_HDR_H
                                c.CanvasSize = UDim2.new(0, 0, 0, math.max(canvasTotal, scrollH))
                            end)
                        end)
                    end
                end

                local function createCollapsibleCard(parent, titleText, layoutOrder, heightWhenExpanded)
                    local card = Instance.new("Frame", parent)
                    card.Size = UDim2.new(1, 0, 0, 46)
                    card.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or Color3.fromRGB(20, 20, 20)
                    card.BackgroundTransparency = 0
                    card.BorderSizePixel = 0
                    card.ClipsDescendants = true
                    card.LayoutOrder = layoutOrder
                    corner(card, 12)

                    local cStr = _makeDummyStroke(card)
                    cStr.Thickness = 1
                    cStr.Color = C.bg3 or Color3.fromRGB(28, 28, 28)
                    cStr.Transparency = 0.3

                    
                    local header = Instance.new("Frame", card)
                    header.Size = UDim2.new(1, 0, 0, 46)
                    header.BackgroundTransparency = 1
                    header.BorderSizePixel = 0

                    
                    local title = Instance.new("TextLabel", header)
                    title.Size = UDim2.new(1, -60, 1, 0)
                    title.Position = UDim2.new(0, 14, 0, 0)
                    title.BackgroundTransparency = 1
                    title.Text = titleText
                    title.Font = Enum.Font.GothamBold
                    title.TextSize = 13
                    title.TextColor3 = C.text or Color3.fromRGB(210, 235, 255)
                    title.TextXAlignment = Enum.TextXAlignment.Left

                    
                    local arrow = Instance.new("TextLabel", header)
                    arrow.Size = UDim2.new(0, 32, 0, 32)
                    arrow.Position = UDim2.new(1, -46, 0.5, -16)
                    arrow.BackgroundTransparency = 1
                    arrow.Text = "▼"
                    arrow.TextColor3 = C.sub or Color3.fromRGB(0, 135, 195)
                    arrow.Font = Enum.Font.GothamBold
                    arrow.TextSize = 10
                    arrow.TextXAlignment = Enum.TextXAlignment.Center

                    
                    local content = Instance.new("Frame", card)
                    content.Size = UDim2.new(1, -28, 0, heightWhenExpanded - 46 - 8)
                    content.Position = UDim2.new(0, 14, 0, 46)
                    content.BackgroundTransparency = 1
                    content.BorderSizePixel = 0
                    content.ClipsDescendants = true

                    
                    if titleText ~= "Anime" and titleText ~= "Series" then
                        local placeholder = Instance.new("TextLabel", content)
                        placeholder.Size = UDim2.new(1, 0, 1, 0)
                        placeholder.BackgroundTransparency = 1
                        placeholder.Text = titleText .. " content coming soon..."
                        placeholder.Font = Enum.Font.Gotham
                        placeholder.TextSize = 11
                        placeholder.TextColor3 = C.sub or Color3.fromRGB(0, 135, 195)
                        placeholder.TextXAlignment = Enum.TextXAlignment.Center
                        placeholder.TextYAlignment = Enum.TextYAlignment.Center
                    end

                    
                    local toggleBtn = Instance.new("TextButton", header)
                    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
                    toggleBtn.BackgroundTransparency = 1
                    toggleBtn.Text = ""
                    toggleBtn.ZIndex = 6

                    local isOpen = false

                    local function toggle()
                        isOpen = not isOpen

                        
                        pcall(function()
                            if _sc and _sc._playHoverSound then
                                _sc._playHoverSound()
                            end
                        end)

                        
                        local targetH = isOpen and heightWhenExpanded or 46
                        twP(card, 0.25, { Size = UDim2.new(1, 0, 0, targetH) }, Enum.EasingStyle.Quart,
                            Enum.EasingDirection.Out)

                        
                        local targetRot = isOpen and 180 or 0
                        twP(arrow, 0.25, { Rotation = targetRot, TextColor3 = isOpen and C.accent or C.sub },
                            Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

                        
                        local targetStrColor = isOpen and C.accent or (C.bg3 or Color3.fromRGB(28, 28, 28))
                        local targetStrTrans = isOpen and 0.5 or 0.3
                        twP(cStr, 0.25, { Color = targetStrColor, Transparency = targetStrTrans }, Enum.EasingStyle
                        .Quart, Enum.EasingDirection.Out)

                        
                        recalculateThemeSizes()
                    end

                    toggleBtn.MouseButton1Click:Connect(toggle)
                    toggleBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then
                            toggle()
                        end
                    end)

                    toggleBtn.MouseEnter:Connect(function()
                        if not isOpen then
                            twP(card, 0.15, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or Color3.fromRGB(28, 28, 28) },
                                Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                        end
                    end)
                    toggleBtn.MouseLeave:Connect(function()
                        if not isOpen then
                            twP(card, 0.15, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or Color3.fromRGB(20, 20, 20) },
                                Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                        end
                    end)

                                        _panelColorHooks[#_panelColorHooks + 1] = function()
                        pcall(function()
                            title.TextColor3 = C.text
                            if isOpen then
                                arrow.TextColor3 = C.accent
                                cStr.Color = C.accent
                            else
                                arrow.TextColor3 = C.sub
                                cStr.Color = C.bg3 or Color3.fromRGB(28, 28, 28)
                            end
                        end)
                    end

                    return { Frame = card, Content = content, Open = toggle, IsOpen = function() return isOpen end, TargetHeight =
                    heightWhenExpanded }
                end

                for _, cData in ipairs(cardsData) do
                    local expH = (cData.name == "Anime") and 214 or (cData.name == "Series" and 160 or 160)
                    cards[cData.name] = createCollapsibleCard(themePage, cData.name, cData.order, expH)
                end

                local onePieceToggleSet = nil
                local onePieceToggleVisual = nil
                local dragonballToggleSet = nil
                local dragonballToggleVisual = nil
                local theBoysToggleSet = nil
                local theBoysToggleVisual = nil
                local deathNoteToggleSet = nil
                local deathNoteToggleVisual = nil
                local dexterToggleSet = nil
                local dexterToggleVisual = nil

                local isLoadingOnePiece = false
                local isLoadingDragonball = false
                local isLoadingTheBoys = false
                local isLoadingDeathNote = false
                local isLoadingDexter = false

                local animeCard = cards["Anime"]
                if animeCard then
                    local initOn = (_TL_activeThemeId == "onepiece")
                    local row, setFn, _, setVisualFn = cleanRow(animeCard.Content, 4, "One Piece", "Straw Hat Theme",
                        C.accent, initOn, function(on)
                        pcall(function()
                            if on then
                                
                                if dragonballToggleSet then dragonballToggleSet(false) end
                                if dragonballToggleVisual then dragonballToggleVisual(false) end
                                isLoadingDragonball = false
                                if theBoysToggleSet then theBoysToggleSet(false) end
                                if theBoysToggleVisual then theBoysToggleVisual(false) end
                                isLoadingTheBoys = false
                                if deathNoteToggleSet then deathNoteToggleSet(false) end
                                if deathNoteToggleVisual then deathNoteToggleVisual(false) end
                                isLoadingDeathNote = false
                                if dexterToggleSet then dexterToggleSet(false) end
                                if dexterToggleVisual then dexterToggleVisual(false) end
                                isLoadingDexter = false
                                if _TL_activeThemeId ~= "onepiece" and not isLoadingOnePiece then
                                    isLoadingOnePiece = true
                                    
                                    local sg = _TL_refs and _TL_refs._TL_ScreenGui
                                    local playerGui = sg and sg.Parent or nil
                                    if not playerGui then
                                        pcall(function() playerGui = game:GetService("Players").LocalPlayer:WaitForChild(
                                            "PlayerGui") end)
                                    end
                                    if not playerGui then return end

                                    
                                    local loadGui = Instance.new("ScreenGui")
                                    loadGui.Name = "OnePieceLoading"
                                    loadGui.IgnoreGuiInset = true
                                    loadGui.DisplayOrder = 999999
                                    loadGui.Parent = playerGui

                                    local frame = Instance.new("Frame")
                                    frame.Size = UDim2.new(1, 0, 1, 0)
                                    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
                                    frame.BorderSizePixel = 0
                                    frame.Active = true
                                    frame.Parent = loadGui

                                    local bgGrad = Instance.new("UIGradient")
                                    bgGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 10)),
                                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 14, 8)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 10))
                                    })
                                    bgGrad.Rotation = 45
                                    bgGrad.Parent = frame

                                    local container = Instance.new("Frame")
                                    container.Size = UDim2.new(0, 450, 0, 320)
                                    container.Position = UDim2.new(0.5, -225, 0.5, -160)
                                    container.BackgroundTransparency = 1
                                    container.BorderSizePixel = 0
                                    container.Parent = frame

                                    
                                    local logo = Instance.new("ImageLabel")
                                    logo.Size = UDim2.new(0, 120, 0, 120)
                                    logo.Position = UDim2.new(0.5, -60, 0, 10)
                                    logo.BackgroundTransparency = 1
                                    logo.Image = "rbxassetid://110896600564086"
                                    logo.ScaleType = Enum.ScaleType.Fit
                                    logo.ImageTransparency = 1
                                    logo.ZIndex = 10
                                    logo.Parent = container

                                    local title = Instance.new("TextLabel")
                                    title.Size = UDim2.new(1, 0, 0, 60)
                                    title.Position = UDim2.new(0, 0, 0, 140)
                                    title.BackgroundTransparency = 1
                                    title.Text = "ONE PIECE"
                                    title.Font = Enum.Font.GothamBlack
                                    title.TextSize = 42
                                    title.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    title.TextXAlignment = Enum.TextXAlignment.Center
                                    title.TextTransparency = 1
                                    title.Parent = container

                                    local titleGrad = Instance.new("UIGradient")
                                    titleGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 40, 40))
                                    })
                                    titleGrad.Rotation = 15
                                    titleGrad.Parent = title

                                    local sub = Instance.new("TextLabel")
                                    sub.Size = UDim2.new(1, 0, 0, 20)
                                    sub.Position = UDim2.new(0, 0, 0, 200)
                                    sub.BackgroundTransparency = 1
                                    sub.Text = "SETTING SAIL..."
                                    sub.Font = Enum.Font.GothamBold
                                    sub.TextSize = 13
                                    sub.TextColor3 = Color3.fromRGB(255, 230, 180)
                                    sub.TextTransparency = 1
                                    sub.TextXAlignment = Enum.TextXAlignment.Center
                                    sub.Parent = container

                                    local track = Instance.new("Frame")
                                    track.Size = UDim2.new(0, 280, 0, 6)
                                    track.Position = UDim2.new(0.5, -140, 0, 240)
                                    track.BackgroundColor3 = Color3.fromRGB(30, 26, 22)
                                    track.BackgroundTransparency = 1
                                    track.BorderSizePixel = 0
                                    track.Parent = container
                                    local trackCorner = Instance.new("UICorner")
                                    trackCorner.CornerRadius = UDim.new(1, 0)
                                    trackCorner.Parent = track

                                    local fill = Instance.new("Frame")
                                    fill.Size = UDim2.new(0, 0, 1, 0)
                                    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                    fill.BorderSizePixel = 0
                                    fill.Parent = track
                                    local fillCorner = Instance.new("UICorner")
                                    fillCorner.CornerRadius = UDim.new(1, 0)
                                    fillCorner.Parent = fill

                                    local fillGrad = Instance.new("UIGradient")
                                    fillGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 195, 0)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 40, 40))
                                    })
                                    fillGrad.Parent = fill

                                    
                                    local TS = game:GetService("TweenService")
                                    TS:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { ImageTransparency = 0 }):Play()
                                    TS:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { TextTransparency = 0 }):Play()
                                    TS:Create(sub, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { TextTransparency = 0.2 }):Play()
                                    TS:Create(track, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { BackgroundTransparency = 0 }):Play()

                                    
                                    local fillTween = TS:Create(fill,
                                        TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                                        { Size = UDim2.new(1, 0, 1, 0) })
                                    fillTween:Play()

                                    
                                    local _opLoadSound = nil
                                    pcall(function()
                                        _opLoadSound                    = Instance.new("Sound", workspace)
                                        _opLoadSound.SoundId            = "rbxassetid://108023565417899"
                                        _opLoadSound.Volume             = 0.6
                                        _opLoadSound.RollOffMaxDistance = 10000
                                        _opLoadSound:Play()
                                    end)

                                    task.delay(1.5, function()
                                        pcall(function()
                                            _TL_applyTheme("onepiece")
                                            
                                            for _, _pn in ipairs({ "Character", "Home", "Settings", "Actions" }) do
                                                local _pp = panels[_pn]
                                                if _pp then
                                                    pcall(function()
                                                        local _db = _pp:FindFirstChild("DragonballBg")
                                                        if _db then _db:Destroy() end
                                                        local _tb = _pp:FindFirstChild("TheBoysBg")
                                                        if _tb then _tb:Destroy() end
                                                    end)
                                                end
                                            end
                                            
                                            local tabBtns = _TL_refs._TL_tabBtns
                                            if tabBtns then
                                                for _, tb in ipairs(tabBtns) do
                                                    local opIcon = _TL_refs._TL_tabOnePieceIcons[tb.name]
                                                    if opIcon and tb.iconImg then
                                                        tb.iconImg.Image = opIcon
                                                        tb.iconImg.ImageColor3 = MGDIM()
                                                    end
                                                end
                                            end
                                            
                                            local charPanel = panels["Character"]
                                            if charPanel then
                                                local bg = charPanel:FindFirstChild("OnePieceBg")
                                                if not bg then
                                                    bg = Instance.new("ImageLabel")
                                                    bg.Name = "OnePieceBg"
                                                    bg.Size = UDim2.new(1, 0, 1, 0)
                                                    bg.Position = UDim2.new(0, 0, 0, 0)
                                                    bg.BackgroundTransparency = 1
                                                    bg.Image = "rbxassetid://134051752019917"
                                                    bg.ScaleType = Enum.ScaleType.Crop
                                                    bg.ImageTransparency = 1
                                                    bg.ZIndex = 0

                                                    local c = Instance.new("UICorner")
                                                    c.CornerRadius = UDim.new(0, 12)
                                                    c.Parent = bg

                                                    bg.Parent = charPanel
                                                end
                                                TS:Create(bg,
                                                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 0.55 }):Play()
                                            end
                                            
                                            local homePanel = panels["Home"]
                                            if homePanel then
                                                local hbg = homePanel:FindFirstChild("OnePieceBg")
                                                if not hbg then
                                                    hbg = Instance.new("ImageLabel")
                                                    hbg.Name = "OnePieceBg"
                                                    hbg.Size = UDim2.new(1, 0, 1, 0)
                                                    hbg.Position = UDim2.new(0, 0, 0, 0)
                                                    hbg.BackgroundTransparency = 1
                                                    hbg.Image = "rbxassetid://85278059623649"
                                                    hbg.ScaleType = Enum.ScaleType.Crop
                                                    hbg.ImageTransparency = 1
                                                    hbg.ZIndex = 0
                                                    local hc = Instance.new("UICorner")
                                                    hc.CornerRadius = UDim.new(0, 12)
                                                    hc.Parent = hbg
                                                    hbg.Parent = homePanel
                                                end
                                                TS:Create(hbg,
                                                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 0.55 }):Play()
                                            end
                                            
                                            local settingsPanel = panels["Settings"]
                                            if settingsPanel then
                                                local sbg = settingsPanel:FindFirstChild("OnePieceBg")
                                                if not sbg then
                                                    sbg = Instance.new("ImageLabel")
                                                    sbg.Name = "OnePieceBg"
                                                    sbg.Size = UDim2.new(1, 0, 1, 0)
                                                    sbg.Position = UDim2.new(0, 0, 0, 0)
                                                    sbg.BackgroundTransparency = 1
                                                    sbg.Image = "rbxassetid://82844161252860"
                                                    sbg.ScaleType = Enum.ScaleType.Crop
                                                    sbg.ImageTransparency = 1
                                                    sbg.ZIndex = 0
                                                    local sc = Instance.new("UICorner")
                                                    sc.CornerRadius = UDim.new(0, 12)
                                                    sc.Parent = sbg
                                                    sbg.Parent = settingsPanel
                                                end
                                                TS:Create(sbg,
                                                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 0.55 }):Play()
                                            end
                                            
                                            local actionsPanel = panels["Actions"]
                                            if actionsPanel then
                                                local abg = actionsPanel:FindFirstChild("OnePieceBg")
                                                if not abg then
                                                    abg = Instance.new("ImageLabel")
                                                    abg.Name = "OnePieceBg"
                                                    abg.Size = UDim2.new(1, 0, 1, 0)
                                                    abg.Position = UDim2.new(0, 0, 0, 0)
                                                    abg.BackgroundTransparency = 1
                                                    abg.Image = _TL_safeGetCustomAsset("assets/THEMES/ONEPIECE/OP-ACT-BG.png") or "rbxassetid://132090006833323"
                                                    abg.ScaleType = Enum.ScaleType.Crop
                                                    abg.ImageTransparency = 1
                                                    abg.ZIndex = 0
                                                    local ac = Instance.new("UICorner")
                                                    ac.CornerRadius = UDim.new(0, 12)
                                                    ac.Parent = abg
                                                    abg.Parent = actionsPanel
                                                end
                                                TS:Create(abg,
                                                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 0.55 }):Play()
                                            end
                                        end)

                                        
                                        local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad,
                                            Enum.EasingDirection.Out)
                                        TS:Create(frame, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(logo, fadeInfo, { ImageTransparency = 1 }):Play()
                                        TS:Create(title, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(sub, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(track, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(fill, fadeInfo, { BackgroundTransparency = 1 }):Play()

                                        task.delay(0.3, function()
                                            pcall(function() loadGui:Destroy() end)
                                            pcall(function()
                                                if _opLoadSound then
                                                    _opLoadSound:Stop()
                                                    _opLoadSound:Destroy()
                                                    _opLoadSound = nil
                                                end
                                            end)
                                            isLoadingOnePiece = false
                                        end)
                                    end)
                                end
                            else
                                local targetTheme = (not _TL_isImgTheme(_TL_lastColor) and _TL_lastColor) or
                                "white"
                                if _TL_isImgTheme(_TL_activeThemeId) then
                                    _TL_applyTheme(targetTheme)
                                end
                                
                                local tabBtns = _TL_refs._TL_tabBtns
                                if tabBtns then
                                    for _, tb in ipairs(tabBtns) do
                                        local origIcon = _TL_refs._TL_tabOrigIcons and _TL_refs._TL_tabOrigIcons
                                        [tb.name]
                                        if origIcon and tb.iconImg then
                                            tb.iconImg.Image = origIcon
                                        end
                                    end
                                end
                                
                                local _TS_off = game:GetService("TweenService")
                                for _, _pname in ipairs({ "Character", "Home", "Settings", "Actions", "Scripts", "Communication" }) do
                                    local _pan = panels[_pname]
                                    if _pan then
                                        for _, _bgName in ipairs({ "OnePieceBg", "DragonballBg", "TheBoysBg", "DeathNoteBg", "DexterBg" }) do
                                            local _bg = _pan:FindFirstChild(_bgName)
                                            if _bg then
                                                local _tw = _TS_off:Create(_bg,
                                                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 1 })
                                                _tw.Completed:Connect(function() pcall(function() _bg:Destroy() end) end)
                                                _tw:Play()
                                            end
                                        end
                                    end
                                end
                                
                                task.defer(function()
                                    pcall(function()
                                        local env = _genv
                                        if env._TL_FixThemeChips then
                                            env._TL_FixThemeChips(targetTheme)
                                        end
                                    end)
                                end)
                            end
                        end)
                    end)
                    onePieceToggleSet = setFn
                    onePieceToggleVisual = setVisualFn
                end

                dragonballToggleSet = nil
                dragonballToggleVisual = nil
                isLoadingDragonball = false
                if animeCard then
                    local initOn = (_TL_activeThemeId == "dragonball")
                    local row, setFn, _, setVisualFn = cleanRow(animeCard.Content, 56, "Dragonball", "Saiyan Theme",
                        C.accent, initOn, function(on)
                        pcall(function()
                            if on then
                                if _TL_activeThemeId ~= "dragonball" and not isLoadingDragonball then
                                    isLoadingDragonball = true
                                    
                                    isLoadingOnePiece = false
                                    if onePieceToggleSet then onePieceToggleSet(false) end
                                    if onePieceToggleVisual then onePieceToggleVisual(false) end
                                    
                                    isLoadingTheBoys = false
                                    if theBoysToggleSet then theBoysToggleSet(false) end
                                    if theBoysToggleVisual then theBoysToggleVisual(false) end
                                    
                                    isLoadingDeathNote = false
                                    if deathNoteToggleSet then deathNoteToggleSet(false) end
                                    if deathNoteToggleVisual then deathNoteToggleVisual(false) end
                                    
                                    isLoadingDexter = false
                                    if dexterToggleSet then dexterToggleSet(false) end
                                    if dexterToggleVisual then dexterToggleVisual(false) end
                                    
                                    local sg = _TL_refs and _TL_refs._TL_ScreenGui
                                    local playerGui = sg and sg.Parent or nil
                                    if not playerGui then
                                        pcall(function() playerGui = game:GetService("Players").LocalPlayer:WaitForChild(
                                            "PlayerGui") end)
                                    end
                                    if not playerGui then return end

                                    
                                    local loadGui = Instance.new("ScreenGui")
                                    loadGui.Name = "DragonballLoading"
                                    loadGui.IgnoreGuiInset = true
                                    loadGui.DisplayOrder = 999999
                                    loadGui.Parent = playerGui

                                    local frame = Instance.new("Frame")
                                    frame.Size = UDim2.new(1, 0, 1, 0)
                                    frame.BackgroundColor3 = Color3.fromRGB(10, 8, 4)
                                    frame.BorderSizePixel = 0
                                    frame.Active = true
                                    frame.Parent = loadGui

                                    local bgGrad = Instance.new("UIGradient")
                                    bgGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 5, 2)),
                                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(28, 16, 4)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 5, 2))
                                    })
                                    bgGrad.Rotation = 45
                                    bgGrad.Parent = frame

                                    local container = Instance.new("Frame")
                                    container.Size = UDim2.new(0, 450, 0, 320)
                                    container.Position = UDim2.new(0.5, -225, 0.5, -160)
                                    container.BackgroundTransparency = 1
                                    container.BorderSizePixel = 0
                                    container.Parent = frame

                                    
                                    local logo = Instance.new("ImageLabel")
                                    logo.Size = UDim2.new(0, 120, 0, 120)
                                    logo.Position = UDim2.new(0.5, -60, 0, 10)
                                    logo.BackgroundTransparency = 1
                                    logo.Image = "rbxassetid://73800014230419"
                                    logo.ScaleType = Enum.ScaleType.Fit
                                    logo.ImageTransparency = 1
                                    logo.ZIndex = 10
                                    logo.Parent = container

                                    local title = Instance.new("TextLabel")
                                    title.Size = UDim2.new(1, 0, 0, 60)
                                    title.Position = UDim2.new(0, 0, 0, 140)
                                    title.BackgroundTransparency = 1
                                    title.Text = "DRAGON BALL"
                                    title.Font = Enum.Font.GothamBlack
                                    title.TextSize = 42
                                    title.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    title.TextXAlignment = Enum.TextXAlignment.Center
                                    title.TextTransparency = 1
                                    title.Parent = container

                                    local titleGrad = Instance.new("UIGradient")
                                    titleGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 165, 0)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 0))
                                    })
                                    titleGrad.Rotation = 15
                                    titleGrad.Parent = title

                                    local sub = Instance.new("TextLabel")
                                    sub.Size = UDim2.new(1, 0, 0, 20)
                                    sub.Position = UDim2.new(0, 0, 0, 200)
                                    sub.BackgroundTransparency = 1
                                    sub.Text = "POWERING UP..."
                                    sub.Font = Enum.Font.GothamBold
                                    sub.TextSize = 13
                                    sub.TextColor3 = Color3.fromRGB(255, 235, 190)
                                    sub.TextTransparency = 1
                                    sub.TextXAlignment = Enum.TextXAlignment.Center
                                    sub.Parent = container

                                    local track = Instance.new("Frame")
                                    track.Size = UDim2.new(0, 280, 0, 6)
                                    track.Position = UDim2.new(0.5, -140, 0, 240)
                                    track.BackgroundColor3 = Color3.fromRGB(30, 20, 8)
                                    track.BackgroundTransparency = 1
                                    track.BorderSizePixel = 0
                                    track.Parent = container
                                    local trackCorner = Instance.new("UICorner")
                                    trackCorner.CornerRadius = UDim.new(1, 0)
                                    trackCorner.Parent = track

                                    local fill = Instance.new("Frame")
                                    fill.Size = UDim2.new(0, 0, 1, 0)
                                    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                    fill.BorderSizePixel = 0
                                    fill.Parent = track
                                    local fillCorner = Instance.new("UICorner")
                                    fillCorner.CornerRadius = UDim.new(1, 0)
                                    fillCorner.Parent = fill

                                    local fillGrad = Instance.new("UIGradient")
                                    fillGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 165, 0)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 0))
                                    })
                                    fillGrad.Parent = fill

                                    
                                    local TS = game:GetService("TweenService")
                                    TS:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { ImageTransparency = 0 }):Play()
                                    TS:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { TextTransparency = 0 }):Play()
                                    TS:Create(sub, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { TextTransparency = 0.2 }):Play()
                                    TS:Create(track, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { BackgroundTransparency = 0 }):Play()

                                    
                                    local fillTween = TS:Create(fill,
                                        TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                                        { Size = UDim2.new(1, 0, 1, 0) })
                                    fillTween:Play()

                                    
                                    local _dbLoadSound = nil
                                    pcall(function()
                                        _dbLoadSound                    = Instance.new("Sound", workspace)
                                        _dbLoadSound.SoundId            = "rbxassetid://9113050449"
                                        _dbLoadSound.Volume             = 0.6
                                        _dbLoadSound.RollOffMaxDistance = 10000
                                        _dbLoadSound:Play()
                                    end)

                                    task.delay(1.5, function()
                                        pcall(function()
                                            _TL_applyTheme("dragonball")
                                            
                                            for _, _pn in ipairs({ "Character", "Home", "Settings", "Actions" }) do
                                                local _pp = panels[_pn]
                                                if _pp then
                                                    pcall(function()
                                                        local _ob = _pp:FindFirstChild("OnePieceBg")
                                                        if _ob then _ob:Destroy() end
                                                        local _tb = _pp:FindFirstChild("TheBoysBg")
                                                        if _tb then _tb:Destroy() end
                                                    end)
                                                end
                                            end
                                            
                                            
                                            pcall(function()
                                                if _TL_refs._TL_tabDragonballIcons and dragonballSettingsIconFileName then
                                                    local _asset = _TL_safeGetCustomAsset(dragonballSettingsIconFileName)
                                                    if _asset then
                                                        _TL_refs._TL_tabDragonballIcons.Settings = _asset
                                                    end
                                                end
                                            end)
                                            local tabBtns = _TL_refs._TL_tabBtns
                                            if tabBtns then
                                                for _, tb in ipairs(tabBtns) do
                                                    local dbIcon = _TL_refs._TL_tabDragonballIcons and
                                                    _TL_refs._TL_tabDragonballIcons[tb.name]
                                                    if dbIcon and tb.iconImg then
                                                        tb.iconImg.Image = dbIcon
                                                    end
                                                end
                                            end
                                            
                                            local charPanel = panels["Character"]
                                            if charPanel then
                                                local bg = charPanel:FindFirstChild("DragonballBg")
                                                if not bg then
                                                    bg = Instance.new("ImageLabel")
                                                    bg.Name = "DragonballBg"
                                                    bg.Size = UDim2.new(1, 0, 1, 0)
                                                    bg.Position = UDim2.new(0, 0, 0, 0)
                                                    bg.BackgroundTransparency = 1
                                                    bg.Image = "rbxassetid://103368961885444"
                                                    bg.ScaleType = Enum.ScaleType.Crop
                                                    bg.ImageTransparency = 1
                                                    bg.ZIndex = 0
                                                    local c = Instance.new("UICorner")
                                                    c.CornerRadius = UDim.new(0, 12)
                                                    c.Parent = bg
                                                    bg.Parent = charPanel
                                                end
                                                TS:Create(bg,
                                                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 0.55 }):Play()
                                            end
                                            
                                            local homePanel = panels["Home"]
                                            if homePanel then
                                                local hbg = homePanel:FindFirstChild("DragonballBg")
                                                if not hbg then
                                                    hbg = Instance.new("ImageLabel")
                                                    hbg.Name = "DragonballBg"
                                                    hbg.Size = UDim2.new(1, 0, 1, 0)
                                                    hbg.Position = UDim2.new(0, 0, 0, 0)
                                                    hbg.BackgroundTransparency = 1
                                                    hbg.Image = _TL_safeGetCustomAsset(dragonballBgFileName) or "rbxassetid://85278059623649"
                                                    hbg.ScaleType = Enum.ScaleType.Crop
                                                    hbg.ImageTransparency = 1
                                                    hbg.ZIndex = 0
                                                    local hc = Instance.new("UICorner")
                                                    hc.CornerRadius = UDim.new(0, 12)
                                                    hc.Parent = hbg
                                                    hbg.Parent = homePanel
                                                end
                                                TS:Create(hbg,
                                                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 0.55 }):Play()
                                            end
                                            
                                            local settingsPanel = panels["Settings"]
                                            if settingsPanel then
                                                local sbg = settingsPanel:FindFirstChild("DragonballBg")
                                                if not sbg then
                                                    sbg = Instance.new("ImageLabel")
                                                    sbg.Name = "DragonballBg"
                                                    sbg.Size = UDim2.new(1, 0, 1, 0)
                                                    sbg.Position = UDim2.new(0, 0, 0, 0)
                                                    sbg.BackgroundTransparency = 1
                                                    sbg.Image = "rbxassetid://94124395988701"
                                                    sbg.ScaleType = Enum.ScaleType.Crop
                                                    sbg.ImageTransparency = 1
                                                    sbg.ZIndex = 0
                                                    local sc = Instance.new("UICorner")
                                                    sc.CornerRadius = UDim.new(0, 12)
                                                    sc.Parent = sbg
                                                    sbg.Parent = settingsPanel
                                                end
                                                TS:Create(sbg,
                                                    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 0.55 }):Play()
                                            end
                                        end)

                                        
                                        local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad,
                                            Enum.EasingDirection.Out)
                                        TS:Create(frame, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(logo, fadeInfo, { ImageTransparency = 1 }):Play()
                                        TS:Create(title, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(sub, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(track, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(fill, fadeInfo, { BackgroundTransparency = 1 }):Play()

                                        task.delay(0.3, function()
                                            pcall(function() loadGui:Destroy() end)
                                            pcall(function()
                                                if _dbLoadSound then
                                                    _dbLoadSound:Stop()
                                                    _dbLoadSound:Destroy()
                                                    _dbLoadSound = nil
                                                end
                                            end)
                                            isLoadingDragonball = false
                                        end)
                                    end)
                                end
                            else
                                local targetTheme = (not _TL_isImgTheme(_TL_lastColor) and _TL_lastColor) or
                                "white"
                                if _TL_isImgTheme(_TL_activeThemeId) then
                                    _TL_applyTheme(targetTheme)
                                end
                                
                                local tabBtns = _TL_refs._TL_tabBtns
                                if tabBtns then
                                    for _, tb in ipairs(tabBtns) do
                                        local origIcon = _TL_refs._TL_tabOrigIcons and _TL_refs._TL_tabOrigIcons
                                        [tb.name]
                                        if origIcon and tb.iconImg then
                                            tb.iconImg.Image = origIcon
                                        end
                                    end
                                end
                                
                                local _TS_off = game:GetService("TweenService")
                                for _, _pname in ipairs({ "Character", "Home", "Settings", "Actions", "Scripts", "Communication" }) do
                                    local _pan = panels[_pname]
                                    if _pan then
                                        for _, _bgName in ipairs({ "DragonballBg", "OnePieceBg", "TheBoysBg", "DeathNoteBg", "DexterBg" }) do
                                            local _bg = _pan:FindFirstChild(_bgName)
                                            if _bg then
                                                local _tw = _TS_off:Create(_bg,
                                                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 1 })
                                                _tw.Completed:Connect(function() pcall(function() _bg:Destroy() end) end)
                                                _tw:Play()
                                            end
                                        end
                                    end
                                end
                                
                                task.defer(function()
                                    pcall(function()
                                        local env = _genv
                                        if env._TL_FixThemeChips then
                                            env._TL_FixThemeChips(targetTheme)
                                        end
                                    end)
                                end)
                            end
                        end)
                    end)
                    dragonballToggleSet = setFn
                    dragonballToggleVisual = setVisualFn
                end

                
                theBoysToggleSet = nil
                theBoysToggleVisual = nil
                isLoadingTheBoys = false
                local seriesCard = cards["Series"]
                if seriesCard then
                    local initOn = (_TL_activeThemeId == "theboys")

                    
                    if initOn then
                        task.defer(function()
                            pcall(function()
                                local TS = game:GetService("TweenService")
                                local homePanel = panels["Home"]
                                if homePanel then
                                    local bg = homePanel:FindFirstChild("TheBoysBg")
                                    if not bg then
                                        bg = Instance.new("ImageLabel")
                                        bg.Name = "TheBoysBg"
                                        bg.Size = UDim2.new(1, 0, 1, 0)
                                        bg.Position = UDim2.new(0, 0, 0, 0)
                                        bg.BackgroundTransparency = 1
                                        bg.Image = _TL_safeGetCustomAsset(theBoysBgFileName) or "rbxassetid://84736824738121"
                                        bg.ScaleType = Enum.ScaleType.Crop
                                        bg.ImageTransparency = 1
                                        bg.ZIndex = 0
                                        local _c = Instance.new("UICorner")
                                        _c.CornerRadius = UDim.new(0, 12)
                                        _c.Parent = bg
                                        bg.Parent = homePanel
                                    end
                                    TS:Create(bg, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { ImageTransparency = 0.55 }):Play()
                                end
                            end)
                        end)
                    end

                    local row, setFn, _, setVisualFn = cleanRow(seriesCard.Content, 4, "The Boys", "Supe Theme",
                        Color3.fromRGB(220, 30, 30), initOn, function(on)
                        pcall(function()
                            if on then
                                
                                if onePieceToggleSet then onePieceToggleSet(false) end
                                if onePieceToggleVisual then onePieceToggleVisual(false) end
                                isLoadingOnePiece = false
                                if dragonballToggleSet then dragonballToggleSet(false) end
                                if dragonballToggleVisual then dragonballToggleVisual(false) end
                                isLoadingDragonball = false
                                if deathNoteToggleSet then deathNoteToggleSet(false) end
                                if deathNoteToggleVisual then deathNoteToggleVisual(false) end
                                isLoadingDeathNote = false
                                if dexterToggleSet then dexterToggleSet(false) end
                                if dexterToggleVisual then dexterToggleVisual(false) end
                                isLoadingDexter = false
                                if _TL_activeThemeId ~= "theboys" and not isLoadingTheBoys then
                                    isLoadingTheBoys = true

                                    
                                    local sg = _TL_refs and _TL_refs._TL_ScreenGui
                                    local playerGui = sg and sg.Parent or nil
                                    if not playerGui then
                                        pcall(function() playerGui = game:GetService("Players").LocalPlayer:WaitForChild(
                                            "PlayerGui") end)
                                    end
                                    if not playerGui then return end

                                    
                                    local loadGui = Instance.new("ScreenGui")
                                    loadGui.Name = "TheBoysLoading"
                                    loadGui.IgnoreGuiInset = true
                                    loadGui.DisplayOrder = 999999
                                    loadGui.Parent = playerGui

                                    local frame = Instance.new("Frame")
                                    frame.Size = UDim2.new(1, 0, 1, 0)
                                    frame.BackgroundColor3 = Color3.fromRGB(12, 10, 10)
                                    frame.BorderSizePixel = 0
                                    frame.Active = true
                                    frame.Parent = loadGui

                                    local bgGrad = Instance.new("UIGradient")
                                    bgGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 8)),
                                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 8, 8)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 8))
                                    })
                                    bgGrad.Rotation = 45
                                    bgGrad.Parent = frame

                                    local container = Instance.new("Frame")
                                    container.Size = UDim2.new(0, 450, 0, 320)
                                    container.Position = UDim2.new(0.5, -225, 0.5, -160)
                                    container.BackgroundTransparency = 1
                                    container.BorderSizePixel = 0
                                    container.Parent = frame

                                    
                                    local logo = Instance.new("ImageLabel")
                                    logo.Size = UDim2.new(0, 120, 0, 120)
                                    logo.Position = UDim2.new(0.5, -60, 0, 10)
                                    logo.BackgroundTransparency = 1
                                    logo.Image = "rbxassetid://123326309117495"
                                    logo.ScaleType = Enum.ScaleType.Fit
                                    logo.ImageTransparency = 1
                                    logo.ZIndex = 10
                                    logo.Parent = container

                                    local title = Instance.new("TextLabel")
                                    title.Size = UDim2.new(1, 0, 0, 60)
                                    title.Position = UDim2.new(0, 0, 0, 140)
                                    title.BackgroundTransparency = 1
                                    title.Text = "THE BOYS"
                                    title.Font = Enum.Font.GothamBlack
                                    title.TextSize = 42
                                    title.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    title.TextXAlignment = Enum.TextXAlignment.Center
                                    title.TextTransparency = 1
                                    title.Parent = container

                                    local titleGrad = Instance.new("UIGradient")
                                    titleGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 30)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0))
                                    })
                                    titleGrad.Rotation = 15
                                    titleGrad.Parent = title

                                    local sub = Instance.new("TextLabel")
                                    sub.Size = UDim2.new(1, 0, 0, 20)
                                    sub.Position = UDim2.new(0, 0, 0, 200)
                                    sub.BackgroundTransparency = 1
                                    sub.Text = "DIABOLICAL..."
                                    sub.Font = Enum.Font.GothamBold
                                    sub.TextSize = 13
                                    sub.TextColor3 = Color3.fromRGB(255, 200, 200)
                                    sub.TextTransparency = 1
                                    sub.TextXAlignment = Enum.TextXAlignment.Center
                                    sub.Parent = container

                                    local track = Instance.new("Frame")
                                    track.Size = UDim2.new(0, 280, 0, 6)
                                    track.Position = UDim2.new(0.5, -140, 0, 240)
                                    track.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
                                    track.BackgroundTransparency = 1
                                    track.BorderSizePixel = 0
                                    track.Parent = container
                                    local trackCorner = Instance.new("UICorner")
                                    trackCorner.CornerRadius = UDim.new(1, 0)
                                    trackCorner.Parent = track

                                    local fill = Instance.new("Frame")
                                    fill.Size = UDim2.new(0, 0, 1, 0)
                                    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                    fill.BorderSizePixel = 0
                                    fill.Parent = track
                                    local fillCorner = Instance.new("UICorner")
                                    fillCorner.CornerRadius = UDim.new(1, 0)
                                    fillCorner.Parent = fill

                                    local fillGrad = Instance.new("UIGradient")
                                    fillGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0))
                                    })
                                    fillGrad.Parent = fill

                                    
                                    local TS = game:GetService("TweenService")
                                    TS:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { ImageTransparency = 0 }):Play()
                                    TS:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { TextTransparency = 0 }):Play()
                                    TS:Create(sub, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { TextTransparency = 0.2 }):Play()
                                    TS:Create(track, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                        { BackgroundTransparency = 0 }):Play()

                                    
                                    local fillTween = TS:Create(fill,
                                        TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                                        { Size = UDim2.new(1, 0, 1, 0) })
                                    fillTween:Play()

                                    
                                    local _tbLoadSound = nil
                                    pcall(function()
                                        _tbLoadSound                    = Instance.new("Sound", workspace)
                                        _tbLoadSound.SoundId            = "rbxassetid://9114223126"
                                        _tbLoadSound.Volume             = 0.6
                                        _tbLoadSound.RollOffMaxDistance = 10000
                                        _tbLoadSound:Play()
                                    end)

                                    task.delay(1.5, function()
                                        pcall(function()
                                            _TL_applyTheme("theboys")
                                            
                                            for _, _pn in ipairs({ "Character", "Home", "Settings", "Actions" }) do
                                                local _pp = panels[_pn]
                                                if _pp then
                                                    pcall(function()
                                                        local _ob = _pp:FindFirstChild("OnePieceBg")
                                                        if _ob then _ob:Destroy() end
                                                        local _db = _pp:FindFirstChild("DragonballBg")
                                                        if _db then _db:Destroy() end
                                                    end)
                                                end
                                            end
                                            
                                            
                                            pcall(function()
                                                local _getIcon = _TL_refs._TL_getCustomIcon
                                                local _tb = _TL_refs._TL_tabTheBoys_Icons
                                                if _tb and _getIcon then
                                                    _tb.Settings = _getIcon(theBoysSettingsIconFileName, "rbxassetid://83091867260863")
                                                    _tb.Home     = _getIcon(theBoysHomeIconFileName,     "rbxassetid://79298842483031")
                                                    _tb.Scripts  = _getIcon(theBoysScriptsIconFileName,  "rbxassetid://99174931681951")
                                                    _tb.Actions  = _getIcon(theBoysActionsIconFileName,  "rbxassetid://110933969812438")
                                                end
                                            end)
                                            local tabBtns = _TL_refs._TL_tabBtns
                                            if tabBtns then
                                                for _, tb in ipairs(tabBtns) do
                                                    local tbIcon = _TL_refs._TL_tabTheBoys_Icons[tb.name]
                                                    if tbIcon and tb.iconImg then
                                                        tb.iconImg.Image = tbIcon
                                                    end
                                                end
                                            end
                                            
                                            local _panelBgs = {
                                                Character = "rbxassetid://77174664585520",
                                                Home      = _TL_safeGetCustomAsset(theBoysBgFileName) or "rbxassetid://84736824738121",
                                                Settings  = "rbxassetid://84736824738121",
                                            }
                                            for _pname, _imgId in pairs(_panelBgs) do
                                                local _pan = panels[_pname]
                                                if _pan then
                                                    local bg = _pan:FindFirstChild("TheBoysBg")
                                                    if not bg then
                                                        bg = Instance.new("ImageLabel")
                                                        bg.Name = "TheBoysBg"
                                                        bg.Size = UDim2.new(1, 0, 1, 0)
                                                        bg.Position = UDim2.new(0, 0, 0, 0)
                                                        bg.BackgroundTransparency = 1
                                                        bg.Image = _imgId
                                                        bg.ScaleType = Enum.ScaleType.Crop
                                                        bg.ImageTransparency = 1
                                                        bg.ZIndex = 0
                                                        local _c = Instance.new("UICorner")
                                                        _c.CornerRadius = UDim.new(0, 12)
                                                        _c.Parent = bg
                                                        bg.Parent = _pan
                                                    end
                                                    TS:Create(bg,
                                                        TweenInfo.new(0.5, Enum.EasingStyle.Quad,
                                                            Enum.EasingDirection.Out), { ImageTransparency = 0.55 })
                                                        :Play()
                                                end
                                            end
                                            task.defer(function()
                                                pcall(function()
                                                    local env = _genv
                                                    if env._TL_FixThemeChips then
                                                        env._TL_FixThemeChips("theboys")
                                                    end
                                                end)
                                            end)
                                        end)

                                        
                                        local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad,
                                            Enum.EasingDirection.Out)
                                        TS:Create(frame, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(logo, fadeInfo, { ImageTransparency = 1 }):Play()
                                        TS:Create(title, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(sub, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(track, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(fill, fadeInfo, { BackgroundTransparency = 1 }):Play()

                                        task.delay(0.3, function()
                                            pcall(function() loadGui:Destroy() end)
                                            pcall(function()
                                                if _tbLoadSound then
                                                    _tbLoadSound:Stop()
                                                    _tbLoadSound:Destroy()
                                                    _tbLoadSound = nil
                                                end
                                            end)
                                            isLoadingTheBoys = false
                                        end)
                                    end)
                                end
                            else
                                isLoadingTheBoys = false
                                local targetTheme = (not _TL_isImgTheme(_TL_lastColor) and _TL_lastColor) or
                                "white"
                                if _TL_isImgTheme(_TL_activeThemeId) then
                                    _TL_applyTheme(targetTheme)
                                end
                                
                                pcall(function()
                                    local _tabBtns = _TL_refs._TL_tabBtns
                                    if _tabBtns then
                                        for _, tb in ipairs(_tabBtns) do
                                            local origIcon = _TL_refs._TL_tabOrigIcons and
                                            _TL_refs._TL_tabOrigIcons[tb.name]
                                            if origIcon and tb.iconImg then
                                                tb.iconImg.Image = origIcon
                                            end
                                        end
                                    end
                                end)
                                
                                local _TS_off = game:GetService("TweenService")
                                for _, _pname in ipairs({ "Character", "Home", "Settings", "Actions", "Scripts", "Communication" }) do
                                    local _pan = panels[_pname]
                                    if _pan then
                                        for _, _bgName in ipairs({ "TheBoysBg", "OnePieceBg", "DragonballBg", "DeathNoteBg", "DexterBg" }) do
                                            local _bg = _pan:FindFirstChild(_bgName)
                                            if _bg then
                                                local _tw = _TS_off:Create(_bg,
                                                    TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                    { ImageTransparency = 1 })
                                                _tw.Completed:Connect(function() pcall(function() _bg:Destroy() end) end)
                                                _tw:Play()
                                            end
                                        end
                                    end
                                end
                                task.defer(function()
                                    pcall(function()
                                        local env = _genv
                                        if env._TL_FixThemeChips then
                                            env._TL_FixThemeChips(targetTheme)
                                        end
                                    end)
                                end)
                            end
                        end)
                    end)
                    theBoysToggleSet = setFn
                    theBoysToggleVisual = setVisualFn
                end

                
                if seriesCard then
                    dexterToggleSet = nil
                    dexterToggleVisual = nil
                    isLoadingDexter = false
                    local initOn = (_TL_activeThemeId == "dexter")
                    local row, setFn, _, setVisualFn = cleanRow(seriesCard.Content, 56, "Dexter", "Dark Passenger Theme",
                        Color3.fromRGB(0, 100, 180), initOn, function(on)
                        pcall(function()
                            if on then
                                if onePieceToggleSet then onePieceToggleSet(false) end
                                if onePieceToggleVisual then onePieceToggleVisual(false) end
                                isLoadingOnePiece = false
                                if dragonballToggleSet then dragonballToggleSet(false) end
                                if dragonballToggleVisual then dragonballToggleVisual(false) end
                                isLoadingDragonball = false
                                if theBoysToggleSet then theBoysToggleSet(false) end
                                if theBoysToggleVisual then theBoysToggleVisual(false) end
                                isLoadingTheBoys = false
                                if deathNoteToggleSet then deathNoteToggleSet(false) end
                                if deathNoteToggleVisual then deathNoteToggleVisual(false) end
                                isLoadingDeathNote = false
                                if _TL_activeThemeId ~= "dexter" and not isLoadingDexter then
                                    isLoadingDexter = true
                                    local sg = _TL_refs and _TL_refs._TL_ScreenGui
                                    local playerGui = sg and sg.Parent or nil
                                    if not playerGui then
                                        pcall(function() playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end)
                                    end
                                    if not playerGui then isLoadingDexter = false; return end

                                    local loadGui = Instance.new("ScreenGui")
                                    loadGui.Name = "DexterLoading"
                                    loadGui.IgnoreGuiInset = true
                                    loadGui.DisplayOrder = 999999
                                    loadGui.Parent = playerGui

                                    local frame = Instance.new("Frame")
                                    frame.Size = UDim2.new(1, 0, 1, 0)
                                    frame.BackgroundColor3 = Color3.fromRGB(2, 6, 12)
                                    frame.BorderSizePixel = 0
                                    frame.Active = true
                                    frame.Parent = loadGui

                                    local bgGrad = Instance.new("UIGradient")
                                    bgGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 4, 10)),
                                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 18, 35)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 4, 10))
                                    })
                                    bgGrad.Rotation = 45
                                    bgGrad.Parent = frame

                                    local container = Instance.new("Frame")
                                    container.Size = UDim2.new(0, 450, 0, 320)
                                    container.Position = UDim2.new(0.5, -225, 0.5, -160)
                                    container.BackgroundTransparency = 1
                                    container.BorderSizePixel = 0
                                    container.Parent = frame

                                    local logo = Instance.new("ImageLabel")
                                    logo.Size = UDim2.new(0, 120, 0, 120)
                                    logo.Position = UDim2.new(0.5, -60, 0, 10)
                                    logo.BackgroundTransparency = 1
                                    logo.Image = _TL_safeGetCustomAsset(dexterLoadingScreenFileName) or dexterLoadingScreenUrl
                                    logo.ScaleType = Enum.ScaleType.Fit
                                    logo.ImageTransparency = 1
                                    logo.ZIndex = 10
                                    logo.Parent = container

                                    local title = Instance.new("TextLabel")
                                    title.Size = UDim2.new(1, 0, 0, 60)
                                    title.Position = UDim2.new(0, 0, 0, 140)
                                    title.BackgroundTransparency = 1
                                    title.Text = "DEXTER"
                                    title.Font = Enum.Font.GothamBlack
                                    title.TextSize = 46
                                    title.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    title.TextXAlignment = Enum.TextXAlignment.Center
                                    title.TextTransparency = 1
                                    title.Parent = container

                                    local titleGrad = Instance.new("UIGradient")
                                    titleGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 220, 255)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 180))
                                    })
                                    titleGrad.Rotation = 10
                                    titleGrad.Parent = title

                                    local sub = Instance.new("TextLabel")
                                    sub.Size = UDim2.new(1, 0, 0, 20)
                                    sub.Position = UDim2.new(0, 0, 0, 200)
                                    sub.BackgroundTransparency = 1
                                    sub.Text = "DARK PASSENGER AWAKENING..."
                                    sub.Font = Enum.Font.GothamBold
                                    sub.TextSize = 13
                                    sub.TextColor3 = Color3.fromRGB(150, 190, 220)
                                    sub.TextTransparency = 1
                                    sub.Parent = container

                                    local track = Instance.new("Frame")
                                    track.Size = UDim2.new(0, 300, 0, 4)
                                    track.Position = UDim2.new(0.5, -150, 0, 250)
                                    track.BackgroundColor3 = Color3.fromRGB(10, 20, 40)
                                    track.BackgroundTransparency = 1
                                    track.BorderSizePixel = 0
                                    track.Parent = container
                                    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 4); tc.Parent = track

                                    local fill = Instance.new("Frame")
                                    fill.Size = UDim2.new(0, 0, 1, 0)
                                    fill.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
                                    fill.BackgroundTransparency = 1
                                    fill.BorderSizePixel = 0
                                    fill.Parent = track
                                    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 4); fc.Parent = fill

                                    local fillGrad = Instance.new("UIGradient")
                                    fillGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 70, 140)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 130, 220))
                                    })
                                    fillGrad.Parent = fill

                                    local TS = game:GetService("TweenService")
                                    TS:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
                                    TS:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
                                    TS:Create(sub, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.2 }):Play()
                                    TS:Create(track, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
                                    TS:Create(fill, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 }):Play()

                                    task.delay(1.5, function()
                                        pcall(function()
                                            _TL_applyTheme("dexter")
                                            for _, _pn in ipairs({ "Character", "Home", "Settings", "Actions", "Scripts", "Communication" }) do
                                                local _pp = panels[_pn]
                                                if _pp then
                                                    pcall(function()
                                                        for _, _bgName in ipairs({ "OnePieceBg", "DragonballBg", "TheBoysBg", "DeathNoteBg", "DexterBg" }) do
                                                            local _ob = _pp:FindFirstChild(_bgName)
                                                            if _ob then _ob:Destroy() end
                                                        end
                                                    end)
                                                end
                                            end
                                            pcall(function()
                                                local _getIcon = _TL_refs._TL_getCustomIcon
                                                local _dx = _TL_refs._TL_tabDexterIcons
                                                if _dx and _getIcon then
                                                    _dx.Character     = _getIcon(dexterCharIconFileName,     _dx.Character)
                                                    _dx.Playerlist    = _getIcon(dexterPlayerlistIconFileName, _dx.Playerlist)
                                                    _dx.Settings      = _getIcon(dexterSettingsIconFileName, _dx.Settings)
                                                    _dx.Scripts       = _getIcon(dexterScriptsIconFileName,  _dx.Scripts)
                                                end
                                            end)
                                            local tabBtns = _TL_refs._TL_tabBtns
                                            if tabBtns then
                                                for _, tb in ipairs(tabBtns) do
                                                    local dxIcon = _TL_refs._TL_tabDexterIcons and _TL_refs._TL_tabDexterIcons[tb.name]
                                                    if dxIcon and tb.iconImg then
                                                        tb.iconImg.Image = dxIcon
                                                    end
                                                end
                                            end
                                            pcall(function()
                                                local _dxPanelBgs = {
                                                    Character     = { file = dexterCharBgFileName,     url = dexterCharBgUrl     },
                                                    Communication = { file = dexterComBgFileName,        url = dexterComBgUrl        },
                                                }
                                                for _pname, _src in pairs(_dxPanelBgs) do
                                                    local _pan = panels[_pname]
                                                    if _pan then
                                                        local _bg = _pan:FindFirstChild("DexterBg")
                                                        if not _bg then
                                                            _bg = Instance.new("ImageLabel")
                                                            _bg.Name = "DexterBg"
                                                            _bg.Size = UDim2.new(1, 0, 1, 0)
                                                            _bg.Position = UDim2.new(0, 0, 0, 0)
                                                            _bg.BackgroundTransparency = 1
                                                            _bg.Image = _TL_safeGetCustomAsset(_src.file) or _src.url
                                                            _bg.ScaleType = Enum.ScaleType.Crop
                                                            _bg.ImageTransparency = 1
                                                            _bg.ZIndex = 0
                                                            local _c = Instance.new("UICorner")
                                                            _c.CornerRadius = UDim.new(0, 12)
                                                            _c.Parent = _bg
                                                            _bg.Parent = _pan
                                                        end
                                                        TS:Create(_bg,
                                                            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                            { ImageTransparency = 0.45 }):Play()
                                                    end
                                                end
                                            end)
                                        end)
                                        local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                                        TS:Create(frame, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(logo, fadeInfo, { ImageTransparency = 1 }):Play()
                                        TS:Create(title, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(sub, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(track, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(fill, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        task.delay(0.3, function()
                                            pcall(function() loadGui:Destroy() end)
                                            isLoadingDexter = false
                                        end)
                                    end)
                                end
                            else
                                isLoadingDexter = false
                                local targetTheme = (not _TL_isImgTheme(_TL_lastColor) and _TL_lastColor) or "white"
                                if _TL_activeThemeId == "dexter" then
                                    _TL_applyTheme(targetTheme)
                                end
                                pcall(function()
                                    local _tabBtns = _TL_refs._TL_tabBtns
                                    if _tabBtns then
                                        for _, tb in ipairs(_tabBtns) do
                                            local origIcon = _TL_refs._TL_tabOrigIcons and _TL_refs._TL_tabOrigIcons[tb.name]
                                            if origIcon and tb.iconImg then
                                                tb.iconImg.Image = origIcon
                                            end
                                        end
                                    end
                                end)
                                local _TS_off = game:GetService("TweenService")
                                for _, _pname in ipairs({ "Character", "Home", "Settings", "Actions", "Scripts", "Communication" }) do
                                    local _pan = panels[_pname]
                                    if _pan then
                                        for _, _bgName in ipairs({ "DexterBg", "DeathNoteBg", "TheBoysBg", "OnePieceBg", "DragonballBg" }) do
                                            local _bg = _pan:FindFirstChild(_bgName)
                                            if _bg then
                                                local _tw = _TS_off:Create(_bg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 1 })
                                                _tw.Completed:Connect(function() pcall(function() _bg:Destroy() end) end)
                                                _tw:Play()
                                            end
                                        end
                                    end
                                end
                                task.defer(function()
                                    pcall(function()
                                        local env = _genv
                                        if env._TL_FixThemeChips then
                                            env._TL_FixThemeChips(targetTheme)
                                        end
                                    end)
                                end)
                            end
                        end)
                    end)
                    dexterToggleSet = setFn
                    dexterToggleVisual = setVisualFn
                end

                
                deathNoteToggleSet = nil
                deathNoteToggleVisual = nil
                isLoadingDeathNote = false
                if animeCard then
                    local initOn = (_TL_activeThemeId == "deathnote")
                    local row, setFn, _, setVisualFn = cleanRow(animeCard.Content, 108, "Death Note", "Shinigami Theme",
                        Color3.fromRGB(200, 20, 20), initOn, function(on)
                        pcall(function()
                            if on then
                                
                                if onePieceToggleSet then onePieceToggleSet(false) end
                                if onePieceToggleVisual then onePieceToggleVisual(false) end
                                isLoadingOnePiece = false
                                if dragonballToggleSet then dragonballToggleSet(false) end
                                if dragonballToggleVisual then dragonballToggleVisual(false) end
                                isLoadingDragonball = false
                                if theBoysToggleSet then theBoysToggleSet(false) end
                                if theBoysToggleVisual then theBoysToggleVisual(false) end
                                isLoadingTheBoys = false
                                if dexterToggleSet then dexterToggleSet(false) end
                                if dexterToggleVisual then dexterToggleVisual(false) end
                                isLoadingDexter = false
                                if _TL_activeThemeId ~= "deathnote" and not isLoadingDeathNote then
                                    isLoadingDeathNote = true
                                    
                                    local sg = _TL_refs and _TL_refs._TL_ScreenGui
                                    local playerGui = sg and sg.Parent or nil
                                    if not playerGui then
                                        pcall(function() playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end)
                                    end
                                    if not playerGui then isLoadingDeathNote = false; return end

                                    
                                    local loadGui = Instance.new("ScreenGui")
                                    loadGui.Name = "DeathNoteLoading"
                                    loadGui.IgnoreGuiInset = true
                                    loadGui.DisplayOrder = 999999
                                    loadGui.Parent = playerGui

                                    local frame = Instance.new("Frame")
                                    frame.Size = UDim2.new(1, 0, 1, 0)
                                    frame.BackgroundColor3 = Color3.fromRGB(4, 3, 3)
                                    frame.BorderSizePixel = 0
                                    frame.Active = true
                                    frame.Parent = loadGui

                                    local bgGrad = Instance.new("UIGradient")
                                    bgGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 2, 2)),
                                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 5, 5)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 2, 2))
                                    })
                                    bgGrad.Rotation = 45
                                    bgGrad.Parent = frame

                                    local container = Instance.new("Frame")
                                    container.Size = UDim2.new(0, 450, 0, 320)
                                    container.Position = UDim2.new(0.5, -225, 0.5, -160)
                                    container.BackgroundTransparency = 1
                                    container.BorderSizePixel = 0
                                    container.Parent = frame

                                    
                                    local logo = Instance.new("ImageLabel")
                                    logo.Size = UDim2.new(0, 120, 0, 120)
                                    logo.Position = UDim2.new(0.5, -60, 0, 10)
                                    logo.BackgroundTransparency = 1
                                    logo.Image = _TL_safeGetCustomAsset(deathNoteLoadingScreenFileName) or deathNoteLoadingScreenUrl
                                    logo.ScaleType = Enum.ScaleType.Fit
                                    logo.ImageTransparency = 1
                                    logo.ZIndex = 10
                                    logo.Parent = container

                                    local title = Instance.new("TextLabel")
                                    title.Size = UDim2.new(1, 0, 0, 60)
                                    title.Position = UDim2.new(0, 0, 0, 140)
                                    title.BackgroundTransparency = 1
                                    title.Text = "DEATH NOTE"
                                    title.Font = Enum.Font.GothamBlack
                                    title.TextSize = 46
                                    title.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    title.TextXAlignment = Enum.TextXAlignment.Center
                                    title.TextTransparency = 1
                                    title.Parent = container

                                    local titleGrad = Instance.new("UIGradient")
                                    titleGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 10, 10))
                                    })
                                    titleGrad.Rotation = 10
                                    titleGrad.Parent = title

                                    local sub = Instance.new("TextLabel")
                                    sub.Size = UDim2.new(1, 0, 0, 20)
                                    sub.Position = UDim2.new(0, 0, 0, 200)
                                    sub.BackgroundTransparency = 1
                                    sub.Text = "WRITING YOUR NAME..."
                                    sub.Font = Enum.Font.GothamBold
                                    sub.TextSize = 13
                                    sub.TextColor3 = Color3.fromRGB(200, 180, 180)
                                    sub.TextTransparency = 1
                                    sub.Parent = container

                                    local track = Instance.new("Frame")
                                    track.Size = UDim2.new(0, 300, 0, 4)
                                    track.Position = UDim2.new(0.5, -150, 0, 250)
                                    track.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
                                    track.BackgroundTransparency = 1
                                    track.BorderSizePixel = 0
                                    track.Parent = container
                                    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 4); tc.Parent = track

                                    local fill = Instance.new("Frame")
                                    fill.Size = UDim2.new(0, 0, 1, 0)
                                    fill.BackgroundColor3 = Color3.fromRGB(180, 10, 10)
                                    fill.BackgroundTransparency = 1
                                    fill.BorderSizePixel = 0
                                    fill.Parent = track
                                    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 4); fc.Parent = fill

                                    local fillGrad = Instance.new("UIGradient")
                                    fillGrad.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 8, 8)),
                                        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 20, 20))
                                    })
                                    fillGrad.Parent = fill

                                    local TS = game:GetService("TweenService")
                                    TS:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
                                    TS:Create(title, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
                                    TS:Create(sub, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.2 }):Play()
                                    TS:Create(track, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
                                    TS:Create(fill, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0 }):Play()

                                    task.delay(1.5, function()
                                        pcall(function()
                                            _TL_applyTheme("deathnote")
                                            
                                            for _, _pn in ipairs({ "Character", "Home", "Settings", "Actions", "Scripts", "Communication" }) do
                                                local _pp = panels[_pn]
                                                if _pp then
                                                    pcall(function()
                                                        for _, _bgName in ipairs({ "OnePieceBg", "DragonballBg", "TheBoysBg", "DexterBg" }) do
                                                            local _ob = _pp:FindFirstChild(_bgName)
                                                            if _ob then _ob:Destroy() end
                                                        end
                                                    end)
                                                end
                                            end
                                            
                                            pcall(function()
                                                local _getIcon = _TL_refs._TL_getCustomIcon
                                                local _dn = _TL_refs._TL_tabDeathNote_Icons
                                                if _dn and _getIcon then
                                                    _dn.Home          = _getIcon(deathNoteHomeIconFileName,     _dn.Home)
                                                    _dn.Character     = _getIcon(deathNoteCharIconFileName,     _dn.Character)
                                                    _dn.Scripts       = _getIcon(deathNoteScriptsIconFileName,  _dn.Scripts)
                                                    _dn.Settings      = _getIcon(deathNoteSettingsIconFileName, _dn.Settings)
                                                    _dn.Communication = _getIcon(deathNoteComIconFileName,      _dn.Communication)
                                                end
                                            end)
                                            local tabBtns = _TL_refs._TL_tabBtns
                                            if tabBtns then
                                                for _, tb in ipairs(tabBtns) do
                                                    local dnIcon = _TL_refs._TL_tabDeathNote_Icons and _TL_refs._TL_tabDeathNote_Icons[tb.name]
                                                    if dnIcon and tb.iconImg then
                                                        tb.iconImg.Image = dnIcon
                                                    end
                                                end
                                            end
                                            
                                            pcall(function()
                                                local _dnPanelBgs = {
                                                    Home         = { file = deathNoteHomeBgFileName,          url = deathNoteHomeBgUrl          },
                                                    Character    = { file = deathNoteCharBgFileName,        url = deathNoteCharBgUrl        },
                                                    Actions      = { file = deathNoteScriptsBgFileName,     url = deathNoteScriptsBgUrl     },
                                                    Scripts      = { file = deathNoteScriptsPanelBgFileName, url = deathNoteScriptsPanelBgUrl },
                                                    Communication = { file = deathNoteComBgFileName,         url = deathNoteComBgUrl         },
                                                }
                                                for _pname, _src in pairs(_dnPanelBgs) do
                                                    local _pan = panels[_pname]
                                                    if _pan then
                                                        local _bg = _pan:FindFirstChild("DeathNoteBg")
                                                        if not _bg then
                                                            _bg = Instance.new("ImageLabel")
                                                            _bg.Name = "DeathNoteBg"
                                                            _bg.Size = UDim2.new(1, 0, 1, 0)
                                                            _bg.Position = UDim2.new(0, 0, 0, 0)
                                                            _bg.BackgroundTransparency = 1
                                                            _bg.Image = _TL_safeGetCustomAsset(_src.file) or _src.url
                                                            _bg.ScaleType = Enum.ScaleType.Crop
                                                            _bg.ImageTransparency = 1
                                                            _bg.ZIndex = 0
                                                            local _c = Instance.new("UICorner")
                                                            _c.CornerRadius = UDim.new(0, 12)
                                                            _c.Parent = _bg
                                                            _bg.Parent = _pan
                                                        end
                                                        local _targetTrans = (_pname == "Home") and 0.65 or 0.45
                                                        TS:Create(_bg,
                                                            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                                            { ImageTransparency = _targetTrans }):Play()
                                                    end
                                                end
                                            end)
                                        end)

                                        
                                        local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                                        TS:Create(frame, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(logo, fadeInfo, { ImageTransparency = 1 }):Play()
                                        TS:Create(title, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(sub, fadeInfo, { TextTransparency = 1 }):Play()
                                        TS:Create(track, fadeInfo, { BackgroundTransparency = 1 }):Play()
                                        TS:Create(fill, fadeInfo, { BackgroundTransparency = 1 }):Play()

                                        task.delay(0.3, function()
                                            pcall(function() loadGui:Destroy() end)
                                            isLoadingDeathNote = false
                                        end)
                                    end)
                                end
                            else
                                isLoadingDeathNote = false
                                local targetTheme = (not _TL_isImgTheme(_TL_lastColor) and _TL_lastColor) or "white"
                                if _TL_activeThemeId == "deathnote" then
                                    _TL_applyTheme(targetTheme)
                                end
                                
                                pcall(function()
                                    local _tabBtns = _TL_refs._TL_tabBtns
                                    if _tabBtns then
                                        for _, tb in ipairs(_tabBtns) do
                                            local origIcon = _TL_refs._TL_tabOrigIcons and _TL_refs._TL_tabOrigIcons[tb.name]
                                            if origIcon and tb.iconImg then
                                                tb.iconImg.Image = origIcon
                                            end
                                        end
                                    end
                                end)
                                
                                local _TS_off = game:GetService("TweenService")
                                for _, _pname in ipairs({ "Character", "Home", "Settings", "Actions", "Scripts", "Communication" }) do
                                    local _pan = panels[_pname]
                                    if _pan then
                                        for _, _bgName in ipairs({ "DeathNoteBg", "DexterBg", "TheBoysBg", "OnePieceBg", "DragonballBg" }) do
                                            local _bg = _pan:FindFirstChild(_bgName)
                                            if _bg then
                                                local _tw = _TS_off:Create(_bg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 1 })
                                                _tw.Completed:Connect(function() pcall(function() _bg:Destroy() end) end)
                                                _tw:Play()
                                            end
                                        end
                                    end
                                end
                                task.defer(function()
                                    pcall(function()
                                        local env = _genv
                                        if env._TL_FixThemeChips then
                                            env._TL_FixThemeChips(targetTheme)
                                        end
                                    end)
                                end)
                            end
                        end)
                    end)
                    deathNoteToggleSet = setFn
                    deathNoteToggleVisual = setVisualFn
                end

                
                function syncThemeTogglesAfterUI()
                    pcall(function()
                        if onePieceToggleVisual then
                            onePieceToggleVisual(_TL_activeThemeId == "onepiece")
                        end
                        if dragonballToggleVisual then
                            dragonballToggleVisual(_TL_activeThemeId == "dragonball")
                        end
                        if theBoysToggleVisual then
                            theBoysToggleVisual(_TL_activeThemeId == "theboys")
                        end
                        if deathNoteToggleVisual then
                            deathNoteToggleVisual(_TL_activeThemeId == "deathnote")
                        end
                        if dexterToggleVisual then
                            dexterToggleVisual(_TL_activeThemeId == "dexter")
                        end
                    end)
                end

                                _panelColorHooks[#_panelColorHooks + 1] = function()
                    pcall(function()
                        
                        
                        if onePieceToggleVisual then
                            onePieceToggleVisual(_TL_activeThemeId == "onepiece" or isLoadingOnePiece)
                        end
                        if dragonballToggleVisual then
                            dragonballToggleVisual(_TL_activeThemeId == "dragonball" or isLoadingDragonball)
                        end
                        if theBoysToggleVisual then
                            theBoysToggleVisual(_TL_activeThemeId == "theboys" or isLoadingTheBoys)
                        end
                        if deathNoteToggleVisual then
                            deathNoteToggleVisual(_TL_activeThemeId == "deathnote" or isLoadingDeathNote)
                        end
                        if dexterToggleVisual then
                            dexterToggleVisual(_TL_activeThemeId == "dexter" or isLoadingDexter)
                        end
                        
                        if (_TL_activeThemeId == "onepiece" or isLoadingOnePiece) and dragonballToggleVisual then
                            dragonballToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "onepiece" or isLoadingOnePiece) and theBoysToggleVisual then
                            theBoysToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "onepiece" or isLoadingOnePiece) and deathNoteToggleVisual then
                            deathNoteToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "onepiece" or isLoadingOnePiece) and dexterToggleVisual then
                            dexterToggleVisual(false)
                        end
                        
                        if (_TL_activeThemeId == "dragonball" or isLoadingDragonball) and onePieceToggleVisual then
                            onePieceToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "dragonball" or isLoadingDragonball) and theBoysToggleVisual then
                            theBoysToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "dragonball" or isLoadingDragonball) and deathNoteToggleVisual then
                            deathNoteToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "dragonball" or isLoadingDragonball) and dexterToggleVisual then
                            dexterToggleVisual(false)
                        end
                        
                        if (_TL_activeThemeId == "theboys" or isLoadingTheBoys) and onePieceToggleVisual then
                            onePieceToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "theboys" or isLoadingTheBoys) and dragonballToggleVisual then
                            dragonballToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "theboys" or isLoadingTheBoys) and deathNoteToggleVisual then
                            deathNoteToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "theboys" or isLoadingTheBoys) and dexterToggleVisual then
                            dexterToggleVisual(false)
                        end
                        
                        if (_TL_activeThemeId == "deathnote" or isLoadingDeathNote) and onePieceToggleVisual then
                            onePieceToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "deathnote" or isLoadingDeathNote) and dragonballToggleVisual then
                            dragonballToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "deathnote" or isLoadingDeathNote) and theBoysToggleVisual then
                            theBoysToggleVisual(false)
                        end
                        
                        if (_TL_activeThemeId == "dexter" or isLoadingDexter) and onePieceToggleVisual then
                            onePieceToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "dexter" or isLoadingDexter) and dragonballToggleVisual then
                            dragonballToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "dexter" or isLoadingDexter) and theBoysToggleVisual then
                            theBoysToggleVisual(false)
                        end
                        if (_TL_activeThemeId == "dexter" or isLoadingDexter) and deathNoteToggleVisual then
                            deathNoteToggleVisual(false)
                        end
                    end)
                end

                
                syncThemeTogglesAfterUI()

                
                
                
                

                local _ok_covertNet, _err_covertNet = pcall(function()

                
                
                
                
                local CHAT_MAX_LENGTH    = 100
                local ROLES_URL          =
                "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NametagRoles.json"
                local SCRIPT_URL         =
                "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/covertnet.lua"

                local Players            = game:GetService("Players")
                local RunService         = game:GetService("RunService")
                local CoreGui            = game:GetService("CoreGui")
                local UserInputService   = game:GetService("UserInputService")
                local TweenService       = game:GetService("TweenService")

                local LocalPlayer        = Players.LocalPlayer

                
                
                
                local function SendRobloxChat(message)
                    if not message or #message == 0 then return end

                    local newOk = pcall(function()
                        local TextChatService = game:GetService("TextChatService")
                        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                            local channel = TextChatService:FindFirstChild("TextChannels")
                            if channel then
                                local general = channel:FindFirstChild("RBXGeneral") or channel:FindFirstChildWhichIsA("TextChannel")
                                if general then
                                    general:SendAsync(message)
                                    return
                                end
                            end
                            error("no channel")
                        else
                            error("not textchatservice")
                        end
                    end)
                    if newOk then return end

                    pcall(function()
                        local args = { string.sub(message, 1, 200), "All" }
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("DefaultChatSystemChatEvents")
                            :WaitForChild("SayMessageRequest")
                            :FireServer(unpack(args))
                    end)
                end

                
                
                
                local guiName            = "CovertNetGUI_v6"
                local cleanupEventName   = "CovertNet_CleanupEvent_v6"
                local _ScriptConnections = {}
                local function Track(c)
                    table.insert(_ScriptConnections, c); return c
                end

                local existingEvent = CoreGui:FindFirstChild(cleanupEventName)
                if existingEvent then
                    pcall(function() existingEvent:Fire() end); task.wait(0.15)
                end

                pcall(function()
                    for _, parent in ipairs({ CoreGui, LocalPlayer:WaitForChild("PlayerGui", 3) }) do
                        if parent then
                            local old = parent:FindFirstChild(guiName)
                            if old then old:Destroy() end
                            for _, desc in ipairs(parent:GetDescendants()) do
                                if desc.Name == "CovertPeerTag" and desc:IsA("BillboardGui") then desc:Destroy() end
                            end
                        end
                    end
                end)
                

                
                
                
                
                LoadRolesFromGithub = function()
                    local success, result = pcall(function() return (game :: any):HttpGet(ROLES_URL) end)
                    if not success or not result or result == "" then
                        warn("[CovertNet] GitHub load failed – nametag roles unavailable")
                        return
                    end
                    local newOverrides, newAdmins = {}, {}
                    for line in result:gmatch("[^\r\n]+") do
                        if not line:match("^%s*%-%-") and line:match("%S") then
                            local username, display, role = line:match(
                            '%["([^"]+)"%]%s*=%s*%{.-display%s*=%s*"([^"]+)".-role%s*=%s*"([^"]+)"')
                            if username and display and role then
                                newOverrides[username] = { display = display, role = role }
                                local r = role:lower()
                                local d = display:lower()
                                if r == "administrator" or r == "owner" or r:find("admin") or r:find("owner") or d:find("owner") or d:find("admin")
                                    or r:find("developer") or r:find("entwickler") or r:find("moderator") or r:find("advertising") then
                                    newAdmins[username] = true
                                end
                            end
                        end
                    end
                    if next(newOverrides) then
                        NameOverrides = newOverrides; AdminNames = newAdmins
                    end
                end

                LoadRolesFromGithub()
                task.spawn(function() while true do
                        task.wait(300); LoadRolesFromGithub()
                    end end)
                
                local _NT_loadConfig  
                task.spawn(function() while true do
                        task.wait(300)
                _NT_loadConfig()
                        
                        if _NT_CONFIG and _NT_CONFIG.roleUsers then
                            local _ADMIN_ROLE_KEYS = { owner = true, admin = true, developer = true }
                            for role, users in pairs(_NT_CONFIG.roleUsers) do
                                if _ADMIN_ROLE_KEYS[role] then
                                    for _, u in ipairs(users) do
                                        AdminNames[tostring(u)] = true
                                    end
                                end
                            end
                        end
                        
                        pcall(function()
                            local guiParentBB = CoreGui
                            for _, desc in ipairs(guiParentBB:GetDescendants()) do
                                if desc:IsA("BillboardGui") and desc.Name:sub(1, 14) == "CovertPeerTag_" then
                                    desc:Destroy()
                                end
                            end
                        end)
                        
                        task.wait(0.5)
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p.Character then
                                local isAdm = AdminNames[p.Name] == true or AdminNames[tostring(p.UserId)] == true
                                pcall(CreateCustomNametag, p.Character, p.Name, isAdm)
                            end
                        end
                    end end)
                local IsLocalAdmin      = _isAdminUser or (AdminNames[LocalPlayer.Name] == true) or (AdminNames[tostring(LocalPlayer.UserId)] == true)

                
                _LocalPlayer.Chatted:Connect(function(msg)
                    if msg:lower() == "!reloadtags" then
                        task.spawn(function()
                _NT_loadConfig()

                
                
                if _NT_CONFIG and _NT_CONFIG.roleUsers then
                    local _ADMIN_ROLE_KEYS = { owner = true, admin = true, developer = true }
                    for role, users in pairs(_NT_CONFIG.roleUsers) do
                        if _ADMIN_ROLE_KEYS[role] then
                            for _, u in ipairs(users) do
                                AdminNames[tostring(u)] = true
                            end
                        end
                    end
                end
                            pcall(function()
                                for _, desc in ipairs(CoreGui:GetDescendants()) do
                                    if desc:IsA("BillboardGui") and desc.Name:sub(1, 14) == "CovertPeerTag_" then
                                        desc:Destroy()
                                    end
                                end
                            end)
                            task.wait(0.3)
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p.Character then
                                    local isAdm = AdminNames[p.Name] == true or AdminNames[tostring(p.UserId)] == true
                                    pcall(CreateCustomNametag, p.Character, p.Name, isAdm)
                                end
                            end
                        end)
                    end
                end)

                
                
                
                local PKT               = { BEGIN = 1, DATA = 2, ENDD = 3 }

                local NORMAL_ANIM_SPEED = 1
                local FIELD_SEP         = string.char(31)

                local SEND_INTERVAL     = 0.28
                local MAX_MSG_BYTES     = 250
                local RECEIVER_TIMEOUT  = 12

                local function encodePacket(ptype, seq, data)
                    return ptype * 1000000 + (seq % 1000) * 1000 + data + 1
                end

                local function decodePacket(speed)
                    local v = math.floor(speed + 0.5)
                    if v < 1000001 or v > 4000000 then return nil end
                    v           = v - 1
                    local data  = v % 1000
                    v           = math.floor(v / 1000)
                    local seq   = v % 1000
                    local ptype = math.floor(v / 1000)
                    if ptype < 1 or ptype > 3 then return nil end
                    return ptype, seq, data
                end

                local function computeChecksum(bytes)
                    local h = 0
                    for i, b in ipairs(bytes) do h = (h * 31 + b + i) % 997 end
                    return h
                end

                local function getPlayingTracks(humanoid)
                    if not humanoid then return {} end
                    local animator = humanoid:FindFirstChildOfClass("Animator")
                    if not animator then return {} end
                    return animator:GetPlayingAnimationTracks()
                end

                local function ensureTrack(humanoid)
                    local tracks = getPlayingTracks(humanoid)
                    if #tracks > 0 then return tracks[1] end
                    local char = humanoid.Parent
                    if not char then return nil end
                    local animate = char:FindFirstChild("Animate")
                    if not animate then return nil end
                    local idle = animate:FindFirstChild("idle")
                    if not idle then return nil end
                    local anim = idle:FindFirstChildOfClass("Animation")
                    if not anim then return nil end
                    local animator = humanoid:FindFirstChildOfClass("Animator")
                    if not animator then
                        animator = Instance.new("Animator"); animator.Parent = humanoid
                    end
                    local track = animator:LoadAnimation(anim)
                    track.Looped = true
                    track:Play()
                    task.wait(0.5)
                    return track
                end

                
                
                
                local PopulateList
                local RefreshAdminPlayerList
                local RefreshPeersList
                local BuildCmdRows
                local ShowToast
                
                
                ShowToast                 = function(msg, kind)
                    pcall(function()
                        local col = nil
                        if kind == "danger" then
                            col = Color3.fromRGB(220, 65, 65)
                        elseif kind == "success" then
                            col = Color3.fromRGB(60, 200, 120)
                        end
                        sendNotif("Admin", msg, 4, col)
                    end)
                end
                local AddChatMessage
                local ShowIncomingPopup

                local adminSelectedPlayer = nil
                local activeCat           = 1
                local activePage          = nil
                local commPage            = nil
                local commChatView        = nil
                local commAdminView       = nil
                local commSubChatBtn      = nil
                local commSubPeersBtn     = nil
                local commSubAdminBtn     = nil
                local commPeersView       = nil
                local commActiveSubview   = "chat"
                local adminPage           = nil
                local peerCountLbl        = nil

                local function _hasAdminAccess()
                    return _isAdminUser
                        or AdminNames[tostring(LocalPlayer.Name)] == true
                        or AdminNames[tostring(LocalPlayer.UserId)] == true
                end

                local function showCommSubview(name)
                    if name == "admin" and not _hasAdminAccess() then name = "chat" end
                    commActiveSubview = name
                    if commChatView then commChatView.Visible = (name == "chat") end
                    if commPeersView then commPeersView.Visible = (name == "peers") end
                    if commAdminView then commAdminView.Visible = (name == "admin") end
                    local accent  = (_C and _C.Accent) or Color3.fromRGB(100, 160, 255)
                    local txtSub  = (_C and _C.TxtSub) or Color3.fromRGB(120, 120, 138)
                    local bgActive = (_C and _C.BG2) or Color3.fromRGB(26, 26, 33)
                    local bgInact  = (_C and _C.BG4) or Color3.fromRGB(38, 38, 48)
                    if commSubChatBtn then
                        local on = (name == "chat")
                        commSubChatBtn.BackgroundColor3 = on and bgActive or bgInact
                        commSubChatBtn.TextColor3 = on and accent or txtSub
                    end
                    if commSubPeersBtn then
                        local on = (name == "peers")
                        commSubPeersBtn.BackgroundColor3 = on and bgActive or bgInact
                        commSubPeersBtn.TextColor3 = on and accent or txtSub
                    end
                    if commSubAdminBtn then
                        local on = (name == "admin")
                        local gold = (_C and _C.Gold) or Color3.fromRGB(215, 175, 80)
                        local goldBg = (_C and _C.GoldD) or Color3.fromRGB(55, 42, 10)
                        commSubAdminBtn.BackgroundColor3 = on and goldBg or bgInact
                        commSubAdminBtn.TextColor3 = on and gold or txtSub
                    end
                    if name == "peers" and RefreshPeersList then task.defer(RefreshPeersList) end
                    if name == "admin" and RefreshAdminPlayerList then task.defer(RefreshAdminPlayerList) end
                end

                do

                    if not _settingsPanel or not _settingsScroll then return end
                    local subH                 = subArea.Size.Y.Offset
                    local totalH               = (CARD_H_S + 12) + subH + 8
                    local newPH                = math.min(SET_BASE_H + math.max(subH, 0), SET_MAX_H)
                    _settingsPanel.Size        = UDim2.new(0, PANEL_W, 0, newPH)
                    local scrollH              = newPH - SET_HDR_H
                    _settingsScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(totalH, scrollH))
                end

                switchCat = function(id)
                    for _, pg in pairs(subPages) do pg.Visible = false end
                    for _, cb in ipairs(catBtns) do
                        twP(cb.card, 0.15, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2 })
                        twP(cb.lbl, 0.15, { TextColor3 = C.sub or _C3_SUB })
                        cb.cStr.Color = C.bg3 or _C3_BG3; cb.cStr.Transparency = 0.3
                        cb.selBar.Visible = false
                        
                        if cb.iconRef then
                            pcall(function()
                                if not cb.iconRef:IsA("ImageLabel") then
                                    twP(cb.iconRef, 0.15, { TextColor3 = C.sub or _C3_SUB })
                                end
                            end)
                        end
                    end
                    if activeCat == id then
                        activeCat = nil
                        tw(subArea, 0.18, { Size = UDim2.new(1, 0, 0, 0) },
                            Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
                        if _settingsPanel then
                            tw(_settingsPanel, 0.18, { Size = UDim2.new(0, PANEL_W, 0, SET_BASE_H) },
                                Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
                        end
                        task.delay(0.20, _updateSubAreaCanvas)
                        return
                    end
                    activeCat = id
                    local pg = subPages[id]
                    if pg then
                        pg.Visible = true
                        local pgH = pg.Size.Y.Offset
                        local newPH = math.min(SET_BASE_H + pgH + 8, SET_MAX_H)
                        tw(subArea, 0.24, { Size = UDim2.new(1, 0, 0, pgH) },
                            Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                        if _settingsPanel then
                            tw(_settingsPanel, 0.24, { Size = UDim2.new(0, PANEL_W, 0, newPH) },
                                Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                        end
                        task.delay(0.26, _updateSubAreaCanvas)
                    end
                    for _, cb in ipairs(catBtns) do
                        if cb.id == id then
                            twP(cb.card, 0.20, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG4 })
                            twP(cb.lbl, 0.20, { TextColor3 = C.text })
                            cb.cStr.Color = cb.col; cb.cStr.Transparency = 0.5
                            cb.selBar.Visible = true
                            
                            if cb.iconRef then
                                pcall(function()
                                    if not cb.iconRef:IsA("ImageLabel") then
                                        twP(cb.iconRef, 0.20, { TextColor3 = cb.col })
                                    end
                                end)
                            end
                        end
                    end
                end
            local _ok_catsLoop = pcall(function()
                for i, cat in ipairs(CATS) do
                    local xOff = (i - 1) * (CARD_W_S + CARD_GAP)
                    local card = Instance.new("Frame", grid)
                    card.Size = UDim2.new(0, CARD_W_S, 0, CARD_H_S)
                    card.Position = UDim2.new(0, xOff, 0, 0)
                    card.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28); card.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                    1 or 0
                    card.BorderSizePixel = 0; corner(card, 12)
                    local cStr = _makeDummyStroke(card)
                    cStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                    1.5 or 1
                    cStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                    Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                    cStr.Transparency = 0.3
                    if _panelColorHooks then
                        _panelColorHooks[#_panelColorHooks + 1] = function()
                            pcall(function()
                                card.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                                1 or 0
                                cStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                                1.5 or 1
                                cStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                                Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                                cStr.Transparency = 0.3
                            end)
                        end
                    end
                    local selBar = Instance.new("Frame", card)
                    selBar.Size = UDim2.new(1, -16, 0, 2); selBar.Position = UDim2.new(0, 8, 0, 0)
                    selBar.BackgroundColor3 = (cat and cat.col) or Color3.fromRGB(0, 170, 255); selBar.BackgroundTransparency = 0
                    selBar.BorderSizePixel = 0; selBar.Visible = false; corner(selBar, 99)
                    
                    local _iconRef = nil
                    if cat.img then
                        local _iSz                     = cat.iconSize or 28
                        local iconImg                  = Instance.new("ImageLabel", card)
                        iconImg.Size                   = UDim2.new(0, _iSz, 0, _iSz)
                        iconImg.Position               = UDim2.new(0.5, -_iSz / 2, 0, -(_iSz / 2) + 29)
                        iconImg.BackgroundTransparency = 1
                        iconImg.Image                  = cat.img
                        iconImg.ImageColor3            = Color3.fromRGB(255, 255, 255)
                        iconImg.ScaleType              = Enum.ScaleType.Fit
                        iconImg.BorderSizePixel        = 0
                        _iconRef                       = iconImg
                    else
                        local icon = Instance.new("TextLabel", card)
                        icon.Size = UDim2.new(1, 0, 0, 32); icon.Position = UDim2.new(0, 0, 0, 8)
                        icon.BackgroundTransparency = 1; icon.Text = cat.icon or ""
                        icon.Font = Enum.Font.GothamBlack; icon.TextSize = 22
                        icon.TextColor3 = Color3.fromRGB(180, 180, 180); icon.TextXAlignment = Enum.TextXAlignment
                        .Center
                        _iconRef = icon
                    end
                    local lbl = Instance.new("TextLabel", card)
                    lbl.Size = UDim2.new(1, -4, 0, 16); lbl.Position = UDim2.new(0, 2, 1, -22)
                    lbl.BackgroundTransparency = 1; lbl.Text = cat.id:upper()
                    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
                    lbl.TextColor3 = C.sub or _C3_SUB; lbl.TextXAlignment = Enum.TextXAlignment.Center
                    local btn = Instance.new("TextButton", card)
                    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 6
                    local catId = cat.id
                    btn.MouseEnter:Connect(function()
                        if _isMobile then return end
                        _sc._playHoverSound()
                        if activeCat ~= catId then
                            twP(card, 0.1, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG4 })
                        end
                    end)
                    btn.MouseLeave:Connect(function()
                        if activeCat ~= catId then
                            twP(card, 0.1, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2 })
                        end
                    end)
                    btn.MouseButton1Click:Connect(function()
                        if _isMobile or _isTablet then return end 
                        switchCat(catId)
                    end)
                    btn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then switchCat(catId) end
                    end)
                    table.insert(catBtns,
                        { id = catId, card = card, lbl = lbl, selBar = selBar, cStr = cStr, col = cat.col, iconRef =
                        _iconRef })
                    
                    
                    if _iconRef then
                        pcall(function()
                            if not _iconRef:IsA("ImageLabel") then
                                _iconRef.TextColor3 = C.sub or _C3_SUB
                            end
                        end)
                    end
                end
            end) 
            
            if #catBtns > 0 then
                switchCat(catBtns[1].id)
            end
            end); if not _ok_Settings then warn("[TL] Settings-IIFE crashed: " .. tostring(_err_Settings)) end

    return p, c
end

return SettingsTab