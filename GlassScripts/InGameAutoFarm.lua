-- Файл: GlassScripts/InGameAutoFarm.lua
return function()
    -- Глобальная защита от дубликатов цикла
    if getgenv().InGameLoopActive then 
        print("🧊 GlassHub: Цикл уже запущен, пропускаю дубликат.")
        return 
    end
    getgenv().InGameLoopActive = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Library = ReplicatedStorage:WaitForChild("Library")
    local AutoFarmCmds = require(Library.Client.AutoFarmCmds)

    task.spawn(function()
        print("🧊 GlassHub: Система контроля автофарма активна")
        
        while true do
            -- Проверяем, что хочет пользователь через GUI
            local wantEnabled = getgenv().AutoFarmEnabled
            local isCurrentlyEnabled = AutoFarmCmds.IsEnabled()

            if wantEnabled then
                -- Включаем ТОЛЬКО если еще не включено
                if not isCurrentlyEnabled then
                    pcall(function()
                        AutoFarmCmds.Enable()
                    end)
                    print("🧊 AutoFarm: Активирован")
                end
            else
                -- Выключаем ТОЛЬКО если еще включено
                if isCurrentlyEnabled then
                    pcall(function()
                        AutoFarmCmds.Disable()
                    end)
                    print("🧊 AutoFarm: Деактивирован")
                end
            end
            
            task.wait(1) -- Не ставь меньше 1 секунды, чтобы игра успевала обработать запрос
        end
    end)
end
