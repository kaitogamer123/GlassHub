_G.AutoSpeedPetsForRank = false


local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local player = game:GetService("Players").LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things.Breakables
local petsFolder = things.Pets

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

local function getTargetsInRange(radius)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    
    local myPos = root.Position
    local found = {}
    local radiusSq = radius^2

    for _, obj in ipairs(breakables:GetChildren()) do
        if obj.Name:match("^%d+$") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local diff = part.Position - myPos
                if (diff.X^2 + diff.Y^2 + diff.Z^2) <= radiusSq then
                    table.insert(found, obj.Name)
                end
            end
        end
    end
    return found
end

task.spawn(function()
    while true do
        if _G.AutoSpeedPetsForRank then 
            local targets = getTargetsInRange(60)
            local attackData = {}

            if #targets > 0 and #petIds > 0 then
                if #targets >= 5 then
                    for i, pId in ipairs(petIds) do
                        local targetId = targets[((i - 1) % #targets) + 1]
                        attackData[pId] = targetId
                    end
                else
                    local mainTarget = targets[1]
                    for _, pId in ipairs(petIds) do
                        attackData[pId] = mainTarget
                    end
                end

                Network:FireServer(attackData)
            end
        end
        
        task.wait(0.2) 
    end
end)
