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
                end)
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
            KillHiders = false, 
            AutoDodge = false,
            DisableSpikes = false
        },
        TugOfWar = {AutoPull = false},
        GlassBridge = {AntiBreak = false, GlassESPEnabled = false},
        JumpRope = {
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
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Сохраняем состояние мыши
local originalMouseBehavior = nil
local originalMouseIconEnabled = nil
local isGUIOpen = false

-- Функции управления мышью
local function EnableMouse()
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    UIS.MouseIconEnabled = true
    UIS.MouseIcon = "rbxasset://SystemCursors/Arrow"
end

local function RestoreMouse()
    if originalMouseBehavior then
        UIS.MouseBehavior = originalMouseBehavior
    end
    if originalMouseIconEnabled ~= nil then
        UIS.MouseIconEnabled = originalMouseIconEnabled
    end
end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local SoonLabel = Instance.new("TextLabel")

-- Анимированный фон с эффектами
local AnimatedBackground = Instance.new("Frame")
local Gradient = Instance.new("UIGradient")
local ParticleFrame = Instance.new("Frame")

-- Кнопка для мобильных устройств
local MobileButton = Instance.new("TextButton")

-- Подсветка вокруг меню
local OuterGlow = Instance.new("Frame")
local InnerGlow = Instance.new("Frame")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonX"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Увеличенные размеры на 15%
MainFrame.Size = UDim2.new(0, 750, 0, 520)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Анимированный градиентный фон
AnimatedBackground.Size = UDim2.new(1, 0, 1, 0)
AnimatedBackground.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
AnimatedBackground.BorderSizePixel = 0
AnimatedBackground.ZIndex = 0
AnimatedBackground.Parent = MainFrame

Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
})
Gradient.Rotation = 45
Gradient.Transparency = NumberSequence.new(0.7)
Gradient.Parent = AnimatedBackground

-- Создаем частицы для фона
for i = 1, 15 do
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(4, 10), 0, math.random(4, 10))
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    particle.BackgroundTransparency = 0.7
    particle.BorderSizePixel = 0
    particle.ZIndex = 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = particle
    
    particle.Parent = AnimatedBackground
    
    -- Анимация частиц
    spawn(function()
        while particle.Parent do
            TweenService:Create(particle, TweenInfo.new(math.random(2, 4), Enum.EasingStyle.Linear), {
                Position = UDim2.new(math.random(), 0, math.random(), 0)
            }):Play()
            wait(math.random(2, 4))
        end
    end)
end

-- Подсветка вокруг меню
OuterGlow.Size = UDim2.new(1, 10, 1, 10)
OuterGlow.Position = UDim2.new(0, -5, 0, -5)
OuterGlow.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OuterGlow.BackgroundTransparency = 0.8
OuterGlow.BorderSizePixel = 0
OuterGlow.ZIndex = -1
OuterGlow.Parent = MainFrame

InnerGlow.Size = UDim2.new(1, -4, 1, -4)
InnerGlow.Position = UDim2.new(0, 2, 0, 2)
InnerGlow.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
InnerGlow.BackgroundTransparency = 0.9
InnerGlow.BorderSizePixel = 0
InnerGlow.ZIndex = -1
InnerGlow.Parent = MainFrame

-- Анимация подсветки
spawn(function()
    while OuterGlow.Parent do
        TweenService:Create(OuterGlow, TweenInfo.new(2, Enum.EasingStyle.Linear), {
            BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        }):Play()
        wait(2)
        TweenService:Create(OuterGlow, TweenInfo.new(2, Enum.EasingStyle.Linear), {
            BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        }):Play()
        wait(2)
    end
end)

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 2
mainStroke.Parent = MainFrame

-- TitleBar для перемещения
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 10
TitleBar.Parent = MainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

TitleLabel.Size = UDim2.new(0.8, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.1, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CreonX v2.0"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Кнопка закрытия
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 11
CloseButton.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    isGUIOpen = false
    RestoreMouse()
    if UIS.TouchEnabled then
        MobileButton.Visible = true
    end
end)

-- Увеличенные табы
TabButtons.Size = UDim2.new(0, 160, 1, -35)
TabButtons.Position = UDim2.new(0, 0, 0, 35)
TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
TabButtons.BackgroundTransparency = 0.3
TabButtons.BorderSizePixel = 0
TabButtons.ZIndex = 5
TabButtons.Parent = MainFrame

local tabCorner = Instance.new("UICorner")
tabCorner.CornerRadius = UDim.new(0, 12)
tabCorner.Parent = TabButtons

ContentFrame.Size = UDim2.new(1, -160, 1, -35)
ContentFrame.Position = UDim2.new(0, 160, 0, 35)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ContentFrame.BackgroundTransparency = 0.3
ContentFrame.BorderSizePixel = 0
ContentFrame.ZIndex = 5
ContentFrame.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 12)
contentCorner.Parent = ContentFrame

SoonLabel.Size = UDim2.new(1, 0, 1, 0)
SoonLabel.BackgroundTransparency = 1
SoonLabel.Text = "Soon...."
SoonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SoonLabel.TextSize = 20
SoonLabel.Font = Enum.Font.GothamBold
SoonLabel.Visible = false
SoonLabel.ZIndex = 6
SoonLabel.Parent = ContentFrame

-- Кнопка для мобильных устройств
if UIS.TouchEnabled then
    MobileButton.Size = UDim2.new(0, 100, 0, 40)
    MobileButton.Position = UDim2.new(0.5, -50, 0, 10)
    MobileButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    MobileButton.BorderSizePixel = 0
    MobileButton.Text = "CreonX"
    MobileButton.TextColor3 = Color3.fromRGB(220, 220, 255)
    MobileButton.TextSize = 13
    MobileButton.Font = Enum.Font.GothamBold
    MobileButton.Parent = ScreenGui
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 8)
    mobileCorner.Parent = MobileButton
    
    local mobileStroke = Instance.new("UIStroke")
    mobileStroke.Color = Color3.fromRGB(80, 80, 100)
    mobileStroke.Thickness = 2
    mobileStroke.Parent = MobileButton
    
    MobileButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MobileButton.Visible = false
        isGUIOpen = true
        EnableMouse()
    end)
    
    MainFrame.Visible = false
else
    MainFrame.Visible = true
    isGUIOpen = true
    originalMouseBehavior = UIS.MouseBehavior
    originalMouseIconEnabled = UIS.MouseIconEnabled
    EnableMouse()
end

-- ESP System (исправленная)
MainModule.ESP = {
    Table = {},
    Players = {},
    Hiders = {},
    Seekers = {},
    Guards = {},
    Keys = {},
    Doors = {},
    Items = {},
    Connections = {},
    Enabled = false,
    
    Toggle = function(enabled)
        MainModule.ESP.Enabled = enabled
        
        if enabled then
            MainModule.ESP.Initialize()
        else
            MainModule.ESP.Cleanup()
        end
    end,
    
    Initialize = function()
        MainModule.ESP.Cleanup()
        
        -- ESP для игроков
        MainModule.ESP.Connections["PlayersAdded"] = Players.PlayerAdded:Connect(function(player)
            MainModule.ESP.AddPlayerESP(player)
        end)
        
        for _, player in pairs(Players:GetPlayers()) do
            MainModule.ESP.AddPlayerESP(player)
        end
        
        -- ESP для предметов HNS
        MainModule.ESP.Connections["Workspace"] = workspace.DescendantAdded:Connect(function(obj)
            if MainModule.ESP.Enabled then
                MainModule.ESP.CheckObject(obj)
            end
        end)
        
        -- Проверяем существующие объекты
        for _, obj in pairs(workspace:GetDescendants()) do
            MainModule.ESP.CheckObject(obj)
        end
    end,
    
    AddPlayerESP = function(player)
        if player == Players.LocalPlayer then return end
        
        MainModule.ESP.Connections["CharacterAdded_"..player.Name] = player.CharacterAdded:Connect(function(char)
            MainModule.ESP.CreatePlayerESP(player, char)
        end)
        
        if player.Character then
            MainModule.ESP.CreatePlayerESP(player, player.Character)
        end
    end,
    
    CreatePlayerESP = function(player, character)
        if not MainModule.ESP.Enabled then return end
        
        -- Ждем полной загрузки персонажа
        repeat wait() until character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")
        
        local espKey = "player_" .. player.Name
        
        -- Удаляем старый ESP если есть
        if MainModule.ESP.Table[espKey] then
            MainModule.ESP.Table[espKey]:Destroy()
        end
        
        -- Создаем BillboardGui для текста
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_" .. player.Name
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = character:WaitForChild("HumanoidRootPart")
        billboard.Parent = character:WaitForChild("HumanoidRootPart")
        
        -- Имя игрока
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Parent = billboard
        
        -- Дистанция
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "Distance"
        distanceLabel.Size = UDim2.new(1, 0, 0, 20)
        distanceLabel.Position = UDim2.new(0, 0, 0, 20)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.Text = "0 studs"
        distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distanceLabel.TextSize = 12
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.Parent = billboard
        
        -- Роль (Hider/Seeker)
        local roleLabel = Instance.new("TextLabel")
        roleLabel.Name = "Role"
        roleLabel.Size = UDim2.new(1, 0, 0, 20)
        roleLabel.Position = UDim2.new(0, 0, 0, 40)
        roleLabel.BackgroundTransparency = 1
        roleLabel.Text = "Player"
        roleLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
        roleLabel.TextSize = 12
        roleLabel.Font = Enum.Font.Gotham
        roleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        roleLabel.TextStrokeTransparency = 0
        roleLabel.Parent = billboard
        
        -- Highlight для визуализации
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(0, 170, 255)
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = character
        
        -- Функция обновления
        local function updateESP()
            if not character or not character.Parent or not character:FindFirstChild("HumanoidRootPart") then
                billboard:Destroy()
                highlight:Destroy()
                return false
            end
            
            -- Обновляем дистанцию
            local localPlayer = Players.LocalPlayer
            local localChar = localPlayer.Character
            if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                local distance = (localChar.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                distanceLabel.Text = math.floor(distance) .. " studs"
                
                -- Меняем цвет в зависимости от дистанции
                if distance < 20 then
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                elseif distance < 50 then
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                else
                    distanceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                end
            end
            
            -- Определяем роль игрока
            if player:GetAttribute("IsHider") then
                roleLabel.Text = "Hider"
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый для хайдеров
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                nameLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif player:GetAttribute("IsHunter") then
                roleLabel.Text = "Seeker"
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный для сикеров
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            else
                roleLabel.Text = "Player"
                highlight.FillColor = Color3.fromRGB(0, 170, 255) -- Синий для обычных игроков
                highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
            
            -- Проверяем здоровье
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if humanoid.Health <= 0 then
                    highlight.FillTransparency = 0.9
                    highlight.OutlineTransparency = 0.5
                    nameLabel.Text = player.Name .. " [DEAD]"
                else
                    highlight.FillTransparency = 0.7
                    highlight.OutlineTransparency = 0
                    nameLabel.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. " HP]"
                end
            end
            
            return true
        end
        
        -- Сохраняем ESP объект
        MainModule.ESP.Table[espKey] = {
            Billboard = billboard,
            Highlight = highlight,
            Update = updateESP,
            Destroy = function()
                if billboard and billboard.Parent then
                    billboard:Destroy()
                end
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
                MainModule.ESP.Table[espKey] = nil
            end
        }
        
        -- Запускаем обновление
        spawn(function()
            while MainModule.ESP.Table[espKey] and MainModule.ESP.Enabled do
                if not updateESP() then
                    break
                end
                wait(0.1)
            end
        end)
    end,
    
    CheckObject = function(obj)
        if obj:IsA("Model") then
            -- Ключи в HNS
            if obj.Name:lower():find("key") and obj.PrimaryPart then
                MainModule.ESP.CreateItemESP(obj, "Key", Color3.fromRGB(255, 255, 0))
            end
            
            -- Двери в HNS
            if obj.Name == "FullDoorAnimated" and obj.PrimaryPart then
                MainModule.ESP.CreateItemESP(obj, "Door", Color3.fromRGB(255, 150, 0))
            end
            
            -- Выходные двери
            if obj.Name == "EXITDOOR" and obj.PrimaryPart and obj:GetAttribute("CANESCAPE") then
                MainModule.ESP.CreateItemESP(obj, "Exit", Color3.fromRGB(0, 255, 0))
            end
        end
    end,
    
    CreateItemESP = function(obj, type, color)
        local espKey = "item_" .. obj.Name .. "_" .. obj:GetDebugId()
        
        if MainModule.ESP.Table[espKey] then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Item_" .. type
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 150, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Adornee = obj.PrimaryPart
        billboard.Parent = obj.PrimaryPart
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = type
        nameLabel.TextColor3 = color
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Parent = billboard
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = obj
        highlight.FillColor = color
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = color
        highlight.OutlineTransparency = 0.3
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = obj
        
        MainModule.ESP.Table[espKey] = {
            Billboard = billboard,
            Highlight = highlight,
            Destroy = function()
                if billboard and billboard.Parent then
                    billboard:Destroy()
                end
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
                MainModule.ESP.Table[espKey] = nil
            end
        }
        
        -- Удаляем ESP при удалении объекта
        obj.AncestryChanged:Connect(function()
            if not obj.Parent then
                if MainModule.ESP.Table[espKey] then
                    MainModule.ESP.Table[espKey]:Destroy()
                end
            end
        end)
    end,
    
    Cleanup = function()
        -- Отключаем все соединения
        for name, conn in pairs(MainModule.ESP.Connections) do
            conn:Disconnect()
        end
        MainModule.ESP.Connections = {}
        
        -- Удаляем все ESP объекты
        for key, espData in pairs(MainModule.ESP.Table) do
            if espData and type(espData.Destroy) == "function" then
                espData:Destroy()
            end
        end
        MainModule.ESP.Table = {}
    end
}

-- Обновляем функцию ToggleESP
local originalToggleESP = MainModule.ToggleESP
MainModule.ToggleESP = function(enabled)
    MainModule.Misc.ESPEnabled = enabled
    MainModule.ESP.Toggle(enabled)
    if originalToggleESP then
        originalToggleESP(enabled)
    end
end

-- Функция для создания очень маленьких кнопок с улучшенным дизайном
local function CreateButton(text, position, size)
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0.9, 0, 0, 32)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(240, 240, 255)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.ZIndex = 6
    button.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 100, 150)
    stroke.Thickness = 1.5
    stroke.Parent = button
    
    -- Гладкая анимация при наведении
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 90),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Color = Color3.fromRGB(100, 150, 255)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 60),
            TextColor3 = Color3.fromRGB(240, 240, 255)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Color = Color3.fromRGB(80, 100, 150)
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 50),
            Size = UDim2.new(button.Size.X.Scale - 0.02, button.Size.X.Offset, button.Size.Y.Scale - 0.02, button.Size.Y.Offset)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 90),
            Size = size or UDim2.new(0.9, 0, 0, 32)
        }):Play()
    end)
    
    return button
end

-- Функция для создания маленьких переключателей с улучшенным дизайном
local function CreateToggle(text, position, enabled, callback)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(0.9, 0, 0, 28)
    toggleContainer.Position = position
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.ZIndex = 6
    toggleContainer.Parent = ContentFrame
    
    -- Текст
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.65, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.ZIndex = 6
    textLabel.Parent = toggleContainer
    
    -- Переключатель (компактный)
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Size = UDim2.new(0.28, 0, 0.6, 0)
    toggleBackground.Position = UDim2.new(0.7, 0, 0.2, 0)
    toggleBackground.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(70, 70, 90)
    toggleBackground.BorderSizePixel = 0
    toggleBackground.ZIndex = 6
    toggleBackground.Parent = toggleContainer
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0.4, 0, 0.8, 0)
    toggleCircle.Position = enabled and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 7
    toggleCircle.Parent = toggleBackground
    
    -- Закругления
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(1, 0)
    corner1.Parent = toggleBackground
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(1, 0)
    corner2.Parent = toggleCircle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 120, 160)
    stroke.Thickness = 1.2
    stroke.Parent = toggleBackground
    
    -- Кнопка для переключения
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.ZIndex = 8
    toggleButton.Parent = toggleContainer
    
    local function updateToggle(newState)
        enabled = newState
        TweenService:Create(toggleBackground, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundColor3 = newState and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(70, 70, 90)
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = newState and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.05, 0, 0.1, 0)
        }):Play()
        
        if callback then
            callback(newState)
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        updateToggle(not enabled)
    end)
    
    return toggleContainer
end

-- Функция для создания слайдера скорости
local function CreateSpeedSlider()
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Size = UDim2.new(0.9, 0, 0, 55)
    sliderContainer.Position = UDim2.new(0.05, 0, 0.05, 0)
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.ZIndex = 6
    sliderContainer.Parent = ContentFrame
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. MainModule.SpeedHack.CurrentSpeed
    speedLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.ZIndex = 6
    speedLabel.Parent = sliderContainer
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Size = UDim2.new(1, 0, 0, 20)
    sliderBackground.Position = UDim2.new(0, 0, 0, 25)
    sliderBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    sliderBackground.BorderSizePixel = 0
    sliderBackground.ZIndex = 6
    sliderBackground.Parent = sliderContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = sliderBackground
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((MainModule.SpeedHack.CurrentSpeed - MainModule.SpeedHack.MinSpeed) / (MainModule.SpeedHack.MaxSpeed - MainModule.SpeedHack.MinSpeed), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 7
    sliderFill.Parent = sliderBackground
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -10, 0, 0)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.ZIndex = 8
    sliderButton.Parent = sliderBackground
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = sliderButton
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(100, 150, 255)
    buttonStroke.Thickness = 2
    buttonStroke.Parent = sliderButton
    
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

-- Функция для создания выпадающего списка
local function CreateDropdown(options, default, position, callback)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(0.9, 0, 0, 32)
    dropdownContainer.Position = position
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Parent = ContentFrame
    dropdownContainer.ZIndex = 10
    
    local dropdownButton = CreateButton(default, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 1, 0))
    dropdownButton.Parent = dropdownContainer
    dropdownButton.Text = default .. " ▼"
    dropdownButton.ZIndex = 11
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(1, 0, 0, #options * 32)
    dropdownList.Position = UDim2.new(0, 0, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.Parent = dropdownContainer
    dropdownList.ZIndex = 20
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = dropdownList
    
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(80, 100, 150)
    listStroke.Thickness = 1.5
    listStroke.Parent = dropdownList
    
    for i, option in ipairs(options) do
        local optionButton = CreateButton(option, UDim2.new(0.05, 0, 0, (i-1)*32), UDim2.new(0.9, 0, 0, 28))
        optionButton.Parent = dropdownList
        optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        optionButton.ZIndex = 21
        
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
    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdownList.Visible then
            if not (dropdownContainer:IsDescendantOf(ScreenGui) and dropdownList:IsMouseOver()) then
                dropdownList.Visible = false
            end
        end
    end)
    
    return dropdownContainer
end

-- Функция для создания ESP настроек
local function CreateESPSettings()
    local settingsContainer = Instance.new("Frame")
    settingsContainer.Size = UDim2.new(0.9, 0, 0, 140)
    settingsContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
    settingsContainer.BackgroundTransparency = 1
    settingsContainer.ZIndex = 6
    settingsContainer.Parent = ContentFrame
    
    local espToggle = CreateToggle("ESP System", UDim2.new(0, 0, 0, 0), MainModule.Misc.ESPEnabled, function(enabled)
        MainModule.ToggleESP(enabled)
    end)
    espToggle.Parent = settingsContainer
    
    local espPlayersToggle = CreateToggle("Show Players", UDim2.new(0, 0, 0, 30), MainModule.Misc.ESPPlayers, function(enabled)
        MainModule.Misc.ESPPlayers = enabled
        if MainModule.ESP.Enabled then
            MainModule.ESP.Toggle(false)
            MainModule.ESP.Toggle(true)
        end
    end)
    espPlayersToggle.Parent = settingsContainer
    
    local espHighlightToggle = CreateToggle("ESP Highlight", UDim2.new(0, 0, 0, 60), MainModule.Misc.ESPHighlight, function(enabled)
        MainModule.Misc.ESPHighlight = enabled
    end)
    espHighlightToggle.Parent = settingsContainer
    
    local espDistanceToggle = CreateToggle("Show Distance", UDim2.new(0, 0, 0, 90), MainModule.Misc.ESPDistance, function(enabled)
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
    
    SoonLabel.Visible = false
    
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
    rebelTitle.Size = UDim2.new(0.9, 0, 0, 35)
    rebelTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
    rebelTitle.BackgroundTransparency = 1
    rebelTitle.Text = "REBEL"
    rebelTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
    rebelTitle.TextSize = 18
    rebelTitle.Font = Enum.Font.GothamBold
    rebelTitle.ZIndex = 6
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
    
    SoonLabel.Visible = false
    
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
    
    SoonLabel.Visible = false
    
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
    
    SoonLabel.Visible = false
    
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
    
    SoonLabel.Visible = false
    
    local autoPickupToggle = CreateToggle("Auto Pickup", UDim2.new(0.05, 0, 0.1, 0), MainModule.HNS.AutoPickup, function(enabled)
        MainModule.ToggleAutoPickup(enabled)
    end)
    
    local spikesKillToggle = CreateToggle("Spikes Kill", UDim2.new(0.05, 0, 0.22, 0), MainModule.HNS.SpikesKill, function(enabled)
        MainModule.ToggleSpikesKill(enabled)
    end)
    
    local disableSpikesToggle = CreateToggle("Disable Spikes", UDim2.new(0.05, 0, 0.34, 0), MainModule.HNS.DisableSpikes, function(enabled)
        MainModule.ToggleDisableSpikes(enabled)
    end)
    
    local killHidersToggle = CreateToggle("Kill Hiders", UDim2.new(0.05, 0, 0.46, 0), MainModule.HNS.KillHiders, function(enabled)
        MainModule.ToggleKillHiders(enabled)
    end)
    
    local autoDodgeToggle = CreateToggle("AutoDodge", UDim2.new(0.05, 0, 0.58, 0), MainModule.HNS.AutoDodge, function(enabled)
        MainModule.ToggleAutoDodge(enabled)
    end)
end

local function CreateGlassBridgeContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    SoonLabel.Visible = false
    
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
    
    SoonLabel.Visible = false
    
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
    
    SoonLabel.Visible = false
    
    local tpStartBtn = CreateButton("Teleport to Start", UDim2.new(0.05, 0, 0.1, 0))
    tpStartBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToJumpRopeStart()
    end)
    
    local tpEndBtn = CreateButton("Teleport to End", UDim2.new(0.05, 0, 0.22, 0))
    tpEndBtn.MouseButton1Click:Connect(function()
        MainModule.TeleportToJumpRopeEnd()
    end)
    
    local antiFailToggle = CreateToggle("Anti-Fail", UDim2.new(0.05, 0, 0.34, 0), MainModule.JumpRope.AntiFail, function(enabled)
        MainModule.ToggleAntiFailJumpRope(enabled)
    end)
end

local function CreateSettingsContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child ~= SoonLabel then
            child:Destroy()
        end
    end
    
    SoonLabel.Visible = false
    
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

-- Создание вкладок с улучшенным дизайном
local tabs = {"Main", "Combat", "Misc", "Rebel", "RLGL", "Guards", "Dalgona", "HNS", "Glass Bridge", "Tug of War", "Jump Rope", "Settings"}
local tabButtons = {}

for i, name in pairs(tabs) do
    local button = CreateButton(name, UDim2.new(0.05, 0, 0, (i-1)*36), UDim2.new(0.9, 0, 0, 32))
    button.Parent = TabButtons
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    button.TextSize = 12
    button.ZIndex = 6
    
    table.insert(tabButtons, button)
    
    if name == "Main" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateMainContent()
            -- Подсвечиваем активную вкладку
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Combat" then
        button.MouseButton1Click:Connect(function()
            CreateCombatContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Misc" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateMiscContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Rebel" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateRebelContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "RLGL" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateRLGLContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Guards" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateGuardsContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Dalgona" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateDalgonaContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "HNS" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateHNSContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Glass Bridge" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateGlassBridgeContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Tug of War" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateTugOfWarContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Jump Rope" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateJumpRopeContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    elseif name == "Settings" then
        button.MouseButton1Click:Connect(function()
            SoonLabel.Visible = false
            CreateSettingsContent()
            for _, btn in pairs(tabButtons) do
                TweenService:Create(btn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 55)
                }):Play()
            end
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            }):Play()
        end)
    end
end

-- Управление для ПК
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
        isGUIOpen = MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
            EnableMouse()
        else
            RestoreMouse()
        end
    end
end)

-- Защита от кликов вне меню когда оно открыто
local function handleInput(input)
    if isGUIOpen and MainFrame.Visible then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.MouseButton2 or
           input.UserInputType == Enum.UserInputType.Touch then
           
            local mousePos = input.Position
            local framePos = MainFrame.AbsolutePosition
            local frameSize = MainFrame.AbsoluteSize
            
            -- Если клик вне меню, предотвращаем действие
            if not (mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
                    mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y) then
                return
            end
        end
    end
end

UIS.InputBegan:Connect(handleInput)

-- Автоматически открываем Main вкладку и активируем первую кнопку
CreateMainContent()
if tabButtons[1] then
    TweenService:Create(tabButtons[1], TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    }):Play()
end

print("CreonHub v2.0 загружен...")

-- При закрытии игры восстанавливаем состояние мыши
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        RestoreMouse()
    end
end)
