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

-- Античит байпас
_G.ANypass = true
if _G.ANypass then
    local function optimizedStealth()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local original_nc = mt.__namecall
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod()
                if method:lower():find("detect") or method:lower():find("check") or method:lower():find("kick") then
                    return nil
                end
                return original_nc(self, ...)
            end
            setreadonly(mt, true)
        end
        task.spawn(function()
            pcall(function()
                for _, obj in pairs(game:GetService("CoreGui"):GetChildren()) do
                    if obj.Name:lower():find("dex") or obj.Name:lower():find("explorer") then
                        obj:Destroy()
                    end
                end
            end)
        end)
    end
    optimizedStealth()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local oldhmmi
    local oldhmmnc
    if hookfunction then
        hookfunction(LocalPlayer.Kick, function() end)
    end
    if hookmetamethod then
        oldhmmi = hookmetamethod(game, "__index", function(self, method)
            if self == LocalPlayer and method:lower() == "kick" then
                return error("Expected ':' not '.' calling member function Kick", 2)
            end
            return oldhmmi(self, method)
        end)
        oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
            if self == LocalPlayer and getnamecallmethod():lower() == "kick" then
                return
            end
            return oldhmmnc(self, ...)
        end)
    end
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
        AutoQTE = {AntiStunEnabled = false},
        Rebel = {Enabled = false},
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
            DeleteSpikes = false, 
            KillHiders = false, 
            AutoDodge = false,
            DisableSpikes = false
        },
        TugOfWar = {AutoPull = false},
        GlassBridge = {AntiBreak = false, GlassESPEnabled = false},
        JumpRope = {
            AutoJump = false,
            AntiFail = false,
            TeleportToStart = false,
            TeleportToEnd = false
        },
        Misc = {
            InstaInteract = false, 
            NoCooldownProximity = false,
            ESPEnabled = false,
            ESPHighlight = true,
            ESPDistance = true,
            ESPFillTransparency = 0.7,
            ESPOutlineTransparency = 0,
            ESPTextSize = 18,
            ESPPlayers = true,
            ESPNPCs = true,
            ESPItems = true,
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
        ToggleDeleteSpikes = function(enabled)
            MainModule.HNS.DeleteSpikes = enabled
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
        ToggleAutoJump = function(enabled)
            MainModule.JumpRope.AutoJump = enabled
        end,
        ToggleAntiFailJumpRope = function(enabled)
            MainModule.JumpRope.AntiFail = enabled
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
        end
    }
else
    print("Main.lua успешно загружен")
end

-- GUI с улучшенным дизайном
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local SoonLabel = Instance.new("TextLabel")

-- Кнопка для мобильных устройств
local MobileButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonX"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Стиль для округлений
local cornerRadius = UDim.new(0, 8)

-- Компактные размеры
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = cornerRadius
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 2
mainStroke.Parent = MainFrame

-- TitleBar для перемещения
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = TitleBar

TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CreonX"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка закрытия для мобильных устройств
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0.5, -10)
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

-- Компактные табы
TabButtons.Size = UDim2.new(0, 140, 1, -28)
TabButtons.Position = UDim2.new(0, 0, 0, 28)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 8)
tabCorner.Parent = TabButtons

ContentFrame.Size = UDim2.new(1, -140, 1, -28)
ContentFrame.Position = UDim2.new(0, 140, 0, 28)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = ContentFrame

SoonLabel.Size = UDim2.new(1, 0, 1, 0)
SoonLabel.BackgroundTransparency = 1
SoonLabel.Text = "Soon...."
SoonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SoonLabel.TextSize = 18
SoonLabel.Font = Enum.Font.Gotham
SoonLabel.Visible = false
SoonLabel.Parent = ContentFrame

-- Кнопка для мобильных устройств
if UIS.TouchEnabled then
    MobileButton.Size = UDim2.new(0, 90, 0, 32)
    MobileButton.Position = UDim2.new(0.5, -45, 0, 8)
    MobileButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    MobileButton.BorderSizePixel = 0
    MobileButton.Text = "CreonX"
    MobileButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    MobileButton.TextSize = 11
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
    
    -- Скрываем основное окно на мобильных устройствах по умолчанию
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

-- Функция для создания очень маленьких кнопок
local function CreateButton(text, position, size)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0.9, 0, 0, 26)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(240, 240, 255)
    button.TextSize = 10
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = button
    
    -- Анимация при наведении
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(65, 65, 85),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 65),
            TextColor3 = Color3.fromRGB(240, 240, 255)
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(65, 65, 85)
        }):Play()
    end)
    
    return button
end

-- Функция для создания маленьких переключателей
local function CreateToggle(text, position, enabled, callback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(0.9, 0, 0, 26)
    toggleContainer.Position = position
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentFrame
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    textLabel.TextSize = 10
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = toggleContainer
    
    -- Переключатель
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Size = UDim2.new(0.25, 0, 0.5, 0)
    toggleBackground.Position = UDim2.new(0.73, 0, 0.25, 0)
    toggleBackground.BackgroundColor3 = enabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleContainer
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0.35, 0, 0.7, 0)
    toggleCircle.Position = enabled and UDim2.new(0.6, 0, 0.15, 0) or UDim2.new(0.05, 0, 0.15, 0)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBackground
    
    -- Закругления
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 10)
    corner1.Parent = toggleBackground
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 8)
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
        game:GetService("TweenService"):Create(toggleBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = newState and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
        }):Play()
        
        game:GetService("TweenService"):Create(toggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = newState and UDim2.new(0.6, 0, 0.15, 0) or UDim2.new(0.05, 0, 0.15, 0)
        }):Play()
        
        callback(newState)
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not enabled)
    end)
    
    return toggleContainer
end

-- Функция для создания слайдера скорости
local function CreateSpeedSlider()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0.9, 0, 0, 50)
    sliderContainer.Position = UDim2.new(0.05, 0, 0.05, 0)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ContentFrame
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 18)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. MainModule.SpeedHack.CurrentSpeed
    speedLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    speedLabel.TextSize = 11
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.Parent = sliderContainer
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, 0, 0, 18)
    sliderBackground.Position = UDim2.new(0, 0, 0, 20)
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
    sliderButton.Size = UDim2.new(0, 18, 0, 18)
    sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -9, 0, 0)
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
        sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -9, 0, 0)
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
local function CreateDropdown(options, default, position, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(0.9, 0, 0, 26)
    dropdownContainer.Position = position
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = ContentFrame
    dropdownContainer.ZIndex = 10
    
    local dropdownButton = CreateButton(default, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 1, 0))
    dropdownButton.Parent = dropdownContainer
    dropdownButton.Text = default .. " ▼"
    dropdownButton.ZIndex = 11
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, #options * 26)
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.Parent = dropdownContainer
    dropdownList.ZIndex = 20
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownList
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(80, 80, 100)
    listStroke.Thickness = 1
    listStroke.Parent = dropdownList
    
    for i, option in ipairs(options) do
        local optionButton = CreateButton(option, UDim2.new(0, 4, 0, (i-1)*26), UDim2.new(1, -8, 0, 22))
        optionButton.Parent = dropdownList
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        optionButton.ZIndex = 21
        
        optionButton.MouseButton1Click:Connect(function()
            dropdownButton.Text = option .. " ▼"
            dropdownList.Visible = false
            callback(option)
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
    end)
    
    return dropdownContainer
end

-- Функция для создания ESP настроек
local function CreateESPSettings()
    local settingsContainer = Instance.new("Frame")
    settingsContainer.Size = UDim2.new(0.9, 0, 0, 120)
    settingsContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.Parent = ContentFrame
    
    local espToggle = CreateToggle("ESP System", UDim2.new(0, 0, 0, 0), MainModule.Misc.ESPEnabled, function(enabled)
        MainModule.ToggleESP(enabled)
    end)
    espToggle.Parent = settingsContainer
    
    local espPlayersToggle = CreateToggle("Show Players", UDim2.new(0, 0, 0.25, 0), MainModule.Misc.ESPPlayers, function(enabled)
        MainModule.Misc.ESPPlayers = enabled
    end)
    espPlayersToggle.Parent = settingsContainer
    
    local espHighlightToggle = CreateToggle("ESP Highlight", UDim2.new(0, 0, 0.5, 0), MainModule.Misc.ESPHighlight, function(enabled)
        MainModule.Misc.ESPHighlight = enabled
    end)
    espHighlightToggle.Parent = settingsContainer
    
    local espDistanceToggle = CreateToggle("Show Distance", UDim2.new(0, 0, 0.75, 0), MainModule.Misc.ESPDistance, function(enabled)
        MainModule.Misc.ESPDistance = enabled
    end)
    espDistanceToggle.Parent = settingsContainer
    
    return settingsContainer
end

-- Функции для создания контента вкладок
local function CreateMainContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local speedLabel = CreateSpeedSlider()
    
    local speedToggle = CreateToggle("SpeedHack", UDim2.new(0.05, 0, 0.18, 0), MainModule.SpeedHack.Enabled, function(enabled)
        MainModule.ToggleSpeedHack(enabled)
    end)
    
    local antiStunToggle = CreateToggle("Anti Stun QTE", UDim2.new(0.05, 0, 0.26, 0), MainModule.AutoQTE.AntiStunEnabled, function(enabled)
        MainModule.ToggleAntiStunQTE(enabled)
    end)
    
    local antiStunRagdollToggle = CreateToggle("Anti Stun + Ragdoll", UDim2.new(0.05, 0, 0.34, 0), MainModule.Misc.AntiStunRagdoll, function(enabled)
        MainModule.ToggleAntiStunRagdoll(enabled)
    end)
    
    local instaInteractToggle = CreateToggle("Insta Interact", UDim2.new(0.05, 0, 0.42, 0), MainModule.Misc.InstaInteract, function(enabled)
        MainModule.ToggleInstaInteract(enabled)
    end)
    
    local noCooldownToggle = CreateToggle("No Cooldown Proximity", UDim2.new(0.05, 0, 0.5, 0), MainModule.Misc.NoCooldownProximity, function(enabled)
        MainModule.ToggleNoCooldownProximity(enabled)
    end)
    
    local tpUpBtn = CreateButton("TP 100 blocks up", UDim2.new(0.05, 0, 0.58, 0))
    tpUpBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportUp100()
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down", UDim2.new(0.05, 0, 0.66, 0))
    tpDownBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportDown40()
    end)
    
    local noclipLabel = CreateButton("Noclip: " .. MainModule.Noclip.Status, UDim2.new(0.05, 0, 0.74, 0))
    noclipLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    noclipLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
end

local function CreateCombatContent()
    SoonLabel.Visible = true
    SoonLabel.Text = "Combat Features Coming Soon"
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
end

local function CreateMiscContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    SoonLabel.Visible = false
    
    -- ESP System в Misc
    CreateESPSettings()
end

local function CreateRebelContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local rebelTitle = Instance.new("TextLabel")
    rebelTitle.Size = UDim2.new(0.9, 0, 0, 30)
    rebelTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
    rebelTitle.BackgroundTransparency = 1
    rebelTitle.Text = "REBEL"
    rebelTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    rebelTitle.TextSize = 16
    rebelTitle.Font = Enum.Font.GothamBold
    rebelTitle.Parent = ContentFrame
    
    local rebelToggle = CreateToggle("Instant Rebel", UDim2.new(0.05, 0, 0.2, 0), MainModule.Rebel.Enabled, function(enabled)
        MainModule.ToggleRebel(enabled)
    end)
end

local function CreateRLGLContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local tpEndBtn = CreateButton("TP TO END", UDim2.new(0.05, 0, 0.1, 0))
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToEnd()
    end)
    
    local tpStartBtn = CreateButton("TP TO START", UDim2.new(0.05, 0, 0.22, 0))
    tpStartBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToStart()
    end)
    
    local godModeToggle = CreateToggle("GodMode", UDim2.new(0.05, 0, 0.34, 0), MainModule.RLGL.GodMode, function(enabled)
        MainModule.ToggleGodMode(enabled)
    end)
end

local function CreateGuardsContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local guardDropdown = CreateDropdown({"Circle", "Triangle", "Square"}, MainModule.Guards.SelectedGuard, UDim2.new(0.05, 0, 0.1, 0), function(selected)
        MainModule.SetGuardType(selected)
    end)
    
    local spawnBtn = CreateButton("Spawn as Guard", UDim2.new(0.05, 0, 0.22, 0))
    spawnBtn.MouseButton1Click:Connect(function()
        MainModule.SpawnAsGuard()
    end)
    
    local rapidFireToggle = CreateToggle("Rapid Fire", UDim2.new(0.05, 0, 0.34, 0), MainModule.Guards.RapidFire, function(enabled)
        MainModule.ToggleRapidFire(enabled)
    end)
    
    local infiniteAmmoToggle = CreateToggle("Infinite Ammo", UDim2.new(0.05, 0, 0.46, 0), MainModule.Guards.InfiniteAmmo, function(enabled)
        MainModule.ToggleInfiniteAmmo(enabled)
    end)
    
    local hitboxToggle = CreateToggle("Hitbox Expander", UDim2.new(0.05, 0, 0.58, 0), MainModule.Guards.HitboxExpander, function(enabled)
        MainModule.ToggleHitboxExpander(enabled)
    end)
    
    local autoFarmToggle = CreateToggle("AutoFarm", UDim2.new(0.05, 0, 0.7, 0), MainModule.Guards.AutoFarm, function(enabled)
        MainModule.ToggleAutoFarm(enabled)
    end)
end

local function CreateDalgonaContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local completeBtn = CreateButton("Complete Dalgona", UDim2.new(0.05, 0, 0.1, 0))
    completeBtn.MouseButton1Click:Connect(function()
        MainModule.CompleteDalgona()
    end)
    
    local lighterBtn = CreateButton("Free Lighter", UDim2.new(0.05, 0, 0.22, 0))
    lighterBtn.MouseButton1Click:Connect(function()
        MainModule.FreeLighter()
    end)
end

local function CreateHNSContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local autoPickupToggle = CreateToggle("Auto Pickup", UDim2.new(0.05, 0, 0.1, 0), MainModule.HNS.AutoPickup, function(enabled)
        MainModule.ToggleAutoPickup(enabled)
    end)
    
    local spikesKillToggle = CreateToggle("Spikes Kill", UDim2.new(0.05, 0, 0.22, 0), MainModule.HNS.SpikesKill, function(enabled)
        MainModule.ToggleSpikesKill(enabled)
    end)
    
    local disableSpikesBtn = CreateButton("Disable Spikes", UDim2.new(0.05, 0, 0.34, 0))
    disableSpikesBtn.MouseButton1Click:Connect(function()
        MainModule.ToggleDisableSpikes(not MainModule.HNS.DisableSpikes)
        disableSpikesBtn.Text = MainModule.HNS.DisableSpikes and "Disable Spikes ✓" or "Disable Spikes"
    end)
    
    local deleteSpikesToggle = CreateToggle("Delete Spikes", UDim2.new(0.05, 0, 0.46, 0), MainModule.HNS.DeleteSpikes, function(enabled)
        MainModule.ToggleDeleteSpikes(enabled)
    end)
    
    local killHidersToggle = CreateToggle("Kill Hiders", UDim2.new(0.05, 0, 0.58, 0), MainModule.HNS.KillHiders, function(enabled)
        MainModule.ToggleKillHiders(enabled)
    end)
    
    local autoDodgeToggle = CreateToggle("AutoDodge", UDim2.new(0.05, 0, 0.7, 0), MainModule.HNS.AutoDodge, function(enabled)
        MainModule.ToggleAutoDodge(enabled)
    end)
end

local function CreateGlassBridgeContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local antiBreakToggle = CreateToggle("Anti Break", UDim2.new(0.05, 0, 0.1, 0), MainModule.GlassBridge.AntiBreak, function(enabled)
        MainModule.ToggleAntiBreak(enabled)
    end)
    
    local glassESPToggle = CreateToggle("Glass Bridge ESP", UDim2.new(0.05, 0, 0.22, 0), MainModule.GlassBridge.GlassESPEnabled, function(enabled)
        MainModule.ToggleGlassBridgeESP(enabled)
    end)
end

local function CreateTugOfWarContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local autoPullToggle = CreateToggle("Auto Pull", UDim2.new(0.05, 0, 0.1, 0), MainModule.TugOfWar.AutoPull, function(enabled)
        MainModule.ToggleAutoPull(enabled)
    end)
end

local function CreateJumpRopeContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local tpStartBtn = CreateButton("Teleport to Start", UDim2.new(0.05, 0, 0.1, 0))
    tpStartBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToJumpRopeStart()
    end)
    
    local tpEndBtn = CreateButton("Teleport to End", UDim2.new(0.05, 0, 0.22, 0))
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToJumpRopeEnd()
    end)
    
    local autoJumpToggle = CreateToggle("Auto Jump", UDim2.new(0.05, 0, 0.34, 0), MainModule.JumpRope.AutoJump, function(enabled)
        MainModule.ToggleAutoJump(enabled)
    end)
    
    local antiFailToggle = CreateToggle("Anti-Fail", UDim2.new(0.05, 0, 0.46, 0), MainModule.JumpRope.AntiFail, function(enabled)
        MainModule.ToggleAntiFailJumpRope(enabled)
    end)
end

local function CreateSettingsContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    local creatorLabel = CreateButton("Creator: Creon", UDim2.new(0.05, 0, 0.1, 0))
    creatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local versionLabel = CreateButton("Version: 2.0", UDim2.new(0.05, 0, 0.22, 0))
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local executorLabel = CreateButton("Executor: " .. executorName, UDim2.new(0.05, 0, 0.34, 0))
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local positionLabel = CreateButton("Position: " .. MainModule.GetPlayerPosition(), UDim2.new(0.05, 0, 0.46, 0))
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    game:GetService("RunService").Heartbeat:Connect(function()
        positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
    end)
end

-- Создание вкладок с очень маленькими кнопками
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Settings"}
for i, name in pairs(tabs) do
    local button = CreateButton(name, UDim2.new(0.05, 0, 0, (i-1)*28), UDim2.new(0.9, 0, 0, 24))
    button.Parent = TabButtons
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    button.TextSize = 10
    
    if name == "Main" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateMainContent()
        end)
    elseif name == "Combat" then
        button.MouseButton1Click:Connect(function()
            CreateCombatContent()
        end)
    elseif name == "Misc" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateMiscContent()
        end)
    elseif name == "Rebel" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateRebelContent()
        end)
    elseif name == "RLGL" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateRLGLContent()
        end)
    elseif name == "Guards" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateGuardsContent()
        end)
    elseif name == "Dalgona" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateDalgonaContent()
        end)
    elseif name == "HNS" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateHNSContent()
        end)
    elseif name == "Glass Bridge" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateGlassBridgeContent()
        end)
    elseif name == "Tug of War" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateTugOfWarContent()
        end)
    elseif name == "Jump Rope" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateJumpRopeContent()
        end)
    elseif name == "Settings" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateSettingsContent()
        end)
    end
end

-- Управление для ПК
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
        end
    end
end)

-- Автоматически открываем Main вкладку
CreateMainContent()

print("CreonHub v2.0 загружен...")
