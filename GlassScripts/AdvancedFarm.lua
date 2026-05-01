-- GlassScripts/AdvancedFarm.lua
local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
local Library = require(game:GetService("ReplicatedStorage").Library)
local Breakables = game:GetService("Workspace").__THINGS.Breakables
local Zones = game:GetService("Workspace").__THINGS.Zones

-- Получаем список UID твоих петов
local function getMyPets()
    local pets = {}
    local equipped = Library.PetCmds.GetEquipped()
    for _, pet in pairs(equipped) do
        table.insert(pets, pet.uid)
    end
    return pets
end

-- Поиск ближайшей зоны BREAK_ZONE
local function getTargetZone()
    if getgenv().FarmMode == "Fixed" and getgenv().FixedZonePos then 
        return {Position = getgenv().FixedZonePos} 
    end
    
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closest, dist = nil, math.huge
    for _, zone in pairs(Zones:GetChildren()) do
        local bZone = zone:FindFirstChild("BREAK_ZONE")
        if bZone then
            local d = (char.HumanoidRootPart.Position - bZone.Position).Magnitude
            if d < dist then
                dist = d
                closest = bZone
            end
        end
    end
    return closest
end

-- Цикл фарма
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().AdvancedFarmEnabled then
            local targetZone = getTargetZone()
            local pets = getMyPets()
            
            if targetZone and #pets > 0 then
                local args = {}
                for _, obj in pairs(Breakables:GetChildren()) do
                    local pos = obj:GetAttribute("ParentPosition") or (obj:IsA("BasePart") and obj.Position)
                    if pos then
                        local diff = (pos - targetZone.Position)
                        -- Твои размеры зоны
                        if math.abs(diff.X) < 45 and math.abs(diff.Z) < 35 then
                            for _, petUID in pairs(pets) do
                                args[obj.Name] = petUID
                            end
                        end
                    end
                    if #args > 50 then break end -- Оптимизация пачки
                end
                
                if next(args) then
                    Network.Breakables_JoinPetBulk:FireServer({args})
                end
            end
        end
    end
end)
