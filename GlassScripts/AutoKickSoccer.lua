local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer

if not _G.SessionGoals then
    _G.SessionGoals = { gift = 0, huge1 = 0, huge2 = 0, titanic = 0, gargantuan = 0 }
end

-- АВТОНОМНЫЙ ПЕРЕХВАТ ПАУЗЫ (Нотификатор встроен прямо сюда)
task.spawn(function()
    local networkFolder = ReplicatedStorage:WaitForChild("Network")
    -- Слушаем ремоут, который игра использует для уведомлений или смены стадий матча
    local notificationRemote = networkFolder:WaitForChild("Notification") or networkFolder:FindFirstChildOfClass("RemoteEvent")
    
    if notificationRemote and notificationRemote:IsA("RemoteEvent") then
        notificationRemote.OnClientEvent:Connect(function(title, text)
            local cleanText = string.lower(tostring(text or title))
            -- Если в системном уведомлении есть слова о сбросе сфер или отдыхе
            if cleanText:find("reset") or cleanText:find("sphere") or cleanText:find("intermission") or cleanText:find("break") then
                getgenv().SoccerNotificationPause = true
                print("🚨 [GlassHub]: Обнаружено уведомление об отдыхе! Активирую паузу на 30 секунд...")
            end
        end)
    end
end)

task.spawn(function()
    local networkFolder = ReplicatedStorage:WaitForChild("Network")
    local invokeCustom = networkFolder:WaitForChild("Instancing_InvokeCustomFromClient")
    
    while true do
        if _G.AutoPerfectPowerActive then
            if getgenv().SoccerNotificationPause then
                task.wait(30)
                getgenv().SoccerNotificationPause = false
            else
                local randomPower = math.random(94, 99) / 100
                local success, response = pcall(function() 
                    return invokeCustom:InvokeServer("SoccerEvent", "GZ_Step", randomPower) 
                end)
                
                local nextDelay = 0.02
                
                if success and type(response) == "table" then
                    if response.Success == false then
                        _G.SessionGoals = { gift = 0, huge1 = 0, huge2 = 0, titanic = 0, gargantuan = 0 }
                    else
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
                    nextDelay = math.random(1, 4) / 100
                else
                    nextDelay = 1.0
                end
                
                task.wait(nextDelay)
            end
        else
            task.wait(0.5)
        end
    end
end)
