-- ====================================================================
-- 10. ДИНАМИЧЕСКОЕ АВТООТКРЫТИЕ ПОДАРКОВ ОТНОСИТЕЛЬНО ИГРОКА (ФИКС)
-- ====================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

task.spawn(function()
    local networkFolder = ReplicatedStorage:WaitForChild("Network")
    local unlockRemote = networkFolder:WaitForChild("WR_Unlock")
    
    if not _G.GlassHubConfig then 
        _G.GlassHubConfig = { AutoGifts = true } 
    end

    while true do
        if _G.GlassHubConfig and _G.GlassHubConfig.AutoGifts == true then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    local pos = hrp.Position
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
            task.wait(0.01)
        else
            task.wait(0.5)
        end
    end
end)
