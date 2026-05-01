local RS = game:GetService("ReplicatedStorage")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local player = game:GetService("Players").LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")

getgenv().EventFarmActive = false
getgenv().EventLockedPos = nil 

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

-- Функция создания визуального квадрата
local function spawnVisualZone(pos)
    local part = Instance.new("Part")
    part.Name = "GlassHub_VisualZone"
    part.Anchored = true
    part.CanCollide = false
    part.CastShadow = false
    part.Transparency = 0.7
    part.Color = Color3.fromRGB(255, 0, 0) -- Красный
    part.Material = Enum.Material.ForceField
    part.Size = Vector3.new(100, 1, 100) -- Квадрат 100x100 (радиус 50)
    part.CFrame = CFrame.new(pos)
    part.Parent = workspace
    
    task.delay(3, function() -- Удаляем через 3 секунды
        part:Destroy()
    end)
end

task.spawn(function()
    while true do
        if getgenv().EventFarmActive then
            -- Если точка не зафиксирована, используем текущую позицию игрока
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local farmPos = getgenv().EventLockedPos or (root and root.Position)
            
            if farmPos and #petIds > 0 then
                local targets = {}
                local radiusSq = 50^2 
                
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
    Lock = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            getgenv().EventLockedPos = root.Position
            spawnVisualZone(root.Position) -- Спавним квадрат только при нажатии
            print("🧊 [Event]: Точка зафиксирована")
        end
    end,
    Reset = function()
        getgenv().EventLockedPos = nil
        print("🧊 [Event]: Точка сброшена (фарм вокруг игрока)")
    end
}
