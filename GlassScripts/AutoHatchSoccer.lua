local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer

local EggCmds = require(ReplicatedStorage:WaitForChild("Library").Client:WaitForChild("EggCmds"))
local eggCFrame = CFrame.new(1425.66479, 20.2455292, -32063.8008, -0.975344896, -4.26336797e-08, -0.220685989, -4.37113883e-08, 1, 0, 0.220685989, 9.64649072e-09, -0.975344896)

local function getNearestCustomEgg()
    local nearestID = nil
    local minDist = 25 
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local customEggs = Workspace.__THINGS:FindFirstChild("CustomEggs")
        if customEggs then
            for _, egg in pairs(customEggs:GetChildren()) do
                if egg:IsA("Model") then
                    local dist = (egg:GetPivot().Position - root.Position).Magnitude
                    if dist < minDist then minDist = dist; nearestID = egg.Name end
                end
            end
        end
    end
    return nearestID
end

task.spawn(function()
    task.wait(3)
    while true do
        if _G.AutoHatchEnabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local currentPos = hrp.Position
                local startPos = eggCFrame.Position
                local distanceXZ = math.sqrt((currentPos.X - startPos.X)^2 + (currentPos.Z - startPos.Z)^2)
                local distanceY = math.abs(currentPos.Y - startPos.Y)
                
                if distanceXZ > 27 or distanceY > 35 then 
                    local groundCFrame = eggCFrame * CFrame.new(0, -24, 0)
                    hrp.CFrame = groundCFrame
                    task.wait(0.05) 
                end
            end
            local targetEgg = getNearestCustomEgg()
            local maxAmount = EggCmds.GetMaxHatch()
            if targetEgg then pcall(function() ReplicatedStorage.Network.CustomEggs_Hatch:InvokeServer(targetEgg, maxAmount) end) end
        end
        task.wait(0.3)
    end
end)
