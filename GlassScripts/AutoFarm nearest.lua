getgenv().AutoSpeedPetsForRank = getgenv().AutoSpeedPetsForRank or false

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
        if pet.Name:match("^%d+$") then
            table.insert(petIds, pet.Name)
        end
    end
end

local function updateBreakables()
    breakableList = breakables:GetChildren()
end

breakables.ChildAdded:Connect(updateBreakables)
breakables.ChildRemoved:Connect(updateBreakables)

petsFolder.ChildAdded:Connect(updatePetList)
petsFolder.ChildRemoved:Connect(updatePetList)

task.delay(2, updatePetList)

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

task.spawn(function()
    while task.wait(0.2) do
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
    end
end)
