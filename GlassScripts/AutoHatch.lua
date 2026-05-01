    local function hatchNearest()
        local player = game.Players.LocalPlayer
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local rootPos = root.Position
        local things = game.Workspace:WaitForChild("__THINGS")
        
        local nearestEggId = nil
        local minDist = 100 

        -- Собираем все модели из обеих папок в одну таблицу для поиска
        local allEggs = {}
        local zoneEggs = things:FindFirstChild("ZoneEggs")
        local customEggs = things:FindFirstChild("CustomEggs")
        
        if zoneEggs then 
            for _, v in pairs(zoneEggs:GetDescendants()) do 
                if v:IsA("Model") then table.insert(allEggs, v) end 
            end 
        end
        if customEggs then 
            for _, v in pairs(customEggs:GetChildren()) do 
                table.insert(allEggs, v) 
            end 
        end

        for _, eggModel in pairs(allEggs) do
            local part = eggModel:FindFirstChild("Main") or eggModel:FindFirstChild("Center") or eggModel:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (rootPos - part.Position).Magnitude
                if dist < minDist then
                    -- Пытаемся вытащить данные через EggsUtil
                    local data = nil
                    local eggNumber = tonumber(eggModel.Name:match("^%d+"))
                    
                    if eggNumber then data = EggsUtil.GetByNumber(eggNumber) end
                    if not data then data = EggsUtil.GetById(eggModel.Name) end
                    if not data then data = EggsUtil.Get(eggModel.Name) end

                    if data then
                        minDist = dist
                        nearestEggId = data._id
                    end
                end
            end
        end

        if nearestEggId then
            local maxHatch = 1
            pcall(function() maxHatch = EggCmds.GetMaxHatch() end)
            
            -- ПРОБУЕМ ТРИ ВАРИАНТА ОТПРАВКИ (один точно сработает)
            print("🧊 [Glass]: Попытка открыть яйцо:", nearestEggId)
            
            -- Вариант 1 (Стандарт)
            local s1 = pcall(function() EggCmds.RequestPurchase(nearestEggId, maxHatch) end)
            
            -- Вариант 2 (Таблица - часто нужен в новых мирах)
            if not s1 then
                pcall(function() EggCmds.RequestPurchase({[nearestEggId] = maxHatch}) end)
            end
            
            -- Вариант 3 (Через Network напрямую, если EggCmds тупит)
            pcall(function()
                game:GetService("ReplicatedStorage").Network.Eggs_RequestPurchase:InvokeServer(nearestEggId, maxHatch)
            end)
        else
            -- Если это вылетит в консоль - значит скрипт не видит яйца рядом
            -- warn("🧊 [Glass]: Яйца в радиусе 100 не найдены.")
        end
    end
