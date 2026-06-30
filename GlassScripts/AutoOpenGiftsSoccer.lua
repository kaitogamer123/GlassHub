-- ====================================================================
-- 10. ДИНАМИЧЕСКОЕ АВТООТКРЫТИЕ ПОДАРКОВ ОТНОСИТЕЛЬНО ИГРОКА
-- ====================================================================
local ReplicatedStorage = game:GetService("InteractivityService") or game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

task.spawn(function()
    local unlockRemote = ReplicatedStorage:WaitForChild("Network"):WaitForChild("WR_Unlock")
    
    if not _G.GlassHubConfig then 
        _G.GlassHubConfig = { AutoGifts = true } 
    end

    while true do
        -- Проверяем переключатель в твоем GUI меню
        if _G.GlassHubConfig and _G.GlassHubConfig.AutoGifts == true then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                pcall(function()
                    local pos = hrp.Position
                    
                    -- Динамически создаем 8 векторов вокруг текущей позиции игрока
                    -- Подарки будут падать по кругу на небольшом расстоянии (5 стадов), не улетая под землю (ось Y)
                    local dynamicVectors = {
                        Vector3.new(pos.X + 5,  pos.Y, pos.Z),
                        Vector3.new(pos.X - 5,  pos.Y, pos.Z),
                        Vector3.new(pos.X,      pos.Y, pos.Z + 5),
                        Vector3.new(pos.X,      pos.Y, pos.Z - 5),
                        Vector3.new(pos.X + 3.5, pos.Y, pos.Z + 3.5),
                        Vector3.new(pos.X - 3.5, pos.Y, pos.Z - 3.5),
                        Vector3.new(pos.X + 3.5, pos.Y, pos.Z - 3.5),
                        Vector3.new(pos.X - 3.5, pos.Y, pos.Z + 3.5)
                    }
                    
                    local args = { 
                        "5615d7e06a684cbfafa26674ead6cceb", 
                        8, 
                        dynamicVectors 
                    }
                    
                    unlockRemote:InvokeServer(unpack(args))
                end)
            end
            -- Бешеная скорость тика
            task.wait(0.01)
        else
            -- Если кнопка в меню выключена — отдыхаем
            task.wait(0.5)
        end
    end
end)
