--!nocheck
-- Standalone Module: CharacterTab
-- Extracted from TLMenu.lua

local CharacterTab = {}

function CharacterTab.Init(ctx)
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
    local C = ctx.C or {
        accent = Color3.fromRGB(0, 170, 255),
        accent2 = Color3.fromRGB(0, 200, 255),
        sub = Color3.fromRGB(150, 150, 150),
        text = Color3.fromRGB(255, 255, 255),
        panelBg = Color3.fromRGB(20, 20, 20),
        bg3 = Color3.fromRGB(40, 40, 40)
    }
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

                local p, c = makePanel("Character", C.accent)
                p.BackgroundColor3 = C.panelBg
                p.BackgroundTransparency = 0
                local _eg = p:FindFirstChildOfClass("UIGradient"); if _eg then _eg:Destroy() end
                local PAD = 16
                local PW  = PANEL_W - PAD * 2
                local CY  = 14
                local function divider(yPos)
                    local d = Instance.new("Frame", c)
                    d.Size = UDim2.new(1, -PAD * 2, 0, 1); d.Position = UDim2.new(0, PAD, 0, yPos)
                    d.BackgroundColor3 = C.bg3 or _C3_BG4
                    d.BackgroundTransparency = 0.2; d.BorderSizePixel = 0
                end
                local function sectionLbl(yPos, txt)
                    local lbl = Instance.new("TextLabel", c)
                    lbl.Size = UDim2.new(1, -PAD * 2, 0, 13); lbl.Position = UDim2.new(0, PAD, 0, yPos)
                    lbl.BackgroundTransparency = 1; lbl.Text = txt
                    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
                    lbl.TextColor3 = C.sub or _C3_SUB
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                end
                local CARD_H = 54
                local function makeSliderRow(yPos, label, sublabel, col, vMin, vMax, vDef, onToggle, onReset, onSlide)
                    local row = {}
                    local function liveCol() return _themePanelColor(col, C.accent) end

                    row.card = Instance.new("Frame", c)
                    row.card.Size = UDim2.new(1, -PAD * 2, 0, CARD_H)
                    row.card.Position = UDim2.new(0, PAD, 0, yPos)
                    row.card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    row.card.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                    0.45 or 0.15
                    row.card.BorderSizePixel = 0
                    corner(row.card, 12)
                    row.cStr = stroke(row.card, 1, C.bg3, 0.3)

                    local s = _makeRealStroke(row.card, 1.0, Color3.fromRGB(255, 255, 255), 0.6)
                    s.Name = "OnePiece_Stroke"
                    s.Enabled = _TL_isImgTheme(_TL_activeThemeId)

                    row.cdot = Instance.new("Frame", row.card)
                    row.cdot.Size = UDim2.new(0, 3, 0, CARD_H - 20)
                    row.cdot.Visible = false
                    row.cdot.Position = UDim2.new(0, 0, 0.5, -(CARD_H - 20) / 2)
                    row.cdot.BackgroundColor3 = liveCol()
                    row.cdot.BackgroundTransparency = 0.3
                    row.cdot.BorderSizePixel = 0
                    corner(row.cdot, 99)

                    row.nameLbl = Instance.new("TextLabel", row.card)
                    row.nameLbl.Size = UDim2.new(0, 120, 0, 18)
                    row.nameLbl.Position = UDim2.new(0, 14, 0, 8)
                    row.nameLbl.BackgroundTransparency = 1
                    row.nameLbl.Text = label
                    row.nameLbl.Font = Enum.Font.GothamBold
                    row.nameLbl.TextSize = 13
                    row.nameLbl.TextColor3 = C.text
                    row.nameLbl.TextXAlignment = Enum.TextXAlignment.Left

                    row.subLbl = Instance.new("TextLabel", row.card)
                    row.subLbl.Size = UDim2.new(0, 120, 0, 13)
                    row.subLbl.Position = UDim2.new(0, 14, 0, 26)
                    row.subLbl.BackgroundTransparency = 1
                    row.subLbl.Text = sublabel
                    row.subLbl.Font = Enum.Font.GothamBold
                    row.subLbl.TextSize = 9
                    row.subLbl.TextColor3 = C.sub
                    row.subLbl.TextXAlignment = Enum.TextXAlignment.Left

                    row.valLbl = Instance.new("TextLabel", row.card)
                    row.valLbl.Size = UDim2.new(0, 52, 0, 18)
                    row.valLbl.Position = UDim2.new(1, -100, 0, 8)
                    row.valLbl.BackgroundTransparency = 1
                    row.valLbl.Text = tostring(vDef)
                    row.valLbl.Font = Enum.Font.GothamBold
                    row.valLbl.TextSize = 13
                    row.valLbl.TextColor3 = liveCol()
                    row.valLbl.TextXAlignment = Enum.TextXAlignment.Left

                    row.rstBtn = Instance.new("TextButton", row.card)
                    row.rstBtn.Size = UDim2.new(0, 30, 0, 22)
                    row.rstBtn.Position = UDim2.new(1, -136, 0, 5)
                    row.rstBtn.BackgroundColor3 = C.bg3
                    row.rstBtn.BackgroundTransparency = 0.2
                    row.rstBtn.Text = "R"
                    row.rstBtn.Font = Enum.Font.GothamBold
                    row.rstBtn.TextSize = 11
                    row.rstBtn.TextColor3 = C.sub
                    row.rstBtn.ZIndex = 8
                    corner(row.rstBtn, 6)
                    row.rstStr = stroke(row.rstBtn, 1, C.bg3, 0.4)

                    row.rstBtn.MouseEnter:Connect(function()
                        twP(row.rstBtn, 0.1, { BackgroundColor3 = liveCol(), BackgroundTransparency = 0.6 })
                    end)
                    row.rstBtn.MouseLeave:Connect(function()
                        twP(row.rstBtn, 0.1, { BackgroundColor3 = C.bg3, BackgroundTransparency = 0.2 })
                    end)

                    row.track = Instance.new("Frame", row.card)
                    row.track.Size = UDim2.new(1, -28, 0, 4)
                    row.track.Position = UDim2.new(0, 14, 1, -14)
                    row.track.BackgroundColor3 = C.bg3
                    row.track.BackgroundTransparency = 0.4
                    row.track.ZIndex = 4
                    corner(row.track, 99)

                    row.fill = Instance.new("Frame", row.track)
                    row.fill.Size = UDim2.new((vDef - vMin) / (vMax - vMin), 0, 1, 0)
                    row.fill.BackgroundColor3 = liveCol()
                    row.fill.BorderSizePixel = 0
                    corner(row.fill, 99)

                    row.knob = Instance.new("Frame", row.track)
                    row.knob.Size = UDim2.new(0, 12, 0, 12)
                    row.knob.Position = UDim2.new((vDef - vMin) / (vMax - vMin), -6, 0.5, -6)
                    row.knob.BackgroundColor3 = Color3.new(1, 1, 1)
                    row.knob.ZIndex = 5
                    row.knob.BorderSizePixel = 0
                    corner(row.knob, 99)
                    row.kStr = stroke(row.knob, 1.5, liveCol(), 0)

                    local dragging, togState = false, false
                    local curVal = vDef
                    local sTargetV = (vDef - vMin) / (vMax - vMin)
                    local sVisualV = sTargetV

                    local function applyRatio(ratio)
                        ratio = math.clamp(ratio, 0, 1)
                        sTargetV = ratio  
                        curVal = math.floor(vMin + ratio * (vMax - vMin))
                        row.valLbl.Text = tostring(curVal)
                        if onSlide then onSlide(curVal, togState) end
                    end

                    task.spawn(function()
                        while row.card and row.card.Parent do
                            local dt = task.wait()
                            if not row.card.Visible then continue end
                            sVisualV = sVisualV + (sTargetV - sVisualV) * math.min(dt * 22, 1)
                            row.fill.Size = UDim2.new(sVisualV, 0, 1, 0)
                            row.knob.Position = UDim2.new(sVisualV, -6, 0.5, -6)
                            local p = 0.65 + math.sin(os.clock() * 5) * 0.35
                            row.knob.BackgroundTransparency = 0.05 * p
                            row.kStr.Transparency = 0.15 * p
                        end
                    end)

                    row.sliderBtn = Instance.new("TextButton", row.track)
                    row.sliderBtn.Size = UDim2.new(1, 80, 1, 60)
                    row.sliderBtn.Position = UDim2.new(0, -40, 0, -30)
                    row.sliderBtn.BackgroundTransparency = 1
                    row.sliderBtn.Text = ""
                    row.sliderBtn.ZIndex = 25

                    local function upSlider(ip)
                        if not row.track or not row.track.Parent then return end
                        local ratio = math.clamp((ip.X - row.track.AbsolutePosition.X) / row.track.AbsoluteSize.X, 0, 1)
                        applyRatio(ratio)
                    end

                    row.sliderBtn.InputBegan:Connect(function(ip)
                        if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            _sc._draggingSlider = true
                            upSlider(ip.Position)
                        end
                    end)
                    _SvcUIS.InputChanged:Connect(function(ip)
                        if dragging and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then
                            upSlider(ip.Position)
                        end
                    end)
                    row.sliderBtn.InputEnded:Connect(function(ip)
                        if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            _sc._draggingSlider = false
                        end
                    end)

                    row.togTrack = Instance.new("Frame", row.card)
                    row.togTrack.Size = UDim2.new(0, 32, 0, 18)
                    row.togTrack.Position = UDim2.new(1, -44, 0, 11)
                    row.togTrack.BackgroundColor3 = C.bg3 or _C3_BG3
                    row.togTrack.BackgroundTransparency = 0.2
                    row.togTrack.BorderSizePixel = 0
                    row.togTrack.ZIndex = 6
                    corner(row.togTrack, 99)

                    row.togKnob = Instance.new("Frame", row.togTrack)
                    row.togKnob.Size = UDim2.new(0, 12, 0, 12)
                    row.togKnob.Position = UDim2.new(0, 2, 0.5, -6)
                    row.togKnob.BackgroundColor3 = _C3_SUB2
                    row.togKnob.BorderSizePixel = 0
                    corner(row.togKnob, 99)

                    local function setToggle(on)
                        togState = on
                        if on then
                            twP(row.togTrack, 0.15, { BackgroundColor3 = liveCol(), BackgroundTransparency = 0.55 })
                            tw(row.togKnob, 0.15, { BackgroundColor3 = _C3_WHITE, Position = UDim2.new(1, -14, 0.5, -6) })
                                :Play()
                            twP(row.cStr, 0.15, { Color = liveCol(), Transparency = 0.5 })
                            pcall(function()
                                local sound = Instance.new("Sound")
                                sound.SoundId = "rbxassetid://136697607304800"
                                sound.Volume = 0.5
                                sound.Parent = workspace
                                sound:Play()
                                _SvcDeb:AddItem(sound, 2)
                            end)
                        else
                            twP(row.togTrack, 0.15, { BackgroundColor3 = C.bg3 or _C3_BG3, BackgroundTransparency = 0.2 })
                            tw(row.togKnob, 0.15, { BackgroundColor3 = _C3_SUB2, Position = UDim2.new(0, 2, 0.5, -6) })
                                :Play()
                            twP(row.cStr, 0.15, { Color = C.bg3 or _C3_BG3, Transparency = 0.3 })
                        end
                        if onToggle then onToggle(on, curVal) end
                    end

                    row.togBtn = Instance.new("TextButton", row.card)
                    row.togBtn.Size = UDim2.new(0, 44, 0, 28)
                    row.togBtn.Position = UDim2.new(1, -50, 0, 6)
                    row.togBtn.BackgroundTransparency = 1
                    row.togBtn.Text = ""
                    row.togBtn.ZIndex = 7

                    row.hitBtn = Instance.new("TextButton", row.card)
                    row.hitBtn.Size = UDim2.new(1, -156, 1, -22)
                    row.hitBtn.Position = UDim2.new(0, 0, 0, 0)
                    row.hitBtn.BackgroundTransparency = 1
                    row.hitBtn.Text = ""
                    row.hitBtn.ZIndex = 3

                    local togDebounce = false
                    local function toggleRow()
                        if togDebounce then return end
                        togDebounce = true
                        setToggle(not togState)
                        task.delay(0.2, function() togDebounce = false end)
                    end

                    row.togBtn.MouseButton1Click:Connect(toggleRow)
                    row.hitBtn.MouseButton1Click:Connect(toggleRow)
                    row.rstBtn.MouseButton1Click:Connect(function()
                        applyRatio((vDef - vMin) / (vMax - vMin))
                        if onReset then onReset(curVal) end
                    end)
                    row.card.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        if _TL_isImgTheme(_TL_activeThemeId) then
                            twP(row.card, 0.2, { BackgroundTransparency = 0.3 })
                        else
                            twP(row.card, 0.2, { BackgroundTransparency = 0.08 })
                        end
                    end)
                    row.card.MouseLeave:Connect(function()
                        if _TL_isImgTheme(_TL_activeThemeId) then
                            twP(row.card, 0.2, { BackgroundTransparency = 0.45 })
                        else
                            twP(row.card, 0.2, { BackgroundTransparency = 0.15 })
                        end
                    end)

                    if _panelColorHooks then
                        _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                            local ac = liveCol()
                            pcall(function() row.cdot.BackgroundColor3 = ac end)
                            pcall(function() row.fill.BackgroundColor3 = ac end)
                            pcall(function() row.kStr.Color = ac end)
                            pcall(function() row.valLbl.TextColor3 = ac end)
                            
                            pcall(function() row.nameLbl.TextColor3 = C.text end)
                            pcall(function() row.subLbl.TextColor3 = C.sub end)
                            pcall(function() row.rstBtn.TextColor3 = C.sub end)
                            pcall(function() row.rstBtn.BackgroundColor3 = C.bg3 end)
                            if togState then
                                pcall(function() row.togTrack.BackgroundColor3 = ac end)
                                pcall(function() row.cStr.Color = ac end)
                            end

                            pcall(function()
                                if newT then
                                    local isOP = _TL_isAnimeTheme(newT.id)
                                    row.card.BackgroundTransparency = isOP and 0.45 or 0.15
                                    if s then s.Enabled = isOP end
                                end
                            end)
                        end
                    end

                    return row.card, setToggle, function() return togState end
                end
                local TOG_H = 40
                local function makeToggleRow(yPos, label, sublabel, col, onToggle)
                    local _colIsStatic = (col == C.red or col == C.orange)
                    local function liveCol() return _colIsStatic and col or C.accent end
                    local card = Instance.new("Frame", c)
                    card.Size = UDim2.new(1, -PAD * 2, 0, TOG_H)
                    card.Position = UDim2.new(0, PAD, 0, yPos)
                    card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    card.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                    0.45 or 0.15
                    card.BorderSizePixel = 0
                    corner(card, 12)

                    local s = _makeRealStroke(card, 1.0, Color3.fromRGB(255, 255, 255), 0.6)
                    s.Name = "OnePiece_Stroke"
                    s.Enabled = _TL_isImgTheme(_TL_activeThemeId)

                    
                    local cStr = stroke(card, 1, C.bg3, 0.3)

                    local cdot = Instance.new("Frame", card)
                    cdot.Size = UDim2.new(0, 3, 0, TOG_H - 16); cdot.Visible = false
                    cdot.Position = UDim2.new(0, 0, 0.5, -(TOG_H - 16) / 2)
                    cdot.BackgroundColor3 = liveCol(); cdot.BackgroundTransparency = 0.3
                    cdot.BorderSizePixel = 0; corner(cdot, 99)

                    local nameLbl = Instance.new("TextLabel", card)
                    nameLbl.Size = UDim2.new(1, -60, 0, 18); nameLbl.Position = UDim2.new(0, 14, 0, 7)
                    nameLbl.BackgroundTransparency = 1; nameLbl.Text = label
                    nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13; nameLbl.TextColor3 = C.text
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

                    local subLbl = Instance.new("TextLabel", card)
                    subLbl.Size = UDim2.new(1, -60, 0, 13); subLbl.Position = UDim2.new(0, 14, 0, 25)
                    subLbl.BackgroundTransparency = 1; subLbl.Text = sublabel
                    subLbl.Font = Enum.Font.GothamBold; subLbl.TextSize = 9; subLbl.TextColor3 = C.sub
                    subLbl.TextXAlignment = Enum.TextXAlignment.Left

                    local togTrack = Instance.new("Frame", card)
                    togTrack.Size = UDim2.new(0, 32, 0, 18); togTrack.Position = UDim2.new(1, -46, 0.5, -9)
                    togTrack.BackgroundColor3 = C.bg3; togTrack.BackgroundTransparency = 0.1; corner(togTrack, 99)

                    local togKnob = Instance.new("Frame", togTrack)
                    togKnob.Size = UDim2.new(0, 12, 0, 12); togKnob.Position = UDim2.new(0, 2, 0.5, -6)
                    togKnob.BackgroundColor3 = C.sub; togKnob.BackgroundTransparency = 0; corner(togKnob, 99)

                    local togState = false
                    local function setToggle(on)
                        togState = on
                        if on then
                            twP(togTrack, 0.15, { BackgroundColor3 = liveCol(), BackgroundTransparency = 0.4 })
                            tw(togKnob, 0.15, { BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.new(1, -14, 0.5,
                                -6) }):Play()
                            pcall(function()
                                local sound = Instance.new("Sound", workspace)
                                sound.SoundId = "rbxassetid://136697607304800"; sound.Volume = 0.4; sound:Play()
                                game:GetService("Debris"):AddItem(sound, 1)
                            end)
                        else
                            twP(togTrack, 0.15, { BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1 })
                            tw(togKnob, 0.15, { BackgroundColor3 = C.sub, Position = UDim2.new(0, 2, 0.5, -6) }):Play()
                        end
                        if onToggle then onToggle(on) end
                    end

                    local btn = Instance.new("TextButton", card)
                    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 10
                    btn.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        if _TL_isImgTheme(_TL_activeThemeId) then
                            twP(card, 0.2, { BackgroundTransparency = 0.3 })
                        else
                            twP(card, 0.2, { BackgroundTransparency = 0.08 })
                        end
                    end)
                    btn.MouseLeave:Connect(function()
                        if _TL_isImgTheme(_TL_activeThemeId) then
                            twP(card, 0.2, { BackgroundTransparency = 0.45 })
                        else
                            twP(card, 0.2, { BackgroundTransparency = 0.15 })
                        end
                    end)
                    btn.MouseButton1Click:Connect(function() setToggle(not togState) end)

                    
                    if _panelColorHooks then
                        _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                            local ac = liveCol()
                            pcall(function() cdot.BackgroundColor3 = ac end)
                            
                            pcall(function() nameLbl.TextColor3 = C.text end)
                            pcall(function() subLbl.TextColor3 = C.sub end)
                            if togState then
                                pcall(function() togTrack.BackgroundColor3 = ac end)
                                pcall(function() cStr.Color = ac end)
                            else
                                pcall(function() togTrack.BackgroundColor3 = C.bg3 end)
                            end

                            pcall(function()
                                if newT then
                                    local isOP = _TL_isAnimeTheme(newT.id)
                                    card.BackgroundTransparency = isOP and 0.45 or 0.15
                                    if s then s.Enabled = isOP end
                                end
                            end)
                        end
                    end
                    return card, setToggle
                end
                local GAP = 8
                
                do
                    local QA_ITEMS                = {
                        { id = "rejoin",  label = "Rejoin",  sub = "Reconnect" },
                        { id = "respawn", label = "Respawn", sub = "(Same Position)" },
                    }
                    local QA_GAP                  = 8
                    local QA_W                    = math.floor((PANEL_W - PAD * 2 - QA_GAP * (#QA_ITEMS - 1)) / #
                    QA_ITEMS)
                    local QA_H                    = 46
                    qaCard                        = Instance.new("Frame", c)
                    qaCard.Size                   = UDim2.new(1, 0, 0, QA_H + 26)
                    qaCard.Position               = UDim2.new(0, 0, 0, CY)
                    qaCard.BackgroundTransparency = 1
                    qaCard.BorderSizePixel        = 0
                    qaLbl                         = Instance.new("TextLabel", qaCard)
                    qaLbl.Size                    = UDim2.new(1, -16, 0, 18)
                    qaLbl.Position                = UDim2.new(0, PAD, 0, 0)
                    qaLbl.BackgroundTransparency  = 1
                    qaLbl.Text                    = "Quick Actions"
                    qaLbl.Font                    = Enum.Font.GothamBold
                    qaLbl.TextSize                = 12
                    qaLbl.TextColor3              = C.sub
                    qaLbl.TextXAlignment          = Enum.TextXAlignment.Left
                    for i, qa in ipairs(QA_ITEMS) do
                        local xOff                  = PAD + (i - 1) * (QA_W + QA_GAP)
                        local chip                  = Instance.new("Frame", qaCard)
                        chip.Size                   = UDim2.new(0, QA_W, 0, QA_H)
                        chip.Position               = UDim2.new(0, xOff, 0, 22)
                        chip.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
                        chip.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                        0.45 or 0.2
                        chip.BorderSizePixel        = 0; corner(chip, 10)

                        local s                       = _makeRealStroke(chip, 1.0, Color3.fromRGB(255, 255, 255), 0.6)
                        s.Name                        = "OnePiece_Stroke"
                        s.Enabled                     = _TL_isImgTheme(_TL_activeThemeId)

                        local lbl                     = Instance.new("TextLabel", chip)
                        lbl.Size                      = UDim2.new(1, -4, 0, 16)
                        lbl.Position                  = UDim2.new(0, 2, 0, 10)
                        lbl.BackgroundTransparency    = 1
                        lbl.Text                      = qa.label
                        lbl.Font                      = Enum.Font.GothamBold
                        lbl.TextSize                  = 11
                        lbl.TextColor3                = C.sub or _C3_SUB
                        lbl.TextXAlignment            = Enum.TextXAlignment.Center
                        local subLbl                  = Instance.new("TextLabel", chip)
                        subLbl.Size                   = UDim2.new(1, -4, 0, 12)
                        subLbl.Position               = UDim2.new(0, 2, 1, -18)
                        subLbl.BackgroundTransparency = 1
                        subLbl.Text                   = qa.sub
                        subLbl.Font                   = Enum.Font.GothamBold
                        subLbl.TextSize               = 9
                        subLbl.TextColor3             = C.sub or _C3_SUB
                        subLbl.TextXAlignment         = Enum.TextXAlignment.Center
                        local btn                     = Instance.new("TextButton", chip)
                        btn.Size                      = UDim2.new(1, 0, 1, 0)
                        btn.BackgroundTransparency    = 1; btn.Text = ""; btn.ZIndex = 10

                        btn.MouseEnter:Connect(function()
                            _sc._playHoverSound()
                            if _TL_isImgTheme(_TL_activeThemeId) then
                                twP(chip, 0.2, { BackgroundTransparency = 0.3 })
                            end
                        end)
                        btn.MouseLeave:Connect(function()
                            if _TL_isImgTheme(_TL_activeThemeId) then
                                twP(chip, 0.2, { BackgroundTransparency = 0.45 })
                            end
                        end)

                        if _panelColorHooks then
                            _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                                pcall(function()
                                    if newT then
                                        local isOP = _TL_isAnimeTheme(newT.id)
                                        chip.BackgroundTransparency = isOP and 0.45 or 0.2
                                        if s then s.Enabled = isOP end
                                    end
                                end)
                            end
                        end
                        local captId = qa.id
                        local function activate()
                            
                            twP(chip, 0.08, { BackgroundColor3 = Color3.fromRGB(5, 5, 5) })
                            twP(lbl, 0.08, { TextColor3 = C.accent or _C3_TEXT3 })
                            twP(subLbl, 0.08, { TextColor3 = C.text })
                            task.delay(0.22, function()
                                twP(chip, 0.15, { BackgroundColor3 = Color3.fromRGB(0, 0, 0) })
                                twP(lbl, 0.15, { TextColor3 = C.sub or _C3_SUB })
                                twP(subLbl, 0.15, { TextColor3 = C.sub or _C3_SUB })
                            end)
                            if captId == "rejoin" then
                                pcall(function()
                                    local TS = game:GetService("TeleportService")
                                    local placeId = game.PlaceId
                                    local Players2 = _SvcPlr
                                    TS:Teleport(placeId, Players2.LocalPlayer)
                                end)
                            end
                            if captId == "respawn" then
                                task.spawn(function()
                                    local char    = LocalPlayer.Character
                                    local hrp     = char and char:FindFirstChild("HumanoidRootPart")
                                    local savedCF = hrp and hrp.CFrame
                                    local hum     = char and char:FindFirstChildOfClass("Humanoid")

                                    -- 1) Fly-Zustand sofort beenden
                                    if flyActive then
                                        flyActive = false
                                        pcall(function() if _flyMod and _flyMod.stop then _flyMod.stop() end end)
                                        pcall(_flyMuteSounds, false)
                                        pcall(function() if _flyPanelSetFn then _flyPanelSetFn(false) end end)
                                    end

                                    -- 2) Godmode aktiv? -> erst deaktivieren damit Tod möglich ist
                                    pcall(function()
                                        if hum then
                                            hum.BreakJointsOnDeath = true
                                            hum.RequiresNeck       = true
                                            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                                            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                                            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                                            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                                            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                                        end
                                    end)
                                    pcall(function() if type(godStop) == "function" then godStop() end end)
                                    pcall(function() if _TL_refs._TL_isGodOn and _TL_refs._TL_isGodOn() then godStop() end end)

                                    -- 3) Positionswiederherstellung VOR dem Tod registrieren
                                    local _respawnDone = false
                                    local function _restorePosition(newChar)
                                        if _respawnDone then return end
                                        _respawnDone = true
                                        if not savedCF then return end
                                        local tries = 0
                                        local function trySet()
                                            tries = tries + 1
                                            local nHrp = newChar:FindFirstChild("HumanoidRootPart")
                                                or newChar:WaitForChild("HumanoidRootPart", 5)
                                            if nHrp then
                                                pcall(function() nHrp.CFrame = savedCF end)
                                                task.delay(0.1, function()
                                                    pcall(function() nHrp.CFrame = savedCF end)
                                                end)
                                                task.delay(0.4, function()
                                                    pcall(function() nHrp.CFrame = savedCF end)
                                                end)
                                            elseif tries < 10 then
                                                task.delay(0.3, trySet)
                                            end
                                        end
                                        trySet()
                                    end

                                    local conn
                                    conn = LocalPlayer.CharacterAdded:Connect(function(newChar)
                                        if conn then pcall(function() conn:Disconnect() end) end
                                        _restorePosition(newChar)
                                    end)

                                    -- Safety: falls CharacterAdded nie feuert, nach 6s aufräumen
                                    task.delay(6, function()
                                        if not _respawnDone then
                                            _respawnDone = true
                                            pcall(function() if conn then conn:Disconnect() end end)
                                        end
                                    end)

                                    -- 4) Tod erzwingen – mehrere Methoden parallel
                                    local function forceKill(h)
                                        if not h or not h.Parent then return end
                                        -- Methode A: Health auf 0
                                        pcall(function() h.Health = 0 end)
                                        -- Methode B: BreakJointsOn_death
                                        pcall(function() h:ChangeState(Enum.HumanoidStateType.Dead) end)
                                    end

                                    local function killByRemovingParts(c)
                                        if not c or not c.Parent then return end
                                        pcall(function()
                                            local neck = c:FindFirstChild("Neck")
                                            if not neck then
                                                local upperTorso = c:FindFirstChild("UpperTorso")
                                                if upperTorso then neck = upperTorso:FindFirstChild("Neck") end
                                            end
                                            if neck then neck:Destroy() end
                                        end)
                                        pcall(function()
                                            local rootJoint = c:FindFirstChild("HumanoidRootPart")
                                            if rootJoint then
                                                local joint = rootJoint:FindFirstChild("RootJoint")
                                                if joint then joint:Destroy() end
                                            end
                                        end)
                                    end

                                    -- Sofort versuchen
                                    forceKill(hum)
                                    task.wait(0.15)

                                    -- Nochmal versuchen (frischer Humanoid nach Evolve/Transform)
                                    local hum3 = char and char:FindFirstChildOfClass("Humanoid")
                                    if hum3 and hum3.Health > 0 then
                                        forceKill(hum3)
                                        task.wait(0.2)
                                    end

                                    -- Fallback: Char-Teile entfernen
                                    local hum4 = char and char:FindFirstChildOfClass("Humanoid")
                                    if hum4 and hum4.Health > 0 then
                                        killByRemovingParts(char)
                                        task.wait(0.3)
                                    end

                                    -- Letzter Ausweg: LoadCharacter (Position wird danach wiederhergestellt)
                                    local hum5 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                                    if hum5 and hum5.Health > 0 then
                                        pcall(function() LocalPlayer:LoadCharacter() end)
                                        -- Position auch nach LoadCharacter wiederherstellen
                                        if savedCF then
                                            task.delay(1, function()
                                                local newChar = LocalPlayer.Character
                                                local nHrp = newChar and newChar:FindFirstChild("HumanoidRootPart")
                                                if nHrp then
                                                    pcall(function() nHrp.CFrame = savedCF end)
                                                    task.delay(0.2, function()
                                                        pcall(function() nHrp.CFrame = savedCF end)
                                                    end)
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end
                            if captId == "r6anim" then
                                task.spawn(function()
                                    local plr = _SvcPlr.LocalPlayer

                                                
            
            
local function RunCustomAnimation(Char)
                                        if Char:WaitForChild("Animate") ~= nil then
                                            Char.Animate.Disabled = true
                                        end
                                        Char:WaitForChild("Humanoid")
                                        for i, v in next, Char.Humanoid:GetPlayingAnimationTracks() do
                                            v:Stop()
                                        end
                                        local script = Char.Animate
                                        local Character = Char
                                        local Humanoid = Character:WaitForChild("Humanoid")
                                        local pose = "Standing"
                                        local UserGameSettings = UserSettings():GetService("UserGameSettings")
                                        local userNoUpdateOnLoopSuccess, userNoUpdateOnLoopValue = pcall(function() return
                                            UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop") end)
                                        local AnimationSpeedDampeningObject = script:FindFirstChild(
                                        "ScaleDampeningPercent")
                                        local HumanoidHipHeight = 2
                                        local humanoidSpeed = 0
                                        local cachedRunningSpeed = 0
                                        local cachedLocalDirection = { x = 0.0, y = 0.0 }
                                        local smallButNotZero = 0.0001
                                        local runBlendtime = 0.2
                                        local lastBlendTime = 0
                                        local WALK_SPEED = 6.4
                                        local RUN_SPEED = 12.8
                                        local EMOTE_TRANSITION_TIME = 0.1
                                        local currentAnim = ""
                                        local currentAnimInstance = nil
                                        local currentAnimTrack = nil
                                        local currentAnimKeyframeHandler = nil
                                        local currentAnimSpeed = 1.0
                                        local PreloadedAnims = {}
                                        local animTable = {}
                                        local animNames = {
                                            idle      = { { id = "http://www.roblox.com/asset/?id=12521158637", weight = 9 }, { id = "http://www.roblox.com/asset/?id=12521162526", weight = 1 } },
                                            walk      = { { id = "http://www.roblox.com/asset/?id=12518152696", weight = 10 } },
                                            run       = { { id = "http://www.roblox.com/asset/?id=12518152696", weight = 10 } },
                                            jump      = { { id = "http://www.roblox.com/asset/?id=12520880485", weight = 10 } },
                                            fall      = { { id = "http://www.roblox.com/asset/?id=12520972571", weight = 10 } },
                                            climb     = { { id = "http://www.roblox.com/asset/?id=12520982150", weight = 10 } },
                                            sit       = { { id = "http://www.roblox.com/asset/?id=12520993168", weight = 10 } },
                                            toolnone  = { { id = "http://www.roblox.com/asset/?id=12520996634", weight = 10 } },
                                            toolslash = { { id = "http://www.roblox.com/asset/?id=12520999032", weight = 10 } },
                                            toollunge = { { id = "http://www.roblox.com/asset/?id=12521002003", weight = 10 } },
                                            wave      = { { id = "http://www.roblox.com/asset/?id=12521004586", weight = 10 } },
                                            point     = { { id = "http://www.roblox.com/asset/?id=12521007694", weight = 10 } },
                                            dance     = { { id = "http://www.roblox.com/asset/?id=12521009666", weight = 10 }, { id = "http://www.roblox.com/asset/?id=12521151637", weight = 10 }, { id = "http://www.roblox.com/asset/?id=12521015053", weight = 10 } },
                                            dance2    = { { id = "http://www.roblox.com/asset/?id=12521169800", weight = 10 }, { id = "http://www.roblox.com/asset/?id=12521173533", weight = 10 }, { id = "http://www.roblox.com/asset/?id=12521027874", weight = 10 } },
                                            dance3    = { { id = "http://www.roblox.com/asset/?id=12521178362", weight = 10 }, { id = "http://www.roblox.com/asset/?id=12521181508", weight = 10 }, { id = "http://www.roblox.com/asset/?id=12521184133", weight = 10 } },
                                            laugh     = { { id = "http://www.roblox.com/asset/?id=12521018724", weight = 10 } },
                                            cheer     = { { id = "http://www.roblox.com/asset/?id=12521021991", weight = 10 } },
                                        }
                                        local strafingLocomotionMap = {}
                                        local fallbackLocomotionMap = {}
                                        local locomotionMap = strafingLocomotionMap
                                        local emoteNames = { wave = false, point = false, dance = true, dance2 = true, dance3 = true, laugh = false, cheer = false }
                                        math.randomseed(tick())

                                        local function configureAnimationSet(name, fileList)
                                            if animTable[name] ~= nil then
                                                for _, connection in pairs(animTable[name].connections) do connection
                                                        :disconnect() end
                                            end
                                            animTable[name] = { count = 0, totalWeight = 0, connections = {} }
                                            if name == "run" or name == "walk" then
                                                local speed = name == "run" and RUN_SPEED or WALK_SPEED
                                                fallbackLocomotionMap[name] = { lv = Vector2.new(0.0, speed), speed =
                                                speed }
                                                locomotionMap = fallbackLocomotionMap
                                            end
                                            if animTable[name].count <= 0 then
                                                for idx, anim in pairs(fileList) do
                                                    animTable[name][idx] = {}
                                                    animTable[name][idx].anim = Instance.new("Animation")
                                                    animTable[name][idx].anim.Name = name
                                                    animTable[name][idx].anim.AnimationId = anim.id
                                                    animTable[name][idx].weight = anim.weight
                                                    animTable[name].count = animTable[name].count + 1
                                                    animTable[name].totalWeight = animTable[name].totalWeight +
                                                    anim.weight
                                                end
                                            end
                                            for i, animType in pairs(animTable) do
                                                for idx = 1, animType.count, 1 do
                                                    if PreloadedAnims[animType[idx].anim.AnimationId] == nil then
                                                        Humanoid:LoadAnimation(animType[idx].anim)
                                                        PreloadedAnims[animType[idx].anim.AnimationId] = true
                                                    end
                                                end
                                            end
                                        end

                                        local function scriptChildModified(child)
                                            local fileList = animNames[child.Name]
                                            if fileList ~= nil then
                                                configureAnimationSet(child.Name, fileList)
                                            else
                                                if child:isA("StringValue") then
                                                    animNames[child.Name] = {}
                                                    configureAnimationSet(child.Name, animNames[child.Name])
                                                end
                                            end
                                        end

                                        script.ChildAdded:connect(scriptChildModified)
                                        script.ChildRemoved:connect(scriptChildModified)

                                        local animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator") or nil
                                        if animator then
                                            local animTracks = animator:GetPlayingAnimationTracks()
                                            for i, track in ipairs(animTracks) do
                                                track:Stop(0); track:Destroy()
                                            end
                                        end

                                        for name, fileList in pairs(animNames) do configureAnimationSet(name, fileList) end
                                        for _, child in script:GetChildren() do
                                            if child:isA("StringValue") and not animNames[child.name] then
                                                animNames[child.Name] = {}
                                                configureAnimationSet(child.Name, animNames[child.Name])
                                            end
                                        end

                                        local toolAnim = "None"
                                        local toolAnimTime = 0
                                        local jumpAnimTime = 0
                                        local jumpAnimDuration = 0.31
                                        local toolTransitionTime = 0.1
                                        local fallTransitionTime = 0.2
                                        local currentlyPlayingEmote = false

                                        local function getHeightScale()
                                            if Humanoid then
                                                if not Humanoid.AutomaticScalingEnabled then return 1 end
                                                local scale = Humanoid.HipHeight / HumanoidHipHeight
                                                if AnimationSpeedDampeningObject == nil then
                                                    AnimationSpeedDampeningObject = script:FindFirstChild(
                                                    "ScaleDampeningPercent")
                                                end
                                                if AnimationSpeedDampeningObject ~= nil then
                                                    scale = 1 +
                                                    (Humanoid.HipHeight - HumanoidHipHeight) *
                                                    AnimationSpeedDampeningObject.Value / HumanoidHipHeight
                                                end
                                                return scale
                                            end
                                            return 1
                                        end

                                        local function signedAngle(a, b)
                                            return -math.atan2(a.x * b.y - a.y * b.x, a.x * b.x + a.y * b.y)
                                        end

                                        local angleWeight = 2.0
                                        local function get2DWeight(px, p1, p2, sx, s1, s2)
                                            local avgLength = 0.5 * (s1 + s2)
                                            local p_1 = { x = (sx - s1) / avgLength, y = (angleWeight * signedAngle(p1, px)) }
                                            local p12 = { x = (s2 - s1) / avgLength, y = (angleWeight * signedAngle(p1, p2)) }
                                            local denom = smallButNotZero + (p12.x * p12.x + p12.y * p12.y)
                                            local numer = p_1.x * p12.x + p_1.y * p12.y
                                            local r = math.clamp(1.0 - numer / denom, 0.0, 1.0)
                                            return r
                                        end

                                        local function blend2D(targetVelo, targetSpeed)
                                            local h = {}
                                            local sum = 0.0
                                            for n, v1 in pairs(locomotionMap) do
                                                if targetVelo.x * v1.lv.x < 0.0 or targetVelo.y * v1.lv.y < 0 then
                                                    h[n] = 0.0; continue
                                                end
                                                h[n] = math.huge
                                                for j, v2 in pairs(locomotionMap) do
                                                    if targetVelo.x * v2.lv.x < 0.0 or targetVelo.y * v2.lv.y < 0 then continue end
                                                    h[n] = math.min(h[n],
                                                        get2DWeight(targetVelo, v1.lv, v2.lv, targetSpeed, v1.speed,
                                                            v2.speed))
                                                end
                                                sum = sum + h[n]
                                            end
                                            local sum2 = 0.0
                                            local weightedVeloX, weightedVeloY = 0, 0
                                            for n, v in pairs(locomotionMap) do
                                                if (h[n] / sum > 0.1) then
                                                    sum2 = sum2 + h[n]; weightedVeloX = weightedVeloX + h[n] * v.lv.x; weightedVeloY =
                                                    weightedVeloY + h[n] * v.lv.y
                                                else
                                                    h[n] = 0.0
                                                end
                                            end
                                            local animSpeed
                                            local wss = weightedVeloX * weightedVeloX + weightedVeloY * weightedVeloY
                                            if wss > smallButNotZero then animSpeed = math.sqrt(targetSpeed * targetSpeed /
                                                wss) else animSpeed = 0 end
                                            animSpeed = animSpeed / getHeightScale()
                                            local groupTimePosition = 0
                                            for n, v in pairs(locomotionMap) do if v.track and v.track.IsPlaying then
                                                    groupTimePosition = v.track.TimePosition; break
                                                end end
                                            for n, v in pairs(locomotionMap) do
                                                if h[n] > 0.0 then
                                                    if v.track and not v.track.IsPlaying then
                                                        v.track:Play(runBlendtime); v.track.TimePosition =
                                                        groupTimePosition
                                                    end
                                                    if v.track then
                                                        local w = math.max(smallButNotZero, h[n] / sum2); v.track
                                                            :AdjustWeight(w, runBlendtime); v.track:AdjustSpeed(
                                                        animSpeed)
                                                    end
                                                else
                                                    if v.track then v.track:Stop(runBlendtime) end
                                                end
                                            end
                                        end

                                        local function getWalkDirection()
                                            local walkToPoint = Humanoid.WalkToPoint; local walkToPart = Humanoid
                                            .WalkToPart
                                            if Humanoid.MoveDirection ~= Vector3.zero then
                                                return Humanoid.MoveDirection
                                            elseif walkToPart or walkToPoint ~= Vector3.zero then
                                                local destination = walkToPart and
                                                walkToPart.CFrame:PointToWorldSpace(walkToPoint) or walkToPoint
                                                local moveVector = Vector3.zero
                                                if Humanoid.RootPart then
                                                    moveVector = destination - Humanoid.RootPart.CFrame.Position
                                                    moveVector = Vector3.new(moveVector.x, 0.0, moveVector.z)
                                                    local mag = moveVector.Magnitude
                                                    if mag > 0.01 then moveVector = moveVector / mag end
                                                end
                                                return moveVector
                                            else
                                                return Humanoid.MoveDirection
                                            end
                                        end

                                        local function updateVelocity(currentTime)
                                            if locomotionMap == strafingLocomotionMap then
                                                local moveDirection = getWalkDirection()
                                                if not Humanoid.RootPart then return end
                                                local cframe = Humanoid.RootPart.CFrame
                                                if math.abs(cframe.UpVector.Y) < smallButNotZero or pose ~= "Running" or humanoidSpeed < 0.001 then
                                                    for n, v in pairs(locomotionMap) do if v.track then v.track
                                                                :AdjustWeight(smallButNotZero, runBlendtime) end end
                                                    return
                                                end
                                                local lookat = cframe.LookVector
                                                local direction = Vector3.new(lookat.X, 0.0, lookat.Z); direction =
                                                direction / direction.Magnitude
                                                local ly = moveDirection:Dot(direction)
                                                if ly <= 0.0 and ly > -0.05 then ly = smallButNotZero end
                                                local lx = direction.X * moveDirection.Z - direction.Z * moveDirection.X
                                                local tempDir2 = Vector2.new(lx, ly)
                                                local delta = Vector2.new(tempDir2.x - cachedLocalDirection.x,
                                                    tempDir2.y - cachedLocalDirection.y)
                                                if delta:Dot(delta) > 0.001 or math.abs(humanoidSpeed - cachedRunningSpeed) > 0.01 or currentTime - lastBlendTime > 1 then
                                                    cachedLocalDirection = tempDir2; cachedRunningSpeed = humanoidSpeed; lastBlendTime =
                                                    currentTime; blend2D(cachedLocalDirection, cachedRunningSpeed)
                                                end
                                            else
                                                if math.abs(humanoidSpeed - cachedRunningSpeed) > 0.01 or currentTime - lastBlendTime > 1 then
                                                    cachedRunningSpeed = humanoidSpeed; lastBlendTime = currentTime; blend2D(
                                                    Vector2.yAxis, cachedRunningSpeed)
                                                end
                                            end
                                        end

                                        local function stopAllAnimations()
                                            local oldAnim = currentAnim
                                            if emoteNames[oldAnim] ~= nil and emoteNames[oldAnim] == false then oldAnim =
                                                "idle" end
                                            if currentlyPlayingEmote then
                                                oldAnim = "idle"; currentlyPlayingEmote = false
                                            end
                                            currentAnim = ""; currentAnimInstance = nil
                                            if currentAnimKeyframeHandler ~= nil then currentAnimKeyframeHandler
                                                    :disconnect() end
                                            if currentAnimTrack ~= nil then
                                                currentAnimTrack:Stop(); currentAnimTrack:Destroy(); currentAnimTrack = nil
                                            end
                                            for _, v in pairs(locomotionMap) do if v.track then
                                                    v.track:Stop(); v.track:Destroy(); v.track = nil
                                                end end
                                            return oldAnim
                                        end

                                        local function setAnimationSpeed(speed)
                                            if currentAnim ~= "walk" then
                                                if speed ~= currentAnimSpeed then
                                                    currentAnimSpeed = speed; currentAnimTrack:AdjustSpeed(
                                                    currentAnimSpeed)
                                                end
                                            end
                                        end

                                        local function rollAnimation(animName)
                                            local roll = math.random(1, animTable[animName].totalWeight)
                                            local idx = 1
                                            while roll > animTable[animName][idx].weight do
                                                roll = roll - animTable[animName][idx].weight; idx = idx + 1
                                            end
                                            return idx
                                        end

                                        local function destroyRunAnimations()
                                            for _, v in pairs(strafingLocomotionMap) do if v.track then
                                                    v.track:Stop(); v.track:Destroy(); v.track = nil
                                                end end
                                            for _, v in pairs(fallbackLocomotionMap) do if v.track then
                                                    v.track:Stop(); v.track:Destroy(); v.track = nil
                                                end end
                                            cachedRunningSpeed = 0
                                        end

                                        local maxVeloX, minVeloX, maxVeloY, minVeloY

                                        local function resetVelocityBounds()
                                            minVeloX = 0; maxVeloX = 0; minVeloY = 0; maxVeloY = 0
                                        end
                                        local function updateVelocityBounds(velo)
                                            if velo then
                                                if velo.x > maxVeloX then maxVeloX = velo.x end; if velo.y > maxVeloY then maxVeloY =
                                                    velo.y end
                                                if velo.x < minVeloX then minVeloX = velo.x end; if velo.y < minVeloY then minVeloY =
                                                    velo.y end
                                            end
                                        end
                                        local function checkVelocityBounds()
                                            if maxVeloX == 0 or minVeloX == 0 or maxVeloY == 0 or minVeloY == 0 then
                                                locomotionMap = fallbackLocomotionMap
                                            else
                                                locomotionMap = strafingLocomotionMap
                                            end
                                        end
                                        local function setupWalkAnimation(anim, animName, transitionTime, humanoid)
                                            resetVelocityBounds()
                                            for n, v in pairs(locomotionMap) do
                                                v.track = humanoid:LoadAnimation(animTable[n][1].anim); v.track.Priority =
                                                Enum.AnimationPriority.Core; updateVelocityBounds(v.lv)
                                            end
                                            checkVelocityBounds()
                                        end

                                        local function keyFrameReachedFunc(frameName)
                                            if frameName == "End" then
                                                local repeatAnim = currentAnim
                                                if emoteNames[repeatAnim] ~= nil and emoteNames[repeatAnim] == false then repeatAnim =
                                                    "idle" end
                                                if currentlyPlayingEmote then
                                                    if currentAnimTrack.Looped then return end
                                                    repeatAnim = "idle"; currentlyPlayingEmote = false
                                                end
                                                local animSpeed = currentAnimSpeed
                                                playAnimation(repeatAnim, 0.15, Humanoid); setAnimationSpeed(animSpeed)
                                            end
                                        end

                                        local function switchToAnim(anim, animName, transitionTime, humanoid)
                                            if anim ~= currentAnimInstance then
                                                if currentAnimTrack ~= nil then
                                                    currentAnimTrack:Stop(transitionTime); currentAnimTrack:Destroy()
                                                end
                                                if currentAnimKeyframeHandler ~= nil then currentAnimKeyframeHandler
                                                        :disconnect() end
                                                currentAnimSpeed = 1.0; currentAnim = animName; currentAnimInstance =
                                                anim
                                                if animName == "walk" then
                                                    setupWalkAnimation(anim, animName, transitionTime, humanoid)
                                                else
                                                    destroyRunAnimations()
                                                    currentAnimTrack = humanoid:LoadAnimation(anim); currentAnimTrack.Priority =
                                                    Enum.AnimationPriority.Core
                                                    currentAnimTrack:Play(transitionTime)
                                                    currentAnimKeyframeHandler = currentAnimTrack.KeyframeReached
                                                    :connect(keyFrameReachedFunc)
                                                end
                                            end
                                        end

                                        function playAnimation(animName, transitionTime, humanoid)
                                            local idx = rollAnimation(animName); local anim = animTable[animName][idx]
                                            .anim
                                            switchToAnim(anim, animName, transitionTime, humanoid); currentlyPlayingEmote = false
                                        end

                                        function playEmote(emoteAnim, transitionTime, humanoid)
                                            switchToAnim(emoteAnim, emoteAnim.Name, transitionTime, humanoid); currentlyPlayingEmote = true
                                        end

                                        local toolAnimName = ""; local toolAnimTrack = nil; local toolAnimInstance = nil; local currentToolAnimKeyframeHandler = nil
                                        local function toolKeyFrameReachedFunc(frameName)
                                            if frameName == "End" then playToolAnimation(toolAnimName, 0.0, Humanoid) end
                                        end
                                        function playToolAnimation(animName, transitionTime, humanoid, priority)
                                            local idx = rollAnimation(animName); local anim = animTable[animName][idx]
                                            .anim
                                            if toolAnimInstance ~= anim then
                                                if toolAnimTrack ~= nil then
                                                    toolAnimTrack:Stop(); toolAnimTrack:Destroy(); transitionTime = 0
                                                end
                                                toolAnimTrack = humanoid:LoadAnimation(anim)
                                                if priority then toolAnimTrack.Priority = priority end
                                                toolAnimTrack:Play(transitionTime); toolAnimName = animName; toolAnimInstance =
                                                anim
                                                currentToolAnimKeyframeHandler = toolAnimTrack.KeyframeReached:connect(
                                                toolKeyFrameReachedFunc)
                                            end
                                        end

                                        local function stopToolAnimations()
                                            local oldAnim = toolAnimName
                                            if currentToolAnimKeyframeHandler ~= nil then currentToolAnimKeyframeHandler
                                                    :disconnect() end
                                            toolAnimName = ""; toolAnimInstance = nil
                                            if toolAnimTrack ~= nil then
                                                toolAnimTrack:Stop(); toolAnimTrack:Destroy(); toolAnimTrack = nil
                                            end
                                            return oldAnim
                                        end

                                        local function onRunning(speed)
                                            local movedDuringEmote = currentlyPlayingEmote and
                                            Humanoid.MoveDirection == Vector3.new(0, 0, 0)
                                            local speedThreshold = movedDuringEmote and Humanoid.WalkSpeed or 0.75
                                            humanoidSpeed = speed
                                            if speed > speedThreshold then
                                                playAnimation("walk", 0.2, Humanoid); if pose ~= "Running" then
                                                    pose = "Running"; updateVelocity(0)
                                                end
                                            else
                                                if emoteNames[currentAnim] == nil and not currentlyPlayingEmote then
                                                    playAnimation("idle", 0.2, Humanoid); pose = "Standing"
                                                end
                                            end
                                        end

                                        Humanoid.Died:connect(function() pose = "Dead" end)
                                        Humanoid.Running:connect(onRunning)
                                        Humanoid.Jumping:connect(function()
                                            playAnimation("jump", 0.1, Humanoid); jumpAnimTime = jumpAnimDuration; pose =
                                            "Jumping"
                                        end)
                                        Humanoid.Climbing:connect(function(speed)
                                            playAnimation("climb", 0.1, Humanoid); setAnimationSpeed(speed / 5.0); pose =
                                            "Climbing"
                                        end)
                                        Humanoid.GettingUp:connect(function() pose = "GettingUp" end)
                                        Humanoid.FreeFalling:connect(function()
                                            if jumpAnimTime <= 0 then playAnimation("fall", fallTransitionTime, Humanoid) end; pose =
                                            "FreeFall"
                                        end)
                                        Humanoid.FallingDown:connect(function() pose = "FallingDown" end)
                                        Humanoid.Seated:connect(function() pose = "Seated" end)
                                        Humanoid.PlatformStanding:connect(function() pose = "PlatformStanding" end)
                                        Humanoid.Swimming:connect(function(speed) if speed > 0 then pose = "Running" else pose =
                                                "Standing" end end)

                                        local function getToolAnim(tool)
                                            for _, c in ipairs(tool:GetChildren()) do
                                                if c.Name == "toolanim" and c.className == "StringValue" then return c end
                                            end
                                            return nil
                                        end
                                        local function animateTool()
                                            if toolAnim == "None" then
                                                playToolAnimation("toolnone", toolTransitionTime, Humanoid,
                                                    Enum.AnimationPriority.Idle); return
                                            end
                                            if toolAnim == "Slash" then
                                                playToolAnimation("toolslash", 0, Humanoid, Enum.AnimationPriority
                                                .Action); return
                                            end
                                            if toolAnim == "Lunge" then
                                                playToolAnimation("toollunge", 0, Humanoid, Enum.AnimationPriority
                                                .Action); return
                                            end
                                        end
                                        local lastTick = 0
                                        local function stepAnimate(currentTime)
                                            local deltaTime = currentTime - lastTick; lastTick = currentTime
                                            if jumpAnimTime > 0 then jumpAnimTime = jumpAnimTime - deltaTime end
                                            if pose == "FreeFall" and jumpAnimTime <= 0 then
                                                playAnimation("fall", fallTransitionTime, Humanoid)
                                            elseif pose == "Seated" then
                                                playAnimation("sit", 0.5, Humanoid); return
                                            elseif pose == "Running" then
                                                playAnimation("walk", 0.2, Humanoid); updateVelocity(currentTime)
                                            elseif pose == "Dead" or pose == "GettingUp" or pose == "FallingDown" or pose == "PlatformStanding" then
                                                stopAllAnimations()
                                            end
                                            local tool = Character:FindFirstChildOfClass("Tool")
                                            if tool and tool:FindFirstChild("Handle") then
                                                local asvo = getToolAnim(tool)
                                                if asvo then
                                                    toolAnim = asvo.Value; asvo.Parent = nil; toolAnimTime = currentTime +
                                                    0.3
                                                end
                                                if currentTime > toolAnimTime then
                                                    toolAnimTime = 0; toolAnim = "None"
                                                end
                                                animateTool()
                                            else
                                                stopToolAnimations(); toolAnim = "None"; toolAnimInstance = nil; toolAnimTime = 0
                                            end
                                        end

                                        _SvcPlr.LocalPlayer.Chatted:connect(function(msg)
                                            local emote = ""
                                            if string.sub(msg, 1, 3) == "/e " then
                                                emote = string.sub(msg, 4)
                                            elseif string.sub(msg, 1, 7) == "/emote " then
                                                emote = string.sub(msg, 8)
                                            end
                                            if pose == "Standing" and emoteNames[emote] ~= nil then playAnimation(emote,
                                                    EMOTE_TRANSITION_TIME, Humanoid) end
                                        end)

                                        if Character.Parent ~= nil then
                                            playAnimation("idle", 0.1, Humanoid); pose = "Standing"
                                        end
                                        task.spawn(function()
                                            while Character.Parent ~= nil do
                                                local _, currentGameTime = wait(0.1); stepAnimate(currentGameTime)
                                            end
                                        end)
                                    end

                                    pcall(function() RunCustomAnimation(plr.Character) end)
                                    sendNotif("R6 Anim", "Custom Animationen aktiv ✅", 3)
                                end)
                            end
                        end
                        btn.MouseButton1Click:Connect(activate)
                        btn.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Touch then activate() end
                        end)
                        btn.MouseEnter:Connect(function()
                            _sc._playHoverSound()
                            twP(chip, 0.1, { BackgroundColor3 = C.bg3 or _C3_BG4 })
                        end)
                        btn.MouseLeave:Connect(function()
                            twP(chip, 0.1, { BackgroundColor3 = C.bg2 or _C3_BG2 })
                        end)
                    end
                    CY = CY + QA_H + 26 + GAP
                end
                
                
                do
                    local _vcModule = _TL_loadModule("TL-ANTIVCBAN")
                    sectionLbl(CY, "VOICE CHAT"); CY = CY + 18
                    local _vcSetToggle = nil
                    if _vcModule then
                        local _, st = makeToggleRow(CY, "Anti-VC Ban", "mic protection", C.accent, function(on)
                            settingsState.antiVcBan = on
                            if on then _vcModule.start(sendNotif) else _vcModule.stop() end
                        end)
                        _vcSetToggle = st
                    else
                        makeToggleRow(CY, "Anti-VC Ban", "mic protection (offline)", C.sub, function() end)
                    end
                    if _vcSetToggle then
                        _G._TL_vcSetToggle = _vcSetToggle
                    end
                    CY = CY + TOG_H + GAP
                    -- Restore ANTIVCBAN if it was active before reinjection
                    task.defer(function()
                        if _vcModule and rawget(_genv, "_TL_persist_antiVcBan") then
                            rawset(_genv, "_TL_persist_antiVcBan", nil)
                            settingsState.antiVcBan = true
                            if _vcSetToggle then pcall(function() _vcSetToggle(true) end) end
                            pcall(function() _vcModule.start(sendNotif) end)
                        end
                    end)
                end
                
                sectionLbl(CY, "MOVEMENT"); CY = CY + 18
                do
                    local moveDropOpen = false
                    local moveAnimSelection = "None"
                    local moveAnimEnabled = false
                    local movePillH = 30
                    local moveDropGap = 6
                    local moveDropExpandedH = 184
                    pcall(function()
                        local prev = _genv.__TL_CharacterAnimRuntime
                        if type(prev) == "table" and type(prev.cleanup) == "function" then
                            prev.cleanup()
                        end
                    end)
                    local moveAnimRuntime = nil

                    local function cleanupMoveAnimRuntime()
                        local runtime = moveAnimRuntime
                        if not runtime then return end
                        moveAnimRuntime = nil
                        runtime.enabled = false
                        for _, conn in ipairs(runtime.connections or {}) do
                            pcall(function() conn:Disconnect() end)
                        end
                        for _, track in pairs(runtime.tracks or {}) do
                            pcall(function() track:Stop(0.1) end)
                            pcall(function() track:Destroy() end)
                        end
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            pcall(function() hum.WalkSpeed = runtime.normalSpeed or 16 end)
                            pcall(function() hum.JumpPower = 50 end)
                        end
                        if _genv.__TL_CharacterAnimRuntime == runtime then
                            _genv.__TL_CharacterAnimRuntime = nil
                        end
                    end

                    local function loadMoveAnimTrack(id, looped, playbackSpeed)
                        local humanoid = LocalPlayer.Character and
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if not humanoid then return nil end
                        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
                        local resolvedId = "rbxassetid://" .. tostring(id)
                        pcall(function()
                            local objects = game:GetObjects(resolvedId)
                            if objects and objects[1] then
                                local obj = objects[1]
                                if obj:IsA("Animation") then
                                    resolvedId = obj.AnimationId
                                else
                                    local child = obj:FindFirstChildOfClass("Animation")
                                    if child then resolvedId = child.AnimationId end
                                end
                                obj.Parent = workspace
                                task.delay(1, function() pcall(function() obj:Destroy() end) end)
                            end
                        end)
                        local anim = Instance.new("Animation")
                        anim.AnimationId = resolvedId
                        local track = animator:LoadAnimation(anim)
                        track.Priority = Enum.AnimationPriority.Action4
                        track.Looped = looped
                        if playbackSpeed then
                            track:AdjustSpeed(playbackSpeed)
                        end
                        task.delay(0.5, function()
                            pcall(function() anim:Destroy() end)
                        end)
                        return track
                    end

                    local MOVE_ANIM_PACKS = {
                        Jolly = {
                            tracks = {
                                Walk = 108909280323688,
                                Idle = 74402735640939,
                                SwimIdle = 70498551494534,
                                Sprint = 110208399858856,
                                Sit = 93903979507056,
                                Jump = 96558453936394,
                            },
                            jumpSpeed = 7.0,
                            sprintSpeed = 28,
                            sitEnabled = true,
                        },
                        Cartoon = {
                            tracks = {
                                Idle = 75821677460914,
                                Walk = 103745502321060,
                                Sprint = 99902465920889,
                            },
                            sprintSpeed = 28,
                            sitEnabled = false,
                        },
                        Mysterious = {
                            tracks = {
                                Idle = 114204486121531,
                                Walk = 108805380118005,
                                Sprint = 103911274783509,
                            },
                            speeds = {
                                Walk = 0.5,
                            },
                            sprintSpeed = 28,
                            sitEnabled = false,
                        },
                        Chibi = {
                            tracks = {
                                Idle = 116866573874014,
                                Walk = 114896599198832,
                                Sprint = 70546017528866,
                            },
                            sprintSpeed = 28,
                            sitEnabled = false,
                        },
                        Nonchalant = {
                            tracks = {
                                Idle = 114135398685339,
                                Walk = 71502890098445,
                                Sprint = 110208399858856,
                            },
                            normalSpeed = 11,
                            sprintSpeed = 28,
                            sitEnabled = false,
                        },
                    }

                    local function startMoveAnimationSet(packName)
                        cleanupMoveAnimRuntime()
                        local pack = MOVE_ANIM_PACKS[packName]
                        if not pack then return end

                        local runtime = {
                            enabled = true,
                            connections = {},
                            tracks = {},
                            currentState = "Idle",
                            pausedByFly = false,
                            isSwimming = false,
                            isSprinting = false,
                            isSitting = false,
                            sprintKeyHeld = false,
                            speedTween = nil,
                            lastSpeed = 16,
                            isJumping = false,
                            landingCooldown = false,
                            normalSpeed = 16,
                            sprintSpeed = 28,
                            sprintKey = Enum.KeyCode.LeftShift,
                            minSpeedThreshold = 0.5,
                            sitKey = Enum.KeyCode.LeftControl,
                        }
                        runtime.cleanup = cleanupMoveAnimRuntime
                        moveAnimRuntime = runtime
                        _genv.__TL_CharacterAnimRuntime = runtime
                        runtime.normalSpeed = pack.normalSpeed or runtime.normalSpeed
                        runtime.sprintSpeed = pack.sprintSpeed or runtime.sprintSpeed

                        local function bind(signal, fn)
                            local conn = signal:Connect(fn)
                            runtime.connections[#runtime.connections + 1] = conn
                            return conn
                        end

                        local function setWalkSpeedSmooth(humanoid, targetSpeed)
                            if not humanoid then return end
                            if runtime.speedTween then runtime.speedTween:Cancel() end
                            if math.abs(targetSpeed - humanoid.WalkSpeed) < 0.1 then
                                humanoid.WalkSpeed = targetSpeed
                                runtime.lastSpeed = targetSpeed
                                return
                            end
                            runtime.speedTween = TweenService:Create(humanoid,
                                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                WalkSpeed = targetSpeed
                            })
                            runtime.speedTween.Completed:Connect(function()
                                runtime.lastSpeed = targetSpeed
                                runtime.speedTween = nil
                            end)
                            runtime.speedTween:Play()
                        end

                        local function stopAllExcept(exceptName)
                            for name, track in pairs(runtime.tracks) do
                                if name ~= exceptName then
                                    pcall(function() track:Stop(0.1) end)
                                end
                            end
                        end

                        local function crossfadeAnimation(fromTrack, toTrack, fadeTime)
                            if fromTrack and fromTrack.IsPlaying then
                                fromTrack:Stop(fadeTime)
                            end
                            if toTrack and not toTrack.IsPlaying then
                                toTrack:Play(fadeTime)
                            end
                        end

                        local function loadAllAnimations(character)
                            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                            if not humanoid then return end

                            for _, track in pairs(runtime.tracks) do
                                pcall(function() track:Stop() end)
                                pcall(function() track:Destroy() end)
                            end
                            runtime.tracks = {}

                            for name, id in pairs(pack.tracks or {}) do
                                local playbackSpeed = (pack.speeds and pack.speeds[name]) or
                                (name == "Jump" and (pack.jumpSpeed or 1) or nil)
                                local track = loadMoveAnimTrack(id, name ~= "Jump", playbackSpeed)
                                if track then
                                    runtime.tracks[name] = track
                                end
                            end

                            if runtime.tracks.Idle then
                                runtime.tracks.Idle:Play(0.1)
                                runtime.currentState = "Idle"
                            end
                            runtime.isSitting = false
                            runtime.isJumping = false
                            runtime.landingCooldown = false
                            humanoid.WalkSpeed = runtime.normalSpeed
                            runtime.lastSpeed = runtime.normalSpeed
                        end

                        local function toggleSit()
                            local character = LocalPlayer.Character
                            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                            if not humanoid then return end

                            if not pack.sitEnabled then return end
                            runtime.isSitting = not runtime.isSitting
                            if runtime.isSitting then
                                local sitTrack = runtime.tracks.Sit
                                if sitTrack then
                                    stopAllExcept("Sit")
                                    crossfadeAnimation(runtime.tracks[runtime.currentState], sitTrack, 0.15)
                                    runtime.currentState = "Sit"
                                    humanoid.WalkSpeed = 0
                                    humanoid.JumpPower = 0
                                end
                            else
                                humanoid.WalkSpeed = runtime.normalSpeed
                                humanoid.JumpPower = 50
                                if runtime.tracks.Idle then
                                    stopAllExcept("Idle")
                                    crossfadeAnimation(runtime.tracks.Sit, runtime.tracks.Idle, 0.15)
                                    runtime.currentState = "Idle"
                                end
                            end
                        end

                        local function updateAnimationState()
                            if not runtime.enabled then return end
                            local character = LocalPlayer.Character
                            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                            if not humanoid or not rootPart then return end

                            if flyActive then
                                if not runtime.pausedByFly then
                                    runtime.pausedByFly = true
                                    stopAllExcept(nil)
                                end
                                return
                            elseif runtime.pausedByFly then
                                runtime.pausedByFly = false
                                if runtime.tracks.Idle and not runtime.tracks.Idle.IsPlaying then
                                    stopAllExcept("Idle")
                                    runtime.tracks.Idle:Play(0.1)
                                    runtime.currentState = "Idle"
                                end
                            end

                            if runtime.isSitting then return end

                            local humanoidState = humanoid:GetState()
                            if humanoidState == Enum.HumanoidStateType.Jumping or humanoidState == Enum.HumanoidStateType.Freefall then
                                if not runtime.isJumping then
                                    runtime.isJumping = true
                                    local jumpTrack = runtime.tracks.Jump
                                    if jumpTrack then
                                        stopAllExcept("Jump")
                                        jumpTrack:Play(0.1)
                                        runtime.currentState = "Jump"
                                    end
                                end
                                return
                            end

                            if runtime.isJumping then
                                runtime.isJumping = false
                                runtime.landingCooldown = true
                                task.delay(0.30, function()
                                    if not moveAnimRuntime or moveAnimRuntime ~= runtime or not runtime.enabled then return end
                                    runtime.landingCooldown = false
                                    if not runtime.isJumping and not runtime.isSitting and runtime.tracks.Idle then
                                        stopAllExcept("Idle")
                                        runtime.tracks.Idle:Play(0.15)
                                        runtime.currentState = "Idle"
                                    end
                                end)
                                return
                            end

                            if runtime.landingCooldown then return end

                            local horizontalSpeed = Vector3.new(rootPart.Velocity.X, 0, rootPart.Velocity.Z).Magnitude
                            local isMoving = horizontalSpeed > runtime.minSpeedThreshold
                            local shouldSprint = runtime.sprintKeyHeld and isMoving and not runtime.isSwimming

                            if shouldSprint and not runtime.isSprinting then
                                runtime.isSprinting = true
                                setWalkSpeedSmooth(humanoid, runtime.sprintSpeed)
                            elseif not shouldSprint and runtime.isSprinting then
                                runtime.isSprinting = false
                                setWalkSpeedSmooth(humanoid, runtime.normalSpeed)
                            end

                            local isInWater = false
                            pcall(function()
                                if not runtime._waterRayParams then
                                    runtime._waterRayParams = RaycastParams.new()
                                    runtime._waterRayParams.FilterType = Enum.RaycastFilterType.Exclude
                                end
                                runtime._waterRayParams.FilterDescendantsInstances = { character }
                                local waterCheck = workspace:Raycast(rootPart.Position, Vector3.new(0, -3, 0), runtime._waterRayParams)
                                if waterCheck and waterCheck.Material == Enum.Material.Water then
                                    isInWater = true
                                end
                            end)

                            local velocity = rootPart.Velocity
                            local moveSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
                            local newState
                            if isInWater then
                                newState = "SwimIdle"
                                runtime.isSwimming = true
                            elseif moveSpeed > runtime.minSpeedThreshold then
                                newState = (runtime.isSprinting and runtime.tracks.Sprint) and "Sprint" or "Walk"
                                runtime.isSwimming = false
                            else
                                newState = "Idle"
                                runtime.isSwimming = false
                            end

                            if newState ~= runtime.currentState then
                                local oldTrack = runtime.tracks[runtime.currentState]
                                local newTrack = runtime.tracks[newState]
                                if newTrack then
                                    stopAllExcept(newState)
                                    crossfadeAnimation(oldTrack, newTrack, 0.1)
                                    runtime.currentState = newState
                                end
                            end
                        end

                        bind(_SvcUIS.InputBegan, function(input, gameProcessed)
                            if gameProcessed or not runtime.enabled then return end
                            if input.KeyCode == runtime.sprintKey then
                                runtime.sprintKeyHeld = true
                            elseif input.KeyCode == runtime.sitKey and pack.sitEnabled then
                                toggleSit()
                            end
                        end)

                        bind(_SvcUIS.InputEnded, function(input)
                            if input.KeyCode == runtime.sprintKey then
                                runtime.sprintKeyHeld = false
                            end
                        end)

                        bind(LocalPlayer.CharacterAdded, function(character)
                            task.wait(0.1)
                            if moveAnimRuntime ~= runtime or not runtime.enabled then return end
                            loadAllAnimations(character)
                        end)

                        if LocalPlayer.Character then
                            loadAllAnimations(LocalPlayer.Character)
                        end

                        bind(_SvcRS.Heartbeat, updateAnimationState)
                        sendNotif("Custom Animation Set", tostring(packName) .. " aktiviert", 3)
                    end

                    local function setMoveAnimationSet(name)
                        moveAnimSelection = name or "None"
                        if moveAnimEnabled and MOVE_ANIM_PACKS[moveAnimSelection] then
                            startMoveAnimationSet(moveAnimSelection)
                        else
                            cleanupMoveAnimRuntime()
                        end
                    end

                    local movePill = Instance.new("Frame", c)
                    movePill.Size = UDim2.new(1, -PAD * 2, 0, movePillH)
                    movePill.Position = UDim2.new(0, PAD, 0, CY)
                    movePill.BackgroundColor3 = C.bg2 or _C3_BG2
                    movePill.BackgroundTransparency = 0
                    movePill.BorderSizePixel = 0
                    corner(movePill, 10)
                    local movePill_Stroke = _makeDummyStroke(movePill)
                    movePill_Stroke.Thickness = 1
                    movePill_Stroke.Color = C.bg3 or _C3_BG3
                    movePill_Stroke.Transparency = 0.25

                    local movePillBtn = Instance.new("TextButton", movePill)
                    movePillBtn.Size = UDim2.new(1, 0, 1, 0)
                    movePillBtn.BackgroundTransparency = 1
                    movePillBtn.BorderSizePixel = 0
                    movePillBtn.Text = "Custom Animation Set"
                    movePillBtn.Font = Enum.Font.GothamBold
                    movePillBtn.TextSize = 11
                    movePillBtn.TextColor3 = C.text or Color3.new(1, 1, 1)
                    movePillBtn.TextXAlignment = Enum.TextXAlignment.Left
                    movePillBtn.TextTruncate = Enum.TextTruncate.AtEnd
                    movePillBtn.AutoButtonColor = false

                    local movePillPad = Instance.new("UIPadding", movePillBtn)
                    movePillPad.PaddingLeft = UDim.new(0, 12)
                    movePillPad.PaddingRight = UDim.new(0, 114)

                    local movePillValue = Instance.new("TextLabel", movePill)
                    movePillValue.Size = UDim2.new(0, 56, 1, 0)
                    movePillValue.Position = UDim2.new(1, -124, 0, 0)
                    movePillValue.BackgroundTransparency = 1
                    movePillValue.Text = moveAnimSelection
                    movePillValue.Font = Enum.Font.GothamBold
                    movePillValue.TextSize = 10
                    movePillValue.TextColor3 = C.sub or _C3_SUB
                    movePillValue.TextXAlignment = Enum.TextXAlignment.Right

                    local moveToggleTrack = Instance.new("Frame", movePill)
                    moveToggleTrack.Size = UDim2.new(0, 32, 0, 18)
                    moveToggleTrack.Position = UDim2.new(1, -64, 0.5, -9)
                    moveToggleTrack.BackgroundColor3 = C.bg3 or _C3_BG3
                    moveToggleTrack.BackgroundTransparency = 0.15
                    moveToggleTrack.BorderSizePixel = 0
                    corner(moveToggleTrack, 99)

                    local moveToggleKnob = Instance.new("Frame", moveToggleTrack)
                    moveToggleKnob.Size = UDim2.new(0, 12, 0, 12)
                    moveToggleKnob.Position = UDim2.new(0, 2, 0.5, -6)
                    moveToggleKnob.BackgroundColor3 = C.sub or _C3_SUB
                    moveToggleKnob.BorderSizePixel = 0
                    corner(moveToggleKnob, 99)

                    local moveToggleBtn = Instance.new("TextButton", movePill)
                    moveToggleBtn.Size = UDim2.new(0, 40, 0, 24)
                    moveToggleBtn.Position = UDim2.new(1, -68, 0.5, -12)
                    moveToggleBtn.BackgroundTransparency = 1
                    moveToggleBtn.Text = ""
                    moveToggleBtn.ZIndex = 9

                    local movePillArrow = Instance.new("TextLabel", movePill)
                    movePillArrow.Size = UDim2.new(0, 18, 1, 0)
                    movePillArrow.Position = UDim2.new(1, -24, 0, 0)
                    movePillArrow.BackgroundTransparency = 1
                    movePillArrow.Text = "▼"
                    movePillArrow.Font = Enum.Font.GothamBold
                    movePillArrow.TextSize = 10
                    movePillArrow.TextColor3 = C.accent or C.text
                    movePillArrow.TextXAlignment = Enum.TextXAlignment.Center

                    local moveDropOuter = Instance.new("Frame", c)
                    moveDropOuter.Size = UDim2.new(1, -PAD * 2, 0, 0)
                    moveDropOuter.Position = UDim2.new(0, PAD, 0, CY + movePillH + moveDropGap)
                    moveDropOuter.BackgroundColor3 = C.bg2 or _C3_BG2
                    moveDropOuter.BackgroundTransparency = 0.06
                    moveDropOuter.BorderSizePixel = 0
                    moveDropOuter.ClipsDescendants = true
                    moveDropOuter.ZIndex = 30
                    corner(moveDropOuter, 12)
                    local moveDrop_Stroke = _makeDummyStroke(moveDropOuter)
                    moveDrop_Stroke.Thickness = 1.2
                    moveDrop_Stroke.Color = C.bg3 or _C3_BG3
                    moveDrop_Stroke.Transparency = 1

                    local moveDropList = Instance.new("Frame", moveDropOuter)
                    moveDropList.Size = UDim2.new(1, -8, 1, -8)
                    moveDropList.Position = UDim2.new(0, 4, 0, 4)
                    moveDropList.BackgroundTransparency = 1

                    local jollyBtn = Instance.new("TextButton", moveDropList)
                    jollyBtn.Size = UDim2.new(1, 0, 0, 32)
                    jollyBtn.Position = UDim2.new(0, 0, 0, 0)
                    jollyBtn.BackgroundColor3 = C.bg3 or _C3_BG3
                    jollyBtn.BackgroundTransparency = 0.82
                    jollyBtn.BorderSizePixel = 0
                    jollyBtn.Text = "Jolly"
                    jollyBtn.Font = Enum.Font.GothamBold
                    jollyBtn.TextSize = 10
                    jollyBtn.TextColor3 = C.text or Color3.new(1, 1, 1)
                    jollyBtn.AutoButtonColor = false
                    jollyBtn.ZIndex = 31
                    corner(jollyBtn, 10)

                    local jollyDot = Instance.new("Frame", jollyBtn)
                    jollyDot.Size = UDim2.new(0, 6, 0, 6)
                    jollyDot.Position = UDim2.new(1, -14, 0.5, -3)
                    jollyDot.BackgroundColor3 = C.accent or Color3.new(1, 1, 1)
                    jollyDot.BorderSizePixel = 0
                    jollyDot.Visible = false
                    jollyDot.ZIndex = 32
                    corner(jollyDot, 99)

                    local cartoonBtn = Instance.new("TextButton", moveDropList)
                    cartoonBtn.Size = UDim2.new(1, 0, 0, 32)
                    cartoonBtn.Position = UDim2.new(0, 0, 0, 36)
                    cartoonBtn.BackgroundColor3 = C.bg3 or _C3_BG3
                    cartoonBtn.BackgroundTransparency = 0.82
                    cartoonBtn.BorderSizePixel = 0
                    cartoonBtn.Text = "Cartoon"
                    cartoonBtn.Font = Enum.Font.GothamBold
                    cartoonBtn.TextSize = 10
                    cartoonBtn.TextColor3 = C.text or Color3.new(1, 1, 1)
                    cartoonBtn.AutoButtonColor = false
                    cartoonBtn.ZIndex = 31
                    corner(cartoonBtn, 10)

                    local cartoonDot = Instance.new("Frame", cartoonBtn)
                    cartoonDot.Size = UDim2.new(0, 6, 0, 6)
                    cartoonDot.Position = UDim2.new(1, -14, 0.5, -3)
                    cartoonDot.BackgroundColor3 = C.accent or Color3.new(1, 1, 1)
                    cartoonDot.BorderSizePixel = 0
                    cartoonDot.Visible = false
                    cartoonDot.ZIndex = 32
                    corner(cartoonDot, 99)

                    local mysteriousBtn = Instance.new("TextButton", moveDropList)
                    mysteriousBtn.Size = UDim2.new(1, 0, 0, 32)
                    mysteriousBtn.Position = UDim2.new(0, 0, 0, 72)
                    mysteriousBtn.BackgroundColor3 = C.bg3 or _C3_BG3
                    mysteriousBtn.BackgroundTransparency = 0.82
                    mysteriousBtn.BorderSizePixel = 0
                    mysteriousBtn.Text = "Mysterious"
                    mysteriousBtn.Font = Enum.Font.GothamBold
                    mysteriousBtn.TextSize = 10
                    mysteriousBtn.TextColor3 = C.text or Color3.new(1, 1, 1)
                    mysteriousBtn.AutoButtonColor = false
                    mysteriousBtn.ZIndex = 31
                    corner(mysteriousBtn, 10)

                    local mysteriousDot = Instance.new("Frame", mysteriousBtn)
                    mysteriousDot.Size = UDim2.new(0, 6, 0, 6)
                    mysteriousDot.Position = UDim2.new(1, -14, 0.5, -3)
                    mysteriousDot.BackgroundColor3 = C.accent or Color3.new(1, 1, 1)
                    mysteriousDot.BorderSizePixel = 0
                    mysteriousDot.Visible = false
                    mysteriousDot.ZIndex = 32
                    corner(mysteriousDot, 99)

                    local chibiBtn = Instance.new("TextButton", moveDropList)
                    chibiBtn.Size = UDim2.new(1, 0, 0, 32)
                    chibiBtn.Position = UDim2.new(0, 0, 0, 108)
                    chibiBtn.BackgroundColor3 = C.bg3 or _C3_BG3
                    chibiBtn.BackgroundTransparency = 0.82
                    chibiBtn.BorderSizePixel = 0
                    chibiBtn.Text = "Chibi"
                    chibiBtn.Font = Enum.Font.GothamBold
                    chibiBtn.TextSize = 10
                    chibiBtn.TextColor3 = C.text or Color3.new(1, 1, 1)
                    chibiBtn.AutoButtonColor = false
                    chibiBtn.ZIndex = 31
                    corner(chibiBtn, 10)

                    local chibiDot = Instance.new("Frame", chibiBtn)
                    chibiDot.Size = UDim2.new(0, 6, 0, 6)
                    chibiDot.Position = UDim2.new(1, -14, 0.5, -3)
                    chibiDot.BackgroundColor3 = C.accent or Color3.new(1, 1, 1)
                    chibiDot.BorderSizePixel = 0
                    chibiDot.Visible = false
                    chibiDot.ZIndex = 32
                    corner(chibiDot, 99)

                    local nonchalantBtn = Instance.new("TextButton", moveDropList)
                    nonchalantBtn.Size = UDim2.new(1, 0, 0, 32)
                    nonchalantBtn.Position = UDim2.new(0, 0, 0, 144)
                    nonchalantBtn.BackgroundColor3 = C.bg3 or _C3_BG3
                    nonchalantBtn.BackgroundTransparency = 0.82
                    nonchalantBtn.BorderSizePixel = 0
                    nonchalantBtn.Text = "Nonchalant"
                    nonchalantBtn.Font = Enum.Font.GothamBold
                    nonchalantBtn.TextSize = 10
                    nonchalantBtn.TextColor3 = C.text or Color3.new(1, 1, 1)
                    nonchalantBtn.AutoButtonColor = false
                    nonchalantBtn.ZIndex = 31
                    corner(nonchalantBtn, 10)

                    local nonchalantDot = Instance.new("Frame", nonchalantBtn)
                    nonchalantDot.Size = UDim2.new(0, 6, 0, 6)
                    nonchalantDot.Position = UDim2.new(1, -14, 0.5, -3)
                    nonchalantDot.BackgroundColor3 = C.accent or Color3.new(1, 1, 1)
                    nonchalantDot.BorderSizePixel = 0
                    nonchalantDot.Visible = false
                    nonchalantDot.ZIndex = 32
                    corner(nonchalantDot, 99)

                    local function refreshMoveAnimPill()
                        movePillValue.Text = moveAnimSelection
                        local isJolly = moveAnimSelection == "Jolly"
                        local isCartoon = moveAnimSelection == "Cartoon"
                        local isMysterious = moveAnimSelection == "Mysterious"
                        local isChibi = moveAnimSelection == "Chibi"
                        local isNonchalant = moveAnimSelection == "Nonchalant"
                        jollyDot.Visible = isJolly
                        cartoonDot.Visible = isCartoon
                        mysteriousDot.Visible = isMysterious
                        chibiDot.Visible = isChibi
                        nonchalantDot.Visible = isNonchalant
                        twP(jollyBtn, 0.08, { BackgroundTransparency = isJolly and 0.56 or 0.82 })
                        twP(jollyBtn, 0.08,
                            { TextColor3 = isJolly and (C.accent or Color3.new(1, 1, 1)) or (C.text or Color3.new(1, 1, 1)) })
                        twP(cartoonBtn, 0.08, { BackgroundTransparency = isCartoon and 0.56 or 0.82 })
                        twP(cartoonBtn, 0.08,
                            { TextColor3 = isCartoon and (C.accent or Color3.new(1, 1, 1)) or
                            (C.text or Color3.new(1, 1, 1)) })
                        twP(mysteriousBtn, 0.08, { BackgroundTransparency = isMysterious and 0.56 or 0.82 })
                        twP(mysteriousBtn, 0.08,
                            { TextColor3 = isMysterious and (C.accent or Color3.new(1, 1, 1)) or
                            (C.text or Color3.new(1, 1, 1)) })
                        twP(chibiBtn, 0.08, { BackgroundTransparency = isChibi and 0.56 or 0.82 })
                        twP(chibiBtn, 0.08,
                            { TextColor3 = isChibi and (C.accent or Color3.new(1, 1, 1)) or (C.text or Color3.new(1, 1, 1)) })
                        twP(nonchalantBtn, 0.08, { BackgroundTransparency = isNonchalant and 0.56 or 0.82 })
                        twP(nonchalantBtn, 0.08,
                            { TextColor3 = isNonchalant and (C.accent or Color3.new(1, 1, 1)) or
                            (C.text or Color3.new(1, 1, 1)) })
                        if moveAnimEnabled and MOVE_ANIM_PACKS[moveAnimSelection] then
                            twP(moveToggleTrack, 0.15,
                                { BackgroundColor3 = C.accent or Color3.new(1, 1, 1), BackgroundTransparency = 0.45 })
                            tw(moveToggleKnob, 0.15,
                                { BackgroundColor3 = Color3.new(1, 1, 1), Position = UDim2.new(1, -14, 0.5, -6) }):Play()
                        else
                            twP(moveToggleTrack, 0.15,
                                { BackgroundColor3 = C.bg3 or _C3_BG3, BackgroundTransparency = 0.15 })
                            tw(moveToggleKnob, 0.15,
                                { BackgroundColor3 = C.sub or _C3_SUB, Position = UDim2.new(0, 2, 0.5, -6) }):Play()
                        end
                    end

                    local function setMoveAnimEnabled(on)
                        local shouldEnable = on and MOVE_ANIM_PACKS[moveAnimSelection] ~= nil
                        moveAnimEnabled = shouldEnable
                        if shouldEnable then
                            startMoveAnimationSet(moveAnimSelection)
                        else
                            cleanupMoveAnimRuntime()
                        end
                        refreshMoveAnimPill()
                    end

                    local function toggleMoveDropdown(forceState)
                        if forceState == nil then
                            moveDropOpen = not moveDropOpen
                        else
                            moveDropOpen = forceState
                        end
                        TweenService:Create(movePillArrow,
                            TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Rotation = moveDropOpen and 180 or 0
                        }):Play()
                        TweenService:Create(moveDropOuter,
                            TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                            Size = UDim2.new(1, -PAD * 2, 0, moveDropOpen and moveDropExpandedH or 0),
                            BackgroundTransparency = moveDropOpen and 0.06 or 1
                        }):Play()
                        TweenService:Create(moveDrop_Stroke, TweenInfo.new(0.25), {
                            Transparency = moveDropOpen and 0.3 or 1
                        }):Play()
                    end

                    movePillBtn.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        twP(movePill, 0.1, { BackgroundColor3 = C.bg3 or _C3_BG3 })
                    end)
                    movePillBtn.MouseLeave:Connect(function()
                        twP(movePill, 0.1, { BackgroundColor3 = C.bg2 or _C3_BG2 })
                    end)
                    movePillBtn.MouseButton1Click:Connect(function()
                        toggleMoveDropdown()
                    end)
                    moveToggleBtn.MouseButton1Click:Connect(function()
                        setMoveAnimEnabled(not moveAnimEnabled)
                    end)

                    jollyBtn.MouseEnter:Connect(function()
                        twP(jollyBtn, 0.08, { BackgroundTransparency = 0.6 })
                    end)
                    jollyBtn.MouseLeave:Connect(function()
                        refreshMoveAnimPill()
                    end)
                    jollyBtn.MouseButton1Click:Connect(function()
                        setMoveAnimationSet("Jolly")
                        refreshMoveAnimPill()
                        toggleMoveDropdown(false)
                    end)

                    cartoonBtn.MouseEnter:Connect(function()
                        twP(cartoonBtn, 0.08, { BackgroundTransparency = 0.6 })
                    end)
                    cartoonBtn.MouseLeave:Connect(function()
                        refreshMoveAnimPill()
                    end)
                    cartoonBtn.MouseButton1Click:Connect(function()
                        setMoveAnimationSet("Cartoon")
                        refreshMoveAnimPill()
                        toggleMoveDropdown(false)
                    end)

                    mysteriousBtn.MouseEnter:Connect(function()
                        twP(mysteriousBtn, 0.08, { BackgroundTransparency = 0.6 })
                    end)
                    mysteriousBtn.MouseLeave:Connect(function()
                        refreshMoveAnimPill()
                    end)
                    mysteriousBtn.MouseButton1Click:Connect(function()
                        setMoveAnimationSet("Mysterious")
                        refreshMoveAnimPill()
                        toggleMoveDropdown(false)
                    end)

                    chibiBtn.MouseEnter:Connect(function()
                        twP(chibiBtn, 0.08, { BackgroundTransparency = 0.6 })
                    end)
                    chibiBtn.MouseLeave:Connect(function()
                        refreshMoveAnimPill()
                    end)
                    chibiBtn.MouseButton1Click:Connect(function()
                        setMoveAnimationSet("Chibi")
                        refreshMoveAnimPill()
                        toggleMoveDropdown(false)
                    end)

                    nonchalantBtn.MouseEnter:Connect(function()
                        twP(nonchalantBtn, 0.08, { BackgroundTransparency = 0.6 })
                    end)
                    nonchalantBtn.MouseLeave:Connect(function()
                        refreshMoveAnimPill()
                    end)
                    nonchalantBtn.MouseButton1Click:Connect(function()
                        setMoveAnimationSet("Nonchalant")
                        refreshMoveAnimPill()
                        toggleMoveDropdown(false)
                    end)

                    refreshMoveAnimPill()
                end
                CY = CY + 30 + GAP
                local FLY_MIN, FLY_MAX, FLY_DEFAULT = 1, 500, 150
                local _flyPanelCard; _flyPanelCard, _flyPanelSetFn = makeSliderRow(CY, "Fly", "speed", "accent",
                    FLY_MIN, FLY_MAX, FLY_DEFAULT,
                    function(on, val)
                        flyActive = on; setFly(on)
                    end,
                    function() FLY_BASE_SPEED = FLY_DEFAULT end,
                    function(val, on) FLY_BASE_SPEED = val end
                )
                CY = CY + CARD_H + GAP
                local _, noclipSetFn = makeToggleRow(CY, "Noclip", "no collision", C.accent,
                    function(on)
                        noclipActive = on; setNoclip(on)
                    end)
                CY = CY + TOG_H + GAP
                
                do
                    local _afActive  = false
                    local _afConn    = nil
                    local _afPlayerAddedConn = nil
                    local _afTracked = {}

                    local function _afDisableCanCollide(part)
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end

                    local function _afTrackCharacter(character)
                        for _, part in pairs(character:GetChildren()) do
                            _afDisableCanCollide(part)
                        end
                        character.ChildAdded:Connect(function(child)
                            _afDisableCanCollide(child)
                        end)
                    end

                    local function _afTrackPlayer(player)
                        if player == LocalPlayer then return end
                        if player.Character then
                            _afTrackCharacter(player.Character)
                        end
                        player.CharacterAdded:Connect(_afTrackCharacter)
                        _afTracked[player] = true
                    end

                    local function _afStart()
                        _afTracked = {}
                        for _, player in pairs(Players:GetPlayers()) do
                            _afTrackPlayer(player)
                        end
                        _afPlayerAddedConn = Players.PlayerAdded:Connect(function(player)
                            if _afActive then _afTrackPlayer(player) end
                        end)
                        pcall(function()
                            local _s = Instance.new("Sound")
                            _s.SoundId = "rbxassetid://117945572498547"
                            _s.Volume = 2
                            _s.PlayOnRemove = true
                            _s.Parent = _SvcSnd
                            _s:Destroy()
                        end)
                        sendNotif("Anti-Fling", "✅ Aktiviert", 3)
                    end

                    local function _afStop()
                        _afActive = false
                        _afTracked = {}
                        if _afConn then
                            _afConn:Disconnect(); _afConn = nil
                        end
                        if _afPlayerAddedConn then
                            _afPlayerAddedConn:Disconnect(); _afPlayerAddedConn = nil
                        end
                    end

                    makeToggleRow(CY, "Anti-Fling", "protection", C.accent2,
                        function(on)
                            _afActive = on
                            if on then
                                _afStart()
                            else
                                _afStop()
                            end
                        end)
                    CY = CY + TOG_H + GAP
                    
                end 
                
                divider(CY); CY = CY + 14
                sectionLbl(CY, "STATS"); CY = CY + 18
                local SPEED_MIN, SPEED_MAX, SPEED_DEFAULT = 1, 500, 16
                speedVal = SPEED_DEFAULT
                makeSliderRow(CY, "Walk Speed", "walkspeed", "accent2",
                    SPEED_MIN, SPEED_MAX, SPEED_DEFAULT,
                    function(on, val)
                        local h = getHumanoid(); if h then h.WalkSpeed = on and val or 16 end
                    end,
                    function()
                        speedVal = SPEED_DEFAULT
                        local h = getHumanoid(); if h then h.WalkSpeed = 16 end
                    end,
                    function(val, on)
                        speedVal = val
                        if on then
                            local h = getHumanoid(); if h then h.WalkSpeed = val end
                        end
                    end
                )
                CY = CY + CARD_H + GAP
                local JUMP_MIN, JUMP_MAX, JUMP_DEFAULT = 1, 999, 50
                jumpVal = JUMP_DEFAULT
                makeSliderRow(CY, "Jump Power", "jumppower", "accent2",
                    JUMP_MIN, JUMP_MAX, JUMP_DEFAULT,
                    function(on, val)
                        local h = getHumanoid()
                        if h then
                            pcall(function() h.UseJumpPower = on end)
                            h.JumpPower = on and val or 50
                            pcall(function() h.JumpHeight = on and (val * 0.36) or 7.2 end)
                        end
                    end,
                    function()
                        jumpVal = JUMP_DEFAULT
                        local h = getHumanoid()
                        if h then
                            pcall(function() h.UseJumpPower = true end)
                            h.JumpPower = JUMP_DEFAULT
                            pcall(function() h.JumpHeight = JUMP_DEFAULT * 0.36 end)
                        end
                    end,
                    function(val, on)
                        jumpVal = val
                        if on then
                            local h = getHumanoid()
                            if h then
                                pcall(function() h.UseJumpPower = true end)
                                h.JumpPower = val
                                pcall(function() h.JumpHeight = val * 0.36 end)
                            end
                        end
                    end
                )
                CY = CY + CARD_H + GAP
                divider(CY); CY = CY + 14
                sectionLbl(CY, "VISIBILITY"); CY = CY + 18
                local _, invisSetFn2 = makeToggleRow(CY, "Invisible", "server-side", C.accent,
                    function(on)
                        if on and _G.TLActions then pcall(function() _G.TLActions.stopAll() end) end
                        invisActive = on; setInvis(on)
                    end)
                CY = CY + TOG_H + GAP
                local _, invisAnimSetFn = makeToggleRow(CY, "Invisible Animation", "action+vanish", C.accent,
                    function(on)
                        _invisSinkEnabled = on; _invisAnimEnabled = on
                    end)
                invisAnimSetFn(true)
                CY = CY + TOG_H + 14
                divider(CY); CY = CY + 14
                sectionLbl(CY, "GODMODE"); CY = CY + 18
                do
                    local godActive       = false
                    godDiedConn     = nil
                    godFF           = nil
                    local _godChar       = nil
                    local _godHum        = nil
                    local _godFF         = nil
                    local _godConns      = {}
                    local _godApplyToken = 0
                    local _godLastApply  = 0
                    local _godFFDebounce = false

                    local function _godCleanConns()
                        for _, c in ipairs(_godConns) do pcall(function() c:Disconnect() end) end
                        _godConns = {}
                    end

                    local function _godProtectHumanoid(hum)
                        if not hum then return end
                        pcall(function()
                            hum.BreakJointsOnDeath = false
                            hum.RequiresNeck       = false
                            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                        end)
                    end

                    local function _godRestoreHumanoid(hum)
                        if not hum then return end
                        pcall(function()
                            hum.BreakJointsOnDeath = true
                            hum.RequiresNeck       = true
                            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                        end)
                    end

                    local function _godApply(char)
                        if not char or not godActive then return end
                        local now = tick()
                        if now - _godLastApply < 0.3 then return end
                        _godLastApply = now
                        _godApplyToken = _godApplyToken + 1
                        local myToken = _godApplyToken

                        _godChar = char
                        local hum = char:FindFirstChildOfClass("Humanoid")
                            or char:WaitForChild("Humanoid", 5)
                        if not hum then return end
                        _godHum = hum

                        -- Humanoid schützen
                        _godProtectHumanoid(hum)

                        -- Network Owner setzen
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
                        end

                        -- Alte ForceField entfernen + neue erstellen (debounced)
                        if not _godFFDebounce then
                            _godFFDebounce = true
                            if _godFF and _godFF.Parent then
                                pcall(function() _godFF:Destroy() end)
                            end
                            _godFF = nil
                            pcall(function()
                                _godFF = Instance.new("ForceField", char)
                                _godFF.Visible = false
                            end)
                            task.delay(0.5, function() _godFFDebounce = false end)
                        end

                        -- Health-Schutz 1: PropertyChangedSignal (schnellster Pfad)
                        local conn1 = hum:GetPropertyChangedSignal("Health"):Connect(function()
                            if not godActive or myToken ~= _godApplyToken then return end
                            if hum.Health < hum.MaxHealth then
                                pcall(function() hum.Health = hum.MaxHealth end)
                            end
                        end)

                        -- Health-Schutz 2: Died-Event (letzter Ausweg)
                        local conn2 = hum.Died:Connect(function()
                            if not godActive or myToken ~= _godApplyToken then return end
                            -- Sofort Health wiederherstellen (kein task.wait!)
                            pcall(function()
                                if hum and hum.Parent then
                                    hum.Health = hum.MaxHealth
                                end
                            end)
                            -- Nomal versuchen nach kurzem Delay
                            task.delay(0.05, function()
                                if not godActive or myToken ~= _godApplyToken then return end
                                pcall(function()
                                    if hum and hum.Parent then
                                        hum.Health = hum.MaxHealth
                                    end
                                end)
                            end)
                        end)

                        -- Health-Schutz 3: StateChanged (erkennet Tod-States)
                        local conn3 = hum.StateChanged:Connect(function(_, newState)
                            if not godActive or myToken ~= _godApplyToken then return end
                            if newState == Enum.HumanoidStateType.Dead then
                                pcall(function()
                                    if hum and hum.Parent then
                                        hum.Health = hum.MaxHealth
                                        hum:ChangeState(Enum.HumanoidStateType.Running)
                                    end
                                end)
                            end
                        end)

                        -- Humanoid schützen falls sie nachträglich hinzugefügt wird
                        local conn4 = char.ChildAdded:Connect(function(child)
                            if not godActive or myToken ~= _godApplyToken then return end
                            if child:IsA("Humanoid") then
                                task.defer(function()
                                    _godProtectHumanoid(child)
                                    pcall(function() child.Health = child.MaxHealth end)
                                end)
                            end
                        end)

                        -- Anti-BreakJoints: Joint-Entfernungen blockieren
                        local conn5 = char.DescendantRemoving:Connect(function(desc)
                            if not godActive or myToken ~= _godApplyToken then return end
                            if desc:IsA("Motor6D") or desc:IsA("Weld") then
                                local name = desc.Name:lower()
                                if name == "neck" or name == "rootjoint" or name == "right shoulder"
                                    or name == "left shoulder" or name == "right hip" or name == "left hip"
                                    or name == "right knee" or name == "left knee" then
                                    -- Joint wurde entfernt – sofort wiederherstellen
                                    task.delay(0, function()
                                        if not godActive or myToken ~= _godApplyToken then return end
                                        if not char or not char.Parent then return end
                                        -- Humanoid states nochmal setzen
                                        local h = char:FindFirstChildOfClass("Humanoid")
                                        if h then _godProtectHumanoid(h) end
                                    end)
                                end
                            end
                        end)

                        table.insert(_godConns, conn1)
                        table.insert(_godConns, conn2)
                        table.insert(_godConns, conn3)
                        table.insert(_godConns, conn4)
                        table.insert(_godConns, conn5)

                        -- Initiale Health-Wiederherstellung
                        pcall(function() hum.Health = hum.MaxHealth end)
                    end

                    local function godStart()
                        if godActive then return end
                        godActive = true
                        _godCleanConns()

                        -- CharacterAdded: bei Respawn Godmode neu anwenden
                        local charConn = LocalPlayer.CharacterAdded:Connect(function(char)
                            if not godActive then return end
                            _godCleanConns()
                            task.wait(0.1)
                            _godApply(char)
                        end)
                        table.insert(_godConns, charConn)

                        -- Heartbeat: zusätzliche Schutzebene + Anti-Void + Anti-Fling
                        local heartbeatErrors = 0
                        local hbConn = RunService.Heartbeat:Connect(function()
                            if not godActive then return end
                            local char = LocalPlayer.Character
                            if not char then return end

                            -- Charakter gewechselt? -> neu anwenden
                            if char ~= _godChar then
                                _godCleanConns()
                                task.spawn(function() _godApply(char) end)
                                return
                            end

                            local hum = _godHum
                            if not hum or not hum.Parent then return end

                            -- Health-Lock (schneller Pfad)
                            if hum.Health < hum.MaxHealth then
                                pcall(function() hum.Health = hum.MaxHealth end)
                            end

                            -- Humanoid-States periodic schützen
                            if math.random(1, 30) == 1 then
                                _godProtectHumanoid(hum)
                            end

                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                -- Anti-Void
                                if hrp.Position.Y < -450 then
                                    pcall(function()
                                        hrp.CFrame = CFrame.new(hrp.Position.X, 100, hrp.Position.Z)
                                        hrp.AssemblyLinearVelocity = Vector3.zero
                                        hrp.AssemblyAngularVelocity = Vector3.zero
                                    end)
                                end

                                -- Anti-Fling
                                local vel = hrp.AssemblyLinearVelocity
                                local ang = hrp.AssemblyAngularVelocity
                                if vel.Magnitude > 300 or ang.Magnitude > 300 then
                                    pcall(function()
                                        hrp.AssemblyLinearVelocity = Vector3.zero
                                        hrp.AssemblyAngularVelocity = Vector3.zero
                                    end)
                                end

                                -- Network Owner периодически setzen
                                if math.random(1, 120) == 1 then
                                    pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
                                end
                            end

                            -- ForceField wiederherstellen wenn entfernt
                            if not _godFFDebounce and not char:FindFirstChildOfClass("ForceField") then
                                _godFFDebounce = true
                                pcall(function()
                                    _godFF = Instance.new("ForceField", char)
                                    _godFF.Visible = false
                                end)
                                task.delay(1, function() _godFFDebounce = false end)
                            end
                        end)
                        table.insert(_godConns, hbConn)

                        -- Sofort anwenden
                        _godApply(LocalPlayer.Character)
                    end

                    local function godStop()
                        godActive = false
                        _godCleanConns()
                        if _godFF and _godFF.Parent then
                            pcall(function() _godFF:Destroy() end)
                        end
                        _godFF = nil
                        _godRestoreHumanoid(_godHum)
                        _godChar = nil; _godHum = nil
                    end

                    makeToggleRow(CY, "Godmode", "health lock", C.accent2,
                        function(on) if on then
                                godStart(); pcall(function() sendNotif("Godmode", "Godmode Enabled!", 2) end)
                            else godStop(); pcall(function() sendNotif("Godmode", "Godmode Disabled!", 2) end) end end)
                    CY                    = CY + TOG_H + GAP
                    _TL_refs._TL_godStart = godStart
                    _TL_refs._TL_godStop  = godStop
                    _TL_refs._TL_isGodOn  = function() return godActive end
                end
                p.Size = UDim2.new(0, PANEL_W, 0, CY)
                LocalPlayer.CharacterAdded:Connect(function(newChar)
                    
                    if invisActive then
                        
                        if invisHeartConn then
                            pcall(function() invisHeartConn:Disconnect() end); invisHeartConn = nil
                        end
                        if invisRenderConn then
                            pcall(function() invisRenderConn:Disconnect() end); invisRenderConn = nil
                        end
                        if invisSteppedConn then
                            pcall(function() invisSteppedConn:Disconnect() end); invisSteppedConn = nil
                        end
                        if _invisHealthConn then
                            pcall(function() _invisHealthConn:Disconnect() end); _invisHealthConn = nil
                        end
                        if _invisHL and _invisHL.Parent then
                            pcall(function() _invisHL:Destroy() end); _invisHL = nil
                        end
                        
                        for _, entry in ipairs(invisParts) do
                            pcall(function()
                                if entry.part and entry.part.Parent then
                                    entry.part.Transparency = entry.origTransp
                                end
                            end)
                        end
                        invisParts = {}
                        _invisSavedCF = nil
                        
                        task.defer(function()
                            local newHum = newChar:FindFirstChildOfClass("Humanoid")
                            if newHum then pcall(function() newHum.CameraOffset = Vector3.zero end) end
                        end)
                    else
                        
                        invisParts = {}
                        _invisSavedCF = nil
                        if _invisHL and _invisHL.Parent then
                            pcall(function() _invisHL:Destroy() end); _invisHL = nil
                        end
                    end
                    
                    task.wait(0.5)
                    local h = getHumanoid()
                    if h then
                        h.WalkSpeed = 16; h.JumpPower = 50
                    end
                    task.wait(0.5); if _invisMod and _invisMod.setupParts then pcall(_invisMod.setupParts) end
                end)
            end
            do

    return p, c
end

return CharacterTab