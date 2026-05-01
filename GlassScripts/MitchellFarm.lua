-- Файл: GlassScripts/MitchellFarm.lua
return function()
    if getgenv().MitchellLoaded then return end
    getgenv().MitchellLoaded = true

    local player = game:GetService("Players").LocalPlayer
    local targetFolder = workspace:WaitForChild("__THINGS"):WaitForChild("AdminAbuseCharacters")

    task.spawn(function()
        while true do
            -- Используем уникальную переменную хаба
            if getgenv().AutoMitchellActive then
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    local items = targetFolder:GetChildren()
                    -- Берем первый доступный объект в папке
                    local target = items[1]
                    
                    if target then
                        local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            -- Телепортация чуть выше объекта
                            rootPart.CFrame = target:GetPivot() * CFrame.new(0, 3, 0)
                            task.wait(0.3)
                            
                            -- Активация промпта (работает в большинстве экзекуторов)
                            if fireproximityprompt then
                                fireproximityprompt(prompt)
                            else
                                -- На всякий случай обычная активация
                                prompt:InputHoldBegin()
                                task.wait(0.1)
                                prompt:InputHoldEnd()
                            end
                        end
                    end
                end
            end
            task.wait(1) -- Проверка раз в секунду
        end
    end)
end
