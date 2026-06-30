local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer

if not _G.SessionGoals then
    _G.SessionGoals = { gift = 0, huge1 = 0, huge2 = 0, titanic = 0, gargantuan = 0 }
end

task.spawn(function()
    local networkFolder = ReplicatedStorage:WaitForChild("Network")
    local invokeCustom = networkFolder:WaitForChild("Instancing_InvokeCustomFromClient")
    
    while true do
        if _G.AutoPerfectPowerActive then
            -- ХУК НА ИНТЕРМИССИЮ: Если вылезло уведомление о сбросе сфер — жестко спим 30 секунд
            if getgenv().SoccerNotificationPause then
                task.wait(30)
                getgenv().SoccerNotificationPause = false -- Сбрасываем флаг паузы после отдыха
            else
                local randomPower = math.random(94, 99) / 100
                local success, response = pcall(function() 
                    return invokeCustom:InvokeServer("SoccerEvent", "GZ_Step", randomPower) 
                end)
                
                local nextDelay = 0.02
                
                -- Если сервер ответил успешно и вернул таблицу данных
                if success and type(response) == "table" then
                    if response.Success == false then
                        -- Полный промах комбо: обнуляем внутренний счетчик
                        _G.SessionGoals = { gift = 0, huge1 = 0, huge2 = 0, titanic = 0, gargantuan = 0 }
                    else
                        -- Парсим попавшие кольца ворот
                        if type(response.Rings) == "table" and #response.Rings > 0 then
                            for _, ringData in pairs(response.Rings) do
                                local rawId = ringData.Id and tostring(ringData.Id)
                                if rawId then
                                    if rawId == "Gift" or rawId == "gift" then _G.SessionGoals.gift = _G.SessionGoals.gift + 1
                                    elseif rawId == "Huge1" or rawId == "huge1" then _G.SessionGoals.huge1 = _G.SessionGoals.huge1 + 1
                                    elseif rawId == "Huge2" or rawId == "huge2" then _G.SessionGoals.huge2 = _G.SessionGoals.huge2 + 1
                                    elseif rawId == "Titanic" or rawId == "titanic" then _G.SessionGoals.titanic = _G.SessionGoals.titanic + 1
                                    elseif rawId == "Gargantuan" or rawId == "gargantuan" then _G.SessionGoals.gargantuan = _G.SessionGoals.gargantuan + 1 end
                                end
                            end
                        end
                    end
                    -- Скорость спама ударов во время матча (от 0.01 до 0.04 сек)
                    nextDelay = math.random(1, 4) / 100
                else
                    -- ИСПРАВЛЕНО: Если пнуть не получилось (ошибка/nil/Generation Failure) — ждем ровно 1 секунду и пробуем снова
                    nextDelay = 1.0
                end
                
                task.wait(nextDelay)
            end
        else
            task.wait(0.5)
        end
    end
end)
