local Cmd = require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds)

-- Защита от дублирования циклов
if not getgenv().InGameLoopStarted then
    getgenv().InGameLoopStarted = true
    task.spawn(function()
        while true do
            if getgenv().ForceInGameFarm then
                if not Cmd.Active then 
                    pcall(function() Cmd.Enable() end) 
                end
            end
            task.wait(1) -- Проверка раз в секунду, без принтов
        end
    end)
end

return function(state)
    getgenv().ForceInGameFarm = state
    if state then
        pcall(function() Cmd.Enable() end)
    else
        pcall(function() Cmd.Disable() end)
    end
end
