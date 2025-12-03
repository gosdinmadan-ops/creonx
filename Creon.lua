-- Creon X v2.1 (исправленная версия для ПК и Delta Mobile)
-- Проверка исполнителя
local executorName = "Unknown"
if identifyexecutor then
    executorName = identifyexecutor()
elseif getexecutorname then
    executorName = getexecutorname()
end

-- Поддерживаемые исполнители (включая Delta)
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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
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

-- Функция для создания выпадающего списка (исправлено)
local function CreateGuardsDropdown(options, default, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(1, -10, 0, 32)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.LayoutOrder = 1
    dropdownContainer.Parent = ContentScrolling
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = default .. " ▼"
    dropdownButton.TextColor3 = Color3.fromRGB(240, 240, 255)
    dropdownButton.TextSize = 12
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = dropdownContainer
    dropdownButton.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = dropdownButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = dropdownButton
    
    -- Анимация для кнопки
    dropdownButton.MouseEnter:Connect(function()
        TweenService:Create(dropdownButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(65, 65, 85),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        TweenService:Create(dropdownButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 65),
            TextColor3 = Color3.fromRGB(240, 240, 255)
        }):Play()
    end)
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Size = UDim2.new(1, 0, 0, math.min(#options * 32, 100))
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdownList.BorderSizePixel = 0
    dropdownList.ScrollBarThickness = 6
    dropdownList.Visible = false
    dropdownList.ZIndex = 100
    dropdownList.Parent = ScreenGui
    
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
        optionButton.Position = UDim2.new(0, 4, 0, (i-1)*32)
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(240, 240, 255)
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.AutoButtonColor = false
        optionButton.ZIndex = 101
        optionButton.Parent = dropdownList
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 6)
        optionCorner.Parent = optionButton
        
        local optionStroke = Instance.new("UIStroke")
        optionStroke.Color = Color3.fromRGB(80, 80, 100)
        optionStroke.Thickness = 1.2
        optionStroke.Parent = optionButton
        
        optionButton.MouseButton1Click:Connect(function()
            if callback then
                callback(option)
            end
            dropdownButton.Text = option .. " ▼"
            dropdownList.Visible = false
        end)
        
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(65, 65, 85),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 65),
                TextColor3 = Color3.fromRGB(240, 240, 255)
            }):Play()
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        if dropdownList.Visible then
            local buttonPos = dropdownButton.AbsolutePosition
            local buttonSize = dropdownButton.AbsoluteSize
            
            dropdownList.Position = UDim2.new(
                0, buttonPos.X,
                0, buttonPos.Y + buttonSize.Y + 5
            )
            dropdownList.Size = UDim2.new(0, buttonSize.X, 0, math.min(#options * 32, 100))
        end
    end)
    
    -- Закрытие при клике вне списка
    local function closeDropdown()
        dropdownList.Visible = false
    end
    
    UIS.InputBegan:Connect(function(input)
        if dropdownList.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position
            local listPos = dropdownList.AbsolutePosition
            local listSize = dropdownList.AbsoluteSize
            
            if not (mousePos.X >= listPos.X and mousePos.X <= listPos.X + listSize.X and
                   mousePos.Y >= listPos.Y and mousePos.Y <= listPos.Y + listSize.Y) then
                closeDropdown()
            end
        end
    end)
    
    -- Очистка при удалении
    dropdownContainer.Destroying:Connect(function()
        if dropdownList then
            dropdownList:Destroy()
        end
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

-- MAIN TAB (с исправленным Anti Stun + Anti Ragdoll)
local function CreateMainContent()
    ClearContent()
    
    -- Speed Slider
    local speedLabel = CreateSpeedSlider()
    
    -- Speed Toggle
    local speedToggle, updateSpeedToggle = CreateToggle("SpeedHack", MainModule.SpeedHack.Enabled, function(enabled)
        MainModule.ToggleSpeedHack(enabled)
    end)
    speedToggle.LayoutOrder = 1
    
    -- Anti Stun QTE
    local antiStunToggle, updateAntiStunToggle = CreateToggle("Anti Stun QTE", MainModule.AutoQTE.AntiStunEnabled, function(enabled)
        MainModule.ToggleAntiStunQTE(enabled)
    end)
    antiStunToggle.LayoutOrder = 2
    
    -- Anti Stun + Anti Ragdoll (объединенная кнопка)
    local antiStunState = MainModule.Misc.BypassRagdollEnabled
    local antiStunToggle, updateAntiStunToggle = CreateToggle("Anti Stun + Anti Ragdoll", antiStunState, function(enabled)
        MainModule.ToggleBypassRagdoll(enabled)
    end)
    antiStunToggle.LayoutOrder = 3
    
    -- Instance Interact
    local instaInteractToggle, updateInstaInteractToggle = CreateToggle("Instance Interact", MainModule.Misc.InstaInteract, function(enabled)
        MainModule.ToggleInstaInteract(enabled)
    end)
    instaInteractToggle.LayoutOrder = 4
    
    -- No Cooldown Proximity
    local noCooldownToggle, updateNoCooldownToggle = CreateToggle("No Cooldown Proximity", MainModule.Misc.NoCooldownProximity, function(enabled)
        MainModule.ToggleNoCooldownProximity(enabled)
    end)
    noCooldownToggle.LayoutOrder = 5
    
    -- Unlock Dash
    local unlockDashToggle, updateUnlockDashToggle = CreateToggle("Unlock Dash", MainModule.Misc.UnlockDashEnabled, function(enabled)
        MainModule.ToggleUnlockDash(enabled)
    end)
    unlockDashToggle.LayoutOrder = 6
    
    -- Unlock Phantom Step
    local unlockPhantomToggle, updateUnlockPhantomToggle = CreateToggle("Unlock Phantom Step", MainModule.Misc.UnlockPhantomStepEnabled, function(enabled)
        MainModule.ToggleUnlockPhantomStep(enabled)
    end)
    unlockPhantomToggle.LayoutOrder = 7
    
    -- Teleport Buttons
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.LayoutOrder = 8
    tpUpBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportUp100()
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.LayoutOrder = 9
    tpDownBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportDown40()
    end)
    
    -- Noclip status
    local noclipLabel = CreateButton("Noclip: " .. MainModule.Noclip.Status)
    noclipLabel.LayoutOrder = 10
    noclipLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    noclipLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
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
        MainModule.ToggleESP(enabled)
    end)
    espToggle.LayoutOrder = 1
    
    -- ESP Players
    local espPlayersToggle, updateEspPlayersToggle = CreateToggle("ESP Players", MainModule.Misc.ESPPlayers, function(enabled)
        MainModule.Misc.ESPPlayers = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espPlayersToggle.LayoutOrder = 2
    
    -- ESP Hiders
    local espHidersToggle, updateEspHidersToggle = CreateToggle("ESP Hiders", MainModule.Misc.ESPHiders, function(enabled)
        MainModule.Misc.ESPHiders = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espHidersToggle.LayoutOrder = 3
    
    -- ESP Seekers
    local espSeekersToggle, updateEspSeekersToggle = CreateToggle("ESP Seekers", MainModule.Misc.ESPSeekers, function(enabled)
        MainModule.Misc.ESPSeekers = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espSeekersToggle.LayoutOrder = 4
    
    -- ESP Candies
    local espCandiesToggle, updateEspCandiesToggle = CreateToggle("ESP Candies", MainModule.Misc.ESPCandies, function(enabled)
        MainModule.Misc.ESPCandies = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espCandiesToggle.LayoutOrder = 5
    
    -- ESP Keys
    local espKeysToggle, updateEspKeysToggle = CreateToggle("ESP Keys", MainModule.Misc.ESPKeys, function(enabled)
        MainModule.Misc.ESPKeys = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espKeysToggle.LayoutOrder = 6
    
    -- ESP Doors
    local espDoorsToggle, updateEspDoorsToggle = CreateToggle("ESP Doors", MainModule.Misc.ESPDoors, function(enabled)
        MainModule.Misc.ESPDoors = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espDoorsToggle.LayoutOrder = 7
    
    -- ESP Guards
    local espGuardsToggle, updateEspGuardsToggle = CreateToggle("ESP Guards", MainModule.Misc.ESPGuards, function(enabled)
        MainModule.Misc.ESPGuards = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espGuardsToggle.LayoutOrder = 8
    
    -- ESP Highlight
    local espHighlightToggle, updateEspHighlightToggle = CreateToggle("ESP Highlight", MainModule.Misc.ESPHighlight, function(enabled)
        MainModule.Misc.ESPHighlight = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espHighlightToggle.LayoutOrder = 9
    
    -- ESP Distance
    local espDistanceToggle, updateEspDistanceToggle = CreateToggle("ESP Distance", MainModule.Misc.ESPDistance, function(enabled)
        MainModule.Misc.ESPDistance = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espDistanceToggle.LayoutOrder = 10
    
    -- ESP Boxes
    local espBoxesToggle, updateEspBoxesToggle = CreateToggle("ESP Boxes", MainModule.Misc.ESPBoxes, function(enabled)
        MainModule.Misc.ESPBoxes = enabled
        if MainModule.Misc.ESPEnabled then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espBoxesToggle.LayoutOrder = 11
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
        MainModule.ToggleRebel(enabled)
    end)
    rebelToggle.LayoutOrder = 2
end

-- RLGL TAB
local function CreateRLGLContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("TP TO END")
    tpEndBtn.LayoutOrder = 1
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToEnd()
    end)
    
    local tpStartBtn = CreateButton("TP TO START")
    tpStartBtn.LayoutOrder = 2
    tpStartBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToStart()
    end)
    
    local godModeToggle, updateGodModeToggle = CreateToggle("GodMode", MainModule.RLGL.GodMode, function(enabled)
        MainModule.ToggleGodMode(enabled)
    end)
    godModeToggle.LayoutOrder = 3
end

-- GUARDS TAB (исправленный)
local function CreateGuardsContent()
    ClearContent()
    
    -- Dropdown с высоким ZIndex
    local options = {"Circle", "Triangle", "Square"}
    local dropdown = CreateGuardsDropdown(options, MainModule.Guards.SelectedGuard, function(selected)
        MainModule.SetGuardType(selected)
    end)
    
    -- Spawn as Guard кнопка
    local spawnBtn = CreateButton("Spawn as Guard")
    spawnBtn.LayoutOrder = 2
    spawnBtn.MouseButton1Click:Connect(function()
        MainModule.SpawnAsGuard()
    end)
    
    -- Остальные переключатели
    local rapidFireToggle, updateRapidFireToggle = CreateToggle("Rapid Fire", MainModule.Guards.RapidFire, function(enabled)
        MainModule.ToggleRapidFire(enabled)
    end)
    rapidFireToggle.LayoutOrder = 3
    
    local infiniteAmmoToggle, updateInfiniteAmmoToggle = CreateToggle("Infinite Ammo", MainModule.Guards.InfiniteAmmo, function(enabled)
        MainModule.ToggleInfiniteAmmo(enabled)
    end)
    infiniteAmmoToggle.LayoutOrder = 4
    
    local hitboxToggle, updateHitboxToggle = CreateToggle("Hitbox Expander", MainModule.Guards.HitboxExpander, function(enabled)
        MainModule.ToggleHitboxExpander(enabled)
    end)
    hitboxToggle.LayoutOrder = 5
    
    local autoFarmToggle, updateAutoFarmToggle = CreateToggle("AutoFarm", MainModule.Guards.AutoFarm, function(enabled)
        MainModule.ToggleAutoFarm(enabled)
    end)
    autoFarmToggle.LayoutOrder = 6
end

-- DALGONA TAB
local function CreateDalgonaContent()
    ClearContent()
    
    local completeBtn = CreateButton("Complete Dalgona")
    completeBtn.LayoutOrder = 1
    completeBtn.MouseButton1Click:Connect(function()
        MainModule.CompleteDalgona()
    end)
    
    local lighterBtn = CreateButton("Free Lighter")
    lighterBtn.LayoutOrder = 2
    lighterBtn.MouseButton1Click:Connect(function()
        MainModule.FreeLighter()
    end)
end

-- HNS TAB
local function CreateHNSContent()
    ClearContent()
    
    -- Kill Aura
    local killAuraToggle, updateKillAuraToggle = CreateToggle("Kill Aura (Hiders)", MainModule.HNS.KillAuraEnabled, function(enabled)
        MainModule.ToggleKillAura(enabled)
    end)
    killAuraToggle.LayoutOrder = 1
    
    -- Kill Hiders
    local killHidersToggle, updateKillHidersToggle = CreateToggle("Kill Hiders", MainModule.HNS.KillSpikesEnabled, function(enabled)
        MainModule.ToggleKillSpikes(enabled)
    end)
    killHidersToggle.LayoutOrder = 2
    
    -- Disable Spikes (кнопка)
    local disableSpikesBtn = CreateButton("Disable Spikes")
    disableSpikesBtn.LayoutOrder = 3
    disableSpikesBtn.MouseButton1Click:Connect(function()
        local newState = not MainModule.HNS.DisableSpikesEnabled
        MainModule.ToggleDisableSpikes(newState)
        if newState then
            disableSpikesBtn.Text = "Disable Spikes (ON)"
            disableSpikesBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        else
            disableSpikesBtn.Text = "Disable Spikes"
            disableSpikesBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        end
    end)
    
    -- Teleport to Hider (кнопка)
    local tpToHiderBtn = CreateButton("Teleport to Hider")
    tpToHiderBtn.LayoutOrder = 4
    tpToHiderBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToHider()
    end)
    
    -- Auto Dodge
    local autoDodgeToggle, updateAutoDodgeToggle = CreateToggle("Auto Dodge", MainModule.HNS.AutoDodgeEnabled, function(enabled)
        MainModule.ToggleAutoDodge(enabled)
    end)
    autoDodgeToggle.LayoutOrder = 5
end

-- GLASS BRIDGE TAB
local function CreateGlassBridgeContent()
    ClearContent()
    
    -- Glass Vision
    local glassVisionToggle, updateGlassVisionToggle = CreateToggle("Glass Vision", MainModule.GlassBridge.GlassVisionEnabled, function(enabled)
        MainModule.ToggleGlassVision(enabled)
    end)
    glassVisionToggle.LayoutOrder = 1
    
    -- Anti Break
    local antiBreakToggle, updateAntiBreakToggle = CreateToggle("Anti Break", MainModule.GlassBridge.AntiBreakEnabled, function(enabled)
        MainModule.ToggleAntiBreak(enabled)
    end)
    antiBreakToggle.LayoutOrder = 2
    
    -- Anti Fall
    local antiFallToggle, updateAntiFallToggle = CreateToggle("Anti Fall", MainModule.GlassBridge.AntiFallEnabled, function(enabled)
        MainModule.ToggleAntiFall(enabled)
    end)
    antiFallToggle.LayoutOrder = 3
    
    -- Teleport to End (кнопка)
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.LayoutOrder = 4
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToGlassBridgeEnd()
    end)
end

-- TUG OF WAR TAB
local function CreateTugOfWarContent()
    ClearContent()
    
    local autoPullToggle, updateAutoPullToggle = CreateToggle("Auto Pull", MainModule.TugOfWar.AutoPull, function(enabled)
        MainModule.ToggleAutoPull(enabled)
    end)
    autoPullToggle.LayoutOrder = 1
end

-- JUMP ROPE TAB
local function CreateJumpRopeContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.LayoutOrder = 1
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToJumpRopeEnd()
    end)
    
    local deleteRopeBtn = CreateButton("Delete The Rope")
    deleteRopeBtn.LayoutOrder = 2
    deleteRopeBtn.MouseButton1Click:Connect(function()
        MainModule.DeleteJumpRope()
    end)
    
    local antiFallBtn = CreateButton("Anti Fall")
    antiFallBtn.LayoutOrder = 3
    antiFallBtn.MouseButton1Click:Connect(function()
        MainModule.ToggleJumpRopeAntiFall(true)
        antiFallBtn.Text = "Anti Fall (ON)"
        antiFallBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end)
end

-- SKY SQUID TAB
local function CreateSkySquidContent()
    ClearContent()
    
    local comingSoon = Instance.new("TextLabel")
    comingSoon.Size = UDim2.new(1, 0, 0, 40)
    comingSoon.BackgroundTransparency = 1
    comingSoon.Text = "Sky Squid Features Coming Soon"
    comingSoon.TextColor3 = Color3.fromRGB(200, 200, 200)
    comingSoon.TextSize = 16
    comingSoon.Font = Enum.Font.Gotham
    comingSoon.Parent = ContentScrolling
end

-- SETTINGS TAB
local function CreateSettingsContent()
    ClearContent()
    
    local creatorLabel = CreateButton("Creator: Creon")
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    creatorLabel.LayoutOrder = 1
    
    local versionLabel = CreateButton("Version: 2.1")
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.LayoutOrder = 2
    
    local executorLabel = CreateButton("Executor: " .. executorName)
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    executorLabel.LayoutOrder = 3
    
    local supportedLabel = CreateButton("Supported: " .. (isSupported and "YES" or "NO"))
    supportedLabel.TextXAlignment = Enum.TextXAlignment.Left
    supportedLabel.LayoutOrder = 4
    
    local positionLabel = CreateButton("Position: " .. MainModule.GetPlayerPosition())
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    positionLabel.LayoutOrder = 5
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.LayoutOrder = 6
    cleanupBtn.MouseButton1Click:Connect(function()
        MainModule.Cleanup()
        ScreenGui:Destroy()
    end)
    
    -- Обновление позиции
    game:GetService("RunService").Heartbeat:Connect(function()
        positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
    end)
end

-- Создание вкладок
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Settings"}
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
        if MainModule.Cleanup then
            MainModule.Cleanup()
        end
    end
end)

-- Отображение сообщения о загрузке
print("Creon X v2.1 loaded successfully")
if not isSupported then
    warn("Warning: Executor " .. executorName .. " is not officially supported")
else
    print("Executor " .. executorName .. " is supported")
end
