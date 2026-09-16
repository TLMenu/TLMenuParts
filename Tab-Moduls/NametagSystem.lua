--!nocheck
-- ══════════════════════════════════════════════════════════════════════
--  TLMenu NametagSystem (Modular Edition v2.0)
--  Universal, Bug-Free, High-Performance Overhead Nametag Engine
-- ══════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local GLOBAL_ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_NametagSystem_Runtime"

-- Cleanup old instance if reloaded
if GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY] and type(GLOBAL_ENV[RUNTIME_KEY].Cleanup) == "function" then
    pcall(GLOBAL_ENV[RUNTIME_KEY].Cleanup)
end

local NametagSystem = {
    Version = "2.0.0",
    Active = false,
}

-- ══════════════════════════════════════════════════════════════════════
-- 1. CONFIGURATION & THEMES (Easily editable!)
-- ══════════════════════════════════════════════════════════════════════

NametagSystem.Config = {
    enabled = true,
    localVisible = true,       -- Broadcasted / visible to other players
    removeOwnNametag = false,  -- Hide LocalPlayer's own nametag locally

    -- Remote definitions
    rolesUrl = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NametagRoles.json",
    configUrl = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NametagConfig.json",

    -- Sizing & Layout
    layout = {
        billboardWidth = 240,
        billboardHeight = 44,
        studsOffsetY = 3.4,
        avatarWidth = 44,
        avatarImagePadding = 3,
        cornerRadius = 8,
        innerCornerRadius = 5,
        borderThickness = 1,
        dividerWidth = 1,
        dividerHeightPct = 0.6,
        dividerTransparency = 0.75,
        nameTextSize = 13,
        nameFont = "GothamBold",
        roleTextSize = 9,
        roleFont = "GothamBold",
        initialsTextSize = 11,
        avatarTextGap = 10,
        textPaddingRight = 4,
        nameLabelHeight = 20,
        nameLabelY = 4,
        roleLabelHeight = 12,
        roleLabelY = 26,
        roleTextTransform = "upper", -- "upper", "lower", "none"
        distanceScaleEnabled = true,
        distanceScaleNear = 10,
        distanceScaleFar = 60,
        distanceScaleMin = 0.35,
    },

    -- Animations
    animations = {
        fadeInDuration = 0.3,
        fadeInEasing = "Quad",
        cardTransparency = 0,
        borderTransparency = 0.3,
    },

    -- Particles (for premium/staff badges)
    particles = {
        enabled = true,
        count = 4,
        minSize = 2,
        maxSize = 4,
        transparency = 0.5,
        moveDurationMin = 3,
        moveDurationMax = 5,
        colors = { "#B87CFF", "#A064F0", "#C896FF", "#8C50DC", "#DDB8FF" },
    },

    -- Role Priority Ranking (Highest applies)
    rolePriority = {
        owner = 7,
        developer = 6,
        admin = 5,
        moderator = 4,
        staff = 3,
        advertising = 2,
        user = 1,
    },

    -- Role Search Keywords
    roleKeywords = {
        owner       = { "owner", "inhaber", "vip" },
        developer   = { "developer", "entwickler", "dev", "coder" },
        admin       = { "admin", "administrator" },
        moderator   = { "moderator", "mod" },
        staff       = { "staff", "team" },
        advertising = { "advertising", "werbung", "media", "partner" },
    },

    -- Default Role Badge Titles
    roleDisplayNames = {
        owner       = "TL Owner",
        developer   = "TL Developer",
        admin       = "TL Admin",
        moderator   = "TL Moderator",
        staff       = "TL Staff",
        advertising = "TL Advertising",
        user        = "TL User",
    },

    -- Color Palettes & Styles for Roles
    themes = {
        user = {
            bg = "#1A1A22", avatarBg = "#1F1F2C", avatarText = "#A0A0C0",
            divider = "#A0A0C0", border = "#A0A0B4", nameText = "#E6E6F0", roleText = "#7878A0",
        },
        admin = {
            bg = "#220E0E", avatarBg = "#2A1212", avatarText = "#FF6464",
            divider = "#FF6464", border = "#DC5050", nameText = "#FF8C8C", roleText = "#C83C3C",
        },
        owner = {
            bg = "#160E1E", avatarBg = "#1B1226", avatarText = "#B87CFF",
            divider = "#B87CFF", border = "#AA64FF", nameText = "#DDB8FF", roleText = "#8850CC",
        },
        developer = {
            bg = "#0C1428", avatarBg = "#101A34", avatarText = "#64B4FF",
            divider = "#64B4FF", border = "#50A0F0", nameText = "#8CD2FF", roleText = "#3C82DC",
        },
        moderator = {
            bg = "#221C0A", avatarBg = "#2A220C", avatarText = "#FFC83C",
            divider = "#FFC83C", border = "#F0B428", nameText = "#FFDC64", roleText = "#DCA01E",
        },
        staff = {
            bg = "#0E1A1A", avatarBg = "#122424", avatarText = "#3CDCB4",
            divider = "#3CDCB4", border = "#28C8A0", nameText = "#64FFD2", roleText = "#20A080",
        },
        advertising = {
            bg = "#1C0E24", avatarBg = "#24122E", avatarText = "#C878FF",
            divider = "#C878FF", border = "#B464F0", nameText = "#E6AAFF", roleText = "#A050D2",
        },
    },

    -- Avatar & Profile Picture URLs
    profilePictures = {
        owner       = { url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-telelumi.png", file = "assets/TL-ROLE-PICS/TL-telelumi.png" },
        user        = { url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/nametag-uploads/nametag-image.png", file = "assets/TL-ROLE-PICS/nametag-image.png" },
        staff       = { url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-STAFF.png", file = "assets/ROLE-ICONS/TL-STAFF.png" },
    },

    -- Dynamic Remote Lists (populated at runtime)
    roleUsers = {},
    nameOverrides = {},
    adminUsers = {},
    customAvatars = {},
}

-- Active runtime registries
local _activeNametags = {}       -- [playerName] = { billboard, head, cardScale, conns }
local _creatingNametag = {}      -- [playerName] = boolean (prevents duplicate spam)
local _listeners = {}            -- Array of RBXScriptConnection

-- ══════════════════════════════════════════════════════════════════════
-- 2. EXECUTOR & ASSET UTILITIES
-- ══════════════════════════════════════════════════════════════════════

local function _safeGetAsset(filePath, fallbackUrl)
    if filePath and filePath ~= "" then
        if type(getcustomasset) == "function" then
            local ok, r = pcall(getcustomasset, filePath)
            if ok and r and r ~= "" then return r end
        end
        if type(getsynasset) == "function" then
            local ok, r = pcall(getsynasset, filePath)
            if ok and r and r ~= "" then return r end
        end
    end
    return fallbackUrl or ""
end

local function _getGuiContainer()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local okCore, cg = pcall(function() return game:GetService("CoreGui") end)
    if okCore and cg then
        local testOk = pcall(function()
            local f = Instance.new("Folder")
            f.Parent = cg
            f:Destroy()
        end)
        if testOk then return cg end
    end
    if LocalPlayer then
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
        if pg then return pg end
    end
    return game:GetService("CoreGui")
end

-- ══════════════════════════════════════════════════════════════════════
-- 3. COLOR & GRADIENT ENGINE
-- ══════════════════════════════════════════════════════════════════════

local function parseColor(val)
    if typeof(val) == "Color3" then return val end
    if type(val) == "table" then
        local r = val.r or val[1] or 255
        local g = val.g or val[2] or 255
        local b = val.b or val[3] or 255
        if r <= 1 and g <= 1 and b <= 1 and (val.r or val[1]) then
            return Color3.new(r, g, b)
        end
        return Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
    end
    if type(val) ~= "string" then return Color3.new(1, 1, 1) end

    local clean = val:gsub("%s+", ""):gsub("^#", "")
    if #clean == 3 then
        local r, g, b = clean:sub(1, 1), clean:sub(2, 2), clean:sub(3, 3)
        clean = r .. r .. g .. g .. b .. b
    elseif #clean == 8 then
        clean = clean:sub(1, 6)
    end
    if #clean == 6 then
        local r = tonumber(clean:sub(1, 2), 16) or 255
        local g = tonumber(clean:sub(3, 4), 16) or 255
        local b = tonumber(clean:sub(5, 6), 16) or 255
        return Color3.fromRGB(r, g, b)
    end
    return Color3.new(1, 1, 1)
end

local FONT_MAP = {
    GothamBold = Enum.Font.GothamBold,
    Gotham = Enum.Font.Gotham,
    GothamMedium = Enum.Font.GothamMedium,
    GothamBlack = Enum.Font.GothamBlack,
    GothamLight = Enum.Font.GothamLight,
    SourceSans = Enum.Font.SourceSans,
    SourceSansBold = Enum.Font.SourceSansBold,
    Arial = Enum.Font.Arial,
    ArialBold = Enum.Font.ArialBold,
    Ubuntu = Enum.Font.Ubuntu,
    UbuntuBold = Enum.Font.UbuntuBold,
}

local function getSafeFont(name)
    if FONT_MAP[name] then return FONT_MAP[name] end
    local ok, f = pcall(function() return Enum.Font[name] end)
    if ok and f then return f end
    return Enum.Font.GothamBold
end

local EASING_MAP = {
    Quad = Enum.EasingStyle.Quad,
    Linear = Enum.EasingStyle.Linear,
    Sine = Enum.EasingStyle.Sine,
    Expo = Enum.EasingStyle.Exponential,
    Back = Enum.EasingStyle.Back,
    Bounce = Enum.EasingStyle.Bounce,
}

local function getSafeEasing(name)
    return EASING_MAP[name] or Enum.EasingStyle.Quad
end

local function getInitials(name)
    if not name or name == "" then return "?" end
    local words = {}
    for w in name:gmatch("%S+") do table.insert(words, w) end
    if #words >= 2 then
        return (words[1]:sub(1, 1) .. words[2]:sub(1, 1)):upper()
    else
        return name:sub(1, math.min(2, #name)):upper()
    end
end

-- ══════════════════════════════════════════════════════════════════════
-- 4. REMOTE CONFIG & ROLE LOADING
-- ══════════════════════════════════════════════════════════════════════

function NametagSystem.ReloadConfig()
    task.spawn(function()
        -- 1. Fetch NametagRoles.json
        pcall(function()
            local res = (game :: any):HttpGet(NametagSystem.Config.rolesUrl)
            if res and #res > 10 then
                local newOverrides = {}
                for line in res:gmatch("[^\r\n]+") do
                    if not line:match("^%s*%-%-") and line:match("%S") then
                        local user, disp, role = line:match('%["([^"]+)"%]%s*=%s*%{.-display%s*=%s*"([^"]+)".-role%s*=%s*"([^"]+)"')
                        if user and disp and role then
                            newOverrides[user] = { display = disp, role = role }
                            local r = role:lower()
                            if r:find("admin") or r:find("owner") or r:find("dev") or r:find("mod") then
                                NametagSystem.Config.adminUsers[user] = true
                            end
                        end
                    end
                end
                if next(newOverrides) then
                    NametagSystem.Config.nameOverrides = newOverrides
                end
            end
        end)

        -- 2. Fetch NametagConfig.json
        pcall(function()
            local res = (game :: any):HttpGet(NametagSystem.Config.configUrl)
            if res and #res > 10 then
                local clean = res:gsub("^[\239\187\191%s]+", ""):gsub("[%s]+$", "")
                local s, e = clean:find("{.*}")
                if s then clean = clean:sub(s, e) end
                local json = HttpService:JSONDecode(clean)
                if type(json) == "table" then
                    if type(json.roleUsers) == "table" then
                        NametagSystem.Config.roleUsers = json.roleUsers
                        for role, list in pairs(json.roleUsers) do
                            if role == "owner" or role == "admin" or role == "developer" then
                                for _, u in ipairs(list) do
                                    NametagSystem.Config.adminUsers[tostring(u)] = true
                                end
                            end
                        end
                    end
                    if type(json.displayNames) == "table" then
                        for k, v in pairs(json.displayNames) do
                            NametagSystem.Config.nameOverrides[k] = NametagSystem.Config.nameOverrides[k] or {}
                            NametagSystem.Config.nameOverrides[k].display = v
                        end
                    end
                    if type(json.roleDisplayNames) == "table" then
                        for k, v in pairs(json.roleDisplayNames) do
                            NametagSystem.Config.roleDisplayNames[k] = v
                        end
                    end
                end
            end
        end)

        -- Refresh all active nametags with new data
        NametagSystem.UpdateAll()
    end)
end

-- ══════════════════════════════════════════════════════════════════════
-- 5. RESOLVE PLAYER THEME & INFO
-- ══════════════════════════════════════════════════════════════════════

function NametagSystem.GetPlayerInfo(playerOrName, isAdmin)
    local pName = type(playerOrName) == "string" and playerOrName or (playerOrName and playerOrName.Name) or ""
    local player = Players:FindFirstChild(pName)
    local cfg = NametagSystem.Config

    local override = cfg.nameOverrides[pName]
    if not override and player then
        override = cfg.nameOverrides[tostring(player.UserId)]
    end

    local displayName = (override and override.display) or (player and player.DisplayName ~= "" and player.DisplayName) or pName
    local roleLabel = override and override.role

    -- Determine Role / Theme Key
    local themeKey = "user"
    local highestPrio = 0

    -- Check explicit roleUsers lists
    if type(cfg.roleUsers) == "table" then
        for role, users in pairs(cfg.roleUsers) do
            for _, u in ipairs(users) do
                if tostring(u):lower() == pName:lower() then
                    local prio = cfg.rolePriority[role] or 0
                    if prio > highestPrio then
                        highestPrio = prio
                        themeKey = role
                    end
                end
            end
        end
    end

    -- Check role keywords if still user
    if themeKey == "user" then
        local checkStr = ((roleLabel or "") .. " " .. displayName):lower()
        for rKey, kws in pairs(cfg.roleKeywords) do
            for _, kw in ipairs(kws) do
                if checkStr:find(kw) then
                    themeKey = rKey
                    break
                end
            end
            if themeKey ~= "user" then break end
        end
    end

    -- Admin override
    local isAdm = isAdmin or cfg.adminUsers[pName] == true or (player and cfg.adminUsers[tostring(player.UserId)] == true)
    if themeKey == "user" and isAdm then
        themeKey = "admin"
    end

    -- Default role label
    if not roleLabel or roleLabel == "" then
        roleLabel = cfg.roleDisplayNames[themeKey] or "TL User"
    end

    local theme = cfg.themes[themeKey] or cfg.themes.user

    return {
        name = pName,
        player = player,
        displayName = displayName,
        roleLabel = roleLabel,
        themeKey = themeKey,
        theme = theme,
        isAdmin = isAdm,
    }
end

function NametagSystem.DoesPlayerQualify(p)
    if not NametagSystem.Config.enabled then return false end
    if not p then return false end
    if LocalPlayer and p == LocalPlayer then return true end
    local cfg = NametagSystem.Config
    local pName = p.Name
    local pUserId = tostring(p.UserId)
    if cfg.adminUsers[pName] == true or cfg.adminUsers[pUserId] == true then return true end
    if cfg.nameOverrides[pName] ~= nil or cfg.nameOverrides[pUserId] ~= nil then return true end
    if type(cfg.roleUsers) == "table" then
        for _, users in pairs(cfg.roleUsers) do
            for _, u in ipairs(users) do
                if tostring(u):lower() == pName:lower() then return true end
            end
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════
-- 6. CREATE OVERHEAD NAMETAG
-- ══════════════════════════════════════════════════════════════════════

function NametagSystem.CreateNametag(character, playerOrName, isAdmin)
    if not character or not character.Parent then return end
    local pName = type(playerOrName) == "string" and playerOrName or (playerOrName and playerOrName.Name) or ""
    if pName == "" then return end

    if _creatingNametag[pName] then return end
    _creatingNametag[pName] = true

    -- Check local player visibility toggle
    local isLocal = (LocalPlayer and LocalPlayer.Name == pName)
    if isLocal and NametagSystem.Config.removeOwnNametag then
        NametagSystem.RemoveNametag(pName)
        _creatingNametag[pName] = nil
        return
    end

    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 4)
    if not head or not head.Parent then
        _creatingNametag[pName] = nil
        return
    end

    -- Remove any existing nametag for this player
    NametagSystem.RemoveNametag(pName)

    local info = NametagSystem.GetPlayerInfo(pName, isAdmin)
    local cfg = NametagSystem.Config
    local layout = cfg.layout
    local theme = info.theme

    local container = _getGuiContainer()
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CovertPeerTag_" .. pName
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, layout.billboardWidth, 0, layout.billboardHeight)
    billboard.StudsOffset = Vector3.new(0, layout.studsOffsetY, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.ResetOnSpawn = false

    -- Card Body
    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(1, 0, 1, 0)
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.new(0.5, 0, 0.5, 0)
    card.BackgroundColor3 = parseColor(theme.bg)
    card.BackgroundTransparency = 1 -- Faded in via tween
    card.BorderSizePixel = 0
    card.Parent = billboard

    local cardCorner = Instance.new("UICorner", card)
    cardCorner.CornerRadius = UDim.new(0, layout.cornerRadius)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = parseColor(theme.border)
    cardStroke.Thickness = layout.borderThickness
    cardStroke.Transparency = 1 -- Faded in via tween
    cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local cardScale = Instance.new("UIScale", card)
    cardScale.Scale = 1

    -- Avatar Box
    local avatar = Instance.new("Frame", card)
    avatar.Name = "Avatar"
    avatar.Size = UDim2.new(0, layout.avatarWidth, 1, 0)
    avatar.Position = UDim2.new(0, 0, 0, 0)
    avatar.BackgroundColor3 = parseColor(theme.avatarBg)
    avatar.BorderSizePixel = 0
    avatar.ZIndex = 2
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, layout.cornerRadius)

    -- Avatar Image / Initials
    local avPad = layout.avatarImagePadding or 3
    local profPic = cfg.profilePictures[info.themeKey]
    local imgSource = profPic and _safeGetAsset(profPic.file, profPic.url)

    if imgSource and imgSource ~= "" then
        local imgLabel = Instance.new("ImageLabel", avatar)
        imgLabel.Size = UDim2.new(1, -avPad * 2, 1, -avPad * 2)
        imgLabel.Position = UDim2.new(0, avPad, 0, avPad)
        imgLabel.BackgroundTransparency = 1
        imgLabel.Image = imgSource
        imgLabel.ScaleType = Enum.ScaleType.Crop
        imgLabel.ZIndex = 3
        Instance.new("UICorner", imgLabel).CornerRadius = UDim.new(0, layout.innerCornerRadius)
    else
        local initLabel = Instance.new("TextLabel", avatar)
        initLabel.Size = UDim2.new(1, 0, 1, 0)
        initLabel.BackgroundTransparency = 1
        initLabel.Text = getInitials(pName)
        initLabel.TextColor3 = parseColor(theme.avatarText)
        initLabel.Font = getSafeFont(layout.nameFont)
        initLabel.TextSize = layout.initialsTextSize
        initLabel.ZIndex = 3
    end

    -- Divider line
    local div = Instance.new("Frame", card)
    div.Name = "Divider"
    div.Size = UDim2.new(0, layout.dividerWidth, layout.dividerHeightPct, 0)
    div.Position = UDim2.new(0, layout.avatarWidth, (1 - layout.dividerHeightPct) / 2, 0)
    div.BackgroundColor3 = parseColor(theme.divider)
    div.BackgroundTransparency = layout.dividerTransparency
    div.BorderSizePixel = 0
    div.ZIndex = 2

    -- Text Container
    local textX = layout.avatarWidth + (layout.avatarTextGap or 10)
    local tPadR = layout.textPaddingRight or 4

    local nameLabel = Instance.new("TextLabel", card)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -textX - tPadR, 0, layout.nameLabelHeight)
    nameLabel.Position = UDim2.new(0, textX, 0, layout.nameLabelY)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = info.displayName
    nameLabel.TextColor3 = parseColor(theme.nameText)
    nameLabel.Font = getSafeFont(layout.nameFont)
    nameLabel.TextSize = layout.nameTextSize
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.ZIndex = 3

    local roleTxt = Instance.new("TextLabel", card)
    roleTxt.Name = "RoleLabel"
    roleTxt.Size = UDim2.new(1, -textX - tPadR, 0, layout.roleLabelHeight)
    roleTxt.Position = UDim2.new(0, textX, 0, layout.roleLabelY)
    roleTxt.BackgroundTransparency = 1

    local finalRoleText = info.roleLabel
    if layout.roleTextTransform == "upper" then
        finalRoleText = finalRoleText:upper()
    elseif layout.roleTextTransform == "lower" then
        finalRoleText = finalRoleText:lower()
    end

    roleTxt.Text = finalRoleText
    roleTxt.TextColor3 = parseColor(theme.roleText)
    roleTxt.Font = getSafeFont(layout.roleFont)
    roleTxt.TextSize = layout.roleTextSize
    roleTxt.TextXAlignment = Enum.TextXAlignment.Left
    roleTxt.TextTruncate = Enum.TextTruncate.AtEnd
    roleTxt.ZIndex = 3

    -- Subtle Particle Accents (for special roles)
    local particleFrames = {}
    if cfg.particles.enabled and info.themeKey ~= "user" and cfg.particles.count > 0 then
        card.ClipsDescendants = true
        for pi = 1, cfg.particles.count do
            local pt = Instance.new("Frame", card)
            local sz = math.random(cfg.particles.minSize, cfg.particles.maxSize)
            pt.Size = UDim2.new(0, sz, 0, sz)
            pt.AnchorPoint = Vector2.new(0.5, 0.5)
            pt.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.8 + 0.1, 0)
            local pColors = cfg.particles.colors
            local colHex = pColors[((pi - 1) % #pColors) + 1]
            pt.BackgroundColor3 = parseColor(colHex)
            pt.BackgroundTransparency = cfg.particles.transparency
            pt.BorderSizePixel = 0
            pt.ZIndex = 1
            Instance.new("UICorner", pt).CornerRadius = UDim.new(1, 0)
            table.insert(particleFrames, pt)
        end
    end

    billboard.Parent = container

    -- Smooth Fade-in Tween
    local fadeInfo = TweenInfo.new(cfg.animations.fadeInDuration, getSafeEasing(cfg.animations.fadeInEasing))
    local twCard = TweenService:Create(card, fadeInfo, { BackgroundTransparency = cfg.animations.cardTransparency })
    local twStroke = TweenService:Create(cardStroke, fadeInfo, { Transparency = cfg.animations.borderTransparency })
    twCard:Play()
    twStroke:Play()

    -- Register in active pool
    _activeNametags[pName] = {
        billboard = billboard,
        head = head,
        cardScale = cardScale,
        particles = particleFrames,
    }

    twCard.Completed:Connect(function()
        _creatingNametag[pName] = nil
    end)
end

-- ══════════════════════════════════════════════════════════════════════
-- 7. REMOVE & UPDATE
-- ══════════════════════════════════════════════════════════════════════

function NametagSystem.RemoveNametag(playerOrName)
    local pName = type(playerOrName) == "string" and playerOrName or (playerOrName and playerOrName.Name) or ""
    if pName == "" then return end

    local tagData = _activeNametags[pName]
    if tagData then
        if tagData.billboard and tagData.billboard.Parent then
            pcall(function() tagData.billboard:Destroy() end)
        end
        _activeNametags[pName] = nil
    end

    -- Also check for any stray billboard with this name
    pcall(function()
        local container = _getGuiContainer()
        for _, desc in ipairs(container:GetChildren()) do
            if desc.Name == "CovertPeerTag_" .. pName then
                desc:Destroy()
            end
        end
    end)
end

function NametagSystem.RemoveAll()
    for pName, _ in pairs(_activeNametags) do
        NametagSystem.RemoveNametag(pName)
    end
    _activeNametags = {}
    pcall(function()
        local container = _getGuiContainer()
        for _, desc in ipairs(container:GetChildren()) do
            if desc.Name:sub(1, 14) == "CovertPeerTag_" then
                desc:Destroy()
            end
        end
    end)
end

function NametagSystem.UpdateAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            NametagSystem.CreateNametag(player.Character, player)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════
-- 8. SETTERS & CONTROLS
-- ══════════════════════════════════════════════════════════════════════

function NametagSystem.SetVisible(visible)
    NametagSystem.Config.localVisible = visible
end

function NametagSystem.SetRemoveOwn(remove)
    NametagSystem.Config.removeOwnNametag = remove
    if LocalPlayer and LocalPlayer.Character then
        if remove then
            NametagSystem.RemoveNametag(LocalPlayer.Name)
        else
            NametagSystem.CreateNametag(LocalPlayer.Character, LocalPlayer)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════
-- 9. INITIALIZATION & LIFECYCLE (Centralized Heartbeat Engine)
-- ══════════════════════════════════════════════════════════════════════

function NametagSystem.Init(ctx)
    if NametagSystem.Active then return NametagSystem end
    NametagSystem.Active = true

    -- Merge custom context if supplied
    if type(ctx) == "table" then
        if ctx.rolesUrl then NametagSystem.Config.rolesUrl = ctx.rolesUrl end
        if ctx.configUrl then NametagSystem.Config.configUrl = ctx.configUrl end
        if ctx.AdminNames then
            for k, v in pairs(ctx.AdminNames) do NametagSystem.Config.adminUsers[k] = v end
        end
        if ctx.NameOverrides then
            for k, v in pairs(ctx.NameOverrides) do NametagSystem.Config.nameOverrides[k] = v end
        end
    end

    -- Initial load of remote configs
    NametagSystem.ReloadConfig()

    -- PlayerAdded listener
    local connAdd = Players.PlayerAdded:Connect(function(player)
        local connChar = player.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if NametagSystem.Active then
                NametagSystem.CreateNametag(char, player)
            end
        end)
        table.insert(_listeners, connChar)
    end)
    table.insert(_listeners, connAdd)

    -- PlayerRemoving listener
    local connRem = Players.PlayerRemoving:Connect(function(player)
        NametagSystem.RemoveNametag(player.Name)
    end)
    table.insert(_listeners, connRem)

    -- Hook characters for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            task.spawn(function()
                task.wait(0.2)
                if NametagSystem.Active then
                    NametagSystem.CreateNametag(player.Character, player)
                end
            end)
        end
        local connChar = player.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if NametagSystem.Active then
                NametagSystem.CreateNametag(char, player)
            end
        end)
        table.insert(_listeners, connChar)
    end

    -- Centralized Distance Scaling & Garbage Collection Loop (Every 0.15s)
    local lastCheck = 0
    local connHeart = RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastCheck < 0.15 then return end
        lastCheck = now

        local cam = workspace.CurrentCamera
        local camPos = cam and cam.CFrame.Position
        local layout = NametagSystem.Config.layout

        if camPos and layout.distanceScaleEnabled then
            local near = layout.distanceScaleNear or 10
            local far = layout.distanceScaleFar or 60
            local minScale = layout.distanceScaleMin or 0.35

            for pName, data in pairs(_activeNametags) do
                local head = data.head
                local scaleInst = data.cardScale
                local bb = data.billboard
                if bb and bb.Parent and head and head.Parent and scaleInst then
                    local dist = (head.Position - camPos).Magnitude
                    local sc = 1
                    if dist > near then
                        sc = math.clamp(1 - (dist - near) / (far - near), minScale, 1)
                    end
                    scaleInst.Scale = sc
                else
                    _activeNametags[pName] = nil
                end
            end
        end
    end)
    table.insert(_listeners, connHeart)

    -- Auto-sync roles every 5 minutes
    task.spawn(function()
        while NametagSystem.Active do
            task.wait(300)
            if NametagSystem.Active then
                NametagSystem.ReloadConfig()
            end
        end
    end)

    if GLOBAL_ENV then
        GLOBAL_ENV[RUNTIME_KEY] = NametagSystem
    end

    return NametagSystem
end

function NametagSystem.Cleanup()
    NametagSystem.Active = false

    -- Disconnect all event connections
    for _, conn in ipairs(_listeners) do
        pcall(function() conn:Disconnect() end)
    end
    _listeners = {}

    -- Destroy all billboards
    NametagSystem.RemoveAll()

    if GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY] == NametagSystem then
        GLOBAL_ENV[RUNTIME_KEY] = nil
    end
end

-- Self-start if required directly
return NametagSystem