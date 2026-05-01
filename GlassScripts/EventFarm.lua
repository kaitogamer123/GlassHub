local RS = game:GetService("ReplicatedStorage")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local player = game:GetService("Players").LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")

getgenv().EventFarmActive = false
getgenv().EventLockedPos = nil 
getgenv().EventFarmRadius = 50 -- Стандартный радиус

local petIds = {}
local lastVisualCircle = nil

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

-- Функция создания визуального круга (цилиндра)
local function showVisualRadius()
    if lastVisualCircle then lastVisualCircle:Destroy() end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local pos = getgenv().EventLockedPos or (root and root.Position)
    
    if not pos then return end

    local circle = Instance.new("Part")
    circle.Name = "GlassHub_VisualRadius"
    circle.Shape = Enum.PartType.Cylinder
    circle.Anchored = true
    circle.CanCollide = false
    circle.Transparency = 0.7 -- Прозрачность 30% видимости
    circle.Color = Color3.fromRGB(255, 0, 0)
    circle.Material = Enum.Material.SmoothPlastic
    -- Диаметр = Радиус * 2
    local diameter = getgenv().EventFarmRadius * 2
    circle.Size = Vector3.new(0.5, diameter, diameter)
    -- Поворачиваем цилиндр, чтобы он лежал как круг на земле
    circle.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    circle.Parent = workspace
    
    lastVisualCircle = circle

    task.delay(3, function()
        if circle and circle.Parent then circle:Destroy() end
    end)
end

task.spawn(function()
    while true do
        if getgenv().EventFarmActive then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local farmPos = getgenv().EventLockedPos or (root and root.Position)
            
            if farmPos and #petIds > 0 then
                local targets = {}
                local radiusSq = getgenv().EventFarmRadius^2 
                local allBreakables = breakables:GetChildren()
                
                for i = 1, #allBreakables do
                    local obj = allBreakables[i]
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local pPos = part.Position
                        local dx, dz = pPos.X - farmPos.X, pPos.Z - farmPos.Z
                        if (dx*dx + dz*dz) <= radiusSq then
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

return {
    Toggle = function(v) getgenv().EventFarmActive = v end,
    SetRadius = function(v) getgenv().EventFarmRadius = v end,
    Show = function() showVisualRadius() end,
    Lock = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            getgenv().EventLockedPos = root.Position
            print("🧊 [Event]: Точка зафиксирована")
        end
    end,
    Reset = function()
        getgenv().EventLockedPos = nil
        print("🧊 [Event]: Точка сброшена")
    end
}
