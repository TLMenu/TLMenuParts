local M = {}
local _cfg = {}
local _active = false
local _isOpen = false

function M.init(cfg)
    _cfg = cfg or {}
end

function M.start()
    _active = true
end

function M.open()
    if not _active then M.start() end
    _isOpen = true
    pcall(function()
        warn("[TL] OutfitPanel: Panel opened (minimal stub)")
    end)
end

function M.close()
    _isOpen = false
end

function M.getIsOpen()
    return _isOpen
end

function M.openForPlayer(player)
    if not _active then M.start() end
    _isOpen = true
    pcall(function()
        warn("[TL] OutfitPanel: Opening for player " .. tostring(player and player.Name))
    end)
end

function M.isActive()
    return _active
end

return M
