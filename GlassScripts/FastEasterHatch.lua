-- Файл: GlassScripts/FastEasterHatch.lua
return function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Network = ReplicatedStorage:WaitForChild("Network")
    local remote = Network:WaitForChild("Instancing_InvokeCustomFromClient")
    
    local THREADS = 30
    local DELAY = 0.02 

    local function hatch()
        remote:InvokeServer("EasterHatchEvent", "HatchRequest")
        if math.random() < 0.125 then
            remote:InvokeServer("EasterHatchEvent", "HatchRequest", math.random(1, 3))
        end
    end

    for i = 1, THREADS do
        task.spawn(function()
            while true do
                -- Используем глобальную переменную, которую будет менять Toggle
                if getgenv().FastEasterHatch then
                    hatch()
                    task.wait(DELAY)
                else
                    task.wait(0.5)
                end
            end
        end)
    end
end
