-- Файл: GlassScripts/InGameAutoFarm.lua
return function()
    if getgenv().InGameLoopActive then return end
    getgenv().InGameLoopActive = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Library = ReplicatedStorage:WaitForChild("Library")
    local AutoFarmCmds = require(Library.Client.AutoFarmCmds)

    -- Синхронизируем: если в меню уже нажато, подхватываем значение
    if getgenv().AutoFarmEnabled == nil then
        getgenv().AutoFarmEnabled = false 
    end

    task.spawn(function()
        while true do
            -- Используем строго getgenv(), так как кнопка в лоадере меняет именно его
            if getgenv().AutoFarmEnabled then
                if not AutoFarmCmds.IsEnabled() then
                    pcall(function()
                        AutoFarmCmds.Enable()
                    end)
                end
            else
                if AutoFarmCmds.IsEnabled() then
                    pcall(function()
                        AutoFarmCmds.Disable()
                    end)
                end
            end
            task.wait(0.5) -- Оптимальная задержка
        end
    end)
    print("🧊 GlassHub: Рабочий цикл исправлен и запущен!")
end
