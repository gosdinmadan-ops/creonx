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
local Debris = game:GetService("Debris")

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

-- RLGL System (исправлено с фейковой телепортацией)
MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    LastDamageTime = 0,
    DamageCheckRate = 0.1,
    LastHealth = 100,
    FakePosition = nil,
    SmoothTeleport = false,
    TeleportSpeed = 50,
    GodModeHeight = 160,
    NormalHeight = 80,
    DamageTeleportPosition = Vector3.new(186.7, 54.3, -100.6),
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
    DodgeRange = 5,
    PhysicalCheckRange = 3,
    DodgeOnContactOnly = true,
    
    SpikePositions = {},
    OriginalSpikeData = {},
    OriginalSpikeTransparency = {},
    SpikesDisabled = false,
    Connections = {}
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
    AutoPull = false,
    Connection = nil
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    DeleteRope = false,
    AntiFallPlatform = nil,
    Connection = nil
}

MainModule.SkySquid = {
    AntiFall = false,
    VoidKill = false,
    AntiFallPlatform = nil,
    SafePlatform = nil,
    Connection = nil
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

-- Функция для плавной фейковой телепортации
local function FakeTeleportToPosition(targetPosition, duration)
    local character = GetCharacter()
    if not character then return end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return end
    
    local startPos = rootPart.Position
    local startTime = tick()
    local endTime = startTime + duration
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime >= endTime then
            connection:Disconnect()
            rootPart.CFrame = CFrame.new(targetPosition)
            return
        end
        
        local progress = (currentTime - startTime) / duration
        progress = progress * progress * (3 - 2 * progress)
        
        local currentPos = startPos:Lerp(targetPosition, progress)
        
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.CFrame = CFrame.new(currentPos)
    end)
    
    return connection
end

-- Функция для получения безопасной позиции выше
local function GetSafePositionAbove(currentPosition, height)
    local rayOrigin = currentPosition + Vector3.new(0, 5, 0)
    local rayDirection = Vector3.new(0, -1, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = workspace:Raycast(rayOrigin, rayDirection * 100, raycastParams)
    
    if result and result.Position then
        return result.Position + Vector3.new(0, height, 0)
    else
        return currentPosition + Vector3.new(0, height, 0)
    end
end

-- Исправленный GodMode для RLGL с фейковой телепортацией
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if enabled then
        -- Запоминаем начальное здоровье
        local character = GetCharacter()
        if character then
            local humanoid = GetHumanoid(character)
            if humanoid then
                MainModule.RLGL.LastHealth = humanoid.Health
                MainModule.RLGL.OriginalHeight = humanoid.RootPart.Position.Y
            end
        end
        
        -- Плавная телепортация вверх
        local character = GetCharacter()
        if character and character.HumanoidRootPart then
            local currentPos = character.HumanoidRootPart.Position
            local targetHeight = currentPos.Y + MainModule.RLGL.GodModeHeight
            local targetPos = Vector3.new(currentPos.X, targetHeight, currentPos.Z)
            
            FakeTeleportToPosition(targetPos, 1.0)
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
                
                -- Проверяем, получили ли мы урон
                if humanoid.Health < MainModule.RLGL.LastHealth then
                    MainModule.RLGL.LastDamageTime = currentTime
                    
                    -- Телепортируем на указанные координаты
                    FakeTeleportToPosition(MainModule.RLGL.DamageTeleportPosition, 0.5)
                    
                    -- Восстанавливаем здоровье
                    humanoid.Health = MainModule.RLGL.LastHealth
                    
                    -- Отключаем GodMode после телепортации
                    task.wait(0.1)
                    MainModule.ToggleGodMode(false)
                else
                    -- Обновляем запомненное здоровье
                    MainModule.RLGL.LastHealth = humanoid.Health
                    
                    -- Поддерживаем высоту GodMode
                    if rootPart.Position.Y < (MainModule.RLGL.OriginalHeight + MainModule.RLGL.GodModeHeight - 10) then
                        local currentPos = rootPart.Position
                        local targetPos = Vector3.new(currentPos.X, MainModule.RLGL.OriginalHeight + MainModule.RLGL.GodModeHeight, currentPos.Z)
                        rootPart.CFrame = rootPart.CFrame:Lerp(CFrame.new(targetPos), 0.1)
                    end
                end
            end)
        end)
    else
        -- Плавная телепортация вниз при выключении
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                local currentPos = rootPart.Position
                local targetHeight = (MainModule.RLGL.OriginalHeight or currentPos.Y) + MainModule.RLGL.NormalHeight
                local targetPos = Vector3.new(currentPos.X, targetHeight, currentPos.Z)
                
                FakeTeleportToPosition(targetPos, 1.0)
            end
        end
        
        -- Сбрасываем значения
        MainModule.RLGL.LastHealth = 100
        MainModule.RLGL.OriginalHeight = nil
    end
end

-- Функции телепортации RLGL с фейковым движением
function MainModule.TeleportToEnd()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            FakeTeleportToPosition(MainModule.RLGL.EndPosition, 2.0)
        end
    end
end

function MainModule.TeleportToStart()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            FakeTeleportToPosition(MainModule.RLGL.StartPosition, 2.0)
        end
    end
end

-- Исправленный AutoDodge (только при физическом контакте)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodgeEnabled = enabled
    
    if MainModule.HNS.Connections.AutoDodge then
        MainModule.HNS.Connections.AutoDodge:Disconnect()
        MainModule.HNS.Connections.AutoDodge = nil
    end
    
    if enabled then
        MainModule.HNS.Connections.AutoDodge = RunService.Heartbeat:Connect(function()
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
                
                -- Проверяем наличие игроков с ножами вблизи
                local shouldDodge = false
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local targetChar = player.Character
                        if targetChar then
                            local targetHumanoid = GetHumanoid(targetChar)
                            local targetRoot = GetRootPart(targetChar)
                            
                            if targetHumanoid and targetHumanoid.Health > 0 and targetRoot then
                                -- Проверяем, есть ли у игрока нож
                                local otherHasKnife = playerHasKnife(player)
                                if otherHasKnife then
                                    local distance = GetDistance(rootPart.Position, targetRoot.Position)
                                    
                                    if distance < MainModule.HNS.DodgeRange then
                                        -- Проверяем физический контакт
                                        local raycastParams = RaycastParams.new()
                                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                        raycastParams.FilterDescendantsInstances = {character}
                                        
                                        local direction = (targetRoot.Position - rootPart.Position).Unit
                                        local raycastResult = workspace:Raycast(
                                            rootPart.Position,
                                            direction * MainModule.HNS.PhysicalCheckRange,
                                            raycastParams
                                        )
                                        
                                        -- Если луч попал в игрока - это физический контакт
                                        if raycastResult and raycastResult.Instance:IsDescendantOf(targetChar) then
                                            shouldDodge = true
                                            break
                                        end
                                        
                                        -- Дополнительная проверка через области
                                        for _, part in pairs(character:GetChildren()) do
                                            if part:IsA("BasePart") then
                                                for _, targetPart in pairs(targetChar:GetChildren()) do
                                                    if targetPart:IsA("BasePart") then
                                                        local partDistance = GetDistance(part.Position, targetPart.Position)
                                                        if partDistance < 2 then
                                                            shouldDodge = true
                                                            break
                                                        end
                                                    end
                                                end
                                                if shouldDodge then break end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if shouldDodge then break end
                    end
                end
                
                -- Также проверяем опасные объекты
                if not shouldDodge then
                    for _, part in pairs(Workspace:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "AutoDodgeHitbox" then
                            local distance = GetDistance(rootPart.Position, part.Position)
                            if distance < MainModule.HNS.PhysicalCheckRange and part:GetAttribute("Dangerous") then
                                shouldDodge = true
                                break
                            end
                        end
                    end
                end
                
                if shouldDodge then
                    -- Проверяем кулдаун
                    local currentTime = tick()
                    if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then return end
                    
                    MainModule.HNS.LastDodgeTime = currentTime
                    
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
                    
                    Debris:AddItem(effect, 0.3)
                    
                    -- Небольшой отскок
                    rootPart.Velocity = rootPart.Velocity + Vector3.new(0, 20, 0)
                end
            end)
        end)
    end
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

-- Исправленный Kill Hiders
function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillAuraEnabled = enabled
    
    if hnsKillAuraConnection then
        hnsKillAuraConnection:Disconnect()
        hnsKillAuraConnection = nil
        MainModule.HNS.CurrentTarget = nil
        MainModule.HNS.CurrentTargetName = nil
    end
    
    if enabled then
        MainModule.ToggleDisableSpikes(true)
        
        hnsKillAuraConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillAuraEnabled then return end
            
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                
                if not (humanoid and rootPart and humanoid.Health > 0) then return end
                
                local hasKnife, knifeTool = playerHasKnife(LocalPlayer)
                if not hasKnife then return end
                
                local targetPlayer = nil
                local targetRoot = nil
                local closestDistance = math.huge
                
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
                            MainModule.HNS.CurrentTarget = nil
                            MainModule.HNS.CurrentTargetName = nil
                        end
                    else
                        MainModule.HNS.CurrentTarget = nil
                        MainModule.HNS.CurrentTargetName = nil
                    end
                end
                
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
                
                if targetPlayer and targetPlayer ~= MainModule.HNS.CurrentTarget then
                    MainModule.HNS.CurrentTarget = targetPlayer
                    MainModule.HNS.CurrentTargetName = targetPlayer.Name
                end
                
                if targetPlayer and targetRoot then
                    local direction = (targetRoot.Position - rootPart.Position).Unit
                    local moveSpeed = 50
                    rootPart.Velocity = direction * moveSpeed
                    
                    if knifeTool and knifeTool:FindFirstChild("RemoteEvent") then
                        knifeTool.RemoteEvent:FireServer()
                    end
                end
            end)
        end)
    else
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
            end
        end
        
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

-- ESP System
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if MainModule.ESP.MainConnection then
        MainModule.ESP.MainConnection:Disconnect()
        MainModule.ESP.MainConnection = nil
    end
    
    -- Очищаем все ESP объекты
    MainModule.ClearESP()
    
    if enabled then
        -- Создаем папку для ESP
        MainModule.ESP.Folder = Instance.new("Folder")
        MainModule.ESP.Folder.Name = "CreonXESP"
        MainModule.ESP.Folder.Parent = CoreGui
        
        -- Функция для создания ESP игрока
        local function CreatePlayerESP(player)
            if not player or player == LocalPlayer then return end
            
            if MainModule.ESP.Players[player] then return end
            
            local espData = {
                Player = player,
                Highlight = nil,
                Billboard = nil,
                Label = nil,
                Connections = {}
            }
            
            MainModule.ESP.Players[player] = espData
            
            local function updateESP()
                if not MainModule.Misc.ESPEnabled then return end
                
                local character = player.Character
                if not character then
                    if espData.Highlight then
                        SafeDestroy(espData.Highlight)
                        espData.Highlight = nil
                    end
                    if espData.Billboard then
                        SafeDestroy(espData.Billboard)
                        espData.Billboard = nil
                    end
                    return
                end
                
                local humanoid = GetHumanoid(character)
                local rootPart = GetRootPart(character)
                
                if not (humanoid and rootPart and humanoid.Health > 0) then
                    if espData.Highlight then
                        SafeDestroy(espData.Highlight)
                        espData.Highlight = nil
                    end
                    if espData.Billboard then
                        SafeDestroy(espData.Billboard)
                        espData.Billboard = nil
                    end
                    return
                end
                
                -- Создаем или обновляем Highlight
                if not espData.Highlight then
                    espData.Highlight = Instance.new("Highlight")
                    espData.Highlight.Name = player.Name .. "_ESP"
                    espData.Highlight.Adornee = character
                    espData.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    espData.Highlight.Enabled = MainModule.Misc.ESPHighlight
                    espData.Highlight.Parent = MainModule.ESP.Folder
                end
                
                -- Настраиваем цвет
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
                
                -- Создаем или обновляем Billboard
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
                    
                    -- Обновляем текст
                    local localCharacter = GetCharacter()
                    local localRoot = localCharacter and GetRootPart(localCharacter)
                    
                    local distanceText = ""
                    if MainModule.Misc.ESPDistance and localRoot then
                        local distance = math.floor(GetDistance(rootPart.Position, localRoot.Position))
                        distanceText = string.format(" [%dm]", distance)
                    end
                    
                    local healthText = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
                    local nameText = player.DisplayName or player.Name
                    
                    espData.Label.Text = string.format("%s\n%s%s", nameText, healthText, distanceText)
                    espData.Label.TextColor3 = espData.Highlight.FillColor
                elseif espData.Billboard then
                    espData.Billboard.Enabled = false
                end
            end
            
            -- Инициализация
            updateESP()
            
            -- Слушатели
            espData.Connections.CharacterAdded = player.CharacterAdded:Connect(function()
                task.wait(0.5)
                updateESP()
            end)
            
            espData.Connections.CharacterRemoving = player.CharacterRemoving:Connect(function()
                if espData.Highlight then
                    SafeDestroy(espData.Highlight)
                    espData.Highlight = nil
                end
                if espData.Billboard then
                    SafeDestroy(espData.Billboard)
                    espData.Billboard = nil
                end
            end)
            
            -- Слушатель атрибутов
            espData.Connections.AttributeChanged = player:GetAttributeChangedSignal("IsHider"):Connect(updateESP)
            espData.Connections.AttributeChanged2 = player:GetAttributeChangedSignal("IsHunter"):Connect(updateESP)
        end
        
        -- Создаем ESP для всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            CreatePlayerESP(player)
        end
        
        -- Слушатель для новых игроков
        MainModule.ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            if MainModule.Misc.ESPEnabled then
                CreatePlayerESP(player)
            end
        end)
        
        -- Слушатель для удаленных игроков
        MainModule.ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
            MainModule.RemovePlayerESP(player)
        end)
        
        -- Основной цикл обновления ESP
        MainModule.ESP.MainConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            
            for player, espData in pairs(MainModule.ESP.Players) do
                if player and player.Parent then
                    if player.Character and espData.Highlight then
                        espData.Highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
                        espData.Highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
                    end
                else
                    MainModule.RemovePlayerESP(player)
                end
            end
        end)
    end
end

-- Функция для удаления ESP игрока
function MainModule.RemovePlayerESP(player)
    if MainModule.ESP.Players[player] then
        local espData = MainModule.ESP.Players[player]
        
        if espData.Highlight then
            SafeDestroy(espData.Highlight)
        end
        if espData.Billboard then
            SafeDestroy(espData.Billboard)
        end
        
        -- Отключаем соединения
        if espData.Connections then
            for _, connection in pairs(espData.Connections) do
                if connection then
                    pcall(function() connection:Disconnect() end)
                end
            end
        end
        
        MainModule.ESP.Players[player] = nil
    end
end

-- Функция для очистки всего ESP
function MainModule.ClearESP()
    for player, _ in pairs(MainModule.ESP.Players) do
        MainModule.RemovePlayerESP(player)
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

-- Функции телепортации с фейковым движением
function MainModule.TeleportUp100()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, 100, 0)
            FakeTeleportToPosition(targetPos, 1.0)
        end
    end
end

function MainModule.TeleportDown40()
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            local targetPos = rootPart.Position + Vector3.new(0, -40, 0)
            FakeTeleportToPosition(targetPos, 0.5)
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

-- Функция для очистки всего ESP
function MainModule.ClearAllESP()
    MainModule.ClearESP()
end

-- Очистка при закрытии
function MainModule.Cleanup()
    -- Отключаем все соединения
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection,
        hnsKillAuraConnection, hnsKillSpikesConnection, hnsAutoDodgeConnection,
        jumpRopeConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Отключаем ESP
    MainModule.ClearESP()
    
    -- Отключаем RLGL
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    -- Отключаем HNS соединения
    if MainModule.HNS.Connections then
        for name, conn in pairs(MainModule.HNS.Connections) do
            if conn then
                pcall(function() conn:Disconnect() end)
                MainModule.HNS.Connections[name] = nil
            end
        end
    end
    
    -- Отключаем Glass Bridge соединения
    if MainModule.GlassBridge.AntiFallConnection then
        MainModule.GlassBridge.AntiFallConnection:Disconnect()
        MainModule.GlassBridge.AntiFallConnection = nil
    end
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if MainModule.GlassBridge.GlassVisionConnection then
        MainModule.GlassBridge.GlassVisionConnection:Disconnect()
        MainModule.GlassBridge.GlassVisionConnection = nil
    end
    
    -- Отключаем Jump Rope соединения
    if MainModule.JumpRope.Connection then
        MainModule.JumpRope.Connection:Disconnect()
        MainModule.JumpRope.Connection = nil
    end
    
    -- Отключаем Sky Squid соединения
    if MainModule.SkySquid.Connection then
        MainModule.SkySquid.Connection:Disconnect()
        MainModule.SkySquid.Connection = nil
    end
    
    -- Отключаем Tug of War соединения
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end
    
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
    
    -- Восстанавливаем скорость
    if MainModule.SpeedHack.Enabled then
        MainModule.ToggleSpeedHack(false)
    end
    
    -- Сбрасываем переменные
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
    MainModule.HNS.KillAuraEnabled = false
    MainModule.HNS.AutoDodgeEnabled = false
    MainModule.HNS.DisableSpikesEnabled = false
    MainModule.Misc.ESPEnabled = false
    MainModule.Misc.InstaInteract = false
    MainModule.Misc.NoCooldownProximity = false
    MainModule.Misc.BypassRagdollEnabled = false
    MainModule.TugOfWar.AutoPull = false
    MainModule.JumpRope.DeleteRope = false
    MainModule.Dalgona.CompleteEnabled = false
    MainModule.Dalgona.FreeLighterEnabled = false
    
    print("Creon X cleanup complete")
end

-- Автоматическая очистка при выходе
LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
