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

-- Цвета с серыми тонами для более элегантного дизайна
local COLORS = {
    RED = Color3.fromRGB(220, 20, 60),
    GREEN = Color3.fromRGB(46, 204, 113),
    GOLD = Color3.fromRGB(241, 196, 15),
    BLUE = Color3.fromRGB(52, 152, 219),
    WHITE = Color3.fromRGB(236, 240, 241),
    SNOW = Color3.fromRGB(255, 255, 255),
    DARK_GRAY = Color3.fromRGB(20, 25, 30),
    MEDIUM_GRAY = Color3.fromRGB(40, 45, 55),
    LIGHT_GRAY = Color3.fromRGB(60, 65, 75),
    SILVER = Color3.fromRGB(180, 185, 195)
}

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

-- Устанавливаем стандартную скорость на 39 вместо 16
if MainModule and MainModule.SpeedHack then
    MainModule.SpeedHack.CurrentSpeed = 39
end

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

-- Переменные для биндов (берем из MainModule или устанавливаем по умолчанию)
local FlyHotkey = MainModule.Fly.DefaultHotkey or Enum.KeyCode.X
local NoclipHotkey = MainModule.Noclip.DefaultHotkey or Enum.KeyCode.V
local KillauraHotkey = MainModule.Killaura.DefaultHotkey or Enum.KeyCode.C
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

-- Снежный эффект
local SnowContainer = Instance.new("Frame")
local SnowParticles = {}

-- Кастомная мышка (крестик)
local CustomCursor = Instance.new("ImageLabel")

-- Кнопка для мобильных устройств (Delta Mobile)
local MobileOpenButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXv25_Christmas"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

-- Размеры GUI
local GUI_WIDTH = 860
local GUI_HEIGHT = 595
local MOBILE_SCALE = 0.6

-- Для мобильных устройств уменьшаем размер
if UIS.TouchEnabled then
    GUI_WIDTH = 860 * MOBILE_SCALE
    GUI_HEIGHT = 595 * MOBILE_SCALE
end

-- Основной фрейм
MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
MainFrame.BackgroundColor3 = COLORS.DARK_GRAY
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Visible = false -- Скрываем по умолчанию

-- Градиентный фон с серыми тонами
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.DARK_GRAY),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 35, 45)),
    ColorSequenceKeypoint.new(1, COLORS.DARK_GRAY)
})
gradient.Rotation = 45
gradient.Parent = MainFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.RED
mainStroke.Thickness = 2
mainStroke.Transparency = 0.3
mainStroke.Parent = MainFrame

-- TitleBar с обновленным дизайном
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.RED),
    ColorSequenceKeypoint.new(0.5, COLORS.GOLD),
    ColorSequenceKeypoint.new(1, COLORS.RED)
})
titleGradient.Rotation = 0
titleGradient.Parent = TitleBar

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎄 Creon X v2.5 🎅"
TitleLabel.TextColor3 = COLORS.WHITE
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextStrokeColor3 = COLORS.RED
TitleLabel.TextStrokeTransparency = 0.5
TitleLabel.Parent = TitleBar

-- Кнопка сворачивания (только для мобильных)
if UIS.TouchEnabled then
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -35, 0.5, -15)
    MinimizeButton.BackgroundColor3 = COLORS.MEDIUM_GRAY
    MinimizeButton.BackgroundTransparency = 0.3
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "❌"
    MinimizeButton.TextColor3 = COLORS.WHITE
    MinimizeButton.TextSize = 14
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = TitleBar

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MobileOpenButton.Visible = true
        if CustomCursor then
            CustomCursor.Visible = false
        end
        -- Убираем снег при закрытии GUI
        if SnowContainer then
            SnowContainer.Visible = false
        end
    end)
end

-- УВЕЛИЧИВАЕМ ШИРИНУ ЛЕВОЙ ПАНЕЛИ С ВКЛАДКАМИ
local TAB_PANEL_WIDTH = 200

-- Фрейм для кнопок вкладок с прокруткой
TabButtons.Size = UDim2.new(0, TAB_PANEL_WIDTH, 1, -40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundColor3 = COLORS.LIGHT_GRAY
TabButtons.BackgroundTransparency = 0.3
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 12)
tabCorner.Parent = TabButtons

-- ScrollingFrame для кнопок вкладок (для мобильных)
local TabScrolling = Instance.new("ScrollingFrame")
TabScrolling.Size = UDim2.new(1, 0, 1, 0)
TabScrolling.BackgroundTransparency = 1
TabScrolling.BorderSizePixel = 0
TabScrolling.ScrollBarThickness = 4
TabScrolling.ScrollBarImageColor3 = COLORS.RED
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
ContentFrame.BackgroundColor3 = COLORS.MEDIUM_GRAY
ContentFrame.BackgroundTransparency = 0.2
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
ContentScrolling.ScrollBarImageColor3 = COLORS.RED
ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScrolling.Parent = ContentFrame

ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)
ContentLayout.Parent = ContentScrolling

-- Кнопка для мобильных устройств (Delta Mobile) - УМЕНЬШЕНА И ОБНОВЛЕНА
if UIS.TouchEnabled then
    MobileOpenButton.Size = UDim2.new(0, 100, 0, 40) -- Уменьшена
    MobileOpenButton.BackgroundColor3 = COLORS.MEDIUM_GRAY
    MobileOpenButton.BackgroundTransparency = 0.2
    MobileOpenButton.BorderSizePixel = 0
    MobileOpenButton.Text = "🎮 OPEN"
    MobileOpenButton.TextColor3 = COLORS.WHITE
    MobileOpenButton.TextSize = 14
    MobileOpenButton.Font = Enum.Font.GothamBold
    MobileOpenButton.Parent = ScreenGui
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 8)
    mobileCorner.Parent = MobileOpenButton
    
    local mobileStroke = Instance.new("UIStroke")
    mobileStroke.Color = COLORS.GOLD
    mobileStroke.Thickness = 2
    mobileStroke.Parent = MobileOpenButton
    
    -- Делаем кнопку передвижной на мобильных устройствах
    local mobileDragging = false
    local mobileDragInput, mobileDragStart, mobileStartPos
    
    local function updateMobileDrag(input)
        local delta = input.Position - mobileDragStart
        MobileOpenButton.Position = UDim2.new(
            mobileStartPos.X.Scale, 
            mobileStartPos.X.Offset + delta.X, 
            mobileStartPos.Y.Scale, 
            mobileStartPos.Y.Offset + delta.Y
        )
    end
    
    MobileOpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = true
            mobileDragStart = input.Position
            mobileStartPos = MobileOpenButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mobileDragging = false
                end
            end)
        end
    end)
    
    MobileOpenButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            mobileDragInput = input
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == mobileDragInput and mobileDragging then
            updateMobileDrag(input)
        end
    end)
    
    MobileOpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
        MobileOpenButton.Visible = false
        
        -- Показываем снег при открытии GUI
        if SnowContainer then
            SnowContainer.Visible = true
        end
    end)
    
    MobileOpenButton.Visible = true
    
    -- Устанавливаем начальную позицию (верхний правый угол)
    MobileOpenButton.Position = UDim2.new(1, -110, 0, 20)
else
    MainFrame.Visible = true
    
    -- Для ПК: показываем снег сразу
    task.spawn(function()
        task.wait(0.5)
        if SnowContainer then
            SnowContainer.Visible = true
        end
    end)
end

-- Кастомная мышка (крестик) - только для ПК
if not UIS.TouchEnabled then
    CustomCursor.Name = "CustomCursor"
    CustomCursor.Size = UDim2.new(0, 32, 0, 32) -- Средний размер
    CustomCursor.BackgroundTransparency = 1
    CustomCursor.Image = "rbxassetid://10747375826" -- Простой плюсик (будет использован как крестик)
    CustomCursor.ImageColor3 = COLORS.RED
    CustomCursor.ImageTransparency = 0
    CustomCursor.Visible = false
    CustomCursor.ZIndex = 10000
    CustomCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    CustomCursor.Parent = ScreenGui
    
    -- Делаем крестик из плюсика (поворачиваем на 45 градусов)
    CustomCursor.Rotation = 45
    
    -- Добавляем эффект свечения
    local glow = Instance.new("UIGradient")
    glow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.RED),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 100)),
        ColorSequenceKeypoint.new(1, COLORS.RED)
    })
    glow.Rotation = 90
    glow.Enabled = true
    glow.Parent = CustomCursor
    
    -- Обновление позиции кастомного курсора
    local lastMousePos = Vector2.new(0, 0)
    
    RunService.RenderStepped:Connect(function()
        if MainFrame.Visible and not UIS.TouchEnabled then
            local mousePos = UIS:GetMouseLocation()
            
            -- Плавное следование за мышкой
            local smoothPos = mousePos:Lerp(lastMousePos, 0.3)
            CustomCursor.Position = UDim2.new(0, smoothPos.X, 0, smoothPos.Y)
            CustomCursor.Visible = true
            
            lastMousePos = smoothPos
        else
            CustomCursor.Visible = false
        end
    end)
end

-- Снежный эффект (видим только при открытом GUI)
SnowContainer.Size = UDim2.new(1, 0, 1, 0)
SnowContainer.BackgroundTransparency = 1
SnowContainer.Visible = false -- Скрываем по умолчанию
SnowContainer.ZIndex = 0
SnowContainer.Parent = ScreenGui

-- Функция для создания снежинок
local function createSnowflakes()
    for i = 1, 30 do
        local snowflake = Instance.new("TextLabel")
        snowflake.Size = UDim2.new(0, 10, 0, 10)
        snowflake.Position = UDim2.new(0, math.random(0, 1000), 0, math.random(-100, 0))
        snowflake.BackgroundTransparency = 1
        snowflake.Text = "❄"
        snowflake.TextColor3 = COLORS.SNOW
        snowflake.TextSize = math.random(12, 20)
        snowflake.TextTransparency = 0.7
        snowflake.ZIndex = 0
        snowflake.Parent = SnowContainer
        
        table.insert(SnowParticles, {
            object = snowflake,
            speed = math.random(20, 50),
            sway = math.random(-10, 10) / 100
        })
    end
end

-- Создаем снежинки
createSnowflakes()

-- Анимация снега
local snowConnection
snowConnection = RunService.RenderStepped:Connect(function(deltaTime)
    if SnowContainer and SnowContainer.Visible then
        for _, snowflake in ipairs(SnowParticles) do
            if snowflake.object and snowflake.object.Parent then
                local currentPos = snowflake.object.Position
                local newY = currentPos.Y.Offset + snowflake.speed * deltaTime
                local newX = currentPos.X.Offset + snowflake.sway * 10
                
                if newY > 1000 then
                    newY = -50
                    newX = math.random(0, 1000)
                end
                
                if newX < 0 then newX = 1000 end
                if newX > 1000 then newX = 0 end
                
                snowflake.object.Position = UDim2.new(0, newX, 0, newY)
                snowflake.object.Rotation = snowflake.object.Rotation + 0.5
            end
        end
    end
end)

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

-- Улучшенная функция для создания кнопок
local function CreateButton(text, isTitle)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, isTitle and 40 or 36)
    button.BackgroundColor3 = isTitle and COLORS.LIGHT_GRAY or COLORS.MEDIUM_GRAY
    button.BackgroundTransparency = isTitle and 0.3 or 0.4
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = isTitle and COLORS.GOLD or COLORS.WHITE
    button.TextSize = isTitle and 14 or 13
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = false
    button.TextStrokeColor3 = isTitle and COLORS.RED or Color3.new(0, 0, 0)
    button.TextStrokeTransparency = isTitle and 0.5 or 0.8
    button.Parent = ContentScrolling
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = isTitle and COLORS.GOLD :Lerp(COLORS.SILVER, 0.5) or COLORS.RED :Lerp(COLORS.SILVER, 0.3)
    stroke.Thickness = isTitle and 1.5 or 1.2
    stroke.Transparency = 0.3
    stroke.Parent = button
    
    -- Анимация при наведении
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = isTitle and 0.2 or 0.3,
            TextColor3 = isTitle and COLORS.WHITE :Lerp(COLORS.GOLD, 0.5) or COLORS.GOLD
        }):Play()
        TweenService:Create(button.UIStroke, TweenInfo.new(0.2), {
            Transparency = 0.1
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = isTitle and 0.3 or 0.4,
            TextColor3 = isTitle and COLORS.GOLD or COLORS.WHITE
        }):Play()
        TweenService:Create(button.UIStroke, TweenInfo.new(0.2), {
            Transparency = 0.3
        }):Play()
    end)
    
    return button
end

-- Улучшенная функция для создания переключателей
local toggleElements = {}
local function CreateToggle(text, getEnabledFunction, callback, layoutOrder)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -10, 0, 36)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentScrolling
    toggleContainer.LayoutOrder = layoutOrder or 999
    
    -- Сохраняем ссылку для обновлений
    table.insert(toggleElements, {
        container = toggleContainer,
        getEnabled = getEnabledFunction,
        callback = callback,
        text = text
    })
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = COLORS.WHITE
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0.8
    textLabel.Parent = toggleContainer
    
    -- Переключатель с обновленным дизайном
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Size = UDim2.new(0, 54, 0, 26)
    toggleBackground.Position = UDim2.new(1, -56, 0.5, -13)
    toggleBackground.BackgroundColor3 = COLORS.LIGHT_GRAY
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleContainer
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 22, 0, 22)
    toggleCircle.BackgroundColor3 = COLORS.WHITE
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Position = UDim2.new(0, 2, 0.5, -11)
    toggleCircle.Parent = toggleBackground
    
    -- Закругления
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(1, 0)
    corner1.Parent = toggleBackground
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(1, 0)
    corner2.Parent = toggleCircle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.SILVER
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
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
            BackgroundColor3 = isEnabled and COLORS.GREEN :Lerp(COLORS.SILVER, 0.3) or COLORS.LIGHT_GRAY
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
            Position = isEnabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11),
            BackgroundColor3 = isEnabled and COLORS.GOLD :Lerp(COLORS.WHITE, 0.5) or COLORS.WHITE
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
        
        -- Специальная обработка для Spikes Kill
        if text == "Spikes Kill" and newState then
            local hasKnife = MainModule.CheckKnifeInInventory()
            if not hasKnife then
                if game:GetService("StarterGui") then
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Spikes Kill",
                        Text = "Knife not found!",
                        Duration = 3
                    })
                end
                newState = false
                updateToggleVisual()
                return
            end
        end
        
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
                    TweenService:Create(toggleBackground, TweenInfo.new(0.1), {
                        BackgroundColor3 = isEnabled and COLORS.GREEN :Lerp(COLORS.SILVER, 0.3) or COLORS.LIGHT_GRAY
                    }):Play()
                    
                    local toggleCircle = toggleBackground:FindFirstChildWhichIsA("Frame")
                    if toggleCircle then
                        TweenService:Create(toggleCircle, TweenInfo.new(0.1), {
                            Position = isEnabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
                        }):Play()
                    end
                end
            end
        end
    end
end

-- Улучшенная функция для создания кнопки бинда
local function CreateBindButton(labelText, currentKey, onBindChanged, layoutOrder)
    local bindContainer = Instance.new("Frame")
    bindContainer.Size = UDim2.new(1, -10, 0, 36)
    bindContainer.BackgroundTransparency = 1
    bindContainer.Parent = ContentScrolling
    bindContainer.LayoutOrder = layoutOrder or 999
    
    local bindFrame = Instance.new("Frame")
    bindFrame.Size = UDim2.new(1, 0, 1, 0)
    bindFrame.BackgroundColor3 = COLORS.MEDIUM_GRAY
    bindFrame.BackgroundTransparency = 0.4
    bindFrame.BorderSizePixel = 0
    bindFrame.Parent = bindContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = bindFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.SILVER
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3
    stroke.Parent = bindFrame
    
    -- Текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.WHITE
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.8
    label.Parent = bindFrame
    
    -- Кнопка бинда
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0.35, 0, 0.7, 0)
    bindBtn.Position = UDim2.new(0.62, 0, 0.15, 0)
    bindBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
    bindBtn.BackgroundTransparency = 0.3
    bindBtn.BorderSizePixel = 0
    bindBtn.Text = currentKey and currentKey.Name or "None"
    bindBtn.TextColor3 = COLORS.WHITE
    bindBtn.TextSize = 12
    bindBtn.Font = Enum.Font.GothamSemibold
    bindBtn.AutoButtonColor = false
    bindBtn.Parent = bindFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = bindBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.GOLD :Lerp(COLORS.SILVER, 0.5)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    btnStroke.Parent = bindBtn
    
    -- Анимации для кнопки
    bindBtn.MouseEnter:Connect(function()
        TweenService:Create(bindBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2,
            TextColor3 = COLORS.GOLD
        }):Play()
        TweenService:Create(bindBtn.UIStroke, TweenInfo.new(0.2), {
            Transparency = 0.1
        }):Play()
    end)
    
    bindBtn.MouseLeave:Connect(function()
        TweenService:Create(bindBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3,
            TextColor3 = COLORS.WHITE
        }):Play()
        TweenService:Create(bindBtn.UIStroke, TweenInfo.new(0.2), {
            Transparency = 0.3
        }):Play()
    end)
    
    -- Функция обновления текста
    local function updateButtonText()
        bindBtn.Text = currentKey and currentKey.Name or "None"
    end
    
    -- Функция изменения бинда
    local function startKeyChange(bindType)
        local choosingVariable
        
        if bindType == "fly" then 
            if isChoosingFlyKey then return end
            isChoosingFlyKey = true
            choosingVariable = isChoosingFlyKey
        elseif bindType == "noclip" then 
            if isChoosingNoclipKey then return end
            isChoosingNoclipKey = true
            choosingVariable = isChoosingNoclipKey
        elseif bindType == "killaura" then 
            if isChoosingKillauraKey then return end
            isChoosingKillauraKey = true
            choosingVariable = isChoosingKillauraKey
        else
            return
        end
        
        bindBtn.Text = "Press a key..."
        bindBtn.BackgroundColor3 = COLORS.GREEN
        bindBtn.BackgroundTransparency = 0.2
        
        local connection
        connection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                updateButtonText()
                bindBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
                bindBtn.BackgroundTransparency = 0.3
                
                if onBindChanged then
                    onBindChanged(currentKey)
                end
                
                if bindType == "fly" then isChoosingFlyKey = false end
                if bindType == "noclip" then isChoosingNoclipKey = false end
                if bindType == "killaura" then isChoosingKillauraKey = false end
                
                if connection then
                    connection:Disconnect()
                end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                updateButtonText()
                bindBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
                bindBtn.BackgroundTransparency = 0.3
                
                if bindType == "fly" then isChoosingFlyKey = false end
                if bindType == "noclip" then isChoosingNoclipKey = false end
                if bindType == "killaura" then isChoosingKillauraKey = false end
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        -- Если 3 секунды не выбрали клавишу - отменяем
        task.delay(3, function()
            if choosingVariable then
                if bindType == "fly" then isChoosingFlyKey = false end
                if bindType == "noclip" then isChoosingNoclipKey = false end
                if bindType == "killaura" then isChoosingKillauraKey = false end
                
                updateButtonText()
                bindBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
                bindBtn.BackgroundTransparency = 0.3
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
    end
    
    bindBtn.MouseButton1Click:Connect(function()
        local bindType
        if labelText:find("Fly") then bindType = "fly" end
        if labelText:find("Noclip") then bindType = "noclip" end
        if labelText:find("Killaura") then bindType = "killaura" end
        if bindType then
            startKeyChange(bindType)
        end
    end)
    
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

-- Функция для создания кнопки изменения горячей клавиши меню
local function CreateKeybindButton()
    local keybindContainer = Instance.new("Frame")
    keybindContainer.Size = UDim2.new(1, -10, 0, 36)
    keybindContainer.BackgroundTransparency = 1
    keybindContainer.Parent = ContentScrolling
    
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, 0, 1, 0)
    keybindFrame.BackgroundColor3 = COLORS.MEDIUM_GRAY
    keybindFrame.BackgroundTransparency = 0.4
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = keybindContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = keybindFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.SILVER
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3
    stroke.Parent = keybindFrame
    
    -- Текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Menu Hotkey: M"
    label.TextColor3 = COLORS.WHITE
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.8
    label.Parent = keybindFrame
    
    -- Кнопка изменения
    local changeBtn = Instance.new("TextButton")
    changeBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
    changeBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
    changeBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
    changeBtn.BackgroundTransparency = 0.3
    changeBtn.BorderSizePixel = 0
    changeBtn.Text = "Change"
    changeBtn.TextColor3 = COLORS.WHITE
    changeBtn.TextSize = 12
    changeBtn.Font = Enum.Font.GothamSemibold
    changeBtn.AutoButtonColor = false
    changeBtn.Parent = keybindFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = changeBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.GOLD :Lerp(COLORS.SILVER, 0.5)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    btnStroke.Parent = changeBtn
    
    -- Функция обновления текста
    local function updateKeyText()
        label.Text = "Menu Hotkey: " .. menuHotkey.Name
    end
    
    -- Функция изменения клавиши
    local function startKeyChange()
        isChoosingMenuKey = true
        changeBtn.Text = "Press any key..."
        changeBtn.BackgroundColor3 = COLORS.GREEN
        changeBtn.BackgroundTransparency = 0.2
        
        local connection
        connection = UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                menuHotkey = input.KeyCode
                updateKeyText()
                
                isChoosingMenuKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
                changeBtn.BackgroundTransparency = 0.3
                
                if connection then
                    connection:Disconnect()
                end
                
                updateHotkeyListener()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                isChoosingMenuKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
                changeBtn.BackgroundTransparency = 0.3
                
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        task.delay(5, function()
            if isChoosingMenuKey then
                isChoosingMenuKey = false
                changeBtn.Text = "Change"
                changeBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
                changeBtn.BackgroundTransparency = 0.3
                
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
    selectorContainer.Size = UDim2.new(1, -10, 0, 36)
    selectorContainer.BackgroundTransparency = 1
    selectorContainer.LayoutOrder = 1
    selectorContainer.Parent = ContentScrolling
    
    local selectorFrame = Instance.new("Frame")
    selectorFrame.Size = UDim2.new(1, 0, 1, 0)
    selectorFrame.BackgroundColor3 = COLORS.MEDIUM_GRAY
    selectorFrame.BackgroundTransparency = 0.4
    selectorFrame.BorderSizePixel = 0
    selectorFrame.Parent = selectorContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = selectorFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.SILVER
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3
    stroke.Parent = selectorFrame
    
    -- Текст
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Guard Type: " .. (MainModule.Guards and MainModule.Guards.SelectedGuard or "Circle")
    label.TextColor3 = COLORS.WHITE
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.8
    label.Parent = selectorFrame
    
    -- Кнопка смены типа
    local changeBtn = Instance.new("TextButton")
    changeBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
    changeBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
    changeBtn.BackgroundColor3 = COLORS.LIGHT_GRAY
    changeBtn.BackgroundTransparency = 0.3
    changeBtn.BorderSizePixel = 0
    changeBtn.Text = "Change"
    changeBtn.TextColor3 = COLORS.WHITE
    changeBtn.TextSize = 12
    changeBtn.Font = Enum.Font.GothamSemibold
    changeBtn.AutoButtonColor = false
    changeBtn.Parent = selectorFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = changeBtn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.GOLD :Lerp(COLORS.SILVER, 0.5)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    btnStroke.Parent = changeBtn
    
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

-- Функция для установки биндов в MainModule
local function SetBindInMainModule(bindType, key)
    if MainModule then
        if bindType == "fly" and MainModule.SetFlyHotkey then
            MainModule.SetFlyHotkey(key)
        elseif bindType == "noclip" and MainModule.SetNoclipHotkey then
            MainModule.SetNoclipHotkey(key)
        elseif bindType == "killaura" and MainModule.SetKillauraHotkey then
            MainModule.SetKillauraHotkey(key)
        end
    end
end

-- MAIN TAB
local function CreateMainContent()
    ClearContent()
    
    -- Faster Speed (бывший SpeedHack)
    CreateToggle("Faster Speed", function() 
        return MainModule and MainModule.SpeedHack and MainModule.SpeedHack.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleSpeedHack then
            MainModule.ToggleSpeedHack(enabled)
        elseif MainModule and MainModule.SpeedHack then
            MainModule.SpeedHack.Enabled = enabled
        end
    end, 1)
    
    -- Fly Toggle
    CreateToggle("Fly", function() 
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
        SetBindInMainModule("fly", newKey)
        setupFlyListener()
    end, 3)
    
    -- Noclip Toggle
    CreateToggle("Noclip", function() 
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
        SetBindInMainModule("noclip", newKey)
        setupNoclipListener()
    end, 5)
    
    -- Free Dash (only player) - ДОСТУПЕН ДЛЯ ВСЕХ ПЛАТФОРМ
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
    
    -- Anti Stun + Anti Ragdoll
    CreateToggle("Anti Stun + Anti Ragdoll", function() 
        return MainModule and MainModule.Misc and MainModule.Misc.BypassRagdollEnabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleBypassRagdoll then
            MainModule.ToggleBypassRagdoll(enabled)
        elseif MainModule and MainModule.Misc then
            MainModule.Misc.BypassRagdollEnabled = enabled
        end
    end, 8)
    
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
    positionLabel.BackgroundColor3 = COLORS.LIGHT_GRAY
    positionLabel.TextColor3 = COLORS.WHITE:Lerp(COLORS.GOLD, 0.5)
    
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
    
    -- Killaura Toggle
    CreateToggle("Killaura", function() 
        return MainModule and MainModule.Killaura and MainModule.Killaura.Enabled or false
    end, function(enabled)
        if MainModule and MainModule.ToggleKillaura then
            MainModule.ToggleKillaura(enabled)
        elseif MainModule and MainModule.Killaura then
            MainModule.Killaura.Enabled = enabled
            -- Показываем уведомление о включении/выключении
            if enabled then
                ShowNotification("Killaura", "Enabled", 3)
            else
                ShowNotification("Killaura", "Disabled", 3)
            end
        end
    end, 2)
    
    -- Killaura Bind
    local killauraBindContainer, killauraBindBtn = CreateBindButton("Killaura Bind", KillauraHotkey, function(newKey)
        KillauraHotkey = newKey
        -- Сохраняем хоткей в MainModule.Killaura
        if MainModule and MainModule.Killaura then
            MainModule.Killaura.Hotkey = newKey
        end
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
    
    -- Hitbox Expander
    CreateToggle("Hitbox Expander", function() 
        return MainModule and MainModule.Guards and MainModule.Guards.HitboxExpander or false
    end, function(enabled)
        if MainModule and MainModule.ToggleHitboxExpander then
            MainModule.ToggleHitboxExpander(enabled)
        elseif MainModule and MainModule.Guards then
            MainModule.Guards.HitboxExpander = enabled
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
    
    -- Spikes Kill
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
            teleportToHiderBtn.BackgroundColor3 = COLORS.RED
            task.wait(1)
            teleportToHiderBtn.Text = "Teleport to Hider"
            teleportToHiderBtn.BackgroundColor3 = COLORS.MEDIUM_GRAY
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
        if MainModule and MainModule.ToggleGlassBridgeESP then
            MainModule.ToggleGlassBridgeESP(not (MainModule.GlassBridge and MainModule.GlassBridge.GlassESPEnabled or false))
            glassEspBtn.Text = MainModule.GlassBridge and MainModule.GlassBridge.GlassESPEnabled and "Glass ESP (ON)" or "Glass ESP (OFF)"
            glassEspBtn.BackgroundColor3 = MainModule.GlassBridge and MainModule.GlassBridge.GlassESPEnabled and COLORS.GREEN :Lerp(COLORS.SILVER, 0.3) or COLORS.MEDIUM_GRAY
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
                deleteRopeBtn.BackgroundColor3 = COLORS.GREEN :Lerp(COLORS.SILVER, 0.3)
                task.wait(1)
                deleteRopeBtn.Text = "Delete The Rope"
                deleteRopeBtn.BackgroundColor3 = COLORS.MEDIUM_GRAY
            else
                deleteRopeBtn.Text = "Rope Not Found"
                deleteRopeBtn.BackgroundColor3 = COLORS.RED
                task.wait(1)
                deleteRopeBtn.Text = "Delete The Rope"
                deleteRopeBtn.BackgroundColor3 = COLORS.MEDIUM_GRAY
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
    
    local titleLabel = CreateButton("LAST DINNER", true)
    titleLabel.LayoutOrder = 1
    
    -- Zone Kill Toggle
    local zoneKillToggle, _, zoneKillTextLabel = CreateToggle("Zone Kill [" .. (ZoneKillEnabled and "ON" or "OFF") .. "]", function() 
        return ZoneKillEnabled 
    end, function(enabled)
        ZoneKillEnabled = enabled
        if enabled then
            zoneKillTextLabel.Text = "Zone Kill [ON]"
        else
            zoneKillTextLabel.Text = "Zone Kill [OFF]"
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

-- Создание вкладок с улучшенным дизайном
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Last Dinner", "Settings"}
local tabButtons = {}

local TAB_BUTTON_WIDTH_PERCENT = 0.95

for i, name in pairs(tabs) do
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(TAB_BUTTON_WIDTH_PERCENT, 0, 0, 40)
    buttonContainer.Position = UDim2.new((1 - TAB_BUTTON_WIDTH_PERCENT)/2, 0, 0, (i-1)*48 + 10)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.LayoutOrder = i
    buttonContainer.Parent = TabScrolling
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = COLORS.MEDIUM_GRAY
    button.BackgroundTransparency = 0.4
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = COLORS.WHITE
    button.TextSize = 13
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = false
    button.TextStrokeColor3 = Color3.new(0, 0, 0)
    button.TextStrokeTransparency = 0.8
    button.Parent = buttonContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.RED :Lerp(COLORS.SILVER, 0.3)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.3
    stroke.Parent = button
    
    -- Анимация для кнопки вкладки
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3,
            TextColor3 = COLORS.GOLD
        }):Play()
        TweenService:Create(button.UIStroke, TweenInfo.new(0.2), {
            Transparency = 0.1,
            Color = COLORS.GOLD :Lerp(COLORS.SILVER, 0.5)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.4,
            TextColor3 = COLORS.WHITE
        }):Play()
        TweenService:Create(button.UIStroke, TweenInfo.new(0.2), {
            Transparency = 0.3,
            Color = COLORS.RED :Lerp(COLORS.SILVER, 0.3)
        }):Play()
    end)
    
    tabButtons[name] = button
    
    local function ActivateTab()
        for tabName, btn in pairs(tabButtons) do
            btn.BackgroundTransparency = 0.4
            btn.TextColor3 = COLORS.WHITE
            TweenService:Create(btn.UIStroke, TweenInfo.new(0.2), {
                Color = COLORS.RED :Lerp(COLORS.SILVER, 0.3)
            }):Play()
        end
        button.BackgroundTransparency = 0.2
        button.TextColor3 = COLORS.GOLD
        TweenService:Create(button.UIStroke, TweenInfo.new(0.2), {
            Color = COLORS.GOLD :Lerp(COLORS.SILVER, 0.5)
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
                -- Показываем снег при открытии GUI
                if SnowContainer then
                    SnowContainer.Visible = true
                end
                -- Показываем кастомный курсор для ПК
                if CustomCursor then
                    CustomCursor.Visible = true
                end
            else
                if UIS.TouchEnabled then
                    MobileOpenButton.Visible = true
                end
                -- Убираем снег при закрытии GUI
                if SnowContainer then
                    SnowContainer.Visible = false
                end
                -- Скрываем кастомный курсор для ПК
                if CustomCursor then
                    CustomCursor.Visible = false
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
                    elseif MainModule.Killaura then
                        MainModule.Killaura.Enabled = not currentState
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
updateHotkeyListener()

-- Автоматическое обновление GUI состояния
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
        -- Убираем снег при закрытии GUI
        if SnowContainer then
            SnowContainer.Visible = false
        end
        -- Скрываем кастомный курсор для ПК
        if CustomCursor then
            CustomCursor.Visible = false
        end
    end
end)

-- Автоматически открываем Main вкладку
if tabButtons["Main"] then
    task.spawn(function()
        task.wait(0.1)
        local btn = tabButtons["Main"]
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = COLORS.GOLD
        TweenService:Create(btn.UIStroke, TweenInfo.new(0.2), {
            Color = COLORS.GOLD :Lerp(COLORS.SILVER, 0.5)
        }):Play()
        CreateMainContent()
        
        -- Показываем снег при открытии GUI на ПК
        if not UIS.TouchEnabled then
            task.wait(0.5)
            if SnowContainer then
                SnowContainer.Visible = true
            end
        end
    end)
end

-- Завершаем инициализацию после создания GUI
task.spawn(function()
    task.wait(2)
    initializing = false
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
        if snowConnection then
            snowConnection:Disconnect()
        end
    end
end)

-- Отображение сообщения о загрузке
print("🎄 Creon X v2.5 loaded successfully 🎅")


