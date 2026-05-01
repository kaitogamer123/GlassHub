-- Файл: GlassScripts/AutoHatch.lua
return function()
    if getgenv().AutoHatchLoaded then return end
    getgenv().AutoHatchLoaded = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local EggCmds = require(ReplicatedStorage.Library.Client.EggCmds)
    local lp = game.Players.LocalPlayer

    -- Функция поиска ближайшего яйца любого типа
    local function getNearestEgg()
        local nearestData = nil
        local minDist = 30 -- Дистанция подбора
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        if not root then return nil end

        local things = workspace.__THINGS
        
        -- 1. СКАНИРУЕМ ИВЕНТОВЫЕ (Custom)
        local customFolder = things:FindFirstChild("CustomEggs")
        if customFolder then
            for _, egg in pairs(customFolder:GetChildren()) do
                local dist = (egg:GetPivot().Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearestData = {id = egg.Name, type = "Custom"}
                end
            end
        end

        -- 2. СКАНИРУЕМ ОБЫЧНЫЕ (ZoneEggs)
        local zoneFolder = things:FindFirstChild("ZoneEggs")
        if zoneFolder and not nearestData then -- Если ивент не найден в упор, ищем обычные
            for _, world in pairs(zoneFolder:GetChildren()) do
                for _, egg in pairs(world:GetChildren()) do
                    local dist = (egg:GetPivot().Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearestData = {id = egg.Name, type = "Normal"}
                    end
                end
            end
        end
        
        return nearestData
    end

    -- ЦИКЛ РАБОТЫ
    task.spawn(function()
        -- Отключаем анимацию открытия (Anti-Lag)
        local playerGui = lp:WaitForChild("PlayerGui")
        task.spawn(function()
            while true do
                if getgenv().AutoHatchNearEgg and playerGui:FindFirstChild("EggOpen") then
                    playerGui.EggOpen.Enabled = false
                end
                task.wait(2)
            end
        end)

        while true do
            if getgenv().AutoHatchNearEgg then
                local egg = getNearestEgg()
                local maxAmount = EggCmds.GetMaxHatch()

                if egg then
                    pcall(function()
                        if egg.type == "Custom" then
                            -- Сигнал для ивентовых
                            ReplicatedStorage.Network.CustomEggs_Hatch:InvokeServer(egg.id, maxAmount)
                        else
                            -- Сигнал для обычных
                            ReplicatedStorage.Network.Eggs_RequestPurchase:InvokeServer(egg.id, maxAmount)
                        end
                    end)
                end
                task.wait(0.3)
            else
                task.wait(1)
            end
        end
    end)
end
