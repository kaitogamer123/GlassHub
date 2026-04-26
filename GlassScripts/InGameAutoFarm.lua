-- Файл: GlassScripts/InGameAutoFarm.lua
return function()
    -- Чтобы не запускать цикл дважды
    if getgenv().InGameLoopActive then return end
    getgenv().InGameLoopActive = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Library = ReplicatedStorage:WaitForChild("Library")
    local AutoFarmCmds = require(Library.Client.AutoFarmCmds)

    -- Изначально ВЫКЛЮЧЕНО
    getgenv().AutoFarmEnabled = false 

    task.spawn(function()
        while true do
            -- Используем getgenv(), чтобы кнопка из GUI могла менять это значение
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
            task.wait(1)
        end
    end)
    print("🧊 GlassHub: Рабочий цикл автофарма загружен!")
end
