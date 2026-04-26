-- Файл: GlassScripts/InGameAutoFarm.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local AutoFarmCmds = require(Library.Client.AutoFarmCmds)

local Functions = {}

-- Функция включения
Functions.Enable = function()
    pcall(function()
        if not AutoFarmCmds.IsEnabled() then
            AutoFarmCmds.Enable()
            print("🧊 GlassHub: Официальный фарм ВКЛЮЧЕН")
        end
    end)
end

-- Функция выключения
Functions.Disable = function()
    pcall(function()
        if AutoFarmCmds.IsEnabled() then
            AutoFarmCmds.Disable()
            print("🧊 GlassHub: Официальный фарм ВЫКЛЮЧЕН")
        end
    end)
end

return Functions
