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

-- Настройка Alert функции
MainModule.Misc.AlertFunction = function(message)
    warn("[CreonX Alert] " .. message)
end

-- Переменные для отслеживания статуса AntiFall
local GlassBridgeAntiFallEnabled = false
local JumpRopeAntiFallEnabled = false
local SkySquidAntiFallEnabled = false

-- Переменные для горячей клавиши
local menuHotkey = Enum.KeyCode.M
local isChoosingKey = false
local keyChangeButton = nil

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

-- Alert GUI для уведомлений
local AlertGui = Instance.new("ScreenGui")
local AlertFrame = Instance.new("Frame")
local AlertText = Instance.new("TextLabel")
local AlertClose = Instance.new("TextButton")

-- Кнопка для мобильных устройств (Delta Mobile)
local MobileOpenButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXv25"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

-- Alert GUI setup
AlertGui.Name = "CreonXAlerts"
AlertGui.Parent = game.CoreGui
AlertGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
AlertGui.ResetOnSpawn = false

AlertFrame.Size = UDim2.new(0, 300, 0, 80)
AlertFrame.Position = UDim2.new(0.5, -150, 0.9, -40)
AlertFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AlertFrame.BorderSizePixel = 0
AlertFrame.Visible = false
AlertFrame.Parent = AlertGui

local alertCorner = Instance.new("UICorner")
alertCorner.CornerRadius = UDim.new(0, 8)
alertCorner.Parent = AlertFrame

local alertStroke = Instance.new("UIStroke")
alertStroke.Color = Color3.fromRGB(60, 60, 80)
alertStroke.Thickness = 2
alertStroke.Parent = AlertFrame

AlertText.Size = UDim2.new(1, -20, 0.7, 0)
AlertText.Position = UDim2.new(0, 10, 0, 10)
AlertText.BackgroundTransparency = 1
AlertText.Text = "Alert Message"
AlertText.TextColor3 = Color3.fromRGB(220, 220, 255)
AlertText.TextSize = 14
AlertText.Font = Enum.Font.Gotham
AlertText.TextWrapped = true
AlertText.Parent = AlertFrame

AlertClose.Size = UDim2.new(0, 80, 0, 25)
AlertClose.Position = UDim2.new(0.5, -40, 1, -35)
AlertClose.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
AlertClose.BorderSizePixel = 0
AlertClose.Text = "Close"
AlertClose.TextColor3 = Color3.fromRGB(240, 240, 255)
AlertClose.TextSize = 12
AlertClose.Font = Enum.Font.Gotham
AlertClose.Parent = AlertFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = AlertClose

AlertClose.MouseButton1Click:Connect(function()
    AlertFrame.Visible = false
end)

-- Функция для показа Alert
local function ShowAlert(message, duration)
    if not duration then duration = 3 end
    AlertText.Text = message
    AlertFrame.Visible = true
    
    task.delay(duration, function()
        if AlertFrame.Visible then
            AlertFrame.Visible = false
        end
    end)
end

-- Обновляем Alert функцию в MainModule
MainModule.Misc.AlertFunction = ShowAlert

-- Размеры GUI
local GUI_WIDTH = 860
local GUI_HEIGHT = 595

-- Для мобильных устройств уменьшаем размер на 40%
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
TitleLabel.Text = "Creon X v2.5"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка сворачивания (увеличиваем для мобильных)
local minimizeButtonSize = 25
if UIS.TouchEnabled then
    minimizeButtonSize = 35  -- Увеличиваем кнопку для мобильных
end

MinimizeButton.Size = UDim2.new(0, minimizeButtonSize, 0, minimizeButtonSize)
MinimizeButton.Position = UDim2.new(1, -minimizeButtonSize-5, 0.5, -minimizeButtonSize/2)
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

-- Scrolling Frame для контента с улучшенной прокруткой для мобильных
ContentScrolling.Size = UDim2.new(1, -10, 1, -10)
ContentScrolling.Position = UDim2.new(0, 5, 0, 5)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.ScrollBarThickness = UIS.TouchEnabled and 10 or 6  -- Толще для мобильных
ContentScrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScrolling.ScrollingEnabled = true
ContentScrolling.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
ContentScrolling.Parent = ContentFrame

ContentLayout.Padding = UDim.new(0, UIS.TouchEnabled and 10 or 8)  -- Больше отступы для мобильных
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)
ContentLayout.Parent = ContentScrolling

-- Кнопка для мобильных устройств (Delta Mobile) - меньшего размера
if UIS.TouchEnabled then
    MobileOpenButton.Size = UDim2.new(0, 100, 0, 35)  -- Меньше размер
    MobileOpenButton.Position = UDim2.new(0.5, -50, 0.2, 0)
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
    
    local mobileDragging = false
    local mobileDragStart, mobileStartPos
    
    MobileOpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = true
            mobileDragStart = input.Position
            mobileStartPos = MobileOpenButton.Position
        end
    end)
    
    MobileOpenButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local currentInput = input
            RunService.RenderStepped:Connect(function()
                if mobileDragging and currentInput then
                    local delta = currentInput.Position - mobileDragStart
                    MobileOpenButton.Position = UDim2.new(
                        mobileStartPos.X.Scale, 
                        mobileStartPos.X.Offset + delta.X,
                        mobileStartPos.Y.Scale, 
                        mobileStartPos.Y.Offset + delta.Y
                    )
                end
            end)
        end
    end)
    
    MobileOpenButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = false
        end
    end)
    
    MainFrame.Visible = false
else
    MainFrame.Visible = true
end

-- Функция для перемещения GUI с улучшенной поддержкой мобильных
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

-- Улучшенная прокрутка для мобильных устройств
if UIS.TouchEnabled then
    local scrolling = false
    local scrollStart = nil
    local scrollVelocity = 0
    local lastScrollTime = 0
    
    ContentScrolling.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            scrolling = true
            scrollStart = input.Position.Y
            scrollVelocity = 0
            lastScrollTime = tick()
        end
    end)
    
    ContentScrolling.InputChanged:Connect(function(input)
        if scrolling and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position.Y - scrollStart
            ContentScrolling.CanvasPosition = Vector2.new(0, math.max(0, ContentScrolling.CanvasPosition.Y - delta))
            scrollStart = input.Position.Y
            
            -- Вычисляем скорость прокрутки
            local currentTime = tick()
            local timeDelta = currentTime - lastScrollTime
            if timeDelta > 0 then
                scrollVelocity = delta / timeDelta
            end
            lastScrollTime = currentTime
        end
    end)
    
    ContentScrolling.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            scrolling = false
            
            -- Инерционная прокрутка
            if math.abs(scrollVelocity) > 10 then
                local inertia = scrollVelocity * 0.9
                local startTime = tick()
                
                while math.abs(inertia) > 1 do
                    local elapsed = tick() - startTime
                    ContentScrolling.CanvasPosition = Vector2.new(0, 
                        math.max(0, ContentScrolling.CanvasPosition.Y - inertia * elapsed))
                    inertia = inertia * 0.95
                    task.wait()
                end
            end
        end
    end)
end

-- Функция для создания кнопок с увеличенным размером для мобильных
local function CreateButton(text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, UIS.TouchEnabled and 40 or 32)  -- Больше для мобильных
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(240, 240, 255)
    button.TextSize = UIS.TouchEnabled and 14 or 12  -- Больше текст для мобильных
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

-- Функция для создания переключателей с увеличенным размером для мобильных
local function CreateToggle(text, enabled, callback, gameCheckCallback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -10, 0, UIS.TouchEnabled and 40 or 32)  -- Больше для мобильных
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentScrolling
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    textLabel.TextSize = UIS.TouchEnabled and 14 or 12  -- Больше текст для мобильных
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = toggleContainer
    
    -- Переключатель с увеличенным размером для мобильных
    local toggleSize = UIS.TouchEnabled and 60 or 50
    local toggleCircleSize = UIS.TouchEnabled and 26 or 22
    
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Size = UDim2.new(0, toggleSize, 0, toggleCircleSize)
    toggleBackground.Position = UDim2.new(1, -toggleSize-2, 0.5, -toggleCircleSize/2)
    toggleBackground.BackgroundColor3 = enabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleContainer
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, toggleCircleSize-4, 0, toggleCircleSize-4)
    toggleCircle.Position = enabled and UDim2.new(1, -toggleCircleSize, 0.5, -(toggleCircleSize-4)/2) or UDim2.new(0, 2, 0.5, -(toggleCircleSize-4)/2)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBackground
    
    -- Закругления
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, toggleCircleSize/2)
    corner1.Parent = toggleBackground
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, (toggleCircleSize-4)/2)
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
        if gameCheckCallback and not gameCheckCallback() then
            ShowAlert("Game not running!")
            return
        end
        
        enabled = newState
        TweenService:Create(toggleBackground, TweenInfo.new(0.2), {
            BackgroundColor3 = newState and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
            Position = newState and UDim2.new(1, -toggleCircleSize, 0.5, -(toggleCircleSize-4)/2) or UDim2.new(0, 2, 0.5, -(toggleCircleSize-4)/2)
        }):Play()
        
        if callback then
            callback(newState)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not enabled)
    end)
    
    return toggleContainer, updateToggle, textLabel
end

-- Функция для создания слайдера скорости
local function CreateSpeedSlider()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -10, 0, UIS.TouchEnabled and 70 or 60)  -- Больше для мобильных
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ContentScrolling
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. MainModule.SpeedHack.CurrentSpeed
    speedLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    speedLabel.TextSize = UIS.TouchEnabled and 14 or 12  -- Больше текст для мобильных
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
    sliderButton.Size = UDim2.new(0, UIS.TouchEnabled and 24 or 20, 0, UIS.TouchEnabled and 24 or 20)  -- Больше для мобильных
    sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -UIS.TouchEnabled and 12 or 10, 0, UIS.TouchEnabled and -2 or 0)
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
        sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -UIS.TouchEnabled and 12 or 10, 0, UIS.TouchEnabled and -2 or 0)
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

-- Функция для создания кнопки изменения горячей клавиши
local function CreateKeybindButton()
    local keybindContainer = Instance.new("Frame")
    keybindContainer.Size = UDim2.new(1, -10, 0, UIS.TouchEnabled and 40 or 32)  -- Больше для мобильных
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
    label.TextSize = UIS.TouchEnabled and 14 or 12  -- Больше текст для мобильных
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
    changeBtn.TextSize = UIS.TouchEnabled and 12 or 11  -- Больше текст для мобильных
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
        if not isChoosingKey then
            TweenService:Create(changeBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(75, 75, 95),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    
    changeBtn.MouseLeave:Connect(function()
        if not isChoosingKey then
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
        isChoosingKey = true
        changeBtn.Text = "Press any key..."
        changeBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        
        local connection
        connection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                -- Сохраняем новую клавишу
                menuHotkey = input.KeyCode
                updateKeyText()
                
                -- Останавливаем выбор
                isChoosingKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if connection then
                    connection:Disconnect()
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                -- Можно добавить поддержку мыши, если нужно
                isChoosingKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        -- Если 5 секунд не выбрали клавишу - отменяем
        task.delay(5, function()
            if isChoosingKey then
                isChoosingKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end
    
    changeBtn.MouseButton1Click:Connect(function()
        if not isChoosingKey then
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
    selectorContainer.Size = UDim2.new(1, -10, 0, UIS.TouchEnabled and 40 or 32)  -- Больше для мобильных
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
    label.Text = "Guard Type: " .. MainModule.Guards.SelectedGuard
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.TextSize = UIS.TouchEnabled and 14 or 12  -- Больше текст для мобильных
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
    changeBtn.TextSize = UIS.TouchEnabled and 12 or 11  -- Больше текст для мобильных
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
    for i, guardType in ipairs(guardTypes) do
        if guardType == MainModule.Guards.SelectedGuard then
            currentIndex = i
            break
        end
    end
    
    changeBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #guardTypes then
            currentIndex = 1
        end
        
        local newGuardType = guardTypes[currentIndex]
        if MainModule.SetGuardType then
            MainModule.SetGuardType(newGuardType)
        else
            MainModule.Guards.SelectedGuard = newGuardType
        end
        label.Text = "Guard Type: " .. newGuardType
    end)
    
    return selectorContainer
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
    local speedToggle, updateSpeedToggle = CreateToggle("SpeedHack", MainModule.SpeedHack.Enabled, function(enabled)
        if MainModule.ToggleSpeedHack then
            MainModule.ToggleSpeedHack(enabled)
        else
            MainModule.SpeedHack.Enabled = enabled
        end
    end)
    speedToggle.LayoutOrder = 1
    
    -- Noclip
    local noclipToggle, updateNoclipToggle = CreateToggle("Noclip", MainModule.Noclip.Enabled, function(enabled)
        if MainModule.ToggleNoclip then
            MainModule.ToggleNoclip(enabled)
        else
            MainModule.Noclip.Enabled = enabled
        end
    end)
    noclipToggle.LayoutOrder = 2
    
    -- Anti Stun QTE
    local antiStunToggle, updateAntiStunToggle = CreateToggle("Anti Stun QTE", MainModule.AutoQTE.AntiStunEnabled, function(enabled)
        if MainModule.ToggleAntiStunQTE then
            MainModule.ToggleAntiStunQTE(enabled)
        else
            MainModule.AutoQTE.AntiStunEnabled = enabled
        end
    end)
    antiStunToggle.LayoutOrder = 3
    
    -- Anti Stun + Anti Ragdoll
    local bypassRagdollToggle, updateBypassRagdollToggle = CreateToggle("Anti Stun + Anti Ragdoll", MainModule.Misc.BypassRagdollEnabled, function(enabled)
        if MainModule.ToggleBypassRagdoll then
            MainModule.ToggleBypassRagdoll(enabled)
        else
            MainModule.Misc.BypassRagdollEnabled = enabled
        end
    end)
    bypassRagdollToggle.LayoutOrder = 4
    
    -- Instance Interact
    local instaInteractToggle, updateInstaInteractToggle = CreateToggle("Instance Interact", MainModule.Misc.InstaInteract, function(enabled)
        if MainModule.ToggleInstaInteract then
            MainModule.ToggleInstaInteract(enabled)
        else
            MainModule.Misc.InstaInteract = enabled
        end
    end)
    instaInteractToggle.LayoutOrder = 5
    
    -- No Cooldown Proximity
    local noCooldownToggle, updateNoCooldownToggle = CreateToggle("No Cooldown Proximity", MainModule.Misc.NoCooldownProximity, function(enabled)
        if MainModule.ToggleNoCooldownProximity then
            MainModule.ToggleNoCooldownProximity(enabled)
        else
            MainModule.Misc.NoCooldownProximity = enabled
        end
    end)
    noCooldownToggle.LayoutOrder = 6
    
    -- Teleport Buttons
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.LayoutOrder = 7
    tpUpBtn.MouseButton1Click:Connect(function()
        if MainModule.TeleportUp100 then
            MainModule.TeleportUp100()
        end
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.LayoutOrder = 8
    tpDownBtn.MouseButton1Click:Connect(function()
        if MainModule.TeleportDown40 then
            MainModule.TeleportDown40()
        end
    end)
    
    -- Position display
    local positionLabel = CreateButton("Position: " .. MainModule.GetPlayerPosition())
    positionLabel.LayoutOrder = 9
    positionLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    positionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    
    -- Update position
    game:GetService("RunService").Heartbeat:Connect(function()
        if positionLabel and positionLabel.Parent then
            positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
        end
    end)
end

-- COMBAT TAB
local function CreateCombatContent()
    ClearContent()
    
    local comingSoon = Instance.new("TextLabel")
    comingSoon.Size = UDim2.new(1, 0, 0, 40)
    comingSoon.BackgroundTransparency = 1
    comingSoon.Text = "Combat Features Coming Soon"
    comingSoon.TextColor3 = Color3.fromRGB(200, 200, 200)
    comingSoon.TextSize = 16
    comingSoon.Font = Enum.Font.Gotham
    comingSoon.Parent = ContentScrolling
end

-- MISC TAB
local function CreateMiscContent()
    ClearContent()
    
    -- ESP System Toggle
    local espToggle, updateEspToggle = CreateToggle("ESP System", MainModule.Misc.ESPEnabled, function(enabled)
        if MainModule.ToggleESP then
            MainModule.ToggleESP(enabled)
        else
            MainModule.Misc.ESPEnabled = enabled
        end
    end)
    espToggle.LayoutOrder = 1
    
    -- ESP Players
    local espPlayersToggle, updateEspPlayersToggle = CreateToggle("ESP Players", MainModule.Misc.ESPPlayers, function(enabled)
        MainModule.Misc.ESPPlayers = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espPlayersToggle.LayoutOrder = 2
    
    -- ESP Hiders
    local espHidersToggle, updateEspHidersToggle = CreateToggle("ESP Hiders", MainModule.Misc.ESPHiders, function(enabled)
        MainModule.Misc.ESPHiders = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espHidersToggle.LayoutOrder = 3
    
    -- ESP Seekers
    local espSeekersToggle, updateEspSeekersToggle = CreateToggle("ESP Seekers", MainModule.Misc.ESPSeekers, function(enabled)
        MainModule.Misc.ESPSeekers = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espSeekersToggle.LayoutOrder = 4
    
    -- ESP Highlight
    local espHighlightToggle, updateEspHighlightToggle = CreateToggle("ESP Highlight", MainModule.Misc.ESPHighlight, function(enabled)
        MainModule.Misc.ESPHighlight = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espHighlightToggle.LayoutOrder = 5
    
    -- ESP Distance
    local espDistanceToggle, updateEspDistanceToggle = CreateToggle("ESP Distance", MainModule.Misc.ESPDistance, function(enabled)
        MainModule.Misc.ESPDistance = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espDistanceToggle.LayoutOrder = 6
end

-- REBEL TAB
local function CreateRebelContent()
    ClearContent()
    
    local rebelTitle = CreateButton("REBEL")
    rebelTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    rebelTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    rebelTitle.TextSize = 14
    rebelTitle.LayoutOrder = 1
    
    local rebelToggle, updateRebelToggle = CreateToggle("Instant Rebel", MainModule.Rebel.Enabled, function(enabled)
        if MainModule.ToggleRebel then
            MainModule.ToggleRebel(enabled)
        else
            MainModule.Rebel.Enabled = enabled
        end
    end)
    rebelToggle.LayoutOrder = 2
end

-- RLGL TAB
local function CreateRLGLContent()
    ClearContent()
    
    -- Сначала проверяем состояние игры
    local function checkRLGLGame()
        return MainModule.CheckRLGLGameState()
    end
    
    local tpEndBtn = CreateButton("TP TO END")
    tpEndBtn.LayoutOrder = 1
    tpEndBtn.MouseButton1Click:Connect(function()
        if MainModule.TeleportToEnd then
            MainModule.TeleportToEnd()
        end
    end)
    
    local tpStartBtn = CreateButton("TP TO START")
    tpStartBtn.LayoutOrder = 2
    tpStartBtn.MouseButton1Click:Connect(function()
        if MainModule.TeleportToStart then
            MainModule.TeleportToStart()
        end
    end)
    
    local godModeToggle, updateGodModeToggle = CreateToggle("GodMode", MainModule.RLGL.GodMode, function(enabled)
        if MainModule.ToggleGodMode then
            MainModule.ToggleGodMode(enabled)
        else
            MainModule.RLGL.GodMode = enabled
        end
    end, checkRLGLGame)
    godModeToggle.LayoutOrder = 3
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
        if MainModule.SpawnAsGuard then
            MainModule.SpawnAsGuard()
        end
    end)
    
    -- Rapid Fire
    local rapidFireToggle, updateRapidFireToggle = CreateToggle("Rapid Fire", MainModule.Guards.RapidFire, function(enabled)
        if MainModule.ToggleRapidFire then
            MainModule.ToggleRapidFire(enabled)
        else
            MainModule.Guards.RapidFire = enabled
        end
    end)
    rapidFireToggle.LayoutOrder = 3
    
    -- Infinite Ammo
    local infiniteAmmoToggle, updateInfiniteAmmoToggle = CreateToggle("Infinite Ammo", MainModule.Guards.InfiniteAmmo, function(enabled)
        if MainModule.ToggleInfiniteAmmo then
            MainModule.ToggleInfiniteAmmo(enabled)
        else
            MainModule.Guards.InfiniteAmmo = enabled
        end
    end)
    infiniteAmmoToggle.LayoutOrder = 4
    
    -- Hitbox Expander
    local hitboxToggle, updateHitboxToggle = CreateToggle("Hitbox Expander", MainModule.Guards.HitboxExpander, function(enabled)
        if MainModule.ToggleHitboxExpander then
            MainModule.ToggleHitboxExpander(enabled)
        else
            MainModule.Guards.HitboxExpander = enabled
        end
    end)
    hitboxToggle.LayoutOrder = 5
    
    -- AutoFarm
    local autoFarmToggle, updateAutoFarmToggle = CreateToggle("AutoFarm", MainModule.Guards.AutoFarm, function(enabled)
        if MainModule.ToggleAutoFarm then
            MainModule.ToggleAutoFarm(enabled)
        else
            MainModule.Guards.AutoFarm = enabled
        end
    end)
    autoFarmToggle.LayoutOrder = 6
end

-- DALGONA TAB
local function CreateDalgonaContent()
    ClearContent()
    
    local completeBtn = CreateButton("Complete Dalgona")
    completeBtn.LayoutOrder = 1
    completeBtn.MouseButton1Click:Connect(function()
        if MainModule.CompleteDalgona then
            MainModule.CompleteDalgona()
        end
    end)
    
    local lighterBtn = CreateButton("Free Lighter")
    lighterBtn.LayoutOrder = 2
    lighterBtn.MouseButton1Click:Connect(function()
        if MainModule.FreeLighter then
            MainModule.FreeLighter()
        end
    end)
end

-- HNS TAB
local function CreateHNSContent()
    ClearContent()
    
    -- Сначала проверяем состояние игры
    local function checkHNSGame()
        return MainModule.CheckHNSGameState()
    end
    
    -- Infinity Stamina (только для тех у кого есть DODGE!)
    local staminaToggle, updateStaminaToggle = CreateToggle("Infinity Stamina", MainModule.HNS.InfinityStaminaEnabled, function(enabled)
        if MainModule.ToggleHNSInfinityStamina then
            MainModule.ToggleHNSInfinityStamina(enabled)
        else
            MainModule.HNS.InfinityStaminaEnabled = enabled
        end
    end, function()
        return MainModule.HNS.HasDodge
    end)
    staminaToggle.LayoutOrder = 1
    
    -- Spikes Kill (только для Seekers с ножом)
    local spikesKillToggle, updateSpikesKillToggle = CreateToggle("Spikes Kill", MainModule.SpikesKill.Enabled, function(enabled)
        if MainModule.ToggleSpikesKill then
            MainModule.ToggleSpikesKill(enabled)
        else
            MainModule.SpikesKill.Enabled = enabled
        end
    end, function()
        return MainModule.HNS.HasKnife
    end)
    spikesKillToggle.LayoutOrder = 2
    
    -- AutoDodge (только для тех у кого есть DODGE!)
    local autoDodgeToggle, updateAutoDodgeToggle = CreateToggle("AutoDodge", MainModule.AutoDodge.Enabled, function(enabled)
        if MainModule.ToggleAutoDodge then
            MainModule.ToggleAutoDodge(enabled)
        else
            MainModule.AutoDodge.Enabled = enabled
        end
    end, function()
        return MainModule.HNS.HasDodge
    end)
    autoDodgeToggle.LayoutOrder = 3
    
    -- Disable Spikes (кликабельная кнопка)
    local disableSpikesBtn = CreateButton("Disable Spikes")
    disableSpikesBtn.LayoutOrder = 4
    disableSpikesBtn.MouseButton1Click:Connect(function()
        if MainModule.DisableSpikes then
            local success = MainModule.DisableSpikes(true)
            if success then
                ShowAlert("Spikes Disabled!")
                disableSpikesBtn.Text = "Spikes Disabled!"
                disableSpikesBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                task.wait(1)
                disableSpikesBtn.Text = "Disable Spikes"
                disableSpikesBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            else
                ShowAlert("Failed to Disable Spikes")
                disableSpikesBtn.Text = "Failed to Disable"
                disableSpikesBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
                task.wait(1)
                disableSpikesBtn.Text = "Disable Spikes"
                disableSpikesBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            end
        end
    end)
    
    -- Teleport to Hider (новая функция)
    local teleportHiderBtn = CreateButton("Teleport to Hider")
    teleportHiderBtn.LayoutOrder = 5
    teleportHiderBtn.MouseButton1Click:Connect(function()
        if MainModule.TeleportToHider then
            MainModule.TeleportToHider()
        end
    end)
end

-- Функция для GLASS BRIDGE с автоматическим AntiFall при включении
local function GlassBridgeToggleCallback(enabled)
    if MainModule.ToggleGlassBridgeAntiBreak then
        MainModule.ToggleGlassBridgeAntiBreak(enabled)
    else
        MainModule.GlassBridge.AntiBreakEnabled = enabled
    end
    
    -- Автоматически создаем AntiFall платформу при включении
    if enabled then
        task.wait(0.3) -- Небольшая задержка
        if MainModule.CreateGlassBridgeAntiFall then
            MainModule.CreateGlassBridgeAntiFall()
            GlassBridgeAntiFallEnabled = true
        end
    else
        -- При выключении удаляем AntiFall платформу
        if MainModule.RemoveGlassBridgeAntiFall then
            MainModule.RemoveGlassBridgeAntiFall()
            GlassBridgeAntiFallEnabled = false
        end
    end
end

-- GLASS BRIDGE TAB
local function CreateGlassBridgeContent()
    ClearContent()
    
    -- AntiBreak (включает и AntiFall автоматически)
    local antiBreakToggle, updateAntiBreakToggle = CreateToggle("AntiBreak", MainModule.GlassBridge.AntiBreakEnabled, GlassBridgeToggleCallback)
    antiBreakToggle.LayoutOrder = 1
    
    -- Manual AntiFall Toggle (ON/OFF) с обновлением текста
    local antiFallToggle, updateAntiFallToggle, antiFallTextLabel = CreateToggle("AntiFall [" .. (GlassBridgeAntiFallEnabled and "ON" or "OFF") .. "]", GlassBridgeAntiFallEnabled, function(enabled)
        GlassBridgeAntiFallEnabled = enabled
        if enabled then
            if MainModule.CreateGlassBridgeAntiFall then
                MainModule.CreateGlassBridgeAntiFall()
                antiFallTextLabel.Text = "AntiFall [ON]"
            end
        else
            if MainModule.RemoveGlassBridgeAntiFall then
                MainModule.RemoveGlassBridgeAntiFall()
                antiFallTextLabel.Text = "AntiFall [OFF]"
            end
        end
    end)
    antiFallToggle.LayoutOrder = 2
    
    -- Glass ESP (кликабельная кнопка)
    local glassEspBtn = CreateButton("Glass ESP")
    glassEspBtn.LayoutOrder = 3
    glassEspBtn.MouseButton1Click:Connect(function()
        if MainModule.RevealGlassBridge then
            MainModule.RevealGlassBridge()
            ShowAlert("Glass Bridge tiles revealed!")
            glassEspBtn.Text = "Glass ESP (Revealed)"
            glassEspBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            task.wait(1)
            glassEspBtn.Text = "Glass ESP"
            glassEspBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        end
    end)
    
    -- Teleport to End (кликабельная кнопка)
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.LayoutOrder = 4
    tpEndBtn.MouseButton1Click:Connect(function()
        if MainModule.TeleportToGlassBridgeEnd then
            MainModule.TeleportToGlassBridgeEnd()
        end
    end)
end

-- TUG OF WAR TAB
local function CreateTugOfWarContent()
    ClearContent()
    
    local autoPullToggle, updateAutoPullToggle = CreateToggle("Auto Pull", MainModule.TugOfWar.AutoPull, function(enabled)
        if MainModule.ToggleAutoPull then
            MainModule.ToggleAutoPull(enabled)
        else
            MainModule.TugOfWar.AutoPull = enabled
        end
    end)
    autoPullToggle.LayoutOrder = 1
end

-- JUMP ROPE TAB
local function CreateJumpRopeContent()
    ClearContent()
    
    -- AntiFall Toggle (ON/OFF) с обновлением текста
    local antiFallToggle, updateAntiFallToggle, antiFallTextLabel = CreateToggle("AntiFall [" .. (JumpRopeAntiFallEnabled and "ON" or "OFF") .. "]", JumpRopeAntiFallEnabled, function(enabled)
        JumpRopeAntiFallEnabled = enabled
        if enabled then
            if MainModule.CreateJumpRopeAntiFall then
                MainModule.CreateJumpRopeAntiFall()
                antiFallTextLabel.Text = "AntiFall [ON]"
            end
        else
            if MainModule.RemoveJumpRopeAntiFall then
                MainModule.RemoveJumpRopeAntiFall()
                antiFallTextLabel.Text = "AntiFall [OFF]"
            end
        end
    end)
    antiFallToggle.LayoutOrder = 1
    
    -- Delete The Rope (кликабельная кнопка)
    local deleteRopeBtn = CreateButton("Delete The Rope")
    deleteRopeBtn.LayoutOrder = 2
    deleteRopeBtn.MouseButton1Click:Connect(function()
        if MainModule.DeleteJumpRope then
            local success = MainModule.DeleteJumpRope()
            if success then
                ShowAlert("Rope deleted successfully!")
                deleteRopeBtn.Text = "Rope Deleted!"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                task.wait(1)
                deleteRopeBtn.Text = "Delete The Rope"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            else
                ShowAlert("Rope not found")
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
        if MainModule.TeleportToJumpRopeEnd then
            MainModule.TeleportToJumpRopeEnd()
        end
    end)
end

-- SKY SQUID TAB
local function CreateSkySquidContent()
    ClearContent()
    
    -- AntiFall Toggle (ON/OFF) с обновлением текста
    local antiFallToggle, updateAntiFallToggle, antiFallTextLabel = CreateToggle("AntiFall [" .. (SkySquidAntiFallEnabled and "ON" or "OFF") .. "]", SkySquidAntiFallEnabled, function(enabled)
        SkySquidAntiFallEnabled = enabled
        if enabled then
            if MainModule.CreateSkySquidAntiFall then
                MainModule.CreateSkySquidAntiFall()
                antiFallTextLabel.Text = "AntiFall [ON]"
            end
        else
            if MainModule.RemoveSkySquidAntiFall then
                MainModule.RemoveSkySquidAntiFall()
                antiFallTextLabel.Text = "AntiFall [OFF]"
            end
        end
    end)
    antiFallToggle.LayoutOrder = 1
    
    -- Void Kill
    local voidKillToggle, updateVoidKillToggle = CreateToggle("Void Kill", MainModule.VoidKill.Enabled, function(enabled)
        if MainModule.ToggleVoidKill then
            MainModule.ToggleVoidKill(enabled)
        else
            MainModule.VoidKill.Enabled = enabled
        end
    end)
    voidKillToggle.LayoutOrder = 2
end

-- LAST DINNER TAB (новая вкладка)
local function CreateLastDinnerContent()
    ClearContent()
    
    -- Проверка состояния игры для Last Dinner
    local function checkLastDinnerGame()
        return MainModule.CheckZoneKillGameState()
    end
    
    local title = CreateButton("LAST DINNER")
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    title.TextColor3 = Color3.fromRGB(255, 150, 50)
    title.TextSize = 14
    title.LayoutOrder = 1
    
    -- Zone Kill функция
    local zoneKillToggle, updateZoneKillToggle = CreateToggle("Zone Kill", MainModule.ZoneKill.Enabled, function(enabled)
        if MainModule.ToggleZoneKill then
            MainModule.ToggleZoneKill(enabled)
        else
            MainModule.ZoneKill.Enabled = enabled
        end
    end, checkLastDinnerGame)
    zoneKillToggle.LayoutOrder = 2
    
    local infoLabel = CreateButton("Teleports to zone when kill animation plays")
    infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    infoLabel.TextSize = 12
    infoLabel.LayoutOrder = 3
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
    
    local positionLabel = CreateButton("Position: " .. MainModule.GetPlayerPosition())
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    positionLabel.LayoutOrder = 6
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.LayoutOrder = 7
    cleanupBtn.MouseButton1Click:Connect(function()
        if MainModule.Cleanup then
            MainModule.Cleanup()
        end
        ScreenGui:Destroy()
        AlertGui:Destroy()
        ShowAlert("Script cleaned up!", 2)
    end)
    
    -- Обновление позиции
    game:GetService("RunService").Heartbeat:Connect(function()
        if positionLabel and positionLabel.Parent then
            positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
        end
    end)
end

-- Создание вкладок с добавлением Last Dinner
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Last Dinner", "Settings"}
local tabButtons = {}

for i, name in pairs(tabs) do
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.9, 0, 0, UIS.TouchEnabled and 40 or 36)  -- Больше для мобильных
    buttonContainer.Position = UDim2.new(0.05, 0, 0, (i-1)*(UIS.TouchEnabled and 42 or 38) + 10)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = TabButtons
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(240, 240, 255)
    button.TextSize = UIS.TouchEnabled and 13 or 12  -- Больше текст для мобильных
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
    end
    
    button.MouseButton1Click:Connect(ActivateTab)
end

-- Обновленная функция управления горячими клавишами
local hotkeyConnection
local function setupHotkeyListener()
    if hotkeyConnection then
        hotkeyConnection:Disconnect()
        hotkeyConnection = nil
    end
    
    hotkeyConnection = UIS.InputBegan:Connect(function(input)
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

-- Установка начального слушателя
setupHotkeyListener()

-- Закрытие при нажатии ESC
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape and MainFrame.Visible then
        MainFrame.Visible = false
        if UIS.TouchEnabled then
            MobileOpenButton.Visible = true
        end
    end
end)

-- Автоматическое выключение функций при неактивной игре
local gameCheckConnection
local function setupGameCheck()
    if gameCheckConnection then
        gameCheckConnection:Disconnect()
        gameCheckConnection = nil
    end
    
    gameCheckConnection = RunService.Heartbeat:Connect(function()
        -- Проверяем RLGL каждые 5 секунд
        if MainModule.RLGL.GodMode then
            MainModule.CheckRLGLGameState()
        end
        
        -- Проверяем HNS каждые 5 секунд
        if MainModule.HNS.InfinityStaminaEnabled or MainModule.SpikesKill.Enabled or MainModule.AutoDodge.Enabled then
            MainModule.CheckHNSGameState()
        end
        
        -- Проверяем Last Dinner каждые 5 секунд
        if MainModule.ZoneKill.Enabled then
            MainModule.CheckZoneKillGameState()
        end
    end)
end

setupGameCheck()

-- Автоматически открываем Main вкладку
if tabButtons["Main"] then
    tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    tabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
end
CreateMainContent()

-- Очистка при удалении GUI
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        if MainModule.Cleanup then
            MainModule.Cleanup()
        end
        if hotkeyConnection then
            hotkeyConnection:Disconnect()
        end
        if gameCheckConnection then
            gameCheckConnection:Disconnect()
        end
    end
end)

-- Функция для обновления слушателя горячей клавиши при изменении
local function updateHotkeyListener()
    setupHotkeyListener()
end

-- Создаем связь между кнопкой изменения и обновлением слушателя
if keyChangeButton then
    keyChangeButton.MouseButton1Click:Connect(updateHotkeyListener)
end

-- Отображение сообщения о загрузке
print("Creon X v2.5 loaded successfully")
print("Menu Hotkey: " .. menuHotkey.Name)
if not isSupported then
    ShowAlert("Warning: Executor " .. executorName .. " is not officially supported", 5)
else
    print("Executor " .. executorName .. " is supported")
end

ShowAlert("Creon X v2.5 loaded! Hotkey: " .. menuHotkey.Name, 3)
