local G = getgenv()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Advanced Anti-Detection
local old; old = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and (method == "Kick" or method == "kick") then 
        return nil 
    end
    return old(self, ...)
end)

G.Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150 -- ล็อคตึงๆ ในระยะสโคป
}

--// Professional UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "Ratthasat_V12_Pro"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 160)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 255, 120)
UIStroke.Thickness = 1.5
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "ELITE SCOPE V12"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

local Credit = Instance.new("TextLabel", MainFrame)
Credit.Size = UDim2.new(1, 0, 0, 15)
Credit.Position = UDim2.new(0, 0, 0, 26)
Credit.Text = "BY RATTHASAT"
Credit.BackgroundTransparency = 1
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 10

RunService.RenderStepped:Connect(function()
    Credit.TextColor3 = Color3.fromHSV(tick() % 4 / 4, 0.7, 1)
end)

--// ปรับปรุงปุ่มย่อเมนู (Minimize System)
local MiniBtn = Instance.new("TextButton", MainFrame)
MiniBtn.Size = UDim2.new(0, 20, 0, 20)
MiniBtn.Position = UDim2.new(1, -25, 0, 5)
MiniBtn.Text = "-"
MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MiniBtn.TextColor3 = Color3.fromRGB(0, 255, 120)
Instance.new("UICorner", MiniBtn)

local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1

local collapsed = false
MiniBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    Container.Visible = not collapsed
    Credit.Visible = not collapsed
    -- Tween ขนาดเมนูให้ย่อ/ขยายได้สมูทๆ
    MainFrame:TweenSize(collapsed and UDim2.new(0, 180, 0, 35) or UDim2.new(0, 180, 0, 160), "Out", "Quart", 0.3, true)
    MiniBtn.Text = collapsed and "+" or "-"
end)

local function CreateToggle(name, pos, callback)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Position = pos
    Btn.Text = name .. " [OFF]"
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Btn.Font = Enum.Font.GothamSemibold
    local BStroke = Instance.new("UIStroke", Btn)
    BStroke.Color = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function()
        local state = callback()
        Btn.Text = name .. (state and " [ON]" or " [OFF]")
        Btn.TextColor3 = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(150, 150, 150)
        BStroke.Color = state and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(40, 40, 40)
    end)
end

CreateToggle("AIMBOT", UDim2.new(0, 0, 0, 0), function() G.Settings.Aimbot = not G.Settings.Aimbot return G.Settings.Aimbot end)
CreateToggle("ESP", UDim2.new(0, 0, 0, 45), function() G.Settings.ESP = not G.Settings.ESP return G.Settings.ESP end)

--// Core Logic: ล็อคแรงสะใจตอนสโคป
local function GetTarget()
    local Target, Closest = nil, G.Settings.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local Hum = v.Character:FindFirstChildOfClass("Humanoid")
            if Hum and Hum.Health > 0 then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if OnScreen then
                    local Dist = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Dist < Closest then
                        Closest = Dist
                        Target = v.Character.Head
                    end
                end
            end
        end
    end
    return Target
end

RunService:BindToRenderStep("ScopeElite", 201, function()
    if G.Settings.Aimbot and Camera.FieldOfView < 65 then 
        local T = GetTarget()
        if T then 
            -- ล็อค 0.8 แรงและเร็วตามสั่ง
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Position), 0.8) 
        end
    end
end)

--// ESP System
local function CreateESP(Player)
    local Highlight = Instance.new("Highlight")
    RunService.RenderStepped:Connect(function()
        if G.Settings.ESP and Player.Character and Player ~= LocalPlayer then
            Highlight.Parent = Player.Character
            Highlight.FillTransparency = 1
            Highlight.OutlineColor = Color3.fromRGB(0, 255, 120)
            return
        end
        Highlight.Parent = nil
    end)
end
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
