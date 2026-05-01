    local function hatchNearest()
        local player = game.Players.LocalPlayer
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local rootPos = root.Position
        local things = game.Workspace:WaitForChild("__THINGS")
        
        local nearestEggData = nil
        local minDist = 100 

        -- Собираем список всех возможных папок с яйцами
        local foldersToSearch = {
            things:FindFirstChild("CustomEggs"),
            things:FindFirstChild("ZoneEggs")
        }

        for _, folder in pairs(foldersToSearch) do
            if folder then
                -- Рекурсивно или через вложенные папки (для ZoneEggs)
                for _, item in pairs(folder:GetDescendants()) do
                    -- Проверяем, что это модель яйца (обычно у них есть "Tier" в атрибутах или специфичные парты)
                    if item:IsA("Model") and (item:FindFirstChild("Main") or item:FindFirstChild("Center")) then
                        local part = item:FindFirstChild("Main") or item:FindFirstChild("Center")
                        local dist = (rootPos - part.Position).Magnitude
                        
                        if dist < minDist then
                            -- Пытаемся найти данные яйца тремя способами:
                            local data = nil
                            
                            -- 1. По номеру (если есть в начале имени)
                            local eggNumber = tonumber(item.Name:match("^%d+"))
                            if eggNumber then
                                data = EggsUtil.GetByNumber(eggNumber)
                            end
                            
                            -- 2. По точному имени/ID (для Ruby Egg или хешей)
                            if not data then
                                data = EggsUtil.GetById(item.Name)
                            end
                            
                            -- 3. По названию (Get)
                            if not data then
                                data = EggsUtil.Get(item.Name)
                            end

                            if data then
                                minDist = dist
                                nearestEggData = data
                            end
                        end
                    end
                end
            end
        end

        if nearestEggData then
            local maxHatch = 1
            pcall(function() maxHatch = EggCmds.GetMaxHatch() end)
            pcall(function()
                -- Используем _id из полученных данных
                EggCmds.RequestPurchase(nearestEggData._id, maxHatch)
            end)
        end
    end
