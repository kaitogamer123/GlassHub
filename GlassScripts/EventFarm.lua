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
local lastCircle = nil
local lastChangeTime = 0
local connection = nil

-- Обновление списка петов
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

-- Плавное удаление круга
local function fadeOutCircle(circle)
    if not circle then return end
    local tween = TweenService:Create(circle, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Transparency = 1,
        Size = Vector3.new(0, 0, 0)
    })
    tween:Play()
    tween.Completed:Connect(function() circle:Destroy() end)
end

-- Визуальный объемный цилиндр
local function showVisualRadius()
    lastChangeTime = tick()
    
    local height = 2.5 -- Высота цилиндра
    local d = getgenv().EventFarmRadius * 2
    
    if lastCircle and lastCircle.Parent then
        TweenService:Create(lastCircle, TweenInfo.new(0.1), {Size = Vector3.new(height, d, d)}):Play()
        return 
    end

    local circle = Instance.new("Part")
    circle.Name = "GlassHub_VisualRadius"
    circle.Shape = Enum.PartType.Cylinder
    circle.Anchored = true
    circle.CanCollide = false
    circle.Transparency = 1
    circle.Color = Color3.fromRGB(80, 120, 255)
    circle.Material = Enum.Material.Neon
    
    circle.Size = Vector3.new(height, d, d)
    circle.Parent = workspace
    lastCircle = circle

    TweenService:Create(circle, TweenInfo.new(0.4), {Transparency = 0.7}):Play()

    if connection then connection:Disconnect() end
    connection = RunService.RenderStepped:Connect(function()
        if not circle or not circle.Parent then 
            if connection then connection:Disconnect() end
            return 
        end

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local pos = getgenv().EventLockedPos or (root and root.Position)

        if pos then
            -- Смещение 2.0 вместо 2.8, чтобы цилиндр стоял НА локе, а не под ней
            circle.CFrame = CFrame.new(pos - Vector3.new(0, 2.0, 0)) * CFrame.Angles(0, 0, math.rad(90))
        end

        if tick() - lastChangeTime > 5 then
            connection:Disconnect()
            lastCircle = nil
            fadeOutCircle(circle)
        end
    end)
end

-- ЦИКЛ ФАРМА
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
                
                -- Поиск объектов в радиусе
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

                -- Отправка данных на сервер
                if #targets > 0 then
                    local data = {}
                    for i = 1, #petIds do
                        local targetId = targets[((i - 1) % #targets) + 1]
                        data[petIds[i]] = targetId
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
    SetRadius = function(v) 
        getgenv().EventFarmRadius = v 
        showVisualRadius() 
    end,
    Show = function() showVisualRadius() end,
    Lock = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then 
            getgenv().EventLockedPos = root.Position 
            showVisualRadius() -- Сразу показываем круг при локе
        end
    end,
    Reset = function() 
        getgenv().EventLockedPos = nil 
    end
}
