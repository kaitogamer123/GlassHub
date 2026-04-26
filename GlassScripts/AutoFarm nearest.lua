--[[
    Файл: GlassScripts/AutofarmNearest.lua
    Логика для Pet Simulator 99
]]

return function()
    -- Защита от повторного запуска цикла
    if getgenv().AutoSpeedPetsLoaded then 
        print("🧊 GlassHub: Логика уже была загружена ранее.")
        return 
    end
    getgenv().AutoSpeedPetsLoaded = true

    local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
    local player = game:GetService("Players").LocalPlayer
    local things = workspace:WaitForChild("__THINGS")
    local breakables = things.Breakables
    local petsFolder = things.Pets

    local petIds = {}
    local breakableList = breakables:GetChildren()

    local function updatePetList()
        table.clear(petIds)
        for _, pet in ipairs(petsFolder:GetChildren()) do
            if pet.Name:match("^%d+$") then table.insert(petIds, pet.Name) end
        end
    end

    local function updateBreakables() breakableList = breakables:GetChildren() end

    breakables.ChildAdded:Connect(updateBreakables)
    breakables.ChildRemoved:Connect(updateBreakables)
    petsFolder.ChildAdded:Connect(updatePetList)
    petsFolder.ChildRemoved:Connect(updatePetList)

    task.spawn(updatePetList)

    local function getTargetsInRange(radius)
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return {} end
        local myPos = root.Position
        local found = {}
        for _, obj in ipairs(breakableList) do
            local part = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                if (part.Position - myPos).Magnitude <= radius then
                    table.insert(found, obj.Name)
                end
            end
        end
        return found
    end

    local lastFire = 0

    -- ВЕЧНЫЙ ЦИКЛ (он не выключится сам)
    task.spawn(function()
        print("🧊 GlassHub: Цикл фарма запущен и ожидает включения кнопки.")
        while true do
            -- Проверяем глобальную переменную из кнопки
            if getgenv().AutoSpeedPetsForRank == true then
                local success, err = pcall(function()
                    local targets = getTargetsInRange(60)
                    if #targets > 0 and #petIds > 0 then
                        local mainTarget = targets[1]
                        local attackData = {}
                        for _, pId in ipairs(petIds) do attackData[pId] = mainTarget end

                        if os.clock() - lastFire > 0.15 then
                            Network:FireServer(attackData)
                            lastFire = os.clock()
                        end
                    end
                end)
                if not success then warn("Ошибка в цикле: " .. err) end
            end
            task.wait(0.2)
        end
    end)
end
