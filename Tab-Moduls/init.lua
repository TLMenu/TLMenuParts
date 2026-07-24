--!nocheck
-- Tab-Moduls index and loader

local TabModuls = {
    Home = require and script and script:FindFirstChild('HomeTab') or nil,
    Character = require and script and script:FindFirstChild('CharacterTab') or nil,
    Scripts = require and script and script:FindFirstChild('ScriptsTab') or nil,
    Actions = require and script and script:FindFirstChild('ActionsTab') or nil,
    Settings = require and script and script:FindFirstChild('SettingsTab') or nil,
    Communication = require and script and script:FindFirstChild('CommunicationTab') or nil,
    Playerlist = require and script and script:FindFirstChild('PlayerlistTab') or nil,
    NametagSystem = require and script and script:FindFirstChild('NametagSystem') or nil,
}

function TabModuls.LoadAll(ctx)
    local results = {}
    local tabs = {'Home', 'Character', 'Scripts', 'Actions', 'Settings', 'Communication', 'Playerlist', 'NametagSystem'}
    for _, tabName in ipairs(tabs) do
        local modName = tabName .. 'Tab'
        local ok, mod
        if type(readfile) == 'function' and type(loadstring) == 'function' then
            local path = 'Tab-Moduls/' .. modName .. '.lua'
            if isfile and isfile(path) then
                mod = loadstring(readfile(path))()
            end
        end
        if not mod and TabModuls[tabName] then
            mod = TabModuls[tabName]
        end
        if mod and type(mod.Init) == 'function' then
            results[tabName] = mod.Init(ctx)
        end
    end
    return results
end

return TabModuls
