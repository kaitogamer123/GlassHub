-- Файл: GlassScripts/AutoMagnet.lua
return function()
    if getgenv().AutoMagnetLoaded then return end
    getgenv().AutoMagnetLoaded = true

    task.spawn(function()
        print("🧊 GlassHub: AutoMagnet запущен.")
        while true do
            task.wait(1.5) -- Задержка, чтобы не спамить сервер слишком сильно
            
            if getgenv().AutoMagnet then
                local things = workspace:FindFirstChild("__THINGS")
                local orbs = things and things:FindFirstChild("Orbs")
                
                if orbs then
                    local orbIds = {}
                    local allOrbs = orbs:GetChildren()
                    
                    -- Собираем все ID сфер в таблицу
                    for _, orb in pairs(allOrbs) do
                        local orbName = tonumber(orb.Name)
                        if orbName then
                            table.insert(orbIds, orbName)
                            orb:Destroy() -- Визуально убираем, чтобы не лагало
                        end
                    end
                    
                    -- Отправляем все сферы одним пакетом (так эффективнее)
                    if #orbIds > 0 then
                        local network = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
                        local collectRemote = network and network:FindFirstChild("Orbs: Collect")
                        
                        if collectRemote then
                            pcall(function()
                                collectRemote:FireServer(orbIds)
                            end)
                        end
                    end
                end
            end
        end
    end)
end
