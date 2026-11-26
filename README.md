# VORTEX-rouge
-- VORTEX RØUGE 4.3
-- Interface local para projeto próprio no Roblox Studio
-- Coloque em um LocalScript

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "VORTEX_ROUGE"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local music = Instance.new("Sound")
music.Name = "VortexMusic"
music.Volume = 0.5
music.Parent = SoundService

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 350)
main.Position = UDim2.new(0.5, -160, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
title.Text = "VORTEX RØUGE 4.3"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = main

local idBox = Instance.new("TextBox")
idBox.Position = UDim2.fromOffset(20, 80)
idBox.Size = UDim2.new(1, -40, 0, 42)
idBox.PlaceholderText = "Digite o ID da música"
idBox.Text = ""
idBox.TextColor3 = Color3.new(1, 1, 1)
idBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
idBox.Parent = main

local function makeButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Position = position
    button.Size = UDim2.new(1, -40, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = name
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Parent = main

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    button.Activated:Connect(callback)
end

makeButton("▶ TOCAR MÚSICA", UDim2.fromOffset(20, 140), function()
    local id = idBox.Text

    if id:match("^%d+$") then
        music.SoundId = "rbxassetid://" .. id
        music:Play()
    end
end)

makeButton("Ⅱ PAUSAR", UDim2.fromOffset(20, 190), function()
    music:Pause()
end)

makeButton("■ PARAR", UDim2.fromOffset(20, 240), function()
    music:Stop()
end)

makeButton("FECHAR", UDim2.fromOffset(20, 290), function()
    music:Stop()
    gui:Destroy()
    music:Destroy()
end)

print("VORTEX RØUGE carregado!")
