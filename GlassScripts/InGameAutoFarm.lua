local Cmd = require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds)
getgenv().GlassInGameActive = false

-- Запускаем цикл один раз при загрузке скрипта
task.spawn(function()
    while true do
        if getgenv().GlassInGameActive then
            if not Cmd.Active then -- Используем Active вместо IsEnabled() для скорости
                pcall(function() Cmd.Enable() end)
            end
        end
        task.wait(1)
    end
end)

return function(state)
    getgenv().GlassInGameActive = state
    if not state then
        pcall(function() Cmd.Disable() end)
    end
    print("In-Game Farm State:", state)
end
