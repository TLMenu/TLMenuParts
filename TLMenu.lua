--!nocheck
_G._invisSinkEnabled = true; _G._invisAnimEnabled = true; _invisSinkEnabled = true; _invisAnimEnabled = true; local _realTS =
game:GetService("TweenService")
local _tsProxy       = setmetatable({}, {
    __index = function(self, k)
        if k == "Create" then
            return function(_, obj, tInfo, props)
                if typeof(obj) ~= "Instance" then
                    local dummyEvent = { Connect = function() end, Wait = function() end }
                    return { Play = function() end, Cancel = function() end, Pause = function() end, Completed =
                    dummyEvent }
                end
                return _realTS:Create(obj, tInfo, props)
            end
        end
        if type(_realTS[k]) == "function" then
            return function(_, ...) return _realTS[k](_realTS, ...) end
        end
        return _realTS[k]
    end
})

local _genv          = (getgenv and getgenv()) or _G
local _SvcUIS        = game:GetService("UserInputService")
local _SvcRS         = game:GetService("RunService")
local _SvcPlr        = game:GetService("Players")
local _SvcSG         = game:GetService("StarterGui")
local _SvcSnd        = game:GetService("SoundService")
local _SvcDeb        = game:GetService("Debris")
local _SvcCP         = game:GetService("ContentProvider")
local _SvcHttp       = game:GetService("HttpService")
local _LocalPlayer   = _SvcPlr.LocalPlayer

local _ADMIN_USERS   = { ["18369137"] = true }
local _isAdminUser   = false
pcall(function() _isAdminUser = (_ADMIN_USERS[tostring(_LocalPlayer.Name)] == true) end)

local task                    = (type(task) == "table" and task) or {
    wait  = function(t) return wait(t or 0) end,
    spawn = function(f, ...) return spawn(f, ...) end,
    delay = function(t, f, ...) return delay(t, f, ...) end,
    defer = function(f, ...) return spawn(f, ...) end
}

local ROLES_URL               = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NametagRoles.json"
local NAMETAG_CONFIG_URL      = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NametagConfig.json"
local SCRIPT_URL              = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/covertnet.lua"
local EMOTEWHEEL_URL          = "https://raw.githubusercontent.com/telelumi/TL-EX/refs/heads/main/TL-SCRIPTS/TL-EX-EMOTEWHEEL"
local NameOverrides           = {}
local AdminNames              = {}
local LoadRolesFromGithub

local nametagImageUrl      = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/nametag-uploads/nametag-image.png"
local nametagImageFileName = "assets/TL-ROLE-PICS/nametag-image.png"

local ownerProfilePicUrl      = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-telelumi.png"
local ownerProfilePicFileName = "assets/TL-ROLE-PICS/TL-telelumi.png"

local userProfilePicUrl      = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TLUSER-ROLE.png"
local userProfilePicFileName = "assets/ROLE-ICONS/TLUSER-ROLE.png"

local customUserAvatars = {
    ["usxirr"] = {
        url  = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-Oso.png",
        file = "assets/TL-ROLE-PICS/TL-Usxirr.png",
        strokeColor = ColorSequence.new(Color3.fromHex("#9A7211"), Color3.fromHex("#000000")),
    },
    ["Abxsent0"] = {
        url  = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-Abxsent0.png",
        file = "assets/ROLE-ICONS/TL-Abxsent0.png",
        strokeColor = ColorSequence.new(Color3.fromHex("#06402B"), Color3.fromHex("#88E788")),
    },
}

local dragonballMusicUrl             = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/THEME-MP3/THEME-MUSIC/DRAGONBALL/DRAGONBALL-THEME-MUSIC-1.mp3"
local dragonballMusicFileName        = "assets/TL-MP3-FILES/DragonBall-Music1.mp3"

local dragonballSettingsIconUrl      = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DRAGONBALL/Theme-Dragonball-Settings-Icon.png"
local dragonballSettingsIconFileName = "assets/THEMES/DRAGONBALL/Theme-Dragonball-Settings-Icon.png"

local dragonballBgUrl      = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DRAGONBALL/Theme-Dragonball-Home-Wallpaper.png"
local dragonballBgFileName = "assets/THEMES/DRAGONBALL/Theme-Dragonball-Home-Wallpaper.png"

local onePieceActionBgUrl      = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ONE%20PIECE/Theme-OnePiece-Action-Wallpaper.png"
local onePieceActionBgFileName = "assets/THEMES/ONEPIECE/OP-ACT-BG.png"

local adminAudioUrl           = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/TLSYSTEM-ADMIN-SFX.mp3"
local adminAudioFileName      = "assets/TL-MP3-FILES/TLSYSTEM-ADMIN-SFX.mp3"

local theBoysScriptsIconUrl      = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/THE%20BOYS/Theme-TheBoys-Scripts-Icon.png"
local theBoysScriptsIconFileName = "assets/THEMES/THEBOYS/Theme-TheBoys-Scripts-Icon.png"
local theBoysSettingsIconUrl     = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/THE%20BOYS/Theme-TheBoys-Settings-Icon.png"
local theBoysSettingsIconFileName = "assets/THEMES/THEBOYS/Theme-TheBoys-Settings-Icon.png"
local theBoysHomeIconUrl         = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/THE%20BOYS/Theme-TheBoys-HomeIcon.png"
local theBoysHomeIconFileName    = "assets/THEMES/THEBOYS/Theme-TheBoys-HomeIcon.png"
local theBoysActionsIconUrl      = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/THE%20BOYS/Theme-TheBoys-Actions-Icon.png"
local theBoysActionsIconFileName = "assets/THEMES/THEBOYS/Theme-TheBoys-Actions-Icon.png"
local theBoysBgUrl               = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/THE%20BOYS/Theme-TheBoys2.png"
local theBoysBgFileName          = "assets/THEMES/THEBOYS/Theme-TheBoys2.png"
local theBoysMusicUrl            = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/THEME-MP3/THEME-MUSIC/THEBOYS/The%20Boys%20Homelander%20Theme%20Enhanced%20Version.mp3"
local theBoysMusicFileName       = "assets/TL-MP3-FILES/Theme-TheBoys-Music.mp3"

local comTabIconUrl              = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Com-Icon.png"
local comTabIconFileName         = "assets/TL-DEFAULT/Com-Icon.png"

local homeTabIconUrl             = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/HomeTab-Icon.png"
local homeTabIconFileName        = "assets/TL-DEFAULT/HomeTab-Icon.png"

local characterTabIconUrl        = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Character-Icon.png"
local characterTabIconFileName   = "assets/TL-DEFAULT/Character-Icon.png"

local scriptsTabIconUrl          = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Scripts-Icon.png"
local scriptsTabIconFileName     = "assets/TL-DEFAULT/Scripts-Icon.png"

local actionsTabIconUrl          = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/ActionTab-Icon.png"
local actionsTabIconFileName     = "assets/TL-DEFAULT/ActionTab-Icon.png"

local playerlistTabIconUrl       = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Playerlist-Icon.png"
local playerlistTabIconFileName  = "assets/TL-DEFAULT/Playerlist-Icon.png"

local deathNoteHomeIconUrl         = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-Home-Icon.png"
local deathNoteHomeIconFileName    = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Home-Icon.png"
local deathNoteCharIconUrl         = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-CharacterIcon.png"
local deathNoteCharIconFileName    = "assets/THEMES/DEATHNOTE/Theme-Death-Note-CharacterIcon.png"
local deathNoteScriptsIconUrl      = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-Scripts-Icon.png"
local deathNoteScriptsIconFileName = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Scripts-Icon.png"
local deathNoteSettingsIconUrl     = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-Settings-Icon.png"
local deathNoteSettingsIconFileName = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Settings-Icon.png"
local deathNoteComIconUrl          = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-Com-Icon.png"
local deathNoteComIconFileName     = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Com-Icon.png"
local deathNoteCharBgUrl           = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-CharacterPanelBackground.png"
local deathNoteCharBgFileName      = "assets/THEMES/DEATHNOTE/Theme-Death-Note-CharPanelBg.png"
local deathNoteComBgUrl            = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-Com-Background.png"
local deathNoteComBgFileName       = "assets/THEMES/DEATHNOTE/Theme-Death-Note-ComPanelBg.png"
local deathNoteScriptsBgUrl        = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-Actions-Background-Icon.png"
local deathNoteScriptsBgFileName   = "assets/THEMES/DEATHNOTE/Theme-Death-Note-ActionsPanelBg.png"
local deathNoteScriptsPanelBgUrl    = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-ScriptsPanel-Background.png"
local deathNoteScriptsPanelBgFileName = "assets/THEMES/DEATHNOTE/Theme-Death-Note-ScriptsPanelBg.png"
local deathNoteLoadingScreenUrl    = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-Loading-Screen.png"
local deathNoteLoadingScreenFileName = "assets/THEMES/DEATHNOTE/Theme-Death-Note-LoadingScreen.png"
local deathNoteHomeBgUrl            = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEATH%20NOTE/Theme-Death-Note-Home-Background-Icon.png"
local deathNoteHomeBgFileName       = "assets/THEMES/DEATHNOTE/Theme-Death-Note-Home-Background.png"

local dexterCharIconUrl             = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEXTER/Theme-Dexter-CharacterIcon.png"
local dexterCharIconFileName        = "assets/DEXTER/Theme-Dexter-CharacterIcon.png"
local dexterCharBgUrl               = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEXTER/Theme-Dexter-CharacterPanel.png"
local dexterCharBgFileName          = "assets/DEXTER/Theme-Dexter-CharacterPanel.png"
local dexterSettingsIconUrl         = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEXTER/Theme-Dexter-Settings-Icon.png"
local dexterSettingsIconFileName    = "assets/DEXTER/Theme-Dexter-Settings-Icon.png"
local dexterScriptsIconUrl          = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEXTER/Theme-Dexter-Scripts-Icon.png"
local dexterScriptsIconFileName     = "assets/DEXTER/Theme-Dexter-Scripts-Icon.png"
local dexterComBgUrl                = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEXTER/Theme-Dexter-Com-Wallpaper.png"
local dexterComBgFileName           = "assets/DEXTER/Theme-Dexter-ComWallpaper.png"
local dexterLoadingScreenUrl        = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEXTER/Theme-Dexter-Loading-Screen.png"
local dexterLoadingScreenFileName   = "assets/DEXTER/Theme-Dexter-LoadingScreen.png"
local dexterPlayerlistIconUrl       = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/DEXTER/Theme-Dexter-Playerlist-Icon.png"
local dexterPlayerlistIconFileName  = "assets/DEXTER/Theme-Dexter-Playerlist-Icon.png"

local loadingScreenVoiceUrl      = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/TLMenuLoadingScreen.mp3"
local loadingScreenVoiceFileName = "assets/TL-MP3-FILES/TLMenuLoadingScreen.mp3"

local _TL_assetLoader = {
    started = false,
    ready   = false,
    total   = 0,
    done    = 0,
    failed  = 0,
    current = "Preparing assets...",
}
rawset(_genv, "_TL_assetLoader", _TL_assetLoader)

local _TL_expectedAssetFiles = {}
rawset(_genv, "_TL_expectedAssetFiles", _TL_expectedAssetFiles)

local _TL_configReady = false
rawset(_genv, "_TL_configReady", _TL_configReady)

local function _TL_safeIsFile(path)
    if type(isfile) ~= "function" then return false end
    local ok, result = pcall(isfile, path)
    return ok and result == true
end

local function _TL_safeIsFolder(path)
    if type(isfolder) ~= "function" then return false end
    local ok, result = pcall(isfolder, path)
    return ok and result == true
end

local function _TL_safeMakeFolder(path)
    if type(makefolder) ~= "function" then return false end
    local ok = pcall(makefolder, path)
    return ok
end

local function _TL_safeWriteFile(path, bytes)
    if type(writefile) ~= "function" then return false end
    local ok = pcall(writefile, path, bytes)
    return ok
end

local function _TL_safeGetCustomAsset(path)
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

local _TL_MANIFEST_URL = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/tl-assets-manifest.json"
local _TL_MANIFEST_CACHE = "assets/manifest-cache.json"

local function _TL_recursiveListFiles(dir)
    local results = {}
    local ok, entries = pcall(function() return listfiles(dir) end)
    if not ok or type(entries) ~= "table" then return results end
    for _, entry in ipairs(entries) do
        if _TL_safeIsFolder(entry) then
            local sub = _TL_recursiveListFiles(entry)
            for _, v in ipairs(sub) do
                results[#results + 1] = v
            end
        else
            results[#results + 1] = entry
        end
    end
    return results
end

local function _TL_loadManifest()
    local ok, cached = pcall(readfile, _TL_MANIFEST_CACHE)
    if ok and cached then
        local decodeOk, decoded = pcall(function() return _SvcHttp:JSONDecode(cached) end)
        if decodeOk and decoded then return decoded end
    end
    local fetchOk, fetched = pcall(function() return (game :: any):HttpGet(_TL_MANIFEST_URL) end)
    if fetchOk and fetched then
        pcall(writefile, _TL_MANIFEST_CACHE, fetched)
        local decodeOk, decoded = pcall(function() return _SvcHttp:JSONDecode(fetched) end)
        if decodeOk and decoded then return decoded end
    end
    return nil
end

local function _TL_syncAssetsFromManifest()
    local manifest = _TL_loadManifest()
    if not manifest then return end
    local baseUrl = manifest.baseUrl or ""
    local tlassetsUrl = manifest.tlassetsUrl or ""
    local expectedFiles = {}
    local allEntries = {}
    for _, entry in ipairs(manifest.images or {}) do
        local repoPath = entry.repo or ""
        local url = repoPath:match("^tlassets:") and (tlassetsUrl .. "/" .. repoPath:gsub("^tlassets:", "")) or (baseUrl .. "/" .. repoPath)
        allEntries[#allEntries + 1] = { name = entry.name, url = url, file = entry.file, kind = "image" }
        expectedFiles[entry.file] = true
        _TL_expectedAssetFiles[entry.file] = { url = url, kind = "image" }
    end
    for _, entry in ipairs(manifest.audio or {}) do
        local repoPath = entry.repo or ""
        local url = repoPath:match("^tlassets:") and (tlassetsUrl .. "/" .. repoPath:gsub("^tlassets:", "")) or (baseUrl .. "/" .. repoPath)
        allEntries[#allEntries + 1] = { name = entry.name, url = url, file = entry.file, kind = "audio" }
        expectedFiles[entry.file] = true
        _TL_expectedAssetFiles[entry.file] = { url = url, kind = "audio" }
    end
    for _, entry in ipairs(allEntries) do
        if not _TL_safeIsFile(entry.file) then
            local dir = entry.file:match("^(.+/)") or ""
            if dir ~= "" and not _TL_safeIsFolder(dir) then
                pcall(function() _TL_safeMakeFolder(dir) end)
            end
            local ok, bytes = pcall(function() return (game :: any):HttpGet(entry.url) end)
            if ok and type(bytes) == "string" and #bytes > 0 then
                _TL_safeWriteFile(entry.file, bytes)
            end
        end
    end
end

task.spawn(function()
    pcall(_TL_syncAssetsFromManifest)
end)

task.spawn(function()
    _TL_assetLoader.started = true
    pcall(function()

    
    if not _TL_safeIsFolder("assets") then
        _TL_safeMakeFolder("assets")
    end
    pcall(function()
        if not _TL_safeIsFolder("assets/TL-MP3-FILES") then _TL_safeMakeFolder("assets/TL-MP3-FILES") end
        if not _TL_safeIsFolder("assets/TL-ROLE-PICS") then _TL_safeMakeFolder("assets/TL-ROLE-PICS") end
        if not _TL_safeIsFolder("assets/TL-DEFAULT") then _TL_safeMakeFolder("assets/TL-DEFAULT") end
        if not _TL_safeIsFolder("assets/ROLE-ICONS") then _TL_safeMakeFolder("assets/ROLE-ICONS") end
        if not _TL_safeIsFolder("assets/THEMES") then _TL_safeMakeFolder("assets/THEMES") end
        if not _TL_safeIsFolder("assets/THEMES/DRAGONBALL") then _TL_safeMakeFolder("assets/THEMES/DRAGONBALL") end
        if not _TL_safeIsFolder("assets/THEMES/ONEPIECE") then _TL_safeMakeFolder("assets/THEMES/ONEPIECE") end
        if not _TL_safeIsFolder("assets/THEMES/THEBOYS") then _TL_safeMakeFolder("assets/THEMES/THEBOYS") end
        if not _TL_safeIsFolder("assets/THEMES/DEATHNOTE") then _TL_safeMakeFolder("assets/THEMES/DEATHNOTE") end
        if not _TL_safeIsFolder("assets/THEMES/DEXTER") then _TL_safeMakeFolder("assets/THEMES/DEXTER") end
    end)

    
    
    
    local assets = {
        
        { name = "TLMenu Loading Screen",  url = loadingScreenVoiceUrl,        file = loadingScreenVoiceFileName,        kind = "audio", priority = 1 },
        { name = "TL Owner Profile Picture",   url = ownerProfilePicUrl,           file = ownerProfilePicFileName,           kind = "image", priority = 1 },
        { name = "TL User Profile Picture",    url = userProfilePicUrl,            file = userProfilePicFileName,            kind = "image", priority = 1 },
        { name = "usxirr Custom Avatar",       url = customUserAvatars["usxirr"].url, file = customUserAvatars["usxirr"].file, kind = "image", priority = 1 },
        { name = "Abxsent0 Custom Avatar",     url = customUserAvatars["Abxsent0"].url, file = customUserAvatars["Abxsent0"].file, kind = "image", priority = 1 },
        { name = "TL Staff Icon", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ROLE-ICONS/TL-STAFF.png", file = "assets/ROLE-ICONS/TL-STAFF.png", kind = "image", priority = 1 },
        { name = "TL Arda Avatar", url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-Arda.png", file = "assets/TL-ROLE-PICS/TL-Arda.png", kind = "image", priority = 1 },
        { name = "TL Sec Avatar", url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-Sec.png", file = "assets/TL-ROLE-PICS/TL-Sec.png", kind = "image", priority = 1 },
        { name = "TL Sleepy Avatar", url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/TL-Sleepy.jpg", file = "assets/TL-ROLE-PICS/TL-Sleepy.jpg", kind = "image", priority = 1 },
        { name = "R5yn Avatar", url = "https://raw.githubusercontent.com/TLMenu/TLMenu.github.io/refs/heads/main/NAMETAG-PROFILEPICTURES/R5yn.png", file = "assets/TL-ROLE-PICS/R5yn.png", kind = "image", priority = 1 },
        { name = "Communication Tab Icon",     url = comTabIconUrl,                file = comTabIconFileName,                kind = "image", priority = 1 },
        { name = "Home Tab Icon",              url = homeTabIconUrl,               file = homeTabIconFileName,               kind = "image", priority = 1 },
        { name = "Character Tab Icon",         url = characterTabIconUrl,          file = characterTabIconFileName,          kind = "image", priority = 1 },
        { name = "Scripts Tab Icon",           url = scriptsTabIconUrl,            file = scriptsTabIconFileName,            kind = "image", priority = 1 },
        { name = "Actions Tab Icon",           url = actionsTabIconUrl,            file = actionsTabIconFileName,            kind = "image", priority = 1 },
        { name = "Playerlist Tab Icon",        url = playerlistTabIconUrl,         file = playerlistTabIconFileName,         kind = "image", priority = 1 },
        { name = "VC Unmuted Icon",            url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/ANTIVCBAN-Unmuted-Icon.png", file = "assets/TL-DEFAULT/TL_Unmuted.png", kind = "image", priority = 1 },
        { name = "VC Muted Icon",              url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/ANTIVCBAN-Mute-Icon.png",    file = "assets/TL-DEFAULT/TL_Muted.png",   kind = "image", priority = 1 },

        { name = "TL Default Emote Icon",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Emote-Icon.png",          file = "assets/TL-DEFAULT/Emote-Icon.png",          kind = "image", priority = 2 },
        { name = "TL Default Music Icon",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Music-Icon.png",          file = "assets/TL-DEFAULT/Music-Icon.png",          kind = "image", priority = 2 },
        { name = "TL Default Visual Icon",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Visual-Icon.png",          file = "assets/TL-DEFAULT/Visual-Icon.png",          kind = "image", priority = 2 },
        { name = "TL Default Visual2 Icon",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Visual2-Icon.png",         file = "assets/TL-DEFAULT/Visual2-Icon.png",         kind = "image", priority = 2 },
        { name = "TL Default Movement Icon",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Movement-Icon.png",        file = "assets/TL-DEFAULT/Movement-Icon.png",        kind = "image", priority = 2 },
        { name = "TL Default Misc Icon",       url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Misc-Icon.png",            file = "assets/TL-DEFAULT/Misc-Icon.png",            kind = "image", priority = 2 },
        { name = "TL Default Colors Icon",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Colors-Icon.png",          file = "assets/TL-DEFAULT/Colors-Icon.png",          kind = "image", priority = 2 },
        { name = "TL Default Theme Icon",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Theme-Icon.png",           file = "assets/TL-DEFAULT/Theme-Icon.png",           kind = "image", priority = 2 },
        { name = "TL Default Themes Icon",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Themes-Icon.png",          file = "assets/TL-DEFAULT/Themes-Icon.png",          kind = "image", priority = 2 },
        { name = "TL Default Keybind Icon",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Keybind-Icon.png",         file = "assets/TL-DEFAULT/Keybind-Icon.png",         kind = "image", priority = 2 },
        { name = "TL Default Cursor Icon",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Cursor-Icon.png",          file = "assets/TL-DEFAULT/Cursor-Icon.png",          kind = "image", priority = 2 },
        { name = "TL Default CustomCursor Icon", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/CustomCursor-Icon%20(2).png", file = "assets/TL-DEFAULT/CustomCursor-Icon.png", kind = "image", priority = 2 },
        { name = "TL Default Search Icon",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Search-Icon.png",          file = "assets/TL-DEFAULT/Search-Icon.png",          kind = "image", priority = 2 },
        { name = "TL Default Search2 Icon",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Search2-Icon.png",         file = "assets/TL-DEFAULT/Search2-Icon.png",         kind = "image", priority = 2 },
        { name = "TL Default Minimize Icon",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/Minimize-Icon.png",        file = "assets/TL-DEFAULT/Minimize-Icon.png",        kind = "image", priority = 2 },
        { name = "TL Default MusicPlay Icon",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/MusicPlay-Icon.png",       file = "assets/TL-DEFAULT/MusicPlay-Icon.png",       kind = "image", priority = 2 },
        { name = "TL Default MusicPause Icon", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/MusicPause-Icon.png",      file = "assets/TL-DEFAULT/MusicPause-Icon.png",      kind = "image", priority = 2 },
        { name = "TL Default MusicBack Icon",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/MusicBack-Icon.png",       file = "assets/TL-DEFAULT/MusicBack-Icon.png",       kind = "image", priority = 2 },
        { name = "TL Default MusicSkip Icon",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/MusicSkip-Icon.png",       file = "assets/TL-DEFAULT/MusicSkip-Icon.png",       kind = "image", priority = 2 },
        { name = "TL Default PING-WLAN Icon",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/PING-WLAN-Icon.png",       file = "assets/TL-DEFAULT/PING-WLAN-Icon.png",       kind = "image", priority = 2 },
        { name = "TL Default PunchFling Icon", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/PunchFling-Icon.png",      file = "assets/TL-DEFAULT/PunchFling-Icon.png",      kind = "image", priority = 2 },
        { name = "TL Default TLMagnifier Icon", url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TLMagnifier-Tool-Icon.png", file = "assets/TL-DEFAULT/TLMagnifier-Tool-Icon.png", kind = "image", priority = 2 },
        { name = "TL Default TL-Icon",         url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TL-Icon.png",              file = "assets/TL-DEFAULT/TL-Icon.png",              kind = "image", priority = 2 },
        { name = "TL Default TLIcon",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TLIcon.png",               file = "assets/TL-DEFAULT/TLIcon.png",               kind = "image", priority = 2 },
        { name = "TL Default TL-ProfileIcon",  url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TL-ProfileIcon.png",       file = "assets/TL-DEFAULT/TL-ProfileIcon.png",       kind = "image", priority = 2 },
        { name = "TL Default TLOpenBars",      url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TLOpenBars-Button.png",     file = "assets/TL-DEFAULT/TLOpenBars-Button.png",    kind = "image", priority = 2 },
        { name = "TL Default TLOpenedBars",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/TLOpenedBars-Button.png",    file = "assets/TL-DEFAULT/TLOpenedBars-Button.png",  kind = "image", priority = 2 },
        { name = "TL Default QA Hug",          url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Hug-Icon.png",       file = "assets/TL-DEFAULT/QuickAction-Hug-Icon.png",       kind = "image", priority = 2 },
        { name = "TL Default QA Kiss",         url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Kiss-Icon.png",      file = "assets/TL-DEFAULT/QuickAction-Kiss-Icon.png",      kind = "image", priority = 2 },
        { name = "TL Default QA Slap",         url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Slap-Icon.png",      file = "assets/TL-DEFAULT/QuickAction-Slap-Icon.png",      kind = "image", priority = 2 },
        { name = "TL Default QA Headbutt",     url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Headbutt-Icon.png", file = "assets/TL-DEFAULT/QuickAction-Headbutt-Icon.png", kind = "image", priority = 2 },
        { name = "TL Default QA Backshots",    url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-DEFAULT/QuickAction%20Backshots-Icon.png", file = "assets/TL-DEFAULT/QuickAction-Backshots-Icon.png", kind = "image", priority = 2 },
        { name = "Admin Join Audio",           url = adminAudioUrl,                file = adminAudioFileName,                kind = "audio", priority = 1 },
        
        { name = "The Boys Scripts Icon",      url = theBoysScriptsIconUrl,        file = theBoysScriptsIconFileName,        kind = "image", priority = 2 },
        { name = "The Boys Settings Icon",     url = theBoysSettingsIconUrl,       file = theBoysSettingsIconFileName,       kind = "image", priority = 2 },
        { name = "The Boys Home Icon",         url = theBoysHomeIconUrl,           file = theBoysHomeIconFileName,           kind = "image", priority = 2 },
        { name = "The Boys Actions Icon",      url = theBoysActionsIconUrl,        file = theBoysActionsIconFileName,        kind = "image", priority = 2 },
        { name = "The Boys Theme Music",       url = theBoysMusicUrl,              file = theBoysMusicFileName,              kind = "audio", priority = 2 },
        { name = "The Boys Wallpaper",         url = theBoysBgUrl,                 file = theBoysBgFileName,                 kind = "image", priority = 2 },
        { name = "Dragonball Settings Icon",   url = dragonballSettingsIconUrl,    file = dragonballSettingsIconFileName,    kind = "image", priority = 2 },
        { name = "Dragonball Wallpaper",       url = dragonballBgUrl,              file = dragonballBgFileName,              kind = "image", priority = 2 },
        { name = "Dragonball Theme Music",     url = dragonballMusicUrl,           file = dragonballMusicFileName,           kind = "audio", priority = 2 },
        { name = "One Piece COM Background",   url = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/ONE%20PIECE/Theme-OnePiece-Com-Wallpaper.png", file = "assets/THEMES/ONEPIECE/OP-COM-BG.png", kind = "image", priority = 2 },
        { name = "One Piece Action Background", url = onePieceActionBgUrl, file = onePieceActionBgFileName, kind = "image", priority = 2 },
        { name = "Death Note Home Icon",       url = deathNoteHomeIconUrl,         file = deathNoteHomeIconFileName,         kind = "image", priority = 2 },
        { name = "Death Note Character Icon",  url = deathNoteCharIconUrl,         file = deathNoteCharIconFileName,         kind = "image", priority = 2 },
        { name = "Death Note Scripts Icon",    url = deathNoteScriptsIconUrl,      file = deathNoteScriptsIconFileName,      kind = "image", priority = 2 },
        { name = "Death Note Settings Icon",   url = deathNoteSettingsIconUrl,     file = deathNoteSettingsIconFileName,     kind = "image", priority = 2 },
        { name = "Death Note Com Icon",        url = deathNoteComIconUrl,          file = deathNoteComIconFileName,          kind = "image", priority = 2 },
        { name = "Death Note Char BG",         url = deathNoteCharBgUrl,           file = deathNoteCharBgFileName,           kind = "image", priority = 2 },
        { name = "Death Note Com BG",          url = deathNoteComBgUrl,            file = deathNoteComBgFileName,            kind = "image", priority = 2 },
        { name = "Death Note Scripts BG",      url = deathNoteScriptsBgUrl,        file = deathNoteScriptsBgFileName,        kind = "image", priority = 2 },
        { name = "Death Note ScriptsPanel BG", url = deathNoteScriptsPanelBgUrl,   file = deathNoteScriptsPanelBgFileName,   kind = "image", priority = 2 },
        { name = "Death Note Loading Screen",  url = deathNoteLoadingScreenUrl,    file = deathNoteLoadingScreenFileName,    kind = "image", priority = 2 },
        { name = "Death Note Home BG",         url = deathNoteHomeBgUrl,           file = deathNoteHomeBgFileName,           kind = "image", priority = 2 },
        { name = "Dexter Character Icon",      url = dexterCharIconUrl,             file = dexterCharIconFileName,             kind = "image", priority = 2 },
        { name = "Dexter Character BG",        url = dexterCharBgUrl,               file = dexterCharBgFileName,               kind = "image", priority = 2 },
        { name = "Dexter Settings Icon",       url = dexterSettingsIconUrl,         file = dexterSettingsIconFileName,         kind = "image", priority = 2 },
        { name = "Dexter Scripts Icon",        url = dexterScriptsIconUrl,          file = dexterScriptsIconFileName,          kind = "image", priority = 2 },
        { name = "Dexter Com Wallpaper",       url = dexterComBgUrl,                file = dexterComBgFileName,                kind = "image", priority = 2 },
        { name = "Dexter Loading Screen",      url = dexterLoadingScreenUrl,        file = dexterLoadingScreenFileName,        kind = "image", priority = 2 },
        { name = "Dexter Playerlist Icon",     url = dexterPlayerlistIconUrl,       file = dexterPlayerlistIconFileName,       kind = "image", priority = 2 },
    }

    
    local _opMusic = {
        { "Track 1",    "ONEPIECE-THEMEMUSIC-1%20(1).mp3",  "assets/TL-MP3-FILES/OP-M-00.mp3" },
        { "Track 2",    "ONEPIECE-THEMEMUSIC-1%20(2).mp3",  "assets/TL-MP3-FILES/OP-M-01.mp3" },
        { "Track 3",    "ONEPIECE-THEMEMUSIC-1%20(3).mp3",  "assets/TL-MP3-FILES/OP-M-02.mp3" },
        { "Track 4",    "ONEPIECE-THEMEMUSIC-1%20(4).mp3",  "assets/TL-MP3-FILES/OP-M-03.mp3" },
        { "Track 5",    "ONEPIECE-THEMEMUSIC-1%20(5).mp3",  "assets/TL-MP3-FILES/OP-M-04.mp3" },
        { "Track 6",    "ONEPIECE-THEMEMUSIC-1%20(6).mp3",  "assets/TL-MP3-FILES/OP-M-05.mp3" },
        { "Track 7",    "ONEPIECE-THEMEMUSIC-1%20(7).mp3",  "assets/TL-MP3-FILES/OP-M-06.mp3" },
        { "Track 8",    "ONEPIECE-THEMEMUSIC-1%20(8).mp3",  "assets/TL-MP3-FILES/OP-M-07.mp3" },
        { "Track 9",    "ONEPIECE-THEMEMUSIC-1%20(9).mp3",  "assets/TL-MP3-FILES/OP-M-08.mp3" },
        { "Track 10",   "ONEPIECE-THEMEMUSIC-1%20(10).mp3", "assets/TL-MP3-FILES/OP-M-09.mp3" },
    }
    local _OP_BASE = "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/THEME-MP3/THEME-MUSIC/ONEPIECE/"
    for _, v in ipairs(_opMusic) do
        assets[#assets + 1] = { name = "OP Music: " .. v[1], url = _OP_BASE .. v[2], file = v[3], kind = "audio", priority = 2 }
    end

    
    local _afkFiles = {
        { "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/THEME-MP3/DRAGONBALL-AFKSFX/DRAGONBALL-AFK-VOICELINE.mp3",  "assets/TL-MP3-FILES/DB-AFK-VL0.mp3" },
        { "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/THEME-MP3/DRAGONBALL-AFKSFX/DRAGONBALL-AFK-VOICELINE1.mp3", "assets/TL-MP3-FILES/DB-AFK-VL1.mp3" },
        { "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/THEME-MP3/ONEPIECE-AFKSFX/ONEPIECE-AFK-VOICELINE.mp3",      "assets/TL-MP3-FILES/OP-AFK-VL0.mp3" },
        { "https://raw.githubusercontent.com/TLMenu/TLASSETS/main/TL-MP3/THEME-MP3/ONEPIECE-AFKSFX/ONEPIECE-AFK-VOICELINE1.mp3",     "assets/TL-MP3-FILES/OP-AFK-VL1.mp3" },
    }
    for _, v in ipairs(_afkFiles) do
        assets[#assets + 1] = { name = "AFK VL: " .. v[2], url = v[1], file = v[2], kind = "audio", priority = 2 }
    end

    
    _TL_assetLoader.total = #assets

    for _, entry in ipairs(assets) do
        if not _TL_expectedAssetFiles[entry.file] then
            _TL_expectedAssetFiles[entry.file] = { url = entry.url, kind = entry.kind }
        end
    end

    
    
    
    local function downloadOne(entry)
        
        if _TL_safeIsFile(entry.file) then
            _TL_assetLoader.done  = _TL_assetLoader.done + 1
            _TL_assetLoader.current = entry.name .. " (cached)"
            return
        end
        local dir = entry.file:match("^(.+/)") or ""
        if dir ~= "" and not _TL_safeIsFolder(dir) then
            pcall(function() _TL_safeMakeFolder(dir) end)
        end
        _TL_assetLoader.current = "Downloading " .. entry.name
        local ok, bytes = pcall(function() return (game :: any):HttpGet(entry.url) end)
        if ok and type(bytes) == "string" and #bytes > 0 then
            local writeOk = _TL_safeWriteFile(entry.file, bytes)
            if not writeOk then
                _TL_assetLoader.failed = _TL_assetLoader.failed + 1
                warn("[TL] writefile failed: " .. entry.file)
            end
        else
            _TL_assetLoader.failed = _TL_assetLoader.failed + 1
            warn("[TL] Download failed: " .. entry.name)
        end
        
        _TL_assetLoader.done = _TL_assetLoader.done + 1
    end

    
    
    local function parallelBatch(entries, maxConcurrent)
        if #entries == 0 then return end
        local pending   = 0
        local nextIdx   = 1
        local allDone   = false

        local function launchNext()
            while pending < maxConcurrent and nextIdx <= #entries do
                local entry = entries[nextIdx]
                nextIdx  = nextIdx + 1
                pending  = pending + 1
                task.spawn(function()
                    pcall(downloadOne, entry)
                    pending  = pending - 1
                end)
            end
            if nextIdx > #entries and pending == 0 then
                allDone = true
            end
        end

        launchNext()
        
        while not allDone do
            task.wait(0.05)
            launchNext()
        end
    end

    
    local critical, heavy = {}, {}
    for _, e in ipairs(assets) do
        if e.priority == 1 then critical[#critical + 1] = e
        else                     heavy[#heavy + 1] = e end
    end

    
    parallelBatch(critical, 4)
    
    parallelBatch(heavy, 2)

    
    if _TL_assetLoader.done > _TL_assetLoader.total then
        _TL_assetLoader.done = _TL_assetLoader.total
    end

    
    
    
    local preloadObjs = {}
    for _, entry in ipairs(assets) do
        if entry.kind == "image" then
            local assetId = _TL_safeIsFile(entry.file) and _TL_safeGetCustomAsset(entry.file) or nil
            if assetId then
                local img = Instance.new("ImageLabel")
                img.Image = assetId
                preloadObjs[#preloadObjs + 1] = img
            end
        end
    end

    if #preloadObjs > 0 then
        _TL_assetLoader.current = "Preloading images (" .. #preloadObjs .. ")..."
        
        local preloadDone = false
        task.spawn(function()
            pcall(function() _SvcCP:PreloadAsync(preloadObjs) end)
            preloadDone = true
        end)
        local preloadStart = tick()
        while not preloadDone and (tick() - preloadStart) < 8 do
            task.wait(0.05)
        end
        if not preloadDone then
            warn("[TL] Image preload timeout — continuing")
        end
        for _, img in ipairs(preloadObjs) do
            pcall(function() img:Destroy() end)
        end
    end

    
    _TL_assetLoader.done    = _TL_assetLoader.total  
    _TL_assetLoader.ready   = true
    _TL_assetLoader.current = _TL_assetLoader.failed > 0
        and ("Assets ready (" .. tostring(_TL_assetLoader.failed) .. " warnings)")
        or  "Assets ready"

    end) 

    
    if not _TL_assetLoader.ready then
        _TL_assetLoader.failed  = (_TL_assetLoader.failed or 0) + 1
        _TL_assetLoader.total   = math.max(_TL_assetLoader.total or 1, 1)
        _TL_assetLoader.done    = _TL_assetLoader.total
        _TL_assetLoader.ready   = true
        _TL_assetLoader.current = "Asset loader recovered from error"
        warn("[TL] Asset loader encountered an unhandled error — marked ready anyway")
    end
end) 

task.spawn(function()
    while not _TL_assetLoader.ready do task.wait(0.1) end
    while not _TL_configReady do task.wait(0.1) end
    task.wait(1)
    pcall(function()
        if not _TL_safeIsFolder("assets") then return end
        local allFiles = _TL_recursiveListFiles("assets")
        local expected = {}
        for file, info in pairs(_TL_expectedAssetFiles) do
            expected[file] = info
        end
        if type(_genv._NT_getExpectedFiles) == "function" then
            local ntFiles = _genv._NT_getExpectedFiles()
            if type(ntFiles) == "table" then
                for file, info in pairs(ntFiles) do
                    if not expected[file] then
                        expected[file] = info
                    end
                end
            end
        end
        for _, filePath in ipairs(allFiles) do
            if filePath:find("^assets/Custom%-Music") or filePath:find("^assets/manifest%-cache%.json$") then
                continue
            end
            if not expected[filePath] then
                pcall(delfile, filePath)
            end
        end
        for filePath, info in pairs(expected) do
            if _TL_safeIsFolder(filePath) then continue end
            if not _TL_safeIsFile(filePath) then
                if info and info.url and info.url ~= "" then
                    local dir = filePath:match("^(.+/)") or ""
                    if dir ~= "" and not _TL_safeIsFolder(dir) then
                        pcall(function() _TL_safeMakeFolder(dir) end)
                    end
                    local ok, bytes = pcall(function() return (game :: any):HttpGet(info.url) end)
                    if ok and type(bytes) == "string" and #bytes > 0 then
                        _TL_safeWriteFile(filePath, bytes)
                    end
                end
            end
        end
        for filePath, info in pairs(expected) do
            if not _TL_safeIsFolder(filePath) and _TL_safeIsFile(filePath) then
                if type(readfile) == "function" then
                    local rOk, content = pcall(readfile, filePath)
                    if not rOk or type(content) ~= "string" or #content == 0 then
                        pcall(delfile, filePath)
                        if info and info.url and info.url ~= "" then
                            local dir = filePath:match("^(.+/)") or ""
                            if dir ~= "" and not _TL_safeIsFolder(dir) then
                                pcall(function() _TL_safeMakeFolder(dir) end)
                            end
                            local ok, bytes = pcall(function() return (game :: any):HttpGet(info.url) end)
                            if ok and type(bytes) == "string" and #bytes > 0 then
                                _TL_safeWriteFile(filePath, bytes)
                            end
                        end
                    end
                end
            end
        end
    end)
end)

local _afkSystem = {
    active        = false,
    lastInputTime = tick(),
    AFK_THRESHOLD = 120,
    currentSound  = nil,
    loopConn      = nil,
    inputConns    = {},
    themeId       = "white",
}
rawset(_genv, "_TL_afkSystem", _afkSystem)

task.spawn(function()
    while true do
        task.wait(300)
        pcall(LoadRolesFromGithub)
    end
end)

pcall(function()
    if _ADMIN_USERS[tostring(_LocalPlayer.Name)] == true or _ADMIN_USERS[tostring(_LocalPlayer.UserId)] == true or AdminNames[tostring(_LocalPlayer.Name)] == true or AdminNames[tostring(_LocalPlayer.UserId)] == true then
        _isAdminUser = true
    end
end)

if not getgenv then _genv.getgenv = function() return _G end end
if not _genv.getnamecallmethod then _genv.getnamecallmethod = function() return "" end end
if not _genv.setnamecallmethod then _genv.setnamecallmethod = function() end end

local function isMobile()
    local camera = workspace.CurrentCamera
    if not camera then return false end
    local viewport = camera.ViewportSize
    return viewport.X < 600 or viewport.Y < 800
end

local function getResponsiveScale()
    local camera = workspace.CurrentCamera
    if not camera then return 1 end
    local viewport = camera.ViewportSize
    local baseWidth = 1920
    return math.max(0.6, math.min(1, viewport.X / baseWidth))
end

if not _genv.Drawing then
    local DrawingStub = {}
    function DrawingStub.new(objType)
        local base = {
            Visible = false,
            Transparency = 1,
            Color = Color3.new(1, 1, 1),
            Thickness = 1,
            ZIndex = 1,
            Remove = function(self) self.Visible = false end,
            Destroy = function(self) self.Visible = false end
        }
        if objType == "Circle" then
            base.Radius = 10; base.Position = Vector2.new(0, 0); base.Filled = false; base.NumSides = 64
        elseif objType == "Line" then
            base.From = Vector2.new(0, 0); base.To = Vector2.new(0, 0)
        elseif objType == "Square" then
            base.Size = Vector2.new(0, 0); base.Position = Vector2.new(0, 0); base.Filled = false
        elseif objType == "Text" then
            base.Text = ""; base.Size = 12; base.Center = false; base.Outline = false; base.Position = Vector2.new(0, 0)
        end
        return base
    end

    _genv.Drawing = DrawingStub
end

local _TL_OBF_HDR = "--[TL-OBF]\n"
local function _TL_obf(d)
    if typeof(d) ~= "string" then return d end
    local r = {}
    for i = 1, #d do r[i] = string.char((d:byte(i) + 42) % 256) end
    return _TL_OBF_HDR .. table.concat(r):reverse()
end
local function _TL_deobf(d)
    if typeof(d) ~= "string" or d:sub(1, #_TL_OBF_HDR) ~= _TL_OBF_HDR then return d end
    local b = d:sub(#_TL_OBF_HDR + 1):reverse()
    local r = {}
    for i = 1, #b do r[i] = string.char((b:byte(i) - 42) % 256) end
    return table.concat(r)
end

local _rawW = (typeof(writefile) == "function") and writefile or function() end
local _rawR = (typeof(readfile) == "function") and readfile or function() return nil end

local function _tlWrite(path, content)
    local pL = path:lower()
    
    local target = pL:find("tlsteal")
    local final = target and _TL_obf(content) or content
    pcall(function() _rawW(path, final) end)
end
local function _tlRead(path)
    local ok, raw = pcall(function() return _rawR(path) end)
    if not ok or not raw then return nil end
    
    local pL = path:lower()
    if pL:find("tlsteal") then
        return _TL_deobf(raw)
    end
    return raw
end

local writefile  = _tlWrite
local readfile   = _tlRead
local isfolder   = (typeof(isfolder) == "function") and isfolder or function() return false end
local makefolder = (typeof(makefolder) == "function") and makefolder or function() end
local isfile     = (typeof(isfile) == "function") and isfile or function() return false end
local appendfile = (typeof(appendfile) == "function") and appendfile or function() end

if not _genv.sethiddenproperty then _genv.sethiddenproperty = function(o, p, v) pcall(function() o[p] = v end) end end
if not _genv.gethiddenproperty then _genv.gethiddenproperty = function(o, p)
        local s, r = pcall(function() return o[p] end)
        return s and r or nil
    end end
if not _genv.getidentity then _genv.getidentity = function() return 2 end end
if not _genv.setidentity then _genv.setidentity = function() end end
if not _genv.checkcaller then _genv.checkcaller = function() return false end end

if not _genv.getrawmetatable then _genv.getrawmetatable = function(o) return (debug :: any).getmetatable(o) end end
if not _genv.setreadonly then _genv.setreadonly = function() end end
if not _genv.make_writeable then _genv.make_writeable = function() end end

if not _genv.request then
    _genv.request = function(options)
        local success, result = pcall(function()
            return (game :: any):HttpGet(options.Url)
        end)
        return { Success = success, Body = result }
    end
end

local _SvcCG = nil
pcall(function() _SvcCG = game:GetService("CoreGui") end)
if not _SvcCG then
    pcall(function() _SvcCG = _LocalPlayer:WaitForChild("PlayerGui", 5) end)
end
if not _SvcCG then _SvcCG = game:GetService("StarterGui") end

local _SvcVIM = nil
pcall(function() _SvcVIM = game:GetService("VirtualInputManager") end)

local _mfloor, _mrandom, _mcos, _msin = math.floor, math.random, math.cos, math.sin
local _mmax, _mmin, _mpi = math.max, math.min, math.pi
local _V3new, _V3_ZERO, _CFlookAt = Vector3.new, Vector3.new(0, 0, 0), CFrame.lookAt

local TLCACHE_DIR = "TLCACHE"
local function _initCache()
    if isfolder and not isfolder(TLCACHE_DIR) then
        pcall(function() makefolder(TLCACHE_DIR) end)
    end
end
local function _saveCache(key, data)
    if not writefile then return end
    pcall(function()
_initCache()
        writefile(TLCACHE_DIR .. "/" .. key .. ".json", _SvcHttp:JSONEncode(data))
    end)
end
local function _loadCache(key)
    if not readfile then return nil end
    _initCache() 
    
    local fileExists = false
    pcall(function() fileExists = (type(isfile) == "function") and isfile(TLCACHE_DIR .. "/" .. key .. ".json") end)
    if not fileExists then return nil end
    local ok, data = pcall(function() return _SvcHttp:JSONDecode(readfile(TLCACHE_DIR .. "/" .. key .. ".json")) end)
    return ok and data or nil
end
_initCache()

local function _NT_hexToColor3(hex)
    if type(hex) ~= "string" or #hex < 7 then return Color3.new(1, 1, 1) end
    local ok, c = pcall(function()
        return Color3.fromHex(hex)
    end)
    return ok and c or Color3.new(1, 1, 1)
end

local function _makeRealStroke(parent, thickness, color, transparency)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Thickness = thickness or 1.2
    s.Color = color or Color3.new(1, 1, 1)
    s.Transparency = transparency or 0.65
    s.Parent = parent
    return s
end
local function _makeDummyStroke(p)
    return setmetatable({}, {
        __index = function() return function() end end,
        __newindex = function() end
    })
end

local function _handleError(err)
    local traceback = debug.traceback()
    local fullError = "╔══════════════════════════════════════════════╗\n" ..
                      "║  TLMENU CRITICAL ERROR DETECTED              ║\n" ..
                      "╟──────────────────────────────────────────────╢\n" ..
                      "║ Error: " .. tostring(err) .. "                 ╢\n" ..
                      "╟──────────────────────────────────────────────╢\n" ..
                      "║ Traceback:\n" .. traceback .. "                ╢\n" ..
                      "╚══════════════════════════════════════════════╝\n"
    warn(fullError)
    print(fullError) 
    pcall(function()
        _SvcSG:SetCore("SendNotification", {
            Title = "⚠️ TLMenu Crash",
            Text = "An error occurred. Check F9 console for details.",
            Duration = 15,
            Button1 = "OK"
        })
    end)
end

task.spawn(function()
    local success, result = xpcall(function()
        

        local _TL_refs: any = {}

        
        local _panelColorHooks: {(...any) -> ()} = {}
        local settingsState: {soundEnabled: boolean, TLColor: string, notifications: boolean, showHint: boolean, autoOpen: boolean, menuSounds: boolean, guiScale: number?, [string]: any}
        local _TL_VP: {guiScale: number?, short: number?, long: number?, [string]: any}
        local flyActive: boolean
        local twP: (...any) -> any
        local extractJsonSection: (json: string, section: string) -> string
        local clearESP: () -> ()
        local flyScreenGui: ScreenGui
        local _flyPanelSetFn: (...any) -> any
        local invisRenderConn: any
        local invisSteppedConn: any
        local MDARK: any
        local MHDR: any
        local MGLOW: any
        local getNearestPlayer: (range: number?) -> Player?
        local flingTogState: boolean
        local PANEL_H_WITH_CARDS: number
        local PANEL_H_BASE: number
        local getBall: (...any) -> any
        local setFreeze: (on: boolean) -> ()
        local setActionsToggle: (...any) -> any
        local sohStopAnim: (...any) -> any
        local _myC: any
        local _isMobile: () -> boolean
        local startPiggyback: (...any) -> any
        local startPiggyback2: (...any) -> any
        local startKiss: (...any) -> any
        local startBackpack: (...any) -> any
        local startOrbit: (...any) -> any
        local startLicking: (...any) -> any
        local startSucking: (...any) -> any
        local startSuckIt: (...any) -> any
        local startBackshots: (...any) -> any
        local startDoggy: (...any) -> any
        local startLayFuck: (...any) -> any
        local startPussySpread: (...any) -> any
        local startHug: (...any) -> any
        local startHug2: (...any) -> any
        local startFacefuck: (...any) -> any
        local startQA74: (...any) -> any
        local startGhost: (...any) -> any
        local startCarry: (...any) -> any
        local startShoulderSit: (...any) -> any
        local startStand: (...any) -> any
        local stopCurrentEmote: (...any) -> any
        local stopAnimEmotes: (...any) -> any
        local stopPiggyback: (...any) -> any
        local stopPiggyback2: (...any) -> any
        local stopKiss: (...any) -> any
        local stopBackpack: (...any) -> any
        local stopOrbit: (...any) -> any
        local stopLicking: (...any) -> any
        local stopSucking: (...any) -> any
        local stopSuckIt: (...any) -> any
        local stopBackshots: (...any) -> any
        local stopDoggy: (...any) -> any
        local stopLayFuck: (...any) -> any
        local stopPussySpread: (...any) -> any
        local stopHug: (...any) -> any
        local stopHug2: (...any) -> any
        local stopCarry: (...any) -> any
        local stopShoulderSit: (...any) -> any
        local stopQA74: (...any) -> any
        local stopGhost: (...any) -> any
        local stopBB: (...any) -> any

        task.spawn(function()
            local assets = {
                "rbxassetid://139800881181209", 
                "rbxassetid://77458828386203",  
                "rbxassetid://72579312094126",  
                "rbxassetid://86857269527024",
                "rbxassetid://139840976938907",
                "rbxassetid://113740413795794",
                "rbxassetid://89009236995193",
                "rbxassetid://77104113506431",
                "rbxassetid://119518980113353",
                "rbxassetid://135716031985311",
                "rbxassetid://79735988088948"
            }
            for _, id in ipairs(assets) do
                pcall(function()
                    local s = Instance.new("Sound")
                    s.SoundId = id
                    _SvcCP:PreloadAsync({ s })
                    s:Destroy()
                end)
                task.wait(0.05) 
            end
        end)
        local _TL_state    = {
            conns = {},
            ui = {},
            favs = {},
            data = {},
            fly = { active = false, speed = 16 },
            actions = {},
            visuals = { espColorIdx = 1 },
            movement = { tfActive = false, pfActive = false, antiRagdollEnabled = false, cfActive = false },
            interaction = { _ctActive = false }
        }
        local _sc: any      = {} 
        local _u           = {} 
        local _aim         = {} 
        _TL_refs._TL_state = _TL_state
        
        local _genv        = (getgenv and getgenv()) or _G
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

        local function _AF_loadAndPlayAnimation(humanoid, ANIMATION_ID)
            if not humanoid then return nil end
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if not animator then
                animator = Instance.new("Animator", humanoid)
            end
            local cleanId = tostring(ANIMATION_ID or ""):gsub("rbxassetid://", "")
            if cleanId == "" or cleanId == "0" then return nil end
            local resolvedId = "rbxassetid://" .. cleanId
            do
                local _objDone = false
                local _objResult = nil
                task.spawn(function()
                    pcall(function()
                        _objResult = game:GetObjects("rbxassetid://" .. cleanId)
                    end)
                    _objDone = true
                end)
                local _deadline = tick() + 3
                while not _objDone and tick() < _deadline do
                    task.wait(0.05)
                end
                if _objDone and _objResult and _objResult[1] then
                    pcall(function()
                        local obj = _objResult[1]
                        if obj:IsA("Animation") then
                            resolvedId = obj.AnimationId
                        else
                            local child = obj:FindFirstChildOfClass("Animation")
                            if child then resolvedId = child.AnimationId end
                        end
                        obj.Parent = workspace
                        task.delay(1, function() pcall(function() obj:Destroy() end) end)
                    end)
                elseif not _objDone then
                    warn("[TL] game:GetObjects timeout for animation " .. cleanId .. " — using fallback ID")
                end
            end
            local anim = Instance.new("Animation")
            anim.AnimationId = resolvedId
            local track = nil
            pcall(function()
                track = animator:LoadAnimation(anim)
            end)
            if not track then return nil end
            track.Priority = Enum.AnimationPriority.Action4
            track.Looped = true
            return track
        end

        local function _AF_prepareActionTrack(track)
            if not track or type(track) ~= "userdata" then return nil end
            pcall(function()
                track.Priority = Enum.AnimationPriority.Action4
                track.Looped = true
                track:AdjustSpeed(1)
                if not track.IsPlaying then
                    track:Play(0.05, 1, 1)
                end
            end)
            return track
        end

        local function _AF_getReliableActionTrack(humanoid, animationId, emoteName)
            if not humanoid then return nil end
            local rawId = tostring(animationId or "")
            if rawId == "" or rawId == "0" then return nil end
            local track = nil
            pcall(function()
                track = _AF_loadAndPlayAnimation(humanoid, rawId)
                if track then
                    track:Play(0.05, 1, 1)
                end
            end)
            track = _AF_prepareActionTrack(track)
            if not track then return nil end
            for _ = 1, 3 do
                local ok, isPlaying = pcall(function() return track.IsPlaying end)
                if ok and isPlaying then
                    return track
                end
                pcall(function() track:Play(0.05, 1, 1) end)
                task.wait()
            end
            return track
        end

        local FILE = "TLMenu.lua"
        if not _genv._TLScriptSource then
            pcall(function()
                if readfile and isfile and isfile(FILE) then
                    local s = readfile(FILE)
                    if s and #s > 500 then _genv._TLScriptSource = s end
                end
            end)
        end
        if not _genv._TLAutoReinject then
            _genv._TLAutoReinject = true
            task.spawn(function()
                local lastJob = tostring(game.JobId)
                while true do
                    task.wait(2.0)
                    local ok, newJob = pcall(function() return tostring(game.JobId) end)
                    if not ok then newJob = lastJob end
                    local changed = (newJob ~= lastJob) and (newJob ~= "") and (lastJob ~= "")
                    if changed then
                        lastJob = newJob
                        task.wait(3.5)
                        pcall(function()
                            if not game:IsLoaded() then game.Loaded:Wait() end
                        end)
                        task.wait(0.8)
                        local src
                        pcall(function()
                            if readfile and isfile and isfile(FILE) then
                                src = readfile(FILE)
                            end
                        end)
                        if not src or #(src or "") < 500 then
                            src = _genv._TLScriptSource
                        end
                        if src and #src > 500 then
                            local fn = loadstring(src)
                            if fn then task.spawn(fn) end
                        end
                        task.wait(5)
                    end
                end
            end)
        end
        if getgenv then
            _genv._TLSessionToken = (_genv._TLSessionToken or 0) + 1
        end
        if not getgenv and _G then
            _G._TLSessionToken = (_G._TLSessionToken or 0) + 1
        end
        local _tlEnv = (getgenv ~= nil and _genv) or _G or {}
        pcall(function()
            local env = _genv
            if env and type(env.TLMenuCleanup) == "function" then
                pcall(env.TLMenuCleanup)
            elseif env and type(env.TLUnload) == "function" then
                pcall(env.TLUnload)
            end
        end)
        if getgenv then
            _genv._TLAllConns = {}
            _genv._TLAllInsts = {}
        end

        
        
        
        
        local _TL_MODULES_BASE = "https://raw.githubusercontent.com/TLMenu/TLMenuParts/main/"
        local _TL_TAB_MODULES_BASE = "https://raw.githubusercontent.com/TLMenu/TLMenuParts/main/Tab-Moduls/"
        local _TL_MODULES = {}
        rawset(_genv, "_TL_MODULES", _TL_MODULES)

        local function _TL_loadModule(name)
            if _TL_MODULES[name] then return _TL_MODULES[name] end
            
            local cleanName = name:gsub("%.lua$", ""):gsub("^Tab%-Moduls/", "")
            local source = nil

            -- 1. Local Filesystem Checks
            local localPaths = {
                "Tab-Moduls/" .. cleanName .. ".lua",
                cleanName .. ".lua",
                name
            }
            for _, path in ipairs(localPaths) do
                if type(_TL_safeIsFile) == "function" and _TL_safeIsFile(path) then
                    local ok, localSrc = pcall(readfile, path)
                    if ok and localSrc and #localSrc > 20 then
                        source = localSrc
                        break
                    end
                end
            end

            -- 2. Remote GitHub HttpGet Checks (Primary: Tab-Moduls/, Secondary: Root)
            if not source then
                local remoteUrls = {
                    _TL_TAB_MODULES_BASE .. cleanName .. ".lua",
                    _TL_MODULES_BASE .. cleanName .. ".lua",
                    _TL_MODULES_BASE .. name .. ".lua"
                }
                for _, url in ipairs(remoteUrls) do
                    local ok, httpSrc = pcall(function() return (game :: any):HttpGet(url) end)
                    if ok and httpSrc and #httpSrc >= 50 and not httpSrc:find("404: Not Found") then
                        source = httpSrc
                        break
                    end
                end
            end

            if not source then
                warn("[TL] Module load failed: " .. name)
                return nil
            end

            local fn, loadErr = loadstring(source)
            if not fn then
                warn("[TL] Module compile error: " .. name .. " — " .. tostring(loadErr))
                return nil
            end
            local modOk, mod = pcall(fn)
            if not modOk then
                warn("[TL] Module exec error: " .. name .. " — " .. tostring(mod))
                return nil
            end

            _TL_MODULES[name] = mod
            _TL_MODULES[cleanName] = mod
            return mod
        end
        rawset(_genv, "_TL_loadModule", _TL_loadModule)

        local env = _genv
        env._panelColorHooks = {}

        local _MY_TOKEN = _genv._TLSessionToken or 1
        getfenv()._TL_SCRIPT_ENV_TOKEN = _MY_TOKEN

        local hookfunction = hookfunction or (replaceclosure) or (detourfunction)
        if hookfunction and getgenv and not _genv._TL_HookedConnect then
            local oldConnect
            local success
            success, oldConnect = pcall(function()
                local signal = game.Loaded
                return hookfunction(signal.Connect, function(self, ...)
                    local conn = oldConnect(self, ...)
                    if conn and typeof(conn) == "RBXScriptConnection" then
                        local okCall, callerEnv = pcall(getfenv, 2)
                        if okCall and callerEnv and callerEnv._TL_SCRIPT_ENV_TOKEN then
                            local allConns = _genv._TLAllConns
                            if allConns then
                                table.insert(allConns, conn)
                            end
                        end
                    end
                    return conn
                end)
            end)
            if success then
                _genv._TL_HookedConnect = true
            end
        end
        local function _tlTrackConn(c)
            pcall(function()
                local env = _genv
                if env and env._TLAllConns then
                    env._TLAllConns[#env._TLAllConns + 1] = c
                end
            end)
            return c
        end
        local function _tlTrackInst(obj)
            pcall(function()
                local env = _genv
                if env and env._TLAllInsts then
                    env._TLAllInsts[#env._TLAllInsts + 1] = obj
                end
            end)
            return obj
        end
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
        pcall(function()
            if getgenv then _genv.SmartBarLoaded = true end
        end)
        local _workspace = workspace or game:GetService("Workspace")

        pcall(function()
            if type(makefolder) == "function" and type(isfolder) == "function" then
                if not isfolder("Custom-Music") then
                    makefolder("Custom-Music")
                end
            end
        end)

        
        pcall(function()
            local vipArea = _workspace:FindFirstChild("VipAreaField")
            if vipArea then
                vipArea:Destroy()
            end
        end)

        
        pcall(function()
            local skyParts = _workspace:FindFirstChild("SkyParts")
            if skyParts then
                skyParts:Destroy()
            end
        end)

        local PIGGYBACK_ANIM_ID, PIGGYBACK2_ANIM_ID = "108744973494490", "112201741232797"
        local tlArrowBig, tlArrow                   = nil, nil
        
        local _CF_ROT180Y                           = CFrame.Angles(0, math.rad(180), 0)
        local function _tlAlive()
            if getgenv ~= nil then return _genv._TLSessionToken == _MY_TOKEN end
            return true
        end
        task.spawn(function()
            Players = nil; pcall(function() Players = _SvcPlr end)
            if not Players then Players = _SvcPlr end
            UserInputService = nil; pcall(function() UserInputService = _SvcUIS end)
            if not UserInputService then
                UserInputService = {
                    InputBegan = { Connect = function(_, fn) return { Disconnect = function() end } end },
                    InputChanged = { Connect = function(_, fn) return { Disconnect = function() end } end },
                    IsKeyDown = function() return false end,
                    IsMouseButtonPressed = function() return false end,
                    GetMouseLocation = function() return Vector2.new(0, 0) end,
                    KeyboardEnabled = false,
                }
            end
            UIS              = UserInputService
            local sendNotif  
            local _C3_WHITE  = Color3.fromRGB(255, 255, 255)
            local _C3_BG3    = Color3.fromRGB(26, 26, 28) 
            local _C3_BG2    = Color3.fromRGB(18, 18, 20)
            local _C3_SUB2   = Color3.fromRGB(85, 88, 95) 
            local _C3_SUB    = Color3.fromRGB(130, 135, 145)
            local _C3_BG4    = Color3.fromRGB(22, 22, 24)
            local _C3_BLACK  = Color3.fromRGB(0, 0, 0)
            local _C3_TEXT3  = Color3.fromRGB(210, 212, 218)
            local _C3_DRED   = Color3.fromRGB(255, 60, 60) 
            local _C3_RED    = Color3.fromRGB(255, 80, 80)

            
            
            
            local _TL_IMG_THEMES = { theboys=true, onepiece=true, dragonball=true, deathnote=true, dexter=true }
            local function _TL_isImgTheme(tid) return _TL_IMG_THEMES[tid] or false end
            
            local _TL_ANIME_THEMES = { theboys=true, onepiece=true, dragonball=true, deathnote=true, dexter=true }
            local function _TL_isAnimeTheme(tid) return _TL_ANIME_THEMES[tid] or false end
            
            TweenService     = nil; pcall(function() TweenService = _tsProxy end)
            RunService = nil; pcall(function() RunService = _SvcRS end)
            if not TweenService then
                TweenService = {
                    Create = function(obj, info, props)
                        return {
                            Play = function()
                                pcall(function()
                                    for k, v in pairs(props) do pcall(function() obj[k] = v end) end
                                end)
                            end,
                            Cancel = function() end,
                            Completed = { Connect = function(_, fn) return { Disconnect = function() end } end },
                        }
                    end
                }
            end
            if not RunService then
                RunService = {
                    Heartbeat     = { Connect = function(_, fn) return { Disconnect = function() end } end },
                    Stepped       = { Connect = function(_, fn) return { Disconnect = function() end } end },
                    RenderStepped = { Connect = function(_, fn) return { Disconnect = function() end } end },
                    PreSimulation = { Connect = function(_, fn) return { Disconnect = function() end } end },
                    PreRender     = { Connect = function(_, fn) return { Disconnect = function() end } end },
                }
            end
            
            local _ENUM_SORT_ORDER_LAYOUT
            pcall(function() _ENUM_SORT_ORDER_LAYOUT = Enum.SortOrder.LayoutOrder end)
            if _ENUM_SORT_ORDER_LAYOUT == nil then _ENUM_SORT_ORDER_LAYOUT = 2 end
            Stats = nil; pcall(function() Stats = game:GetService("Stats") end)
            CoreGui = nil; pcall(function() CoreGui = game:GetService("CoreGui") end)
            GroupService = nil; pcall(function() GroupService = game:GetService("GroupService") end)
            local LocalPlayer, PlayerGui = Players.LocalPlayer, nil
            pcall(function() PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10) end)
            if not PlayerGui then PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") end
            local Character = LocalPlayer.Character
            if not Character then
                local charConn, charDone
                charConn = LocalPlayer.CharacterAdded:Connect(function(c)
                    Character = c
                    charDone = true
                    if charConn then pcall(function() charConn:Disconnect() end) end
                end)
                local t = 0
                while not charDone and t < 8 do
                    task.wait(0.1); t = t + 0.1
                end
                if charConn then pcall(function() charConn:Disconnect() end) end
                if not Character then Character = LocalPlayer.Character end
            end
            local noclipConn, noclipCachedParts, noclipOrigCollide = nil, {}, {}
            local function noclipRebuildCache(ch)
                noclipCachedParts = {}
                if not ch then return end
                for _, part in ipairs(ch:GetDescendants()) do
                    if part:IsA("BasePart") then
                        table.insert(noclipCachedParts, part)
                    end
                end
            end

            LocalPlayer.CharacterAdded:Connect(function(c)
                Character = c
                if noclipConn then noclipRebuildCache(c) end
            end)
            local function getHumanoid()
                local c = Character
                return c and c:FindFirstChildOfClass("Humanoid")
            end
            local function getRootPart()
                local c = Character
                return c and c:FindFirstChild("HumanoidRootPart")
            end
            
            function safeStand()
                if flyActive then return end
                local myChar = LocalPlayer.Character
                if not myChar then return end
                local hrp = myChar:FindFirstChild("HumanoidRootPart")
                local hum = myChar:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum then return end
                hrp.AssemblyLinearVelocity = Vector3.zero
                pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
                hum.PlatformStand = false
                pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end)
                hum.WalkSpeed = 16
            end

            local C = {

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
                
                bg        = Color3.fromRGB(10, 10, 10),
                bg2       = Color3.fromRGB(20, 20, 20),
                bg3       = Color3.fromRGB(28, 28, 28),
                bghov     = Color3.fromRGB(18, 20, 26),
                border    = Color3.fromRGB(0, 200, 255),
                borderdim = Color3.fromRGB(0, 40, 85),
                accent    = Color3.fromRGB(0, 200, 255),
                accent2   = Color3.fromRGB(0, 160, 220),
                accent3   = Color3.fromRGB(0, 120, 180),
                green     = Color3.fromRGB(0, 200, 255),
                red       = Color3.fromRGB(255, 60, 90),
                orange    = Color3.fromRGB(255, 155, 45),
                text      = Color3.fromRGB(210, 235, 255),
                sub       = Color3.fromRGB(0, 135, 195),
                gradL     = Color3.fromRGB(0, 200, 255),
                gradR     = Color3.fromRGB(0, 160, 220),
                panelBg   = Color3.fromRGB(10, 10, 10),
                panelHdr  = Color3.fromRGB(20, 20, 20),
            }
            if _genv then _genv.C = C end
            _G.C = C

            
            
            
            local function corner(parent, radius)
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(0, radius or 8)
                c.Parent = parent
                return c
            end

            local function stroke(parent, a, b, c)
                return _makeDummyStroke(parent)
            end

            local function gradient(parent, rotation, c1, c2)
                local g = Instance.new("UIGradient")
                g.Rotation = rotation or 0
                g.Color = ColorSequence.new(c1 or Color3.new(1, 1, 1), c2 or c1 or Color3.new(1, 1, 1))
                g.Parent = parent
                return g
            end

            local function applyTextStyle(obj, minSize)
                if not obj then return end
                obj.Font = Enum.Font.GothamBold
                if minSize then obj.TextSize = math.max(obj.TextSize, minSize) end
                obj.TextColor3 = C.text or Color3.new(1, 1, 1)
                obj.TextTransparency = 0
                obj.TextStrokeTransparency = 1
            end

            local function stylePanelSurface(frame, r, trans)
                frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                frame.BackgroundTransparency = trans or 0.25
                frame.BorderSizePixel = 0
                corner(frame, r or 10)
                stroke(frame, 1.2, C.bg3 or Color3.fromRGB(45, 45, 45), 0.2)
            end

            local function styleThumbSurface(frame, radius)
                frame.BorderSizePixel  = 0
                frame.ClipsDescendants = true
                frame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
                corner(frame, radius or 8)
                return stroke(frame, 1, C.bg3 or Color3.fromRGB(45, 45, 45), 0.28)
            end

            
            
            
                        
            
            
local _TL_THEMES = {
                { id = "matrix",   name = "Matrix",   accent = Color3.fromRGB(30, 255, 90), accent2 = Color3.fromRGB(0, 200, 55), sub = Color3.fromRGB(0, 140, 35), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(210, 255, 220), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "blue",     name = "Cyber",    accent = Color3.fromRGB(0, 200, 255), accent2 = Color3.fromRGB(0, 160, 220), sub = Color3.fromRGB(0, 135, 195), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(210, 235, 255), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "purple",   name = "Neon",     accent = Color3.fromRGB(190, 80, 255), accent2 = Color3.fromRGB(160, 55, 220), sub = Color3.fromRGB(140, 45, 195), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(240, 220, 255), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "red",      name = "Crimson",  accent = Color3.fromRGB(255, 55, 80), accent2 = Color3.fromRGB(220, 40, 60), sub = Color3.fromRGB(195, 30, 50), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(255, 220, 225), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "gold",     name = "Gold",     accent = Color3.fromRGB(255, 200, 0), accent2 = Color3.fromRGB(220, 168, 0), sub = Color3.fromRGB(195, 148, 0), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(255, 245, 210), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "cyan",     name = "Ice",      accent = Color3.fromRGB(0, 255, 200), accent2 = Color3.fromRGB(0, 218, 168), sub = Color3.fromRGB(0, 188, 148), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(210, 255, 248), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "rose",     name = "Rose",     accent = Color3.fromRGB(255, 100, 160), accent2 = Color3.fromRGB(220, 75, 130), sub = Color3.fromRGB(195, 55, 110), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(255, 225, 235), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "orange",   name = "Blaze",    accent = Color3.fromRGB(255, 130, 0), accent2 = Color3.fromRGB(220, 105, 0), sub = Color3.fromRGB(195, 88, 0), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(255, 238, 215), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "lime",     name = "Toxic",    accent = Color3.fromRGB(150, 255, 0), accent2 = Color3.fromRGB(118, 215, 0), sub = Color3.fromRGB(100, 185, 0), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(230, 255, 205), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "white",    name = "Ghost",    accent = Color3.fromRGB(220, 225, 235), accent2 = Color3.fromRGB(185, 190, 200), sub = Color3.fromRGB(160, 165, 175), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(240, 242, 248), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "teal",     name = "Teal",     accent = Color3.fromRGB(0, 210, 185), accent2 = Color3.fromRGB(0, 175, 155), sub = Color3.fromRGB(0, 150, 135), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(210, 252, 248), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "indigo",   name = "Void",     accent = Color3.fromRGB(100, 120, 255), accent2 = Color3.fromRGB(75, 95, 220), sub = Color3.fromRGB(58, 75, 195), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(225, 228, 255), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "peach",    name = "Peach",    accent = Color3.fromRGB(255, 175, 100), accent2 = Color3.fromRGB(220, 145, 75), sub = Color3.fromRGB(195, 122, 58), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(255, 242, 228), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "mint",     name = "Mint",     accent = Color3.fromRGB(80, 255, 185), accent2 = Color3.fromRGB(58, 215, 152), sub = Color3.fromRGB(42, 185, 130), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(215, 255, 242), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "onepiece", name = "One Piece", accent = Color3.fromRGB(255, 195, 0), accent2 = Color3.fromRGB(230, 40, 40), sub = Color3.fromRGB(0, 135, 220), borderdim = Color3.fromRGB(30, 30, 30), text = Color3.fromRGB(255, 230, 180), panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                { id = "dragonball", name = "Dragonball", accent = Color3.fromRGB(255, 190, 0), accent2 = Color3.fromRGB(255, 55, 15), sub = Color3.fromRGB(45, 130, 255), borderdim = Color3.fromRGB(40, 22, 5), text = Color3.fromRGB(255, 242, 205), panelBg = Color3.fromRGB(8, 7, 5), panelHdr = Color3.fromRGB(20, 13, 4) },
                { id = "theboys",  name = "The Boys", accent = Color3.fromRGB(220, 30, 30), accent2 = Color3.fromRGB(180, 20, 20), sub = Color3.fromRGB(255, 200, 0), borderdim = Color3.fromRGB(30, 10, 10), text = Color3.fromRGB(255, 220, 220), panelBg = Color3.fromRGB(10, 5, 5), panelHdr = Color3.fromRGB(20, 8, 8) },
                { id = "deathnote", name = "Death Note", accent = Color3.fromRGB(200, 20, 20), accent2 = Color3.fromRGB(140, 10, 10), sub = Color3.fromRGB(180, 180, 180), borderdim = Color3.fromRGB(25, 5, 5), text = Color3.fromRGB(240, 230, 230), panelBg = Color3.fromRGB(6, 4, 4), panelHdr = Color3.fromRGB(14, 8, 8) },
                { id = "dexter",    name = "Dexter",    accent = Color3.fromRGB(0, 100, 180), accent2 = Color3.fromRGB(0, 65, 120), sub = Color3.fromRGB(180, 180, 180), borderdim = Color3.fromRGB(5, 10, 20), text = Color3.fromRGB(200, 230, 255), panelBg = Color3.fromRGB(4, 6, 10), panelHdr = Color3.fromRGB(8, 14, 22) },
            }
            local _TL_activeThemeId = "white"
            local _TL_lastRenderedThemeId = _TL_activeThemeId
            local _TL_lastColor = "white"
            local function _TL_applyTheme(themeId, paletteOnly)
                
                local newT = nil
                for _, t in ipairs(_TL_THEMES) do if t.id == themeId then
                        newT = t; break
                    end end
                if not newT then return end
                local oldT = nil
                for _, t in ipairs(_TL_THEMES) do if t.id == _TL_lastRenderedThemeId then
                        oldT = t; break
                    end end
                if not oldT then oldT = _TL_THEMES[1] end

                
                
                if not _G._TL_origColorProps then _G._TL_origColorProps = {} end
                local _origColorProps = _G._TL_origColorProps

                
                local function close(a, b, tol) 
                    return math.abs(a.R - b.R) < tol and math.abs(a.G - b.G) < tol and math.abs(a.B - b.B) < tol
                end
                
                
                
                
                
                
                
                local anchors   = {
                    { oldT.accent,    newT.accent },
                    { oldT.accent2,   newT.accent2 },
                    { oldT.sub,       newT.sub },
                    { oldT.borderdim, newT.borderdim },
                    { oldT.text,      newT.text },
                    
                    
                    { C.accent,       newT.accent },
                    { C.accent2,      newT.accent2 },
                    { C.sub,          newT.sub },
                    { C.borderdim,    newT.borderdim },
                    { C.text,         newT.text },
                    { C.green,        newT.accent },
                    { C.gradL,        newT.accent },
                    { C.gradR,        newT.accent2 },
                    { C.border,       newT.accent },
                    
                    
                    
                    
                    
                    
                }
                local function remapColor(col)
                    
                    for _, a in ipairs(anchors) do
                        if close(col, a[1], 0.015) then return a[2] end
                    end
                    return nil
                end

                
                C.accent          = newT.accent
                C.accent2         = newT.accent2
                C.sub             = newT.sub
                C.borderdim       = newT.borderdim
                C.text            = newT.text
                C.green           = newT.accent
                C.gradL           = newT.accent
                C.gradR           = newT.accent2
                C.border          = newT.accent
                
                
                
                local themeFallbacks = {
                    matrix     = { panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                    blue       = { panelBg = Color3.fromRGB(10, 15, 25), panelHdr = Color3.fromRGB(15, 22, 35) },
                    purple     = { panelBg = Color3.fromRGB(20, 10, 25), panelHdr = Color3.fromRGB(28, 15, 35) },
                    red        = { panelBg = Color3.fromRGB(25, 10, 12), panelHdr = Color3.fromRGB(35, 15, 18) },
                    gold       = { panelBg = Color3.fromRGB(25, 20, 8),  panelHdr = Color3.fromRGB(35, 28, 12) },
                    cyan       = { panelBg = Color3.fromRGB(15, 15, 20), panelHdr = Color3.fromRGB(20, 20, 22) },
                    rose       = { panelBg = Color3.fromRGB(25, 12, 18), panelHdr = Color3.fromRGB(35, 18, 25) },
                    orange     = { panelBg = Color3.fromRGB(25, 15, 8),  panelHdr = Color3.fromRGB(35, 22, 12) },
                    lime       = { panelBg = Color3.fromRGB(12, 22, 8),  panelHdr = Color3.fromRGB(18, 32, 12) },
                    white      = { panelBg = Color3.fromRGB(15, 15, 18), panelHdr = Color3.fromRGB(20, 20, 22) },
                    teal       = { panelBg = Color3.fromRGB(10, 18, 16), panelHdr = Color3.fromRGB(15, 25, 22) },
                    indigo     = { panelBg = Color3.fromRGB(12, 12, 28), panelHdr = Color3.fromRGB(18, 18, 38) },
                    peach      = { panelBg = Color3.fromRGB(25, 18, 12), panelHdr = Color3.fromRGB(35, 25, 18) },
                    mint       = { panelBg = Color3.fromRGB(10, 22, 16), panelHdr = Color3.fromRGB(15, 32, 22) },
                    onepiece   = { panelBg = Color3.fromRGB(10, 10, 10), panelHdr = Color3.fromRGB(20, 20, 20) },
                    dragonball = { panelBg = Color3.fromRGB(8, 7, 5),    panelHdr = Color3.fromRGB(20, 13, 4)  },
                    theboys    = { panelBg = Color3.fromRGB(10, 5, 5),   panelHdr = Color3.fromRGB(20, 8, 8)   },
                    deathnote  = { panelBg = Color3.fromRGB(6, 4, 4),    panelHdr = Color3.fromRGB(14, 8, 8)   },
                    dexter     = { panelBg = Color3.fromRGB(4, 6, 10),   panelHdr = Color3.fromRGB(8, 14, 22)  },
                }
                local _thFallback = themeFallbacks[themeId] or themeFallbacks.matrix
                C.panelBg  = _thFallback.panelBg or Color3.fromRGB(0, 0, 0)
                C.panelHdr = _thFallback.panelHdr or Color3.fromRGB(0, 0, 0)
                _TL_activeThemeId = themeId
                
                pcall(function()
                    local _afkSetFn = _genv._TL_afkSetTheme
                    if _afkSetFn then _afkSetFn(themeId) end
                end)
                
                pcall(function()
                    local opBg = _TL_refs and _TL_refs._OP_PanelBgImg
                    if opBg and opBg.Parent then
                        opBg.Visible = (themeId == "onepiece")
                    end
                end)
                pcall(function()
                    local opPlBg = _TL_refs and _TL_refs._OP_PlBgImg
                    if opPlBg and opPlBg.Parent then
                        opPlBg.Visible = (themeId == "onepiece")
                    end
                end)
                pcall(function()
                    local opComBg = _TL_refs and _TL_refs._OP_ComPanelBgImg
                    if opComBg and opComBg.Parent then
                        opComBg.Visible = (themeId == "onepiece")
                    end
                end)
                
                pcall(function()
                    if _panelColorHooks then
                        for _, fn in ipairs(_panelColorHooks) do pcall(fn, newT) end
                    end
                end)
                if paletteOnly then
                    
                    
                    
                    _TL_lastRenderedThemeId = themeId
                    pcall(function()
                    if getgenv and not _isSpecialTheme then _genv._TL_savedTheme = themeId end
                    end)
                    return
                end
                

                
                local sg = nil
                pcall(function() sg = _TL_refs and _TL_refs._TL_ScreenGui end)
                if not sg then pcall(function() sg = ScreenGui end) end
                if not sg or not sg.Parent then return end

                
                local function cancelBgTweens(obj)
                    pcall(function()
                        if obj and obj.Parent then
                            
                            local current = obj.BackgroundColor3
                            obj.BackgroundColor3 = current
                        end
                    end)
                end

                local function _isInsideNametag(el)
                    local cur = el
                    while cur and cur.Parent do
                        if cur:IsA("BillboardGui") and cur.Name:sub(1, 14) == "CovertPeerTag_" then
                            return true
                        end
                        cur = cur.Parent
                    end
                    return false
                end

                for _, d in ipairs(sg:GetDescendants()) do
                    pcall(function()
                        if _isInsideNametag(d) then return end
                        local cn = d.ClassName
                        if cn == "UIStroke" then
                            local n = remapColor(d.Color); if n then d.Color = n end
                        elseif cn == "Frame" or cn == "ScrollingFrame" then
                            if cn == "ScrollingFrame" then
                                pcall(function()
                                    local currentSBC = d.ScrollBarImageColor3
                                    local n = remapColor(currentSBC)
                                    if n then
                                        d.ScrollBarImageColor3 = n
                                    elseif close(currentSBC, Color3.fromRGB(104, 104, 112), 0.05) then
                                        d.ScrollBarImageColor3 = newT.accent
                                    end
                                end)
                            end
                            if d.BackgroundTransparency < 0.99 then
                                
                                cancelBgTweens(d)
                                local currentCol = d.BackgroundColor3
                                if not _origColorProps[d] then _origColorProps[d] = currentCol end
                                local n = remapColor(currentCol)
                                
                                if n then
                                    local isAcc = close(n, newT.accent, 0.01) or close(n, newT.accent2, 0.01)
                                    
                                    local wasBg = close(_origColorProps[d], oldT.panelBg or Color3.new(), 0.06)
                                        or close(_origColorProps[d], oldT.panelHdr or Color3.new(), 0.06)
                                    
                                    
                                    local looksLikeBg = close(currentCol, Color3.fromRGB(10, 10, 10), 0.08)
                                        or close(currentCol, Color3.fromRGB(15, 15, 15), 0.08)
                                        or close(currentCol, Color3.fromRGB(20, 20, 20), 0.08)
                                        or close(currentCol, Color3.fromRGB(28, 28, 28), 0.08)
                                        or close(currentCol, Color3.fromRGB(30, 30, 30), 0.08)
                                        
                                        or close(currentCol, Color3.fromRGB(20, 13,  4), 0.04)
                                        or close(currentCol, Color3.fromRGB(20,  8,  8), 0.04)
                                        or close(currentCol, Color3.fromRGB(10,  5,  5), 0.04)
                                        or close(currentCol, Color3.fromRGB( 8,  7,  5), 0.04)
                                        
                                        or close(currentCol, Color3.fromRGB( 4,  6, 10), 0.04)
                                        or close(currentCol, Color3.fromRGB( 8, 14, 22), 0.04)
                                        
                                        or close(currentCol, Color3.fromRGB( 6,  4,  4), 0.04)
                                        or close(currentCol, Color3.fromRGB(14,  8,  8), 0.04)
                                    if (wasBg or looksLikeBg) and isAcc and not close(newT.accent, newT.panelBg or Color3.new(), 0.1) then
                                        d.BackgroundColor3 = newT.panelBg or Color3.fromRGB(10, 10, 10)
                                    else
                                        d.BackgroundColor3 = n
                                    end
                                end
                            end
                        elseif cn == "TextLabel" or cn == "TextButton" or cn == "TextBox" then
                            local nt = remapColor(d.TextColor3); if nt then d.TextColor3 = nt end
                            if d.BackgroundTransparency < 0.99 then
                                cancelBgTweens(d)
                                local nb = remapColor(d.BackgroundColor3); if nb then d.BackgroundColor3 = nb end
                            end
                            
                        elseif cn == "ImageLabel" or cn == "ImageButton" then
                            local ni = remapColor(d.ImageColor3); if ni then d.ImageColor3 = ni end
                            
                        elseif cn == "UIGradient" then
                            local kps = d.Color.Keypoints
                            local changed, newKps = false, {}
                            for _, kp in ipairs(kps) do
                                local n = remapColor(kp.Value)
                                if n then
                                    newKps[#newKps + 1] = ColorSequenceKeypoint.new(kp.Time, n); changed = true
                                else
                                    newKps[#newKps + 1] = kp
                                end
                            end
                            if changed then d.Color = ColorSequence.new(newKps) end
                        end
                    end)
                end

                
                
                
                
                C.panelBg  = _thFallback.panelBg or Color3.fromRGB(0, 0, 0)
                C.panelHdr = _thFallback.panelHdr or Color3.fromRGB(0, 0, 0)

                
                
                pcall(function()
                    if _panelAccentObjs then
                        for _, r in ipairs(_panelAccentObjs) do
                            pcall(function()
                                if r.pf and r.pf.Parent then r.pf.BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) end
                                if r.hdrf and r.hdrf.Parent then r.hdrf.BackgroundColor3 = C.panelHdr or Color3.fromRGB(26, 26, 28) end
                                if r.hdrCut and r.hdrCut.Parent then r.hdrCut.BackgroundColor3 = C.panelHdr or Color3.fromRGB(26, 26, 28) end
                            end)
                        end
                    end
                end)

                if not _TL_isAnimeTheme(themeId) then
                    _TL_lastColor = themeId
                end

                
                
                
                local _isSpecialTheme = _TL_isImgTheme(themeId)
                pcall(function()
                    if settingsState then
                        settingsState.TLColor = themeId
                    end
                    if writefile and not _isSpecialTheme then
                        
                        _saveCache("color", { id = themeId })
                        
                        local ok, cur = pcall(readfile, "SmartBar_Save.json")
                        if not ok or not cur or cur == "" then
                            cur = '{\n  "settings": {\n    "TL-Color": "' .. themeId .. '"\n  },\n  "keybinds": {}\n}'
                            pcall(writefile, "SmartBar_Save.json", cur)
                        else
                            
                            cur = cur:gsub('"themeColor"%s*:%s*"[^"]*"', '"TL-Color": "' .. themeId .. '"')
                            cur = cur:gsub(',?%s*"lastColorTheme"%s*:%s*"[^"]*"', "")
                            cur = cur:gsub(',?%s*"TL-LastColor"%s*:%s*"[^"]*"', "")
                            if not cur:find('"TL-Color"') then
                                cur = cur:gsub('("settings"%s*:%s*{)', '%1\n    "TL-Color": "' .. themeId .. '",')
                            end
                            pcall(writefile, "SmartBar_Save.json", cur)
                        end
                    end
                    
                    if getgenv then _genv._TL_savedTheme = themeId end
                end)

                
                pcall(function()
                    if _tlEnv._TL_FixThemeChips then
                        _tlEnv._TL_FixThemeChips(themeId)
                    end
                end)
                _TL_lastRenderedThemeId = themeId
            end

            ScreenGui                = _tlTrackInst(Instance.new("ScreenGui"))
            ScreenGui.Name           = "SmartBarGui"
            ScreenGui.ResetOnSpawn   = false
            ScreenGui.IgnoreGuiInset = true
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ScreenGui.DisplayOrder   = 999

            
            do
                local _gs = Instance.new("UIScale", ScreenGui)
                _gs.Name  = "TL_GlobalScale"

                
                local ok, vp = pcall(function() return workspace.CurrentCamera.ViewportSize end)
                vp = ok and vp or Vector2.new(1920, 1080)
                _gs.Scale = math.clamp(math.min(vp.X / 1920, vp.Y / 1080), 0.55, 1.15)
                _TL_refs._TL_guiScaleInst = _gs
                _TL_GUIScale = _gs

                
                pcall(function()
                    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                        local ok2, vp2 = pcall(function() return workspace.CurrentCamera.ViewportSize end)
                        if ok2 and vp2 and _gs and _gs.Parent then
                            local newScale = math.clamp(math.min(vp2.X / 1920, vp2.Y / 1080), 0.55, 1.15)
                            if settingsState and settingsState.guiScale and settingsState.guiScale > 0 then
                                newScale = settingsState.guiScale
                            end
                            _gs.Scale = newScale
                            if _TL_VP then
                                _TL_VP.guiScale = newScale
                                _TL_VP.short = math.min(vp2.X, vp2.Y)
                                _TL_VP.long  = math.max(vp2.X, vp2.Y)
                            end
                        end
                    end)
                end)
            end
            local function _tryParentGui(gui)
                if gui.Parent and gui.Parent.Parent then return true end
                
                if gethui then pcall(function() gui.Parent = gethui() end) end
                if gui.Parent and gui.Parent.Parent then return true end
                pcall(function() gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
                if gui.Parent and gui.Parent.Parent then return true end
                pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 3) end)
                if gui.Parent and gui.Parent.Parent then return true end
                if CoreGui then pcall(function() gui.Parent = CoreGui end) end
                if gui.Parent and gui.Parent.Parent then return true end
                pcall(function() gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui end)
                return gui.Parent ~= nil
            end
            _tryParentGui(ScreenGui)
            pcall(function()
                
                
                
                local TOOL_NAME  = "_TLInspect"
                local SLOT_IMAGE = "rbxassetid://71807151037163"
                local RS         = RunService or _SvcRS
                local patched    = {}
                local function patchSlot(slot)
                    if patched[slot] then return end
                    patched[slot] = true
                    for _, d in ipairs(slot:GetDescendants()) do
                        pcall(function()
                            if d:IsA("TextLabel") or d:IsA("TextButton") then
                                d.Text                   = ""
                                d.TextTransparency       = 1
                                d.TextStrokeTransparency = 1
                                d.BackgroundTransparency = 1
                            end
                            if d:IsA("Frame") then
                                d.BackgroundTransparency = 1
                                d.BorderSizePixel        = 0
                            end
                            if d:IsA("ImageLabel") or d:IsA("ImageButton") then
                                if d.Name ~= "_TLInvImg" then
                                    d.BackgroundTransparency = 1
                                    d.ImageTransparency      = 1
                                    d.BorderSizePixel        = 0
                                end
                            end
                        end)
                    end
                    pcall(function()
                        slot.BackgroundTransparency = 1
                        slot.BorderSizePixel        = 0
                        if slot:IsA("ImageButton") or slot:IsA("ImageLabel") then
                            slot.ImageTransparency = 1
                        end
                    end)
                    if not slot:FindFirstChild("_TLInvImg") then
                        local img                  = Instance.new("ImageLabel")
                        img.Name                   = "_TLInvImg"
                        img.Size                   = UDim2.new(1, 0, 1, 0)
                        img.Position               = UDim2.new(0, 0, 0, 0)
                        img.BackgroundTransparency = 1
                        img.BorderSizePixel        = 0
                        img.Image                  = SLOT_IMAGE
                        img.ScaleType              = Enum.ScaleType.Fit
                        img.ZIndex                 = 20
                        img.Parent                 = slot
                    end
                end
                local function scanBackpack()
                    if not ((Players.LocalPlayer.Backpack and Players.LocalPlayer.Backpack:FindFirstChild(TOOL_NAME))
                            or (Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild(TOOL_NAME))) then
                        return
                    end
                    local cg = game:GetService("CoreGui")
                    local rg = cg:FindFirstChild("RobloxGui"); if not rg then return end
                    local bg = rg:FindFirstChild("BackpackGui"); if not bg then return end
                    for _, d in ipairs(bg:GetDescendants()) do
                        local isToolLabel = d:IsA("TextLabel") and
                            (d.Text == TOOL_NAME or d.Text == "TL Magnifyer" or d.Text == "TL Magnifier" or d.Text == "TLInspect")
                        local isToolFrame = d:IsA("Frame") and d.Name == TOOL_NAME
                        if isToolLabel or isToolFrame then
                            local slot = d.Parent
                            while slot and not (slot:IsA("Frame") or slot:IsA("ImageButton")) do
                                slot = slot.Parent
                            end
                            if slot then patchSlot(slot) end
                        end
                    end
                end
                local t = 0
                local conn
                conn = _tlTrackConn(RS.Heartbeat:Connect(function(dt)
                    t = t + dt
                    if t < 0.5 then return end
                    t = 0
                    pcall(scanBackpack)
                end))
                local charResetConn = _tlTrackConn(Players.LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(1)
                    patched = {}
                    t = 0
                end))
                pcall(function()
                    if getgenv then
                        _genv._TLInvPatchCleanup = function()
                            pcall(function() if conn then conn:Disconnect() end end)
                            pcall(function() if charResetConn then charResetConn:Disconnect() end end)
                            conn, charResetConn = nil, nil
                            patched = {}
                        end
                    end
                end)
            end)
            pcall(function()
                local RS  = RunService or _SvcRS
                local UIS = UserInputService or _SvcUIS
                local TS  = game:GetService("TweenService")
                local PG  = Players.LocalPlayer:FindFirstChild("PlayerGui")
                    or Players.LocalPlayer:WaitForChild("PlayerGui", 8)
                if not PG then return end
                local MATRIX_GREEN  = C.accent or Color3.fromRGB(0, 200, 255)
                local cards         = {}
                local outlines      = {}
                local isInGermanVoice = false
                task.spawn(function()
                    pcall(function()
                        if game.PlaceId == 8573215907 or game.PlaceId == 136162036182779 then
                            isInGermanVoice = true
                        else
                            local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
                            if info and type(info.Name) == "string" and string.find(string.lower(info.Name), "german") and string.find(string.lower(info.Name), "voice") then
                                isInGermanVoice = true
                            end
                        end
                    end)
                end)

                local function tween(obj, t, props, style, dir)
                    local info = TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
                    local tw = TS:Create(obj, info, props)
                    tw:Play()
                    return tw
                end

                local function corner(parent, radius)
                    local c = Instance.new("UICorner")
                    c.CornerRadius = UDim.new(0, radius or 8)
                    c.Parent = parent
                    return c
                end

                local function setOutline(p, on, color)
                    if outlines[p] then
                        pcall(function() outlines[p]:Destroy() end)
                        outlines[p] = nil
                    end
                    if on and p.Character then
                        pcall(function()
                            local hl               = Instance.new("Highlight")
                            hl.Adornee             = p.Character
                            hl.FillTransparency    = 1
                            hl.OutlineColor        = color or MATRIX_GREEN
                            hl.OutlineTransparency = 0
                            hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent              = workspace
                            outlines[p]            = hl
                        end)
                    end
                end

                local function openCard(p)
                    if cards[p] then return end
                    if not p or not p.Character then return end

                    
                    local MG          = C.accent or Color3.fromRGB(0, 200, 255)
                    local MGA         = C.sub or Color3.fromRGB(0, 135, 195)
                    local MGLOW       = C.text or Color3.fromRGB(210, 235, 255)
                    local MDARK       = Color3.fromRGB(12, 12, 14)
                    local MHDR        = Color3.fromRGB(18, 18, 22)
                    local MKEY        = Color3.fromRGB(160, 180, 200)
                    local MVAL        = Color3.fromRGB(230, 240, 255)
                    local MSEP        = Color3.fromRGB(100, 120, 140)

                    local PW, PH      = 258, 360

                    
                    local bb          = Instance.new("ScreenGui")
                    bb.Name           = "_TLHolo_" .. p.Name
                    bb.ResetOnSpawn   = false
                    bb.IgnoreGuiInset = true
                    bb.DisplayOrder   = 9999
                    _tryParentGui(bb)

                    
                    local _isMobile, _isTablet, _uiScale = false, false, 1.0
                    pcall(function()
                        local vp    = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
                        local touch = UIS.TouchEnabled
                        local kbd   = UIS.KeyboardEnabled
                        local short = math.min(vp.X, vp.Y)
                        _isMobile   = touch and not kbd and short < 500
                        _isTablet   = touch and not kbd and short >= 500 and short < 900
                        if _isMobile then
                            _uiScale = math.clamp((short * 0.85) / PW, 0.55, 1.1)
                        elseif _isTablet then
                            _uiScale = math.clamp((short * 0.55) / PW, 0.75, 1.15)
                        elseif vp.X < 1000 then
                            _uiScale = math.clamp(vp.X / 1280, 0.75, 1.0)
                        end
                    end)

                    
                    local root                  = Instance.new("Frame", bb)
                    root.Size                   = UDim2.new(0, PW, 0, PH)
                    root.BackgroundTransparency = 1
                    root.BorderSizePixel        = 0
                    
                    local startPos, targetPos
                    if _isMobile or _isTablet then
                        root.AnchorPoint = Vector2.new(0.5, 0.5)
                        startPos         = UDim2.new(0.5, 0, 1.5, 0)
                        targetPos        = UDim2.new(0.5, 0, 0.5, 30)
                    else
                        root.AnchorPoint = Vector2.new(1, 0.5)
                        startPos         = UDim2.new(1, 300, 0.5, 0)
                        targetPos        = UDim2.new(1, -16, 0.5, 0)
                    end
                    root.Position = startPos
                    
                    local _uiScaleInst                               = Instance.new("UIScale", root)
                    _uiScaleInst.Scale                               = _uiScale

                    
                    local ds                                         = Instance.new("ImageLabel", root)
                    ds.Name                                          = "DropShadow"
                    ds.BackgroundTransparency                        = 1
                    ds.Position                                      = UDim2.new(0, -10, 0, -10)
                    ds.Size                                          = UDim2.new(1, 20, 1, 20)
                    ds.BorderSizePixel                               = 0
                    ds.ZIndex                                        = 0
                    ds.Image                                         = "rbxassetid://1316045217"
                    ds.ImageColor3                                   = Color3.fromRGB(0, 0, 0)
                    ds.ImageTransparency                             = 0.75
                    ds.ScaleType                                     = Enum.ScaleType.Slice
                    ds.SliceCenter                                   = Rect.new(15, 15, 113, 113)

                    
                    local bg                                         = Instance.new("Frame", root)
                    bg.Size                                          = UDim2.new(1, 0, 1, 0)
                    bg.BackgroundColor3                              = MDARK
                    bg.BackgroundTransparency                        = 0.15
                    bg.BorderSizePixel                               = 0; bg.ZIndex = 1
                    bg.ClipsDescendants                              = true
                    Instance.new("UICorner", bg).CornerRadius        = UDim.new(0, 16)
                    
                    local bgGrad = Instance.new("UIGradient", bg)
                    bgGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 22)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 12))
                    })

                    
                    local border = Instance.new("UIStroke", bg)
                    border.Thickness = 1.2
                    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    border.Transparency = 0.2
                    local borderGrad = Instance.new("UIGradient", border)
                    borderGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, C.accent or Color3.fromRGB(0, 200, 255)),
                        ColorSequenceKeypoint.new(0.5, C.accent2 or Color3.fromRGB(0, 150, 255)),
                        ColorSequenceKeypoint.new(1, C.accent or Color3.fromRGB(0, 200, 255))
                    })
                    borderGrad.Rotation = 45

                    
                    tween(root, 0.4, {Position = targetPos}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

                    
                    local hdr                                        = Instance.new("Frame", bg)
                    hdr.Size                                         = UDim2.new(1, 0, 0, 56)
                    hdr.Position                                     = UDim2.new(0, 0, 0, 0)
                    hdr.BackgroundColor3                             = MHDR; hdr.BackgroundTransparency = 0.3
                    hdr.BorderSizePixel                              = 0; hdr.ZIndex = 3
                    Instance.new("UICorner", hdr).CornerRadius       = UDim.new(0, 16)

                    
                    local hdrSep                                     = Instance.new("Frame", bg)
                    hdrSep.Size                                      = UDim2.new(1, 0, 0, 1)
                    hdrSep.Position                                  = UDim2.new(0, 0, 0, 56)
                    hdrSep.BackgroundColor3                          = Color3.fromRGB(60, 60, 75)
                    hdrSep.BackgroundTransparency                    = 0.5
                    hdrSep.BorderSizePixel                           = 0; hdrSep.ZIndex = 3

                    
                    local statusLbl                                  = Instance.new("TextLabel", bg)
                    statusLbl.Size                                   = UDim2.new(0, 44, 0, 10)
                    statusLbl.Position                               = UDim2.new(1, -72, 0, 10)
                    statusLbl.BackgroundTransparency                 = 1; statusLbl.Text = "ONLINE"
                    statusLbl.TextColor3                             = MG; statusLbl.Font = Enum.Font.GothamBold
                    statusLbl.TextSize                               = 8; statusLbl.TextXAlignment = Enum.TextXAlignment.Right
                    statusLbl.ZIndex                                 = 5

                    
                    local statusDot                                  = Instance.new("Frame", bg)
                    statusDot.Size                                   = UDim2.new(0, 6, 0, 6)
                    statusDot.Position                               = UDim2.new(1, -22, 0, 12)
                    statusDot.BackgroundColor3                       = MG; statusDot.BorderSizePixel = 0; statusDot.ZIndex = 5
                    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)
                    
                    task.spawn(function()
                        while statusDot and statusDot.Parent do
                            local tw1 = TS:Create(statusDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                                Size = UDim2.new(0, 8, 0, 8),
                                Position = UDim2.new(1, -23, 0, 11),
                                BackgroundTransparency = 0.2
                            })
                            tw1:Play()
                            task.wait(0.6)
                            if not (statusDot and statusDot.Parent) then break end
                            local tw2 = TS:Create(statusDot, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                                Size = UDim2.new(0, 6, 0, 6),
                                Position = UDim2.new(1, -22, 0, 12),
                                BackgroundTransparency = 0
                            })
                            tw2:Play()
                            task.wait(0.6)
                        end
                    end)

                    
                    local closeBtn = Instance.new("ImageButton", hdr)
                    closeBtn.Size = UDim2.new(0, 16, 0, 16)
                    closeBtn.Position = UDim2.new(1, -22, 0, 30)
                    closeBtn.BackgroundTransparency = 1
                    closeBtn.Image = "rbxassetid://121032825074289"
                    closeBtn.ImageColor3 = Color3.fromRGB(180, 180, 190)
                    closeBtn.ZIndex = 5
                    closeBtn.MouseEnter:Connect(function()
                        closeBtn.ImageColor3 = Color3.fromRGB(255, 100, 100)
                    end)
                    closeBtn.MouseLeave:Connect(function()
                        closeBtn.ImageColor3 = Color3.fromRGB(180, 180, 190)
                    end)
                    closeBtn.MouseButton1Click:Connect(function()
                        toggle(p)
                    end)

                    
                    local ava                                        = Instance.new("Frame", hdr)
                    ava.Size                                         = UDim2.new(0, 38, 0, 38)
                    ava.Position                                     = UDim2.new(0, 10, 0.5, -19)
                    ava.BackgroundColor3                             = Color3.fromRGB(0, 0, 0)
                    ava.BackgroundTransparency                       = 0.5; ava.BorderSizePixel = 0; ava.ZIndex = 3
                    Instance.new("UICorner", ava).CornerRadius       = UDim.new(1, 0)
                    
                    local ring = Instance.new("UIStroke", ava)
                    ring.Thickness = 1.5
                    ring.Color = MG
                    ring.Transparency = 0.3
                    
                    
                    local avaImg                                     = Instance.new("ImageLabel", ava)
                    avaImg.Size                                      = UDim2.new(1, 0, 1, 0); avaImg.BackgroundTransparency = 1
                    avaImg.Image                                     = ""; avaImg.ScaleType = Enum.ScaleType.Crop; avaImg.ZIndex = 4
                    Instance.new("UICorner", avaImg).CornerRadius    = UDim.new(1, 0)

                    task.spawn(function()
                        pcall(function()
                            local img = Players:GetUserThumbnailAsync(p.UserId,
                                Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                            if avaImg.Parent then avaImg.Image = img end
                        end)
                    end)

                    
                    local nm                      = Instance.new("TextLabel", hdr)
                    nm.Size                       = UDim2.new(1, -125, 0, 18); nm.Position = UDim2.new(0, 58, 0, 10)
                    nm.BackgroundTransparency     = 1; nm.Text = p.Name
                    nm.TextColor3                 = MGLOW; nm.Font = Enum.Font.GothamBlack
                    nm.TextSize                   = 13; nm.TextXAlignment = Enum.TextXAlignment.Left
                    nm.TextTruncate               = Enum.TextTruncate.AtEnd; nm.ZIndex = 3

                    
                    local nmSub                   = Instance.new("TextLabel", hdr)
                    nmSub.Size                    = UDim2.new(1, -125, 0, 13); nmSub.Position = UDim2.new(0, 58, 0, 30)
                    nmSub.BackgroundTransparency  = 1
                    nmSub.Text                    = "@" .. (p.DisplayName or p.Name)
                    nmSub.TextColor3              = MGA; nmSub.Font = Enum.Font.GothamBold
                    nmSub.TextSize                = 11; nmSub.TextXAlignment = Enum.TextXAlignment.Left
                    nmSub.TextTruncate            = Enum.TextTruncate.AtEnd; nmSub.ZIndex = 3

                    
                    local sf                      = Instance.new("ScrollingFrame", bg)
                    sf.Size                       = UDim2.new(1, -4, 1, -124)
                    sf.Position                   = UDim2.new(0, 2, 0, 60)
                    sf.BackgroundTransparency     = 1; sf.BorderSizePixel = 0
                    sf.ScrollBarThickness         = 3; sf.ScrollBarImageColor3 = C.accent
                    sf.ScrollBarImageTransparency = 0.2
                    sf.CanvasSize                 = UDim2.new(0, 0, 0, 0)
                    sf.AutomaticCanvasSize        = Enum.AutomaticSize.Y
                    sf.ElasticBehavior            = Enum.ElasticBehavior.Never
                    sf.ScrollingDirection         = Enum.ScrollingDirection.Y; sf.ZIndex = 3

                    local ll                      = Instance.new("UIListLayout", sf)
                    ll.SortOrder                  = Enum.SortOrder.LayoutOrder; ll.Padding = UDim.new(0, 4)

                    local sfPad                   = Instance.new("UIPadding", sf)
                    sfPad.PaddingLeft             = UDim.new(0, 8)
                    sfPad.PaddingRight            = UDim.new(0, 8)
                    sfPad.PaddingTop              = UDim.new(0, 8)
                    sfPad.PaddingBottom           = UDim.new(0, 8)

                    
                    local ord                     = 0
                    local function mkRow(key, val)
                        ord = ord + 1
                        local f = Instance.new("Frame", sf)
                        f.Size = UDim2.new(1, 0, 0, 26); f.LayoutOrder = ord
                        f.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
                        f.BackgroundTransparency = 0.6
                        f.BorderSizePixel = 0; f.ZIndex = 4
                        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
                        
                        local rowStroke = Instance.new("UIStroke", f)
                        rowStroke.Thickness = 1
                        rowStroke.Color = Color3.fromRGB(45, 45, 52)
                        rowStroke.Transparency = 0.5
                        rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                        local k = Instance.new("TextLabel", f)
                        k.Size = UDim2.new(0, 100, 1, 0); k.Position = UDim2.new(0, 10, 0, 0)
                        k.BackgroundTransparency = 1; k.Text = tostring(key:upper())
                        k.TextColor3 = MKEY; k.Font = Enum.Font.GothamBold
                        k.TextSize = 10; k.TextXAlignment = Enum.TextXAlignment.Left; k.ZIndex = 5

                        local v = Instance.new("TextLabel", f)
                        v.Size = UDim2.new(1, -116, 1, 0); v.Position = UDim2.new(0, 116, 0, 0)
                        v.BackgroundTransparency = 1; v.Text = tostring(val ~= nil and val or "?")
                        v.TextColor3 = MVAL; v.Font = Enum.Font.Gotham
                        v.TextSize = 10; v.TextXAlignment = Enum.TextXAlignment.Left
                        v.TextTruncate = Enum.TextTruncate.AtEnd; v.ZIndex = 5
                        
                        
                        f.MouseEnter:Connect(function()
                            TS:Create(f, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                                BackgroundColor3 = Color3.fromRGB(35, 35, 42),
                                BackgroundTransparency = 0.4
                            }):Play()
                            TS:Create(rowStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                                Transparency = 0.2,
                                Color = C.accent or Color3.fromRGB(0, 200, 255)
                            }):Play()
                        end)
                        f.MouseLeave:Connect(function()
                            TS:Create(f, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                                BackgroundColor3 = Color3.fromRGB(22, 22, 26),
                                BackgroundTransparency = 0.6
                            }):Play()
                            TS:Create(rowStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                                Transparency = 0.5,
                                Color = Color3.fromRGB(45, 45, 52)
                            }):Play()
                        end)

                        return v
                    end

                    local function mkSec(title)
                        ord = ord + 1
                        local f = Instance.new("Frame", sf)
                        f.Size = UDim2.new(1, 0, 0, 22); f.LayoutOrder = ord
                        f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = 4

                        local lb = Instance.new("TextLabel", f)
                        lb.Size = UDim2.new(1, 0, 1, 0); lb.Position = UDim2.new(0, 4, 0, 4)
                        lb.BackgroundTransparency = 1; lb.Text = string.upper(tostring(title or ""))
                        lb.TextColor3 = MSEP; lb.Font = Enum.Font.GothamBlack
                        lb.TextSize = 10; lb.TextXAlignment = Enum.TextXAlignment.Left; lb.ZIndex = 5
                    end

                    
                    mkRow("name", p.Name)
                    mkRow("display", p.DisplayName)
                    mkRow("uid", p.UserId)
                    mkRow("age", tostring(p.AccountAge or "?") .. "d")
                    local mem = "false"
                    pcall(function() if p.MembershipType == Enum.MembershipType.Premium then mem = "true" end end)
                    mkRow("premium", mem)
                    local ping = "?"
                    pcall(function()
                        ping = math.floor((game:GetService("Stats") :: any).Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
                    end)
                    mkRow("ping", ping)
                    mkRow("team", (p.Team and p.Team.Name) or "nil")
                    local hp, mhp = "?", "?"
                    pcall(function()
                        local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                        if h then
                            hp = math.floor(h.Health); mhp = math.floor(h.MaxHealth)
                        end
                    end)
                    mkRow("hp", hp ~= "?" and (hp .. "/" .. mhp) or "?")
                    mkSec("ACCOUNT")
                    local vJoin    = mkRow("joined", "loading…")
                    local vAliases = mkRow("aliases", "loading…")
                    mkSec("SOCIAL")
                    local vFriends = mkRow("friends", "loading…")

                    
                    local _cachedNames = {}
                    task.spawn(function()
                        local HS = game:GetService("HttpService")
                        pcall(function()
                            local d = HS:JSONDecode((game :: any):HttpGet("https://users.roblox.com/v1/users/" .. p.UserId))
                            if d and d.created then
                                local y, m, dd = d.created:match("(%d+)-(%d+)-(%d+)")
                                if y and vJoin.Parent then vJoin.Text = dd .. "." .. m .. "." .. y end
                            end
                        end)
                        pcall(function()
                            local d = HS:JSONDecode((game :: any):HttpGet(
                                "https://users.roblox.com/v1/users/" .. p.UserId .. "/username-history?limit=10"))
                            if d and d.data and #d.data > 0 then
                                local ns = {}; for _, v in ipairs(d.data) do ns[#ns + 1] = v.name end
                                _cachedNames = ns
                                if vAliases.Parent then vAliases.Text = table.concat(ns, ", ") end
                            elseif vAliases.Parent then
                                vAliases.Text = "none"
                            end
                        end)
                        pcall(function()
                            local d = HS:JSONDecode((game :: any):HttpGet(
                                "https://friends.roblox.com/v1/users/" .. p.UserId .. "/friends/count"))
                            if d and d.count ~= nil and vFriends.Parent then vFriends.Text = tostring(d.count) end
                        end)
                    end)

                    
                    local footSep                                 = Instance.new("Frame", bg)
                    footSep.Size                                  = UDim2.new(1, 0, 0, 1)
                    footSep.Position                              = UDim2.new(0, 0, 1, -46)
                    footSep.BackgroundColor3                      = Color3.fromRGB(60, 60, 75)
                    footSep.BackgroundTransparency                = 0.5
                    footSep.BorderSizePixel                       = 0; footSep.ZIndex = 8

                    

                    local addBtn                                  = Instance.new("TextButton", bg)
                    addBtn.BackgroundColor3                       = Color3.fromRGB(25, 25, 30)
                    addBtn.BackgroundTransparency                 = 0.4
                    addBtn.BorderSizePixel                        = 0
                    addBtn.TextColor3                             = Color3.fromRGB(245, 245, 250)
                    addBtn.Font                                   = Enum.Font.GothamBold; addBtn.TextSize = 9
                    addBtn.ZIndex                                 = 9; addBtn.Active = true
                    Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 8)
                    
                    local addSt                                   = Instance.new("UIStroke", addBtn)
                    addSt.Color                                   = C.accent or Color3.fromRGB(0, 200, 255)
                    addSt.Thickness                               = 1.2
                    addSt.Transparency                            = 0.4
                    addSt.ApplyStrokeMode                         = Enum.ApplyStrokeMode.Border

                    
                    addBtn.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        TS:Create(addBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.2,
                            BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                        }):Play()
                        TS:Create(addSt, TweenInfo.new(0.2), {
                            Transparency = 0
                        }):Play()
                    end)
                    addBtn.MouseLeave:Connect(function()
                        TS:Create(addBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.4,
                            BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                        }):Play()
                        TS:Create(addSt, TweenInfo.new(0.2), {
                            Transparency = 0.4
                        }):Play()
                    end)

                    addBtn.MouseButton1Click:Connect(function()
                        if not addBtn.Active then return end
                        addBtn.Text = "SENDING…"; addBtn.BackgroundTransparency = 0.4
                        task.spawn(function()
                            local ok = pcall(function()
                                game:GetService("Players").LocalPlayer:RequestFriendship(p)
                            end)
                            task.wait(0.5)
                            if addBtn.Parent then
                                addBtn.Text = ok and "SENT" or "FRIENDS"
                                addBtn.BackgroundColor3 = ok and C.accent or Color3.fromRGB(55, 55, 55)
                                addBtn.BackgroundTransparency = ok and 0.2 or 0.8; addBtn.Active = false
                            end
                        end)
                    end)

                    local namesBtn                                  = Instance.new("TextButton", bg)
                    namesBtn.BackgroundColor3                       = Color3.fromRGB(25, 25, 30)
                    namesBtn.BackgroundTransparency                 = 0.4
                    namesBtn.BorderSizePixel                        = 0
                    namesBtn.TextColor3                             = Color3.fromRGB(245, 245, 250)
                    namesBtn.Font                                   = Enum.Font.GothamBold; namesBtn.TextSize = 9
                    namesBtn.ZIndex                                 = 9; namesBtn.Active = true
                    Instance.new("UICorner", namesBtn).CornerRadius = UDim.new(0, 8)
                    
                    local namesSt                                   = Instance.new("UIStroke", namesBtn)
                    namesSt.Color                                   = C.accent2 or Color3.fromRGB(0, 160, 220)
                    namesSt.Thickness                               = 1.2
                    namesSt.Transparency                            = 0.4
                    namesSt.ApplyStrokeMode                         = Enum.ApplyStrokeMode.Border

                    namesBtn.MouseEnter:Connect(function()
                        _sc._playHoverSound()
                        TS:Create(namesBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.2,
                            BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255)
                        }):Play()
                        TS:Create(namesSt, TweenInfo.new(0.2), {
                            Transparency = 0
                        }):Play()
                    end)
                    namesBtn.MouseLeave:Connect(function()
                        TS:Create(namesBtn, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0.4,
                            BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                        }):Play()
                        TS:Create(namesSt, TweenInfo.new(0.2), {
                            Transparency = 0.4
                        }):Play()
                    end)

                    if isInGermanVoice then
                        
                        addBtn.Size = UDim2.new(0, 76, 0, 28)
                        addBtn.Position = UDim2.new(0, 8, 1, -38)
                        addBtn.Text = "FRIEND"

                        namesBtn.Size = UDim2.new(0, 78, 0, 28)
                        namesBtn.Position = UDim2.new(0, 168, 1, -38)
                        namesBtn.Text = "NAMES"
                    else
                        
                        addBtn.Size = UDim2.new(0, 114, 0, 28)
                        addBtn.Position = UDim2.new(0, 10, 1, -38)
                        addBtn.Text = "ADD FRIEND"

                        namesBtn.Size = UDim2.new(1, -138, 0, 28)
                        namesBtn.Position = UDim2.new(0, 130, 1, -38)
                        namesBtn.Text = "NAMES ◈"
                    end

                    
                    local namesPopup = nil
                    local function _doNamesBtn()
                        if namesPopup and namesPopup.Parent then
                            namesPopup:Destroy(); namesPopup = nil
                            namesBtn.Text = isInGermanVoice and "NAMES" or "NAMES ◈"; return
                        end
                        namesBtn.Text        = isInGermanVoice and "[ NAMES ]" or "[ NAMES ◈ ]"

                        local POP_W          = 180
                        local pop            = Instance.new("Frame", root)
                        pop.Name             = "_NamesPopup"
                        pop.AnchorPoint      = Vector2.new(1, 0)
                        pop.Position         = UDim2.new(0, 20, 0, 0) 
                        pop.Size             = UDim2.new(0, POP_W, 0, 40)
                        pop.BackgroundColor3 = MDARK
                        pop.BackgroundTransparency = 0.15
                        pop.BorderSizePixel  = 0; pop.ZIndex = 30
                        corner(pop, 10)
                        
                        local popSt = Instance.new("UIStroke", pop)
                        popSt.Color = C.accent or Color3.fromRGB(0, 200, 255)
                        popSt.Thickness = 1.2
                        popSt.Transparency = 0.3
                        popSt.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        
                        
                        tween(pop, 0.3, {Position = UDim2.new(0, -10, 0, 0)})

                        local popHdr = Instance.new("Frame", pop)
                        popHdr.Size = UDim2.new(1, 0, 0, 32)
                        popHdr.BackgroundColor3 = MHDR
                        popHdr.BackgroundTransparency = 0.3
                        popHdr.BorderSizePixel = 0; popHdr.ZIndex = 31
                        corner(popHdr, 10)

                        local popTit = Instance.new("TextLabel", popHdr)
                        popTit.Size = UDim2.new(1, -34, 1, 0); popTit.Position = UDim2.new(0, 12, 0, 0)
                        popTit.BackgroundTransparency = 1; popTit.Text = "PREVIOUS NAMES"
                        popTit.TextColor3 = MGLOW; popTit.Font = Enum.Font.GothamBold
                        popTit.TextSize = 9; popTit.TextXAlignment = Enum.TextXAlignment.Left; popTit.ZIndex = 32

                        local xBtn = Instance.new("ImageButton", popHdr)
                        xBtn.Size = UDim2.new(0, 14, 0, 14)
                        xBtn.Position = UDim2.new(1, -22, 0.5, -7)
                        xBtn.BackgroundTransparency = 1; xBtn.Image = "rbxassetid://121032825074289"
                        xBtn.ImageColor3 = Color3.fromRGB(180, 180, 190); xBtn.ZIndex = 33
                        xBtn.MouseButton1Click:Connect(function()
                            if namesPopup then
                                namesPopup:Destroy(); namesPopup = nil
                            end
                            namesBtn.Text = isInGermanVoice and "NAMES" or "NAMES ◈"
                        end)
                        xBtn.MouseEnter:Connect(function() tween(xBtn, 0.12, { ImageColor3 = Color3.fromRGB(255, 100, 100) }) end)
                        xBtn.MouseLeave:Connect(function() tween(xBtn, 0.12, { ImageColor3 = Color3.fromRGB(180, 180, 190) }) end)

                        local scroll = Instance.new("ScrollingFrame", pop)
                        scroll.Position = UDim2.new(0, 0, 0, 32); scroll.Size = UDim2.new(1, 0, 1, -32)
                        scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ZIndex = 31
                        scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = C.accent
                        scroll.ScrollBarImageTransparency = 0.2
                        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                        local lfl = Instance.new("UIListLayout", scroll)
                        lfl.Padding = UDim.new(0, 4); lfl.SortOrder = Enum.SortOrder.LayoutOrder
                        local lfp = Instance.new("UIPadding", scroll)
                        lfp.PaddingLeft = UDim.new(0, 8); lfp.PaddingRight = UDim.new(0, 8)
                        lfp.PaddingTop = UDim.new(0, 8); lfp.PaddingBottom = UDim.new(0, 8)

                        local function addNRow(idx, name)
                            local rf = Instance.new("Frame", scroll)
                            rf.Size = UDim2.new(1, 0, 0, 26); rf.LayoutOrder = idx
                            rf.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                            rf.BackgroundTransparency = 0.6
                            rf.BorderSizePixel = 0; rf.ZIndex = 32
                            corner(rf, 6)

                            local rfStroke = Instance.new("UIStroke", rf)
                            rfStroke.Color = Color3.fromRGB(45, 45, 52)
                            rfStroke.Thickness = 1
                            rfStroke.Transparency = 0.5
                            rfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                            local il = Instance.new("TextLabel", rf)
                            il.Size = UDim2.new(0, 22, 1, 0); il.Position = UDim2.fromOffset(4, 0)
                            il.BackgroundTransparency = 1; il.Text = tostring(idx)
                            il.TextColor3 = C.accent or Color3.fromRGB(0, 160, 255); il.Font = Enum.Font.GothamBold; il.TextSize = 10; il.ZIndex = 33

                            local nl = Instance.new("TextLabel", rf)
                            nl.Size = UDim2.new(1, -34, 1, 0); nl.Position = UDim2.fromOffset(28, 0)
                            nl.BackgroundTransparency = 1; nl.Text = name
                            nl.TextColor3 = Color3.fromRGB(230, 230, 235); nl.Font = Enum.Font.Gotham; nl.TextSize = 11
                            nl.TextXAlignment = Enum.TextXAlignment.Left; nl.TextTruncate = Enum.TextTruncate.AtEnd; nl.ZIndex = 33
                        end

                        local function populate(ns)
                            for _, c in ipairs(scroll:GetChildren()) do
                                if c:IsA("Frame") then c:Destroy() end
                            end
                            if #ns == 0 then
                                addNRow(1, "No history found")
                            else
                                for i, n in ipairs(ns) do addNRow(i, n) end
                            end
                            local count = math.max(#ns, 1)
                            local totalH = math.clamp(32 + (count * 30) + 16, 60, 260)
                            pop.Size = UDim2.new(0, POP_W, 0, totalH)
                        end

                        namesPopup = pop
                        if #_cachedNames > 0 then
                            populate(_cachedNames)
                        else
                            addNRow(1, "Loading names...")
                            pop.Size = UDim2.new(0, POP_W, 0, 68)
                            task.spawn(function()
                                local ok, res = pcall(function()
                                    local data = (game :: any):HttpGet("https://users.roblox.com/v1/users/" ..
                                    p.UserId .. "/username-history?limit=10")
                                    local d = game:GetService("HttpService"):JSONDecode(data)
                                    local ns = {}
                                    if d and d.data then for _, v in ipairs(d.data) do ns[#ns + 1] = v.name end end
                                    return ns
                                end)
                                if ok and res then
                                    _cachedNames = res
                                    if namesPopup and namesPopup.Parent then populate(res) end
                                end
                            end)
                        end
                    end
                    namesBtn.MouseButton1Click:Connect(_doNamesBtn)
                    namesBtn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then _doNamesBtn() end
                    end)

                    
                    local scrollConn = nil
                    local mouseIn = false
                    sf.ScrollingEnabled = true
                    if not (_isMobile or _isTablet) then
                        scrollConn = UIS.InputChanged:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                                if not bb.Parent then return end
                                local ap = bg.AbsolutePosition; local as = bg.AbsoluteSize
                                local mp = UIS:GetMouseLocation()
                                mouseIn = mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y
                                return
                            end
                            if inp.UserInputType ~= Enum.UserInputType.MouseWheel or not mouseIn then return end
                            local maxY = math.max(0, sf.AbsoluteCanvasSize.Y - sf.AbsoluteSize.Y)
                            sf.CanvasPosition = Vector2.new(0,
                                math.clamp(sf.CanvasPosition.Y - inp.Position.Z * 36, 0, maxY))
                        end)
                    end

                    local respawnConn = p.CharacterAdded:Connect(function(c)
                        task.wait(0.2)
                        if outlines[p] then pcall(function() outlines[p].Adornee = c end) end
                    end)
                    cards[p] = { gui = bb, sc = scrollConn, resp = respawnConn, isMobile = _isMobile or _isTablet }
                end

                local function closeCard(p)
                    local d = cards[p]; if not d then return end
                    pcall(function() if d.sc then d.sc:Disconnect() end end)
                    pcall(function() d.resp:Disconnect() end)
                    pcall(function()
                        local root = d.gui:FindFirstChildOfClass("Frame")
                        if root then
                            local targetPos
                            if d.isMobile then
                                targetPos = UDim2.new(0.5, 0, 1.5, 0)
                            else
                                targetPos = UDim2.new(1, 300, 0.5, 0)
                            end
                            local tw = TS:Create(root, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = targetPos})
                            tw:Play()
                            tw.Completed:Connect(function()
                                pcall(function() d.gui:Destroy() end)
                            end)
                        else
                            d.gui:Destroy()
                        end
                    end)
                    cards[p] = nil
                end

                local function closeAll()
                    for p in pairs(cards) do closeCard(p) end
                    for p in pairs(outlines) do setOutline(p, false) end
                end

                local function toggle(p)
                    if cards[p] then
                        closeCard(p); setOutline(p, false)
                    else
                        setOutline(p, true); openCard(p)
                    end
                end

                local function removeTLTool()
                    for _, loc in ipairs({
                        Players.LocalPlayer:FindFirstChildOfClass("Backpack"),
                        Players.LocalPlayer.Character
                    }) do
                        if loc then
                            local t = loc:FindFirstChild("_TLInspect")
                            if t then t:Destroy() end
                        end
                    end
                    closeAll()
                end

                removeTLTool()
                local tool   = Instance.new("Tool")
                tool.Name    = "_TLInspect"
                tool.ToolTip = ""
                pcall(function() tool.TextureId = "rbxassetid://84392553014944" end)
                tool.CanBeDropped   = false
                tool.RequiresHandle = true
                tool.GripPos        = Vector3.new(0, 0, -0.3)
                tool.GripForward    = Vector3.new(0, 0, -1)
                tool.GripRight      = Vector3.new(1, 0, 0)
                tool.GripUp         = Vector3.new(0, 1, 0)
                local handle        = Instance.new("Part", tool)
                handle.Name         = "Handle"
                handle.Size         = Vector3.new(0.1, 0.1, 0.1)
                handle.CanCollide   = false
                handle.Massless     = true
                handle.CastShadow   = false
                handle.Transparency = 1

                local function setupTool(t)
                    local clickConn = nil
                    local moveConn = nil
                    local lastHover = nil
                    
                    t.Equipped:Connect(function(mouse)
                        if clickConn then
                            clickConn:Disconnect(); clickConn = nil
                        end
                        if moveConn then
                            moveConn:Disconnect(); moveConn = nil
                        end
                        
                        if mouse then
                            clickConn = mouse.Button1Down:Connect(function()
                                local hit = mouse.Target; if not hit then return end
                                local ch = hit:FindFirstAncestorOfClass("Model")
                                local p  = ch and Players:GetPlayerFromCharacter(ch)
                                if p and p ~= Players.LocalPlayer then toggle(p) end
                            end)
                            moveConn = mouse.Move:Connect(function()
                                local hit = mouse.Target
                                local ch = hit and hit:FindFirstAncestorOfClass("Model")
                                local p = ch and Players:GetPlayerFromCharacter(ch)
                                if p and p ~= Players.LocalPlayer then
                                    if lastHover ~= p then
                                        if lastHover and not cards[lastHover] then setOutline(lastHover, false) end
                                        if not cards[p] then setOutline(p, true, MATRIX_GREEN) end
                                        lastHover = p
                                    end
                                else
                                    if lastHover then
                                        if not cards[lastHover] then setOutline(lastHover, false) end
                                        lastHover = nil
                                    end
                                end
                            end)
                        else
                            local _hasTouchEnabled = pcall(function() return UIS.TouchEnabled end) and UIS.TouchEnabled
                            if _hasTouchEnabled then
                                clickConn = UIS.TouchTap:Connect(function(positions)
                                    local cam = workspace.CurrentCamera; if not cam then return end
                                    local pos = positions[1]
                                    if not pos then return end
                                    local ray = cam:ScreenPointToRay(pos.X, pos.Y)
                                    local res = workspace:Raycast(ray.Origin, ray.Direction * 500)
                                    local hit = res and res.Instance; if not hit then return end
                                    local ch = hit:FindFirstAncestorOfClass("Model")
                                    local p  = ch and Players:GetPlayerFromCharacter(ch)
                                    if p and p ~= Players.LocalPlayer then toggle(p) end
                                end)
                            else
                                clickConn = UIS.InputBegan:Connect(function(inp, gpe)
                                    if gpe or inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                                    local cam = workspace.CurrentCamera; if not cam then return end
                                    local mp  = UIS:GetMouseLocation()
                                    local ray = cam:ScreenPointToRay(mp.X, mp.Y)
                                    local res = workspace:Raycast(ray.Origin, ray.Direction * 500)
                                    local hit = res and res.Instance; if not hit then return end
                                    local ch = hit:FindFirstAncestorOfClass("Model")
                                    local p  = ch and Players:GetPlayerFromCharacter(ch)
                                    if p and p ~= Players.LocalPlayer then toggle(p) end
                                end)
                            end
                        end
                    end)
                    
                    t.Unequipped:Connect(function()
                        if clickConn then
                            clickConn:Disconnect(); clickConn = nil
                        end
                        if moveConn then
                            moveConn:Disconnect(); moveConn = nil
                        end
                        if lastHover then
                            setOutline(lastHover, false); lastHover = nil
                        end
                        closeAll()
                    end)
                end

                setupTool(tool)

                local function spawnTool()
                    for _, loc in ipairs({
                        Players.LocalPlayer:FindFirstChildOfClass("Backpack"),
                        Players.LocalPlayer.Character
                    }) do
                        if loc then
                            local old = loc:FindFirstChild("_TLInspect")
                            if old then old:Destroy() end
                        end
                    end
                    local bp = Players.LocalPlayer:FindFirstChildOfClass("Backpack")
                        or Players.LocalPlayer:WaitForChild("Backpack", 8)
                    if bp then tool.Parent = bp end
                end

                local function createNewTool()
                    for _, loc in ipairs({
                        Players.LocalPlayer:FindFirstChildOfClass("Backpack"),
                        Players.LocalPlayer.Character
                    }) do
                        if loc then
                            local old = loc:FindFirstChild("_TLInspect")
                            if old then old:Destroy() end
                        end
                    end
                    local newTool   = Instance.new("Tool")
                    newTool.Name    = "_TLInspect"
                    newTool.ToolTip = ""
                    pcall(function() newTool.TextureId = "rbxassetid://84392553014944" end)
                    newTool.CanBeDropped   = false
                    newTool.RequiresHandle = true
                    newTool.GripPos        = Vector3.new(0, 0, -0.3)
                    newTool.GripForward    = Vector3.new(0, 0, -1)
                    newTool.GripRight      = Vector3.new(1, 0, 0)
                    newTool.GripUp         = Vector3.new(0, 1, 0)
                    local handle           = Instance.new("Part", newTool)
                    handle.Name            = "Handle"
                    handle.Size            = Vector3.new(0.1, 0.1, 0.1)
                    handle.CanCollide      = false
                    handle.Massless        = true
                    handle.CastShadow      = false
                    handle.Transparency    = 1
                    
                    setupTool(newTool)
                    
                    local bp = Players.LocalPlayer:FindFirstChildOfClass("Backpack")
                        or Players.LocalPlayer:WaitForChild("Backpack", 8)
                    if bp then newTool.Parent = bp end
                    tool = newTool
                end

                task.spawn(spawnTool)
                Players.LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(0.8); task.spawn(createNewTool)
                end)
                if getgenv then _genv._TLRemoveTool = removeTLTool end
            end)
                        
            
            
keybinds, keybindMainConn = {}, nil
            isConfiguringKeybind = false
            lastConfiguredKey = nil
            lastConfiguredTime = 0
            function rebuildKeybindListener()
                if keybindMainConn then keybindMainConn:Disconnect() end
                keybindMainConn = UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if isConfiguringKeybind then return end
                    if lastConfiguredKey and input.KeyCode == lastConfiguredKey and tick() - lastConfiguredTime < 0.5 then return end
                    for actionName, data in pairs(keybinds) do
                        if data.key and input.KeyCode == data.key and data.callback then
                            data.callback()
                        end
                    end
                end)
            end

            rebuildKeybindListener()

            
            local function registerKeybind(actionName, defaultKey, callback)
                keybinds[actionName] = { key = defaultKey, callback = callback }
            end
            keybindLabelUpdaters, SAVE_FILE = {}, "SmartBar_Save.json"
            settingsState = {
                soundEnabled   = true,
                TLColor        = "white",
                notifications  = true,
                showHint       = false,
                autoOpen       = false,
                menuSounds     = true,
                guiScale       = 1.0,
                guiPosition    = 1, 
                nametagVisible = true, 
                removeNametag  = false, 
                antiVcBan      = false,
            }

            
            
            
            
            

            local function initializeThemeAndSettings()
                

                
                
                local cachedColor = _loadCache("color")

                local _gotColorFromCache = false

                if cachedColor and cachedColor.id then
                    _TL_activeThemeId     = cachedColor.id
                    settingsState.TLColor = cachedColor.id
                    _TL_lastColor         = cachedColor.id
                    _gotColorFromCache    = true
                elseif _genv._TL_savedTheme then
                    _TL_activeThemeId     = _genv._TL_savedTheme
                    settingsState.TLColor = _genv._TL_savedTheme
                    _TL_lastColor         = _genv._TL_savedTheme
                    _gotColorFromCache    = true
                end

                
                
                
                local _saveFileExists = false
                pcall(function()
                    _saveFileExists = (type(isfile) == "function") and isfile(SAVE_FILE)
                end)
                if readfile and _saveFileExists and not _gotColorFromCache then
                    local ok, content = pcall(readfile, SAVE_FILE)
                    if ok and content and content ~= "" then
                        local settBlock = extractJsonSection(content, "settings")
                        if settBlock ~= "" then
                            
                            local tc = settBlock:match('"TL%-Color"%s*:%s*"([^"]*)"')
                                    or settBlock:match('"themeColor"%s*:%s*"([^"]*)"')
                            if tc and tc ~= "" then
                                _TL_activeThemeId     = tc
                                settingsState.TLColor = tc
                                _TL_lastColor         = tc
                            end
                        end
                    end
                end

                
                
                
                local themeToApply = settingsState.TLColor
                if themeToApply and _TL_IMG_THEMES[themeToApply] and not _TL_ANIME_THEMES[themeToApply] then
                    themeToApply          = "white"
                    _TL_activeThemeId     = "white"
                    settingsState.TLColor = "white"
                    _TL_lastColor         = "white"
                end

                
                if themeToApply then
                    pcall(function()
                        _TL_applyTheme(themeToApply, true)
                    end)
                end
            end

            
            pcall(initializeThemeAndSettings)

            local T = {
                settings_title            = "Settings",
                settings_general          = "General",
                settings_keybinds         = "Keybinds",
                settings_sound            = "Sound Effects",
                settings_sound_badge      = "Global",
                settings_notif            = "Notifications",
                settings_notif_badge      = "Hints",
                settings_hint             = "Show Hint",
                settings_hint_badge       = "UI",
                settings_auto             = "Auto-open",
                settings_auto_badge       = "Startup",
                settings_menusounds       = "Menu Sounds",
                settings_menusounds_badge = "UI",
                notif_settings_loaded     = "Settings loaded ✅",
                notif_saved               = "✅  Saved!",
                save_settings             = "💾  Save Settings & Keybinds",
                home_section_game         = "CURRENT EXPERIENCE",
                home_section_profile      = "YOUR PROFILE",
                home_place_id             = "Place ID",
                home_universe_id          = "Universe ID",
                home_job_id               = "Job ID",
                kb_hint                   = "Click a key, then press a button  –  Esc to clear",
                kb_reset                  = "Reset",
                profile_online            = "Online",
                smartbar_hint             = "Press  K  to open the SmartBar",
                qa_nobody                 = "Nobody nearby",
                qa_title                  = "QUICK ACTIONS",
                qa_subtitle               = "Select an action",
                qa_stopped                = "Stopped",
                qa_no_target              = "⚠  No target found",
                qa_idle                   = "Idle  –  Select an action",
                qa_extras                 = "  EXTRAS",
                script_active             = "Active",
                script_inactive           = "Inactive",
                gb_no_target_char         = "No target character!",
                gb_no_own_char            = "No own character!",
                gb_missing_parts          = "Missing parts!",
                rush_label                = "Rush",
                rush_player_pill          = "Player...",
                rush_no_players           = "No players online",
                rush_stopped              = "Stopped 🛑",
                rush_no_target_char       = "No target character!",
                rush_no_char              = "No own character!",
                rush_missing_parts        = "Missing parts!",
                rush_running              = "Rush ⚡ ",
                actions_info_lbl          = "Actions",
                actions_info_sub          = "Select a player & action, then activate",
                actions_pick_target       = "Target",
                actions_player_pill       = "Player...",
                actions_action_pill       = "Action...",
                actions_row_lbl           = "Actions",
                actions_status_idle       = "Inactive",
                actions_select_player     = "Select a player first!",
                actions_select_action     = "Select an action first!",
                actions_following         = "Following: ",
                actions_stopped           = "Stopped",
                actions_no_players        = "No players online",
                playercard_spectate       = "Spectate",
                playercard_teleport       = "Teleport",
                playercard_esp            = "ESP",
                anim_no_nearby            = "No player nearby!",
                orbit_respawn             = "Target respawned – Orbit reset!",
                no_players_online         = "No players online",
            }

            T.saved_outfits_title = "Saved Outfits"
            T.saved_outfits_sub = "Manage your outfits"
            T.new_folder = "New Folder"
            T.folder_prefix = "Folder: "
            T.unknown = "Unknown"
            T.no_outfits_saved = "— No outfits saved"

            local function serializeData()
                local kbData = {}
                for name, data in pairs(keybinds) do
                    kbData[name] = data.key and tostring(data.key):gsub("Enum.KeyCode%.", "") or "None"
                end
                local lines = { "{\n" }
                lines[#lines + 1] = '  "settings": {\n'
                local settKeys = {}
                for k in pairs(settingsState) do settKeys[#settKeys + 1] = k end
                for i, k in ipairs(settKeys) do
                    local v = settingsState[k]
                    local comma = i < #settKeys and "," or ""
                    if type(v) == "string" then
                        lines[#lines + 1] = string.format('    "%s": "%s"%s\n', k, v, comma)
                    else
                        lines[#lines + 1] = string.format('    "%s": %s%s\n', k, tostring(v), comma)
                    end
                end
                lines[#lines + 1] = '  },\n'
                lines[#lines + 1] = '  "keybinds": {\n'
                local kbKeys = {}
                for k in pairs(kbData) do kbKeys[#kbKeys + 1] = k end
                for i, k in ipairs(kbKeys) do
                    local comma = i < #kbKeys and "," or ""
                    lines[#lines + 1] = string.format('    "%s": "%s"%s\n', k, kbData[k], comma)
                end
                lines[#lines + 1] = '  }\n'
                lines[#lines + 1] = "}"
                return table.concat(lines)
            end
            local function saveData()
                pcall(function()
                    if writefile then
                        writefile(SAVE_FILE, serializeData())
                    end
                end)
            end

            local function extractJsonSection(json, section)
                local startPat = '"' .. section .. '":%s*{'
                local startPos = json:find(startPat)
                if not startPos then return "" end
                local braceStart = json:find('{', startPos)
                if not braceStart then return "" end
                local depth = 0
                local i = braceStart
                while i <= #json do
                    local ch = json:sub(i, i)
                    if ch == '{' then
                        depth = depth + 1
                    elseif ch == '}' then
                        depth = depth - 1
                        if depth == 0 then
                            return json:sub(braceStart + 1, i - 1)
                        end
                    end
                    i = i + 1
                end
                return ""
            end
            
            
            local function loadData()
                pcall(function()
                    if not readfile then return end
                    local ok, content = pcall(readfile, SAVE_FILE)
                    if not ok or not content or content == "" then return end
                    local settBlock = extractJsonSection(content, "settings")
                    
                    for key in pairs(settingsState) do
                        do
                            local bval = settBlock:match('"' .. key .. '":%s*(true|false)')
                            if bval then
                                settingsState[key] = bval == "true"
                            else
                                local nval = settBlock:match('"' .. key .. '":%s*([%d%.%-]+)')
                                if nval then
                                    settingsState[key] = tonumber(nval) or settingsState[key]
                                end
                            end
                        end
                    end
                    local kbBlock = extractJsonSection(content, "keybinds")
                    if kbBlock and kbBlock ~= "" then
                        for name, data in pairs(keybinds) do
                            local keyName = kbBlock:match('"' .. name .. '":%s*"([^"]*)"')
                            if keyName and keyName ~= "None" then
                                local found = nil
                                pcall(function()
                                    found = Enum.KeyCode[keyName]
                                end)
                                if found then
                                    data.key = found
                                    if keybindLabelUpdaters[name] then
                                        pcall(function() keybindLabelUpdaters[name](found) end)
                                    end
                                end
                            elseif keyName == "None" then
                                data.key = nil
                                if keybindLabelUpdaters[name] then
                                    pcall(function() keybindLabelUpdaters[name](nil) end)
                                end
                            end
                        end
                    end
                end)
                task.defer(function()
                    if _G.settingToggleSetters then
                        for key, setFn in pairs(_G.settingToggleSetters) do
                            pcall(function() setFn(settingsState[key]) end)
                        end
                    end
                end)
            end
            local function gradStroke(p, t, tr)
                local s           = _makeDummyStroke(p)
                s.Thickness       = t or 0.9
                s.Transparency    = tr or 0.1
                s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                local g           = setmetatable({},
                    { __index = function() return function() end end, __newindex = function() end })
                g.Color           = ColorSequence.new {
                    ColorSequenceKeypoint.new(0, C.gradL),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 60, 200)),
                    ColorSequenceKeypoint.new(1, C.gradR),
                }
                g.Rotation        = 90
                return s, g
            end
            local _TI_CACHE = {}
            local function _getTI(t, sty, dir)
                local s = sty or Enum.EasingStyle.Quart
                local d = dir or Enum.EasingDirection.Out
                local k1 = _TI_CACHE[t]
                if not k1 then
                    k1 = {}; _TI_CACHE[t] = k1
                end
                local k2 = k1[s]
                if not k2 then
                    k2 = {}; k1[s] = k2
                end
                local ti = k2[d]
                if not ti then
                    ti = TweenInfo.new(t, s, d); k2[d] = ti
                end
                return ti
            end
            local function tw(obj, t, props, sty, dir)
                if typeof(obj) ~= "Instance" then return { Play = function() end, Cancel = function() end } end
                return TweenService:Create(obj, _getTI(t, sty, dir), props)
            end
            local function twP(obj, t, props, sty, dir)
                if typeof(obj) ~= "Instance" then return { Play = function() end, Cancel = function() end } end
                local tw_ = TweenService:Create(obj, _getTI(t, sty, dir), props)
                tw_:Play(); return tw_
            end
            local function twC(slot, obj, t, props, sty, dir)
                if slot.tween then pcall(function() slot.tween:Cancel() end) end
                local tween = tw(obj, t, props, sty, dir)
                slot.tween = tween
                tween:Play()
                return tween
            end
            
            
            local _hoverSoundObj = nil
            local _hoverSoundLastT = 0
            local _HOVER_SND_GAP = 0.04 
            pcall(function()
                _hoverSoundObj                    = _tlTrackInst(Instance.new("Sound"))
                _hoverSoundObj.SoundId            = "rbxassetid://139800881181209"
                _hoverSoundObj.Volume             = 0.5
                _hoverSoundObj.RollOffMaxDistance = 10000
                _hoverSoundObj.Name               = "HoverSound"
                return
            end)
            _sc._playHoverSound = function()
                if _sc._draggingSlider then return end
                if not settingsState.menuSounds then return end
                local now = tick()
                if now - _hoverSoundLastT < _HOVER_SND_GAP then return end
                _hoverSoundLastT = now
                pcall(function()
                    if not _hoverSoundObj then return end
                    local s = _hoverSoundObj:Clone()
                    s.Parent = _SvcSnd
                    s.Volume = 0.5
                    s:Play()
                    _SvcDeb:AddItem(s, 3)
                end)
            end
            local function _themePanelColor(col, fallback)
                
                if col == "accent" then return C.accent end
                if col == "accent2" then return C.accent2 end
                if col == "sub" then return C.sub end

                local base = fallback or C.accent or C.text
                if typeof(col) ~= "Color3" then return base end
                
                if col == C.orange or col == C.red or col == C.green or col == C.accent or col == C.accent2 then
                    return col
                end
                return col
            end

            
            local function _scriptCatAccent(baseCol)
                local ta = C.accent or Color3.fromRGB(0, 255, 140)
                if typeof(baseCol) ~= "Color3" then return ta end
                return baseCol:Lerp(ta, 0.38)
            end

            local function cleanRow(parent, yPos, label, sublabel, col, initOn, onToggle)
                local ROW_H = 46
                local card = Instance.new("Frame", parent)
                card.Size = UDim2.new(1, 0, 0, ROW_H)
                card.Position = UDim2.new(0, 0, 0, yPos)
                card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                card.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                0.45 or 0.15; card.BorderSizePixel = 0
                corner(card, 12)
                local cStr = _makeDummyStroke(card)
                cStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                1.5 or 1
                cStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                cStr.Transparency = 0.3
                local cdot = Instance.new("Frame", card)
                cdot.Size = UDim2.new(0, 3, 0, ROW_H - 16); cdot.Visible = false
                cdot.Position = UDim2.new(0, 0, 0.5, -(ROW_H - 16) / 2)
                cdot.BackgroundColor3 = _themePanelColor(col, C.accent); cdot.BackgroundTransparency = 0.4
                cdot.BorderSizePixel = 0; corner(cdot, 99)
                local nameLbl = Instance.new("TextLabel", card)
                nameLbl.Size = UDim2.new(1, -60, 0, 18); nameLbl.Position = UDim2.new(0, 14, 0, sublabel and 6 or 14)
                nameLbl.BackgroundTransparency = 1; nameLbl.Text = label
                nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 13
                nameLbl.TextColor3 = C.text or _C3_TEXT3
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                if sublabel then
                    local subLbl = Instance.new("TextLabel", card)
                    subLbl.Size = UDim2.new(1, -60, 0, 13); subLbl.Position = UDim2.new(0, 14, 0, 24)
                    subLbl.BackgroundTransparency = 1; subLbl.Text = sublabel
                    subLbl.Font = Enum.Font.GothamBold; subLbl.TextSize = 9
                    subLbl.TextColor3 = C.sub or _C3_SUB
                    subLbl.TextXAlignment = Enum.TextXAlignment.Left
                end
                local togTrack = Instance.new("Frame", card)
                togTrack.Size = UDim2.new(0, 32, 0, 18); togTrack.Position = UDim2.new(1, -46, 0.5, -9)
                togTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3
                togTrack.BackgroundTransparency = 0.2; togTrack.BorderSizePixel = 0; corner(togTrack, 99)
                local togKnob = Instance.new("Frame", togTrack)
                togKnob.Size = UDim2.new(0, 12, 0, 12)
                togKnob.Position = initOn and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                togKnob.BackgroundColor3 = initOn and _C3_WHITE or _C3_SUB2
                togKnob.BackgroundTransparency = 0; togKnob.BorderSizePixel = 0; corner(togKnob, 99)
                if initOn then
                    togTrack.BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255); togTrack.BackgroundTransparency = 0.55
                    cStr.Color = C.accent; cStr.Transparency = 0.5
                end
                local togState = initOn or false
                local function setToggle(on, suppressCallback)
                    togState = on
                    local activeCol = C
                    .accent 
                    if on then
                        twP(togTrack, 0.15, { BackgroundColor3 = activeCol, BackgroundTransparency = 0.55 })
                        twP(togKnob, 0.15, { BackgroundColor3 = _C3_WHITE, Position = UDim2.new(1, -14, 0.5, -6) })
                        twP(cStr, 0.15, { Color = activeCol, Transparency = 0.5 })
                        
                        pcall(function()
                            local sound = Instance.new("Sound")
                            sound.SoundId = "rbxassetid://127366656618533"
                            sound.Volume = 0.5
                            sound.Parent = workspace
                            sound:Play()
                            _SvcDeb:AddItem(sound, 2)
                        end)
                    else
                        twP(togTrack, 0.15, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3, BackgroundTransparency = 0.2 })
                        twP(togKnob, 0.15, { BackgroundColor3 = _C3_SUB2, Position = UDim2.new(0, 2, 0.5, -6) })
                        twP(cStr, 0.15,
                            { Color = _TL_isImgTheme(_TL_activeThemeId) and
                            Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3), Transparency = 0.3 })
                    end
                    if not suppressCallback and onToggle then pcall(onToggle, on) end
                end
                local function setToggleVisual(on)
                    
                    local activeCol = C.accent
                    if on then
                        twP(togTrack, 0.15, { BackgroundColor3 = activeCol, BackgroundTransparency = 0.55 })
                        twP(togKnob, 0.15, { BackgroundColor3 = _C3_WHITE, Position = UDim2.new(1, -14, 0.5, -6) })
                        twP(cStr, 0.15, { Color = activeCol, Transparency = 0.5 })
                    else
                        twP(togTrack, 0.15, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3, BackgroundTransparency = 0.2 })
                        twP(togKnob, 0.15, { BackgroundColor3 = _C3_SUB2, Position = UDim2.new(0, 2, 0.5, -6) })
                        twP(cStr, 0.15,
                            { Color = _TL_isImgTheme(_TL_activeThemeId) and
                            Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3), Transparency = 0.3 })
                    end
                end
                local btn = Instance.new("TextButton", card)
                btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 6
                local _togDebounceA = false
                local _startPosCR = nil
                btn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch then _startPosCR = inp.Position end
                end)
                btn.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch and _startPosCR then
                        local dist = (inp.Position - _startPosCR).Magnitude
                        _startPosCR = nil
                        if dist < 8 then
                            if _togDebounceA then return end
                            _togDebounceA = true
                            setToggle(not togState)
                            task.delay(0.3, function() _togDebounceA = false end)
                        end
                    end
                end)
                btn.MouseButton1Click:Connect(function()
                    if not _togDebounceA then setToggle(not togState) end
                end)
                btn.MouseEnter:Connect(function()
                    if (isMobile() == true) then return end
                    _sc._playHoverSound()
                    twP(card, 0.08, {
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                        0.3 or 0.08
                    })
                end)
                btn.MouseLeave:Connect(function()
                    twP(card, 0.08, {
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                        0.45 or 0.15
                    })
                end)

                _panelColorHooks[#_panelColorHooks + 1] = function()
                    pcall(function()
                        card.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        card.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                        0.45 or 0.15
                        
                        nameLbl.TextColor3 = C.text or _C3_TEXT3
                        if sublabel then pcall(function()
                            for _, ch in ipairs(card:GetChildren()) do
                                if ch:IsA("TextLabel") and ch.TextSize == 9 then ch.TextColor3 = C.sub or _C3_SUB end
                            end
                        end) end
                        if not togState then
                            cStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                            Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                            cStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                            1.5 or 1
                            cStr.Transparency = 0.3
                            togTrack.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG3
                            togKnob.BackgroundColor3 = _C3_SUB2
                        else
                            cStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                            Color3.fromRGB(255, 255, 255) or C.accent
                            cStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                            1.5 or 1
                            cStr.Transparency = 0.5
                        end
                    end)
                end

                return card, setToggle, function() return togState end, setToggleVisual
            end
            local function makeToggle(parent, x, y, initState, onChange)
                local W, H             = 44, 24
                local track            = Instance.new("Frame", parent)
                track.Size             = UDim2.new(0, W, 0, H)
                track.Position         = UDim2.new(0, x, 0, y)
                track.BackgroundColor3 = initState and C.accent or C.bg3
                track.BorderSizePixel  = 0
                corner(track, 16)
                local ts              = stroke(track, 1, initState and C.accent or C.borderdim, initState and 0.0 or 0.3)
                local knob            = Instance.new("Frame", track)
                knob.Size             = UDim2.new(0, H - 6, 0, H - 6)
                knob.Position         = initState
                    and UDim2.new(0, W - (H - 6) - 3, 0, 3)
                    or UDim2.new(0, 3, 0, 3)
                knob.BackgroundColor3 = _C3_WHITE
                knob.BorderSizePixel  = 0
                corner(knob, 99)
                local ks = _makeDummyStroke(knob)
                ks.Thickness = 0.8; ks.Color = _C3_BLACK; ks.Transparency = 0.5
                local state = initState
                local function setState(on)
                    state = on
                    tw(knob, 0.20, {
                        Position = on and UDim2.new(0, W - (H - 6) - 3, 0, 3)
                            or UDim2.new(0, 3, 0, 3)
                    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                    twP(track, 0.18, { BackgroundColor3 = on and C.accent or C.bg3 })
                    tw(ts, 0.18, {
                        Color        = on and C.accent or C.borderdim,
                        Transparency = on and 0.0 or 0.3,
                    }):Play()
                    if onChange then onChange(on) end
                end
                local btn = Instance.new("TextButton", track)
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.ZIndex = knob.ZIndex + 2
                btn.MouseButton1Click:Connect(function()
                    local turningOn = not state
                    setState(turningOn)
                    if turningOn then
                        pcall(function()
                            local SoundService = _SvcSnd
                            local s = Instance.new("Sound")
                            s.SoundId = "rbxassetid://79062163283657"
                            s.Volume = 0.6
                            s.Parent = SoundService
                            s:Play()
                            _SvcDeb:AddItem(s, 5)
                        end)
                    end
                end)
                local _startPosT = nil
                btn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch then
                        _startPosT = inp.Position
                    end
                end)
                btn.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.Touch and _startPosT then
                        local dist = (inp.Position - _startPosT).Magnitude
                        _startPosT = nil
                        if dist < 8 then
                            local turningOn = not state
                            setState(turningOn)
                            if turningOn then
                                pcall(function()
                                    local SoundService = _SvcSnd
                                    local s = Instance.new("Sound")
                                    s.SoundId = "rbxassetid://79062163283657"
                                    s.Volume = 0.6; s.Parent = SoundService; s:Play()
                                    _SvcDeb:AddItem(s, 5)
                                end)
                            end
                        end
                    end
                end)
                return track, setState, function() return state end
            end
            
            local _TL_VP = {}
            do
                local _ok, _vp = pcall(function() return workspace.CurrentCamera.ViewportSize end)
                _vp            = _ok and _vp or Vector2.new(1920, 1080)
                local _uis     = _SvcUIS
                local _touch   = pcall(function() return _uis.TouchEnabled end) and _uis.TouchEnabled
                local _kbd     = pcall(function() return _uis.KeyboardEnabled end) and _uis.KeyboardEnabled
                local _short   = math.min(_vp.X, _vp.Y)
                local _long    = math.max(_vp.X, _vp.Y)
                local _isMob   = _touch and not _kbd and _short < 500
                local _isTab   = _touch and not _kbd and _short >= 500 and _short < 900
                local _isTch   = _touch and not _kbd

                
                
                local _pnlW
                if _isTch then
                    local _vlWEst = _isMob and 72 or 66 
                    local _avail  = _long - _vlWEst - 5 - 8 - 8
                    if _isMob then
                        _pnlW = math.floor(math.clamp(_avail, 220, 360))
                    else
                        _pnlW = math.floor(math.clamp(_avail, 280, 430))
                    end
                else
                    _pnlW = 430
                end

                
                
                
                local _mobScl = 1.0
                if _isMob then
                    _mobScl = math.clamp(_short / 667, 0.50, 0.72)
                elseif _isTab then
                    _mobScl = math.clamp(_short / 900, 0.72, 0.88)
                end

                
                
                local _refW, _refH = 1920, 1080
                local _guiScale = math.clamp(math.min(_vp.X / _refW, _vp.Y / _refH), 0.55, 1.15)

                _TL_VP.isMob     = _isMob
                _TL_VP.isTab     = _isTab
                _TL_VP.isTouch   = _isTch
                _TL_VP.short     = _short
                _TL_VP.long      = _long
                _TL_VP.pnlW      = _pnlW
                _TL_VP.fwW       = 288
                _TL_VP.fwH       = 34
                _TL_VP.mobScl    = 1.0  
                _TL_VP.guiScale  = _guiScale
            end

            
            local PANEL_W               = _TL_VP.pnlW
            local HOME_PANEL_W_OVERRIDE = nil
            panels, panelCreditGrads    = {}, {}
            local _panelTweens          = {} 
            
            local P_MG                  = C.accent 
            local P_MGA                 = C.accent2 
            local P_MGDIM               = C.sub 
            local function _TL_shadeRGB(c, m)
                return Color3.fromRGB(
                    math.clamp(math.floor(c.R * 255 * m), 0, 255),
                    math.clamp(math.floor(c.G * 255 * m), 0, 255),
                    math.clamp(math.floor(c.B * 255 * m), 0, 255))
            end
            local function _TL_computePanelSurfaceGradients(themeId)
                if themeId == "matrix" then
                    return {
                        hdr = ColorSequence.new {
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 22, 10)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(3, 15, 7)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 10, 4)),
                        },
                        body = ColorSequence.new {
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 18, 9)),
                            ColorSequenceKeypoint.new(0.18, Color3.fromRGB(3, 11, 5)),
                            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(1, 7, 3)),
                            ColorSequenceKeypoint.new(1, C.bg or Color3.fromRGB(15, 15, 20)),
                        },
                        cg = ColorSequence.new {
                            ColorSequenceKeypoint.new(0, C.accent),
                            ColorSequenceKeypoint.new(1, C.panelBg),
                        },
                    }
                end
                local pb = C.panelBg or C.bg
                local ph = C.panelHdr or C.bg2
                return {
                    hdr = ColorSequence.new {
                        ColorSequenceKeypoint.new(0, _TL_shadeRGB(ph, 1.12)),
                        ColorSequenceKeypoint.new(0.5, ph),
                        ColorSequenceKeypoint.new(1, _TL_shadeRGB(ph, 0.82)),
                    },
                    body = ColorSequence.new {
                        ColorSequenceKeypoint.new(0, _TL_shadeRGB(pb, 1.08)),
                        ColorSequenceKeypoint.new(0.18, _TL_shadeRGB(pb, 1.0)),
                        ColorSequenceKeypoint.new(0.55, _TL_shadeRGB(pb, 0.9)),
                        ColorSequenceKeypoint.new(1, _TL_shadeRGB(pb, 0.78)),
                    },
                    cg = ColorSequence.new {
                        ColorSequenceKeypoint.new(0, C.accent),
                        ColorSequenceKeypoint.new(1, pb),
                    },
                }
            end
            
            local _panelAccentObjs = {} 
            _panelColorHooks[#_panelColorHooks + 1] = function(newT)
                P_MG       = newT.accent
                P_MGA      = newT.accent2
                P_MGDIM    = newT.sub
                local surf = _TL_computePanelSurfaceGradients(newT.id)
                
                for _, r in ipairs(_panelAccentObjs) do
                    pcall(function()
                        if r.stroke then r.stroke.Color = newT.accent end
                        if r.top then r.top.BackgroundColor3 = newT.accent end
                        if r.sep then r.sep.BackgroundColor3 = newT.accent end
                        if r.rain then r.rain.TextColor3 = newT.accent end
                        if r.dot then r.dot.BackgroundColor3 = newT.accent end
                        if r.title then r.title.TextColor3 = newT.accent end
                        if r.scan then r.scan.TextColor3 = newT.accent end
                        if r.ib then r.ib.Color = newT.accent end
                        if r.sbt then r.sbt.BackgroundColor3 = newT.accent end
                        if r.sbth then r.sbth.BackgroundColor3 = newT.accent end
                        if r.cgrad then
                            r.cgrad.Color = ColorSequence.new {
                                ColorSequenceKeypoint.new(0, newT.sub),
                                ColorSequenceKeypoint.new(0.30, newT.sub),
                                ColorSequenceKeypoint.new(0.50, newT.accent2),
                                ColorSequenceKeypoint.new(0.70, newT.sub),
                                ColorSequenceKeypoint.new(1, newT.sub),
                            }
                        end
                        if r.pf and r.pf.Parent then r.pf.BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) end
                        if r.hdrf and r.hdrf.Parent then r.hdrf.BackgroundColor3 = C.panelHdr or Color3.fromRGB(26, 26, 28) end
                        if r.hdrCut and r.hdrCut.Parent then r.hdrCut.BackgroundColor3 = C.panelHdr or Color3.fromRGB(26, 26, 28) end
                        if r.bodyGrad and surf.body then r.bodyGrad.Color = surf.body end
                        if r.hdrGrad and surf.hdr then r.hdrGrad.Color = surf.hdr end
                        if r.cgGrad and surf.cg then r.cgGrad.Color = surf.cg end
                    end)
                end
            end

            local function makePanel(name, accentDot)
                local p            = Instance.new("Frame", ScreenGui)
                p.Name             = name
                p.Size             = UDim2.new(0, PANEL_W, 0, 10)
                p.AnchorPoint      = Vector2.new(0, 0)
                p.Position         = UDim2.new(0, 61, 0, -(600))
                p.Visible          = false
                p.ClipsDescendants = true
                stylePanelSurface(p, 12, 0)

                

                
                local pStroke           = _makeDummyStroke(p)
                pStroke.Thickness       = 1
                pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                pStroke.Color           = C.bg3 or Color3.fromRGB(45, 45, 45)
                pStroke.Transparency    = 0

                
                local hdr               = Instance.new("Frame", p)
                hdr.Size                = UDim2.new(1, 0, 0, 48)
                hdr.BackgroundColor3    = Color3.fromRGB(0, 0, 0)
                hdr.BackgroundTransparency = 0.2
                hdr.BorderSizePixel     = 0; hdr.ZIndex = 2
                corner(hdr, 12)
                gradient(hdr, 90, Color3.fromRGB(5, 5, 5), Color3.fromRGB(0, 0, 0))

                
                local hdrCut                  = Instance.new("Frame", hdr)
                hdrCut.Size                   = UDim2.new(1, 0, 0, 12); hdrCut.Position = UDim2.new(0, 0, 1, -12)
                hdrCut.BackgroundColor3       = Color3.fromRGB(0, 0, 0); hdrCut.BackgroundTransparency = 0.2; hdrCut.BorderSizePixel = 0; hdrCut.ZIndex = 2

                
                local sep                     = Instance.new("Frame", p)
                sep.Size                      = UDim2.new(1, 0, 0, 1)
                sep.Position                  = UDim2.new(0, 0, 0, 48)
                sep.BackgroundColor3          = C.accent
                sep.BackgroundTransparency    = 0.4
                sep.BorderSizePixel           = 0; sep.ZIndex = 3

                
                local htitle                  = Instance.new("TextLabel", hdr)
                htitle.Size                   = UDim2.new(1, -165, 1, 0)
                htitle.Position               = UDim2.new(0, 16, 0, 0)
                htitle.BackgroundTransparency = 1
                htitle.Text                   = name:upper()
                htitle.Font                   = Enum.Font.GothamBold
                htitle.TextSize               = 15
                htitle.TextColor3             = C.text
                htitle.TextXAlignment         = Enum.TextXAlignment.Left
                htitle.ZIndex                 = 5

                
                local credit                  = Instance.new("TextLabel", hdr)
                credit.Size                   = UDim2.new(0, 100, 1, 0)
                credit.Position               = UDim2.new(1, -135, 0, 0)
                credit.BackgroundTransparency = 1
                credit.Text                   = "telelumi"
                credit.Font                   = Enum.Font.GothamBold
                credit.TextSize               = 11
                credit.TextColor3             = C.sub
                credit.TextXAlignment         = Enum.TextXAlignment.Right
                credit.ZIndex                 = 5
                
                
                
                local scroll                  = Instance.new("ScrollingFrame", p)
                scroll.Name                   = "Content"
                scroll.Size                   = UDim2.new(1, -12, 1, -58)
                scroll.Position               = UDim2.new(0, 6, 0, 54)
                scroll.BackgroundTransparency = 1
                scroll.BorderSizePixel        = 0
                scroll.ClipsDescendants       = true
                scroll.ScrollBarThickness     = 0
                scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
                scroll.ScrollingDirection     = Enum.ScrollingDirection.Y
                scroll.ElasticBehavior        = Enum.ElasticBehavior.Never
                scroll.Active                 = true
                scroll.ScrollingEnabled       = true
                if _TL_VP.isTouch then
                    scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = C.accent
                    scroll.ScrollBarImageColor3 = C.accent
                end
                
                local sbTrack                  = Instance.new("Frame", p)
                sbTrack.Name                   = "ScrollTrack"
                sbTrack.Size                   = UDim2.new(0, 4, 1, -66)
                sbTrack.Position               = UDim2.new(1, -8, 0, 58)
                sbTrack.BackgroundColor3       = C.bg3
                sbTrack.BackgroundTransparency = 0.4
                sbTrack.BorderSizePixel        = 0
                sbTrack.Visible                = false
                corner(sbTrack, 99)
                local sbThumb                  = Instance.new("Frame", sbTrack)
                sbThumb.BackgroundColor3       = C.accent
                sbThumb.BackgroundTransparency = 0
                sbThumb.BorderSizePixel        = 0
                sbThumb.Size                   = UDim2.new(1, 0, 0, 30)
                sbThumb.Position               = UDim2.new(0, 0, 0, 0)
                corner(sbThumb, 99)
                local function updateScrollbar()
                    local canvasH = scroll.CanvasSize.Y.Offset
                    local frameH  = scroll.AbsoluteSize.Y
                    local trackH  = sbTrack.AbsoluteSize.Y
                    if canvasH <= frameH or frameH <= 0 or trackH <= 0 then
                        sbTrack.Visible = false
                        return
                    end
                    sbTrack.Visible  = true
                    local ratio      = frameH / canvasH
                    local thumbH     = math.max(20, trackH * ratio)
                    local maxScroll  = canvasH - frameH
                    local thumbY     = 0
                    if maxScroll > 0 then
                        thumbY = math.clamp(
                            (scroll.CanvasPosition.Y / maxScroll) * (trackH - thumbH),
                            0, math.max(0, trackH - thumbH)
                        )
                    end
                    sbThumb.Size     = UDim2.new(1, 0, 0, thumbH)
                    sbThumb.Position = UDim2.new(0, 0, 0, thumbY)
                end
                pcall(function() scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateScrollbar) end)
                pcall(function() scroll:GetPropertyChangedSignal("CanvasSize"):Connect(updateScrollbar) end)

                
                do
                    local dragging = false
                    local startY, startScrollY
                    sbThumb.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            startY = input.Position.Y
                            startScrollY = scroll.CanvasPosition.Y
                            pcall(function() TweenService:Create(sbThumb, TweenInfo.new(0.2),
                                    { BackgroundTransparency = 0.15 }):Play() end)
                        end
                    end)
                    _SvcUIS.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local delta = input.Position.Y - startY
                            local canvasH = scroll.CanvasSize.Y.Offset
                            local frameH = scroll.AbsoluteSize.Y
                            local trackH = sbTrack.AbsoluteSize.Y
                            local thumbH = sbThumb.AbsoluteSize.Y
                            if canvasH > frameH then
                                local scrollDelta = (delta / (trackH - thumbH)) * (canvasH - frameH)
                                scroll.CanvasPosition = Vector2.new(0,
                                    math.clamp(startScrollY + scrollDelta, 0, canvasH - frameH))
                            end
                        end
                    end)
                    _SvcUIS.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            dragging = false
                            pcall(function() TweenService:Create(sbThumb, TweenInfo.new(0.2),
                                    { BackgroundTransparency = 0 }):Play() end)
                        end
                    end)
                end
                local function autoCanvas()
                    local maxY = 0
                    for _, ch in ipairs(scroll:GetChildren()) do
                        if ch:IsA("GuiObject") then
                            local bottom = ch.Position.Y.Offset + ch.Size.Y.Offset
                            if bottom > maxY then maxY = bottom end
                        end
                    end
                    scroll.CanvasSize = UDim2.new(0, 0, 0, maxY + 12)
                    task.defer(updateScrollbar)
                    task.defer(updateScrollbar)
                end
                scroll.ChildAdded:Connect(function() task.defer(autoCanvas) end)
                scroll.ChildRemoved:Connect(function() task.defer(autoCanvas) end)

                

                panels[name] = p
                
                table.insert(_panelAccentObjs, {
                    stroke = pStroke,
                    top = nil,
                    sep = sep,
                    rain = nil,
                    dot = nil,
                    title = htitle,
                    scan = nil,
                    ib = nil,
                    sbt = sbTrack,
                    sbth = sbThumb,
                    cgrad = nil,
                    pf = p,
                    hdrf = hdr,
                    hdrCut = hdrCut,
                    bodyGrad = nil,
                    hdrGrad = nil,
                    cgGrad = nil,
                })
                return p, scroll
            end
            local function setNoclip(on)
                if noclipConn then
                    noclipConn:Disconnect(); noclipConn = nil
                end
                if on then
                    noclipOrigCollide = {}
                    local ch = Character
                    noclipRebuildCache(ch)
                    if ch then
                        for _, part in ipairs(noclipCachedParts) do
                            noclipOrigCollide[part] = part.CanCollide
                        end
                    end
                    noclipConn = RunService.Heartbeat:Connect(function()
                        local parts = noclipCachedParts
                        local n = #parts
                        if n == 0 then return end
                        for i = 1, n do
                            local p = parts[i]
                            if p then p.CanCollide = false end
                        end
                    end)
                else
                    for _, part in ipairs(noclipCachedParts) do
                        if part and part.Parent then
                            if part.Name == "HumanoidRootPart" then
                                part.CanCollide = false
                            elseif noclipOrigCollide[part] ~= nil then
                                part.CanCollide = noclipOrigCollide[part]
                            else
                                part.CanCollide = true
                            end
                        end
                    end
                    noclipOrigCollide = {}
                    noclipCachedParts = {}
                end
            end
            
            
            
            
            
            local ppActive                = false
            local _act_following    = false
            local _SOH              = nil 
            local _AF               = nil 
            
            
            
            
            local invisActive = false
            local invisParts  = {}
            local invisHeartConn = nil
            local _invisHealthConn = nil
            local _invisHL = nil
            local _invisSavedCF = nil
            local _invGhostConn = nil
            _invisAnimEnabled = true
            _invisSinkEnabled = true
            local _invisRespConn = nil

            local flyActive = false
            local setFly    = nil
            local _flyMuteSounds = function() end
            local _flyPanelSetFn = nil

            flyScreenGui = _tlTrackInst(Instance.new("ScreenGui"))
            flyScreenGui.Name = "TL_FlyGui"
            flyScreenGui.ResetOnSpawn = false
            flyScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            flyScreenGui.DisplayOrder = 100
            _tryParentGui(flyScreenGui)

            
            local _invisMod = _TL_loadModule("TL-Invisible")
            if _invisMod then
                if type(_invisMod.start) == "function" then
                    setInvis = function(on)
                        invisActive = on
                        if on then _invisMod.start() else _invisMod.stop() end
                    end
                else
                    setInvis = function(on) invisActive = on; warn("[TL] Invisible module: no start/stop") end
                end
                task.defer(function()
                    if type(_invisMod.isActive) == "function" then invisActive = _invisMod.isActive() end
                end)
            else
                setInvis = function(on) invisActive = on; warn("[TL] Invisible module offline") end
            end
            local function invisSetupParts()
                if _invisMod and type(_invisMod.setupParts) == "function" then pcall(_invisMod.setupParts) end
            end

            
            local _flyMod = _TL_loadModule("TL-Fly")
            if _flyMod then
                if type(_flyMod.start) == "function" then
                    setFly = function(on)
                        flyActive = on
                        if on then _flyMod.start() else _flyMod.stop() end
                    end
                else
                    setFly = function(on) flyActive = on; warn("[TL] Fly module: no start/stop") end
                end
                _flyPanelSetFn = setFly
                task.defer(function()
                    if type(_flyMod.isActive) == "function" then flyActive = _flyMod.isActive() end
                end)
            else
                setFly = function(on) flyActive = on; warn("[TL] Fly module offline") end
                _flyPanelSetFn = setFly
            end

            local cutActive = false
            local function setCut(on)
                cutActive = on
                _TL_state.movement.cfActive = on
                if not on then
                    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
                    return
                end
                pcall(function() sendNotif("CutFucker", "Movement & Camera unlocked", 2) end)
                task.spawn(function()
                    while cutActive do
                        pcall(function() RunService.RenderStepped:Wait() end)
                        if not cutActive then break end

                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            pcall(function()
                                hum.PlatformStand = false
                                if hum.WalkSpeed < 1 then hum.WalkSpeed = 16 end
                            end)
                        end

                        local cam = workspace.CurrentCamera
                        if cam then
                            pcall(function()
                                if cam.CameraType ~= Enum.CameraType.Custom then
                                    cam.CameraType = Enum.CameraType.Custom
                                end
                                if hum and cam.CameraSubject ~= hum then
                                    cam.CameraSubject = hum
                                end
                                cam.MinDistance = 0.5
                                cam.MaxDistance = math.max(cam.MaxDistance, 128)
                                if cam.FieldOfView < 5 then cam.FieldOfView = 70 end
                                LocalPlayer.DevComputerCameraMovementMode = Enum.DevComputerCameraMovementMode
                                .UserChoice
                                LocalPlayer.DevTouchCameraMovementMode = Enum.DevTouchCameraMovementMode.UserChoice
                                _SvcUIS.MouseBehavior = Enum.MouseBehavior.Default
                                _SvcUIS.MouseIconEnabled = true
                            end)
                        end

                        pcall(function()
                            local pm = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                            if pm then
                                local controls = require(pm):GetControls()
                                if controls then controls:Enable() end
                            end
                        end)
                    end
                end)
            end

            
            
            
            noclipActive = false
            local espMod = _TL_loadModule("TL-ESP")
            espEnabled = false
            espHighlights = {}
            espBillboards = {}
            espColorIdx = 1

            local function setESP(on)
                espEnabled = on
                if espMod then espMod.start(on) end
            end

            local function refreshESPColor()
                if espMod then espMod.setColorIdx(espColorIdx); espMod.refreshColor() end
            end

            local function espCurrentColor()
                if espMod then return espMod.currentColor() end
                return Color3.fromRGB(255, 255, 255)
            end

            local ESP_COLORS = espMod and espMod.getColors() or {}

            pcall(function()
                local cachedESPColor = _loadCache("esp_color")
                if cachedESPColor and cachedESPColor.idx then
                    espColorIdx = cachedESPColor.idx
                    if espMod then espMod.setColorIdx(espColorIdx) end
                end
            end)

            _activeNotifs = {}
            local notifArea = nil

                        
            
            
sendNotif = function(title, text, dur, accentOverride)
                if not settingsState.notifications then return end

                if not notifArea then
                    notifArea = Instance.new("Frame", flyScreenGui)
                    notifArea.Name = "TL_NotifArea"
                    notifArea.Size = UDim2.new(0, 300, 1, -60)
                    notifArea.Position = UDim2.new(1, -15, 1, -35)
                    notifArea.AnchorPoint = Vector2.new(1, 1)
                    notifArea.BackgroundTransparency = 1
                    notifArea.BorderSizePixel = 0
                    notifArea.ZIndex = 9999
                end

                local colAccent = accentOverride or C.accent or Color3.fromRGB(0, 255, 150)
                local card = Instance.new("Frame", notifArea)
                card.Name = "NotificationCard"
                card.Size = UDim2.new(1, 0, 0, 72)
                card.AnchorPoint = Vector2.new(0, 1)
                card.Position = UDim2.new(1.5, 0, 1, -(#_activeNotifs * 80))
                card.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
                card.BackgroundTransparency = 0.02
                card.BorderSizePixel = 0
                card.ZIndex = 10000
                card.ClipsDescendants = true
                corner(card, 12)

                
                local shadow = Instance.new("ImageLabel", card)
                shadow.Name = "Shadow"
                shadow.AnchorPoint = Vector2.new(0.5, 0.5)
                shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
                shadow.Size = UDim2.new(1, 0, 1, 0)
                shadow.BackgroundTransparency = 1
                shadow.Image = "rbxassetid://1316045217"
                shadow.ImageColor3 = colAccent
                shadow.ImageTransparency = 1
                shadow.ScaleType = Enum.ScaleType.Slice
                shadow.SliceCenter = Rect.new(15, 15, 113, 113)
                shadow.ZIndex = card.ZIndex - 1

                
                local stroke = _makeDummyStroke(card)
                stroke.Thickness = 1.2
                stroke.Color = colAccent
                stroke.Transparency = 0.6

                local accBar = Instance.new("Frame", card)
                accBar.Size = UDim2.new(0, 4, 1, -24)
                accBar.Position = UDim2.new(0, 10, 0, 12)
                accBar.BackgroundColor3 = colAccent
                accBar.BorderSizePixel = 0
                corner(accBar, 4)

                local titleLbl = Instance.new("TextLabel", card)
                titleLbl.Size = UDim2.new(1, -50, 0, 20)
                titleLbl.Position = UDim2.new(0, 24, 0, 12)
                titleLbl.Text = "<b><font color=\"#" ..
                colAccent:ToHex() .. "\">◈</font></b>  " .. tostring(title or "SYSTEM"):upper()
                titleLbl.RichText = true
                titleLbl.Font = Enum.Font.GothamBold
                titleLbl.TextSize = 12
                titleLbl.TextColor3 = C.text
                titleLbl.TextXAlignment = Enum.TextXAlignment.Left
                titleLbl.BackgroundTransparency = 1
                titleLbl.ZIndex = 10001

                local bodyLbl = Instance.new("TextLabel", card)
                bodyLbl.Size = UDim2.new(1, -44, 1, -42)
                bodyLbl.Position = UDim2.new(0, 24, 0, 32)
                bodyLbl.Text = tostring(text or "")
                bodyLbl.Font = Enum.Font.GothamMedium
                bodyLbl.TextSize = 11
                bodyLbl.TextColor3 = C.sub
                bodyLbl.TextXAlignment = Enum.TextXAlignment.Left
                bodyLbl.TextYAlignment = Enum.TextYAlignment.Top
                bodyLbl.TextWrapped = true
                bodyLbl.BackgroundTransparency = 1
                bodyLbl.ZIndex = 10001

                local pWrap = Instance.new("Frame", card)
                pWrap.Size = UDim2.new(1, -40, 0, 2)
                pWrap.Position = UDim2.new(0, 24, 1, -10)
                pWrap.BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38)
                pWrap.BackgroundTransparency = 0.8
                pWrap.BorderSizePixel = 0
                corner(pWrap, 4)

                local pBar = Instance.new("Frame", pWrap)
                pBar.Size = UDim2.new(1, 0, 1, 0)
                pBar.BackgroundColor3 = colAccent
                pBar.BorderSizePixel = 0
                corner(pBar, 4)

                table.insert(_activeNotifs, card)

                pcall(function() if _sc._playHoverSound then _sc._playHoverSound() end end)
                tw(card, 0.6, { Position = UDim2.new(0, 0, 1, card.Position.Y.Offset) }, Enum.EasingStyle.Back,
                    Enum.EasingDirection.Out):Play()

                task.spawn(function()
                    local d = dur or 5
                    tw(pBar, d, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear):Play()
                    task.wait(d)

                    local out = tw(card, 0.4, { Position = UDim2.new(1.6, 0, 1, card.Position.Y.Offset) },
                        Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                    out:Play()
                    out.Completed:Wait()

                    for i, v in ipairs(_activeNotifs) do
                        if v == card then
                            table.remove(_activeNotifs, i); break
                        end
                    end
                    card:Destroy()

                    
                    for i, v in ipairs(_activeNotifs) do
                        tw(v, 0.4, { Position = UDim2.new(0, 0, 1, -((i - 1) * 80)) }, Enum.EasingStyle.Quart,
                            Enum.EasingDirection.Out):Play()
                    end
                end)
            end

            _genv.TLSendNotif = sendNotif
            -- Dynamic Tab Modules Loader (loaded from Tab-Moduls/)
            local ctx = {
                game = game,
                _genv = _genv,
                ScreenGui = ScreenGui,
                makePanel = makePanel,
                C = C,
                PANEL_W = PANEL_W,
                _sc = _sc,
                _TL_refs = _TL_refs,
                _TL_loadModule = _TL_loadModule,
                _TL_VP = _TL_VP,
            }

            -- 1. Home Tab
            local homeMod = _TL_loadModule("HomeTab")
            local p, _homeSc
            if homeMod and type(homeMod.Init) == "function" then
                p, _homeSc = homeMod.Init(ctx)
    local _ENUM_SORT_ORDER_LAYOUT = ctx._ENUM_SORT_ORDER_LAYOUT or (Enum and Enum.SortOrder and Enum.SortOrder.LayoutOrder) or 0

            end

            -- 2. Character Tab
            local charMod = _TL_loadModule("CharacterTab")
            if charMod and type(charMod.Init) == "function" then
                charMod.Init(ctx)
            end

            -- 3. Scripts Tab
            local scriptsMod = _TL_loadModule("ScriptsTab")
            if scriptsMod and type(scriptsMod.Init) == "function" then
                scriptsMod.Init(ctx)
            end

            -- 4. Actions Tab
            local actionsMod = _TL_loadModule("ActionsTab")
            if actionsMod and type(actionsMod.Init) == "function" then
                actionsMod.Init(ctx)
            end

            -- 5. Settings Tab
            local settingsMod = _TL_loadModule("SettingsTab")
            if settingsMod and type(settingsMod.Init) == "function" then
                settingsMod.Init(ctx)
            end

            -- 6. Communication Tab
            local commMod = _TL_loadModule("CommunicationTab")
            if commMod and type(commMod.Init) == "function" then
                commMod.Init(ctx)
            end

            -- 7. Playerlist Tab
            local plMod = _TL_loadModule("PlayerlistTab")
            if plMod and type(plMod.Init) == "function" then
                plMod.Init(ctx)
            end

                
                
                
                local nametagPage
                nametagPage = (function()
                    local _ok_ntPage = pcall(function()
                        nametagPage                        = Instance.new("Frame", subArea)
                        nametagPage.BackgroundTransparency = 1; nametagPage.BorderSizePixel = 0
                        nametagPage.Visible                = false
                        nametagPage.Size                   = UDim2.new(1, 0, 0, 168)

                        local _, ntVisSet = subRow(nametagPage, 0, "Nametag sichtbar", "Sichtbar für andere Spieler", C.accent,
                            settingsState.nametagVisible, function(on)
                            settingsState.nametagVisible = on
                            task.spawn(saveData)
                            BroadcastNametagVisibility()
                        end)
                        settingToggleSetters["nametagVisible"] = ntVisSet

                        local _, ntRemSet = subRow(nametagPage, 54, "Remove Nametag", "Removes nametag above your head", C.accent,
                            settingsState.removeNametag, function(on)
                            settingsState.removeNametag = on
                            task.spawn(saveData)
                            
                            pcall(function()
                                local myChar = LocalPlayer.Character
                                if myChar then
                                    local tag = CoreGui:FindFirstChild("CovertPeerTag_" .. LocalPlayer.Name)
                                    if on and tag then
                                        tag:Destroy()
                                    elseif not on then
                                        local head = myChar:FindFirstChild("Head")
                                        if head and not creatingNametag[LocalPlayer.Name] then
                                            local isAdm = IsLocalAdmin
                                            task.spawn(CreateCustomNametag, myChar, LocalPlayer.Name, isAdm)
                                        end
                                    end
                                end
                            end)
                        end)
                        settingToggleSetters["removeNametag"] = ntRemSet
                    end)
                    return nametagPage
                end)

                subPages = { General = genPage, Keybinds = kbPage, Colors = colorsPage, Theme = themePage, ["C-CURSOR"] =
                visualSettingsPage, Music = musicPage, Nametag = nametagPage }

                
                function _updateSubAreaCanvas()
                    if not _settingsPanel or not _settingsScroll then return end
                    local subH                 = subArea.Size.Y.Offset
                    local totalH               = (CARD_H_S + 12) + subH + 8
                    local newPH                = math.min(SET_BASE_H + math.max(subH, 0), SET_MAX_H)
                    _settingsPanel.Size        = UDim2.new(0, PANEL_W, 0, newPH)
                    local scrollH              = newPH - SET_HDR_H
                    _settingsScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(totalH, scrollH))
                end

                switchCat = function(id)
                    for _, pg in pairs(subPages) do pg.Visible = false end
                    for _, cb in ipairs(catBtns) do
                        twP(cb.card, 0.15, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2 })
                        twP(cb.lbl, 0.15, { TextColor3 = C.sub or _C3_SUB })
                        cb.cStr.Color = C.bg3 or _C3_BG3; cb.cStr.Transparency = 0.3
                        cb.selBar.Visible = false
                        
                        if cb.iconRef then
                            pcall(function()
                                if not cb.iconRef:IsA("ImageLabel") then
                                    twP(cb.iconRef, 0.15, { TextColor3 = C.sub or _C3_SUB })
                                end
                            end)
                        end
                    end
                    if activeCat == id then
                        activeCat = nil
                        tw(subArea, 0.18, { Size = UDim2.new(1, 0, 0, 0) },
                            Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
                        if _settingsPanel then
                            tw(_settingsPanel, 0.18, { Size = UDim2.new(0, PANEL_W, 0, SET_BASE_H) },
                                Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
                        end
                        task.delay(0.20, _updateSubAreaCanvas)
                        return
                    end
                    activeCat = id
                    local pg = subPages[id]
                    if pg then
                        pg.Visible = true
                        local pgH = pg.Size.Y.Offset
                        local newPH = math.min(SET_BASE_H + pgH + 8, SET_MAX_H)
                        tw(subArea, 0.24, { Size = UDim2.new(1, 0, 0, pgH) },
                            Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                        if _settingsPanel then
                            tw(_settingsPanel, 0.24, { Size = UDim2.new(0, PANEL_W, 0, newPH) },
                                Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                        end
                        task.delay(0.26, _updateSubAreaCanvas)
                    end
                    for _, cb in ipairs(catBtns) do
                        if cb.id == id then
                            twP(cb.card, 0.20, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG4 })
                            twP(cb.lbl, 0.20, { TextColor3 = C.text })
                            cb.cStr.Color = cb.col; cb.cStr.Transparency = 0.5
                            cb.selBar.Visible = true
                            
                            if cb.iconRef then
                                pcall(function()
                                    if not cb.iconRef:IsA("ImageLabel") then
                                        twP(cb.iconRef, 0.20, { TextColor3 = cb.col })
                                    end
                                end)
                            end
                        end
                    end
                end
            local _ok_catsLoop = pcall(function()
                for i, cat in ipairs(CATS) do
                    local xOff = (i - 1) * (CARD_W_S + CARD_GAP)
                    local card = Instance.new("Frame", grid)
                    card.Size = UDim2.new(0, CARD_W_S, 0, CARD_H_S)
                    card.Position = UDim2.new(0, xOff, 0, 0)
                    card.BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28); card.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                    1 or 0
                    card.BorderSizePixel = 0; corner(card, 12)
                    local cStr = _makeDummyStroke(card)
                    cStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                    1.5 or 1
                    cStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                    Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                    cStr.Transparency = 0.3
                    if _panelColorHooks then
                        _panelColorHooks[#_panelColorHooks + 1] = function()
                            pcall(function()
                                card.BackgroundTransparency = _TL_isImgTheme(_TL_activeThemeId) and
                                1 or 0
                                cStr.Thickness = _TL_isImgTheme(_TL_activeThemeId) and
                                1.5 or 1
                                cStr.Color = _TL_isImgTheme(_TL_activeThemeId) and
                                Color3.fromRGB(255, 255, 255) or (C.bg3 or _C3_BG3)
                                cStr.Transparency = 0.3
                            end)
                        end
                    end
                    local selBar = Instance.new("Frame", card)
                    selBar.Size = UDim2.new(1, -16, 0, 2); selBar.Position = UDim2.new(0, 8, 0, 0)
                    selBar.BackgroundColor3 = (cat and cat.col) or Color3.fromRGB(0, 170, 255); selBar.BackgroundTransparency = 0
                    selBar.BorderSizePixel = 0; selBar.Visible = false; corner(selBar, 99)
                    
                    local _iconRef = nil
                    if cat.img then
                        local _iSz                     = cat.iconSize or 28
                        local iconImg                  = Instance.new("ImageLabel", card)
                        iconImg.Size                   = UDim2.new(0, _iSz, 0, _iSz)
                        iconImg.Position               = UDim2.new(0.5, -_iSz / 2, 0, -(_iSz / 2) + 29)
                        iconImg.BackgroundTransparency = 1
                        iconImg.Image                  = cat.img
                        iconImg.ImageColor3            = Color3.fromRGB(255, 255, 255)
                        iconImg.ScaleType              = Enum.ScaleType.Fit
                        iconImg.BorderSizePixel        = 0
                        _iconRef                       = iconImg
                    else
                        local icon = Instance.new("TextLabel", card)
                        icon.Size = UDim2.new(1, 0, 0, 32); icon.Position = UDim2.new(0, 0, 0, 8)
                        icon.BackgroundTransparency = 1; icon.Text = cat.icon or ""
                        icon.Font = Enum.Font.GothamBlack; icon.TextSize = 22
                        icon.TextColor3 = Color3.fromRGB(180, 180, 180); icon.TextXAlignment = Enum.TextXAlignment
                        .Center
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
                        if activeCat ~= catId then
                            twP(card, 0.1, { BackgroundColor3 = C.bg3 or Color3.fromRGB(34, 34, 38) or _C3_BG4 })
                        end
                    end)
                    btn.MouseLeave:Connect(function()
                        if activeCat ~= catId then
                            twP(card, 0.1, { BackgroundColor3 = C.bg2 or Color3.fromRGB(26, 26, 28) or _C3_BG2 })
                        end
                    end)
                    btn.MouseButton1Click:Connect(function()
                        if _isMobile or _isTablet then return end 
                        switchCat(catId)
                    end)
                    btn.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.Touch then switchCat(catId) end
                    end)
                    table.insert(catBtns,
                        { id = catId, card = card, lbl = lbl, selBar = selBar, cStr = cStr, col = cat.col, iconRef =
                        _iconRef })
                    
                    
                    if _iconRef then
                        pcall(function()
                            if not _iconRef:IsA("ImageLabel") then
                                _iconRef.TextColor3 = C.sub or _C3_SUB
                            end
                        end)
                    end
                end
            end) 
            
            if catBtns and #catBtns > 0 then
                switchCat(catBtns[1].id)
            end
            end)
            
            
            function getNearestPlayer()
                local myRoot = getRootPart(); if not myRoot then return nil end
                local best, bestDist = nil, math.huge
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character then
                        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d = (hrp.Position - myRoot.Position).Magnitude
                            if d < bestDist then
                                bestDist = d; best = pl
                            end
                        end
                    end
                end
                return best
            end

            
            task.spawn(function()
                local _ok_SmartBar, _err_SmartBar = pcall(function()
                    local BAR_W, BAR_H, BAR_R = 514, 58, 8 

                    
                    local VL_W, VL_H, VL_GAP, VL_ICON_W, VL_ICON_H
                    do
                        local _ok, _vp = pcall(function() return workspace.CurrentCamera.ViewportSize end)
                        _vp            = _ok and _vp or Vector2.new(1920, 1080)
                        local _touch   = pcall(function() return UIS.TouchEnabled end) and UIS.TouchEnabled
                        local _kbd     = pcall(function() return UIS.KeyboardEnabled end) and UIS.KeyboardEnabled
                        local _short   = math.min(_vp.X, _vp.Y)
                        if _touch and not _kbd and _short < 500 then
                            
                            
                            local _scale = math.clamp(_short / 360, 0.7, 1.2)
                            VL_W      = math.floor(38 * _scale)
                            VL_H      = math.floor(42 * _scale)
                            VL_GAP    = math.max(3, math.floor(4 * _scale))
                            VL_ICON_W = math.floor(36 * _scale)
                            VL_ICON_H = math.floor(36 * _scale)
                        elseif _touch and not _kbd then
                            
                            
                            local _scale = math.clamp(_short / 768, 0.75, 1.3)
                            VL_W      = math.floor(49 * _scale)
                            VL_H      = math.floor(54 * _scale)
                            VL_GAP    = math.max(4, math.floor(5 * _scale))
                            VL_ICON_W = math.floor(48 * _scale)
                            VL_ICON_H = math.floor(48 * _scale)
                        else
                            
                            
                            local _scale = math.clamp(_vp.X / 1920, 0.75, 1.0)
                            VL_W      = math.floor(58 * _scale)
                            VL_H      = math.floor(65 * _scale)
                            VL_GAP    = math.max(4, math.floor(5 * _scale))
                            VL_ICON_W = math.floor(58 * _scale)
                            VL_ICON_H = math.floor(58 * _scale)
                        end
                    end 

                    
                    local _sbScale = 1.0
                    do
                        local ok, vp = pcall(function() return workspace.CurrentCamera.ViewportSize end)
                        vp           = ok and vp or Vector2.new(1920, 1080)
                        local touch  = pcall(function() return UIS.TouchEnabled end) and UIS.TouchEnabled
                        local kbd    = pcall(function() return UIS.KeyboardEnabled end) and UIS.KeyboardEnabled
                        local short  = math.min(vp.X, vp.Y)
                        local long   = math.max(vp.X, vp.Y)
                        if touch and not kbd and short < 500 then
                            _sbScale = math.clamp(long * 0.88 / BAR_W, 0.55, 1.0)
                        elseif touch and not kbd then
                            _sbScale = math.clamp(long * 0.72 / BAR_W, 0.7, 1.0)
                        elseif vp.X < 900 then
                            _sbScale = math.clamp(vp.X * 0.88 / BAR_W, 0.6, 1.0)
                        end
                    end

                    
                    local function _TL_getComTabIcon()
                        local asset = _TL_safeIsFile(comTabIconFileName) and
                        _TL_safeGetCustomAsset(comTabIconFileName) or nil
                        return asset or "rbxassetid://117318347375651"
                    end
                    local function _TL_getDefaultTabIcon(fname, fallback)
                        local asset = _TL_safeIsFile(fname) and
                        _TL_safeGetCustomAsset(fname) or nil
                        return asset or fallback
                    end
                    local tabDefs = {
                        { name = "Home",        img = _TL_getDefaultTabIcon(homeTabIconFileName,       "rbxassetid://95315124947838") },
                        { name = "Character",   img = _TL_getDefaultTabIcon(characterTabIconFileName,   "rbxassetid://130511578744559") },
                        { name = "Scripts",     img = _TL_getDefaultTabIcon(scriptsTabIconFileName,     "rbxassetid://99174931681951") },
                        { name = "Actions",     img = _TL_getDefaultTabIcon(actionsTabIconFileName,     "rbxassetid://110933969812438") },
                        { name = "Playerlist",  img = _TL_getDefaultTabIcon(playerlistTabIconFileName,  "rbxassetid://133167021592598") },
                        { name = "Settings",    img = "rbxassetid://117318347375651" },
                        { name = "Communication", img = _TL_getComTabIcon() },
                    }
                    local _TAB_CARD_W  = 62
                    local _TAB_CARD_H  = 60
                    local _TAB_GAP     = 6
                    local _TAB_BAR_PAD = 12
                    local _TOTAL_TABS  = #tabDefs
                    local _TAB_BAR_W   = _TOTAL_TABS * _TAB_CARD_W + (_TOTAL_TABS - 1) * _TAB_GAP + _TAB_BAR_PAD * 2
                    local _TAB_BAR_H   = _TAB_CARD_H + _TAB_BAR_PAD * 2
                    local PANEL_SHOW = UDim2.new(0.5, 0, 1, -_TAB_BAR_H - 22)
                    local PANEL_HIDE = UDim2.new(0.5, 0, 1, 30)

                    
                    local function getPanelXAnchor()
                        local pos = settingsState and settingsState.guiPosition or 1
                        if pos == 0 then return 0, 0, 8       
                        elseif pos == 2 then return 1, 1, -8  
                        else return 0.5, 0.5, 0 end           
                    end

                    
                    local function MG_B() return C.accent end
                    local function MGA_B() return C.accent2 end
                    local function MGDIM() return C.sub end

                    
                    local FW_W, FW_H, FW_X_OFFSET   = 284, 34, -5

                    
                    local SmartBar                  = Instance.new("Frame", ScreenGui)
                    SmartBar.Name                   = "SmartBar"
                    SmartBar.Size                   = UDim2.new(0, 1, 0, 1) 
                    SmartBar.AnchorPoint            = Vector2.new(1, 0)
                    SmartBar.Position               = UDim2.new(1, -1, 0, 0) 
                    SmartBar.BackgroundColor3       = Color3.fromRGB(10, 10, 10)
                    SmartBar.BackgroundTransparency = 1
                    SmartBar.BorderSizePixel        = 0
                    SmartBar.Visible                = true 
                    SmartBar.ZIndex                 = 8
                    SmartBar.ClipsDescendants       = false 
                    corner(SmartBar, 10)
                    

                    
                    local tlMainIcon                      = nil 
                    local tlMainBtn                       = nil

                    
                    local rainLblBar                      = nil

                    
                    
                    
                    
                    local tabCardsHolder                  = Instance.new("Frame", ScreenGui)
                    tabCardsHolder.Name                   = "TLTabCards"
                    local _tabBarInitAX, _tabBarInitXSc, _tabBarInitXOff = getPanelXAnchor()
                    tabCardsHolder.AnchorPoint            = Vector2.new(_tabBarInitAX, 1)
                    tabCardsHolder.Size                   = UDim2.new(0, _TAB_BAR_W, 0, 0)
                    tabCardsHolder.Position               = UDim2.new(_tabBarInitXSc, _tabBarInitXOff, 1, 2)
                    tabCardsHolder.BackgroundColor3       = C.panelBg or Color3.fromRGB(0, 0, 0)
                    tabCardsHolder.BackgroundTransparency = 0.2
                    tabCardsHolder.BorderSizePixel        = 0
                    tabCardsHolder.ClipsDescendants       = true
                    tabCardsHolder.Visible                = false
                    tabCardsHolder.ZIndex                 = 7
                    corner(tabCardsHolder, 12)

                    local isOpen, activeTab, _closeTok = false, nil, 0

                    local tabBtns, selectTab = {}, nil

                    
                    
                    _TL_refs._TL_applyGuiPosition = function(pos)
                        settingsState.guiPosition = pos
                        task.spawn(saveData)
                        local ax, xsc, xoff = getPanelXAnchor()
                        local newBarPos = UDim2.new(xsc, xoff, 1, 2)
                        local newPanelPos = UDim2.new(xsc, xoff, PANEL_SHOW.Y.Scale, PANEL_SHOW.Y.Offset)
                        if tabCardsHolder then
                            tabCardsHolder.AnchorPoint = Vector2.new(ax, 1)
                            tabCardsHolder.Position = newBarPos
                        end
                        if panels then
                            for name, pan in pairs(panels) do
                                if pan and pan.Visible then
                                    pan.AnchorPoint = Vector2.new(ax, 1)
                                    pan.Position = newPanelPos
                                end
                            end
                        end
                    end

                    for i, tab in ipairs(tabDefs) do
                        local xOff = _TAB_BAR_PAD + (i - 1) * (_TAB_CARD_W + _TAB_GAP)

                        
                        local card                  = Instance.new("Frame", tabCardsHolder)
                        card.Size                   = UDim2.new(0, _TAB_CARD_W, 0, _TAB_CARD_H)
                        card.Position               = UDim2.new(0, xOff, 0, _TAB_BAR_PAD)
                        card.BackgroundColor3       = C.panelBg or Color3.fromRGB(0, 0, 0)
                        card.BackgroundTransparency = 0.45
                        card.BorderSizePixel        = 0
                        card.ZIndex                 = 8
                        corner(card, 10)
                        local card_Stroke           = Instance.new("UIStroke", card)
                        card_Stroke.Thickness       = 1; card_Stroke.Color = MGDIM(); card_Stroke.Transparency = 0.82
                        card_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

                        
                        local pill                  = Instance.new("Frame", card)
                        pill.Size                   = UDim2.new(0.5, 0, 0, 3)
                        pill.Position               = UDim2.new(0.25, 0, 1, -4)
                        pill.BackgroundColor3       = MG_B()
                        pill.BackgroundTransparency = 1
                        pill.BorderSizePixel        = 0; pill.ZIndex = 10
                        corner(pill, 99)


                        local iconImg, iconLbl = nil, nil
                        local _ico             = 24
                        local _icoY            = 8
                        local _emoH            = 26
                        local _emoY            = 5
                        local _emoSz           = 20
                        if tab.img then
                            local _sz, _yPos = _ico, _icoY
                            if tab.name == "Character" then
                                _sz = 30
                                _yPos = 5
                            end
                            local _off                     = math.floor(_sz / 2)
                            iconImg                        = Instance.new("ImageLabel", card)
                            iconImg.Size                   = UDim2.new(0, _sz, 0, _sz)
                            iconImg.Position               = UDim2.new(0.5, -_off, 0, _yPos)
                            iconImg.BackgroundTransparency = 1
                            iconImg.Image                  = tab.img
                            iconImg.ImageColor3            = MGDIM()
                            iconImg.ScaleType              = Enum.ScaleType.Fit
                            iconImg.ZIndex                 = 10
                        else
                            iconLbl                        = Instance.new("TextLabel", card)
                            iconLbl.Size                   = UDim2.new(1, 0, 0, _emoH)
                            iconLbl.Position               = UDim2.new(0, 0, 0, _emoY)
                            iconLbl.BackgroundTransparency = 1
                            iconLbl.Text                   = tab.icon or ""
                            iconLbl.Font                   = Enum.Font.GothamBlack
                            iconLbl.TextSize               = _emoSz
                            iconLbl.TextColor3             = MGDIM()
                            iconLbl.TextXAlignment         = Enum.TextXAlignment.Center
                            iconLbl.ZIndex                 = 10
                        end

                        
                        local lbl                  = Instance.new("TextLabel", card)
                        lbl.Size                   = UDim2.new(1, -4, 0, 11)
                        lbl.Position               = UDim2.new(0, 2, 1, -15)
                        lbl.BackgroundTransparency = 1
                        lbl.Text                   = (tab.name == "Communication" and "COM" or tab.name:upper())
                        lbl.Font                   = Enum.Font.GothamBold
                        lbl.TextSize               = 10
                        lbl.TextScaled             = false
                        lbl.TextColor3             = Color3.fromRGB(160, 160, 170)
                        lbl.TextXAlignment         = Enum.TextXAlignment.Center
                        lbl.ZIndex                 = 10

                        
                        local btn                  = Instance.new("TextButton", card)
                        btn.Size                   = UDim2.new(1, 0, 1, 0)
                        btn.BackgroundTransparency = 1
                        btn.Text                   = ""; btn.ZIndex = 12

                        table.insert(tabBtns, {
                            name        = tab.name,
                            card        = card,
                            pill        = pill,
                            card_Stroke = card_Stroke,
                            iconLbl     = iconLbl,
                            iconImg     = iconImg,
                            lbl         = lbl,
                        })

                        btn.MouseEnter:Connect(function()
                            if _isMobile then return end
                            _sc._playHoverSound()
                            if activeTab ~= tab.name then
                                if iconImg then twP(iconImg, 0.10, { ImageColor3 = Color3.fromRGB(200, 200, 210) }) end
                                if iconLbl then twP(iconLbl, 0.10, { TextColor3 = MGA_B() }) end
                                twP(lbl, 0.10, { TextColor3 = Color3.fromRGB(220, 220, 230) })
                                if card_Stroke then twP(card_Stroke, 0.10, { Color = MG_B(), Transparency = 0.5 }) end
                            end
                        end)
                        btn.MouseLeave:Connect(function()
                            if activeTab ~= tab.name then
                                if iconImg then twP(iconImg, 0.10, { ImageColor3 = MGDIM() }) end
                                if iconLbl then twP(iconLbl, 0.10, { TextColor3 = MGDIM() }) end
                                twP(lbl, 0.10, { TextColor3 = Color3.fromRGB(160, 160, 170) })
                                if card_Stroke then twP(card_Stroke, 0.10, { Color = MGDIM(), Transparency = 0.82 }) end
                            end
                        end)
                        
                        local _tabBtnLock = false
                        local captName = tab.name
                        local function tabBtnActivate()
                            if _tabBtnLock then return end
                            _tabBtnLock = true
                            task.delay(0.35, function() _tabBtnLock = false end)
                            selectTab(captName)
                        end
                        btn.MouseButton1Click:Connect(tabBtnActivate)
                        btn.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.Touch then tabBtnActivate() end
                        end)
                    end
                    
                    _TL_refs._TL_tabBtns = tabBtns
                    
                    _TL_refs._TL_tabOrigIcons = {
                        Home       = _TL_getDefaultTabIcon(homeTabIconFileName,      "rbxassetid://95315124947838"),
                        Character  = _TL_getDefaultTabIcon(characterTabIconFileName, "rbxassetid://130511578744559"),
                        Playerlist = _TL_getDefaultTabIcon(playerlistTabIconFileName,"rbxassetid://133167021592598"),
                        Settings   = "rbxassetid://117318347375651",
                        Actions    = _TL_getDefaultTabIcon(actionsTabIconFileName,   "rbxassetid://110933969812438"),
                        Admin      = "rbxassetid://117318347375651",
                        Scripts    = _TL_getDefaultTabIcon(scriptsTabIconFileName,   "rbxassetid://99174931681951"),
                        Communication = _TL_getComTabIcon(),
                    }
                    
                    _TL_refs._TL_tabOnePieceIcons = {
                        Home       = "rbxassetid://98331541002580",
                        Character  = "rbxassetid://89458904008601",
                        Playerlist = "rbxassetid://99305081178541",
                        Settings   = "rbxassetid://104468772328182",
                        Actions    = "rbxassetid://84685771974677",
                    }
                    _TL_refs._TL_tabDragonballIcons = {
                        Home       = "rbxassetid://73282723782417",
                        Character  = "rbxassetid://75090359908318",
                        Playerlist = "rbxassetid://98892794324034",
                        
                        
                        Settings   = (function()
                            if dragonballSettingsIconFileName and _TL_safeIsFile(dragonballSettingsIconFileName) then
                                local r = _TL_safeGetCustomAsset(dragonballSettingsIconFileName)
                                if r then return r end
                            end
                            return "rbxassetid://117318347375651"
                        end)(),
                    }
                    
                    local function _TL_getCustomIcon(fname, fallback)
                        if fname and _TL_safeIsFile(fname) then
                            local r = _TL_safeGetCustomAsset(fname)
                            if r then return r end
                        end
                        return fallback
                    end
                    _TL_refs._TL_tabTheBoys_Icons = {
                        Home      = _TL_getCustomIcon(theBoysHomeIconFileName,    "rbxassetid://79298842483031"),
                        Settings  = _TL_getCustomIcon(theBoysSettingsIconFileName, "rbxassetid://83091867260863"),
                        Character = "rbxassetid://102595422414933",
                        Actions   = _TL_getCustomIcon(theBoysActionsIconFileName,  "rbxassetid://110933969812438"),
                        Scripts   = _TL_getCustomIcon(theBoysScriptsIconFileName,  "rbxassetid://99174931681951"),
                    }
                    _TL_refs._TL_getCustomIcon = _TL_getCustomIcon
                    
                    _TL_refs._TL_tabDeathNote_Icons = {
                        Home          = _TL_getCustomIcon(deathNoteHomeIconFileName,     "rbxassetid://95315124947838"),
                        Character     = _TL_getCustomIcon(deathNoteCharIconFileName,     "rbxassetid://130511578744559"),
                        Scripts       = _TL_getCustomIcon(deathNoteScriptsIconFileName,  "rbxassetid://99174931681951"),
                        Settings      = _TL_getCustomIcon(deathNoteSettingsIconFileName, "rbxassetid://117318347375651"),
                        Communication = _TL_getCustomIcon(deathNoteComIconFileName,      _TL_getComTabIcon()),
                    }
                    
                    if _TL_activeThemeId == "deathnote" then
                        pcall(function()
                            for _, tb in ipairs(tabBtns) do
                                local dnIcon = _TL_refs._TL_tabDeathNote_Icons[tb.name]
                                if dnIcon and tb.iconImg then
                                    tb.iconImg.Image = dnIcon
                                end
                            end
                        end)
                    end
                    
                    _TL_refs._TL_tabDexterIcons = {
                        Character     = _TL_getCustomIcon(dexterCharIconFileName,     "rbxassetid://130511578744559"),
                        Playerlist    = _TL_getCustomIcon(dexterPlayerlistIconFileName, "rbxassetid://133167021592598"),
                        Settings      = _TL_getCustomIcon(dexterSettingsIconFileName, "rbxassetid://117318347375651"),
                        Scripts       = _TL_getCustomIcon(dexterScriptsIconFileName,  "rbxassetid://99174931681951"),
                    }
                    
                    if _TL_activeThemeId == "dexter" then
                        pcall(function()
                            for _, tb in ipairs(tabBtns) do
                                local dxIcon = _TL_refs._TL_tabDexterIcons[tb.name]
                                if dxIcon and tb.iconImg then
                                    tb.iconImg.Image = dxIcon
                                end
                            end
                        end)
                        task.defer(function()
                            pcall(function()
                                local _dxStartupBgs = {
                                    Character     = { file = dexterCharBgFileName,     url = dexterCharBgUrl     },
                                    Communication = { file = dexterComBgFileName,        url = dexterComBgUrl        },
                                }
                                for _pname, _src in pairs(_dxStartupBgs) do
                                    local _pan = panels[_pname]
                                    if _pan then
                                        local _bg = _pan:FindFirstChild("DexterBg")
                                        if not _bg then
                                            _bg = Instance.new("ImageLabel")
                                            _bg.Name = "DexterBg"
                                            _bg.Size = UDim2.new(1, 0, 1, 0)
                                            _bg.Position = UDim2.new(0, 0, 0, 0)
                                            _bg.BackgroundTransparency = 1
                                            _bg.Image = _TL_safeGetCustomAsset(_src.file) or _src.url
                                            _bg.ScaleType = Enum.ScaleType.Crop
                                            _bg.ImageTransparency = 0.45
                                            _bg.ZIndex = 0
                                            local _c = Instance.new("UICorner")
                                            _c.CornerRadius = UDim.new(0, 12)
                                            _c.Parent = _bg
                                            _bg.Parent = _pan
                                        end
                                    end
                                end
                            end)
                        end)
                    end
                    
                    if _TL_activeThemeId == "dragonball" then
                        pcall(function()
                            
                            if dragonballSettingsIconFileName then
                                local _asset = _TL_safeGetCustomAsset(dragonballSettingsIconFileName)
                                if _asset then
                                    _TL_refs._TL_tabDragonballIcons.Settings = _asset
                                end
                            end
                            for _, tb in ipairs(tabBtns) do
                                local dbIcon = _TL_refs._TL_tabDragonballIcons[tb.name]
                                if dbIcon and tb.iconImg then
                                    tb.iconImg.Image = dbIcon
                                end
                            end
                            task.defer(function()
                                pcall(function()
                                    local _panelBgs = {
                                        Character = "rbxassetid://103368961885444",
                                        Home      = "rbxassetid://85278059623649",
                                        Settings  = "rbxassetid://94124395988701",
                                    }
                                    for _pname, _imgId in pairs(_panelBgs) do
                                        local _pan = panels[_pname]
                                        if _pan then
                                            local _bg = _pan:FindFirstChild("DragonballBg")
                                            if not _bg then
                                                _bg = Instance.new("ImageLabel")
                                                _bg.Name = "DragonballBg"
                                                _bg.Size = UDim2.new(1, 0, 1, 0)
                                                _bg.Position = UDim2.new(0, 0, 0, 0)
                                                _bg.BackgroundTransparency = 1
                                                _bg.Image = _imgId
                                                _bg.ScaleType = Enum.ScaleType.Crop
                                                _bg.ImageTransparency = 0.55
                                                _bg.ZIndex = 0
                                                local _c = Instance.new("UICorner")
                                                _c.CornerRadius = UDim.new(0, 12)
                                                _c.Parent = _bg
                                                _bg.Parent = _pan
                                            end
                                        end
                                    end
                                end)
                            end)
                        end)
                    end
                    
                    if _TL_activeThemeId == "onepiece" then
                        pcall(function()
                            for _, tb in ipairs(tabBtns) do
                                local opIcon = _TL_refs._TL_tabOnePieceIcons[tb.name]
                                if opIcon and tb.iconImg then
                                    tb.iconImg.Image = opIcon
                                end
                            end
                            task.defer(function()
                                pcall(function()
                                    local _panelBgs = {
                                        Character = "rbxassetid://134051752019917",
                                        Home      = "rbxassetid://85278059623649",
                                        Settings  = "rbxassetid://82844161252860",
                                    }
                                    for _pname, _imgId in pairs(_panelBgs) do
                                        local _pan = panels[_pname]
                                        if _pan then
                                            local _bg = _pan:FindFirstChild("OnePieceBg")
                                            if not _bg then
                                                _bg = Instance.new("ImageLabel")
                                                _bg.Name = "OnePieceBg"
                                                _bg.Size = UDim2.new(1, 0, 1, 0)
                                                _bg.Position = UDim2.new(0, 0, 0, 0)
                                                _bg.BackgroundTransparency = 1
                                                _bg.Image = _imgId
                                                _bg.ScaleType = Enum.ScaleType.Crop
                                                _bg.ImageTransparency = 0.55
                                                _bg.ZIndex = 0
                                                local _c = Instance.new("UICorner")
                                                _c.CornerRadius = UDim.new(0, 12)
                                                _c.Parent = _bg
                                                _bg.Parent = _pan
                                            end
                                        end
                                    end
                                end)
                            end)
                        end)
                    end
                    
                    if _TL_activeThemeId == "theboys" then
                        pcall(function()
                            
                            local _getIcon = _TL_refs._TL_getCustomIcon
                            local _tb = _TL_refs._TL_tabTheBoys_Icons
                            if _tb and _getIcon then
                                _tb.Settings = _getIcon(theBoysSettingsIconFileName, "rbxassetid://83091867260863")
                                _tb.Home     = _getIcon(theBoysHomeIconFileName,     "rbxassetid://79298842483031")
                                _tb.Scripts  = _getIcon(theBoysScriptsIconFileName,  "rbxassetid://99174931681951")
                                _tb.Actions  = _getIcon(theBoysActionsIconFileName,  "rbxassetid://110933969812438")
                            end
                            local tabBtns = _TL_refs._TL_tabBtns or tabBtns
                            for _, tb in ipairs(tabBtns) do
                                local tbIcon = _TL_refs._TL_tabTheBoys_Icons[tb.name]
                                if tbIcon and tb.iconImg then
                                    tb.iconImg.Image = tbIcon
                                end
                            end
                        end)
                        task.defer(function()
                            pcall(function()
                                local _panelBgs = {
                                    Character = "rbxassetid://77174664585520",
                                    Home      = "rbxassetid://84736824738121",
                                    Settings  = "rbxassetid://84736824738121",
                                }
                                for _pname, _imgId in pairs(_panelBgs) do
                                    local _pan = panels[_pname]
                                    if _pan then
                                        local bg = _pan:FindFirstChild("TheBoysBg")
                                        if not bg then
                                            bg = Instance.new("ImageLabel")
                                            bg.Name = "TheBoysBg"
                                            bg.Size = UDim2.new(1, 0, 1, 0)
                                            bg.Position = UDim2.new(0, 0, 0, 0)
                                            bg.BackgroundTransparency = 1
                                            bg.Image = _imgId
                                            bg.ScaleType = Enum.ScaleType.Crop
                                            bg.ImageTransparency = 0.55
                                            bg.ZIndex = 0
                                            local _c = Instance.new("UICorner")
                                            _c.CornerRadius = UDim.new(0, 12)
                                            _c.Parent = bg
                                            bg.Parent = _pan
                                        end
                                    end
                                end
                            end)
                        end)
                    end
                    
                    if _TL_activeThemeId == "deathnote" then
                        pcall(function()
                            
                            local _getIcon = _TL_refs._TL_getCustomIcon
                            local _dn = _TL_refs._TL_tabDeathNote_Icons
                            if _dn and _getIcon then
                                _dn.Home          = _getIcon(deathNoteHomeIconFileName,     _dn.Home)
                                _dn.Character     = _getIcon(deathNoteCharIconFileName,     _dn.Character)
                                _dn.Scripts       = _getIcon(deathNoteScriptsIconFileName,  _dn.Scripts)
                                _dn.Settings      = _getIcon(deathNoteSettingsIconFileName, _dn.Settings)
                                _dn.Communication = _getIcon(deathNoteComIconFileName,      _dn.Communication)
                            end
                            local tabBtns = _TL_refs._TL_tabBtns or tabBtns
                            for _, tb in ipairs(tabBtns) do
                                local dnIcon = _TL_refs._TL_tabDeathNote_Icons and _TL_refs._TL_tabDeathNote_Icons[tb.name]
                                if dnIcon and tb.iconImg then
                                    tb.iconImg.Image = dnIcon
                                end
                            end
                        end)
                        task.defer(function()
                            pcall(function()
                                local _dnStartupBgs = {
                                    Home         = { file = deathNoteHomeBgFileName,          url = deathNoteHomeBgUrl          },
                                    Character    = { file = deathNoteCharBgFileName,        url = deathNoteCharBgUrl        },
                                    Actions      = { file = deathNoteScriptsBgFileName,     url = deathNoteScriptsBgUrl     },
                                    Scripts      = { file = deathNoteScriptsPanelBgFileName, url = deathNoteScriptsPanelBgUrl },
                                    Communication = { file = deathNoteComBgFileName,         url = deathNoteComBgUrl         },
                                }
                                for _pname, _src in pairs(_dnStartupBgs) do
                                    local _pan = panels[_pname]
                                    if _pan then
                                        local _bg = _pan:FindFirstChild("DeathNoteBg")
                                        if not _bg then
                                            _bg = Instance.new("ImageLabel")
                                            _bg.Name = "DeathNoteBg"
                                            _bg.Size = UDim2.new(1, 0, 1, 0)
                                            _bg.Position = UDim2.new(0, 0, 0, 0)
                                            _bg.BackgroundTransparency = 1
                                            _bg.Image = _TL_safeGetCustomAsset(_src.file) or _src.url
                                            _bg.ScaleType = Enum.ScaleType.Crop
                                            _bg.ImageTransparency = (_pname == "Home") and 0.65 or 0.45
                                            _bg.ZIndex = 0
                                            local _c = Instance.new("UICorner")
                                            _c.CornerRadius = UDim.new(0, 12)
                                            _c.Parent = _bg
                                            _bg.Parent = _pan
                                        end
                                    end
                                end
                            end)
                        end)
                    end
                    local function deselectAll()
                        for _, tb in ipairs(tabBtns) do
                            twP(tb.pill, 0.14, { BackgroundTransparency = 1 })
                            if tb.card_Stroke then
                                tb.card_Stroke.Color = MGDIM(); tb.card_Stroke.Transparency = 0.82
                            end
                            if tb.iconLbl then twP(tb.iconLbl, 0.14, { TextColor3 = MGDIM() }) end
                            if tb.iconImg then twP(tb.iconImg, 0.14, { ImageColor3 = MGDIM() }) end
                            twP(tb.lbl, 0.14, { TextColor3 = Color3.fromRGB(160, 160, 170) })
                        end
                    end

                    selectTab = function(name)
                        if activeTab and panels[activeTab] then
                            if activeTab == "Communication" then activePage = nil end
                            local old = panels[activeTab]
                            local _oax, _oxsc, _oxoff = getPanelXAnchor()
                            old.AnchorPoint = Vector2.new(_oax, 1)
                            local oldTargetPos = UDim2.new(_oxsc, _oxoff, PANEL_HIDE.Y.Scale, PANEL_HIDE.Y.Offset + 10)
                            tw(old, 0.16, {
                                Position               = oldTargetPos,
                                BackgroundTransparency = 1,
                            }, Enum.EasingStyle.Exponential, Enum.EasingDirection.In):Play()
                            task.delay(0.18, function() pcall(function() old.Visible = false end) end)
                        end
                        deselectAll()
                        if name == activeTab then
                            activeTab = nil; return
                        end
                        activeTab = name
                        for _, tb in ipairs(tabBtns) do
                            if tb.name == name then
                                twP(tb.pill, 0.20, { BackgroundTransparency = 0 })
                                if tb.card_Stroke then
                                    tb.card_Stroke.Color = MG_B(); tb.card_Stroke.Transparency = 0.3
                                end
                                if tb.iconLbl then twP(tb.iconLbl, 0.16, { TextColor3 = MG_B() }) end
                                if tb.iconImg then twP(tb.iconImg, 0.16, { ImageColor3 = Color3.new(1, 1, 1) }) end
                                twP(tb.lbl, 0.16, { TextColor3 = Color3.fromRGB(255, 255, 255) })
                            end
                        end
                        if panels[name] then
                            local pan                  = panels[name]
                            pan.BackgroundTransparency = 1
                            local _ax, _xsc, _xoff     = getPanelXAnchor()
                            pan.AnchorPoint            = Vector2.new(_ax, 1)
                            
                            local _pwOpen              = (name == "Home" and HOME_PANEL_W_OVERRIDE) or PANEL_W
                            pan.Size                   = UDim2.new(0, _pwOpen, 0, pan.Size.Y.Offset)
                            local startPos             = UDim2.new(_xsc, _xoff, PANEL_HIDE.Y.Scale, PANEL_HIDE.Y.Offset + 18)
                            pan.Position    = startPos
                            pan.Visible     = true
                            local targetPos = UDim2.new(_xsc, _xoff, PANEL_SHOW.Y.Scale, PANEL_SHOW.Y.Offset)
                            if name == "Communication" then
                                activePage = commPage
                                pcall(function()
                                    if commActiveSubview ~= "admin" or not _hasAdminAccess() then showCommSubview("chat") end
                                    PopulateList()
                                    if RefreshAdminPlayerList and commAdminView and commAdminView.Visible then
                                        RefreshAdminPlayerList() end
                                end)
                            end
                            local _pt = tw(pan, 0.28, {
                                Position               = targetPos,
                                BackgroundTransparency = 0,
                            }, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
                            _panelTweens[name] = _pt
                            _pt:Play()
                        end
                    end
                    _TL_refs._TL_selectTab = selectTab
                    do
                        
                        local rainAcc = 0
                        local shimAcc = 0
                        local _shimV2 = Vector2.new(0, 0) 
                        _tlTrackConn(RunService.Heartbeat:Connect(function(dt)
                            if not _tlAlive() then return end
                            if not isOpen then return end 
                            shimAcc = shimAcc + dt
                            if shimAcc < 0.033 then return end
                            rainAcc = (rainAcc + shimAcc * 28) % VL_W
                            if rainLblBar then
                                rainLblBar.Position = UDim2.new(0, -rainAcc, 0, 0)
                            end
                            local cn = #panelCreditGrads
                            if cn > 0 then
                                local st = (os.clock() * 0.25) % 1
                                local cX = -1.5 + st * 3
                                _shimV2 = Vector2.new(cX, 0)
                                for i = 1, cn do panelCreditGrads[i].Offset = _shimV2 end
                            end
                            shimAcc = 0
                        end))
                    end
                    function openBar()
                        if _TL_refs._TL_closeQABar then _TL_refs._TL_closeQABar() end
                        _closeTok              = _closeTok + 1
                        isOpen                 = true
                        local _, _tbXsc, _tbXoff = getPanelXAnchor()
                        tabCardsHolder.Visible = true
                        tabCardsHolder.AnchorPoint = Vector2.new(_, 1)
                        tabCardsHolder.Size    = UDim2.new(0, _TAB_BAR_W, 0, 0)
                        tabCardsHolder.Position = UDim2.new(_tbXsc, _tbXoff, 1, 10)
                        tw(tabCardsHolder, 0.30, {
                            Size = UDim2.new(0, _TAB_BAR_W, 0, _TAB_BAR_H),
                            Position = UDim2.new(_tbXsc, _tbXoff, 1, 2),
                        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
                        
                        if tlMainIcon then twP(tlMainIcon, 0.18, { ImageColor3 = Color3.fromRGB(255, 255, 255) }) end
                        if tlArrowBig then tlArrowBig.Image = "rbxassetid://125463592889179" end
                    end

                    function closeBar()
                        isOpen = false
                        if activeTab and panels[activeTab] then
                            local pan = panels[activeTab]
                            local _cax, _cxsc, _cxoff = getPanelXAnchor()
                            tw(pan, 0.16, {
                                Position               = UDim2.new(_cxsc, _cxoff, PANEL_HIDE.Y.Scale, PANEL_HIDE.Y.Offset + 10),
                                BackgroundTransparency = 1,
                            }, Enum.EasingStyle.Exponential, Enum.EasingDirection.In):Play()
                            task.delay(0.18, function() pcall(function() pan.Visible = false end) end)
                        end
                        activeTab = nil
                        deselectAll()
                        local _, _tbXsc2, _tbXoff2 = getPanelXAnchor()
                        local myTok = _closeTok + 1; _closeTok = myTok
                        tw(tabCardsHolder, 0.20, {
                            Size = UDim2.new(0, _TAB_BAR_W, 0, 0),
                            Position = UDim2.new(_tbXsc2, _tbXoff2, 1, 10),
                        }, Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
                        task.delay(0.22, function()
                            if _closeTok == myTok then
                                tabCardsHolder.Visible = false
                            end
                        end)
                        
                        if tlMainIcon then twP(tlMainIcon, 0.18, { ImageColor3 = Color3.fromRGB(255, 255, 255) }) end
                        if tlArrowBig then tlArrowBig.Image = "rbxassetid://119926812103560" end
                    end

                                        
                                        _panelColorHooks[#_panelColorHooks + 1] = function(_newT)
                        pcall(function()
                            if tabCardsHolder and tabCardsHolder.Parent then
                                twP(tabCardsHolder, 0.12, { BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(0, 0, 0) })
                                local thStroke = tabCardsHolder:FindFirstChildOfClass("UIStroke")
                                if thStroke then thStroke.Color = MGDIM() end
                            end
                            for _, tb in ipairs(tabBtns) do
                                local isActive = (tb.name == activeTab)
                                if tb.card then
                                    twP(tb.card, 0.12, { BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(0, 0, 0) })
                                end
                                if tb.card_Stroke then
                                    tb.card_Stroke.Color = isActive and MG_B() or MGDIM()
                                    tb.card_Stroke.Transparency = isActive and 0.3 or 0.82
                                end
                                if tb.iconLbl then
                                    twP(tb.iconLbl, 0.12, { TextColor3 = isActive and MG_B() or MGDIM() })
                                end
                                if tb.iconImg then
                                    twP(tb.iconImg, 0.12, { ImageColor3 = isActive and Color3.new(1, 1, 1) or MGDIM() })
                                end
                                twP(tb.lbl, 0.12, { TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170) })
                                twP(tb.pill, 0.12, { BackgroundColor3 = MG_B() })
                            end
                        end)
                    end
                    -- SmartBar toggle is now handled exclusively by the configurable
                    -- keybind system (rebuildKeybindListener). The old hardcoded K
                    -- listener was removed so that changing the keybind actually works.
                    
                    
                    
                    
                    pcall(function()
                        if LocalPlayer then
                            LocalPlayer.CharacterAdded:Connect(function()
                                task.wait(1.2)
                                if settingsState.autoOpen and not isOpen then openBar() end
                            end)
                        end
                    end)
                    pcall(function()
                        game:GetService("TeleportService").LocalPlayerArrivedFromTeleport:Connect(function()
                            task.wait(2)
                            if settingsState.autoOpen and not isOpen then openBar() end
                        end)
                    end)
                    task.spawn(function()
                        task.wait(0.5)
                        pcall(function() if type(loadData) == "function" then loadData() end end)
                        pcall(function() if type(rebuildKeybindListener) == "function" then rebuildKeybindListener() end end)
                        pcall(function() if type(sendNotif) == "function" then sendNotif("SmartBar", T.notif_settings_loaded, 2) end end)
                        
                        if settingsState and settingsState.guiScale and settingsState.guiScale > 0 and _TL_GUIScale then
                            _TL_GUIScale.Scale = settingsState.guiScale
                        end
                        
                        if settingsState and settingsState.guiPosition and _TL_refs and _TL_refs._TL_applyGuiPosition then
                            pcall(function() _TL_refs._TL_applyGuiPosition(settingsState.guiPosition) end)
                        end
                    end)
                    do
                        local pGui = (LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")) or _SvcSG
                        local existing = pGui and pGui:FindFirstChild("FPSWidget")
                        if not existing then
                            pcall(function()
                                existing = game:GetService("CoreGui"):FindFirstChild("FPSWidget")
                            end)
                        end
                        if not existing then
                            pcall(function()
                                for _, sg in ipairs(PlayerGui:GetChildren()) do
                                    local w = sg:FindFirstChild("FPSWidget")
                                    if w then w:Destroy() end
                                end
                            end)
                        end
                        if existing then pcall(function() existing:Destroy() end) end
                        local inSG = ScreenGui:FindFirstChild("FPSWidget")
                        if inSG then inSG:Destroy() end
                    end
                    
                    local FW_W, FW_H                 = 304, 36
                    local fpsWidget                  = Instance.new("Frame", ScreenGui)
                    fpsWidget.Name                   = "FPSWidget"
                    fpsWidget.Size                   = UDim2.new(0, FW_W, 0, FW_H)
                    fpsWidget.AnchorPoint            = Vector2.new(1, 0.5)
                    fpsWidget.BackgroundColor3       = C.panelBg or Color3.fromRGB(15, 15, 18)
                    fpsWidget.BackgroundTransparency = 0.1
                    fpsWidget.BorderSizePixel        = 0
                    fpsWidget.ZIndex                 = 20
                    fpsWidget.Active                 = false
                    fpsWidget.ClipsDescendants       = true

                    do
                        local c = Instance.new("UICorner", fpsWidget); c.CornerRadius = UDim.new(0, 8)
                    end

                    local fwStroke = Instance.new("UIStroke", fpsWidget)
                    fwStroke.Thickness = 1.5
                    fwStroke.Color = C.accent2
                    fwStroke.Transparency = 0.3

                    local fwShadow = Instance.new("ImageLabel", fpsWidget)
                    fwShadow.Name = "DropShadow"
                    fwShadow.AnchorPoint = Vector2.new(0.5, 0.5)
                    fwShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
                    fwShadow.Size = UDim2.new(1, 0, 1, 0)
                    fwShadow.BackgroundTransparency = 1
                    fwShadow.Image = "rbxassetid://1316045217"
                    fwShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
                    fwShadow.ImageTransparency = 1
                    fwShadow.ScaleType = Enum.ScaleType.Slice
                    fwShadow.SliceCenter = Rect.new(10, 10, 118, 118)
                    fwShadow.ZIndex = 19

                    do
                        local ok, vp = pcall(function() return workspace.CurrentCamera.ViewportSize end)
                        vp           = ok and vp or Vector2.new(1920, 1080)
                        local touch  = pcall(function() return UIS.TouchEnabled end) and UIS.TouchEnabled
                        local kbd    = pcall(function() return UIS.KeyboardEnabled end) and UIS.KeyboardEnabled
                        local short  = math.min(vp.X, vp.Y)
                        local isMob  = touch and not kbd and short < 500
                        local isTab  = touch and not kbd and short >= 500 and short < 900
                        if isMob or isTab then
                            local fwUIScale       = Instance.new("UIScale", fpsWidget)
                            fwUIScale.Scale       = _TL_VP.mobScl
                            fpsWidget.AnchorPoint = Vector2.new(1, 0)
                            fpsWidget.Position    = UDim2.new(1, -(5 + VL_W + 4), 0, 0)
                        else
                            fpsWidget.AnchorPoint = Vector2.new(1, 0)
                            fpsWidget.Position    = UDim2.new(1, -(5), 0, math.floor((VL_ICON_H - FW_H) / 2))
                        end
                    end

                    local function quickTween(obj, duration, props, style, dir)
                        local twObj = TweenService:Create(obj,
                            TweenInfo.new(duration, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
                            props)
                        twObj:Play()
                        return twObj
                    end
                    
                    local smartCapsule = Instance.new("Frame", fpsWidget)
                    smartCapsule.Name = "SmartCapsule"
                    smartCapsule.Size = UDim2.fromOffset(28, 28)
                    smartCapsule.Position = UDim2.new(0, 4, 0.5, -14)
                    smartCapsule.BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(30, 30, 35)
                    smartCapsule.BorderSizePixel = 0
                    smartCapsule.ZIndex = 21
                    local smartCapsuleCorner = Instance.new("UICorner", smartCapsule)
                    smartCapsuleCorner.CornerRadius = UDim.new(1, 0)
                    local scIcon = Instance.new("ImageLabel", smartCapsule)
                    scIcon.Size = UDim2.fromOffset(16, 16)
                    scIcon.Position = UDim2.fromScale(0.5, 0.5)
                    scIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                    scIcon.BackgroundTransparency = 1
                    scIcon.Image = "rbxassetid://6031068433"
                    scIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    scIcon.Visible = false
                    scIcon.ZIndex = 22
                    local scTlIcon = Instance.new("TextLabel", smartCapsule)
                    scTlIcon.Size = UDim2.fromScale(1, 1)
                    scTlIcon.BackgroundTransparency = 1
                    scTlIcon.Text = "TL"
                    scTlIcon.Font = Enum.Font.GothamBlack
                    scTlIcon.TextSize = 12
                    scTlIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
                    scTlIcon.TextXAlignment = Enum.TextXAlignment.Center
                    scTlIcon.TextYAlignment = Enum.TextYAlignment.Center
                    scTlIcon.ZIndex = 23

                    local qaCapsule = Instance.new("Frame", fpsWidget)
                    qaCapsule.Name = "QACapsule"
                    qaCapsule.Size = UDim2.fromOffset(28, 28)
                    qaCapsule.Position = UDim2.new(0, 36, 0.5, -14)
                    qaCapsule.BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(30, 30, 35)
                    qaCapsule.BorderSizePixel = 0
                    qaCapsule.ZIndex = 21
                    local qaCapsuleCorner = Instance.new("UICorner", qaCapsule)
                    qaCapsuleCorner.CornerRadius = UDim.new(1, 0)
                    local qaIcon = Instance.new("ImageLabel", qaCapsule)
                    qaIcon.Size = UDim2.fromOffset(16, 16)
                    qaIcon.Position = UDim2.fromScale(0.5, 0.5)
                    qaIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                    qaIcon.BackgroundTransparency = 1
                    qaIcon.Image = "rbxassetid://6031265976"
                    qaIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    qaIcon.Visible = false
                    qaIcon.ZIndex = 22
                    local qaTlIcon = Instance.new("TextLabel", qaCapsule)
                    qaTlIcon.Size = UDim2.fromScale(1, 1)
                    qaTlIcon.BackgroundTransparency = 1
                    qaTlIcon.Text = "TLQ"
                    qaTlIcon.Font = Enum.Font.GothamBlack
                    qaTlIcon.TextSize = 12
                    qaTlIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
                    qaTlIcon.TextXAlignment = Enum.TextXAlignment.Center
                    qaTlIcon.TextYAlignment = Enum.TextYAlignment.Center
                    qaTlIcon.ZIndex = 23

                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    local tlSmartHitbox = Instance.new("TextButton", fpsWidget)
                    tlSmartHitbox.Size = UDim2.new(0, 32, 0, FW_H)
                    tlSmartHitbox.Position = UDim2.new(0, 4, 0, 0)
                    tlSmartHitbox.BackgroundTransparency = 1
                    tlSmartHitbox.Text = ""
                    tlSmartHitbox.ZIndex = 9999

                    local tlHitbox = Instance.new("TextButton", fpsWidget)
                    tlHitbox.Size = UDim2.new(0, 32, 0, FW_H)
                    tlHitbox.Position = UDim2.new(0, 36, 0, 0)
                    tlHitbox.BackgroundTransparency = 1
                    tlHitbox.Text = ""
                    tlHitbox.ZIndex = 9999

                    local _smartHitboxLock = false
                    local function smartHitboxActivate()
                        if _smartHitboxLock then return end
                        _smartHitboxLock = true; task.delay(0.35, function() _smartHitboxLock = false end)
                        if isOpen then closeBar() else openBar() end
                    end
                    tlSmartHitbox.MouseButton1Click:Connect(smartHitboxActivate)
                    tlSmartHitbox.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then
                            smartHitboxActivate() end end)
                    tlSmartHitbox.MouseEnter:Connect(function()
                        quickTween(smartCapsule, 0.15,
                            { BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255), Size = UDim2.fromOffset(30, 28), Position = UDim2.new(0, 3,
                                0.5, -14) })
                        quickTween(smartCapsuleCorner, 0.15, { CornerRadius = UDim.new(0, 8) })
                        quickTween(scTlIcon, 0.15, { TextSize = 13 })
                        quickTween(scIcon, 0.15, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
                    end)
                    tlSmartHitbox.MouseLeave:Connect(function()
                        quickTween(smartCapsule, 0.15,
                            { BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(30, 30, 35), Size = UDim2.fromOffset(28, 28), Position =
                            UDim2.new(0, 4, 0.5, -14) })
                        quickTween(smartCapsuleCorner, 0.15, { CornerRadius = UDim.new(1, 0) })
                        quickTween(scTlIcon, 0.15, { TextSize = 12 })
                    end)
                    tlHitbox.MouseEnter:Connect(function()
                        quickTween(qaCapsule, 0.15,
                            { BackgroundColor3 = C.accent or Color3.fromRGB(0, 170, 255), Size = UDim2.fromOffset(30, 28), Position = UDim2
                            .new(0, 35, 0.5, -14) })
                        quickTween(qaCapsuleCorner, 0.15, { CornerRadius = UDim.new(0, 8) })
                        quickTween(qaTlIcon, 0.15, { TextSize = 13 })
                    end)
                    tlHitbox.MouseLeave:Connect(function()
                        quickTween(qaCapsule, 0.15,
                            { BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(30, 30, 35), Size = UDim2.fromOffset(28, 28), Position =
                            UDim2.new(0, 36, 0.5, -14) })
                        quickTween(qaCapsuleCorner, 0.15, { CornerRadius = UDim.new(1, 0) })
                        quickTween(qaTlIcon, 0.15, { TextSize = 12 })
                    end)

                    local sepLine = Instance.new("Frame", fpsWidget)
                    sepLine.Size = UDim2.new(0, 1, 0, 20)
                    sepLine.Position = UDim2.new(0, 74, 0.5, -10)
                    sepLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    sepLine.BackgroundTransparency = 0.8
                    sepLine.BorderSizePixel = 0
                    sepLine.ZIndex = 21

                    local fpsIcon = Instance.new("ImageLabel", fpsWidget)
                    fpsIcon.Size = UDim2.fromOffset(14, 14)
                    fpsIcon.Position = UDim2.new(0, 80, 0.5, -7)
                    fpsIcon.BackgroundTransparency = 1
                    fpsIcon.Image = "rbxassetid://14264627447"
                    fpsIcon.ZIndex = 21

                    local fpsText = Instance.new("TextLabel", fpsWidget)
                    fpsText.Size = UDim2.fromOffset(24, 14)
                    fpsText.Position = UDim2.new(0, 90, 0.5, -7)
                    fpsText.BackgroundTransparency = 1
                    fpsText.Text = "FPS"
                    fpsText.Font = Enum.Font.GothamBlack
                    fpsText.TextSize = 12
                    fpsText.TextColor3 = Color3.fromRGB(180, 185, 195)
                    fpsText.TextXAlignment = Enum.TextXAlignment.Left
                    fpsText.ZIndex = 21
                    fpsText.TextStrokeTransparency = 1

                    local fwVal = Instance.new("TextLabel", fpsWidget)
                    fwVal.Size = UDim2.fromOffset(26, 14)
                    fwVal.Position = UDim2.new(0, 116, 0.5, -7)
                    fwVal.BackgroundTransparency = 1
                    fwVal.Text = "--"
                    fwVal.Font = Enum.Font.GothamBold
                    fwVal.TextSize = 13
                    fwVal.TextColor3 = Color3.fromRGB(255, 255, 255)
                    fwVal.TextXAlignment = Enum.TextXAlignment.Left
                    fwVal.ZIndex = 21
                    fwVal.TextStrokeTransparency = 0

                    local pingSignal = Instance.new("ImageLabel", fpsWidget)
                    pingSignal.Size = UDim2.fromOffset(16, 16)
                    pingSignal.Position = UDim2.new(0, 155, 0.5, -8)
                    pingSignal.BackgroundTransparency = 1
                    pingSignal.Image = "rbxassetid://116475274976643"
                    pingSignal.ZIndex = 22
                    

                    local pingVal = Instance.new("TextLabel", fpsWidget)
                    pingVal.Size = UDim2.fromOffset(40, 14)
                    pingVal.Position = UDim2.new(0, 177, 0.5, -7)
                    pingVal.BackgroundTransparency = 1
                    pingVal.Text = "--"
                    pingVal.Font = Enum.Font.GothamBold
                    pingVal.TextSize = 13
                    pingVal.TextColor3 = Color3.fromRGB(255, 255, 255)
                    pingVal.TextXAlignment = Enum.TextXAlignment.Center
                    pingVal.ZIndex = 21
                    pingVal.TextStrokeTransparency = 0

                    local execSepLine = Instance.new("Frame", fpsWidget)
                    execSepLine.Size = UDim2.new(0, 1, 0, 16)
                    execSepLine.Position = UDim2.new(0, 220, 0.5, -8)
                    execSepLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    execSepLine.BackgroundTransparency = 0.8
                    execSepLine.BorderSizePixel = 0
                    execSepLine.ZIndex = 21

                    local function _tlCurrentExecutor()
                        local ok, name = pcall(function()
                            if type(identifyexecutor) == "function" then
                                local n = identifyexecutor()
                                if n then return tostring(n) end
                            end
                            if type(getexecutorname) == "function" then
                                local n = getexecutorname()
                                if n then return tostring(n) end
                            end
                            if type(getexecutor) == "function" then
                                local n = getexecutor()
                                if n then return tostring(n) end
                            end
                        end)
                        name = (ok and name and tostring(name)) or "Executor"
                        name = name:gsub("^%s+", ""):gsub("%s+$", "")
                        if #name == 0 then name = "Executor" end
                        if #name > 12 then name = name:sub(1, 12) end
                        return name
                    end

                    local execVal = Instance.new("TextLabel", fpsWidget)
                    execVal.Size = UDim2.fromOffset(78, 14)
                    execVal.Position = UDim2.new(1, -82, 0.5, -7)
                    execVal.BackgroundTransparency = 1
                    execVal.Text = _tlCurrentExecutor()
                    execVal.Font = Enum.Font.GothamBold
                    execVal.TextSize = 12
                    execVal.TextColor3 = C.accent2 or Color3.fromRGB(255, 255, 255)
                    execVal.TextXAlignment = Enum.TextXAlignment.Center
                    execVal.TextTruncate = Enum.TextTruncate.AtEnd
                    execVal.ZIndex = 21
                    execVal.TextStrokeTransparency = 0

                                        _panelColorHooks[#_panelColorHooks + 1] = function(_newT)
                        pcall(function() fwStroke.Color = C.accent2 end)
                        pcall(function() execVal.TextColor3 = C.accent2 or Color3.fromRGB(255, 255, 255) end)
                        pcall(function() fpsText.TextColor3 = C.sub or Color3.fromRGB(180, 185, 195) end)
                        pcall(function()
                            fpsWidget.BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(15, 15, 18)
                        end)
                        pcall(function()
                            if smartCapsule and smartCapsule.Parent then
                                smartCapsule.BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(30, 30, 35)
                            end
                        end)
                        pcall(function()
                            if qaCapsule and qaCapsule.Parent then
                                qaCapsule.BackgroundColor3 = C.panelBg or Color3.fromRGB(18, 18, 20) or Color3.fromRGB(30, 30, 35)
                            end
                        end)
                    end

                    local _fwSamples                      = {}
                    local _FW_WINDOW                      = 60
                    local _fwPingAcc                      = 0
                    local _fwPingIval                     = 0.5
                    local _fwLastPing                     = 0
                    local _fwStatsService; pcall(function() _fwStatsService = game:GetService("Stats") end)
                    local _fwPingItem
                    pcall(function() if _fwStatsService then _fwPingItem = _fwStatsService.Network.ServerStatsItem
                            ["Data Ping"] end end)

                    _tlTrackConn(_SvcRS.Heartbeat:Connect(function(dt)
                        if not _tlAlive() then return end
                        table.insert(_fwSamples, 1 / math.max(dt, 0.001))
                        if #_fwSamples > _FW_WINDOW then table.remove(_fwSamples, 1) end
                        _fwPingAcc = _fwPingAcc + dt
                        if _fwPingAcc >= _fwPingIval then
                            _fwPingAcc = 0
                            local sum, n = 0, #_fwSamples
                            for i = 1, n do sum = sum + _fwSamples[i] end
                            local fps = _mfloor(n > 0 and (sum / n) or 0)
                            local pingOk, pVal = pcall(function() return _fwPingItem:GetValue() end)
                            if pingOk and pVal then _fwLastPing = _mfloor(pVal) end

                            local fpsCol = fps >= 60 and Color3.fromRGB(100, 215, 130) or
                            fps >= 30 and Color3.fromRGB(230, 195, 70) or Color3.fromRGB(235, 80, 80)
                            local pingCol = _fwLastPing <= 80 and Color3.fromRGB(100, 215, 130) or
                            _fwLastPing <= 150 and Color3.fromRGB(230, 195, 70) or Color3.fromRGB(235, 80, 80)

                            if fwVal and fwVal.Parent then
                                fwVal.Text = tostring(fps)
                                fwVal.TextColor3 = fpsCol
                                fpsIcon.ImageColor3 = fpsCol
                            end
                            if pingVal and pingVal.Parent then
                                pingVal.Text = _fwLastPing .. "ms"
                                pingVal.TextColor3 = pingCol
                                                            end
                        end
                    end))

                    do
                        local _genv = getgenv and getgenv()
                        if _genv then
                            rawset(_genv, "_TL_ScreenGui", ScreenGui)
                            rawset(_genv, "_TL_fpsWidget", fpsWidget)
                            rawset(_genv, "_TL_tlHitbox", tlHitbox)
                            rawset(_genv, "_TL_tlLblBig", tlLblBig)
                            rawset(_genv, "_TL_tlArrowBig", tlArrowBig)
                            rawset(_genv, "_TL_tlLbl", tlLbl)
                            rawset(_genv, "_TL_tlArrow", tlArrow)
                            rawset(_genv, "_TL_FW_W", FW_W)
                            rawset(_genv, "_TL_FW_H", FW_H)
                            rawset(_genv, "_TL_FW_X_OFFSET", FW_X_OFFSET)
                            rawset(_genv, "_TL_VL_ICON_W", VL_ICON_W)
                            rawset(_genv, "_TL_VL_ICON_H", VL_ICON_H)
                            rawset(_genv, "_TL_tw", tw)
                            rawset(_genv, "_TL_corner", corner)
                            rawset(_genv, "_TL_sendNotif", sendNotif)
                            rawset(_genv, "_TL_getNearestPlayer", getNearestPlayer)
                            rawset(_genv, "_TL_getRootPart", getRootPart)
                            rawset(_genv, "_TL_getHumanoid", getHumanoid)
                            rawset(_genv, "_TL_safeStand", safeStand)
                            rawset(_genv, "_TL_stopBB", stopBB)
                            rawset(_genv, "_TL_startBB", startBB)
                        end
                    end
                    
                    _TL_refs._TL_ScreenGui        = ScreenGui
                    _TL_refs._TL_fpsWidget        = fpsWidget
                    _TL_refs._TL_tlHitbox         = tlHitbox
                    _TL_refs._TL_tlLbl            = tlLbl
                    _TL_refs._TL_tlArrow          = tlArrow
                    _TL_refs._TL_tlArrowBig       = tlArrowBig
                    _TL_refs._TL_FW_W             = FW_W
                    _TL_refs._TL_FW_H             = FW_H
                    _TL_refs._TL_FW_X_OFFSET      = FW_X_OFFSET
                    _TL_refs._TL_VL_ICON_W        = VL_ICON_W
                    _TL_refs._TL_VL_ICON_H        = VL_ICON_H
                    _TL_refs._TL_tw               = tw
                    _TL_refs._TL_corner           = corner
                    _TL_refs._TL_sendNotif        = sendNotif
                    _TL_refs._TL_getNearestPlayer = getNearestPlayer
                    _TL_refs._TL_getRootPart      = getRootPart
                    _TL_refs._TL_getHumanoid      = getHumanoid
                    _TL_refs._TL_safeStand        = safeStand
                    _TL_refs._TL_stopBB           = stopBB
                    _TL_refs._TL_startBB          = startBB
                    _TL_refs._TL_qaDispatch       = function(key, target)
                        if not target or not target.Character then return false end
                        local _tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                        if not _tRoot then return false end
                        local _actionOk = false
                        pcall(function()
                        if key == "soh" then
                            startSitOnHead(target); _actionOk = true
                        elseif key == "piggyback" then
                            startPiggyback(target); _actionOk = true
                        elseif key == "piggyback2" then
                            startPiggyback2(target); _actionOk = true
                        elseif key == "kiss" then
                            startKiss(target); _actionOk = true
                        elseif key == "backpack" then
                            startBackpack(target); _actionOk = true
                        elseif key == "friend" then
                            _actionOk = startFriend(target)
                        elseif key == "hug" then
                            startHug(target); _actionOk = true
                        elseif key == "hug2" then
                            startHug2(target); _actionOk = true
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
                        elseif key == "facefuck" then
                            startFacefuck(target); _actionOk = true
                        elseif key == "orbit" then
                            startOrbit(target); _actionOk = true
                        elseif key == "upsidedown" then
                            _actionOk = startUpsideDown(target)
                        elseif key == "crossud" then
                            _actionOk = startCrossUD(target)
                        elseif key == "spinning" then
                            _actionOk = startSpinning(target)
                        elseif key == "ghost" then
                            startGhost(target); _actionOk = true
                        elseif key == "bang" then
                            startFollow(target); _actionOk = true
                        end
                        end)
                        return _actionOk
                    end
                    _TL_refs._TL_AF               = _AF
                    _TL_refs._TL_SOH              = _SOH
                    _TL_refs._TL_act_stopFollow   = _act_stopFollow
                    _TL_refs._TL_stopGhost        = stopGhost
                    _TL_refs._TL_stopSitOnHead    = stopSitOnHead
                    _TL_refs._TL_stopPiggyback    = stopPiggyback
                    _TL_refs._TL_stopPiggyback2   = stopPiggyback2
                    _TL_refs._TL_stopKiss         = stopKiss
                    _TL_refs._TL_stopBackpack     = stopBackpack
                    _TL_refs._TL_stopOrbit        = stopOrbit
                    _TL_refs._TL_stopUpsideDown   = stopUpsideDown
                    _TL_refs._TL_stopCrossUD      = stopCrossUD
                    _TL_refs._TL_stopFriend       = stopFriend
                    _TL_refs._TL_stopSpinning     = stopSpinning
                    _TL_refs._TL_stopLicking      = stopLicking
                    _TL_refs._TL_stopSucking      = stopSucking
                    _TL_refs._TL_stopSuckIt       = stopSuckIt
                    _TL_refs._TL_stopBackshots    = stopBackshots
                    _TL_refs._TL_stopDoggy        = stopDoggy
                    _TL_refs._TL_stopLayFuck      = stopLayFuck
                    _TL_refs._TL_stopFacefuck     = stopFacefuck
                    _TL_refs._TL_stopPussySpread  = stopPussySpread
                    _TL_refs._TL_stopHug          = stopHug
                    _TL_refs._TL_stopHug2         = stopHug2
                    _TL_refs._TL_stopCarry        = stopCarry
                    _TL_refs._TL_stopShoulderSit  = stopShoulderSit

                    
                    
                                
            
            
local function _TL_showLoadingScreen()
                        local TweenService = _tsProxy
                        local Heartbeat    = game:GetService("RunService").Heartbeat
                        local Players      = game:GetService("Players")

                        local LC = {
                            bg           = Color3.fromRGB(  6,   6,  11),
                            surface      = Color3.fromRGB( 18,  18,  24),
                            border       = Color3.fromRGB( 32,  32,  40),
                            accent       = Color3.fromRGB(130,  90, 245),
                            accentDim    = Color3.fromRGB( 80,  50, 160),
                            accentBright = Color3.fromRGB(168, 126, 248),
                            text         = Color3.fromRGB(220, 220, 230),
                            textDim      = Color3.fromRGB(130, 130, 145),
                            textMuted    = Color3.fromRGB( 75,  75,  90),
                            white        = Color3.fromRGB(245, 245, 250),
                            green        = Color3.fromRGB(100, 210, 140),
                            greenDim     = Color3.fromRGB( 55, 140,  90),
                            nebula1      = Color3.fromRGB( 60,  30, 110),
                            nebula2      = Color3.fromRGB( 25,  18,  70),
                            indigo       = Color3.fromRGB( 35,  20,  80),
                            deepPurple   = Color3.fromRGB( 18,  10,  42),
                        }

                        local LAYOUT = {
                            imgSize       = 130,
                            frameSize     = 150,
                            frameRadius   = 20,
                            barWidth      = 360,
                            barHeight     = 3,
                            duration      = 3.5,
                            stepCount     = 5,
                            gridSpacing   = 60,
                            gridAlpha     = 0.06,
                            dustCount     = 80,
                            orbCount      = 25,
                            bokehCount    = 8,
                            streakCount   = 4,
                            emberCount    = 18,
                            sparkleCount  = 15,
                        }

                        local SCREEN_NAME = "TL_LoadingScreen"
                        local MAX_WAIT    = 60

                        pcall(function()
                            local old = game:GetService("CoreGui"):FindFirstChild(SCREEN_NAME)
                            if old then old:Destroy() end
                        end)
                        for _, child in ipairs(Players.LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
                            if child.Name == SCREEN_NAME then child:Destroy() end
                        end

                        local function lmake(cls, props, parent)
                            local obj = Instance.new(cls)
                            for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
                            if parent then obj.Parent = parent end
                            return obj
                        end
                        local function addCorner(r, parent) return lmake("UICorner", {CornerRadius = UDim.new(0, r)}, parent) end
                        local function addGradient(parent, cs, rot)
                            local g = lmake("UIGradient", {Color = cs, Rotation = rot or 0}, parent)
                            return g
                        end
                        local function tw(obj, dur, props, style, dir)
                            local t = TweenService:Create(obj,
                                TweenInfo.new(dur, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
                            t:Play(); return t
                        end
                        local function lerp(a, b, t2) return a + (b - a) * t2 end
                        local function lerpColor(c1, c2, t2)
                            return Color3.new(lerp(c1.R, c2.R, t2), lerp(c1.G, c2.G, t2), lerp(c1.B, c2.B, t2))
                        end

                        local rand = math.random
                        local sin  = math.sin
                        local cos  = math.cos
                        local abs  = math.abs
                        local pi2  = math.pi * 2

                        local gui = lmake("ScreenGui", {
                            Name = SCREEN_NAME, ResetOnSpawn = false,
                            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                            DisplayOrder = 999, IgnoreGuiInset = true,
                        })
                        pcall(function() gui.Parent = game:GetService("CoreGui") end)
                        if not gui.Parent then
                            pcall(function() gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 5) end)
                        end
                        if not gui.Parent then return end

                        local screenSize = workspace.CurrentCamera.ViewportSize
                        local SW, SH = screenSize.X, screenSize.Y

                        task.spawn(function()
                            pcall(function()
                                local _vloader = rawget(_genv, "_TL_assetLoader")
                                if _vloader then
                                    local _vwait = 0
                                    while not _vloader.ready and _vwait < 15 do
                                        task.wait(0.2); _vwait = _vwait + 0.2
                                    end
                                end
                                local snd = Instance.new("Sound")
                                snd.Name = "TLMenu_VoiceLine"; snd.Volume = 1.0
                                snd.RollOffMaxDistance = 10000
                                local cached = nil
                                if _TL_safeIsFile(loadingScreenVoiceFileName) then
                                    cached = _TL_safeGetCustomAsset(loadingScreenVoiceFileName)
                                end
                                if cached then
                                    snd.SoundId = cached; snd.Parent = gui
                                    task.wait(0.1)
                                    if snd and snd.Parent then snd:Play() end
                                end
                            end)
                        end)

                        lmake("Frame", {
                            Size = UDim2.new(1,0,1,0), BackgroundColor3 = LC.bg,
                            BorderSizePixel = 0, ZIndex = 1,
                        }, gui)

                        local gradFrame = lmake("Frame", {
                            Size = UDim2.new(2.4,0,2.4,0), Position = UDim2.new(-0.7,0,-0.7,0),
                            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2,
                        }, gui)
                        local bgGradient = addGradient(gradFrame, ColorSequence.new({
                            ColorSequenceKeypoint.new(0,    Color3.fromRGB(65, 35, 120)),
                            ColorSequenceKeypoint.new(0.18, Color3.fromRGB(40, 20,  85)),
                            ColorSequenceKeypoint.new(0.38, Color3.fromRGB(20, 12,  50)),
                            ColorSequenceKeypoint.new(0.58, LC.bg),
                            ColorSequenceKeypoint.new(0.78, Color3.fromRGB(12,  8,  30)),
                            ColorSequenceKeypoint.new(1,    LC.bg),
                        }), -35)

                        local fogHolder = lmake("Frame", {
                            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                            BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 3,
                        }, gui)
                        local fogBlobs = {}
                        local fogConfigs = {
                            { size = 700, color = Color3.fromRGB(70, 35, 130), alpha = 0.90, x = 0.15, y = 0.20, vx =  14, vy =  9  },
                            { size = 550, color = Color3.fromRGB(30, 20,  80), alpha = 0.86, x = 0.80, y = 0.65, vx = -11, vy = -7  },
                            { size = 400, color = Color3.fromRGB(90, 50, 160), alpha = 0.93, x = 0.50, y = 0.80, vx =   8, vy = -12 },
                        }
                        for i, cfg in ipairs(fogConfigs) do
                            local blob = lmake("ImageLabel", {
                                Size = UDim2.new(0, cfg.size, 0, cfg.size),
                                Position = UDim2.new(cfg.x, -cfg.size/2, cfg.y, -cfg.size/2),
                                BackgroundTransparency = 1, ImageColor3 = cfg.color,
                                ImageTransparency = cfg.alpha, Image = "rbxasset://textures/whiteCircle512.png",
                                BorderSizePixel = 0, ZIndex = 3,
                            }, fogHolder)
                            fogBlobs[i] = {
                                obj = blob, x = cfg.x * SW, y = cfg.y * SH,
                                vx = cfg.vx, vy = cfg.vy, size = cfg.size, baseAlpha = cfg.alpha,
                            }
                        end

                        local gridHolder = lmake("Frame", {
                            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                            BorderSizePixel = 0, ZIndex = 4,
                        }, gui)
                        local gridColor = Color3.fromRGB(100, 70, 180)
                        local gridTrans = 1 - LAYOUT.gridAlpha
                        for x = 0, SW, LAYOUT.gridSpacing do
                            lmake("Frame", {
                                Size = UDim2.new(0,1,1,0), Position = UDim2.new(0,x,0,0),
                                BackgroundColor3 = gridColor, BackgroundTransparency = gridTrans,
                                BorderSizePixel = 0,
                            }, gridHolder)
                        end
                        for y = 0, SH, LAYOUT.gridSpacing do
                            lmake("Frame", {
                                Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0,y),
                                BackgroundColor3 = gridColor, BackgroundTransparency = gridTrans,
                                BorderSizePixel = 0,
                            }, gridHolder)
                        end

                        local vignetteFrame = lmake("Frame", {
                            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                            BorderSizePixel = 0, ZIndex = 4,
                        }, gui)
                        local vigTop = lmake("Frame", {
                            Size = UDim2.new(1,0,0.22,0), BackgroundColor3 = Color3.new(0,0,0),
                            BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 4,
                        }, vignetteFrame)
                        addGradient(vigTop, NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
                        }), 90)
                        local vigBot = lmake("Frame", {
                            Size = UDim2.new(1,0,0.22,0), Position = UDim2.new(0,0,0.78,0),
                            BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.35,
                            BorderSizePixel = 0, ZIndex = 4,
                        }, vignetteFrame)
                        addGradient(vigBot, NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
                        }), 90)
                        local vigLeft = lmake("Frame", {
                            Size = UDim2.new(0.15,0,1,0), BackgroundColor3 = Color3.new(0,0,0),
                            BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 4,
                        }, vignetteFrame)
                        addGradient(vigLeft, NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
                        }), 0)
                        local vigRight = lmake("Frame", {
                            Size = UDim2.new(0.15,0,1,0), Position = UDim2.new(0.85,0,0,0),
                            BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.45,
                            BorderSizePixel = 0, ZIndex = 4,
                        }, vignetteFrame)
                        addGradient(vigRight, NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
                        }), 0)

                        local scanFrame = lmake("Frame", {
                            Size = UDim2.new(1,0,2,0), BackgroundColor3 = Color3.new(0,0,0),
                            BackgroundTransparency = 0.94, BorderSizePixel = 0, ZIndex = 5,
                        }, gui)
                        local scanOffset = 0

                        local particleHolder = lmake("Frame", {
                            Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1,
                            BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 6,
                        }, gui)

                        local PARTICLE_COLORS = {
                            Color3.fromRGB(130,  90, 245), Color3.fromRGB(168, 126, 248),
                            Color3.fromRGB(100,  70, 200), Color3.fromRGB(180, 160, 255),
                            Color3.fromRGB( 80, 120, 255), Color3.fromRGB(200, 180, 255),
                            Color3.fromRGB(255, 255, 255),
                        }
                        local function pickColor() return PARTICLE_COLORS[rand(1, #PARTICLE_COLORS)] end

                        local dustParticles = {}
                        for i = 1, LAYOUT.dustCount do
                            local sz = rand(1, 3)
                            local alpha = rand(5, 20) / 100
                            local px = rand() * SW
                            local py = rand() * SH
                            local col = lerpColor(LC.accent, LC.white, rand() * 0.3)
                            local dot = lmake("Frame", {
                                Size = UDim2.new(0,sz,0,sz), Position = UDim2.new(0,px,0,py),
                                BackgroundColor3 = col, BackgroundTransparency = 1 - alpha,
                                BorderSizePixel = 0, ZIndex = 6,
                            }, particleHolder)
                            addCorner(sz, dot)
                            dustParticles[i] = {
                                obj = dot, x = px, y = py,
                                vx = (rand() - 0.5) * 0.3, vy = (rand() - 0.5) * 0.2 - 0.1,
                                baseAlpha = alpha, phase = rand() * pi2, freq = 1.5 + rand() * 2, sz = sz,
                            }
                        end

                        local orbParticles = {}
                        for i = 1, LAYOUT.orbCount do
                            local sz = rand(4, 12)
                            local alpha = rand(10, 35) / 100
                            local px = rand() * SW
                            local py = rand() * SH
                            local col = pickColor()
                            local haloSz = sz * 4
                            local halo = lmake("ImageLabel", {
                                Size = UDim2.new(0,haloSz,0,haloSz),
                                Position = UDim2.new(0,px-haloSz/2,0,py-haloSz/2),
                                BackgroundTransparency = 1, ImageColor3 = col,
                                ImageTransparency = 1 - (alpha * 0.3),
                                Image = "rbxasset://textures/whiteCircle512.png",
                                BorderSizePixel = 0, ZIndex = 6,
                            }, particleHolder)
                            local dot = lmake("Frame", {
                                Size = UDim2.new(0,sz,0,sz),
                                Position = UDim2.new(0,px-sz/2,0,py-sz/2),
                                BackgroundColor3 = col, BackgroundTransparency = 1 - alpha,
                                BorderSizePixel = 0, ZIndex = 7,
                            }, particleHolder)
                            addCorner(sz, dot)
                            orbParticles[i] = {
                                dot = dot, halo = halo, x = px, y = py,
                                baseX = px, baseY = py,
                                vx = (rand()-0.5)*0.6, vy = (rand()-0.5)*0.4-0.15,
                                baseAlpha = alpha, phase = rand()*pi2, freq = 0.8+rand()*1.5,
                                sz = sz, haloSz = haloSz, col = col,
                                orbitR = rand(20,80), orbitSpeed = (rand()-0.5)*1.2,
                                orbitAngle = rand()*pi2, driftX = 0, driftY = 0,
                            }
                        end

                        local bokehParticles = {}
                        for i = 1, LAYOUT.bokehCount do
                            local sz = rand(40, 120)
                            local alpha = rand(3, 8) / 100
                            local px = rand() * SW
                            local py = rand() * SH
                            local col = lerpColor(LC.accent, Color3.fromRGB(60, 40, 140), rand())
                            local circle = lmake("ImageLabel", {
                                Size = UDim2.new(0,sz,0,sz),
                                Position = UDim2.new(0,px-sz/2,0,py-sz/2),
                                BackgroundTransparency = 1, ImageColor3 = col,
                                ImageTransparency = 1 - alpha,
                                Image = "rbxasset://textures/whiteCircle512.png",
                                BorderSizePixel = 0, ZIndex = 5,
                            }, particleHolder)
                            local ring = lmake("Frame", {
                                Size = UDim2.new(0,sz,0,sz),
                                Position = UDim2.new(0,px-sz/2,0,py-sz/2),
                                BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
                            }, particleHolder)
                            addCorner(sz, ring)
                            lmake("UIStroke", {Color = col, Thickness = 1, Transparency = 1 - (alpha*1.5)}, ring)
                            bokehParticles[i] = {
                                circle = circle, ring = ring, x = px, y = py,
                                vx = (rand()-0.5)*0.15, vy = (rand()-0.5)*0.1,
                                baseAlpha = alpha, phase = rand()*pi2, sz = sz, col = col,
                                pulseFreq = 0.3+rand()*0.5,
                            }
                        end

                        local streakParticles = {}
                        for i = 1, LAYOUT.streakCount do
                            local len = rand(60, 180)
                            local thick = rand(1, 2)
                            local streak = lmake("Frame", {
                                Size = UDim2.new(0,len,0,thick),
                                Position = UDim2.new(0,-len,0,rand()*SH),
                                BackgroundColor3 = LC.accentBright, BackgroundTransparency = 0.5,
                                BorderSizePixel = 0, Rotation = -25+rand(-10,10), ZIndex = 8,
                            }, particleHolder)
                            addCorner(thick, streak)
                            lmake("UIGradient", {
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.4),
                                    NumberSequenceKeypoint.new(0.7, 0.1), NumberSequenceKeypoint.new(1, 0.6),
                                }),
                            }, streak)
                            streakParticles[i] = {
                                obj = streak, x = -len-rand(0,SW), y = rand(50,SH-50),
                                speed = rand(300,700), len = len, thick = thick,
                                cooldown = rand(2,6), timer = rand()*4, active = false,
                                rotation = -25+rand(-10,10),
                            }
                        end

                        local emberParticles = {}
                        for i = 1, LAYOUT.emberCount do
                            local sz = rand(2, 5)
                            local alpha = rand(15, 45) / 100
                            local px = rand() * SW
                            local py = SH + rand(20, 200)
                            local ember = lmake("Frame", {
                                Size = UDim2.new(0,sz,0,sz), Position = UDim2.new(0,px,0,py),
                                BackgroundColor3 = lerpColor(Color3.fromRGB(200,140,255), Color3.fromRGB(255,200,100), rand()*0.4),
                                BackgroundTransparency = 1 - alpha, BorderSizePixel = 0, ZIndex = 7,
                            }, particleHolder)
                            addCorner(sz, ember)
                            local glowSz = sz * 3
                            local glow = lmake("ImageLabel", {
                                Size = UDim2.new(0,glowSz,0,glowSz),
                                Position = UDim2.new(0,px-glowSz/2,0,py-glowSz/2),
                                BackgroundTransparency = 1, ImageColor3 = Color3.fromRGB(180,130,255),
                                ImageTransparency = 1 - (alpha*0.25),
                                Image = "rbxasset://textures/whiteCircle512.png",
                                BorderSizePixel = 0, ZIndex = 6,
                            }, particleHolder)
                            emberParticles[i] = {
                                dot = ember, glow = glow, x = px, y = py,
                                vx = (rand()-0.5)*0.8, vy = -(rand()*1.2+0.5),
                                baseAlpha = alpha, phase = rand()*pi2, sz = sz, glowSz = glowSz,
                                wobbleAmp = rand(15,40), wobbleFreq = 1+rand()*2, startX = px,
                            }
                        end

                        local sparkleParticles = {}
                        for i = 1, LAYOUT.sparkleCount do
                            local container = lmake("Frame", {
                                Size = UDim2.new(0,16,0,16),
                                Position = UDim2.new(0,rand()*SW,0,rand()*SH),
                                BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 9,
                            }, particleHolder)
                            local h = lmake("Frame", {
                                Size = UDim2.new(1,0,0,2), Position = UDim2.new(0,0,0.5,-1),
                                BackgroundColor3 = Color3.fromRGB(220,200,255),
                                BackgroundTransparency = 0.2, BorderSizePixel = 0,
                            }, container)
                            addCorner(1, h)
                            lmake("UIGradient", {
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.4, 0),
                                    NumberSequenceKeypoint.new(0.6, 0), NumberSequenceKeypoint.new(1, 1),
                                }),
                            }, h)
                            local v = lmake("Frame", {
                                Size = UDim2.new(0,2,1,0), Position = UDim2.new(0.5,-1,0,0),
                                BackgroundColor3 = Color3.fromRGB(220,200,255),
                                BackgroundTransparency = 0.2, BorderSizePixel = 0,
                            }, container)
                            addCorner(1, v)
                            lmake("UIGradient", {
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.4, 0),
                                    NumberSequenceKeypoint.new(0.6, 0), NumberSequenceKeypoint.new(1, 1),
                                }), Rotation = 90,
                            }, v)
                            lmake("ImageLabel", {
                                Size = UDim2.new(0,20,0,20), Position = UDim2.new(0.5,-10,0.5,-10),
                                BackgroundTransparency = 1, ImageColor3 = Color3.fromRGB(200,180,255),
                                ImageTransparency = 0.7, Image = "rbxasset://textures/whiteCircle512.png",
                                BorderSizePixel = 0,
                            }, container)
                            sparkleParticles[i] = {
                                obj = container, x = rand()*SW, y = rand()*SH,
                                timer = rand()*5, interval = 1.5+rand()*4, flashDur = 0.3+rand()*0.4,
                                state = "hidden", stateTimer = 0, scale = 0,
                                maxScale = 0.6+rand()*0.8, rotation = 0, rotSpeed = (rand()-0.5)*60,
                            }
                            container.Size = UDim2.new(0,0,0,0)
                        end

                        local FS = LAYOUT.frameSize
                        local IS = LAYOUT.imgSize
                        local FR = LAYOUT.frameRadius

                        local logoGroup = lmake("Frame", {
                            Size = UDim2.new(0,FS+40,0,FS+80),
                            Position = UDim2.new(0.5,-(FS+40)/2, 0.30,-(FS+80)/2),
                            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 10,
                        }, gui)

                        local frameGlow = lmake("Frame", {
                            Size = UDim2.new(0,FS+16,0,FS+16),
                            Position = UDim2.new(0.5,-(FS+16)/2, 0,10),
                            BackgroundColor3 = LC.accentDim, BackgroundTransparency = 0.82,
                            BorderSizePixel = 0,
                        }, logoGroup)
                        addCorner(FR+6, frameGlow)

                        local logoFrame = lmake("Frame", {
                            Size = UDim2.new(0,FS,0,FS),
                            Position = UDim2.new(0.5,-FS/2, 0,18),
                            BackgroundColor3 = LC.surface, BackgroundTransparency = 0.3,
                            BorderSizePixel = 0,
                        }, logoGroup)
                        addCorner(FR, logoFrame)

                        local frameStroke = lmake("UIStroke", {
                            Color = LC.accent, Thickness = 2, Transparency = 0.35,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        }, logoFrame)

                        local logoImage = lmake("ImageLabel", {
                            Size = UDim2.new(0,IS,0,IS),
                            Position = UDim2.new(0.5,-IS/2, 0.5,-IS/2),
                            BackgroundTransparency = 1, BorderSizePixel = 0,
                            Image = "rbxassetid://89872178631966",
                            ScaleType = Enum.ScaleType.Fit,
                        }, logoFrame)
                        addCorner(FR-4, logoImage)

                        local titleLabel = lmake("TextLabel", {
                            Size = UDim2.new(1,0,0,28),
                            Position = UDim2.new(0,0, 0,FS+26),
                            Text = "", TextColor3 = LC.accent, TextSize = 22,
                            Font = Enum.Font.GothamBlack,
                            BackgroundTransparency = 1, BorderSizePixel = 0,
                        }, logoGroup)

                        lmake("TextLabel", {
                            Size = UDim2.new(1,0,0,14),
                            Position = UDim2.new(0,0, 0,FS+56),
                            Text = "v1.03 \xc2\xb7 Enjoy it",
                            TextColor3 = LC.textMuted, TextSize = 11,
                            Font = Enum.Font.GothamMedium,
                            BackgroundTransparency = 1, BorderSizePixel = 0,
                        }, logoGroup)

                        local TIPS = {
                            "[PC] You can open the TLMenu quicker when u set up a keybind.",
                            "U can select a color of your choice, based how you want the TLMenu to look!",
                            "Ur using right now the best script, did you know that?",
                        }

                        local tipsBg = lmake("Frame", {
                            Size = UDim2.new(0,LAYOUT.barWidth,0,34),
                            Position = UDim2.new(0.5,-(LAYOUT.barWidth/2), 0.52,-17),
                            BackgroundColor3 = LC.surface, BackgroundTransparency = 0.55,
                            BorderSizePixel = 0, ZIndex = 10,
                        }, gui)
                        addCorner(8, tipsBg)
                        lmake("UIStroke", {Color = LC.border, Thickness = 1, Transparency = 0.55}, tipsBg)

                        lmake("TextLabel", {
                            Size = UDim2.new(0,44,1,0), Position = UDim2.new(0,10,0,0),
                            Text = "TIPP", TextColor3 = LC.accent, TextSize = 9,
                            Font = Enum.Font.GothamBlack, BackgroundTransparency = 1,
                            BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 11,
                        }, tipsBg)

                        lmake("Frame", {
                            Size = UDim2.new(0,1,0,16), Position = UDim2.new(0,56,0.5,-8),
                            BackgroundColor3 = LC.accent, BackgroundTransparency = 0.6,
                            BorderSizePixel = 0, ZIndex = 11,
                        }, tipsBg)

                        local tipsClip = lmake("Frame", {
                            Size = UDim2.new(1,-70,1,0), Position = UDim2.new(0,64,0,0),
                            BackgroundTransparency = 1, BorderSizePixel = 0,
                            ClipsDescendants = true, ZIndex = 11,
                        }, tipsBg)
                        lmake("UIGradient", {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.80, 0),
                                NumberSequenceKeypoint.new(1, 1),
                            }),
                        }, tipsClip)

                        local tipsLabel = lmake("TextLabel", {
                            Size = UDim2.new(0,900,1,0), Position = UDim2.new(0,0,0,0),
                            Text = TIPS[1], TextColor3 = LC.textDim, TextSize = 10,
                            Font = Enum.Font.GothamMedium, BackgroundTransparency = 1,
                            BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left,
                            TextTruncate = Enum.TextTruncate.None, ZIndex = 12,
                        }, tipsClip)

                        local MARQUEE_SPEED = 40
                        local MARQUEE_PAUSE = 2.1
                        local MARQUEE_GAP   = 55
                        local tipIndex      = 1
                        local marqueeX      = 0
                        local marqueePause  = MARQUEE_PAUSE
                        local tipsClipW     = LAYOUT.barWidth - 70

                        local BW = LAYOUT.barWidth
                        local BH = LAYOUT.barHeight

                        local barGroup = lmake("Frame", {
                            Size = UDim2.new(0,BW,0,56),
                            Position = UDim2.new(0.5,-BW/2, 0.67,0),
                            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 10,
                        }, gui)

                        lmake("TextLabel", {
                            Size = UDim2.new(0.65,0,0,13), Position = UDim2.new(0,0,0,0),
                            Text = "LOADING ASSETS", TextColor3 = LC.textMuted, TextSize = 10,
                            Font = Enum.Font.GothamBold, BackgroundTransparency = 1,
                            BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left,
                        }, barGroup)

                        local barPct = lmake("TextLabel", {
                            Size = UDim2.new(0.35,0,0,13), Position = UDim2.new(0.65,0,0,0),
                            Text = "0%", TextColor3 = LC.accent, TextSize = 11,
                            Font = Enum.Font.GothamBold, BackgroundTransparency = 1,
                            BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Right,
                        }, barGroup)

                        local barTrack = lmake("Frame", {
                            Size = UDim2.new(1,0,0,BH), Position = UDim2.new(0,0,0,18),
                            BackgroundColor3 = Color3.fromRGB(32,28,52), BorderSizePixel = 0,
                            ClipsDescendants = false, ZIndex = 10,
                        }, barGroup)
                        addCorner(999, barTrack)
                        lmake("UIStroke", {Color = Color3.fromRGB(55,45,85), Thickness = 1, Transparency = 0.6}, barTrack)

                        for _, frac in ipairs({0.25, 0.50, 0.75}) do
                            lmake("Frame", {
                                Size = UDim2.new(0,1,0,BH+4),
                                Position = UDim2.new(frac,0,0.5,-(BH+4)/2),
                                BackgroundColor3 = Color3.fromRGB(60,50,88), BackgroundTransparency = 0.4,
                                BorderSizePixel = 0, ZIndex = 12,
                            }, barTrack)
                        end

                        local barFillClip = lmake("Frame", {
                            Size = UDim2.new(0,0,1,0), BackgroundTransparency = 1,
                            BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 11,
                        }, barTrack)

                        local barFill = lmake("Frame", {
                            Size = UDim2.new(1,0,1,0), BackgroundColor3 = LC.accent,
                            BorderSizePixel = 0, ZIndex = 11,
                        }, barFillClip)
                        addCorner(999, barFill)
                        addGradient(barFill, ColorSequence.new({
                            ColorSequenceKeypoint.new(0,   LC.accentDim),
                            ColorSequenceKeypoint.new(0.6, LC.accent),
                            ColorSequenceKeypoint.new(1,   LC.accentBright),
                        }), 0)

                        local tipDot = lmake("Frame", {
                            Size = UDim2.new(0,8,0,8), Position = UDim2.new(0,-4,0.5,-4),
                            BackgroundColor3 = LC.accentBright, BorderSizePixel = 0, ZIndex = 14,
                        }, barTrack)
                        addCorner(999, tipDot)

                        local tipHalo = lmake("Frame", {
                            Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,-9,0.5,-9),
                            BackgroundColor3 = LC.accent, BackgroundTransparency = 0.72,
                            BorderSizePixel = 0, ZIndex = 13,
                        }, barTrack)
                        addCorner(999, tipHalo)

                        local STEP_N   = LAYOUT.stepCount
                        local stepDots = {}
                        local dotsHolder = lmake("Frame", {
                            Size = UDim2.new(0,(STEP_N*8)+((STEP_N-1)*5),0,8),
                            Position = UDim2.new(1,-((STEP_N*8)+((STEP_N-1)*5)),0,27),
                            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 10,
                        }, barGroup)
                        for i = 1, STEP_N do
                            local dot = lmake("Frame", {
                                Size = UDim2.new(0,6,0,6), Position = UDim2.new(0,(i-1)*13,0,1),
                                BackgroundColor3 = Color3.fromRGB(55,46,80), BorderSizePixel = 0, ZIndex = 10,
                            }, dotsHolder)
                            addCorner(999, dot)
                            stepDots[i] = dot
                        end

                        local bottomBar = lmake("Frame", {
                            Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,1,-28),
                            BackgroundColor3 = LC.bg, BackgroundTransparency = 0.15,
                            BorderSizePixel = 0, ZIndex = 10,
                        }, gui)
                        lmake("Frame", {
                            Size = UDim2.new(1,0,0,1), BackgroundColor3 = LC.accent,
                            BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 11,
                        }, bottomBar)
                        lmake("TextLabel", {
                            Size = UDim2.new(0,260,1,0), Position = UDim2.new(0,16,0,0),
                            Text = "TLMENU LOADING SYSTEM", TextColor3 = Color3.fromRGB(62,55,88),
                            TextSize = 10, Font = Enum.Font.GothamBold, BackgroundTransparency = 1,
                            BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left,
                        }, bottomBar)
                        lmake("TextLabel", {
                            Size = UDim2.new(0,180,1,0), Position = UDim2.new(1,-196,0,0),
                            Text = "\xc2\xa9 TL\xc2\xb7Productions", TextColor3 = Color3.fromRGB(58,52,80),
                            TextSize = 10, Font = Enum.Font.GothamMedium, BackgroundTransparency = 1,
                            BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Right,
                        }, bottomBar)

                        local statusLabel = lmake("TextLabel", {
                            Size = UDim2.new(1,0,0,13), Position = UDim2.new(0,0,0,29),
                            Text = "Initializing engine core...", TextColor3 = LC.textMuted,
                            TextSize = 10, Font = Enum.Font.GothamMedium, BackgroundTransparency = 1,
                            BorderSizePixel = 0, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
                        }, barGroup)

                        local STATUS_MESSAGES = {
                            "Initializing engine core...", "Loading shader cache...",
                            "Preparing asset pipeline...", "Compiling bytecode...",
                            "Warming up render thread...", "Almost ready...",
                        }
                        local TITLE_FRAMES = {"T","TL","TLM","TLME","TLMEN","TLMENU"}
                        local TITLE_DELAYS = {0.20, 0.20, 0.12, 0.12, 0.12, 0}

                        local progress    = 0
                        local startTime   = tick()
                        local titleStep   = 1
                        local titleTimer  = 0
                        local closing     = false
                        local GLOW_BASE   = FS + 16
                        local loader      = rawget(_genv, "_TL_assetLoader")

                        local function onComplete()
                            closing = true
                            loopConn:Disconnect()
                            progress = 100
                            barFillClip.Size = UDim2.new(1,0,1,0)
                            barPct.Text = "100%"
                            tw(barPct, 0.35, {TextColor3 = LC.green})
                            tw(barFill, 0.35, {BackgroundColor3 = LC.green})
                            tw(tipDot, 0.35, {BackgroundColor3 = LC.green})
                            tw(tipHalo, 0.35, {BackgroundColor3 = LC.green})
                            tipDot.Position = UDim2.new(1,-4,0.5,-4)
                            tipHalo.Position = UDim2.new(1,-9,0.5,-9)
                            task.wait(0.2)
                            statusLabel.Text = "All systems operational."
                            for _, d in ipairs(stepDots) do
                                tw(d, 0.15, {BackgroundColor3 = LC.green})
                                task.wait(0.06)
                            end
                            task.wait(0.5)
                            local snd = gui:FindFirstChild("TLMenu_VoiceLine", true)
                            if snd and snd.IsPlaying then
                                tw(snd, 0.3, {Volume = 0})
                                task.wait(0.3)
                                pcall(function() snd:Stop() end)
                            end
                            local FADE_DUR = 0.55
                            for _, v in ipairs(gui:GetDescendants()) do
                                pcall(function()
                                    local cn = v.ClassName
                                    if cn == "Frame" or cn == "ScrollingFrame" then
                                        local s = v:FindFirstChildOfClass("UIStroke")
                                        if s then tw(s, FADE_DUR, {Transparency = 1}) end
                                        tw(v, FADE_DUR, {BackgroundTransparency = 1})
                                    elseif cn == "TextLabel" or cn == "TextButton" then
                                        tw(v, FADE_DUR, {TextTransparency = 1, BackgroundTransparency = 1})
                                    elseif cn == "ImageLabel" or cn == "ImageButton" then
                                        tw(v, FADE_DUR, {ImageTransparency = 1, BackgroundTransparency = 1})
                                    end
                                end)
                            end
                            task.wait(FADE_DUR + 0.1)
                            pcall(function() gui:Destroy() end)
                            _TL_loading = false
                            pcall(function()
                                if settingsState and settingsState.autoOpen then
                                    if not isOpen then openBar() end
                                else
                                    sendNotif("TLMenu", "System loaded. Press [K] to toggle.", 4)
                                end
                            end)
                        end

                        loopConn = Heartbeat:Connect(function(dt)
                            if not gui or not gui.Parent then loopConn:Disconnect(); return end
                            local now = tick()
                            local elapsed = now - startTime

                            local loaderReady = (not loader) or loader.ready == true
                            local loaderProgress = 0
                            if loader and (loader.total or 0) > 0 then
                                loaderProgress = math.clamp((loader.done or 0) / loader.total, 0, 1)
                            elseif loaderReady then
                                loaderProgress = 1
                            end
                            local timeFloor = math.min((elapsed / LAYOUT.duration) * 65, 65)
                            local target = math.max(timeFloor, loaderProgress * 99)
                            if loaderReady and elapsed >= LAYOUT.duration then
                                target = 100
                            else
                                target = math.min(target, 99)
                            end
                            progress = progress + (target - progress) * math.min(dt * 4, 0.12)
                            local frac = math.clamp(progress / 100, 0, 1)
                            barFillClip.Size = UDim2.new(frac, 0, 1, 0)
                            barPct.Text = math.floor(progress) .. "%"

                            local tipX = frac * BW
                            tipDot.Position = UDim2.new(0, tipX - 4, 0.5, -4)
                            tipHalo.Position = UDim2.new(0, tipX - 9, 0.5, -9)
                            local tipPulse = (sin(now * 5) + 1) * 0.5
                            tipHalo.BackgroundTransparency = 0.65 + tipPulse * 0.2

                            if loader and not loaderReady and loader.current then
                                statusLabel.Text = loader.current
                            else
                                local msgIdx = math.clamp(math.floor(progress / (100 / #STATUS_MESSAGES)) + 1, 1, #STATUS_MESSAGES)
                                statusLabel.Text = STATUS_MESSAGES[msgIdx]
                            end

                            local activeDot = math.floor(frac * STEP_N)
                            for i, d in ipairs(stepDots) do
                                if i <= activeDot then
                                    d.BackgroundColor3 = LC.accent
                                    d.BackgroundTransparency = 0
                                elseif i == activeDot + 1 then
                                    local dp = (sin(now * 3) + 1) * 0.5
                                    d.BackgroundColor3 = LC.accent
                                    d.BackgroundTransparency = 0.4 + dp * 0.35
                                else
                                    d.BackgroundColor3 = Color3.fromRGB(55, 46, 80)
                                    d.BackgroundTransparency = 0
                                end
                            end

                            if bgGradient and bgGradient.Parent then
                                bgGradient.Rotation = (bgGradient.Rotation + dt * 3) % 360
                            end

                            for _, fb in ipairs(fogBlobs) do
                                fb.x = fb.x + fb.vx * dt
                                fb.y = fb.y + fb.vy * dt
                                if fb.x < -fb.size*0.3 or fb.x > SW+fb.size*0.3 then fb.vx = -fb.vx end
                                if fb.y < -fb.size*0.3 or fb.y > SH+fb.size*0.3 then fb.vy = -fb.vy end
                                local breathe = sin(now*0.4+fb.x*0.01)*0.04
                                fb.obj.ImageTransparency = fb.baseAlpha + breathe
                                fb.obj.Position = UDim2.new(0, fb.x-fb.size/2, 0, fb.y-fb.size/2)
                            end

                            scanOffset = (scanOffset + dt*25) % SH
                            scanFrame.Position = UDim2.new(0, 0, 0, -scanOffset)

                            local pulse = (sin(now*1.2)+1)*0.5
                            local glowSize = GLOW_BASE + pulse*16
                            local glowOff = pulse*8
                            if frameGlow and frameGlow.Parent then
                                frameGlow.BackgroundTransparency = 0.78+pulse*0.14
                                frameGlow.Size = UDim2.new(0,glowSize,0,glowSize)
                                frameGlow.Position = UDim2.new(0.5,-glowSize/2, 0,10-glowOff)
                            end

                            if frameStroke and frameStroke.Parent then
                                frameStroke.Transparency = 0.25+(sin(now*1.5)+1)*0.2
                            end

                            if logoImage and logoImage.Parent then
                                local s = IS + sin(now*0.6)*3
                                logoImage.Size = UDim2.new(0,s,0,s)
                                logoImage.Position = UDim2.new(0.5,-s/2, 0.5,-s/2)
                            end

                            for _, p in ipairs(dustParticles) do
                                p.x = p.x + p.vx*(dt*60)
                                p.y = p.y + p.vy*(dt*60)
                                if p.x < -20 then p.x = SW+20 elseif p.x > SW+20 then p.x = -20 end
                                if p.y < -20 then p.y = SH+20 elseif p.y > SH+20 then p.y = -20 end
                                p.obj.Position = UDim2.new(0,p.x,0,p.y)
                                local shimmer = (sin(now*p.freq+p.phase)+1)*0.5
                                p.obj.BackgroundTransparency = 1-(p.baseAlpha*(0.3+shimmer*0.7))
                            end

                            for _, p in ipairs(orbParticles) do
                                p.driftX = p.driftX+p.vx*dt*30
                                p.driftY = p.driftY+p.vy*dt*30
                                if p.baseX+p.driftX < -100 then p.driftX = p.driftX+SW+200 end
                                if p.baseX+p.driftX > SW+100 then p.driftX = p.driftX-SW-200 end
                                if p.baseY+p.driftY < -100 then p.driftY = p.driftY+SH+200 end
                                if p.baseY+p.driftY > SH+100 then p.driftY = p.driftY-SH-200 end
                                p.orbitAngle = p.orbitAngle+p.orbitSpeed*dt
                                local ox = cos(p.orbitAngle)*p.orbitR
                                local oy = sin(p.orbitAngle)*p.orbitR*0.6
                                p.x = p.baseX+p.driftX+ox
                                p.y = p.baseY+p.driftY+oy
                                local pulse2 = (sin(now*p.freq+p.phase)+1)*0.5
                                local alpha = p.baseAlpha*(0.4+pulse2*0.6)
                                local szMult = 1+pulse2*0.3
                                local curSz = p.sz*szMult
                                local curHalo = p.haloSz*szMult
                                p.dot.Size = UDim2.new(0,curSz,0,curSz)
                                p.dot.Position = UDim2.new(0,p.x-curSz/2,0,p.y-curSz/2)
                                p.dot.BackgroundTransparency = 1-alpha
                                p.halo.Size = UDim2.new(0,curHalo,0,curHalo)
                                p.halo.Position = UDim2.new(0,p.x-curHalo/2,0,p.y-curHalo/2)
                                p.halo.ImageTransparency = 1-(alpha*0.35)
                            end

                            for _, p in ipairs(bokehParticles) do
                                p.x = p.x+p.vx*(dt*60)
                                p.y = p.y+p.vy*(dt*60)
                                if p.x < -p.sz then p.x = SW+p.sz elseif p.x > SW+p.sz then p.x = -p.sz end
                                if p.y < -p.sz then p.y = SH+p.sz elseif p.y > SH+p.sz then p.y = -p.sz end
                                local breathe = (sin(now*p.pulseFreq+p.phase)+1)*0.5
                                local alpha = p.baseAlpha*(0.5+breathe*0.5)
                                local curSz = p.sz*(0.9+breathe*0.2)
                                p.circle.Size = UDim2.new(0,curSz,0,curSz)
                                p.circle.Position = UDim2.new(0,p.x-curSz/2,0,p.y-curSz/2)
                                p.circle.ImageTransparency = 1-alpha
                                p.ring.Size = UDim2.new(0,curSz,0,curSz)
                                p.ring.Position = UDim2.new(0,p.x-curSz/2,0,p.y-curSz/2)
                            end

                            for _, p in ipairs(streakParticles) do
                                if p.active then
                                    p.x = p.x+p.speed*dt
                                    local sinY = sin(now*2)*15
                                    p.obj.Position = UDim2.new(0,p.x,0,p.y+sinY)
                                    local screenFrac = p.x/SW
                                    local fade2 = 1-abs(screenFrac-0.5)*2
                                    fade2 = math.clamp(fade2,0,1)
                                    p.obj.BackgroundTransparency = 1-(fade2*0.6)
                                    if p.x > SW+p.len+50 then
                                        p.active = false
                                        p.timer = 0
                                        p.cooldown = 2+rand()*5
                                        p.obj.Position = UDim2.new(0,-p.len-100,0,0)
                                    end
                                else
                                    p.timer = p.timer+dt
                                    if p.timer >= p.cooldown then
                                        p.active = true
                                        p.x = -p.len-rand(0,100)
                                        p.y = rand(30,SH-30)
                                        p.speed = rand(350,800)
                                        p.rotation = -25+rand(-15,15)
                                        p.obj.Rotation = p.rotation
                                        p.obj.Size = UDim2.new(0,p.len,0,p.thick)
                                    end
                                end
                            end

                            for _, p in ipairs(emberParticles) do
                                p.y = p.y+p.vy*(dt*60)
                                local wobble = sin(now*p.wobbleFreq+p.phase)*p.wobbleAmp
                                p.x = p.startX+wobble
                                if p.y < -30 then
                                    p.y = SH+rand(20,100)
                                    p.startX = rand()*SW
                                    p.x = p.startX
                                end
                                local yFrac = p.y/SH
                                local fadeAlpha = p.baseAlpha
                                if yFrac < 0.3 then fadeAlpha = fadeAlpha*(yFrac/0.3) end
                                local emberPulse = (sin(now*3+p.phase)+1)*0.5
                                fadeAlpha = fadeAlpha*(0.6+emberPulse*0.4)
                                local curSz = p.sz*(0.8+emberPulse*0.4)
                                p.dot.Size = UDim2.new(0,curSz,0,curSz)
                                p.dot.Position = UDim2.new(0,p.x-curSz/2,0,p.y-curSz/2)
                                p.dot.BackgroundTransparency = 1-fadeAlpha
                                local curGlow = p.glowSz*(0.8+emberPulse*0.4)
                                p.glow.Size = UDim2.new(0,curGlow,0,curGlow)
                                p.glow.Position = UDim2.new(0,p.x-curGlow/2,0,p.y-curGlow/2)
                                p.glow.ImageTransparency = 1-(fadeAlpha*0.3)
                            end

                            for _, p in ipairs(sparkleParticles) do
                                p.rotation = p.rotation+p.rotSpeed*dt
                                if p.state == "hidden" then
                                    p.timer = p.timer+dt
                                    if p.timer >= p.interval then
                                        p.x = rand(40,SW-40)
                                        p.y = rand(40,SH-40)
                                        p.state = "appearing"
                                        p.stateTimer = 0
                                        p.scale = 0
                                        p.timer = 0
                                    end
                                elseif p.state == "appearing" then
                                    p.stateTimer = p.stateTimer+dt
                                    local t2 = math.clamp(p.stateTimer/0.15,0,1)
                                    t2 = 1-(1-t2)*(1-t2)
                                    p.scale = p.maxScale*t2
                                    if p.stateTimer >= 0.15 then
                                        p.state = "visible"
                                        p.stateTimer = 0
                                        p.scale = p.maxScale
                                    end
                                elseif p.state == "visible" then
                                    p.stateTimer = p.stateTimer+dt
                                    local vp = sin(p.stateTimer*8)*0.15
                                    p.scale = p.maxScale*(1+vp)
                                    if p.stateTimer >= p.flashDur then
                                        p.state = "fading"
                                        p.stateTimer = 0
                                    end
                                elseif p.state == "fading" then
                                    p.stateTimer = p.stateTimer+dt
                                    local t2 = math.clamp(p.stateTimer/0.2,0,1)
                                    p.scale = p.maxScale*(1-t2)
                                    if p.stateTimer >= 0.2 then
                                        p.state = "hidden"
                                        p.stateTimer = 0
                                        p.timer = 0
                                        p.interval = 1+rand()*4
                                        p.scale = 0
                                    end
                                end
                                local sz = 16*p.scale
                                if sz < 0.5 then sz = 0 end
                                p.obj.Size = UDim2.new(0,sz,0,sz)
                                p.obj.Position = UDim2.new(0,p.x-sz/2,0,p.y-sz/2)
                                p.obj.Rotation = p.rotation
                            end

                            if tipsLabel and tipsLabel.Parent then
                                local textW = tipsLabel.TextBounds.X
                                if textW <= tipsClipW then
                                    marqueeX = 0
                                    marqueePause = MARQUEE_PAUSE
                                    tipsLabel.Position = UDim2.new(0,0,0,0)
                                else
                                    if marqueePause > 0 then
                                        marqueePause = marqueePause-dt
                                    else
                                        marqueeX = marqueeX-MARQUEE_SPEED*dt
                                        local maxScroll = -(textW+MARQUEE_GAP-tipsClipW)
                                        if marqueeX <= maxScroll then
                                            tipIndex = (tipIndex%#TIPS)+1
                                            tipsLabel.Text = TIPS[tipIndex]
                                            marqueeX = 0
                                            marqueePause = MARQUEE_PAUSE
                                        end
                                        tipsLabel.Position = UDim2.new(0,math.floor(marqueeX),0,0)
                                    end
                                end
                            end

                            if titleStep <= #TITLE_FRAMES then
                                titleTimer = titleTimer+dt
                                if titleTimer >= (TITLE_DELAYS[titleStep] or 0) then
                                    titleLabel.Text = TITLE_FRAMES[titleStep]
                                    titleStep = titleStep+1
                                    titleTimer = 0
                                end
                            end

                            if not closing and loaderReady and elapsed >= LAYOUT.duration then
                                task.spawn(onComplete)
                            end
                        end)

                        task.spawn(function()
                            local waited = 0
                            while waited < MAX_WAIT do
                                task.wait(1)
                                waited = waited+1
                                if closing then return end
                            end
                            pcall(function()
                                if loader then
                                    loader.done = math.max(loader.done or 0, loader.total or 1)
                                    loader.ready = true
                                    loader.current = "Timeout \xe2\x80\x94 continuing"
                                end
                            end)
                        end)
                    end 

                    pcall(_TL_showLoadingScreen)
                end); if not _ok_SmartBar then warn("[TL] SmartBar-IIFE crashed: " .. tostring(_err_SmartBar)) end
            end)

            
            do
                local _bbMod2 = _TL_loadModule("SCRIPTS-TAB/TL-QABar")
                if _bbMod2 then
                    _bbMod2.initQABar({
                        _TL_refs = _TL_refs,
                        _genv = _genv,
                        C = C,
                        _panelColorHooks = _panelColorHooks,
                        _makeRealStroke = _makeRealStroke,
                        _tlAlive = _tlAlive,
                        twP = twP,
                        getNearestPlayer = getNearestPlayer,
                        _handleError = _handleError,
                        stopStand = stopStand,
                        standStopAnim = standStopAnim,
                        closeBar = closeBar,
                        LocalPlayer = LocalPlayer,
                        RunService = RunService,
                        _SvcUIS = _SvcUIS,
                        _TL_VP = _TL_VP,
                        _sc = _sc,
                        _AF = _AF,
                        stopQA74 = stopQA74,
                        stopBB = function() pcall(function() stopBB() end) end,
                        startBB = function(tgt, mode) pcall(function() startBB(tgt, mode) end) end,
                        registerResetFn = function(fn) _G.TLQA_ResetUI = fn end,
                    })
                    _bbMod2.startQABar()
                end
            end 
            
            
            
            
            
            ; (function()
                local _afk = _genv._TL_afkSystem
                if not _afk then return end

                local _afkFiles = {
                    dragonball = { "assets/TL-MP3-FILES/DB-AFK-VL0.mp3", "assets/TL-MP3-FILES/DB-AFK-VL1.mp3" },
                    onepiece   = { "assets/TL-MP3-FILES/OP-AFK-VL0.mp3", "assets/TL-MP3-FILES/OP-AFK-VL1.mp3" },
                    theboys    = { "assets/TL-MP3-FILES/TB-AFK-VL0.mp3" },
                }

                
                rawset(_genv, "_TL_afkSetTheme", function(id)
                    _afk.themeId = id or "white"
                end)

                local function _afkStopSound()
                    if _afk.currentSound then
                        pcall(function() _afk.currentSound:Stop() end)
                        pcall(function() _afk.currentSound:Destroy() end)
                        _afk.currentSound = nil
                    end
                end

                local function _afkPlayRandom()
                    local files = _afkFiles[_afk.themeId]
                    if not files or #files == 0 then return end

                    
                    local chosen = files[math.random(1, #files)]
                    if not (isfile and isfile(chosen)) then
                        warn("[AFK] Datei nicht gefunden: " .. tostring(chosen))
                        return
                    end

                    _afkStopSound()
                    pcall(function()
                        local snd   = Instance.new("Sound")
                        snd.Name    = "TLMenu_AFK_VL"
                        local _asset = _TL_safeGetCustomAsset(chosen)
                        snd.SoundId = _asset or chosen
                        snd.Volume  = 1.0
                        snd.Looped  = false
                        snd.Parent  = _SvcSnd
                        snd:Play()
                        _afk.currentSound = snd
                        
                        _SvcDeb:AddItem(snd, 30)
                    end)
                end

                local _afkTriggered = false 

                
                local function _afkResetTimer()
                    _afk.lastInputTime = tick()
                    if _afkTriggered then
                        _afkTriggered = false
                        _afkStopSound()
                    end
                end

                local _afkUIS = game:GetService("UserInputService")
                local _afkInputConn1 = _afkUIS.InputBegan:Connect(function() _afkResetTimer() end)
                local _afkInputConn2 = _afkUIS.InputChanged:Connect(function() _afkResetTimer() end)
                table.insert(_afk.inputConns, _afkInputConn1)
                table.insert(_afk.inputConns, _afkInputConn2)

                
                local _afkCheckInterval = 5
                local _afkLastCheck     = tick()
                local _afkHBConn        = game:GetService("RunService").Heartbeat:Connect(function()
                    local now = tick()
                    if now - _afkLastCheck < _afkCheckInterval then return end
                    _afkLastCheck = now

                    
                    if not _afkFiles[_afk.themeId] then return end

                    local elapsed = now - _afk.lastInputTime
                    if elapsed >= _afk.AFK_THRESHOLD and not _afkTriggered then
                        _afkTriggered = true
                        task.spawn(_afkPlayRandom)
                    end
                end)
                _afk.loopConn           = _afkHBConn
                _afk.active             = true

                
            end)()

            

            _TL_refs.TLMenuCleanup = function()
                pcall(function()
                    local _afk = _genv._TL_afkSystem
                    if _afk then
                        if _afk.loopConn then
                            pcall(function() _afk.loopConn:Disconnect() end); _afk.loopConn = nil
                        end
                        for _, c in ipairs(_afk.inputConns) do pcall(function() c:Disconnect() end) end
                        _afk.inputConns = {}
                        if _afk.currentSound then
                            pcall(function() _afk.currentSound:Stop() end)
                            pcall(function() _afk.currentSound:Destroy() end)
                            _afk.currentSound = nil
                        end
                        _afk.active = false
                    end
                    if getgenv then
                        _genv._TL_afkSystem   = nil
                        _genv._TL_afkSetTheme = nil
                    end
                end)

                pcall(function()
                    if keybindMainConn then
                        pcall(function() keybindMainConn:Disconnect() end); keybindMainConn = nil
                    end
                end)
                pcall(function()
                    if _G.TLActionsStop then _G.TLActionsStop() end
                end)
                pcall(function()
                    if getgenv and getgenv()._TLAllConns then
                        for _, c in ipairs(_genv._TLAllConns) do
                            pcall(function() c:Disconnect() end)
                        end
                        _genv._TLAllConns = nil
                    end
                end)
                pcall(function()
                    if getgenv and getgenv()._TLAllInsts then
                        for _, obj in ipairs(_genv._TLAllInsts) do
                            pcall(function()
                                if obj and obj.Parent then obj:Destroy() end
                            end)
                        end
                        _genv._TLAllInsts = nil
                    end
                end)

                pcall(function()
                    if getgenv and getgenv()._TLFlingConn then
                        _genv._TLFlingConn:Disconnect()
                        _genv._TLFlingConn = nil
                    end
                end)
                
                pcall(function()
                    local mods = rawget(_genv, "_TL_MODULES")
                    if mods then
                        for name, mod in pairs(mods) do
                            pcall(function()
                                if type(mod) == "table" and type(mod.cleanup) == "function" then
                                    mod.cleanup()
                                end
                            end)
                        end
                        rawset(_genv, "_TL_MODULES", nil)
                    end
                end)
                pcall(function()
                    local _modRunkeys = { "__TL_FlyRuntime", "__TL_InvisRuntime", "__TL_ShaderRuntime" }
                    for _, rk in ipairs(_modRunkeys) do
                        local r = rawget(_genv, rk)
                        if type(r) == "table" and type(r.cleanup) == "function" then
                            pcall(r.cleanup)
                        end
                        rawset(_genv, rk, nil)
                    end
                    -- Preserve ANTIVCBAN across reinjections
                    local _vcRun = rawget(_genv, "__TL_AntiVCBAN_Runtime")
                    if type(_vcRun) == "table" and type(_vcRun.cleanup) == "function" then
                        if settingsState and settingsState.antiVcBan then
                            -- Still active — save flag, don't kill
                            rawset(_genv, "_TL_persist_antiVcBan", true)
                        else
                            pcall(_vcRun.cleanup)
                            rawset(_genv, "__TL_AntiVCBAN_Runtime", nil)
                        end
                    end
                end)
                local _qb_ref = _TL_refs._TL_qb or {}
                local _conns = {
                    _TL_state.conns.flyConn, _TL_state.conns.noclipConn, _TL_state.conns._espRadConn,
                    _TL_state.conns.rushConn, _TL_state.conns.rushNoclipConn, _TL_state.conns.updateConnUI,
                    _TL_state.conns._act_followRSConn, _SOH and _SOH.conn,
                    _AF and _AF.udConn,
                    _TL_state.conns.friendConn, _TL_state.conns.spinConn, _TL_state.conns.ppConn, _TL_state.conns
                    .pp2Conn,
                    _TL_state.conns.kissConn, _TL_state.conns.bpConn, _TL_state.conns.lickingConn, _TL_state.conns
                    .suckingConn,
                    _TL_state.conns.facefuckConn, _TL_state.conns.backshotsConn, _TL_state.conns.psConn, _TL_state.conns
                    .hugConn,
                    _TL_state.conns.carryConn, _TL_state.conns.ssConn, _TL_state.conns.qa74Conn, _TL_state.conns
                    .orbitConn,
                    _TL_state.conns.ghostConn, _TL_state.conns.bbConn, _TL_state.conns.bbRespConn, _TL_state.conns
                    .bbRemConn,
                    _TL_state.conns.bbAnimConn_, _TL_state.conns.bbAnimConn2_, _TL_state.conns.bbAnimConn3_,
                    _TL_state.conns.bbAnimConn4_, _TL_state.conns.bbAnimConn5_, _TL_state.conns.bbAnimConn6_, _TL_state
                    .conns.bbAnimConn7_,
                    _TL_state.conns.bbAnimConn8_, _TL_state.conns.bbAnimConn9_, _TL_state.conns.bbAnimConn10_, _TL_state
                    .conns.bbHealthConn_,
                    _TL_state.conns.bbRespAnimConn_,
                    _TL_state.conns.invisHeartConn, _TL_state.conns.invisRenderConn, _TL_state.conns.invisSteppedConn,
                    _TL_state.conns.orbitTargetRespConn, _TL_state.conns.ghostRespConn,
                    _TL_state.conns.ppCharConn, _TL_state.conns.pp2CharConn, _TL_state.conns.kissCharConn, _TL_state
                    .conns.bpCharConn,
                    _TL_state.conns.lickingCharConn, _TL_state.conns.suckItCharConn, _TL_state.conns.suckingCharConn,
                    _TL_state.conns.facefuckCharConn, _TL_state.conns.backshotsCharConn, _TL_state.conns.layFuckCharConn,
                    _TL_state.conns.psCharConn, _TL_state.conns.hugCharConn, _TL_state.conns.hug2CharConn, _TL_state
                    .conns.carryCharConn,
                    _TL_state.conns.ssCharConn, _TL_state.conns.qa74CharConn, _TL_state.conns.avCharConn, _TL_state
                    .conns._ui_charConn_,
                    _TL_state.conns.cursorSyncConn, _TL_state.conns.fxConn, _TL_state.conns.antiRagdollConnection,
                    _TL_state.conns.tfConn, _TL_state.conns.AimbotConnection, _TL_state.conns.TriggerBotConnection,
                    _TL_state.conns._ctHoverConn, _qb_ref.qaNoSitConn, _qb_ref.qaNoSitSeatedConn,
                    _qb_ref.qaRespawnConn, _qb_ref.qaTargetRespawnConn, _qb_ref.qaTargetWatchConn, _TL_state.conns
                    ._dhAimConn,
                    _TL_state.conns._dhPickConn, _TL_state.conns._dhFlyConn, _TL_state.conns._dhNoclipConn,
                    _TL_state.conns._mm2FlyConn, _TL_state.conns._mm2NoclipConn,
                }
                for _, c in ipairs(_conns) do
                    if c then pcall(function() c:Disconnect() end) end
                end
                _TL_state.conns.bbAnimConn_     = nil; _TL_state.conns.bbAnimConn2_ = nil; _TL_state.conns.bbAnimConn3_ = nil
                _TL_state.conns.bbAnimConn4_    = nil; _TL_state.conns.bbAnimConn5_ = nil; _TL_state.conns.bbAnimConn6_ = nil
                _TL_state.conns.bbAnimConn7_    = nil; _TL_state.conns.bbAnimConn8_ = nil; _TL_state.conns.bbAnimConn9_ = nil
                _TL_state.conns.bbAnimConn10_   = nil; _TL_state.conns.bbHealthConn_ = nil; _TL_state.conns.bbRespAnimConn_ = nil
                pcall(function()
                    _TL_state.fly.active = false
                    _flyMuteSounds(false)
                    if _invisHL and _invisHL.Parent then
                        _invisHL:Destroy(); _invisHL = nil
                    end
                end)
                pcall(function() if stopBB then stopBB() end end)
                pcall(function()
                    if _G._TLCursorRSConn then
                        pcall(function() _G._TLCursorRSConn:Disconnect() end); _G._TLCursorRSConn = nil
                    end
                    if _G._TLCursorGui and _G._TLCursorGui.Parent then
                        _G._TLCursorGui:Destroy(); _G._TLCursorGui = nil
                    end
                    pcall(function() _SvcUIS.MouseIconEnabled = true end)
                end)
                pcall(function()
                    local lp = _SvcPlr.LocalPlayer
                    local pg = lp:FindFirstChild("PlayerGui")
                    if pg then
                        for _, n in ipairs({ "SmartBarGui", "MatrixTrackerGUI" }) do
                            local g = pg:FindFirstChild(n); if g then g:Destroy() end
                        end
                    end
                    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
                    if ok and cg then
                        for _, n in ipairs({ "SmartBarGui", "MatrixTrackerGUI" }) do
                            local gx = cg:FindFirstChild(n); if gx then gx:Destroy() end
                        end
                    end
                    if gethui then
                        pcall(function()
                            local hui = gethui()
                            for _, n in ipairs({ "SmartBarGui", "MatrixTrackerGUI" }) do
                                local g = hui:FindFirstChild(n); if g then g:Destroy() end
                            end
                        end)
                    end
                    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
                end)
                pcall(function()
                    if _espGui and _espGui.Parent then
                        _espGui:Destroy(); _espGui = nil
                    end
                end)
                pcall(function()
                    if _hoverSoundObj then
                        _hoverSoundObj:Destroy(); _hoverSoundObj = nil
                    end
                end)

                pcall(function()
                    if getgenv and getgenv()._TLRemoveTool then
                        _genv._TLRemoveTool()
                        _genv._TLRemoveTool = nil
                    end
                end)
                pcall(function()
                    if getgenv and getgenv()._TLInvPatchCleanup then
                        _genv._TLInvPatchCleanup()
                        _genv._TLInvPatchCleanup = nil
                    end
                end)
                _G.TLActions        = nil
                _G.TLActionsStop    = nil
                pcall(function()
                    local env = _genv
                    env._panelColorHooks = nil
                end)
                pcall(function()
                    if getgenv then
                        _genv._TL_AntiVoidStop    = nil
                        _genv.TLMenuCleanup       = nil
                        _genv.TLUnload            = nil
                        _genv.SmartBarLoaded      = nil
                        _genv.TLSendNotif         = nil

                    end
                end)
                _G.TLMenuCleanup = nil
            end
            pcall(function()
                local env = _genv
                env.TLMenuCleanup = _TL_refs.TLMenuCleanup
                env.TLUnload = _TL_refs.TLMenuCleanup
            end)
            _G.TLMenuCleanup = _TL_refs.TLMenuCleanup
    end, _handleError)
end)

task.spawn(function()
    local ok, src = pcall(function() return (game :: any):HttpGet(EMOTEWHEEL_URL) end)
    if ok and src and #src > 10 then
        pcall(loadstring(src))
    end
end)