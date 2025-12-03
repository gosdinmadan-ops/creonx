-- Main.lua - Creon X v2.2 (Исправленная версия)
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
    Enabled = false
}

MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    GodModeTimeout = nil,
    LastDamageTime = 0,
    DamageCheckRate = 0.1,
    TeleportOnDamage = false,
    LastHealth = 100
}

MainModule.Guards = {
    SelectedGuard = "Circle",
    AutoFarm = false,
    RapidFire = false,
    InfiniteAmmo = false,
    HitboxExpander = false,
    OriginalFireRates = {},
    OriginalAmmo = {},
    OriginalHitboxes = {}
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

-- HNS System (исправлено)
MainModule.HNS = {
    KillAuraEnabled = false,
    KillSpikesEnabled = false,
    RemoveSpikesEnabled = false,
    DisableSpikesEnabled = false,
    TeleportToHiderEnabled = false,
    AutoDodgeEnabled = false,
    
    LastKillTime = 0,
    KillCooldown = 0.5,
    CurrentTarget = nil,
    CurrentTargetName = nil,
    TargetDistance = 0,
    
    LastDodgeTime = 0,
    DodgeCooldown = 1.0,
    DodgeRange = 10,
    
    SpikePositions = {},
    OriginalSpikeData = {},
    OriginalSpikeTransparency = {},
    SpikesDisabled = false
}

-- Glass Bridge System (исправлено)
MainModule.GlassBridge = {
    GlassVisionEnabled = false,
    AntiFallEnabled = false,
    AntiBreakEnabled = false,
    GlassPlatformsEnabled = false,
    
    GlassPlatforms = {},
    AntiFallPlatform = nil,
    AntiFallConnection = nil,
    AntiBreakConnection = nil,
    GlassVisionConnection = nil,
    
    EndPosition = Vector3.new(-196.372467, 522.192139, -1534.20984),
    SafeHeight = 500
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    DeleteRope = false,
    AntiFallPlatform = nil,
    JumpRopeConnection = nil
}

MainModule.SkySquid = {
    AntiFall = false,
    VoidKill = false,
    AntiFallPlatform = nil,
    SafePlatform = nil
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

-- ESP System (переработано для оптимизации)
MainModule.ESPTable = {
    Players = {},
    Hiders = {},
    Seekers = {},
    Guards = {},
    Doors = {},
    Keys = {},
    EscapeDoors = {}
}

MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 0.1 -- Более частые обновления для плавности
MainModule.ESPCache = {}
MainModule.ESPConnection = nil
MainModule.PlayerESPConnections = {}
MainModule.ESPInstances = {} -- Для хранения ESP объектов

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
local hnsKillAuraConnection = nil
local hnsKillSpikesConnection = nil
local hnsAutoDodgeConnection = nil
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

-- Функция для проверки, есть ли у игрока нож
local function playerHasKnife(player)
    if not player or not player.Character then return false end
    
    -- Проверяем в персонаже
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    
    -- Проверяем в бэкпаке
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

-- Функция для получения расстояния
local function GetDistance(position1, position2)
    if not position1 or not position2 then return math.huge end
    return (position1 - position2).Magnitude
end

-- Функция для проверки, является ли игрок хайдером
local function IsHider(player)
    if not player then return false end
    return player:GetAttribute("IsHider") == true
end

-- Функция для проверки, является ли игрок сикером
local function IsSeeker(player)
    if not player then return false end
    return player:GetAttribute("IsHunter") == true
end

-- Bypass Ragdoll функция с улучшенной защитой (исправленная версия)
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
                local Character = LocalPlayer.Character
                if not Character then return end
                
                local Humanoid = Character:FindFirstChild("Humanoid")
                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                
                if not (Humanoid and HumanoidRootPart) then return end

                -- 1. Мягкое удаление Ragdoll объектов (включая Ragdoll Stun и подобные)
                for _, child in ipairs(Character:GetChildren()) do
                    if child.Name == "Ragdoll" or child.Name == "Ragdoll Stun" or string.find(child.Name:lower(), "ragdoll") then
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

                -- 2. Удаляем вредоносные папки и объекты
                local harmfulFolders = {
                    "RotateDisabled", 
                    "RagdollWakeupImmunity",
                    "RagdollStun",
                    "Stun",
                    "Knockout",
                    "Paralyze"
                }
                
                for _, folderName in pairs(harmfulFolders) do
                    local folder = Character:FindFirstChild(folderName)
                    if folder then
                        folder:Destroy()
                    end
                end

                -- 3. Основная защита от толчков
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local currentVelocity = part.Velocity
                        local horizontalSpeed = Vector3.new(currentVelocity.X, 0, currentVelocity.Z).Magnitude
                        
                        if horizontalSpeed > 50 and part ~= HumanoidRootPart then
                            local newVelocity = Vector3.new(
                                currentVelocity.X * 0.8,
                                currentVelocity.Y,
                                currentVelocity.Z * 0.8
                            )
                            part.Velocity = newVelocity
                        end
                        
                        for _, force in pairs(part:GetChildren()) do
                            if force:IsA("BodyForce") then
                                local forceMagnitude = force.Force.Magnitude
                                if forceMagnitude > 1000 then
                                    force:Destroy()
                                end
                            elseif force:IsA("BodyVelocity") then
                                if force.Velocity.Magnitude > 30 then
                                    force:Destroy()
                                end
                            elseif force:IsA("BodyGyro") or force:IsA("BodyAngularVelocity") then
                                -- Удаляем вращающие силы
                                force:Destroy()
                            end
                        end
                    end
                end
                
                -- 4. Защита корневого объекта
                local playerInputVelocity = HumanoidRootPart.Velocity
                local externalForces = {}
                
                for _, force in pairs(HumanoidRootPart:GetChildren()) do
                    if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                        table.insert(externalForces, force)
                    end
                end
                
                if #externalForces > 0 then
                    local filteredVelocity = Vector3.new(
                        playerInputVelocity.X,
                        HumanoidRootPart.Velocity.Y,
                        playerInputVelocity.Z
                    )
                    
                    HumanoidRootPart.Velocity = filteredVelocity
                    
                    for _, force in pairs(externalForces) do
                        task.spawn(function()
                            if force:IsA("BodyVelocity") then
                                for i = 1, 5 do
                                    if force and force.Parent then
                                        force.Velocity = force.Velocity * 0.5
                                        task.wait(0.02)
                                    end
                                end
                            end
                            pcall(function() force:Destroy() end)
                        end)
                    end
                end
                
                -- 5. Проверяем состояние Humanoid
                if Humanoid:GetState() == Enum.HumanoidStateType.FallingDown or
                   Humanoid:GetState() == Enum.HumanoidStateType.Physics then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    Humanoid.PlatformStand = false
                end
            end)
        end)
        
        -- Слушатель для мгновенного удаления новых Ragdoll объектов
        local char = LocalPlayer.Character
        if char then
            local ragdollListener = char.ChildAdded:Connect(function(child)
                if (child.Name == "Ragdoll" or 
                    child.Name == "Ragdoll Stun" or 
                    string.find(child.Name:lower(), "ragdoll")) and 
                    MainModule.Misc.BypassRagdollEnabled then
                    
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                    
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
            
            -- Сохраняем соединение для последующего отключения
            bypassRagdollConnection.ragdollListener = ragdollListener
        end
    else
        -- При выключении очищаем слушатели
        if bypassRagdollConnection and bypassRagdollConnection.ragdollListener then
            bypassRagdollConnection.ragdollListener:Disconnect()
        end
        
        local character = LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, conn in pairs(getconnections(rootPart.ChildAdded)) do
                    conn:Disconnect()
                end
            end
        end
    end
end
-- Новый AutoDodge (исправленный и оптимизированный)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodgeEnabled = enabled
    
    if hnsAutoDodgeConnection then
        hnsAutoDodgeConnection:Disconnect()
        hnsAutoDodgeConnection = nil
    end
    
    if enabled then
        hnsAutoDodgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodgeEnabled then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                
                if not (humanoid and rootPart) then return end
                
                -- Проверяем, есть ли у нас нож
                local hasKnife, knifeTool = playerHasKnife(LocalPlayer)
                if not hasKnife then return end
                
                -- Проверяем наличие опасных объектов рядом
                local shouldDodge = false
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local targetChar = player.Character
                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                            local targetRoot = targetChar.HumanoidRootPart
                            local distance = GetDistance(rootPart.Position, targetRoot.Position)
                            
                            -- Проверяем, держит ли другой игрок нож
                            local otherHasKnife = playerHasKnife(player)
                            if otherHasKnife and distance < MainModule.HNS.DodgeRange then
                                shouldDodge = true
                                break
                            end
                        end
                    end
                end
                
                -- Также проверяем наличие опасных частей в workspace
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "AutoDodgeHitbox" then
                        local distance = GetDistance(rootPart.Position, part.Position)
                        if distance < MainModule.HNS.DodgeRange and part:GetAttribute("Dangerous") then
                            shouldDodge = true
                            break
                        end
                    end
                end
                
                if shouldDodge then
                    -- Активируем додж
                    if UserInputService.TouchEnabled then
                        -- Для мобильных устройств
                        pcall(function()
                            local backpack = LocalPlayer:FindFirstChild("Backpack")
                            if backpack then
                                local tool = backpack:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool.Parent = character
                                    task.wait(0.1)
                                    tool.Parent = backpack
                                end
                            end
                        end)
                    else
                        -- Для ПК
                        pcall(function()
                            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                            task.wait(0.05)
                            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                        end)
                    end
                    
                    -- Визуальная обратная связь
                    local effect = Instance.new("Part")
                    effect.Size = Vector3.new(5, 0.2, 5)
                    effect.Position = rootPart.Position - Vector3.new(0, 3, 0)
                    effect.Color = Color3.fromRGB(255, 255, 0)
                    effect.Material = Enum.Material.Neon
                    effect.Anchored = true
                    effect.CanCollide = false
                    effect.Transparency = 0.7
                    effect.Parent = Workspace
                    
                    game:GetService("Debris"):AddItem(effect, 0.3)
                end
            end)
        end)
    end
end

-- Исправленный Kill Hiders (HNS система)
function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillAuraEnabled = enabled
    
    if hnsKillAuraConnection then
        hnsKillAuraConnection:Disconnect()
        hnsKillAuraConnection = nil
        MainModule.HNS.CurrentTarget = nil
        MainModule.HNS.CurrentTargetName = nil
    end
    
    if enabled then
        -- Отключаем шипы при включении
        MainModule.ToggleDisableSpikes(true)
        
        hnsKillAuraConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillAuraEnabled then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                
                if not (humanoid and rootPart and humanoid.Health > 0) then return end
                
                -- Проверяем, есть ли у нас нож
                local hasKnife, knifeTool = playerHasKnife(LocalPlayer)
                if not hasKnife then return end
                
                -- Ищем цель
                local targetPlayer = nil
                local targetRoot = nil
                local closestDistance = math.huge
                
                -- Если у нас уже есть цель, проверяем ее
                if MainModule.HNS.CurrentTarget and MainModule.HNS.CurrentTarget.Character then
                    local targetChar = MainModule.HNS.CurrentTarget.Character
                    local targetHumanoid = GetHumanoid(targetChar)
                    local targetRootPart = GetRootPart(targetChar)
                    
                    if targetHumanoid and targetHumanoid.Health > 0 and targetRootPart then
                        local distance = GetDistance(rootPart.Position, targetRootPart.Position)
                        
                        if distance <= 300 and IsHider(MainModule.HNS.CurrentTarget) then
                            targetPlayer = MainModule.HNS.CurrentTarget
                            targetRoot = targetRootPart
                            closestDistance = distance
                            MainModule.HNS.TargetDistance = distance
                        else
                            -- Цель умерла или вышла за пределы радиуса
                            MainModule.HNS.CurrentTarget = nil
                            MainModule.HNS.CurrentTargetName = nil
                        end
                    else
                        -- Цель умерла
                        MainModule.HNS.CurrentTarget = nil
                        MainModule.HNS.CurrentTargetName = nil
                    end
                end
                
                -- Если нет цели, ищем новую
                if not targetPlayer then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and IsHider(player) then
                            local targetChar = player.Character
                            if targetChar then
                                local targetHumanoid = GetHumanoid(targetChar)
                                local targetRootPart = GetRootPart(targetChar)
                                
                                if targetHumanoid and targetHumanoid.Health > 0 and targetRootPart then
                                    local distance = GetDistance(rootPart.Position, targetRootPart.Position)
                                    
                                    if distance < closestDistance and distance <= 300 then
                                        closestDistance = distance
                                        targetPlayer = player
                                        targetRoot = targetRootPart
                                        MainModule.HNS.TargetDistance = distance
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Сохраняем новую цель
                if targetPlayer and targetPlayer ~= MainModule.HNS.CurrentTarget then
                    MainModule.HNS.CurrentTarget = targetPlayer
                    MainModule.HNS.CurrentTargetName = targetPlayer.Name
                end
                
                -- Если нашли цель, телепортируемся к ней
                if targetPlayer and targetRoot then
                    -- Телепортируемся перед целью на фиксированном расстоянии
                    local frontPosition = targetRoot.Position + (targetRoot.CFrame.LookVector * -2)
                    rootPart.CFrame = CFrame.new(frontPosition, targetRoot.Position)
                    
                    -- Делаем себя статичным (следуем за целью)
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = rootPart
                    weld.Part1 = targetRoot
                    weld.Parent = rootPart
                    
                    -- Удаляем старый weld если он есть
                    for _, child in pairs(rootPart:GetChildren()) do
                        if child:IsA("WeldConstraint") and child ~= weld then
                            child:Destroy()
                        end
                    end
                    
                    -- Атакуем
                    if knifeTool and knifeTool:FindFirstChild("RemoteEvent") then
                        knifeTool.RemoteEvent:FireServer()
                    end
                else
                    -- Если нет цели, удаляем weld
                    for _, child in pairs(rootPart:GetChildren()) do
                        if child:IsA("WeldConstraint") then
                            child:Destroy()
                        end
                    end
                end
            end)
        end)
    else
        -- Отключаем weld при выключении
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                for _, child in pairs(rootPart:GetChildren()) do
                    if child:IsA("WeldConstraint") then
                        child:Destroy()
                    end
                end
            end
        end
        
        -- Включаем шипы обратно
        MainModule.ToggleDisableSpikes(false)
        
        MainModule.HNS.CurrentTarget = nil
        MainModule.HNS.CurrentTargetName = nil
    end
end

-- Функция для отключения/включения шипов
function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikesEnabled = enabled
    MainModule.HNS.SpikesDisabled = enabled
    
    if enabled then
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        if not MainModule.HNS.OriginalSpikeData[spike] then
                            MainModule.HNS.OriginalSpikeData[spike] = {
                                Transparency = spike.Transparency,
                                CanTouch = spike.CanTouch
                            }
                        end
                        spike.Transparency = 1
                        spike.CanTouch = false
                    end
                end
            end
        end)
    else
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for spike, data in pairs(MainModule.HNS.OriginalSpikeData) do
                    if spike and spike.Parent then
                        spike.Transparency = data.Transparency
                        spike.CanTouch = data.CanTouch
                    end
                end
                MainModule.HNS.OriginalSpikeData = {}
            end
        end)
    end
end

-- Исправленный ESP System (оптимизированный и без лагов)
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if MainModule.ESPConnection then
        MainModule.ESPConnection:Disconnect()
        MainModule.ESPConnection = nil
    end
    
    -- Очищаем старые ESP объекты
    MainModule.ClearESP()
    
    if enabled then
        -- Создаем папку для ESP
        MainModule.ESPFolder = Instance.new("Folder")
        MainModule.ESPFolder.Name = "CreonXESP"
        MainModule.ESPFolder.Parent = CoreGui
        
        -- Функция для создания ESP для игрока
        local function CreatePlayerESP(player)
            if not player or player == LocalPlayer then return end
            
            local character = player.Character
            if not character then return end
            
            local humanoid = GetHumanoid(character)
            local rootPart = GetRootPart(character)
            
            if not (humanoid and rootPart and humanoid.Health > 0) then return end
            
            -- Создаем Highlight
            local highlight = Instance.new("Highlight")
            highlight.Name = player.Name .. "_ESP"
            highlight.Adornee = character
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = true
            
            -- Настраиваем цвет в зависимости от типа игрока
            if IsHider(player) and MainModule.Misc.ESPHiders then
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый для хайдеров
                highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
            elseif IsSeeker(player) and MainModule.Misc.ESPSeekers then
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Красный для сикеров
                highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
            elseif MainModule.Misc.ESPPlayers then
                highlight.FillColor = Color3.fromRGB(0, 120, 255) -- Синий для обычных игроков
                highlight.OutlineColor = Color3.fromRGB(0, 100, 200)
            else
                highlight:Destroy()
                return
            end
            
            highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
            highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
            highlight.Parent = MainModule.ESPFolder
            
            -- Создаем BillboardGui для текста
            local billboard = Instance.new("BillboardGui")
            billboard.Name = player.Name .. "_Text"
            billboard.Adornee = rootPart
            billboard.AlwaysOnTop = true
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = player.Name
            textLabel.TextColor3 = highlight.FillColor
            textLabel.TextSize = MainModule.Misc.ESPTextSize
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            textLabel.TextStrokeTransparency = 0.5
            textLabel.Parent = billboard
            
            billboard.Parent = MainModule.ESPFolder
            
            -- Сохраняем в таблицу
            MainModule.ESPInstances[player] = {
                Highlight = highlight,
                Billboard = billboard,
                Player = player
            }
            
            -- Соединение для обновления здоровья
            local healthConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if humanoid.Health <= 0 then
                    MainModule.RemovePlayerESP(player)
                else
                    UpdatePlayerESPText(player)
                end
            end)
            
            -- Соединение для удаления при выходе
            local removalConnection = player:GetPropertyChangedSignal("Parent"):Connect(function()
                if not player.Parent then
                    MainModule.RemovePlayerESP(player)
                end
            end)
            
            MainModule.PlayerESPConnections[player] = {
                Health = healthConnection,
                Removal = removalConnection
            }
            
            -- Функция для обновления текста
            function UpdatePlayerESPText(player)
                if not MainModule.ESPInstances[player] then return end
                
                local espData = MainModule.ESPInstances[player]
                if not espData.Billboard or not espData.Billboard.Parent then return end
                
                local textLabel = espData.Billboard:FindFirstChild("TextLabel")
                if not textLabel then return end
                
                local character = player.Character
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                local localRoot = GetRootPart(GetCharacter())
                
                if humanoid and rootPart then
                    local healthText = string.format("%.0f", humanoid.Health)
                    local distanceText = ""
                    
                    if MainModule.Misc.ESPDistance and localRoot then
                        local distance = math.floor(GetDistance(rootPart.Position, localRoot.Position))
                        distanceText = string.format(" [%d]", distance)
                    end
                    
                    textLabel.Text = player.Name .. " (" .. healthText .. "HP)" .. distanceText
                end
            end
            
            -- Начальное обновление
            UpdatePlayerESPText(player)
        end
        
        -- Функция для обновления всех ESP
        local function UpdateAllESP()
            for player, espData in pairs(MainModule.ESPInstances) do
                if player and player.Parent and player.Character then
                    UpdatePlayerESPText(player)
                end
            end
        end
        
        -- Создаем ESP для существующих игроков
        for _, player in pairs(Players:GetPlayers()) do
            CreatePlayerESP(player)
        end
        
        -- Обработка новых игроков
        local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            if MainModule.Misc.ESPEnabled then
                CreatePlayerESP(player)
            end
        end)
        
        -- Обработка атрибутов (hider/seeker)
        local function MonitorAttributes(player)
            if not player then return end
            
            local hiderConnection = player:GetAttributeChangedSignal("IsHider"):Connect(function()
                if MainModule.ESPInstances[player] then
                    MainModule.RemovePlayerESP(player)
                    CreatePlayerESP(player)
                end
            end)
            
            local seekerConnection = player:GetAttributeChangedSignal("IsHunter"):Connect(function()
                if MainModule.ESPInstances[player] then
                    MainModule.RemovePlayerESP(player)
                    CreatePlayerESP(player)
                end
            end)
            
            MainModule.PlayerESPConnections[player] = MainModule.PlayerESPConnections[player] or {}
            MainModule.PlayerESPConnections[player].Hider = hiderConnection
            MainModule.PlayerESPConnections[player].Seeker = seekerConnection
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            MonitorAttributes(player)
        end
        
        -- Основной цикл обновления ESP
        MainModule.ESPConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            
            UpdateAllESP()
            
            -- Обновляем прозрачность
            for _, espData in pairs(MainModule.ESPInstances) do
                if espData.Highlight then
                    espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                    espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                end
            end
        end)
        
        -- Сохраняем соединения
        table.insert(MainModule.PlayerESPConnections, playerAddedConnection)
    else
        MainModule.ClearESP()
    end
end

-- Функция для удаления ESP игрока
function MainModule.RemovePlayerESP(player)
    if MainModule.ESPInstances[player] then
        local espData = MainModule.ESPInstances[player]
        if espData.Highlight then
            SafeDestroy(espData.Highlight)
        end
        if espData.Billboard then
            SafeDestroy(espData.Billboard)
        end
        MainModule.ESPInstances[player] = nil
    end
    
    if MainModule.PlayerESPConnections[player] then
        for _, connection in pairs(MainModule.PlayerESPConnections[player]) do
            if connection then
                pcall(function() connection:Disconnect() end)
            end
        end
        MainModule.PlayerESPConnections[player] = nil
    end
end

-- Функция для очистки всего ESP
function MainModule.ClearESP()
    for player, _ in pairs(MainModule.ESPInstances) do
        MainModule.RemovePlayerESP(player)
    end
    MainModule.ESPInstances = {}
    
    for _, connections in pairs(MainModule.PlayerESPConnections) do
        for _, connection in pairs(connections) do
            if connection then
                pcall(function() connection:Disconnect() end)
            end
        end
    end
    MainModule.PlayerESPConnections = {}
    
    if MainModule.ESPFolder then
        SafeDestroy(MainModule.ESPFolder)
        MainModule.ESPFolder = nil
    end
end

-- Исправленная функция Guards
function MainModule.SetGuardType(guardType)
    -- Корректная обработка выбора типа охранника
    if guardType == "Circle" then
        MainModule.Guards.SelectedGuard = "Circle"
    elseif guardType == "Triangle" then
        MainModule.Guards.SelectedGuard = "Triangle"
    elseif guardType == "Square" then
        MainModule.Guards.SelectedGuard = "Square"
    else
        MainModule.Guards.SelectedGuard = "Circle" -- По умолчанию
    end
end

-- Исправленная функция GodMode для RLGL
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    if enabled then
        -- Запоминаем начальное здоровье
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                MainModule.RLGL.LastHealth = humanoid.Health
            end
        end
        
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageTime < MainModule.RLGL.DamageCheckRate then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                
                if not (humanoid and rootPart) then return end
                
                -- Проверяем, получили ли мы урон
                if humanoid.Health < MainModule.RLGL.LastHealth then
                    MainModule.RLGL.LastDamageTime = currentTime
                    
                    -- Телепортируем на указанные координаты
                    rootPart.CFrame = CFrame.new(186.7, 54.3, -100.6)
                    
                    -- Восстанавливаем здоровье
                    humanoid.Health = MainModule.RLGL.LastHealth
                    
                    -- Отключаем GodMode после телепортации
                    task.wait(0.1)
                    MainModule.ToggleGodMode(false)
                else
                    -- Обновляем запомненное здоровье
                    MainModule.RLGL.LastHealth = humanoid.Health
                    
                    -- Поднимаемся на высоту GodMode (если нужно)
                    if rootPart.Position.Y < 1000 then
                        local currentPos = rootPart.Position
                        rootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
                    end
                end
            end)
        end)
    else
        -- Сбрасываем значения
        MainModule.RLGL.LastHealth = 100
    end
end

-- Функции скорости
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
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 100, 0)
        end
    end
end

function MainModule.TeleportDown40()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.CFrame = rootPart.CFrame + Vector3.new(0, -40, 0)
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

-- Instant Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    
    if enabled then
        task.spawn(function()
            while MainModule.Rebel.Enabled do
                pcall(function()
                    local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote")
                    local args = {
                        {
                            AttemptToSpawnAsGuard = "Rebel"
                        }
                    }
                    remote:FireServer(unpack(args))
                end)
                task.wait(0.1)
            end
        end)
    end
end

-- RLGL функции
function MainModule.TeleportToEnd()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
        end
    end
end

function MainModule.TeleportToStart()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
        end
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

-- Hitbox Expander функция (исправлено - без Z-Index)
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
    
    if autoPullConnection then
        autoPullConnection:Disconnect()
        autoPullConnection = nil
    end
    
    if enabled then
        autoPullConnection = RunService.Heartbeat:Connect(function()
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
function MainModule.ToggleDeleteRope(enabled)
    MainModule.JumpRope.DeleteRope = enabled
    
    if jumpRopeConnection then
        jumpRopeConnection:Disconnect()
        jumpRopeConnection = nil
    end
    
    if enabled then
        local function deleteRope()
            pcall(function()
                local rope = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("rope")
                if rope then
                    rope:Destroy()
                else
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name:lower() == "rope" or obj.Name:lower():find("jump") then
                            obj:Destroy()
                            break
                        end
                    end
                end
            end)
        end
        
        deleteRope()
        
        jumpRopeConnection = RunService.Heartbeat:Connect(function()
            if MainModule.JumpRope.DeleteRope then
                deleteRope()
            end
        end)
    end
end

function MainModule.TeleportToJumpRopeEnd()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.CFrame = CFrame.new(720.896057, 198.628311, 921.170654)
        end
    end
end

function MainModule.TeleportToJumpRopeStart()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.CFrame = CFrame.new(615.284424, 192.274277, 920.952515)
        end
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

-- Очистка при закрытии
function MainModule.Cleanup()
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection,
        hnsKillAuraConnection, hnsKillSpikesConnection, hnsAutoDodgeConnection,
        MainModule.GlassBridge.AntiFallConnection, MainModule.GlassBridge.AntiBreakConnection,
        MainModule.GlassBridge.GlassVisionConnection, MainModule.JumpRope.JumpRopeConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем ESP
    MainModule.ClearESP()
    
    -- Очищаем HNS
    MainModule.HNS.KillAuraEnabled = false
    MainModule.HNS.KillSpikesEnabled = false
    MainModule.HNS.DisableSpikesEnabled = false
    MainModule.HNS.AutoDodgeEnabled = false
    MainModule.HNS.CurrentTarget = nil
    MainModule.HNS.CurrentTargetName = nil
    
    -- Восстанавливаем хитбоксы
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
    
    -- Восстанавливаем Infinite Ammo
    for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalAmmo = {}
    
    -- Восстанавливаем Rapid Fire
    for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalFireRates = {}
    
    -- Восстанавливаем шипы
    MainModule.ToggleDisableSpikes(false)
end

-- Автоматическая очистка при выходе
LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule

