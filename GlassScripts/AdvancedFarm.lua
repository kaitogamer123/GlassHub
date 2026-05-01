local RS = game:GetService("ReplicatedStorage")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")
local Map3 = workspace:WaitForChild("Map3")

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

-- Функция проверки: находится ли точка внутри бокса (зоны)
local function isPointInZone(point, zonePart)
    local size = zonePart.Size
    local cframe = zonePart.CFrame
    local relativePoint = cframe:PointToObjectSpace(point)
    
    return math.abs(relativePoint.X) <= size.X/2 and
           math.abs(relativePoint.Y) <= size.Y/2 and
           math.abs(relativePoint.Z) <= size.Z/2
end

local function getClosestZone()
    local closest, dist = nil, math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, folder in ipairs(Map3:GetChildren()) do
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
            local target = getgenv().Glass_Adv_Target or getClosestZone()
            
            if target and #petIds > 0 then
                local targets = {}
                local objects = breakables:GetChildren()
                
                for i = 1, #objects do
                    local obj = objects[i]
                    local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if p then
                        -- Теперь проверяем не радиус, а вхождение в размеры парта зоны
                        if isPointInZone(p.Position, target) then
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
