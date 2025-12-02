-- Creon X v2.1 (исправленная версия с поддержкой Delta)
-- Проверка исполнителя
local executorName = "Unknown"
if identifyexecutor then
    executorName = identifyexecutor()
elseif getexecutorname then
    executorName = getexecutorname()
end

-- Поддержка для Delta (мобильные устройства)
if executorName == "Unknown" then
    -- Проверяем Delta через окружение
    if type(syn) == "table" and syn.request then
        executorName = "Delta"
    elseif get_hidden_gui then
        executorName = "Delta"
    elseif tostring(getfenv):find("Delta") then
        executorName = "Delta"
    end
end

print("Executor detected:", executorName)

local supportedExecutors = {"xeno", "bunnu", "volcano", "potassium", "seliware", "zenith", "bunni", "delta", "scriptware", "krnl", "oxygen", "fluxus"}
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

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Загрузка Main модуля
local MainModule
local success, err = pcall(function()
    -- Попробуем загрузить с GitHub
    local url = "https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Main.lua"
    local content = game:HttpGet(url, true)
    MainModule = loadstring(content)()
    print("Main.lua успешно загружен с GitHub")
end)

if not success then
    warn("Не удалось загрузить Main.lua с GitHub: " .. tostring(err))
    print("Используем встроенную реализацию")
    
    -- Создаем мини-реализацию MainModule
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
            OriginalAmmo = {},
            OriginalHitboxes = {}
        },
        Dalgona = {CompleteEnabled = false, FreeLighterEnabled = false},
        HNS = {
            SpikesKill = false, 
            DisableSpikes = false, 
            KillHiders = false, 
            AutoDodge = false,
            LastDodgeTime = 0,
            DodgeCooldown = 1.0,
            DodgeRange = 10,
            LastDodgeKeyTime = 0,
            DodgeKeyCooldown = 0.1
        },
        TugOfWar = {AutoPull = false},
        GlassBridge = {
            AntiBreak = false, 
            GlassESPEnabled = false,
            GlassPlatform = false,
            FakeGlassCover = false,
            AntiFallPlatform = nil
        },
        JumpRope = {TeleportToEnd = false, DeleteRope = false},
        SkySquid = {AntiFall = false, VoidKill = false, AntiFallPlatform = nil, SafePlatform = nil},
        Misc = {
            InstaInteract = false, 
            NoCooldownProximity = false,
            ESPEnabled = false,
            ESPPlayers = true,
            ESPHiders = true,
            ESPSeekers = true,
            ESPCandies = false,
            ESPKeys = true,
            ESPDoors = true,
            ESPEscapeDoors = true,
            ESPGuards = true,
            ESPHighlight = true,
            ESPDistance = true,
            ESPNames = true,
            ESPBoxes = true,
            ESPFillTransparency = 0.7,
            ESPOutlineTransparency = 0,
            ESPTextSize = 18,
            AntiStunRagdoll = false
        },
        
        -- Реализация функций
        ToggleSpeedHack = function(enabled)
            MainModule.SpeedHack.Enabled = enabled
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if enabled then
                        MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
                        humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                    else
                        humanoid.WalkSpeed = MainModule.SpeedHack.DefaultSpeed
                    end
                end
            end
        end,
        
        SetSpeed = function(value)
            if value < MainModule.SpeedHack.MinSpeed then
                value = MainModule.SpeedHack.MinSpeed
            elseif value > MainModule.SpeedHack.MaxSpeed then
                value = MainModule.SpeedHack.MaxSpeed
            end
            
            MainModule.SpeedHack.CurrentSpeed = value
            
            if MainModule.SpeedHack.Enabled then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = value
                    end
                end
            end
            
            return value
        end,
        
        TeleportUp100 = function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
            end
        end,
        
        TeleportDown40 = function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + Vector3.new(0, -40, 0)
            end
        end,
        
        ToggleAntiStunQTE = function(enabled)
            MainModule.AutoQTE.AntiStunEnabled = enabled
        end,
        
        ToggleAntiStunRagdoll = function(enabled)
            MainModule.Misc.AntiStunRagdoll = enabled
        end,
        
        ToggleRebel = function(enabled)
            MainModule.Rebel.Enabled = enabled
        end,
        
        TeleportToEnd = function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
            end
        end,
        
        TeleportToStart = function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
            end
        end,
        
        ToggleGodMode = function(enabled)
            MainModule.RLGL.GodMode = enabled
        end,
        
        SetGuardType = function(guardType)
            MainModule.Guards.SelectedGuard = guardType
        end,
        
        SpawnAsGuard = function()
            local args = {{AttemptToSpawnAsGuard = MainModule.Guards.SelectedGuard}}
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote"):FireServer(unpack(args))
            end)
        end,
        
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
        
        FreeLighter = function() 
            player:SetAttribute("HasLighter", true)
        end,
        
        ToggleSpikesKill = function(enabled)
            MainModule.HNS.SpikesKill = enabled
        end,
        
        ToggleDisableSpikes = function(enabled)
            MainModule.HNS.DisableSpikes = enabled
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
        
        CreateGlassBridgeCover = function() end,
        RemoveGlassBridgeCover = function() end,
        CreateHugeAntiFallPlatform = function() end,
        RemoveHugeAntiFallPlatform = function() end,
        
        TeleportToJumpRopeEnd = function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
            end
        end,
        
        DeleteJumpRope = function()
            if game.Workspace:FindFirstChild("Effects") then
                local rope = game.Workspace.Effects:FindFirstChild("rope")
                if rope then
                    rope:Destroy()
                end
            end
        end,
        
        ToggleSkySquidAntiFall = function(enabled)
            MainModule.SkySquid.AntiFall = enabled
        end,
        
        ToggleSkySquidVoidKill = function(enabled)
            MainModule.SkySquid.VoidKill = enabled
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
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local position = character.HumanoidRootPart.Position
                return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
            end
            return "Не доступно"
        end,
        
        Cleanup = function() 
            warn("Cleanup выполнен")
        end
    }
end

-- Определяем платформу (ПК или мобильное устройство)
local isMobile = UIS.TouchEnabled or executorName:lower():find("delta")

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
local SoonLabel = Instance.new("TextLabel")

-- Кнопка для мобильных устройств
local MobileOpenButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXv21"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Настройки размеров для разных платформ
local GUI_WIDTH, GUI_HEIGHT
if isMobile then
    -- Для мобильных устройств (Delta)
    GUI_WIDTH = 900
    GUI_HEIGHT = 650
else
    -- Для ПК
    GUI_WIDTH = 860
    GUI_HEIGHT = 595
end

-- Основной фрейм
MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, GUI_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 2
mainStroke.Parent = MainFrame

-- TitleBar для перемещения
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Creon X v2.1"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка скрытия (_)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "_"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    if isMobile then
        MobileOpenButton.Visible = true
    end
end)

-- Табы
TabButtons.Size = UDim2.new(0, 160, 1, -40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 12)
tabCorner.Parent = TabButtons

-- Content Frame с прокруткой
ContentFrame.Size = UDim2.new(1, -160, 1, -40)
ContentFrame.Position = UDim2.new(0, 160, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = ContentFrame

-- Scrolling Frame для контента
ContentScrolling.Size = UDim2.new(1, -15, 1, -15)
ContentScrolling.Position = UDim2.new(0, 8, 0, 8)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.ScrollBarThickness = isMobile and 10 or 8
ContentScrolling.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
ContentScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentScrolling.Parent = ContentFrame

ContentLayout.Padding = UDim.new(0, isMobile and 10 or 8)
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

-- Кнопка OPEN для мобильных устройств
if isMobile then
    MobileOpenButton.Size = UDim2.new(0, 120, 0, 45)
    MobileOpenButton.Position = UDim2.new(0.5, -60, 0.1, 0) -- Чуть выше центра
    MobileOpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    MobileOpenButton.BorderSizePixel = 0
    MobileOpenButton.Text = "OPEN"
    MobileOpenButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    MobileOpenButton.TextSize = 14
    MobileOpenButton.Font = Enum.Font.GothamBold
    MobileOpenButton.Parent = ScreenGui
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 10)
    mobileCorner.Parent = MobileOpenButton
    
    local mobileStroke = Instance.new("UIStroke")
    mobileStroke.Color = Color3.fromRGB(70, 70, 90)
    mobileStroke.Thickness = 2
    mobileStroke.Parent = MobileOpenButton
    
    -- Тень для кнопки
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = MobileOpenButton
    
    -- Анимация при наведении (для ПК, если Delta на ПК)
    if not UIS.TouchEnabled then
        MobileOpenButton.MouseEnter:Connect(function()
            TweenService:Create(MobileOpenButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            }):Play()
        end)
        
        MobileOpenButton.MouseLeave:Connect(function()
            TweenService:Create(MobileOpenButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            }):Play()
        end)
    end
    
    MobileOpenButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MobileOpenButton.Visible = false
    end)
    
    -- Делаем кнопку перемещаемой
    local mobileDragging = false
    local mobileDragStart, mobileStartPos
    
    local function updateMobilePos(input)
        local delta = input.Position - mobileDragStart
        MobileOpenButton.Position = UDim2.new(
            mobileStartPos.X.Scale, 
            mobileStartPos.X.Offset + delta.X,
            mobileStartPos.Y.Scale, 
            mobileStartPos.Y.Offset + delta.Y
        )
    end
    
    MobileOpenButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mobileDragging = true
            mobileDragStart = input.Position
            mobileStartPos = MobileOpenButton.Position
            
            -- Эффект нажатия
            TweenService:Create(MobileOpenButton, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 70)
            }):Play()
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    mobileDragging = false
                    TweenService:Create(MobileOpenButton, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    }):Play()
                end
            end)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if mobileDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateMobilePos(input)
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
        
        -- Эффект нажатия
        TweenService:Create(TitleBar, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        }):Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(TitleBar, TweenInfo.new(0.1), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                }):Play()
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
    button.Size = UDim2.new(1, -10, 0, isMobile and 40 or 36)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(240, 240, 255)
    button.TextSize = isMobile and 13 or 12
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = ContentScrolling
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1.2
    stroke.Parent = button
    
    -- Анимация при наведении (только для ПК)
    if not isMobile or not UIS.TouchEnabled then
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
    end
    
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
    toggleContainer.Size = UDim2.new(1, -10, 0, isMobile and 40 or 36)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = ContentScrolling
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.7, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    textLabel.TextSize = isMobile and 13 or 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = toggleContainer
    
    -- Переключатель
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Size = UDim2.new(0, isMobile and 60 or 50, 0, isMobile and 26 or 22)
    toggleBackground.Position = UDim2.new(1, isMobile and -62 or -52, 0.5, isMobile and -13 or -11)
    toggleBackground.BackgroundColor3 = enabled and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(80, 80, 100)
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = toggleContainer
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, isMobile and 22 or 18, 0, isMobile and 22 or 18)
    toggleCircle.Position = enabled and UDim2.new(1, isMobile and -24 or -20, 0.5, isMobile and -11 or -9) or UDim2.new(0, 2, 0.5, isMobile and -11 or -9)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBackground
    
    -- Закругления
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, isMobile and 13 or 11)
    corner1.Parent = toggleBackground
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, isMobile and 11 or 9)
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
            Position = newState and UDim2.new(1, isMobile and -24 or -20, 0.5, isMobile and -11 or -9) or UDim2.new(0, 2, 0.5, isMobile and -11 or -9)
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
    sliderContainer.Size = UDim2.new(1, -10, 0, isMobile and 70 or 60)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Parent = ContentScrolling
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, isMobile and 25 or 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. MainModule.SpeedHack.CurrentSpeed
    speedLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    speedLabel.TextSize = isMobile and 14 or 12
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.Parent = sliderContainer
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, 0, 0, isMobile and 25 or 20)
    sliderBackground.Position = UDim2.new(0, 0, 0, isMobile and 30 or 25)
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
    sliderButton.Size = UDim2.new(0, isMobile and 25 or 20, 0, isMobile and 25 or 20)
    sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, isMobile and -12.5 or -10, 0, 0)
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
        sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, isMobile and -12.5 or -10, 0, 0)
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
local function CreateDropdown(options, default, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(1, -10, 0, isMobile and 40 or 36)
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = ContentScrolling
    
    local dropdownButton = CreateButton(default .. " ▼")
    dropdownButton.Parent = dropdownContainer
    dropdownButton.Size = UDim2.new(1, 0, 1, 0)
    dropdownButton.Position = UDim2.new(0, 0, 0, 0)
    dropdownButton.Text = default .. " ▼"
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, #options * (isMobile and 42 or 38))
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.Parent = dropdownContainer
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = dropdownList
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(80, 80, 100)
    listStroke.Thickness = 1
    listStroke.Parent = dropdownList
    
    for i, option in ipairs(options) do
        local optionButton = CreateButton(option)
        optionButton.Parent = dropdownList
        optionButton.Size = UDim2.new(1, -8, 0, isMobile and 36 or 32)
        optionButton.Position = UDim2.new(0, 4, 0, (i-1)*(isMobile and 42 or 38) + 3)
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
    
    -- Закрываем при клике вне списка
    if not isMobile then
        UIS.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownList.Visible then
                if not dropdownContainer:IsDescendantOf(input.Target) then
                    dropdownList.Visible = false
                end
            end
        end)
    end
    
    return dropdownContainer
end

-- Функции для создания контента вкладок
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
    
    local speedLabel = CreateSpeedSlider()
    
    local speedToggle, updateSpeedToggle = CreateToggle("SpeedHack", MainModule.SpeedHack.Enabled, function(enabled)
        MainModule.ToggleSpeedHack(enabled)
    end)
    
    local antiStunToggle, updateAntiStunToggle = CreateToggle("Anti Stun QTE", MainModule.AutoQTE.AntiStunEnabled, function(enabled)
        MainModule.ToggleAntiStunQTE(enabled)
    end)
    
    local antiStunRagdollToggle, updateAntiStunRagdollToggle = CreateToggle("Anti Stun + Ragdoll", MainModule.Misc.AntiStunRagdoll, function(enabled)
        MainModule.ToggleAntiStunRagdoll(enabled)
    end)
    
    local instaInteractToggle, updateInstaInteractToggle = CreateToggle("Insta Interact", MainModule.Misc.InstaInteract, function(enabled)
        MainModule.ToggleInstaInteract(enabled)
    end)
    
    local noCooldownToggle, updateNoCooldownToggle = CreateToggle("No Cooldown Proximity", MainModule.Misc.NoCooldownProximity, function(enabled)
        MainModule.ToggleNoCooldownProximity(enabled)
    end)
    
    local tpUpBtn = CreateButton("TP 100 blocks up")
    tpUpBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportUp100()
    end)
    
    local tpDownBtn = CreateButton("TP 40 blocks down")
    tpDownBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportDown40()
    end)
    
    local noclipLabel = CreateButton("Noclip: " .. MainModule.Noclip.Status)
    noclipLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    noclipLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    
    -- Новые функции Main
    local unlockDashToggle, updateUnlockDashToggle = CreateToggle("Unlock Dash (Don't work)", false, function(enabled)
        MainModule.UnlockDash = enabled
        warn("Unlock Dash: Эта функция временно недоступна")
    end)
    
    local unlockPhantomToggle, updateUnlockPhantomToggle = CreateToggle("Unlock Phantom Step (Don't work)", false, function(enabled)
        MainModule.UnlockPhantomStep = enabled
        warn("Unlock Phantom Step: Эта функция временно недоступна")
    end)
    
    local antiStunToggle2, updateAntiStunToggle2 = CreateToggle("Anti Stun", MainModule.AntiStun or false, function(enabled)
        MainModule.AntiStun = enabled
        if MainModule.ToggleAntiStun then
            MainModule.ToggleAntiStun(enabled)
        end
    end)
    
    local antiRagdollToggle, updateAntiRagdollToggle = CreateToggle("Anti Ragdoll", MainModule.AntiRagdoll or false, function(enabled)
        MainModule.AntiRagdoll = enabled
        if MainModule.ToggleAntiRagdoll then
            MainModule.ToggleAntiRagdoll(enabled)
        end
    end)
    
    local removeInjuredToggle, updateRemoveInjuredToggle = CreateToggle("Remove Injured Walking", MainModule.RemoveInjuredWalking or false, function(enabled)
        MainModule.RemoveInjuredWalking = enabled
        if MainModule.ToggleRemoveInjuredWalking then
            MainModule.ToggleRemoveInjuredWalking(enabled)
        end
    end)
    
    local removeStunToggle, updateRemoveStunToggle = CreateToggle("Remove Stun Effects", MainModule.RemoveStunEffects or false, function(enabled)
        MainModule.RemoveStunEffects = enabled
        -- Здесь будет реализация
    end)
    
    local removeAllDebuffsBtn = CreateButton("Remove All Debuffs Now")
    removeAllDebuffsBtn.MouseButton1Click:Connect(function()
        if MainModule.RemoveAllDebuffs then
            local count = MainModule.RemoveAllDebuffs()
            warn("Удалено " .. count .. " дебаффов")
        end
    end)
end

local function CreateCombatContent()
    ClearContent()
    SoonLabel.Visible = true
    SoonLabel.Text = "Combat Features Coming Soon"
end

local function CreateMiscContent()
    ClearContent()
    
    -- ESP настройки
    local espToggle, updateEspToggle = CreateToggle("ESP System", MainModule.Misc.ESPEnabled, function(enabled)
        MainModule.ToggleESP(enabled)
    end)
    
    local espPlayersToggle, updateEspPlayersToggle = CreateToggle("Show Players", MainModule.Misc.ESPPlayers, function(enabled)
        MainModule.Misc.ESPPlayers = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espHidersToggle, updateEspHidersToggle = CreateToggle("Show Hiders", MainModule.Misc.ESPHiders, function(enabled)
        MainModule.Misc.ESPHiders = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espSeekersToggle, updateEspSeekersToggle = CreateToggle("Show Seekers", MainModule.Misc.ESPSeekers, function(enabled)
        MainModule.Misc.ESPSeekers = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espGuardsToggle, updateEspGuardsToggle = CreateToggle("Show Guards", MainModule.Misc.ESPGuards, function(enabled)
        MainModule.Misc.ESPGuards = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espCandiesToggle, updateEspCandiesToggle = CreateToggle("Show Candies", MainModule.Misc.ESPCandies, function(enabled)
        MainModule.Misc.ESPCandies = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espKeysToggle, updateEspKeysToggle = CreateToggle("Show Keys", MainModule.Misc.ESPKeys, function(enabled)
        MainModule.Misc.ESPKeys = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espDoorsToggle, updateEspDoorsToggle = CreateToggle("Show Doors", MainModule.Misc.ESPDoors, function(enabled)
        MainModule.Misc.ESPDoors = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espExitDoorsToggle, updateEspExitDoorsToggle = CreateToggle("Show Exit Doors", MainModule.Misc.ESPEscapeDoors, function(enabled)
        MainModule.Misc.ESPEscapeDoors = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espNamesToggle, updateEspNamesToggle = CreateToggle("Show Names", MainModule.Misc.ESPNames, function(enabled)
        MainModule.Misc.ESPNames = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espDistanceToggle, updateEspDistanceToggle = CreateToggle("Show Distance", MainModule.Misc.ESPDistance, function(enabled)
        MainModule.Misc.ESPDistance = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espSnowToggle, updateEspSnowToggle = CreateToggle("Show Snow", MainModule.Misc.ESPShowSnow or true, function(enabled)
        MainModule.Misc.ESPShowSnow = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espHPToggle, updateEsphptoggle = CreateToggle("Show HP", MainModule.Misc.ESPShowHP or true, function(enabled)
        MainModule.Misc.ESPShowHP = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espBoxesToggle, updateEspBoxesToggle = CreateToggle("Show Boxes", MainModule.Misc.ESPBoxes, function(enabled)
        MainModule.Misc.ESPBoxes = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
    
    local espHighlightToggle, updateEspHighlightToggle = CreateToggle("Show Highlight", MainModule.Misc.ESPHighlight, function(enabled)
        MainModule.Misc.ESPHighlight = enabled
        if MainModule.UpdateESPSettings then
            MainModule.UpdateESPSettings()
        end
    end)
end

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

local function CreateGuardsContent()
    ClearContent()
    
    -- Дропдаун выше кнопок
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
    
    local antiFallToggle, updateAntiFallToggle = CreateToggle("Anti Fall", false, function(enabled)
        if enabled then
            if MainModule.CreateJumpRopeAntiFall then
                MainModule.CreateJumpRopeAntiFall()
            end
        else
            if MainModule.JumpRope and MainModule.JumpRope.AntiFallPlatform then
                MainModule.JumpRope.AntiFallPlatform:Destroy()
                MainModule.JumpRope.AntiFallPlatform = nil
            end
        end
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
    
    local executorLabel = CreateButton("Executor: " .. executorName)
    executorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local positionLabel = CreateButton("Position: " .. MainModule.GetPlayerPosition())
    positionLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local platformLabel = CreateButton("Platform: " .. (isMobile and "Mobile (Delta)" or "PC"))
    platformLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local cleanupBtn = CreateButton("Cleanup Script")
    cleanupBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    cleanupBtn.MouseButton1Click:Connect(function()
        MainModule.Cleanup()
        ScreenGui:Destroy()
    end)
    
    -- Обновление позиции
    game:GetService("RunService").Heartbeat:Connect(function()
        positionLabel.Text = "Position: " .. MainModule.GetPlayerPosition()
    end)
end

-- Создание кнопок вкладок
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Sky Squid", "Settings"}
local tabButtons = {}
local tabContainers = {}

for i, name in pairs(tabs) do
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.9, 0, 0, isMobile and 42 or 38)
    buttonContainer.Position = UDim2.new(0.05, 0, 0, (i-1)*(isMobile and 46 or 42) + 10)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = TabButtons
    
    local button = CreateButton(name)
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Position = UDim2.new(0, 0, 0, 0)
    button.Parent = buttonContainer
    button.TextSize = isMobile and 13 or 12
    
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
    end
    
    button.MouseButton1Click:Connect(ActivateTab)
end

-- Управление для ПК
if not isMobile then
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.M then
            MainFrame.Visible = not MainFrame.Visible
            if MainFrame.Visible then
                MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.5, -GUI_HEIGHT/2)
            end
        end
    end)
    
    -- Закрытие при нажатии ESC
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Escape and MainFrame.Visible then
            MainFrame.Visible = false
        end
    end)
end

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

print("Creon X v2.1 загружен...")
print("Платформа: " .. (isMobile and "Mobile (Delta)" or "PC"))
print("Исполнитель: " .. executorName)
