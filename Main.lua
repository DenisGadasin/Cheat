local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Roblox Cheat", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ESPSection = MainTab:AddSection({
    Name = "ESP & Aimbot"
})

-- Переменные
local ESPEnabled = false
local AimbotEnabled = false
local WalkSpeed = 16
local AimFOV = 100
local Player = game.Players.LocalPlayer

-- FOV круг
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 50
FOVCircle.Radius = AimFOV
FOVCircle.Visible = false
FOVCircle.Filled = false

local function UpdateFOV()
    FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation()
    FOVCircle.Radius = AimFOV
    FOVCircle.Visible = AimbotEnabled
end

game:GetService("RunService").RenderStepped:Connect(UpdateFOV)

-- Функция для создания ESP
local function ApplyESP()
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and not v:FindFirstChild("Highlight") then
            local esp = Instance.new("Highlight", v)
            esp.FillColor = Color3.fromRGB(17, 164, 255)
        end
    end
end

-- Включение/выключение ESP
MainTab:AddToggle({
    Name = "Toggle ESP",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            ApplyESP()
        else
            for _, v in pairs(game.Workspace:GetDescendants()) do
                if v:FindFirstChild("Highlight") then
                    v:FindFirstChild("Highlight"):Destroy()
                end
            end
        end
    end
})

-- Обновление ESP после респавна
Player.CharacterAdded:Connect(function()
    wait(1)
    if ESPEnabled then
        ApplyESP()
    end
end)

-- Aimbot
local Players = game:GetService("Players")
local Camera = game.Workspace.CurrentCamera
local AimEnabled = false
local AimPart = "Head"

local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild(AimPart) then
            local part = player.Character[AimPart]
            local distance = (part.Position - Camera.CFrame.Position).Magnitude

            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

            if onScreen and distToMouse <= AimFOV and distance < shortestDistance then
                closestTarget = part
                shortestDistance = distance
            end
        end
    end
    return closestTarget
end

game:GetService("RunService").RenderStepped:Connect(function()
    if AimEnabled and AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

MainTab:AddToggle({
    Name = "Toggle Aimbot",
    Default = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and AimbotEnabled then
        AimEnabled = true
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimEnabled = false
    end
end)

-- Ползунок для скорости
MainTab:AddSlider({
    Name = "Speed Hack",
    Min = 16,
    Max = 50,
    Default = 16,
    Increment = 1,
    Callback = function(Value)
        WalkSpeed = Value
        if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
            Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = WalkSpeed
        end
    end
})

-- Ползунок для FOV
MainTab:AddSlider({
    Name = "Aimbot FOV",
    Min = 50,
    Max = 500,
    Default = 100,
    Increment = 10,
    Callback = function(Value)
        AimFOV = Value
    end
})

OrionLib:Init()
