-- Файл: GlassScripts/InGameAutoFarm.lua
return function()
    local AutoFarmCmds = require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds)

    task.spawn(function()
        while true do
            -- Используем getgenv, чтобы кнопка из лоадера (выше) работала
            if getgenv().AutoFarmEnabled then
                if not AutoFarmCmds.IsEnabled() then
                    pcall(function() AutoFarmCmds.Enable() end)
                end
            else
                if AutoFarmCmds.IsEnabled() then
                    pcall(function() AutoFarmCmds.Disable() end)
                end
            end
            task.wait(1) 
        end
    end)
end
