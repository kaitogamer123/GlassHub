local scriptID = os.clock()
getgenv().CurrentInGameID = scriptID

-- Функция для получения СВЕЖЕЙ версии модуля
local function getActiveCmd()
    local s, res = pcall(function() 
        return require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds) 
    end)
    return s and res
end


return function(state)
    getgenv().ForceInGameFarm = state
    local CurrentCmd = getActiveCmd()
    if CurrentCmd then
        if state then pcall(function() CurrentCmd.Enable() end)
        else pcall(function() CurrentCmd.Disable() end) end
    end
end
