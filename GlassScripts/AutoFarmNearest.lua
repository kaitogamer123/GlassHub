return function()
    if getgenv().AutoSpeedPetsLoaded then return end
    getgenv().AutoSpeedPetsLoaded = true

    -- Путь к удаленному событию атаки
    local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
    local player = game:GetService("Players").LocalPlayer
    local things = workspace:WaitForChild("__THINGS")
    local breakables = things:WaitForChild("Breakables")
    local petsFolder = things:WaitForChild("Pets")

    local petIds = {}
    
    -- Функция обновления списка ID твоих петов
    local function updatePetList()
        table.clear(petIds)
        for _, pet in ipairs(petsFolder:GetChildren()) do
            if pet:IsA("Model") and pet.Name:match("^%d+$") then
                table.insert(petIds, pet.Name)
            end
        end
    end

    -- Следим за петами (если экипировал новых)
    petsFolder.ChildAdded:Connect(updatePetList)
    petsFolder.ChildRemoved:Connect(updatePetList)
    task.spawn(updatePetList)

    local lastFire = 0

    task.spawn(function()
        print("🧊 GlassHub: Логика атак запущена.")
        while true do
            if getgenv().AutoSpeedPetsForRank == true then
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    -- Ищем ближайшую цель
                    local nearest = nil
                    local minDist = 60
                    
                    for _, obj in ipairs(breakables:GetChildren()) do
                        local part = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = (part.Position - root.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                nearest = obj.Name -- Нам нужен ID (имя) объекта
                            end
                        end
                    end

                    -- Если цель найдена и есть петы
                    if nearest and #petIds > 0 then
                        if os.clock() - lastFire > 0.05 then
                            local attackData = {}
                            for _, pId in ipairs(petIds) do
                                attackData[pId] = nearest
                            end
                            
                            -- Пытаемся атаковать
                            pcall(function()
                                Network:FireServer(attackData)
                            end)
                            lastFire = os.clock()
                        end
                    end
                end
            end
            task.wait(0.05) -- Ускорили цикл для "спид" эффекта
        end
    end)
end
