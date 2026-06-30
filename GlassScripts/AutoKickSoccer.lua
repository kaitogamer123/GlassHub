local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer

local lastCheckTime = 0
if not _G.SessionGoals then
    _G.SessionGoals = { gift = 0, huge1 = 0, huge2 = 0, titanic = 0, gargantuan = 0 }
end

local function isIntermissionActive()
    local things = Workspace:FindFirstChild("__THINGS")
    local soccerInstance = things and things:FindFirstChild("Instances") and things.Instances:FindFirstChild("SoccerEvent")
    if not soccerInstance then return false end
    local intermission = soccerInstance:FindFirstChild("IntermissionText")
    if not intermission then return false end
    
    local gate = intermission:FindFirstChild("Gate")
    local surfaceGui = gate and gate:FindFirstChild("SurfaceGui")
    local textLabel = surfaceGui and surfaceGui:FindFirstChild("TextLabel")
    
    if surfaceGui and surfaceGui.Enabled == true and textLabel and textLabel.Visible == true then
        local txt = string.lower(textLabel.Text)
        local cleanText = string.gsub(txt, "%s+", "")
        if cleanText ~= "" and cleanText ~= "loading..." and (string.match(cleanText, "%d+") or string.find(cleanText, "inter")) then
            return true
        end
    end
    return false
end

task.spawn(function()
    local networkFolder = ReplicatedStorage:WaitForChild("Network")
    local invokeCustom = networkFolder:WaitForChild("Instancing_InvokeCustomFromClient")
    
    while true do
        if _G.AutoPerfectPowerActive then
            if getgenv().SoccerNotificationPause then
                task.wait(0.5)
            else
                if isIntermissionActive() then
                    task.wait(0.5)
                else
                    local randomPower = math.random(94, 99) / 100
                    local success, response = pcall(function() 
                        return invokeCustom:InvokeServer("SoccerEvent", "GZ_Step", randomPower) 
                    end)
                    
                    local nextDelay = 0.02
                    
                    if success and type(response) == "table" then
                        if response.Success == false then
                            _G.SessionGoals = { gift = 0, huge1 = 0, huge2 = 0, titanic = 0, gargantuan = 0 }
                            if _G.SoccerStats then _G.SoccerStats.StatsBreakdown = "G: 0 | H1: 0 | H2: 0 | TT: 0 | Garg: 0" end
                        else
                            if type(response.Rings) == "table" and #response.Rings > 0 then
                                for _, ringData in pairs(response.Rings) do
                                    local rawId = ringData.Id and tostring(ringData.Id)
                                    if rawId then
                                        if rawId == "Gift" or rawId == "gift" then _G.SessionGoals.gift = _G.SessionGoals.gift + 1
                                        elseif rawId == "Huge1" or rawId == "huge1" then _G.SessionGoals.huge1 = _G.SessionGoals.huge1 + 1
                                        elseif rawId == "Huge2" or rawId == "huge2" then _G.SessionGoals.huge2 = _G.SessionGoals.huge2 + 1
                                        elseif rawId == "Titanic" or rawId == "titanic" then _G.SessionGoals.titanic = _G.SessionGoals.titanic + 1
                                        elseif rawId == "Gargantuan" or rawId == "gargantuan" then _G.SessionGoals.gargantuan = _G.SessionGoals.gargantuan + 1 end
                                    end
                                end
                            end
                            
                            if _G.SoccerStats then
                                _G.SoccerStats.StatsBreakdown = string.format(
                                    "G: %s | H1: %s | H2: %s | TT: %s | Garg: %s",
                                    tostring(_G.SessionGoals.gift), tostring(_G.SessionGoals.huge1),
                                    tostring(_G.SessionGoals.huge2), tostring(_G.SessionGoals.titanic), tostring(_G.SessionGoals.gargantuan)
                                )
                            end
                        end

                        if response.Studs and _G.SoccerStats then
                            local studs = tonumber(response.Studs) or 0
                            if studs >= 1000000 then _G.SoccerStats.KickDistance = string.format("%.2fM", studs / 1000000)
                            elseif studs >= 1000 then _G.SoccerStats.KickDistance = string.format("%.1fK", studs / 1000)
                            else _G.SoccerStats.KickDistance = tostring(studs) end
                        end
                        nextDelay = math.random(1, 4) / 100
                    else
                        nextDelay = 1.0
                    end
                    task.wait(nextDelay)
                end
            end
        else
            task.wait(0.5)
        end
    end
end)
