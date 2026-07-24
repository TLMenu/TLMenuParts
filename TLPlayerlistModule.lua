local TLPlayerlistModule = {}
TLPlayerlistModule.__index = TLPlayerlistModule

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local trackedStaff = {}
local staffCheckCache = {}
local _adminAudioPlayed = false

local function playStaffAlert()
    if not _adminAudioPlayed then
        _adminAudioPlayed = true
        pcall(function()
            local s = Instance.new("Sound")
            local adminAsset = nil
            pcall(function()
                local _TL_safeIsFile = getgenv and getgenv()._TL_safeIsFile
                local _TL_safeGetCustomAsset = getgenv and getgenv()._TL_safeGetCustomAsset
                local adminAudioFileName = "admin_alert.mp3"
                if _TL_safeIsFile and _TL_safeGetCustomAsset and _TL_safeIsFile(adminAudioFileName) then
                    adminAsset = _TL_safeGetCustomAsset(adminAudioFileName)
                end
            end)
            if adminAsset then
                s.SoundId = adminAsset
            else
                s.SoundId = "rbxassetid://76216668797350"
            end
            s.Volume = 2
            s.Parent = game:GetService("SoundService")
            s:Play()
            s.Ended:Connect(function()
                pcall(function() s:Destroy() end)
            end)
            game:GetService("Debris"):AddItem(s, 30)
        end)
    end
end

local function sendStaffDetectorNotification(_TL_refs, title, text)
    local settingsState = _TL_refs and _TL_refs._TL_settingsState
    if settingsState and settingsState.notifications == false then return end
    pcall(function()
        local sendNotif = _TL_refs and _TL_refs._TL_sendNotif
        if sendNotif then
            sendNotif(title, text, 7, Color3.fromRGB(255, 80, 80))
        end
    end)
end

local function isThreatRole(roleName)
    if not roleName then return false end
    local s = tostring(roleName):lower()
    if s:match("free admin") or s:match("vip") or s:match("donator") or s:match("premium") then
        return false
    end
    if s:match("admin") or s:match("mod") or s:match("owner") or s:match("creator")
        or s:match("staff") or s:match("youtube") or s:match("tiktok") or s:match("twitch")
        or s:match("tester") or s:match("developer") then
        return true
    end
    return false
end

local function checkPlayerForStaff(plr)
    if not plr or plr == LocalPlayer then return false, "" end
    local isGroupGame = game.CreatorType == Enum.CreatorType.Group
    local creatorId = game.CreatorId

    if not isGroupGame and plr.UserId == creatorId then
        return true, "Game Owner"
    end
    local ok, vipOwnerId = pcall(function() return (game :: any).VIPServerOwnerId end)
    if ok and vipOwnerId and vipOwnerId ~= 0 and plr.UserId == vipOwnerId then
        return true, "VIP Server Owner (Admin)"
    end
    if isGroupGame then
        local successRank, rank = pcall(function() return plr:GetRankInGroup(creatorId) end)
        local successRole, roleName = pcall(function() return plr:GetRoleInGroup(creatorId) end)
        if successRank and successRole and type(rank) == "number" and rank > 0 then
            if rank == 255 then
                return true, "Group Owner"
            elseif rank >= 200 then
                return true, "Group Admin"
            elseif rank >= 100 then
                return true, "Group Moderator"
            elseif isThreatRole(roleName) then
                return true, "Group Role: " .. tostring(roleName)
            end
        end
    end

    local successRoblox, rankRoblox = pcall(function() return plr:GetRankInGroup(1200769) end)
    if successRoblox and type(rankRoblox) == "number" and rankRoblox > 0 then
        return true, "Roblox Staff"
    end

    local successStar, rankStar = pcall(function() return plr:GetRankInGroup(4199740) end)
    if successStar and type(rankStar) == "number" and rankStar > 0 then
        return true, "Roblox Video Star"
    end

    local adminSystemRole = nil
    for attr, val in pairs(plr:GetAttributes()) do
        local attrName = tostring(attr):lower()
        if type(val) == "number" then
            if (attrName:match("admin") or attrName:match("adonis")) and val >= 2 then
                adminSystemRole = "Admin System (Level " .. tostring(val) .. ")"
                break
            end
        elseif type(val) == "string" then
            if isThreatRole(val) then
                adminSystemRole = "In-Game Role (" .. tostring(val) .. ")"
                break
            end
        end
    end

    if not adminSystemRole then
        for _, obj in ipairs(plr:GetChildren()) do
            if obj:IsA("StringValue") and isThreatRole(obj.Value) then
                adminSystemRole = "In-Game Role (" .. tostring(obj.Value) .. ")"
                break
            end
        end
    end
    if adminSystemRole then
        return true, adminSystemRole
    end

    local char = plr.Character
    if char and char:FindFirstChild("Head") then
        for _, obj in ipairs(char.Head:GetChildren()) do
            if obj:IsA("BillboardGui") then
                for _, desc in ipairs(obj:GetDescendants()) do
                    if desc:IsA("TextLabel") and isThreatRole(desc.Text) then
                        return true, "Overhead Tag (" .. tostring(desc.Text) .. ")"
                    end
                end
            end
        end
    end

    local function checkTools(parent)
        if not parent then return false, "" end
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") or tool:IsA("HopperBin") then
                local tName = tostring(tool.Name):lower()
                if tName:match("f3x") or tName:match("btools") or tName:match("ban")
                    or tName:match("kick") or tName:match("admin") then
                    return true, "Admin Tool (" .. tostring(tool.Name) .. ")"
                end
            end
        end
        return false, ""
    end

    local hasTool, toolName = checkTools(plr:FindFirstChild("Backpack"))
    if hasTool then return true, toolName end
    if char then
        local hasToolChar, toolNameChar = checkTools(char)
        if hasToolChar then return true, toolNameChar end
    end
    return false, ""
end

local function setStaffState(_TL_refs, plr, isStaff, role, notifyOnDetect)
    local previousRole = trackedStaff[plr]
    local normalizedRole = (isStaff and role) or nil
    staffCheckCache[plr] = normalizedRole or false
    trackedStaff[plr] = normalizedRole
    if notifyOnDetect and normalizedRole and not previousRole then
        sendStaffDetectorNotification(_TL_refs, "Staff/Creator detected", plr.Name .. "\nRole: " .. normalizedRole)
        playStaffAlert()
    end
    if previousRole ~= normalizedRole then
        local fn = _TL_refs and _TL_refs._TL_rebuildPlayerList
        if type(fn) == "function" then fn() end
    end
    return isStaff, role
end

local function runStaffCheck(_TL_refs, plr, notifyOnDetect, delaySec, onDone)
    if not plr or plr == LocalPlayer then
        if onDone then onDone(false, "") end
        return
    end
    task.spawn(function()
        if delaySec and delaySec > 0 then task.wait(delaySec) end
        if not plr.Parent then
            if onDone then onDone(false, "") end
            return
        end
        local cached = staffCheckCache[plr]
        if cached ~= nil then
            local isStaff = cached ~= false
            local role = isStaff and cached or ""
            if isStaff and notifyOnDetect and not trackedStaff[plr] then
                trackedStaff[plr] = role
                sendStaffDetectorNotification(_TL_refs, "Staff/Creator detected", plr.Name .. "\nRole: " .. role)
                playStaffAlert()
                local fn = _TL_refs and _TL_refs._TL_rebuildPlayerList
                if type(fn) == "function" then fn() end
            end
            if onDone then onDone(isStaff, role) end
            return
        end
        local isStaff, role = checkPlayerForStaff(plr)
        setStaffState(_TL_refs, plr, isStaff, role, notifyOnDetect)
        if onDone then onDone(isStaff, role) end
    end)
end

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
    local espHighlights                = {}
    local _plFilterText               = ""
    local _currentDropdownH           = 0

    -- extra header space to make room for the dropdown result list underneath the searchbar
    local HEADER_H                    = 44
    local SEARCH_ICON_ASSET           = "rbxassetid://3926305904" -- vector magnifier sprite sheet (replace with your icon pack id if different)
    local SEARCH_ICON_RECT_OFFSET     = Vector2.new(964, 324)
    local SEARCH_ICON_RECT_SIZE       = Vector2.new(36, 36)

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

    -- ============================================================
    -- SEARCHBAR (redesigned: sharp corners + colored underline focus)
    -- ============================================================
    local searchFrame                  = Instance.new("Frame", c)
    searchFrame.Name                   = "TL_PL_SearchFrame"
    searchFrame.Size                   = UDim2.new(1, -PAD * 2, 0, 28)
    searchFrame.Position               = UDim2.new(0, PAD, 0, 6)
    searchFrame.BackgroundColor3       = C.bg2 or _C3_BG2
    searchFrame.BackgroundTransparency = 0
    searchFrame.BorderSizePixel        = 0
    searchFrame.ClipsDescendants       = false
    corner(searchFrame, 4) -- sharp corners (was 8)

    -- thin frame border on all sides (subtle), sharp radius
    local search_Stroke               = _makeDummyStroke(searchFrame)
    search_Stroke.Thickness           = 1
    search_Stroke.Color               = C.bg3 or _C3_BG3
    search_Stroke.Transparency        = 0.3

    -- colored underline accent (the focus indicator) - sits as its own thin frame
    -- so it can be 2px and independent from the UIStroke rounding
    local searchUnderline              = Instance.new("Frame", searchFrame)
    searchUnderline.Name               = "TL_PL_SearchUnderline"
    searchUnderline.AnchorPoint        = Vector2.new(0, 1)
    searchUnderline.Size               = UDim2.new(1, 0, 0, 2)
    searchUnderline.Position           = UDim2.new(0, 0, 1, 1)
    searchUnderline.BackgroundColor3   = C.accent
    searchUnderline.BackgroundTransparency = 1 -- hidden until focused
    searchUnderline.BorderSizePixel    = 0
    searchUnderline.ZIndex             = 6

    -- vector search icon (ImageLabel instead of emoji glyph)
    local searchIcon                   = Instance.new("ImageLabel", searchFrame)
    searchIcon.Name                    = "TL_PL_SearchIcon"
    searchIcon.Size                    = UDim2.new(0, 14, 0, 14)
    searchIcon.Position                = UDim2.new(0, 10, 0.5, -7)
    searchIcon.BackgroundTransparency  = 1
    searchIcon.Image                   = SEARCH_ICON_ASSET
    searchIcon.ImageRectOffset         = SEARCH_ICON_RECT_OFFSET
    searchIcon.ImageRectSize           = SEARCH_ICON_RECT_SIZE
    searchIcon.ImageColor3             = C.sub or Color3.fromRGB(120, 120, 130)
    searchIcon.ScaleType               = Enum.ScaleType.Fit

    local searchBox                   = Instance.new("TextBox", searchFrame)
    searchBox.Name                    = "TL_PL_SearchBox"
    searchBox.Size                    = UDim2.new(1, -62, 1, 0)
    searchBox.Position                = UDim2.new(0, 32, 0, 0)
    searchBox.BackgroundTransparency  = 1
    searchBox.Font                    = Enum.Font.Gotham
    searchBox.TextSize                = 12
    searchBox.TextColor3              = C.text or Color3.new(1, 1, 1)
    searchBox.PlaceholderText         = "Search players"
    searchBox.PlaceholderColor3       = C.sub or Color3.fromRGB(120, 120, 130)
    searchBox.Text                    = ""
    searchBox.ClearTextOnFocus        = false
    searchBox.TextXAlignment          = Enum.TextXAlignment.Left
    searchBox.ZIndex                  = 5

    -- clear ("x") button, only visible once there's text
    local searchClearBtn               = Instance.new("TextButton", searchFrame)
    searchClearBtn.Name                = "TL_PL_SearchClear"
    searchClearBtn.Size                = UDim2.new(0, 20, 0, 20)
    searchClearBtn.AnchorPoint          = Vector2.new(1, 0.5)
    searchClearBtn.Position             = UDim2.new(1, -6, 0.5, 0)
    searchClearBtn.BackgroundTransparency = 1
    searchClearBtn.Font                 = Enum.Font.GothamBold
    searchClearBtn.Text                 = "\xC3\x97" -- "×"
    searchClearBtn.TextSize             = 14
    searchClearBtn.TextColor3           = C.sub or Color3.fromRGB(120, 120, 130)
    searchClearBtn.Visible              = false
    searchClearBtn.ZIndex               = 6

    searchBox.Focused:Connect(function()
        twP(search_Stroke, 0.15, { Color = C.accent, Transparency = 0.45 })
        twP(searchUnderline, 0.15, { BackgroundTransparency = 0 })
    end)
    searchBox.FocusLost:Connect(function()
        twP(search_Stroke, 0.15, { Color = C.bg3 or _C3_BG3, Transparency = 0.3 })
        if _plFilterText == "" then
            twP(searchUnderline, 0.15, { BackgroundTransparency = 1 })
        end
    end)

    -- ============================================================
    -- LIVE RESULT DROPDOWN (replaces card filtering while searching)
    -- ============================================================
    local DROPDOWN_ROW_H               = 40
    local DROPDOWN_MAX_ROWS            = 6

    local dropdownFrame                 = Instance.new("Frame", c)
    dropdownFrame.Name                  = "TL_PL_Dropdown"
    dropdownFrame.Size                  = UDim2.new(1, -PAD * 2, 0, 0)
    dropdownFrame.Position              = UDim2.new(0, PAD, 0, 6 + 28) -- directly under searchFrame
    dropdownFrame.BackgroundColor3      = C.bg2 or _C3_BG2
    dropdownFrame.BackgroundTransparency = 0
    dropdownFrame.BorderSizePixel       = 0
    dropdownFrame.ClipsDescendants      = true
    dropdownFrame.Visible               = false
    corner(dropdownFrame, 4) -- sharp corners, matches searchbar
    local dropdownStroke                = _makeDummyStroke(dropdownFrame)
    dropdownStroke.Thickness            = 1
    dropdownStroke.Color                = C.bg3 or _C3_BG3
    dropdownStroke.Transparency         = 0.3

    local dropdownList                  = Instance.new("ScrollingFrame", dropdownFrame)
    dropdownList.Name                   = "TL_PL_DropdownList"
    dropdownList.Size                   = UDim2.new(1, 0, 1, 0)
    dropdownList.BackgroundTransparency  = 1
    dropdownList.BorderSizePixel        = 0
    dropdownList.ScrollBarThickness     = 3
    dropdownList.CanvasSize             = UDim2.new(0, 0, 0, 0)

    local dropdownEmptyLbl              = Instance.new("TextLabel", dropdownFrame)
    dropdownEmptyLbl.Name               = "TL_PL_DropdownEmpty"
    dropdownEmptyLbl.Size               = UDim2.new(1, 0, 1, 0)
    dropdownEmptyLbl.BackgroundTransparency = 1
    dropdownEmptyLbl.Font               = Enum.Font.Gotham
    dropdownEmptyLbl.TextSize           = 12
    dropdownEmptyLbl.TextColor3         = C.sub or Color3.fromRGB(150, 150, 160)
    dropdownEmptyLbl.Text               = "No player found"
    dropdownEmptyLbl.Visible            = false

    local dropdownRowCache              = {} -- userId -> row instances, reused across filters

    -- tracks which player (if any) is "pinned open" after being picked from the dropdown
    local _pickedUserId                 = nil

    local function getThreatRankInfo(pl)
        local role = (_TL_refs and _TL_refs._TL_getThreatRole and _TL_refs._TL_getThreatRole(pl)) or nil
        if not role then
            return "Player", (C.bg3 or _C3_BG3), 0.35, (C.sub or Color3.fromRGB(120, 120, 130))
        end
        local lowRole     = role:lower()
        local displayRole = role:gsub("^Group Role: ", "")
        local isOwner     = lowRole:find("owner") or lowRole:find("besitzer")
        local isAdmin     = lowRole:find("admin") or lowRole:find("administrator")
        local isMod       = lowRole:find("moderator") or lowRole:find("mod")
        local isManager   = lowRole:find("manager") or lowRole:find("management")
        local isCreator   = lowRole:find("creator") or lowRole:find("star") or lowRole:find("video") or lowRole:find("influencer")

        if isOwner then
            return displayRole, Color3.fromRGB(255, 200, 0), 0.2, Color3.new(1, 1, 1)
        elseif isManager or isAdmin or isMod then
            return displayRole, Color3.fromRGB(220, 40, 40), 0.2, Color3.new(1, 1, 1)
        elseif isCreator then
            return displayRole, Color3.fromRGB(0, 140, 255), 0.2, Color3.new(1, 1, 1)
        end
        return displayRole, (C.bg3 or _C3_BG3), 0.35, (C.sub or Color3.fromRGB(120, 120, 130))
    end

    -- forward-declared; assigned once createRow/rebuildList exist below
    local rebuildList
    local selectPlayer

    local function createDropdownRow(pl)
        local row                      = Instance.new("TextButton", dropdownList)
        row.Name                       = "ddRow_" .. pl.UserId
        row.Size                       = UDim2.new(1, 0, 0, DROPDOWN_ROW_H)
        row.BackgroundColor3           = C.bg2 or _C3_BG2
        row.BackgroundTransparency     = 0
        row.BorderSizePixel            = 0
        row.AutoButtonColor            = false
        row.Text                       = ""
        row.ZIndex                     = 7

        local avF                       = Instance.new("Frame", row)
        avF.Size                        = UDim2.new(0, 26, 0, 26)
        avF.Position                    = UDim2.new(0, 8, 0.5, -13)
        avF.BackgroundColor3            = C.bg3 or _C3_BG3
        avF.BackgroundTransparency      = 0.2
        avF.BorderSizePixel             = 0
        corner(avF, 99)
        local clipF                      = Instance.new("Frame", avF)
        clipF.Size                       = UDim2.new(1, 0, 1, 0)
        clipF.BackgroundTransparency     = 1
        clipF.ClipsDescendants           = true
        corner(clipF, 99)
        local avatar                      = Instance.new("ImageLabel", clipF)
        avatar.Size                       = UDim2.new(1, 0, 1, 0)
        avatar.BackgroundTransparency     = 1
        avatar.ScaleType                  = Enum.ScaleType.Crop
        avatar.ZIndex                     = 8
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

        local nameLbl                    = Instance.new("TextLabel", row)
        nameLbl.Size                      = UDim2.new(1, -140, 0, 16)
        nameLbl.Position                  = UDim2.new(0, 42, 0, 6)
        nameLbl.BackgroundTransparency    = 1
        nameLbl.Font                      = Enum.Font.GothamBold
        nameLbl.TextSize                  = 12
        nameLbl.TextColor3                = C.text or Color3.new(1, 1, 1)
        nameLbl.TextXAlignment             = Enum.TextXAlignment.Left
        nameLbl.TextTruncate               = Enum.TextTruncate.AtEnd
        nameLbl.Text                       = pl.DisplayName

        local userLbl                     = Instance.new("TextLabel", row)
        userLbl.Size                      = UDim2.new(1, -140, 0, 12)
        userLbl.Position                  = UDim2.new(0, 42, 0, 21)
        userLbl.BackgroundTransparency    = 1
        userLbl.Font                      = Enum.Font.Gotham
        userLbl.TextSize                  = 9
        userLbl.TextColor3                = C.sub or Color3.fromRGB(120, 120, 130)
        userLbl.TextXAlignment             = Enum.TextXAlignment.Left
        userLbl.TextTruncate               = Enum.TextTruncate.AtEnd
        userLbl.Text                       = "@" .. pl.Name

        local rankLabel, rankBgCol, rankBgTrans, rankTextCol = getThreatRankInfo(pl)
        local rankBg                      = Instance.new("Frame", row)
        rankBg.Size                       = UDim2.new(0, 74, 0, 16)
        rankBg.AnchorPoint                = Vector2.new(1, 0.5)
        rankBg.Position                   = UDim2.new(1, -10, 0.5, 0)
        rankBg.BackgroundColor3           = rankBgCol
        rankBg.BackgroundTransparency     = rankBgTrans
        rankBg.BorderSizePixel            = 0
        corner(rankBg, 99)
        local rankTxt                       = Instance.new("TextLabel", rankBg)
        rankTxt.Size                        = UDim2.new(1, 0, 1, 0)
        rankTxt.BackgroundTransparency      = 1
        rankTxt.Font                        = Enum.Font.GothamBold
        rankTxt.TextSize                    = 8
        rankTxt.Text                        = rankLabel
        rankTxt.TextColor3                  = rankTextCol
        rankTxt.TextXAlignment              = Enum.TextXAlignment.Center
        rankTxt.TextTruncate                = Enum.TextTruncate.AtEnd

        row.MouseEnter:Connect(function()
            playHoverSound()
            twP(row, 0.08, { BackgroundColor3 = C.bg3 or _C3_BG3 })
        end)
        row.MouseLeave:Connect(function()
            twP(row, 0.08, { BackgroundColor3 = C.bg2 or _C3_BG2 })
        end)
        row.MouseButton1Click:Connect(function()
            if selectPlayer then selectPlayer(pl) end
        end)

        panelColorHooks[#panelColorHooks + 1] = function()
            pcall(function() row.BackgroundColor3 = C.bg2 or _C3_BG2 end)
            pcall(function() avF.BackgroundColor3 = C.bg3 or _C3_BG3 end)
            pcall(function() nameLbl.TextColor3 = C.text end)
            pcall(function() userLbl.TextColor3 = C.sub end)
        end

        return row
    end

    local function rebuildDropdown()
        local filter = _plFilterText:lower()
        dropdownList:ClearAllChildren()
        dropdownRowCache = {}

        if filter == "" then
            _currentDropdownH = 0
            dropdownFrame.Visible = false
            dropdownFrame.Size = UDim2.new(1, -PAD * 2, 0, 0)
            return
        end

        local matches = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                if pl.Name:lower():find(filter, 1, true) or pl.DisplayName:lower():find(filter, 1, true) then
                    table.insert(matches, pl)
                end
            end
        end
        table.sort(matches, function(a, b) return a.Name < b.Name end)

        dropdownFrame.Visible = true

        if #matches == 0 then
            _currentDropdownH = 48
            dropdownEmptyLbl.Visible = true
            dropdownFrame.Size = UDim2.new(1, -PAD * 2, 0, 48)
            return
        end

        dropdownEmptyLbl.Visible = false
        for i, pl in ipairs(matches) do
            local row = createDropdownRow(pl)
            row.Position = UDim2.new(0, 0, 0, (i - 1) * DROPDOWN_ROW_H)
            dropdownRowCache[pl.UserId] = row
        end

        local visibleRows = math.min(#matches, DROPDOWN_MAX_ROWS)
        _currentDropdownH = visibleRows * DROPDOWN_ROW_H
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, #matches * DROPDOWN_ROW_H)
        dropdownFrame.Size = UDim2.new(1, -PAD * 2, 0, _currentDropdownH)
    end

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

    -- ============================================================
    -- rebuildList now has 3 states:
    --  1) filter == "" and no pick            -> show ALL cards (unchanged default)
    --  2) filter ~= ""                        -> hide ALL cards, show dropdown instead
    --  3) filter == "" but a player was picked -> show ONLY that player's card
    -- ============================================================
    rebuildList = function()
        local plrs      = Players:GetPlayers()
        local activeIds = {}

        for _, pl in ipairs(plrs) do activeIds[pl.UserId] = true end
        for uid, entry in pairs(rowCache) do
            if not activeIds[uid] then
                entry.row:Destroy(); rowCache[uid] = nil
            end
        end

        -- searching: dropdown owns the UI, cards panel stays empty
        if _plFilterText ~= "" then
            for _, entry in pairs(rowCache) do entry.row.Visible = false end
            noResultsLbl.Visible = false
            hdrLine.Visible = false
            local panelH = HEADER_H + 6 + _currentDropdownH + 16
            p.Size = UDim2.new(0, PANEL_W, 0, panelH)
            c.CanvasSize = UDim2.new(0, 0, 0, panelH)
            if countLbl and countLbl.Parent then countLbl.Text = tostring(#plrs) end
            return
        end

        hdrLine.Visible = true

        table.sort(plrs, function(a, b)
            local aMod = _TL_refs and _TL_refs._TL_isThreatPlayer and _TL_refs._TL_isThreatPlayer(a) or false
            local bMod = _TL_refs and _TL_refs._TL_isThreatPlayer and _TL_refs._TL_isThreatPlayer(b) or false
            if aMod ~= bMod then return aMod end
            return a.Name < b.Name
        end)

        local visIdx = 0
        for _, pl in ipairs(plrs) do
            if pl == Players.LocalPlayer then continue end

            -- if a player was picked from the dropdown, only that card shows
            local show = (_pickedUserId == nil) or (_pickedUserId == pl.UserId)

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

        if visIdx == 0 and _pickedUserId ~= nil then
            -- picked player left the game mid-view
            _pickedUserId = nil
            noResultsLbl.Visible = false
            c.CanvasSize = UDim2.new(0, 0, 0, 0)
        else
            noResultsLbl.Visible = false
            c.CanvasSize = UDim2.new(0, 0, 0, math.max(ROW_H_ACTUAL, contentH))
        end

        local minH = HEADER_H + (ROW_H_ACTUAL + GAP) * 3 + 16
        p.Size = UDim2.new(0, PANEL_W, 0, math.max(minH, math.min(contentH, 420)))
    end

    -- called when a dropdown row is clicked: pin that player's card, clear the search
    selectPlayer = function(pl)
        _pickedUserId = pl.UserId
        searchBox.Text = ""
        -- Text change already triggers rebuildDropdown+rebuildList via the signal below,
        -- but we set _pickedUserId first so rebuildList shows only this player.
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        _plFilterText = searchBox.Text or ""
        searchClearBtn.Visible = (_plFilterText ~= "")
        if _plFilterText ~= "" then
            _pickedUserId = nil -- typing again clears any pinned single-card view
            twP(searchUnderline, 0.15, { BackgroundTransparency = 0 })
        elseif not searchBox:IsFocused() then
            twP(searchUnderline, 0.15, { BackgroundTransparency = 1 })
        end
        rebuildDropdown()
        rebuildList()
    end)

    searchClearBtn.MouseButton1Click:Connect(function()
        searchBox.Text = ""
        searchBox:CaptureFocus()
    end)

    panelColorHooks[#panelColorHooks + 1] = function()
        pcall(function() p.BackgroundColor3 = C.panelBg end)
        pcall(function() countBadge.BackgroundColor3 = C.accent end)
        pcall(function() countLbl.TextColor3 = C.accent end)
        pcall(function() hdrLine.BackgroundColor3 = C.bg3 or _C3_BG3 end)
        pcall(function() searchFrame.BackgroundColor3 = C.bg2 or _C3_BG2 end)
        pcall(function() search_Stroke.Color = C.bg3 or _C3_BG3 end)
        pcall(function() searchUnderline.BackgroundColor3 = C.accent end)
        pcall(function() searchIcon.ImageColor3 = C.sub end)
        pcall(function() searchBox.TextColor3 = C.text end)
        pcall(function() searchBox.PlaceholderColor3 = C.sub end)
        pcall(function() searchClearBtn.TextColor3 = C.sub end)
        pcall(function() dropdownFrame.BackgroundColor3 = C.bg2 or _C3_BG2 end)
        pcall(function() dropdownStroke.Color = C.bg3 or _C3_BG3 end)
        pcall(function() dropdownEmptyLbl.TextColor3 = C.sub end)

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
    _TL_refs._TL_isThreatPlayer = function(plr)
        return trackedStaff[plr] ~= nil
    end
    _TL_refs._TL_getThreatRole = function(plr)
        return trackedStaff[plr]
    end
    _TL_refs._TL_checkThreatPlayer = function(plr, callback)
        runStaffCheck(_TL_refs, plr, false, 0, callback)
    end

    rebuildList()

    for _, pl in ipairs(Players:GetPlayers()) do
        runStaffCheck(_TL_refs, pl, true, 0)
    end

    self._connections[#self._connections + 1] = Players.PlayerAdded:Connect(function(pl)
        task.wait(0.15); rebuildDropdown(); rebuildList()
        runStaffCheck(_TL_refs, pl, true, 3)
    end)
    self._connections[#self._connections + 1] = Players.PlayerRemoving:Connect(function(pl)
        task.wait(0.15)
        local entry = rowCache[pl.UserId]
        if entry then
            entry.row:Destroy(); rowCache[pl.UserId] = nil
        end
        if _pickedUserId == pl.UserId then _pickedUserId = nil end
        staffCheckCache[pl] = nil
        if trackedStaff[pl] then
            local role = trackedStaff[pl]
            trackedStaff[pl] = nil
            sendStaffDetectorNotification(_TL_refs, "TLMenuSystem: Staff/Creator left",
                pl.Name .. "\nRole: " .. role .. "\nLeft the server.")
            local fn = _TL_refs and _TL_refs._TL_rebuildPlayerList
            if type(fn) == "function" then fn() end
            if not next(trackedStaff) then
                task.delay(1, function()
                    if not next(trackedStaff) then
                        sendStaffDetectorNotification(_TL_refs, "TLMenuSystem:", "No Admin/Content-Creator Ingame.")
                    end
                end)
            end
        end
        rebuildDropdown()
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
