local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local player = game:GetService("Players").LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")

getgenv().EventFarmActive = false
getgenv().EventLockedPos = nil 
getgenv().EventFarmRadius = 50 

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

-- Функция создания визуального круга с эффектами
local function showVisualRadius()
    if lastVisualCircle then lastVisualCircle:Destroy() end

    local circle = Instance.new("Part")
    circle.Name = "GlassHub_VisualRadius"
    circle.Shape = Enum.PartType.Cylinder
    circle.Anchored = true
    circle.CanCollide = false
    circle.Transparency = 1 -- Начинаем с полной прозрачности
    circle.Color = Color3.fromRGB(80, 120, 255) -- Синий под стиль GlassHub
    circle.Material = Enum.Material.Neon
    
    local diameter = getgenv().EventFarmRadius * 2
    circle.Size = Vector3.new(0.2, diameter, diameter)
    circle.Parent = workspace
    lastVisualCircle = circle

    -- Анимация появления (Fade In)
    TweenService:Create(circle, TweenInfo.new(0.5), {Transparency = 0.7}):Play()

    -- Логика следования и удаления
    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not circle or not circle.Parent then 
            connection:Disconnect() 
            return 
        end

        -- Если позиция не залокана, круг двигается за игроком
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local currentPos = getgenv().EventLockedPos or (root and root.Position)

        if currentPos then
            circle.CFrame = CFrame.new(currentPos - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
        end

        -- Через 3 секунды начинаем исчезновение
        if tick() - startTime > 3 then
            connection:Disconnect()
            local fadeOut = TweenService:Create(circle, TweenInfo.new(0.5), {Transparency = 1, Size = Vector3.new(0,0,0)})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                circle:Destroy()
            end)
        end
    end)
end

-- Основной цикл фарма
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
        task.wait(0.1)
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
        end
    end,
    Reset = function()
        getgenv().EventLockedPos = nil
    end
}
