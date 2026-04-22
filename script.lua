local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Terrain = Workspace.Terrain
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Uncap FPS if the executor supports it
if setfpscap then pcall(function() setfpscap(0) end) end

-- Clean up old instances
if CoreGui:FindFirstChild("SpongesBooster") then
    CoreGui.SpongesBooster:Destroy()
end

-- GUI Construction
local FoxBooster = Instance.new("ScreenGui")
FoxBooster.Name = "SpongesBooster"
FoxBooster.Parent = CoreGui
FoxBooster.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 135) -- Expanded to fit the new modules
MainFrame.Position = UDim2.new(0.5, -90, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
MainFrame.Active = true
MainFrame.Parent = FoxBooster

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Position = UDim2.new(0, 0, 0, 2)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.Code
TitleLabel.Text = "SPONGES FPS BOOSTER"
TitleLabel.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -10, 0, 32)
ToggleBtn.Position = UDim2.new(0, 5, 0, 26)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.Text = "FPS: OFF"
ToggleBtn.Parent = MainFrame

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, -10, 0, 32)
SpeedBtn.Position = UDim2.new(0, 5, 0, 62)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextScaled = true
SpeedBtn.Font = Enum.Font.Code
SpeedBtn.Text = "SPEED: OFF"
SpeedBtn.Parent = MainFrame

local JumpBtn = Instance.new("TextButton")
JumpBtn.Size = UDim2.new(1, -10, 0, 32)
JumpBtn.Position = UDim2.new(0, 5, 0, 98)
JumpBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.TextScaled = true
JumpBtn.Font = Enum.Font.Code
JumpBtn.Text = "JUMP: OFF"
JumpBtn.Parent = MainFrame

-- Reliable Custom Dragging
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Pop-up function
local function showPopup(text, color)
    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(1, 0, 1, 0)
    popup.Position = UDim2.new(0, 0, 0, 0)
    popup.BackgroundTransparency = 1
    popup.Text = text
    popup.Font = Enum.Font.GothamBlack
    popup.TextSize = 100
    popup.TextColor3 = color
    popup.TextStrokeTransparency = 0
    popup.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    popup.ZIndex = 100
    popup.Parent = FoxBooster
    
    task.delay(3, function()
        local tween = TweenService:Create(popup, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 1,
            TextStrokeTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function() popup:Destroy() end)
    end)
end

-- ==========================================
-- MODULE: SPEED & JUMP (Native Overrides)
-- ==========================================
local isSpeedOn = false
local speedLoop = nil

SpeedBtn.MouseButton1Click:Connect(function()
    isSpeedOn = not isSpeedOn
    if isSpeedOn then
        SpeedBtn.Text = "SPEED: ON"
        SpeedBtn.TextColor3 = Color3.fromRGB(50, 255, 50)
        showPopup("SPEED ACTIVATED", Color3.fromRGB(50, 255, 50))
        
        speedLoop = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 120 -- Tweak this multiplier if you need more juice
            end
        end)
    else
        SpeedBtn.Text = "SPEED: OFF"
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        if speedLoop then speedLoop:Disconnect(); speedLoop = nil end
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16 -- Return to default Roblox speed
        end
    end
end)

local isJumpOn = false
local jumpLoop = nil

JumpBtn.MouseButton1Click:Connect(function()
    isJumpOn = not isJumpOn
    if isJumpOn then
        JumpBtn.Text = "JUMP: ON"
        JumpBtn.TextColor3 = Color3.fromRGB(50, 255, 50)
        showPopup("JUMP ACTIVATED", Color3.fromRGB(50, 255, 50))
        
        jumpLoop = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.UseJumpPower = true
                char.Humanoid.JumpPower = 150 -- Tweak this for height
            end
        end)
    else
        JumpBtn.Text = "JUMP: OFF"
        JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        if jumpLoop then jumpLoop:Disconnect(); jumpLoop = nil end
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = 50 -- Default jump power
        end
    end
end)

-- ==========================================
-- MODULE: FPS & MEMORY BOOSTER
-- ==========================================
local isBoosted = false
local propCache = setmetatable({}, {__mode = "k"})
local connection = nil
local oldTech = nil

local function cacheAndApply(obj)
    if not obj or not obj.Parent then return end
    if obj:IsA("BasePart") then
        if not propCache[obj] then propCache[obj] = { Material = obj.Material, Reflectance = obj.Reflectance, CastShadow = obj.CastShadow } end
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        if not propCache[obj] then propCache[obj] = { Transparency = obj.Transparency } end
        obj.Transparency = 1
    elseif obj:IsA("PostEffect") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Smoke") then
        if not propCache[obj] then propCache[obj] = { Enabled = obj.Enabled } end
        obj.Enabled = false
    end
end

local function restore(obj)
    if propCache[obj] then
        for prop, val in pairs(propCache[obj]) do pcall(function() obj[prop] = val end) end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isBoosted = not isBoosted
    if isBoosted then
        ToggleBtn.Text = "FPS: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(50, 255, 50)
        MainFrame.BorderColor3 = Color3.fromRGB(50, 255, 50)
        TitleLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        showPopup("FPS ACTIVATED", Color3.fromRGB(50, 255, 50))
        
        propCache[Lighting] = { GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime }
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 0
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        
        if sethiddenproperty and gethiddenproperty then pcall(function() oldTech = gethiddenproperty(Lighting, "Technology"); sethiddenproperty(Lighting, "Technology", 2) end) end
        
        propCache[Terrain] = { WaterWaveSize = Terrain.WaterWaveSize, WaterWaveSpeed = Terrain.WaterWaveSpeed, WaterReflectance = Terrain.WaterReflectance, WaterTransparency = Terrain.WaterTransparency, Decoration = Terrain.Decoration }
        Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0; Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0; Terrain.Decoration = false
        
        for _, obj in pairs(Workspace:GetDescendants()) do cacheAndApply(obj) end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        pcall(function() settings().Network.IncomingReplicationLag = 0 end)
        
        connection = Workspace.DescendantAdded:Connect(cacheAndApply)
        pcall(function() collectgarbage("collect") end)
    else
        ToggleBtn.Text = "FPS: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
        TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        showPopup("DEACTIVATED", Color3.fromRGB(255, 50, 50))
        
        if connection then connection:Disconnect(); connection = nil end
        restore(Lighting)
        restore(Terrain)
        if sethiddenproperty and oldTech then pcall(function() sethiddenproperty(Lighting, "Technology", oldTech) end) end
        for _, obj in pairs(Workspace:GetDescendants()) do restore(obj) end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    end
end)
