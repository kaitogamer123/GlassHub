
-- Файл: GlassScripts/InGameAutoFarm.lua
return function(v)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local AutoFarmCmds = require(ReplicatedStorage.Library.Client.AutoFarmCmds)
    local Library = ReplicatedStorage:WaitForChild("Library")
    
    if v then
        pcall(function() AutoFarmCmds.Enable() end)
        print("🧊 GlassHub: Отправлена команда ENABLE")
    else
        pcall(function() AutoFarmCmds.Disable() end)
        print("🧊 GlassHub: Отправлена команда DISABLE")
    end
end
