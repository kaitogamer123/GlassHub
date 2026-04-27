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
                    
                    -- Собираем ID апгрейда (Например: Easter2026Egg8 + Luck)
                    local eggId = getgenv().SelectedEasterEgg or "Easter2026Egg8"
                    local track = getgenv().SelectedEasterUpgrade or "Luck"
                    local upgradeId = eggId .. track

                    -- ШАГ 1: Покупаем выбранный апгрейд
                    if track ~= "None" then
                        local bought
                        repeat
                            bought = UpgradeRemote:InvokeServer(upgradeId)
                            task.wait(0.1)
                        until not bought or not getgenv().AutoEasterManager
                    end

                    -- ШАГ 2: Машина удачи
                    local boostType = getgenv().SelectedEasterLuck or "Huge"
                    if boostType ~= "None" then
                        for _, item in pairs(inv) do
                            local internalKey = tokenMapping[item.id]
                            if internalKey and (item._am or 0) > 5000 then
                                Net.Invoke("Easter2026ChanceMachine_AddTime", boostType, internalKey, item._am)
                            end
                        end
                    end
                end)
            end
            task.wait(60) -- Проверка раз в минуту
        end
    end)
end
