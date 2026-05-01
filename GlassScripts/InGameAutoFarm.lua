local scriptID = os.clock()
getgenv().CurrentInGameID = scriptID

-- Функция для получения СВЕЖЕЙ версии модуля
local function getActiveCmd()
    local s, res = pcall(function() 
        return require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds) 
    end)
    return s and res
end

task.spawn(function()
    while true do
        -- Убиваем старый цикл при обновлении
        if getgenv().CurrentInGameID ~= scriptID then break end

        if getgenv().ForceInGameFarm then
            local CurrentCmd = getActiveCmd()
            
            if CurrentCmd then
                -- Проверяем именно актуальную версию модуля
                if not CurrentCmd.Active then
                    pcall(function() CurrentCmd.Enable() end)
                end
            end
        end
        task.wait(1.5) -- Увеличил задержку, чтобы игра успела обновить поля
    end
end)

return function(state)
    getgenv().ForceInGameFarm = state
    local CurrentCmd = getActiveCmd()
    if CurrentCmd then
        if state then pcall(function() CurrentCmd.Enable() end)
        else pcall(function() CurrentCmd.Disable() end) end
    end
end
