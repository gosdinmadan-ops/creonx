-- Creon X v2.5 (исправленная версия для ПК и Delta Mobile)
-- Проверка исполнителя
local executorName = "Unknown"
if identifyexecutor then
    executorName = identifyexecutor()
elseif getexecutorname then
    executorName = getexecutorname()
end

-- Поддерживаемые исполнители (включая Delta)
local supportedExecutors = {"bunnu", "volcano", "potassium", "seliware", "zenith", "bunni", "delta", "hydrogen", "electron"}
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
local player = Players.LocalPlayer

-- Загрузка Main модуля
local MainModule
local success, err = pcall(function()
    local url = "https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Main.lua"
    local content = game:HttpGet(url, true)
    MainModule = loadstring(content)()
end)

if not success then
    warn("Failed to load Main.lua: " .. tostring(err))
    return
end

-- Важно: Отключаем Bypass Ragdoll при запуске
task.spawn(function()
    task.wait(0.5) -- Даем время для инициализации
    if MainModule and MainModule.ToggleBypassRagdoll then
        -- Явно отключаем Bypass Ragdoll при старте
        MainModule.ToggleBypassRagdoll(false)
        print("Bypass Ragdoll отключен при запуске")
    end
end)

-- Переменные для отслеживания статуса AntiFall
local GlassBridgeAntiFallEnabled = false
local JumpRopeAntiFallEnabled = false
local SkySquidAntiFallEnabled = false

-- Переменная для Zone Kill
local ZoneKillEnabled = false

-- Переменные для горячей клавиши меню
local menuHotkey = Enum.KeyCode.M
local isChoosingMenuKey = false
local keyChangeButton = nil

-- Переменные для биндов
local FlyHotkey = nil
local NoclipHotkey = nil
local KillauraHotkey = nil
local isChoosingFlyKey = false
local isChoosingNoclipKey = false
local isChoosingKillauraKey = false

-- Флаг для предотвращения автоматического включения Bypass
local initializing = true

-- GUI Creon X v2.5
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
ScreenGui.Name = "CreonXv25"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

-- Размеры GUI
local GUI_WIDTH = 860
local GUI_HEIGHT = 595
local MOBILE_SCALE = 0.6 -- Уменьшение на 40% для мобильных

-- Для мобильных устройств уменьшаем размер
if UIS.TouchEnabled then
    GUI_WIDTH = 860 * MOBILE_SCALE
    GUI_HEIGHT = 595 * MOBILE_SCALE
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
TitleLabel.Text = "Creon X v2.5"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка сворачивания (только для мобильных)
if UIS.TouchEnabled then
    MinimizeButton.Size = UDim2.new(0, 35, 0, 35) -- Увеличена для мобильных
    MinimizeButton.Position = UDim2.new(1, -40, 0.5, -17.5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "X"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 18
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = TitleBar

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MobileOpenButton.Visible = true
    end)
else
    -- Для ПК кнопки сворачивания нет
end

-- УВЕЛИЧИВАЕМ ШИРИНУ ЛЕВОЙ ПАНЕЛИ С ВКЛАДКАМИ
local TAB_PANEL_WIDTH = 180 -- Было 150, увеличили на 30 пикселей

-- Фрейм для кнопок вкладок с прокруткой
TabButtons.Size = UDim2.new(0, TAB_PANEL_WIDTH, 1, -35)
TabButtons.Position = UDim2.new(0, 0, 0, 35)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 8)
tabCorner.Parent = TabButtons

-- ScrollingFrame для кнопок вкладок (для мобильных)
local TabScrolling = Instance.new("ScrollingFrame")
TabScrolling.Size = UDim2.new(1, 0, 1, 0)
TabScrolling.BackgroundTransparency = 1
TabScrolling.BorderSizePixel = 0
TabScrolling.ScrollBarThickness = 4
TabScrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
TabScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScrolling.Parent = TabButtons

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5) -- Отступ между вкладками
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabScrolling.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
end)
TabLayout.Parent = TabScrolling

-- Content Frame с прокруткой (УМЕНЬШАЕМ ШИРИНУ ИЗ-ЗА УВЕЛИЧЕНИЯ ЛЕВОЙ ПАНЕЛИ)
ContentFrame.Size = UDim2.new(1, -TAB_PANEL_WIDTH, 1, -35)
ContentFrame.Position = UDim2.new(0, TAB_PANEL_WIDTH, 0, 35)
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
    
    MobileOpenButton.MouseEnter:Connect(function()
        TweenService:Create(MobileOpenButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 60),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    MobileOpenButton.MouseLeave:Connect(function()
        TweenService:Create(MobileOpenButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 45),
            TextColor3 = Color3.fromRGB(220, 220, 255)
        }):Play()
    end)
    
    MobileOpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
        MobileOpenButton.Visible = false
    end)
    
    -- Перетаскивание кнопки OPEN
    local mobileDragging = false
    local mobileDragStart, mobileStartPos
    
    MobileOpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = true
            mobileDragStart = input.Position
            mobileStartPos = MobileOpenButton.Position
            MobileOpenButton.ZIndex = 10
        end
    end)
    
    MobileOpenButton.InputChanged:Connect(function(input)
        if mobileDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - mobileDragStart
            MobileOpenButton.Position = UDim2.new(
                mobileStartPos.X.Scale, 
                mobileStartPos.X.Offset + delta.X,
                mobileStartPos.Y.Scale, 
                mobileStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    MobileOpenButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = false
            MobileOpenButton.ZIndex = 1
        end
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
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(65, 65, 85)
        }):Play()
    end)
    
    return button
end

-- Улучшенная функция для создания переключателей с защитой от ошибок
local toggleElements = {}
local function CreateToggle(text, getEnabledFunction, callback, layoutOrder, bypassInitialization)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -10, 0, 32)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentScrolling
    toggleContainer.LayoutOrder = layoutOrder or 999
    
    -- Сохраняем ссылку для обновлений
    table.insert(toggleElements, {
        container = toggleContainer,
        getEnabled = getEnabledFunction,
        callback = callback,
        text = text,
        bypassInitialization = bypassInitialization or false
    })
    
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
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleContainer
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 18, 0, 18)
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
    
    local function updateToggleVisual()
        if not toggleContainer or not toggleContainer.Parent then
            return
        end
        
        local success, isEnabled = pcall(getEnabledFunction)
        if not success then
            isEnabled = false
        end
        
        TweenService:Create(toggleBackground, TweenInfo.new(0.2), {
            BackgroundColor3 = isEnabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
            Position = isEnabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        }):Play()
    end
    
    local function toggleFunction()
        -- Если идет инициализация и это Bypass Ragdoll - пропускаем
        if initializing and text:find("Anti Stun %+ Anti Ragdoll") then
            print("Пропускаем автоматическое включение Bypass Ragdoll во время инициализации")
            return
        end
        
        local success, currentState = pcall(getEnabledFunction)
        if not success then
            currentState = false
        end
        
        local newState = not currentState
        if callback then
            callback(newState)
        end
        updateToggleVisual()
    end
    
    toggleButton.MouseButton1Click:Connect(toggleFunction)
    
    -- Инициализация состояния
    updateToggleVisual()
    
    return toggleContainer, toggleFunction, textLabel
end

-- Функция для обновления всех переключателей
local function UpdateAllToggles()
    for _, toggleData in pairs(toggleElements) do
        if toggleData.container and toggleData.container.Parent then
            local success, isEnabled = pcall(toggleData.getEnabled)
            if success then
                local toggleBackground = toggleData.container:FindFirstChildWhichIsA("Frame")
                if toggleBackground then
                    TweenService:Create(toggleBackground, TweenInfo.new(0.2), {
                        BackgroundColor3 = isEnabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
                    }):Play()
                    
                    local toggleCircle = toggleBackground:FindFirstChildWhichIsA("Frame")
                    if toggleCircle then
                        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                            Position = isEnabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                        }):Play()
                    end
                end
            end
        end
    end
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
    speedLabel.Text = "Speed: " .. (MainModule.SpeedHack and MainModule.SpeedHack.CurrentSpeed or 16)
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
    sliderFill.Size = UDim2.new((MainModule.SpeedHack and MainModule.SpeedHack.CurrentSpeed or 16) / (MainModule.SpeedHack and MainModule.SpeedHack.MaxSpeed or 30), 0, 1, 0)
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
        if MainModule and MainModule.SetSpeed then
            local newSpeed = MainModule.SetSpeed(value)
            speedLabel.Text = "Speed: " .. newSpeed
            sliderFill.Size = UDim2.new((newSpeed - (MainModule.SpeedHack and MainModule.SpeedHack.MinSpeed or 16)) / ((MainModule.SpeedHack and MainModule.SpeedHack.MaxSpeed or 30) - (MainModule.SpeedHack and MainModule.SpeedHack.MinSpeed or 16)), 0, 1, 0)
            sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, 0)
        end
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            local newSpeed = math.floor((MainModule.SpeedHack and MainModule.SpeedHack.MinSpeed or 16) + relativeX * ((MainModule.SpeedHack and MainModule.SpeedHack.MaxSpeed or 30) - (MainModule.SpeedHack and MainModule.SpeedHack.MinSpeed or 16)))
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

-- Функция для создания слайдера Killaura радиуса
local function CreateKillauraRadiusSlider()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -10, 0, 60)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ContentScrolling
    
    local radiusLabel = Instance.new("TextLabel")
    radiusLabel.Size = UDim2.new(1, 0, 0, 20)
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.Text = "Killaura Radius: " .. (MainModule.Killaura and MainModule.Killaura.Radius or 30)
    radiusLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    radiusLabel.TextSize = 12
    radiusLabel.Font = Enum.Font.GothamBold
    radiusLabel.Parent = sliderContainer
    
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
    sliderFill.Size = UDim2.new(((MainModule.Killaura and MainModule.Killaura.Radius or 30) - 15) / ((MainModule.Killaura and MainModule.Killaura.MaxRadius or 50) - 15), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
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
    
    local function updateRadius(value)
        if MainModule and MainModule.SetKillauraRadius then
            local newRadius = MainModule.SetKillauraRadius(value)
            radiusLabel.Text = "Killaura Radius: " .. newRadius
            sliderFill.Size = UDim2.new((newRadius - 15) / ((MainModule.Killaura and MainModule.Killaura.MaxRadius or 50) - 15), 0, 1, 0)
            sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, 0)
        end
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            local newRadius = math.floor(15 + relativeX * ((MainModule.Killaura and MainModule.Killaura.MaxRadius or 50) - 15))
            updateRadius(newRadius)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return radiusLabel
end

-- Улучшенная функция для создания кнопки бинда
local function CreateBindButton(labelText, currentKey, onBindChanged, layoutOrder)
    local bindContainer = Instance.new("Frame")
    bindContainer.Size = UDim2.new(1, -10, 0, 32)
    bindContainer.BackgroundTransparency = 1
    bindContainer.Parent = ContentScrolling
    bindContainer.LayoutOrder = layoutOrder or 999
    
    local bindFrame = Instance.new("Frame")
    bindFrame.Size = UDim2.new(1, 0, 1, 0)
    bindFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    bindFrame.BorderSizePixel = 0
    bindFrame.Parent = bindContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = bindFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = bindFrame
    
    -- Текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = bindFrame
    
    -- Кнопка бинда с динамическим обновлением
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0.35, 0, 0.7, 0)
    bindBtn.Position = UDim2.new(0.62, 0, 0.15, 0)
    bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    bindBtn.BorderSizePixel = 0
    bindBtn.Text = currentKey and currentKey.Name or "None"
    bindBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    bindBtn.TextSize = 11
    bindBtn.Font = Enum.Font.Gotham
    bindBtn.AutoButtonColor = false
    bindBtn.Parent = bindFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = bindBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(80, 80, 100)
    btnStroke.Thickness = 1
    btnStroke.Parent = bindBtn
    
    -- Функция обновления текста кнопки
    local function updateButtonText()
        bindBtn.Text = currentKey and currentKey.Name or "None"
    end
    
    -- Анимации для кнопки
    bindBtn.MouseEnter:Connect(function()
        TweenService:Create(bindBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(75, 75, 95),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    bindBtn.MouseLeave:Connect(function()
        TweenService:Create(bindBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 75),
            TextColor3 = Color3.fromRGB(240, 240, 255)
        }):Play()
    end)
    
    -- Функция изменения бинда
    local function startKeyChange()
        bindBtn.Text = "Press a key..."
        bindBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        
        local connection
        connection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                updateButtonText()
                bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if onBindChanged then
                    onBindChanged(currentKey)
                end
                
                if connection then
                    connection:Disconnect()
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                updateButtonText()
                bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        -- Если 3 секунды не выбрали клавишу - отменяем
        task.delay(3, function()
            if bindBtn.Text == "Press a key..." then
                updateButtonText()
                bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end
    
    bindBtn.MouseButton1Click:Connect(startKeyChange)
    
    -- Автоматическое обновление текста каждые 0.1 секунды
    local updateConnection
    updateConnection = RunService.Heartbeat:Connect(function()
        if bindContainer and bindContainer.Parent then
            updateButtonText()
        else
            if updateConnection then
                updateConnection:Disconnect()
            end
        end
    end)
    
    return bindContainer, bindBtn
end

-- Функция для создания кнопки изменения горячей клавиши меню
local function CreateKeybindButton()
    local keybindContainer = Instance.new("Frame")
    keybindContainer.Size = UDim2.new(1, -10, 0, 32)
    keybindContainer.BackgroundTransparency = 1
    keybindContainer.Parent = ContentScrolling
    
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, 0, 1, 0)
    keybindFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = keybindContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = keybindFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = keybindFrame
    
    -- Текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Menu Hotkey: M"
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = keybindFrame
    
    -- Кнопка изменения
    local changeBtn = Instance.new("TextButton")
    changeBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
    changeBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
    changeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    changeBtn.BorderSizePixel = 0
    changeBtn.Text = "Change"
    changeBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    changeBtn.TextSize = 11
    changeBtn.Font = Enum.Font.Gotham
    changeBtn.AutoButtonColor = false
    changeBtn.Parent = keybindFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = changeBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(80, 80, 100)
    btnStroke.Thickness = 1
    btnStroke.Parent = changeBtn
    
    -- Анимации для кнопки
    changeBtn.MouseEnter:Connect(function()
        if not isChoosingMenuKey then
            TweenService:Create(changeBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(75, 75, 95),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    changeBtn.MouseLeave:Connect(function()
        if not isChoosingMenuKey then
            TweenService:Create(changeBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 75),
                TextColor3 = Color3.fromRGB(240, 240, 255)
            }):Play()
        end
    end)
    
    -- Функция обновления текста
    local function updateKeyText()
        label.Text = "Menu Hotkey: " .. menuHotkey.Name
    end
    
    -- Функция изменения клавиши
    local function startKeyChange()
        isChoosingMenuKey = true
        changeBtn.Text = "Press any key..."
        changeBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        
        local connection
        connection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                menuHotkey = input.KeyCode
                updateKeyText()
                
                isChoosingMenuKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if connection then
                    connection:Disconnect()
                end
                
                updateHotkeyListener()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                isChoosingMenuKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        task.delay(5, function()
            if isChoosingMenuKey then
                isChoosingMenuKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end
    
    changeBtn.MouseButton1Click:Connect(function()
        if not isChoosingMenuKey then
            startKeyChange()
        end
    end)
    
    updateKeyText()
    keyChangeButton = changeBtn
    
    return keybindContainer
end

-- Простая кнопка выбора Guard типа
local function CreateGuardTypeSelector()
    local selectorContainer = Instance.new("Frame")
    selectorContainer.Size = UDim2.new(1, -10, 0, 32)
    selectorContainer.BackgroundTransparency = 1
    selectorContainer.LayoutOrder = 1
    selectorContainer.Parent = ContentScrolling
    
    local selectorFrame = Instance.new("Frame")
    selectorFrame.Size = UDim2.new(1, 0, 1, 0)
    selectorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    selectorFrame.BorderSizePixel = 0
    selectorFrame.Parent = selectorContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = selectorFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = selectorFrame
    
    -- Текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Guard Type: " .. (MainModule.Guards and MainModule.Guards.SelectedGuard or "Circle")
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = selectorFrame
    
    -- Кнопка смены типа
    local changeBtn = Instance.new("TextButton")
    changeBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
    changeBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
    changeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    changeBtn.BorderSizePixel = 0
    changeBtn.Text = "Change"
    changeBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    changeBtn.TextSize = 11
    changeBtn.Font = Enum.Font.Gotham
    changeBtn.AutoButtonColor = false
    changeBtn.Parent = selectorFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = changeBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(80, 80, 100)
    btnStroke.Thickness = 1
    btnStroke.Parent = changeBtn
    
    -- Анимации для кнопки
    changeBtn.MouseEnter:Connect(function()
        TweenService:Create(changeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(75, 75, 95),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    changeBtn.MouseLeave:Connect(function()
        TweenService:Create(changeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 75),
            TextColor3 = Color3.fromRGB(240, 240, 255)
        }):Play()
    end)
    
    -- Циклическое переключение типов
    local guardTypes = {"Circle", "Triangle", "Square"}
    local currentIndex = 1
    
    changeBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #guardTypes then
            currentIndex = 1
        end
        
        local newGuardType = guardTypes[currentIndex]
        if MainModule and MainModule.SetGuardType then
            MainModule.SetGuardType(newGuardType)
        elseif MainModule and MainModule.Guards then
            MainModule.Guards.SelectedGuard = newGuardType
        end
        label.Text = "Guard Type: " .. newGuardType
    end)
    
    return selectorContainer
end

-- Функции для создания контента вкладок
local function ClearContent()
    toggleElements = {} -- Очищаем массив переключателей
    for _, child in pairs(ContentScrolling:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

-- Ссылки на элементы GUI для обновлений
local speedToggleElement, flyToggleElement, noclipToggleElement, killauraToggleElement

-- MAIN TAB
local function CreateMainContent()
    ClearContent()
    
    -- Speed Slider
    local speedLabel = CreateSpeedSlider()
    
    -- Speed Toggle (первое)
    speedToggleElement = CreateToggle("SpeedHack", function() 
        return MainModule and MainModule.SpeedHack and MainModule.SpeedHack.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleSpeedHack then
            MainModule.ToggleSpeedHack(enabled)
        elseif MainModule and MainModule.SpeedHack then
            MainModule.SpeedHack.Enabled = enabled
        end
    end, 1)
    
    -- Fly Toggle (второе)
    flyToggleElement = CreateToggle("Fly", function() 
        return MainModule and MainModule.Fly and MainModule.Fly.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleFly then
            MainModule.ToggleFly(enabled)
        elseif MainModule and MainModule.Fly then
            MainModule.Fly.Enabled = enabled
        end
    end, 2)
    
    -- Fly Bind
    local flyBindContainer, flyBindBtn = CreateBindButton("Fly Bind", FlyHotkey, function(newKey)
        FlyHotkey = newKey
        setupFlyListener()
    end, 3)
    
    -- Noclip Toggle
    noclipToggleElement = CreateToggle("Noclip", function() 
        return MainModule and MainModule.Noclip and MainModule.Noclip.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleNoclip then
            MainModule.ToggleNoclip(enabled)
        elseif MainModule and MainModule.Noclip then
            MainModule.Noclip.Enabled = enabled
        end
    end, 4)
    
    -- Noclip Bind
    local noclipBindContainer, noclipBindBtn = CreateBindButton("Noclip Bind", NoclipHotkey, function(newKey)
        NoclipHotkey = newKey
        setupNoclipListener()
    end, 5)
    
    -- Free Dash (only player)
    CreateToggle("Free Dash (only player)", function() 
        return MainModule and MainModule.FreeDash and MainModule.FreeDash.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleFreeDash then
            MainModule.ToggleFreeDash(enabled)
        elseif MainModule and MainModule.FreeDash then
            MainModule.FreeDash.Enabled = enabled
        end
    end, 6)
    
    -- Anti Stun QTE
    CreateToggle("Anti Stun QTE", function() 
        return MainModule and MainModule.AutoQTE and MainModule.AutoQTE.AntiStunEnabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleAntiStunQTE then
            MainModule.ToggleAntiStunQTE(enabled)
        elseif MainModule and MainModule.AutoQTE then
            MainModule.AutoQTE.AntiStunEnabled = enabled
        end
    end, 7)
    
    -- Anti Stun + Anti Ragdoll - ВАЖНО: предотвращаем автоматическое включение
    CreateToggle("Anti Stun + Anti Ragdoll", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.BypassRagdollEnabled or false
    end, function(enabled)
        -- Явно отключаем при вызове во время инициализации
        if initializing then
            enabled = false
            print("Bypass Ragdoll принудительно отключен при инициализации")
        end
        
        if MainModule and MainModule.ToggleBypassRagdoll then
            MainModule.ToggleBypassRagdoll(enabled)
        elseif MainModule and MainModule.Misc then
            MainModule.Misc.BypassRagdollEnabled = enabled
        end
    end, 8, true) -- Последний параметр: bypassInitialization = true
    
    -- Instance Interact
    CreateToggle("Instance Interact", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.InstaInteract or false
    end, function(enabled)
        if MainModule and MainModule.ToggleInstaInteract then
            MainModule.ToggleInstaInteract(enabled)
        elseif MainModule and MainModule.Misc then
            MainModule.Misc.InstaInteract = enabled
        end
    end, 9)
    
    -- No Cooldown Proximity
    CreateToggle("No Cooldown Proximity", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.NoCooldownProximity or false
    end, function(enabled)
        if MainModule and MainModule.ToggleNoCooldownProximity then
            MainModule.ToggleNoCooldownProximity(enabled)
        elseif MainModule and MainModule.Misc then
            MainModule.Misc.NoCooldownProximity = enabled
        end
    end, 10)
    
    -- Teleport Buttons
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.LayoutOrder = 11
    tpUpBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportUp100 then
            MainModule.TeleportUp100()
        end
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.LayoutOrder = 12
    tpDownBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportDown40 then
            MainModule.TeleportDown40()
        end
    end)
    
    -- Position display
    local positionLabel = CreateButton("Position: " .. (MainModule and MainModule.GetPlayerPosition and MainModule.GetPlayerPosition() or "0,0,0"))
    positionLabel.LayoutOrder = 13
    positionLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    positionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    
    -- Update position
    game:GetService("RunService").Heartbeat:Connect(function()
        if positionLabel and positionLabel.Parent then
            if MainModule and MainModule.GetPlayerPosition then
                positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
            end
        end
    end)
end

-- COMBAT TAB
local function CreateCombatContent()
    ClearContent()
    
    -- Killaura Title
    local killauraTitle = CreateButton("KILLAURA")
    killauraTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    killauraTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    killauraTitle.TextSize = 14
    killauraTitle.LayoutOrder = 1
    
    -- Killaura Radius Slider
    local radiusLabel = CreateKillauraRadiusSlider()
    
    -- Killaura Toggle с улучшенным сообщением
    killauraToggleElement = CreateToggle("Killaura", function() 
        return MainModule and MainModule.Killaura and MainModule.Killaura.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleKillaura then
            MainModule.ToggleKillaura(enabled)
            if enabled then
                print("Killaura Enabled")
            else
                print("Killaura Disabled")
            end
        elseif MainModule and MainModule.Killaura then
            MainModule.Killaura.Enabled = enabled
            if enabled then
                print("Killaura Enabled")
            else
                print("Killaura Disabled")
            end
        end
    end, 2)
    
    -- Killaura Bind
    local killauraBindContainer, killauraBindBtn = CreateBindButton("Killaura Bind", KillauraHotkey, function(newKey)
        KillauraHotkey = newKey
        setupKillauraListener()
    end, 3)
end

-- MISC TAB
local function CreateMiscContent()
    ClearContent()
    
    -- ESP System Toggle
    CreateToggle("ESP System", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.ESPEnabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleESP then
            MainModule.ToggleESP(enabled)
        elseif MainModule and MainModule.Misc then
            MainModule.Misc.ESPEnabled = enabled
        end
    end, 1)
    
    -- ESP Players
    CreateToggle("ESP Players", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.ESPPlayers or false
    end, function(enabled)
        if MainModule and MainModule.Misc then
            MainModule.Misc.ESPPlayers = enabled
            if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
                MainModule.ToggleESP(false)
                task.wait(0.1)
                MainModule.ToggleESP(true)
            end
        end
    end, 2)
    
    -- ESP Hiders
    CreateToggle("ESP Hiders", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.ESPHiders or false
    end, function(enabled)
        if MainModule and MainModule.Misc then
            MainModule.Misc.ESPHiders = enabled
            if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
                MainModule.ToggleESP(false)
                task.wait(0.1)
                MainModule.ToggleESP(true)
            end
        end
    end, 3)
    
    -- ESP Seekers
    CreateToggle("ESP Seekers", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.ESPSeekers or false
    end, function(enabled)
        if MainModule and MainModule.Misc then
            MainModule.Misc.ESPSeekers = enabled
            if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
                MainModule.ToggleESP(false)
                task.wait(0.1)
                MainModule.ToggleESP(true)
            end
        end
    end, 4)
    
    -- ESP Highlight
    CreateToggle("ESP Highlight", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.ESPHighlight or false
    end, function(enabled)
        if MainModule and MainModule.Misc then
            MainModule.Misc.ESPHighlight = enabled
            if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
                MainModule.ToggleESP(false)
                task.wait(0.1)
                MainModule.ToggleESP(true)
            end
        end
    end, 5)
    
    -- ESP Distance
    CreateToggle("ESP Distance", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.ESPDistance or false
    end, function(enabled)
        if MainModule and MainModule.Misc then
            MainModule.Misc.ESPDistance = enabled
            if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
                MainModule.ToggleESP(false)
                task.wait(0.1)
                MainModule.ToggleESP(true)
            end
        end
    end, 6)
end

-- REBEL TAB
local function CreateRebelContent()
    ClearContent()
    
    local rebelTitle = CreateButton("REBEL")
    rebelTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    rebelTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    rebelTitle.TextSize = 14
    rebelTitle.LayoutOrder = 1
    
    CreateToggle("Instant Rebel", function() 
        return MainModule and MainModule.Rebel and MainModule.Rebel.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleRebel then
            MainModule.ToggleRebel(enabled)
        elseif MainModule and MainModule.Rebel then
            MainModule.Rebel.Enabled = enabled
        end
    end, 2)
end

-- RLGL TAB
local function CreateRLGLContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("TP TO END")
    tpEndBtn.LayoutOrder = 1
    tpEndBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportToEnd then
            MainModule.TeleportToEnd()
        end
    end)
    
    local tpStartBtn = CreateButton("TP TO START")
    tpStartBtn.LayoutOrder = 2
    tpStartBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportToStart then
            MainModule.TeleportToStart()
        end
    end)
    
    CreateToggle("GodMode", function() 
        return MainModule and MainModule.RLGL and MainModule.RLGL.GodMode or false
    end, function(enabled)
        if MainModule and MainModule.ToggleGodMode then
            MainModule.ToggleGodMode(enabled)
        elseif MainModule and MainModule.RLGL then
            MainModule.RLGL.GodMode = enabled
        end
    end, 3)
end

-- GUARDS TAB
local function CreateGuardsContent()
    ClearContent()
    
    -- Guard Type Selector
    local guardSelector = CreateGuardTypeSelector()
    
    -- Spawn as Guard кнопка
    local spawnBtn = CreateButton("Spawn as Guard")
    spawnBtn.LayoutOrder = 2
    spawnBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.SpawnAsGuard then
            MainModule.SpawnAsGuard()
        end
    end)
    
    -- Free Dash (only guard)
    CreateToggle("Free Dash (only guard)", function() 
        return MainModule and MainModule.FreeDashGuards and MainModule.FreeDashGuards.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleFreeDashGuards then
            MainModule.ToggleFreeDashGuards(enabled)
        elseif MainModule and MainModule.FreeDashGuards then
            MainModule.FreeDashGuards.Enabled = enabled
        end
    end, 3)
    
    -- Rapid Fire
    CreateToggle("Rapid Fire", function() 
        return MainModule and MainModule.Guards and MainModule.Guards.RapidFire or false
    end, function(enabled)
        if MainModule and MainModule.ToggleRapidFire then
            MainModule.ToggleRapidFire(enabled)
        elseif MainModule and MainModule.Guards then
            MainModule.Guards.RapidFire = enabled
        end
    end, 4)
    
    -- Infinite Ammo
    CreateToggle("Infinite Ammo", function() 
        return MainModule and MainModule.Guards and MainModule.Guards.InfiniteAmmo or false
    end, function(enabled)
        if MainModule and MainModule.ToggleInfiniteAmmo then
            MainModule.ToggleInfiniteAmmo(enabled)
        elseif MainModule and MainModule.Guards then
            MainModule.Guards.InfiniteAmmo = enabled
        end
    end, 5)
    
    -- Hitbox Expander с улучшенным сообщением
    CreateToggle("Hitbox Expander", function() 
        return MainModule and MainModule.Guards and MainModule.Guards.HitboxExpander or false
    end, function(enabled)
        if MainModule and MainModule.ToggleHitboxExpander then
            MainModule.ToggleHitboxExpander(enabled)
            if enabled then
                print("Hitbox Enabled...")
            end
        elseif MainModule and MainModule.Guards then
            MainModule.Guards.HitboxExpander = enabled
            if enabled then
                print("Hitbox Enabled...")
            end
        end
    end, 6)
    
    -- AutoFarm
    CreateToggle("AutoFarm", function() 
        return MainModule and MainModule.Guards and MainModule.Guards.AutoFarm or false
    end, function(enabled)
        if MainModule and MainModule.ToggleAutoFarm then
            MainModule.ToggleAutoFarm(enabled)
        elseif MainModule and MainModule.Guards then
            MainModule.Guards.AutoFarm = enabled
        end
    end, 7)
end

-- DALGONA TAB
local function CreateDalgonaContent()
    ClearContent()
    
    local completeBtn = CreateButton("Complete Dalgona")
    completeBtn.LayoutOrder = 1
    completeBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.CompleteDalgona then
            MainModule.CompleteDalgona()
        end
    end)
    
    local lighterBtn = CreateButton("Free Lighter")
    lighterBtn.LayoutOrder = 2
    lighterBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.FreeLighter then
            MainModule.FreeLighter()
        end
    end)
end

-- HNS TAB
local function CreateHNSContent()
    ClearContent()
    
    -- Infinity Stamina
    CreateToggle("Infinity Stamina", function() 
        return MainModule and MainModule.HNS and MainModule.HNS.InfinityStaminaEnabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleHNSInfinityStamina then
            MainModule.ToggleHNSInfinityStamina(enabled)
        elseif MainModule and MainModule.HNS then
            MainModule.HNS.InfinityStaminaEnabled = enabled
        end
    end, 1)
    
    -- Spikes Kill с улучшенным сообщением
    CreateToggle("Spikes Kill", function() 
        return MainModule and MainModule.SpikesKillFeature and MainModule.SpikesKillFeature.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleSpikesKill then
            local result = MainModule.ToggleSpikesKill(enabled)
            if not enabled then
                print("Knife not found!")
            end
        elseif MainModule and MainModule.SpikesKillFeature then
            MainModule.SpikesKillFeature.Enabled = enabled
            if not enabled then
                print("Knife not found!")
            end
        end
    end, 2)
    
    -- AutoDodge
    CreateToggle("AutoDodge", function() 
        return MainModule and MainModule.AutoDodge and MainModule.AutoDodge.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleAutoDodge then
            MainModule.ToggleAutoDodge(enabled)
        elseif MainModule and MainModule.AutoDodge then
            MainModule.AutoDodge.Enabled = enabled
        end
    end, 3)
    
    -- Teleport to Hider
    local teleportToHiderBtn = CreateButton("Teleport to Hider")
    teleportToHiderBtn.LayoutOrder = 4
    teleportToHiderBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportToHider then
            MainModule.TeleportToHider()
        else
            teleportToHiderBtn.Text = "Function Not Available"
            teleportToHiderBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
            task.wait(1)
            teleportToHiderBtn.Text = "Teleport to Hider"
            teleportToHiderBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        end
    end)
end

-- GLASS BRIDGE TAB
local function CreateGlassBridgeContent()
    ClearContent()
    
    -- AntiBreak (включает и AntiFall автоматически)
    CreateToggle("AntiBreak", function() 
        return MainModule and MainModule.GlassBridge and MainModule.GlassBridge.AntiBreakEnabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleGlassBridgeAntiBreak then
            MainModule.ToggleGlassBridgeAntiBreak(enabled)
        elseif MainModule and MainModule.GlassBridge then
            MainModule.GlassBridge.AntiBreakEnabled = enabled
        end
        
        if enabled then
            task.wait(0.3)
            if MainModule and MainModule.CreateGlassBridgeAntiFall then
                MainModule.CreateGlassBridgeAntiFall()
                GlassBridgeAntiFallEnabled = true
            end
        else
            if MainModule and MainModule.RemoveGlassBridgeAntiFall then
                MainModule.RemoveGlassBridgeAntiFall()
                GlassBridgeAntiFallEnabled = false
            end
        end
    end, 1)
    
    -- Glass ESP (кликабельная кнопка)
    local glassEspBtn = CreateButton("Glass ESP")
    glassEspBtn.LayoutOrder = 2
    glassEspBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.RevealGlassBridge then
            MainModule.RevealGlassBridge()
            glassEspBtn.Text = "Glass ESP (Revealed)"
            glassEspBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            task.wait(1)
            glassEspBtn.Text = "Glass ESP"
            glassEspBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        end
    end)
    
    -- Teleport to End (кликабельная кнопка)
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.LayoutOrder = 3
    tpEndBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportToGlassBridgeEnd then
            MainModule.TeleportToGlassBridgeEnd()
        end
    end)
end

-- TUG OF WAR TAB
local function CreateTugOfWarContent()
    ClearContent()
    
    CreateToggle("Auto Pull", function() 
        return MainModule and MainModule.TugOfWar and MainModule.TugOfWar.AutoPull or false
    end, function(enabled)
        if MainModule and MainModule.ToggleAutoPull then
            MainModule.ToggleAutoPull(enabled)
        elseif MainModule and MainModule.TugOfWar then
            MainModule.TugOfWar.AutoPull = enabled
        end
    end, 1)
end

-- JUMP ROPE TAB
local function CreateJumpRopeContent()
    ClearContent()
    
    -- AntiFall Toggle (ON/OFF) с обновлением текста
    local antiFallToggle, _, antiFallTextLabel = CreateToggle("AntiFall [" .. (JumpRopeAntiFallEnabled and "ON" or "OFF") .. "]", function() 
        return JumpRopeAntiFallEnabled 
    end, function(enabled)
        JumpRopeAntiFallEnabled = enabled
        if enabled then
            if MainModule and MainModule.CreateJumpRopeAntiFall then
                MainModule.CreateJumpRopeAntiFall()
                antiFallTextLabel.Text = "AntiFall [ON]"
            end
        else
            if MainModule and MainModule.RemoveJumpRopeAntiFall then
                MainModule.RemoveJumpRopeAntiFall()
                antiFallTextLabel.Text = "AntiFall [OFF]"
            end
        end
    end, 1)
    
    -- Delete The Rope (кликабельная кнопка)
    local deleteRopeBtn = CreateButton("Delete The Rope")
    deleteRopeBtn.LayoutOrder = 2
    deleteRopeBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.DeleteJumpRope then
            local success = MainModule.DeleteJumpRope()
            if success then
                deleteRopeBtn.Text = "Rope Deleted!"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                task.wait(1)
                deleteRopeBtn.Text = "Delete The Rope"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            else
                deleteRopeBtn.Text = "Rope Not Found"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
                task.wait(1)
                deleteRopeBtn.Text = "Delete The Rope"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            end
        end
    end)
    
    -- Teleport to End (кликабельная кнопка)
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.LayoutOrder = 3
    tpEndBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportToJumpRopeEnd then
            MainModule.TeleportToJumpRopeEnd()
        end
    end)
end

-- SKY SQUID TAB
local function CreateSkySquidContent()
    ClearContent()
    
    -- AntiFall Toggle (ON/OFF) с обновлением текста
    local antiFallToggle, _, antiFallTextLabel = CreateToggle("AntiFall [" .. (SkySquidAntiFallEnabled and "ON" or "OFF") .. "]", function() 
        return SkySquidAntiFallEnabled 
    end, function(enabled)
        SkySquidAntiFallEnabled = enabled
        if enabled then
            if MainModule and MainModule.CreateSkySquidAntiFall then
                MainModule.CreateSkySquidAntiFall()
                antiFallTextLabel.Text = "AntiFall [ON]"
            end
        else
            if MainModule and MainModule.RemoveSkySquidAntiFall then
                MainModule.RemoveSkySquidAntiFall()
                antiFallTextLabel.Text = "AntiFall [OFF]"
            end
        end
    end, 1)
    
    -- Void Kill
    CreateToggle("Void Kill", function() 
        return MainModule and MainModule.VoidKillFeature and MainModule.VoidKillFeature.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleVoidKill then
            MainModule.ToggleVoidKill(enabled)
        elseif MainModule and MainModule.VoidKillFeature then
            MainModule.VoidKillFeature.Enabled = enabled
        end
    end, 2)
end

-- LAST DINNER TAB
local function CreateLastDinnerContent()
    ClearContent()
    
    local titleLabel = CreateButton("LAST DINNER")
    titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    titleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    titleLabel.TextSize = 14
    titleLabel.LayoutOrder = 1
    
    -- Zone Kill Toggle
    local zoneKillToggle, _, zoneKillTextLabel = CreateToggle("Zone Kill [" .. (ZoneKillEnabled and "ON" or "OFF") .. "]", function() 
        return ZoneKillEnabled 
    end, function(enabled)
        ZoneKillEnabled = enabled
        if enabled then
            zoneKillTextLabel.Text = "Zone Kill [ON]"
            print("Zone Kill активирован")
        else
            zoneKillTextLabel.Text = "Zone Kill [OFF]"
            print("Zone Kill деактивирован")
        end
    end, 2)
end

-- SETTINGS TAB
local function CreateSettingsContent()
    ClearContent()
    
    local creatorLabel = CreateButton("Creator: Creon")
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    creatorLabel.LayoutOrder = 1
    
    local versionLabel = CreateButton("Version: 2.5")
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.LayoutOrder = 2
    
    local executorLabel = CreateButton("Executor: " .. executorName)
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    executorLabel.LayoutOrder = 3
    
    local supportedLabel = CreateButton("Supported: " .. (isSupported and "YES" or "NO"))
    supportedLabel.TextXAlignment = Enum.TextXAlignment.Left
    supportedLabel.LayoutOrder = 4
    
    -- Кнопка для изменения горячей клавиши меню
    local keybindButton = CreateKeybindButton()
    keybindButton.LayoutOrder = 5
    
    local positionLabel = CreateButton("Position: " .. (MainModule and MainModule.GetPlayerPosition and MainModule.GetPlayerPosition() or "0,0,0"))
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    positionLabel.LayoutOrder = 6
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.LayoutOrder = 7
    cleanupBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.Cleanup then
            MainModule.Cleanup()
        end
        ScreenGui:Destroy()
    end)
    
    -- Обновление позиции
    game:GetService("RunService").Heartbeat:Connect(function()
        if positionLabel and positionLabel.Parent then
            if MainModule and MainModule.GetPlayerPosition then
                positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
            end
        end
    end)
end

-- Создание вкладок с обновленным списком
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Last Dinner", "Settings"}
local tabButtons = {}

local TAB_BUTTON_WIDTH_PERCENT = 1.00 -- 95% ширины контейнера

for i, name in pairs(tabs) do
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(TAB_BUTTON_WIDTH_PERCENT, 0, 0, 36)
    buttonContainer.Position = UDim2.new((1 - TAB_BUTTON_WIDTH_PERCENT)/2, 0, 0, (i-1)*42 + 10) -- Центрируем
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.LayoutOrder = i
    buttonContainer.Parent = TabScrolling
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(240, 240, 255)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = button
    
    -- Анимация для кнопки вкладки
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
        elseif name == "Last Dinner" then
            CreateLastDinnerContent()
        elseif name == "Settings" then
            CreateSettingsContent()
        end
        
        -- Обновляем все переключатели после смены вкладки
        task.wait(0.1)
        UpdateAllToggles()
    end
    
    button.MouseButton1Click:Connect(ActivateTab)
end

-- Слушатели для горячих клавиш
local menuHotkeyConnection
local flyHotkeyConnection
local noclipHotkeyConnection
local killauraHotkeyConnection

-- Улучшенная функция для настройки слушателя меню
local function setupHotkeyListener()
    if menuHotkeyConnection then
        menuHotkeyConnection:Disconnect()
        menuHotkeyConnection = nil
    end
    
    menuHotkeyConnection = UIS.InputBegan:Connect(function(input)
        if input.KeyCode == menuHotkey then
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
end

-- Улучшенная функция для настройки слушателя Fly
local function setupFlyListener()
    if flyHotkeyConnection then
        flyHotkeyConnection:Disconnect()
        flyHotkeyConnection = nil
    end
    
    if FlyHotkey then
        flyHotkeyConnection = UIS.InputBegan:Connect(function(input)
            if input.KeyCode == FlyHotkey then
                local success, currentState = pcall(function()
                    return MainModule and MainModule.Fly and MainModule.Fly.Enabled or false
                end)
                
                if success and MainModule then
                    if MainModule.ToggleFly then
                        MainModule.ToggleFly(not currentState)
                    elseif MainModule.Fly then
                        MainModule.Fly.Enabled = not currentState
                        if MainModule.Fly.Enabled and MainModule.EnableFlight then
                            MainModule.EnableFlight()
                        elseif not MainModule.Fly.Enabled and MainModule.DisableFlight then
                            MainModule.DisableFlight()
                        end
                    end
                end
            end
        end)
    end
end

-- Улучшенная функция для настройки слушателя Noclip
local function setupNoclipListener()
    if noclipHotkeyConnection then
        noclipHotkeyConnection:Disconnect()
        noclipHotkeyConnection = nil
    end
    
    if NoclipHotkey then
        noclipHotkeyConnection = UIS.InputBegan:Connect(function(input)
            if input.KeyCode == NoclipHotkey then
                local success, currentState = pcall(function()
                    return MainModule and MainModule.Noclip and MainModule.Noclip.Enabled or false
                end)
                
                if success and MainModule then
                    if MainModule.ToggleNoclip then
                        MainModule.ToggleNoclip(not currentState)
                    elseif MainModule.Noclip then
                        MainModule.Noclip.Enabled = not currentState
                    end
                end
            end
        end)
    end
end

-- Улучшенная функция для настройки слушателя Killaura
local function setupKillauraListener()
    if killauraHotkeyConnection then
        killauraHotkeyConnection:Disconnect()
        killauraHotkeyConnection = nil
    end
    
    if KillauraHotkey then
        killauraHotkeyConnection = UIS.InputBegan:Connect(function(input)
            if input.KeyCode == KillauraHotkey then
                local success, currentState = pcall(function()
                    return MainModule and MainModule.Killaura and MainModule.Killaura.Enabled or false
                end)
                
                if success and MainModule then
                    if MainModule.ToggleKillaura then
                        MainModule.ToggleKillaura(not currentState)
                        if not currentState then
                            print("Killaura Enabled")
                        else
                            print("Killaura Disabled")
                        end
                    elseif MainModule.Killaura then
                        MainModule.Killaura.Enabled = not currentState
                        if not currentState then
                            print("Killaura Enabled")
                        else
                            print("Killaura Disabled")
                        end
                    end
                end
            end
        end)
    end
end

-- Функция для обновления всех слушателей горячих клавиш
local function updateHotkeyListener()
    setupHotkeyListener()
    setupFlyListener()
    setupNoclipListener()
    setupKillauraListener()
end

-- Установка начальных слушателей
setupHotkeyListener()

-- Автоматическое обновление GUI состояния каждые 1.3 секунды
local guiUpdateConnection
guiUpdateConnection = RunService.Heartbeat:Connect(function()
    UpdateAllToggles()
    task.wait(1.3)
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

-- Создаем Main контент и сразу отключаем инициализацию
CreateMainContent()

-- Завершаем инициализацию после создания GUI
task.spawn(function()
    task.wait(2) -- Даем время на полную инициализацию
    initializing = false
    print("Инициализация завершена")
end)

-- Очистка при удалении GUI
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        if MainModule and MainModule.Cleanup then
            MainModule.Cleanup()
        end
        if menuHotkeyConnection then
            menuHotkeyConnection:Disconnect()
        end
        if flyHotkeyConnection then
            flyHotkeyConnection:Disconnect()
        end
        if noclipHotkeyConnection then
            noclipHotkeyConnection:Disconnect()
        end
        if killauraHotkeyConnection then
            killauraHotkeyConnection:Disconnect()
        end
        if guiUpdateConnection then
            guiUpdateConnection:Disconnect()
        end
    end
end)

-- Bypass Anti-Kick система
local function LoadAntiKick()
    --// Cache
    local getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, lower, gsub, match = getgenv, getnamecallmethod, hookmetamethod, hookfunction, newcclosure, checkcaller, string.lower, string.gsub, string.match

    --// Loaded check
    if getgenv().ED_AntiKick then
        return
    end

    --// Variables
    local cloneref = cloneref or function(...) 
        return ...
    end

    local clonefunction = clonefunction or function(...)
        return ...
    end

    local Players, LocalPlayer, StarterGui = cloneref(game:GetService("Players")), cloneref(game:GetService("Players").LocalPlayer), cloneref(game:GetService("StarterGui"))

    local SetCore = clonefunction(StarterGui.SetCore)
    local FindFirstChild = clonefunction(game.FindFirstChild)

    local CompareInstances = function(Instance1, Instance2)
        return (typeof(Instance1) == "Instance" and typeof(Instance2) == "Instance")
    end

    local CanCastToSTDString = function(...)
        return pcall(FindFirstChild, game, ...)
    end

    --// Global Variables
    getgenv().ED_AntiKick = {
        Enabled = true, -- Set to false if you want to disable the Anti-Kick.
        SendNotifications = true, -- Set to true if you want to get notified for every event.
        CheckCaller = true -- Set to true if you want to disable kicking by other user executed scripts.
    }

    --// Main

    -- Показываем уведомление при загрузке один раз
    if getgenv().ED_AntiKick.SendNotifications then
        task.spawn(function()
            task.wait(1)
            StarterGui:SetCore("SendNotification", {
                Title = "Bypassed CreonHub...",
                Text = "",
                Duration = 3
            })
        end)
    end

    local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local self, message = ...
        local method = getnamecallmethod()
        
        if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and CompareInstances(self, LocalPlayer) and gsub(method, "^%l", string.upper) == "Kick" and ED_AntiKick.Enabled then
            if CanCastToSTDString(message) then
                -- Только блокируем кик, не показываем уведомления
                return
            end
        end

        return OldNamecall(...)
    end))

    local OldFunction; OldFunction = hookfunction(LocalPlayer.Kick, function(...)
        local self, Message = ...

        if ((ED_AntiKick.CheckCaller and not checkcaller()) or true) and CompareInstances(self, LocalPlayer) and ED_AntiKick.Enabled then
            if CanCastToSTDString(Message) then
                -- Только блокируем кик, не показываем уведомления
                return
            end
        end
        
        return OldFunction(...)
    end)
end

-- Загружаем Anti-Kick систему
LoadAntiKick()

-- Отображение сообщения о загрузке
print("Creon X v2.5 loaded successfully")
print("Menu Hotkey: " .. menuHotkey.Name)
print("Fly Hotkey: " .. (FlyHotkey and FlyHotkey.Name or "Not set"))
print("Noclip Hotkey: " .. (NoclipHotkey and NoclipHotkey.Name or "Not set"))
print("Killaura Hotkey: " .. (KillauraHotkey and KillauraHotkey.Name or "Not set"))
if not isSupported then
    warn("Warning: Executor " .. executorName .. " is not officially supported")
else
    print("Executor " .. executorName .. " is supported")
end
