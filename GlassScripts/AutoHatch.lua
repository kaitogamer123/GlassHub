    local function hatchNearest()
        local player = game.Players.LocalPlayer
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local rootPos = root.Position
        local things = game.Workspace:WaitForChild("__THINGS")
        local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
        
        local nearestEgg = nil
        local eggType = nil -- "Normal" или "Custom"
        local minDist = 100 

        -- 1. ИЩЕМ В ОБЫЧНЫХ (ZoneEggs)
        local zoneEggs = things:FindFirstChild("ZoneEggs")
        if zoneEggs then
            for _, v in pairs(zoneEggs:GetDescendants()) do
                if v:IsA("Model") and (v:FindFirstChild("Main") or v:FindFirstChild("Center")) then
                    local dist = (rootPos - (v:FindFirstChild("Main") or v:FindFirstChild("Center")).Position).Magnitude
                    if dist < minDist then
                        local data = EggsUtil.GetByNumber(tonumber(v.Name:match("^%d+"))) or EggsUtil.GetById(v.Name)
                        if data then
                            minDist = dist
                            nearestEgg = data._id
                            eggType = "Normal"
                        end
                    end
                end
            end
        end

        -- 2. ИЩЕМ В ИВЕНТОВЫХ (CustomEggs)
        local customEggs = things:FindFirstChild("CustomEggs")
        if customEggs then
            for _, v in pairs(customEggs:GetChildren()) do
                local part = v:FindFirstChild("Main") or v:FindFirstChild("Center") or v:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (rootPos - part.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearestEgg = v.Name -- Для кастомных это ID папки
                        eggType = "Custom"
                    end
                end
            end
        end

        -- ОТПРАВКА ЗАПРОСА
        if nearestEgg and eggType then
            local maxHatch = 1
            pcall(function() maxHatch = EggCmds.GetMaxHatch() end)
            
            if eggType == "Custom" then
                -- Сигнал для ивентовых яиц
                network.CustomEggs_Hatch:InvokeServer(nearestEgg, maxHatch)
            else
                -- Сигнал для обычных яиц
                network.Eggs_RequestPurchase:InvokeServer(nearestEgg, maxHatch)
            end
        end
    end
