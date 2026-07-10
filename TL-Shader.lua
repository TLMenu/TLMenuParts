


local GLOBAL_ENV = (typeof(getgenv) == "function" and getgenv()) or _G
local RUNTIME_KEY = "__TL_ShaderRuntime"

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

local Lighting = game:GetService("Lighting")

local _shActive = false
local _shInsts  = {}
local _origLighting = nil

local function shClean()
    for _, v in ipairs(_shInsts) do pcall(function() v:Destroy() end) end
    _shInsts = {}
    if _origLighting then
        pcall(function()
            Lighting.Brightness = _origLighting.Brightness
            Lighting.Ambient = _origLighting.Ambient
            Lighting.OutdoorAmbient = _origLighting.OutdoorAmbient
            Lighting.ClockTime = _origLighting.ClockTime
            Lighting.ExposureCompensation = _origLighting.Exposure
            Lighting.EnvironmentDiffuseScale = _origLighting.Diff
            Lighting.EnvironmentSpecularScale = _origLighting.Spec
        end)
        _origLighting = nil
    end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child.Name:find("TLShader_") then pcall(function() child:Destroy() end) end
    end
end

local function shApply()
    shClean()
    if not _origLighting then
        _origLighting = {
            Brightness = Lighting.Brightness,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ClockTime = Lighting.ClockTime,
            Exposure = Lighting.ExposureCompensation,
            Diff = Lighting.EnvironmentDiffuseScale,
            Spec = Lighting.EnvironmentSpecularScale
        }
    end

    pcall(function()
        Lighting.Brightness = 2.25
        Lighting.ClockTime = 17.55
        Lighting.ExposureCompensation = 0.1
        Lighting.Technology = Enum.Technology.Future
    end)

    local function mk(cls, name, props)
        local inst = Instance.new(cls)
        inst.Name = "TLShader_" .. name
        for k, v in pairs(props) do inst[k] = v end
        inst.Parent = Lighting
        table.insert(runtime.instances, inst)
        return inst
    end

    mk("ColorCorrectionEffect", "Color", {
        Brightness = 0,
        Contrast = 0.1,
        Saturation = 0.25,
        TintColor = Color3.fromRGB(255, 255, 255)
    })
    mk("BloomEffect", "Bloom", {
        Enabled = true, Intensity = 0.3, Size = 10, Threshold = 0.8
    })
    mk("SunRaysEffect", "Sun", {
        Enabled = true, Intensity = 0.1, Spread = 0.8
    })
    mk("Sky", "Sky", {
        SkyboxBk = "rbxassetid://144933338",
        SkyboxDn = "rbxassetid://144931530",
        SkyboxFt = "rbxassetid://144933262",
        SkyboxLf = "rbxassetid://144933244",
        SkyboxRt = "rbxassetid://144933299",
        SkyboxUp = "rbxassetid://144931564",
        SunAngularSize = 5,
        StarCount = 5000
    })
end

local API = {}

API.start = function()
    if _shActive then return end
    _shActive = true
    pcall(shApply)
end

API.stop = function()
    if not _shActive then return end
    _shActive = false
    shClean()
end

API.toggle = function()
    if _shActive then API.stop() else API.start() end
end

API.isActive = function() return _shActive end

API.cleanup = function()
    API.stop()
    runtime.cleanup()
end


if GLOBAL_ENV then
    GLOBAL_ENV._TL_setShader    = API.toggle
    GLOBAL_ENV._TL_shaderActive = API.isActive
end

runtime.start    = API.start
runtime.stop     = API.stop
runtime.isActive = API.isActive

return API
