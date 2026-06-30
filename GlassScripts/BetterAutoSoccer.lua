local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

task.spawn(function()
    local networkFolder = ReplicatedStorage:WaitForChild("Network")
    local notificationRemote = networkFolder:FindFirstChild("Notification") or networkFolder:FindFirstChildOfClass("RemoteEvent")
    
    if notificationRemote and notificationRemote:IsA("RemoteEvent") then
        notificationRemote.OnClientEvent:Connect(function(title, text)
            local cleanText = string.lower(tostring(text or title))
            if cleanText:find("reset") or cleanText:find("sphere") or cleanText:find("intermission") or cleanText:find("break") then
                getgenv().SoccerNotificationPause = true
            end
        end)
    end
end)

task.spawn(function()
    local networkFolder = ReplicatedStorage:WaitForChild("Network")
    local invokeCustom = networkFolder:WaitForChild("Instancing_InvokeCustomFromClient")
    
    while true do
        if _G.BetterAutoSoccerActive then
            if getgenv().SoccerNotificationPause then
                task.wait(30)
                getgenv().SoccerNotificationPause = false
            else
                local randomPower = math.random(94, 99) / 100
                task.spawn(function()
                    pcall(function()
                        invokeCustom:InvokeServer("SoccerEvent", "GZ_Step", randomPower)
                    end)
                end)
                task.wait(0.1)
            end
        else
            task.wait(0.5)
        end
    end
end)
