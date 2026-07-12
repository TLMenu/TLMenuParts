-- TL-ROLE-DETECTOR: Staff/Creator detection system
-- Standalone module fetched and executed by TLMenu.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GroupService = game:GetService("GroupService")

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

local function refreshStaffDetectorUI()
    pcall(function()
        local _TL_refs = getgenv and getgenv()._TL_refs
        local fn = _TL_refs and _TL_refs._TL_rebuildPlayerList
        if type(fn) == "function" then fn() end
    end)
end

local function sendStaffDetectorNotification(title, text)
    local _TL_refs = getgenv and getgenv()._TL_refs
    local settingsState = _TL_refs and _TL_refs._TL_settingsState
    if settingsState and settingsState.notifications == false then return end
    pcall(function()
        local sendNotif = getgenv and getgenv()._TL_refs and getgenv()._TL_refs._TL_sendNotif
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

local function setStaffState(plr, isStaff, role, notifyOnDetect)
    local previousRole = trackedStaff[plr]
    local normalizedRole = (isStaff and role) or nil
    staffCheckCache[plr] = normalizedRole or false
    trackedStaff[plr] = normalizedRole
    if notifyOnDetect and normalizedRole and not previousRole then
        sendStaffDetectorNotification("Staff/Creator detected", plr.Name .. "\nRole: " .. normalizedRole)
        playStaffAlert()
    end
    if previousRole ~= normalizedRole then
        refreshStaffDetectorUI()
    end
    return isStaff, role
end

local function runStaffCheck(plr, notifyOnDetect, delaySec, onDone)
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
                sendStaffDetectorNotification("Staff/Creator detected", plr.Name .. "\nRole: " .. role)
                playStaffAlert()
                refreshStaffDetectorUI()
            end
            if onDone then onDone(isStaff, role) end
            return
        end
        local isStaff, role = checkPlayerForStaff(plr)
        setStaffState(plr, isStaff, role, notifyOnDetect)
        if onDone then onDone(isStaff, role) end
    end)
end

pcall(function()
    local _TL_refs = getgenv and getgenv()._TL_refs
    if _TL_refs then
        _TL_refs._TL_isThreatPlayer = function(plr)
            return trackedStaff[plr] ~= nil
        end
        _TL_refs._TL_getThreatRole = function(plr)
            return trackedStaff[plr]
        end
        _TL_refs._TL_checkThreatPlayer = function(plr, callback)
            runStaffCheck(plr, false, 0, callback)
        end
    end
end)

local function initialStaffScan()
    local playersInGame = Players:GetPlayers()
    for _, plr in ipairs(playersInGame) do
        runStaffCheck(plr, true, 0)
    end
    task.spawn(function()
        task.wait(1.2)
        if not next(trackedStaff) then
            sendStaffDetectorNotification("TLMenuSystem", "ModScan Completed!")
        end
    end)
end

initialStaffScan()

Players.PlayerAdded:Connect(function(plr)
    runStaffCheck(plr, true, 3)
end)

Players.PlayerRemoving:Connect(function(plr)
    staffCheckCache[plr] = nil
    if trackedStaff[plr] then
        local role = trackedStaff[plr]
        trackedStaff[plr] = nil
        sendStaffDetectorNotification("TLMenuSystem: Staff/Creator left",
            plr.Name .. "\nRole: " .. role .. "\nLeft the server.")
        refreshStaffDetectorUI()
        if not next(trackedStaff) then
            task.delay(1, function()
                if not next(trackedStaff) then
                    sendStaffDetectorNotification("TLMenuSystem:", "No Admin/Content-Creator Ingame.")
                end
            end)
        end
    end
end)
