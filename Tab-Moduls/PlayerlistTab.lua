--!nocheck

local PlayerlistTab = {}
PlayerlistTab.__index = PlayerlistTab

local trackedStaff = {}
local trackedCat   = {}
local staffCheckCache = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- ROLE SYSTEM  (merged from TL-Detector-Prototyp1.lua)
-- ─────────────────────────────────────────────────────────────────────────────

local ROLE_COLORS = {
    Owner        = Color3.fromRGB(255, 200,  0),
    Admin        = Color3.fromRGB(220,  40, 40),
    RobloxStaff  = Color3.fromRGB(255,  60, 60),
    Moderator    = Color3.fromRGB(  0, 170, 255),
    Staff        = Color3.fromRGB( 50, 140, 255),
    Creator      = Color3.fromRGB( 10,  45, 150),
    VideoStar    = Color3.fromRGB(180,  60, 220),
    Management   = Color3.fromRGB(255, 140,  0),
}
local ROLE_FALLBACK_COLOR = Color3.fromRGB(90, 95, 110)

-- Human-readable pill labels per category
local ROLE_PILL_LABEL = {
    Owner       = "Owner",
    Admin       = "Admin",
    RobloxStaff = "Roblox Staff",
    Moderator   = "Moderator",
    Staff       = "Staff",
    Creator     = "Content Creator",
    VideoStar   = "Video Star",
    Management  = "Management",
}

-- ─────────────────────────────────────────────────────────────────────────────
-- RANK MANAGER  (RoProxy HTTP group-rank scanner)
-- ─────────────────────────────────────────────────────────────────────────────
local _RM_CONFIG = {
    RoProxyUrl    = "https://groups.roproxy.com/v1/users/%d/groups/roles",
    CacheTTL      = 30,
    RequestDelay  = 0.35,
    RetryAttempts = 3,
}

local RankManager = {
    _cache       = {},
    _queue       = {},
    _processing  = false,
    _connections = {},
    _listeners   = {},
}

function RankManager:Cleanup()
    for _, conn in ipairs(self._connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(self._cache)
    table.clear(self._queue)
    table.clear(self._listeners)
end

function RankManager:OnUpdate(callback)
    table.insert(self._listeners, callback)
end

local function _RM_httpGet(url)
    local ok, res = pcall(function()
        local fn = (rawget(_G, "request") or rawget(_G, "http_request")
            or (rawget(_G, "syn") and rawget(rawget(_G, "syn"), "request")))
        if not fn then error("no http fn") end
        return fn({ Url = url, Method = "GET" })
    end)
    if ok and res and (res.StatusCode == 200 or res.Success) then return res.Body end
    return nil
end

local function _RM_fetchRoProxy(userId, groupId)
    local url  = string.format(_RM_CONFIG.RoProxyUrl, userId)
    local body = _RM_httpGet(url)
    if body then
        local HttpService = game:GetService("HttpService")
        local ok, decoded = pcall(function() return HttpService:JSONDecode(body) end)
        if ok and decoded and decoded.data then
            for _, entry in ipairs(decoded.data) do
                if entry.group and entry.group.id == groupId then
                    return { rank = entry.role.rank, role = entry.role.name, failed = false }
                end
            end
            return { rank = 0, role = "Non-Member", failed = false }
        end
    end
    return nil
end

local function _RM_fetchNative(player, groupId)
    for _ = 1, _RM_CONFIG.RetryAttempts do
        local ok, rank = pcall(function() return player:GetRankInGroup(groupId) end)
        if ok then
            local _, role = pcall(function() return player:GetRoleInGroup(groupId) end)
            return { rank = rank, role = role or "Member", failed = false }
        end
        task.wait(1)
    end
    return { failed = true }
end

function RankManager:_processQueue(groupId)
    if self._processing then return end
    self._processing = true
    task.spawn(function()
        while #self._queue > 0 do
            local item = table.remove(self._queue, 1)
            local data = _RM_fetchRoProxy(item.userId, groupId)
                      or _RM_fetchNative(item.player, groupId)
            data.timestamp         = os.clock()
            self._cache[item.userId] = data
            item.callback(data)
            task.wait(_RM_CONFIG.RequestDelay)
        end
        self._processing = false
    end)
end

function RankManager:GetPlayerRank(player, groupId, callback)
    local cached = self._cache[player.UserId]
    if cached and (os.clock() - cached.timestamp) < _RM_CONFIG.CacheTTL then
        callback(cached)
        return
    end
    table.insert(self._queue, { userId = player.UserId, player = player, callback = callback })
    self:_processQueue(groupId)
end

-- ─────────────────────────────────────────────────────────────────────────────

local function sendStaffDetectorNotification(_TL_refs, title, text, color)
    local settingsState = _TL_refs and _TL_refs._TL_settingsState
    if settingsState and settingsState.notifications == false then return end
    pcall(function()
        local sendNotif = _TL_refs and _TL_refs._TL_sendNotif
        if sendNotif then
            sendNotif(title, text, 7, color or Color3.fromRGB(255, 80, 80))
        end
    end)
end

local function isPerkRole(roleName)
    local s = tostring(roleName):lower()
    return s:match("free admin") or s:match("vip") or s:match("donator") or s:match("premium")
end

local groupBaseRank = {}
local function getGroupBaseRank(groupId)
    if groupBaseRank[groupId] then return groupBaseRank[groupId] end
    local ok, info = pcall(function() return game:GetService("GroupService"):GetGroupInfoAsync(groupId) end)
    if not ok or type(info) ~= "table" or type(info.Roles) ~= "table" then return nil end
    local base
    for _, r in ipairs(info.Roles) do
        if r.Rank > 0 and (not base or r.Rank < base) then base = r.Rank end
    end
    groupBaseRank[groupId] = base or 1
    return groupBaseRank[groupId]
end

local function isThreatRole(roleName)
    if not roleName then return false end
    local s = tostring(roleName):lower()
    if isPerkRole(roleName) then
        return false
    end
    if s:match("admin") or s:match("mod") or s:match("owner") or s:match("creator")
        or s:match("staff") or s:match("youtube") or s:match("tiktok") or s:match("twitch")
        or s:match("tester") or s:match("developer") or s:match("manage") then
        return true
    end
    return false
end

local function classifyRole(text)
    if not text then return nil end
    local s = tostring(text):lower()
    if s:find("free admin", 1, true) then return nil end
    if s:find("owner", 1, true) or s:find("besitzer", 1, true) then return "Owner" end
    if s:find("manage", 1, true) or s:find("leitung", 1, true) then return "Management" end
    if s:find("youtube", 1, true) or s:find("tiktok", 1, true)
        or s:find("twitch", 1, true) or s:find("influencer", 1, true)
        or s:find("streamer", 1, true) or s:find("content creator", 1, true) then
        return "Creator"
    end
    if s:find("video star", 1, true) then return "VideoStar" end
    if s:find("creator", 1, true) then return "Creator" end
    if s:find("roblox staff", 1, true) then return "RobloxStaff" end
    if s:find("admin", 1, true) then return "Admin" end
    if s:find("moderat", 1, true) or s:find("%f[%a]mod%f[%A]") then return "Moderator" end
    if s:find("staff", 1, true) then return "Staff" end
    return nil
end

local function checkPlayerForStaff(plr, LocalPlayer)
    if not plr or plr == LocalPlayer then return false, "" end
    if not game:IsLoaded() then game.Loaded:Wait() end
    local isGroupGame = game.CreatorType == Enum.CreatorType.Group
    local creatorId = game.CreatorId

    if not isGroupGame and plr.UserId == creatorId then
        return true, "Game Owner", "Owner"
    end
    local ok, vipOwnerId = pcall(function() return (game :: any).VIPServerOwnerId end)
    if ok and vipOwnerId and vipOwnerId ~= 0 and plr.UserId == vipOwnerId then
        return true, "VIP Server Owner (Admin)", "Owner"
    end
    if isGroupGame then
        local rank, roleName
        for _ = 1, 3 do
            local okRank, r = pcall(function() return plr:GetRankInGroup(creatorId) end)
            local okRole, n = pcall(function() return plr:GetRoleInGroup(creatorId) end)
            if okRank and okRole and type(r) == "number" then
                rank, roleName = r, n
                break
            end
            task.wait(1)
        end
        if rank and rank > 0 then
            local roleStr = "Group Role: " .. tostring(roleName)
            if rank == 255 then
                return true, roleStr, "Owner"
            end

            local cat = classifyRole(roleName)
            if not cat and not isPerkRole(roleName) and rank > (getGroupBaseRank(creatorId) or 99) then
                cat = rank >= 200 and "Admin" or "Moderator"
            end
            if cat or isThreatRole(roleName) then
                return true, roleStr, cat
            end
        end
    end

    local successRoblox, rankRoblox = pcall(function() return plr:GetRankInGroup(1200769) end)
    if successRoblox and type(rankRoblox) == "number" and rankRoblox > 0 then
        return true, "Roblox Staff", "RobloxStaff"
    end

    local successStar, rankStar = pcall(function() return plr:GetRankInGroup(4199740) end)
    if successStar and type(rankStar) == "number" and rankStar > 0 then
        return true, "Roblox Video Star", "VideoStar"
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

local function getStaffInfo(plr)
    local role = trackedStaff[plr]
    if not role then return nil end
    local label = tostring(role):gsub("^Group Role: ", "")
    local cat = trackedCat[plr]
    return label, (cat and ROLE_COLORS[cat]) or ROLE_FALLBACK_COLOR, cat
end

local function setStaffState(_TL_refs, plr, isStaff, role, notifyOnDetect, category)
    local previousRole, previousCat = trackedStaff[plr], trackedCat[plr]
    local normalizedRole = (isStaff and role and role ~= "") and role or nil
    local cat = normalizedRole and (category or classifyRole(normalizedRole)) or nil
    staffCheckCache[plr] = normalizedRole and { role = normalizedRole, cat = cat } or false
    trackedStaff[plr] = normalizedRole
    trackedCat[plr] = cat
    if notifyOnDetect and normalizedRole and not previousRole then
        sendStaffDetectorNotification(_TL_refs, "Staff/Creator detected",
            plr.Name .. "\nRole: " .. normalizedRole, cat and ROLE_COLORS[cat])
    end
    if previousRole ~= normalizedRole or previousCat ~= cat then
        local fn = _TL_refs and _TL_refs._TL_rebuildPlayerList
        if type(fn) == "function" then fn() end
    end
end

local function runStaffCheck(_TL_refs, plr, notifyOnDetect, delaySec, onDone, LocalPlayer)
    if not plr or plr == LocalPlayer then
        if onDone then onDone(false, "") end
        return
    end
    task.spawn(function()
        if delaySec and delaySec > 0 then
            task.wait(delaySec)
        end
        if not plr.Parent then
            if onDone then onDone(false, "") end
            return
        end
        local cached = staffCheckCache[plr]
        if cached ~= nil then
            local isStaff = cached ~= false
            setStaffState(_TL_refs, plr, isStaff, isStaff and cached.role or nil, notifyOnDetect, isStaff and cached.cat or nil)
            if onDone then onDone(isStaff, isStaff and cached.role or "") end
            return
        end
        local isStaff, role, cat = checkPlayerForStaff(plr, LocalPlayer)
        setStaffState(_TL_refs, plr, isStaff, role, notifyOnDetect, cat)
        if onDone then onDone(isStaff, role) end
    end)
end

function PlayerlistTab.Init(ctx)
    ctx = type(ctx) == "table" and ctx or {}
    local game = ctx.game or game
    local _genv = ctx._genv or (getgenv and getgenv()) or _G or {}
    local _SvcUIS = game:GetService("UserInputService")
    local _SvcRS  = game:GetService("RunService")
    local _SvcPlr = ctx.Players or game:GetService("Players")
    local Players = _SvcPlr
    local LocalPlayer = ctx.LocalPlayer or Players.LocalPlayer
    local TweenService = game:GetService("TweenService")

    local function corner(parent, r)
        if ctx.corner then return ctx.corner(parent, r) end
        if not parent then return nil end
        local c = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, r or 8)
        c.Parent = parent
        return c
    end

    local function stroke(parent, thick, col, trans)
        if ctx.stroke then return ctx.stroke(parent, thick, col, trans) end
        if not parent then return nil end
        local s = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
        s.Thickness = thick or 1
        s.Color = col or Color3.fromRGB(255, 255, 255)
        s.Transparency = trans or 0
        s.Parent = parent
        return s
    end

    local function _makeDummyStroke(parent, thick, col, trans)
        if ctx._makeDummyStroke then return ctx._makeDummyStroke(parent, thick, col, trans) end
        return stroke(parent, thick, col, trans)
    end

    local twP = ctx.twP or function(inst, dur, props, style, dir)
        if not inst then return end
        pcall(function()
            local tw = TweenService:Create(
                inst,
                TweenInfo.new(dur or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
                props
            )
            tw:Play()
        end)
    end

    local _tlTrackInst = ctx._tlTrackInst or function(inst)
        local allInsts = _genv._TLAllInsts
        if type(allInsts) == "table" and inst then
            table.insert(allInsts, inst)
        end
        return inst
    end

    local getRootPart = ctx.getRootPart or function()
        local char = LocalPlayer and LocalPlayer.Character
        return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
    end

    local playHoverSound = ctx.playHoverSound or function()
        pcall(function()
            local sc = ctx._sc
            if sc and type(sc._playHoverSound) == "function" then
                sc._playHoverSound()
            end
        end)
    end

    local _C3_DEF_BG   = Color3.fromRGB(18, 18, 20)
    local _C3_DEF_BG2  = Color3.fromRGB(26, 26, 28)
    local _C3_DEF_BG3  = Color3.fromRGB(34, 34, 38)
    local _C3_DEF_ACC  = Color3.fromRGB(0, 170, 255)
    local _C3_DEF_SUB  = Color3.fromRGB(130, 135, 145)
    local _C3_DEF_TXT  = Color3.fromRGB(255, 255, 255)

    local C = ctx.C or {
        accent = _C3_DEF_ACC,
        accent2 = Color3.fromRGB(0, 200, 255),
        sub = _C3_DEF_SUB,
        text = _C3_DEF_TXT,
        panelBg = _C3_DEF_BG,
        bg2 = _C3_DEF_BG2,
        bg3 = _C3_DEF_BG3,
        panelHdr = _C3_DEF_BG2,
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
    local PlayerGui = ctx.PlayerGui or (LocalPlayer and (LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)))
    local _C3_BG2 = ctx._C3_BG2 or C.bg2 or _C3_DEF_BG2
    local _C3_BG3 = ctx._C3_BG3 or C.bg3 or _C3_DEF_BG3
    local _TL_refs = ctx._TL_refs or {}
    local _TL_activeThemeId = ctx._TL_activeThemeId or (_genv and _genv._TL_activeThemeId) or "default"
    local panelColorHooks = ctx.panelColorHooks or (_genv and _genv._panelColorHooks) or {}

    local makePanel = ctx.makePanel or function(name, accent)
        local p = Instance.new("Frame")
        p.Name = name
        p.Size = UDim2.new(0, PANEL_W, 0, 420)
        p.BorderSizePixel = 0
        local c = Instance.new("ScrollingFrame", p)
        c.Name = "Content"
        c.Size = UDim2.new(1, 0, 1, 0)
        c.BackgroundTransparency = 1
        c.BorderSizePixel = 0
        c.ScrollBarThickness = 4
        return p, c
    end

    local p, c = makePanel("Playerlist", C.accent)
    p.BackgroundColor3 = C.panelBg
    p.BackgroundTransparency = 0
    local _eg = p:FindFirstChildOfClass("UIGradient"); if _eg then _eg:Destroy() end

    local function isOnePieceTheme(tId)
        local id = tId or (ctx and ctx._TL_activeThemeId)
            or (_TL_refs and _TL_refs._TL_activeThemeId)
            or (_genv and _genv._TL_activeThemeId)
            or "default"
        return tostring(id):lower() == "onepiece"
    end

    local _OP_PlBgImg                  = Instance.new("ImageLabel")
    _OP_PlBgImg.Name                   = "OnePieceBg"
    _OP_PlBgImg.Size                   = UDim2.new(1, 0, 1, 0)
    _OP_PlBgImg.Position               = UDim2.new(0, 0, 0, 0)
    _OP_PlBgImg.BackgroundTransparency = 1
    _OP_PlBgImg.Image                  = "rbxassetid://132090006833323"
    _OP_PlBgImg.ScaleType              = Enum.ScaleType.Crop
    _OP_PlBgImg.ImageTransparency      = 0.35
    _OP_PlBgImg.ZIndex                 = 1
    _OP_PlBgImg.Visible                = isOnePieceTheme(_TL_activeThemeId)
    _OP_PlBgImg.Parent                 = p
    corner(_OP_PlBgImg, 12)
    if _TL_refs then
        _TL_refs._OP_PlBgImg          = _OP_PlBgImg
    end

    local PAD                         = 16
    local PW                          = PANEL_W - PAD * 2
    local ROW_H_ACTUAL                = 70
    local GAP                         = 6
    local avatarCache                 = {}
    local rowCache                    = {}
    local espHighlights               = {}
    local _plFilterText               = ""
    local _currentDropdownH           = 0

    local HEADER_H                    = 44
    local SEARCH_ICON_ASSET           = "rbxassetid://3926305904"
    local SEARCH_ICON_RECT_OFFSET     = Vector2.new(964, 324)
    local SEARCH_ICON_RECT_SIZE       = Vector2.new(36, 36)

    local countBadge                  = Instance.new("Frame", c)
    countBadge.Size                   = UDim2.new(0, 36, 0, 20)
    countBadge.Position               = UDim2.new(1, -PAD - 36, 0, 12)
    countBadge.BackgroundColor3       = C.accent
    countBadge.BackgroundTransparency = 0.72
    countBadge.BorderSizePixel        = 0
    corner(countBadge, 99)
    local countLbl                    = Instance.new("TextLabel", countBadge)
    countLbl.Size                     = UDim2.new(1, 0, 1, 0)
    countLbl.BackgroundTransparency   = 1
    countLbl.Font                     = Enum.Font.GothamBlack
    countLbl.TextSize                 = 10
    countLbl.TextColor3               = C.accent
    countLbl.TextXAlignment           = Enum.TextXAlignment.Center
    countLbl.Text                     = tostring(#Players:GetPlayers())

    local searchFrame                 = Instance.new("Frame", c)
    searchFrame.Name                  = "TL_PL_SearchFrame"
    searchFrame.Size                  = UDim2.new(1, -PAD * 2, 0, 28)
    searchFrame.Position              = UDim2.new(0, PAD, 0, 6)
    searchFrame.BackgroundColor3      = C.bg2 or _C3_BG2
    searchFrame.BackgroundTransparency = 0
    searchFrame.BorderSizePixel       = 0
    searchFrame.ClipsDescendants      = false
    corner(searchFrame, 4)

    local search_Stroke               = _makeDummyStroke(searchFrame)
    search_Stroke.Thickness           = 1
    search_Stroke.Color               = C.bg3 or _C3_BG3
    search_Stroke.Transparency        = 0.3

    local searchUnderline             = Instance.new("Frame", searchFrame)
    searchUnderline.Name              = "TL_PL_SearchUnderline"
    searchUnderline.AnchorPoint       = Vector2.new(0, 1)
    searchUnderline.Size              = UDim2.new(1, 0, 0, 2)
    searchUnderline.Position          = UDim2.new(0, 0, 1, 1)
    searchUnderline.BackgroundColor3  = C.accent
    searchUnderline.BackgroundTransparency = 1
    searchUnderline.BorderSizePixel   = 0
    searchUnderline.ZIndex            = 6

    local searchIcon                  = Instance.new("ImageLabel", searchFrame)
    searchIcon.Name                   = "TL_PL_SearchIcon"
    searchIcon.Size                   = UDim2.new(0, 14, 0, 14)
    searchIcon.Position               = UDim2.new(0, 10, 0.5, -7)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image                  = SEARCH_ICON_ASSET
    searchIcon.ImageRectOffset        = SEARCH_ICON_RECT_OFFSET
    searchIcon.ImageRectSize          = SEARCH_ICON_RECT_SIZE
    searchIcon.ImageColor3            = C.sub or Color3.fromRGB(120, 120, 130)
    searchIcon.ScaleType              = Enum.ScaleType.Fit

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

    local searchClearBtn              = Instance.new("TextButton", searchFrame)
    searchClearBtn.Name               = "TL_PL_SearchClear"
    searchClearBtn.Size               = UDim2.new(0, 20, 0, 20)
    searchClearBtn.AnchorPoint         = Vector2.new(1, 0.5)
    searchClearBtn.Position            = UDim2.new(1, -6, 0.5, 0)
    searchClearBtn.BackgroundTransparency = 1
    searchClearBtn.Font                = Enum.Font.GothamBold
    searchClearBtn.Text                = "\xC3\x97"
    searchClearBtn.TextSize            = 14
    searchClearBtn.TextColor3          = C.sub or Color3.fromRGB(120, 120, 130)
    searchClearBtn.Visible             = false
    searchClearBtn.ZIndex              = 6

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

    local DROPDOWN_ROW_H              = 40
    local DROPDOWN_MAX_ROWS           = 6

    local dropdownFrame               = Instance.new("Frame", c)
    dropdownFrame.Name                = "TL_PL_Dropdown"
    dropdownFrame.Size                = UDim2.new(1, -PAD * 2, 0, 0)
    dropdownFrame.Position            = UDim2.new(0, PAD, 0, 6 + 28)
    dropdownFrame.BackgroundColor3    = C.bg2 or _C3_BG2
    dropdownFrame.BackgroundTransparency = 0
    dropdownFrame.BorderSizePixel     = 0
    dropdownFrame.ClipsDescendants    = true
    dropdownFrame.Visible             = false
    corner(dropdownFrame, 4)
    local dropdownStroke              = _makeDummyStroke(dropdownFrame)
    dropdownStroke.Thickness          = 1
    dropdownStroke.Color              = C.bg3 or _C3_BG3
    dropdownStroke.Transparency       = 0.3

    local dropdownList                = Instance.new("ScrollingFrame", dropdownFrame)
    dropdownList.Name                 = "TL_PL_DropdownList"
    dropdownList.Size                 = UDim2.new(1, 0, 1, 0)
    dropdownList.BackgroundTransparency = 1
    dropdownList.BorderSizePixel      = 0
    dropdownList.ScrollBarThickness   = 3
    dropdownList.CanvasSize           = UDim2.new(0, 0, 0, 0)

    local dropdownEmptyLbl            = Instance.new("TextLabel", dropdownFrame)
    dropdownEmptyLbl.Name             = "TL_PL_DropdownEmpty"
    dropdownEmptyLbl.Size             = UDim2.new(1, 0, 1, 0)
    dropdownEmptyLbl.BackgroundTransparency = 1
    dropdownEmptyLbl.Font             = Enum.Font.Gotham
    dropdownEmptyLbl.TextSize         = 12
    dropdownEmptyLbl.TextColor3       = C.sub or Color3.fromRGB(150, 150, 160)
    dropdownEmptyLbl.Text             = "No player found"
    dropdownEmptyLbl.Visible          = false

    local dropdownRowCache            = {}
    local _pickedUserId               = nil

    local _SvcText = game:GetService("TextService")
    local function pillWidth(label, minW, maxW)
        local w
        local ok, size = pcall(function()
            return _SvcText:GetTextSize(label, 8, Enum.Font.GothamBold, Vector2.new(1000, 20))
        end)
        if ok and size then w = size.X else w = #label * 6 end
        return math.clamp(math.ceil(w) + 18, minW, maxW)
    end

    local function getThreatRankInfo(pl)
        local _, color, cat = getStaffInfo(pl)
        if not cat then
            -- Default: "User" pill (grey)
            return "User", (C.bg3 or _C3_BG3), 0.35, (C.sub or Color3.fromRGB(120, 120, 130))
        end
        -- Map category to friendly pill label
        local pillLabel = ROLE_PILL_LABEL[cat] or cat
        return pillLabel, color, 0.15, Color3.new(1, 1, 1)
    end

    local rebuildList
    local selectPlayer

    local function createDropdownRow(pl)
        local row                     = Instance.new("TextButton", dropdownList)
        row.Name                      = "ddRow_" .. pl.UserId
        row.Size                      = UDim2.new(1, 0, 0, DROPDOWN_ROW_H)
        row.BackgroundColor3          = C.bg2 or _C3_BG2
        row.BackgroundTransparency    = 0
        row.BorderSizePixel           = 0
        row.AutoButtonColor           = false
        row.Text                      = ""
        row.ZIndex                    = 7

        local avF                     = Instance.new("Frame", row)
        avF.Size                      = UDim2.new(0, 26, 0, 26)
        avF.Position                  = UDim2.new(0, 8, 0.5, -13)
        avF.BackgroundColor3          = C.bg3 or _C3_BG3
        avF.BackgroundTransparency    = 0.2
        avF.BorderSizePixel           = 0
        corner(avF, 99)
        local clipF                   = Instance.new("Frame", avF)
        clipF.Size                    = UDim2.new(1, 0, 1, 0)
        clipF.BackgroundTransparency  = 1
        clipF.ClipsDescendants        = true
        corner(clipF, 99)
        local avatar                  = Instance.new("ImageLabel", clipF)
        avatar.Size                   = UDim2.new(1, 0, 1, 0)
        avatar.BackgroundTransparency = 1
        avatar.ScaleType              = Enum.ScaleType.Crop
        avatar.ZIndex                 = 8
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

        local nameLbl                 = Instance.new("TextLabel", row)
        nameLbl.Size                  = UDim2.new(1, -140, 0, 16)
        nameLbl.Position              = UDim2.new(0, 42, 0, 6)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font                  = Enum.Font.GothamBold
        nameLbl.TextSize              = 12
        nameLbl.TextColor3            = C.text or Color3.new(1, 1, 1)
        nameLbl.TextXAlignment        = Enum.TextXAlignment.Left
        nameLbl.TextTruncate          = Enum.TextTruncate.AtEnd
        nameLbl.Text                  = pl.DisplayName

        local userLbl                 = Instance.new("TextLabel", row)
        userLbl.Size                  = UDim2.new(1, -140, 0, 12)
        userLbl.Position              = UDim2.new(0, 42, 0, 21)
        userLbl.BackgroundTransparency = 1
        userLbl.Font                  = Enum.Font.Gotham
        userLbl.TextSize              = 9
        userLbl.TextColor3            = C.sub or Color3.fromRGB(120, 120, 130)
        userLbl.TextXAlignment        = Enum.TextXAlignment.Left
        userLbl.TextTruncate          = Enum.TextTruncate.AtEnd
        userLbl.Text                  = "@" .. pl.Name

        local rankLabel, rankBgCol, rankBgTrans, rankTextCol = getThreatRankInfo(pl)
        local rankBg                  = Instance.new("Frame", row)
        rankBg.Size                   = UDim2.new(0, pillWidth(rankLabel, 52, 96), 0, 16)
        rankBg.AnchorPoint            = Vector2.new(1, 0.5)
        rankBg.Position               = UDim2.new(1, -10, 0.5, 0)
        rankBg.BackgroundColor3       = rankBgCol
        rankBg.BackgroundTransparency = rankBgTrans
        rankBg.BorderSizePixel        = 0
        corner(rankBg, 99)
        local rankTxt                 = Instance.new("TextLabel", rankBg)
        rankTxt.Size                  = UDim2.new(1, 0, 1, 0)
        rankTxt.BackgroundTransparency = 1
        rankTxt.Font                  = Enum.Font.GothamBold
        rankTxt.TextSize              = 8
        rankTxt.Text                  = rankLabel
        rankTxt.TextColor3            = rankTextCol
        rankTxt.TextXAlignment        = Enum.TextXAlignment.Center
        rankTxt.TextTruncate          = Enum.TextTruncate.AtEnd

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

    local hdrLine                     = Instance.new("Frame", c)
    hdrLine.Size                      = UDim2.new(1, -PAD * 2, 0, 1)
    hdrLine.Position                  = UDim2.new(0, PAD, 0, HEADER_H - 2)
    hdrLine.BackgroundColor3          = C.bg3 or _C3_BG3
    hdrLine.BackgroundTransparency    = 0.3
    hdrLine.BorderSizePixel           = 0

    local noResultsLbl                = Instance.new("TextLabel", c)
    noResultsLbl.Size                 = UDim2.new(1, -PAD * 2, 1, -HEADER_H)
    noResultsLbl.Position             = UDim2.new(0, PAD, 0, HEADER_H)
    noResultsLbl.BackgroundTransparency = 1
    noResultsLbl.Text                 = ""
    noResultsLbl.Font                 = Enum.Font.Gotham
    noResultsLbl.TextSize             = 13
    noResultsLbl.TextColor3           = C.sub or Color3.fromRGB(150, 150, 160)
    noResultsLbl.TextXAlignment       = Enum.TextXAlignment.Center
    noResultsLbl.Visible              = false

    local function makePillBtn(parent, xScale, xOff, w, label, accentC)
        local col                = accentC or C.accent
        local f                  = Instance.new("Frame", parent)
        f.Size                   = UDim2.new(0, w, 0, 22)
        f.Position               = UDim2.new(xScale, xOff, 0.5, -11)
        f.BackgroundColor3       = col
        f.BackgroundTransparency = 0.72
        f.BorderSizePixel        = 0
        corner(f, 6)
        local s                  = _makeDummyStroke(f)
        s.Thickness              = 0; s.Color = col; s.Transparency = 1
        local tb                 = Instance.new("TextButton", f)
        tb.Size                  = UDim2.new(1, 0, 1, 0)
        tb.BackgroundTransparency = 1
        tb.Text                  = label:upper()
        tb.Font                  = Enum.Font.GothamBlack
        tb.TextSize              = 9
        tb.TextColor3            = col
        tb.ZIndex                = 8
        tb.Active                = true

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

        local avF                   = Instance.new("Frame", card)
        avF.Name                    = "avF"
        avF.Size                    = UDim2.new(0, 42, 0, 42)
        avF.Position                = UDim2.new(0, 12, 0.5, -21)
        avF.BackgroundColor3        = C.bg3 or _C3_BG3
        avF.BackgroundTransparency  = 0.2
        avF.BorderSizePixel         = 0
        corner(avF, 99)
        local clipF                 = Instance.new("Frame", avF)
        clipF.Size                  = UDim2.new(1, 0, 1, 0)
        clipF.BackgroundTransparency = 1
        clipF.ClipsDescendants      = true
        corner(clipF, 99)
        local avatar                = Instance.new("ImageLabel", clipF)
        avatar.Size                 = UDim2.new(1, 0, 1, 0)
        avatar.BackgroundTransparency = 1
        avatar.ScaleType            = Enum.ScaleType.Crop
        avatar.ZIndex               = 4
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
        local ring                  = _makeDummyStroke(avF)
        ring.Thickness              = 1.5
        ring.Color                  = col
        ring.Transparency           = 0.35

        local NX                    = 62
        local nameLbl               = Instance.new("TextLabel", card)
        nameLbl.Size                = UDim2.new(0, PW - NX - 4, 0, 18)
        nameLbl.Position            = UDim2.new(0, NX, 0, 8)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text                = pl.DisplayName
        nameLbl.Font                = Enum.Font.GothamBold
        nameLbl.TextSize            = 13
        nameLbl.TextColor3          = C.text or Color3.new(1, 1, 1)
        nameLbl.TextXAlignment      = Enum.TextXAlignment.Left
        nameLbl.TextTruncate        = Enum.TextTruncate.AtEnd

        local userLbl               = Instance.new("TextLabel", card)
        userLbl.Size                = UDim2.new(0, 160, 0, 12)
        userLbl.Position            = UDim2.new(0, NX, 0, 27)
        userLbl.BackgroundTransparency = 1
        userLbl.Text                = "@" .. pl.Name .. (isMe and "  \xE2\x98\x85" or "")
        userLbl.Font                = Enum.Font.GothamBold
        userLbl.TextSize            = 9
        userLbl.TextColor3          = C.sub or Color3.fromRGB(120, 120, 130)
        userLbl.TextXAlignment      = Enum.TextXAlignment.Left
        userLbl.TextTruncate        = Enum.TextTruncate.AtEnd

        local rankBg                = Instance.new("Frame", card)
        rankBg.Size                 = UDim2.new(0, 52, 0, 14)
        rankBg.Position             = UDim2.new(0, NX, 0, 42)
        rankBg.BackgroundColor3     = C.bg3 or _C3_BG3
        rankBg.BackgroundTransparency = 0.35
        rankBg.BorderSizePixel      = 0
        corner(rankBg, 99)
        local rankTxt               = Instance.new("TextLabel", rankBg)
        rankTxt.Size                = UDim2.new(1, 0, 1, 0)
        rankTxt.BackgroundTransparency = 1
        rankTxt.Font                = Enum.Font.GothamBold
        rankTxt.TextSize            = 8
        rankTxt.Text                = "User"
        rankTxt.TextColor3          = C.sub or Color3.fromRGB(120, 120, 130)
        rankTxt.TextXAlignment      = Enum.TextXAlignment.Center
        rankTxt.TextTruncate        = Enum.TextTruncate.AtEnd

        local function refreshThreatBadge()
            local label, bgCol, bgTrans, txtCol = getThreatRankInfo(pl)
            rankBg.BackgroundColor3       = bgCol
            rankBg.BackgroundTransparency = bgTrans
            rankBg.Size                   = UDim2.new(0, pillWidth(label, 52, 130), 0, 14)
            rankTxt.Text                  = label
            rankTxt.TextColor3            = txtCol
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
            local function doTeleport()
                if pl.Character then
                    local tR = pl.Character:FindFirstChild("HumanoidRootPart")
                    local mR = getRootPart()
                    if tR and mR then mR.CFrame = tR.CFrame * CFrame.new(0, 0, 3.5) end
                end
            end
            tpBtn.MouseButton1Click:Connect(doTeleport)
            tpBtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then doTeleport() end
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
            local specS2                 = _makeDummyStroke(specF)
            specS2.Thickness             = 0; specS2.Color = specCol; specS2.Transparency = 0.6

            local specImg                = Instance.new("TextButton", specF)
            specImg.Size                 = UDim2.new(1, 0, 1, 0)
            specImg.Position             = UDim2.new(0, 0, 0, 0)
            specImg.BackgroundTransparency = 1
            specImg.Text                 = "SPEC"
            specImg.Font                 = Enum.Font.GothamBlack
            specImg.TextSize             = 9
            specImg.TextColor3           = specCol
            specImg.ZIndex               = 8

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

    rebuildList = function()
        local plrs      = Players:GetPlayers()
        local activeIds = {}

        for _, pl in ipairs(plrs) do activeIds[pl.UserId] = true end
        for uid, entry in pairs(rowCache) do
            if not activeIds[uid] then
                entry.row:Destroy(); rowCache[uid] = nil
            end
        end

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
            if pl ~= LocalPlayer then
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
        end

        local total = #plrs
        if countLbl and countLbl.Parent then
            countLbl.Text = tostring(total)
        end

        local contentH = HEADER_H + visIdx * (ROW_H_ACTUAL + GAP) + 16

        if visIdx == 0 and _pickedUserId ~= nil then
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

    selectPlayer = function(pl)
        _pickedUserId = pl.UserId
        searchBox.Text = ""
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        _plFilterText = searchBox.Text or ""
        searchClearBtn.Visible = (_plFilterText ~= "")
        if _plFilterText ~= "" then
            _pickedUserId = nil
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

    panelColorHooks[#panelColorHooks + 1] = function(newT)
        local curThemeId = (newT and (newT.id or newT.name))
            or (_genv and _genv._TL_activeThemeId)
            or (_TL_refs and _TL_refs._TL_activeThemeId)
            or "default"
        local isOP = (tostring(curThemeId):lower() == "onepiece")
        if _OP_PlBgImg and _OP_PlBgImg.Parent then
            _OP_PlBgImg.Visible = isOP
        end

        pcall(function() p.BackgroundColor3 = C.panelBg end)
        pcall(function() p.BackgroundTransparency = 0 end)
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
    _TL_refs._TL_getThreatCategory = function(plr)
        return trackedCat[plr]
    end
    _TL_refs._TL_checkThreatPlayer = function(plr, callback)
        runStaffCheck(_TL_refs, plr, false, 0, callback, LocalPlayer)
    end

    rebuildList()

    -- ── Immediate scan: native checks for all current players ────────────────
    for _, pl in ipairs(Players:GetPlayers()) do
        runStaffCheck(_TL_refs, pl, true, 0, nil, LocalPlayer)
    end

    -- ── RoProxy group-rank scan for game creator group (if group game) ───────
    task.spawn(function()
        if not game:IsLoaded() then game.Loaded:Wait() end
        if game.CreatorType == Enum.CreatorType.Group then
            local groupId = game.CreatorId
            RankManager:OnUpdate(function(players)
                for _, pl in ipairs(players) do
                    if pl ~= LocalPlayer then
                        RankManager:GetPlayerRank(pl, groupId, function(data)
                            if data and not data.failed and data.rank and data.rank > 0 then
                                local roleName = tostring(data.role or "")
                                local cat = classifyRole(roleName)
                                if not cat and not isPerkRole(roleName) then
                                    cat = data.rank >= 200 and "Admin"
                                       or data.rank >= 100 and "Moderator"
                                       or (data.rank > (getGroupBaseRank(groupId) or 1) and "Staff")
                                       or nil
                                end
                                if cat then
                                    setStaffState(_TL_refs, pl, true,
                                        "Group Role: " .. roleName, true, cat)
                                end
                            end
                        end)
                    end
                end
            end)
            RankManager:Init(groupId)
        end
    end)

    task.spawn(function()
        task.wait(1.2)
        if not next(trackedStaff) then
            sendStaffDetectorNotification(_TL_refs, "TLMenuSystem", "ModScan Completed!")
        end
    end)

    Players.PlayerAdded:Connect(function(pl)
        task.wait(0.15)
        rebuildDropdown()
        rebuildList()
        runStaffCheck(_TL_refs, pl, true, 3, nil, LocalPlayer)
    end)

    Players.PlayerRemoving:Connect(function(pl)
        task.wait(0.15)
        local entry = rowCache[pl.UserId]
        if entry then
            entry.row:Destroy(); rowCache[pl.UserId] = nil
        end
        if _pickedUserId == pl.UserId then _pickedUserId = nil end
        staffCheckCache[pl] = nil
        if trackedStaff[pl] then
            local role = trackedStaff[pl]
            local leftCat = trackedCat[pl]
            trackedStaff[pl] = nil
            trackedCat[pl] = nil
            sendStaffDetectorNotification(_TL_refs, "TLMenuSystem: Staff/Creator left",
                pl.Name .. "\nRole: " .. role .. "\nLeft the server.", leftCat and ROLE_COLORS[leftCat])
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

    PlayerlistTab.rebuildList = rebuildList
    PlayerlistTab.rowCache = rowCache
    PlayerlistTab.avatarCache = avatarCache
    PlayerlistTab.panel = p
    PlayerlistTab.content = c

    return p, c
end

function PlayerlistTab.new()
    local obj = {
        _panel = nil,
        _content = nil,
    }
    return setmetatable(obj, PlayerlistTab)
end

function PlayerlistTab:Build(cfg)
    local p, c = PlayerlistTab.Init(cfg)
    self._panel = p
    self._content = c
    return p, c
end

function PlayerlistTab:Refresh()
    if PlayerlistTab.rebuildList then
        PlayerlistTab.rebuildList()
    end
end

return PlayerlistTab