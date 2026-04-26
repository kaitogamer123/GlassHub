-- Файл: GlassScripts/AutoTap.lua
return function()
    if getgenv().AutoTapLoaded then return end
    getgenv().AutoTapLoaded = true

    local RADIUS = 150
    local MAX_TARGETS = 20
    local player = game.Players.LocalPlayer
    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_PlayerDealDamage")

    local function getBreakables()
        local things = workspace:FindFirstChild("__THINGS")
        return things and things:FindFirstChild("Breakables")
    end

    task.spawn(function()
        print("🧊 GlassHub: AutoTap (Task) запущен.")
        while true do
            -- Проверяем переменную, которую меняет кнопка
            if getgenv().AutoTap == true then
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                
                if root then
                    local breakablesPath = getBreakables()
                    if breakablesPath then
                        local rootPos = root.Position
                        local targets = {}
                        local allBreakables = breakablesPath:GetChildren()

                        -- Собираем цели в радиусе
                        for i = 1, #allBreakables do
                            local obj = allBreakables[i]
                            local part = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local dist = (rootPos - part.Position).Magnitude
                                if dist <= RADIUS then
                                    table.insert(targets, {instance = obj, distance = dist})
                                end
                            end
                        end

                        -- Сортируем от ближних к дальним
                        table.sort(targets, function(a, b) return a.distance < b.distance end)

                        -- Кликаем по лимиту целей
                        local limit = math.min(#targets, MAX_TARGETS)
                        for i = 1, limit do
                            if not getgenv().AutoTap then break end
                            pcall(function()
                                network:FireServer(targets[i].instance.Name)
                            end)
                        end
                    end
                end
            end
            task.wait(0.2) -- Твоя прошлая рабочая задержка
        end
    end)
end
