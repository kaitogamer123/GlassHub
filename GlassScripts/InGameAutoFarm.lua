-- Файл: GlassScripts/InGameAutoFarm.lua
return function()
    if _G.InGameLoopActive then return end
    _G.InGameLoopActive = true

    local AutoFarmCmds = require(game:GetService("ReplicatedStorage").Library.Child("Library").Client.AutoFarmCmds)
    
    task.spawn(function()
        local lastState = nil 
        
        while true do
            -- Кнопка в GUI меняет _G.AutoFarmEnabled (так как мы их приравняли)
            local currentState = _G.AutoFarmEnabled
            
            if currentState ~= lastState then
                if currentState == true then
                    pcall(function() AutoFarmCmds.Enable() end)
                else
                    pcall(function() AutoFarmCmds.Disable() end)
                end
                lastState = currentState
            end
            
            task.wait(0.5)
        end
    end)
end
