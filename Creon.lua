-- Creon X v2.6 (Winter Edition)
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
local SoundService = game:GetService("SoundService")
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

-- Флаг для предотвращения автоматического включения Bypass
local initializing = true

-- Переменные для отслеживания статуса AntiFall
local GlassBridgeAntiFallEnabled = false
local JumpRopeAntiFallEnabled = false
local SkySquidAntiFallEnabled = false

-- Переменная для Zone Kill
local ZoneKillEnabled = false

-- Переменные для биндов
local FlyHotkey = nil
local NoclipHotkey = nil
local KillauraHotkey = nil

-- Переменные для отслеживания выбора клавиш
local isChoosingFlyKey = false
local isChoosingNoclipKey = false
local isChoosingKillauraKey = false

-- GUI Creon X v2.6 (Winter Edition)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local MinimizeButton = Instance.new("TextButton")

-- Tab buttons container
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local ContentScrolling = Instance.new("ScrollingFrame")
local ContentLayout = Instance.new("UIListLayout")

-- Snow particles for winter theme
local SnowContainer = Instance.new("Frame")

-- Custom cursor for PC
local CustomCursor = Instance.new("ImageLabel")

-- Music player
local backgroundMusic
local musicPlaying = false

-- Кнопка для мобильных устройств (Delta Mobile)
local MobileOpenButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXv26"
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

-- Create snow effect (only for PC)
if not UIS.TouchEnabled then
    SnowContainer.Size = UDim2.new(1, 0, 1, 0)
    SnowContainer.BackgroundTransparency = 1
    SnowContainer.Parent = ScreenGui
    
    for i = 1, 50 do
        local snowflake = Instance.new("Frame")
        snowflake.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
        snowflake.Position = UDim2.new(0, math.random(0, 1000), 0, -math.random(20, 100))
        snowflake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        snowflake.BackgroundTransparency = 0.7
        snowflake.BorderSizePixel = 0
        snowflake.ZIndex = 0
        snowflake.Parent = SnowContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = snowflake
        
        -- Animate snowflake
        spawn(function()
            local speed = math.random(20, 50) / 100
            local sway = math.random(-50, 50)
            local startX = snowflake.Position.X.Offset
            
            while snowflake and snowflake.Parent do
                local xPos = startX + math.sin(tick() * 0.5) * sway
                snowflake.Position = UDim2.new(
                    0, xPos,
                    snowflake.Position.Y.Scale,
                    snowflake.Position.Y.Offset + speed
                )
                
                if snowflake.Position.Y.Offset > 600 then
                    snowflake.Position = UDim2.new(0, math.random(0, 1000), 0, -20)
                end
                wait(0.03)
            end
        end)
    end
end

-- Create custom cursor (only for PC)
if not UIS.TouchEnabled then
    CustomCursor.Size = UDim2.new(0, 32, 0, 32)
    CustomCursor.BackgroundTransparency = 1
    CustomCursor.Image = "rbxassetid://11128591779" -- Simple cursor image
    CustomCursor.ImageColor3 = Color3.fromRGB(255, 255, 255)
    CustomCursor.ZIndex = 1000
    CustomCursor.Parent = ScreenGui
    CustomCursor.Visible = false
    
    -- Update cursor position
    RunService.RenderStepped:Connect(function()
        if CustomCursor.Visible and not UIS.MouseIconEnabled then
            local mousePos = UIS:GetMouseLocation()
            CustomCursor.Position = UDim2.new(0, mousePos.X - 16, 0, mousePos.Y - 16)
        end
    end)
end

-- Основной фрейм
MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 35) -- Темно-синий зимний фон
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(80, 120, 180) -- Голубой обводка
mainStroke.Thickness = 2.5
mainStroke.Parent = MainFrame

-- TitleBar для перемещения
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 35, 60) -- Темно-синий
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

-- Gradient for title bar
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 60, 60)), -- Красный
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 120)), -- Светло-красный
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 60, 60)) -- Красный
})
titleGradient.Rotation = 90
titleGradient.Parent = TitleBar

TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "❄️ Creon X v2.6 ❄️"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка сворачивания (только для мобильных)
if UIS.TouchEnabled then
    MinimizeButton.Size = UDim2.new(0, 40, 0, 40)
    MinimizeButton.Position = UDim2.new(1, -45, 0.5, -20)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "✕"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 20
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = TitleBar

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MobileOpenButton.Visible = true
    end)
end

-- УВЕЛИЧИВАЕМ ШИРИНУ ЛЕВОЙ ПАНЕЛИ С ВКЛАДКАМИ
local TAB_PANEL_WIDTH = 200

-- Фрейм для кнопок вкладок
TabButtons.Size = UDim2.new(0, TAB_PANEL_WIDTH, 1, -40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 12)
tabCorner.Parent = TabButtons

-- ScrollingFrame для кнопок вкладок
local TabScrolling = Instance.new("ScrollingFrame")
TabScrolling.Size = UDim2.new(1, 0, 1, 0)
TabScrolling.BackgroundTransparency = 1
TabScrolling.BorderSizePixel = 0
TabScrolling.ScrollBarThickness = 4
TabScrolling.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 200)
TabScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScrolling.Parent = TabButtons

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 8)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabScrolling.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
end)
TabLayout.Parent = TabScrolling

-- Content Frame с прокруткой
ContentFrame.Size = UDim2.new(1, -TAB_PANEL_WIDTH, 1, -40)
ContentFrame.Position = UDim2.new(0, TAB_PANEL_WIDTH, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = ContentFrame

-- Scrolling Frame для контента
ContentScrolling.Size = UDim2.new(1, -15, 1, -15)
ContentScrolling.Position = UDim2.new(0, 7.5, 0, 7.5)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.ScrollBarThickness = 6
ContentScrolling.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 200)
ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScrolling.Parent = ContentFrame

ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)
ContentLayout.Parent = ContentScrolling

-- Кнопка для мобильных устройств (Delta Mobile)
if UIS.TouchEnabled then
    MobileOpenButton.Size = UDim2.new(0, 140, 0, 50)
    MobileOpenButton.Position = UDim2.new(0.5, -70, 0.2, 0)
    MobileOpenButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    MobileOpenButton.BorderSizePixel = 0
    MobileOpenButton.Text = "❄️ OPEN ❄️"
    MobileOpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileOpenButton.TextSize = 18
    MobileOpenButton.Font = Enum.Font.GothamBold
    MobileOpenButton.Parent = ScreenGui
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 12)
    mobileCorner.Parent = MobileOpenButton
    
    local mobileGradient = Instance.new("UIGradient")
    mobileGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 40, 40))
    })
    mobileGradient.Rotation = 90
    mobileGradient.Parent = MobileOpenButton
    
    MobileOpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
        MobileOpenButton.Visible = false
    end)
    
    -- Улучшенное перетаскивание кнопки OPEN для мобильных
    local mobileDragging = false
    local mobileDragStart, mobileStartPos
    local dragTween
    
    MobileOpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = true
            mobileDragStart = input.Position
            mobileStartPos = MobileOpenButton.Position
            MobileOpenButton.ZIndex = 10
            
            -- Анимация при касании
            if dragTween then dragTween:Cancel() end
            dragTween = TweenService:Create(MobileOpenButton, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 130, 0, 45)
            }):Play()
        end
    end)
    
    MobileOpenButton.InputChanged:Connect(function(input)
        if mobileDragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - mobileDragStart
            local newPosition = UDim2.new(
                mobileStartPos.X.Scale, 
                mobileStartPos.X.Offset + delta.X,
                mobileStartPos.Y.Scale, 
                mobileStartPos.Y.Offset + delta.Y
            )
            
            -- Ограничиваем позицию в пределах экрана
            local absSize = ScreenGui.AbsoluteSize
            local btnSize = MobileOpenButton.AbsoluteSize
            
            local minX = 0
            local maxX = absSize.X - btnSize.X
            local minY = 0
            local maxY = absSize.Y - btnSize.Y
            
            local xPos = math.clamp(newPosition.X.Offset, minX, maxX)
            local yPos = math.clamp(newPosition.Y.Offset, minY, maxY)
            
            MobileOpenButton.Position = UDim2.new(0, xPos, 0, yPos)
        end
    end)
    
    MobileOpenButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = false
            MobileOpenButton.ZIndex = 1
            
            -- Возвращаем размер
            if dragTween then dragTween:Cancel() end
            dragTween = TweenService:Create(MobileOpenButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 140, 0, 50)
            }):Play()
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

-- Функция для создания кнопок с зимним дизайном
local function CreateButton(text, isTitle)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 36)
    button.BackgroundColor3 = isTitle and Color3.fromRGB(40, 50, 80) or Color3.fromRGB(30, 40, 70)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = isTitle and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(220, 220, 255)
    button.TextSize = isTitle and 14 or 13
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = ContentScrolling
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 200)
    stroke.Thickness = 1.5
    stroke.Parent = button
    
    -- Gradient for button
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, button.BackgroundColor3),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(
            math.min(button.BackgroundColor3.R * 255 + 20, 255)/255,
            math.min(button.BackgroundColor3.G * 255 + 20, 255)/255,
            math.min(button.BackgroundColor3.B * 255 + 20, 255)/255
        ))
    })
    buttonGradient.Rotation = 90
    buttonGradient.Parent = button
    
    -- Анимация при наведении
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 70, 110),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(150, 200, 255)
        }):Play()
        
        if not UIS.TouchEnabled then
            UIS.MouseIconEnabled = false
            if CustomCursor then
                CustomCursor.Visible = true
            end
        end
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = isTitle and Color3.fromRGB(40, 50, 80) or Color3.fromRGB(30, 40, 70),
            TextColor3 = isTitle and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(220, 220, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(100, 150, 200)
        }):Play()
        
        if not UIS.TouchEnabled then
            UIS.MouseIconEnabled = true
            if CustomCursor then
                CustomCursor.Visible = false
            end
        end
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(20, 30, 60)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(50, 70, 110)
        }):Play()
    end)
    
    return button
end

-- Массив для отслеживания переключателей
local toggleElements = {}

-- Улучшенная функция для создания переключателей
local function CreateToggle(text, getEnabledFunction, callback, layoutOrder)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -10, 0, 40)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentScrolling
    toggleContainer.LayoutOrder = layoutOrder or 999
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 1, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = toggleContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggleFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 200)
    stroke.Thickness = 1.5
    stroke.Parent = toggleFrame
    
    -- Gradient для фона
    local frameGradient = Instance.new("UIGradient")
    frameGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 35, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 45, 75))
    })
    frameGradient.Rotation = 90
    frameGradient.Parent = toggleFrame
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.65, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 15, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = toggleFrame
    
    -- Переключатель
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Size = UDim2.new(0, 60, 0, 28)
    toggleBackground.Position = UDim2.new(1, -70, 0.5, -14)
    toggleBackground.BackgroundColor3 = Color3.fromRGB(60, 70, 100)
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleFrame
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 22, 0, 22)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Position = UDim2.new(0, 3, 0.5, -11)
    toggleCircle.Parent = toggleBackground
    
    -- Закругления
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 14)
    bgCorner.Parent = toggleBackground
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0, 11)
    circleCorner.Parent = toggleCircle
    
    local bgStroke = Instance.new("UIStroke")
    bgStroke.Color = Color3.fromRGB(120, 170, 220)
    bgStroke.Thickness = 2
    bgStroke.Parent = toggleBackground
    
    -- Gradient для переключателя
    local toggleGradient = Instance.new("UIGradient")
    toggleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 70, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 90, 120))
    })
    toggleGradient.Rotation = 90
    toggleGradient.Parent = toggleBackground
    
    -- Кнопка для переключения
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    -- Анимации для кнопки
    toggleButton.MouseEnter:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 45, 80)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(150, 200, 255)
        }):Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        local success, isEnabled = pcall(getEnabledFunction)
        if not success then isEnabled = false end
        
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = isEnabled and Color3.fromRGB(30, 50, 90) or Color3.fromRGB(25, 35, 60)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(100, 150, 200)
        }):Play()
    end)
    
    local function updateToggleVisual()
        if not toggleContainer or not toggleContainer.Parent then
            return
        end
        
        local success, isEnabled = pcall(getEnabledFunction)
        if not success then
            isEnabled = false
        end
        
        TweenService:Create(toggleBackground, TweenInfo.new(0.3), {
            BackgroundColor3 = isEnabled and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(180, 60, 60)
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.3), {
            Position = isEnabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        }):Play()
        
        TweenService:Create(toggleFrame, TweenInfo.new(0.3), {
            BackgroundColor3 = isEnabled and Color3.fromRGB(30, 50, 90) or Color3.fromRGB(25, 35, 60)
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
        
        -- Special handling for Spikes Kill
        if text == "Spikes Kill" then
            if newState then
                local hasKnife = MainModule.CheckKnifeInInventory()
                if not hasKnife then
                    textLabel.Text = "Spikes Kill [No Knife]"
                    textLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    task.wait(2)
                    newState = false
                    updateToggleVisual()
                    return
                else
                    textLabel.Text = "Spikes Kill"
                    textLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
                end
            end
        end
        
        if callback then
            callback(newState)
        end
        
        updateToggleVisual()
    end
    
    toggleButton.MouseButton1Click:Connect(toggleFunction)
    
    -- Сохраняем для обновлений
    table.insert(toggleElements, {
        container = toggleContainer,
        getEnabled = getEnabledFunction,
        callback = callback,
        textLabel = textLabel,
        updateVisual = updateToggleVisual
    })
    
    -- Инициализация состояния
    updateToggleVisual()
    
    return toggleContainer, toggleFunction, textLabel
end

-- Функция для обновления всех переключателей
local function UpdateAllToggles()
    for _, toggleData in pairs(toggleElements) do
        if toggleData.container and toggleData.container.Parent then
            toggleData.updateVisual()
        end
    end
end

-- Функция для создания кнопки бинда
local function CreateBindButton(labelText, currentKey, onBindChanged, layoutOrder)
    local bindContainer = Instance.new("Frame")
    bindContainer.Size = UDim2.new(1, -10, 0, 40)
    bindContainer.BackgroundTransparency = 1
    bindContainer.Parent = ContentScrolling
    bindContainer.LayoutOrder = layoutOrder or 999
    
    local bindFrame = Instance.new("Frame")
    bindFrame.Size = UDim2.new(1, 0, 1, 0)
    bindFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    bindFrame.BorderSizePixel = 0
    bindFrame.Parent = bindContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = bindFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 200)
    stroke.Thickness = 1.5
    stroke.Parent = bindFrame
    
    -- Gradient
    local frameGradient = Instance.new("UIGradient")
    frameGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 35, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 45, 75))
    })
    frameGradient.Rotation = 90
    frameGradient.Parent = bindFrame
    
    -- Текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Parent = bindFrame
    
    -- Кнопка бинда
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0.35, 0, 0.7, 0)
    bindBtn.Position = UDim2.new(0.52, 0, 0.15, 0)
    bindBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
    bindBtn.BorderSizePixel = 0
    bindBtn.Text = currentKey and currentKey.Name or "None"
    bindBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    bindBtn.TextSize = 12
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.AutoButtonColor = false
    bindBtn.Parent = bindFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = bindBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(100, 150, 200)
    btnStroke.Thickness = 1.5
    btnStroke.Parent = bindBtn
    
    -- Gradient для кнопки
    local btnGradient = Instance.new("UIGradient")
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 60, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 80, 120))
    })
    btnGradient.Rotation = 90
    btnGradient.Parent = bindBtn
    
    -- Функция обновления текста
    local function updateButtonText()
        bindBtn.Text = currentKey and currentKey.Name or "None"
    end
    
    -- Анимации для кнопки
    bindBtn.MouseEnter:Connect(function()
        TweenService:Create(bindBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 90, 140),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(150, 200, 255)
        }):Play()
        TweenService:Create(bindFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(35, 45, 80)
        }):Play()
    end)
    
    bindBtn.MouseLeave:Connect(function()
        TweenService:Create(bindBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 60, 100),
            TextColor3 = Color3.fromRGB(240, 240, 255)
        }):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(100, 150, 200)
        }):Play()
        TweenService:Create(bindFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(25, 35, 60)
        }):Play()
    end)
    
    -- Функция изменения бинда
    local function startKeyChange()
        bindBtn.Text = "[Press any key]"
        bindBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        
        local connection
        connection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                updateButtonText()
                bindBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
                
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
                bindBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        -- Если 3 секунды не выбрали клавишу - отменяем
        task.delay(3, function()
            if bindBtn.Text == "[Press any key]" then
                updateButtonText()
                bindBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end
    
    bindBtn.MouseButton1Click:Connect(startKeyChange)
    
    -- Автоматическое обновление текста
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

-- Функция для создания слайдера скорости (переименована в Faster Speed)
local function CreateSpeedSlider()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -10, 0, 60)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ContentScrolling
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 25)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Faster Speed: " .. (MainModule.SpeedHack and MainModule.SpeedHack.CurrentSpeed or 16)
    speedLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.Parent = sliderContainer
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, 0, 0, 22)
    sliderBackground.Position = UDim2.new(0, 0, 0, 30)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = sliderContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 11)
    corner.Parent = sliderBackground
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((MainModule.SpeedHack and MainModule.SpeedHack.CurrentSpeed or 16) / (MainModule.SpeedHack and MainModule.SpeedHack.MaxSpeed or 30), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 11)
    fillCorner.Parent = sliderFill
    
    -- Gradient для заполнения
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 220, 120))
    })
    fillGradient.Rotation = 90
    fillGradient.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 24, 0, 24)
    sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -12, 0, -1)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBackground
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    
    local function updateSpeed(value)
        if MainModule and MainModule.SetSpeed then
            local newSpeed = MainModule.SetSpeed(value)
            speedLabel.Text = "Faster Speed: " .. newSpeed
            sliderFill.Size = UDim2.new((newSpeed - (MainModule.SpeedHack and MainModule.SpeedHack.MinSpeed or 16)) / ((MainModule.SpeedHack and MainModule.SpeedHack.MaxSpeed or 30) - (MainModule.SpeedHack and MainModule.SpeedHack.MinSpeed or 16)), 0, 1, 0)
            sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -12, 0, -1)
        end
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
        TweenService:Create(sliderButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 28, 0, 28)
        }):Play()
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
            TweenService:Create(sliderButton, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 24, 0, 24)
            }):Play()
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
    radiusLabel.Size = UDim2.new(1, 0, 0, 25)
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.Text = "Killaura Radius: " .. (MainModule.Killaura and MainModule.Killaura.Radius or 30)
    radiusLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    radiusLabel.TextSize = 14
    radiusLabel.Font = Enum.Font.GothamBold
    radiusLabel.Parent = sliderContainer
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, 0, 0, 22)
    sliderBackground.Position = UDim2.new(0, 0, 0, 30)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = sliderContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 11)
    corner.Parent = sliderBackground
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(((MainModule.Killaura and MainModule.Killaura.Radius or 30) - 15) / ((MainModule.Killaura and MainModule.Killaura.MaxRadius or 50) - 15), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 11)
    fillCorner.Parent = sliderFill
    
    -- Gradient для заполнения
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
    })
    fillGradient.Rotation = 90
    fillGradient.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 24, 0, 24)
    sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -12, 0, -1)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBackground
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    
    local function updateRadius(value)
        if MainModule and MainModule.SetKillauraRadius then
            local newRadius = MainModule.SetKillauraRadius(value)
            radiusLabel.Text = "Killaura Radius: " .. newRadius
            sliderFill.Size = UDim2.new((newRadius - 15) / ((MainModule.Killaura and MainModule.Killaura.MaxRadius or 50) - 15), 0, 1, 0)
            sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -12, 0, -1)
        end
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
        TweenService:Create(sliderButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 28, 0, 28)
        }):Play()
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
            TweenService:Create(sliderButton, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 24, 0, 24)
            }):Play()
        end
    end)
    
    return radiusLabel
end

-- Функции для создания контента вкладок
local function ClearContent()
    toggleElements = {}
    for _, child in pairs(ContentScrolling:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

-- MAIN TAB
local function CreateMainContent()
    ClearContent()
    
    -- Speed Slider (переименован в Faster Speed)
    local speedLabel = CreateSpeedSlider()
    speedLabel.LayoutOrder = 1
    
    -- Speed Toggle (переименован в Faster Speed)
    CreateToggle("Faster Speed", function() 
        return MainModule and MainModule.SpeedHack and MainModule.SpeedHack.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleSpeedHack then
            MainModule.ToggleSpeedHack(enabled)
        elseif MainModule and MainModule.SpeedHack then
            MainModule.SpeedHack.Enabled = enabled
        end
    end, 2)
    
    -- Fly Toggle
    CreateToggle("Fly", function() 
        return MainModule and MainModule.Fly and MainModule.Fly.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleFly then
            MainModule.ToggleFly(enabled)
        elseif MainModule and MainModule.Fly then
            MainModule.Fly.Enabled = enabled
        end
    end, 3)
    
    -- Fly Bind
    local flyBindContainer, flyBindBtn = CreateBindButton("Fly Bind", FlyHotkey, function(newKey)
        FlyHotkey = newKey
        setupFlyListener()
    end, 4)
    
    -- Noclip Toggle
    CreateToggle("Noclip", function() 
        return MainModule and MainModule.Noclip and MainModule.Noclip.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleNoclip then
            MainModule.ToggleNoclip(enabled)
        elseif MainModule and MainModule.Noclip then
            MainModule.Noclip.Enabled = enabled
        end
    end, 5)
    
    -- Noclip Bind
    local noclipBindContainer, noclipBindBtn = CreateBindButton("Noclip Bind", NoclipHotkey, function(newKey)
        NoclipHotkey = newKey
        setupNoclipListener()
    end, 6)
    
    -- Free Dash (only player)
    CreateToggle("Free Dash (only player)", function() 
        return MainModule and MainModule.FreeDash and MainModule.FreeDash.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleFreeDash then
            MainModule.ToggleFreeDash(enabled)
        elseif MainModule and MainModule.FreeDash then
            MainModule.FreeDash.Enabled = enabled
        end
    end, 7)
    
    -- Anti Stun QTE
    CreateToggle("Anti Stun QTE", function() 
        return MainModule and MainModule.AutoQTE and MainModule.AutoQTE.AntiStunEnabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleAntiStunQTE then
            MainModule.ToggleAntiStunQTE(enabled)
        elseif MainModule and MainModule.AutoQTE then
            MainModule.AutoQTE.AntiStunEnabled = enabled
        end
    end, 8)
    
    -- Anti Stun + Anti Ragdoll
    CreateToggle("Anti Stun + Anti Ragdoll", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.BypassRagdollEnabled or false
    end, function(enabled)
        if initializing then
            enabled = false
            print("Bypass Ragdoll принудительно отключен при инициализации")
        end
        
        if MainModule and MainModule.ToggleBypassRagdoll then
            MainModule.ToggleBypassRagdoll(enabled)
        elseif MainModule and MainModule.Misc then
            MainModule.Misc.BypassRagdollEnabled = enabled
        end
    end, 9, true)
    
    -- Instance Interact
    CreateToggle("Instance Interact", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.InstaInteract or false
    end, function(enabled)
        if MainModule and MainModule.ToggleInstaInteract then
            MainModule.ToggleInstaInteract(enabled)
        elseif MainModule and MainModule.Misc then
            MainModule.Misc.InstaInteract = enabled
        end
    end, 10)
    
    -- No Cooldown Proximity
    CreateToggle("No Cooldown Proximity", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.NoCooldownProximity or false
    end, function(enabled)
        if MainModule and MainModule.ToggleNoCooldownProximity then
            MainModule.ToggleNoCooldownProximity(enabled)
        elseif MainModule and MainModule.Misc then
            MainModule.Misc.NoCooldownProximity = enabled
        end
    end, 11)
    
    -- Teleport Buttons
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.LayoutOrder = 12
    tpUpBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportUp100 then
            MainModule.TeleportUp100()
        end
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.LayoutOrder = 13
    tpDownBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.TeleportDown40 then
            MainModule.TeleportDown40()
        end
    end)
    
    -- Position display
    local positionLabel = CreateButton("Position: " .. (MainModule and MainModule.GetPlayerPosition and MainModule.GetPlayerPosition() or "0,0,0"))
    positionLabel.LayoutOrder = 14
    positionLabel.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
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
    local killauraTitle = CreateButton("KILLAURA", true)
    killauraTitle.LayoutOrder = 1
    
    -- Killaura Radius Slider
    local radiusLabel = CreateKillauraRadiusSlider()
    radiusLabel.LayoutOrder = 2
    
    -- Killaura Toggle
    CreateToggle("Killaura", function() 
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
    end, 3)
    
    -- Killaura Bind
    local killauraBindContainer, killauraBindBtn = CreateBindButton("Killaura Bind", KillauraHotkey, function(newKey)
        KillauraHotkey = newKey
        setupKillauraListener()
    end, 4)
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
    
    local rebelTitle = CreateButton("REBEL", true)
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
    
    -- Simple Guard type selector
    local guardSelectorBtn = CreateButton("Guard Type: " .. (MainModule.Guards and MainModule.Guards.SelectedGuard or "Circle"))
    guardSelectorBtn.LayoutOrder = 1
    guardSelectorBtn.MouseButton1Click:Connect(function()
        local guardTypes = {"Circle", "Triangle", "Square"}
        local current = MainModule.Guards and MainModule.Guards.SelectedGuard or "Circle"
        local index = table.find(guardTypes, current) or 1
        local nextIndex = (index % #guardTypes) + 1
        local newType = guardTypes[nextIndex]
        
        if MainModule and MainModule.SetGuardType then
            MainModule.SetGuardType(newType)
        elseif MainModule and MainModule.Guards then
            MainModule.Guards.SelectedGuard = newType
        end
        guardSelectorBtn.Text = "Guard Type: " .. newType
    end)
    
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
    
    -- Hitbox Expander
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
            MainModule.ToggleSpikesKill(enabled)
        elseif MainModule and MainModule.SpikesKillFeature then
            MainModule.SpikesKillFeature.Enabled = enabled
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
            teleportToHiderBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
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
            glassEspBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            task.wait(1)
            glassEspBtn.Text = "Glass ESP"
            glassEspBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
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
    
    -- AntiFall Toggle
    CreateToggle("AntiFall", function() 
        return JumpRopeAntiFallEnabled
    end, function(enabled)
        JumpRopeAntiFallEnabled = enabled
        if enabled then
            if MainModule and MainModule.CreateJumpRopeAntiFall then
                MainModule.CreateJumpRopeAntiFall()
            end
        else
            if MainModule and MainModule.RemoveJumpRopeAntiFall then
                MainModule.RemoveJumpRopeAntiFall()
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
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
                task.wait(1)
                deleteRopeBtn.Text = "Delete The Rope"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
            else
                deleteRopeBtn.Text = "Rope Not Found"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
                task.wait(1)
                deleteRopeBtn.Text = "Delete The Rope"
                deleteRopeBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
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
    
    -- AntiFall Toggle
    CreateToggle("AntiFall", function() 
        return SkySquidAntiFallEnabled
    end, function(enabled)
        SkySquidAntiFallEnabled = enabled
        if enabled then
            if MainModule and MainModule.CreateSkySquidAntiFall then
                MainModule.CreateSkySquidAntiFall()
            end
        else
            if MainModule and MainModule.RemoveSkySquidAntiFall then
                MainModule.RemoveSkySquidAntiFall()
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
    
    local titleLabel = CreateButton("LAST DINNER", true)
    titleLabel.LayoutOrder = 1
    
    -- Zone Kill Toggle
    CreateToggle("Zone Kill", function() 
        return ZoneKillEnabled
    end, function(enabled)
        ZoneKillEnabled = enabled
        if enabled then
            print("Zone Kill активирован")
        else
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
    
    local versionLabel = CreateButton("Version: 2.6 (Winter Edition)")
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    versionLabel.LayoutOrder = 2
    
    local executorLabel = CreateButton("Executor: " .. executorName)
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    executorLabel.LayoutOrder = 3
    
    local supportedLabel = CreateButton("Supported: " .. (isSupported and "YES" or "NO"))
    supportedLabel.TextXAlignment = Enum.TextXAlignment.Left
    supportedLabel.LayoutOrder = 4
    
    -- Music Toggle
    CreateToggle("Music", function()
        return musicPlaying
    end, function(enabled)
        musicPlaying = enabled
        if enabled then
            PlayMusic()
        else
            StopMusic()
        end
    end, 5)
    
    local positionLabel = CreateButton("Position: " .. (MainModule and MainModule.GetPlayerPosition and MainModule.GetPlayerPosition() or "0,0,0"))
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    positionLabel.LayoutOrder = 6
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.LayoutOrder = 7
    cleanupBtn.MouseButton1Click:Connect(function()
        if MainModule and MainModule.Cleanup then
            MainModule.Cleanup()
        end
        StopMusic()
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

-- Создание вкладок
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Last Dinner", "Settings"}
local tabButtons = {}

local TAB_BUTTON_WIDTH_PERCENT = 0.95

for i, name in pairs(tabs) do
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(TAB_BUTTON_WIDTH_PERCENT, 0, 0, 38)
    buttonContainer.Position = UDim2.new((1 - TAB_BUTTON_WIDTH_PERCENT)/2, 0, 0, (i-1)*42 + 10)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.LayoutOrder = i
    buttonContainer.Parent = TabScrolling
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(220, 220, 255)
    button.TextSize = 13
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 200)
    stroke.Thickness = 1.5
    stroke.Parent = button
    
    -- Gradient
    local btnGradient = Instance.new("UIGradient")
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 40, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 50, 85))
    })
    btnGradient.Rotation = 90
    btnGradient.Parent = button
    
    -- Анимация для кнопки вкладки
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 70, 110),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(150, 200, 255)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 40, 70),
            TextColor3 = Color3.fromRGB(220, 220, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Color = Color3.fromRGB(100, 150, 200)
        }):Play()
    end)
    
    tabButtons[name] = button
    
    local function ActivateTab()
        for tabName, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
            btn.TextColor3 = Color3.fromRGB(220, 220, 255)
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(30, 40, 70)
            }):Play()
        end
        
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 60, 60),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
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
        task.wait(0.05)
        UpdateAllToggles()
    end
    
    button.MouseButton1Click:Connect(ActivateTab)
end

-- Слушатели для горячих клавиш
local flyHotkeyConnection
local noclipHotkeyConnection
local killauraHotkeyConnection

-- Функция для настройки слушателя Fly
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

-- Функция для настройки слушателя Noclip
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

-- Функция для настройки слушателя Killaura
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
local function updateHotkeyListeners()
    setupFlyListener()
    setupNoclipListener()
    setupKillauraListener()
end

-- Установка начальных слушателей
updateHotkeyListeners()

-- Управление мышкой для ПК
local function updateMouseCursor()
    if not UIS.TouchEnabled then
        -- Показываем/скрываем кастомный курсор
        UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                if MainFrame.Visible then
                    UIS.MouseIconEnabled = false
                    if CustomCursor then
                        CustomCursor.Visible = true
                    end
                else
                    UIS.MouseIconEnabled = true
                    if CustomCursor then
                        CustomCursor.Visible = false
                    end
                end
            end
        end)
        
        -- Скрываем курсор при закрытии меню
        MainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if not MainFrame.Visible then
                UIS.MouseIconEnabled = true
                if CustomCursor then
                    CustomCursor.Visible = false
                end
            end
        end)
    end
end

updateMouseCursor()

-- Музыкальные функции
local function PlayMusic()
    if backgroundMusic then
        backgroundMusic:Destroy()
    end
    
    backgroundMusic = Instance.new("Sound")
    backgroundMusic.SoundId = "rbxassetid://566507830"
    backgroundMusic.Volume = 0.3
    backgroundMusic.Looped = true
    backgroundMusic.Parent = SoundService
    
    backgroundMusic.Ended:Connect(function()
        if musicPlaying then
            backgroundMusic:Play()
        end
    end)
    
    backgroundMusic:Play()
    print("Music started")
end

local function StopMusic()
    if backgroundMusic then
        backgroundMusic:Stop()
        backgroundMusic:Destroy()
        backgroundMusic = nil
    end
    print("Music stopped")
end

-- Автоматическое обновление GUI состояния каждые 0.5 секунды
local guiUpdateConnection
guiUpdateConnection = RunService.Heartbeat:Connect(function()
    UpdateAllToggles()
    task.wait(0.5)
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
    tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    tabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- Создаем Main контент
CreateMainContent()

-- Завершаем инициализацию
task.spawn(function()
    task.wait(1)
    initializing = false
    print("Инициализация завершена")
    
    -- Автоматически включаем музыку
    musicPlaying = true
    PlayMusic()
end)

-- Очистка при удалении GUI
ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        if MainModule and MainModule.Cleanup then
            MainModule.Cleanup()
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
        StopMusic()
    end
end)

-- Bypass Anti-Kick система
local function LoadAntiKick()
    if getgenv().ED_AntiKick then
        return
    end

    local Players, LocalPlayer, StarterGui = game:GetService("Players"), game:GetService("Players").LocalPlayer, game:GetService("StarterGui")
    
    getgenv().ED_AntiKick = {
        Enabled = true,
        SendNotifications = true,
        CheckCaller = true
    }

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

    local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", function(...)
        local self, message = ...
        local method = getnamecallmethod()
        
        if ((getgenv().ED_AntiKick.CheckCaller and not checkcaller()) or true) and self == LocalPlayer and method == "Kick" and ED_AntiKick.Enabled then
            return
        end

        return OldNamecall(...)
    end)

    local OldFunction; OldFunction = hookfunction(LocalPlayer.Kick, function(...)
        local self, Message = ...

        if ((ED_AntiKick.CheckCaller and not checkcaller()) or true) and self == LocalPlayer and ED_AntiKick.Enabled then
            return
        end
        
        return OldFunction(...)
    end)
end

-- Загружаем Anti-Kick систему
LoadAntiKick()

-- Отображение сообщения о загрузке
print("❄️ Creon X v2.6 (Winter Edition) loaded successfully ❄️")
print("Fly Hotkey: " .. (FlyHotkey and FlyHotkey.Name or "Not set"))
print("Noclip Hotkey: " .. (NoclipHotkey and NoclipHotkey.Name or "Not set"))
print("Killaura Hotkey: " .. (KillauraHotkey and KillauraHotkey.Name or "Not set"))
if not isSupported then
    warn("Warning: Executor " .. executorName .. " is not officially supported")
else
    print("Executor " .. executorName .. " is supported")
end
