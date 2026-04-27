-- Файл: GlassScripts/EasterManager.lua
return function()
    local Lib = game:GetService("ReplicatedStorage"):WaitForChild("Library")
    local Save = require(Lib:WaitForChild("Client"):WaitForChild("Save"))
    local Net = require(Lib:WaitForChild("Client"):WaitForChild("Network"))
    local UpgradeRemote = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("EventUpgrades: Purchase")

    local tokenMapping = {
        ["Spring Bluebell Token"] = "Bluebell",
        ["Spring Red Tulip Token"] = "RedTulip",
        ["Spring Pink Rose Token"] = "PinkRose",
        ["Spring Yellow Sunflower Token"] = "Sunflower"
    }

    task.spawn(function()
        while true do
            if getgenv().AutoEasterManager then
                pcall(function()
                    local inv = Save.Get().Inventory.Misc or {}
                    local eggId = getgenv().SelectedEasterEgg or "Easter2026Egg8"
                    
                    -- ШАГ 1: АПГРЕЙДЫ (Цикл по всем включенным типам)
                    -- Ожидаем таблицу вида {Luck = true, ShinyLuck = false, ...}
                    local upgrades = getgenv().SelectedEasterUpgrades or {}
                    
                    for track, enabled in pairs(upgrades) do
                        if enabled then
                            local upgradeId = eggId .. track
                            -- Покупаем уровни, пока хватает валюты
                            local bought
                            repeat
                                bought = UpgradeRemote:InvokeServer(upgradeId)
                                if bought then task.wait(0.1) end
                            until not bought or not getgenv().AutoEasterManager
                        end
                    end

                    -- ШАГ 2: МАШИНА УДАЧИ (Цикл по всем включенным бустам)
                    -- Ожидаем таблицу вида {Huge = true, Titanic = true, ...}
                    local luckBoosts = getgenv().SelectedEasterLuckBoosts or {}

                    for boostType, enabled in pairs(luckBoosts) do
                        if enabled then
                            for _, item in pairs(inv) do
                                local internalKey = tokenMapping[item.id]
                                -- Оставляем запас 5000 токенов
                                if internalKey and (item._am or 0) > 5000 then
                                    local amountToUse = item._am - 5000
                                    Net.Invoke("Easter2026ChanceMachine_AddTime", boostType, internalKey, amountToUse)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(60) -- Проверка раз в минуту
        end
    end)
end
