-- Main.lua - Creon X v2.3 (Полная версия с правильным Antifall)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Переменные
MainModule.SpeedHack = {
    Enabled = false,
    DefaultSpeed = 16,
    CurrentSpeed = 16,
    MaxSpeed = 150,
    MinSpeed = 16
}

MainModule.Noclip = {
    Enabled = false,
    Status = "Don't work, Disabled"
}

MainModule.AutoQTE = {
    AntiStunEnabled = false
}

MainModule.Rebel = {
    Enabled = false,
    Connection = nil,
    LastKillTime = 0,
    KillCooldown = 0.1,
    LastCheckTime = 0,
    CheckCooldown = 0.5
}

-- RLGL System
MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    LastDamageTime = 0,
    DamageCheckRate = 0.1,
    LastHealth = 100,
    GodModeHeight = 160,
    NormalHeight = 80,
    DamageTeleportPosition = Vector3.new(-903.4, 1184.9, -556),
    StartPosition = Vector3.new(-55.3, 1023.1, -545.8),
    EndPosition = Vector3.new(-214.4, 1023.1, 146.7),
    Connection = nil
}

MainModule.Guards = {
    SelectedGuard = "Circle",
    AutoFarm = false,
    RapidFire = false,
    InfiniteAmmo = false,
    HitboxExpander = false,
    OriginalFireRates = {},
    OriginalAmmo = {},
    OriginalHitboxes = {},
    Connections = {}
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

-- Glass Bridge System
MainModule.GlassBridge = {
    AntiBreakEnabled = false,
    AntiBreakConnection = nil,
    GlassESPEnabled = false,
    GlassESPConnection = nil,
    EndPosition = Vector3.new(-196.372467, 522.192139, -1534.20984)
}

MainModule.TugOfWar = {
    AutoPull = false,
    Connection = nil
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    Connection = nil
}

MainModule.SkySquid = {
    Connection = nil
}

-- ЕДИНАЯ СИСТЕМА ANTIFALL
MainModule.Antifall = {
    Enabled = false,
    Platform = nil,
    PlatformOffset = -5,
    PlatformSize = Vector3.new(12, 1, 12),
    PlatformColor = Color3.fromRGB(0, 170, 255),
    PlatformTransparency = 0.3,
    MoveUpKey = Enum.KeyCode.O,
    MoveDownKey = Enum.KeyCode.P,
    MoveStep = 3,
    Connection = nil,
    InputConnection = nil,
    TouchGui = nil,
    LastHeight = nil,
    LastPlayerHeight = nil,
    IsJumping = false,
    JumpCheckRate = 0.1,
    LastJumpCheck = 0,
    FollowDistance = 50,
    MinPlatformY = -1000,
    MaxPlatformY = 5000,
    GroundCheckRayLength = 10,
    IsOnGround = true
}

MainModule.Misc = {
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
    BypassRagdollEnabled = false,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    UnlockDashEnabled = false,
    UnlockPhantomStepEnabled = false,
    LastInjuredNotify = 0,
    LastESPUpdate = 0
}

-- HNS System
MainModule.HNS = {
    InfinityStaminaEnabled = false,
    InfinityStaminaConnection = nil
}

-- ESP System
MainModule.ESP = {
    Players = {},
    Objects = {},
    Connections = {},
    Folder = nil,
    MainConnection = nil,
    UpdateRate = 0.1
}

-- Постоянные соединения
local speedConnection = nil
local autoFarmConnection = nil
local godModeConnection = nil
local instaInteractConnection = nil
local noCooldownConnection = nil
local antiStunConnection = nil
local rapidFireConnection = nil
local infiniteAmmoConnection = nil
local hitboxConnection = nil
local autoPullConnection = nil
local bypassRagdollConnection = nil
local jumpRopeConnection = nil

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function IsMobile()
    return UserInputService.TouchEnabled
end

local function GetDistance(position1, position2)
    if not position1 or not position2 then return math.huge end
    return (position1 - position2).Magnitude
end

local function IsHider(player)
    if not player then return false end
    return player:GetAttribute("IsHider") == true
end

local function IsSeeker(player)
    if not player then return false end
    return player:GetAttribute("IsHunter") == true
end

local function SafeTeleport(position)
    local character = GetCharacter()
    if not character then return false end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return false end
    
    local currentCFrame = rootPart.CFrame
    
    local tempPart = Instance.new("Part")
    tempPart.Size = Vector3.new(1, 1, 1)
    tempPart.Transparency = 1
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Position = currentCFrame.Position
    tempPart.Parent = workspace
    Debris:AddItem(tempPart, 0.1)
    
    local fakeVelocity = Instance.new("BodyVelocity")
    fakeVelocity.Velocity = (position - currentCFrame.Position).Unit * 100
    fakeVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    fakeVelocity.Parent = rootPart
    Debris:AddItem(fakeVelocity, 0.1)
    
    rootPart.CFrame = CFrame.new(position)
    
    task.delay(0.05, function()
        if fakeVelocity and fakeVelocity.Parent then
            fakeVelocity:Destroy()
        end
    end)
    
    return true
end

-- Функции для игроков с ножом
local function playerHasKnife(player)
    if not player or not player.Character then return false end
    
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    
    if player:FindFirstChild("Backpack") then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                    return true, tool
                end
            end
        end
    end
    
    return false, nil
end

-- Функция для получения оружия игрока
local function GetPlayerGun()
    local character = GetCharacter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("Gun") then
                return tool
            end
        end
    end
    
    return nil
end

-- Функция для получения врагов
local function GetEnemies()
    local enemies = {}
    local liveFolder = Workspace:FindFirstChild("Live")
    
    if not liveFolder then return enemies end
    
    for _, model in pairs(liveFolder:GetChildren()) do
        if model:IsA("Model") then
            local enemyTag = model:FindFirstChild("Enemy")
            local deadTag = model:FindFirstChild("Dead")
            
            if enemyTag and not deadTag then
                local isPlayer = false
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name == model.Name then
                        isPlayer = true
                        break
                    end
                end
                
                if not isPlayer then
                    table.insert(enemies, model.Name)
                    if #enemies >= 5 then
                        break
                    end
                end
            end
        end
    end
    
    return enemies
end

-- Функция для мгновенного убийства врага
local function KillEnemy(enemyName)
    pcall(function()
        local liveFolder = Workspace:FindFirstChild("Live")
        if not liveFolder then return end
        
        local enemy = liveFolder:FindFirstChild(enemyName)
        if not enemy then return end
        
        local enemyTag = enemy:FindFirstChild("Enemy")
        local deadTag = enemy:FindFirstChild("Dead")
        
        if not enemyTag or deadTag then return end
        
        local gun = GetPlayerGun()
        if not gun then return end
        
        local args = {
            gun,
            {
                ["ClientRayNormal"] = Vector3.new(-1.1920928955078125e-7, 1.0000001192092896, 0),
                ["FiredGun"] = true,
                ["SecondaryHitTargets"] = {},
                ["ClientRayInstance"] = Workspace:WaitForChild("StairWalkWay"):WaitForChild("Part"),
                ["ClientRayPosition"] = Vector3.new(-220.17489624023438, 183.2957763671875, 301.07257080078125),
                ["bulletCF"] = CFrame.new(-220.5039825439453, 185.22506713867188, 302.133544921875, 0.9551116228103638, 0.2567310333251953, -0.14782091975212097, 7.450581485102248e-9, 0.4989798665046692, 0.8666135668754578, 0.2962462604045868, -0.8277127146720886, 0.4765814542770386),
                ["HitTargets"] = {
                    [enemyName] = "Head"
                },
                ["bulletSizeC"] = Vector3.new(0.009999999776482582, 0.009999999776482582, 4.452499866485596),
                ["NoMuzzleFX"] = false,
                ["FirePosition"] = Vector3.new(-72.88850402832031, -679.4803466796875, -173.31005859375)
            }
        }
        
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FiredGunClient")
        remote:FireServer(unpack(args))
    end)
end

-- Instant REBEL функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    if enabled then
        MainModule.Rebel.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Rebel.Enabled then return end
            
            local currentTime = tick()
            
            if currentTime - MainModule.Rebel.LastCheckTime < MainModule.Rebel.CheckCooldown then return end
            MainModule.Rebel.LastCheckTime = currentTime
            
            local enemies = GetEnemies()
            if #enemies == 0 then return end
            
            for _, enemyName in pairs(enemies) do
                if currentTime - MainModule.Rebel.LastKillTime < MainModule.Rebel.KillCooldown then
                    task.wait(MainModule.Rebel.KillCooldown)
                end
                
                KillEnemy(enemyName)
                MainModule.Rebel.LastKillTime = tick()
                
                task.wait(0.05)
            end
        end)
    else
        MainModule.Rebel.LastKillTime = 0
        MainModule.Rebel.LastCheckTime = 0
    end
end

-- GodMode для RLGL
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if enabled then
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                MainModule.RLGL.LastHealth = humanoid.Health
                MainModule.RLGL.OriginalHeight = humanoid.RootPart.Position.Y
            end
        end
        
        local character = GetCharacter()
        if character and character.HumanoidRootPart then
            local currentPos = character.HumanoidRootPart.Position
            local targetHeight = currentPos.Y + MainModule.RLGL.GodModeHeight
            local targetPos = Vector3.new(currentPos.X, targetHeight, currentPos.Z)
            
            SafeTeleport(targetPos)
        end
        
        MainModule.RLGL.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageTime < MainModule.RLGL.DamageCheckRate then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                
                if not (humanoid and rootPart) then return end
                
                if humanoid.Health < MainModule.RLGL.LastHealth then
                    MainModule.RLGL.LastDamageTime = currentTime
                    
                    SafeTeleport(MainModule.RLGL.DamageTeleportPosition)
                    
                    humanoid.Health = MainModule.RLGL.LastHealth
                    
                    task.wait(0.1)
                    MainModule.ToggleGodMode(false)
                else
                    MainModule.RLGL.LastHealth = humanoid.Health
                    
                    if rootPart.Position.Y < (MainModule.RLGL.OriginalHeight + MainModule.RLGL.GodModeHeight - 10) then
                        local currentPos = rootPart.Position
                        local targetPos = Vector3.new(currentPos.X, MainModule.RLGL.OriginalHeight + MainModule.RLGL.GodModeHeight, currentPos.Z)
                        SafeTeleport(targetPos)
                    end
                end
            end)
        end)
    else
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                local currentPos = rootPart.Position
                local targetHeight = (MainModule.RLGL.OriginalHeight or currentPos.Y) + MainModule.RLGL.NormalHeight
                local targetPos = Vector3.new(currentPos.X, targetHeight, currentPos.Z)
                
                SafeTeleport(targetPos)
            end
        end
        
        MainModule.RLGL.LastHealth = 100
        MainModule.RLGL.OriginalHeight = nil
    end
end

-- Функции телепортации RLGL
function MainModule.TeleportToEnd()
    SafeTeleport(MainModule.RLGL.EndPosition)
end

function MainModule.TeleportToStart()
    SafeTeleport(MainModule.RLGL.StartPosition)
end

-- ПРОВЕРКА ПРЫЖКА для Antifall
local function IsPlayerJumping(character)
    if not character then return false end
    
    local humanoid = GetHumanoid(character)
    if not humanoid then return false end
    
    local state = humanoid:GetState()
    local isJumping = (state == Enum.HumanoidStateType.Jumping) or
                     (state == Enum.HumanoidStateType.Freefall) or
                     (humanoid.FloorMaterial == Enum.Material.Air)
    
    local rootPart = GetRootPart(character)
    if rootPart and rootPart.Velocity.Y > 2 then
        isJumping = true
    end
    
    return isJumping
end

-- ПРОВЕРКА НАХОЖДЕНИЯ НА ЗЕМЛЕ
local function IsPlayerOnGround(character)
    if not character then return true end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return true end
    
    local rayOrigin = rootPart.Position
    local rayDirection = Vector3.new(0, -MainModule.Antifall.GroundCheckRayLength, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    return result ~= nil
end

-- СОЗДАНИЕ ПЛАТФОРМЫ ANTIFALL
function MainModule.CreateAntifallPlatform()
    if MainModule.Antifall.Platform and MainModule.Antifall.Platform.Parent then
        MainModule.Antifall.Platform:Destroy()
        MainModule.Antifall.Platform = nil
    end
    
    local character = GetCharacter()
    if not character then return nil end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    
    local currentPosition = rootPart.Position
    
    local platform = Instance.new("Part")
    platform.Name = "CreonX_Antifall"
    platform.Size = MainModule.Antifall.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanTouch = true
    platform.CanQuery = true
    platform.CastShadow = false
    platform.Material = Enum.Material.SmoothPlastic
    platform.Color = MainModule.Antifall.PlatformColor
    platform.Transparency = MainModule.Antifall.PlatformTransparency
    
    -- Начальная высота под ногами игрока
    local targetY = currentPosition.Y + MainModule.Antifall.PlatformOffset
    
    if targetY < MainModule.Antifall.MinPlatformY then
        targetY = MainModule.Antifall.MinPlatformY
    elseif targetY > MainModule.Antifall.MaxPlatformY then
        targetY = MainModule.Antifall.MaxPlatformY
    end
    
    platform.Position = Vector3.new(currentPosition.X, targetY, currentPosition.Z)
    platform.Parent = workspace
    
    MainModule.Antifall.Platform = platform
    MainModule.Antifall.LastHeight = targetY
    MainModule.Antifall.LastPlayerHeight = currentPosition.Y
    
    print("[Antifall]: Платформа создана под вами")
    
    if IsMobile() then
        MainModule.CreateAntifallMobileGUI()
    end
    
    return platform
end

-- СОЗДАНИЕ GUI КНОПОК ДЛЯ МОБИЛЬНЫХ
function MainModule.CreateAntifallMobileGUI()
    if MainModule.Antifall.TouchGui and MainModule.Antifall.TouchGui.Parent then
        MainModule.Antifall.TouchGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CreonX_AntifallGUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    -- Кнопка ВВЕРХ
    local upButton = Instance.new("TextButton")
    upButton.Name = "UpButton"
    upButton.Size = UDim2.new(0, 60, 0, 60)
    upButton.Position = UDim2.new(1, -70, 0.5, -70)
    upButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    upButton.BackgroundTransparency = 0.3
    upButton.Text = "↑"
    upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    upButton.TextSize = 24
    upButton.Font = Enum.Font.GothamBold
    upButton.BorderSizePixel = 0
    
    local upCorner = Instance.new("UICorner")
    upCorner.CornerRadius = UDim.new(0, 12)
    upCorner.Parent = upButton
    
    -- Кнопка ВНИЗ
    local downButton = Instance.new("TextButton")
    downButton.Name = "DownButton"
    downButton.Size = UDim2.new(0, 60, 0, 60)
    downButton.Position = UDim2.new(1, -70, 0.5, 20)
    downButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    downButton.BackgroundTransparency = 0.3
    downButton.Text = "↓"
    downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    downButton.TextSize = 24
    downButton.Font = Enum.Font.GothamBold
    downButton.BorderSizePixel = 0
    
    local downCorner = Instance.new("UICorner")
    downCorner.CornerRadius = UDim.new(0, 12)
    downCorner.Parent = downButton
    
    upButton.MouseButton1Down:Connect(function()
        MainModule.MoveAntifallUp()
    end)
    
    downButton.MouseButton1Down:Connect(function()
        MainModule.MoveAntifallDown()
    end)
    
    upButton.Parent = screenGui
    downButton.Parent = screenGui
    screenGui.Parent = CoreGui
    
    MainModule.Antifall.TouchGui = screenGui
end

-- ПЕРЕМЕЩЕНИЕ ПЛАТФОРМЫ ВВЕРХ
function MainModule.MoveAntifallUp()
    if not MainModule.Antifall.Enabled or not MainModule.Antifall.Platform then return end
    
    local currentY = MainModule.Antifall.Platform.Position.Y
    local newY = currentY + MainModule.Antifall.MoveStep
    
    if newY > MainModule.Antifall.MaxPlatformY then
        newY = MainModule.Antifall.MaxPlatformY
    end
    
    MainModule.Antifall.Platform.Position = Vector3.new(
        MainModule.Antifall.Platform.Position.X,
        newY,
        MainModule.Antifall.Platform.Position.Z
    )
    MainModule.Antifall.LastHeight = newY
    
    print("[Antifall]: Платформа поднята на 3 единицы. Текущая высота: " .. math.floor(newY))
end

-- ПЕРЕМЕЩЕНИЕ ПЛАТФОРМЫ ВНИЗ
function MainModule.MoveAntifallDown()
    if not MainModule.Antifall.Enabled or not MainModule.Antifall.Platform then return end
    
    local currentY = MainModule.Antifall.Platform.Position.Y
    local newY = currentY - MainModule.Antifall.MoveStep
    
    if newY < MainModule.Antifall.MinPlatformY then
        newY = MainModule.Antifall.MinPlatformY
    end
    
    MainModule.Antifall.Platform.Position = Vector3.new(
        MainModule.Antifall.Platform.Position.X,
        newY,
        MainModule.Antifall.Platform.Position.Z
    )
    MainModule.Antifall.LastHeight = newY
    
    print("[Antifall]: Платформа опущена на 3 единицы. Текущая высота: " .. math.floor(newY))
end

-- ОСНОВНАЯ ФУНКЦИЯ ANTIFALL
function MainModule.ToggleAntifall(enabled)
    MainModule.Antifall.Enabled = enabled
    
    if MainModule.Antifall.Connection then
        MainModule.Antifall.Connection:Disconnect()
        MainModule.Antifall.Connection = nil
    end
    
    if MainModule.Antifall.InputConnection then
        MainModule.Antifall.InputConnection:Disconnect()
        MainModule.Antifall.InputConnection = nil
    end
    
    if enabled then
        local platform = MainModule.CreateAntifallPlatform()
        if not platform then
            MainModule.Antifall.Enabled = false
            return
        end
        
        MainModule.Antifall.InputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == MainModule.Antifall.MoveUpKey then
                MainModule.MoveAntifallUp()
            elseif input.KeyCode == MainModule.Antifall.MoveDownKey then
                MainModule.MoveAntifallDown()
            end
        end)
        
        MainModule.Antifall.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.Antifall.Enabled or not MainModule.Antifall.Platform then return end
            
            local character = GetCharacter()
            if not character then return end
            
            local rootPart = GetRootPart(character)
            if not rootPart then return end
            
            local currentTime = tick()
            
            if currentTime - MainModule.Antifall.LastJumpCheck > MainModule.Antifall.JumpCheckRate then
                MainModule.Antifall.IsJumping = IsPlayerJumping(character)
                MainModule.Antifall.IsOnGround = IsPlayerOnGround(character)
                MainModule.Antifall.LastJumpCheck = currentTime
            end
            
            local currentPosition = rootPart.Position
            local platformPosition = MainModule.Antifall.Platform.Position
            
            -- Если игрок прыгает - НЕ двигаем платформу по Y
            if MainModule.Antifall.IsJumping then
                -- Сохраняем текущую высоту платформы
                MainModule.Antifall.LastHeight = platformPosition.Y
                return
            end
            
            local horizontalDistance = Vector3.new(
                currentPosition.X - platformPosition.X,
                0,
                currentPosition.Z - platformPosition.Z
            ).Magnitude
            
            if horizontalDistance > MainModule.Antifall.FollowDistance then
                local newY = MainModule.Antifall.LastHeight or (currentPosition.Y + MainModule.Antifall.PlatformOffset)
                
                if newY < MainModule.Antifall.MinPlatformY then
                    newY = MainModule.Antifall.MinPlatformY
                elseif newY > MainModule.Antifall.MaxPlatformY then
                    newY = MainModule.Antifall.MaxPlatformY
                end
                
                MainModule.Antifall.Platform.Position = Vector3.new(
                    currentPosition.X,
                    newY,
                    currentPosition.Z
                )
                
            elseif horizontalDistance > 2 then
                local targetX = currentPosition.X
                local targetZ = currentPosition.Z
                local currentY = platformPosition.Y
                
                if MainModule.Antifall.LastHeight then
                    currentY = MainModule.Antifall.LastHeight
                end
                
                if currentY < MainModule.Antifall.MinPlatformY then
                    currentY = MainModule.Antifall.MinPlatformY
                elseif currentY > MainModule.Antifall.MaxPlatformY then
                    currentY = MainModule.Antifall.MaxPlatformY
                end
                
                local newPosition = Vector3.new(
                    platformPosition.X + (targetX - platformPosition.X) * 0.2,
                    currentY,
                    platformPosition.Z + (targetZ - platformPosition.Z) * 0.2
                )
                
                MainModule.Antifall.Platform.Position = newPosition
            end
            
            MainModule.Antifall.LastPlayerHeight = currentPosition.Y
        end)
        
        print("[Antifall]: Активирован. Используйте O/P для управления высотой")
        
    else
        if MainModule.Antifall.Platform and MainModule.Antifall.Platform.Parent then
            MainModule.Antifall.Platform:Destroy()
            MainModule.Antifall.Platform = nil
        end
        
        if MainModule.Antifall.TouchGui and MainModule.Antifall.TouchGui.Parent then
            MainModule.Antifall.TouchGui:Destroy()
            MainModule.Antifall.TouchGui = nil
        end
        
        MainModule.Antifall.LastHeight = nil
        MainModule.Antifall.LastPlayerHeight = nil
        
        print("[Antifall]: Деактивирован")
    end
end

-- Glass Bridge AntiBreak функция (автоматически включает Antifall)
function MainModule.ToggleGlassBridgeAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if enabled then
        MainModule.ToggleAntifall(true)
        
        MainModule.GlassBridge.AntiBreakConnection = RunService.Heartbeat:Connect(function()
            local GlassBridge = workspace:FindFirstChild("GlassBridge")
            if not GlassBridge then return end
            
            local GlassHolder = GlassBridge:FindFirstChild("GlassHolder")
            if not GlassHolder then return end
            
            for _, rowFolder in pairs(GlassHolder:GetChildren()) do
                for _, glassModel in pairs(rowFolder:GetChildren()) do
                    if glassModel:IsA("Model") and glassModel.PrimaryPart then
                        if glassModel.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                            glassModel.PrimaryPart:SetAttribute("exploitingisevil", nil)
                        end
                        
                        if glassModel.PrimaryPart:IsA("BasePart") then
                            glassModel.PrimaryPart.CanCollide = true
                            glassModel.PrimaryPart.Anchored = true
                        end
                    end
                end
            end
        end)
        
        print("[GlassBridge AntiBreak]: Активирован (Antifall автоматически включен)")
        
    else
        MainModule.ToggleAntifall(false)
        print("[GlassBridge AntiBreak]: Деактивирован")
    end
end

-- Glass Bridge ESP функция
function MainModule.RevealGlassBridge()
    local Effects = ReplicatedStorage:FindFirstChild("Modules") and 
                   ReplicatedStorage.Modules:FindFirstChild("Effects")
    
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then
        warn("GlassHolder not found in workspace.GlassBridge")
        return
    end

    for _, tilePair in pairs(glassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                local primaryPart = tileModel.PrimaryPart
                for _, child in ipairs(tileModel:GetChildren()) do
                    if child:IsA("Highlight") then
                        child:Destroy()
                    end
                end
                local isBreakable = primaryPart:GetAttribute("exploitingisevil") == true

                local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                local transparency = 0.5

                for _, part in pairs(tileModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
                            Transparency = transparency,
                            Color = targetColor
                        }):Play()
                    end
                end

                local highlight = Instance.new("Highlight")
                highlight.FillColor = targetColor
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0.5
                highlight.Parent = tileModel
            end
        end
    end

    if Effects then
        local success, result = pcall(function()
            return require(Effects)
        end)
        
        if success and result and result.AnnouncementTween then
            result.AnnouncementTween({
                AnnouncementOneLine = true,
                FasterTween = true,
                DisplayTime = 10,
                AnnouncementDisplayText = "[CreonHub]: Safe tiles are green, breakable tiles are red!"
            })
        end
    end
    
    print("[CreonHub]: Safe tiles are green, breakable tiles are red!")
end

-- Teleport to End для Glass Bridge
function MainModule.TeleportToGlassBridgeEnd()
    SafeTeleport(MainModule.GlassBridge.EndPosition)
end

-- Dalgona функции
function MainModule.CompleteDalgona()
    task.spawn(function()
        local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                    ReplicatedStorage.Modules:FindFirstChild("Games") and
                                    ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
        if not DalgonaClientModule then return end
        
        for _, func in pairs(getreg()) do
            if typeof(func) == "function" and islclosure(func) then
                local info = getinfo(func)
                if info.nups == 76 then
                    setupvalue(func, 33, 9999)
                    setupvalue(func, 34, 9999)
                end
            end
        end
    end)
end

function MainModule.FreeLighter()
    LocalPlayer:SetAttribute("HasLighter", true)
end

-- Tug Of War функции
function MainModule.ToggleAutoPull(enabled)
    MainModule.TugOfWar.AutoPull = enabled
    
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end
    
    if enabled then
        MainModule.TugOfWar.Connection = RunService.Heartbeat:Connect(function()
            if MainModule.TugOfWar.AutoPull then
                pcall(function()
                    local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable")
                    local args = {
                        { IHateYou = true }
                    }
                    Remote:FireServer(unpack(args))
                end)
                task.wait(0.25)
            end
        end)
    end
end

-- Jump Rope функции
function MainModule.DeleteJumpRope()
    local ropeFound = false
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Rope" then
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    
    if not ropeFound then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("rope") and 
               (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    
    local effects = workspace:FindFirstChild("Effects")
    if not ropeFound and effects then
        for _, obj in pairs(effects:GetDescendants()) do
            if obj.Name:lower():find("rope") and 
               (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                obj:Destroy()
                ropeFound = true
                break
            end
        end
    end
    
    return ropeFound
end

function MainModule.TeleportToJumpRopeEnd()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            SafeTeleport(Vector3.new(720.896057, 198.628311, 921.170654))
        end
    end
end

function MainModule.TeleportToJumpRopeStart()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            SafeTeleport(Vector3.new(615.284424, 192.274277, 920.952515))
        end
    end
end

-- Speed функции
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if enabled then
        speedConnection = RunService.Heartbeat:Connect(function()
            if MainModule.SpeedHack.Enabled then
                local character = GetCharacter()
                if character then
                    local humanoid = GetHumanoid(character)
                    if humanoid then
                        humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                    end
                end
            end
        end)
    else
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                humanoid.WalkSpeed = MainModule.SpeedHack.DefaultSpeed
            end
        end
    end
end

function MainModule.SetSpeed(value)
    if value < MainModule.SpeedHack.MinSpeed then
        value = MainModule.SpeedHack.MinSpeed
    elseif value > MainModule.SpeedHack.MaxSpeed then
        value = MainModule.SpeedHack.MaxSpeed
    end
    
    MainModule.SpeedHack.CurrentSpeed = value
    
    if MainModule.SpeedHack.Enabled then
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
    
    return value
end

-- Функции телепортации
function MainModule.TeleportUp100()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, 100, 0)
            SafeTeleport(targetPos)
        end
    end
end

function MainModule.TeleportDown40()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, -40, 0)
            SafeTeleport(targetPos)
        end
    end
end

-- Anti Stun QTE функция
function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled
    
    if antiStunConnection then
        antiStunConnection:Disconnect()
        antiStunConnection = nil
    end
    
    if enabled then
        antiStunConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoQTE.AntiStunEnabled then return end
            
            pcall(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local impactFrames = playerGui:FindFirstChild("ImpactFrames")
                if not impactFrames then return end
                
                local replicatedStorage = ReplicatedStorage
                
                local success, hbgModule = pcall(function()
                    return require(replicatedStorage.Modules.HBGQTE)
                end)
                
                if not success then return end
                
                for _, child in pairs(impactFrames:GetChildren()) do
                    if child.Name == "OuterRingTemplate" and child:IsA("Frame") then
                        for _, innerChild in pairs(impactFrames:GetChildren()) do
                            if innerChild.Name == "InnerTemplate" and innerChild.Position == child.Position 
                               and not innerChild:GetAttribute("Failed") and not innerChild:GetAttribute("Tweening") then
                               
                                pcall(function()
                                    local qteData = {
                                        Inner = innerChild,
                                        Outer = child,
                                        Duration = 2,
                                        StartedAt = tick()
                                    }
                                    hbgModule.Pressed(false, qteData)
                                end)
                                break
                            end
                        end
                    end
                end
            end)
        end)
    end
end

-- Функция для установки типа Guard
function MainModule.SetGuardType(guardType)
    if guardType == "Circle" then
        MainModule.Guards.SelectedGuard = "Circle"
    elseif guardType == "Triangle" then
        MainModule.Guards.SelectedGuard = "Triangle"
    elseif guardType == "Square" then
        MainModule.Guards.SelectedGuard = "Square"
    else
        MainModule.Guards.SelectedGuard = "Circle"
    end
end

-- Guards функции
function MainModule.SpawnAsGuard()
    local args = {
        {
            AttemptToSpawnAsGuard = MainModule.Guards.SelectedGuard
        }
    }
    
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote"):FireServer(unpack(args))
    end)
end

function MainModule.ToggleAutoFarm(enabled)
    MainModule.Guards.AutoFarm = enabled
    
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
    
    if enabled then
        autoFarmConnection = RunService.Heartbeat:Connect(function()
            if MainModule.Guards.AutoFarm then
                local args2 = {
                    "GameOver",
                    4450
                }
                pcall(function()
                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VideoGameRemote"):FireServer(unpack(args2))
                end)
            end
        end)
    end
end

-- Rapid Fire функция
function MainModule.ToggleRapidFire(enabled)
    MainModule.Guards.RapidFire = enabled
    
    if rapidFireConnection then
        rapidFireConnection:Disconnect()
        rapidFireConnection = nil
    end
    
    if enabled then
        rapidFireConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.RapidFire then return end
            
            pcall(function()
                local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
                if not weaponsFolder then return end
                
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if gunsFolder then
                    for _, obj in ipairs(gunsFolder:GetDescendants()) do
                        if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            if not MainModule.Guards.OriginalFireRates[obj] then
                                MainModule.Guards.OriginalFireRates[obj] = obj.Value
                            end
                            obj.Value = 0
                        end
                    end
                end
                
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                    if not MainModule.Guards.OriginalFireRates[obj] then
                                        MainModule.Guards.OriginalFireRates[obj] = obj.Value
                                    end
                                    obj.Value = 0
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        pcall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
            MainModule.Guards.OriginalFireRates = {}
        end)
    end
end

-- Infinite Ammo функция
function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    
    if enabled then
        infiniteAmmoConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            
            local character = GetCharacter()
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") then
                                    if not MainModule.Guards.OriginalAmmo[obj] then
                                        MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                    end
                                    obj.Value = 9999
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        pcall(function()
            for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
                if obj and obj.Parent then
                    obj.Value = originalValue
                end
            end
            MainModule.Guards.OriginalAmmo = {}
        end)
    end
end

-- Hitbox Expander функция
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    if enabled then
        local HITBOX_SIZE = 10
        
        hitboxConnection = RunService.Stepped:Connect(function()
            if not MainModule.Guards.HitboxExpander then 
                for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
                    if player and player.Character then
                        for partName, originalSize in pairs(originalSizes) do
                            local part = player.Character:FindFirstChild(partName)
                            if part and part:IsA("BasePart") then
                                part.Size = originalSize
                                part.CanCollide = true
                            end
                        end
                    end
                end
                MainModule.Guards.OriginalHitboxes = {}
                return 
            end
            
            pcall(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        if not MainModule.Guards.OriginalHitboxes[player] then
                            MainModule.Guards.OriginalHitboxes[player] = {}
                            
                            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                            if rootPart and rootPart:IsA("BasePart") then
                                MainModule.Guards.OriginalHitboxes[player]["HumanoidRootPart"] = rootPart.Size
                            end
                        end
                        
                        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart and rootPart:IsA("BasePart") then
                            if MainModule.Guards.OriginalHitboxes[player] and MainModule.Guards.OriginalHitboxes[player]["HumanoidRootPart"] then
                                rootPart.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
                                rootPart.CanCollide = true
                            end
                        end
                    end
                end
            end)
        end)
    else
        pcall(function()
            for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
                if player and player.Character then
                    for partName, originalSize in pairs(originalSizes) do
                        local part = player.Character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            part.Size = originalSize
                            part.CanCollide = true
                        end
                    end
                end
            end
            MainModule.Guards.OriginalHitboxes = {}
        end)
    end
end

-- HNS Infinity Stamina функция
function MainModule.ToggleHNSInfinityStamina(enabled)
    MainModule.HNS.InfinityStaminaEnabled = enabled
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    if enabled then
        MainModule.HNS.InfinityStaminaConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.InfinityStaminaEnabled then return end
            
            task.spawn(function()
                if LocalPlayer.Character then
                    local stamina = LocalPlayer.Character:FindFirstChild("StaminaVal")
                    if stamina then
                        stamina.Value = 100
                    end
                end
            end)
        end)
    end
end

-- ESP система
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
    
    MainModule.ClearESP()
    
    if enabled then
        MainModule.ESP.Folder = Instance.new("Folder")
        MainModule.ESP.Folder.Name = "CreonXESP"
        MainModule.ESP.Folder.Parent = CoreGui
        
        local function UpdatePlayerESP(player)
            if not player or player == LocalPlayer then return end
            
            local character = player.Character
            if not character then return end
            
            local humanoid = GetHumanoid(character)
            local rootPart = GetRootPart(character)
            
            if not (humanoid and rootPart and humanoid.Health > 0) then return end
            
            local localCharacter = GetCharacter()
            local localRoot = localCharacter and GetRootPart(localCharacter)
            
            local espData = MainModule.ESP.Players[player]
            if not espData then
                espData = {
                    Player = player,
                    Highlight = nil,
                    Billboard = nil,
                    Label = nil
                }
                MainModule.ESP.Players[player] = espData
            end
            
            if not espData.Highlight then
                espData.Highlight = Instance.new("Highlight")
                espData.Highlight.Name = player.Name .. "_ESP"
                espData.Highlight.Adornee = character
                espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
                espData.Highlight.Parent = MainModule.ESP.Folder
            end
            
            if IsHider(player) and MainModule.Misc.ESPHiders then
                espData.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
            elseif IsSeeker(player) and MainModule.Misc.ESPSeekers then
                espData.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                espData.Highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            elseif MainModule.Misc.ESPPlayers then
                espData.Highlight.FillColor = Color3.fromRGB(0, 120, 255)
                espData.Highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
            else
                espData.Highlight.Enabled = false
            end
            
            espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
            espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
            
            if MainModule.Misc.ESPNames then
                if not espData.Billboard then
                    espData.Billboard = Instance.new("BillboardGui")
                    espData.Billboard.Name = player.Name .. "_Text"
                    espData.Billboard.Adornee = rootPart
                    espData.Billboard.AlwaysOnTop = true
                    espData.Billboard.Size = UDim2.new(0, 200, 0, 50)
                    espData.Billboard.StudsOffset = Vector3.new(0, 3, 0)
                    espData.Billboard.Parent = MainModule.ESP.Folder
                    
                    espData.Label = Instance.new("TextLabel")
                    espData.Label.Size = UDim2.new(1, 0, 1, 0)
                    espData.Label.BackgroundTransparency = 1
                    espData.Label.TextColor3 = espData.Highlight.FillColor
                    espData.Label.TextSize = MainModule.Misc.ESPTextSize
                    espData.Label.Font = Enum.Font.GothamBold
                    espData.Label.TextStrokeColor3 = Color3.new(0, 0, 0)
                    espData.Label.TextStrokeTransparency = 0.5
                    espData.Label.Parent = espData.Billboard
                end
                
                espData.Billboard.Enabled = true
                
                local distanceText = ""
                if MainModule.Misc.ESPDistance and localRoot then
                    local distance = math.floor(GetDistance(rootPart.Position, localRoot.Position))
                    distanceText = string.format(" [%dm]", distance)
                end
                
                local healthText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                local nameText = player.DisplayName or player.Name
                
                espData.Label.Text = string.format("%s\n%s%s", nameText, healthText, distanceText)
                espData.Label.TextColor3 = espData.Highlight.FillColor
                espData.Label.TextSize = MainModule.Misc.ESPTextSize
            elseif espData.Billboard then
                espData.Billboard.Enabled = false
            end
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdatePlayerESP(player)
                
                player.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    UpdatePlayerESP(player)
                end)
            end
        end
        
        MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if MainModule.Misc.ESPEnabled and player ~= LocalPlayer then
                task.wait(0.5)
                UpdatePlayerESP(player)
            end
        end)
        
        MainModule.ESP.MainConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            
            for player, espData in pairs(MainModule.ESP.Players) do
                if player and player.Parent and player.Character then
                    UpdatePlayerESP(player)
                else
                    if espData.Highlight then
                        SafeDestroy(espData.Highlight)
                    end
                    if espData.Billboard then
                        SafeDestroy(espData.Billboard)
                    end
                    MainModule.ESP.Players[player] = nil
                end
            end
        end)
    end
end

function MainModule.ClearESP()
    for player, espData in pairs(MainModule.ESP.Players) do
        if espData.Highlight then
            SafeDestroy(espData.Highlight)
        end
        if espData.Billboard then
            SafeDestroy(espData.Billboard)
        end
    end
    MainModule.ESP.Players = {}
    
    if MainModule.ESP.Connections then
        for name, connection in pairs(MainModule.ESP.Connections) do
            if connection then
                pcall(function() connection:Disconnect() end)
                MainModule.ESP.Connections[name] = nil
            end
        end
    end
    
    if MainModule.ESP.Folder then
        SafeDestroy(MainModule.ESP.Folder)
        MainModule.ESP.Folder = nil
    end
    
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
end

-- Misc функции
function MainModule.ToggleInstaInteract(enabled)
    MainModule.Misc.InstaInteract = enabled
    
    if instaInteractConnection then
        instaInteractConnection:Disconnect()
        instaInteractConnection = nil
    end
    
    if enabled then
        local function makePromptInstant(prompt)
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0
            end
        end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end

        instaInteractConnection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end)
    end
end

function MainModule.ToggleNoCooldownProximity(enabled)
    MainModule.Misc.NoCooldownProximity = enabled
    
    if noCooldownConnection then
        noCooldownConnection:Disconnect()
        noCooldownConnection = nil
    end
    
    if enabled then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        
        noCooldownConnection = Workspace.DescendantAdded:Connect(function(obj)
            if MainModule.Misc.NoCooldownProximity then
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
        end)
    end
end

-- Функция для получения координат
function MainModule.GetPlayerPosition()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local position = rootPart.Position
            return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
        end
    end
    return "Не доступно"
end

-- Bypass Ragdoll функция (упрощенная)
function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled
    
    if bypassRagdollConnection then
        bypassRagdollConnection:Disconnect()
        bypassRagdollConnection = nil
    end
    
    if enabled then
        bypassRagdollConnection = RunService.Stepped:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            
            pcall(function()
                local Character = GetCharacter()
                if not Character then return end
                
                local Humanoid = GetHumanoid(Character)
                local HumanoidRootPart = GetRootPart(Character)
                
                if not (Humanoid and HumanoidRootPart) then return end

                for _, child in ipairs(Character:GetChildren()) do
                    if child.Name == "Ragdoll" then
                        task.spawn(function()
                            for i = 1, 10 do
                                if child and child.Parent then
                                    for _, part in pairs(child:GetChildren()) do
                                        if part:IsA("BasePart") then
                                            part.Transparency = part.Transparency + 0.1
                                        end
                                    end
                                    task.wait(0.05)
                                end
                            end
                            pcall(function() child:Destroy() end)
                        end)
                        
                        Humanoid.PlatformStand = false
                        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end)
    end
end

-- Очистка при закрытии
function MainModule.Cleanup()
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection,
        jumpRopeConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    MainModule.ToggleAntifall(false)
    MainModule.ClearESP()
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if MainModule.GlassBridge.GlassESPConnection then
        MainModule.GlassBridge.GlassESPConnection:Disconnect()
        MainModule.GlassBridge.GlassESPConnection = nil
    end
    
    if MainModule.JumpRope.Connection then
        MainModule.JumpRope.Connection:Disconnect()
        MainModule.JumpRope.Connection = nil
    end
    
    if MainModule.SkySquid.Connection then
        MainModule.SkySquid.Connection:Disconnect()
        MainModule.SkySquid.Connection = nil
    end
    
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end
    
    if MainModule.Guards.OriginalHitboxes then
        for player, originalSizes in pairs(MainModule.Guards.OriginalHitboxes) do
            if player and player.Character then
                for partName, originalSize in pairs(originalSizes) do
                    local part = player.Character:FindFirstChild(partName)
                    if part and part:IsA("BasePart") then
                        part.Size = originalSize
                        part.CanCollide = true
                    end
                end
            end
        end
        MainModule.Guards.OriginalHitboxes = {}
    end
    
    for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalAmmo = {}
    
    for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalFireRates = {}
    
    if MainModule.SpeedHack.Enabled then
        MainModule.ToggleSpeedHack(false)
    end
    
    MainModule.SpeedHack.Enabled = false
    MainModule.SpeedHack.CurrentSpeed = 16
    MainModule.Noclip.Enabled = false
    MainModule.AutoQTE.AntiStunEnabled = false
    MainModule.Rebel.Enabled = false
    MainModule.RLGL.GodMode = false
    MainModule.Guards.AutoFarm = false
    MainModule.Guards.RapidFire = false
    MainModule.Guards.InfiniteAmmo = false
    MainModule.Guards.HitboxExpander = false
    MainModule.HNS.InfinityStaminaEnabled = false
    MainModule.Misc.ESPEnabled = false
    MainModule.Misc.InstaInteract = false
    MainModule.Misc.NoCooldownProximity = false
    MainModule.Misc.BypassRagdollEnabled = false
    MainModule.TugOfWar.AutoPull = false
    MainModule.Dalgona.CompleteEnabled = false
    MainModule.Dalgona.FreeLighterEnabled = false
    MainModule.GlassBridge.AntiBreakEnabled = false
    MainModule.GlassBridge.GlassESPEnabled = false
    MainModule.Antifall.Enabled = false
    
    print("Creon X cleanup complete")
end

-- Автоматическая очистка при выходе
LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
