-- Файл: GlassScripts/EasterManager.lua
return function()
    local Lib = game:GetService("ReplicatedStorage"):WaitForChild("Library")
    local Save = require(Lib:WaitForChild("Client"):WaitForChild("Save"))
    local Net = require(Lib:WaitForChild("Client"):WaitForChild("Network"))
    
    -- Модули машин из твоих скриптов
    local ChanceMachineCmds = require(Lib:WaitForChild("Client"):WaitForChild("Easter2026ChanceMachineCmds"))
    local ChanceMachineTypes = require(Lib:WaitForChild("Library"):WaitForChild("Types"):WaitForChild("Easter2026ChanceMachine"))
    local UpgradeCmds = require(Lib:WaitForChild("Client"):WaitForChild("EventUpgradeCmds"))
    local UpgradeDirectory = require(Lib:WaitForChild("Library"):WaitForChild("Directory"):WaitForChild("EventUpgrades"))
    local EasterTypes = require(Lib:WaitForChild("Library"):WaitForChild("Types"):WaitForChild("Easter2026"))

    local tokenMapping = {
        ["Spring Bluebell Token"] = "Bluebell",
        ["Spring Red Tulip Token"] = "RedTulip",
        ["Spring Pink Rose Token"] = "PinkRose",
        ["Spring Yellow Sunflower Token"] = "Sunflower",
        ["Spring Boss Chest Token"] = "BossChest"
    }

    task.spawn(function()
        while true do
            if getgenv().AutoEasterManager then
                pcall(function()
                    local currentSave = Save.Get()
                    local inv = currentSave.Inventory.Misc or {}
                    
                    -- ОПРЕДЕЛЯЕМ ЦЕЛЕВОЕ ЯЙЦО (из GUI или активное в игре)
                    local activeEggNum = currentSave.Easter2026ActiveEgg or 1
                    local targetEggNum = getgenv().SelectedEasterEggNum or activeEggNum
                    local eggPrefix = "Easter2026Egg" .. targetEggNum

                    -- 1. ЛОГИКА UPGRADE MACHINE (Прокачка веток)
                    local selectedUpgrades = getgenv().SelectedEasterUpgrades or {}
                    for track, enabled in pairs(selectedUpgrades) do
                        if enabled then
                            local upgradeData = UpgradeDirectory[eggPrefix .. track]
                            if upgradeData then
                                -- Проверка: не макс ли уровень
                                if UpgradeCmds.GetTier(upgradeData) < #upgradeData.TierPowers then
                                    -- Покупка через официальный модуль
                                    local success = UpgradeCmds.Purchase(upgradeData)
                                    if success then
                                        print("🚀 [UPGRADE]: Куплен " .. track .. " для Egg " .. targetEggNum)
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                    end

                    -- 2. ЛОГИКА CHANCE MACHINE (Заливка удачи)
                    local luckBoosts = getgenv().SelectedEasterLuckBoosts or {}
                    local maxSeconds = ChanceMachineCmds.GetMaxBoostSeconds()

                    for boostType, enabled in pairs(luckBoosts) do
                        if enabled and ChanceMachineCmds.GetBoostTime(boostType) < maxSeconds then
                            for _, item in pairs(inv) do
                                local internalTokenName = tokenMapping[item.id]
                                if internalTokenName and (item._am or 0) > 5000 then
                                    local needed = ChanceMachineCmds.GetTokensToMax(boostType)
                                    local amountToUse = math.min(item._am - 5000, needed)
                                    
                                    if amountToUse > 0 then
                                        -- Заливка через официальный модуль
                                        local success = ChanceMachineCmds.AddBoost(boostType, internalTokenName, amountToUse)
                                        if success then
                                            print("🎯 [LUCK]: Влито " .. amountToUse .. " в " .. boostType)
                                        end
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(30) -- Проверка каждые 30 секунд
        end
    end)
end
