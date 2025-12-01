-- Creon X v2.1 (оптимизированный)
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
    warn("Unsupported executor: " .. executorName)
end

-- Загрузка Main модуля
local MainModule
local success, err = pcall(function()
    MainModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Main.lua"))()
end)

if not success then
    warn("Не удалось загрузить Main.lua: " .. tostring(err))
    -- Создаем заглушку с правильными функциями
    MainModule = {
        SpeedHack = {Enabled = false, DefaultSpeed = 16, CurrentSpeed = 16, MaxSpeed = 150, MinSpeed = 16},
        Noclip = {Enabled = false, Status = "Don't work, Disabled"},
        AutoQTE = {AntiStunEnabled = false, SkySquidQTEEnabled = false},
        Rebel = {Enabled = false, InfiniteAmmo = false, RapidFire = false},
        RLGL = {GodMode = false, OriginalHeight = nil},
        Guards = {
            SelectedGuard = "Circle", 
            AutoFarm = false,
            RapidFire = false,
            InfiniteAmmo = false,
            HitboxExpander = false,
            OriginalFireRates = {},
            OriginalAmmo = {}
        },
        Dalgona = {CompleteEnabled = false, FreeLighterEnabled = false},
        HNS = {
            AutoPickup = false, 
            SpikesKill = false, 
            DisableSpikes = false, 
            KillHiders = false, 
            AutoDodge = false
        },
        TugOfWar = {AutoPull = false},
        GlassBridge = {AntiBreak = false, GlassESPEnabled = false},
        JumpRope = {
            AntiFail = false,
            TeleportToStart = false,
            TeleportToEnd = false
        },
        SkySquid = {
            AntiFall = false,
            AutoQTE = false,
            SafePlatform = false,
            VoidKill = false
        },
        SquidGame = {},
        Misc = {
            InstaInteract = false, 
            NoCooldownProximity = false,
            ESPEnabled = false,
            ESPPlayers = true,
            ESPHiders = true,
            ESPSeekers = true,
            ESPCandies = false,
            ESPKeys = true,
            ESPDoors = false,
            ESPEscapeDoors = true,
            ESPGuards = true,
            ESPHighlight = true,
            ESPDistance = true,
            ESPNames = true,
            ESPBoxes = true,
            ESPFillTransparency = 0.7,
            ESPOutlineTransparency = 0,
            ESPTextSize = 18,
            AntiStunRagdoll = false
        },
        
        -- Функции
        ToggleSpeedHack = function(enabled)
            MainModule.SpeedHack.Enabled = enabled
        end,
        SetSpeed = function(value)
            MainModule.SpeedHack.CurrentSpeed = value
            return value
        end,
        TeleportUp100 = function() end,
        TeleportDown40 = function() end,
        ToggleAntiStunQTE = function(enabled)
            MainModule.AutoQTE.AntiStunEnabled = enabled
        end,
        ToggleAntiStunRagdoll = function(enabled)
            MainModule.Misc.AntiStunRagdoll = enabled
        end,
        ToggleRebel = function(enabled)
            MainModule.Rebel.Enabled = enabled
        end,
        ToggleRebelInfiniteAmmo = function(enabled)
            MainModule.Rebel.InfiniteAmmo = enabled
        end,
        ToggleRebelRapidFire = function(enabled)
            MainModule.Rebel.RapidFire = enabled
        end,
        TeleportToEnd = function() end,
        TeleportToStart = function() end,
        ToggleGodMode = function(enabled)
            MainModule.RLGL.GodMode = enabled
        end,
        SetGuardType = function(guardType)
            MainModule.Guards.SelectedGuard = guardType
        end,
        SpawnAsGuard = function() end,
        ToggleAutoFarm = function(enabled)
            MainModule.Guards.AutoFarm = enabled
        end,
        ToggleRapidFire = function(enabled)
            MainModule.Guards.RapidFire = enabled
        end,
        ToggleInfiniteAmmo = function(enabled)
            MainModule.Guards.InfiniteAmmo = enabled
        end,
        ToggleHitboxExpander = function(enabled)
            MainModule.Guards.HitboxExpander = enabled
        end,
        CompleteDalgona = function() end,
        FreeLighter = function() end,
        ToggleAutoPickup = function(enabled)
            MainModule.HNS.AutoPickup = enabled
        end,
        ToggleSpikesKill = function(enabled)
            MainModule.HNS.SpikesKill = enabled
        end,
        ToggleDisableSpikes = function(enabled)
            MainModule.HNS.DisableSpikes = enabled
        end,
        ToggleKillHiders = function(enabled)
            MainModule.HNS.KillHiders = enabled
        end,
        ToggleAutoDodge = function(enabled)
            MainModule.HNS.AutoDodge = enabled
        end,
        ToggleAutoPull = function(enabled)
            MainModule.TugOfWar.AutoPull = enabled
        end,
        ToggleAntiBreak = function(enabled)
            MainModule.GlassBridge.AntiBreak = enabled
        end,
        ToggleGlassBridgeESP = function(enabled)
            MainModule.GlassBridge.GlassESPEnabled = enabled
        end,
        TeleportToJumpRopeStart = function() end,
        TeleportToJumpRopeEnd = function() end,
        ToggleAntiFailJumpRope = function(enabled)
            MainModule.JumpRope.AntiFail = enabled
        end,
        ToggleSkySquidAntiFall = function(enabled)
            MainModule.SkySquid.AntiFall = enabled
        end,
        ToggleSkySquidSafePlatform = function(enabled)
            MainModule.SkySquid.SafePlatform = enabled
        end,
        ToggleSkySquidVoidKill = function(enabled)
            MainModule.SkySquid.VoidKill = enabled
        end,
        ToggleInstaInteract = function(enabled)
            MainModule.Misc.InstaInteract = enabled
        end,
        ToggleNoCooldownProximity = function(enabled)
            MainModule.Misc.NoCooldownProximity = enabled
        end,
        ToggleESP = function(enabled)
            MainModule.Misc.ESPEnabled = enabled
        end,
        GetPlayerPosition = function() 
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local position = character.HumanoidRootPart.Position
                return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
            end
            return "Не доступно"
        end,
        Cleanup = function() end
    }
else
    print("Main.lua успешно загружен")
end

-- GUI Creon X v2.1
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local ContentScrolling = Instance.new("ScrollingFrame")
local ContentLayout = Instance.new("UIListLayout")
local SoonLabel = Instance.new("TextLabel")

-- Кнопка для мобильных устройств
local MobileButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXv21"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Увеличенные размеры на 30% (еще +15% от предыдущего)
local GUI_WIDTH = 860  -- 748 * 1.15
local GUI_HEIGHT = 595 -- 518 * 1.15

-- Основной фрейм
MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 2
mainStroke.Parent = MainFrame

-- TitleBar для перемещения
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = TitleBar

TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Creon X v2.1"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка закрытия
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0.5, -12.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    if UIS.TouchEnabled then
        MobileButton.Visible = true
    end
end)

-- Табы
TabButtons.Size = UDim2.new(0, 150, 1, -35)
TabButtons.Position = UDim2.new(0, 0, 0, 35)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 8)
tabCorner.Parent = TabButtons

-- Content Frame с прокруткой
ContentFrame.Size = UDim2.new(1, -150, 1, -35)
ContentFrame.Position = UDim2.new(0, 150, 0, 35)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = ContentFrame

-- Scrolling Frame для контента
ContentScrolling.Size = UDim2.new(1, -10, 1, -10)
ContentScrolling.Position = UDim2.new(0, 5, 0, 5)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.ScrollBarThickness = 6
ContentScrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScrolling.Parent = ContentFrame

ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)
ContentLayout.Parent = ContentScrolling

SoonLabel.Size = UDim2.new(1, 0, 1, 0)
SoonLabel.BackgroundTransparency = 1
SoonLabel.Text = "Coming Soon..."
SoonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SoonLabel.TextSize = 18
SoonLabel.Font = Enum.Font.Gotham
SoonLabel.Visible = false
SoonLabel.Parent = ContentScrolling

-- Кнопка для мобильных устройств
if UIS.TouchEnabled then
    MobileButton.Size = UDim2.new(0, 100, 0, 36)
    MobileButton.Position = UDim2.new(0.5, -50, 0, 8)
    MobileButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    MobileButton.BorderSizePixel = 0
    MobileButton.Text = "Creon X"
    MobileButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    MobileButton.TextSize = 12
    MobileButton.Font = Enum.Font.GothamBold
    MobileButton.Parent = ScreenGui
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 6)
    mobileCorner.Parent = MobileButton
    
    local mobileStroke = Instance.new("UIStroke")
    mobileStroke.Color = Color3.fromRGB(80, 80, 100)
    mobileStroke.Thickness = 2
    mobileStroke.Parent = MobileButton
    
    MobileButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MobileButton.Visible = false
    end)
    
    MainFrame.Visible = false
else
    MainFrame.Visible = false -- Скрываем по умолчанию, открывается на P
end

-- Функция для перемещения GUI (упрощенная)
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Функция для создания кнопок
local function CreateButton(text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(240, 240, 255)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = ContentScrolling
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = button
    
    return button
end

-- Функция для создания заголовка
local function CreateTitle(text)
    local titleContainer = Instance.new("Frame")
    titleContainer.Size = UDim2.new(1, -10, 0, 40)
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = ContentScrolling
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = text
    titleText.TextColor3 = Color3.fromRGB(255, 80, 80)
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleContainer
    
    local underline = Instance.new("Frame")
    underline.Size = UDim2.new(1, 0, 0, 2)
    underline.Position = UDim2.new(0, 0, 1, -2)
    underline.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    underline.BorderSizePixel = 0
    underline.Parent = titleContainer
    
    return titleContainer
end

-- Функция для создания переключателей (упрощенная)
local function CreateToggle(text, enabled, callback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -10, 0, 32)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentScrolling
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = toggleContainer
    
    -- Переключатель
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Size = UDim2.new(0, 50, 0, 22)
    toggleBackground.Position = UDim2.new(1, -52, 0.5, -11)
    toggleBackground.BackgroundColor3 = enabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleContainer
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 18, 0, 18)
    toggleCircle.Position = enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBackground
    
    -- Закругления
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 11)
    corner1.Parent = toggleBackground
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 9)
    corner2.Parent = toggleCircle
    
    -- Кнопка для переключения
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggleContainer
    
    local function updateToggle(newState)
        enabled = newState
        toggleBackground.BackgroundColor3 = newState and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
        toggleCircle.Position = newState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        
        if callback then
            callback(newState)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not enabled)
    end)
    
    return toggleContainer, updateToggle
end

-- Функция для создания слайдера скорости
local function CreateSpeedSlider()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -10, 0, 60)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ContentScrolling
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. MainModule.SpeedHack.CurrentSpeed
    speedLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.Parent = sliderContainer
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, 0, 0, 20)
    sliderBackground.Position = UDim2.new(0, 0, 0, 25)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = sliderContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = sliderBackground
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((MainModule.SpeedHack.CurrentSpeed - MainModule.SpeedHack.MinSpeed) / (MainModule.SpeedHack.MaxSpeed - MainModule.SpeedHack.MinSpeed), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 8)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBackground
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            local newSpeed = math.floor(MainModule.SpeedHack.MinSpeed + relativeX * (MainModule.SpeedHack.MaxSpeed - MainModule.SpeedHack.MinSpeed))
            updateSpeed(newSpeed)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return speedLabel
end

-- Функция для создания выпадающего списка
local function CreateDropdown(options, default, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(1, -10, 0, 32)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = ContentScrolling
    
    local dropdownButton = CreateButton(default .. " ▼")
    dropdownButton.Parent = dropdownContainer
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Position = UDim2.new(0, 0, 0, 0)
    dropdownButton.Text = default .. " ▼"
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, #options * 32)
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.Parent = dropdownContainer
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownList
    
    for i, option in ipairs(options) do
        local optionButton = CreateButton(option)
        optionButton.Parent = dropdownList
        optionButton.Size = UDim2.new(1, -8, 0, 28)
        optionButton.Position = UDim2.new(0, 4, 0, (i-1)*32 + 2)
        optionButton.Text = option
        
        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option .. " ▼"
            dropdownList.Visible = false
            if callback then
                callback(option)
            end
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
    
    return dropdownContainer
end

-- Функция для создания ESP настроек (оптимизированная)
local function CreateESPSettings()
    local settingsContainer = Instance.new("Frame")
    settingsContainer.Size = UDim2.new(1, -10, 0, 250)  -- Уменьшена высота
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.Parent = ContentScrolling
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, 0, 0, 25)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = "ESP Settings"
    sectionTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
    sectionTitle.TextSize = 14
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = settingsContainer
    
    local yPosition = 30
    local toggleHeight = 32
    
    -- Основные переключатели ESP
    local espToggle, updateEspToggle = CreateToggle("ESP System", MainModule.Misc.ESPEnabled, function(enabled)
        MainModule.ToggleESP(enabled)
    end)
    espToggle.Parent = settingsContainer
    espToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    -- Типы объектов ESP (только нужные)
    local espPlayersToggle, updatePlayersToggle = CreateToggle("Players", MainModule.Misc.ESPPlayers, function(enabled)
        MainModule.Misc.ESPPlayers = enabled
    end)
    espPlayersToggle.Parent = settingsContainer
    espPlayersToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espHidersToggle, updateHidersToggle = CreateToggle("Hiders", MainModule.Misc.ESPHiders, function(enabled)
        MainModule.Misc.ESPHiders = enabled
    end)
    espHidersToggle.Parent = settingsContainer
    espHidersToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espSeekersToggle, updateSeekersToggle = CreateToggle("Seekers", MainModule.Misc.ESPSeekers, function(enabled)
        MainModule.Misc.ESPSeekers = enabled
    end)
    espSeekersToggle.Parent = settingsContainer
    espSeekersToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espKeysToggle, updateKeysToggle = CreateToggle("Keys", MainModule.Misc.ESPKeys, function(enabled)
        MainModule.Misc.ESPKeys = enabled
    end)
    espKeysToggle.Parent = settingsContainer
    espKeysToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espEscapeDoorsToggle, updateEscapeDoorsToggle = CreateToggle("Escape Doors", MainModule.Misc.ESPEscapeDoors, function(enabled)
        MainModule.Misc.ESPEscapeDoors = enabled
    end)
    espEscapeDoorsToggle.Parent = settingsContainer
    espEscapeDoorsToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espGuardsToggle, updateGuardsToggle = CreateToggle("Guards", MainModule.Misc.ESPGuards, function(enabled)
        MainModule.Misc.ESPGuards = enabled
    end)
    espGuardsToggle.Parent = settingsContainer
    espGuardsToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    return settingsContainer
end

-- Функции для создания контента вкладок
local function ClearContent()
    for _, child in pairs(ContentScrolling:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            if child ~= SoonLabel then
                child:Destroy()
            end
        end
    end
    SoonLabel.Visible = false
end

-- ===================================================================
-- MAIN CONTENT
-- ===================================================================
local function CreateMainContent()
    ClearContent()
    
    CreateTitle("MAIN FUNCTIONS")
    
    local speedLabel = CreateSpeedSlider()
    
    local speedToggle = CreateToggle("SpeedHack", MainModule.SpeedHack.Enabled, function(enabled)
        MainModule.ToggleSpeedHack(enabled)
    end)
    
    local antiStunToggle = CreateToggle("Anti Stun QTE", MainModule.AutoQTE.AntiStunEnabled, function(enabled)
        MainModule.ToggleAntiStunQTE(enabled)
    end)
    
    local antiStunRagdollToggle = CreateToggle("Anti Stun + Ragdoll", MainModule.Misc.AntiStunRagdoll, function(enabled)
        MainModule.ToggleAntiStunRagdoll(enabled)
    end)
    
    local instaInteractToggle = CreateToggle("Insta Interact", MainModule.Misc.InstaInteract, function(enabled)
        MainModule.ToggleInstaInteract(enabled)
    end)
    
    local noCooldownToggle = CreateToggle("No Cooldown Proximity", MainModule.Misc.NoCooldownProximity, function(enabled)
        MainModule.ToggleNoCooldownProximity(enabled)
    end)
    
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportUp100()
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportDown40()
    end)
    
    local noclipLabel = CreateButton("Noclip: " .. MainModule.Noclip.Status)
    noclipLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    noclipLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
end

-- ===================================================================
-- COMBAT CONTENT
-- ===================================================================
local function CreateCombatContent()
    ClearContent()
    SoonLabel.Visible = true
    SoonLabel.Text = "Combat Features Coming Soon"
end

-- ===================================================================
-- MISC CONTENT
-- ===================================================================
local function CreateMiscContent()
    ClearContent()
    
    CreateTitle("MISCELLANEOUS")
    
    -- ESP System в Misc (оптимизированная)
    CreateESPSettings()
end

-- ===================================================================
-- REBEL CONTENT
-- ===================================================================
local function CreateRebelContent()
    ClearContent()
    
    CreateTitle("REBEL")
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -10, 0, 25)
    subtitle.Position = UDim2.new(0, 5, 0, 45)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Instant Rebel Functions"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = ContentScrolling
    
    local yPos = 80
    
    -- Instant Rebel
    local rebelToggle = CreateToggle("Instant Rebel", MainModule.Rebel.Enabled, function(enabled)
        MainModule.ToggleRebel(enabled)
    end)
    rebelToggle.Parent = ContentScrolling
    rebelToggle.Position = UDim2.new(0, 5, 0, yPos)
    
    yPos = yPos + 40
    
    -- Inf Ammo
    local infAmmoToggle = CreateToggle("Infinite Ammo", MainModule.Rebel.InfiniteAmmo, function(enabled)
        MainModule.ToggleRebelInfiniteAmmo(enabled)
    end)
    infAmmoToggle.Parent = ContentScrolling
    infAmmoToggle.Position = UDim2.new(0, 5, 0, yPos)
    
    yPos = yPos + 40
    
    -- Rapid Fire
    local rapidFireToggle = CreateToggle("Rapid Fire", MainModule.Rebel.RapidFire, function(enabled)
        MainModule.ToggleRebelRapidFire(enabled)
    end)
    rapidFireToggle.Parent = ContentScrolling
    rapidFireToggle.Position = UDim2.new(0, 5, 0, yPos)
end

-- ===================================================================
-- RLGL CONTENT
-- ===================================================================
local function CreateRLGLContent()
    ClearContent()
    
    CreateTitle("RED LIGHT GREEN LIGHT")
    
    local tpEndBtn = CreateButton("TP TO END")
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToEnd()
    end)
    
    local tpStartBtn = CreateButton("TP TO START")
    tpStartBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToStart()
    end)
    
    local godModeToggle = CreateToggle("GodMode", MainModule.RLGL.GodMode, function(enabled)
        MainModule.ToggleGodMode(enabled)
    end)
end

-- ===================================================================
-- GUARDS CONTENT
-- ===================================================================
local function CreateGuardsContent()
    ClearContent()
    
    CreateTitle("GUARDS")
    
    local guardDropdown = CreateDropdown({"Circle", "Triangle", "Square"}, MainModule.Guards.SelectedGuard, function(selected)
        MainModule.SetGuardType(selected)
    end)
    
    local spawnBtn = CreateButton("Spawn as Guard")
    spawnBtn.MouseButton1Click:Connect(function()
        MainModule.SpawnAsGuard()
    end)
    
    local rapidFireToggle = CreateToggle("Rapid Fire", MainModule.Guards.RapidFire, function(enabled)
        MainModule.ToggleRapidFire(enabled)
    end)
    
    local infiniteAmmoToggle = CreateToggle("Infinite Ammo", MainModule.Guards.InfiniteAmmo, function(enabled)
        MainModule.ToggleInfiniteAmmo(enabled)
    end)
    
    local hitboxToggle = CreateToggle("Hitbox Expander", MainModule.Guards.HitboxExpander, function(enabled)
        MainModule.ToggleHitboxExpander(enabled)
    end)
    
    local autoFarmToggle = CreateToggle("AutoFarm", MainModule.Guards.AutoFarm, function(enabled)
        MainModule.ToggleAutoFarm(enabled)
    end)
end

-- ===================================================================
-- DALGONA CONTENT
-- ===================================================================
local function CreateDalgonaContent()
    ClearContent()
    
    CreateTitle("DALGONA GAME")
    
    local completeBtn = CreateButton("Complete Dalgona")
    completeBtn.MouseButton1Click:Connect(function()
        MainModule.CompleteDalgona()
    end)
    
    local lighterBtn = CreateButton("Free Lighter")
    lighterBtn.MouseButton1Click:Connect(function()
        MainModule.FreeLighter()
    end)
end

-- ===================================================================
-- HNS CONTENT
-- ===================================================================
local function CreateHNSContent()
    ClearContent()
    
    CreateTitle("HIDE AND SEEK")
    
    local autoPickupToggle = CreateToggle("Auto Pickup", MainModule.HNS.AutoPickup, function(enabled)
        MainModule.ToggleAutoPickup(enabled)
    end)
    
    local spikesKillToggle = CreateToggle("Spikes Kill", MainModule.HNS.SpikesKill, function(enabled)
        MainModule.ToggleSpikesKill(enabled)
    end)
    
    local disableSpikesToggle = CreateToggle("Disable Spikes", MainModule.HNS.DisableSpikes, function(enabled)
        MainModule.ToggleDisableSpikes(enabled)
    end)
    
    local killHidersToggle = CreateToggle("Kill Hiders", MainModule.HNS.KillHiders, function(enabled)
        MainModule.ToggleKillHiders(enabled)
    end)
    
    local autoDodgeToggle = CreateToggle("AutoDodge", MainModule.HNS.AutoDodge, function(enabled)
        MainModule.ToggleAutoDodge(enabled)
    end)
end

-- ===================================================================
-- GLASS BRIDGE CONTENT
-- ===================================================================
local function CreateGlassBridgeContent()
    ClearContent()
    
    CreateTitle("GLASS BRIDGE")
    
    local antiBreakToggle = CreateToggle("Anti Break", MainModule.GlassBridge.AntiBreak, function(enabled)
        MainModule.ToggleAntiBreak(enabled)
    end)
    
    local glassESPToggle = CreateToggle("Glass Bridge ESP", MainModule.GlassBridge.GlassESPEnabled, function(enabled)
        MainModule.ToggleGlassBridgeESP(enabled)
    end)
end

-- ===================================================================
-- TUG OF WAR CONTENT
-- ===================================================================
local function CreateTugOfWarContent()
    ClearContent()
    
    CreateTitle("TUG OF WAR")
    
    local autoPullToggle = CreateToggle("Auto Pull", MainModule.TugOfWar.AutoPull, function(enabled)
        MainModule.ToggleAutoPull(enabled)
    end)
end

-- ===================================================================
-- JUMP ROPE CONTENT
-- ===================================================================
local function CreateJumpRopeContent()
    ClearContent()
    
    CreateTitle("JUMP ROPE")
    
    local tpStartBtn = CreateButton("Teleport to Start")
    tpStartBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToJumpRopeStart()
    end)
    
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToJumpRopeEnd()
    end)
    
    local antiFailToggle = CreateToggle("Anti-Fail", MainModule.JumpRope.AntiFail, function(enabled)
        MainModule.ToggleAntiFailJumpRope(enabled)
    end)
end

-- ===================================================================
-- SKY SQUID GAME CONTENT (оптимизированный)
-- ===================================================================
local function CreateSkySquidContent()
    ClearContent()
    
    CreateTitle("SKY SQUID GAME")
    
    local antiFallToggle = CreateToggle("Anti Fall - Sky Squid", MainModule.SkySquid.AntiFall, function(enabled)
        MainModule.ToggleSkySquidAntiFall(enabled)
    end)
    
    -- QTE убран, используется общий из Main
    
    local safePlatformToggle = CreateToggle("Safe Platform - Sky Squid", MainModule.SkySquid.SafePlatform, function(enabled)
        MainModule.ToggleSkySquidSafePlatform(enabled)
    end)
    
    local voidKillToggle = CreateToggle("Void Kill - Sky Squid", MainModule.SkySquid.VoidKill, function(enabled)
        MainModule.ToggleSkySquidVoidKill(enabled)
    end)
end

-- ===================================================================
-- SQUID GAME CONTENT
-- ===================================================================
local function CreateSquidGameContent()
    ClearContent()
    
    CreateTitle("SQUID GAME")
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -10, 0, 100)
    infoLabel.Position = UDim2.new(0, 5, 0, 50)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Squid Game functions coming soon!\nCheck other tabs for specific minigames."
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    infoLabel.TextSize = 14
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.Parent = ContentScrolling
end

-- ===================================================================
-- SETTINGS CONTENT
-- ===================================================================
local function CreateSettingsContent()
    ClearContent()
    
    CreateTitle("SETTINGS")
    
    local creatorLabel = CreateButton("Creator: Creon")
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local versionLabel = CreateButton("Version: 2.1")
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local executorLabel = CreateButton("Executor: " .. executorName)
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local positionLabel = CreateButton("Position: " .. MainModule.GetPlayerPosition())
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.MouseButton1Click:Connect(function()
        MainModule.Cleanup()
        ScreenGui:Destroy()
    end)
    
    -- Обновление позиции
    game:GetService("RunService").Heartbeat:Connect(function()
        positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
    end)
end

-- ===================================================================
-- СОЗДАНИЕ ВКЛАДОК
-- ===================================================================
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Squid Game", "Settings"}
local tabButtons = {}
local tabContainers = {}

for i, name in pairs(tabs) do
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.9, 0, 0, 36)
    buttonContainer.Position = UDim2.new(0.05, 0, 0, (i-1)*38 + 10)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = TabButtons
    
    local button = CreateButton(name)
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.Parent = buttonContainer
    button.TextSize = 12
    
    -- Сохраняем кнопку для выделения активной вкладки
    tabButtons[name] = button
    tabContainers[name] = buttonContainer
    
    -- Функция для активации вкладки
    local function ActivateTab()
        -- Выделяем активную вкладку
        for tabName, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- Создаем контент для вкладки
        if name == "Main" then
            CreateMainContent()
        elseif name == "Combat" then
            CreateCombatContent()
        elseif name == "Misc" then
            CreateMiscContent()
        elseif name == "Rebel" then
            CreateRebelContent()
        elseif name == "RLGL" then
            CreateRLGLContent()
        elseif name == "Guards" then
            CreateGuardsContent()
        elseif name == "Dalgona" then
            CreateDalgonaContent()
        elseif name == "HNS" then
            CreateHNSContent()
        elseif name == "Glass Bridge" then
            CreateGlassBridgeContent()
        elseif name == "Tug of War" then
            CreateTugOfWarContent()
        elseif name == "Jump Rope" then
            CreateJumpRopeContent()
        elseif name == "Sky Squid" then
            CreateSkySquidContent()
        elseif name == "Squid Game" then
            CreateSquidGameContent()
        elseif name == "Settings" then
            CreateSettingsContent()
        end
    end
    
    button.MouseButton1Click:Connect(ActivateTab)
end

-- ===================================================================
-- УПРАВЛЕНИЕ КЛАВИШАМИ (ИСПРАВЛЕННОЕ)
-- ===================================================================
local menuToggleCooldown = false
local menuToggleCooldownTime = 0.3 -- 0.3 секунды кд

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- Используем P для открытия/закрытия меню
    if input.KeyCode == Enum.KeyCode.P then
        if menuToggleCooldown then return end
        
        menuToggleCooldown = true
        MainFrame.Visible = not MainFrame.Visible
        
        if MainFrame.Visible then
            MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
        end
        
        -- Сбрасываем кд через время
        task.wait(menuToggleCooldownTime)
        menuToggleCooldown = false
    end
    
    -- ESC для закрытия меню
    if input.KeyCode == Enum.KeyCode.Escape and MainFrame.Visible then
        MainFrame.Visible = false
    end
end)

-- ===================================================================
-- ИНИЦИАЛИЗАЦИЯ
-- ===================================================================
-- Автоматически открываем Main вкладку и выделяем её
if tabButtons["Main"] then
    tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    tabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
end
CreateMainContent()

-- Очистка при удалении GUI
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        MainModule.Cleanup()
    end
end)

print("Creon X v2.1 загружен")
