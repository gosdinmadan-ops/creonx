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

-- Проверяем наличие необходимых функций ESP
if not MainModule.ToggleESP then
    -- Добавляем функцию ESP если ее нет
    MainModule.ESP = {
        Enabled = false,
        Players = {},
        Objects = {},
        Connections = {}
    }
    
    function MainModule.ToggleESP(enabled)
        MainModule.Misc.ESPEnabled = enabled
        
        if MainModule.ESP.Connection then
            MainModule.ESP.Connection:Disconnect()
            MainModule.ESP.Connection = nil
        end
        
        -- Очищаем все ESP объекты
        MainModule.ClearESP()
        
        if enabled then
            -- Основное соединение для обновления ESP
            MainModule.ESP.Connection = RunService.RenderStepped:Connect(function()
                if not MainModule.Misc.ESPEnabled then return end
                MainModule.UpdateESP()
            end)
            
            -- Создаем ESP для всех игроков
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    MainModule.AddPlayerESP(player)
                end
            end
            
            -- Слушатель для новых игроков
            MainModule.ESP.PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
                if MainModule.Misc.ESPEnabled then
                    MainModule.AddPlayerESP(player)
                end
            end)
            
            -- Слушатель для ушедших игроков
            MainModule.ESP.PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
                if MainModule.ESP.Players[player] then
                    local espData = MainModule.ESP.Players[player]
                    if espData.Highlight then
                        espData.Highlight:Destroy()
                    end
                    if espData.Billboard then
                        espData.Billboard:Destroy()
                    end
                    MainModule.ESP.Players[player] = nil
                end
            end)
        else
            -- Очищаем все ESP объекты
            MainModule.ClearESP()
            
            -- Отключаем соединения
            if MainModule.ESP.PlayerAddedConnection then
                MainModule.ESP.PlayerAddedConnection:Disconnect()
                MainModule.ESP.PlayerAddedConnection = nil
            end
            
            if MainModule.ESP.PlayerRemovingConnection then
                MainModule.ESP.PlayerRemovingConnection:Disconnect()
                MainModule.ESP.PlayerRemovingConnection = nil
            end
        end
    end
    
    function MainModule.AddPlayerESP(player)
        if MainModule.ESP.Players[player] then return end
        
        local espData = {
            Player = player,
            Highlight = nil,
            Billboard = nil,
            Label = nil
        }
        
        -- Создаем ESP когда появляется персонаж
        local function createESP()
            local character = player.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if not rootPart or not humanoid or humanoid.Health <= 0 then return end
            
            -- Создаем Highlight
            if not espData.Highlight then
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.Name = player.Name .. "_Highlight"
                espData.Highlight.Adornee = character
                espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
                espData.Highlight.Parent = workspace
                
                -- Цвет в зависимости от типа
                if player:GetAttribute("IsHider") then
                    espData.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    espData.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                elseif player:GetAttribute("IsHunter") then
                    espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    espData.Highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
                else
                    espData.Highlight.FillColor = Color3.fromRGB(0, 120, 255)
                    espData.Highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
                end
            end
            
            -- Создаем Billboard
            if not espData.Billboard then
                espData.Billboard = Instance.new("BillboardGui")
                espData.Billboard.Name = player.Name .. "_Billboard"
                espData.Billboard.Adornee = rootPart
                espData.Billboard.Size = UDim2.new(0, 200, 0, 50)
                espData.Billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                espData.Billboard.AlwaysOnTop = true
                espData.Billboard.Enabled = MainModule.Misc.ESPNames
                espData.Billboard.Parent = workspace
                
                espData.Label = Instance.new("TextLabel")
                espData.Label.Size = UDim2.new(1, 0, 1, 0)
                espData.Label.BackgroundTransparency = 1
                espData.Label.TextStrokeTransparency = 0.5
                espData.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
                espData.Label.Font = Enum.Font.GothamBold
                espData.Label.TextSize = MainModule.Misc.ESPTextSize
                espData.Label.Parent = espData.Billboard
                
                -- Соединение для обновления здоровья
                humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    if espData.Label and MainModule.Misc.ESPEnabled then
                        local distance = ""
                        if MainModule.Misc.ESPDistance and Players.LocalPlayer.Character then
                            local localRoot = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if localRoot then
                                distance = string.format("[%dm]", math.floor((rootPart.Position - localRoot.Position).Magnitude))
                            end
                        end
                        
                        local healthText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                        local nameText = player.DisplayName or player.Name
                        local roleText = ""
                        
                        if player:GetAttribute("IsHider") then
                            roleText = " (Hider)"
                        elseif player:GetAttribute("IsHunter") then
                            roleText = " (Seeker)"
                        end
                        
                        espData.Label.Text = string.format("%s%s\n%s %s", nameText, roleText, healthText, distance)
                    end
                end)
            end
        end
        
        -- Создаем ESP при появлении персонажа
        if player.Character then
            createESP()
        end
        
        -- Слушатель для нового персонажа
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            createESP()
        end)
        
        MainModule.ESP.Players[player] = espData
    end
    
    function MainModule.UpdateESP()
        for player, espData in pairs(MainModule.ESP.Players) do
            if player and player.Parent then
                local character = player.Character
                if character and espData.Highlight then
                    espData.Highlight.Enabled = MainModule.Misc.ESPHighlight and MainModule.Misc.ESPEnabled
                    espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                    espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                    
                    if espData.Billboard then
                        espData.Billboard.Enabled = MainModule.Misc.ESPNames and MainModule.Misc.ESPEnabled
                        if espData.Label then
                            espData.Label.TextSize = MainModule.Misc.ESPTextSize
                        end
                    end
                end
            else
                -- Игрок вышел
                if espData.Highlight then
                    espData.Highlight:Destroy()
                end
                if espData.Billboard then
                    espData.Billboard:Destroy()
                end
                MainModule.ESP.Players[player] = nil
            end
        end
    end
    
    function MainModule.ClearESP()
        for player, espData in pairs(MainModule.ESP.Players) do
            if espData.Highlight then
                espData.Highlight:Destroy()
            end
            if espData.Billboard then
                espData.Billboard:Destroy()
            end
        end
        MainModule.ESP.Players = {}
    end
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

-- Простая кнопка выбора Guard типа (без выпадающего списка)
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
    label.Text = "Guard Type: " .. MainModule.Guards.SelectedGuard
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
        MainModule.SetGuardType(newGuardType)
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
        MainModule.ToggleSpeedHack(enabled)
    end)
    speedToggle.LayoutOrder = 1
    
    -- Anti Stun QTE
    local antiStunToggle, updateAntiStunToggle = CreateToggle("Anti Stun QTE", MainModule.AutoQTE.AntiStunEnabled, function(enabled)
        MainModule.ToggleAntiStunQTE(enabled)
    end)
    antiStunToggle.LayoutOrder = 2
    
    -- Anti Stun + Anti Ragdoll
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
    
    -- Teleport Buttons
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.LayoutOrder = 6
    tpUpBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportUp100()
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.LayoutOrder = 7
    tpDownBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportDown40()
    end)
    
    -- Noclip status
    local noclipLabel = CreateButton("Noclip: " .. MainModule.Noclip.Status)
    noclipLabel.LayoutOrder = 8
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

-- MISC TAB (исправленный)
local function CreateMiscContent()
    ClearContent()
    
    -- ESP System Toggle
    local espToggle, updateEspToggle = CreateToggle("ESP System", MainModule.Misc.ESPEnabled, function(enabled)
        if MainModule.ToggleESP then
            MainModule.ToggleESP(enabled)
        else
            -- Запасной вариант
            MainModule.Misc.ESPEnabled = enabled
            if enabled then
                -- Простой ESP
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer and player.Character then
                        local highlight = Instance.new("Highlight")
                        highlight.Adornee = player.Character
                        highlight.FillColor = Color3.fromRGB(0, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                        highlight.FillTransparency = 0.3
                        highlight.Parent = workspace
                        
                        -- Удаляем при смерти или выходе
                        player.CharacterRemoving:Connect(function()
                            highlight:Destroy()
                        end)
                    end
                end
            end
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
    
    -- ESP Guards
    local espGuardsToggle, updateEspGuardsToggle = CreateToggle("ESP Guards", MainModule.Misc.ESPGuards, function(enabled)
        MainModule.Misc.ESPGuards = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espGuardsToggle.LayoutOrder = 5
    
    -- ESP Highlight
    local espHighlightToggle, updateEspHighlightToggle = CreateToggle("ESP Highlight", MainModule.Misc.ESPHighlight, function(enabled)
        MainModule.Misc.ESPHighlight = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espHighlightToggle.LayoutOrder = 6
    
    -- ESP Distance
    local espDistanceToggle, updateEspDistanceToggle = CreateToggle("ESP Distance", MainModule.Misc.ESPDistance, function(enabled)
        MainModule.Misc.ESPDistance = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espDistanceToggle.LayoutOrder = 7
    
    -- ESP Boxes
    local espBoxesToggle, updateEspBoxesToggle = CreateToggle("ESP Boxes", MainModule.Misc.ESPBoxes, function(enabled)
        MainModule.Misc.ESPBoxes = enabled
        if MainModule.Misc.ESPEnabled and MainModule.ToggleESP then
            MainModule.ToggleESP(false)
            task.wait(0.1)
            MainModule.ToggleESP(true)
        end
    end)
    espBoxesToggle.LayoutOrder = 8
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

-- GUARDS TAB (исправленный - без выпадающего списка)
local function CreateGuardsContent()
    ClearContent()
    
    -- Guard Type Selector (простая кнопка переключения)
    local guardSelector = CreateGuardTypeSelector()
    
    -- Spawn as Guard кнопка
    local spawnBtn = CreateButton("Spawn as Guard")
    spawnBtn.LayoutOrder = 2
    spawnBtn.MouseButton1Click:Connect(function()
        MainModule.SpawnAsGuard()
    end)
    
    -- Rapid Fire
    local rapidFireToggle, updateRapidFireToggle = CreateToggle("Rapid Fire", MainModule.Guards.RapidFire, function(enabled)
        MainModule.ToggleRapidFire(enabled)
    end)
    rapidFireToggle.LayoutOrder = 3
    
    -- Infinite Ammo
    local infiniteAmmoToggle, updateInfiniteAmmoToggle = CreateToggle("Infinite Ammo", MainModule.Guards.InfiniteAmmo, function(enabled)
        MainModule.ToggleInfiniteAmmo(enabled)
    end)
    infiniteAmmoToggle.LayoutOrder = 4
    
    -- Hitbox Expander (исправленный - без Z-Index)
    local hitboxToggle, updateHitboxToggle = CreateToggle("Hitbox Expander", MainModule.Guards.HitboxExpander, function(enabled)
        MainModule.ToggleHitboxExpander(enabled)
    end)
    hitboxToggle.LayoutOrder = 5
    
    -- AutoFarm
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

-- HNS TAB (упрощенный)
local function CreateHNSContent()
    ClearContent()

     -- Teleport to Hider (кнопка)
    local tpToHiderBtn = CreateButton("Teleport to Hider")
    tpToHiderBtn.LayoutOrder = 4
    tpToHiderBtn.MouseButton1Click:Connect(function()
        if MainModule.TeleportToHider then
            MainModule.TeleportToHider()
        end
    end)
    
    -- Kill Hiders
    local killHidersToggle, updateKillHidersToggle = CreateToggle("Kill Hiders", MainModule.HNS.KillAuraEnabled, function(enabled)
        if MainModule.ToggleKillHiders then
            MainModule.ToggleKillHiders(enabled)
        end
    end)
    killHidersToggle.LayoutOrder = 1
    
    -- Auto Dodge (исправленный)
    local autoDodgeToggle, updateAutoDodgeToggle = CreateToggle("Auto Dodge", MainModule.HNS.AutoDodgeEnabled, function(enabled)
        if MainModule.ToggleAutoDodge then
            MainModule.ToggleAutoDodge(enabled)
        end
    end)
    autoDodgeToggle.LayoutOrder = 2
    
    -- Disable Spikes (кнопка)
    local disableSpikesBtn = CreateButton("Disable Spikes")
    disableSpikesBtn.LayoutOrder = 3
    disableSpikesBtn.MouseButton1Click:Connect(function()
        local newState = not MainModule.HNS.DisableSpikesEnabled
        if MainModule.ToggleDisableSpikes then
            MainModule.ToggleDisableSpikes(newState)
            if newState then
                disableSpikesBtn.Text = "Disable Spikes (ON)"
                disableSpikesBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            else
                disableSpikesBtn.Text = "Disable Spikes"
                disableSpikesBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            end
        end
    end)
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


