local Window = requireHttp and requireHttp("Library/Window.lua") or loadstring(game:HttpGet(""))()
local Tabs = requireHttp and requireHttp("Library/Tabs.lua") or loadstring(game:HttpGet(""))()

local Library = {}

function Library:CreateWindow(name)
    return Window.CreateWindow(name)
end

return Library
