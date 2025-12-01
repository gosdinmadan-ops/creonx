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

local MainModule
local mainSuccess, mainErr = pcall(function()
    MainModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Main.lua"))()
end)

if not mainSuccess then
    warn("Не удалось загрузить Main.lua: " .. tostring(mainErr))
    MainModule = {}
end

local SkySquidModule
local skySuccess, skyErr = pcall(function()
    SkySquidModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/sky.lua"))()
end)

if not skySuccess then
    warn("Не удалось загрузить sky.lua: " .. tostring(skyErr))
    SkySquidModule = {}
end

local KillauraModule
local killSuccess, killErr = pcall(function()
    KillauraModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/killaura.lua"))()
end)

if not killSuccess then
    warn("Не удалось загрузить killaura.lua: " .. tostring(killErr))
    KillauraModule = {}
end

local CombinedModule = {}

for key, value in pairs(MainModule) do
    CombinedModule[key] = value
end

for key, value in pairs(SkySquidModule) do
    CombinedModule["SkySquid_" .. key] = value
end

for key, value in pairs(KillauraModule) do
    CombinedModule["Killaura_" .. key] = value
end

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

local MobileButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXv21"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

local GUI_WIDTH = 860
local GUI_HEIGHT = 595

local originalMouseBehavior = nil
local originalIconEnabled = nil

local function SaveMouseState()
    originalMouseBehavior = UIS.MouseBehavior
    originalIconEnabled = UIS.MouseIconEnabled
end

local function RestoreMouseState()
    if originalMouseBehavior then
        UIS.MouseBehavior = originalMouseBehavior
    end
    if originalIconEnabled ~= nil then
        UIS.MouseIconEnabled = originalIconEnabled
    end
end

local function EnableMenuMouse()
    SaveMouseState()
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    UIS.MouseIconEnabled = true
end

local function DisableMenuMouse()
    RestoreMouseState()
end

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
    DisableMenuMouse()
    if UIS.TouchEnabled then
        MobileButton.Visible = true
    end
end)

TabButtons.Size = UDim2.new(0, 150, 1, -35)
TabButtons.Position = UDim2.new(0, 0, 0, 35)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 8)
tabCorner.Parent = TabButtons

ContentFrame.Size = UDim2.new(1, -150, 1, -35)
ContentFrame.Position = UDim2.new(0, 150, 0, 35)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = ContentFrame

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
        EnableMenuMouse()
    end)
    
    MainFrame.Visible = false
else
    MainFrame.Visible = true
    SaveMouseState()
end

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

local function CreateToggle(text, enabled, callback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, -10, 0, 32)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentScrolling
    
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

local function CreateSpeedSlider()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(1, -10, 0, 60)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ContentScrolling
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. CombinedModule.SpeedHack.CurrentSpeed
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
    sliderFill.Size = UDim2.new((CombinedModule.SpeedHack.CurrentSpeed - CombinedModule.SpeedHack.MinSpeed) / (CombinedModule.SpeedHack.MaxSpeed - CombinedModule.SpeedHack.MinSpeed), 0, 1, 0)
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
        local newSpeed = CombinedModule.SetSpeed(value)
        speedLabel.Text = "Speed: " .. newSpeed
        sliderFill.Size = UDim2.new((newSpeed - CombinedModule.SpeedHack.MinSpeed) / (CombinedModule.SpeedHack.MaxSpeed - CombinedModule.SpeedHack.MinSpeed), 0, 1, 0)
        sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, 0)
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            local newSpeed = math.floor(CombinedModule.SpeedHack.MinSpeed + relativeX * (CombinedModule.SpeedHack.MaxSpeed - CombinedModule.SpeedHack.MinSpeed))
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
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(80, 80, 100)
    listStroke.Thickness = 1
    listStroke.Parent = dropdownList
    
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

local function CreateESPSettings()
    local settingsContainer = Instance.new("Frame")
    settingsContainer.Size = UDim2.new(1, -10, 0, 380)
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
    
    local espToggle, updateEspToggle = CreateToggle("ESP System", CombinedModule.Misc.ESPEnabled, function(enabled)
        CombinedModule.ToggleESP(enabled)
    end)
    espToggle.Parent = settingsContainer
    espToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espHighlightToggle, updateHighlightToggle = CreateToggle("ESP Highlight", CombinedModule.Misc.ESPHighlight, function(enabled)
        CombinedModule.Misc.ESPHighlight = enabled
    end)
    espHighlightToggle.Parent = settingsContainer
    espHighlightToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espDistanceToggle, updateDistanceToggle = CreateToggle("Show Distance", CombinedModule.Misc.ESPDistance, function(enabled)
        CombinedModule.Misc.ESPDistance = enabled
    end)
    espDistanceToggle.Parent = settingsContainer
    espDistanceToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espNamesToggle, updateNamesToggle = CreateToggle("Show Names", CombinedModule.Misc.ESPNames, function(enabled)
        CombinedModule.Misc.ESPNames = enabled
    end)
    espNamesToggle.Parent = settingsContainer
    espNamesToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espBoxesToggle, updateBoxesToggle = CreateToggle("Show Boxes", CombinedModule.Misc.ESPBoxes, function(enabled)
        CombinedModule.Misc.ESPBoxes = enabled
    end)
    espBoxesToggle.Parent = settingsContainer
    espBoxesToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight + 10
    
    local typesTitle = Instance.new("TextLabel")
    typesTitle.Size = UDim2.new(1, 0, 0, 20)
    typesTitle.Position = UDim2.new(0, 0, 0, yPosition)
    typesTitle.BackgroundTransparency = 1
    typesTitle.Text = "ESP Types:"
    typesTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    typesTitle.TextSize = 12
    typesTitle.Font = Enum.Font.GothamBold
    typesTitle.TextXAlignment = Enum.TextXAlignment.Left
    typesTitle.Parent = settingsContainer
    
    yPosition = yPosition + 25
    
    local espPlayersToggle, updatePlayersToggle = CreateToggle("Players", CombinedModule.Misc.ESPPlayers, function(enabled)
        CombinedModule.Misc.ESPPlayers = enabled
    end)
    espPlayersToggle.Parent = settingsContainer
    espPlayersToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espHidersToggle, updateHidersToggle = CreateToggle("Hiders", CombinedModule.Misc.ESPHiders, function(enabled)
        CombinedModule.Misc.ESPHiders = enabled
    end)
    espHidersToggle.Parent = settingsContainer
    espHidersToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espSeekersToggle, updateSeekersToggle = CreateToggle("Seekers", CombinedModule.Misc.ESPSeekers, function(enabled)
        CombinedModule.Misc.ESPSeekers = enabled
    end)
    espSeekersToggle.Parent = settingsContainer
    espSeekersToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espCandiesToggle, updateCandiesToggle = CreateToggle("Candies", CombinedModule.Misc.ESPCandies, function(enabled)
        CombinedModule.Misc.ESPCandies = enabled
    end)
    espCandiesToggle.Parent = settingsContainer
    espCandiesToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    yPosition = yPosition + toggleHeight
    
    local espKeysToggle, updateKeysToggle = CreateToggle("Keys", CombinedModule.Misc.ESPKeys, function(enabled)
        CombinedModule.Misc.ESPKeys = enabled
    end)
    espKeysToggle.Parent = settingsContainer
    espKeysToggle.Position = UDim2.new(0, 0, 0, yPosition)
    
    return settingsContainer
end

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

local function CreateMainContent()
    ClearContent()
    
    CreateSpeedSlider()
    
    CreateToggle("SpeedHack", CombinedModule.SpeedHack.Enabled, function(enabled)
        CombinedModule.ToggleSpeedHack(enabled)
    end)
    
    CreateToggle("Anti Stun QTE", CombinedModule.AutoQTE.AntiStunEnabled, function(enabled)
        CombinedModule.ToggleAntiStunQTE(enabled)
    end)
    
    CreateToggle("Anti Stun + Ragdoll", CombinedModule.Misc.AntiStunRagdoll, function(enabled)
        CombinedModule.ToggleAntiStunRagdoll(enabled)
    end)
    
    CreateToggle("Insta Interact", CombinedModule.Misc.InstaInteract, function(enabled)
        CombinedModule.ToggleInstaInteract(enabled)
    end)
    
    CreateToggle("No Cooldown Proximity", CombinedModule.Misc.NoCooldownProximity, function(enabled)
        CombinedModule.ToggleNoCooldownProximity(enabled)
    end)
    
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.MouseButton1Click:Connect(function()
        CombinedModule.TeleportUp100()
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.MouseButton1Click:Connect(function()
        CombinedModule.TeleportDown40()
    end)
    
    local noclipLabel = CreateButton("Noclip: " .. CombinedModule.Noclip.Status)
    noclipLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    noclipLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
end

local function CreateCombatContent()
    ClearContent()
    
    CreateToggle("Killaura", CombinedModule.Killaura_Enabled, function(enabled)
        CombinedModule.Killaura_Toggle(enabled)
    end)
    
    CreateToggle("Improved Mode", CombinedModule.Killaura_ImprovedMode, function(enabled)
        CombinedModule.Killaura_ToggleImprovedMode(enabled)
    end)
    
    CreateToggle("Rage Mode", CombinedModule.Killaura_RageMode, function(enabled)
        CombinedModule.Killaura_ToggleRageMode(enabled)
    end)
    
    CreateToggle("Smart Mode", CombinedModule.Killaura_SmartMode, function(enabled)
        CombinedModule.Killaura_ToggleSmartMode(enabled)
    end)
    
    CreateToggle("Auto Attack", CombinedModule.Killaura_AutoAttack, function(enabled)
        CombinedModule.Killaura_ToggleAutoAttack(enabled)
    end)
    
    local rangeLabel = CreateButton("Range: " .. CombinedModule.Killaura_Range)
    rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local speedLabel = CreateButton("Follow Speed: " .. CombinedModule.Killaura_FollowSpeed)
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local smoothToggle = CreateToggle("Smooth Follow", CombinedModule.Killaura_SmoothFollow, function(enabled)
        CombinedModule.Killaura_SmoothFollow = enabled
    end)
end

local function CreateMiscContent()
    ClearContent()
    
    CreateESPSettings()
end

local function CreateRebelContent()
    ClearContent()
    
    local rebelTitle = CreateButton("REBEL")
    rebelTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    rebelTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    rebelTitle.TextSize = 14
    
    CreateToggle("Instant Rebel", CombinedModule.Rebel.Enabled, function(enabled)
        CombinedModule.ToggleRebel(enabled)
    end)
    
    CreateToggle("Infinite Ammo", CombinedModule.Rebel.InfAmmo, function(enabled)
        CombinedModule.ToggleRebelInfAmmo(enabled)
    end)
    
    CreateToggle("Rapid Fire", CombinedModule.Rebel.RapidFire, function(enabled)
        CombinedModule.ToggleRebelRapidFire(enabled)
    end)
end

local function CreateRLGLContent()
    ClearContent()
    
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.MouseButton1Click:Connect(function()
        CombinedModule.TeleportToEndRLGL()
    end)
    
    local tpStartBtn = CreateButton("Teleport to Start")
    tpStartBtn.MouseButton1Click:Connect(function()
        CombinedModule.TeleportToStartRLGL()
    end)
    
    CreateToggle("GodMode", CombinedModule.RLGL.GodMode, function(enabled)
        CombinedModule.ToggleGodMode(enabled)
    end)
end

local function CreateGuardsContent()
    ClearContent()
    
    local guardDropdown = CreateDropdown({"Circle", "Triangle", "Square"}, CombinedModule.Guards.SelectedGuard, function(selected)
        CombinedModule.SetGuardType(selected)
    end)
    
    local spawnBtn = CreateButton("Spawn as Guard")
    spawnBtn.MouseButton1Click:Connect(function()
        CombinedModule.SpawnAsGuard()
    end)
    
    CreateToggle("Rapid Fire", CombinedModule.Guards.RapidFire, function(enabled)
        CombinedModule.ToggleRapidFire(enabled)
    end)
    
    CreateToggle("Infinite Ammo", CombinedModule.Guards.InfiniteAmmo, function(enabled)
        CombinedModule.ToggleInfiniteAmmo(enabled)
    end)
    
    CreateToggle("Hitbox Expander", CombinedModule.Guards.HitboxExpander, function(enabled)
        CombinedModule.ToggleHitboxExpander(enabled)
    end)
    
    CreateToggle("AutoFarm", CombinedModule.Guards.AutoFarm, function(enabled)
        CombinedModule.ToggleAutoFarm(enabled)
    end)
end

local function CreateDalgonaContent()
    ClearContent()
    
    local completeBtn = CreateButton("Complete Dalgona")
    completeBtn.MouseButton1Click:Connect(function()
        CombinedModule.CompleteDalgona()
    end)
    
    local lighterBtn = CreateButton("Free Lighter")
    lighterBtn.MouseButton1Click:Connect(function()
        CombinedModule.FreeLighter()
    end)
end

local function CreateHNSContent()
    ClearContent()
    
    CreateToggle("Auto Pickup", CombinedModule.HNS.AutoPickup, function(enabled)
        CombinedModule.ToggleAutoPickup(enabled)
    end)
    
    CreateToggle("Spikes Kill", CombinedModule.HNS.SpikesKill, function(enabled)
        CombinedModule.ToggleSpikesKill(enabled)
    end)
    
    local disableSpikesBtn = CreateButton("Disable Spikes")
    disableSpikesBtn.MouseButton1Click:Connect(function()
        CombinedModule.DisableSpikes()
    end)
    
    CreateToggle("Kill Hiders", CombinedModule.HNS.KillHiders, function(enabled)
        CombinedModule.ToggleKillHiders(enabled)
    end)
    
    CreateToggle("AutoDodge", CombinedModule.HNS.AutoDodge, function(enabled)
        CombinedModule.ToggleAutoDodge(enabled)
    end)
end

local function CreateGlassBridgeContent()
    ClearContent()
    
    CreateToggle("Anti Break", CombinedModule.GlassBridge.AntiBreak, function(enabled)
        CombinedModule.ToggleAntiBreak(enabled)
    end)
    
    local glassESPBtn = CreateButton("Glass ESP")
    glassESPBtn.MouseButton1Click:Connect(function()
        CombinedModule.ToggleGlassBridgeESP(true)
        task.wait(1)
        CombinedModule.ToggleGlassBridgeESP(false)
    end)
    
    CreateToggle("Anti Fall", CombinedModule.GlassBridge.AntiFallEnabled, function(enabled)
        CombinedModule.ToggleGlassBridgeAntiFall(enabled)
    end)
    
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.MouseButton1Click:Connect(function()
        CombinedModule.TeleportToGlassBridgeEnd()
    end)
end

local function CreateTugOfWarContent()
    ClearContent()
    
    CreateToggle("Auto Pull", CombinedModule.TugOfWar.AutoPull, function(enabled)
        CombinedModule.ToggleAutoPull(enabled)
    end)
end

local function CreateJumpRopeContent()
    ClearContent()
    
    local tpStartBtn = CreateButton("Teleport to Start")
    tpStartBtn.MouseButton1Click:Connect(function()
        CombinedModule.TeleportToJumpRopeStart()
    end)
    
    local tpEndBtn = CreateButton("Teleport to End")
    tpEndBtn.MouseButton1Click:Connect(function()
        CombinedModule.TeleportToJumpRopeEnd()
    end)
    
    local deleteRopeBtn = CreateButton("Delete Rope")
    deleteRopeBtn.MouseButton1Click:Connect(function()
        CombinedModule.DeleteRope()
    end)
    
    CreateToggle("Anti-Fail", CombinedModule.JumpRope.AntiFail, function(enabled)
        CombinedModule.ToggleAntiFailJumpRope(enabled)
    end)
    
    CreateToggle("Anti Fall", CombinedModule.JumpRope.AntiFallEnabled, function(enabled)
        CombinedModule.ToggleJumpRopeAntiFall(enabled)
    end)
    
    CreateToggle("No Balance", CombinedModule.JumpRope.NoBalance, function(enabled)
        CombinedModule.ToggleNoBalance(enabled)
    end)
    
    CreateToggle("Auto Jump", CombinedModule.JumpRope.AutoJump, function(enabled)
        CombinedModule.ToggleAutoJump(enabled)
    end)
    
    local freezeToggle = CreateToggle("Freeze Rope", false, function(enabled)
        CombinedModule.FreezeRope(enabled)
    end)
end

local function CreateSkySquidContent()
    ClearContent()
    
    CreateToggle("Anti Fall", CombinedModule.SkySquid_AntiFallEnabled, function(enabled)
        CombinedModule.SkySquid_ToggleAntiFall(enabled)
    end)
    
    CreateToggle("Void Kill", CombinedModule.SkySquid_VoidKillEnabled, function(enabled)
        CombinedModule.SkySquid_ToggleVoidKill(enabled)
    end)
end

local function CreateSettingsContent()
    ClearContent()
    
    local creatorLabel = CreateButton("Creator: Creon")
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local versionLabel = CreateButton("Version: 2.1")
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local executorLabel = CreateButton("Executor: " .. executorName)
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local positionLabel = CreateButton("Position: " .. CombinedModule.GetPlayerPosition())
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.MouseButton1Click:Connect(function()
        CombinedModule.Cleanup()
        if CombinedModule.Killaura_Cleanup then
            CombinedModule.Killaura_Cleanup()
        end
        if CombinedModule.SkySquid_Cleanup then
            CombinedModule.SkySquid_Cleanup()
        end
        ScreenGui:Destroy()
    end)
    
    game:GetService("RunService").Heartbeat:Connect(function()
        positionLabel.Text = "Position: " .. CombinedModule.GetPlayerPosition()
    end)
end

local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Settings"}
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
    
    tabButtons[name] = button
    tabContainers[name] = buttonContainer
    
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
        
        EnableMenuMouse()
    end
    
    button.MouseButton1Click:Connect(ActivateTab)
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
            EnableMenuMouse()
        else
            DisableMenuMouse()
        end
    end
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Escape and MainFrame.Visible then
        MainFrame.Visible = false
        DisableMenuMouse()
    end
end)

if tabButtons["Main"] then
    tabButtons["Main"].BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    tabButtons["Main"].TextColor3 = Color3.fromRGB(255, 255, 255)
end
CreateMainContent()
EnableMenuMouse()

ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        RestoreMouseState()
        CombinedModule.Cleanup()
        if CombinedModule.Killaura_Cleanup then
            CombinedModule.Killaura_Cleanup()
        end
        if CombinedModule.SkySquid_Cleanup then
            CombinedModule.SkySquid_Cleanup()
        end
    end
end)

print("Creon X v2.1 загружен...")
