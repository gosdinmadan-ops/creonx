-- Creon X v2.1 GUI с исправлениями
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Загрузка Main модуля
local MainModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Main.lua"))()

-- GUI Creon X v2.1
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local ContentScrolling = Instance.new("ScrollingFrame")
local ContentLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXv21"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основной фрейм
MainFrame.Size = UDim2.new(0, 860, 0, 595)
MainFrame.Position = UDim2.new(0.5, -430, 0.5, -297.5)
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

-- TitleBar
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

-- Кнопка скрытия (_)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -30, 0.5, -12.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "_"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
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

-- Content Frame
ContentFrame.Size = UDim2.new(1, -150, 1, -35)
ContentFrame.Position = UDim2.new(0, 150, 0, 35)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = ContentFrame

-- Scrolling Frame
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

-- Функция для создания выпадающего списка (поверх всех кнопок)
local function CreateDropdown(options, default, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(1, -10, 0, 32)
    dropdownContainer.BackgroundTransparency = 1
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
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = dropdownButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = dropdownButton
    
    -- Анимация при наведении
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
    
    -- Создаем фрейм для списка (ПОВЕРХ ВСЕХ ЭЛЕМЕНТОВ)
    local dropdownList = Instance.new("Frame")
    dropdownList.Name = "DropdownList"
    dropdownList.Size = UDim2.new(1, 0, 0, #options * 36)
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ZIndex = 100 -- ВЫСОКИЙ Z-INDEX
    dropdownList.Parent = ScreenGui -- ВЫСОКИЙ УРОВЕНЬ
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownList
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(80, 80, 100)
    listStroke.Thickness = 1
    listStroke.Parent = dropdownList
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -8, 0, 32)
        optionButton.Position = UDim2.new(0, 4, 0, (i-1)*36 + 2)
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(240, 240, 255)
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.AutoButtonColor = false
        optionButton.ZIndex = 101 -- ЕЩЕ ВЫШЕ
        optionButton.Parent = dropdownList
        
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 6)
        optionCorner.Parent = optionButton
        
        local optionStroke = Instance.new("UIStroke")
        optionStroke.Color = Color3.fromRGB(80, 80, 100)
        optionStroke.Thickness = 1
        optionStroke.Parent = optionButton
        
        -- Анимация для опций
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(65, 65, 85)
            }):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            }):Play()
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option .. " ▼"
            dropdownList.Visible = false
            if callback then
                callback(option)
            end
        end)
    end
    
    local function updateDropdownPosition()
        if dropdownList.Visible then
            local buttonPos = dropdownButton.AbsolutePosition
            local buttonSize = dropdownButton.AbsoluteSize
            dropdownList.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 5)
            dropdownList.Size = UDim2.new(0, buttonSize.X, 0, #options * 36)
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        if dropdownList.Visible then
            updateDropdownPosition()
        end
    end)
    
    -- Обновляем позицию при перемещении GUI
    MainFrame:GetPropertyChangedSignal("Position"):Connect(updateDropdownPosition)
    
    -- Закрываем при клике вне списка
    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownList.Visible then
            if not dropdownList:IsDescendantOf(input.Target) and not dropdownButton:IsDescendantOf(input.Target) then
                dropdownList.Visible = false
            end
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

local function CreateMainContent()
    ClearContent()
    
    local speedLabel = CreateSpeedSlider()
    
    local speedToggle, updateSpeedToggle = CreateToggle("Speed Hack", MainModule.SpeedHack.Enabled, function(enabled)
        MainModule.ToggleSpeedHack(enabled)
    end)
    
    local autoQTEToggle, updateAutoQTEToggle = CreateToggle("Auto QTE", MainModule.AutoQTE.AntiStunEnabled, function(enabled)
        MainModule.ToggleAutoQTE(enabled)
    end)
    
    local unlockDashToggle, updateUnlockDashToggle = CreateToggle("Unlock Dash", MainModule.UnlockDash, function(enabled)
        MainModule.ToggleUnlockDash(enabled)
    end)
    
    local instaInteractToggle, updateInstaInteractToggle = CreateToggle("Insta Interact", MainModule.InstaInteract, function(enabled)
        MainModule.ToggleInstaInteract(enabled)
    end)
    
    local noCooldownToggle, updateNoCooldownToggle = CreateToggle("No Cooldown Proximity", MainModule.NoCooldownProximity, function(enabled)
        MainModule.ToggleNoCooldownProximity(enabled)
    end)
    
    local noclipToggle, updateNoclipToggle = CreateToggle("Noclip: " .. MainModule.Noclip.Status, MainModule.Noclip.Enabled, function(enabled)
        MainModule.ToggleNoclip(enabled)
        updateNoclipToggle(enabled)
    end)
    
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportUp100()
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportDown40()
    end)
    
    local antiStunToggle, updateAntiStunToggle = CreateToggle("Anti Stun", MainModule.AntiStun, function(enabled)
        MainModule.ToggleAntiStun(enabled)
    end)
    
    local antiRagdollToggle, updateAntiRagdollToggle = CreateToggle("Anti Ragdoll", MainModule.AntiRagdoll, function(enabled)
        MainModule.ToggleAntiRagdoll(enabled)
    end)
    
    local unlockPhantomToggle, updateUnlockPhantomToggle = CreateToggle("Unlock Phantom Step", MainModule.UnlockPhantomStep, function(enabled)
        MainModule.ToggleUnlockPhantomStep(enabled)
    end)
end

local function CreateMiscContent()
    ClearContent()
    
    -- ESP настройки
    local espToggle, updateEspToggle = CreateToggle("ESP System", MainModule.ESPEnabled, function(enabled)
        MainModule.ToggleESP(enabled)
    end)
    
    local espPlayersToggle, updateEspPlayersToggle = CreateToggle("Show Players", MainModule.ESPPlayers, function(enabled)
        MainModule.ESPPlayers = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espHidersToggle, updateEspHidersToggle = CreateToggle("Show Hiders", MainModule.ESPHiders, function(enabled)
        MainModule.ESPHiders = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espSeekersToggle, updateEspSeekersToggle = CreateToggle("Show Seekers", MainModule.ESPSeekers, function(enabled)
        MainModule.ESPSeekers = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espGuardsToggle, updateEspGuardsToggle = CreateToggle("Show Guards", MainModule.ESPGuards, function(enabled)
        MainModule.ESPGuards = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espCandiesToggle, updateEspCandiesToggle = CreateToggle("Show Candies", MainModule.ESPCandies, function(enabled)
        MainModule.ESPCandies = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espKeysToggle, updateEspKeysToggle = CreateToggle("Show Keys", MainModule.ESPKeys, function(enabled)
        MainModule.ESPKeys = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espDoorsToggle, updateEspDoorsToggle = CreateToggle("Show Doors", MainModule.ESPDoors, function(enabled)
        MainModule.ESPDoors = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espExitDoorsToggle, updateEspExitDoorsToggle = CreateToggle("Show Exit Doors", MainModule.ESPEscapeDoors, function(enabled)
        MainModule.ESPEscapeDoors = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espNamesToggle, updateEspNamesToggle = CreateToggle("Show Names", MainModule.ESPNames, function(enabled)
        MainModule.ESPNames = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espDistanceToggle, updateEspDistanceToggle = CreateToggle("Show Distance", MainModule.ESPDistance, function(enabled)
        MainModule.ESPDistance = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espSnowToggle, updateEspSnowToggle = CreateToggle("Show Snow", MainModule.ESPShowSnow, function(enabled)
        MainModule.ESPShowSnow = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espHPToggle, updateEsphptoggle = CreateToggle("Show HP", MainModule.ESPShowHP, function(enabled)
        MainModule.ESPShowHP = enabled
        MainModule.UpdateESPSettings()
    end)
    
    local espBoxesToggle, updateEspBoxesToggle = CreateToggle("Show Boxes", MainModule.ESPBoxes, function(enabled)
        MainModule.ESPBoxes = enabled
        MainModule.UpdateESPSettings()
    end)
end

local function CreateGuardsContent()
    ClearContent()
    
    -- Дропдаун для выбора охранника (ПОВЕРХ КНОПОК)
    local guardDropdown = CreateDropdown({"Circle", "Triangle", "Square"}, MainModule.Guards.SelectedGuard, function(selected)
        MainModule.SetGuardType(selected)
    end)
    
    local spawnBtn = CreateButton("Spawn as Guard")
    spawnBtn.MouseButton1Click:Connect(function()
        MainModule.SpawnAsGuard()
    end)
    
    local rapidFireToggle, updateRapidFireToggle = CreateToggle("Rapid Fire", MainModule.Guards.RapidFire, function(enabled)
        MainModule.ToggleRapidFire(enabled)
    end)
    
    local infiniteAmmoToggle, updateInfiniteAmmoToggle = CreateToggle("Infinite Ammo", MainModule.Guards.InfiniteAmmo, function(enabled)
        MainModule.ToggleInfiniteAmmo(enabled)
    end)
    
    local hitboxToggle, updateHitboxToggle = CreateToggle("Hitbox Expander", MainModule.Guards.HitboxExpander, function(enabled)
        MainModule.ToggleHitboxExpander(enabled)
    end)
    
    local autoFarmToggle, updateAutoFarmToggle = CreateToggle("AutoFarm", MainModule.Guards.AutoFarm, function(enabled)
        MainModule.ToggleAutoFarm(enabled)
    end)
end

-- Остальные функции вкладок (остаются без изменений)
local function CreateRebelContent()
    ClearContent()
    
    local rebelTitle = CreateButton("REBEL")
    rebelTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    rebelTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    rebelTitle.TextSize = 14
    
    local rebelToggle, updateRebelToggle = CreateToggle("Instant Rebel", MainModule.Rebel.Enabled, function(enabled)
        MainModule.ToggleRebel(enabled)
    end)
end

local function CreateRLGLContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("TP TO END")
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToEnd()
    end)
    
    local tpStartBtn = CreateButton("TP TO START")
    tpStartBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToStart()
    end)
    
    local godModeToggle, updateGodModeToggle = CreateToggle("GodMode", MainModule.RLGL.GodMode, function(enabled)
        MainModule.ToggleGodMode(enabled)
    end)
end

local function CreateDalgonaContent()
    ClearContent()
    
    local completeBtn = CreateButton("Complete Dalgona")
    completeBtn.MouseButton1Click:Connect(function()
        MainModule.CompleteDalgona()
    end)
    
    local lighterBtn = CreateButton("Free Lighter")
    lighterBtn.MouseButton1Click:Connect(function()
        MainModule.FreeLighter()
    end)
end

local function CreateHNSContent()
    ClearContent()
    
    local spikesKillToggle, updateSpikesKillToggle = CreateToggle("Spikes Kill", MainModule.HNS.SpikesKill, function(enabled)
        MainModule.ToggleSpikesKill(enabled)
    end)
    
    local disableSpikesBtn = CreateButton("Disable Spikes")
    disableSpikesBtn.MouseButton1Click:Connect(function()
        MainModule.ToggleDisableSpikes(not MainModule.HNS.DisableSpikes)
        if MainModule.HNS.DisableSpikes then
            disableSpikesBtn.Text = "Disable Spikes (ON)"
        else
            disableSpikesBtn.Text = "Disable Spikes"
        end
    end)
    
    local killHidersToggle, updateKillHidersToggle = CreateToggle("Kill Hiders", MainModule.HNS.KillHiders, function(enabled)
        MainModule.ToggleKillHiders(enabled)
    end)
    
    local autoDodgeToggle, updateAutoDodgeToggle = CreateToggle("Auto Dodge", MainModule.HNS.AutoDodge, function(enabled)
        MainModule.ToggleAutoDodge(enabled)
    end)
end

local function CreateGlassBridgeContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("TP END")
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToEnd()
    end)
    
    local glassEspBtn = CreateButton("GLASS ESP")
    glassEspBtn.MouseButton1Click:Connect(function()
        MainModule.ToggleGlassBridgeESP(not MainModule.GlassBridge.GlassESPEnabled)
        if MainModule.GlassBridge.GlassESPEnabled then
            glassEspBtn.Text = "GLASS ESP (ON)"
        else
            glassEspBtn.Text = "GLASS ESP"
        end
    end)
    
    local antiBreakToggle, updateAntiBreakToggle = CreateToggle("Anti Break", MainModule.GlassBridge.AntiBreak, function(enabled)
        MainModule.ToggleAntiBreak(enabled)
    end)
end

local function CreateTugOfWarContent()
    ClearContent()
    
    local autoPullToggle, updateAutoPullToggle = CreateToggle("Auto Pull", MainModule.TugOfWar.AutoPull, function(enabled)
        MainModule.ToggleAutoPull(enabled)
    end)
end

local function CreateJumpRopeContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToJumpRopeEnd()
    end)
    
    local deleteRopeBtn = CreateButton("Delete The Rope")
    deleteRopeBtn.MouseButton1Click:Connect(function()
        MainModule.DeleteJumpRope()
    end)
end

local function CreateSkySquidContent()
    ClearContent()
    
    local antiFallToggle, updateAntiFallToggle = CreateToggle("Anti Fall", MainModule.SkySquid.AntiFall, function(enabled)
        MainModule.ToggleSkySquidAntiFall(enabled)
    end)
    
    local voidKillToggle, updateVoidKillToggle = CreateToggle("Void Kill", MainModule.SkySquid.VoidKill, function(enabled)
        MainModule.ToggleSkySquidVoidKill(enabled)
    end)
end

local function CreateSettingsContent()
    ClearContent()
    
    local creatorLabel = CreateButton("Creator: Creon")
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local versionLabel = CreateButton("Version: 2.1")
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local positionLabel = CreateButton("Position: " .. MainModule.GetPlayerPosition())
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.MouseButton1Click:Connect(function()
        MainModule.Cleanup()
        ScreenGui:Destroy()
    end)
    
    game:GetService("RunService").Heartbeat:Connect(function()
        positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
    end)
end

-- Создание вкладок
local tabs = {"Main", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Settings"}
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
            MainFrame.Position = UDim2.new(0.5, -430, 0.5, -297.5)
        end
    end
end)

-- Автоматически открываем Main вкладку
if tabButtons["Main"] then
    tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    tabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
end
CreateMainContent()

print("Creon X v2.1 загружен!")
