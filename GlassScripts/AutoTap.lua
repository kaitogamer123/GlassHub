-- Файл: GlassScripts/AutoTap.lua
return function()
    if getgenv().AutoTapLoaded then return end
    getgenv().AutoTapLoaded = true

    local RADIUS = 150
    local MAX_TARGETS = 20
    local player = game.Players.LocalPlayer
    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Breakables_PlayerDealDamage")

    local function getBreakables()
        return workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Breakables")
    end

    task.spawn(function()
        while true do
            -- Используем getgenv для синхронизации с кнопкой
            if getgenv().AutoTapForRank then
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                
                if root then
                    local breakablesPath = getBreakables()
                    if breakablesPath then
                        local rootPos = root.Position
                        local targets = {}
                        local allBreakables = breakablesPath:GetChildren()

                        for i = 1, #allBreakables do
                            local obj = allBreakables[i]
                            local part = obj:FindFirstChild("Main") or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                local dist = (rootPos - part.Position).Magnitude
                                if dist <= RADIUS then
                                    table.insert(targets, {instance = obj, distance = dist})
                                end
                            end
                        end

                        table.sort(targets, function(a, b) return a.distance < b.distance end)

                        local limit = math.min(#targets, MAX_TARGETS)
                        for i = 1, limit do
                            if not getgenv().AutoTapForRank then break end
                            -- Сама отправка урона
                            pcall(function()
                                network:FireServer(targets[i].instance.Name)
                            end)
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end
