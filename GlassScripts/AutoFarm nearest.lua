--[[
    Файл: AutoSpeedPets.lua
    Логика для Pet Simulator 99 (Bulk Pet Attack)
]]

return function()
    -- Проверка на дубликаты (чтобы не запускать цикл дважды)
    if getgenv().AutoSpeedPetsLoaded then 
        return 
    end
    getgenv().AutoSpeedPetsLoaded = true

    -- Настройка переменной управления (если еще не создана)
    if getgenv().AutoSpeedPetsForRank == nil then
        getgenv().AutoSpeedPetsForRank = false
    end

    local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
    local player = game:GetService("Players").LocalPlayer

    local things = workspace:WaitForChild("__THINGS")
    local breakables = things.Breakables
    local petsFolder = things.Pets

    local petIds = {}
    local breakableList = breakables:GetChildren()

    -- Обновление списка петов
    local function updatePetList()
        table.clear(petIds)
        for _, pet in ipairs(petsFolder:GetChildren()) do
            if pet.Name:match("^%d+$") then
                table.insert(petIds, pet.Name)
            end
        end
    end

    -- Обновление списка объектов
    local function updateBreakables()
        breakableList = breakables:GetChildren()
    end

    -- Подписки на события
    breakables.ChildAdded:Connect(updateBreakables)
    breakables.ChildRemoved:Connect(updateBreakables)
    petsFolder.ChildAdded:Connect(updatePetList)
    petsFolder.ChildRemoved:Connect(updatePetList)

    task.delay(2, updatePetList)

    -- Поиск целей в радиусе
    local function getTargetsInRange(radius)
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return {} end

        local myPos = root.Position
        local radiusSq = radius * radius
        local found = {}

        for _, obj in ipairs(breakableList) do
            local part = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local diff = part.Position - myPos
                if (diff.X^2 + diff.Y^2 + diff.Z^2) <= radiusSq then
                    table.insert(found, obj.Name)
                end
            end
        end
        return found
    end

    local lastFire = 0

    -- ОСНОВНОЙ ЦИКЛ ФАРМА
    task.spawn(function()
        while true do
            -- Цикл работает всегда, но атакует только когда кнопка включена (true)
            if getgenv().AutoSpeedPetsForRank then
                local targets = getTargetsInRange(60)
                local petCount = #petIds

                if #targets > 0 and petCount > 0 then
                    local mainTarget = targets[1]
                    local attackData = {}

                    for _, pId in ipairs(petIds) do
                        attackData[pId] = mainTarget
                    end

                    if os.clock() - lastFire > 0.15 then
                        Network:FireServer(attackData)
                        lastFire = os.clock()
                    end
                end
            end
            task.wait(0.2)
        end
    end)
    
    print("🧊 GlassHub: Логика AutoSpeedPets успешно загружена!")
end
