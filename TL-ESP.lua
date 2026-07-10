


local GLOBAL_ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_ESPRuntime"

local prev = GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY]
if type(prev) == "table" and type(prev.cleanup) == "function" then pcall(prev.cleanup) end

local runtime = { connections = {}, instances = {}, destroyed = false }
runtime.cleanup = function()
    if runtime.destroyed then return end; runtime.destroyed = true
    for _, c in ipairs(runtime.connections) do pcall(function() c:Disconnect() end) end
    runtime.connections = {}
    for i = #runtime.instances, 1, -1 do
        pcall(function() local inst = runtime.instances[i]; if inst and inst.Parent then inst:Destroy() end end)
    end
    runtime.instances = {}
    if GLOBAL_ENV and GLOBAL_ENV[RUNTIME_KEY] == runtime then GLOBAL_ENV[RUNTIME_KEY] = nil end
end
if GLOBAL_ENV then GLOBAL_ENV[RUNTIME_KEY] = runtime end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer


local function getC()
    if GLOBAL_ENV and GLOBAL_ENV.C then return GLOBAL_ENV.C end
    return {
        text  = Color3.fromRGB(255, 255, 255),
        sub   = Color3.fromRGB(156, 156, 156),
        accent = Color3.fromRGB(99, 102, 241),
    }
end


local espEnabled      = false
local espData         = {}
local espCharConns    = {}
local espHighlights   = {}
local espBillboards   = {}
local _espRadConn     = nil
local espColorIdx     = 1

local ESP_COLORS = {
    { name = "White",  color = Color3.fromRGB(255, 255, 255) },
    { name = "Red",    color = Color3.fromRGB(220, 50, 50) },
    { name = "Green",  color = Color3.fromRGB(60, 230, 100) },
    { name = "Blue",   color = Color3.fromRGB(60, 140, 255) },
    { name = "Cyan",   color = Color3.fromRGB(0, 220, 220) },
    { name = "Pink",   color = Color3.fromRGB(255, 100, 200) },
    { name = "Orange", color = Color3.fromRGB(255, 160, 40) },
    { name = "Yellow", color = Color3.fromRGB(255, 230, 40) },
    { name = "Purple", color = Color3.fromRGB(180, 80, 255) },
    { name = "Black",  color = Color3.fromRGB(20, 20, 20) },
}

local ESP_NEAR_DIST_SQ = 110 * 110
local ESP_FILL_NEAR    = 0.6

local function espCurrentColor()
    return ESP_COLORS[espColorIdx].color
end


local function clearESP()
    local batch = 0
    for pl, d in pairs(espData) do
        if d.hl and d.hl.Parent then d.hl:Destroy() end
        if d.bb and d.bb.Parent then d.bb:Destroy() end
        batch += 1
        if batch % 12 == 0 then task.wait() end
    end
    espData       = {}
    espHighlights = {}
    espBillboards = {}
    for _, c in pairs(espCharConns) do
        if c then pcall(function() c:Disconnect() end) end
    end
    espCharConns = {}
end

local function applyESPToChar(pl, char)
    if not espEnabled then return end
    local d = espData[pl]
    if d and d.hl and d.hl.Parent then d.hl:Destroy() end
    if d and d.bb and d.bb.Parent then d.bb:Destroy() end
    local col = espCurrentColor()
    local hl
    local hlOk = pcall(function()
        hl                     = Instance.new("Highlight")
        hl.Adornee             = char
        hl.FillTransparency    = 1
        hl.FillColor           = col
        hl.OutlineColor        = col
        hl.OutlineTransparency = 0
        hl.Parent              = char
    end)
    if not hlOk or not hl or not hl.Parent then
        pcall(function()
            hl                     = Instance.new("SelectionBox")
            hl.Adornee             = char:FindFirstChild("HumanoidRootPart") or char
            hl.Color3              = col
            hl.LineThickness       = 0
            hl.SurfaceTransparency = 0.9
            hl.SurfaceColor3       = col
            hl.Parent              = char
        end)
    end
    local head = char:FindFirstChild("Head")
    local bb, lbl
    if head then
        pcall(function()
            bb                         = Instance.new("BillboardGui")
            bb.Name                    = "ESP_BB"
            bb.Adornee                 = head
            bb.Size                    = UDim2.new(0, 120, 0, 20)
            bb.StudsOffset             = Vector3.new(0, 2.4, 0)
            bb.AlwaysOnTop             = true
            bb.ResetOnSpawn            = false
            bb.Enabled                 = true
            bb.Parent                  = head
            lbl                        = Instance.new("TextLabel", bb)
            lbl.Size                   = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text                   = pl.DisplayName
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextSize               = 13
            lbl.TextColor3             = col
            lbl.TextStrokeColor3       = Color3.new(0, 0, 0)
            lbl.TextStrokeTransparency = 0
            lbl.TextTransparency       = 0
            lbl.TextXAlignment         = Enum.TextXAlignment.Center
            lbl.TextYAlignment         = Enum.TextYAlignment.Center
            lbl.Name                   = "NameLbl"
        end)
    end
    espData[pl] = { hl = hl, bb = bb, lbl = lbl, lastNear = false, lastNameVis = false }
    espHighlights[pl] = hl
    espBillboards[pl] = bb
end

local function addESPPlayer(pl)
    if not espEnabled or pl == lp then return end
    if espCharConns[pl] then pcall(function() espCharConns[pl]:Disconnect() end) end
    espCharConns[pl] = pl.CharacterAdded:Connect(function(char)
        if espData[pl] then espData[pl].cachedRoot = nil end
        task.wait(0.15)
        applyESPToChar(pl, char)
    end)
    table.insert(runtime.connections, espCharConns[pl])
    if espData[pl] and espData[pl].hl and espData[pl].hl.Parent then return end
    espData[pl] = {}
    if pl.Character then
        applyESPToChar(pl, pl.Character)
    else
        task.spawn(function()
            local char = pl.Character
            if not char then
                local conn; conn = pl.CharacterAdded:Wait()
                char = conn
            end
            task.wait(0.15)
            if espEnabled and pl and pl.Parent then
                applyESPToChar(pl, pl.Character or char)
            end
        end)
    end
end

local function startESPRadiusLoop()
    if _espRadConn then _espRadConn:Disconnect() end
    local _espAcc = 0
    local _espMyRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local charConn = lp.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        _espMyRoot = char:FindFirstChild("HumanoidRootPart")
    end)
    table.insert(runtime.connections, charConn)
    _espRadConn = RunService.Heartbeat:Connect(function(dt)
        if not espEnabled then return end
        _espAcc = _espAcc + dt
        if _espAcc < 0.25 then return end
        _espAcc = 0
        local myRoot = _espMyRoot
        if not myRoot or not myRoot.Parent then
            local c = lp.Character
            myRoot = c and c:FindFirstChild("HumanoidRootPart")
            _espMyRoot = myRoot
        end
        if not myRoot then return end
        local myPosX = myRoot.Position.X
        local myPosY = myRoot.Position.Y
        local myPosZ = myRoot.Position.Z
        for pl, d in pairs(espData) do
            local hl = d.hl
            if hl and hl.Parent then
                local tRoot = d.cachedRoot
                if not tRoot or not tRoot.Parent then
                    local tChar = pl.Character
                    tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                    d.cachedRoot = tRoot
                end
                local distSq = math.huge
                if tRoot and tRoot.Parent then
                    local dx = tRoot.Position.X - myPosX
                    local dy = tRoot.Position.Y - myPosY
                    local dz = tRoot.Position.Z - myPosZ
                    distSq = dx * dx + dy * dy + dz * dz
                end
                local wantNear = distSq <= ESP_NEAR_DIST_SQ
                if wantNear ~= d.lastNear then
                    hl.FillTransparency = wantNear and ESP_FILL_NEAR or 1
                    d.lastNear = wantNear
                end
                local bb = d.bb
                if not bb or not bb.Parent then
                    local tChar = pl.Character
                    local tHead = tChar and tChar:FindFirstChild("Head")
                    bb          = tHead and tHead:FindFirstChild("ESP_BB")
                    d.bb        = bb
                    d.lbl       = bb and bb:FindFirstChild("NameLbl")
                    d.lastNameVis = false
                end
                if bb and bb.Parent and not d.lastNameVis then
                    bb.Enabled    = true
                    d.lastNameVis = true
                end
            end
        end
    end)
    table.insert(runtime.connections, _espRadConn)
end

local function setESP(on)
    espEnabled = on
    clearESP()
    if on then
        local batch = 0
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= lp then
                addESPPlayer(pl)
                batch += 1
                if batch % 8 == 0 then task.wait() end
            end
        end
        startESPRadiusLoop()
    else
        if _espRadConn then
            _espRadConn:Disconnect(); _espRadConn = nil
        end
    end
end

local function refreshESPColor()
    local col = espCurrentColor()
    for pl, d in pairs(espData) do
        if d.hl and d.hl.Parent then
            d.hl.FillColor    = col
            d.hl.OutlineColor = col
        end
        if d.lbl then d.lbl.TextColor3 = col end
    end
end

local function removeESPPlayer(pl)
    local d = espData[pl]
    if d then
        if d.hl and d.hl.Parent then pcall(function() d.hl:Destroy() end) end
        if d.bb and d.bb.Parent then pcall(function() d.bb:Destroy() end) end
        espData[pl] = nil
    end
    espHighlights[pl] = nil
    espBillboards[pl] = nil
    if espCharConns[pl] then
        pcall(function() espCharConns[pl]:Disconnect() end)
        espCharConns[pl] = nil
    end
end


local playerAddedConn = Players.PlayerAdded:Connect(function(pl)
    task.spawn(function()
        for attempt = 1, 6 do
            task.wait(attempt == 1 and 0.5 or 1.0)
            if not espEnabled then return end
            if pl and pl.Parent then
                addESPPlayer(pl)
                if espData[pl] and espData[pl].hl and espData[pl].hl.Parent then return end
            end
        end
    end)
end)
table.insert(runtime.connections, playerAddedConn)

local playerRemovingConn = Players.PlayerRemoving:Connect(function(pl)
    removeESPPlayer(pl)
end)
table.insert(runtime.connections, playerRemovingConn)


local API = {}

API.start         = setESP
API.stop          = function() setESP(false) end
API.isActive      = function() return espEnabled end
API.refreshColor  = refreshESPColor
API.removePlayer  = removeESPPlayer

API.getColors     = function() return ESP_COLORS end
API.getColorIdx   = function() return espColorIdx end
API.setColorIdx   = function(idx)
    espColorIdx = idx
    refreshESPColor()
end
API.currentColor  = espCurrentColor

API.getHighlights = function() return espHighlights end
API.getBillboards = function() return espBillboards end

API.cleanup = function()
    setESP(false)
    clearESP()
    runtime.cleanup()
end


if GLOBAL_ENV then
    GLOBAL_ENV._TL_setESP       = API.start
    GLOBAL_ENV._TL_espActive    = API.isActive
    GLOBAL_ENV._TL_refreshESP   = refreshESPColor
    GLOBAL_ENV._TL_espColors    = ESP_COLORS
end

runtime.start     = API.start
runtime.stop      = API.stop
runtime.isActive  = API.isActive

return API
