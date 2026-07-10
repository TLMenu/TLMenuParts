

local MarketplaceService = game:GetService("MarketplaceService")


local placeId = game.PlaceId
local universeId = 0
pcall(function() universeId = tonumber(game.GameId) or 0 end)

local gameTitle = tostring(game.Name)
pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
    if info and type(info.Name) == "string" and info.Name ~= "" then
        gameTitle = info.Name
    end
end)


local gameThumb = "rbxasset://textures/ui/GuiImagePlaceholder.png"
if universeId > 0 then
    gameThumb = "rbxthumb://type=GameIcon&id=" .. tostring(universeId) .. "&w=256&h=256"
end


local GAME_REGISTRY = {
    [136162036182779] = {
        name     = "German Voice",
        manifest = "ALV-SCRIPTS/ALV-GAMES/GERMANVOICE/manifest.json",
        basePath = "ALV-SCRIPTS/ALV-GAMES/GERMANVOICE/",
    },
}

local registeredGame = GAME_REGISTRY[placeId]


local isGermanVoice = false

if placeId == 8573215907 or placeId == 136162036182779 then
    isGermanVoice = true
else
    pcall(function()
        local info = MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
        if info and type(info.Name) == "string" then
            local lower = string.lower(info.Name)
            if string.find(lower, "german") and string.find(lower, "voice") then
                isGermanVoice = true
            end
        end
    end)
end


return {
    placeId       = placeId,
    universeId    = universeId,
    gameTitle     = gameTitle,
    gameThumb     = gameThumb,
    isGermanVoice = isGermanVoice,
    registeredGame = registeredGame,
}
