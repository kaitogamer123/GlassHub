
local farmActive = false
local farmLoop = nil

return function(state)
    farmActive = state
    
    local success, err = pcall(function()
        local Cmd = require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds)
        
        if farmActive then
            -- Если фарм включили, запускаем защитный цикл
            if not farmLoop then
                farmLoop = task.spawn(function()
                    while farmActive do
                        -- Принудительно проверяем статус фарма. 
                        -- Если он выключен кем-то другим — включаем.
                        if not Cmd.Active then 
                            Cmd.Enable()
                        end
                        task.wait(0.5) -- Оптимальная задержка
                    end
                end)
            end
            print("🧊 [GlassHub]: In-Game Farm FORCED ON")
        else
            -- Если выключаем, останавливаем цикл и выключаем фарм
            farmActive = false
            farmLoop = nil
            Cmd.Disable()
            print("🧊 [GlassHub]: In-Game Farm Disabled")
        end
    end)
    
    if not success then
        warn("InGameAutoFarm Error: " .. tostring(err))
    end
end
