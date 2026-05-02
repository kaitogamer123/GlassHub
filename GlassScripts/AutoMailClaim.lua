-- Файл: GlassScripts/AutoMailClaim.lua
return function()
    if getgenv().AutoMailLoaded then return end
    getgenv().AutoMailLoaded = true

    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
    local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)

    local function getMailIds()
        local ids = {}
        -- В PS99 путь именно такой через GetSaves
        local success, data = pcall(function() return save.GetSaves()[game.Players.LocalPlayer] end)
        
        if success and data and data.Inventory and data.Inventory.Mailbox then
            for id, _ in pairs(data.Inventory.Mailbox) do
                table.insert(ids, id)
            end
        end
        return ids
    end

    task.spawn(function()
        while true do
            if getgenv().AutoClaimMail == true then
                local mailIds = getMailIds()
                if #mailIds > 0 then
                    pcall(function()
                        network["Mailbox: Claim"]:InvokeServer(mailIds)
                    end)
                end
            end
            task.wait(5)
        end
    end)
end
