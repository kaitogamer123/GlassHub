-- Файл: GlassScripts/AutoHatch.lua
return function()
    -- Защита от повторного запуска цикла
    if getgenv().AutoHatchLoaded then return end
    getgenv().AutoHatchLoaded = true

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local EggCmds = require(ReplicatedStorage.Library.Client.EggCmds)
    local EggsUtil = require(ReplicatedStorage.Library.Util.EggsUtil)
    local lp = game.Players.LocalPlayer

    -- Функция поиска ближайшего яйца
    local function getNearestEgg()
        local nearestData = nil
        local minDist = 40 -- Радиус поиска
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        if not root then return nil end
        local things = workspace:WaitForChild("__THINGS")
        
        -- Список всех возможных папок с яйцами (Eggs, ZoneEggs, CustomEggs)
        local paths = {
            things:FindFirstChild("Eggs"),
            things:FindFirstChild("ZoneEggs"),
            things:FindFirstChild("CustomEggs")
        }

        for _, folder in pairs(paths) do
            if folder then
                -- Для ZoneEggs и Eggs используем глубокий поиск миров
                local items = (folder.Name == "CustomEggs") and folder:GetChildren() or folder:GetDescendants()
                
                for _, item in pairs(items) do
                    -- Проверяем, что это модель и у неё есть точка привязки
                    if item:IsA("Model") and (item:FindFirstChild("Main") or item:FindFirstChild("Center") or item.PrimaryPart) then
                        local dist = (item:GetPivot().Position - root.Position).Magnitude
                        
                        if dist < minDist then
                            local eggId = item.Name
                            local eggType = (folder.Name == "CustomEggs") and "Custom" or "Normal"
                            
                            -- Если это обычное яйцо, пробуем достать технический ID через EggsUtil
                            if eggType == "Normal" then
                                local eggNumber = tonumber(item.Name:match("^%d+"))
                                if eggNumber then
                                    local data = EggsUtil.GetByNumber(eggNumber)
                                    if data then eggId = data._id end
                                end
                            end

                            minDist = dist
                            nearestData = {id = eggId, type = eggType}
                        end
                    end
                end
            end
        end
        return nearestData
    end

    -- ОСНОВНОЙ ЦИКЛ
    task.spawn(function()
        while true do
            if getgenv().AutoHatchNearEgg == true then
                local egg = getNearestEgg()
                
                if egg then
                    local maxAmount = 1
                    pcall(function() maxAmount = EggCmds.GetMaxHatch() end)

                    pcall(function()
                        if egg.type == "Custom" then
                            -- Сигнал для ИВЕНТОВЫХ яиц (твой рабочий вариант)
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
