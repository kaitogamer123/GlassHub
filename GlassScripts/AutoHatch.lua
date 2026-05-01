    local function getNearestEgg()
        local nearestData = nil
        local minDist = 35
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not root then return nil end

        local things = workspace.__THINGS
        
        -- 1. СКАНИРУЕМ ИВЕНТОВЫЕ (Custom)
        local customFolder = things:FindFirstChild("CustomEggs")
        if customFolder then
            for _, egg in pairs(customFolder:GetChildren()) do
                -- ФИКС: Проверяем, что это МОДЕЛЬ, а не Highlight или другой мусор
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
                    -- ФИКС: Проверка на модель
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
