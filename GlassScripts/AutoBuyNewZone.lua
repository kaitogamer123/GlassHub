local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ZoneCmds = require(ReplicatedStorage.Library.Client.ZoneCmds)
local ZonesUtil = require(ReplicatedStorage.Library.Util.ZonesUtil)
local Network = require(ReplicatedStorage.Library.Client.Network)

_G.AutoBuyNewZone = false

local function buyNextZone()
    -- Получаем текущую максимальную зону
    local _, maxZoneData = ZoneCmds.GetMaxOwnedZone()
    
    if maxZoneData and maxZoneData.ZoneNumber then
        -- Ищем данные следующей зоны (+1)
        local _, nextZoneData = ZonesUtil.GetZoneFromNumber(maxZoneData.ZoneNumber + 1)
        
        if nextZoneData and nextZoneData.ZoneName then
            -- Отправляем запрос на покупку
            local success = Network.Invoke("Zones_RequestPurchase", nextZoneData.ZoneName)
            if success then
                print("🧊 [AutoBuy]: Куплена новая зона: " .. nextZoneData.ZoneName)
            end
        end
    end
end

-- Основной цикл
task.spawn(function()
    print("🧊 [GlassHub]: Auto Buy Zones Loaded")
    while true do
        if _G.AutoBuyNewZone then
            pcall(buyNextZone)
        end
        task.wait(2) -- Проверка каждые 2 секунды
    end
end)

-- Функция управления для лоадера
return function(state)
    _G.AutoBuyNewZone = state
end
