-- Проверка исполнителя
local executorName = "Unknown"
if identifyexecutor then
    executorName = identifyexecutor()
elseif getexecutorname then
    executorName = getexecutorname()
end

local supportedExecutors = {"xeno", "bunnu", "volcano", "potassium", "seliware", "zenith", "bunni"}
local isSupported = false

for _, name in pairs(supportedExecutors) do
    if executorName:lower():find(name:lower()) then
        isSupported = true
        break
    end
end

if not isSupported then
    error("Unsupported executor: " .. executorName)
    return
end

-- Античит байпас
_G.ANypass = true
if _G.ANypass then
    local function optimizedStealth()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local original_nc = mt.__namecall
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod()
                if method:lower():find("detect") or method:lower():find("check") or method:lower():find("kick") then
                    return nil
                end
                return original_nc(self, ...)
            end
            setreadonly(mt, true)
        end
        task.spawn(function()
            pcall(function()
                for _, obj in pairs(game:GetService("CoreGui"):GetChildren()) do
                    if obj.Name:lower():find("dex") or obj.Name:lower():find("explorer") then
                        obj:Destroy()
                    end
                end
            end)
        end)
    end
    optimizedStealth()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local oldhmmi
    local oldhmmnc
    if hookfunction then
        hookfunction(LocalPlayer.Kick, function() end)
    end
    if hookmetamethod then
        oldhmmi = hookmetamethod(game, "__index", function(self, method)
            if self == LocalPlayer and method:lower() == "kick" then
                return error("Expected ':' not '.' calling member function Kick", 2)
            end
            return oldhmmi(self, method)
        end)
        oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
            if self == LocalPlayer and getnamecallmethod():lower() == "kick" then
                return
            end
            return oldhmmnc(self, ...)
        end)
    end
    print("Unmatched Full Anti-Cheat Bypass Active")
end

-- Загрузка Main модуля из того же репозитория
local MainModule
local success, err = pcall(function()
    -- Используем тот же базовый путь что и для этого скрипта
    local mainUrl = "https://raw.githubusercontent.com/gosdinmadan-ops/creonxx/main/Main.lua"
    MainModule = loadstring(game:HttpGet(mainUrl))()
end)

if not success then
    warn("Не удалось загрузить Main.lua: " .. err)
    -- Создаем заглушку если файл не загрузился
    MainModule = {
        SpeedHack = {Enabled = false, DefaultSpeed = 16, CurrentSpeed = 16, MaxSpeed = 150},
        Noclip = {Enabled = false, Status = "Don't work, Disabled"},
        AutoQTE = {Enabled = false},
        ToggleSpeedHack = function(enabled)
            MainModule.SpeedHack.Enabled = enabled
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if enabled then
                        MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
                        humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                    else
                        humanoid.WalkSpeed = MainModule.SpeedHack.DefaultSpeed
                    end
                end
            end
        end,
        SetSpeed = function(value)
            MainModule.SpeedHack.CurrentSpeed = value
            if MainModule.SpeedHack.Enabled then
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = value
                    end
                end
            end
        end,
        ToggleAutoQTE = function(enabled)
            MainModule.AutoQTE.Enabled = enabled
            if enabled then
                task.spawn(function()
                    while MainModule.AutoQTE.Enabled do
                        pcall(function()
                            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteForQTE")
                            if remote and remote:IsA("RemoteEvent") then
                                remote:FireServer()
                            end
                        end)
                        task.wait(0.2)
                    end
                end)
            end
        end,
        EnableRageQTE = function() end,
        DisableRageQTE = function() end,
        EnableAntiStunQTE = function() end,
        DisableAntiStunQTE = function() end
    }
end

-- GUI
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local SoonLabel = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonX"

MainFrame.Size = UDim2.new(0, 600, 0, 480)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
TitleLabel.BorderSizePixel = 0
TitleLabel.Text = "CreonX"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame

TabButtons.Size = UDim2.new(0, 120, 1, -30)
TabButtons.Position = UDim2.new(0, 0, 0, 30)
TabButtons.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
TabButtons.Parent = MainFrame

ContentFrame.Size = UDim2.new(1, -120, 1, -30)
ContentFrame.Position = UDim2.new(0, 120, 0, 30)
ContentFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
ContentFrame.Parent = MainFrame

SoonLabel.Size = UDim2.new(1, 0, 1, 0)
SoonLabel.BackgroundTransparency = 1
SoonLabel.Text = "Soon...."
SoonLabel.TextColor3 = Color3.new(1, 1, 1)
SoonLabel.TextSize = 28
SoonLabel.Font = Enum.Font.Gotham
SoonLabel.Parent = ContentFrame

local tabs = {"Main", "Combat", "Misc", "Settings"}
local buttons = {}
local currentContent = {}

-- Функция для создания элементов Main вкладки
local function CreateMainContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    -- SpeedHack Toggle
    local speedToggle = Instance.new("TextButton")
    speedToggle.Size = UDim2.new(0.8, 0, 0, 30)
    speedToggle.Position = UDim2.new(0.1, 0, 0.1, 0)
    speedToggle.BackgroundColor3 = MainModule.SpeedHack.Enabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
    speedToggle.BorderSizePixel = 0
    speedToggle.Text = "SpeedHack: " .. (MainModule.SpeedHack.Enabled and "ON" or "OFF")
    speedToggle.TextColor3 = Color3.new(1, 1, 1)
    speedToggle.TextSize = 14
    speedToggle.Font = Enum.Font.Gotham
    speedToggle.Parent = ContentFrame
    
    speedToggle.MouseButton1Click:Connect(function()
        MainModule.ToggleSpeedHack(not MainModule.SpeedHack.Enabled)
        speedToggle.BackgroundColor3 = MainModule.SpeedHack.Enabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
        speedToggle.Text = "SpeedHack: " .. (MainModule.SpeedHack.Enabled and "ON" or "OFF")
    end)
    
    -- Speed Slider
    local speedValue = Instance.new("TextLabel")
    speedValue.Size = UDim2.new(0.8, 0, 0, 20)
    speedValue.Position = UDim2.new(0.1, 0, 0.2, 0)
    speedValue.BackgroundTransparency = 1
    speedValue.Text = "Speed: " .. MainModule.SpeedHack.CurrentSpeed
    speedValue.TextColor3 = Color3.new(1, 1, 1)
    speedValue.TextSize = 14
    speedValue.Font = Enum.Font.Gotham
    speedValue.Parent = ContentFrame
    
    local speedSlider = Instance.new("TextButton")
    speedSlider.Size = UDim2.new(0.8, 0, 0, 20)
    speedSlider.Position = UDim2.new(0.1, 0, 0.25, 0)
    speedSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    speedSlider.BorderSizePixel = 0
    speedSlider.Text = "▲ Increase Speed ▼"
    speedSlider.TextColor3 = Color3.new(1, 1, 1)
    speedSlider.TextSize = 12
    speedSlider.Font = Enum.Font.Gotham
    speedSlider.Parent = ContentFrame
    
    speedSlider.MouseButton1Click:Connect(function()
        if MainModule.SpeedHack.CurrentSpeed < MainModule.SpeedHack.MaxSpeed then
            MainModule.SetSpeed(MainModule.SpeedHack.CurrentSpeed + 5)
            speedValue.Text = "Speed: " .. MainModule.SpeedHack.CurrentSpeed
        end
    end)
    
    -- Noclip Label
    local noclipLabel = Instance.new("TextLabel")
    noclipLabel.Size = UDim2.new(0.8, 0, 0, 30)
    noclipLabel.Position = UDim2.new(0.1, 0, 0.35, 0)
    noclipLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    noclipLabel.BorderSizePixel = 0
    noclipLabel.Text = "Noclip: " .. MainModule.Noclip.Status
    noclipLabel.TextColor3 = Color3.new(1, 1, 1)
    noclipLabel.TextSize = 14
    noclipLabel.Font = Enum.Font.Gotham
    noclipLabel.Parent = ContentFrame
    
    -- Auto QTE Toggle
    local qteToggle = Instance.new("TextButton")
    qteToggle.Size = UDim2.new(0.8, 0, 0, 30)
    qteToggle.Position = UDim2.new(0.1, 0, 0.5, 0)
    qteToggle.BackgroundColor3 = MainModule.AutoQTE.Enabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
    qteToggle.BorderSizePixel = 0
    qteToggle.Text = "Auto QTE: " .. (MainModule.AutoQTE.Enabled and "ON" or "OFF")
    qteToggle.TextColor3 = Color3.new(1, 1, 1)
    qteToggle.TextSize = 14
    qteToggle.Font = Enum.Font.Gotham
    qteToggle.Parent = ContentFrame
    
    qteToggle.MouseButton1Click:Connect(function()
        MainModule.ToggleAutoQTE(not MainModule.AutoQTE.Enabled)
        qteToggle.BackgroundColor3 = MainModule.AutoQTE.Enabled and Color3.new(0, 0.5, 0) or Color3.new(0.5, 0, 0)
        qteToggle.Text = "Auto QTE: " .. (MainModule.AutoQTE.Enabled and "ON" or "OFF")
    end)
    
    currentContent = {speedToggle, speedValue, speedSlider, noclipLabel, qteToggle}
end

-- Создание вкладок
for i, name in pairs(tabs) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 48)
    button.Position = UDim2.new(0, 0, 0, (i-1)*48)
    button.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.Parent = TabButtons
    
    if name == "Main" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateMainContent()
        end)
    elseif name == "Settings" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            for _, child in pairs(ContentFrame:GetChildren()) do
                if child ~= SoonLabel then
                    child:Destroy()
                end
            end
            
            local creatorLabel = Instance.new("TextLabel")
            creatorLabel.Size = UDim2.new(1, -20, 0, 25)
            creatorLabel.Position = UDim2.new(0, 10, 0, 50)
            creatorLabel.BackgroundTransparency = 1
            creatorLabel.Text = "Creator: Creon"
            creatorLabel.TextColor3 = Color3.new(1, 1, 1)
            creatorLabel.TextSize = 16
            creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
            creatorLabel.Font = Enum.Font.Gotham
            creatorLabel.Parent = ContentFrame
            
            local versionLabel = Instance.new("TextLabel")
            versionLabel.Size = UDim2.new(1, -20, 0, 25)
            versionLabel.Position = UDim2.new(0, 10, 0, 80)
            versionLabel.BackgroundTransparency = 1
            versionLabel.Text = "Version: 1.0"
            versionLabel.TextColor3 = Color3.new(1, 1, 1)
            versionLabel.TextSize = 16
            versionLabel.TextXAlignment = Enum.TextXAlignment.Left
            versionLabel.Font = Enum.Font.Gotham
            versionLabel.Parent = ContentFrame
            
            local executorLabel = Instance.new("TextLabel")
            executorLabel.Size = UDim2.new(1, -20, 0, 25)
            executorLabel.Position = UDim2.new(0, 10, 0, 110)
            executorLabel.BackgroundTransparency = 1
            executorLabel.Text = "Executor: " .. executorName
            executorLabel.TextColor3 = Color3.new(1, 1, 1)
            executorLabel.TextSize = 16
            executorLabel.TextXAlignment = Enum.TextXAlignment.Left
            executorLabel.Font = Enum.Font.Gotham
            executorLabel.Parent = ContentFrame
        end)
    else
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = true
            for _, child in pairs(ContentFrame:GetChildren()) do
                if child ~= SoonLabel then
                    child:Destroy()
                end
            end
        end)
    end
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Автоматически открываем Main вкладку
CreateMainContent()


