--!nocheck
-- Standalone Module: ActionsTab
-- Extracted from TLMenu.lua

local ActionsTab = {}

function ActionsTab.Init(ctx)
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

                local p, c = makePanel("Actions", C.accent)
                local function buildPlayerDropdown(playerPill, playerPillLbl, playerPillAvatar, playerPillBtn, getTarget,
                                                   setTarget)
                    local dropdownOpen = false
                    local DD_ITEM_H = 34; local DD_MAX = 5
                    local ddFrame = Instance.new("Frame", ScreenGui)
                    ddFrame.Name = "FollowDropdown"
                    ddFrame.BackgroundColor3 = C.bg2; ddFrame.BackgroundTransparency = 0.06
                    ddFrame.BorderSizePixel = 0; ddFrame.ZIndex = 11000; ddFrame.Visible = false
                    pcall(function()
                        local pcard = ddFrame.Parent
                        if pcard then pcard.ZIndex = 1 end
                    end)

                    ddFrame.ClipsDescendants = true
                    corner(ddFrame, 14); gradStroke(ddFrame, 1.5, 0.22)
                    
                    local ddBg = Instance.new("UIGradient", ddFrame)
                    local function _ddBgUpdate()
                        local pb = C.panelBg or Color3.fromRGB(10, 10, 10)
                        local pb2 = pb:Lerp(Color3.new(0, 0, 0), 0.25)
                        ddBg.Color = ColorSequence.new {
                            ColorSequenceKeypoint.new(0, pb),
                            ColorSequenceKeypoint.new(1, pb2),
                        }
                    end
                    _ddBgUpdate(); ddBg.Rotation = 135
                                        _panelColorHooks[#_panelColorHooks + 1] = function()
                        pcall(_ddBgUpdate)
                        pcall(function() ddFrame.BackgroundColor3 = C.bg2 end)
                    end
                    local ddScroll = Instance.new("ScrollingFrame", ddFrame)
                    ddScroll.Size = UDim2.new(1, 0, 1, 0); ddScroll.BackgroundTransparency = 1
                    ddScroll.BorderSizePixel = 0; ddScroll.ScrollBarThickness = 3; ddScroll.ScrollBarImageColor3 = C.accent
                    ddScroll.ScrollBarImageColor3 = C.gradL
                    ddScroll.ScrollingDirection = Enum.ScrollingDirection.Y
                    ddScroll.CanvasSize = UDim2.new(0, 0, 0, 0); ddScroll.ZIndex = 11001
                    local ddList = Instance.new("UIListLayout", ddScroll)
                    ddList.SortOrder = _ENUM_SORT_ORDER_LAYOUT or (Enum and Enum.SortOrder and Enum.SortOrder.LayoutOrder) or 0; ddList.Padding = UDim.new(0, 2)
                    local function positionDropdown(targetH)
                        local abs = playerPill.AbsolutePosition; local absSize = playerPill.AbsoluteSize
                        local screenH = ScreenGui.AbsoluteSize.Y
                        local screenW = ScreenGui.AbsoluteSize.X
                        local spaceBelow = screenH - (abs.Y + absSize.Y + 4)
                        local spaceAbove = abs.Y - 4
                        local h = targetH or ddFrame.Size.Y.Offset
                        local posX = math.clamp(abs.X, 0, math.max(0, screenW - absSize.X))
                        local posY
                        if spaceBelow >= h + 4 or spaceBelow >= spaceAbove then
                            posY = abs.Y + absSize.Y + 4
                        else
                            posY = abs.Y - h - 4
                        end
                        posY = math.clamp(posY, 4, math.max(4, screenH - h - 4))
                        ddFrame.Position = UDim2.new(0, posX, 0, posY)
                        ddFrame.Size = UDim2.new(0, absSize.X, 0, h)
                    end
                    local ddSlot = { tween = nil }
                    local function closeDropdown()
                        if not dropdownOpen then return end; dropdownOpen = false
                        local t = twC(ddSlot, ddFrame, 0.18, { Size = UDim2.new(0, ddFrame.Size.X.Offset, 0, 0) },
                            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                        t.Completed:Connect(function()
                            if not dropdownOpen then
                                ddFrame.Visible = false
                                pcall(function()
                                    local pcard = ddFrame.Parent
                                    if pcard then pcard.ZIndex = 1 end
                                end)
                            end
                        end)
                    end
                    local function buildDropdown()
                        for _, ch in ipairs(ddScroll:GetChildren()) do
                            if ch:IsA("GuiObject") then ch:Destroy() end
                        end
                        local plrs = {}
                        for _, pl in ipairs(Players:GetPlayers()) do
                            if pl ~= LocalPlayer then table.insert(plrs, pl) end
                        end
                        if #plrs == 0 then
                            local noLbl = Instance.new("TextLabel", ddScroll)
                            noLbl.Size = UDim2.new(1, 0, 0, DD_ITEM_H); noLbl.BackgroundTransparency = 1
                            noLbl.Text = T.actions_no_players; noLbl.Font = Enum.Font.GothamBold; noLbl.TextSize = 13
                            noLbl.TextColor3 = C.text; noLbl.ZIndex = 11002
                        end
                        local selectedFollowTarget = getTarget()
                        for _, pl in ipairs(plrs) do
                            local row = Instance.new("Frame", ddScroll)
                            row.Size = UDim2.new(1, -8, 0, DD_ITEM_H); row.BackgroundColor3 = C.bg3
                            row.BackgroundTransparency = 0.85; row.BorderSizePixel = 0; row.ZIndex = 11002
                            corner(row, 10)
                            local avatarClip = Instance.new("Frame", row)
                            avatarClip.Size = UDim2.new(0, 24, 0, 24); avatarClip.Position = UDim2.new(0, 5, 0.5, -12)
                            avatarClip.BackgroundColor3 = C.bg3; avatarClip.BackgroundTransparency = 0.4
                            avatarClip.BorderSizePixel = 0; avatarClip.ZIndex = 11003; avatarClip.ClipsDescendants = true
                            corner(avatarClip, 99)
                            local avatarImg = Instance.new("ImageLabel", avatarClip)
                            avatarImg.Size = UDim2.new(1, 0, 1, 0); avatarImg.BackgroundTransparency = 1
                            avatarImg.Image = "rbxassetid://142509179"; avatarImg.ImageColor3 = C.sub
                            avatarImg.ScaleType = Enum.ScaleType.Crop; avatarImg.ZIndex = 11004
                            task.spawn(function()
                                local ok, url = pcall(function()
                                    return Players:GetUserThumbnailAsync(pl.UserId, Enum.ThumbnailType.HeadShot,
                                        Enum.ThumbnailSize.Size48x48)
                                end)
                                if ok and url and avatarImg.Parent then
                                    avatarImg.Image = url; avatarImg.ImageColor3 = _C3_WHITE
                                end
                            end)
                            local nameLbl = Instance.new("TextLabel", row)
                            nameLbl.Size = UDim2.new(1, -44, 1, 0); nameLbl.Position = UDim2.new(0, 34, 0, 0)
                            nameLbl.BackgroundTransparency = 1
                            nameLbl.Text = pl.DisplayName; nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13
                            nameLbl.TextColor3 = (selectedFollowTarget == pl) and C.accent or C.text
                            nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 11003
                            if selectedFollowTarget == pl then
                                local dot = Instance.new("Frame", row)
                                dot.Size = UDim2.new(0, 5, 0, 5); dot.Position = UDim2.new(1, -12, 0.5, -2)
                                dot.BackgroundColor3 = C.accent; dot.BorderSizePixel = 0; corner(dot, 99); dot.ZIndex = 11003
                            end
                            local rowBtn = Instance.new("TextButton", row)
                            rowBtn.Size = UDim2.new(1, 0, 1, 0); rowBtn.BackgroundTransparency = 1
                            rowBtn.Text = ""; rowBtn.ZIndex = 11005
                            rowBtn.MouseEnter:Connect(function()
                                _sc._playHoverSound()
                                twP(row, 0.1, { BackgroundTransparency = 0.55 })
                                twP(nameLbl, 0.1, { TextColor3 = C.accent })
                            end)
                            rowBtn.MouseLeave:Connect(function()
                                twP(row, 0.1, { BackgroundTransparency = 0.85 })
                                if getTarget() ~= pl then tw(nameLbl, 0.1, { TextColor3 = C.text }):Play() end
                            end)
                            rowBtn.MouseButton1Click:Connect(function()
                                setTarget(pl)
                                playerPillLbl.Text = pl.DisplayName; playerPillLbl.TextColor3 = C.accent
                                if playerPillAvatar then
                                    playerPillAvatar.Image = "rbxassetid://142509179"
                                    playerPillAvatar.ImageColor3 = C.sub
                                    task.spawn(function()
                                        local ok2, url2 = pcall(function()
                                            return Players:GetUserThumbnailAsync(pl.UserId, Enum.ThumbnailType.HeadShot,
                                                Enum.ThumbnailSize.Size48x48)
                                        end)
                                        if ok2 and url2 and playerPillAvatar and playerPillAvatar.Parent then
                                            playerPillAvatar.Image = url2
                                            playerPillAvatar.ImageColor3 = _C3_WHITE
                                        end
                                    end)
                                end
                                twP(playerPill, 0.08, { BackgroundTransparency = 0.0 })
                                task.delay(0.1, function() tw(playerPill, 0.15, { BackgroundTransparency = 0.08 }):Play() end)
                                closeDropdown()
                            end)
                            rowBtn.InputBegan:Connect(function(inp)
                                if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                    setTarget(pl)
                                    playerPillLbl.Text = pl.DisplayName; playerPillLbl.TextColor3 = C.accent
                                    if playerPillAvatar then
                                        playerPillAvatar.Image = "rbxassetid://142509179"
                                        playerPillAvatar.ImageColor3 = C.sub
                                        task.spawn(function()
                                            local ok2, url2 = pcall(function()
                                                return Players:GetUserThumbnailAsync(pl.UserId,
                                                    Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                                            end)
                                            if ok2 and url2 and playerPillAvatar and playerPillAvatar.Parent then
                                                playerPillAvatar.Image = url2
                                                playerPillAvatar.ImageColor3 = _C3_WHITE
                                            end
                                        end)
                                    end
                                    twP(playerPill, 0.08, { BackgroundTransparency = 0.0 })
                                    task.delay(0.1,
                                        function() tw(playerPill, 0.15, { BackgroundTransparency = 0.08 }):Play() end)
                                    closeDropdown()
                                end
                            end)
                        end
                        local count = math.max(1, #plrs)
                        ddScroll.CanvasSize = UDim2.new(0, 0, 0, count * (DD_ITEM_H + 2) + 6)
                        return math.min(count, DD_MAX) * (DD_ITEM_H + 2) + 6
                    end
                    local function openDropdown()
                        if dropdownOpen then
                            closeDropdown(); return
                        end
                        dropdownOpen = true
                        local targetH = buildDropdown()
                        positionDropdown(targetH)
                        ddFrame.Size = UDim2.new(0, playerPill.AbsoluteSize.X, 0, 0); ddFrame.Visible = true
                        pcall(function()
                            local pcard = ddFrame.Parent
                            if pcard then pcard.ZIndex = 15 end
                        end)

                        twP(ddFrame, 0.22, { Size = UDim2.new(0, playerPill.AbsoluteSize.X, 0, targetH) },
                            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    end
                    playerPillBtn.MouseButton1Click:Connect(openDropdown)
                    playerPillBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then openDropdown() end
                    end)
                    UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            task.defer(function()
                                if not dropdownOpen then return end
                                local mp = UserInputService:GetMouseLocation()
                                local abs = ddFrame.AbsolutePosition; local absS = ddFrame.AbsoluteSize
                                local inside = mp.X >= abs.X and mp.X <= abs.X + absS.X and mp.Y >= abs.Y and
                                mp.Y <= abs.Y + absS.Y
                                local onPill = false; pcall(function()
                                    local pa = playerPill.AbsolutePosition; local ps = playerPill.AbsoluteSize
                                    onPill = mp.X >= pa.X and mp.X <= pa.X + ps.X and mp.Y >= pa.Y and mp.Y <= pa.Y +
                                    ps.Y
                                end)
                                if not inside and not onPill then closeDropdown() end
                            end)
                        end
                    end)
                    return { open = openDropdown, close = closeDropdown }
                end
                p.Size            = UDim2.new(0, PANEL_W, 0, 340)
                local stopFollow  = _act_stopFollow
                local startFollow = _act_startFollow
                local playerPill, playerPillAvatar, playerPillLbl, playerPillBtn
                local actionPill, actionPillLbl, actionPillBtn, actionRow
                local statusDot, statusTxt
                do
                    local _isImgInfo = _TL_isImgTheme(_TL_activeThemeId)
                    local infoCard = Instance.new("Frame", c)
                    infoCard.Size = UDim2.new(1, 0, 0, 52); infoCard.Position = UDim2.new(0, 0, 0, 0)
                    infoCard.BackgroundColor3 = _isImgInfo and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                    infoCard.BackgroundTransparency = _isImgInfo and 0.94 or 0
                    infoCard.BorderSizePixel = 0; corner(infoCard, 12)
                    local infoStr = _makeDummyStroke(infoCard)
                    infoStr.Thickness = _isImgInfo and 1.5 or 1
                    infoStr.Color = _isImgInfo and Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                    infoStr.Transparency = 0.3
                    local infoDot = Instance.new("Frame", infoCard)
                    infoDot.Size = UDim2.new(0, 3, 0, 32); infoDot.Visible = false; infoDot.Position = UDim2.new(0, 0,
                        0.5, -16)
                    infoDot.BackgroundColor3 = C.accent; infoDot.BackgroundTransparency = 0.4
                    infoDot.BorderSizePixel = 0; corner(infoDot, 99)
                    local infoIcon = Instance.new("TextLabel", infoCard)
                    infoIcon.Size = UDim2.new(0, 36, 1, 0); infoIcon.Position = UDim2.new(0, 10, 0, 0)
                    infoIcon.BackgroundTransparency = 1; infoIcon.Text = "ℹ"
                    infoIcon.Font = Enum.Font.GothamBlack; infoIcon.TextSize = 21
                    infoIcon.TextXAlignment = Enum.TextXAlignment.Center
                    local infoLbl = Instance.new("TextLabel", infoCard)
                    infoLbl.Size = UDim2.new(1, -52, 0, 20); infoLbl.Position = UDim2.new(0, 46, 0, 7)
                    infoLbl.BackgroundTransparency = 1; infoLbl.Text = T.actions_info_lbl
                    infoLbl.Font = Enum.Font.GothamBold; infoLbl.TextSize = 13
                    infoLbl.TextColor3 = C.text; infoLbl.TextXAlignment = Enum.TextXAlignment.Left
                    local infoSub = Instance.new("TextLabel", infoCard)
                    infoSub.Size = UDim2.new(1, -52, 0, 14); infoSub.Position = UDim2.new(0, 46, 0, 29)
                    infoSub.BackgroundTransparency = 1; infoSub.Text = T.actions_info_sub
                    infoSub.Font = Enum.Font.GothamMedium; infoSub.TextSize = 11
                    infoSub.TextColor3 = C.sub; infoSub.TextXAlignment = Enum.TextXAlignment.Left
                    local pickRow = Instance.new("Frame", c)
                    pickRow.Size = UDim2.new(1, 0, 0, 46); pickRow.Position = UDim2.new(0, 0, 0, 62)
                    
                    local _pickIsImgTheme = _TL_isImgTheme(_TL_activeThemeId)
                    pickRow.BackgroundColor3 = _pickIsImgTheme and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                    pickRow.BackgroundTransparency = _pickIsImgTheme and 0.94 or 0; pickRow.BorderSizePixel = 0; corner(
                    pickRow, 14)
                    local pickStr = _makeDummyStroke(pickRow)
                    pickStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and 1.5 or 1
                    pickStr.Color = _TL_isImgTheme(_TL_activeThemeId) and Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                    pickStr.Transparency = 0.3
                                        _panelColorHooks[#_panelColorHooks + 1] = function()
                        pcall(function()
                            local _isImg = _TL_isImgTheme(_TL_activeThemeId)
                            pickRow.BackgroundColor3 = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                            pickRow.BackgroundTransparency = _isImg and 0.94 or 0
                            pickStr.Thickness = _isImg and 1.5 or 1
                            pickStr.Color = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                            pickStr.Transparency = 0.3
                        end)
                    end
                    local pickDot = Instance.new("Frame", pickRow)
                    pickDot.Size = UDim2.new(0, 3, 0, 26); pickDot.Visible = false; pickDot.Position = UDim2.new(0, 0,
                        0.5, -13)
                    pickDot.BackgroundColor3 = C.accent; pickDot.BackgroundTransparency = 0.4
                    pickDot.BorderSizePixel = 0; corner(pickDot, 99)
                    local pickLbl = Instance.new("TextLabel", pickRow)
                    pickLbl.Size = UDim2.new(0, 60, 1, 0); pickLbl.Position = UDim2.new(0, 16, 0, 0)
                    pickLbl.BackgroundTransparency = 1; pickLbl.Text = T.actions_pick_target
                    pickLbl.Font = Enum.Font.GothamBold; pickLbl.TextSize = 13
                    pickLbl.TextColor3 = C.text; pickLbl.TextXAlignment = Enum.TextXAlignment.Left
                    playerPill = Instance.new("Frame", pickRow)
                    playerPill.Size = UDim2.new(0, 138, 0, 28); playerPill.Position = UDim2.new(0, 72, 0.5, -14)
                    playerPill.BackgroundColor3 = C.bg3; playerPill.BackgroundTransparency = 0.08
                    playerPill.BorderSizePixel = 0
                    corner(playerPill, 11)
                    local playerPillStr = _makeDummyStroke(playerPill)
                    playerPillStr.Thickness = 1; playerPillStr.Color = C.bg3 or _C3_BG3; playerPillStr.Transparency = 0.3
                    local playerPillAvatarClip = Instance.new("Frame", playerPill)
                    playerPillAvatarClip.Size = UDim2.new(0, 20, 0, 20); playerPillAvatarClip.Position = UDim2.new(0, 5,
                        0.5, -10)
                    playerPillAvatarClip.BackgroundColor3 = C.bg3; playerPillAvatarClip.BackgroundTransparency = 0.4
                    playerPillAvatarClip.BorderSizePixel = 0; playerPillAvatarClip.ZIndex = 3; playerPillAvatarClip.ClipsDescendants = true
                    corner(playerPillAvatarClip, 99)
                    playerPillAvatar = Instance.new("ImageLabel", playerPillAvatarClip)
                    playerPillAvatar.Size = UDim2.new(1, 0, 1, 0); playerPillAvatar.BackgroundTransparency = 1
                    playerPillAvatar.Image = "rbxassetid://142509179"; playerPillAvatar.ImageColor3 = C.sub
                    playerPillAvatar.ScaleType = Enum.ScaleType.Crop; playerPillAvatar.ZIndex = 4
                    playerPillLbl = Instance.new("TextLabel", playerPill)
                    playerPillLbl.Size = UDim2.new(1, -44, 1, 0); playerPillLbl.Position = UDim2.new(0, 30, 0, 0)
                    playerPillLbl.BackgroundTransparency = 1; playerPillLbl.Text = T.actions_player_pill
                    playerPillLbl.Font = Enum.Font.GothamBold; playerPillLbl.TextSize = 13
                    playerPillLbl.TextColor3 = C.text; playerPillLbl.TextXAlignment = Enum.TextXAlignment.Left
                    playerPillLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    playerPillBtn = Instance.new("TextButton", playerPill)
                    playerPillBtn.Size = UDim2.new(1, 0, 1, 0); playerPillBtn.BackgroundTransparency = 1
                    playerPillBtn.Text = ""; playerPillBtn.ZIndex = 6
                    actionPill = Instance.new("Frame", pickRow)
                    actionPill.Size = UDim2.new(0, 138, 0, 28); actionPill.Position = UDim2.new(1, -153, 0.5, -14)
                    actionPill.BackgroundColor3 = C.bg3; actionPill.BackgroundTransparency = 0.08
                    actionPill.BorderSizePixel = 0
                    corner(actionPill, 11)
                    local actionPillStr = _makeDummyStroke(actionPill)
                    actionPillStr.Thickness = 1; actionPillStr.Color = C.bg3 or _C3_BG3; actionPillStr.Transparency = 0.3
                    actionPillLbl = Instance.new("TextLabel", actionPill)
                    actionPillLbl.Size = UDim2.new(1, -22, 1, 0); actionPillLbl.Position = UDim2.new(0, 8, 0, 0)
                    actionPillLbl.BackgroundTransparency = 1; actionPillLbl.Text = T.actions_action_pill
                    actionPillLbl.Font = Enum.Font.GothamBold; actionPillLbl.TextSize = 13
                    actionPillLbl.TextColor3 = C.text; actionPillLbl.TextXAlignment = Enum.TextXAlignment.Left
                    actionPillLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    actionPillBtn = Instance.new("TextButton", actionPill)
                    actionPillBtn.Size = UDim2.new(1, 0, 1, 0); actionPillBtn.BackgroundTransparency = 1
                    actionPillBtn.Text = ""; actionPillBtn.ZIndex = 6
                    local _isImgAct = _TL_isImgTheme(_TL_activeThemeId)
                    actionRow = Instance.new("Frame", c)
                    actionRow.Size = UDim2.new(1, 0, 0, 46); actionRow.Position = UDim2.new(0, 0, 0, 118)
                    actionRow.BackgroundColor3 = _isImgAct and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                    actionRow.BackgroundTransparency = _isImgAct and 1 or 0
                    actionRow.BorderSizePixel = 0
                    corner(actionRow, 12)
                    local actionRowStr = _makeDummyStroke(actionRow)
                    actionRowStr.Thickness = _isImgAct and 1.5 or 1
                    actionRowStr.Color = _isImgAct and Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                    actionRowStr.Transparency = 0.3
                    local actionRowDot = Instance.new("Frame", actionRow)
                    actionRowDot.Size = UDim2.new(0, 3, 0, 26); actionRowDot.Visible = false; actionRowDot.Position =
                    UDim2.new(0, 0, 0.5, -13)
                    actionRowDot.BackgroundColor3 = C.accent; actionRowDot.BackgroundTransparency = 0.4
                    actionRowDot.BorderSizePixel = 0; corner(actionRowDot, 99)
                    local actionRowLbl = Instance.new("TextLabel", actionRow)
                    actionRowLbl.Size = UDim2.new(0, 140, 1, 0); actionRowLbl.Position = UDim2.new(0, 16, 0, 0)
                    actionRowLbl.BackgroundTransparency = 1; actionRowLbl.Text = T.actions_row_lbl
                    actionRowLbl.Font = Enum.Font.GothamBold; actionRowLbl.TextSize = 13
                    actionRowLbl.TextColor3 = C.text; actionRowLbl.TextXAlignment = Enum.TextXAlignment.Left
                    local _isImgStat = _TL_isImgTheme(_TL_activeThemeId)
                    local statusCard = Instance.new("Frame", c)
                    statusCard.Size = UDim2.new(1, 0, 0, 36); statusCard.Position = UDim2.new(0, 0, 0, 174)
                    statusCard.BackgroundColor3 = _isImgStat and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                    statusCard.BackgroundTransparency = _isImgStat and 0.94 or 0.18
                    statusCard.BorderSizePixel = 0
                    corner(statusCard, 12)
                    local statusStr = _makeDummyStroke(statusCard)
                    statusStr.Thickness = _isImgStat and 1.5 or 1
                    statusStr.Color = _isImgStat and Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                    statusStr.Transparency = 0.3
                    statusDot = Instance.new("Frame", statusCard)
                    statusDot.Size = UDim2.new(0, 8, 0, 8); statusDot.Position = UDim2.new(0, 14, 0.5, -4)
                    statusDot.BackgroundColor3 = C.red; statusDot.BorderSizePixel = 0; corner(statusDot, 99)
                    statusTxt = Instance.new("TextLabel", statusCard)
                    statusTxt.Size = UDim2.new(1, -40, 1, 0); statusTxt.Position = UDim2.new(0, 30, 0, 0)
                    statusTxt.BackgroundTransparency = 1; statusTxt.Text = T.actions_status_idle
                    statusTxt.Font = Enum.Font.GothamBold; statusTxt.TextSize = 13
                    statusTxt.TextColor3 = C.text; statusTxt.TextXAlignment = Enum.TextXAlignment.Left
                    
                                        _panelColorHooks[#_panelColorHooks + 1] = function()
                        pcall(function()
                            local _isImg = _TL_isImgTheme(_TL_activeThemeId)
                            if infoCard and infoCard.Parent then
                                infoCard.BackgroundColor3 = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                                infoCard.BackgroundTransparency = _isImg and 0.94 or 0
                                infoStr.Color = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                                infoStr.Thickness = _isImg and 1.5 or 1
                            end
                            if actionRow and actionRow.Parent then
                                actionRow.BackgroundColor3 = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                                actionRow.BackgroundTransparency = _isImg and 1 or 0
                                actionRowStr.Color = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                                actionRowStr.Thickness = _isImg and 1.5 or 1
                            end
                            if statusCard and statusCard.Parent then
                                statusCard.BackgroundColor3 = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                                statusCard.BackgroundTransparency = _isImg and 0.94 or 0.18
                                statusStr.Color = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                                statusStr.Thickness = _isImg and 1.5 or 1
                                statusTxt.TextColor3 = C.text
                            end
                            if pickRow and pickRow.Parent then
                                pickRow.BackgroundColor3 = _isImg and Color3.fromRGB(255, 255, 255) or (C.bg2 or _C3_BG2)
                                pickRow.BackgroundTransparency = _isImg and 0.94 or 0
                            end
                            if pickDot and pickDot.Parent then pickDot.BackgroundColor3 = C.accent end
                            if actionRowDot and actionRowDot.Parent then actionRowDot.BackgroundColor3 = C.accent end
                            if actionRowLbl and actionRowLbl.Parent then actionRowLbl.TextColor3 = C.text end
                        end)
                    end
                end
                local selectedFollowTarget = nil
                local selectedAction       = nil
                local ACTIONS              = ACTIONS_DEF
                do
                    stopUpsideDown = function()
                        if _AF.udConn then
                            _AF.udConn:Disconnect(); _AF.udConn = nil
                        end
                        _AF.upsideDownActive = false; _AF.udTarget = nil
                        safeStand()
                    end
                    startUpsideDown = function(targetPlayer)
                        stopUpsideDown()
                        local myChar     = LocalPlayer.Character
                        local targetChar = targetPlayer and targetPlayer.Character
                        if not myChar or not targetChar then
                            sendNotif("Upside Down", "No character!", 2); return false
                        end
                        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                        local tHRP0 = targetChar:FindFirstChild("HumanoidRootPart")
                        local hum   = myChar:FindFirstChildOfClass("Humanoid")
                        if not myHRP or not tHRP0 or not hum then
                            sendNotif("Upside Down", "Missing parts!", 2); return false
                        end
                        hum.PlatformStand = true; hum.WalkSpeed = 0
                        pcall(function() myHRP:SetNetworkOwner(LocalPlayer) end)
                        pcall(sethiddenproperty, myHRP, "PhysicsRepRootPart", tHRP0)
                        local _udTargetPos   = tHRP0.Position + Vector3.new(0, 3.5, 0)
                        local _udCurrentPos  = _udTargetPos
                        _AF.upsideDownActive = true; _AF.udTarget = targetPlayer
                        sendNotif("Upside Down", "Hanging over " .. targetPlayer.Name .. " 🦇", 3)
                        _AF.udConn = _RSConnect(function()
                            if not _AF.upsideDownActive then return end
                            local tc   = _AF.udTarget and _AF.udTarget.Character
                            local tHRP = tc and tc:FindFirstChild("HumanoidRootPart")
                            local _lpc = LocalPlayer.Character
                            local myR  = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                            if not tHRP or not myR then
                                _AF.upsideDownActive = false
                                task.defer(function() pcall(function() setActionsToggle(false) end) end); return
                            end
                            pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP)
                            _udTargetPos = tHRP.Position + Vector3.new(0, 3.5, 0)
                            local _udA = 1 - (1 - 0.98) ^ (1 / 60 * 60); _udCurrentPos = _udCurrentPos:Lerp(_udTargetPos, _udA)
                            myR.Velocity = Vector3.zero
                            myR.CFrame = CFrame.new(_udCurrentPos) * tHRP.CFrame * CFrame.Angles(math.rad(180), 0, 0)
                            for _, _6_ in ipairs(_lpc:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                            local h2 = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                            if h2 then h2.PlatformStand = true end
                        end)
                        return true
                    end
                end
                do
                    stopCrossUD = function()
                        if _AF.crossUDConn then
                            _AF.crossUDConn:Disconnect(); _AF.crossUDConn = nil
                        end
                        _AF.crossUDActive = false; _AF.crossUDTarget = nil
                        if _AF.crossUDBP then
                            pcall(function() _AF.crossUDBP:Destroy() end); _AF.crossUDBP = nil
                        end
                        if _AF.crossUDBG then
                            pcall(function() _AF.crossUDBG:Destroy() end); _AF.crossUDBG = nil
                        end
                        local char = LocalPlayer.Character
                        if char and _AF.crossUDOrigC0 then
                            for _, m in ipairs(char:GetDescendants()) do
                                if m:IsA("Motor6D") and _AF.crossUDOrigC0[m] then
                                    pcall(function() m.C0 = _AF.crossUDOrigC0[m] end)
                                end
                            end
                        end
                        _AF.crossUDOrigC0 = nil
                        safeStand()
                    end
                    startCrossUD = function(targetPlayer)
                        stopCrossUD()
                        local myChar     = LocalPlayer.Character
                        local targetChar = targetPlayer and targetPlayer.Character
                        if not myChar or not targetChar then
                            sendNotif("Cross UD", "No character!", 2); return false
                        end
                        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                        local tHRP0 = targetChar:FindFirstChild("HumanoidRootPart")
                        local tHead = targetChar:FindFirstChild("Head")
                        local hum   = myChar:FindFirstChildOfClass("Humanoid")
                        if not myHRP or not tHRP0 or not hum then
                            sendNotif("Cross UD", "Missing parts!", 2); return false
                        end
                        hum.PlatformStand = true
                        pcall(function() myHRP:SetNetworkOwner(LocalPlayer) end)
                        pcall(sethiddenproperty, myHRP, "PhysicsRepRootPart", tHRP0)
                        _AF.crossUDOrigC0 = {}
                        for _, m in ipairs(myChar:GetDescendants()) do
                            if m:IsA("Motor6D") then
                                _AF.crossUDOrigC0[m] = m.C0
                            end
                        end
                        local function applyTPose(char2)
                            if not char2 then return end
                            local tors = char2:FindFirstChild("UpperTorso") or char2:FindFirstChild("Torso")
                            if not tors then return end
                            local rArm = char2:FindFirstChild("Right Arm")
                            local lArm = char2:FindFirstChild("Left Arm")
                            if rArm and lArm then
                                local rJ = tors:FindFirstChild("Right Shoulder")
                                local lJ = tors:FindFirstChild("Left Shoulder")
                                if rJ then pcall(function() rJ.C0 = CFrame.new(1, 0.5, 0) *
                                        CFrame.Angles(0, math.rad(90), 0) end) end
                                if lJ then pcall(function() lJ.C0 = CFrame.new(-1, 0.5, 0) *
                                        CFrame.Angles(0, math.rad(-90), 0) end) end
                            end
                            local rUArm = char2:FindFirstChild("RightUpperArm")
                            local lUArm = char2:FindFirstChild("LeftUpperArm")
                            if rUArm then
                                local rJ = rUArm:FindFirstChildOfClass("Motor6D")
                                if rJ then pcall(function() rJ.C0 = CFrame.new(0, -0.5, 0) *
                                        CFrame.Angles(0, 0, math.rad(-90)) end) end
                            end
                            if lUArm then
                                local lJ = lUArm:FindFirstChildOfClass("Motor6D")
                                if lJ then pcall(function() lJ.C0 = CFrame.new(0, -0.5, 0) *
                                        CFrame.Angles(0, 0, math.rad(90)) end) end
                            end
                        end
                        task.spawn(function() applyTPose(myChar) end)
                        local headY = tHead and tHead.Size.Y or 0.6
                        local HOVER_Y = 3.5 + headY
                        local _curPos = tHRP0.Position + Vector3.new(0, HOVER_Y, 0)
                        _AF.crossUDActive = true; _AF.crossUDTarget = targetPlayer
                        sendNotif("Cross UD", "Crossing over " .. targetPlayer.Name .. " ✝", 3)
                        _AF.crossUDConn = _RSConnect(function()
                            if not _AF.crossUDActive then return end
                            local tc   = _AF.crossUDTarget and _AF.crossUDTarget.Character
                            local tHRP = tc and tc:FindFirstChild("HumanoidRootPart")
                            local _lpc = LocalPlayer.Character
                            local myR  = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                            if not tHRP or not myR then
                                _AF.crossUDActive = false
                                task.defer(function() pcall(function() setActionsToggle(false) end) end); return
                            end
                            pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP)
                            local tHead2           = tc:FindFirstChild("Head")
                            local hY2              = tHead2 and tHead2.Size.Y or 0.6
                            local targetPos        = tHRP.Position + Vector3.new(0, 3.5 + hY2, 0)
                            local alpha            = 1 - (1 - 0.98) ^ (1 / 60 * 60)
                            _curPos                = _curPos:Lerp(targetPos, alpha)
                            myR.Velocity = Vector3.zero
                            myR.CFrame = CFrame.new(_curPos) * tHRP.CFrame * CFrame.Angles(math.rad(180), 0, 0)
                            for _, _6_ in ipairs(_lpc:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                            local myHum            = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                            if myHum then myHum.PlatformStand = true end
                            task.spawn(function() applyTPose(_lpc) end)
                        end)
                        return true
                    end
                end
                do
                    local friendConn     = nil
                    local friendTarget   = nil
                    stopFriend           = function()
                        if friendConn then
                            friendConn:Disconnect(); friendConn = nil
                        end
                        _AF.friendActive = false; friendTarget = nil
                        if _AF.friendDanceTrack then
                            pcall(function() _AF.friendDanceTrack:Stop() end); _AF.friendDanceTrack = nil
                        end
                        safeStand()
                    end
                    startFriend          = function(targetPlayer)
                        stopFriend()
                        local myChar     = LocalPlayer.Character
                        local targetChar = targetPlayer and targetPlayer.Character
                        if not myChar or not targetChar then
                            sendNotif("Friend", "No character!", 2); return false
                        end
                        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                        local tHRP0 = targetChar:FindFirstChild("HumanoidRootPart")
                        local hum   = myChar:FindFirstChildOfClass("Humanoid")
                        if not myHRP or not tHRP0 or not hum then
                            sendNotif("Friend", "Missing parts!", 2); return false
                        end
                        hum.PlatformStand = true; hum.WalkSpeed = 0
                        pcall(function() myHRP:SetNetworkOwner(LocalPlayer) end)
                        pcall(sethiddenproperty, myHRP, "PhysicsRepRootPart", tHRP0)
                        pcall(function()
                        end)
                        myHRP.CFrame = tHRP0.CFrame * CFrame.new(3, 0, 0)
                        pcall(function()
                            _AF.friendDanceTrack = _AF_loadAndPlayAnimation(hum, "182435933")
                            if _AF.friendDanceTrack then _AF.friendDanceTrack:Play() end
                        end)
                        _AF.friendActive = true; friendTarget = targetPlayer
                        sendNotif("Friend", "Befriending " .. targetPlayer.Name .. " 🤝", 3)
                        friendConn = _RSConnect(function()
                            if not _AF.friendActive then return end
                            local tc   = friendTarget and friendTarget.Character
                            local tHRP = tc and tc:FindFirstChild("HumanoidRootPart")
                            local _lpc = LocalPlayer.Character
                            local myR  = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                            if not tHRP or not myR then
                                _AF.friendActive = false
                                task.defer(function() pcall(function() setActionsToggle(false) end) end); return
                            end
                            pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP)
                            myR.Velocity = Vector3.zero
                            myR.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0)
                            for _, _6_ in ipairs(_lpc:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                            local h2 = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                            if h2 then h2.PlatformStand = true end
                        end)
                        return true
                    end
                end
                do
                    local spinConn     = nil
                    local spinTarget   = nil
                    stopSpinning       = function()
                        if spinConn then
                            spinConn:Disconnect(); spinConn = nil
                        end
                        _AF.spinningActive = false; spinTarget = nil; _AF.spinAngle = 0
                        safeStand()
                    end
                    startSpinning      = function(targetPlayer)
                        stopSpinning()
                        local myChar     = LocalPlayer.Character
                        local targetChar = targetPlayer and targetPlayer.Character
                        if not myChar or not targetChar then
                            sendNotif("Spinning", "No character!", 2); return false
                        end
                        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
                        local tHRP0 = targetChar:FindFirstChild("HumanoidRootPart")
                        local hum   = myChar:FindFirstChildOfClass("Humanoid")
                        if not myHRP or not tHRP0 or not hum then
                            sendNotif("Spinning", "Missing parts!", 2); return false
                        end
                        hum.PlatformStand = true; hum.WalkSpeed = 0
                        pcall(function() myHRP:SetNetworkOwner(LocalPlayer) end)
                        pcall(sethiddenproperty, myHRP, "PhysicsRepRootPart", tHRP0)
                        pcall(function()
                        end)
                        _AF.spinAngle = 0
                        myHRP.CFrame = CFrame.new(
                            tHRP0.Position + Vector3.new(math.cos(0) * 7, 0, math.sin(0) * 7), tHRP0.Position
                        )
                        _AF.spinningActive = true; spinTarget = targetPlayer
                        sendNotif("Spinning", "Orbiting " .. targetPlayer.Name .. " 🔄", 3)
                        spinConn = _RSConnect(function()
                            if not _AF.spinningActive then return end
                            local tc   = spinTarget and spinTarget.Character
                            local tHRP = tc and tc:FindFirstChild("HumanoidRootPart")
                            local _lpc = LocalPlayer.Character
                            local myR  = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                            if not tHRP or not myR then
                                _AF.spinningActive = false
                                task.defer(function() pcall(function() setActionsToggle(false) end) end); return
                            end
                            pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP)
                            _AF.spinAngle = _AF.spinAngle + 0.05
                            myR.Velocity = Vector3.zero
                            myR.CFrame = CFrame.new(
                                tHRP.Position +
                                Vector3.new(math.cos(_AF.spinAngle) * 7, 0, math.sin(_AF.spinAngle) * 7),
                                tHRP.Position
                                )
                            for _, _6_ in ipairs(_lpc:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                            local h2 = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                            if h2 then h2.PlatformStand = true end
                        end)
                        return true
                    end
                end
                local function stopCurrentAction()
                    pcall(function()
                        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.Anchored = false end
                    end)
                    pcall(stopCurrentEmote)
                    pcall(stopAnimEmotes)
                    if _act_following then
                        stopFollow(); _act_following = false
                    end
                    if _SOH.active then
                        stopSitOnHead(); _SOH.active = false
                    end
                    if ppActive then
                        stopPiggyback(); ppActive = false
                    end
                    if _AF.pp2Active then
                        stopPiggyback2(); _AF.pp2Active = false
                    end
                    if _AF.kissActive then
                        stopKiss(); _AF.kissActive = false
                    end
                    if _AF.backpackActive then
                        stopBackpack(); _AF.backpackActive = false
                    end
                    if _AF.orbitActive then
                        stopOrbit(); _AF.orbitActive = false
                    end
                    if _AF.upsideDownActive then
                        stopUpsideDown(); _AF.upsideDownActive = false
                    end
                    if _AF.crossUDActive then
                        stopCrossUD(); _AF.crossUDActive = false
                    end
                    if _AF.friendActive then
                        stopFriend(); _AF.friendActive = false
                    end
                    if _AF.spinningActive then
                        stopSpinning(); _AF.spinningActive = false
                    end
                    if _AF.lickingActive then
                        stopLicking(); _AF.lickingActive = false
                    end
                    if _AF.suckingActive then
                        stopSucking(); _AF.suckingActive = false
                    end
                    if _AF.suckItActive then
                        stopSuckIt(); _AF.suckItActive = false
                    end
                    if _AF.backshotsActive then
                        stopBackshots(); _AF.backshotsActive = false
                    end
                    if _AF.doggyActive then
                        stopDoggy(); _AF.doggyActive = false
                    end
                    if _AF.layFuckActive then
                        stopLayFuck(); _AF.layFuckActive = false
                    end
                    if _AF.pussySpreadActive then
                        stopPussySpread(); _AF.pussySpreadActive = false
                    end
                    if _AF.hugActive then
                        stopHug(); _AF.hugActive = false
                    end
                    if _AF.hug2Active then
                        stopHug2(); _AF.hug2Active = false
                    end
                    if _AF.carryActive then
                        stopCarry(); _AF.carryActive = false
                    end
                    if _AF.shoulderSitActive then
                        stopShoulderSit(); _AF.shoulderSitActive = false
                    end
                    if _AF.qa74Active then
                        stopQA74(); _AF.qa74Active = false
                    end
                    if _AF.ghostActive then
                        stopGhost(); _AF.ghostActive = false
                    end
                    if _AF.bbActive then
                        stopBB(); _AF.bbActive = false
                    end
                    pcall(function() if not noclipActive then setNoclip(false) end end)
                    pcall(safeStand)
                end
                local actDdOpen = false
                local ACT_IH = 34; local ACT_MX = 6
                local actDdFrame = Instance.new("Frame", ScreenGui)
                actDdFrame.Name = "ActionsDropdown"
                
                actDdFrame.BackgroundColor3 = C.panelBg or Color3.fromRGB(10, 10, 10); actDdFrame.BackgroundTransparency = 0.06
                actDdFrame.BorderSizePixel = 0; actDdFrame.ZIndex = 50; actDdFrame.Visible = false
                actDdFrame.ClipsDescendants = true
                corner(actDdFrame, 14); gradStroke(actDdFrame, 1.5, 0.22)
                local actDdBg = Instance.new("UIGradient", actDdFrame)
                local function _actDdBgUpdate()
                    local pb = C.panelBg or Color3.fromRGB(10, 10, 10)
                    local pb2 = pb:Lerp(Color3.new(0, 0, 0), 0.25)
                    actDdBg.Color = ColorSequence.new {
                        ColorSequenceKeypoint.new(0, pb),
                        ColorSequenceKeypoint.new(0.5, pb:Lerp(pb2, 0.5)),
                        ColorSequenceKeypoint.new(1, pb2),
                    }
                end
                _actDdBgUpdate(); actDdBg.Rotation = 135
                                _panelColorHooks[#_panelColorHooks + 1] = function()
                    pcall(_actDdBgUpdate)
                    pcall(function() actDdFrame.BackgroundColor3 = C.panelBg or Color3.fromRGB(10, 10, 10) end)
                end
                local actDdScroll = Instance.new("ScrollingFrame", actDdFrame)
                actDdScroll.Size = UDim2.new(1, 0, 1, 0); actDdScroll.BackgroundTransparency = 1
                 actDdScroll.BorderSizePixel = 0; actDdScroll.ScrollBarThickness = 3; actDdScroll.ScrollBarImageColor3 = C.accent
                actDdScroll.ScrollBarImageColor3 = C.gradL
                actDdScroll.ScrollingDirection = Enum.ScrollingDirection.Y
                actDdScroll.CanvasSize = UDim2.new(0, 0, 0, 0); actDdScroll.ZIndex = 51
                local actDdList = Instance.new("UIListLayout", actDdScroll)
                actDdList.SortOrder = _ENUM_SORT_ORDER_LAYOUT or (Enum and Enum.SortOrder and Enum.SortOrder.LayoutOrder) or 0; actDdList.Padding = UDim.new(0, 2)
                local function posActDd()
                    local abs = actionPill.AbsolutePosition; local absS = actionPill.AbsoluteSize
                    actDdFrame.Position = UDim2.new(0, abs.X, 0, abs.Y + absS.Y + 4)
                    actDdFrame.Size = UDim2.new(0, absS.X, 0, actDdFrame.Size.Y.Offset)
                end
                local actDdSlot = { tween = nil }
                local function closeActDd()
                    if not actDdOpen then return end; actDdOpen = false
                    local t = twC(actDdSlot, actDdFrame, 0.18, { Size = UDim2.new(0, actDdFrame.Size.X.Offset, 0, 0) },
                        Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                    t.Completed:Connect(function() if not actDdOpen then actDdFrame.Visible = false end end)
                end
                local function buildActDd()
                    for _, ch in ipairs(actDdScroll:GetChildren()) do
                        if ch:IsA("GuiObject") then ch:Destroy() end
                    end
                    for _, act in ipairs(ACTIONS) do
                        local row = Instance.new("Frame", actDdScroll)
                        row.Size = UDim2.new(1, -8, 0, ACT_IH); row.BackgroundColor3 = C.bg3
                        row.BackgroundTransparency = 0.85; row.BorderSizePixel = 0; row.ZIndex = 52
                        corner(row, 10)
                        local pad = Instance.new("UIPadding", row); pad.PaddingLeft = UDim.new(0, 11)
                        local nameLbl = Instance.new("TextLabel", row)
                        nameLbl.Size = UDim2.new(1, -10, 1, 0); nameLbl.BackgroundTransparency = 1
                        nameLbl.Text = act.label; nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13
                        nameLbl.TextColor3 = (selectedAction == act.key) and act.col or C.text
                        nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 53
                        if selectedAction == act.key then
                            local dot = Instance.new("Frame", row)
                            dot.Size = UDim2.new(0, 5, 0, 5); dot.Position = UDim2.new(1, -12, 0.5, -2)
                            dot.BackgroundColor3 = act.col; dot.BorderSizePixel = 0
                            corner(dot, 99); dot.ZIndex = 53
                        end
                        local rBtn = Instance.new("TextButton", row)
                        rBtn.Size = UDim2.new(1, 0, 1, 0); rBtn.BackgroundTransparency = 1
                        rBtn.Text = ""; rBtn.ZIndex = 54
                        rBtn.MouseEnter:Connect(function()
                            _sc._playHoverSound()
                            tw(row, 0.1, { BackgroundTransparency = 0.55 }):Play(); tw(nameLbl, 0.1, { TextColor3 = act
                            .col }):Play()
                        end)
                        rBtn.MouseLeave:Connect(function()
                            twP(row, 0.1, { BackgroundTransparency = 0.85 })
                            if selectedAction ~= act.key then tw(nameLbl, 0.1, { TextColor3 = C.text }):Play() end
                        end)
                        rBtn.MouseButton1Click:Connect(function()
                            selectedAction = act.key
                            actionPillLbl.Text = act.label; actionPillLbl.TextColor3 = act.col
                            twP(actionPill, 0.08, { BackgroundTransparency = 0.0 })
                            task.delay(0.1, function() tw(actionPill, 0.15, { BackgroundTransparency = 0.08 }):Play() end)
                            closeActDd()
                        end)
                        rBtn.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                                selectedAction = act.key
                                actionPillLbl.Text = act.label; actionPillLbl.TextColor3 = act.col
                                twP(actionPill, 0.08, { BackgroundTransparency = 0.0 })
                                task.delay(0.1, function() tw(actionPill, 0.15, { BackgroundTransparency = 0.08 }):Play() end)
                                closeActDd()
                            end
                        end)
                    end
                    local cnt = #ACTIONS
                    actDdScroll.CanvasSize = UDim2.new(0, 0, 0, cnt * (ACT_IH + 2) + 6)
                    return math.min(cnt, ACT_MX) * (ACT_IH + 2) + 6
                end
                local function openActDd()
                    if actDdOpen then
                        closeActDd(); return
                    end; actDdOpen = true; posActDd()
                    local th = buildActDd(); actDdFrame.Size = UDim2.new(0, actionPill.AbsoluteSize.X, 0, 0); actDdFrame.Visible = true
                    twC(actDdSlot, actDdFrame, 0.22, { Size = UDim2.new(0, actionPill.AbsoluteSize.X, 0, th) },
                        Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
                actionPillBtn.MouseButton1Click:Connect(openActDd)
                actionPillBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch then openActDd() end
                end)
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        task.defer(function()
                            if actDdOpen then
                                local mp = UserInputService:GetMouseLocation()
                                local ab = actDdFrame.AbsolutePosition; local abS = actDdFrame.AbsoluteSize
                                local ins = mp.X >= ab.X and mp.X <= ab.X + abS.X and mp.Y >= ab.Y and mp.Y <= ab.Y +
                                abS.Y
                                local onP = false; pcall(function()
                                    local pa = actionPill.AbsolutePosition; local ps = actionPill.AbsoluteSize
                                    onP = mp.X >= pa.X and mp.X <= pa.X + ps.X and mp.Y >= pa.Y and mp.Y <= pa.Y + ps.Y
                                end)
                                if not ins and not onP then closeActDd() end
                            end
                        end)
                    end
                end)
                local ddAPI                  = buildPlayerDropdown(
                    playerPill, playerPillLbl, playerPillAvatar, playerPillBtn,
                    function() return selectedFollowTarget end,
                    function(pl) selectedFollowTarget = pl end
                )
                local closeDropdown          = ddAPI.close
                local openDropdown           = ddAPI.open
                local setActionsToggle
                local _, _setActionsToggle, _ = makeToggle(actionRow, PANEL_W - 66, 11, false, function(on)
                    if on then
                        if not selectedFollowTarget then
                            sendNotif("Actions", T.actions_select_player, 2)
                            task.defer(function() setActionsToggle(false) end); return
                        end
                        if not selectedAction then
                            sendNotif("Actions", T.actions_select_action, 2)
                            task.defer(function() setActionsToggle(false) end); return
                        end
                        stopCurrentAction()
                        local ok = false
                        if selectedAction == "bang" then
                            ok = startFollow(selectedFollowTarget)
                        elseif selectedAction == "soh" then
                            startSitOnHead(selectedFollowTarget); ok = true
                        elseif selectedAction == "piggyback" then
                            startPiggyback(selectedFollowTarget); ok = true
                        elseif selectedAction == "piggyback2" then
                            startPiggyback2(selectedFollowTarget); ok = true
                        elseif selectedAction == "kiss" then
                            startKiss(selectedFollowTarget); ok = true
                        elseif selectedAction == "backpack" then
                            startBackpack(selectedFollowTarget); ok = true
                        elseif selectedAction == "orbit" then
                            startOrbit(selectedFollowTarget); ok = true
                        elseif selectedAction == "upsidedown" then
                            ok = startUpsideDown(selectedFollowTarget)
                        elseif selectedAction == "crossud" then
                            ok = startCrossUD(selectedFollowTarget)
                        elseif selectedAction == "friend" then
                            ok = startFriend(selectedFollowTarget)
                        elseif selectedAction == "spinning" then
                            ok = startSpinning(selectedFollowTarget)
                        elseif selectedAction == "licking" then
                            startLicking(selectedFollowTarget); ok = true
                        elseif selectedAction == "backshots" then
                            startBackshots(selectedFollowTarget); ok = true
                        elseif selectedAction == "layfuck" then
                            startLayFuck(selectedFollowTarget); ok = true
                        elseif selectedAction == "pussyspread" then
                            startPussySpread(selectedFollowTarget); ok = true
                        elseif selectedAction == "hug" then
                            startHug(selectedFollowTarget); ok = true
                        elseif selectedAction == "hug2" then
                            startHug2(selectedFollowTarget); ok = true
                        elseif selectedAction == "carry" then
                            startCarry(selectedFollowTarget); ok = true
                        elseif selectedAction == "shouldersit" then
                            startShoulderSit(selectedFollowTarget); ok = true
                        elseif selectedAction == "sucking" then
                            startSucking(selectedFollowTarget); ok = true
                        elseif selectedAction == "suckit" then
                            startSuckIt(selectedFollowTarget); ok = true
                        elseif selectedAction == "ghost" then
                            startGhost(selectedFollowTarget); ok = true
                        end
                        if ok then
                            statusDot.BackgroundColor3 = C.accent
                            local n = selectedFollowTarget.Name
                            statusTxt.Text = selectedAction == "bang" and (T.actions_following .. n)
                                or selectedAction == "soh" and ("On Head: " .. n)
                                or selectedAction == "kiss" and ("Kiss: " .. n)
                                or selectedAction == "backpack" and ("Backpack: " .. n)
                                or selectedAction == "orbit" and ("Orbit: " .. n)
                                or selectedAction == "upsidedown" and ("Upside Down: " .. n)
                                or selectedAction == "crossud" and ("Cross UD: " .. n)
                                or selectedAction == "friend" and ("Friend: " .. n)
                                or selectedAction == "spinning" and ("Spinning: " .. n)
                                or selectedAction == "licking" and ("Licking: " .. n)
                                or selectedAction == "backshots" and ("Backshots: " .. n)
                                or selectedAction == "layfuck" and ("Lay Fuck: " .. n)
                                or selectedAction == "pussyspread" and ("Pussy Spread: " .. n)
                                or selectedAction == "hug" and ("Hug: " .. n)
                                or selectedAction == "hug2" and ("Hug 2: " .. n)
                                or selectedAction == "carry" and ("Carry: " .. n)
                                or selectedAction == "shouldersit" and ("Shouldersit: " .. n)
                                or selectedAction == "sucking" and ("Sucking: " .. n)
                                or selectedAction == "suckit" and ("Suck It: " .. n)
                                or selectedAction == "ghost" and ("Ghost: " .. n)
                                or ("Piggyback: " .. n)
                            statusTxt.TextColor3 = C.accent
                        else
                            task.defer(function() setActionsToggle(false) end)
                        end
                    else
                        local wasRunning = (statusTxt.Text ~= T.actions_status_idle)
                        stopCurrentAction()
                        setFreeze(false)
                        statusDot.BackgroundColor3 = C.red
                        statusTxt.Text = T.actions_status_idle
                        statusTxt.TextColor3 = C.text
                        if wasRunning then
                            sendNotif("Actions", T.actions_stopped, 1)
                        end
                    end
                end)
                setActionsToggle = _setActionsToggle
                setFollowToggle              = setActionsToggle
                _G.TLActionsStop             = function()
                    setActionsToggle(false)
                end

                local function execute1XAction(targetPlayer, animId, notifName, emoji, zOffset, speed)
                    local myChar = LocalPlayer.Character
                    local targetChar = targetPlayer and targetPlayer.Character
                    if not myChar or not targetChar then return end
                    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    local tgtTorso = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
                    local hum = myChar:FindFirstChildOfClass("Humanoid")
                    if not myRoot or not tgtTorso or not hum then return end

                    if _G.TLActionsStop then pcall(_G.TLActionsStop) end

                    myRoot.CFrame = tgtTorso.CFrame * CFrame.new(0, 0, zOffset or -2.5) * CFrame.Angles(0, math.pi, 0)

                    task.wait()
                    local track = _AF_getReliableActionTrack(hum, animId, "1XAnim_" .. notifName)
                    if track then
                        track.Looped = false
                        track:Play()
                        if speed then track:AdjustSpeed(speed) end
                        sendNotif("1X Action", emoji .. " " .. notifName .. " on " .. targetPlayer.Name, 2)

                        task.spawn(function()
                            local t = 0
                            while track.Length == 0 and t < 2 do
                                task.wait(0.1); t = t + 0.1
                            end
                            local waitTime = track.Length > 0 and track.Length or 3
                            if speed then waitTime = waitTime / speed end

                            
                            local t2 = 0
                            while not track.IsPlaying and t2 < 1.5 do
                                task.wait(0.1); t2 = t2 + 0.1
                            end

                            
                            local t3 = 0
                            while track.IsPlaying and t3 < 10 do
                                task.wait(0.1); t3 = t3 + 0.1
                            end

                            pcall(function() myRoot.Anchored = false end)
                            if _G.TLQA_ResetUI then pcall(_G.TLQA_ResetUI) end
                        end)
                    else
                        pcall(function() myRoot.Anchored = false end)
                        if _G.TLQA_ResetUI then pcall(_G.TLQA_ResetUI) end
                    end
                end
                _G.TLActions = {
                    stopAll = function()
                        setActionsToggle(false)
                    end,
                    start   = function(key, target)
                        
                        if not target or not target.Character then
                            return false
                        end
                        local _tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                        if not _tRoot then return false end
                        pcall(function() setNoclip(true) end)
                        local _actionOk = false
                        local _ok, _err = pcall(function()
                        if key == "bang" then
                            startFollow(target); _actionOk = true
                        elseif key == "soh" then
                            startSitOnHead(target); _actionOk = true
                        elseif key == "piggyback" then
                            startPiggyback(target); _actionOk = true
                        elseif key == "piggyback2" then
                            startPiggyback2(target); _actionOk = true
                        elseif key == "kiss" then
                            startKiss(target); _actionOk = true
                        elseif key == "backpack" then
                            startBackpack(target); _actionOk = true
                        elseif key == "orbit" then
                            startOrbit(target); _actionOk = true
                        elseif key == "upsidedown" then
                            _actionOk = startUpsideDown(target)
                        elseif key == "crossud" then
                            _actionOk = startCrossUD(target)
                        elseif key == "friend" then
                            _actionOk = startFriend(target)
                        elseif key == "spinning" then
                            _actionOk = startSpinning(target)
                        elseif key == "licking" then
                            startLicking(target); _actionOk = true
                        elseif key == "sucking" then
                            startSucking(target); _actionOk = true
                        elseif key == "suck_it" then
                            startSuckIt(target); _actionOk = true
                        elseif key == "backshots" then
                            startBackshots(target); _actionOk = true
                        elseif key == "doggy" then
                            startDoggy(target); _actionOk = true
                        elseif key == "layfuck" then
                            startLayFuck(target); _actionOk = true
                        elseif key == "pussyspread" then
                            startPussySpread(target); _actionOk = true
                        elseif key == "hug" then
                            startHug(target); _actionOk = true
                        elseif key == "hug2" then
                            startHug2(target); _actionOk = true
                        elseif key == "facefuck" then
                            startFacefuck(target); _actionOk = true
                        elseif key == "qa74" then
                            startQA74(target); _actionOk = true
                        elseif key == "ghost" then
                            startGhost(target); _actionOk = true
                        elseif key == "carry" then
                            startCarry(target); _actionOk = true
                        elseif key == "carryshoulder" then
                            startShoulderSit(target, "101003999980390", "Carry on shoulder"); _actionOk = true
                        elseif key == "shouldersit" then
                            startShoulderSit(target); _actionOk = true
                        elseif key == "stand" then
                            startStand(target); _actionOk = true
                        elseif key == "headstand" then
                            startStand(target, "71483261700852", "Head Stand", CFrame.new(0.2, 4, 0.2)); _actionOk = true
                        elseif key == "headbutt" then
                            task.spawn(function() execute1XAction(target, "81011129131522", "Headbutt", "💥", -1.3, 1.5) end); _actionOk = true
                        elseif key == "jumpscare_vr" then
                            task.spawn(function() execute1XAction(target, "102559848050770", "Jumpscare VR", "👻", -2.0) end); _actionOk = true
                        elseif key == "1x_kiss" then
                            task.spawn(function() execute1XAction(target, "83995690642462", "Kiss", "💋", -1.5) end); _actionOk = true
                        elseif key == "1x_slap" then
                            task.spawn(function() execute1XAction(target, "118273721275238", "Slap", "👋", -2.5) end); _actionOk = true
                        elseif key == "1x_hug" then
                            task.spawn(function() execute1XAction(target, "90892690280238", "Hug", "🫂", -1.5) end); _actionOk = true
                        end
                        end) 
                        if not _ok then warn("[TLActions] Error:", _err) end
                        return _actionOk
                    end,
                }
                p.Size = UDim2.new(0, PANEL_W, 0, 226)
                LocalPlayer.CharacterAdded:Connect(function()
                    if _act_following or _SOH.active or ppActive or _AF.orbitActive
                        or _AF.kissActive or _AF.lickingActive or _AF.suckingActive or _AF.backshotsActive
                        or _AF.doggyActive or _AF.backpackActive or _AF.upsideDownActive or _AF.friendActive
                        or _AF.spinningActive or _AF.pussySpreadActive or _AF.hugActive or _AF.qa74Active
                        or _AF.facefuckActive or _AF.ghostActive or _AF.bbActive then
                        stopCurrentAction()
                        task.defer(function() pcall(function() setActionsToggle(false) end) end)
                        statusDot.BackgroundColor3 = C.red
                        statusTxt.Text = "Inactive (Respawn)"
                        statusTxt.TextColor3 = C.text
                    end
                end)
                local freezeEnabled = false
                setFreeze           = function(on)
                    freezeEnabled = on
                    pcall(function()
                        if _genv.TLAnimFreeze then _genv.TLAnimFreeze(on) end
                    end)
                end
                _SOH.active         = false
                do
                    local function _TLact_Piggyback()
                        do
                            local ppConn      = nil
                            ppActive          = false
                            local ppTarget    = nil
                            local ppAnimTrack = nil
                            local ppAnimConn  = nil
                            local ppCharConn  = nil
                            local function ppStopAnim()
                                if ppAnimConn then
                                    ppAnimConn:Disconnect(); ppAnimConn = nil
                                end
                                if ppCharConn then
                                    ppCharConn:Disconnect(); ppCharConn = nil
                                end
                                if ppAnimTrack then
                                    pcall(function()
                                        ppAnimTrack:AdjustSpeed(1); ppAnimTrack:Stop()
                                    end)
                                    ppAnimTrack = nil
                                end
                            end
                            local function ppPlayAnim(char)
                                if not char then return end
                                if PIGGYBACK_ANIM_ID == "0" or PIGGYBACK_ANIM_ID == "" then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                if hum.RigType == Enum.HumanoidRigType.R6 then return end
                                local track = _AF_getReliableActionTrack(hum, PIGGYBACK_ANIM_ID, "PiggybackAnim")
                                if not track then return end
                                setFreeze(true)
                                local _lpc = LocalPlayer.Character
                                local mHum = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                                if mHum then mHum.PlatformStand = true end
                                ppAnimTrack = track
                                if ppAnimConn then ppAnimConn:Disconnect() end
                                ppAnimConn = track.Stopped:Connect(function()
                                    if ppActive then
                                        task.wait(0.05)
                                        if ppActive then pcall(function() ppPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function ppStartAnim()
                                ppStopAnim()
                                task.spawn(function() ppPlayAnim(LocalPlayer.Character) end)
                                ppCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if ppActive then
                                        task.wait(0.5); task.spawn(function() ppPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopPiggyback = function()
                                if ppConn then
                                    ppConn:Disconnect(); ppConn = nil
                                end
                                ppActive = false; ppTarget = nil
                                if not _SOH.active then setFreeze(false) end
                                ppStopAnim()
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startPiggyback = function(targetPlayer)
                                stopPiggyback()
                                local myChar = LocalPlayer.Character; local targetChar = targetPlayer and
                                targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Piggyback", "No character!", 2); return
                                end
                                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif("Piggyback", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local _ppTP = tgtTorso.Position + tgtTorso.CFrame.LookVector * -1.1 +
                                Vector3.new(0, 0.2, 0); local _ppCP = _ppTP
                                ppActive = true; ppTarget = targetPlayer
                                sendNotif("Piggyback", "Clinging to " .. targetPlayer.Name .. " 🐵", 3)
                                ppStartAnim()
                                ppConn = _RSConnect(function()
                                    if not ppActive then return end
                                    local tc = ppTarget and ppTarget.Character
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart"); if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tgtRoot)
                                    _ppTP              = torso.Position + torso.CFrame.LookVector * -1.1 +
                                    Vector3.new(0, 0.2, 0)
                                    local _ppA         = 1 - (1 - 0.98) ^ (1 / 60 * 60); _ppCP = _ppCP:Lerp(_ppTP, _ppA)
                                    myR.Velocity = Vector3.zero
                                    myR.CFrame = CFrame.new(_ppCP, myR.Position + torso.CFrame.LookVector)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2           = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Piggyback()
                end
                do
                    local function _TLact_Piggyback2()
                        do
                            local pp2Conn      = nil
                            _AF.pp2Active      = false
                            local pp2Target    = nil
                            local pp2AnimTrack = nil
                            local pp2AnimConn  = nil
                            local pp2CharConn  = nil
                            local function pp2StopAnim()
                                if pp2AnimConn then
                                    pp2AnimConn:Disconnect(); pp2AnimConn = nil
                                end
                                if pp2CharConn then
                                    pp2CharConn:Disconnect(); pp2CharConn = nil
                                end
                                if pp2AnimTrack then
                                    pcall(function()
                                        pp2AnimTrack:AdjustSpeed(1); pp2AnimTrack:Stop()
                                    end)
                                    pp2AnimTrack = nil
                                end
                            end
                            local function pp2PlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                if hum.RigType == Enum.HumanoidRigType.R6 then return end
                                local track = _AF_getReliableActionTrack(hum, PIGGYBACK2_ANIM_ID, "Piggyback2Anim")
                                if not track then return end
                                setFreeze(true)
                                local _lpc = LocalPlayer.Character
                                local mHum = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                                if mHum then mHum.PlatformStand = true end
                                pp2AnimTrack = track
                                if pp2AnimConn then pp2AnimConn:Disconnect() end
                                pp2AnimConn = track.Stopped:Connect(function()
                                    if _AF.pp2Active then
                                        task.wait(0.05)
                                        if _AF.pp2Active then pcall(function() pp2PlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function pp2StartAnim()
                                pp2StopAnim()
                                task.spawn(function() pp2PlayAnim(LocalPlayer.Character) end)
                                pp2CharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.pp2Active then
                                        task.wait(0.5); task.spawn(function() pp2PlayAnim(char) end)
                                    end
                                end)
                            end
                            stopPiggyback2 = function()
                                if pp2Conn then
                                    pp2Conn:Disconnect(); pp2Conn = nil
                                end
                                _AF.pp2Active = false; pp2Target = nil
                                if not _SOH.active and not ppActive then setFreeze(false) end
                                pp2StopAnim()
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startPiggyback2 = function(targetPlayer)
                                stopPiggyback2()
                                local myChar = LocalPlayer.Character; local targetChar = targetPlayer and
                                targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Piggyback2", "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif("Piggyback2", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid()
                                if hum then hum.PlatformStand = true end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local _pp2TP = tgtTorso.Position + tgtTorso.CFrame.LookVector * -1.1 +
                                Vector3.new(0, 0.2, 0)
                                local _pp2CP = _pp2TP
                                _AF.pp2Active = true; pp2Target = targetPlayer
                                sendNotif("Piggyback2", "Clinging to " .. targetPlayer.Name .. " 🐵", 3)
                                pp2StartAnim()
                                pp2Conn = _RSConnect(function(dt)
                                    if not _AF.pp2Active then return end
                                    local tc    = pp2Target and pp2Target.Character
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart"); if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tgtRoot)
                                    _pp2TP              = torso.Position + torso.CFrame.LookVector * -1.1 +
                                    Vector3.new(0, 0.2, 0)
                                    local _pp2A         = 1 - (1 - 0.98) ^ (dt * 60); _pp2CP = _pp2CP:Lerp(_pp2TP, _pp2A)
                                    myR.Velocity = Vector3.zero
                                    myR.CFrame = CFrame.new(_pp2CP, myR.Position + torso.CFrame.LookVector)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2            = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Piggyback2()
                end
                do
                    local function _TLact_Kiss()
                        do
                            local kissConn      = nil
                            local kissTarget    = nil
                            local kissAnimTrack = nil
                            local kissAnimConn  = nil
                            local kissCharConn  = nil
                            local KISS_ANIM_ID  = "102367337136163"
                            local function kissStopAnim()
                                if kissAnimConn then
                                    kissAnimConn:Disconnect(); kissAnimConn = nil
                                end
                                if kissCharConn then
                                    kissCharConn:Disconnect(); kissCharConn = nil
                                end
                                if kissAnimTrack then
                                    pcall(function()
                                        kissAnimTrack:AdjustSpeed(1); kissAnimTrack:Stop()
                                    end)
                                    kissAnimTrack = nil
                                end
                            end
                            local function kissPlayAnim(char)
                                if not char then return end
                                if KISS_ANIM_ID == "0" or KISS_ANIM_ID == "" then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                if hum.RigType == Enum.HumanoidRigType.R6 then return end
                                local track = _AF_getReliableActionTrack(hum, KISS_ANIM_ID, "KissAnim")
                                if not track then return end
                                setFreeze(true)
                                kissAnimTrack = track
                                if kissAnimConn then kissAnimConn:Disconnect() end
                                kissAnimConn = track.Stopped:Connect(function()
                                    if _AF.kissActive then
                                        task.wait(0.05)
                                        if _AF.kissActive then pcall(function() kissPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function kissStartAnim()
                                kissStopAnim()
                                task.spawn(function() kissPlayAnim(LocalPlayer.Character) end)
                                kissCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.kissActive then
                                        task.wait(0.5); task.spawn(function() kissPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopKiss = function()
                                _AF.kissActive = false; kissTarget = nil
                                if kissConn then
                                    kissConn:Disconnect(); kissConn = nil
                                end
                                if kissBodyPos then
                                end
                                if kissBodyGyro then
                                end
                                kissStopAnim()

                                local myChar = LocalPlayer.Character
                                local myR = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")

                                if myR then
                                    pcall(function() sethiddenproperty(myR, "PhysicsRepRootPart", nil) end)
                                    pcall(function() myR.Anchored = false end)
                                    myR.Velocity = Vector3.zero
                                    pcall(function()
                                        for _, o in ipairs(myR:GetChildren()) do
                                            if o:IsA("BodyVelocity") or o:IsA("BodyAngularVelocity")
                                                or o:IsA("BodyPosition") or o:IsA("BodyGyro") then
                                                o:Destroy()
                                            end
                                        end
                                    end)
                                end

                                if hum then
                                    pcall(function() hum.Sit = false end)
                                    pcall(function() hum.AutoRotate = true end)
                                    pcall(function() hum.WalkSpeed = 16 end)
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
                                    pcall(function() if not flyActive then hum.PlatformStand = false end end)
                                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                                end

                                setFreeze(false)
                                safeStand()

                                task.delay(0.08, function()
                                    local c2 = LocalPlayer.Character
                                    local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                                    local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
                                    if r2 then
                                        pcall(function() sethiddenproperty(r2, "PhysicsRepRootPart", nil) end)
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
                                        pcall(function() if not flyActive then h2.PlatformStand = false end end)
                                        pcall(function() h2:ChangeState(Enum.HumanoidStateType.Running) end)
                                    end
                                    pcall(safeStand)
                                end)
                            end

                            pcall(function()
                                local _lpc = LocalPlayer.Character
                                local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                            end)

                            startKiss = function(targetPlayer)
                                stopKiss()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Kiss", "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif("Kiss", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid()
                                if hum then hum.PlatformStand = true end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                pcall(function()
                                    local hum = getHumanoid(); if hum then hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end
                                end)
                                local oscTime = 0
                                local KISS_SPEED = 10.0
                                _AF.kissActive = true; kissTarget = targetPlayer
                                sendNotif("Kiss", "💋 Kiss: " .. targetPlayer.Name, 3)
                                kissStartAnim()
                                myRoot.Velocity = Vector3.zero
                                myRoot.CFrame = tgtRoot.CFrame * CFrame.new(0, -0.5, -1.0) * _CF_ROT180Y
                                kissConn = _RSConnect(function(dt)
                                    if not _AF.kissActive then return end
                                    local tc    = kissTarget and kissTarget.Character
                                    local tHRP  = tc and tc:FindFirstChild("HumanoidRootPart")
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not tHRP or not torso.Parent or not tHRP.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR  = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP)
                                    oscTime = oscTime + dt * KISS_SPEED
                                    pcall(function()
                                        local offset = -1.2 - math.sin(oscTime) * 0.08
                                        myR.CFrame = tHRP.CFrame * CFrame.new(0, 1.5, offset) * _CF_ROT180Y
                                    end)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    myR.Velocity = Vector3.zero
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Kiss()
                end
                do
                    local function _TLact_Backpack()
                        do
                            local bpConn           = nil
                            local bpTarget         = nil
                            local bpHoverVel       = nil
                            local bpAnimTrack      = nil
                            local bpAnimConn       = nil
                            local bpCharConn       = nil
                            local BACKPACK_ANIM_ID = "73500261613116"
                            local function bpStopAnim()
                                if bpAnimConn then
                                    bpAnimConn:Disconnect(); bpAnimConn = nil
                                end
                                if bpCharConn then
                                    bpCharConn:Disconnect(); bpCharConn = nil
                                end
                                if bpAnimTrack then
                                    pcall(function()
                                        bpAnimTrack:AdjustSpeed(1); bpAnimTrack:Stop()
                                    end)
                                    bpAnimTrack = nil
                                end
                            end
                            local function bpPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, BACKPACK_ANIM_ID, "BackpackAnim")
                                if not track then return end
                                setFreeze(true)
                                bpAnimTrack = track
                                if bpAnimConn then bpAnimConn:Disconnect() end
                                bpAnimConn = track.Stopped:Connect(function()
                                    if _AF.backpackActive then
                                        task.wait(0.05)
                                        if _AF.backpackActive then pcall(function() bpPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function bpStartAnim()
                                bpStopAnim()
                                task.spawn(function() bpPlayAnim(LocalPlayer.Character) end)
                                bpCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.backpackActive then
                                        task.wait(0.5); task.spawn(function() bpPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopBackpack = function()
                                if bpConn then
                                    bpConn:Disconnect(); bpConn = nil
                                end
                                _AF.backpackActive = false; bpTarget = nil
                                if bpBodyPos then
                                end
                                if bpBodyGyro then
                                end
                                if bpHoverVel then
                                    pcall(function() bpHoverVel:Destroy() end); bpHoverVel = nil
                                end
                                if not _SOH.active and not ppActive and not _AF.kissActive then setFreeze(false) end
                                bpStopAnim()
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startBackpack = function(targetPlayer)
                                stopBackpack()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Backpack", "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif("Backpack", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local _bpkTP = tgtTorso.Position + tgtTorso.CFrame.LookVector * -1.2 +
                                Vector3.new(0, 2.5, 0); local _bpkCP = _bpkTP
                                _AF.backpackActive = true; bpTarget = targetPlayer
                                sendNotif("Backpack", "🎒 Backpack: " .. targetPlayer.Name, 3)
                                bpStartAnim()
                                setFreeze(true)
                                bpConn = _RSConnect(function()
                                    if not _AF.backpackActive then return end
                                    local tc    = bpTarget and bpTarget.Character
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tgtRoot)
                                    _bpkTP = torso.Position + torso.CFrame.LookVector * -1.2 + Vector3.new(0, 2.5, 0)
                                    local _bpkA = 1 - (1 - 0.98) ^ (1 / 60 * 60); _bpkCP = _bpkCP:Lerp(_bpkTP, _bpkA)
                                    myR.Velocity = Vector3.zero
                                    myR.CFrame = CFrame.new(_bpkCP, myR.Position + torso.CFrame.LookVector) * CFrame.Angles(0, -2 * math.pi, 0)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Backpack()
                end
                do
                    local function _TLact_Licking()
                        do
                            local lickingConn      = nil
                            local lickingTarget    = nil
                            local lickingBodyPos   = nil
                            local lickingAnimTrack = nil
                            local lickingAnimConn  = nil
                            local lickingCharConn  = nil
                            local LICKING_ANIM_ID  = "86345507952689"
                            local function lickingStopAnim()
                                if lickingAnimConn then
                                    lickingAnimConn:Disconnect(); lickingAnimConn = nil
                                end
                                if lickingCharConn then
                                    lickingCharConn:Disconnect(); lickingCharConn = nil
                                end
                                if lickingAnimTrack then
                                    pcall(function()
                                        lickingAnimTrack:AdjustSpeed(1); lickingAnimTrack:Stop()
                                    end)
                                    lickingAnimTrack = nil
                                end
                            end
                            local function lickingPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, LICKING_ANIM_ID, "LickingAnim")
                                if not track then return end
                                setFreeze(true)
                                lickingAnimTrack = track
                                track:AdjustSpeed(1.5)
                                if lickingAnimConn then lickingAnimConn:Disconnect() end
                                lickingAnimConn = track.Stopped:Connect(function()
                                    if _AF.lickingActive then
                                        task.wait(0.05)
                                        if _AF.lickingActive then pcall(function() lickingPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function lickingStartAnim()
                                lickingStopAnim()
                                task.spawn(function() lickingPlayAnim(LocalPlayer.Character) end)
                                lickingCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.lickingActive then
                                        task.wait(0.5); task.spawn(function() lickingPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopLicking = function()
                                _AF.lickingActive = false; lickingTarget = nil
                                if lickingConn then
                                    lickingConn:Disconnect(); lickingConn = nil
                                end
                                if lickingBodyPos then
                                    pcall(function() lickingBodyPos:Destroy() end); lickingBodyPos = nil
                                end
                                lickingStopAnim()
                                setFreeze(false)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startLicking = function(targetPlayer)
                                stopLicking()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Licking", "No character!", 2); return
                                end
                                local myRoot  = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                if not myRoot or not tgtRoot then
                                    sendNotif("Licking", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid()
                                if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function() myRoot:SetNetworkOwner(LocalPlayer) end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local tgtCF0 = tgtRoot.CFrame * CFrame.new(0, -1.4, -2.5) * _CF_ROT180Y
                                pcall(function()
                                    myRoot.CFrame = tgtCF0; myRoot.Velocity = _V3_ZERO
                                end)
                                local oscTime = 0
                                local LICKING_SPEED = 15.0
                                _AF.lickingActive = true; lickingTarget = targetPlayer
                                sendNotif("Licking", "Licking " .. targetPlayer.Name .. " 👅", 3)
                                lickingStartAnim()
                                lickingConn = _RSConnect(function(dt)
                                    if not _AF.lickingActive then return end
                                    local tc    = lickingTarget and lickingTarget.Character
                                    local torso = tc and tc:FindFirstChild("HumanoidRootPart")
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", torso)
                                    oscTime = oscTime + dt * LICKING_SPEED
                                    myR.Velocity = Vector3.zero
                                    local tPelvis = torso
                                    local tgtCF = tPelvis.CFrame * CFrame.new(0, -3.4, -2.5 - math.sin(oscTime) * 0.4) *
                                    _CF_ROT180Y
                                    myR.CFrame = tgtCF
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Licking()
                end
                do
                    local function _TLact_SuckIt()
                        do
                            local suckItConn      = nil
                            local suckItTarget    = nil
                            local suckItAnimTrack = nil
                            local suckItAnimConn  = nil
                            local suckItCharConn  = nil
                            local SUCKIT_ANIM_ID  = "79294534752809"
                            local function suckItStopAnim()
                                if suckItAnimConn then
                                    suckItAnimConn:Disconnect(); suckItAnimConn = nil
                                end
                                if suckItCharConn then
                                    suckItCharConn:Disconnect(); suckItCharConn = nil
                                end
                                if suckItAnimTrack then
                                    pcall(function()
                                        suckItAnimTrack:AdjustSpeed(1); suckItAnimTrack:Stop()
                                    end)
                                    suckItAnimTrack = nil
                                end
                            end
                            local function suckItPlayAnim(char)
                                if not char then return end
                                if SUCKIT_ANIM_ID == "0" or SUCKIT_ANIM_ID == "" then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, SUCKIT_ANIM_ID, "SuckItAnim")
                                if not track then return end
                                setFreeze(true)
                                suckItAnimTrack = track
                                track:AdjustSpeed(1.5)
                                if suckItAnimConn then suckItAnimConn:Disconnect() end
                                suckItAnimConn = track.Stopped:Connect(function()
                                    if _AF.suckItActive then
                                        task.wait(0.05)
                                        if _AF.suckItActive then pcall(function() suckItPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function suckItStartAnim()
                                suckItStopAnim()
                                task.spawn(function() suckItPlayAnim(LocalPlayer.Character) end)
                                suckItCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.suckItActive then
                                        task.wait(0.5); task.spawn(function() suckItPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopSuckIt = function()
                                _AF.suckItActive = false; suckItTarget = nil
                                if suckItConn then
                                    suckItConn:Disconnect(); suckItConn = nil
                                end
                                suckItStopAnim()
                                setFreeze(false)
                                local hum = getHumanoid()
                                if hum and not flyActive then
                                    hum.PlatformStand = false
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
                                end
                                pcall(function()
                                    local myR = getRootPart()
                                    if myR then myR.Velocity = Vector3.zero end
                                end)
                            end
                            startSuckIt = function(targetPlayer)
                                stopSuckIt()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Suck It", "No character!", 2); return
                                end
                                local myRoot  = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                if not myRoot or not tgtRoot then
                                    sendNotif("Suck It", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid()
                                if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function() myRoot:SetNetworkOwner(LocalPlayer) end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local tgtCF0 = tgtRoot.CFrame * CFrame.new(0, -2.2, -2.0) * _CF_ROT180Y
                                pcall(function()
                                    myRoot.CFrame = tgtCF0; myRoot.Velocity = _V3_ZERO
                                end)
                                local oscTime = 0
                                local SUCKIT_OSC_SPEED = 12.0
                                _AF.suckItActive = true; suckItTarget = targetPlayer
                                sendNotif("Suck it", "😈 " .. targetPlayer.Name, 3)
                                suckItStartAnim()
                                suckItConn = _RSConnect(function(dt)
                                    if not _AF.suckItActive then return end
                                    local tc    = suckItTarget and suckItTarget.Character
                                    local torso = tc and tc:FindFirstChild("HumanoidRootPart")
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR  = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", torso)
                                    oscTime = oscTime + dt * SUCKIT_OSC_SPEED
                                    myR.Velocity = Vector3.zero
                                    local tPelvis = torso
                                    local tgtCF = tPelvis.CFrame * CFrame.new(0, -1.2, -2.0 - math.sin(oscTime) * 1.0) *
                                    _CF_ROT180Y
                                    myR.CFrame = tgtCF
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_SuckIt()
                end
                do
                    local function _TLact_Sucking()
                        do
                            local suckingConn      = nil
                            local suckingTarget    = nil
                            local suckingAnimTrack = nil
                            local suckingAnimConn  = nil
                            local suckingCharConn  = nil
                            local SUCKING_ANIM_ID  = "74402438715168"
                            local function suckingStopAnim()
                                if suckingAnimConn then
                                    suckingAnimConn:Disconnect(); suckingAnimConn = nil
                                end
                                if suckingCharConn then
                                    suckingCharConn:Disconnect(); suckingCharConn = nil
                                end
                                if suckingAnimTrack then
                                    pcall(function()
                                        suckingAnimTrack:AdjustSpeed(1); suckingAnimTrack:Stop()
                                    end)
                                    suckingAnimTrack = nil
                                end
                                _G._TLSuckingTrack = nil
                            end
                            local function suckingPlayAnim(char)
                                if not char then return end
                                if SUCKING_ANIM_ID == "0" or SUCKING_ANIM_ID == "" then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, SUCKING_ANIM_ID, "SuckingAnim")
                                if not track then return end
                                setFreeze(true)
                                suckingAnimTrack = track
                                track:AdjustSpeed(2)
                                _G._TLSuckingTrack = track
                                if suckingAnimConn then suckingAnimConn:Disconnect() end
                                suckingAnimConn = track.Stopped:Connect(function()
                                    if _AF.suckingActive then
                                        task.wait(0.05)
                                        if _AF.suckingActive then pcall(function() suckingPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function suckingStartAnim()
                                suckingStopAnim()
                                task.spawn(function() suckingPlayAnim(LocalPlayer.Character) end)
                                suckingCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.suckingActive then
                                        task.wait(0.5); task.spawn(function() suckingPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopSucking = function()
                                _AF.suckingActive = false; suckingTarget = nil
                                if suckingConn then
                                    suckingConn:Disconnect(); suckingConn = nil
                                end
                                if suckingBodyPos then
                                end
                                if suckingBodyGyro then
                                end
                                suckingStopAnim()
                                setFreeze(false)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startSucking = function(targetPlayer)
                                stopSucking()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Sucking", "No character!", 2); return
                                end
                                local myRoot  = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                if not myRoot or not tgtRoot then
                                    sendNotif("Sucking", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid()
                                if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function() myRoot:SetNetworkOwner(LocalPlayer) end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local tgtCF0 = tgtRoot.CFrame * CFrame.new(0, -1.4, -3.1) * _CF_ROT180Y
                                pcall(function()
                                    myRoot.CFrame = tgtCF0; myRoot.Velocity = _V3_ZERO
                                end)
                                local oscTime = 0
                                local SUCKING_SPEED = 20.0
                                _AF.suckingActive = true; suckingTarget = targetPlayer
                                sendNotif("Sucking", "😈 Sucking " .. targetPlayer.Name, 3)
                                suckingStartAnim()
                                suckingConn = _RSConnect(function(dt)
                                    if not _AF.suckingActive then return end
                                    local tc    = suckingTarget and suckingTarget.Character
                                    local torso = tc and tc:FindFirstChild("HumanoidRootPart")
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", torso)
                                    oscTime = oscTime + dt * SUCKING_SPEED
                                    myR.Velocity = Vector3.zero
                                    local tPelvis = torso
                                    local tgtCF = tPelvis.CFrame * CFrame.new(0, -0.4, -3.1 - math.sin(oscTime) * 0.5) *
                                    _CF_ROT180Y
                                    myR.CFrame = tgtCF
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Sucking()
                end
                do
                    local function _TLact_Facefuck()
                        do
                            local facefuckConn      = nil
                            local facefuckTarget    = nil
                            local facefuckAnimTrack = nil
                            local facefuckAnimConn  = nil
                            local facefuckCharConn  = nil
                            local FACEFUCK_ANIM_ID  = "01180934467755"
                            local function facefuckStopAnim()
                                if facefuckAnimConn then
                                    facefuckAnimConn:Disconnect(); facefuckAnimConn = nil
                                end
                                if facefuckCharConn then
                                    facefuckCharConn:Disconnect(); facefuckCharConn = nil
                                end
                                if facefuckAnimTrack then
                                    pcall(function()
                                        facefuckAnimTrack:AdjustSpeed(1); facefuckAnimTrack:Stop()
                                    end)
                                    facefuckAnimTrack = nil
                                end
                            end
                            local function facefuckPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, FACEFUCK_ANIM_ID, "FacefuckAnim")
                                if not track then return end
                                setFreeze(true)
                                facefuckAnimTrack = track
                                if facefuckAnimConn then facefuckAnimConn:Disconnect() end
                                facefuckAnimConn = track.Stopped:Connect(function()
                                    if _AF.facefuckActive then
                                        task.wait(0.05)
                                        if _AF.facefuckActive then pcall(function() facefuckPlayAnim(LocalPlayer
                                                .Character) end) end
                                    end
                                end)
                            end
                            local function facefuckStartAnim()
                                facefuckStopAnim()
                                task.spawn(function() facefuckPlayAnim(LocalPlayer.Character) end)
                                facefuckCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.facefuckActive then
                                        task.wait(0.5); task.spawn(function() facefuckPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopFacefuck = function()
                                _AF.facefuckActive = false; facefuckTarget = nil
                                if facefuckConn then
                                    facefuckConn:Disconnect(); facefuckConn = nil
                                end
                                if facefuckBodyPos then
                                end
                                facefuckStopAnim()
                                setFreeze(false)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startFacefuck = function(targetPlayer)
                                stopFacefuck()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Facefuck", "No character!", 2); return
                                end
                                local myRoot  = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtHead = targetChar:FindFirstChild("Head")
                                if not myRoot or not tgtRoot or not tgtHead then
                                    sendNotif("Facefuck", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local oscTime      = 0
                                local FF_SPEED     = 12.0
                                local FF_DEPTH     = 0.9
                                local FF_BASE_Z    = -2.8
                                _AF.facefuckActive = true; facefuckTarget = targetPlayer
                                sendNotif("Facefuck", "😈 Facefucking " .. targetPlayer.Name, 3)
                                facefuckStartAnim()
                                myRoot.Velocity = Vector3.zero
                                myRoot.CFrame = tgtHead.CFrame * CFrame.new(0, -2.6, FF_BASE_Z) * _CF_ROT180Y
                                facefuckConn = _RSConnect(function(dt)
                                    if not _AF.facefuckActive then return end
                                    local tc   = facefuckTarget and facefuckTarget.Character
                                    local head = tc and tc:FindFirstChild("Head")
                                    if not head or not head.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", head)
                                    oscTime = oscTime + dt * FF_SPEED
                                    myR.Velocity = Vector3.zero
                                    pcall(function()
                                        local zOffset = FF_BASE_Z - math.sin(oscTime) * FF_DEPTH
                                        local torso = tc and tc:FindFirstChild("HumanoidRootPart")
                                        local stableCF = torso and (torso.CFrame * CFrame.new(0, -2.6, 0)) or head
                                        .CFrame
                                        myR.CFrame = stableCF
                                            * CFrame.new(0, 0, zOffset)
                                            * _CF_ROT180Y
                                    end)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Facefuck()
                end
                do
                    local function _TLact_Backshots()
                        do
                            local backshotsConn      = nil
                            local backshotsTarget    = nil
                            local backshotsBodyPos   = nil
                            local backshotsAnimTrack = nil
                            local backshotsAnimConn  = nil
                            local backshotsCharConn  = nil
                            local BACKSHOTS_ANIM_ID  = "101003999980390"
                            local function backshotsStopAnim()
                                if backshotsAnimConn then
                                    backshotsAnimConn:Disconnect(); backshotsAnimConn = nil
                                end
                                if backshotsCharConn then
                                    backshotsCharConn:Disconnect(); backshotsCharConn = nil
                                end
                                if backshotsAnimTrack then
                                    pcall(function()
                                        backshotsAnimTrack:AdjustSpeed(1); backshotsAnimTrack:Stop()
                                    end)
                                    backshotsAnimTrack = nil
                                end
                            end
                            local function backshotsPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, BACKSHOTS_ANIM_ID, "BackshotsAnim")
                                if not track then return end
                                setFreeze(true)
                                backshotsAnimTrack = track
                                if backshotsAnimConn then backshotsAnimConn:Disconnect() end
                                backshotsAnimConn = track.Stopped:Connect(function()
                                    if _AF.backshotsActive then
                                        task.wait(0.05)
                                        if _AF.backshotsActive then pcall(function() backshotsPlayAnim(LocalPlayer
                                                .Character) end) end
                                    end
                                end)
                            end
                            local function backshotsStartAnim()
                                backshotsStopAnim()
                                task.spawn(function() backshotsPlayAnim(LocalPlayer.Character) end)
                                backshotsCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.backshotsActive then
                                        task.wait(0.5); task.spawn(function() backshotsPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopBackshots = function()
                                _AF.backshotsActive = false; backshotsTarget = nil
                                if backshotsConn then
                                    backshotsConn:Disconnect(); backshotsConn = nil
                                end
                                if backshotsBodyPos then
                                    pcall(function() backshotsBodyPos:Destroy() end); backshotsBodyPos = nil
                                end
                                backshotsStopAnim()
                                pcall(function() setFreeze(false) end)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startBackshots = function(targetPlayer)
                                stopBackshots()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Backshots", "No character!", 2); return
                                end
                                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                                local tHRP   = targetChar:FindFirstChild("HumanoidRootPart")
                                if not myRoot or not tHRP then
                                    sendNotif("Backshots", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function() myRoot:SetNetworkOwner(LocalPlayer) end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tHRP)
                                local oscTime = 0
                                local BS_SPEED = 10.0
                                _AF.backshotsActive = true; backshotsTarget = targetPlayer
                                sendNotif("Backshots", "Backshots on " .. targetPlayer.Name, 3)
                                backshotsStartAnim()
                                myRoot.Velocity = Vector3.zero
                                myRoot.CFrame = tHRP.CFrame * CFrame.new(0, -1.85, -2.0) *
                                    CFrame.Angles(math.rad(20) + 0.03, 0, 0)
                                backshotsConn = _RSConnect(function(dt)
                                    if not _AF.backshotsActive then return end
                                    local tc    = backshotsTarget and backshotsTarget.Character
                                    local tHRP2 = tc and tc:FindFirstChild("HumanoidRootPart")
                                    local _lpc  = LocalPlayer.Character
                                    local myR   = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                    if not tHRP2 or not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP2)
                                    oscTime = oscTime + dt * BS_SPEED
                                    myR.Velocity = Vector3.zero
                                    local tPelvis = tHRP2
                                    local offset = -2.0 - math.sin(oscTime) * 1.5
                                    myR.CFrame = tPelvis.CFrame * CFrame.new(0, -3.2, offset) * CFrame.Angles(math.rad(20) + 0.03, 0, 0)
                                    for _, _6_ in ipairs(_lpc:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Backshots()
                end
                do
                    local function _TLact_LayFuck()
                        do
                            local layFuckConn      = nil
                            local layFuckTarget    = nil
                            local layFuckAnimTrack = nil
                            local layFuckAnimConn  = nil
                            local layFuckCharConn  = nil
                            local LAYFUCK_ANIM_ID  = "95678189010798"
                            local function layFuckStopAnim()
                                if layFuckAnimConn then
                                    layFuckAnimConn:Disconnect(); layFuckAnimConn = nil
                                end
                                if layFuckCharConn then
                                    layFuckCharConn:Disconnect(); layFuckCharConn = nil
                                end
                                if layFuckAnimTrack then
                                    pcall(function()
                                        layFuckAnimTrack:AdjustSpeed(1); layFuckAnimTrack:Stop()
                                    end)
                                    layFuckAnimTrack = nil
                                end
                            end
                            local function layFuckPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, LAYFUCK_ANIM_ID, "LayFuckAnim")
                                if not track then return end
                                setFreeze(true)
                                layFuckAnimTrack = track
                                if layFuckAnimConn then layFuckAnimConn:Disconnect() end
                                layFuckAnimConn = track.Stopped:Connect(function()
                                    if _AF.layFuckActive then
                                        task.wait(0.05)
                                        if _AF.layFuckActive then pcall(function() layFuckPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function layFuckStartAnim()
                                layFuckStopAnim()
                                task.spawn(function() layFuckPlayAnim(LocalPlayer.Character) end)
                                layFuckCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.layFuckActive then
                                        task.wait(0.5); task.spawn(function() layFuckPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopLayFuck = function()
                                _AF.layFuckActive = false; layFuckTarget = nil
                                if layFuckConn then
                                    layFuckConn:Disconnect(); layFuckConn = nil
                                end
                                if layFuckBodyPos then
                                end
                                layFuckStopAnim()
                                pcall(function() setFreeze(false) end)
                                local hum = getHumanoid()
                                if hum and not flyActive then
                                    hum.PlatformStand = false
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        if myRoot then myRoot.Velocity = Vector3.zero end
                                    end)
                                end
                            end
                            startLayFuck = function(targetPlayer)
                                stopLayFuck()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Lay Fuck", "No character!", 2); return
                                end
                                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                                local tHRP   = targetChar:FindFirstChild("HumanoidRootPart")
                                if not myRoot or not tHRP then
                                    sendNotif("Lay Fuck", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function() myRoot:SetNetworkOwner(LocalPlayer) end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tHRP)
                                local oscTime     = 0
                                local LF_SPEED    = 12.0
                                local LF_DEPTH    = 0.9
                                local LF_BASE     = 1.1
                                _AF.layFuckActive = true; layFuckTarget = targetPlayer
                                sendNotif("Lay Fuck", "Lay Fuck on " .. targetPlayer.Name, 3)
                                layFuckStartAnim()
                                myRoot.Velocity = Vector3.zero
                                myRoot.CFrame = tHRP.CFrame * CFrame.new(0, -3.7, LF_BASE) * _CF_ROT180Y
                                layFuckConn = _RSConnect(function(dt)
                                    if not _AF.layFuckActive then return end
                                    local tc    = layFuckTarget and layFuckTarget.Character
                                    local tHRP2 = tc and tc:FindFirstChild("HumanoidRootPart")
                                    local _lpc  = LocalPlayer.Character
                                    local myR   = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                    if not tHRP2 or not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP2)
                                    oscTime = oscTime + dt * LF_SPEED
                                        local tPelvis = tHRP2
                                        local zOff = LF_BASE - math.sin(oscTime) * LF_DEPTH
                                        myR.Velocity = Vector3.zero
                                        myR.CFrame = tPelvis.CFrame * CFrame.new(0, -1.7, zOff)
                                    for _, _6_ in ipairs(_lpc:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function()
                                        if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                                            h2:ChangeState(Enum.HumanoidStateType.Physics)
                                        end
                                    end)
                                end)
                            end
                        end
                    end
                    _TLact_LayFuck()
                end

                do
                    local function _TLact_Doggy()
                        do
                            local doggyConn      = nil
                            local doggyTarget    = nil
                            local doggyAnimTrack = nil
                            local doggyAnimConn  = nil
                            local doggyCharConn  = nil

                            local DOGGY_ANIM_ID  = "101856096472698"

                            local function doggyStopAnim()
                                if doggyAnimTrack then
                                    doggyAnimTrack:Stop(); doggyAnimTrack = nil
                                end
                                if doggyAnimConn then
                                    doggyAnimConn:Disconnect(); doggyAnimConn = nil
                                end
                                if doggyCharConn then
                                    doggyCharConn:Disconnect(); doggyCharConn = nil
                                end
                            end

                            local function doggyPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, DOGGY_ANIM_ID, "DoggyAnim")
                                if not track then return end
                                setFreeze(true)
                                doggyAnimTrack = track
                                if doggyAnimConn then doggyAnimConn:Disconnect() end
                                doggyAnimConn = track.Stopped:Connect(function()
                                    if _AF.doggyActive then
                                        task.wait(0.05)
                                        if _AF.doggyActive then pcall(function() doggyPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                                track:Play()
                                track:AdjustSpeed(1.5)
                            end

                            local function doggyStartAnim()
                                doggyStopAnim()
                                task.spawn(function() doggyPlayAnim(LocalPlayer.Character) end)
                                doggyCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.doggyActive then
                                        task.wait(0.5); task.spawn(function() doggyPlayAnim(char) end)
                                    end
                                end)
                            end

                            stopDoggy = function()
                                _AF.doggyActive = false; doggyTarget = nil
                                if doggyConn then
                                    doggyConn:Disconnect(); doggyConn = nil
                                end
                                if doggyBodyPos then
                                end
                                doggyStopAnim()
                                setFreeze(false)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end

                            startDoggy = function(targetPlayer)
                                stopDoggy()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Doggy", "No character!", 2); return
                                end
                                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                                local tHRP   = targetChar:FindFirstChild("HumanoidRootPart")
                                if not myRoot or not tHRP then
                                    sendNotif("Doggy", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function() myRoot:SetNetworkOwner(LocalPlayer) end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tHRP)
                                local oscTime = 0
                                _AF.doggyActive = true; doggyTarget = targetPlayer
                                sendNotif("Doggy", "Doggy on " .. targetPlayer.Name, 3)
                                doggyStartAnim()
                                pcall(function()
                                    local tPelvis = tHRP
                                    myRoot.CFrame = tPelvis.CFrame * CFrame.new(0, -4.4, -0.8)
                                    myRoot.Velocity = Vector3.zero
                                end)
                                doggyConn = _RSConnect(function(dt)
                                    if not _AF.doggyActive then return end
                                    local tc    = doggyTarget and doggyTarget.Character
                                    local tHRP2 = tc and tc:FindFirstChild("HumanoidRootPart")
                                    local _lpc  = LocalPlayer.Character
                                    local myR   = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                    if not tHRP2 or not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP2)
                                    myR.Velocity = Vector3.zero
                                    local tPelvis2 = tHRP2
                                    myR.CFrame = tPelvis2.CFrame * CFrame.new(0, -4.7, -0.8) * CFrame.Angles(math.rad(-90), 0, 0)
                                    for _, _6_ in ipairs(_lpc:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                end)
                            end
                        end
                    end
                    _TLact_Doggy()
                end
                do
                    local function _TLact_PussySpread()
                        do
                            local psConn      = nil
                            local psTarget    = nil
                            local psAnimTrack = nil
                            local psAnimConn  = nil
                            local psCharConn  = nil
                            local PS_ANIM_ID  = "120754278085861"
                            local function psStopAnim()
                                if psAnimConn then
                                    psAnimConn:Disconnect(); psAnimConn = nil
                                end
                                if psCharConn then
                                    psCharConn:Disconnect(); psCharConn = nil
                                end
                                if psAnimTrack then
                                    pcall(function()
                                        psAnimTrack:AdjustSpeed(1); psAnimTrack:Stop()
                                    end)
                                    psAnimTrack = nil
                                end
                            end
                            local function psPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, PS_ANIM_ID, "PussySpreadAnim")
                                if not track then return end
                                setFreeze(true)
                                psAnimTrack = track
                                if psAnimConn then psAnimConn:Disconnect() end
                                psAnimConn = track.Stopped:Connect(function()
                                    if _AF.pussySpreadActive then
                                        task.wait(0.05)
                                        if _AF.pussySpreadActive then pcall(function() psPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function psStartAnim()
                                psStopAnim()
                                task.spawn(function() psPlayAnim(LocalPlayer.Character) end)
                                psCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.pussySpreadActive then
                                        task.wait(0.5); task.spawn(function() psPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopPussySpread = function()
                                _AF.pussySpreadActive = false; psTarget = nil
                                if psConn then
                                    psConn:Disconnect(); psConn = nil
                                end
                                if psBodyPos then
                                end
                                psStopAnim()
                                pcall(function() setFreeze(false) end)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startPussySpread = function(targetPlayer)
                                stopPussySpread()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Pussy Spread", "No character!", 2); return
                                end
                                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                                local tHRP   = targetChar:FindFirstChild("HumanoidRootPart")
                                if not myRoot or not tHRP then
                                    sendNotif("Pussy Spread", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function() myRoot:SetNetworkOwner(LocalPlayer) end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tHRP)
                                local oscTime = 0
                                local PS_SPEED = 10.0
                                _AF.pussySpreadActive = true; psTarget = targetPlayer
                                sendNotif("Pussy Spread", "Pussy Spread on " .. targetPlayer.Name, 3)
                                psStartAnim()
                                psConn = _RSConnect(function(dt)
                                    if not _AF.pussySpreadActive then return end
                                    local tc    = psTarget and psTarget.Character
                                    local tHRP2 = tc and tc:FindFirstChild("HumanoidRootPart")
                                    local _lpc  = LocalPlayer.Character
                                    local myR   = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                    if not tHRP2 or not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP2)
                                    oscTime = oscTime + dt * PS_SPEED
                                    myR.Velocity = Vector3.zero
                                    local tPelvis = tHRP2
                                    local offset = -2.0 - math.sin(oscTime) * 1.5
                                    myR.CFrame = tPelvis.CFrame * CFrame.new(0, -2.45, offset)
                                    for _, _6_ in ipairs(_lpc:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _lpc and _lpc:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_PussySpread()
                end
                do
                    local function _TLact_Hug()
                        do
                            local hugConn      = nil
                            local hugTarget    = nil
                            local hugCurrentCF = nil
                            local hugAnimTrack = nil
                            local hugAnimConn  = nil
                            local hugCharConn  = nil
                            local HUG_ANIM_ID  = "93667149408515"
                            local function hugStopAnim()
                                if hugAnimConn then
                                    hugAnimConn:Disconnect(); hugAnimConn = nil
                                end
                                if hugCharConn then
                                    hugCharConn:Disconnect(); hugCharConn = nil
                                end
                                if hugAnimTrack then
                                    pcall(function()
                                        hugAnimTrack:AdjustSpeed(1); hugAnimTrack:Stop()
                                    end)
                                    hugAnimTrack = nil
                                end
                            end
                            local function hugPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, HUG_ANIM_ID, "HugAnim")
                                if not track then return end
                                setFreeze(true)
                                hugAnimTrack = track
                                if hugAnimConn then hugAnimConn:Disconnect() end
                                hugAnimConn = track.Stopped:Connect(function()
                                    if _AF.hugActive then
                                        task.wait(0.05)
                                        if _AF.hugActive then pcall(function() hugPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function hugStartAnim()
                                hugStopAnim()
                                task.spawn(function() hugPlayAnim(LocalPlayer.Character) end)
                                hugCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.hugActive then
                                        task.wait(0.5); task.spawn(function() hugPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopHug = function()
                                _AF.hugActive = false; hugTarget = nil
                                if hugConn then
                                    pcall(function() hugConn:Disconnect() end); hugConn = nil
                                end
                                if hugBodyPos then
                                end
                                hugCurrentCF = nil
                                hugStopAnim()
                                local myChar = LocalPlayer.Character
                                local myR = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                                if myR then
                                    pcall(function() sethiddenproperty(myR, "PhysicsRepRootPart", nil) end)
                                    pcall(function() myR.Anchored = false end)
                                    myR.Velocity = Vector3.zero
                                    pcall(function()
                                        for _, o in ipairs(myR:GetChildren()) do
                                            if o:IsA("BodyVelocity") or o:IsA("BodyAngularVelocity")
                                                or o:IsA("BodyPosition") or o:IsA("BodyGyro") then
                                                o:Destroy()
                                            end
                                        end
                                    end)
                                end
                                if hum then
                                    pcall(function() hum.Sit = false end)
                                    pcall(function() hum.AutoRotate = true end)
                                    pcall(function() hum.WalkSpeed = 16 end)
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true) end)
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Running, true) end)
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end)
                                    pcall(function() if not flyActive then hum.PlatformStand = false end end)
                                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                                end
                                setFreeze(false)
                                safeStand()
                                task.delay(0.08, function()
                                    local char2 = LocalPlayer.Character
                                    local hrp2 = char2 and char2:FindFirstChild("HumanoidRootPart")
                                    local hum2 = char2 and char2:FindFirstChildOfClass("Humanoid")
                                    if hrp2 then
                                        pcall(function() sethiddenproperty(hrp2, "PhysicsRepRootPart", nil) end)
                                        hrp2.Velocity = Vector3.zero
                                        pcall(function()
                                            for _, o in ipairs(hrp2:GetChildren()) do
                                                if o:IsA("BodyVelocity") or o:IsA("BodyAngularVelocity")
                                                    or o:IsA("BodyPosition") or o:IsA("BodyGyro") then
                                                    o:Destroy()
                                                end
                                            end
                                        end)
                                    end
                                    if hum2 then
                                        pcall(function() hum2.Sit = false end)
                                        pcall(function() if not flyActive then hum2.PlatformStand = false end end)
                                        pcall(function() hum2:ChangeState(Enum.HumanoidStateType.Running) end)
                                    end
                                    pcall(safeStand)
                                end)
                            end
                            startHug = function(targetPlayer)
                                stopHug()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Hug", "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif("Hug", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                hugCurrentCF = nil
                                local oscTime = 0
                                local HUG_SPEED = 10.0
                                _AF.hugActive = true; hugTarget = targetPlayer
                                sendNotif("Hug", "Hugging " .. targetPlayer.Name .. " 🤗", 3)
                                hugStartAnim()
                                pcall(function()
                                    local offset = -1.35
                                    local targetCF = tgtTorso.CFrame * CFrame.new(0, 0.05, offset) * _CF_ROT180Y
                                    myRoot.CFrame = targetCF
                                    myRoot.Velocity = Vector3.zero
                                end)
                                hugConn = _RSConnect(function(dt)
                                    if not _AF.hugActive then return end
                                    local tc    = hugTarget and hugTarget.Character
                                    local tHRP  = tc and tc:FindFirstChild("HumanoidRootPart")
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not tHRP then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tHRP)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    oscTime = oscTime + dt * HUG_SPEED
                                    pcall(function()
                                        local offset = -1.35 - math.sin(oscTime) * 0.04
                                        local targetCF = torso.CFrame * CFrame.new(0, 0.05, offset) * _CF_ROT180Y
                                        local alpha = 1 - (1 - 0.88) ^ (dt * 60)
                                        if not hugCurrentCF then
                                            hugCurrentCF = targetCF
                                        else
                                            hugCurrentCF = hugCurrentCF:Lerp(targetCF, alpha)
                                        end
                                        myR.CFrame = hugCurrentCF
                                    end)
                                    myR.Velocity = Vector3.zero
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Hug()
                end
                do
                    local function _TLact_Hug2()
                        do
                            local hug2Conn      = nil
                            local hug2Target    = nil
                            local hug2BodyPos   = nil
                            local hug2AnimTrack = nil
                            local hug2AnimConn  = nil
                            local hug2CharConn  = nil
                            local HUG2_ANIM_ID  = "101809619267911"
                            local function hug2StopAnim()
                                if hug2AnimConn then
                                    hug2AnimConn:Disconnect(); hug2AnimConn = nil
                                end
                                if hug2CharConn then
                                    hug2CharConn:Disconnect(); hug2CharConn = nil
                                end
                                if hug2AnimTrack then
                                    pcall(function()
                                        hug2AnimTrack:AdjustSpeed(1); hug2AnimTrack:Stop()
                                    end)
                                    hug2AnimTrack = nil
                                end
                            end
                            local function hug2PlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, HUG2_ANIM_ID, "Hug2Anim")
                                if not track then return end
                                setFreeze(true)
                                hug2AnimTrack = track
                                if hug2AnimConn then hug2AnimConn:Disconnect() end
                                hug2AnimConn = track.Stopped:Connect(function()
                                    if _AF.hug2Active then
                                        task.wait(0.05)
                                        if _AF.hug2Active then pcall(function() hug2PlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function hug2StartAnim()
                                hug2StopAnim()
                                task.spawn(function() hug2PlayAnim(LocalPlayer.Character) end)
                                hug2CharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.hug2Active then
                                        task.wait(0.5); task.spawn(function() hug2PlayAnim(char) end)
                                    end
                                end)
                            end
                            stopHug2 = function()
                                _AF.hug2Active = false; hug2Target = nil
                                if hug2Conn then
                                    pcall(function() hug2Conn:Disconnect() end); hug2Conn = nil
                                end
                                if hug2BodyPos then
                                    pcall(function() hug2BodyPos:Destroy() end); hug2BodyPos = nil
                                end
                                hug2StopAnim()
                                pcall(function()
                                    local myR = LocalPlayer.Character and
                                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if myR then myR.Anchored = false end
                                end)
                                setFreeze(false)
                                safeStand()
                            end
                            startHug2 = function(targetPlayer)
                                stopHug2()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Hug 2", "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif("Hug 2", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid()
                                if hum then
                                    hum.PlatformStand = true
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                _AF.hug2Active = true; hug2Target = targetPlayer
                                sendNotif("Hug 2", "Hugging " .. targetPlayer.Name .. " from behind 🤗", 3)
                                hug2StartAnim()
                                myRoot.Velocity = Vector3.zero
                                myRoot.CFrame = tgtTorso.CFrame * CFrame.new(0, 0, 1.1)
                                hug2Conn = _RSConnect(function(dt)
                                    if not _AF.hug2Active then return end
                                    local tc    = hug2Target and hug2Target.Character
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR  = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", torso)
                                    myR.Velocity = Vector3.zero
                                    myR.CFrame = torso.CFrame * CFrame.new(0, 0, 1.1)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function()
                                        if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                                            h2:ChangeState(Enum.HumanoidStateType.Physics)
                                        end
                                    end)
                                end)
                            end
                        end
                    end
                    _TLact_Hug2()
                end
                do
                    local function _TLact_Carry()
                        do
                            local carryConn      = nil
                            local carryTarget    = nil
                            local carryBodyPos   = nil
                            local carryAnimTrack = nil
                            local carryAnimConn  = nil
                            local carryCharConn  = nil
                            local CARRY_ANIM_ID  = "95469914338674"
                            local function carryStopAnim()
                                if carryAnimConn then
                                    carryAnimConn:Disconnect(); carryAnimConn = nil
                                end
                                if carryCharConn then
                                    carryCharConn:Disconnect(); carryCharConn = nil
                                end
                                if carryAnimTrack then
                                    pcall(function()
                                        carryAnimTrack:AdjustSpeed(1); carryAnimTrack:Stop()
                                    end)
                                    carryAnimTrack = nil
                                end
                            end
                            local function carryPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, CARRY_ANIM_ID, "CarryAnim")
                                if not track then return end
                                setFreeze(true)
                                carryAnimTrack = track
                                if carryAnimConn then carryAnimConn:Disconnect() end
                                carryAnimConn = track.Stopped:Connect(function()
                                    if _AF.carryActive then
                                        task.wait(0.05)
                                        if _AF.carryActive then pcall(function() carryPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function carryStartAnim()
                                carryStopAnim()
                                task.spawn(function() carryPlayAnim(LocalPlayer.Character) end)
                                carryCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.carryActive then
                                        task.wait(0.5); task.spawn(function() carryPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopCarry = function()
                                _AF.carryActive = false; carryTarget = nil
                                if carryConn then
                                    carryConn:Disconnect(); carryConn = nil
                                end
                                if carryBodyPos then
                                    pcall(function() carryBodyPos:Destroy() end); carryBodyPos = nil
                                end
                                carryStopAnim()
                                setFreeze(false)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startCarry = function(targetPlayer)
                                stopCarry()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("Carry", "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif("Carry", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local oscTime = 0
                                local CARRY_SPEED = 10.0
                                _AF.carryActive = true; carryTarget = targetPlayer
                                sendNotif("Carry", "💪 Carrying " .. targetPlayer.Name, 3)
                                carryStartAnim()
                                myRoot.Velocity = Vector3.zero
                                myRoot.CFrame = tgtTorso.CFrame * CFrame.new(0.5, -0.5, -1.2)
                                carryConn = _RSConnect(function(dt)
                                    if not _AF.carryActive then return end
                                    local tc    = carryTarget and carryTarget.Character
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tgtRoot)
                                    oscTime = oscTime + dt * CARRY_SPEED
                                    myR.Velocity = Vector3.zero
                                    myR.CFrame = torso.CFrame
                                        * CFrame.new(0.5, -0.5, -1.2)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Carry()
                end
                do
                    local function _TLact_ShoulderSit()
                        do
                            local ssConn             = nil
                            local ssTarget           = nil
                            local ssBodyPos          = nil
                            local ssAnimTrack        = nil
                            local ssAnimConn         = nil
                            local ssCharConn         = nil
                            local SS_DEFAULT_ANIM_ID = "119898270336796"
                            local SS_ANIM_ID         = SS_DEFAULT_ANIM_ID
                            local function ssStopAnim()
                                if ssAnimConn then
                                    ssAnimConn:Disconnect(); ssAnimConn = nil
                                end
                                if ssCharConn then
                                    ssCharConn:Disconnect(); ssCharConn = nil
                                end
                                if ssAnimTrack then
                                    pcall(function()
                                        ssAnimTrack:AdjustSpeed(1); ssAnimTrack:Stop()
                                    end)
                                    ssAnimTrack = nil
                                end
                            end
                            local function ssPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, SS_ANIM_ID, "SSAnim")
                                if not track then return end
                                setFreeze(true)
                                ssAnimTrack = track
                                if ssAnimConn then ssAnimConn:Disconnect() end
                                ssAnimConn = track.Stopped:Connect(function()
                                    if _AF.shoulderSitActive then
                                        task.wait(0.05)
                                        if _AF.shoulderSitActive then pcall(function() ssPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function ssStartAnim()
                                ssStopAnim()
                                task.spawn(function() ssPlayAnim(LocalPlayer.Character) end)
                                ssCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.shoulderSitActive then
                                        task.wait(0.5); task.spawn(function() ssPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopShoulderSit = function()
                                _AF.shoulderSitActive = false; ssTarget = nil
                                if ssConn then
                                    ssConn:Disconnect(); ssConn = nil
                                end
                                if ssBodyPos then
                                    pcall(function() ssBodyPos:Destroy() end); ssBodyPos = nil
                                end
                                ssStopAnim()
                                setFreeze(false)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startShoulderSit = function(targetPlayer, animId, displayName)
                                stopShoulderSit()
                                SS_ANIM_ID       = tostring(animId or SS_DEFAULT_ANIM_ID)
                                local ssTitle    = displayName or "Shouldersit"
                                local ssOffset   = (ssTitle == "Carry on shoulder") and CFrame.new(1.8, 0.2, 1) or
                                CFrame.new(1.8, 2.2, 0)
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif(ssTitle, "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif(ssTitle, "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local oscTime = 0
                                local SS_SPEED = 10.0
                                _AF.shoulderSitActive = true; ssTarget = targetPlayer
                                sendNotif(ssTitle, ssTitle .. ": " .. targetPlayer.Name, 3)
                                ssStartAnim()
                                myRoot.Velocity = Vector3.zero
                                myRoot.CFrame = tgtTorso.CFrame * ssOffset * CFrame.Angles(0, 0, 0)
                                ssConn = _RSConnect(function(dt)
                                    if not _AF.shoulderSitActive then return end
                                    local tc    = ssTarget and ssTarget.Character
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tgtRoot)
                                    oscTime = oscTime + dt * SS_SPEED
                                    myR.Velocity = Vector3.zero
                                    myR.CFrame = torso.CFrame
                                        * ssOffset
                                        * CFrame.Angles(0, 0, 0)
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_ShoulderSit()
                end
                do
                    local function _TLact_Stand()
                        do
                            local standConn             = nil
                            local standTarget           = nil
                            local standBodyPos          = nil
                            local standAnimTrack        = nil
                            local standAnimConn         = nil
                            local standCharConn         = nil
                            local STAND_DEFAULT_ANIM_ID = "133594786690861"
                            local STAND_ANIM_ID         = STAND_DEFAULT_ANIM_ID
                            standStopAnim               = function()
                                if standAnimConn then
                                    standAnimConn:Disconnect(); standAnimConn = nil
                                end
                                if standCharConn then
                                    standCharConn:Disconnect(); standCharConn = nil
                                end
                                if standAnimTrack then
                                    pcall(function()
                                        standAnimTrack:AdjustSpeed(1); standAnimTrack:Stop()
                                    end)
                                    standAnimTrack = nil
                                end
                            end
                            local function standPlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = _AF_getReliableActionTrack(hum, STAND_ANIM_ID, "StandAnim")
                                if not track then return end
                                setFreeze(true)
                                standAnimTrack = track
                                if standAnimConn then standAnimConn:Disconnect() end
                                standAnimConn = track.Stopped:Connect(function()
                                    if _AF.standActive or (_AF.bbActive and (_AF.bbMode == "bb_stand" or _AF.bbMode == "bb_headstand")) then
                                        task.wait(0.05)
                                        if _AF.standActive or (_AF.bbActive and (_AF.bbMode == "bb_stand" or _AF.bbMode == "bb_headstand")) then
                                            pcall(function() standPlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            standSetAnim = function(animId)
                                STAND_ANIM_ID = tostring(animId or STAND_DEFAULT_ANIM_ID)
                            end
                            standStartAnim = function()
                                standStopAnim()
                                task.spawn(function() standPlayAnim(LocalPlayer.Character) end)
                                standCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.standActive or (_AF.bbActive and (_AF.bbMode == "bb_stand" or _AF.bbMode == "bb_headstand")) then
                                        task.wait(0.5); task.spawn(function() standPlayAnim(char) end)
                                    end
                                end)
                            end
                            stopStand = function()
                                _AF.standActive = false; standTarget = nil
                                if standConn then
                                    standConn:Disconnect(); standConn = nil
                                end
                                if standBodyPos then
                                    pcall(function() standBodyPos:Destroy() end); standBodyPos = nil
                                end
                                standStopAnim()
                                setFreeze(false)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        if myRoot then
                                            myRoot.AssemblyLinearVelocity = Vector3.zero
                                            myRoot.AssemblyAngularVelocity = Vector3.zero
                                            local rayOrigin = myRoot.Position + Vector3.new(0, 2, 0)
                                            local rayDir = Vector3.new(0, -50, 0)
                                            local rayParams = RaycastParams.new()
                                            rayParams.FilterDescendantsInstances = {_lpc}
                                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                            local rayResult = workspace:Raycast(rayOrigin, rayDir, rayParams)
                                            if rayResult then
                                                myRoot.CFrame = CFrame.new(
                                                    Vector3.new(myRoot.Position.X, rayResult.Position.Y + 3, myRoot.Position.Z)
                                                ) * myRoot.CFrame.Rotation
                                            end
                                        end
                                    end)
                                end
                            end
                            startStand = function(targetPlayer, animId, displayName, standOffset)
                                stopStand()
                                standSetAnim(animId)
                                local standTitle   = displayName or "Stand"
                                local followOffset = standOffset or CFrame.new(-0.8, 2, 2.2)
                                local myChar       = LocalPlayer.Character
                                local targetChar   = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif(standTitle, "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif(standTitle, "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                _AF.standActive = true; standTarget = targetPlayer
                                sendNotif(standTitle, standTitle .. ": " .. targetPlayer.Name, 3)
                                standStartAnim()
                                standConn = _RSConnect(function(dt)
                                    if not _AF.standActive then return end
                                    local tc    = standTarget and standTarget.Character
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", tgtRoot)
                                    myR.Velocity = Vector3.zero
                                    myR.CFrame = torso.CFrame * followOffset
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_Stand()
                end
                do
                    local function _TLact_QA74()
                        do
                            local qa74Conn      = nil
                            local qa74Target    = nil
                            local qa74AnimTrack = nil
                            local qa74AnimConn  = nil
                            local qa74CharConn  = nil
                            local QA74_ANIM_ID  = "74402438715168"
                            local function qa74StopAnim()
                                if qa74AnimConn then
                                    qa74AnimConn:Disconnect(); qa74AnimConn = nil
                                end
                                if qa74CharConn then
                                    qa74CharConn:Disconnect(); qa74CharConn = nil
                                end
                                if qa74AnimTrack then
                                    pcall(function()
                                        qa74AnimTrack:AdjustSpeed(1); qa74AnimTrack:Stop()
                                    end)
                                    qa74AnimTrack = nil
                                end
                            end
                            local function qa74PlayAnim(char)
                                if not char then return end
                                local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
                                local track = nil
                                local emoteId = tonumber(QA74_ANIM_ID)
                                pcall(function()
                                    local desc = hum:FindFirstChildOfClass("HumanoidDescription")
                                    if not desc then desc = hum:WaitForChild("HumanoidDescription", 3) end
                                    if desc then
                                        desc:AddEmote("QA74Anim", emoteId)
                                        track = hum:PlayEmoteAndGetAnimTrackById(emoteId)
                                    end
                                end)
                                if not track then
                                    pcall(function() track = hum:PlayEmoteAndGetAnimTrackById(emoteId) end)
                                end
                                if not track then
                                    pcall(function()
                                        track = _AF_loadAndPlayAnimation(hum, QA74_ANIM_ID)
                                        if track then track:Play() end
                                    end)
                                end
                                if not track or type(track) ~= "userdata" then return end
                                setFreeze(true)
                                qa74AnimTrack = track
                                if qa74AnimConn then qa74AnimConn:Disconnect() end
                                qa74AnimConn = track.Stopped:Connect(function()
                                    if _AF.qa74Active then
                                        task.wait(0.05)
                                        if _AF.qa74Active then pcall(function() qa74PlayAnim(LocalPlayer.Character) end) end
                                    end
                                end)
                            end
                            local function qa74StartAnim()
                                qa74StopAnim()
                                task.spawn(function() qa74PlayAnim(LocalPlayer.Character) end)
                                qa74CharConn = LocalPlayer.CharacterAdded:Connect(function(char)
                                    if _AF.qa74Active then
                                        task.wait(0.5); task.spawn(function() qa74PlayAnim(char) end)
                                    end
                                end)
                            end
                            stopQA74 = function()
                                _AF.qa74Active = false; qa74Target = nil
                                if qa74Conn then
                                    qa74Conn:Disconnect(); qa74Conn = nil
                                end
                                if qa74BodyPos then
                                end
                                qa74StopAnim()
                                setFreeze(false)
                                local hum = getHumanoid(); if hum and not flyActive then
                                    hum.PlatformStand = false; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, true) end)
                                end
                                if not flyActive then
                                    pcall(function()
                                        local _lpc = LocalPlayer.Character
                                        local myRoot = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                        pcall(function() if myRoot then myRoot.Velocity = Vector3.zero end end)
                                    end)
                                end
                            end
                            startQA74 = function(targetPlayer)
                                stopQA74()
                                local myChar     = LocalPlayer.Character
                                local targetChar = targetPlayer and targetPlayer.Character
                                if not myChar or not targetChar then
                                    sendNotif("QA74", "No character!", 2); return
                                end
                                local myRoot   = myChar:FindFirstChild("HumanoidRootPart")
                                local tgtRoot  = targetChar:FindFirstChild("HumanoidRootPart")
                                local tgtTorso = targetChar:FindFirstChild("UpperTorso") or
                                targetChar:FindFirstChild("Torso")
                                if not myRoot or not tgtRoot or not tgtTorso then
                                    sendNotif("QA74", "Missing parts!", 2); return
                                end
                                local hum = getHumanoid(); if hum then
                                    hum.PlatformStand = true; pcall(function() hum:SetStateEnabled(
                                        Enum.HumanoidStateType.Seated, false) end)
                                end
                                pcall(function()
                                    local myR = getRootPart(); if myR then myR:SetNetworkOwner(LocalPlayer) end
                                end)
                                pcall(sethiddenproperty, myRoot, "PhysicsRepRootPart", tgtRoot)
                                local oscTime = 0
                                local QA74_SPEED = 10.0
                                _AF.qa74Active = true; qa74Target = targetPlayer
                                sendNotif("Animation", "🎬 Playing near " .. targetPlayer.Name, 3)
                                qa74StartAnim()
                                myRoot.Velocity = Vector3.zero
                                myRoot.CFrame = tgtTorso.CFrame * CFrame.new(0, 0, -1.1) * _CF_ROT180Y
                                qa74Conn = _RSConnect(function(dt)
                                    if not _AF.qa74Active then return end
                                    local tc    = qa74Target and qa74Target.Character
                                    local torso = tc and (tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("Torso"))
                                    if not torso or not torso.Parent then return end
                                    local _myC = LocalPlayer.Character
                                    local myR = _myC and _myC:FindFirstChild("HumanoidRootPart")
                                    if not myR then return end
                                    pcall(sethiddenproperty, myR, "PhysicsRepRootPart", torso)
                                    oscTime = oscTime + dt * QA74_SPEED
                                        local offset = -1.1 - math.sin(oscTime) * 0.2
                                        myR.Velocity = Vector3.zero
                                        myR.CFrame = torso.CFrame * CFrame.new(0, 0, offset) * _CF_ROT180Y
                                    for _, _6_ in ipairs(_myC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local h2 = _myC and _myC:FindFirstChildOfClass("Humanoid")
                                    if h2 then h2.PlatformStand = true end
                                    pcall(function() if h2:GetState() == Enum.HumanoidStateType.Seated then
                                            h2:SetStateEnabled(Enum.HumanoidStateType.Seated, false); h2:ChangeState(
                                            Enum.HumanoidStateType.Physics)
                                        end end)
                                end)
                            end
                        end
                    end
                    _TLact_QA74()
                end
                do
                    local function _TLact_Orbit()
                        do
                            local orbitConn           = nil
                            local orbitTarget_        = nil
                            local orbitTargetRespConn = nil
                            local orbitBodyPos        = nil
                            stopOrbit                 = function()
                                if orbitConn then
                                    orbitConn:Disconnect(); orbitConn = nil
                                end
                                if orbitTargetRespConn then
                                    orbitTargetRespConn:Disconnect(); orbitTargetRespConn = nil
                                end
                                _AF.orbitActive = false; orbitTarget_ = nil

                                local myChar    = LocalPlayer.Character
                                local hrp       = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                local hum       = myChar and myChar:FindFirstChildOfClass("Humanoid")

                                if hrp then
                            pcall(function() sethiddenproperty(hrp, "PhysicsRepRootPart", nil) end)
                            
                            pcall(function()
                                if raknet and _bbRakHooked and _bbRakHookFn then
                                    raknet.remove_send_hook(_bbRakHookFn)
                                    _bbRakHooked = false
                                    _bbRakHookFn = nil
                                end
                            end)
                                    hrp.Anchored = false
                                    hrp.Velocity = Vector3.zero
                                    if orbitBodyPos then
                                        pcall(function() orbitBodyPos:Destroy() end); orbitBodyPos = nil
                                    end
                                    
                                    pcall(function()
                                        for _, o in ipairs(hrp:GetChildren()) do
                                            if o:IsA("BodyVelocity") or o:IsA("BodyPosition") or o:IsA("BodyGyro") then o
                                                    :Destroy() end
                                        end
                                    end)
                                end

                                if hum then
                                    workspace.CurrentCamera.CameraSubject = hum
                                    if not flyActive then hum.PlatformStand = false end
                                    hum.WalkSpeed = 16
                                    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
                                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                                end

                                pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
                                sendNotif("Orbit TP", T.qa_stopped, 1)
                                safeStand()

                                
                                task.delay(0.1, function()
                                    local c2 = LocalPlayer.Character
                                    local r2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                                    local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
                                    if r2 then
                                        pcall(function() sethiddenproperty(r2, "PhysicsRepRootPart", nil) end)
                                        r2.Velocity = Vector3.zero
                                    end
                                    if h2 then
                                        if not flyActive then h2.PlatformStand = false end
                                        h2:ChangeState(Enum.HumanoidStateType.Running)
                                    end
                                    pcall(safeStand)
                                end)
                            end
                            startOrbit                = function(targetPlayer)
                                stopOrbit()
                                if not targetPlayer or not targetPlayer.Character then
                                    sendNotif("Orbit TP", T.gb_no_target_char, 2); return
                                end
                                local myChar = LocalPlayer.Character
                                if not myChar then
                                    sendNotif("Orbit TP", T.gb_no_own_char, 2); return
                                end
                                local hrp = myChar:FindFirstChild("HumanoidRootPart")
                                local hum = myChar:FindFirstChildOfClass("Humanoid")
                                if not hrp or not hum then
                                    sendNotif("Orbit TP", "Missing HRP/Hum!", 2); return
                                end
                                _AF.orbitActive = true
                                orbitTarget_    = targetPlayer
                                local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                                if targetHum then workspace.CurrentCamera.CameraSubject = targetHum end
                                local initHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if initHRP then
                                    hrp.CFrame = initHRP.CFrame * CFrame.new(math.random(-3, 3), 2, 5)
                                end
                                hum.PlatformStand = true
                                pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
                                pcall(sethiddenproperty, hrp, "PhysicsRepRootPart", initHRP)
                                hum.WalkSpeed            = 0
                                local ORBIT_NEAR         = 2.2
                                local ORBIT_FAR          = 6.5
                                local ORBIT_BREATH_SPEED = 0.35
                                local orbitSpeed         = 35
                                local phase              = 0
                                local breathPhase        = 0
                                local directionFlipTimer = 0
                                local flipInterval       = 0.08
                                local function makeOrbitConn()
                                    if orbitConn then orbitConn:Disconnect() end
                                    phase = 0; breathPhase = 0; directionFlipTimer = 0
                                    local slowPhase = 0
                                    local _orbitVelAcc = 0
                                    local _orCC = LocalPlayer.Character
                                    local _orMH = _orCC and _orCC:FindFirstChild("HumanoidRootPart")
                                    local _orTC = orbitTarget_ and orbitTarget_.Character
                                    local _orTH = _orTC and _orTC:FindFirstChild("HumanoidRootPart")
                                    orbitConn = RunService.Heartbeat:Connect(function(dt)
                                        if not _AF.orbitActive then return end
                                        local myChar = LocalPlayer.Character
                                        if myChar ~= _orCC then
                                            _orCC = myChar
                                            _orMH = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                        end
                                        local tChar = orbitTarget_ and orbitTarget_.Character
                                        if tChar ~= _orTC then
                                            _orTC = tChar
                                            _orTH = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                        end
                                        local tHRP = _orTH
                                        local myHRP = _orMH
                                        if not tHRP or not tHRP.Parent or not myHRP or not myHRP.Parent then return end
                                        local center = tHRP.Position
                                        phase = phase + dt * orbitSpeed * math.pi * 2
                                        breathPhase = breathPhase + dt * ORBIT_BREATH_SPEED * math.pi * 2
                                        local breathT = (math.sin(breathPhase) + 1) * 0.5
                                        local orbitRadius = ORBIT_NEAR + (ORBIT_FAR - ORBIT_NEAR) * breathT
                                        local cosP = _mcos(phase)
                                        local sinP = _msin(phase)
                                        local offset = _V3new(cosP * orbitRadius, 2.5 + _msin(phase * 3) * 1.5,
                                            sinP * orbitRadius)
                                        local targetPos = center + offset
                                        local dist = (myHRP.Position - center).Magnitude
                                        if dist > 30 then
                                            myHRP.CFrame = CFrame.new(center +
                                            Vector3.new(_mrandom(-3, 3), 1.5, _mrandom(-3, 3)))
                                            pcall(function() myHRP.AssemblyLinearVelocity = Vector3.zero end)
                                            return
                                        end
                                        local toCenter     = (center - myHRP.Position).Unit
                                        local tangent      = Vector3.new(-toCenter.Z, 0, toCenter.X).Unit
                                        local velocityDir  = tangent * (orbitSpeed * orbitRadius * 4)
                                        directionFlipTimer = directionFlipTimer + dt
                                        if directionFlipTimer > flipInterval then
                                            velocityDir        = -velocityDir
                                            directionFlipTimer = 0
                                            flipInterval       = _mrandom(8, 15) * 0.01
                                        end
                                        pcall(function() myHRP.AssemblyLinearVelocity = velocityDir +
                                            (targetPos - myHRP.Position) * 10 end)
                                        myHRP.CFrame = CFrame.lookAt(myHRP.Position, center)
                                        slowPhase = slowPhase + dt * 0.9
                                        local camOffset = Vector3.new(
                                            _mcos(slowPhase) * (orbitRadius + 1.5),
                                            2.5,
                                            _msin(slowPhase) * (orbitRadius + 1.5)
                                        )
                                        local cam = _workspace.CurrentCamera
                                        if cam then
                                            if cam.CameraType ~= Enum.CameraType.Scriptable then
                                                cam.CameraType = Enum.CameraType.Scriptable
                                            end
                                            cam.CFrame = _CFlookAt(center + camOffset, center + Vector3.new(0, 1, 0))
                                        end
                                        _orbitVelAcc = (_orbitVelAcc or 0) + dt
                                        if _orbitVelAcc >= 0.06 then
                                            _orbitVelAcc = 0
                                            if _AF.orbitActive then
                                                local _lpc2 = LocalPlayer.Character
                                                local h = _lpc2 and _lpc2:FindFirstChild("HumanoidRootPart")
                                                pcall(function() if h then h.AssemblyLinearVelocity = velocityDir * 0.8 end end)
                                            end
                                        end
                                    end)
                                end
                                makeOrbitConn()
                                orbitTargetRespConn = targetPlayer.CharacterAdded:Connect(function(newChar)
                                    task.wait(0.5)
                                    if not _AF.orbitActive then return end
                                    local newHRP = newChar:FindFirstChild("HumanoidRootPart")
                                    local _lpc = LocalPlayer.Character
                                    local myHRP2 = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                    if newHRP and myHRP2 then
                                        myHRP2.CFrame = newHRP.CFrame * CFrame.new(math.random(-3, 3), 0, 5)
                                        pcall(function() myHRP2.AssemblyLinearVelocity = Vector3.zero end)
                                    end
                                    sendNotif("Orbit TP", T.orbit_respawn, 2)
                                    makeOrbitConn()
                                end)
                                sendNotif("Orbit TP", "🔄 Orbit: " .. targetPlayer.Name, 3)
                            end
                        end
                    end
                    _TLact_Orbit()
                end
                do
                    local function _TLact_Ghost()
                        do
                            local ghostConn          = nil
                            local ghostRespConn      = nil
                            local ghostHealthConn    = nil
                            local ghostTarget_       = nil
                            local GHOST_DEPTH        = -15
                            local GHOST_FOLLOW_SPEED = 12
                            stopGhost                = function()
                                local lastTargetPos = nil
                                if ghostTarget_ and ghostTarget_.Character then
                                    local tHRP = ghostTarget_.Character:FindFirstChild("HumanoidRootPart")
                                    if tHRP then lastTargetPos = tHRP.Position end
                                end
                                if ghostConn then
                                    ghostConn:Disconnect(); ghostConn = nil
                                end
                                if ghostRespConn then
                                    ghostRespConn:Disconnect(); ghostRespConn = nil
                                end
                                if ghostHealthConn then
                                    ghostHealthConn:Disconnect(); ghostHealthConn = nil
                                end
                                _AF.ghostActive = false; ghostTarget_ = nil
                                local myChar = LocalPlayer.Character
                                if myChar then
                                    local hrp = myChar:FindFirstChild("HumanoidRootPart")
                                    local hum = myChar:FindFirstChildOfClass("Humanoid")
                                    if hrp then
                                        hrp.Anchored = false
                                        hrp.AssemblyLinearVelocity = Vector3.zero
                                        task.spawn(function()
                                            task.wait(0.05)
                                            local originX              = lastTargetPos and lastTargetPos.X or
                                            hrp.Position.X
                                            local originZ              = lastTargetPos and lastTargetPos.Z or
                                            hrp.Position.Z
                                            local rayO = Vector3.new(originX, originZ and (hrp.Position.Y + 10) or (lastTargetPos and lastTargetPos.Y + 10 or 10), originZ)
                                            local rayD = Vector3.new(0, -60, 0)
                                            local rayP = RaycastParams.new()
                                            rayP.FilterDescendantsInstances = {myChar}
                                            rayP.FilterType = Enum.RaycastFilterType.Exclude
                                            local rayR = workspace:Raycast(rayO, rayD, rayP)
                                            local safeY = rayR and (rayR.Position.Y + 3) or (lastTargetPos and (lastTargetPos.Y + 1) or 1)
                                            hrp.CFrame                 = CFrame.new(originX, safeY, originZ)
                                            hrp.AssemblyLinearVelocity = Vector3.zero
                                        end)
                                    end
                                    if hum then
                                        if not flyActive then hum.PlatformStand = false end
                                        hum.WalkSpeed = 16
                                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                                    end
                                end
                                local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                                pcall(function()
                                    workspace.CurrentCamera.CameraSubject = myHum or
                                    (myChar and myChar:FindFirstChild("HumanoidRootPart"))
                                    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                                end)
                                sendNotif("Ghost", T.qa_stopped, 1)
                            end
                            startGhost               = function(targetPlayer)
                                stopGhost()
                                if not targetPlayer or not targetPlayer.Character then
                                    sendNotif("Ghost", T.gb_no_target_char, 2); return
                                end
                                local myChar = LocalPlayer.Character
                                if not myChar then
                                    sendNotif("Ghost", T.gb_no_own_char, 2); return
                                end
                                local hrp = myChar:FindFirstChild("HumanoidRootPart")
                                local hum = myChar:FindFirstChildOfClass("Humanoid")
                                if not hrp or not hum then
                                    sendNotif("Ghost", T.gb_missing_parts, 2); return
                                end
                                local tChar = targetPlayer.Character
                                local initHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                if not initHRP then
                                    sendNotif("Ghost", T.gb_no_target_char, 2); return
                                end
                                _AF.ghostActive = true
                                ghostTarget_    = targetPlayer
                                pcall(sethiddenproperty, hrp, "PhysicsRepRootPart", initHRP)
                                hrp.CFrame = CFrame.new(initHRP.Position.X, GHOST_DEPTH, initHRP.Position.Z)
                                hum.PlatformStand = true
                                hum.WalkSpeed     = 0
                                pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
                                ghostHealthConn = hum.HealthChanged:Connect(function(newHealth)
                                    if not _AF.ghostActive then return end
                                    if newHealth <= 0 then
                                        hum.Health = hum.MaxHealth
                                    end
                                end)
                                local cam = workspace.CurrentCamera
                                if cam then
                                    cam.CameraSubject = targetPlayer.Character and
                                        (targetPlayer.Character:FindFirstChildOfClass("Humanoid") or
                                            targetPlayer.Character:FindFirstChild("HumanoidRootPart"))
                                    cam.CameraType = Enum.CameraType.Follow
                                end
                                local ghostStateTick = 0
                                local _ghostCamAcc = 0
                                local _ghCC = LocalPlayer.Character
                                local _ghMH = _ghCC and _ghCC:FindFirstChild("HumanoidRootPart")
                                local _ghHm = _ghCC and _ghCC:FindFirstChildOfClass("Humanoid")
                                local _ghTC = ghostTarget_ and ghostTarget_.Character
                                local _ghTH = _ghTC and _ghTC:FindFirstChild("HumanoidRootPart")
                                ghostConn = RunService.Heartbeat:Connect(function(dt)
                                    if not _AF.ghostActive then return end
                                    local myChar2 = LocalPlayer.Character
                                    if myChar2 ~= _ghCC then
                                        _ghCC = myChar2; _ghMH = myChar2 and myChar2:FindFirstChild("HumanoidRootPart")
                                        _ghHm = myChar2 and myChar2:FindFirstChildOfClass("Humanoid")
                                    end
                                    local tChar = ghostTarget_ and ghostTarget_.Character
                                    if tChar ~= _ghTC then
                                        _ghTC = tChar; _ghTH = tChar and tChar:FindFirstChild("HumanoidRootPart")
                                    end
                                    local tHRP  = _ghTH; local myHRP = _ghMH
                                    if not tHRP or not tHRP.Parent or not myHRP or not myHRP.Parent then return end
                                    pcall(sethiddenproperty, myHRP, "PhysicsRepRootPart", tHRP)
                                    for _, _6_ in ipairs(_ghCC:GetDescendants()) do if _6_:IsA("BasePart") then _6_.CanCollide = false end end
                                    local myHum2 = _ghHm
                                    local targetPos = Vector3.new(tHRP.Position.X, GHOST_DEPTH, tHRP.Position.Z)
                                    local delta = targetPos - myHRP.Position
                                    pcall(function() myHRP.AssemblyLinearVelocity = delta * GHOST_FOLLOW_SPEED end)
                                    _ghostCamAcc = _ghostCamAcc + dt
                                    if _ghostCamAcc >= 0.5 then
                                        _ghostCamAcc = 0
                                        local cam2 = _workspace.CurrentCamera
                                        if cam2 then
                                            if cam2.CameraType ~= Enum.CameraType.Follow then
                                                cam2.CameraType = Enum.CameraType.Follow
                                            end
                                            if tChar then
                                                local camSubject = tChar:FindFirstChildOfClass("Humanoid") or tHRP
                                                if cam2.CameraSubject ~= camSubject then
                                                    cam2.CameraSubject = camSubject
                                                end
                                            end
                                        end
                                    end
                                    if myHum2 then
                                        if not myHum2.PlatformStand then myHum2.PlatformStand = true end
                                        if myHum2.Health < myHum2.MaxHealth then myHum2.Health = myHum2.MaxHealth end
                                        ghostStateTick = ghostStateTick + dt
                                        if ghostStateTick >= 0.5 then
                                            ghostStateTick = 0
                                            pcall(function() myHum2:ChangeState(Enum.HumanoidStateType.Physics) end)
                                        end
                                    end
                                end)
                                ghostRespConn = targetPlayer.CharacterAdded:Connect(function(newChar)
                                    task.wait(0.5)
                                    if not _AF.ghostActive then return end
                                    local newHRP = newChar:FindFirstChild("HumanoidRootPart")
                                    local _lpc = LocalPlayer.Character
                                    local myHRP2 = _lpc and _lpc:FindFirstChild("HumanoidRootPart")
                                    if newHRP and myHRP2 then
                                        myHRP2.CFrame = CFrame.new(newHRP.Position.X, GHOST_DEPTH, newHRP.Position.Z)
                                        pcall(function() myHRP2.AssemblyLinearVelocity = Vector3.zero end)
                                    end
                                    local cam3 = workspace.CurrentCamera
                                    if cam3 then
                                        cam3.CameraSubject = newChar:FindFirstChildOfClass("Humanoid") or newHRP
                                        cam3.CameraType = Enum.CameraType.Follow
                                    end
                                end)
                                local ghostPlayerRemConn
                                ghostPlayerRemConn = Players.PlayerRemoving:Connect(function(pl)
                                    if pl == ghostTarget_ and _AF.ghostActive then
                                        ghostPlayerRemConn:Disconnect()
                                        stopGhost()
                                        sendNotif("Ghost", "👻 " .. pl.Name .. " has left", 2)
                                    end
                                end)
                                sendNotif("Ghost", "👻 Ghost: " .. targetPlayer.Name, 3)
                            end
                        end
                    end
                    _TLact_Ghost()
                end
                do
                    local _genv = getgenv and getgenv()
                    if _genv then
                        rawset(_genv, "_TL_AF", _AF)
                        rawset(_genv, "_TL_SOH", _SOH)
                        rawset(_genv, "_TL_act_stopFollow", _act_stopFollow)
                        rawset(_genv, "_TL_stopGhost", stopGhost)
                        rawset(_genv, "_TL_startGhost", startGhost)
                        rawset(_genv, "_TL_stopSitOnHead", stopSitOnHead)
                        rawset(_genv, "_TL_stopPiggyback", stopPiggyback)
                        rawset(_genv, "_TL_stopPiggyback2", stopPiggyback2)
                        rawset(_genv, "_TL_stopKiss", stopKiss)
                        rawset(_genv, "_TL_stopBackpack", stopBackpack)
                        rawset(_genv, "_TL_stopOrbit", stopOrbit)
                        rawset(_genv, "_TL_stopUpsideDown", stopUpsideDown)
                        rawset(_genv, "_TL_stopCrossUD", stopCrossUD)
                        rawset(_genv, "_TL_stopFriend", stopFriend)
                        rawset(_genv, "_TL_stopSpinning", stopSpinning)
                        rawset(_genv, "_TL_stopLicking", stopLicking)
                        rawset(_genv, "_TL_stopSucking", stopSucking)
                        rawset(_genv, "_TL_stopSuckIt", stopSuckIt)
                        rawset(_genv, "_TL_stopBackshots", stopBackshots)
                        rawset(_genv, "_TL_stopDoggy", stopDoggy)
                        rawset(_genv, "_TL_stopLayFuck", stopLayFuck)
                        rawset(_genv, "_TL_stopFacefuck", stopFacefuck)
                        rawset(_genv, "_TL_stopPussySpread", stopPussySpread)
                        rawset(_genv, "_TL_stopHug", stopHug)
                        rawset(_genv, "_TL_stopHug2", stopHug2)
                        rawset(_genv, "_TL_stopCarry", stopCarry)
                        rawset(_genv, "_TL_stopShoulderSit", stopShoulderSit)
                    end
                end
            end 
            
            do
                local _bbMod = _TL_loadModule("SCRIPTS-TAB/TL-ByteBreaker")
                if _bbMod then
                    _bbMod.initBB({
                        _AF = _AF,
                        _AF_getReliableActionTrack = _AF_getReliableActionTrack,
                        LocalPlayer = LocalPlayer,
                        RunService = RunService,
                        Players = Players,
                        sethiddenproperty = sethiddenproperty,
                        flyActive = function() return flyActive end,
                        setFreeze = setFreeze,
                        getHumanoid = getHumanoid,
                        sendNotif = sendNotif,
                        T = T,
                        _TL_refs = _TL_refs,
                        _tlTrackConn = _tlTrackConn,
                        safeStand = safeStand,
                        standStartAnim = function(...) if type(_G.standStartAnim) == "function" then _G.standStartAnim(...) end end,
                        standSetAnim = function(...) if type(_G.standSetAnim) == "function" then _G.standSetAnim(...) end end,
                        raknet = raknet,
                        V3_ZERO = _V3_ZERO,
                        CF_ROT180Y = _CF_ROT180Y,
                        PIGGYBACK_ANIM_ID = PIGGYBACK_ANIM_ID,
                        PIGGYBACK2_ANIM_ID = PIGGYBACK2_ANIM_ID,
                    })
                    stopBB = function() pcall(function() _bbMod.stopBB() end) end
                    startBB = function(target, mode)
                        if not target or not target.Character then return end
                        pcall(function() _bbMod.startBB(target, mode) end)
                    end
                end
            end
            ;(function()
                local _plModuleSrc = (game :: any):HttpGet("https://raw.githubusercontent.com/TLMenu/TLMenuParts/refs/heads/main/TLPlayerlistModule.lua")
                local _plModuleFn = loadstring(_plModuleSrc)
                local TLPlayerlistModule = _plModuleFn and _plModuleFn() or nil
                if not TLPlayerlistModule then return end

                local playerlistModule = TLPlayerlistModule.new()
                playerlistModule:Build({
                    C = C,
                    PANEL_W = PANEL_W,
                    PlayerGui = PlayerGui,
                    Players = Players,
                    LocalPlayer = LocalPlayer,
                    _C3_BG2 = _C3_BG2,
                    _C3_BG3 = _C3_BG3,
                    _TL_refs = _TL_refs,
                    _TL_activeThemeId = _TL_activeThemeId,
                    makePanel = makePanel,
                    _makeDummyStroke = _makeDummyStroke,
                    corner = corner,
                    twP = twP,
                    _tlTrackInst = _tlTrackInst,
                    panelColorHooks = _panelColorHooks,
                    getRootPart = getRootPart,
                    playHoverSound = function() _sc._playHoverSound() end,
                    threatSystem = {},
                })
            end)()
            function makeKeybindWidget(parent, yPos, actionName, defaultKey, callback)
                registerKeybind(actionName, defaultKey, callback)
                local row                  = Instance.new("Frame", parent)
                row.Size                   = UDim2.new(1, 0, 0, 52)
                row.Position               = UDim2.new(0, 0, 0, yPos)
                row.BackgroundColor3       = C.bg2 or _C3_BG2
                row.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                1 or 0
                row.BorderSizePixel        = 0
                corner(row, 14)
                local rowS = _makeDummyStroke(row)
                rowS.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                1.5 or 1
                rowS.Color = _TL_isImgTheme(_TL_activeThemeId) and
                Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                rowS.Transparency = 0.3
                if _panelColorHooks then
                    _panelColorHooks[#_panelColorHooks + 1] = function()
                        pcall(function()
                            row.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                            1 or 0
                            rowS.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                            1.5 or 1
                            rowS.Color = _TL_isImgTheme(_TL_activeThemeId) and
                            Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                            rowS.Transparency = 0.3
                        end)
                        
                        pcall(function() rowD.BackgroundColor3 = C.accent end)
                        pcall(function() lbl.TextColor3 = C.text end)
                        pcall(function() if not listening then descLbl.TextColor3 = C.sub or _C3_SUB end end)
                        pcall(function() if not listening then keyCardStroke.Color = C.accent2 or C.accent end end)
                        pcall(function() keyIcon.TextColor3 = C.accent2 or C.accent end)
                        pcall(function() if not listening then kl.TextColor3 = C.text end end)
                        pcall(function() keyCard.BackgroundColor3 = C.bg3 or _C3_BG3 end)
                    end
                end
                local rowD = Instance.new("Frame", row); rowD.Size = UDim2.new(0, 4, 0, 28); rowD.Visible = false; rowD.Position =
                UDim2.new(0, 0, 0.5, -14)
                rowD.BackgroundColor3 = C.accent or C.accent2; rowD.BackgroundTransparency = 0.3; rowD.BorderSizePixel = 0; corner(
                rowD, 99)
                local lbl                      = Instance.new("TextLabel", row)
                lbl.Size                       = UDim2.new(0, 160, 1, 0)
                lbl.Position                   = UDim2.new(0, 16, 0, 0)
                lbl.BackgroundTransparency     = 1
                lbl.Text                       = actionName
                lbl.Font                       = Enum.Font.GothamBold
                lbl.TextSize                   = 14
                lbl.TextColor3                 = C.text
                lbl.TextXAlignment             = Enum.TextXAlignment.Left
                local descLbl                  = Instance.new("TextLabel", row)
                descLbl.Size                   = UDim2.new(0, 100, 1, 0)
                descLbl.Position               = UDim2.new(0, 176, 0, 0)
                descLbl.BackgroundTransparency = 1
                descLbl.Text                   = "Press to change"
                descLbl.Font                   = Enum.Font.Gotham
                descLbl.TextSize               = 11
                descLbl.TextColor3             = C.sub or _C3_SUB
                descLbl.TextXAlignment         = Enum.TextXAlignment.Left
                local keyCard                  = Instance.new("Frame", row)
                keyCard.Size                   = UDim2.new(0, 90, 0, 36)
                keyCard.Position               = UDim2.new(1, -100, 0.5, -18)
                keyCard.BackgroundColor3       = C.bg3 or _C3_BG3
                keyCard.BackgroundTransparency = 0.3
                keyCard.BorderSizePixel        = 0
                corner(keyCard, 10)
                local keyCardStroke            = _makeDummyStroke(keyCard)
                keyCardStroke.Thickness        = 1.5; keyCardStroke.Color = C.accent2 or C.accent; keyCardStroke.Transparency = 0.7
                local keyIcon                  = Instance.new("TextLabel", keyCard)
                keyIcon.Size                   = UDim2.new(0, 20, 0, 20)
                keyIcon.Position               = UDim2.new(0, 6, 0.5, -10)
                keyIcon.BackgroundTransparency = 1
                keyIcon.Text                   = ""
                keyIcon.Font                   = Enum.Font.GothamBold
                keyIcon.TextSize               = 16
                keyIcon.TextColor3             = C.accent2 or C.accent
                keyIcon.TextXAlignment         = Enum.TextXAlignment.Center
                local function keyName(kc)
                    if kc == nil then return "None" end
                    local n = tostring(kc):gsub("Enum.KeyCode.", "")
                    return n
                end
                local kl                         = Instance.new("TextLabel", keyCard)
                kl.Size                          = UDim2.new(1, -26, 1, 0)
                kl.Position                      = UDim2.new(0, 26, 0, 0)
                kl.BackgroundTransparency        = 1
                kl.Text                          = keyName(defaultKey)
                kl.Font                          = Enum.Font.GothamBold
                kl.TextSize                      = 14
                kl.TextColor3                    = C.text
                kl.TextXAlignment                = Enum.TextXAlignment.Center
                keybindLabelUpdaters[actionName] = function(kc)
                    pcall(function() kl.Text = keyName(kc) end)
                end
                local keyBtn                     = Instance.new("TextButton", keyCard)
                keyBtn.Size                      = UDim2.new(1, 0, 1, 0)
                keyBtn.BackgroundTransparency    = 1
                keyBtn.Text                      = ""
                keyBtn.ZIndex                    = 6
                local listening                  = false
                local listenConn                 = nil
                local pulseConn                  = nil
                local pulseState                 = false
                local function stopListening()
                    listening = false
                    isConfiguringKeybind = false
                    if listenConn then
                        listenConn:Disconnect(); listenConn = nil
                    end
                    pulseConn = nil
                    twP(keyCard, 0.2, { BackgroundColor3 = C.bg3 or _C3_BG3, BackgroundTransparency = 0.3 })
                    twP(keyCardStroke, 0.2, { Color = C.accent2 or C.accent, Transparency = 0.7 })
                    twP(kl, 0.2, { TextColor3 = C.text })
                    kl.Text = keyName(keybinds[actionName] and keybinds[actionName].key)
                    descLbl.Text = "Press to change"
                    descLbl.TextColor3 = C.sub or _C3_SUB
                end
                local function startListening()
                    if listening then
                        stopListening(); return
                    end
                    listening = true
                    isConfiguringKeybind = true
                    kl.Text = "..."
                    kl.TextColor3 = C.accent
                    descLbl.Text = "Press any key"
                    descLbl.TextColor3 = C.accent
                    twP(keyCard, 0.2, { BackgroundColor3 = C.accent, BackgroundTransparency = 0.15 })
                    twP(keyCardStroke, 0.2, { Color = C.accent, Transparency = 0.3 })
                    pulseConn = task.spawn(function()
                        while listening and _tlAlive() do
                            pulseState = not pulseState
                            pcall(function()
                                keyCardStroke.Transparency = pulseState and 0.2 or 0.5
                            end)
                            task.wait(0.4)
                        end
                    end)
                    listenConn = UserInputService.InputBegan:Connect(function(input, gpe)
                        if input.KeyCode == Enum.KeyCode.Backspace then
                            keybinds[actionName].key = nil
                            stopListening()
                            task.spawn(saveData)
                            return
                        end
                        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        local newKey = input.KeyCode
                        keybinds[actionName].key = newKey
                        lastConfiguredKey = newKey
                        lastConfiguredTime = tick()
                        stopListening()
                        kl.Text = keyName(newKey)
                        task.spawn(saveData)
                    end)
                end
                keyBtn.MouseButton1Click:Connect(startListening)
                keyBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch then startListening() end
                end)
                keyBtn.MouseEnter:Connect(function()
                    _sc._playHoverSound()
                    if not listening then
                        twP(keyCard, 0.15, { BackgroundColor3 = C.accent2 or C.accent, BackgroundTransparency = 0.2 })
                        twP(keyCardStroke, 0.15, { Color = C.accent, Transparency = 0.4 })
                        twP(kl, 0.15, { TextColor3 = C.accent })
                        descLbl.Text = "Click to bind"
                        descLbl.TextColor3 = C.accent
                    end
                end)
                keyBtn.MouseLeave:Connect(function()
                    if not listening then
                        twP(keyCard, 0.15, { BackgroundColor3 = C.bg3 or _C3_BG3, BackgroundTransparency = 0.3 })
                        twP(keyCardStroke, 0.15, { Color = C.accent2 or C.accent, Transparency = 0.7 })
                        twP(kl, 0.15, { TextColor3 = C.text })
                        descLbl.Text = "Press to change"
                        descLbl.TextColor3 = C.sub or _C3_SUB
                    end
                end)
                return row
            end

            function setupAutoReinject(enable)
                pcall(function()
                    if enable and writefile then
                        local folderOk = true
                        pcall(function()
                            if isfolder and not isfolder("autorun") then
                                if makefolder then makefolder("autorun") end
                            end
                            folderOk = not isfolder or isfolder("autorun")
                        end)
                        if folderOk then
                            pcall(function()
                                writefile("autorun/SmartBar_Autorun.lua",
                                    "task.wait(1.5)\nprint('[SmartBar] Auto-reinject active')\n")
                            end)
                        end
                    elseif not enable then
                        pcall(function()
                            if delfile then delfile("autorun/SmartBar_Autorun.lua") end
                        end)
                    end
                end)
            end

            local switchCat = function() end
                        
            
            
return p, c

return ActionsTab