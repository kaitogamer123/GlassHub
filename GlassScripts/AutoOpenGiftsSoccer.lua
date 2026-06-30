local ReplicatedStorage = game:GetService("ReplicatedStorage")

task.spawn(function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local unlockRemote = replicatedStorage:WaitForChild("Network"):WaitForChild("WR_Unlock")
    
    local giftVectors = {
        Vector3.new(1428.330322265625, -6.832083702087402, -32052.076171875),
        Vector3.new(1435.823974609375, -6.832083702087402, -32057.38671875),
        Vector3.new(1419.276611328125, -6.832083702087402, -32053.62109375),
        Vector3.new(1437.3677978515625, -6.832083702087402, -32066.44140625),
        Vector3.new(1413.9664306640625, -6.832083702087402, -32061.11328125),
        Vector3.new(1432.0576171875, -6.832083702087402, -32073.93359375),
        Vector3.new(1415.51025390625, -6.832083702087402, -32070.16796875),
        Vector3.new(1423.00390625, -6.832083702087402, -32075.478515625)
    }

    if not _G.GlassHubConfig then _G.GlassHubConfig = { AutoGifts = true } end

    while true do
        if _G.GlassHubConfig and _G.GlassHubConfig.AutoGifts == true then
            pcall(function()
                local args = { "5615d7e06a684cbfafa26674ead6cceb", 8, giftVectors }
                unlockRemote:InvokeServer(unpack(args))
            end)
            task.wait(0.01)
        else
            task.wait(0.5)
        end
    end
end)
