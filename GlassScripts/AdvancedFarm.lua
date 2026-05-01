local RS = game:GetService("ReplicatedStorage")
local Network = RS:WaitForChild("Network"):WaitForChild("Breakables_JoinPetBulk")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local things = workspace:WaitForChild("__THINGS")
local breakables = things:WaitForChild("Breakables")
local petsFolder = things:WaitForChild("Pets")
local Map3 = workspace:WaitForChild("Map3")

getgenv().AdvancedFarmActive = false
getgenv().LockedZone = nil 

local petIds = {}

local function log(msg)
    print("🧊 [AdvancedFarm]: " .. tostring(msg))
end

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

local function getNearestZone()
    local closest, dist = nil, math.huge
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, folder in ipairs(Map3:GetChildren()) do
        local zone = folder:FindFirstChild("INTERACT", true) and folder.INTERACT:FindFirstChild("BREAK_ZONES", true) and folder.INTERACT.BREAK_ZONES:FindFirstChild("BREAK_ZONE")
        if zone then
            local d = (zone.Position - root.Position).Magnitude
            if d < dist then
                dist = d
                closest = zone
            end
        end
    end
    return closest
end

task.spawn(function()
    log("Скрипт готов к работе.")
    while true do
        if getgenv().AdvancedFarmActive then
            local targetZone = getgenv().LockedZone or getNearestZone()
            
            if targetZone and #petIds > 0 then
                local zonePos = targetZone.Position
                local targets = {}
                local allBreakables = breakables:GetChildren()
                
                for i = 1, #allBreakables do
                    local obj = allBreakables[i]
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    
                    if part then
                        if (part.Position - zonePos).Magnitude <= 85 then
                            table.insert(targets, obj.Name)
                        end
                    end
                    if #targets >= 40 then break end 
                end

                if #targets > 0 then
                    local attackData = {}
                    for i = 1, #petIds do
                        attackData[petIds[i]] = targets[((i - 1) % #targets) + 1]
                    end
                    Network:FireServer(attackData)
                end
            end
        end
        task.wait(0.1)
    end
end)

return function(state)
    getgenv().AdvancedFarmActive = state
    log(state and "Фарм запущен" or "Фарм остановлен")
end
