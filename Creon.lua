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

-- Загрузка Main модуля
local MainModule
local success, err = pcall(function()
    local mainUrl = "https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Main.lua"
    MainModule = loadstring(game:HttpGet(mainUrl))()
end)

if not success then
    warn("Не удалось загрузить Main.lua: " .. err)
    -- Заглушка
    MainModule = {
        SpeedHack = {Enabled = false, DefaultSpeed = 16, CurrentSpeed = 16, MaxSpeed = 150, MinSpeed = 16},
        Noclip = {Enabled = false, Status = "Don't work, Disabled"},
        AutoQTE = {Enabled = false, RageEnabled = false, AntiStunEnabled = false},
        Rebel = {Enabled = false},
        RLGL = {GodMode = false},
        ToggleSpeedHack = function() end,
        SetSpeed = function() return 16 end,
        ToggleAutoQTE = function() end,
        ToggleRageQTE = function() end,
        ToggleAntiStunQTE = function() end,
        ToggleRebel = function() end,
        TeleportToEnd = function() end,
        TeleportToStart = function() end,
        ToggleGodMode = function() end,
        GetPlayerPosition = function() return "Не доступно" end
    }
end

-- GUI с новым дизайном
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local SoonLabel = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonX"

-- Увеличенные размеры
MainFrame.Size = UDim2.new(0, 690, 0, 528)
MainFrame.Position = UDim2.new(0.5, -345, 0.5, -264)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.Parent = ScreenGui

-- TitleBar для перемещения
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CreonX"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

TabButtons.Size = UDim2.new(0, 130, 1, -25)
TabButtons.Position = UDim2.new(0, 0, 0, 25)
TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

ContentFrame.Size = UDim2.new(1, -130, 1, -25)
ContentFrame.Position = UDim2.new(0, 130, 0, 25)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

SoonLabel.Size = UDim2.new(1, 0, 1, 0)
SoonLabel.BackgroundTransparency = 1
SoonLabel.Text = "Soon...."
SoonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SoonLabel.TextSize = 24
SoonLabel.Font = Enum.Font.Gotham
SoonLabel.Parent = ContentFrame

-- Функция для перемещения GUI
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Функция для создания красивого элемента
local function CreateButton(text, position, size)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0.85, 0, 0, 35)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 80)
    stroke.Thickness = 1
    stroke.Parent = button
    
    -- Анимация при наведении
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        }):Play()
    end)
    
    return button
end

-- Функция для создания переключателя
local function CreateToggle(text, position, enabled, callback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(0.85, 0, 0, 35)
    toggleContainer.Position = position
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentFrame
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.7, 0, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = text
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 12
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = toggleContainer
    
    local toggleIndicator = Instance.new("TextLabel")
    toggleIndicator.Size = UDim2.new(0.25, 0, 0.6, 0)
    toggleIndicator.Position = UDim2.new(0.72, 0, 0.2, 0)
    toggleIndicator.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Text = enabled and "→" or "←"
    toggleIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleIndicator.TextSize = 12
    toggleIndicator.Font = Enum.Font.GothamBold
    toggleIndicator.Parent = toggleContainer
    
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 6)
    corner1.Parent = toggleButton
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 4)
    corner2.Parent = toggleIndicator
    
    local stroke1 = Instance.new("UIStroke")
    stroke1.Color = Color3.fromRGB(80, 80, 80)
    stroke1.Thickness = 1
    stroke1.Parent = toggleButton
    
    toggleButton.MouseButton1Click:Connect(function()
        local newState = not enabled
        enabled = newState
        toggleIndicator.BackgroundColor3 = newState and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        toggleIndicator.Text = newState and "→" or "←"
        callback(newState)
    end)
    
    return toggleContainer
end

-- Функция для создания слайдера скорости
local function CreateSpeedSlider()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0.85, 0, 0, 60)
    sliderContainer.Position = UDim2.new(0.075, 0, 0.1, 0)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ContentFrame
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. MainModule.SpeedHack.CurrentSpeed
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Parent = sliderContainer
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, 0, 0, 20)
    sliderBackground.Position = UDim2.new(0, 0, 0, 25)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = sliderContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = sliderBackground
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((MainModule.SpeedHack.CurrentSpeed - MainModule.SpeedHack.MinSpeed) / (MainModule.SpeedHack.MaxSpeed - MainModule.SpeedHack.MinSpeed), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBackground
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    
    local function updateSpeed(value)
        local newSpeed = MainModule.SetSpeed(value)
        speedLabel.Text = "Speed: " .. newSpeed
        sliderFill.Size = UDim2.new((newSpeed - MainModule.SpeedHack.MinSpeed) / (MainModule.SpeedHack.MaxSpeed - MainModule.SpeedHack.MinSpeed), 0, 1, 0)
        sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, 0)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            local newSpeed = math.floor(MainModule.SpeedHack.MinSpeed + relativeX * (MainModule.SpeedHack.MaxSpeed - MainModule.SpeedHack.MinSpeed))
            updateSpeed(newSpeed)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return speedLabel
end

-- Функция для создания элементов Main вкладки
local function CreateMainContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    -- SpeedHack Toggle
    local speedToggle = CreateToggle("SpeedHack", UDim2.new(0.075, 0, 0.02, 0), MainModule.SpeedHack.Enabled, function(enabled)
        MainModule.ToggleSpeedHack(enabled)
    end)
    
    -- Speed Slider
    local speedLabel = CreateSpeedSlider()
    
    -- Auto QTE Toggle
    local qteToggle = CreateToggle("Auto QTE", UDim2.new(0.075, 0, 0.25, 0), MainModule.AutoQTE.Enabled, function(enabled)
        MainModule.ToggleAutoQTE(enabled)
    end)
    
    -- Rage QTE Toggle
    local rageToggle = CreateToggle("Rage QTE", UDim2.new(0.075, 0, 0.32, 0), MainModule.AutoQTE.RageEnabled, function(enabled)
        MainModule.ToggleRageQTE(enabled)
    end)
    
    -- Anti Stun QTE Toggle
    local antistunToggle = CreateToggle("Anti Stun QTE", UDim2.new(0.075, 0, 0.39, 0), MainModule.AutoQTE.AntiStunEnabled, function(enabled)
        MainModule.ToggleAntiStunQTE(enabled)
    end)
    
    -- Noclip Label
    local noclipLabel = CreateButton("Noclip: " .. MainModule.Noclip.Status, UDim2.new(0.075, 0, 0.46, 0))
    noclipLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    noclipLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
end

-- Функция для создания Rebel вкладки
local function CreateRebelContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    -- Заголовок REBEL
    local rebelTitle = Instance.new("TextLabel")
    rebelTitle.Size = UDim2.new(0.85, 0, 0, 40)
    rebelTitle.Position = UDim2.new(0.075, 0, 0.05, 0)
    rebelTitle.BackgroundTransparency = 1
    rebelTitle.Text = "REBEL"
    rebelTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
    rebelTitle.TextSize = 24
    rebelTitle.Font = Enum.Font.GothamBold
    rebelTitle.Parent = ContentFrame
    
    -- Instant Rebel Toggle
    local rebelToggle = CreateToggle("Instant Rebel", UDim2.new(0.075, 0, 0.2, 0), MainModule.Rebel.Enabled, function(enabled)
        MainModule.ToggleRebel(enabled)
    end)
end

-- Функция для создания RLGL вкладки
local function CreateRLGLContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local tpEndBtn = CreateButton("TP TO END", UDim2.new(0.075, 0, 0.1, 0))
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToEnd()
    end)
    
    local tpStartBtn = CreateButton("TP TO START", UDim2.new(0.075, 0, 0.2, 0))
    tpStartBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToStart()
    end)
    
    local godModeToggle = CreateToggle("GodMode", UDim2.new(0.075, 0, 0.3, 0), MainModule.RLGL.GodMode, function(enabled)
        MainModule.ToggleGodMode(enabled)
    end)
end

-- Функция для создания Settings вкладки
local function CreateSettingsContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local creatorLabel = CreateButton("Creator: Creon", UDim2.new(0.075, 0, 0.1, 0))
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local versionLabel = CreateButton("Version: 1.0", UDim2.new(0.075, 0, 0.2, 0))
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local executorLabel = CreateButton("Executor: " .. executorName, UDim2.new(0.075, 0, 0.3, 0))
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Координаты игрока
    local positionLabel = CreateButton("Position: " .. MainModule.GetPlayerPosition(), UDim2.new(0.075, 0, 0.4, 0))
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Обновление координат
    game:GetService("RunService").Heartbeat:Connect(function()
        positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
    end)
end

-- Создание вкладок
local tabs = {"Main", "Rebel", "RLGL", "Settings"}
for i, name in pairs(tabs) do
    local button = CreateButton(name, UDim2.new(0.05, 0, 0, (i-1)*55), UDim2.new(0.9, 0, 0, 45))
    button.Parent = TabButtons
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    
    if name == "Main" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateMainContent()
        end)
    elseif name == "Rebel" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateRebelContent()
        end)
    elseif name == "RLGL" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateRLGLContent()
        end)
    elseif name == "Settings" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateSettingsContent()
        end)
    end
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Position = UDim2.new(0.5, -345, 0.5, -264)
        end
    end
end)

-- Автоматически открываем Main вкладку
CreateMainContent()

print("CreonX загружен! Нажми M для открытия/закрытия")
