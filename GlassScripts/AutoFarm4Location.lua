
return function()
    if getgenv().MegaFarmLoaded then return end
    getgenv().MegaFarmLoaded = true

    local Network = require(game:GetService("ReplicatedStorage").Library.Client.Network)
    local AutoFarmCmds = require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds)
    
    -- СОЗДАНИЕ ОПОВЕЩЕНИЙ
    local ScreenGui = Instance.new("ScreenGui")
    local MainLabel = Instance.new("TextLabel")
    local StatusLabel = Instance.new("TextLabel")

    ScreenGui.Name = "GlassHub_Notify"
    ScreenGui.Parent = game:GetService("CoreGui") -- Поверх всех окон
    ScreenGui.DisplayOrder = 999

    MainLabel.Parent = ScreenGui
    MainLabel.BackgroundTransparency = 1
    MainLabel.Position = UDim2.new(0.5, -250, 0.4, 0)
    MainLabel.Size = UDim2.new(0, 500, 0, 50)
    MainLabel.Font = Enum.Font.FredokaOne
    MainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainLabel.TextSize = 35
    MainLabel.Text = "🚀 4 LOCATION FARM ACTIVATED"
    MainLabel.TextStrokeTransparency = 0
    MainLabel.Visible = false

    StatusLabel.Parent = MainLabel
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 1, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Font = Enum.Font.SourceSansBold
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    StatusLabel.TextSize = 24
    StatusLabel.Text = "Поиск зон: 0/4"
    StatusLabel.TextStrokeTransparency = 0

    local ignoredZones = {} 
    local testingTarget = nil 
    local confirmedCount = 0

    local function getZoneOfPart(part)
        local EasterEvent = workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("EasterHatchEvent")
        if not EasterEvent then return nil end
        local ZonesFolder = EasterEvent:FindFirstChild("BREAK_ZONES")
        if not ZonesFolder then return nil end
        local hp = part:FindFirstChild("Hitbox") or part:FindFirstChildWhichIsA("BasePart")
        if not hp then return nil end
        local pPos = hp.Position
        for _, zone in pairs(ZonesFolder:GetChildren()) do
            local size, pos = zone.Size, zone.Position
            if pPos.X >= pos.X - size.X/2 - 10 and pPos.X <= pos.X + size.X/2 + 10 and
               pPos.Z >= pos.Z - size.Z/2 - 10 and pPos.Z <= pos.Z + size.Z/2 + 10 then
                return zone.Name
            end
        end
        return nil
    end

    task.spawn(function()
        local Things = workspace:WaitForChild("__THINGS")
        local Breakables = Things:WaitForChild("Breakables")
        local Pets = Things:WaitForChild("Pets")
        local Orbs = Things:WaitForChild("Orbs")

        while true do
            local active = getgenv().MegaFarmSystem
            MainLabel.Visible = active -- Показываем GUI только когда кнопка включена

            if active then
                pcall(function()
                    if not AutoFarmCmds.IsEnabled() then AutoFarmCmds.Enable() end

                    -- Сбор сфер
                    local orbIds = {}
                    for _, o in pairs(Orbs:GetChildren()) do 
                        table.insert(orbIds, tonumber(o.Name)) 
                        o:Destroy() 
                    end
                    if #orbIds > 0 then Network.Fire("Orbs: Collect", orbIds) end
                    
                    -- Атака петами
                    local petIds = {}
                    for _, p in pairs(Pets:GetChildren()) do table.insert(petIds, p.Name) end
                    local allTargets = Breakables:GetChildren()

                    -- Логика теста зон
                    if not testingTarget then
                        for _, t in pairs(allTargets) do
                            local zName = getZoneOfPart(t)
                            if zName and ignoredZones[zName] == nil then
                                testingTarget = t
                                ignoredZones[zName] = "checking"
                                
                                task.delay(5, function() 
                                    if testingTarget and testingTarget.Parent == Breakables then
                                        ignoredZones[zName] = true
                                    else
                                        ignoredZones[zName] = false
                                        confirmedCount = confirmedCount + 1
                                        StatusLabel.Text = "✅ Zones: " .. confirmedCount .. "/4"
                                        
                                        if confirmedCount >= 4 then
                                            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                                            StatusLabel.Text = "🔥 ALL ZONES FINDED"
                                        end
                                    end
                                    testingTarget = nil
                                end)
                                break
                            end
                        end
                    end

                    local data = {}
                    local validTargets = {}
                    for _, t in pairs(allTargets) do
                        local zName = getZoneOfPart(t)
                        if not zName or ignoredZones[zName] == false then table.insert(validTargets, t) end
                    end

                    for _, pId in ipairs(petIds) do
                        if testingTarget then
                            data[pId] = testingTarget.Name
                        elseif #validTargets > 0 then
                            data[pId] = validTargets[math.random(1, #validTargets)].Name
                        end
                    end

                    if next(data) then Network.Fire("Breakables_JoinPetBulk", data) end
                end)
            else
                if AutoFarmCmds.IsEnabled() then pcall(function() AutoFarmCmds.Disable() end) end
            end
            task.wait(0.2)
        end
    end)
end
