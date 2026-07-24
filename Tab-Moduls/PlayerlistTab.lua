--!nocheck
-- Standalone Module: PlayerlistTab
-- Extracted from TLMenu.lua

local PlayerlistTab = {}

function PlayerlistTab.Init(ctx)
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

                        local function _togglePL()
                            if _toggling then return end
                            _toggling = true
                            _plOpen = not _plOpen
                            if _plOpen then
                                
                                musicPage.Size = UDim2.new(1, 0, 0, cardY + PL_HEADER_H + _plInnerH + 8)
                                _refreshMusicPanelH()
                                
                                tw(card, 0.18, { Size = UDim2.new(1, -16, 0, PL_HEADER_H + _plInnerH) },
                                    Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
                                tw(clipWrap, 0.18, { Size = UDim2.new(1, 0, 0, _plInnerH) },
                                    Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
                                twP(chev, 0.15, { Rotation = 180 })
                            else
                                
                                musicPage.Size = UDim2.new(1, 0, 0, cardY + PL_HEADER_H + 8)
                                _refreshMusicPanelH()
                                tw(card, 0.15, { Size = UDim2.new(1, -16, 0, PL_HEADER_H) },
                                    Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
                                tw(clipWrap, 0.15, { Size = UDim2.new(1, 0, 0, 0) },
                                    Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
                                twP(chev, 0.15, { Rotation = 0 })
                            end
                            task.delay(0.20, function() _toggling = false end)
                        end

                        hBtn.MouseButton1Click:Connect(function()
                            if not _isMobile and not _isTablet then _togglePL() end
                        end)
                        hBtn.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Touch then _togglePL() end
                        end)
                    end
                    local function _destroyPlaylistCard()
                        if _plCard then pcall(function() _plCard:Destroy() end) end
                        _plCard = nil; _plChevron = nil; _plRowFrames = {}
                        _plOpen = false; _plCurTheme = nil; _activeMusicRow = nil
                        _plInnerH = 0
                        _stopMusic()
                    end
                    
                    musicPage.Size = UDim2.new(1, 0, 0, MUSIC_BASE_H)
                    local _opRowVisible = false
                    local function _setOPRow(show, themeId)
                        if show and themeId and not THEME_PLAYLISTS[themeId] then
                            show = false
                        end
                        if show == _opRowVisible and _plCurTheme == themeId then return end
                        _opRowVisible = show
                        if show and themeId then
                            pcall(_buildPlaylistCard, themeId)
                            local cardY = MUSIC_BASE_H + PL_PAD_TOP
                            musicPage.Size = UDim2.new(1, 0, 0, cardY + PL_HEADER_H + 8)
                            _refreshMusicPanelH()
                        else
                            musicPage.Size = UDim2.new(1, 0, 0, MUSIC_BASE_H)
                            _destroyPlaylistCard()
                            _refreshMusicPanelH()
                        end
                    end
                    
                    _setOPRow(_TL_activeThemeId ~= nil, _TL_activeThemeId)
                    
                                        _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                        pcall(function()
                            if newT and newT.id then
                                _setOPRow(true, newT.id)
                            else
                                _setOPRow(false)
                            end
                        end)
                    end

                    -- ═══════════════════════════════════════════════════
                    -- Custom Music Player (filesystem-based)
                    -- ═══════════════════════════════════════════════════
                    local _cmFolder = nil
                    local _cmTracks = {}
                    local _cmRowFrames = {}
                    local _cmCard = nil
                    local _CM_ROW_H = 40
                    local _CM_PAD = 8

                    local function _cmEnsureFolder()
                        if type(isfolder) ~= "function" or type(makefolder) ~= "function" then return nil end
                        if not isfolder("Custom-Music") then
                            pcall(function() makefolder("Custom-Music") end)
                        end
                        return isfolder("Custom-Music") and "Custom-Music" or nil
                    end

                    local function _cmScan()
                        _cmTracks = {}
                        local path = _cmEnsureFolder()
                        if not path then return end
                        if type(listfiles) ~= "function" then return end
                        local ok, files = pcall(function() return listfiles(path) end)
                        if not ok or not files then return end
                        for _, file in ipairs(files) do
                            local name = file:match("([^/\\]+)$") or file
                            local ext = name:match("%.([^.]+)$")
                            if ext then
                                local le = ext:lower()
                                if le == "mp3" or le == "ogg" or le == "wav" or le == "webm" or le == "opus" then
                                    _cmTracks[#_cmTracks + 1] = { name = name:gsub("%.[^.]+$", ""), id = path .. "/" .. name, file = file }
                                end
                            end
                        end
                        table.sort(_cmTracks, function(a, b) return a.name < b.name end)
                    end

                    local function _cmRefreshRows()
                        if not _cmCard then return end
                        for _, rf in ipairs(_cmRowFrames) do pcall(function() rf.row:Destroy() end) end
                        _cmRowFrames = {}
                        local n = #_cmTracks
                        local hSub = _cmCard:FindFirstChild("CMSub")
                        if hSub then hSub.Text = n .. " Track" .. (n ~= 1 and "s" or "") end
                        local rowCont = _cmCard:FindFirstChild("CMRowCont")
                        if not rowCont then return end
                        for i, trk in ipairs(_cmTracks) do
                            local ry = (i - 1) * _CM_ROW_H + 4
                            local row = Instance.new("Frame", rowCont)
                            row.Size = UDim2.new(1, -8, 0, _CM_ROW_H - 4)
                            row.Position = UDim2.new(0, 4, 0, ry)
                            row.BackgroundColor3 = Color3.fromRGB(0, 0, 0); row.BackgroundTransparency = 0.15
                            row.BorderSizePixel = 0; corner(row, 10)
                            local rb = Instance.new("TextButton", row)
                            rb.Size = UDim2.new(1, 0, 1, 0); rb.BackgroundTransparency = 1; rb.Text = ""; rb.ZIndex = 5
                            local note = Instance.new("TextLabel", row)
                            note.Size = UDim2.new(0, 24, 1, 0); note.Position = UDim2.new(0, 6, 0, 0)
                            note.BackgroundTransparency = 1; note.Text = "♫"
                            note.Font = Enum.Font.GothamBold; note.TextSize = 14
                            note.TextColor3 = (C.accent or _C3_ACC); note.TextXAlignment = Enum.TextXAlignment.Center
                            local nl = Instance.new("TextLabel", row)
                            nl.Size = UDim2.new(1, -50, 0, 16); nl.Position = UDim2.new(0, 32, 0.5, -8)
                            nl.BackgroundTransparency = 1; nl.Text = trk.name
                            nl.Font = Enum.Font.GothamBold; nl.TextSize = 12
                            nl.TextColor3 = C.text or _C3_TEXT; nl.TextXAlignment = Enum.TextXAlignment.Left
                            _cmRowFrames[#_cmRowFrames + 1] = { row = row, nl = nl, id = trk.id, col = (C.accent or _C3_ACC), name = trk.name }
                            local tid, rr, nlr = trk.id, row, nl
                            rb.MouseButton1Click:Connect(function()
                                if _activeMusicRow == rr then
                                    _stopMusic(); _activeMusicRow = nil; _currentTrackIdx = nil
                                    for _, rf in ipairs(_cmRowFrames) do
                                        if rf.row == rr then twP(rf.row, 0.12, { BackgroundTransparency = 0.15 }); twP(rf.nl, 0.12, { TextColor3 = C.text or _C3_TEXT }) end
                                    end
                                    playBtn.Image = "rbxassetid://" .. tostring(_PLAY_IMG)
                                    twP(playImg, 0.10, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
                                    return
                                end
                                if _activeMusicRow then
                                    for _, rf in ipairs(_plRowFrames) do
                                        if rf.row == _activeMusicRow then twP(rf.row, 0.12, { BackgroundTransparency = 0.15 }); twP(rf.nameL, 0.12, { TextColor3 = C.text or _C3_TEXT }) end
                                    end
                                    for _, rf in ipairs(_cmRowFrames) do
                                        if rf.row == _activeMusicRow then twP(rf.row, 0.12, { BackgroundTransparency = 0.15 }); twP(rf.nl, 0.12, { TextColor3 = C.text or _C3_TEXT }) end
                                    end
                                end
                                _currentTracks = _cmTracks; _currentTrackIdx = i
                                _playMusicId(tid, _musicVol, trk.name)
                                _activeMusicRow = rr
                                twP(rr, 0.15, { BackgroundTransparency = 0.75 })
                                twP(nlr, 0.15, { TextColor3 = (C.accent or _C3_ACC) })
                                playBtn.Image = "rbxassetid://" .. tostring(_STOP_IMG)
                                twP(playImg, 0.10, { ImageColor3 = C.accent or _C3_ACC })
                            end)
                            rb.MouseEnter:Connect(function() if _activeMusicRow ~= rr then twP(rr, 0.08, { BackgroundTransparency = 0.82 }) end end)
                            rb.MouseLeave:Connect(function() if _activeMusicRow ~= rr then twP(rr, 0.08, { BackgroundTransparency = 0.15 }) end end)
                        end
                    end

                    local function _cmBuildCard()
                        if _cmCard then pcall(function() _cmCard:Destroy() end) end
                        _cmCard = nil; _cmRowFrames = {}
                        _cmScan()
                        local n = #_cmTracks
                        local baseY = MUSIC_BASE_H + PL_PAD_TOP + PL_HEADER_H + _CM_PAD

                        if n == 0 then
                            if _cmCard and _cmCard.Parent then _cmCard.Parent:Destroy() end
                            _cmCard = nil
                            local em = Instance.new("TextLabel", musicPage)
                            em.Size = UDim2.new(1, -16, 0, 24); em.Position = UDim2.new(0, 8, 0, baseY)
                            em.BackgroundTransparency = 1; em.Text = "No tracks found"
                            em.Font = Enum.Font.Gotham; em.TextSize = 11
                            em.TextColor3 = C.sub or _C3_SUB; em.TextXAlignment = Enum.TextXAlignment.Center
                            _cmCard = em; return
                        end


    return _togglePL
end

return PlayerlistTab