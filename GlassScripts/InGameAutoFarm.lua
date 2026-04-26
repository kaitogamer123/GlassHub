-- Файл: GlassScripts/InGameAutoFarm.lua
return function()
    if getgenv().InGameFarmLoopStarted then return end
    getgenv().InGameFarmLoopStarted = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local AutoFarmCmds = require(ReplicatedStorage.Library.Client.AutoFarmCmds)

    task.spawn(function()
        while true do
            -- Проверяем глобальную переменную, которую меняет твоя кнопка
            if getgenv().AutoFarmEnabled == true then 
                local success, isEnabled = pcall(function() return AutoFarmCmds.IsEnabled() end)
                
                if success and not isEnabled then
                    pcall(function() 
                        AutoFarmCmds.Enable() 
                        -- print("🧊 GlassHub: Принудительное переподключение фарма")
                    end)
                end
            elseif getgenv().AutoFarmEnabled == false then
                -- Если кнопку отжали, один раз выключаем и ждем
                if AutoFarmCmds.IsEnabled() then
                    pcall(function() AutoFarmCmds.Disable() end)
                end
            end
            task.wait(1) -- Проверка раз в секунду, чтобы не лагало
        end
    end)
    print("🧊 GlassHub: Логика автофарма инициализирована")
end
