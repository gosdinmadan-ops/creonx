-- Creon X v2.1 (исправленная версия для ПК и Delta Mobile)
local Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Main.lua"))()

-- Загрузка всех модулей
local Misc = Main.LoadModule("Misc")
local RLGL = Main.LoadModule("RLGL")
local SkySquid = Main.LoadModule("SkySquid")
local JumpRope = Main.LoadModule("JumpRope")
local Dalgona = Main.LoadModule("Dalgona")
local TugOfWar = Main.LoadModule("TugOfWar")
local Guards = Main.LoadModule("Guards")

-- Проверка исполнителя
local executorName = "Unknown"
if identifyexecutor then
    executorName = identifyexecutor()
elseif getexecutorname then
    executorName = getexecutorname()
end

-- Поддерживаемые исполнители
local supportedExecutors = {"xeno", "bunnu", "volcano", "potassium", "seliware", "zenith", "bunni", "delta", "hydrogen", "electron"}
local isSupported = false

for _, name in pairs(supportedExecutors) do
    if executorName:lower():find(name:lower()) then
        isSupported = true
        break
    end
end

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GUI Creon X v2.1
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local ContentScrolling = Instance.new("ScrollingFrame")
local ContentLayout = Instance.new("UIListLayout")

-- Кнопка для мобильных устройств (Delta Mobile)
local MobileOpenButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXv21"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Размеры GUI
local GUI_WIDTH = 860
local GUI_HEIGHT = 595

-- Для мобильных устройств уменьшаем размер
if UIS.TouchEnabled then
    GUI_WIDTH = 700
    GUI_HEIGHT = 500
end

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

TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Creon X v2.1"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка сворачивания
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = MinimizeButton

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    if UIS.TouchEnabled then
        MobileOpenButton.Visible = true
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

-- Кнопка для мобильных устройств (Delta Mobile)
if UIS.TouchEnabled then
    MobileOpenButton.Size = UDim2.new(0, 120, 0, 40)
    MobileOpenButton.Position = UDim2.new(0.5, -60, 0.2, 0)
    MobileOpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    MobileOpenButton.BorderSizePixel = 0
    MobileOpenButton.Text = "OPEN"
    MobileOpenButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    MobileOpenButton.TextSize = 14
    MobileOpenButton.Font = Enum.Font.GothamBold
    MobileOpenButton.Parent = ScreenGui
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 8)
    mobileCorner.Parent = MobileOpenButton
    
    local mobileStroke = Instance.new("UIStroke")
    mobileStroke.Color = Color3.fromRGB(60, 60, 80)
    mobileStroke.Thickness = 2
    mobileStroke.Parent = MobileOpenButton
    
    MobileOpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
        MobileOpenButton.Visible = false
    end)
    
    MainFrame.Visible = false
else
    MainFrame.Visible = true
end

-- Функция для перемещения GUI
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
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
    
    -- Анимация при наведении
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(65, 65, 85),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 65),
            TextColor3 = Color3.fromRGB(240, 240, 255)
        }):Play()
    end)
    
    return button
end

-- Функция для создания переключателей
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
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 120, 140)
    stroke.Thickness = 1
    stroke.Parent = toggleBackground
    
    -- Кнопка для переключения
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggleContainer
    
    local function updateToggle(newState)
        enabled = newState
        TweenService:Create(toggleBackground, TweenInfo.new(0.2), {
            BackgroundColor3 = newState and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
            Position = newState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }):Play()
        
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
    speedLabel.Text = "Speed: " .. Misc.SpeedHack.CurrentSpeed
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
    sliderFill.Size = UDim2.new((Misc.SpeedHack.CurrentSpeed - Misc.SpeedHack.MinSpeed) / (Misc.SpeedHack.MaxSpeed - Misc.SpeedHack.MinSpeed), 0, 1, 0)
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
        local newSpeed = Misc.SetSpeed(value)
        speedLabel.Text = "Speed: " .. newSpeed
        sliderFill.Size = UDim2.new((newSpeed - Misc.SpeedHack.MinSpeed) / (Misc.SpeedHack.MaxSpeed - Misc.SpeedHack.MinSpeed), 0, 1, 0)
        sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, 0)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            local newSpeed = math.floor(Misc.SpeedHack.MinSpeed + relativeX * (Misc.SpeedHack.MaxSpeed - Misc.SpeedHack.MinSpeed))
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

-- Функция для создания выпадающего списка для Guards
local function CreateDropdown(options, default, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(1, -10, 0, 32)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = ContentScrolling
    
    local dropdownButton = CreateButton(default .. " ▼")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Position = UDim2.new(0, 0, 0, 0)
    dropdownButton.Text = default .. " ▼"
    dropdownButton.Parent = dropdownContainer
    dropdownButton.ZIndex = 10
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, #options * 32)
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 20
    dropdownList.Parent = dropdownContainer
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownList
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(80, 80, 100)
    listStroke.Thickness = 1
    listStroke.Parent = dropdownList
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -8, 0, 28)
        optionButton.Position = UDim2.new(0, 4, 0, (i-1)*32 + 2)
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(240, 240, 255)
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.AutoButtonColor = false
        optionButton.ZIndex = 30
        optionButton.Parent = dropdownList
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 6)
        optionCorner.Parent = optionButton
        
        local optionStroke = Instance.new("UIStroke")
        optionStroke.Color = Color3.fromRGB(80, 80, 100)
        optionStroke.Thickness = 1.2
        optionStroke.Parent = optionButton
        
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

-- Функции для создания контента вкладок
local function ClearContent()
    for _, child in pairs(ContentScrolling:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

-- MAIN TAB
local function CreateMainContent()
    ClearContent()
    
    -- Speed Slider
    local speedLabel = CreateSpeedSlider()
    
    -- Speed Toggle
    local speedToggle, updateSpeedToggle = CreateToggle("SpeedHack", Misc.SpeedHack.Enabled, function(enabled)
        Misc.ToggleSpeedHack(enabled)
    end)
    
    -- Anti Stun QTE
    local antiStunToggle, updateAntiStunToggle = CreateToggle("Anti Stun QTE", false, function(enabled)
        Misc.ToggleAntiStunQTE(enabled)
    end)
    
    -- Anti Ragdoll
    local antiRagdollToggle, updateAntiRagdollToggle = CreateToggle("Anti Ragdoll", Misc.AntiRagdoll.Enabled, function(enabled)
        if enabled then
            Misc.AntiRagdoll.Enable()
        else
            Misc.AntiRagdoll.Disable()
        end
    end)
    
    -- Instance Interact
    local instaInteractToggle, updateInstaInteractToggle = CreateToggle("Instance Interact", Misc.Misc.InstaInteract, function(enabled)
        Misc.ToggleInstaInteract(enabled)
    end)
    
    -- No Cooldown Proximity
    local noCooldownToggle, updateNoCooldownToggle = CreateToggle("No Cooldown Proximity", Misc.Misc.NoCooldownProximity, function(enabled)
        Misc.ToggleNoCooldownProximity(enabled)
    end)
    
    -- Remove Injured
    local removeInjuredToggle, updateRemoveInjuredToggle = CreateToggle("Remove Injured", Misc.EffectsRemover.RemoveInjuredEnabled, function(enabled)
        Misc.EffectsRemover.ToggleRemoveInjured(enabled)
    end)
    
    -- Remove Stun
    local removeStunToggle, updateRemoveStunToggle = CreateToggle("Remove Stun", Misc.EffectsRemover.RemoveStunEnabled, function(enabled)
        Misc.EffectsRemover.ToggleRemoveStun(enabled)
    end)
    
    -- Teleport Buttons
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.MouseButton1Click:Connect(function()
        Misc.TeleportUp100()
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.MouseButton1Click:Connect(function()
        Misc.TeleportDown40()
    end)
end

-- MISC TAB (ESP Settings)
local function CreateMiscContent()
    ClearContent()
    
    -- ESP System Toggle
    local espToggle, updateEspToggle = CreateToggle("ESP System", Misc.Misc.ESPEnabled, function(enabled)
        Misc.ToggleESP(enabled)
    end)
    
    -- ESP Settings
    local espPlayersToggle, updateEspPlayersToggle = CreateToggle("ESP Players", Misc.Misc.ESPPlayers, function(enabled)
        Misc.Misc.ESPPlayers = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    local espHidersToggle, updateEspHidersToggle = CreateToggle("ESP Hiders", Misc.Misc.ESPHiders, function(enabled)
        Misc.Misc.ESPHiders = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    local espSeekersToggle, updateEspSeekersToggle = CreateToggle("ESP Seekers", Misc.Misc.ESPSeekers, function(enabled)
        Misc.Misc.ESPSeekers = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    local espCandiesToggle, updateEspCandiesToggle = CreateToggle("ESP Candies", Misc.Misc.ESPCandies, function(enabled)
        Misc.Misc.ESPCandies = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    local espKeysToggle, updateEspKeysToggle = CreateToggle("ESP Keys", Misc.Misc.ESPKeys, function(enabled)
        Misc.Misc.ESPKeys = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    local espDoorsToggle, updateEspDoorsToggle = CreateToggle("ESP Doors", Misc.Misc.ESPDoors, function(enabled)
        Misc.Misc.ESPDoors = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    local espGuardsToggle, updateEspGuardsToggle = CreateToggle("ESP Guards", Misc.Misc.ESPGuards, function(enabled)
        Misc.Misc.ESPGuards = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    -- Snow ESP Settings
    local snowToggle, updateSnowToggle = CreateToggle("Snow ESP", Misc.Misc.ESPSnow.Enabled, function(enabled)
        Misc.ToggleSnowESP(enabled)
    end)
    
    local snowDistanceToggle, updateSnowDistanceToggle = CreateToggle("Snow Distance", Misc.Misc.ESPSnow.ShowDistance, function(enabled)
        Misc.Misc.ESPSnow.ShowDistance = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    local snowHPToggle, updateSnowHPToggle = CreateToggle("Snow HP", Misc.Misc.ESPSnow.ShowHP, function(enabled)
        Misc.Misc.ESPSnow.ShowHP = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    -- Box ESP Settings
    local boxToggle, updateBoxToggle = CreateToggle("Box ESP", Misc.Misc.ESPBox.Enabled, function(enabled)
        Misc.ToggleBoxESP(enabled)
    end)
    
    local boxDistanceToggle, updateBoxDistanceToggle = CreateToggle("Box Distance", Misc.Misc.ESPBox.ShowDistance, function(enabled)
        Misc.Misc.ESPBox.ShowDistance = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
    
    local boxNameToggle, updateBoxNameToggle = CreateToggle("Box Name", Misc.Misc.ESPBox.ShowName, function(enabled)
        Misc.Misc.ESPBox.ShowName = enabled
        if Misc.Misc.ESPEnabled then
            Misc.ToggleESP(false)
            task.wait(0.1)
            Misc.ToggleESP(true)
        end
    end)
end

-- RLGL TAB
local function CreateRLGLContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("TP TO END")
    tpEndBtn.MouseButton1Click:Connect(function()
        RLGL.TeleportToEnd()
    end)
    
    local tpStartBtn = CreateButton("TP TO START")
    tpStartBtn.MouseButton1Click:Connect(function()
        RLGL.TeleportToStart()
    end)
    
    local godModeToggle, updateGodModeToggle = CreateToggle("GodMode", RLGL.RLGL.GodMode, function(enabled)
        RLGL.ToggleGodMode(enabled)
    end)
end

-- SKY SQUID TAB
local function CreateSkySquidContent()
    ClearContent()
    
    local antiFallToggle, updateAntiFallToggle = CreateToggle("Anti Fall", SkySquid.SkySquid.AntiFall, function(enabled)
        SkySquid.ToggleSkySquidAntiFall(enabled)
    end)
    
    local voidKillToggle, updateVoidKillToggle = CreateToggle("Void Kill", SkySquid.SkySquid.VoidKill, function(enabled)
        SkySquid.ToggleSkySquidVoidKill(enabled)
    end)
end

-- JUMP ROPE TAB
local function CreateJumpRopeContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.MouseButton1Click:Connect(function()
        JumpRope.TeleportToJumpRopeEnd()
    end)
    
    local deleteRopeBtn = CreateButton("Delete The Rope")
    deleteRopeBtn.MouseButton1Click:Connect(function()
        JumpRope.DeleteJumpRope()
    end)
    
    local antiFallBtn = CreateButton("Anti Fall")
    antiFallBtn.MouseButton1Click:Connect(function()
        JumpRope.ToggleJumpRopeAntiFall(true)
        antiFallBtn.Text = "Anti Fall (ON)"
    end)
end

-- DALGONA TAB
local function CreateDalgonaContent()
    ClearContent()
    
    local completeBtn = CreateButton("Complete Dalgona")
    completeBtn.MouseButton1Click:Connect(function()
        Dalgona.CompleteDalgona()
    end)
    
    local lighterBtn = CreateButton("Free Lighter")
    lighterBtn.MouseButton1Click:Connect(function()
        Dalgona.FreeLighter()
    end)
end

-- TUG OF WAR TAB
local function CreateTugOfWarContent()
    ClearContent()
    
    local autoPullToggle, updateAutoPullToggle = CreateToggle("Auto Pull", TugOfWar.TugOfWar.AutoPull, function(enabled)
        TugOfWar.ToggleAutoPull(enabled)
    end)
end

-- GUARDS TAB
local function CreateGuardsContent()
    ClearContent()
    
    -- Dropdown для выбора Guard
    local dropdown = CreateDropdown({"Circle", "Triangle", "Square"}, Guards.Guards.SelectedGuard, function(selected)
        Guards.SetGuardType(selected)
    end)
    
    local spawnBtn = CreateButton("Spawn as Guard")
    spawnBtn.MouseButton1Click:Connect(function()
        Guards.SpawnAsGuard()
    end)
    
    local rapidFireToggle, updateRapidFireToggle = CreateToggle("Rapid Fire", Guards.Guards.RapidFire, function(enabled)
        Guards.ToggleRapidFire(enabled)
    end)
    
    local infiniteAmmoToggle, updateInfiniteAmmoToggle = CreateToggle("Infinite Ammo", Guards.Guards.InfiniteAmmo, function(enabled)
        Guards.ToggleInfiniteAmmo(enabled)
    end)
    
    local hitboxToggle, updateHitboxToggle = CreateToggle("Hitbox Expander", Guards.Guards.HitboxExpander, function(enabled)
        Guards.ToggleHitboxExpander(enabled)
    end)
    
    local autoFarmToggle, updateAutoFarmToggle = CreateToggle("AutoFarm", Guards.Guards.AutoFarm, function(enabled)
        Guards.ToggleAutoFarm(enabled)
    end)
end

-- SETTINGS TAB
local function CreateSettingsContent()
    ClearContent()
    
    local creatorLabel = CreateButton("Creator: Creon")
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local versionLabel = CreateButton("Version: 2.1")
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local executorLabel = CreateButton("Executor: " .. executorName)
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local supportedLabel = CreateButton("Supported: " .. (isSupported and "YES" or "NO"))
    supportedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local positionLabel = CreateButton("Position: " .. Misc.GetPlayerPosition())
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.MouseButton1Click:Connect(function()
        Main.Cleanup()
        Misc.Cleanup()
        RLGL.Cleanup()
        SkySquid.Cleanup()
        JumpRope.Cleanup()
        Dalgona.Cleanup()
        TugOfWar.Cleanup()
        Guards.Cleanup()
        ScreenGui:Destroy()
    end)
    
    -- Обновление позиции
    game:GetService("RunService").Heartbeat:Connect(function()
        positionLabel.Text = "Position: " .. Misc.GetPlayerPosition()
    end)
end

-- Создание вкладок
local tabs = {"Main", "Misc", "RLGL", "Sky Squid", "Jump Rope", "Dalgona", "Tug of War", "Guards", "Settings"}
local tabButtons = {}

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
    
    tabButtons[name] = button
    
    local function ActivateTab()
        for tabName, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        if name == "Main" then
            CreateMainContent()
        elseif name == "Misc" then
            CreateMiscContent()
        elseif name == "RLGL" then
            CreateRLGLContent()
        elseif name == "Sky Squid" then
            CreateSkySquidContent()
        elseif name == "Jump Rope" then
            CreateJumpRopeContent()
        elseif name == "Dalgona" then
            CreateDalgonaContent()
        elseif name == "Tug of War" then
            CreateTugOfWarContent()
        elseif name == "Guards" then
            CreateGuardsContent()
        elseif name == "Settings" then
            CreateSettingsContent()
        end
    end
    
    button.MouseButton1Click:Connect(ActivateTab)
end

-- Управление для ПК
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
            if UIS.TouchEnabled then
                MobileOpenButton.Visible = false
            end
        else
            if UIS.TouchEnabled then
                MobileOpenButton.Visible = true
            end
        end
    end
end)

-- Закрытие при нажатии ESC
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape and MainFrame.Visible then
        MainFrame.Visible = false
        if UIS.TouchEnabled then
            MobileOpenButton.Visible = true
        end
    end
end)

-- Автоматически открываем Main вкладку
if tabButtons["Main"] then
    tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    tabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
end
CreateMainContent()

-- Очистка при удалении GUI
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        Main.Cleanup()
        Misc.Cleanup()
        RLGL.Cleanup()
        SkySquid.Cleanup()
        JumpRope.Cleanup()
        Dalgona.Cleanup()
        TugOfWar.Cleanup()
        Guards.Cleanup()
    end
end)

-- Отображение сообщения о загрузке
print("Creon X v2.1 loaded successfully")
print("Modules loaded: Main, Misc, RLGL, SkySquid, JumpRope, Dalgona, TugOfWar, Guards")
if not isSupported then
    warn("Warning: Executor " .. executorName .. " is not officially supported")
else
    print("Executor " .. executorName .. " is supported")
end
