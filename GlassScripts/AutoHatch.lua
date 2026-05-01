-- Файл: GlassScripts/AutoHatch.lua
return function()
    -- Защита от повторного запуска цикла
    if getgenv().AutoHatchLoaded then return end
    getgenv().AutoHatchLoaded = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local EggCmds = require(ReplicatedStorage.Library.Client.EggCmds)
    local lp = game.Players.LocalPlayer

    -- Функция поиска ближайшего яйца
    local function getNearestEgg()
        local nearestData = nil
        local minDist = 35 -- Радиус поиска
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        if not root then return nil end
        local things = workspace:WaitForChild("__THINGS")
        
        -- 1. СКАНИРУЕМ ИВЕНТОВЫЕ (CustomEggs)
        local customFolder = things:FindFirstChild("CustomEggs")
        if customFolder then
            for _, egg in pairs(customFolder:GetChildren()) do
                -- ПРОВЕРКА: Только модели (игнорируем Highlight и прочее)
                if egg:IsA("Model") then
                    local dist = (egg:GetPivot().Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearestData = {id = egg.Name, type = "Custom"}
                    end
                end
            end
        end

        -- 2. СКАНИРУЕМ ОБЫЧНЫЕ (ZoneEggs)
        local zoneFolder = things:FindFirstChild("ZoneEggs")
        if zoneFolder and not nearestData then
            for _, world in pairs(zoneFolder:GetChildren()) do
                for _, egg in pairs(world:GetChildren()) do
                    -- ПРОВЕРКА: Только модели
                    if egg:IsA("Model") then
                        local dist = (egg:GetPivot().Position - root.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearestData = {id = egg.Name, type = "Normal"}
                        end
                    end
                end
            end
        end
        
        return nearestData
    end

    -- ОСНОВНОЙ ЦИКЛ
    task.spawn(function()
        local playerGui = lp:WaitForChild("PlayerGui")
        
        -- Фоновое отключение анимации (чтобы не лагало)
        task.spawn(function()
            while true do
                if getgenv().AutoHatchNearEgg and playerGui:FindFirstChild("EggOpen") then
                    playerGui.EggOpen.Enabled = false
                end
                task.wait(1)
            end
        end)

        while true do
            if getgenv().AutoHatchNearEgg == true then
                local egg = getNearestEgg()
                
                if egg then
                    -- Получаем макс. кол-во яиц за раз (8, 30 и т.д.)
                    local maxAmount = 1
                    pcall(function() maxAmount = EggCmds.GetMaxHatch() end)

                    pcall(function()
                        if egg.type == "Custom" then
                            -- Сигнал для ИВЕНТОВЫХ яиц
                            ReplicatedStorage.Network.CustomEggs_Hatch:InvokeServer(egg.id, maxAmount)
                        else
                            -- Сигнал для ОБЫЧНЫХ яиц
                            ReplicatedStorage.Network.Eggs_RequestPurchase:InvokeServer(egg.id, maxAmount)
                        end
                    end)
                end
                task.wait(0.3) -- Скорость открытия
            else
                task.wait(1)
            end
        end
    end)
end
