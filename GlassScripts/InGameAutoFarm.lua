-- Файл: GlassScripts/InGameAutoFarm.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local AutoFarmCmds = require(Library.Client.AutoFarmCmds)

-- Возвращаем таблицу с функциями напрямую
return {
    Enable = function()
        pcall(function()
            if not AutoFarmCmds.IsEnabled() then
                AutoFarmCmds.Enable()
                print("🧊 GlassHub: Включено")
            end
        end)
    end,
    Disable = function()
        pcall(function()
            if AutoFarmCmds.IsEnabled() then
                AutoFarmCmds.Disable()
                print("🧊 GlassHub: Выключено")
            end
        end)
    end
}
