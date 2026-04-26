-- Файл: GlassScripts/AutoTap.lua
return function()
    if getgenv().AutoTapLoaded then return end
    getgenv().AutoTapLoaded = true

    local RADIUS = 150
    local MAX_TARGETS = 20

    local player = game.Players.LocalPlayer
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local runService = game:GetService("RunService")
    local network = replicatedStorage:WaitForChild("Network"):WaitForChild("Breakables_PlayerDealDamage")

    local function getBreakables()
        local things = workspace:FindFirstChild("__THINGS")
        return things and things:FindFirstChild("Breakables")
    end

    -- Используем Heartbeat для максимальной скорости кликов
    runService.Heartbeat:Connect(function()
        -- Проверяем переменную, которую переключает кнопка
        if not getgenv().AutoTap then return end
        
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local breakablesPath = getBreakables()
        if not breakablesPath then return end
        
        local rootPos = root.Position
        local count = 0
        local objects = breakablesPath:GetChildren()

        for i = 1, #objects do
            if count >= MAX_TARGETS then break end
            
            local obj = objects[i]
            local part = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
            
            if part then
                -- Используем твою рабочую проверку дистанции
                if (rootPos - part.Position).Magnitude <= RADIUS then
                    network:FireServer(obj.Name)
                    count = count + 1
                end
            end
        end
    end)
    
    print("🧊 GlassHub: AutoTap на Heartbeat загружен!")
end
