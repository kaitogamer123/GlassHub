return function(state)
    local success, err = pcall(function()
        local Cmd = require(game:GetService("ReplicatedStorage").Library.Client.AutoFarmCmds)
        if state then
            Cmd.Enable()
            print("AutoFarm: Script Enabled")
        else
            Cmd.Disable()
            print("AutoFarm: Script Disabled")
        end
    end)
    
    if not success then
        warn("InGameAutoFarm Error: " .. tostring(err))
    end
end
