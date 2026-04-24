-- Scripts/AutoHatch.lua
return function(state)
    -- Используем локальную переменную внутри файла, чтобы управлять циклом
    _G.AutoHatchEnabled = state 

    -- Если выключили, дальше код не пойдет
    if not state then 
        print("Auto Hatch остановлен")
        return 
    end

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Library = ReplicatedStorage:WaitForChild("Library")
    local EggCmds = require(Library.Client.EggCmds)
    local lp = game.Players.LocalPlayer

    local function getNearestCustomEgg()
        local nearestID = nil
        local minDist = 25 
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        if root then
            local customEggs = workspace.__THINGS:FindFirstChild("CustomEggs")
            if customEggs then
                for _, egg in pairs(customEggs:GetChildren()) do
                    if egg:IsA("Model") then
                        local dist = (egg:GetPivot().Position - root.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearestID = egg.Name
                        end
                    end
                end
            end
        end
        return nearestID
    end

    -- Запускаем цикл только если state == true
    task.spawn(function()
        local playerGui = lp:WaitForChild("PlayerGui")

        print("Auto Hatch запущен")
        while _G.AutoHatchEnabled do
            local targetEgg = getNearestCustomEgg()
            local maxAmount = EggCmds.GetMaxHatch()
            
            if targetEgg then
                pcall(function()
                    ReplicatedStorage.Network.CustomEggs_Hatch:InvokeServer(targetEgg, maxAmount)
                end)
            end
            task.wait(0.3)
        end
    end)
end
