-- Файл: GlassScripts/AutoTap.lua
return function()
    if getgenv().AutoTapLoaded then return end
    getgenv().AutoTapLoaded = true

    local RADIUS = 150
    local DAMAGE_SPEED = 0.05 -- Максимальная скорость без кика (было 0.2)
    local player = game.Players.LocalPlayer
    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_PlayerDealDamage")

    local function getBreakables()
        local things = workspace:FindFirstChild("__THINGS")
        return things and things:FindFirstChild("Breakables")
    end

    task.spawn(function()
        print("🧊 GlassHub: Ultra AutoTap запущен.")
        while true do
            if getgenv().AutoTap == true then
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                
                if root then
                    local breakablesPath = getBreakables()
                    if breakablesPath then
                        local rootPos = root.Position
                        local allBreakables = breakablesPath:GetChildren()

                        -- Вместо сортировки просто бьем всё, что в радиусе, максимально быстро
                        for i = 1, #allBreakables do
                            if not getgenv().AutoTap then break end
                            
                            local obj = allBreakables[i]
                            local part = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
                            
                            if part then
                                -- Оптимизированная проверка (без квадратного корня для скорости)
                                local distSq = (rootPos - part.Position).Magnitude
                                if distSq <= RADIUS then
                                    -- Используем spawn, чтобы не ждать ответа сервера и бить следующую цель мгновенно
                                    task.spawn(function()
                                        network:FireServer(obj.Name)
                                    end)
                                end
                            end
                            
                            -- Каждые 10 ударов делаем микро-паузу, чтобы не лагало
                            if i % 10 == 0 then task.wait() end 
                        end
                    end
                end
            end
            task.wait(DAMAGE_SPEED) 
        end
    end)
end
