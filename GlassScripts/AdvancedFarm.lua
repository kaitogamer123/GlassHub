-- GlassScripts/AdvancedFarm.lua
local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
local Library = require(game:GetService("ReplicatedStorage").Library)
local Breakables = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("Breakables")

-- Функция для динамического поиска папки с зонами (Map1, Map2, Map3...)
local function getZonesFolder()
    for _, m in pairs(game.Workspace:GetChildren()) do
        if m.Name:match("^Map") then
            -- Прочесываем локации внутри Мапы в поиске INTERACT.BREAK_ZONES
            for _, area in pairs(m:GetChildren()) do
                local bz = area:FindFirstChild("INTERACT") and area.INTERACT:FindFirstChild("BREAK_ZONES")
                if bz then
                    return bz
                end
            end
        end
    end
    return nil
end

local Zones = getZonesFolder()

-- Обновляем ссылку на зоны раз в 5 секунд (на случай перехода в другой мир)
task.spawn(function()
    while task.wait(5) do
        Zones = getZonesFolder()
    end
end)

-- Получаем список UID твоих петов
local function getMyPets()
    local pets = {}
    local equipped = Library.PetCmds.GetEquipped()
    for _, pet in pairs(equipped) do
        table.insert(pets, pet.uid)
    end
    return pets
end

-- Поиск ближайшей зоны для фарма
local function getTargetZone()
    if getgenv().FarmMode == "Fixed" and getgenv().FixedZonePos then 
        return {Position = getgenv().FixedZonePos} 
    end
    
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not Zones then return nil end
    
    local closest, dist = nil, math.huge
    for _, zone in pairs(Zones:GetChildren()) do
        -- В Map3 зоны — это сами парты внутри BREAK_ZONES
        if zone:IsA("BasePart") then
            local d = (char.HumanoidRootPart.Position - zone.Position).Magnitude
            if d < dist then
                dist = d
                closest = zone
            end
        end
    end
    return closest
end

-- Основной цикл фарма
task.spawn(function()
    print("✅ Advanced Farm Script Started")
    while task.wait(0.1) do
        if getgenv().AdvancedFarmEnabled then
            local targetZone = getTargetZone()
            local pets = getMyPets()
            
            if targetZone and #pets > 0 then
                local args = {}
                local count = 0
                
                for _, obj in pairs(Breakables:GetChildren()) do
                    local pos = obj:GetAttribute("ParentPosition") or (obj:IsA("BasePart") and obj.Position)
                    
                    if pos then
                        local diff = (pos - targetZone.Position)
                        -- Радиус захвата объектов в зоне
                        if math.abs(diff.X) < 50 and math.abs(diff.Z) < 50 then
                            for _, petUID in pairs(pets) do
                                args[obj.Name] = petUID
                            end
                            count = count + 1
                        end
                    end
                    if count > 50 then break end -- Оптимизация, чтобы не кикнуло
                end
                
                if next(args) then
                    Network.Breakables_JoinPetBulk:FireServer({args})
                end
            end
        end
    end
end)
