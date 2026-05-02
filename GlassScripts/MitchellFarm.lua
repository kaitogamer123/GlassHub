-- Файл: GlassScripts/MitchellFarm.lua
return function()
    if getgenv().MitchellLoaded then return end
    getgenv().MitchellLoaded = true

    local player = game:GetService("Players").LocalPlayer
    local things = workspace:WaitForChild("__THINGS")

    task.spawn(function()
        while true do
            if getgenv().AutoMitchellActive == true then
                -- Безопасный поиск папки без зависания консоли
                local targetFolder = things:FindFirstChild("AdminAbuseCharacters")
                
                if targetFolder then
                    local character = player.Character
                    local root = character and character:FindFirstChild("HumanoidRootPart")
                    
                    if root then
                        local items = targetFolder:GetChildren()
                        local target = items[1] -- Берем Mitchell
                        
                        if target and target:IsA("Model") then
                            local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if prompt then
                                -- ТП и активация
                                root.CFrame = target:GetPivot() * CFrame.new(0, 3, 0)
                                task.wait(0.3)
                                if fireproximityprompt then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end
