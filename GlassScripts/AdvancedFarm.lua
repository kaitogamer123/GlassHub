local RS = game:GetService("ReplicatedStorage")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")

getgenv().Glass_Adv_Active = false
getgenv().Glass_Adv_Target = nil 

local petIds = {}

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

-- Поиск активного мира
local function getActiveMapContainer()
    local containers = {"Map", "Map2", "Map3", "Map4", "Map5"}
    for _, name in ipairs(containers) do
        local c = workspace:FindFirstChild(name)
        if c then return c end
    end
    return nil
end

-- Теперь ищем не одну зону, а ПАПКУ локации, которая ближе всего
local function getNearestZoneFolder()
    local mapContainer = getActiveMapContainer()
    if not mapContainer then return nil end

    local closest, dist = nil, math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, folder in ipairs(mapContainer:GetChildren()) do
        -- Ориентируемся на положение папки или её первой зоны
        local zone = folder:FindFirstChild("BREAK_ZONE", true)
        if zone then
            local d = (zone.Position - root.Position).Magnitude
            if d < dist then
                dist = d
                closest = folder -- Возвращаем всю папку локации
            end
        end
    end
    return closest
end

task.spawn(function()
    while true do
        if getgenv().Glass_Adv_Active then
            -- Целью теперь может быть либо конкретный парт (Locked), либо папка локации
            local targetObj = getgenv().Glass_Adv_Target
            local targetFolder = not targetObj and getNearestZoneFolder()
            
            if (targetObj or targetFolder) and #petIds > 0 then
                local targets = {}
                local objects = breakables:GetChildren()
                
                -- Собираем все BREAK_ZONE в этой локации
                local activeZones = {}
                if targetObj then
                    table.insert(activeZones, targetObj)
                else
                    for _, v in ipairs(targetFolder:GetDescendants()) do
                        if v.Name == "BREAK_ZONE" and v:IsA("BasePart") then
                            table.insert(activeZones, v)
                        end
                    end
                end

                for i = 1, #objects do
                    local obj = objects[i]
                    local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if p then
                        local pPos = p.Position
                        -- Проверяем монетку против ВСЕХ зон в этой локации
                        for _, zone in ipairs(activeZones) do
                            local zPos = zone.Position
                            local radius = (math.max(zone.Size.X, zone.Size.Z) / 2) + 15
                            local dx = pPos.X - zPos.X
                            local dz = pPos.Z - zPos.Z
                            
                            if (dx*dx + dz*dz) <= (radius * radius) then
                                table.insert(targets, obj.Name)
                                break -- Нашли зону, дальше не проверяем для этой монетки
                            end
                        end
                    end
                    if #targets >= 40 then break end 
                end

                if #targets > 0 then
                    local data = {}
                    for i = 1, #petIds do
                        data[petIds[i]] = targets[((i - 1) % #targets) + 1]
                    end
                    Network:FireServer(data)
                end
            end
        end
        task.wait(0.12)
    end
end)

return function(state)
    getgenv().Glass_Adv_Active = state
end
