-- Файл: GlassScripts/InGameAutoFarm.lua
return function()
    if getgenv().InGameFarmLoaded then return end
    getgenv().InGameFarmLoaded = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Library = ReplicatedStorage:WaitForChild("Library")
    local AutoFarmCmds = require(Library.Client.AutoFarmCmds)

    task.spawn(function()
        while true do
            -- Используем переменную getgenv().AutoFarmEnabled для связи с кнопкой
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
    
    print("🧊 GlassHub: Внутриигровой автофарм готов к работе.")
end
