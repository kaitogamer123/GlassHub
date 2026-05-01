local RS = game:GetService("ReplicatedStorage")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local player = game:GetService("Players").LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")

getgenv().EventFarmActive = false

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

task.spawn(function()
    while true do
        if getgenv().EventFarmActive then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root and #petIds > 0 then
                local myPos = root.Position
                local targets = {}
                local radiusSq = 50^2 
                
                local allBreakables = breakables:GetChildren()
                for i = 1, #allBreakables do
                    local obj = allBreakables[i]
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if part then
                        local pPos = part.Position
                        local dx, dy, dz = pPos.X - myPos.X, pPos.Y - myPos.Y, pPos.Z - myPos.Z
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
        task.wait(0.12)
    end
end)

return function(state)
    getgenv().EventFarmActive = state
end
