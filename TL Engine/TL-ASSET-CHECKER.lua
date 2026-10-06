--!nocheck
local _genv = (getgenv and getgenv()) or _G

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 0. SINGLE-EXECUTION GUARD (Die Engine läuft nur EINMAL pro Session)
-- ══════════════════════════════════════════════════════════════════════════════════════
if type(_genv) == "table" and rawget(_genv, "TL_ENGINE_ACTIVE") then
    local _existing = rawget(_genv, "TLAssetChecker")
    if _existing ~= nil then
        return _existing
    end
end
if type(_genv) == "table" then
    rawset(_genv, "TL_ENGINE_ACTIVE", true)
end

local ContentProvider = game:GetService("ContentProvider")
local HttpService     = game:GetService("HttpService")
local RunService      = game:GetService("RunService")
local Players         = game:GetService("Players")

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 1. EXPLOIT & FILESYSTEM COMPATIBILITY LAYER
-- ══════════════════════════════════════════════════════════════════════════════════════

local function _safeIsFile(path)
    if type(isfile) ~= "function" then return false end
    local ok, res = pcall(isfile, path)
    return ok and res == true
end

local function _safeIsFolder(path)
    if type(isfolder) ~= "function" then return false end
    local ok, res = pcall(isfolder, path)
    return ok and res == true
end

local function _safeMakeFolder(path)
    if type(makefolder) ~= "function" then return false end
    return pcall(makefolder, path)
end

local function _safeReadFile(path)
    if type(readfile) ~= "function" then return nil end
    local ok, data = pcall(readfile, path)
    if ok and type(data) == "string" then return data end
    return nil
end

local function _safeWriteFile(path, data)
    if type(writefile) ~= "function" then return false end
    local ok = pcall(writefile, path, data)
    return ok == true
end

local function _safeDelFile(path)
    if type(delfile) == "function" then
        return pcall(delfile, path)
    end
    return false
end

local function _safeGetCustomAsset(path)
    if type(getcustomasset) == "function" then
        local ok, asset = pcall(getcustomasset, path)
        if ok and asset and asset ~= "" then return asset end
    end
    if type(getsynasset) == "function" then
        local ok, asset = pcall(getsynasset, path)
        if ok and asset and asset ~= "" then return asset end
    end
    return nil
end

local function _httpRequest(url, method)
    method = method or "GET"
    local reqFn = (type(request) == "function" and request)
        or (type(http_request) == "function" and http_request)
        or (type(syn) == "table" and type(syn.request) == "function" and syn.request)
        or (type(http) == "table" and type(http.request) == "function" and http.request)

    if reqFn then
        local ok, res = pcall(reqFn, {
            Url = url,
            Method = method,
            Headers = {
                ["User-Agent"] = "TLEngine-AssetChecker/2.1",
                ["Cache-Control"] = "no-cache",
                ["Pragma"] = "no-cache"
            }
        })
        if ok and type(res) == "table" then
            return res
        end
    end

    if method == "GET" then
        local ok, body = pcall(function() return game:HttpGet(url, true) end)
        if ok and type(body) == "string" then
            return {
                Success = true,
                StatusCode = 200,
                Body = body,
                Headers = {}
            }
        end
    end

    return nil
end

-- Wandelt GitHub "/blob/" URLs automatisch in "/raw/" um, da blob nur HTML Webseiten liefert
local function _normalizeUrl(url)
    if not url or type(url) ~= "string" then return "" end
    local clean = url:gsub("^%s+", ""):gsub("%s+$", "")
    if clean:find("github.com/.+/blob/") then
        clean = clean:gsub("github.com/([^/]+)/([^/]+)/blob/", "raw.githubusercontent.com/%1/%2/")
    end
    return clean
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 2. ASSET CHECKER ENGINE CONFIGURATION & STATE
-- ══════════════════════════════════════════════════════════════════════════════════════

local TLAssetChecker = {
    Version = "2.2.0",
    BuildId = "2026.10.TL_ENGINE_V3",
    StateFilePath = "assets/.tl_asset_state.json",

    Config = {
        AutoReplaceOutdated = true,   -- Veraltete Dateien automatisch aus dem Workspace ersetzen
        AutoRepairBroken    = true,   -- Defekte Dateien automatisch versuchen neu zu laden
        LogToConsole        = true,   -- Detaillierte F9 Konsolenausgabe
        DeepImagePreload    = false,  -- Zusätzlicher Rendering-Test via ContentProvider:PreloadAsync
        MaxConcurrent       = 4,      -- Parallele Downloads (GH-Assets kommen in Wellen statt sequenziell)
        ThrottleDelay       = 0.03,   -- Pause zwischen Download-Starts (GitHub Rate-Limit-Schutz)
    },

    -- Status-Speicher für Prüfungen
    Diagnostics = {
        TotalScanned    = 0,
        ValidHealthy    = 0,
        Replaced        = {},
        Repaired        = {},
        BrokenDamaged   = {},
        RemoteDead      = {},
        MissingCreated  = {},
    },

    RegisteredAssets = {},
    _scanning        = false,
}

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 3. MASTER ASSET REGISTRY (VOLLSTÄNDIGER ASSET-KATALOG)
-- ══════════════════════════════════════════════════════════════════════════════════════

local MASTER_ASSETS = {
    -- ── STANDARD ICONS (TL-DEFAULT) ──────────────────────────────────────────────────
    { category = "TL-DEFAULT", name = "Emote Icon",             kind = "image", file = "assets/TL-DEFAULT/Emote-Icon.png",              url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Emote-Icon.png" },
    { category = "TL-DEFAULT", name = "Music Icon",             kind = "image", file = "assets/TL-DEFAULT/Music-Icon.png",              url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Music-Icon.png" },
    { category = "TL-DEFAULT", name = "Visual Icon",            kind = "image", file = "assets/TL-DEFAULT/Visual-Icon.png",             url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Visual-Icon.png" },
    { category = "TL-DEFAULT", name = "Visual2 Icon",           kind = "image", file = "assets/TL-DEFAULT/Visual2-Icon.png",            url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Visual2-Icon.png" },
    { category = "TL-DEFAULT", name = "Movement Icon",          kind = "image", file = "assets/TL-DEFAULT/Movement-Icon.png",           url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Movement-Icon.png" },
    { category = "TL-DEFAULT", name = "Misc Icon",              kind = "image", file = "assets/TL-DEFAULT/Misc-Icon.png",               url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Misc-Icon.png" },
    { category = "TL-DEFAULT", name = "Colors Icon",            kind = "image", file = "assets/TL-DEFAULT/Colors-Icon.png",             url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Colors-Icon.png" },
    { category = "TL-DEFAULT", name = "Theme Icon",             kind = "image", file = "assets/TL-DEFAULT/Theme-Icon.png",              url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Theme-Icon.png" },
    { category = "TL-DEFAULT", name = "Themes Icon",            kind = "image", file = "assets/TL-DEFAULT/Themes-Icon.png",             url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Themes-Icon.png" },
    { category = "TL-DEFAULT", name = "Keybind Icon",           kind = "image", file = "assets/TL-DEFAULT/Keybind-Icon.png",            url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Keybind-Icon.png" },
    { category = "TL-DEFAULT", name = "Cursor Icon",            kind = "image", file = "assets/TL-DEFAULT/Cursor-Icon.png",             url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Cursor-Icon.png" },
    { category = "TL-DEFAULT", name = "CustomCursor Icon",      kind = "image", file = "assets/TL-DEFAULT/CustomCursor-Icon.png",       url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/CustomCursor-Icon%20(2).png" },
    { category = "TL-DEFAULT", name = "Search Icon",            kind = "image", file = "assets/TL-DEFAULT/Search-Icon.png",             url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Search-Icon.png" },
    { category = "TL-DEFAULT", name = "Search2 Icon",           kind = "image", file = "assets/TL-DEFAULT/Search2-Icon.png",            url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Search2-Icon.png" },
    { category = "TL-DEFAULT", name = "Minimize Icon",          kind = "image", file = "assets/TL-DEFAULT/Minimize-Icon.png",           url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Minimize-Icon.png" },
    { category = "TL-DEFAULT", name = "MusicPlay Icon",         kind = "image", file = "assets/TL-DEFAULT/MusicPlay-Icon.png",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/MusicPlay-Icon.png" },
    { category = "TL-DEFAULT", name = "MusicPause Icon",        kind = "image", file = "assets/TL-DEFAULT/MusicPause-Icon.png",         url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/MusicPause-Icon.png" },
    { category = "TL-DEFAULT", name = "MusicBack Icon",         kind = "image", file = "assets/TL-DEFAULT/MusicBack-Icon.png",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/MusicBack-Icon.png" },
    { category = "TL-DEFAULT", name = "MusicSkip Icon",         kind = "image", file = "assets/TL-DEFAULT/MusicSkip-Icon.png",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/MusicSkip-Icon.png" },
    { category = "TL-DEFAULT", name = "PING-WLAN Icon",         kind = "image", file = "assets/TL-DEFAULT/PING-WLAN-Icon.png",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/PING-WLAN-Icon.png" },
    { category = "TL-DEFAULT", name = "PunchFling Icon",        kind = "image", file = "assets/TL-DEFAULT/PunchFling-Icon.png",         url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/PunchFling-Icon.png" },
    { category = "TL-DEFAULT", name = "TLMagnifier Tool Icon",  kind = "image", file = "assets/TL-DEFAULT/TLMagnifier-Tool-Icon.png",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TLMagnifier-Tool-Icon.png" },
    { category = "TL-DEFAULT", name = "TL-Icon",                kind = "image", file = "assets/TL-DEFAULT/TL-Icon.png",                 url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TL-Icon.png" },
    { category = "TL-DEFAULT", name = "TLIcon",                 kind = "image", file = "assets/TL-DEFAULT/TLIcon.png",                  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TLIcon.png" },
    { category = "TL-DEFAULT", name = "TL-ProfileIcon",         kind = "image", file = "assets/TL-DEFAULT/TL-ProfileIcon.png",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TL-ProfileIcon.png" },
    { category = "TL-DEFAULT", name = "TLOpenBars Button",      kind = "image", file = "assets/TL-DEFAULT/TLOpenBars-Button.png",       url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TLOpenBars-Button.png" },
    { category = "TL-DEFAULT", name = "TLOpenedBars Button",    kind = "image", file = "assets/TL-DEFAULT/TLOpenedBars-Button.png",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TLOpenedBars-Button.png" },
    { category = "TL-DEFAULT", name = "VC Unmuted Icon",        kind = "image", file = "assets/TL-DEFAULT/TL_Unmuted.png",              url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/ANTIVCBAN-Unmuted-Icon.png" },
    { category = "TL-DEFAULT", name = "VC Muted Icon",          kind = "image", file = "assets/TL-DEFAULT/TL_Muted.png",                url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/ANTIVCBAN-Mute-Icon.png" },
    { category = "TL-DEFAULT", name = "QuickAction - Hug",      kind = "image", file = "assets/TL-DEFAULT/QuickAction-Hug-Icon.png",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Hug-Icon.png" },
    { category = "TL-DEFAULT", name = "QuickAction - Kiss",     kind = "image", file = "assets/TL-DEFAULT/QuickAction-Kiss-Icon.png",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Kiss-Icon.png" },
    { category = "TL-DEFAULT", name = "QuickAction - Slap",     kind = "image", file = "assets/TL-DEFAULT/QuickAction-Slap-Icon.png",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Slap-Icon.png" },
    { category = "TL-DEFAULT", name = "QuickAction - Headbutt", kind = "image", file = "assets/TL-DEFAULT/QuickAction-Headbutt-Icon.png", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Headbutt-Icon.png" },
    { category = "TL-DEFAULT", name = "QuickAction - Backshots",kind = "image", file = "assets/TL-DEFAULT/QuickAction-Backshots-Icon.png",url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Backshots-Icon.png" },
    { category = "TL-DEFAULT", name = "Communication Tab Icon", kind = "image", file = "assets/TL-DEFAULT/Com-Icon.png",               url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Com-Icon.png" },
    { category = "TL-DEFAULT", name = "Home Tab Icon",          kind = "image", file = "assets/TL-DEFAULT/HomeTab-Icon.png",            url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/HomeTab-Icon.png" },
    { category = "TL-DEFAULT", name = "Character Tab Icon",     kind = "image", file = "assets/TL-DEFAULT/Character-Icon.png",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Character-Icon.png" },
    { category = "TL-DEFAULT", name = "Scripts Tab Icon",       kind = "image", file = "assets/TL-DEFAULT/Scripts-Icon.png",            url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Scripts-Icon.png" },
    { category = "TL-DEFAULT", name = "Actions Tab Icon",       kind = "image", file = "assets/TL-DEFAULT/ActionTab-Icon.png",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/ActionTab-Icon.png" },
    { category = "TL-DEFAULT", name = "Playerlist Tab Icon",    kind = "image", file = "assets/TL-DEFAULT/Playerlist-Icon.png",         url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Playerlist-Icon.png" },

    -- ── ROLES & AVATARS ─────────────────────────────────────────────────────────────
    { category = "ROLES", name = "TL Owner Profile Picture",    kind = "image", file = "assets/TL-ROLE-PICS/TL-telelumi.png",          url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-telelumi.png" },
    { category = "ROLES", name = "TL User Profile Picture",     kind = "image", file = "assets/ROLE-ICONS/TLUSER-ROLE.png",             url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TLUSER-ROLE.png" },
    { category = "ROLES", name = "usxirr Custom Avatar",        kind = "image", file = "assets/TL-ROLE-PICS/TL-Usxirr.png",             url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-Oso.png" },
    { category = "ROLES", name = "Abxsent0 Custom Avatar",      kind = "image", file = "assets/ROLE-ICONS/TL-Abxsent0.png",             url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-Abxsent0.png" },
    { category = "ROLES", name = "TL Staff Icon",               kind = "image", file = "assets/ROLE-ICONS/TL-STAFF.png",                url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-STAFF.png" },
    { category = "ROLES", name = "TL Arda Avatar",              kind = "image", file = "assets/TL-ROLE-PICS/TL-Arda.png",               url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-Arda.png" },
    { category = "ROLES", name = "TL Sec Avatar",               kind = "image", file = "assets/TL-ROLE-PICS/TL-Sec.png",                url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-Sec.png" },
    { category = "ROLES", name = "TL Sleepy Avatar",            kind = "image", file = "assets/TL-ROLE-PICS/TL-Sleepy.jpg",             url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-Sleepy.jpg" },
    { category = "ROLES", name = "R5yn Avatar",                 kind = "image", file = "assets/TL-ROLE-PICS/R5yn.png",                  url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/R5yn.png" },
    { category = "ROLES", name = "Nametag Image",               kind = "image", file = "assets/TL-ROLE-PICS/nametag-image.png",         url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/nametag-uploads/nametag-image.png" },

    -- ── DRAGONBALL THEME ─────────────────────────────────────────────────────────────
    { category = "DRAGONBALL", name = "Character Icon",         kind = "image", file = "assets/THEMES/DRAGONBALL/Theme-Dragonball-CharacterIcon.png",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DRAGONBALL/Theme-Dragonball-CharacterIcon.png" },
    { category = "DRAGONBALL", name = "Wallpaper (Char BG)",    kind = "image", file = "assets/THEMES/DRAGONBALL/Theme-Dragonball-CharacterPanel.png",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DRAGONBALL/Theme-Dragonball-CharacterPanel.png" },
    { category = "DRAGONBALL", name = "Home Icon",              kind = "image", file = "assets/THEMES/DRAGONBALL/Theme-Dragonball-HomeIcon.png",       url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DRAGONBALL/Theme-Dragonball-HomeIcon.png" },
    { category = "DRAGONBALL", name = "Loading Screen",         kind = "image", file = "assets/THEMES/DRAGONBALL/Theme-Dragonball-Loading-Screen.png",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DRAGONBALL/Theme-Dragonball-Loading-Screen.png" },
    { category = "DRAGONBALL", name = "Playerlist Icon",        kind = "image", file = "assets/THEMES/DRAGONBALL/Theme-Dragonball-Playerlist-Icon.png", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DRAGONBALL/Theme-Dragonball-Playerlist-Icon.png" },
    { category = "DRAGONBALL", name = "Settings Icon",          kind = "image", file = "assets/THEMES/DRAGONBALL/Theme-Dragonball-Settings-Icon.png",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DRAGONBALL/Theme-Dragonball-Settings-Icon.png" },
    { category = "DRAGONBALL", name = "Wallpaper (Home BG)",    kind = "image", file = "assets/THEMES/DRAGONBALL/Theme-Dragonball-Home-Wallpaper.png",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DRAGONBALL/Theme-Dragonball-Home-Wallpaper.png" },
    { category = "DRAGONBALL", name = "Theme Music",            kind = "audio", file = "assets/TL-MP3-FILES/DRAGONBALL/DRAGONBALL-THEME-MUSIC-1.mp3",  url = "https://github.com/TLMenu/TLASSETS/raw/main/TL-MP3/THEME-MP3/THEME-MUSIC/DRAGONBALL/DRAGONBALL-THEME-MUSIC-1.mp3" },
    { category = "DRAGONBALL", name = "AFK Voiceline 1",        kind = "audio", file = "assets/TL-MP3-FILES/DB-AFK-VL0.mp3",                            url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/AFKSFX/DRAGONBALL-AFKSFX/DRAGONBALL-AFK-VOICELINE.mp3" },
    { category = "DRAGONBALL", name = "AFK Voiceline 2",        kind = "audio", file = "assets/TL-MP3-FILES/DB-AFK-VL1.mp3",                            url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/AFKSFX/DRAGONBALL-AFKSFX/DRAGONBALL-AFK-VOICELINE1.mp3" },

    -- ── THE BOYS THEME ───────────────────────────────────────────────────────────────
    { category = "THE BOYS", name = "Scripts Icon",             kind = "image", file = "assets/THEMES/THEBOYS/Theme-TheBoys-Scripts-Icon.png",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/THE%20BOYS/Theme-TheBoys-Scripts-Icon.png" },
    { category = "THE BOYS", name = "Settings Icon",            kind = "image", file = "assets/THEMES/THEBOYS/Theme-TheBoys-Settings-Icon.png", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/THE%20BOYS/Theme-TheBoys-Settings-Icon.png" },
    { category = "THE BOYS", name = "Home Icon",                kind = "image", file = "assets/THEMES/THEBOYS/Theme-TheBoys-HomeIcon.png",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/THE%20BOYS/Theme-TheBoys-HomeIcon.png" },
    { category = "THE BOYS", name = "Actions Icon",             kind = "image", file = "assets/THEMES/THEBOYS/Theme-TheBoys-Actions-Icon.png",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/THE%20BOYS/Theme-TheBoys-Actions-Icon.png" },
    { category = "THE BOYS", name = "Wallpaper (Home BG)",      kind = "image", file = "assets/THEMES/THEBOYS/Theme-TheBoys2.jpg",              url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/THEMES/THE%20BOYS/Theme-TheBoys2.jpg" },
    { category = "THE BOYS", name = "Theme Music",              kind = "audio", file = "assets/TL-MP3-FILES/THEBOYS/Theme-TheBoys-Music.mp3",   url = "https://github.com/TLMenu/TLASSETS/raw/main/TL-MP3/THEME-MP3/THEME-MUSIC/THEBOYS/The%20Boys%20Homelander%20Theme%20Enhanced%20Version.mp3" },
    { category = "THE BOYS", name = "AFK Voiceline",            kind = "audio", file = "assets/TL-MP3-FILES/TB-AFK-VL0.mp3",                    url = "https://github.com/TLMenu/TLASSETS/raw/main/TL-MP3/THEME-MP3/THEBOYS-AFKSFX/THEBOYS-AFK-VOICELINE.mp3" },

    -- ── ONE PIECE THEME ──────────────────────────────────────────────────────────────
    { category = "ONE PIECE", name = "Home Icon",               kind = "image", file = "assets/THEMES/ONEPIECE/Theme-OnePiece-HomeIcon.png",             url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-OnePiece-HomeIcon.png" },
    { category = "ONE PIECE", name = "Character Icon",          kind = "image", file = "assets/THEMES/ONEPIECE/Theme-OnePiece-CharacterIcon.png",        url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-OnePiece-CharacterIcon.png" },
    { category = "ONE PIECE", name = "Settings Icon",           kind = "image", file = "assets/THEMES/ONEPIECE/Theme-OnePiece-SettingsIcon.png",         url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-OnePiece-SettingsIcon.png" },
    { category = "ONE PIECE", name = "Settings Wallpaper",      kind = "image", file = "assets/THEMES/ONEPIECE/Theme-OnePiece-Setting-Wallpaper.png",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-OnePiece-Setting-Wallpaper.png" },
    { category = "ONE PIECE", name = "Home Wallpaper",          kind = "image", file = "assets/THEMES/ONEPIECE/Theme-OnePiece-Home-Wallpaper2.png",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-OnePiece-Home-Wallpaper2.png" },
    { category = "ONE PIECE", name = "Loading Screen",          kind = "image", file = "assets/THEMES/ONEPIECE/Theme-OnePiece-Loading-Screen.png",       url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-OnePiece-Loading-Screen.png" },
    { category = "ONE PIECE", name = "Playerlist Icon",         kind = "image", file = "assets/THEMES/ONEPIECE/Theme-OnePiece-Playerlist-Icon.png",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-OnePiece-Playerlist-Icon.png" },
    { category = "ONE PIECE", name = "Playerlist Wallpaper",    kind = "image", file = "assets/THEMES/ONEPIECE/Theme-Onepiece-Playerlist-Wallpaper.png", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-Onepiece-Playerlist-Wallpaper.png" },
    { category = "ONE PIECE", name = "Action Wallpaper",        kind = "image", file = "assets/THEMES/ONEPIECE/Theme-OnePiece-Action-Wallpaper.png",     url = "https://github.com/TLMenu/TLASSETS/raw/main/THEMES/ONE%20PIECE/Theme-OnePiece-Action-Wallpaper.png" },
    { category = "ONE PIECE", name = "COM Wallpaper",           kind = "image", file = "assets/THEMES/Theme-OnePiece-Com-Wallpaper.png",                 url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/ONE%20PIECE/Theme-OnePiece-Com-Wallpaper.png" },
    { category = "ONE PIECE", name = "AFK Voiceline 1",         kind = "audio", file = "assets/TL-MP3-FILES/ONEPIECE-AFK-VOICELINE.mp3",                 url = "https://github.com/TLMenu/TLASSETS/raw/main/TL-MP3/THEME-MP3/ONEPIECE-AFKSFX/ONEPIECE-AFK-VOICELINE.mp3" },
    { category = "ONE PIECE", name = "AFK Voiceline 2",         kind = "audio", file = "assets/TL-MP3-FILES/ONEPIECE-AFK-VOICELINE1.mp3",                url = "https://github.com/TLMenu/TLASSETS/raw/main/TL-MP3/THEME-MP3/ONEPIECE-AFKSFX/ONEPIECE-AFK-VOICELINE1.mp3" },
    -- One Piece Playlist
    { category = "ONE PIECE", name = "OP Music 00 (A Very Very Strongest)", kind = "audio", file = "assets/TL-MP3-FILES/OP-M-00.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/A%20VERY%20VERY%20VERY%20STRONGEST.mp3" },
    { category = "ONE PIECE", name = "OP Music 01 (Gear 5 Epic)",           kind = "audio", file = "assets/TL-MP3-FILES/OP-M-01.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/GEAR%205%20EPIC%20VERSION.mp3" },
    { category = "ONE PIECE", name = "OP Music 02 (Gear 5 Drums of Lib.)",  kind = "audio", file = "assets/TL-MP3-FILES/OP-M-02.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/GEAR%205%20THEME%20(DRUMS%20OF%20LIBERATION).mp3" },
    { category = "ONE PIECE", name = "OP Music 03 (Kaizoku Ou)",            kind = "audio", file = "assets/TL-MP3-FILES/OP-M-03.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/KAIZOKU%20OU%20NI%20ORE%20WA%20NARU.mp3" },
    { category = "ONE PIECE", name = "OP Music 04 (Luffy vs Ratchet)",      kind = "audio", file = "assets/TL-MP3-FILES/OP-M-04.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/Luffy%20vs%20Ratchet%20Final%20Battle.mp3" },
    { category = "ONE PIECE", name = "OP Music 05 (Overtaken)",             kind = "audio", file = "assets/TL-MP3-FILES/OP-M-05.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/OVERTAKEN%20(ONE%20PIECE).mp3" },
    { category = "ONE PIECE", name = "OP Music 06 (The Very Strongest)",    kind = "audio", file = "assets/TL-MP3-FILES/OP-M-06.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/The%20Very%20Very%20Very%20Strongest.mp3" },
    { category = "ONE PIECE", name = "OP Music 07 (World's Number One)",    kind = "audio", file = "assets/TL-MP3-FILES/OP-M-07.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/THE%20WORLD'S%20NUMBER%20ONE%20ORE%20WA%20NARU!.mp3" },
    { category = "ONE PIECE", name = "OP Music 08 (Usopp Theme)",           kind = "audio", file = "assets/TL-MP3-FILES/OP-M-08.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/Usopp%20Theme.mp3" },
    { category = "ONE PIECE", name = "OP Music 09 (Zoro Theme)",            kind = "audio", file = "assets/TL-MP3-FILES/OP-M-09.mp3", url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/THEME%20MUSICS/ONEPIECE/Zoro%20Theme.mp3" },

    -- ── DEATH NOTE THEME ─────────────────────────────────────────────────────────────
    { category = "DEATH NOTE", name = "Home Icon",             kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Home-Icon.png",         url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-Home-Icon.png" },
    { category = "DEATH NOTE", name = "Character Icon",        kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-CharacterIcon.png",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-CharacterIcon.png" },
    { category = "DEATH NOTE", name = "Scripts Icon",          kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Scripts-Icon.png",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-Settings-Icon.png" },
    { category = "DEATH NOTE", name = "Settings Icon",         kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Settings-Icon.png",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-Settings-Icon.png" },
    { category = "DEATH NOTE", name = "Com Icon",              kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Com-Icon.png",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-Com-Icon.png" },
    { category = "DEATH NOTE", name = "Char BG",               kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-CharPanelBg.png",       url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-CharacterPanelBackground.png" },
    { category = "DEATH NOTE", name = "Com BG",                kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-ComPanelBg.png",        url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-Com-Background.png" },
    { category = "DEATH NOTE", name = "Actions BG",            kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-ActionsPanelBg.png",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-Actions-Background-Icon.png" },
    { category = "DEATH NOTE", name = "ScriptsPanel BG",       kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-ScriptsPanelBg.png",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-ScriptsPanel-Background.png" },
    { category = "DEATH NOTE", name = "Loading Screen",        kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-LoadingScreen.png",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-Loading-Screen.png" },
    { category = "DEATH NOTE", name = "Home BG",               kind = "image", file = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Home-Background.png",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEATH%20NOTE/Theme-Death-Note-Home-Background-Icon.png" },

    -- ── DEXTER THEME ─────────────────────────────────────────────────────────────────
    { category = "DEXTER", name = "Home Icon",                 kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-HomeIcon.png",           url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEXTER/Theme-Dexter-HomeIcon.png" },
    { category = "DEXTER", name = "Settings Wallpaper",        kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-Settings-Wallpaper.png", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEXTER/Theme-Dexter-Settings-Wallpaper.png" },
    { category = "DEXTER", name = "Settings Icon",             kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-Settings-Icon.png",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEXTER/Theme-Dexter-Settings-Icon.png" },
    { category = "DEXTER", name = "Character Icon",            kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-CharacterIcon.png",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEXTER/Theme-Dexter-CharacterIcon.png" },
    { category = "DEXTER", name = "Character Panel BG",        kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-CharacterPanel.png",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEXTER/Theme-Dexter-CharacterPanel.png" },
    { category = "DEXTER", name = "Scripts Icon",              kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-Scripts-Icon.png",       url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEXTER/Theme-Dexter-Scripts-Icon.png" },
    { category = "DEXTER", name = "Com Wallpaper",             kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-ComWallpaper.png",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEXTER/Theme-Dexter-Com-Wallpaper.png" },
    { category = "DEXTER", name = "Loading Screen",            kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-LoadingScreen.png",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/THEMES/DEXTER/Theme-Dexter-Loading-Screen.png" },
    { category = "DEXTER", name = "Playerlist Icon",           kind = "image", file = "assets/THEMES/DEXTER/Theme-Dexter-Playerlist-Icon.png",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/refs/heads/main/DEXTER/Theme-Dexter-Playerlist-Icon.png" },

    -- ── SFX & AUDIO ──────────────────────────────────────────────────────────────────
    { category = "SFX", name = "Loading Screen Voice",         kind = "audio", file = "assets/TL-MP3-FILES/TLMenuLoadingScreen.mp3",               url = "https://github.com/TLMenu/TLASSETS/raw/main/TL-MP3/TLMenuLoadingScreen.mp3" },
    { category = "SFX", name = "Admin Join Audio",             kind = "audio", file = "assets/TL-MP3-FILES/TLSYSTEM-ADMIN-SFX.mp3",               url = "https://github.com/TLMenu/TLASSETS/raw/main/TL%20SFX/TLMENU-STANDARD-SFX/TLSYSTEM-ADMIN-SFX.mp3" },
}

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 4. INTEGRITY & HEALTH VALIDATION LOGIC
-- ══════════════════════════════════════════════════════════════════════════════════════

-- Prüft die Datei-Header auf bekannte Signaturen (Magic Bytes)
local function _checkBinaryFormat(bytes, kind, filePath)
    if not bytes or #bytes == 0 then
        return false, "0-Byte leere Datei"
    end

    -- Erkennung von HTML-Fehlerseiten / GitHub 404s
    local snippet = bytes:sub(1, 120):lower()
    if snippet:find("<!doctype") or snippet:find("<html") or snippet:find("<body") then
        return false, "Datei enthält HTML-Fehlerseite (GitHub HTML anstatt Binärdatei)"
    end
    if snippet:find("404: not found") or snippet:find('"message":') or snippet:find('"error":') then
        return false, "Datei enthält Server-Fehlermeldung (404 Not Found)"
    end

    if kind == "image" then
        -- PNG: \137PNG\r\n\026\10 (0x89 0x50 0x4E 0x47 0x0D 0x0A 0x1A 0x0A)
        local isPng = (bytes:sub(1, 8) == string.char(137, 80, 78, 71, 13, 10, 26, 10))
        -- JPEG: \255\216\255 (0xFF 0xD8 0xFF)
        local isJpg = (bytes:sub(1, 2) == string.char(255, 216))

        if filePath:lower():find("%.png$") and not isPng then
            return false, "Ungültiger PNG Header (Magische Bytes stimmen nicht)"
        elseif (filePath:lower():find("%.jpg$") or filePath:lower():find("%.jpeg$")) and not isJpg then
            return false, "Ungültiger JPEG Header"
        elseif not isPng and not isJpg then
            return false, "Unbekanntes/korruptes Bildformat"
        end
    elseif kind == "audio" then
        -- MP3: ID3 Tag oder Frame-Sync (0xFF 0xFB / 0xFA / etc.)
        local isId3 = (bytes:sub(1, 3) == "ID3")
        local b1 = string.byte(bytes, 1) or 0
        local isSync = (b1 == 255)

        if not isId3 and not isSync and #bytes < 1024 then
            return false, "Möglicherweise beschädigte oder unvollständige MP3-Audiodatei"
        end
    end

    return true, "OK"
end

-- Validiert eine lokale Datei im Workspace
function TLAssetChecker:ValidateLocalFile(entry)
    local path = entry.file
    if not _safeIsFile(path) then
        return false, "MISSING", "Datei existiert nicht im Workspace"
    end

    local content = _safeReadFile(path)
    if not content or #content == 0 then
        return false, "EMPTY", "Datei ist leer (0 Bytes)"
    end

    local okHeader, headerErr = _checkBinaryFormat(content, entry.kind, path)
    if not okHeader then
        return false, "CORRUPTED_HEADER", headerErr
    end

    -- Prüfung ob Executor getcustomasset die Datei laden kann
    if entry.kind == "image" then
        local customAsset = _safeGetCustomAsset(path)
        if not customAsset then
            return false, "UNLOADABLE", "getcustomasset konnte Datei nicht in rbxasset umwandeln"
        end
    end

    return true, "HEALTHY", "Asset ist intakt und einsatzbereit", content
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 5. STATE MANAGEMENT & OUTDATED DETECTION
-- ══════════════════════════════════════════════════════════════════════════════════════

function TLAssetChecker:LoadState()
    if _safeIsFile(self.StateFilePath) then
        local raw = _safeReadFile(self.StateFilePath)
        if raw and #raw > 0 then
            local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and type(decoded) == "table" then
                return decoded
            end
        end
    end
    return {
        buildId = self.BuildId,
        version = self.Version,
        assets = {}
    }
end

function TLAssetChecker:SaveState(state)
    local dir = self.StateFilePath:match("^(.+/)") or ""
    if dir ~= "" and not _safeIsFolder(dir) then
        _safeMakeFolder(dir)
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(state) end)
    if ok and encoded then
        _safeWriteFile(self.StateFilePath, encoded)
    end
end

-- Berechnet eine einfache Prüfsumme (schnell und überall ohne C-Libs ausführbar)
local function _computeChecksum(str)
    if not str then return "0" end
    local hash = 5381
    local len = #str
    -- Stichprobenartige Bytemischung für maximale Geschwindigkeit bei großen Dateien
    local step = (len > 32768) and math.floor(len / 1000) or 1
    for i = 1, len, step do
        local b = string.byte(str, i)
        hash = (hash * 33 + b) % 4294967296
    end
    return string.format("%x_%d", hash, len)
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 6. DOWNLOAD, AUTO-REPLACE & AUTO-REPAIR
-- ══════════════════════════════════════════════════════════════════════════════════════

-- Auflösungs-Cache: verhindert wiederholte Datei-Scans & Reparatur-Downloads bei jedem GetAsset-Aufruf
local _assetResolveCache = {}
local _repairInFlight    = {}

local function _ensureDirectory(path)
    local dir = path:match("^(.+/)") or ""
    if dir == "" then return true end
    local parts = {}
    for part in dir:gmatch("[^/]+") do
        table.insert(parts, part)
    end
    local current = ""
    for _, part in ipairs(parts) do
        current = (current == "") and part or (current .. "/" .. part)
        if not _safeIsFolder(current) then
            _safeMakeFolder(current)
        end
    end
    return true
end

function TLAssetChecker:DownloadAsset(entry)
    local normalizedUrl = _normalizeUrl(entry.url)
    local res = _httpRequest(normalizedUrl, "GET")

    if not res or (res.StatusCode and res.StatusCode ~= 200) then
        return nil, "Download fehlgeschlagen (HTTP " .. tostring(res and res.StatusCode or "TIMEOUT/ERROR") .. ")"
    end

    local body = res.Body
    if not body or #body == 0 then
        return nil, "Empfangener Inhalt ist leer (0 Bytes)"
    end

    local valid, err = _checkBinaryFormat(body, entry.kind, entry.file)
    if not valid then
        return nil, "Remote-Datei auf GitHub ist selbst fehlerhaft: " .. err
    end

    return body, nil
end

function TLAssetChecker:InstallOrReplace(entry, freshBytes, reason)
    _ensureDirectory(entry.file)
    local ok = _safeWriteFile(entry.file, freshBytes)
    if not ok then
        return false, "writefile fehlgeschlagen (Rechteproblem im Executor?)"
    end
    _assetResolveCache[entry.file] = nil
    return true, "Erfolgreich gespeichert (" .. reason .. ")"
end

-- Führt Jobs in Gruppen mit MaxConcurrent parallel aus (statt sequenziell mit Endlos-Wartezeit)
function TLAssetChecker:_RunJobsParallel(jobs, worker)
    local total = #jobs
    if total == 0 then return end
    local concurrency = math.max(1, math.min(self.Config.MaxConcurrent or 1, total))

    if type(task) ~= "table" or type(task.spawn) ~= "function" then
        for i = 1, total do pcall(worker, jobs[i]) end
        return
    end

    local canJoin = (type(task.join) == "function")
    for chunkStart = 1, total, concurrency do
        local threads = {}
        local chunkEnd = math.min(chunkStart + concurrency - 1, total)
        for i = chunkStart, chunkEnd do
            local job = jobs[i]
            threads[#threads + 1] = task.spawn(function()
                pcall(worker, job)
            end)
        end
        if canJoin then
            for _, thread in ipairs(threads) do
                pcall(task.join, thread)
            end
        else
            -- Fallback: grobe Wartezeit solange die Gruppe braucht
            task.wait(self.Config.ThrottleDelay * 5 + 0.5)
        end
        if chunkStart + concurrency <= total and self.Config.ThrottleDelay > 0 then
            task.wait(self.Config.ThrottleDelay)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 7. HAUPT-PRÜFPROZESS (CHECK ALL)
-- ══════════════════════════════════════════════════════════════════════════════════════

function TLAssetChecker:CheckAll(options)
    -- Reentrance-Guard: nie zwei Scans gleichzeitig, keine wiederholten Dauer-Scans
    if self._scanning then
        if self.Config.LogToConsole then
            print("[TL-CHECKER] Scan läuft bereits – wiederholter Aufruf wird übersprungen.")
        end
        return self.Diagnostics
    end
    self._scanning = true
    local okRun, scanResult = pcall(self._CheckAllImpl, self, options)
    self._scanning = false
    if not okRun then
        warn("[TL-CHECKER] Scan fehlgeschlagen: " .. tostring(scanResult))
        return self.Diagnostics
    end
    return scanResult
end

function TLAssetChecker:_CheckAllImpl(options)
    options = options or {}
    local autoReplace = (options.autoReplace ~= nil) and options.autoReplace or self.Config.AutoReplaceOutdated
    local autoRepair  = (options.autoRepair ~= nil) and options.autoRepair or self.Config.AutoRepairBroken
    local forceSync   = options.forceSync or false
    local scanStart   = tick()

    -- Reset Diagnostics
    self.Diagnostics = {
        TotalScanned    = 0,
        ValidHealthy    = 0,
        Replaced        = {},
        Repaired        = {},
        BrokenDamaged   = {},
        RemoteDead      = {},
        MissingCreated  = {},
    }

    local state = self:LoadState()
    state.assets = state.assets or {}
    local assetsToScan = self.RegisteredAssets
    if #assetsToScan == 0 then
        assetsToScan = MASTER_ASSETS
    end

    if self.Config.LogToConsole then
        print(string.format("[TL-CHECKER] TL ENGINE ASSET CHECKER v%s", self.Version))
        print(string.format("[TL-CHECKER] Phase 1/2: Lokaler Scan von %d Assets (ohne Netzwerk, ohne Wartezeit)...", #assetsToScan))
        if forceSync then
            print("[TL-CHECKER] [MODUS] FORCE-SYNC AKTIVIERT: Alle lokalen Assets werden aktualisiert.")
        end
    end

    -- PHASE 1: Nur lokale Validierung – kein Netzverkehr, keine Throttle-Pausen
    local downloadQueue = {}

    for _, entry in ipairs(assetsToScan) do
        self.Diagnostics.TotalScanned = self.Diagnostics.TotalScanned + 1
        local normalizedUrl = _normalizeUrl(entry.url)
        local isHealthy, statusType, statusMsg, localBytes = self:ValidateLocalFile(entry)
        local cachedMeta = state.assets[entry.file]
        local isOutdated = false
        local outdatedReason = ""

        -- 1. Prüfen ob URL im Script geändert wurde (z.B. Bugfix für Settings-Icon)
        if cachedMeta and cachedMeta.url and cachedMeta.url ~= normalizedUrl then
            isOutdated = true
            outdatedReason = "URL wurde im Script aktualisiert (alt: " .. cachedMeta.url:sub(1, 30) .. "...)"
        end

        -- 2. Prüfen ob Force-Sync anliegt
        if forceSync then
            isOutdated = true
            outdatedReason = "Erzwungener Force-Sync durch Benutzer/Entwickler"
        end

        -- Fall A: Datei ist beschädigt oder korrupt -> Reparatur-Download einreihen
        if not isHealthy and statusType ~= "MISSING" then
            table.insert(self.Diagnostics.BrokenDamaged, {
                entry = entry,
                error = statusMsg,
                type = statusType
            })
            if autoRepair then
                downloadQueue[#downloadQueue + 1] = { entry = entry, url = normalizedUrl, mode = "repair", reason = statusMsg }
            end

        -- Fall B: Datei fehlt komplett -> Download einreihen
        elseif statusType == "MISSING" then
            downloadQueue[#downloadQueue + 1] = { entry = entry, url = normalizedUrl, mode = "missing" }

        -- Fall C: Datei ist lokal vorhanden, aber VERALTET -> Replace einreihen
        elseif isOutdated and autoReplace then
            downloadQueue[#downloadQueue + 1] = { entry = entry, url = normalizedUrl, mode = "outdated", reason = outdatedReason }

        -- Fall D: Datei ist gesund und aktuell
        else
            self.Diagnostics.ValidHealthy = self.Diagnostics.ValidHealthy + 1
            if not cachedMeta and localBytes then
                state.assets[entry.file] = {
                    url = normalizedUrl,
                    size = #localBytes,
                    checksum = _computeChecksum(localBytes),
                    updatedAt = os.time and os.time() or tick()
                }
            end
        end
    end

    -- PHASE 2: Netzwerk-Teile parallel laden (MaxConcurrent) statt sequenziell mit Dauer-Warten
    if #downloadQueue > 0 then
        if self.Config.LogToConsole then
            print(string.format("[TL-CHECKER] Phase 2/2: %d Download(s)/Reparatur(en), parallelisiert (x%d)...",
                #downloadQueue, math.max(1, self.Config.MaxConcurrent or 1)))
        end

        self:_RunJobsParallel(downloadQueue, function(job)
            local entry = job.entry
            local freshBytes, dlErr = self:DownloadAsset(entry)

            if not freshBytes then
                if job.mode == "outdated" then
                    -- GitHub nicht erreichbar: gesunde lokale Datei behalten
                    self.Diagnostics.ValidHealthy = self.Diagnostics.ValidHealthy + 1
                else
                    table.insert(self.Diagnostics.RemoteDead, {
                        entry = entry,
                        reason = (job.mode == "missing")
                            and ("Fehlt lokal & Remote nicht erreichbar: " .. tostring(dlErr))
                            or  tostring(dlErr or "Download fehlgeschlagen")
                    })
                end
                return
            end

            local replaceReason = (job.mode == "repair") and "Defektes Asset repariert"
                or (job.mode == "outdated") and "Outdated Replace"
                or "Erstmaliger Download"

            local installed, instErr = self:InstallOrReplace(entry, freshBytes, replaceReason)
            if not installed then
                table.insert(self.Diagnostics.RemoteDead, { entry = entry, reason = instErr })
                return
            end

            state.assets[entry.file] = {
                url = job.url,
                size = #freshBytes,
                checksum = _computeChecksum(freshBytes),
                updatedAt = os.time and os.time() or tick()
            }

            if job.mode == "repair" then
                table.insert(self.Diagnostics.Repaired, { entry = entry, oldError = job.reason })
            elseif job.mode == "missing" then
                table.insert(self.Diagnostics.MissingCreated, entry)
            else
                table.insert(self.Diagnostics.Replaced, { entry = entry, reason = job.reason })
            end
        end)
    end

    -- PHASE 3 (optional): Tiefen-Rendering-Scan – erkennt Bilder, die Roblox nicht laden kann
    if self.Config.DeepImagePreload then
        local preloadList, preloadMap = {}, {}
        for _, entry in ipairs(assetsToScan) do
            if entry.kind == "image" and _safeIsFile(entry.file) then
                local assetId = _safeGetCustomAsset(entry.file)
                if assetId and assetId ~= "" then
                    preloadList[#preloadList + 1] = assetId
                    preloadMap[assetId] = entry
                end
            end
        end
        if #preloadList > 0 then
            pcall(function()
                ContentProvider:PreloadAsync(preloadList, function(contentId, status)
                    if status ~= Enum.AssetFetchStatus.Success then
                        local failedEntry = preloadMap[contentId]
                        if failedEntry then
                            table.insert(self.Diagnostics.BrokenDamaged, {
                                entry = failedEntry,
                                error = "Rendering-Check fehlgeschlagen: " .. tostring(status),
                                type = "PRELOAD_FAILED"
                            })
                        end
                    end
                end)
            end)
        end
    end

    self:SaveState(state)
    self:PrintDiagnosticReport()
    if self.Config.LogToConsole then
        print(string.format("[TL-CHECKER] Scan abgeschlossen in %.2fs.", tick() - scanStart))
    end
    return self.Diagnostics
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 8. F9 KONSOLEN-REPORT (FÜR ENTWICKLER & FEHLERBEHEBUNG)
-- ══════════════════════════════════════════════════════════════════════════════════════

function TLAssetChecker:PrintDiagnosticReport()
    if not self.Config.LogToConsole then return end

    local diag = self.Diagnostics

    -- 1. Erfolgreich ersetzte / reparierte Assets
    if #diag.Replaced > 0 then
        print("\n🔄 [TL-CHECKER] [AUTOMATISCH ERSETZTE ASSETS (OUTDATED -> NEU)]:")
        for _, item in ipairs(diag.Replaced) do
            print(string.format("  • [%s] %s (%s)", item.entry.category, item.entry.name, item.entry.file))
            print(string.format("    -> Grund: %s", item.reason))
        end
    end

    if #diag.Repaired > 0 then
        print("\n🛠️ [TL-CHECKER] [ERFOLGREICH REPARIERTE ASSETS (VOM ENTWICKLER-GITHUB GEHOLT)]:")
        for _, item in ipairs(diag.Repaired) do
            print(string.format("  • [%s] %s -> Fehler war: %s (Erfolgreich repariert!)", item.entry.category, item.entry.name, item.oldError))
        end
    end

    if #diag.MissingCreated > 0 then
        print(string.format("\n📥 [TL-CHECKER] %d fehlende Assets erfolgreich neu heruntergeladen.", #diag.MissingCreated))
    end

    -- 2. BESCHÄDIGTE / DEFEKTE ASSETS (PROMINENT MIT WARN IN F9)
    if #diag.BrokenDamaged > 0 or #diag.RemoteDead > 0 then
        warn("\n" .. string.rep("═", 86))
        warn("⚠️  [TL-CHECKER] WARNUNG: BESCHÄDIGTE ODER DEFEKTE ASSETS ERKANNT!")
        warn("   Die folgenden Assets konnten nicht geladen werden oder haben ungültige GitHub URLs.")
        warn("   Bitte überprüfe die aufgelisteten Dateien und URLs zur Reparatur:")
        warn(string.rep("═", 86))

        local brokenCount = 0
        for _, item in ipairs(diag.BrokenDamaged) do
            brokenCount = brokenCount + 1
            warn(string.format("\n[%d] DEFEKTE LOKALE DATEI:", brokenCount))
            warn("  • Name:      " .. tostring(item.entry.name) .. " [" .. tostring(item.entry.category) .. "]")
            warn("  • Pfad:      " .. tostring(item.entry.file))
            warn("  • Fehler:    " .. tostring(item.error) .. " (Typ: " .. tostring(item.type) .. ")")
            warn("  • GitHub-URL: " .. tostring(item.entry.url))
        end

        for _, item in ipairs(diag.RemoteDead) do
            brokenCount = brokenCount + 1
            warn(string.format("\n[%d] FEHLERHAFTE GITHUB-URL (AUF GITHUB REPARIEREN!):", brokenCount))
            warn("  • Name:      " .. tostring(item.entry.name) .. " [" .. tostring(item.entry.category) .. "]")
            warn("  • Pfad:      " .. tostring(item.entry.file))
            warn("  • Grund:     " .. tostring(item.reason))
            warn("  • Defekte URL: " .. tostring(item.entry.url))
            warn("  -> Hinweis: Überprüfe ob die Datei im GitHub-Repository existiert oder ob es ein 404 Fehler ist!")
        end
        warn("\n" .. string.rep("═", 86))
    end

    -- 3. Finale Statistik
    print(string.format([[

══════════════════════════════════════════════════════════════════════════════════════
  TL ENGINE ASSET CHECKER – ZUSAMMENFASSUNG:
  • Gesamt geprüft:         %d
  • Intakt & Gültig:        %d
  • Automatisch Ersetzt:    %d (Veraltete Assets aktualisiert)
  • Repariert:              %d (Korrupte/Leere Dateien gerettet)
  • Fehlend Heruntergeladen: %d
  • Kritisch Defekt / 404:  %d %s
══════════════════════════════════════════════════════════════════════════════════════
]],
        diag.TotalScanned,
        diag.ValidHealthy,
        #diag.Replaced,
        #diag.Repaired,
        #diag.MissingCreated,
        #diag.RemoteDead,
        (#diag.RemoteDead > 0) and "(⚠️ SIEHE F9 WARNUNGEN OBEN ZUR BEHEBUNG)" or "(Alles sauber!)"
    ))
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 9. PUBLIC API & GUI HELPER METHODEN
-- ══════════════════════════════════════════════════════════════════════════════════════

-- Lädt ein Asset sicher als rbxasset oder URL. Ergebnis wird gecacht -> kein Dauer-Scan,
-- kein wiederholter Reparatur-Download pro Aufruf.
function TLAssetChecker:GetAsset(filePath, fallbackUrl)
    if not filePath then return fallbackUrl or "" end

    local cached = _assetResolveCache[filePath]
    if cached then return cached end

    if _safeIsFile(filePath) then
        local content = _safeReadFile(filePath)
        if content and #content > 0 then
            local assetId = _safeGetCustomAsset(filePath)
            if assetId and assetId ~= "" then
                _assetResolveCache[filePath] = assetId
                return assetId
            end
        end
    end

    -- Lokal kaputt oder fehlend: genau EIN Reparatur-Download pro Datei anstoßen
    for _, item in ipairs(MASTER_ASSETS) do
        if item.file == filePath then
            if not _repairInFlight[filePath] then
                _repairInFlight[filePath] = true
                task.spawn(function()
                    local freshBytes = self:DownloadAsset(item)
                    if freshBytes then
                        self:InstallOrReplace(item, freshBytes, "OnDemand AutoRepair")
                    end
                    _repairInFlight[filePath] = nil
                end)
            end
            return item.url or fallbackUrl or ""
        end
    end

    return fallbackUrl or ""
end

-- Wendet ein Asset direkt auf ein ImageLabel oder ImageButton an (inklusive Sicherheitscheck)
function TLAssetChecker:ApplyToImage(imageGui, filePath, fallbackUrl)
    if not imageGui or typeof(imageGui) ~= "Instance" then return false end
    local assetId = self:GetAsset(filePath, fallbackUrl)
    if assetId and assetId ~= "" then
        pcall(function()
            imageGui.Image = assetId
        end)
        return true
    end
    return false
end

-- Startet einen erzwungenen Abgleich aller Assets mit GitHub (ohne manuelles Ordnerlöschen)
function TLAssetChecker:ForceSync()
    return self:CheckAll({ forceSync = true, autoReplace = true, autoRepair = true })
end

-- Registriert ein zusätzliches benutzerdefiniertes Asset zur Prüfung
function TLAssetChecker:RegisterAsset(entry)
    if type(entry) == "table" and entry.file and entry.url then
        table.insert(self.RegisteredAssets, {
            category = entry.category or "CUSTOM",
            name     = entry.name or entry.file,
            kind     = entry.kind or "image",
            file     = entry.file,
            url      = entry.url
        })
    end
end

-- Initialisiere Master Assets in der Registrierung
for _, item in ipairs(MASTER_ASSETS) do
    table.insert(TLAssetChecker.RegisteredAssets, item)
end

-- Globale Exporte für Executor & TLMenu
_genv.TLAssetChecker = TLAssetChecker
_G.TLAssetChecker    = TLAssetChecker
_G.TLCheckAssets     = function(force) return TLAssetChecker:CheckAll({ forceSync = force == true }) end
_G.TLForceSyncAssets = function() return TLAssetChecker:ForceSync() end

-- Automatische Ausführung beim direkten Laden des Skripts
task.spawn(function()
    TLAssetChecker:CheckAll()
end)

return TLAssetChecker
