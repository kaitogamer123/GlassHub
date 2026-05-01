local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local player = Players.LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things.Breakables
local petsFolder = things.Pets

-- Путь к зонам
local ZonesPath = workspace:WaitForChild("Map3"):WaitForChild("201 | Prison Block"):WaitForChild("INTERACT"):WaitForChild("BREAK_ZONES")

local petIds = {}
getgenv().AdvancedFarmActive = false
getgenv().LockedZone = nil 

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

-- Поиск ближайшей зоны к игроку
local function getNearestZone()
    local closest, dist = nil, math.huge
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, zone in ipairs(ZonesPath:GetChildren()) do
        local part = zone:IsA("BasePart") and zone or zone:FindFirstChildWhichIsA("BasePart")
        if part then
            local d = (part.Position - root.Position).Magnitude
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
        if getgenv().AdvancedFarmActive then
            -- Если зона не залочена, ищем ближайшую
            local targetZone = getgenv().LockedZone or getNearestZone()
            
            if targetZone and #petIds > 0 then
                local zonePart = targetZone:IsA("BasePart") and targetZone or targetZone:FindFirstChildWhichIsA("BasePart")
                local zonePos = zonePart.Position
                local targets = {}
                local radiusSq = 75^2 
                
                local allBreakables = breakables:GetChildren()
                for i = 1, #allBreakables do
                    local obj = allBreakables[i]
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if part then
                        local pPos = part.Position
                        local dx = pPos.X - zonePos.X
                        local dy = pPos.Y - zonePos.Y
                        local dz = pPos.Z - zonePos.Z
                        if (dx*dx + dy*dy + dz*dz) <= radiusSq then
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

-- Функция-переключатель для хаба
return function(state)
    getgenv().AdvancedFarmActive = state
end
