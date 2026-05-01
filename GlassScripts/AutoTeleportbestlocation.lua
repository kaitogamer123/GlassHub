local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local ZoneCmds = require(ReplicatedStorage.Library.Client.ZoneCmds)

_G.AutoTeleportbestlocation = false
_G.Teleportbestlocationaccept = 0

local currentBestNum = -1
local stayConnection = nil
local FREE_DISTANCE = 30

-- Поиск папки зоны во всех мирах (Map, Map2, Map3 и т.д.)
local function findZoneFolder(targetNum)
    local containers = {"Map", "Map2", "Map3", "Map4", "Map5"}
    for _, name in ipairs(containers) do
        local c = workspace:FindFirstChild(name)
        if c then
            for _, folder in ipairs(c:GetChildren()) do
                local n = tonumber(folder.Name:match("^(%d+)"))
                if n == targetNum then return folder end
            end
        end
    end
    return nil
end

local function doTeleport()
    if not _G.AutoTeleportbestlocation or tick() < _G.Teleportbestlocationaccept then return end
    
    local _, zoneData = ZoneCmds.GetMaxOwnedZone()
    if not zoneData or not zoneData.ZoneNumber then return end
    
    local bestNum = zoneData.ZoneNumber
    local folder = findZoneFolder(bestNum)
    if not folder then return end
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Ищем MainPart для телепорта (центр зоны)
    local mainPart = nil
    local interact = folder:FindFirstChild("INTERACT")
    if interact then
        for _, v in ipairs(interact:GetDescendants()) do
            if v:IsA("BasePart") and v.Name:match("^Main") then
                mainPart = v
                break
            end
        end
    end

    -- Если нет MainPart, ищем точку Teleport
    if not mainPart then
        local persistent = folder:FindFirstChild("PERSISTENT")
        local zoneTP = persistent and persistent:FindFirstChild("Teleport")
        if zoneTP then
            if (root.Position - zoneTP.Position).Magnitude > 20 then
                root.CFrame = zoneTP.CFrame * CFrame.new(0, 3, 0)
            end
        end
        return
    end

    -- Удержание в зоне
    if (root.Position - mainPart.Position).Magnitude > FREE_DISTANCE then
        root.CFrame = mainPart.CFrame * CFrame.new(0, 3, 0)
    end

    -- Обновление соединения Heartbeat при смене зоны
    if not stayConnection or currentBestNum ~= bestNum then
        if stayConnection then stayConnection:Disconnect() end
        currentBestNum = bestNum
        
        stayConnection = RunService.Heartbeat:Connect(function()
            if not _G.AutoTeleportbestlocation or tick() < _G.Teleportbestlocationaccept then
                if stayConnection then stayConnection:Disconnect(); stayConnection = nil end
                return
            end
            if root and mainPart and mainPart.Parent then
                if (root.Position - mainPart.Position).Magnitude > FREE_DISTANCE then
                    root.CFrame = mainPart.CFrame * CFrame.new(0, 3, 0)
                end
            end
        end)
    end
end

-- Основной цикл
task.spawn(function()
    print("🧊 [GlassHub]: Auto Teleport Best Location Loaded")
    while true do
        local success, err = pcall(doTeleport)
        if not success then warn("Teleport Error: " .. tostring(err)) end
        task.wait(1)
    end
end)

-- Возвращаем функцию управления для лоадера
return function(state)
    _G.AutoTeleportbestlocation = state
end
