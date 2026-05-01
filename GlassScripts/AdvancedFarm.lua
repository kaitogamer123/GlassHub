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

local function getNearestZone()
    local mapContainer = getActiveMapContainer()
    if not mapContainer then return nil end

    local closest, dist = nil, math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, folder in ipairs(mapContainer:GetChildren()) do
        local zone = folder:FindFirstChild("BREAK_ZONE", true)
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
        if getgenv().Glass_Adv_Active then
            local target = getgenv().Glass_Adv_Target or getNearestZone()
            
            if target and #petIds > 0 then
                local zonePos = target.Position
                -- Берем радиус на основе размера BREAK_ZONE (половина самой большой стороны + запас)
                local radius = (math.max(target.Size.X, target.Size.Z) / 2) + 5
                local radiusSq = radius * radius
                
                local targets = {}
                local objects = breakables:GetChildren()
                
                for i = 1, #objects do
                    local obj = objects[i]
                    local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if p then
                        local pPos = p.Position
                        local dx = pPos.X - zonePos.X
                        local dy = pPos.Y - zonePos.Y
                        local dz = pPos.Z - zonePos.Z
                        -- Старая добрая проверка по радиусу, но радиус теперь умный
                        if (dx*dx + dy*dy + dz*dz) <= radiusSq then
                            table.insert(targets, obj.Name)
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
        task.wait(0.15)
    end
end)

return function(state)
    getgenv().Glass_Adv_Active = state
end
