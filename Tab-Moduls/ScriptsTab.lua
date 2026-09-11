--!nocheck
-- Standalone Module: ScriptsTab
-- Extracted from TLMenu.lua

local ScriptsTab = {}

function ScriptsTab.Init(ctx)
    local _ENUM_SORT_ORDER_LAYOUT = ctx._ENUM_SORT_ORDER_LAYOUT or (Enum and Enum.SortOrder and Enum.SortOrder.LayoutOrder) or 0

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
    local _sc = ctx._sc or {}
    local _TL_refs = ctx._TL_refs
    local _TL_loadModule = ctx._TL_loadModule
    local _TL_VP = ctx._TL_VP

                local p, c           = makePanel("Scripts", C.accent2)
                _sc.scriptsPanel     = p
                _sc.scriptsScroll    = c
                p.Size               = UDim2.new(0, PANEL_W, 0, 108)
                p.ClipsDescendants   = false
                c.ClipsDescendants   = true
                c.ScrollBarThickness = 0
                c.ScrollingEnabled   = false
                c.Size               = UDim2.new(1, 0, 1, 0)
                c.CanvasSize         = UDim2.new(0, 0, 0, 0)
                c.Position           = UDim2.new(0, 0, 0, 56)
                local _sbt           = p:FindFirstChild("ScrollTrack")
                if _sbt then _sbt.Visible = false end
                
                do
                    local _ok2, _vp2 = pcall(function() return workspace.CurrentCamera.ViewportSize end)
                    _vp2 = _ok2 and _vp2 or Vector2.new(1920, 1080)
                    local _t2 = pcall(function() return _SvcUIS.TouchEnabled end)
                        and _SvcUIS.TouchEnabled
                    local _k2 = pcall(function() return _SvcUIS.KeyboardEnabled end)
                        and _SvcUIS.KeyboardEnabled
                    if _t2 and not _k2 then
                        c.ScrollingEnabled   = true
                         c.ScrollBarThickness = 3; c.ScrollBarImageColor3 = C.accent
                        c.ClipsDescendants   = true
                        p.ClipsDescendants   = true
                    end
                end
                local SCRIPT_CATS               = {
                    { id = "Troll",    img = "rbxassetid://120351884957369", col = C.red },
                    { id = "Movement", img = "rbxassetid://115822754618291", col = C.accent2 },
                    { id = "Visual",   img = "rbxassetid://122084214712991", col = C.accent3 },
                    { id = "Misc",     img = "rbxassetid://117318347375651", col = C.accent },
                    { id = "Combat",   img = "rbxassetid://84261020849153",  col = C.orange, iconSize = 56 },
                }
                local S_CARD_GAP                = 8
                local S_CARD_W                  = math.floor((PANEL_W - 32 - S_CARD_GAP * (#SCRIPT_CATS - 1)) /
                #SCRIPT_CATS)
                local S_CARD_H                  = 80
                sSubPages                       = {}
                sActiveCat                      = nil
                sGrid                           = Instance.new("Frame", c)
                sGrid.Size                      = UDim2.new(1, -32, 0, S_CARD_H)
                sGrid.Position                  = UDim2.new(0, 16, 0, 0)
                sGrid.BackgroundTransparency    = 1
                sGrid.BorderSizePixel           = 0
                local sSubArea                        = Instance.new("Frame", c)
                sSubArea.Size                   = UDim2.new(1, 0, 0, 0)
                sSubArea.Position               = UDim2.new(0, 0, 0, S_CARD_H + 12)
                sSubArea.BackgroundTransparency = 1
                sSubArea.BorderSizePixel        = 0
                sSubArea.ClipsDescendants       = false
                local _TL_WIDGET_CLOSE_ICON     = "rbxassetid://111119570195816"
                local _scriptWidgetMod = _TL_loadModule("SCRIPTS-TAB/TL-ScriptWidget")
                if _scriptWidgetMod then
                    _scriptWidgetMod.init({
                        ScreenGui = ScreenGui,
                        _sc = _sc,
                        MDARK = MDARK, MHDR = MHDR, MGLOW = MGLOW,
                        _C3_WHITE = _C3_WHITE,
                        _TL_WIDGET_CLOSE_ICON = _TL_WIDGET_CLOSE_ICON,
                        getNearestPlayer = getNearestPlayer,
                    })
                end
                local function makeWidgetOpenBtn(parent, xPos, yPos, label, callback)
                    if _scriptWidgetMod then return _scriptWidgetMod.makeWidgetOpenBtn(parent, xPos, yPos, label, callback) end
                end
                createScriptWidget = function(scriptName, accentCol, onToggleFn, initState, extraBuilder)
                    if _scriptWidgetMod then return _scriptWidgetMod.createScriptWidget(scriptName, accentCol, onToggleFn, initState, extraBuilder) end
                end
                local function sRow(parent, yPos, labelText, badgeText, badgeCol, initOn, onToggle)
                    local row, setFn, getFn = cleanRow(parent, yPos, labelText, badgeText, badgeCol, initOn, onToggle)
                    return row, setFn, getFn
                end
                task.wait(0.05)
                trollPage                        = Instance.new("Frame", sSubArea)
                trollPage.BackgroundTransparency = 1; trollPage.BorderSizePixel = 0
                trollPage.Visible                = false
                trollLayout                      = Instance.new("UIListLayout", trollPage)
                trollLayout.SortOrder            = _ENUM_SORT_ORDER_LAYOUT or (Enum and Enum.SortOrder and Enum.SortOrder.LayoutOrder) or 0
                trollLayout.FillDirection        = Enum.FillDirection.Vertical
                trollLayout.Padding              = UDim.new(0, 6)
                trollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    trollPage.Size = UDim2.new(1, 0, 0, trollLayout.AbsoluteContentSize.Y)
                end)
                
                local TROLL_TOP_H, TROLL_GAP, TROLL_BOT_H = 46, 4, 34
                local TROLL_ROW_H = TROLL_TOP_H + TROLL_GAP + TROLL_BOT_H
                local _activePlayerPillDropdown = nil
                local function createPlayerPill(parent, yPos, labelText, defaultText, onSelect, onToggle)
                    local pill = Instance.new("Frame", parent)
                    pill.Size = UDim2.new(1, -32, 0, 24)
                    pill.Position = UDim2.new(0, 16, 0, yPos)
                    pill.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28); pill.BackgroundTransparency = 0
                    pill.BorderSizePixel = 0; corner(pill, 12)

                    local pillLbl = Instance.new("TextLabel", pill)
                    pillLbl.Size = UDim2.new(1, -24, 1, 0); pillLbl.Position = UDim2.new(0, 10, 0, 0)
                    pillLbl.BackgroundTransparency = 1; pillLbl.Text = defaultText
                    pillLbl.Font = Enum.Font.GothamBold; pillLbl.TextSize = 13
                    pillLbl.TextColor3 = C.text; pillLbl.TextXAlignment = Enum.TextXAlignment.Left
                    pillLbl.TextTruncate = Enum.TextTruncate.AtEnd; pillLbl.ZIndex = 9

                    local pillBtn = Instance.new("TextButton", pill)
                    pillBtn.Size = UDim2.new(1, 0, 1, 0); pillBtn.BackgroundTransparency = 1
                    pillBtn.Text = ""; pillBtn.ZIndex = 10; pillBtn.Active = true

                    local pillS = stroke(pill, 1, C.accent, 0.6)

                    local arrow = Instance.new("TextLabel", pill)
                    arrow.Size = UDim2.new(0, 20, 1, 0); arrow.Position = UDim2.new(1, -22, 0, 0)
                    arrow.BackgroundTransparency = 1; arrow.Text = "▼"; arrow.Font = Enum.Font.GothamBold
                    arrow.TextSize = 10; arrow.TextColor3 = C.text; arrow.ZIndex = 9; arrow.TextTransparency = 0.4

                    local ddFrame = Instance.new("Frame", ScreenGui)
                    ddFrame.AnchorPoint = Vector2.new(0, 0); ddFrame.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28)
                    ddFrame.BackgroundTransparency = 0; ddFrame.BorderSizePixel = 0
                    ddFrame.ZIndex = 5000; ddFrame.Visible = false
                    ; ddFrame.ClipsDescendants = true
                    corner(ddFrame, 12); stroke(ddFrame, 1.2, C.accent, 0.3)

                    local ddScroll = Instance.new("ScrollingFrame", ddFrame)
                    ddScroll.Size = UDim2.new(1, 0, 1, 0); ddScroll.BackgroundTransparency = 1
                    ddScroll.BorderSizePixel = 0; ddScroll.ScrollBarThickness = 3; ddScroll.ScrollBarImageColor3 = C.accent
                    ddScroll.ScrollBarImageColor3 = C.accent or C.red; ddScroll.ScrollingDirection = Enum
                    .ScrollingDirection.Y
                    ddScroll.CanvasSize = UDim2.new(0, 0, 0, 0); ddScroll.ZIndex = 5001

                    local ddList = Instance.new("UIListLayout", ddScroll)
                    ddList.FillDirection = Enum.FillDirection.Vertical; ddList.VerticalAlignment = Enum
                    .VerticalAlignment.Top
                    ddList.SortOrder = Enum.SortOrder.LayoutOrder; ddList.Padding = UDim.new(0, 2)
                    local DD_IH, DD_MAX_ROWS = 32, 6
                    local ddSlot = { tween = nil }
                    local selectedPlayer = nil

                    local function closeDd()
                        if _activePlayerPillDropdown ~= ddFrame then return end
                        _activePlayerPillDropdown = nil
                        local w = ddFrame.Size.X.Offset
                        local t = twC(ddSlot, ddFrame, 0.2, { Size = UDim2.new(0, w, 0, 0) }, Enum.EasingStyle.Quart,
                            Enum.EasingDirection.In)
                        t.Completed:Connect(function()
                            ddFrame.Visible = false
                        end)
                        if onToggle then onToggle(false, 0) end
                        twP(arrow, 0.2, { Rotation = 0 })
                        twP(pillS, 0.2, { Color = C.accent, Transparency = 0.6 })
                    end

                    local function buildDd()
                        for _, ch in ipairs(ddScroll:GetChildren()) do if ch:IsA("GuiObject") then ch:Destroy() end end
                        local plrs = {}
                        for _, pl in ipairs(Players:GetPlayers()) do if pl ~= LocalPlayer then table.insert(plrs, pl) end end
                        if #plrs == 0 then
                            local noLbl = Instance.new("TextLabel", ddScroll)
                            noLbl.Size = UDim2.new(1, 0, 0, DD_IH); noLbl.BackgroundTransparency = 1
                            noLbl.Text = "No other players online"; noLbl.Font = Enum.Font.GothamBold; noLbl.TextSize = 12
                            noLbl.TextColor3 = C.sub; noLbl.ZIndex = 5002
                        end
                        for _, pl in ipairs(plrs) do
                            local row = Instance.new("Frame", ddScroll)
                            row.Size = UDim2.new(1, -4, 0, DD_IH); row.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38)
                            row.BackgroundTransparency = 0.9; row.BorderSizePixel = 0; row.ZIndex = 5002; corner(row, 10)
                            local pad = Instance.new("UIPadding", row); pad.PaddingLeft = UDim.new(0, 12)
                            local nameLbl = Instance.new("TextLabel", row)
                            nameLbl.Size = UDim2.new(1, -10, 1, 0); nameLbl.BackgroundTransparency = 1
                            nameLbl.Text = pl.DisplayName; nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13
                            nameLbl.TextColor3 = (selectedPlayer == pl) and C.red or C.text
                            nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 5003
                            local rBtn = Instance.new("TextButton", row)
                            rBtn.Size = UDim2.new(1, 0, 1, 0); rBtn.BackgroundTransparency = 1; rBtn.Text = ""
                            rBtn.ZIndex = 5004; rBtn.Active = true
                            rBtn.MouseEnter:Connect(function() twP(row, 0.15, { BackgroundTransparency = 0.7 }) end)
                            rBtn.MouseLeave:Connect(function() twP(row, 0.15, { BackgroundTransparency = 0.9 }) end)
                            rBtn.MouseButton1Click:Connect(function()
                                selectedPlayer = pl; pillLbl.Text = pl.DisplayName; pillLbl.TextColor3 = C.accent
                                if onSelect then onSelect(pl) end; closeDd()
                            end)
                        end
                        local cnt = math.max(1, #plrs)
                        ddScroll.CanvasSize = UDim2.new(0, 0, 0, cnt * (DD_IH + 2) + 8)
                        return math.min(cnt, DD_MAX_ROWS) * (DD_IH + 2) + 8
                    end

                    pillBtn.MouseButton1Click:Connect(function()
                        if _activePlayerPillDropdown == ddFrame then
                            closeDd(); return
                        end
                        if _activePlayerPillDropdown then pcall(function() _activePlayerPillDropdown.Visible = false end) end
                        _activePlayerPillDropdown = ddFrame
                        local targetH = buildDd(); ddScroll.CanvasPosition = Vector2.new(0, 0)

                        local absPos, absSize = pill.AbsolutePosition, pill.AbsoluteSize
                        local screenH = ScreenGui.AbsoluteSize.Y
                        local screenW = ScreenGui.AbsoluteSize.X
                        local pw = absSize.X
                        local posX = math.clamp(absPos.X, 0, math.max(0, screenW - pw))
                        local spaceBelow = screenH - (absPos.Y + absSize.Y + 12)
                        local spaceAbove = absPos.Y - 12
                        local finalH, posY
                        if spaceBelow >= targetH + 8 or spaceBelow >= spaceAbove then
                            finalH = math.min(targetH, spaceBelow - 4)
                            posY = absPos.Y + absSize.Y + 4
                        else
                            finalH = math.min(targetH, spaceAbove - 4)
                            posY = absPos.Y - finalH - 4
                        end

                        ddFrame.Position = UDim2.new(0, posX, 0, posY)
                        ddFrame.Size = UDim2.new(0, pw, 0, 0); ddFrame.Visible = true
                        if onToggle then onToggle(true, finalH) end
                        twP(pillS, 0.2, { Color = C.accent or C.red, Transparency = 0.2 })
                        twP(arrow, 0.2, { Rotation = 180 })
                        twC(ddSlot, ddFrame, 0.25, { Size = UDim2.new(0, pw, 0, finalH) }, Enum.EasingStyle.Back,
                            Enum.EasingDirection.Out)
                    end)

                    UserInputService.InputBegan:Connect(function(input)
                        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and _activePlayerPillDropdown == ddFrame then
                            task.defer(function()
                                local mp = UserInputService:GetMouseLocation()
                                local abP, abS = ddFrame.AbsolutePosition, ddFrame.AbsoluteSize
                                local inD = mp.X >= abP.X and mp.X <= abP.X + abS.X and mp.Y >= abP.Y and
                                mp.Y <= abP.Y + abS.Y
                                local paP, paS = pill.AbsolutePosition, pill.AbsoluteSize
                                local inP = mp.X >= paP.X and mp.X <= paP.X + paS.X and mp.Y >= paP.Y and
                                mp.Y <= paP.Y + paS.Y
                                if not inD and not inP then closeDd() end
                            end)
                        end
                    end)

                    return {
                        pill = pill,
                        setTarget = function(pl)
                            if not pl then
                                selectedPlayer = nil; pillLbl.Text = defaultText; pillLbl.TextColor3 = C.text
                            else
                                selectedPlayer = pl; pillLbl.Text = pl.DisplayName; pillLbl.TextColor3 = C.accent or
                                C.red
                            end
                            if onSelect then onSelect(pl) end
                        end,
                        getSelected = function() return selectedPlayer end,
                        destroy = function() pcall(function()
                                ddFrame:Destroy(); pill:Destroy()
                            end) end
                    }
                end
                do
                    local rushActive         = false
                    local rushConn           = nil
                    local rushNoclipConn     = nil
                    local RUSH_ANIM_ID = "132168791204839"
                    local rushAnimTrack      = nil
                    local rushAnimConn       = nil
                    local function rushStopAnim()
                        if rushAnimConn then
                            rushAnimConn:Disconnect(); rushAnimConn = nil
                        end
                        if rushAnimTrack then
                            pcall(function()
                                rushAnimTrack:AdjustSpeed(1); rushAnimTrack:Stop()
                            end)
                            rushAnimTrack = nil
                        end
                    end
                    local function rushPlayAnim(char)
                        if not char then return end
                        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                        local track = nil
                        local emoteId = tonumber(RUSH_ANIM_ID)
                        pcall(function()
                            local desc = hum:FindFirstChildOfClass("HumanoidDescription")
                            if not desc then desc = hum:WaitForChild("HumanoidDescription", 3) end
                            if desc then
                                desc:AddEmote("RushAnim", emoteId)
                                track = hum:PlayEmoteAndGetAnimTrackById(emoteId)
                            end
                        end)
                        if not track then
                            pcall(function()
                                track = hum:PlayEmoteAndGetAnimTrackById(emoteId)
                            end)
                        end
                        if not track then
                            pcall(function()
                                track = _AF_loadAndPlayAnimation(hum, RUSH_ANIM_ID)
                                if track then track:Play() end
                            end)
                        end
                        if not track or type(track) ~= "userdata" then return end
                        if _genv.TLAnimFreeze then _genv.TLAnimFreeze(true) end
                        rushAnimTrack = track
                        if rushAnimConn then rushAnimConn:Disconnect() end
                        rushAnimConn = track.Stopped:Connect(function()
                            if rushActive then
                                task.wait(0.05)
                                if rushActive then pcall(function() rushPlayAnim(LocalPlayer.Character) end) end
                            end
                        end)
                    end
                    local _rushWidgetToggleFn = nil
                    local function rushStop(updateToggle)
                        rushActive = false
                        if rushConn then
                            rushConn:Disconnect(); rushConn = nil
                        end
                        if rushNoclipConn then
                            rushNoclipConn:Disconnect(); rushNoclipConn = nil
                        end
                        rushStopAnim()
                        if _genv.TLAnimFreeze then _genv.TLAnimFreeze(false) end
                        local myChar = LocalPlayer.Character
                        if myChar then
                            local hrp = myChar:FindFirstChild("HumanoidRootPart")
                            local hum = myChar:FindFirstChildOfClass("Humanoid")
                            if hrp then hrp.Anchored = false end
                            if hum then
                                if not flyActive then hum.PlatformStand = false end; hum.WalkSpeed = 16
                            end
                            for _, part in ipairs(myChar:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = true end
                            end
                        end
                        
                        if updateToggle and _rushWidgetToggleFn then
                            pcall(function() _rushWidgetToggleFn(false) end)
                        end
                        
                    end
                    local flingMod = _TL_loadModule("TL-BALL-FLING")
                    local flingSelectedPlayer = nil

                    local FLING_SUB_H = 12
                    local FLING_ROW_H = TROLL_TOP_H + TROLL_GAP + FLING_SUB_H + 8
                    local flingRow = Instance.new("Frame", trollPage)
                    flingRow.Size = UDim2.new(1, 0, 0, FLING_ROW_H); flingRow.LayoutOrder = 3
                    flingRow.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2; flingRow.BackgroundTransparency = 0
                    flingRow.BorderSizePixel = 0; corner(flingRow, 12)
                    local flingTop = Instance.new("Frame", flingRow)
                    flingTop.Size = UDim2.new(1, 0, 0, TROLL_TOP_H); flingTop.Position = UDim2.new(0, 0, 0, 0)
                    flingTop.BackgroundTransparency = 1; flingTop.BorderSizePixel = 0
                    local flingRowDot = Instance.new("Frame", flingRow)
                    flingRowDot.Size = UDim2.new(0, 3, 0, 26); flingRowDot.Visible = false; flingRowDot.Position = UDim2
                    .new(0, 0, 0, 10)
                    flingRowDot.BackgroundColor3 = C.red or Color3.fromRGB(220, 60, 60); flingRowDot.BackgroundTransparency = 0.4
                    flingRowDot.BorderSizePixel = 0; corner(flingRowDot, 99)
                    local flingLbl = Instance.new("TextLabel", flingTop)
                    flingLbl.Size = UDim2.new(0, 120, 1, 0); flingLbl.Position = UDim2.new(0, 16, 0, 0)
                    flingLbl.BackgroundTransparency = 1; flingLbl.Text = "Fling"
                    flingLbl.Font = Enum.Font.GothamBold; flingLbl.TextSize = 13
                    flingLbl.TextColor3 = C.text or _C3_TEXT3
                    flingLbl.TextXAlignment = Enum.TextXAlignment.Left
                    local flingSub = Instance.new("TextLabel", flingRow)
                    flingSub.Size = UDim2.new(1, -32, 0, FLING_SUB_H); flingSub.Position = UDim2.new(0, 16, 0,
                        TROLL_TOP_H + TROLL_GAP)
                    flingSub.BackgroundTransparency = 1; flingSub.Text = "Anchor-Fling  ◈  BodyVelocity"
                    flingSub.Font = Enum.Font.GothamBold; flingSub.TextSize = 9
                    flingSub.TextColor3 = C.sub or _C3_SUB
                    flingSub.TextXAlignment = Enum.TextXAlignment.Left
                    local flingTrack = Instance.new("Frame", flingTop)
                    flingTrack.Size = UDim2.new(0, 32, 0, 18); flingTrack.Position = UDim2.new(1, -44, 0.5, -9)
                    flingTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3
                    flingTrack.BackgroundTransparency = 0.2; flingTrack.BorderSizePixel = 0; corner(flingTrack, 99)
                    local flingKnob = Instance.new("Frame", flingTrack)
                    flingKnob.Size = UDim2.new(0, 12, 0, 12); flingKnob.Position = UDim2.new(0, 2, 0.5, -6)
                    flingKnob.BackgroundColor3 = _C3_SUB2
                    flingKnob.BackgroundTransparency = 0; flingKnob.BorderSizePixel = 0; corner(flingKnob, 99)
                    local flingTogState = false
                    local function flingSetToggle(on)
                        flingTogState = on
                        if on then
                            twP(flingTrack, 0.15,
                                { BackgroundColor3 = C.red or Color3.fromRGB(220, 60, 60), BackgroundTransparency = 0.55 })
                            twP(flingKnob, 0.15, { BackgroundColor3 = _C3_WHITE, Position = UDim2.new(1, -14, 0.5, -6) })

                            local target = flingSelectedPlayer
                            if not target then
                                target = getNearestPlayer()
                            end

                            if target then
                                flingSelectedPlayer = target
                                flingMod.start(target)
                            else
                                flingSetToggle(false); return
                            end
                        else
                            twP(flingTrack, 0.15, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3, BackgroundTransparency = 0.2 })
                            twP(flingKnob, 0.15, { BackgroundColor3 = _C3_SUB2, Position = UDim2.new(0, 2, 0.5, -6) })
                            flingMod.stop()
                        end
                    end
                    local flingRowBtn = Instance.new("TextButton", flingRow)
                    
                    flingRowBtn.Size = UDim2.new(1, 0, 0, FLING_ROW_H - TROLL_TOP_H)
                    flingRowBtn.Position = UDim2.new(0, 0, 0, TROLL_TOP_H)
                    flingRowBtn.BackgroundTransparency = 1; flingRowBtn.Text = ""; flingRowBtn.ZIndex = 5
                    flingRowBtn.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        twP(flingRow, 0.08, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG4 })
                    end)
                    flingRowBtn.MouseLeave:Connect(function()
                        twP(flingRow, 0.08, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2 })
                    end)
                    local flingTogBtn = Instance.new("TextButton", flingTop)
                    flingTogBtn.Size = UDim2.new(0, 36, 0, 24); flingTogBtn.Position = UDim2.new(1, -44, 0.5, -12)
                    flingTogBtn.BackgroundTransparency = 1; flingTogBtn.Text = ""; flingTogBtn.ZIndex = 7
                    flingTogBtn.MouseButton1Click:Connect(function() flingSetToggle(not flingTogState) end)
                    local flingWState = false
                    local flingWidgetSelected = nil
                    local function flingWBtnPillDo()
                        local flingWState2 = flingWState or false
                        createScriptWidget("Fling", C.accent2, function(on)
                            flingWState = on
                            if on then
                                local target = flingWidgetSelected
                                if not target then target = getNearestPlayer() end
                                if target then
                                    flingWidgetSelected = target
                                    flingSelectedPlayer = target
                                    flingMod.start(target)
                                    return true
                                end
                                return false
                            else
                                flingMod.stop()
                            end
                        end, flingWState2, function(body, width, yOffset, ac, setToggleFn)
                            local sRow = Instance.new("Frame", body)
                            sRow.Size = UDim2.new(1, -24, 0, 38); sRow.Position = UDim2.new(0, 12, 0, yOffset + 4)
                            sRow.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28); sRow.BackgroundTransparency = 0.4
                            sRow.BorderSizePixel = 0; corner(sRow, 10)
                            local sStr = _makeDummyStroke(sRow); sStr.Thickness = 1; sStr.Color = ac; sStr.Transparency = 0.8

                            local sHdr = Instance.new("TextLabel", sRow)
                            sHdr.Size = UDim2.new(1, -16, 1, 0); sHdr.Position = UDim2.new(0, 12, 0, 0)
                            sHdr.BackgroundTransparency = 1; sHdr.Text = "FLING ACTIVE"; sHdr.Font = Enum.Font
                            .GothamBlack
                            sHdr.TextSize = 10; sHdr.TextColor3 = ac; sHdr.TextXAlignment = Enum.TextXAlignment.Left

                            local sIco = Instance.new("Frame", sRow)
                            sIco.Size = UDim2.new(0, 6, 0, 6); sIco.Position = UDim2.new(1, -18, 0.5, -3)
                            sIco.BackgroundColor3 = ac; sIco.BorderSizePixel = 0; corner(sIco, 99)

                            local pRow = Instance.new("Frame", body)
                            pRow.Size = UDim2.new(1, -24, 0, 30); pRow.Position = UDim2.new(0, 12, 0, yOffset + 46)
                            pRow.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28); pRow.BackgroundTransparency = 0.4
                            pRow.BorderSizePixel = 0; corner(pRow, 10)
                            local pStr = _makeDummyStroke(pRow); pStr.Thickness = 1; pStr.Color = C.bg3; pStr.Transparency = 0.6

                            local pLbl = Instance.new("TextLabel", pRow)
                            pLbl.Size = UDim2.new(0, 50, 1, 0); pLbl.Position = UDim2.new(0, 10, 0, 0)
                            pLbl.BackgroundTransparency = 1; pLbl.Text = "Target:"; pLbl.Font = Enum.Font.GothamBold
                            pLbl.TextSize = 10; pLbl.TextColor3 = C.sub; pLbl.TextXAlignment = Enum.TextXAlignment.Left

                            local pBtn = Instance.new("TextButton", pRow)
                            pBtn.Size = UDim2.new(1, -70, 1, -6); pBtn.Position = UDim2.new(0, 60, 0, 3)
                            pBtn.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38); pBtn.BackgroundTransparency = 0.3
                            pBtn.BorderSizePixel = 0; corner(pBtn, 8)
                            pBtn.Text = flingWidgetSelected and flingWidgetSelected.Name or "Nearest"; pBtn.Font = Enum.Font.Gotham
                            pBtn.TextSize = 11; pBtn.TextColor3 = C.text; pBtn.TextXAlignment = Enum.TextXAlignment.Left

                            local function refreshFlingPlayerList()
                                local pls = Players:GetPlayers()
                                local maxH = 180
                                local count = math.min(#pls, 12)
                                local totalH = count * 24 + 4
                                local actualH = math.min(totalH, maxH)

                                local drop = Instance.new("Frame", body)
                                drop.Size = UDim2.new(0, width - 24, 0, actualH)
                                drop.Position = UDim2.new(0, 12, 0, yOffset + 80)
                                drop.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28); drop.BackgroundTransparency = 0.1
                                drop.BorderSizePixel = 0; corner(drop, 10); drop.ZIndex = 15
                                local dStr = _makeDummyStroke(drop); dStr.Thickness = 1; dStr.Color = C.bg3; dStr.Transparency = 0.4

                                local scroll = Instance.new("ScrollingFrame", drop)
                                scroll.Size = UDim2.new(1, -4, 1, -4); scroll.Position = UDim2.new(0, 2, 0, 2)
                                scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
                                scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = C.accent
                                scroll.CanvasSize = UDim2.new(0, 0, 0, count * 24 + 4)
                                local sLayout = Instance.new("UIListLayout", scroll)
                                sLayout.SortOrder = Enum.SortOrder.LayoutOrder; sLayout.Padding = UDim.new(0, 0)

                                local closed = false
                                local function closeDrop()
                                    if closed then return end; closed = true
                                    pcall(function() drop:Destroy() end)
                                end

                                for i, pl in ipairs(pls) do
                                    local row = Instance.new("TextButton", scroll)
                                    row.Size = UDim2.new(1, 0, 0, 24); row.LayoutOrder = i
                                    row.BackgroundColor3 = (flingWidgetSelected == pl) and C.bg3 or C.bg2
                                    row.BackgroundTransparency = 0.6; row.BorderSizePixel = 0; row.Text = ""
                                    row.TextColor3 = C.text; row.ZIndex = 16
                                    row.MouseEnter:Connect(function() row.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38); row.BackgroundTransparency = 0.3 end)
                                    row.MouseLeave:Connect(function()
                                        row.BackgroundColor3 = (flingWidgetSelected == pl) and C.bg3 or C.bg2
                                        row.BackgroundTransparency = 0.6
                                    end)
                                    local rl = Instance.new("TextLabel", row)
                                    rl.Size = UDim2.new(1, -10, 1, 0); rl.Position = UDim2.new(0, 8, 0, 0)
                                    rl.BackgroundTransparency = 1; rl.Text = pl.Name; rl.Font = Enum.Font.Gotham
                                    rl.TextSize = 11; rl.TextColor3 = C.text; rl.TextXAlignment = Enum.TextXAlignment.Left
                                    rl.ZIndex = 17
                                    row.MouseButton1Click:Connect(function()
                                        flingWidgetSelected = pl
                                        flingSelectedPlayer = pl
                                        pBtn.Text = pl.Name
                                        closeDrop()
                                    end)
                                end

                                pBtn.MouseButton1Click:Connect(closeDrop)
                                return drop
                            end

                            local activeDrop = nil
                            pBtn.MouseButton1Click:Connect(function()
                                if activeDrop and activeDrop.Parent then
                                    pcall(function() activeDrop:Destroy() end)
                                    activeDrop = nil
                                    return
                                end
                                activeDrop = refreshFlingPlayerList()
                            end)

                            return 84
                        end)
                    end
                    makeWidgetOpenBtn(flingTop, 138, 10, "OPEN", flingWBtnPillDo)
                    LocalPlayer.CharacterAdded:Connect(function()
                        flingMod.stop()
                        flingSetToggle(false)
                        flingWidgetSelected = nil
                    end)
                end

                do
                    local outfitExpandRow                  = Instance.new("Frame", trollPage)
                    outfitExpandRow.Size              = UDim2.new(1, 0, 0, 46); outfitExpandRow.LayoutOrder = 5
                    outfitExpandRow.BackgroundColor3  = Color3.fromRGB(22, 22, 22); outfitExpandRow.BackgroundTransparency = 0
                    outfitExpandRow.BorderSizePixel   = 0;
                    local outfitExpandCorner                = Instance.new("UICorner", outfitExpandRow); outfitExpandCorner.CornerRadius =
                    UDim.new(0, 12)
                    local outfitExpandRowS                  = _makeDummyStroke(outfitExpandRow)
                    outfitExpandRowS.Thickness         = 1; outfitExpandRowS.Color = Color3.fromRGB(44, 44, 48); outfitExpandRowS.Transparency = 0.3

                    local outfitExpandLbl                   = Instance.new("TextLabel", outfitExpandRow)
                    outfitExpandLbl.Size               = UDim2.new(0, 150, 1, 0); outfitExpandLbl.Position = UDim2.new(0, 16, 0,
                        0)
                    outfitExpandLbl.BackgroundTransparency = 1; outfitExpandLbl.Text = "Outfit Expand"
                    outfitExpandLbl.Font               = Enum.Font.GothamBold; outfitExpandLbl.TextSize = 13
                    outfitExpandLbl.TextColor3         = Color3.fromRGB(255, 255, 255); outfitExpandLbl.TextXAlignment = Enum
                    .TextXAlignment.Left

                    local outfitExpandBtn                   = Instance.new("TextButton", outfitExpandRow)
                    outfitExpandBtn.Size               = UDim2.new(0, 70, 0, 24); outfitExpandBtn.Position = UDim2.new(1, -82,
                        0.5, -12)
                    outfitExpandBtn.BackgroundColor3   = Color3.fromRGB(18, 8, 8); outfitExpandBtn.BackgroundTransparency = 0
                    outfitExpandBtn.BorderSizePixel    = 0; outfitExpandBtn.Text = "Open"
                    outfitExpandBtn.Font               = Enum.Font.GothamBold; outfitExpandBtn.TextSize = 13
                    outfitExpandBtn.TextColor3         = Color3.fromRGB(255, 255, 255); outfitExpandBtn.ZIndex = 5
                    local outfitExpandBtnCorner             = Instance.new("UICorner", outfitExpandBtn); outfitExpandBtnCorner.CornerRadius =
                    UDim.new(0, 4)
                    local outfitExpandBtnS                  = _makeDummyStroke(outfitExpandBtn)
                    outfitExpandBtnS.Thickness         = 1.2; outfitExpandBtnS.Color = C.accent; outfitExpandBtnS.Transparency = 0.1

                    
                    
                    
                    
                    
                    
                    
                    
                    do
                        local _oeUrl = _TL_MODULES_BASE .. "TL-OUTFIT-EXPAND.lua"
                        outfitExpandBtn.MouseButton1Click:Connect(function()
                            local ok, source = pcall(function() return (game :: any):HttpGet(_oeUrl) end)
                            if not ok or not source or #source < 50 then
                                warn("[TL] Module load failed: TL-OUTFIT-EXPAND — " .. tostring(source))
                                sendNotif("Outfit Expand", "Module offline ❌", 2)
                                return
                            end
                            local fn, loadErr = loadstring(source)
                            if not fn then
                                warn("[TL] Module compile error: TL-OUTFIT-EXPAND — " .. tostring(loadErr))
                                sendNotif("Outfit Expand", "Module offline ❌", 2)
                                return
                            end
                            local execOk, execErr = pcall(fn)
                            if not execOk then
                                warn("[TL] Module exec error: TL-OUTFIT-EXPAND — " .. tostring(execErr))
                                sendNotif("Outfit Expand", "Module offline ❌", 2)
                            end
                        end)
                    end
                end

                task.wait(0.05)
                            
            
            
movePage = Instance.new("Frame", sSubArea)
                movePage.BackgroundTransparency = 1; movePage.BorderSizePixel = 0
                movePage.Visible = false
                
                do
                    local avMod = _TL_loadModule("SCRIPTS-TAB/TL-AntiVoid")
                    if avMod then
                        avMod.init({ RunService = RunService, LocalPlayer = LocalPlayer, sendNotif = sendNotif })
                        sRow(movePage, 0, "Anti-Void", "Im not letting you die in the Void!!", C.accent2, false,
                            function(on)
                                if on then
                                    avMod.start()
                                    sendNotif("Anti-Void", "Anti-Void activated ✅ Watching over you!", 3)
                                else
                                    avMod.stop()
                                    sendNotif("Anti-Void", "Anti-Void deactivated.", 2)
                                end
                            end)
                    end
                end
                movePage.Size = UDim2.new(1, 0, 0, 280)

                
                do
                    local arMod = _TL_loadModule("SCRIPTS-TAB/TL-AntiRagdoll")
                    if arMod then
                        arMod.init({ RunService = RunService, LocalPlayer = LocalPlayer, flyActiveFn = function() return flyActive end })
                        sRow(movePage, 56, "Anti-Ragdoll", "Movement", C.red, false, function(on)
                            if on then arMod.start() else arMod.stop() end
                        end)
                    end
                end

                
                do
                    local pfMod = _TL_loadModule("SCRIPTS-TAB/TL-PunchFling")
                    if pfMod then
                        pfMod.init({ RunService = RunService, Players = Players, LocalPlayer = LocalPlayer, sendNotif = sendNotif })
                        sRow(movePage, 112, "Punch-Fling", "Combat", C.orange, false, function(on)
                            if on then
                                pfMod.start()
                                sendNotif("Punch-Fling", "🔧 Tool im Backpack", 3)
                            else
                                pfMod.stop()
                                sendNotif("Punch-Fling", "Deactivated & Tool removed.", 2)
                            end
                        end)
                        LocalPlayer.CharacterAdded:Connect(function()
                            task.wait(1)
                            if pfMod.isActive() then pfMod.start() end
                        end)
                    end
                end

                
                do
                    local tfMod = _TL_loadModule("SCRIPTS-TAB/TL-TouchFling")
                    if tfMod then
                        tfMod.init({ RunService = RunService, Players = Players, LocalPlayer = LocalPlayer, sendNotif = sendNotif, _AF_loadAndPlayAnimation = _AF_loadAndPlayAnimation, flyMuteSoundsFn = _flyMuteSounds })
                        local tfModeList = tfMod.getModes()
                        local tfRow, tfSetTog, _ = sRow(movePage, 168, "Touch Fling", "Movement V5", C.accent2, false,
                            function(on)
                                if on then
                                    tfMod.start()
                                    sendNotif("Touch Fling", "Fling active: " .. tfMod.getMode(), 3)
                                else
                                    tfMod.stop()
                                    sendNotif("Touch Fling", "Disabled.", 2)
                                end
                            end)

                        
                        local mPill = Instance.new("Frame", tfRow)
                        mPill.Size = UDim2.new(0, 85, 0, 26); mPill.Position = UDim2.new(0, 80, 0.5, -13)
                        mPill.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38); mPill.BackgroundTransparency = 0.5; corner(mPill, 8)
                        mPill.ZIndex = 12; local mPillS = stroke(mPill, 1.2, C.accent, 0.6)

                        local mBtn = Instance.new("TextButton", mPill)
                        mBtn.Size = UDim2.new(1, 0, 1, 0); mBtn.BackgroundTransparency = 1; mBtn.Text = tfMod.getMode():upper() .. "  ▼"
                        mBtn.Font = Enum.Font.GothamBlack; mBtn.TextSize = 8; mBtn.TextColor3 = _C3_WHITE; mBtn.ZIndex = 13

                        mBtn.MouseEnter:Connect(function()
                            tw(mPill, 0.15, { BackgroundTransparency = 0.2, BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255) }):Play(); tw(mPillS, 0.15, { Transparency = 0.2 }):Play()
                        end)
                        mBtn.MouseLeave:Connect(function()
                            tw(mPill, 0.15, { BackgroundTransparency = 0.5, BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) }):Play(); tw(mPillS, 0.15, { Transparency = 0.6 }):Play()
                        end)

                        
                        local mDrop = Instance.new("Frame", ScreenGui)
                        mDrop.Size = UDim2.new(0, 85, 0, #tfModeList * 26 + 4)
                        mDrop.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28); mDrop.Visible = false; mDrop.ZIndex = 11000; corner(mDrop, 8); stroke(mDrop, 1.5, C.accent, 0.3)

                        
                        RunService.RenderStepped:Connect(function()
                            if not mDrop or not mDrop.Parent or not mDrop.Visible then return end
                            if not mPill or not mPill.Visible or not mPill.Parent then
                                mDrop.Visible = false; return
                            end
                            local abs = mPill.AbsolutePosition
                            mDrop.Position = UDim2.new(0, abs.X, 0, abs.Y + 26)
                        end)

                        for i, m in ipairs(tfModeList) do
                            local b = Instance.new("TextButton", mDrop)
                            b.Size = UDim2.new(1, -8, 0, 24); b.Position = UDim2.new(0, 4, 0, (i - 1) * 26 + 2)
                            b.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38); b.BackgroundTransparency = 1; b.Text = m:upper()
                            b.Font = Enum.Font.GothamBold; b.TextSize = 8; b.TextColor3 = C.text; b.ZIndex = 11001; corner(b, 4)

                            b.MouseEnter:Connect(function() tw(b, 0.1, { BackgroundTransparency = 0.7 }):Play() end)
                            b.MouseLeave:Connect(function() tw(b, 0.1, { BackgroundTransparency = 1 }):Play() end)

                            b.MouseButton1Click:Connect(function()
                                tfMod.setMode(m); mBtn.Text = tfMod.getMode():upper() .. "  ▼"; mDrop.Visible = false
                                if tfMod.isActive() then sendNotif("Touch Fling", "Mode: " .. tfMod.getMode(), 1) end
                            end)
                        end
                        mBtn.MouseButton1Click:Connect(function() mDrop.Visible = not mDrop.Visible end)

                        
                        local sMin, sMax = 10, 250
                        local tfSpeed = tfMod.getSpeed()
                        local sTrack = Instance.new("Frame", tfRow)
                        sTrack.Size = UDim2.new(0, 110, 0, 6); sTrack.Position = UDim2.new(0, 222, 0.5, -3)
                        sTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38); corner(sTrack, 3); stroke(sTrack, 1, C.accent2, 0.5)
                        sTrack.ZIndex = 12
                        local sFill = Instance.new("Frame", sTrack)
                        sFill.Size = UDim2.new((tfSpeed - sMin) / (sMax - sMin), 0, 1, 0); sFill.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255); corner(sFill, 3); sFill.ZIndex = 13
                        local sKnob = Instance.new("Frame", sTrack)
                        sKnob.Size = UDim2.new(0, 12, 0, 12); sKnob.Position = UDim2.new((tfSpeed - sMin) / (sMax - sMin), -6, 0.5, -6)
                        sKnob.BackgroundColor3 = _C3_WHITE; corner(sKnob, 99); local sKnobS = stroke(sKnob, 1.5, C.accent2, 0); sKnob.ZIndex = 14
                        local sVal = Instance.new("TextLabel", tfRow)
                        sVal.Size = UDim2.new(0, 24, 0, 14); sVal.Position = UDim2.new(0, 336, 0.5, -7)
                        sVal.BackgroundTransparency = 1; sVal.Text = tostring(tfSpeed); sVal.Font = Enum.Font.GothamBold; sVal.TextSize = 10; sVal.TextColor3 = C.text; sVal.ZIndex = 13

                        local sTargetV = (tfSpeed - sMin) / (sMax - sMin)
                        local sVisualV = sTargetV
                        local sDrag = false
                        local function upTFSlider(pos)
                            if not sTrack or not sTrack.Parent then return end
                            local rel = math.clamp((pos.X - sTrack.AbsolutePosition.X) / sTrack.AbsoluteSize.X, 0, 1)
                            tfMod.setSpeed(math.floor(sMin + rel * (sMax - sMin)))
                            sTargetV = rel; sVal.Text = tostring(tfMod.getSpeed())
                        end

                        
                        task.spawn(function()
                            while sTrack and sTrack.Parent do
                                local dt = task.wait()
                                if not movePage.Visible then continue end
                                sVisualV = sVisualV + (sTargetV - sVisualV) * math.min(dt * 20, 1)
                                sFill.Size = UDim2.new(sVisualV, 0, 1, 0)
                                sKnob.Position = UDim2.new(sVisualV, -6, 0.5, -6)
                                local p = 0.6 + math.sin(tick() * 5) * 0.4
                                sKnob.BackgroundTransparency = 0.1 * p
                                if sKnobS then sKnobS.Transparency = 0.2 * p end
                            end
                        end)

                        local sInp = Instance.new("TextButton", sTrack)
                        sInp.Size = UDim2.new(1, 80, 1, 60); sInp.Position = UDim2.new(0, -40, 0, -30); sInp.BackgroundTransparency = 1; sInp.Text = ""; sInp.ZIndex = 25
                        sInp.InputBegan:Connect(function(ip)
                            if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
                                sDrag = true; upTFSlider(ip.Position)
                            end
                        end)
                        UserInputService.InputChanged:Connect(function(ip)
                            if sDrag and (ip.UserInputType == Enum.UserInputType.MouseMovement or ip.UserInputType == Enum.UserInputType.Touch) then
                                upTFSlider(ip.Position)
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(ip)
                            if ip.UserInputType == Enum.UserInputType.MouseButton1 or ip.UserInputType == Enum.UserInputType.Touch then
                                sDrag = false
                            end
                        end)
                    end
                end

                
                do
                    local ctMod = _TL_loadModule("SCRIPTS-TAB/TL-ClickTeleport")
                    if ctMod then
                        ctMod.init({ RunService = RunService, UserInputService = UserInputService or _SvcUIS, LocalPlayer = LocalPlayer, sendNotif = sendNotif })
                        sRow(movePage, 224, "Click Teleport", "Movement", C.accent2, false, function(on)
                            if on then
                                ctMod.start()
                                sendNotif("Click Teleport", "📍 Klick = Teleport", 2)
                            else
                                ctMod.stop()
                            end
                        end)
                        LocalPlayer.CharacterAdded:Connect(function()
                            if ctMod.isActive() then ctMod.start() end
                        end)
                    end
                end

                task.wait(0.05)
                            
            
            
visualPage = Instance.new("Frame", sSubArea)
                visualPage.BackgroundTransparency = 1; visualPage.BorderSizePixel = 0
                visualPage.Visible = false
                espRow, espSetFn = sRow(visualPage, 0, "ESP / Highlight", "Visual", C.accent2, false, setESP)
                do
                    local PILL_W, PILL_H                = 110, 26
                    local SWATCH_SZ                     = 12
                    espColorPill                        = Instance.new("Frame", espRow)
                    espColorPill.Size                   = UDim2.new(0, PILL_W, 0, PILL_H)
                    espColorPill.Position               = UDim2.new(0, 210, 0.5, -13)
                    espColorPill.BackgroundColor3       = C.bg2
                    espColorPill.BackgroundTransparency = 0.1
                    espColorPill.BorderSizePixel        = 0
                    espColorPill.ZIndex                 = 7
                    corner(espColorPill, 8)
                    stroke(espColorPill, 1, C.accent2, 0.45)
                    espSwatch                  = Instance.new("Frame", espColorPill)
                    espSwatch.Size             = UDim2.new(0, SWATCH_SZ, 0, SWATCH_SZ)
                    espSwatch.Position         = UDim2.new(0, 5, 0.5, -SWATCH_SZ / 2)
                    espSwatch.BackgroundColor3 = espCurrentColor()
                    espSwatch.BorderSizePixel  = 0
                    corner(espSwatch, 3)
                    espColLbl                         = Instance.new("TextLabel", espColorPill)
                    espColLbl.Size                    = UDim2.new(1, -(SWATCH_SZ + 28), 1, 0)
                    espColLbl.Position                = UDim2.new(0, SWATCH_SZ + 10, 0, 0)
                    espColLbl.BackgroundTransparency  = 1
                    espColLbl.Text                    = ESP_COLORS[espColorIdx].name
                    espColLbl.Font                    = Enum.Font.GothamBold
                    espColLbl.TextSize                = 10
                    espColLbl.TextColor3              = C.text
                    espColLbl.TextXAlignment          = Enum.TextXAlignment.Left
                    espArrow                          = Instance.new("ImageLabel", espColorPill)
                    espArrow.Size                     = UDim2.new(0, 16, 0, 16)
                    espArrow.Position                 = UDim2.new(1, -20, 0.5, -8)
                    espArrow.BackgroundTransparency   = 1
                    espArrow.Image                    = "rbxassetid://115943405523448"
                    espArrow.ImageColor3              = _C3_WHITE
                    espArrow.ImageTransparency        = 0
                    espArrow.ScaleType                = Enum.ScaleType.Fit
                    espArrow.BorderSizePixel          = 0
                    espArrow.ZIndex                   = 8
                    local ITEM_H                      = 24
                    local DD_VISIBLE                  = 4
                    espDdFrame                        = Instance.new("Frame", espColorPill)
                    espDdFrame.Size                   = UDim2.new(0, PILL_W, 0, 0)
                    espDdFrame.Position               = UDim2.new(0, 0, 1, 4)
                    espDdFrame.BackgroundColor3       = C.bg2
                    espDdFrame.BackgroundTransparency = 0.05
                    espDdFrame.BorderSizePixel        = 0
                    espDdFrame.ClipsDescendants       = true
                    espDdFrame.ZIndex                 = 20
                    corner(espDdFrame, 8)
                    stroke(espDdFrame, 1, C.accent2, 0.4)
                    espDdScroll                            = Instance.new("ScrollingFrame", espDdFrame)
                    espDdScroll.Size                       = UDim2.new(1, 0, 1, 0)
                    espDdScroll.BackgroundTransparency     = 1
                    espDdScroll.BorderSizePixel            = 0
                     espDdScroll.ScrollBarThickness         = 3; espDdScroll.ScrollBarImageColor3 = C.accent
                    espDdScroll.ScrollBarImageColor3       = C.accent2
                    espDdScroll.ScrollBarImageTransparency = 0
                    espDdScroll.ScrollingDirection         = Enum.ScrollingDirection.Y
                    espDdScroll.CanvasSize                 = UDim2.new(0, 0, 0, 0)
                    espDdScroll.ElasticBehavior            = Enum.ElasticBehavior.Never
                    espDdScroll.ZIndex                     = 21
                    espDdList                              = Instance.new("UIListLayout", espDdScroll)
                    espDdList.SortOrder                    = _ENUM_SORT_ORDER_LAYOUT or (Enum and Enum.SortOrder and Enum.SortOrder.LayoutOrder) or 0
                    espDdList.Padding                      = UDim.new(0, 2)
                    ddPad                                  = Instance.new("UIPadding", espDdScroll)
                    ddPad.PaddingLeft                      = UDim.new(0, 4); ddPad.PaddingRight = UDim.new(0, 4)
                    ddPad.PaddingTop                       = UDim.new(0, 3); ddPad.PaddingBottom = UDim.new(0, 3)
                    ddOpen                                 = false
                    for i, entry in ipairs(ESP_COLORS) do
                        local item                        = Instance.new("TextButton", espDdScroll)
                        item.Size                   = UDim2.new(1, -8, 0, ITEM_H)
                        item.BackgroundColor3       = C.bg3
                        item.BackgroundTransparency = 0.85
                        item.BorderSizePixel        = 0
                        item.Text                   = ""
                        item.ZIndex                 = 21
                        item.LayoutOrder            = i
                        corner(item, 6)
                        local sw            = Instance.new("Frame", item)
                        sw.Size             = UDim2.new(0, 10, 0, 10)
                        sw.Position         = UDim2.new(0, 5, 0.5, -5)
                        sw.BackgroundColor3 = entry.color
                        sw.BorderSizePixel  = 0
                        sw.ZIndex           = 22
                        corner(sw, 3)
                        local nl                  = Instance.new("TextLabel", item)
                        nl.Size                   = UDim2.new(1, -22, 1, 0)
                        nl.Position               = UDim2.new(0, 19, 0, 0)
                        nl.BackgroundTransparency = 1
                        nl.Text                   = entry.name
                        nl.Font                   = Enum.Font.GothamBold
                        nl.TextSize               = 10
                        nl.TextColor3             = C.text
                        nl.TextXAlignment         = Enum.TextXAlignment.Left
                        nl.ZIndex                 = 22
                        item.MouseEnter:Connect(function()
                            _sc._playHoverSound()
                            twP(item, 0.08, { BackgroundTransparency = 0.5 })
                        end)
                        item.MouseLeave:Connect(function()
                            twP(item, 0.08, { BackgroundTransparency = 0.85 })
                        end)
                        item.MouseButton1Click:Connect(function()
                            espColorIdx = i
                            espSwatch.BackgroundColor3 = entry.color
                            espColLbl.Text = entry.name
                            _saveCache("esp_color", { idx = espColorIdx })
                            
                            for _, ch in ipairs(espDdScroll:GetChildren()) do
                                if ch:IsA("TextButton") then
                                    local l = ch:FindFirstChildOfClass("TextLabel")
                                    if l then l.TextColor3 = C.text end
                                end
                            end
                            
                            
                            nl.TextColor3 = entry.color
                            refreshESPColor()
                            twP(espDdFrame, 0.15, { Size = UDim2.new(0, PILL_W, 0, 0) }, Enum.EasingStyle.Quart,
                                Enum.EasingDirection.In)
                            twP(espArrow, 0.1, { ImageTransparency = 0 })
                            ddOpen = false
                            task.delay(0.15, function()
                                if not ddOpen then
                                    espRow.ZIndex = 1
                                end
                            end)
                        end)
                        item.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Touch then
                                espColorIdx = i
                                espSwatch.BackgroundColor3 = entry.color
                                espColLbl.Text = entry.name
                                _saveCache("esp_color", { idx = espColorIdx })
                                
                                for _, ch in ipairs(espDdScroll:GetChildren()) do
                                    if ch:IsA("TextButton") then
                                        local l = ch:FindFirstChildOfClass("TextLabel")
                                        if l then l.TextColor3 = C.text end
                                    end
                                end
                                
                                nl.TextColor3 = entry.color
                                refreshESPColor()
                                twP(espDdFrame, 0.15, { Size = UDim2.new(0, PILL_W, 0, 0) }, Enum.EasingStyle.Quart,
                                    Enum.EasingDirection.In)
                                twP(espArrow, 0.1, { ImageTransparency = 0 })
                                ddOpen = false
                                task.delay(0.15, function()
                                    if not ddOpen then
                                        espRow.ZIndex = 1
                                    end
                                end)
                            end
                        end)
                    end
                    local TOTAL_CANVAS_H              = #ESP_COLORS * (ITEM_H + 2) + 6
                    local TOTAL_DD_H                  = math.min(DD_VISIBLE, #ESP_COLORS) * (ITEM_H + 2) + 6
                    espDdScroll.CanvasSize            = UDim2.new(0, 0, 0, TOTAL_CANVAS_H)
                    espPillBtn                        = Instance.new("TextButton", espColorPill)
                    espPillBtn.Size                   = UDim2.new(1, 0, 1, 0)
                    espPillBtn.BackgroundTransparency = 1
                    espPillBtn.Text                   = ""
                    espPillBtn.ZIndex                 = 9
                    espPillBtn.MouseButton1Click:Connect(function()
                        ddOpen = not ddOpen
                        if ddOpen then
                            espRow.ZIndex = 15
                            espDdFrame.Size = UDim2.new(0, PILL_W, 0, 0)
                            twP(espDdFrame, 0.18, { Size = UDim2.new(0, PILL_W, 0, TOTAL_DD_H) }, Enum.EasingStyle.Back,
                                Enum.EasingDirection.Out)
                            twP(espArrow, 0.1, { ImageTransparency = 0.4 })
                        else
                            twP(espDdFrame, 0.13, { Size = UDim2.new(0, PILL_W, 0, 0) }, Enum.EasingStyle.Quart,
                                Enum.EasingDirection.In)
                            twP(espArrow, 0.1, { ImageTransparency = 0 })
                            task.delay(0.15, function()
                                if not ddOpen then
                                    espRow.ZIndex = 1
                                end
                            end)
                        end
                    end)
                    espPillBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then
                            ddOpen = not ddOpen
                            if ddOpen then
                                espRow.ZIndex = 15
                                espDdFrame.Size = UDim2.new(0, PILL_W, 0, 0)
                                twP(espDdFrame, 0.18, { Size = UDim2.new(0, PILL_W, 0, TOTAL_DD_H) },
                                    Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                                twP(espArrow, 0.1, { ImageTransparency = 0.4 })
                            else
                                twP(espDdFrame, 0.13, { Size = UDim2.new(0, PILL_W, 0, 0) }, Enum.EasingStyle.Quart,
                                    Enum.EasingDirection.In)
                                twP(espArrow, 0.1, { ImageTransparency = 0 })
                                task.delay(0.15, function()
                                    if not ddOpen then
                                        espRow.ZIndex = 1
                                    end
                                end)
                            end
                        end
                    end)
                end
                visualPage.Size = UDim2.new(1, 0, 0, 120)

                
                do
                    local _shdMod = _TL_loadModule("TL-Shader")
                    local shRow = Instance.new("Frame", visualPage)
                    shRow.Size = UDim2.new(1, 0, 0, 54)
                    shRow.Position = UDim2.new(0, 0, 0, 52)
                    shRow.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2; shRow.BackgroundTransparency = 0
                    shRow.BorderSizePixel = 0; corner(shRow, 12); shRow.LayoutOrder = 5
                    local shRowS = _makeDummyStroke(shRow)
                    shRowS.Thickness = 1; shRowS.Color = C.bg3 or _C3_BG3; shRowS.Transparency = 0.3
                    local shDot = Instance.new("Frame", shRow)
                    shDot.Size = UDim2.new(0, 3, 0, 34); shDot.Visible = false; shDot.Position = UDim2.new(0, 0, 0.5, -17)
                    shDot.BackgroundColor3 = Color3.fromRGB(99, 155, 255); shDot.BackgroundTransparency = 0.4
                    shDot.BorderSizePixel = 0; corner(shDot, 99)
                    local shLbl = Instance.new("TextLabel", shRow)
                    shLbl.Size = UDim2.new(0, 160, 0, 18); shLbl.Position = UDim2.new(0, 14, 0, 8)
                    shLbl.BackgroundTransparency = 1; shLbl.Text = "Shader"
                    shLbl.Font = Enum.Font.GothamBold; shLbl.TextSize = 13
                    shLbl.TextColor3 = C.text or Color3.new(1, 1, 1)
                    shLbl.TextXAlignment = Enum.TextXAlignment.Left
                    local shSub = Instance.new("TextLabel", shRow)
                    shSub.Size = UDim2.new(0, 160, 0, 12); shSub.Position = UDim2.new(0, 14, 0, 26)
                    shSub.BackgroundTransparency = 1; shSub.Text = if _shdMod then "Basic Realistic Shaders" else "Module offline"
                    shSub.Font = Enum.Font.Gotham; shSub.TextSize = 9
                    shSub.TextColor3 = Color3.fromRGB(99, 155, 255)
                    shSub.TextXAlignment = Enum.TextXAlignment.Left
                    local shBadge = Instance.new("Frame", shRow)
                    shBadge.Size = UDim2.new(0, 36, 0, 14); shBadge.Position = UDim2.new(0, 179, 0, 8)
                    shBadge.BackgroundColor3 = Color3.fromRGB(99, 155, 255); shBadge.BackgroundTransparency = 0.7
                    shBadge.BorderSizePixel = 0; corner(shBadge, 99)
                    local shBTxt = Instance.new("TextLabel", shBadge)
                    shBTxt.Size = UDim2.new(1, 0, 1, 0); shBTxt.BackgroundTransparency = 1
                    shBTxt.Text = "Visual"; shBTxt.Font = Enum.Font.GothamBold
                    shBTxt.TextSize = 8; shBTxt.TextColor3 = Color3.fromRGB(99, 155, 255)
                    shBTxt.TextXAlignment = Enum.TextXAlignment.Center
                    local shBtnF = Instance.new("Frame", shRow)
                    shBtnF.Size = UDim2.new(0, 80, 0, 26); shBtnF.Position = UDim2.new(1, -90, 0.5, -13)
                    shBtnF.BackgroundColor3 = Color3.fromRGB(10, 18, 40)
                    shBtnF.BackgroundTransparency = 0.2; shBtnF.BorderSizePixel = 0; corner(shBtnF, 8)
                    local shBtnS = _makeDummyStroke(shBtnF)
                    shBtnS.Thickness = 1; shBtnS.Color = Color3.fromRGB(99, 155, 255); shBtnS.Transparency = 0.55
                    local shBtn = Instance.new("TextButton", shBtnF)
                    shBtn.Size = UDim2.new(1, 0, 1, 0); shBtn.BackgroundTransparency = 1
                    shBtn.Text = "OFF"; shBtn.Font = Enum.Font.GothamBold
                    shBtn.TextSize = 11; shBtn.TextColor3 = Color3.new(1, 1, 1); shBtn.ZIndex = 5; shBtn.Active = true
                    local function shToggle()
                        if not _shdMod then return end
                        local nowActive = not _shdMod.isActive()
                        if nowActive then _shdMod.start() else _shdMod.stop() end
                        if _shdMod.isActive() then
                            shBtn.Text = "ON"; shBtn.TextColor3 = Color3.fromRGB(99, 155, 255)
                            twP(shBtnF, 0.15, { BackgroundColor3 = Color3.fromRGB(12, 28, 70) })
                            twP(shBtnS, 0.15, { Transparency = 0.1 })
                            sendNotif("Shader", "Basic Shaders ACTIVE", 2)
                        else
                            shBtn.Text = "OFF"; shBtn.TextColor3 = Color3.new(1, 1, 1)
                            twP(shBtnF, 0.15, { BackgroundColor3 = Color3.fromRGB(10, 18, 40), BackgroundTransparency = 0.2 })
                            twP(shBtnS, 0.15, { Transparency = 0.55 })
                            sendNotif("Shader", "Shader DEACTIVATED", 2)
                        end
                    end
                    shBtn.MouseButton1Click:Connect(shToggle)
                    shBtn.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        twP(shBtnF, 0.08, { BackgroundTransparency = 0 }); twP(shBtnS, 0.08, { Transparency = 0.1 }); twP(
                        shBtn, 0.08, { TextColor3 = Color3.fromRGB(99, 155, 255) })
                    end)
                    shBtn.MouseLeave:Connect(function()
                        if not (_shdMod and _shdMod.isActive()) then
                            twP(shBtnF, 0.08, { BackgroundTransparency = 0.2 }); twP(shBtnS, 0.08, { Transparency = 0.55 }); twP(
                            shBtn, 0.08, { TextColor3 = Color3.new(1, 1, 1) })
                        end
                    end)
                end

                _sc.sonstigePage                        = Instance.new("Frame", sSubArea)
                _sc.sonstigePage.BackgroundTransparency = 1; _sc.sonstigePage.BorderSizePixel = 0
                _sc.sonstigePage.Visible                = false
                
                _sc.miscLayout                          = Instance.new("UIListLayout", _sc.sonstigePage)
                _sc.miscLayout.SortOrder                = _ENUM_SORT_ORDER_LAYOUT or (Enum and Enum.SortOrder and Enum.SortOrder.LayoutOrder) or 0
                _sc.miscLayout.FillDirection            = Enum.FillDirection.Vertical
                _sc.miscLayout.Padding                  = UDim.new(0, 0)

                
                _sc.panelTw                             = {} 
                _sc.resizeScriptsPanel                  = function(contentH, easeStyle, easeDir, duration)
                    local HEADER_OFF = 56
                    local newH       = HEADER_OFF + (S_CARD_H + 12) + contentH + 32
                    local scrollH    = newH - HEADER_OFF
                    
                    if _sc.panelTw.p then pcall(function() _sc.panelTw.p:Cancel() end) end
                    if _sc.panelTw.sub then pcall(function() _sc.panelTw.sub:Cancel() end) end
                    _sc.scriptsPanel.ClipsDescendants = true
                    local dur          = duration or 0.22
                    local sty          = easeStyle or Enum.EasingStyle.Quart
                    local dir          = easeDir or Enum.EasingDirection.Out
                    _sc.panelTw.sub    = twP(sSubArea, dur, { Size = UDim2.new(1, 0, 0, contentH + 16) }, sty, dir)
                    _sc.panelTw.p      = twP(_sc.scriptsPanel, dur, { Size = UDim2.new(0, PANEL_W, 0, newH) }, sty, dir)
                    local totalContentH = (S_CARD_H + 12) + contentH + 16
                    local viewH = math.max(scrollH, totalContentH + 8)
                    c.Size             = UDim2.new(1, 0, 0, viewH)
                    c.CanvasSize       = UDim2.new(0, 0, 0, totalContentH + 8)
                    c.ScrollingEnabled = true
                    task.delay(dur + 0.05, function()
                            pcall(function()
                                _sc.scriptsPanel.ClipsDescendants = false
                            end)
                    end)
                end

                
                _sc.updateMiscSize                      = function()
                    local H = _sc.miscLayout.AbsoluteContentSize.Y
                    _sc.sonstigePage.Size = UDim2.new(1, 0, 0, math.max(H, 1))
                    if sActiveCat ~= "Misc" then return end
                    _sc.resizeScriptsPanel(H)
                end

                
                _sc.updateActiveCatSize                 = function()
                    if not sActiveCat then return end
                    local pg = sSubPages and sSubPages[sActiveCat]
                    if not pg then return end
                    task.defer(function()
                        local pgH = pg.AbsoluteSize.Y
                        if pgH < 1 then pgH = pg.Size.Y.Offset end
                        _sc.resizeScriptsPanel(pgH)
                    end)
                end

                
                
                
                _sc.folderHdrH                          = 40
                _sc.makeMiscFolder                      = function(folderName, folderIcon, accentCol, layoutOrder,
                                                                   pageParent)
                    local isOpen                     = false
                    local headerVisible              = true
                    local childrenH                  = 0
                    local childCount                 = 0

                    local container                  = Instance.new("Frame", pageParent or _sc.sonstigePage)
                    container.Size                   = UDim2.new(1, 0, 0, _sc.folderHdrH)
                    container.BackgroundTransparency = 1
                    container.BorderSizePixel        = 0
                    container.LayoutOrder            = layoutOrder
                    container.ClipsDescendants       = false

                    local hdr                        = Instance.new("Frame", container)
                    hdr.Size                         = UDim2.new(1, 0, 0, _sc.folderHdrH)
                    hdr.Position                     = UDim2.new(0, 0, 0, 0)
                    hdr.BackgroundColor3             = C.bg2 or Color3.fromRGB(3, 14, 6)
                    hdr.BackgroundTransparency       = 0
                    hdr.BorderSizePixel              = 0
                    corner(hdr, 10)

                    local hdrDot                  = Instance.new("Frame", hdr)
                    hdrDot.Size                   = UDim2.new(0, 3, 0, _sc.folderHdrH - 16); hdrDot.Visible = false
                    hdrDot.Position               = UDim2.new(0, 0, 0.5, -(_sc.folderHdrH - 16) / 2)
                    hdrDot.BackgroundColor3       = _themePanelColor(accentCol, C.accent)
                    hdrDot.BackgroundTransparency = 0.4
                    hdrDot.BorderSizePixel        = 0
                    corner(hdrDot, 99)

                    local iconLbl                  = Instance.new("TextLabel", hdr)
                    iconLbl.Size                   = UDim2.new(0, 20, 0, 20)
                    iconLbl.Position               = UDim2.new(0, 12, 0.5, -10)
                    iconLbl.BackgroundTransparency = 1
                    iconLbl.Text                   = folderIcon
                    iconLbl.Font                   = Enum.Font.GothamBlack
                    iconLbl.TextSize               = 14
                    iconLbl.TextColor3             = Color3.fromRGB(255, 255, 255)
                    iconLbl.TextXAlignment         = Enum.TextXAlignment.Center

                    local nameLbl                  = Instance.new("TextLabel", hdr)
                    nameLbl.Size                   = UDim2.new(1, -78, 0, 18)
                    nameLbl.Position               = UDim2.new(0, 38, 0.5, -9)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text                   = folderName
                    nameLbl.Font                   = Enum.Font.GothamBold
                    nameLbl.TextSize               = 13
                    nameLbl.TextColor3             = C.text or Color3.fromRGB(210, 255, 220)
                    nameLbl.TextXAlignment         = Enum.TextXAlignment.Left

                    local badge                    = Instance.new("Frame", hdr)
                    badge.Size                     = UDim2.new(0, 18, 0, 14)
                    badge.Position                 = UDim2.new(1, -50, 0.5, -7)
                    badge.BackgroundColor3         = _themePanelColor(accentCol, C.accent)
                    badge.BackgroundTransparency   = 0.78
                    badge.BorderSizePixel          = 0
                    corner(badge, 99)
                    local badgeLbl                  = Instance.new("TextLabel", badge)
                    badgeLbl.Size                   = UDim2.new(1, 0, 1, 0)
                    badgeLbl.BackgroundTransparency = 1
                    badgeLbl.Text                   = "0"
                    badgeLbl.Font                   = Enum.Font.GothamBlack
                    badgeLbl.TextSize               = 9
                    badgeLbl.TextColor3             = _themePanelColor(accentCol, C.accent)
                    badgeLbl.TextXAlignment         = Enum.TextXAlignment.Center

                    local chevron                   = Instance.new("TextLabel", hdr)
                    chevron.Size                    = UDim2.new(0, 20, 0, 20)
                    chevron.Position                = UDim2.new(1, -26, 0.5, -10)
                    chevron.BackgroundTransparency  = 1
                    chevron.Text                    = "▼"
                    chevron.Font                    = Enum.Font.GothamBlack
                    chevron.TextSize                = 10
                    chevron.TextColor3              = _themePanelColor(accentCol, C.accent)
                    chevron.TextXAlignment          = Enum.TextXAlignment.Center

                    local divider                   = Instance.new("Frame", container)
                    divider.Size                    = UDim2.new(1, -16, 0, 1)
                    divider.Position                = UDim2.new(0, 8, 0, _sc.folderHdrH)
                    divider.BackgroundColor3        = _themePanelColor(accentCol, C.accent)
                    divider.BackgroundTransparency  = 0.82
                    divider.BorderSizePixel         = 0
                    divider.Visible                 = false

                    local content                   = Instance.new("Frame", container)
                    content.Size                    = UDim2.new(1, 0, 0, 0)
                    content.Position                = UDim2.new(0, 0, 0, _sc.folderHdrH + 1)
                    content.BackgroundTransparency  = 1
                    content.BorderSizePixel         = 0
                    content.ClipsDescendants        = false
                    content.Visible                 = false

                    local btn                       = Instance.new("TextButton", hdr)
                    btn.Size                        = UDim2.new(1, 0, 1, 0)
                    btn.BackgroundTransparency      = 1
                    btn.Text                        = ""
                    btn.ZIndex                      = 6

                    local function applyFolderTheme(newT)
                        local accent = (newT and newT.accent) or (C.accent or _themePanelColor(accentCol, C.accent))
                        local textCol = (newT and newT.text) or (C.text or Color3.fromRGB(210, 255, 220))
                        hdr.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or Color3.fromRGB(3, 14, 6)
                        hdrDot.BackgroundColor3 = accent
                        iconLbl.TextColor3 = accent
                        nameLbl.TextColor3 = textCol
                        badge.BackgroundColor3 = accent
                        badgeLbl.TextColor3 = accent
                        chevron.TextColor3 = accent
                        divider.BackgroundColor3 = accent
                    end

                    local function applyState()
                        local effectiveOpen = isOpen or not headerVisible
                        local baseH = headerVisible and _sc.folderHdrH or 0
                        local contentH = effectiveOpen and childrenH or 0

                        hdr.Visible = headerVisible
                        btn.Visible = headerVisible
                        btn.Active = headerVisible
                        content.Position = UDim2.new(0, 0, 0, headerVisible and (_sc.folderHdrH + 1) or 0)
                        divider.Position = UDim2.new(0, 8, 0, headerVisible and _sc.folderHdrH or 0)
                        divider.Visible = headerVisible and effectiveOpen and childrenH > 0
                        content.Visible = effectiveOpen and childrenH > 0
                        content.Size = UDim2.new(1, 0, 0, contentH)
                        container.Size = UDim2.new(1, 0, 0, baseH + contentH)
                        chevron.Rotation = effectiveOpen and 90 or 0
                        applyFolderTheme()
                    end

                    btn.MouseEnter:Connect(function()
                        if _isMobile then return end
                        _sc._playHoverSound()
                        if headerVisible then
                            twP(hdr, 0.08, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or Color3.fromRGB(7, 22, 10) })
                        end
                    end)
                    btn.MouseLeave:Connect(function()
                        if headerVisible then
                            twP(hdr, 0.08, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or Color3.fromRGB(3, 14, 6) })
                        end
                    end)

                    local _folderAnimating = false
                    btn.MouseButton1Click:Connect(function()
                        if not headerVisible or _folderAnimating then return end
                        isOpen = not isOpen
                        if isOpen then
                            _folderAnimating = true
                            content.Size     = UDim2.new(1, 0, 0, 0)
                            content.Visible  = true
                            divider.Visible  = true
                            container.Size   = UDim2.new(1, 0, 0, _sc.folderHdrH + childrenH)
                            twP(content, 0.24, { Size = UDim2.new(1, 0, 0, childrenH) },
                                Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                            twP(chevron, 0.20, { Rotation = 90 }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                            task.delay(0.26, function()
                                _folderAnimating = false
                                applyFolderTheme()
                            end)
                        else
                            _folderAnimating = true
                            twP(content, 0.20, { Size = UDim2.new(1, 0, 0, 0) },
                                Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                            twP(chevron, 0.18, { Rotation = 0 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                            task.delay(0.22, function()
                                container.Size   = UDim2.new(1, 0, 0, _sc.folderHdrH)
                                content.Visible  = false
                                divider.Visible  = false
                                _folderAnimating = false
                                applyFolderTheme()
                            end)
                        end
                    end)

                    local function addRow(label, badge2, badgeCol, initOn, onToggle)
                        local ROW_H             = 46
                        local PAD_H             = 6
                        local PAD_SIDE          = 8
                        local yPos              = PAD_H + childCount * (ROW_H + 4)
                        local row, setFn, getFn = cleanRow(content, yPos, label, badge2,
                            _themePanelColor(badgeCol, C.accent), initOn, onToggle)
                        row.Size                = UDim2.new(1, -PAD_SIDE * 2, 0, ROW_H)
                        row.Position            = UDim2.new(0, PAD_SIDE, 0, yPos)
                        childCount              = childCount + 1
                        childrenH               = PAD_H + childCount * (ROW_H + 4) + PAD_H
                        badgeLbl.Text           = tostring(childCount)
                        applyState()
                        return row, setFn, getFn
                    end

                    if _panelColorHooks then
                        _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                            pcall(applyFolderTheme, newT)
                        end
                    end
                    applyState()

                    local api = {
                        setOpen = function(openState)
                            isOpen = openState == true
                            applyState()
                        end,
                        setHeaderVisible = function(show)
                            headerVisible = show ~= false
                            if not headerVisible then
                                isOpen = true
                            end
                            applyState()
                        end,
                        setActive = function(active)
                            container.Visible = active ~= false
                            if container.Visible then
                                applyState()
                            else
                                content.Visible = false
                                divider.Visible = false
                                container.Size = UDim2.new(1, 0, 0, 0)
                            end
                        end,
                        refresh = applyState,
                        getHeight = function()
                            local baseH = headerVisible and _sc.folderHdrH or 0
                            return baseH + ((isOpen or not headerVisible) and childrenH or 0)
                        end,
                    }

                    return container, content, addRow, api
                end

                
                
                _sc.makeMiscGamePanel                   = function(accentCol, layoutOrder, pageParent)
                    local childrenH                  = 0
                    local childCount                 = 0

                    local ROW_H                      = 46
                    local PAD_H                      = 6
                    local ROW_GAP                    = 4
                    local PAD_SIDE                   = 8
                    local MAX_VISIBLE_ROWS           = 50
                    local maxScrollH                 = PAD_H + MAX_VISIBLE_ROWS * (ROW_H + ROW_GAP) + PAD_H

                    local container                  = Instance.new("Frame", pageParent or _sc.sonstigePage)
                    container.Size                   = UDim2.new(1, 0, 0, 0)
                    container.BackgroundColor3       = C.bg2 or Color3.fromRGB(3, 14, 6)
                    container.BackgroundTransparency = 0.14
                    container.BorderSizePixel        = 0
                    container.LayoutOrder            = layoutOrder
                    container.ClipsDescendants       = false
                    corner(container, 10)

                    local scroll = Instance.new("ScrollingFrame", container)
                    scroll.Name = "GameScriptScroll"
                    scroll.Size = UDim2.new(1, -16, 0, 0)
                    scroll.Position = UDim2.new(0, 8, 0, 4)
                    scroll.BackgroundTransparency = 1
                    scroll.BorderSizePixel = 0
                    scroll.ClipsDescendants = true
                     scroll.ScrollingDirection = Enum.ScrollingDirection.Y
                     scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = C.accent
                    scroll.ScrollBarImageColor3 = _themePanelColor(accentCol, C.accent)
                    scroll.ScrollBarImageTransparency = 0.42
                    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                    scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
                    scroll.ScrollingEnabled = false
                    scroll.ElasticBehavior = Enum.ElasticBehavior.Never

                    local content = Instance.new("Frame", scroll)
                    content.Size = UDim2.new(1, 0, 0, 0)
                    content.Position = UDim2.new(0, 0, 0, 0)
                    content.BackgroundTransparency = 1
                    content.BorderSizePixel = 0

                    local function applyFolderTheme(newT)
                        local accent = (newT and newT.accent) or (C.accent or _themePanelColor(accentCol, C.accent))
                        container.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or Color3.fromRGB(3, 14, 6)
                        scroll.ScrollBarImageColor3 = _themePanelColor(accentCol, accent)
                    end

                    local function applyState()
                        local ch = childrenH
                        local canvasH = math.max(ch, 1)
                        content.Size = UDim2.new(1, 0, 0, canvasH)
                        scroll.CanvasSize = UDim2.new(0, 0, 0, canvasH)
                        local vh = (ch <= 0) and 0 or math.min(ch, maxScrollH)
                        scroll.Size = UDim2.new(1, -16, 0, vh)
                        scroll.ScrollingEnabled = ch > maxScrollH
                        if ch <= maxScrollH then
                            scroll.CanvasPosition = Vector2.new(0, 0)
                        end
                        container.Size = UDim2.new(1, 0, 0, (vh > 0) and (vh + 8) or 0)
                    end

                    local function addRow(label, badge2, badgeCol, initOn, onToggle)
                        local yPos              = PAD_H + childCount * (ROW_H + ROW_GAP)
                        local row, setFn, getFn = cleanRow(content, yPos, label, badge2,
                            _themePanelColor(badgeCol, C.accent), initOn, onToggle)
                        row.Size                = UDim2.new(1, -PAD_SIDE * 2, 0, ROW_H)
                        row.Position            = UDim2.new(0, PAD_SIDE, 0, yPos)
                        childCount              = childCount + 1
                        childrenH               = PAD_H + childCount * (ROW_H + ROW_GAP) + PAD_H
                        applyState()
                        return row, setFn, getFn
                    end

                    if _panelColorHooks then
                        _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                            pcall(applyFolderTheme, newT)
                        end
                    end
                    applyState()

                    local api = {
                        setOpen = function() end,
                        setHeaderVisible = function() end,
                        setActive = function(active)
                            container.Visible = active ~= false
                            if container.Visible then
                                scroll.Visible = true
                                content.Visible = true
                                applyState()
                            else
                                scroll.Visible = false
                                content.Visible = false
                                container.Size = UDim2.new(1, 0, 0, 0)
                            end
                        end,
                        refresh = applyState,
                        getHeight = function()
                            if childrenH <= 0 then return 0 end
                            return math.min(childrenH, maxScrollH) + 8
                        end,
                    }

                    return container, content, addRow, api
                end
                
                
                
                task.wait(0.05)
                combatPage                        = Instance.new("ScrollingFrame", sSubArea)
                combatPage.BackgroundTransparency = 1; combatPage.BorderSizePixel = 0
                combatPage.Visible                = false
                 combatPage.ScrollBarThickness     = 3; combatPage.ScrollBarImageColor3 = C.accent
                combatPage.ScrollBarImageColor3   = C.accent or Color3.fromRGB(200, 200, 200)
                combatPage.ScrollingDirection     = Enum.ScrollingDirection.Y
                combatPage.CanvasSize             = UDim2.new(0, 0, 0, 0)
                combatPage.AutomaticCanvasSize    = Enum.AutomaticSize.Y
                combatPage.ElasticBehavior        = Enum.ElasticBehavior.Never
                combatPage.ClipsDescendants       = true

                combatLayout                      = Instance.new("UIListLayout", combatPage)
                combatLayout.SortOrder            = _ENUM_SORT_ORDER_LAYOUT or (Enum and Enum.SortOrder and Enum.SortOrder.LayoutOrder) or 0
                combatLayout.FillDirection        = Enum.FillDirection.Vertical
                combatLayout.Padding              = UDim.new(0, 0)
                combatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    local H = combatLayout.AbsoluteContentSize.Y
                    if H > 1 then
                        combatPage.Size = UDim2.new(1, 0, 0, math.min(H, 350))
                        if typeof(_sc.updateActiveCatSize) == "function" then
                            _sc.updateActiveCatSize()
                        end
                    end
                end)

                combatContainer, combatContent, combatAddRow, _combatFolderApi = _sc.makeMiscFolder("Combat Tools", "TL",
                    C.red, 1, combatPage)
                task.defer(function()
                    if _combatFolderApi then
                        _combatFolderApi.setHeaderVisible(false)
                    end
                end)

                

                
                do
                    local aimMod = _TL_loadModule("SCRIPTS-TAB/TL-Aimbot")
                    if aimMod then
                        aimMod.init({ Players = Players, RunService = RunService, UserInputService = UserInputService, Workspace = Workspace, LocalPlayer = LocalPlayer })
                        local cfg = aimMod.getConfig()

                        combatAddRow("Aimbot Master", "Combat", C.red, false, function(on)
                            if on then
                                aimMod.start()
                                sendNotif("Aimbot", "Aimbot ACTIVATED - Hold RMB to aim", 3)
                            else
                                aimMod.stop()
                                sendNotif("Aimbot", "Aimbot DEACTIVATED", 2)
                            end
                        end)

                        combatAddRow("Silent Aim", "Combat", C.red, false, function(on)
                            aimMod.setSilentAim(on)
                            sendNotif("Aimbot", "Silent Aim " .. (on and "ON" or "OFF"), 2)
                        end)

                        combatAddRow("Aimlock", "Combat", C.red, false, function(on)
                            aimMod.setAimlockToggle(on)
                            sendNotif("Aimbot", "Aimlock " .. (on and "ON" or "OFF"), 2)
                        end)

                        combatAddRow("Wall Check", "Combat", C.red, false, function(on)
                            aimMod.setWallCheck(on)
                        end)

                        combatAddRow("Show FOV Circle", "Combat", C.red, false, function(on)
                            aimMod.setShowFOV(on)
                        end)

                        combatAddRow("Show Target Line", "Combat", C.red, false, function(on)
                            aimMod.setShowTargetLine(on)
                        end)

                        combatAddRow("Team Check", "Combat", C.red, false, function(on)
                            aimMod.setTeamCheck(on)
                        end)

                        combatAddRow("Auto Fire", "Combat", C.red, false, function(on)
                            aimMod.setAutoFire(on)
                        end)

                        combatAddRow("Trigger Bot", "Combat", C.red, false, function(on)
                            aimMod.setTriggerBot(on)
                        end)

                        
                        local fovRow = combatAddRow("FOV Size", "Combat", C.red, false, function() end)
                        for _, ch in ipairs(fovRow:GetChildren()) do
                            if not ch:IsA("UICorner") and not ch:IsA("UIStroke") then ch:Destroy() end
                        end
                        local fovLbl = Instance.new("TextLabel", fovRow)
                        fovLbl.Size = UDim2.new(0, 80, 0, 18); fovLbl.Position = UDim2.new(0, 16, 0, 7)
                        fovLbl.BackgroundTransparency = 1; fovLbl.Text = "FOV Size"; fovLbl.Font = Enum.Font.GothamBold
                        fovLbl.TextSize = 12; fovLbl.TextColor3 = C.text or Color3.fromRGB(240, 240, 240); fovLbl.TextXAlignment = Enum.TextXAlignment.Left
                        local fovVal = Instance.new("TextLabel", fovRow)
                        fovVal.Size = UDim2.new(0, 40, 0, 18); fovVal.Position = UDim2.new(1, -48, 0, 7)
                        fovVal.BackgroundTransparency = 1; fovVal.Text = tostring(cfg.FOV); fovVal.Font = Enum.Font.GothamBold
                        fovVal.TextSize = 11; fovVal.TextColor3 = C.sub or Color3.fromRGB(180, 180, 180); fovVal.TextXAlignment = Enum.TextXAlignment.Right
                        local fovTrack = Instance.new("Frame", fovRow)
                        fovTrack.Size = UDim2.new(1, -32, 0, 6); fovTrack.Position = UDim2.new(0, 16, 0, 30)
                        fovTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or Color3.fromRGB(60, 60, 70); fovTrack.BackgroundTransparency = 0.2
                        fovTrack.BorderSizePixel = 0; local _fc1 = Instance.new("UICorner", fovTrack); _fc1.CornerRadius = UDim.new(1, 0)
                        local fovFill = Instance.new("Frame", fovTrack)
                        local fovPct = (cfg.FOV - 30) / 270
                        fovFill.Size = UDim2.new(fovPct, 0, 1, 0); fovFill.BackgroundColor3 = C.red or Color3.fromRGB(220, 60, 60)
                        fovFill.BorderSizePixel = 0; local _fc2 = Instance.new("UICorner", fovFill); _fc2.CornerRadius = UDim.new(1, 0)
                        local fovKnob = Instance.new("Frame", fovFill)
                        fovKnob.Size = UDim2.new(0, 12, 0, 12); fovKnob.Position = UDim2.new(1, -6, 0.5, -6)
                        fovKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); fovKnob.BorderSizePixel = 0
                        local _fc3 = Instance.new("UICorner", fovKnob); _fc3.CornerRadius = UDim.new(1, 0)
                        local fovBtn = Instance.new("TextButton", fovRow)
                        fovBtn.Size = UDim2.new(1, 0, 1, 0); fovBtn.BackgroundTransparency = 1; fovBtn.Text = ""; fovBtn.ZIndex = 6
                        local fovDrag = false
                        local function fovUpdate(x)
                            local p = math.clamp((x - fovTrack.AbsolutePosition.X) / fovTrack.AbsoluteSize.X, 0, 1)
                            fovFill.Size = UDim2.new(p, 0, 1, 0)
                            aimMod.setFOV(30 + math.floor(p * 270))
                            fovVal.Text = tostring(cfg.FOV)
                        end
                        fovBtn.InputBegan:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                                fovDrag = true; fovUpdate(i.Position.X)
                            end
                        end)
                        UserInputService.InputChanged:Connect(function(i)
                            if not fovDrag then return end
                            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                                fovUpdate(i.Position.X)
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fovDrag = false end
                        end)

                        
                        local smRow = combatAddRow("Smoothness", "Combat", C.red, false, function() end)
                        for _, ch in ipairs(smRow:GetChildren()) do
                            if not ch:IsA("UICorner") and not ch:IsA("UIStroke") then ch:Destroy() end
                        end
                        local smLbl = Instance.new("TextLabel", smRow)
                        smLbl.Size = UDim2.new(0, 90, 0, 18); smLbl.Position = UDim2.new(0, 16, 0, 7)
                        smLbl.BackgroundTransparency = 1; smLbl.Text = "Smoothness"; smLbl.Font = Enum.Font.GothamBold
                        smLbl.TextSize = 12; smLbl.TextColor3 = C.text or Color3.fromRGB(240, 240, 240); smLbl.TextXAlignment = Enum.TextXAlignment.Left
                        local smVal = Instance.new("TextLabel", smRow)
                        smVal.Size = UDim2.new(0, 40, 0, 18); smVal.Position = UDim2.new(1, -48, 0, 7)
                        smVal.BackgroundTransparency = 1; smVal.Text = string.format("%.2f", cfg.Smoothness); smVal.Font = Enum.Font.GothamBold
                        smVal.TextSize = 11; smVal.TextColor3 = C.sub or Color3.fromRGB(180, 180, 180); smVal.TextXAlignment = Enum.TextXAlignment.Right
                        local smTrack = Instance.new("Frame", smRow)
                        smTrack.Size = UDim2.new(1, -32, 0, 6); smTrack.Position = UDim2.new(0, 16, 0, 30)
                        smTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or Color3.fromRGB(60, 60, 70); smTrack.BackgroundTransparency = 0.2
                        smTrack.BorderSizePixel = 0; local _sc1 = Instance.new("UICorner", smTrack); _sc1.CornerRadius = UDim.new(1, 0)
                        local smFill = Instance.new("Frame", smTrack)
                        local smPct = (cfg.Smoothness - 0.01) / 0.19
                        smFill.Size = UDim2.new(smPct, 0, 1, 0); smFill.BackgroundColor3 = C.red or Color3.fromRGB(220, 60, 60)
                        smFill.BorderSizePixel = 0; local _sc2 = Instance.new("UICorner", smFill); _sc2.CornerRadius = UDim.new(1, 0)
                        local smKnob = Instance.new("Frame", smFill)
                        smKnob.Size = UDim2.new(0, 12, 0, 12); smKnob.Position = UDim2.new(1, -6, 0.5, -6)
                        smKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); smKnob.BorderSizePixel = 0
                        local _sc3 = Instance.new("UICorner", smKnob); _sc3.CornerRadius = UDim.new(1, 0)
                        local smBtn = Instance.new("TextButton", smRow)
                        smBtn.Size = UDim2.new(1, 0, 1, 0); smBtn.BackgroundTransparency = 1; smBtn.Text = ""; smBtn.ZIndex = 6
                        local smDrag = false
                        local function smUpdate(x)
                            local p = math.clamp((x - smTrack.AbsolutePosition.X) / smTrack.AbsoluteSize.X, 0.01, 1)
                            smFill.Size = UDim2.new(p, 0, 1, 0)
                            aimMod.setSmoothness(0.01 + (p * 0.19))
                            smVal.Text = string.format("%.2f", cfg.Smoothness)
                        end
                        smBtn.InputBegan:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                                smDrag = true; smUpdate(i.Position.X)
                            end
                        end)
                        UserInputService.InputChanged:Connect(function(i)
                            if not smDrag then return end
                            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                                smUpdate(i.Position.X)
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then smDrag = false end
                        end)

                        
                        LocalPlayer.CharacterRemoving:Connect(function()
                            pcall(function() if aimMod.getConfig().FOVCircle and aimMod.getConfig().FOVCircle.Remove then aimMod.getConfig().FOVCircle:Remove() end end)
                        end)
                    end
                end 

                
                _sc.sonstigePage.Size = UDim2.new(1, 0, 0, 174)

                
                miscToolsContainer, miscToolsContent, miscToolsAddRow = _sc.makeMiscFolder("Misc Tools", "⚙", C.accent, 2,
                    _sc.sonstigePage)
                cfRow, cfSetFn = miscToolsAddRow("Cutszene breaker", "Break Cutszene and Walk around", C.accent, false,
                    function(on) setCut(on) end)
                _TL_refs._TL_setCut = setCut

                do
                    local gvMod = _TL_loadModule("SCRIPTS-TAB/GVAutoFish")
                    if not gvMod and type(readfile) == "function" and type(isfile) == "function" then
                        local paths = { "SCRIPTS-TAB/GVAutoFish.lua", "GVAutoFish.lua" }
                        for _, p in ipairs(paths) do
                            if isfile(p) then
                                local okS, src = pcall(readfile, p)
                                if okS and src then
                                    local fn = loadstring(src)
                                    if fn then
                                        local okE, res = pcall(fn)
                                        if okE and res then gvMod = res; break end
                                    end
                                end
                            end
                        end
                    end
                    if gvMod and gvMod.init then
                        gvMod.init({
                            RunService = RunService,
                            Players = Players,
                            LocalPlayer = LocalPlayer,
                            UserInputService = UserInputService,
                            sendNotif = sendNotif,
                            C = C,
                        })
                        local gvRow, gvSetFn = miscToolsAddRow("GV AutoFish", "German Voice 🎣", C.accent2 or C.accent, false,
                            function(on)
                                if on then
                                    gvMod.start()
                                    if sendNotif then sendNotif("GV AutoFish", "Auto-Angeln aktiv 🎣", 3) end
                                else
                                    gvMod.stop()
                                    if sendNotif then sendNotif("GV AutoFish", "Auto-Angeln deaktiviert.", 2) end
                                end
                            end)
                        if gvMod.onToggleChanged then
                            gvMod.onToggleChanged(function(on)
                                if gvSetFn then gvSetFn(on, true) end
                            end)
                        end
                        if gvRow then
                            local hudBtn = Instance.new("TextButton", gvRow)
                            hudBtn.Size = UDim2.new(0, 42, 0, 22)
                            hudBtn.Position = UDim2.new(1, -95, 0.5, -11)
                            hudBtn.BackgroundColor3 = C.bg3 or Color3.fromRGB(35, 35, 42)
                            hudBtn.BackgroundTransparency = 0.3
                            hudBtn.BorderSizePixel = 0
                            hudBtn.Text = "HUD"
                            hudBtn.Font = Enum.Font.GothamBold
                            hudBtn.TextSize = 10
                            hudBtn.TextColor3 = C.accent or Color3.fromRGB(0, 200, 255)
                            hudBtn.ZIndex = 8
                            corner(hudBtn, 6)
                            local hudStroke = stroke(hudBtn, 1, C.accent or Color3.fromRGB(0, 200, 255), 0.5)
                            hudBtn.MouseButton1Click:Connect(function()
                                if gvMod.toggleGui then gvMod.toggleGui() end
                            end)
                        end
                    end
                end

                _sc.miscLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    _sc.updateMiscSize()
                end)
                _sc.subPages = { Troll = trollPage, Movement = movePage, Visual = visualPage, Misc =
                _sc.sonstigePage, Combat = combatPage }
                _sc.baseH = 80 + 62
                _sc.activeCat = nil
                _sc.catBtns = {}
                _sc.switchSCat = function(id)
                    for _, pg in pairs(_sc.subPages) do pg.Visible = false end
                    for _, cb in ipairs(_sc.catBtns) do
                        twP(cb.card, 0.15, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2 })
                        twP(cb.lbl, 0.15, { TextColor3 = C.sub or _C3_SUB })
                        cb.cStr.Color = C.bg3 or _C3_BG3; cb.cStr.Transparency = 0.3
                        cb.selBar.Visible = false
                        if cb.iconRef then
                            pcall(function()
                                if cb.iconRef:IsA("ImageLabel") then
                                else
                                    twP(cb.iconRef, 0.15, { TextColor3 = C.sub or _C3_SUB })
                                end
                            end)
                        end
                    end
                    if _sc.activeCat == id then
                        _sc.activeCat = nil
                        sActiveCat = nil
                        if _sc.panelTw.p then pcall(function() _sc.panelTw.p:Cancel() end) end
                        if _sc.panelTw.sub then pcall(function() _sc.panelTw.sub:Cancel() end) end
                        twP(sSubArea, 0.18, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quart,
                            Enum.EasingDirection.In)
                        twP(_sc.scriptsPanel, 0.18, { Size = UDim2.new(0, PANEL_W, 0, _sc.baseH) }, Enum.EasingStyle.Quart,
                            Enum.EasingDirection.In)
                        task.delay(0.2, function() pcall(function() _sc.scriptsPanel.ClipsDescendants = false end) end)
                        if _sc.scriptsScroll then
                            _sc.scriptsScroll.Size = UDim2.new(1, 0, 0, _sc.baseH - 56)
                            _sc.scriptsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                        end
                        return
                    end
                    _sc.activeCat = id
                    sActiveCat = id
                    local pg = _sc.subPages[id]
                    if pg then
                        pg.Visible = true
                        task.spawn(function()
                            if id == "Misc" and typeof(_sc.updateMiscSize) == "function" then _sc.updateMiscSize() end
                            local pgH = 0
                            for _ = 1, 15 do
                                task.wait()
                                pgH = pg.Size.Y.Offset
                                if pgH > 1 then break end
                                pgH = pg.AbsoluteSize.Y
                                if pgH > 1 then break end
                            end
                            if pgH < 1 then pgH = 188 end
                            _sc.resizeScriptsPanel(pgH, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0.24)
                        end)
                    end
                    for _, cb in ipairs(_sc.catBtns) do
                        if cb.id == id then
                            twP(cb.card, 0.20, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG4 })
                            twP(cb.lbl, 0.20, { TextColor3 = C.text })
                            cb.cStr.Color = cb.col; cb.cStr.Transparency = 0.5
                            cb.selBar.Visible = true
                            if cb.iconRef then
                                pcall(function()
                                    if cb.iconRef:IsA("ImageLabel") then
                                    else
                                        twP(cb.iconRef, 0.20, { TextColor3 = cb.col })
                                    end
                                end)
                            end
                        end
                    end
                end
                 
                    local _S_GAP = 8
                    local _S_H = 80
                    local _SCATS = {
                        { id = "Troll",    img = "rbxassetid://120351884957369", col = C.red },
                        { id = "Movement", img = "rbxassetid://115822754618291", col = C.accent2 },
                        { id = "Visual",   img = "rbxassetid://122084214712991", col = C.accent3 },
                        { id = "Misc",     img = "rbxassetid://117318347375651", col = C.accent },
                        { id = "Combat",   img = "rbxassetid://84261020849153",  col = C.orange, iconSize = 56 },
                    }
                    local _S_W = math.floor((PANEL_W - 32 - _S_GAP * (#_SCATS - 1)) / #_SCATS)
                    for i, cat in ipairs(_SCATS) do
                        local xOff = (i - 1) * (_S_W + _S_GAP)
                        local card = Instance.new("Frame", sGrid)
                        card.Size = UDim2.new(0, _S_W, 0, _S_H)
                        card.Position = UDim2.new(0, xOff, 0, 0)
                        card.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28); card.BackgroundTransparency = 0
                        card.BorderSizePixel = 0; corner(card, 12)
                        local cStr = _makeDummyStroke(card)
                        cStr.Thickness = 1; cStr.Color = C.bg3 or _C3_BG3; cStr.Transparency = 0.3
                        local selBar = Instance.new("Frame", card)
                        selBar.Size = UDim2.new(1, -16, 0, 2); selBar.Position = UDim2.new(0, 8, 0, 0)
                        selBar.BackgroundColor3 = _scriptCatAccent(cat.col); selBar.BackgroundTransparency = 0
                        selBar.BorderSizePixel = 0; selBar.Visible = false; corner(selBar, 99)
                        local _iconRef = nil
                        if cat.img then
                            local iconImg = Instance.new("ImageLabel", card)
                            local _iSz = cat.iconSize or 28
                            iconImg.Size = UDim2.new(0, _iSz, 0, _iSz); iconImg.Position = UDim2.new(0.5, -_iSz / 2, 0,
                                -(_iSz / 2) + 29)
                            iconImg.BackgroundTransparency = 1; iconImg.Image = cat.img
                            iconImg.ImageColor3 = Color3.new(1, 1, 1); iconImg.ScaleType = Enum.ScaleType.Fit
                            _iconRef = iconImg
                        else
                            local icon = Instance.new("TextLabel", card)
                            icon.Size = UDim2.new(1, 0, 0, 32); icon.Position = UDim2.new(0, 0, 0, 8)
                            icon.BackgroundTransparency = 1; icon.Text = cat.icon or ""
                            icon.Font = Enum.Font.GothamBlack; icon.TextSize = 22
                            icon.TextColor3 = C.sub or _C3_SUB; icon.TextXAlignment = Enum.TextXAlignment.Center
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
                            if _sc.activeCat ~= catId then
                                twP(card, 0.1, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG4 })
                            end
                        end)
                        btn.MouseLeave:Connect(function()
                            if _sc.activeCat ~= catId then
                                twP(card, 0.1, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2 })
                            end
                        end)
                        local _sCatBtnLock = false
                        local function sCatActivate()
                            if _sCatBtnLock then return end
                            _sCatBtnLock = true
                            task.delay(0.35, function() _sCatBtnLock = false end)
                            _sc.switchSCat(catId)
                        end
                        btn.MouseButton1Click:Connect(sCatActivate)
                        btn.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Touch then sCatActivate() end
                        end)
                        table.insert(_sc.catBtns, {
                            id = catId,
                            card = card,
                            lbl = lbl,
                            selBar = selBar,
                            cStr = cStr,
                            iconRef = _iconRef,
                            baseCol = cat.col,
                            col = _scriptCatAccent(cat.col),
                        })
                    end
                                        _panelColorHooks[#_panelColorHooks + 1] = function()
                        for _, cb in ipairs(_sc.catBtns) do
                            local tc = _scriptCatAccent(cb.baseCol)
                            cb.col = tc
                            cb.selBar.BackgroundColor3 = tc
                            if _sc.activeCat == cb.id then
                                cb.cStr.Color = tc
                                cb.cStr.Transparency = 0.5
                            end
                        end
                    end
                    pcall(function() _sc.scriptsPanel.Size = UDim2.new(0, PANEL_W, 0, _sc.baseH) end)
            
            _act_following, _act_followTarget, _act_followRSConn = false, nil,
                nil                                                    
            local _act_bangAnimTrack = nil
            local _act_bangOscTime = 0
            local function _act_stopFollow()
                _act_following = false
                if _act_followRSConn then
                    _act_followRSConn:Disconnect(); _act_followRSConn = nil
                end
                _act_followTarget = nil; _act_bangOscTime = 0
                if _act_bangAnimTrack then
                    pcall(function() _act_bangAnimTrack:Stop() end); _act_bangAnimTrack = nil
                end
                local hum = getHumanoid(); if hum then
                    hum.WalkSpeed = 16; if not flyActive then hum.PlatformStand = false end
                end
                pcall(function() setFreeze(false) end)
                pcall(function()
                    if flyActive then return end
                    local myChar = LocalPlayer.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        myRoot.AssemblyLinearVelocity = Vector3.zero
                        myRoot.AssemblyAngularVelocity = Vector3.zero
                        local rayO = myRoot.Position + Vector3.new(0, 2, 0)
                        local rayD = Vector3.new(0, -50, 0)
                        local rayP = RaycastParams.new()
                        rayP.FilterDescendantsInstances = {myChar}
                        rayP.FilterType = Enum.RaycastFilterType.Exclude
                        local rayR = workspace:Raycast(rayO, rayD, rayP)
                        if rayR then
                            myRoot.CFrame = CFrame.new(
                                Vector3.new(myRoot.Position.X, rayR.Position.Y + 3, myRoot.Position.Z)
                            ) * myRoot.CFrame.Rotation
                        end
                    end
                end)
            end
            local function _act_startFollow(targetPlayer)
                _act_stopFollow()
                local targetChar = targetPlayer and targetPlayer.Character
                if not targetChar then
                    sendNotif("Bang V2", "Target has no character!", 2); return false
                end
                _act_following = true; _act_followTarget = targetPlayer; _act_bangOscTime = 0
                pcall(function()
                    local myChar = LocalPlayer.Character
                    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    if hum then
                        _act_bangAnimTrack = _AF_loadAndPlayAnimation(hum, "116967071050039")
                        if _act_bangAnimTrack then
                            _act_bangAnimTrack:Play(); _act_bangAnimTrack:AdjustSpeed(2)
                        end
                    end
                end)
                _act_followRSConn = _RSConnect(function(dt)
                    if not _act_following then return end
                    local myRoot = getRootPart()
                    if not myRoot then
                        _act_following = false
                        task.defer(function() pcall(function() setActionsToggle(false) end) end)
                        return
                    end

                    local target = _act_followTarget
                    if not target or not target.Parent then
                        _act_following = false
                        task.defer(function() pcall(function() setActionsToggle(false) end) end)
                        return
                    end

                    local tc = target.Character
                    local tHRP = tc and tc:FindFirstChild("HumanoidRootPart")

                    if not tHRP or not tHRP.Parent then
                        return
                    end

                    pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tHRP)
                    _act_bangOscTime = _act_bangOscTime + dt * 10.0
                    myRoot.Velocity = Vector3.zero
                    myRoot.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3.5 - (math.sin(_act_bangOscTime) * 3))
                        local h2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if h2 then h2.PlatformStand = true end
                    for _, _6_ in ipairs(LocalPlayer.Character:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                end)
                return true
            end
                        
            
            
_TL_state.actions = {}
            
            _SOH = {
                active = false,
                bodyPos = nil,
                bodyGyro = nil,
                conn = nil,
                target = nil,
                hoverVel = nil,
                animTrack = nil,
                animConn = nil,
                charConn = nil,
                ANIM_ID = "119898270336796",
            }
            _TL_state.ppActive = false
            _TL_state.setFreeze = nil
            do
                _TL_state.actions.stopSitOnHead = function()
                    _SOH.active = false
                    if _SOH.hoverVel then
                        pcall(function() _SOH.hoverVel:Destroy() end); _SOH.hoverVel = nil
                    end
                    if _SOH.bodyPos then
                        pcall(function() _SOH.bodyPos:Destroy() end); _SOH.bodyPos = nil
                    end
                    if _SOH.bodyGyro then
                        pcall(function() _SOH.bodyGyro:Destroy() end); _SOH.bodyGyro = nil
                    end
                    if _SOH.conn then
                        pcall(function() _SOH.conn:Disconnect() end); _SOH.conn = nil
                    end
                    _SOH.target = nil
                    sohStopAnim()
                    local myChar = LocalPlayer.Character
                    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.PlatformStand = false
                        if _TL_state.setFreeze then _TL_state.setFreeze(false) end
                    end
                end
                local function sohStopAnim()
                    if _SOH.animTrack then
                        pcall(function() _SOH.animTrack:Stop(0.1) end); _SOH.animTrack = nil
                    end
                    if _SOH.animConn then
                        pcall(function() _SOH.animConn:Disconnect() end); _SOH.animConn = nil
                    end
                    if _SOH.charConn then
                        pcall(function() _SOH.charConn:Disconnect() end); _SOH.charConn = nil
                    end
                end
                local function sohPlayAnim(char)
                    if not char then return end
                    if _SOH.ANIM_ID == "0" or _SOH.ANIM_ID == "" then return end
                    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                    if hum.RigType == Enum.HumanoidRigType.R6 then return end
                    local track = _AF_getReliableActionTrack(hum, _SOH.ANIM_ID, "SitOnHeadAnim")
                    if not track then return end
                    if setFreeze then setFreeze(true) end
                    _SOH.animTrack = track
                    if _SOH.animConn then _SOH.animConn:Disconnect() end
                    task.spawn(function()
                        task.wait(2)
                        if not _SOH.active or not _SOH.animTrack then return end
                        pcall(function()
                            _SOH.animTrack:AdjustSpeed(0); _SOH.animTrack.TimePosition = 2
                        end)
                        while _tlAlive() and _SOH.active and _SOH.animTrack do
                            pcall(function() _SOH.animTrack.TimePosition = 2 end); task.wait(0.03)
                        end
                    end)
                    _SOH.animConn = track.Stopped:Connect(function()
                        if _SOH.active and _SOH.animTrack then
                            pcall(function()
                                _SOH.animTrack:AdjustSpeed(0); _SOH.animTrack.TimePosition = 2
                            end)
                        end
                    end)
                end
                local function sohStartAnim()
                    sohStopAnim()
                    task.spawn(function() sohPlayAnim(LocalPlayer.Character) end)
                    _SOH.charConn = LocalPlayer.CharacterAdded:Connect(function(char)
                        if _SOH.active then
                            task.wait(0.5); task.spawn(function() sohPlayAnim(char) end)
                        end
                    end)
                end
                stopSitOnHead = function()
                    if _SOH.conn then
                        _SOH.conn:Disconnect(); _SOH.conn = nil
                    end
                    _SOH.active = false; _SOH.target = nil
                    if _SOH.bodyPos then
                        pcall(function() _SOH.bodyPos:Destroy() end); _SOH.bodyPos = nil
                    end
                    if _SOH.bodyGyro then
                        pcall(function() _SOH.bodyGyro:Destroy() end); _SOH.bodyGyro = nil
                    end
                    if not ppActive and setFreeze then setFreeze(false) end
                    sohStopAnim()
                    local hum = getHumanoid(); if hum and not flyActive then
                        hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated,
                                true) end)
                    end
                    pcall(function()
                        local _lpc = LocalPlayer.Character
                        local r = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                        pcall(function() if r then r.Velocity = Vector3.zero end end)
                    end)
                end
                startSitOnHead = function(targetPlayer)
                    stopSitOnHead()
                    local myChar = LocalPlayer.Character
                    local tChar  = targetPlayer and targetPlayer.Character
                    if not myChar or not tChar then
                        sendNotif("Sit on Head", "No character!", 2); return
                    end
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    local tHead  = tChar:FindFirstChild("Head")
                    local tHRP   = tChar:FindFirstChild("HumanoidRootPart")
                    if not myRoot or not tHead then
                        sendNotif("Sit on Head", "Missing parts!", 2); return
                    end
                    local hum = getHumanoid(); if hum then
                        hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated,
                                false) end)
                    end
                    pcall(function()
                        local r = getRootPart(); if r then r:SetNetworkOwner(LocalPlayer) end
                    end)
                    if tHRP then
                        pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tHRP)
                    end
                    local tp = tHead.Position + Vector3.new(0, 1, 0); local cp = tp
                    _SOH.active = true; _SOH.target = targetPlayer
                    sendNotif("Sit on Head", "Sitting on " .. targetPlayer.Name .. " 👑", 3)
                    sohStartAnim(); if setFreeze then setFreeze(true) end
                    _SOH.conn = _RSConnect(function()
                        if not _SOH.active then return end
                        local tc2  = _SOH.target and _SOH.target.Character
                        local head = tc2 and tc2:FindFirstChild("Head"); if not head or not head.Parent then return end
                        local myC = LocalPlayer.Character
                        local myR = myC and myC:FindFirstChild("HumanoidRootPart")
                        if not myR then return end
                        pcall(sethiddenproperty, myR, "PhysicsRepRootPart", head)
                        tp = head.Position + Vector3.new(0, 1, 0)
                        cp = cp:Lerp(tp, 0.98)
                        myR.Velocity = Vector3.zero
                        myR.CFrame = CFrame.new(cp, head.Position)
                        for _, _6_ in ipairs(myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                        local h2              = myC:FindFirstChildOfClass("Humanoid")
                        if h2 then h2.PlatformStand = true end
                        pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(Enum
                                .HumanoidStateType.Physics)
                            end end)
                    end)
                end

            end
            _AF = { 
                kissActive = false,
                backpackActive = false,
                orbitActive = false,
                upsideDownActive = false,
                crossUDActive = false,
                friendActive = false,
                spinningActive = false,
                lickingActive = false,
                suckingActive = false,
                suckItActive = false,
                backshotsActive = false,
                layFuckActive = false,
                facefuckActive = false,
                pussySpreadActive = false,
                doggyActive = false,
                origGodState = false,
                hugActive = false,
                hug2Active = false,
                qa74Active = false,
                carryActive = false,
                shoulderSitActive = false,
                pp2Active = false,
                ghostActive = false,
                bbActive = false,
                standActive = false,
                friendDanceTrack = nil,
                spinAngle = 0,
                udConn = nil,
                udTarget = nil,
            }
            local bbMode_ = nil 
            local function _AF_onStartAction()
                _AF.origGodState = _TL_refs._TL_isGodOn and _TL_refs._TL_isGodOn() or false
                _AF.origInvisState = invisActive
                if _TL_refs._TL_godStart then pcall(_TL_refs._TL_godStart) end
                if invisActive then pcall(function() setInvis(false) end) end
                local hum = getHumanoid()
                if hum then
                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)
                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
                end
            end
            local function _AF_onStopAction()
                if not _AF.origGodState and _TL_refs._TL_godStop then pcall(_TL_refs._TL_godStop) end
                local hum = getHumanoid()
                if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end) end
                if _AF.origInvisState then
                    invisActive = true
                    pcall(function() setInvis(true) end)
                    _AF.origInvisState = nil
                end
            end
            _AF.onStartAction = _AF_onStartAction
            _AF.onStopAction = _AF_onStopAction
            local ACTIONS_DEF = {
                { key = "bang",        label = "Bang V2",      col = Color3.fromRGB(43, 221, 146) },
                { key = "soh",         label = "On Head",      col = _C3_RED },
                { key = "piggyback",   label = "Piggyback",    col = Color3.fromRGB(255, 170, 50) },
                { key = "piggyback2",  label = "Piggyback2",   col = Color3.fromRGB(255, 200, 80) },
                { key = "kiss",        label = "Kiss",         col = Color3.fromRGB(255, 120, 180) },
                { key = "backpack",    label = "Backpack",     col = Color3.fromRGB(120, 180, 255) },
                { key = "orbit",       label = "Orbit TP",     col = Color3.fromRGB(100, 220, 255) },
                { key = "upsidedown",  label = "Upside Down",  col = Color3.fromRGB(200, 100, 255) },
                { key = "crossud",     label = "Cross UD",     col = Color3.fromRGB(180, 80, 255) },
                { key = "friend",      label = "Friend",       col = Color3.fromRGB(255, 200, 80) },
                { key = "spinning",    label = "Spinning",     col = Color3.fromRGB(80, 220, 200) },
                { key = "licking",     label = "Licking",      col = Color3.fromRGB(255, 80, 160) },
                { key = "backshots",   label = "Backshots",    col = _C3_DRED },
                { key = "layfuck",     label = "Lay Fuck",     col = Color3.fromRGB(255, 80, 100) },
                { key = "pussyspread", label = "Pussy Spread", col = Color3.fromRGB(220, 80, 220) },
                { key = "hug",         label = "Hug",          col = Color3.fromRGB(100, 220, 255) },
                { key = "hug2",        label = "Hug 2",        col = Color3.fromRGB(80, 200, 240) },
                { key = "carry",       label = "Carry",        col = Color3.fromRGB(255, 160, 60) },
                { key = "shouldersit", label = "Shouldersit",  col = Color3.fromRGB(60, 200, 140) },
                { key = "sucking",     label = "Sucking 2",    col = Color3.fromRGB(255, 80, 160) },
                { key = "suckit",      label = "Suck It",      col = Color3.fromRGB(255, 100, 180) },
                { key = "ghost",       label = "Ghost",        col = Color3.fromRGB(160, 160, 255) },
                { key = "shit",        label = "Shit on Head",  col = Color3.fromRGB(139, 90, 43) },
                { key = "spidergrip",  label = "Spider Grip",   col = Color3.fromRGB(80, 180, 80) },
                { key = "fingering",   label = "Fingering",     col = Color3.fromRGB(200, 100, 150) },
                { key = "ghosthover",  label = "Ghost Hover",   col = Color3.fromRGB(180, 180, 220) },
            }
            

    return p, c
end

return ScriptsTab