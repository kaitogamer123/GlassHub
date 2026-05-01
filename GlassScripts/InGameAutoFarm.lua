local Cmd = require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds)

return function(state)
    getgenv().ForceInGameFarm = state -- Это ГЛАВНЫЙ ФЛАГ для всех остальных скриптов
    if state then
        Cmd.Enable()
    else
        Cmd.Disable()
    end
end
