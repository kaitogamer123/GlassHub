-- Файл: GlassScripts/InGameAutoFarm.lua
return function()
    if getgenv().InGameFarmLoaded then return end
    getgenv().InGameFarmLoaded = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Library = ReplicatedStorage:WaitForChild("Library")
    local AutoFarmCmds = require(Library.Client.AutoFarmCmds)

    -- Принудительно ставим выключенное состояние при первой загрузке
    getgenv().AutoFarmEnabled = false 

    task.spawn(function()
        while true do
            -- Ждем 1 секунду между проверками, чтобы не нагружать сервер
            task.wait(1)

            -- Если кнопка ВКЛЮЧЕНА (true)
            if getgenv().AutoFarmEnabled == true then
                if not AutoFarmCmds.IsEnabled() then
                    pcall(function()
                        AutoFarmCmds.Enable()
                        print("🧊 GlassHub: Игровой автофарм ВКЛЮЧЕН")
                    end)
                end
            -- Если кнопка ВЫКЛЮЧЕНА (false)
            elseif getgenv().AutoFarmEnabled == false then
                if AutoFarmCmds.IsEnabled() then
                    pcall(function()
                        AutoFarmCmds.Disable()
                        print("🧊 GlassHub: Игровой автофарм ВЫКЛЮЧЕН")
                    end)
                end
            end
        end
    end)
    
    print("🧊 GlassHub: Внутриигровой автофарм инициализирован (OFF).")
end
