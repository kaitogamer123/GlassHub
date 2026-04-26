local BASE = "https://raw.githubusercontent.com/kaitogamer123/GlassHub/refs/heads/main/"

local function requireHttp(path)
    return loadstring(game:HttpGet(BASE .. path))()
end

local Library = requireHttp("Library/Init.lua")

-- пример использования
local Window = Library:CreateWindow("🧊 GlassHub PS99")
local MainTab = Window:CreateTab("Main", "🏠")

MainTab:AddToggle("Left", "Auto Farm", function(v)
    print("Auto Farm:", v)
end)

MainTab:AddButton("Right", "Test Button", function()
    print("Button clicked")
end)

Window:Show("Main")
