-- Генерируем уникальный ID для каждой загрузки скрипта
local scriptID = os.clock() 
getgenv().CurrentInGameID = scriptID 

local Cmd = require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds)

-- Функция самого фарма
local function runFarm(state)
    getgenv().ForceInGameFarm = state
    if state then
        pcall(function() Cmd.Enable() end)
    else
        pcall(function() Cmd.Disable() end)
    end
end

-- Цикл с проверкой "свой-чужой"
task.spawn(function()
    while true do
        -- Если ID сменился (скрипт обновили) — этот цикл СТОПАЕТСЯ навсегда
        if getgenv().CurrentInGameID ~= scriptID then 
            break 
        end

        if getgenv().ForceInGameFarm then
            if not Cmd.Active then
                pcall(function() Cmd.Enable() end)
            end
        end
        task.wait(1)
    end
end)

return runFarm
