--!nocheck
-- Standalone Module: HomeTab
-- Extracted from TLMenu.lua

local HomeTab = {}

function HomeTab.Init(ctx)
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
    local C = ctx.C or {

    local _C3_DEF_BG   = Color3.fromRGB(18, 18, 20)
    local _C3_DEF_BG2  = Color3.fromRGB(26, 26, 28)
    local _C3_DEF_BG3  = Color3.fromRGB(34, 34, 38)
    local _C3_DEF_ACC  = Color3.fromRGB(0, 170, 255)
    local _C3_DEF_SUB  = Color3.fromRGB(130, 135, 145)
    local _C3_DEF_TXT  = Color3.fromRGB(255, 255, 255)
    
    if type(C) == "table" then
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
    end
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

makePanel("Home", C.accent)
                _homeSc:Destroy()
                pcall(function() p:FindFirstChild("ScrollTrack"):Destroy() end)
                p.ClipsDescendants       = false 
                p.BackgroundColor3       = C.panelBg
                p.BackgroundTransparency = 0
                for _, ch in ipairs(p:GetChildren()) do
                    if ch:IsA("UIGradient") then ch:Destroy() end
                end
                for _, ch in ipairs(p:GetChildren()) do
                    if ch:IsA("Frame") and ch.BackgroundTransparency >= 0.9 then
                        ch:Destroy(); break
                    end
                end
                for _, ch in ipairs(p:GetChildren()) do
                    if ch:IsA("Frame") and ch.Size.Y.Offset == 48 then
                        ch.BackgroundColor3 = C.panelHdr or Color3.fromRGB(26, 26, 28)
                        ch.BackgroundTransparency = 0
                        local g = ch:FindFirstChildOfClass("UIGradient"); if g then g:Destroy() end
                    end
                end

                
                local hdr = p:FindFirstChild("Header") or p:FindFirstChildOfClass("Frame")
                if hdr and hdr.Size.Y.Offset == 48 then
                    
                    for _, ch in ipairs(hdr:GetChildren()) do
                        if ch:IsA("UIStroke") then ch:Destroy() end
                    end

                    local hdrGrad = Instance.new("UIGradient", hdr)
                    hdrGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, C.panelHdr),
                        ColorSequenceKeypoint.new(1, C.panelBg)
                    })
                    hdrGrad.Rotation = 90
                end

                local c                  = Instance.new("Frame", p)
                c.Name                   = "HomeContent"; c.Size = UDim2.new(1, 0, 1, -54); c.Position = UDim2.new(0, 0,
                    0, 54)
                c.BackgroundTransparency = 1; c.BorderSizePixel = 0; c.Active = true

                
                local HOME_W             = 310
                HOME_PANEL_W_OVERRIDE    = HOME_W
                p.Size                   = UDim2.new(0, HOME_W, 0, p.Size.Y.Offset)

                local PAD                = 16
                local PW                 = HOME_W - PAD * 2
                local Y                  = 14

                
                local function twP(inst, duration, properties, style, dir)
                    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection
                    .Out)
                    local t = _tsProxy:Create(inst, info, properties)
                    t:Play()
                    return t
                end

                
                local function applyModernGlass(frame, cornerRadius, transparency)
                    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    frame.BackgroundTransparency = transparency or 0.94
                    frame.BorderSizePixel = 0

                    local cCrn = Instance.new("UICorner", frame)
                    cCrn.CornerRadius = UDim.new(0, cornerRadius or 14)

                    
                    local grad = Instance.new("UIGradient", frame)
                    grad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
                    grad.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.4),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    grad.Rotation = -45

                    
                    local s = _makeRealStroke(frame, 1.0, Color3.fromRGB(255, 255, 255), 0.6)
                    s.Name = "OnePiece_Stroke"
                    s.Enabled = _TL_isImgTheme(_TL_activeThemeId)

                    return cCrn, grad
                end

                local function addCardHover(card)
                    card.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        twP(card, 0.25, { BackgroundTransparency = 0.88 })
                    end)
                    card.MouseLeave:Connect(function()
                        twP(card, 0.25, { BackgroundTransparency = 0.94 })
                    end)
                end

                local function divider(yPos)
                    local d = Instance.new("Frame", c)
                    d.Size = UDim2.new(1, -PAD * 2, 0, 1)
                    d.Position = UDim2.new(0, PAD, 0, yPos)
                    d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    d.BackgroundTransparency = 0.92
                    d.BorderSizePixel = 0
                    return d
                end

                local _placeId = game.PlaceId
                local _universeId = 0
                pcall(function() _universeId = tonumber(game.GameId) or 0 end)
                local _gameTitle = tostring(game.Name)
                pcall(function()
                    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
                    if info and type(info.Name) == "string" and info.Name ~= "" then _gameTitle = info.Name end
                end)
                local _gameThumb = "rbxasset://textures/ui/GuiImagePlaceholder.png"
                if _universeId > 0 then
                    _gameThumb = "rbxthumb://type=GameIcon&id=" .. tostring(_universeId) .. "&w=256&h=256"
                end
                local _jobShow = nil
                pcall(function()
                    local j = game.JobId
                    if j and tostring(j) ~= "" and tostring(j) ~= "00000000-0000-0000-0000-000000000000" then
                        _jobShow = tostring(j)
                    end
                end)

                
                _u.secGame = Instance.new("TextLabel", c)
                _u.secGame.Size = UDim2.new(1, -PAD * 2, 0, 14)
                _u.secGame.Position = UDim2.new(0, PAD, 0, Y)
                _u.secGame.BackgroundTransparency = 1
                _u.secGame.Text = T.home_section_game
                _u.secGame.Font = Enum.Font.GothamBold; _u.secGame.TextSize = 11
                _u.secGame.TextColor3 = C.accent
                _u.secGame.TextXAlignment = Enum.TextXAlignment.Left
                Y = Y + 20

                
                local GAME_CARD_H = 100
                _u.gameCard = Instance.new("Frame", c)
                _u.gameCard.Size = UDim2.new(1, -PAD * 2, 0, GAME_CARD_H)
                _u.gameCard.Position = UDim2.new(0, PAD, 0, Y)

                applyModernGlass(_u.gameCard, 16, 0.94)
                addCardHover(_u.gameCard)

                local iconSz = 72
                _u.iconWrap = Instance.new("Frame", _u.gameCard)
                _u.iconWrap.Size = UDim2.new(0, iconSz, 0, iconSz)
                _u.iconWrap.Position = UDim2.new(0, 14, 0.5, -iconSz / 2)
                _u.iconWrap.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                _u.iconWrap.BackgroundTransparency = 0.5
                _u.iconWrap.BorderSizePixel = 0
                Instance.new("UICorner", _u.iconWrap).CornerRadius = UDim.new(0, 12)

                _u.gameIcon = Instance.new("ImageLabel", _u.iconWrap)
                _u.gameIcon.Size = UDim2.new(1, 0, 1, 0)
                _u.gameIcon.BackgroundTransparency = 1
                _u.gameIcon.Image = _gameThumb
                _u.gameIcon.ScaleType = Enum.ScaleType.Crop
                Instance.new("UICorner", _u.gameIcon).CornerRadius = UDim.new(0, 12)

                
                _u.gameCard.MouseEnter:Connect(function()
                    twP(_u.iconWrap, 0.25,
                        { Size = UDim2.new(0, iconSz + 4, 0, iconSz + 4), Position = UDim2.new(0, 12, 0.5, -iconSz / 2 -
                        2) })
                end)
                _u.gameCard.MouseLeave:Connect(function()
                    twP(_u.iconWrap, 0.25,
                        { Size = UDim2.new(0, iconSz, 0, iconSz), Position = UDim2.new(0, 14, 0.5, -iconSz / 2) })
                end)

                local infoX = 14 + iconSz + 14
                _u.gameTitleLbl = Instance.new("TextLabel", _u.gameCard)
                _u.gameTitleLbl.Size = UDim2.new(1, -infoX - 14, 0, 22)
                _u.gameTitleLbl.Position = UDim2.new(0, infoX, 0, 12)
                _u.gameTitleLbl.BackgroundTransparency = 1
                _u.gameTitleLbl.Text = _gameTitle
                _u.gameTitleLbl.Font = Enum.Font.GothamBlack; _u.gameTitleLbl.TextSize = 13
                _u.gameTitleLbl.TextColor3 = C.text or _C3_TEXT3
                _u.gameTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
                _u.gameTitleLbl.TextTruncate = Enum.TextTruncate.AtEnd

                _u.linePlace = Instance.new("TextLabel", _u.gameCard)
                _u.linePlace.Size = UDim2.new(1, -infoX - 14, 0, 16)
                _u.linePlace.Position = UDim2.new(0, infoX, 0, 38)
                _u.linePlace.BackgroundTransparency = 1
                _u.linePlace.Text = T.home_place_id .. ":  " .. tostring(_placeId)
                _u.linePlace.Font = Enum.Font.GothamMedium; _u.linePlace.TextSize = 11
                _u.linePlace.TextColor3 = C.sub or _C3_SUB
                _u.linePlace.TextXAlignment = Enum.TextXAlignment.Left

                local _metaY = 56
                if _universeId > 0 then
                    _u.lineUni = Instance.new("TextLabel", _u.gameCard)
                    _u.lineUni.Size = UDim2.new(1, -infoX - 14, 0, 16)
                    _u.lineUni.Position = UDim2.new(0, infoX, 0, _metaY)
                    _u.lineUni.BackgroundTransparency = 1
                    _u.lineUni.Text = T.home_universe_id .. ":  " .. tostring(_universeId)
                    _u.lineUni.Font = Enum.Font.GothamMedium; _u.lineUni.TextSize = 11
                    _u.lineUni.TextColor3 = C.sub or _C3_SUB
                    _u.lineUni.TextXAlignment = Enum.TextXAlignment.Left
                    _metaY = _metaY + 18
                end
                if _jobShow then
                    local jt = _jobShow
                    if #jt > 22 then jt = string.sub(jt, 1, 22) .. "?" end
                    _u.lineJob = Instance.new("TextLabel", _u.gameCard)
                    _u.lineJob.Size = UDim2.new(1, -infoX - 14, 0, 16)
                    _u.lineJob.Position = UDim2.new(0, infoX, 0, _metaY)
                    _u.lineJob.BackgroundTransparency = 1
                    _u.lineJob.Text = T.home_job_id .. ":  " .. jt
                    _u.lineJob.Font = Enum.Font.GothamMedium; _u.lineJob.TextSize = 11
                    _u.lineJob.TextColor3 = C.sub or _C3_SUB
                    _u.lineJob.TextXAlignment = Enum.TextXAlignment.Left
                end

                Y = Y + GAME_CARD_H + 12
                divider(Y); Y = Y + 12

                
                _u.secProf = Instance.new("TextLabel", c)
                _u.secProf.Size = UDim2.new(1, -PAD * 2, 0, 14)
                _u.secProf.Position = UDim2.new(0, PAD, 0, Y)
                _u.secProf.BackgroundTransparency = 1
                _u.secProf.Text = T.home_section_profile
                _u.secProf.Font = Enum.Font.GothamBold; _u.secProf.TextSize = 11
                _u.secProf.TextColor3 = C.accent
                _u.secProf.TextXAlignment = Enum.TextXAlignment.Left
                Y = Y + 20

                
                local PROF_CARD_H = 100
                _u.profCard = Instance.new("Frame", c)
                _u.profCard.Size = UDim2.new(1, -PAD * 2, 0, PROF_CARD_H)
                _u.profCard.Position = UDim2.new(0, PAD, 0, Y)

                applyModernGlass(_u.profCard, 16, 0.94)
                addCardHover(_u.profCard)

                local profAvSize = 64
                _u.profAvWrap = Instance.new("Frame", _u.profCard)
                _u.profAvWrap.Size = UDim2.new(0, profAvSize, 0, profAvSize)
                _u.profAvWrap.Position = UDim2.new(0, 14, 0.5, -profAvSize / 2)
                _u.profAvWrap.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                _u.profAvWrap.BackgroundTransparency = 0.5
                _u.profAvWrap.BorderSizePixel = 0
                Instance.new("UICorner", _u.profAvWrap).CornerRadius = UDim.new(1, 0)

                
                local sonarRing = Instance.new("Frame", _u.profCard)
                sonarRing.Size = _u.profAvWrap.Size
                sonarRing.Position = _u.profAvWrap.Position
                sonarRing.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                sonarRing.BackgroundTransparency = 0.6
                sonarRing.BorderSizePixel = 0
                Instance.new("UICorner", sonarRing).CornerRadius = UDim.new(1, 0)
                sonarRing.ZIndex = _u.profAvWrap.ZIndex - 1

                task.spawn(function()
                    while _tlAlive() do
                        sonarRing.Size = UDim2.new(0, profAvSize, 0, profAvSize)
                        sonarRing.Position = UDim2.new(0, 14, 0.5, -profAvSize / 2)
                        sonarRing.BackgroundTransparency = 0.5

                        local t = tw(sonarRing, 2.0, {
                            Size = UDim2.new(0, profAvSize + 28, 0, profAvSize + 28),
                            Position = UDim2.new(0, 14 - 14, 0.5, -profAvSize / 2 - 14),
                            BackgroundTransparency = 1
                        }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

                        t:Play()
                        task.wait(2.0)
                    end
                end)

                _u.homeAvatar = Instance.new("ImageLabel", _u.profAvWrap)
                _u.homeAvatar.Size = UDim2.new(1, 0, 1, 0); _u.homeAvatar.BackgroundTransparency = 1
                _u.homeAvatar.Image = "rbxassetid://142509179"
                _u.homeAvatar.ImageColor3 = C.sub or _C3_SUB
                _u.homeAvatar.ScaleType = Enum.ScaleType.Crop; _u.homeAvatar.ZIndex = 5
                Instance.new("UICorner", _u.homeAvatar).CornerRadius = UDim.new(1, 0)

                task.spawn(function()
                    local ok, url = pcall(function()
                        return Players:GetUserThumbnailAsync(LocalPlayer.UserId,
                            Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    end)
                    if ok and url and _u.homeAvatar.Parent then
                        if type(url) == "string" then
                            _u.homeAvatar.Image = url
                            _u.homeAvatar.ImageColor3 = _C3_WHITE
                        elseif typeof(url) == "Instance" and url:IsA("Content") then
                            _u.homeAvatar.Image = url.Value
                            _u.homeAvatar.ImageColor3 = _C3_WHITE
                        end
                    end
                end)

                local TX = 14 + profAvSize + 16
                _u.nameLbl = Instance.new("TextLabel", _u.profCard)
                _u.nameLbl.Size = UDim2.new(1, -(TX + 76), 0, 22)
                _u.nameLbl.Position = UDim2.new(0, TX, 0, 14)
                _u.nameLbl.BackgroundTransparency = 1
                _u.nameLbl.Text = LocalPlayer.DisplayName
                _u.nameLbl.Font = Enum.Font.GothamBlack; _u.nameLbl.TextSize = 15
                _u.nameLbl.TextColor3 = C.text or Color3.fromRGB(255, 255, 255)
                _u.nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                _u.nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

                _u.tagLbl = Instance.new("TextLabel", _u.profCard)
                _u.tagLbl.Size = UDim2.new(1, -(TX + 76), 0, 16)
                _u.tagLbl.Position = UDim2.new(0, TX, 0, 38)
                _u.tagLbl.BackgroundTransparency = 1
                _u.tagLbl.Text = "@" .. LocalPlayer.Name
                _u.tagLbl.Font = Enum.Font.GothamMedium; _u.tagLbl.TextSize = 11
                _u.tagLbl.TextColor3 = C.sub or _C3_SUB
                _u.tagLbl.TextXAlignment = Enum.TextXAlignment.Left
                _u.tagLbl.TextTruncate = Enum.TextTruncate.AtEnd

                
                _u.profDot = Instance.new("Frame", _u.profCard)
                _u.profDot.Size = UDim2.new(0, 8, 0, 8)
                _u.profDot.Position = UDim2.new(0, TX, 0, 66)
                _u.profDot.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                _u.profDot.BorderSizePixel = 0
                Instance.new("UICorner", _u.profDot).CornerRadius = UDim.new(1, 0)

                
                task.spawn(function()
                    while _tlAlive() do
                        if _u.profDot and _u.profDot.Parent then
                            twP(_u.profDot, 1.0, { BackgroundTransparency = 0.8 })
                            task.wait(1.0)
                            twP(_u.profDot, 1.0, { BackgroundTransparency = 0 })
                            task.wait(1.0)
                        else
                            task.wait(1)
                        end
                    end
                end)

                _u.onLbl = Instance.new("TextLabel", _u.profCard)
                _u.onLbl.Size = UDim2.new(1, -(TX + 20), 0, 14)
                _u.onLbl.Position = UDim2.new(0, TX + 16, 0, 63)
                _u.onLbl.BackgroundTransparency = 1; _u.onLbl.Text = T.profile_online ..
                "  •  " .. tostring(LocalPlayer.AccountAge) .. " days"
                _u.onLbl.Font = Enum.Font.GothamMedium; _u.onLbl.TextSize = 12
                _u.onLbl.TextColor3 = C.sub or _C3_SUB
                _u.onLbl.TextXAlignment = Enum.TextXAlignment.Left

                
                _u.verF = Instance.new("Frame", _u.profCard)
                _u.verF.Size = UDim2.new(0, 64, 0, 24)
                _u.verF.Position = UDim2.new(1, -78, 0, 14)
                _u.verF.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255); _u.verF.BackgroundTransparency = 0.85
                _u.verF.BorderSizePixel = 0
                Instance.new("UICorner", _u.verF).CornerRadius = UDim.new(0, 12)

                _u.verLbl = Instance.new("TextLabel", _u.verF)
                _u.verLbl.Size = UDim2.new(1, 0, 1, 0); _u.verLbl.BackgroundTransparency = 1
                _u.verLbl.Text = "TLMenu"; _u.verLbl.Font = Enum.Font.GothamBlack; _u.verLbl.TextSize = 12
                _u.verLbl.TextColor3 = C.accent; _u.verLbl.TextXAlignment = Enum.TextXAlignment.Center

                Y = Y + PROF_CARD_H + 12
                divider(Y); Y  = Y + 12

                
                local CHIP_H   = 56
                local CHIP_GAP = 10
                local CHIP_W   = math.floor((HOME_W - PAD * 2 - CHIP_GAP * 2) / 3)
                statDefs       = {
                    { label = "FPS", icon = "📊", kind = "accent", key = "fps" },
                    { label = "Ping", icon = "📡", kind = "accent", key = "ping" },
                    { label = "Players", icon = "👥", kind = "orange", key = "players" },
                }

                homeStatLabels, homeChipDots = {}, {}

                for i, stat in ipairs(statDefs) do
                    local xOff = PAD + (i - 1) * (CHIP_W + CHIP_GAP)
                    local chip = Instance.new("Frame", c)
                    chip.Size = UDim2.new(0, CHIP_W, 0, CHIP_H)
                    chip.Position = UDim2.new(0, xOff, 0, Y)

                    applyModernGlass(chip, 14, 0.94)
                    addCardHover(chip)

                    local valL = Instance.new("TextLabel", chip)
                    valL.Size = UDim2.new(1, -12, 0, 22); valL.Position = UDim2.new(0, 12, 0, 10)
                    valL.BackgroundTransparency = 1; valL.Text = "◈"
                    valL.Font = Enum.Font.GothamBlack; valL.TextSize = 14
                    valL.TextColor3 = C.text
                    valL.TextXAlignment = Enum.TextXAlignment.Left
                    homeStatLabels[stat.key] = valL

                    local subL = Instance.new("TextLabel", chip)
                    subL.Size = UDim2.new(1, -12, 0, 12); subL.Position = UDim2.new(0, 12, 0, 32)
                    subL.BackgroundTransparency = 1; subL.Text = stat.label:upper()
                    subL.Font = Enum.Font.GothamMedium; subL.TextSize = 11
                    subL.TextColor3 = C.sub
                    subL.TextXAlignment = Enum.TextXAlignment.Left
                end

                local _fa, _ff, _sa = 0, 0, 0
                local _homeSvcStats; pcall(function() _homeSvcStats = game:GetService("Stats") end)
                local _homeStatPingItem; pcall(function()
                    local _s = (_homeSvcStats :: any)
                    if _s then _homeStatPingItem = _s.Network.ServerStatsItem["Data Ping"] or
                        _s.Network.ServerStatsItem["DataPing"] end
                end)
                Y = Y + CHIP_H + 20
                divider(Y); Y = Y + 14

                local function sectionLbl(yPos, txt)
                    local lbl = Instance.new("TextLabel", c)
                    lbl.Size = UDim2.new(1, -PAD * 2, 0, 14); lbl.Position = UDim2.new(0, PAD, 0, yPos)
                    lbl.BackgroundTransparency = 1; lbl.Text = txt
                    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
                    lbl.TextColor3 = C.accent
                    lbl.TextXAlignment = Enum.TextXAlignment.Left
                end

                sectionLbl(Y, "SYSTEM UTILS")
                Y = Y + 20

                
                local function makeSrvBtn(x, y, w, h, txt, sub, fn)
                    local b = Instance.new("TextButton", c)
                    b.Size = UDim2.new(0, w, 0, h); b.Position = UDim2.new(0, PAD + x, 0, Y + y)
                    b.Active = true
                    b.ZIndex = 50

                    applyModernGlass(b, 14, 0.94)
                    b.Text = ""

                    local t1 = Instance.new("TextLabel", b)
                    t1.Size = UDim2.new(1, 0, 0, 18); t1.Position = UDim2.new(0, 0, 0.5, -15)
                    t1.BackgroundTransparency = 1; t1.Text = txt
                    t1.Font = Enum.Font.GothamBlack; t1.TextSize = 12; t1.TextColor3 = C.text

                    local t2 = Instance.new("TextLabel", b)
                    t2.Size = UDim2.new(1, 0, 0, 14); t2.Position = UDim2.new(0, 0, 0.5, 1)
                    t2.BackgroundTransparency = 1; t2.Text = sub
                    t2.Font = Enum.Font.GothamMedium; t2.TextSize = 11; t2.TextColor3 = C.sub

                    b.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        twP(b, 0.2, { BackgroundTransparency = 0.88 })
                    end)
                    b.MouseLeave:Connect(function()
                        twP(b, 0.2, { BackgroundTransparency = 0.94 })
                    end)
                    b.MouseButton1Click:Connect(fn)

                    return b
                end

                local bw = (HOME_W - PAD * 2 - 12) / 2
                makeSrvBtn(0, 0, bw, 52, "Rejoin", "Current Server", function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end)
                makeSrvBtn(bw + 12, 0, bw, 52, "Server Hop", "New Server", function()
                    local x = {}
                    pcall(function()
                        local data = (game :: any):HttpGet("https://games.roblox.com/v1/games/" ..
                        game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
                        for _, v in ipairs(game:GetService("HttpService"):JSONDecode(data).data) do
                            if v.maxPlayers > v.playing and v.id ~= game.JobId then x[#x + 1] = v.id end
                        end
                    end)
                    if #x > 0 then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,
                            x[math.random(1, #x)]) end
                end)

                
                do
                    local _discDropVisible                           = false
                    local _discDrop                                  = nil

                    local discBtn                                    = makeSrvBtn(0, 64, bw * 2 + 12, 52, "Discord",
                        "Join Discord Server!", function() end)

                    
                    _discDrop                                        = Instance.new("Frame", c)
                    _discDrop.Size                                   = UDim2.new(0, bw * 2 + 12, 0, 0)
                    _discDrop.Position                               = UDim2.new(0, PAD, 0, Y + 64 + 60)
                    _discDrop.BackgroundColor3                       = Color3.fromRGB(0, 0, 0)
                    _discDrop.BackgroundTransparency                 = 0.8
                    _discDrop.BorderSizePixel                        = 0
                    _discDrop.Visible                                = false
                    _discDrop.ZIndex                                 = 15
                    _discDrop.ClipsDescendants                       = true
                    Instance.new("UICorner", _discDrop).CornerRadius = UDim.new(0, 12)

                    local dStroke                                    = _makeRealStroke(_discDrop, 1.0,
                        Color3.fromRGB(255, 255, 255), 0.6)
                    dStroke.Name                                     = "OnePieceStroke"
                    dStroke.Enabled                                  = _TL_isImgTheme(_TL_activeThemeId)

                    local _DISC_SERVERS                              = {
                        { label = "🇩🇪  German Server", link = "https://discord.gg/6RK7yANN7F" },
                        { label = "🇬🇧  English Server", link = "https://discord.gg/fRt49bcpfE" },
                    }

                    for i, srv in ipairs(_DISC_SERVERS) do
                        local row                                  = Instance.new("TextButton", _discDrop)
                        row.Size                                   = UDim2.new(1, -12, 0, 36)
                        row.Position                               = UDim2.new(0, 6, 0, 6 + (i - 1) * 42)
                        row.BackgroundColor3                       = Color3.fromRGB(255, 255, 255)
                        row.BackgroundTransparency                 = 0.94
                        row.BorderSizePixel                        = 0
                        row.Text                                   = srv.label
                        row.Font                                   = Enum.Font.GothamMedium; row.TextSize = 12
                        row.TextColor3                             = C.text
                        row.ZIndex                                 = 16
                        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

                        local rStroke                              = _makeRealStroke(row, 1.0,
                            Color3.fromRGB(255, 255, 255), 0.6)
                        rStroke.Name                               = "OnePieceStroke"
                        rStroke.Enabled                            = _TL_isImgTheme(_TL_activeThemeId)

                        row.MouseEnter:Connect(function() twP(row, 0.15, { BackgroundTransparency = 0.88 }) end)
                        row.MouseLeave:Connect(function() twP(row, 0.15, { BackgroundTransparency = 0.94 }) end)
                        row.MouseButton1Click:Connect(function()
                            pcall(function() setclipboard(srv.link) end)
                            sendNotif("Discord", "Server link copied to clipboard!", 2)
                            _discDropVisible = false
                            twP(_discDrop, 0.25, { Size = UDim2.new(0, bw * 2 + 12, 0, 0) }, Enum.EasingStyle.Quart,
                                Enum.EasingDirection.In)
                            task.delay(0.25, function()
                                if not _discDropVisible then _discDrop.Visible = false end
                            end)
                            twP(p, 0.35, { Size = UDim2.new(0, HOME_W, 0, Y + 116 + 54 + 20) })
                        end)
                    end

                    discBtn.MouseButton1Click:Connect(function()
                        _discDropVisible = not _discDropVisible

                        local diff       = _discDropVisible and 96 or 0

                        if _discDropVisible then
                            _discDrop.Visible = true
                            twP(_discDrop, 0.35, { Size = UDim2.new(0, bw * 2 + 12, 0, 92) }, Enum.EasingStyle.Back,
                                Enum.EasingDirection.Out)
                        else
                            twP(_discDrop, 0.25, { Size = UDim2.new(0, bw * 2 + 12, 0, 0) }, Enum.EasingStyle.Quart,
                                Enum.EasingDirection.In)
                            task.delay(0.25, function()
                                if not _discDropVisible then _discDrop.Visible = false end
                            end)
                        end

                        twP(p, 0.35, { Size = UDim2.new(0, HOME_W, 0, Y + 116 + 54 + 20 + diff) })
                    end)
                end

                Y = Y + 116 + 20

                
                _tlTrackConn(RunService.Heartbeat:Connect(function(dt)
                    if not _tlAlive() or not p.Visible then return end
                    _ff = _ff + 1; _fa = _fa + dt
                    if _fa >= 0.25 then
                        local fps = _mfloor(_ff / _fa); _fa = 0; _ff = 0
                        local l = homeStatLabels["fps"]
                        if l and l.Parent then
                            l.Text = fps
                            local fpsCol = fps >= 55 and C.accent or (fps >= 30 and C.orange or C.red)
                            l.TextColor3 = fpsCol
                        end
                    end
                    _sa = _sa + dt
                    if _sa >= 1.5 then
                        _sa = 0
                        local lp = homeStatLabels["players"]
                        if lp and lp.Parent then
                            local playCount = #Players:GetPlayers()
                            lp.Text = tostring(playCount)
                            lp.TextColor3 = C.orange or Color3.fromRGB(255, 155, 60)
                        end
                        local lping = homeStatLabels["ping"]
                        if lping and lping.Parent and _homeStatPingItem then
                            local ok, v = pcall(function() return _homeStatPingItem:GetValue() end)
                            if ok and v then
                                lping.Text = _mfloor(v)
                                local pingCol = v < 80 and C.accent or (v < 150 and C.orange or C.red)
                                lping.TextColor3 = pingCol
                            end
                        end
                    end
                end))

                
                _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                    pcall(function() _u.profDot.BackgroundColor3 = newT.accent end)
                    pcall(function() _u.onLbl.TextColor3 = newT.accent end)
                    pcall(function() _u.verF.BackgroundColor3 = newT.accent end)
                    pcall(function() _u.verLbl.TextColor3 = newT.accent end)
                    pcall(function() p.BackgroundColor3 = newT.panelBg end)
                    pcall(function() sonarRing.BackgroundColor3 = newT.accent end)
                    pcall(function()
                        for _, ch in ipairs(p:GetChildren()) do
                            if ch:IsA("Frame") and ch.Size.Y.Offset == 48 then
                                ch.BackgroundColor3 = newT.panelHdr
                                local g = ch:FindFirstChildOfClass("UIGradient")
                                if g then
                                    g.Color = ColorSequence.new({
                                        ColorSequenceKeypoint.new(0, newT.panelHdr),
                                        ColorSequenceKeypoint.new(1, newT.panelBg)
                                    })
                                end
                            end
                        end
                    end)

                    
                    pcall(function()
                        local isOP = _TL_isAnimeTheme(newT.id)
                        for _, child in ipairs(c:GetDescendants()) do
                            if child:IsA("UIStroke") and child.Name == "OnePiece_Stroke" then
                                child.Enabled = isOP
                            end
                        end
                    end)
                end
                p.Size = UDim2.new(0, HOME_W, 0, Y + 54)
            end

            local createScriptWidget = nil
            do

    return p, _homeSc
end

return HomeTab