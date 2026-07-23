local TLPlayerlistModule = {}
TLPlayerlistModule.__index = TLPlayerlistModule

function TLPlayerlistModule.new()
    return setmetatable({
        _connections = {},
        _rowCache = {},
        _avatarCache = {},
        _espHighlights = {},
        _panel = nil,
        _content = nil,
        _filterText = "",
        _built = false,
    }, TLPlayerlistModule)
end

function TLPlayerlistModule:Build(cfg)
    if self._built then return end
    self._built = true

    local C          = cfg.C
    local PANEL_W    = cfg.PANEL_W
    local PlayerGui  = cfg.PlayerGui
    local Players    = cfg.Players
    local LocalPlayer = cfg.LocalPlayer
    local _C3_BG2    = cfg._C3_BG2
    local _C3_BG3    = cfg._C3_BG3
    local _TL_refs   = cfg._TL_refs
    local _TL_activeThemeId = cfg._TL_activeThemeId
    local makePanel  = cfg.makePanel
    local _makeDummyStroke = cfg._makeDummyStroke
    local corner     = cfg.corner
    local twP        = cfg.twP
    local _tlTrackInst = cfg._tlTrackInst
    local panelColorHooks = cfg.panelColorHooks
    local getRootPart = cfg.getRootPart
    local playHoverSound = cfg.playHoverSound

    local p, c = makePanel("Playerlist", C.accent)
    p.BackgroundColor3 = C.panelBg
    p.BackgroundTransparency = 0
    local _eg = p:FindFirstChildOfClass("UIGradient"); if _eg then _eg:Destroy() end
    self._panel = p
    self._content = c

    local _OP_PlBgImg                  = Instance.new("ImageLabel")
    _OP_PlBgImg.Name                   = "TLMenu_OP_PlBg"
    _OP_PlBgImg.Size                   = UDim2.new(1, 0, 1, 0)
    _OP_PlBgImg.Position               = UDim2.new(0, 0, 0, 0)
    _OP_PlBgImg.BackgroundTransparency = 1
    _OP_PlBgImg.Image                  = "rbxassetid://132090006833323"
    _OP_PlBgImg.ScaleType              = Enum.ScaleType.Crop
    _OP_PlBgImg.ImageTransparency      = 0.35
    _OP_PlBgImg.ZIndex                 = 1
    _OP_PlBgImg.Visible                = (_TL_activeThemeId == "onepiece")
    _OP_PlBgImg.Parent                 = p
    corner(_OP_PlBgImg, 12)
    _TL_refs._OP_PlBgImg              = _OP_PlBgImg

    local PAD                         = 16
    local PW                          = PANEL_W - PAD * 2
    local ROW_H_ACTUAL                = 70
    local GAP                         = 6
    local avatarCache                 = {}
    local rowCache                    = {}
    local espHighlights               = {}
    local _plFilterText               = ""

    local HEADER_H                    = 44

    local countBadge                  = Instance.new("Frame", c)
    countBadge.Size                   = UDim2.new(0, 36, 0, 20)
    countBadge.Position               = UDim2.new(1, -PAD - 36, 0, 12)
    countBadge.BackgroundColor3       = C.accent
    countBadge.BackgroundTransparency = 0.72
    countBadge.BorderSizePixel        = 0
    corner(countBadge, 99)
    local countLbl                     = Instance.new("TextLabel", countBadge)
    countLbl.Size                      = UDim2.new(1, 0, 1, 0)
    countLbl.BackgroundTransparency    = 1
    countLbl.Font                      = Enum.Font.GothamBlack
    countLbl.TextSize                  = 10
    countLbl.TextColor3                = C.accent
    countLbl.TextXAlignment            = Enum.TextXAlignment.Center
    countLbl.Text                      = tostring(#Players:GetPlayers())

    local searchFrame                  = Instance.new("Frame", c)
    searchFrame.Size                   = UDim2.new(1, -PAD * 2, 0, 28)
    searchFrame.Position               = UDim2.new(0, PAD, 0, 6)
    searchFrame.BackgroundColor3       = C.bg2 or _C3_BG2
    searchFrame.BackgroundTransparency = 0
    searchFrame.BorderSizePixel        = 0
    corner(searchFrame, 8)
    local search_Stroke               = _makeDummyStroke(searchFrame)
    search_Stroke.Thickness           = 1
    search_Stroke.Color               = C.bg3 or _C3_BG3
    search_Stroke.Transparency        = 0.3

    local searchIcon                  = Instance.new("TextLabel", searchFrame)
    searchIcon.Size                   = UDim2.new(0, 24, 1, 0)
    searchIcon.Position               = UDim2.new(0, 6, 0, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text                   = "\xF0\x9F\x94\x8D"
    searchIcon.Font                   = Enum.Font.GothamBold
    searchIcon.TextSize               = 12
    searchIcon.TextXAlignment         = Enum.TextXAlignment.Center

    local searchBox                   = Instance.new("TextBox", searchFrame)
    searchBox.Size                    = UDim2.new(1, -58, 1, 0)
    searchBox.Position                = UDim2.new(0, 28, 0, 0)
    searchBox.BackgroundTransparency  = 1
    searchBox.Font                    = Enum.Font.Gotham
    searchBox.TextSize                = 12
    searchBox.TextColor3              = C.text or Color3.new(1, 1, 1)
    searchBox.PlaceholderText         = "Search players"
    searchBox.PlaceholderColor3       = C.sub or Color3.fromRGB(120, 120, 130)
    searchBox.Text                    = ""
    searchBox.ClearTextOnFocus        = false
    searchBox.ZIndex                  = 5

    searchBox.Focused:Connect(function()
        twP(search_Stroke, 0.15, { Color = C.accent, Transparency = 0.45 })
    end)
    searchBox.FocusLost:Connect(function()
        twP(search_Stroke, 0.15, { Color = C.bg3 or _C3_BG3, Transparency = 0.3 })
    end)

    local hdrLine                       = Instance.new("Frame", c)
    hdrLine.Size                        = UDim2.new(1, -PAD * 2, 0, 1)
    hdrLine.Position                    = UDim2.new(0, PAD, 0, HEADER_H - 2)
    hdrLine.BackgroundColor3            = C.bg3 or _C3_BG3
    hdrLine.BackgroundTransparency      = 0.3
    hdrLine.BorderSizePixel             = 0

    local noResultsLbl                  = Instance.new("TextLabel", c)
    noResultsLbl.Size                   = UDim2.new(1, -PAD * 2, 1, -HEADER_H)
    noResultsLbl.Position               = UDim2.new(0, PAD, 0, HEADER_H)
    noResultsLbl.BackgroundTransparency = 1
    noResultsLbl.Text                   = ""
    noResultsLbl.Font                   = Enum.Font.Gotham
    noResultsLbl.TextSize               = 13
    noResultsLbl.TextColor3             = C.sub or Color3.fromRGB(150, 150, 160)
    noResultsLbl.TextXAlignment         = Enum.TextXAlignment.Center
    noResultsLbl.Visible                = false

    local function makePillBtn(parent, xScale, xOff, w, label, accentC)
        local col                = accentC or C.accent
        local f                  = Instance.new("Frame", parent)
        f.Size                   = UDim2.new(0, w, 0, 22)
        f.Position               = UDim2.new(xScale, xOff, 0.5, -11)
        f.BackgroundColor3       = col
        f.BackgroundTransparency = 0.72
        f.BorderSizePixel        = 0
        corner(f, 6)
        local s                   = _makeDummyStroke(f)
        s.Thickness               = 0; s.Color = col; s.Transparency = 1
        local tb                  = Instance.new("TextButton", f)
        tb.Size                   = UDim2.new(1, 0, 1, 0)
        tb.BackgroundTransparency = 1
        tb.Text                   = label:upper()
        tb.Font                   = Enum.Font.GothamBlack
        tb.TextSize               = 9
        tb.TextColor3             = col
        tb.ZIndex                 = 8
        tb.Active                 = true
        local function onHover()
            playHoverSound()
            twP(f, 0.08, { BackgroundColor3 = col, BackgroundTransparency = 0.2 })
            twP(tb, 0.08, { TextColor3 = Color3.new(1, 1, 1) })
        end
        local function onLeave()
            twP(f, 0.12, { BackgroundColor3 = col, BackgroundTransparency = 0.72 })
            twP(tb, 0.12, { TextColor3 = col })
        end
        tb.MouseEnter:Connect(onHover)
        tb.MouseLeave:Connect(onLeave)
        tb.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then onHover() end
        end)
        tb.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then onLeave() end
        end)
        return f, tb, s
    end

    local function createRow(pl, yPos)
        local isMe                  = (pl == LocalPlayer)
        local col                   = isMe and (C.accent or Color3.fromRGB(120, 200, 255))
            or C.accent2 or C.accent

        local card                  = Instance.new("Frame", c)
        card.Name                   = "plRow_" .. pl.UserId
        card.Size                   = UDim2.new(1, -PAD * 2, 0, ROW_H_ACTUAL)
        card.Position               = UDim2.new(0, PAD, 0, yPos)
        card.BackgroundColor3       = C.bg2 or _C3_BG2
        card.BackgroundTransparency = 0
        card.BorderSizePixel        = 0
        corner(card, 12)

        local cStr                  = _makeDummyStroke(card)
        cStr.Thickness              = 1
        cStr.Color                  = C.bg3 or _C3_BG3
        cStr.Transparency           = 0.35

        local cdot                  = Instance.new("Frame", card)
        cdot.Size                   = UDim2.new(0, 3, 0, ROW_H_ACTUAL - 18); cdot.Visible = false
        cdot.Position               = UDim2.new(0, 0, 0.5, -(ROW_H_ACTUAL - 18) / 2)
        cdot.BackgroundColor3       = col
        cdot.BackgroundTransparency = 0.35
        cdot.BorderSizePixel        = 0
        corner(cdot, 99)

        local avF                  = Instance.new("Frame", card)
        avF.Name                   = "avF"
        avF.Size                   = UDim2.new(0, 42, 0, 42)
        avF.Position               = UDim2.new(0, 12, 0.5, -21)
        avF.BackgroundColor3       = C.bg3 or _C3_BG3
        avF.BackgroundTransparency = 0.2
        avF.BorderSizePixel        = 0
        corner(avF, 99)
        local clipF                  = Instance.new("Frame", avF)
        clipF.Size                   = UDim2.new(1, 0, 1, 0)
        clipF.BackgroundTransparency = 1
        clipF.ClipsDescendants       = true
        corner(clipF, 99)
        local avatar                  = Instance.new("ImageLabel", clipF)
        avatar.Size                   = UDim2.new(1, 0, 1, 0)
        avatar.BackgroundTransparency = 1
        avatar.ScaleType              = Enum.ScaleType.Crop
        avatar.ZIndex                 = 4
        if avatarCache[pl.UserId] then
            avatar.Image       = avatarCache[pl.UserId]
            avatar.ImageColor3 = Color3.new(1, 1, 1)
        else
            avatar.Image       = "rbxassetid://142509179"
            avatar.ImageColor3 = C.sub or Color3.fromRGB(100, 100, 110)
            task.spawn(function()
                local ok, url = pcall(function()
                    return Players:GetUserThumbnailAsync(
                        pl.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100
                    )
                end)
                if ok and url and avatar.Parent then
                    avatarCache[pl.UserId] = url
                    avatar.Image           = url
                    avatar.ImageColor3     = Color3.new(1, 1, 1)
                end
            end)
        end
        local ring                     = _makeDummyStroke(avF)
        ring.Thickness                 = 1.5
        ring.Color                     = col
        ring.Transparency              = 0.35

        local NX                       = 62
        local nameLbl                  = Instance.new("TextLabel", card)
        nameLbl.Size                   = UDim2.new(0, PW - NX - 4, 0, 18)
        nameLbl.Position               = UDim2.new(0, NX, 0, 8)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text                   = pl.DisplayName
        nameLbl.Font                   = Enum.Font.GothamBold
        nameLbl.TextSize               = 13
        nameLbl.TextColor3             = C.text or Color3.new(1, 1, 1)
        nameLbl.TextXAlignment         = Enum.TextXAlignment.Left
        nameLbl.TextTruncate           = Enum.TextTruncate.AtEnd

        local userLbl                  = Instance.new("TextLabel", card)
        userLbl.Size                   = UDim2.new(0, 160, 0, 12)
        userLbl.Position               = UDim2.new(0, NX, 0, 27)
        userLbl.BackgroundTransparency = 1
        userLbl.Text                   = "@" .. pl.Name .. (isMe and "  \xE2\x98\x85" or "")
        userLbl.Font                   = Enum.Font.GothamBold
        userLbl.TextSize               = 9
        userLbl.TextColor3             = C.sub or Color3.fromRGB(120, 120, 130)
        userLbl.TextXAlignment         = Enum.TextXAlignment.Left
        userLbl.TextTruncate           = Enum.TextTruncate.AtEnd

        local rankBg                   = Instance.new("Frame", card)
        rankBg.Size                    = UDim2.new(0, 52, 0, 14)
        rankBg.Position                = UDim2.new(0, NX, 0, 42)
        rankBg.BackgroundColor3        = C.bg3 or _C3_BG3
        rankBg.BackgroundTransparency  = 0.35
        rankBg.BorderSizePixel         = 0
        corner(rankBg, 99)
        local rankTxt                    = Instance.new("TextLabel", rankBg)
        rankTxt.Size                     = UDim2.new(1, 0, 1, 0)
        rankTxt.BackgroundTransparency   = 1
        rankTxt.Font                     = Enum.Font.GothamBold
        rankTxt.TextSize                 = 8
        rankTxt.Text                     = "Player"
        rankTxt.TextColor3               = C.sub or Color3.fromRGB(120, 120, 130)
        rankTxt.TextXAlignment           = Enum.TextXAlignment.Center

        local creatorBg                  = Instance.new("Frame", card)
        creatorBg.Size                   = UDim2.new(0, 80, 0, 14)
        creatorBg.Position               = UDim2.new(0, NX + 58, 0, 42)
        creatorBg.BackgroundColor3       = Color3.fromRGB(0, 140, 255)
        creatorBg.BackgroundTransparency = 0.25
        creatorBg.BorderSizePixel        = 0; creatorBg.Visible = false
        corner(creatorBg, 99)
        local creatorTxt                  = Instance.new("TextLabel", creatorBg)
        creatorTxt.Size                   = UDim2.new(1, 0, 1, 0)
        creatorTxt.BackgroundTransparency = 1
        creatorTxt.Font                   = Enum.Font.GothamBold
        creatorTxt.TextSize               = 8
        creatorTxt.Text                   = "Content-Creator"
        creatorTxt.TextColor3             = Color3.new(1, 1, 1)
        creatorTxt.TextXAlignment         = Enum.TextXAlignment.Center

        local ownerBg                     = Instance.new("Frame", card)
        ownerBg.Size                      = UDim2.new(0, 52, 0, 14)
        ownerBg.Position                  = UDim2.new(0, NX + 58, 0, 42)
        ownerBg.BackgroundColor3          = Color3.fromRGB(255, 40, 40)
        ownerBg.BackgroundTransparency    = 0.2
        ownerBg.BorderSizePixel           = 0; ownerBg.Visible = false
        corner(ownerBg, 99)
        local ownerTxt                  = Instance.new("TextLabel", ownerBg)
        ownerTxt.Size                   = UDim2.new(1, 0, 1, 0)
        ownerTxt.BackgroundTransparency = 1
        ownerTxt.Font                   = Enum.Font.GothamBold
        ownerTxt.TextSize               = 8
        ownerTxt.Text                   = "Owner"
        ownerTxt.TextColor3             = Color3.new(1, 1, 1)
        ownerTxt.TextXAlignment         = Enum.TextXAlignment.Center

        local function refreshThreatBadge()
            local role = (_TL_refs and _TL_refs._TL_getThreatRole and _TL_refs._TL_getThreatRole(pl)) or nil
            if role then
                local lowRole     = role:lower()
                local displayRole = role:gsub("^Group Role: ", "")
                local isCreator   = lowRole:find("creator") or lowRole:find("star") or lowRole:find("video") or
                lowRole:find("influencer")
                local isOwner     = lowRole:find("owner") or lowRole:find("besitzer")
                local isAdmin     = lowRole:find("admin") or lowRole:find("administrator")
                local isMod       = lowRole:find("moderator") or lowRole:find("mod")
                local isManager   = lowRole:find("manager") or lowRole:find("management")

                if isOwner then
                    rankBg.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
                    rankBg.BackgroundTransparency = 0.2
                elseif isManager then
                    rankBg.BackgroundColor3 = Color3.fromRGB(160, 20, 20)
                    rankBg.BackgroundTransparency = 0.2
                elseif isAdmin then
                    rankBg.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
                    rankBg.BackgroundTransparency = 0.2
                elseif isMod then
                    rankBg.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
                    rankBg.BackgroundTransparency = 0.2
                elseif isCreator then
                    rankBg.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                    rankBg.BackgroundTransparency = 0.2
                else
                    rankBg.BackgroundColor3 = C.bg3 or _C3_BG3
                    rankBg.BackgroundTransparency = 0.35
                end

                rankTxt.Text       = displayRole
                rankTxt.TextColor3 = Color3.fromRGB(255, 255, 255)

                ownerBg.Visible    = false
                creatorBg.Visible  = false
            else
                rankBg.BackgroundColor3       = C.bg3 or _C3_BG3
                rankBg.BackgroundTransparency = 0.35
                rankTxt.Text                  = "Player"
                rankTxt.TextColor3            = C.sub or Color3.fromRGB(120, 120, 130)
                creatorBg.Visible             = false
                ownerBg.Visible               = false
            end
        end
        refreshThreatBadge()
        if not isMe and _TL_refs and _TL_refs._TL_checkThreatPlayer then
            _TL_refs._TL_checkThreatPlayer(pl, function()
                if card and card.Parent then
                    refreshThreatBadge()
                end
            end)
        end

        local PW2, G2 = 44, 5

        local espF, espBtn, espS = makePillBtn(card, 1, -PW2 - 8, PW2, "ESP", C.accent)
        local espOn = false
        local function setEsp(on)
            espOn = on
            if on then
                espBtn.Text = "ESP \xF0\x9F\x92\x88"
                twP(espF, 0.15, { BackgroundColor3 = C.accent, BackgroundTransparency = 0.75 })
                twP(espS, 0.15, { Transparency = 0.1 })
                twP(cStr, 0.15, { Color = C.accent, Transparency = 0.35 })
                local char = pl.Character
                if char and not espHighlights[pl] then
                    local h               = _tlTrackInst(Instance.new("Highlight", PlayerGui))
                    h.Name                = "TL_ESP_Highlight"
                    h.Adornee             = char
                    h.FillTransparency    = 1
                    h.OutlineColor        = Color3.new(1, 1, 1)
                    h.OutlineTransparency = 0
                    espHighlights[pl]     = h
                end
            else
                espBtn.Text = "ESP"
                twP(espF, 0.15, { BackgroundColor3 = C.bg3 or _C3_BG3, BackgroundTransparency = 0.25 })
                twP(espS, 0.15, { Transparency = 0.6 })
                twP(cStr, 0.15, { Color = C.bg3 or _C3_BG3, Transparency = 0.35 })
                if espHighlights[pl] then
                    espHighlights[pl]:Destroy(); espHighlights[pl] = nil
                end
            end
        end
        espBtn.MouseButton1Click:Connect(function() setEsp(not espOn) end)
        espBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then setEsp(not espOn) end
        end)

        if not isMe then
            local _, tpBtn = makePillBtn(card, 1, -PW2 - 8 - G2 - PW2, PW2, "TP", C.accent)
            tpBtn.MouseButton1Click:Connect(function()
                if pl.Character then
                    local tR = pl.Character:FindFirstChild("HumanoidRootPart")
                    local mR = getRootPart()
                    if tR and mR then mR.CFrame = tR.CFrame * CFrame.new(0, 0, 3.5) end
                end
            end)
            tpBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then
                    if pl.Character then
                        local tR = pl.Character:FindFirstChild("HumanoidRootPart")
                        local mR = getRootPart()
                        if tR and mR then mR.CFrame = tR.CFrame * CFrame.new(0, 0, 3.5) end
                    end
                end
            end)

            local isSpectating           = false
            local specCol                = C.accent2 or C.accent

            local specF                  = Instance.new("Frame", card)
            specF.Size                   = UDim2.new(0, PW2, 0, 22)
            specF.Position               = UDim2.new(1, -PW2 - 8 - G2 - PW2 - G2 - PW2, 0.5, -11)
            specF.BackgroundColor3       = C.bg3 or _C3_BG3
            specF.BackgroundTransparency = 0.25
            specF.BorderSizePixel        = 0
            corner(specF, 6)
            local specS2                   = _makeDummyStroke(specF)
            specS2.Thickness               = 0; specS2.Color = specCol; specS2.Transparency = 0.6

            local specImg                  = Instance.new("TextButton", specF)
            specImg.Size                   = UDim2.new(1, 0, 1, 0)
            specImg.Position               = UDim2.new(0, 0, 0, 0)
            specImg.BackgroundTransparency = 1
            specImg.Text                   = "SPEC"
            specImg.Font                   = Enum.Font.GothamBlack
            specImg.TextSize               = 9
            specImg.TextColor3             = specCol
            specImg.ZIndex                 = 8

            local function setSpec(on)
                isSpectating = on
                local cam = workspace.CurrentCamera; if not cam then return end
                if on then
                    twP(specImg, 0.15, { TextColor3 = Color3.new(1, 1, 1) })
                    twP(specF, 0.15, { BackgroundColor3 = specCol, BackgroundTransparency = 0.75 })
                    twP(specS2, 0.15, { Transparency = 0.1 })
                    local char = pl.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            cam.CameraType = Enum.CameraType.Custom; cam.CameraSubject = hum
                        end
                    end
                else
                    twP(specImg, 0.15, { TextColor3 = specCol })
                    twP(specF, 0.15, { BackgroundColor3 = C.bg3 or _C3_BG3, BackgroundTransparency = 0.25 })
                    twP(specS2, 0.15, { Transparency = 0.6 })
                    local myChar = LocalPlayer.Character
                    if myChar then
                        cam.CameraType    = Enum.CameraType.Custom
                        cam.CameraSubject = myChar:FindFirstChildOfClass("Humanoid")
                            or myChar:FindFirstChild("HumanoidRootPart")
                    end
                end
            end

            local function onSpecHover()
                playHoverSound()
                twP(specF, 0.08, { BackgroundColor3 = specCol, BackgroundTransparency = 0.2 })
                if not isSpectating then twP(specImg, 0.08, { TextColor3 = Color3.new(1, 1, 1) }) end
            end
            local function onSpecLeave()
                if not isSpectating then
                    twP(specF, 0.12, { BackgroundColor3 = C.bg3 or _C3_BG3, BackgroundTransparency = 0.25 })
                    twP(specImg, 0.12, { TextColor3 = specCol })
                end
            end

            specImg.MouseEnter:Connect(onSpecHover)
            specImg.MouseLeave:Connect(onSpecLeave)
            specImg.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then onSpecHover() end
            end)
            specImg.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then onSpecLeave() end
            end)
            specImg.MouseButton1Click:Connect(function() setSpec(not isSpectating) end)

            panelColorHooks[#panelColorHooks + 1] = function()
                pcall(function() if specS2 then specS2.Color = C.accent2 or C.accent end end)
                pcall(function() if specImg then specImg.TextColor3 = C.accent2 or C.accent end end)
            end
        end

        panelColorHooks[#panelColorHooks + 1] = function()
            pcall(function() if espS then espS.Color = C.accent end end)
            pcall(function() if ring then ring.Color = isMe and C.accent or (C.accent2 or C.accent) end end)
            pcall(function() if cStr then cStr.Color = C.bg3 or _C3_BG3 end end)
        end

        card.MouseEnter:Connect(function()
            playHoverSound()
            twP(card, 0.1, { BackgroundColor3 = C.bg3 or _C3_BG3 })
        end)
        card.MouseLeave:Connect(function()
            twP(card, 0.1, { BackgroundColor3 = C.bg2 or _C3_BG2 })
        end)

        rowCache[pl.UserId] = { row = card, refreshThreat = refreshThreatBadge }
        return card
    end

    local function rebuildList()
        local plrs      = Players:GetPlayers()
        local filter    = _plFilterText:lower()
        local activeIds = {}

        for _, pl in ipairs(plrs) do activeIds[pl.UserId] = true end
        for uid, entry in pairs(rowCache) do
            if not activeIds[uid] then
                entry.row:Destroy(); rowCache[uid] = nil
            end
        end

        table.sort(plrs, function(a, b)
            local aMod = _TL_refs and _TL_refs._TL_isThreatPlayer and _TL_refs._TL_isThreatPlayer(a) or false
            local bMod = _TL_refs and _TL_refs._TL_isThreatPlayer and _TL_refs._TL_isThreatPlayer(b) or false
            if aMod ~= bMod then return aMod end
            return a.Name < b.Name
        end)

        local visIdx = 0
        for _, pl in ipairs(plrs) do
            if pl == Players.LocalPlayer then continue end

            local show = filter == ""
                or pl.Name:lower():find(filter, 1, true)
                or pl.DisplayName:lower():find(filter, 1, true)

            local entry = rowCache[pl.UserId]
            if show then
                local yPos = HEADER_H + visIdx * (ROW_H_ACTUAL + GAP) + 4
                if entry then
                    entry.row.Position = UDim2.new(0, PAD, 0, yPos)
                    entry.row.Visible  = true
                    if entry.refreshThreat then entry.refreshThreat() end
                else
                    createRow(pl, yPos)
                end
                visIdx = visIdx + 1
            else
                if entry then entry.row.Visible = false end
            end
        end

        local total = #plrs
        if countLbl and countLbl.Parent then
            countLbl.Text = tostring(total)
        end

        local contentH = HEADER_H + visIdx * (ROW_H_ACTUAL + GAP) + 16

        if visIdx == 0 and _plFilterText ~= "" then
            noResultsLbl.Text = "No player found for: \"" .. _plFilterText .. "\""
            noResultsLbl.Visible = true
            contentH = 420
            c.CanvasSize = UDim2.new(0, 0, 0, 0)
        else
            noResultsLbl.Visible = false
            c.CanvasSize = UDim2.new(0, 0, 0, math.max(ROW_H_ACTUAL, contentH))
        end

        local minH = HEADER_H + (ROW_H_ACTUAL + GAP) * 3 + 16
        p.Size = UDim2.new(0, PANEL_W, 0, math.max(minH, math.min(contentH, 420)))
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        _plFilterText = searchBox.Text or ""
        rebuildList()
    end)

    panelColorHooks[#panelColorHooks + 1] = function()
        pcall(function() p.BackgroundColor3 = C.panelBg end)
        pcall(function() countBadge.BackgroundColor3 = C.accent end)
        pcall(function() countLbl.TextColor3 = C.accent end)
        pcall(function() hdrLine.BackgroundColor3 = C.bg3 or _C3_BG3 end)
        pcall(function() searchFrame.BackgroundColor3 = C.bg2 or _C3_BG2 end)
        pcall(function() search_Stroke.Color = C.bg3 or _C3_BG3 end)
        pcall(function() searchBox.TextColor3 = C.text end)
        pcall(function() searchBox.PlaceholderColor3 = C.sub end)

        for _, ch in ipairs(p:GetChildren()) do
            pcall(function()
                if ch:IsA("Frame") and ch.Size.Y.Offset == 48 then
                    ch.BackgroundColor3 = C.panelHdr
                end
            end)
        end

        for _, entry in pairs(rowCache) do
            pcall(function()
                local card = entry.row
                if card and card.Parent then
                    card.BackgroundColor3 = C.bg2 or _C3_BG2
                    local str = card:FindFirstChildOfClass("UIStroke")
                    if str then str.Color = C.bg3 or _C3_BG3 end
                    local avF = card:FindFirstChild("avF")
                    if avF then avF.BackgroundColor3 = C.bg3 or _C3_BG3 end
                    for _, lbl in ipairs(card:GetDescendants()) do
                        if lbl:IsA("TextLabel") then
                            local fs = lbl.TextSize
                            if fs >= 13 then
                                lbl.TextColor3 = C.text
                            else
                                lbl.TextColor3 = C.sub
                            end
                        end
                    end
                    for _, pill in ipairs(card:GetDescendants()) do
                        if pill:IsA("Frame") and pill:FindFirstChildOfClass("UICorner") and pill:FindFirstChildOfClass("TextButton") then
                            local uc = pill:FindFirstChildOfClass("UICorner")
                            if uc and uc.CornerRadius.Scale >= 0.5 then
                                pcall(function() pill.BackgroundColor3 = C.accent end)
                                local tb2 = pill:FindFirstChildOfClass("TextButton")
                                if tb2 then tb2.TextColor3 = C.accent end
                            end
                        end
                    end
                    if entry.refreshThreat then entry.refreshThreat() end
                end
            end)
        end
    end

    _TL_refs._TL_rebuildPlayerList = rebuildList

    rebuildList()
    self._connections[#self._connections + 1] = Players.PlayerAdded:Connect(function()
        task.wait(0.15); rebuildList()
    end)
    self._connections[#self._connections + 1] = Players.PlayerRemoving:Connect(function(pl)
        task.wait(0.15)
        local entry = rowCache[pl.UserId]
        if entry then
            entry.row:Destroy(); rowCache[pl.UserId] = nil
        end
        rebuildList()
    end)

    self._rebuildList = rebuildList
    self._rowCache = rowCache
    self._avatarCache = avatarCache
end

function TLPlayerlistModule:Refresh()
    if self._rebuildList then self._rebuildList() end
end

function TLPlayerlistModule:Destroy()
    for _, conn in ipairs(self._connections) do
        pcall(function() conn:Disconnect() end)
    end
    self._connections = {}
    if self._rowCache then
        for uid, entry in pairs(self._rowCache) do
            pcall(function() entry.row:Destroy() end)
        end
        self._rowCache = {}
    end
    if self._panel then
        pcall(function() self._panel:Destroy() end)
    end
end

return TLPlayerlistModule
