local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local player = Players.LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")

local Map3 = workspace:WaitForChild("Map3")

local petIds = {}
getgenv().AdvancedFarmActive = false
getgenv().LockedZone = nil 

-- Обновление списка питомцев
local function updatePetList()
    table.clear(petIds)
    for _, pet in ipairs(petsFolder:GetChildren()) do
        if pet.Name:match("^%d+$") then
            table.insert(petIds, pet.Name)
        end
    end
end

updatePetList()
petsFolder.ChildAdded:Connect(updatePetList)
petsFolder.ChildRemoved:Connect(updatePetList)

-- Поиск ближайшей зоны во ВСЕХ папках Map3
local function getNearestZone()
    local closest, dist = nil, math.huge
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, folder in ipairs(Map3:GetChildren()) do
        -- Ищем путь: Папка -> INTERACT -> BREAK_ZONES -> BREAK_ZONE
        local interact = folder:FindFirstChild("INTERACT")
        local zones = interact and interact:FindFirstChild("BREAK_ZONES")
        local zone = zones and zones:FindFirstChild("BREAK_ZONE")

        if zone then
            local d = (zone.Position - root.Position).Magnitude
            if d < dist then
                dist = d
                closest = zone
            end
        end
    end
    return closest
end

task.spawn(function()
    while true do
        -- Условие: включен AdvancedFarm И функция InGameFarm активна
        if getgenv().AdvancedFarmActive and _G.InGameFarmRunning then
            local targetZone = getgenv().LockedZone or getNearestZone()
            
            if targetZone and #petIds > 0 then
                local zonePos = targetZone.Position
                local targets = {}
                
                local allBreakables = breakables:GetChildren()
                for i = 1, #allBreakables do
                    local obj = allBreakables[i]
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if part then
                        -- Проверка дистанции от центра найденной зоны
                        local pPos = part.Position
                        local dx, dy, dz = pPos.X - zonePos.X, pPos.Y - zonePos.Y, pPos.Z - zonePos.Z
                        if (dx*dx + dy*dy + dz*dz) <= 80^2 then -- Радиус 80
                            table.insert(targets, obj.Name)
                        end
                    end
                    if #targets >= 40 then break end 
                end

                if #targets > 0 then
                    local attackData = {}
                    for i = 1, #petIds do
                        attackData[petIds[i]] = targets[((i - 1) % #targets) + 1]
                    end
                    Network:FireServer(attackData)
                end
            end
        end
        task.wait(0.1)
    end
end)

return function(state)
    getgenv().AdvancedFarmActive = state
end
