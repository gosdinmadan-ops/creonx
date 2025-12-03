-- Main.lua - Creon X v2.2 (Полностью исправленная версия)
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

-- RLGL System (ИСПРАВЛЕННЫЙ)
MainModule.RLGL = {
    GodMode = false,
    OriginalCFrame = nil,
    GodModeTimeout = nil,
    LastDamageCheck = 0,
    DamageCheckRate = 0.3,
    DamageDetected = false,
    InitialHealth = nil,
    DamageCountdown = 8,  -- 8 секунд до отключения после получения урона
    SafePosition = Vector3.new(-856, 1184.9, -550),  -- Координаты для телепорта при уроне
    GodModeConnection = nil
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

-- HNS System (обновлено с исправлением AutoDodge)
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
    
    LastDodgeTime = 0,
    DodgeCooldown = 0.8, -- Более короткий кулдаун
    DodgeRange = 10, -- Range 10 как просили
    
    SpikePositions = {},
    OriginalSpikeData = {},
    KillSpikesConnection = nil,
    KillAuraConnection = nil,
    AutoDodgeConnection = nil,
    
    -- Для оптимизации AutoDodge
    LastHitboxCheck = 0,
    HitboxCheckRate = 0.15, -- Более частая проверка
    TrackedHitboxes = {},
    LastKnifePlayerCheck = 0,
    KnifePlayerCheckRate = 0.2,
    KnifePlayers = {} -- Игроки с ножом рядом
}

-- Glass Bridge System
MainModule.GlassBridge = {
    GlassVisionEnabled = false,
    AntiFallEnabled = false,
    AntiBreakEnabled = false,
    GlassPlatformsEnabled = false,
    GlassCoverEnabled = false,
    
    GlassPlatforms = {},
    AntiFallPlatform = nil,
    GlassCover = nil,
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
    AntiFallPlatform = nil
}

MainModule.SkySquid = {
    AntiFall = false,
    VoidKill = false,
    AntiFallPlatform = nil,
    SafePlatform = nil
}

-- ESP System
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
    LastESPUpdate = 0,
    ESPUpdateRate = 0.3,
    
    -- Anti-Knockback/Ragdoll
    OriginalRagdollProperties = {},
    RagdollAntiKnockbackEnabled = false,
    
    -- Цвета ESP
    PlayerEspColor = Color3.fromRGB(0, 170, 255),
    SeekerEspColor = Color3.fromRGB(255, 0, 0),
    HiderEspColor = Color3.fromRGB(0, 255, 0),
    GuardEspColor = Color3.fromRGB(255, 165, 0),
    DoorEspColor = Color3.fromRGB(255, 255, 0),
    EscapeDoorEspColor = Color3.fromRGB(255, 0, 255),
    KeyEspColor = Color3.fromRGB(255, 255, 255),
    
    -- Эффекты
    LastEffectsCleanup = 0,
    EffectsCleanupRate = 0.3
}

-- ESP Table structure
MainModule.ESPTable = {
    Player = {},
    Seeker = {},
    Hider = {},
    Guard = {},
    Door = {},
    None = {},
    Key = {},
    EscapeDoor = {}
}

MainModule.ESPFolder = nil
MainModule.ESPConnections = {}
MainModule.PlayerESPConnections = {}

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

local function GetDistance(position)
    local character = LocalPlayer.Character
    if not character then return 0 end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return 0 end
    
    if typeof(position) == "Instance" then
        if position:IsA("BasePart") then
            position = position.Position
        elseif position:IsA("Model") and position.PrimaryPart then
            position = position.PrimaryPart.Position
        else
            return 0
        end
    end
    
    return math.floor((rootPart.Position - position).Magnitude)
end

-- RLGL GodMode (ПОЛНОСТЬЮ ИСПРАВЛЕННЫЙ)
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    -- Отключаем все таймеры и соединения
    if MainModule.RLGL.GodModeTimeout then
        MainModule.RLGL.GodModeTimeout:Disconnect()
        MainModule.RLGL.GodModeTimeout = nil
    end
    
    if MainModule.RLGL.GodModeConnection then
        MainModule.RLGL.GodModeConnection:Disconnect()
        MainModule.RLGL.GodModeConnection = nil
    end
    
    -- Отключаем все другие RLGL соединения
    for i, conn in ipairs(MainModule.ESPConnections) do
        if tostring(conn):find("RLGL") then
            pcall(function() conn:Disconnect() end)
            table.remove(MainModule.ESPConnections, i)
        end
    end
    
    if enabled then
        print("[RLGL GodMode] Включен")
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Сохраняем текущую позицию и здоровье
            MainModule.RLGL.OriginalCFrame = character.HumanoidRootPart.CFrame
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                MainModule.RLGL.InitialHealth = humanoid.Health
                print("[RLGL GodMode] Начальное здоровье:", MainModule.RLGL.InitialHealth)
            end
            
            -- Поднимаем игрока на высоту
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
        
        -- Сбрасываем флаг получения урона
        MainModule.RLGL.DamageDetected = false
        
        -- Проверка урона (только один раз)
        MainModule.RLGL.GodModeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageCheck < MainModule.RLGL.DamageCheckRate then return end
            MainModule.RLGL.LastDamageCheck = currentTime
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Проверяем, получили ли мы урон ПОСЛЕ включения GodMode (только один раз)
            if not MainModule.RLGL.DamageDetected then
                if MainModule.RLGL.InitialHealth and humanoid.Health < MainModule.RLGL.InitialHealth then
                    print("[RLGL GodMode] Обнаружен урон! Здоровье было:", MainModule.RLGL.InitialHealth, "Стало:", humanoid.Health)
                    
                    -- Устанавливаем флаг, что урон получен (только один раз)
                    MainModule.RLGL.DamageDetected = true
                    
                    -- Телепортируем на безопасные координаты (один раз)
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = CFrame.new(MainModule.RLGL.SafePosition)
                        print("[RLGL GodMode] Телепортирован на безопасную позицию")
                    end
                    
                    -- Восстанавливаем здоровье
                    humanoid.Health = humanoid.MaxHealth
                    
                    -- Запускаем таймер отключения через 8 секунд
                    MainModule.RLGL.GodModeTimeout = RunService.Heartbeat:Connect(function()
                        task.wait(MainModule.RLGL.DamageCountdown)
                        
                        print("[RLGL GodMode] Автоматическое отключение через", MainModule.RLGL.DamageCountdown, "секунд")
                        
                        -- Отключаем GodMode
                        MainModule.RLGL.GodMode = false
                        
                        -- НЕ телепортируем обратно вниз
                        -- Просто отключаем все функции GodMode
                        
                        -- Отключаем соединения
                        if MainModule.RLGL.GodModeConnection then
                            MainModule.RLGL.GodModeConnection:Disconnect()
                            MainModule.RLGL.GodModeConnection = nil
                        end
                        
                        if MainModule.RLGL.GodModeTimeout then
                            MainModule.RLGL.GodModeTimeout:Disconnect()
                            MainModule.RLGL.GodModeTimeout = nil
                        end
                        
                        -- Очищаем переменные
                        MainModule.RLGL.OriginalCFrame = nil
                        MainModule.RLGL.InitialHealth = nil
                        MainModule.RLGL.DamageDetected = false
                        
                        print("[RLGL GodMode] Отключен (без телепорта вниз)")
                    end)
                else
                    -- Если InitialHealth еще не установлен, устанавливаем его
                    if not MainModule.RLGL.InitialHealth then
                        MainModule.RLGL.InitialHealth = humanoid.Health
                    end
                end
            end
        end)
        
        table.insert(MainModule.ESPConnections, MainModule.RLGL.GodModeConnection)
        
    else
        print("[RLGL GodMode] Отключен вручную")
        
        -- Отключаем все соединения
        if MainModule.RLGL.GodModeTimeout then
            MainModule.RLGL.GodModeTimeout:Disconnect()
            MainModule.RLGL.GodModeTimeout = nil
        end
        
        if MainModule.RLGL.GodModeConnection then
            MainModule.RLGL.GodModeConnection:Disconnect()
            MainModule.RLGL.GodModeConnection = nil
        end
        
        -- НЕ телепортируем обратно вниз!
        -- Просто очищаем переменные
        MainModule.RLGL.OriginalCFrame = nil
        MainModule.RLGL.InitialHealth = nil
        MainModule.RLGL.DamageDetected = false
        
        print("[RLGL GodMode] Отключен (без телепорта вниз)")
    end
end

-- Bypass Ragdoll + Anti-Knockback (ПОЛНОСТЬЮ ИСПРАВЛЕННЫЙ)
function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled
    MainModule.Misc.RagdollAntiKnockbackEnabled = enabled
    
    if enabled then
        print("[Bypass Ragdoll] Включен (с Anti-Knockback)")
        
        local function applyAntiKnockback()
            local character = LocalPlayer.Character
            if not character then 
                print("[Bypass Ragdoll] Персонаж не найден")
                return false 
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then 
                print("[Bypass Ragdoll] Humanoid не найден")
                return false 
            end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then 
                print("[Bypass Ragdoll] HumanoidRootPart не найден")
                return false 
            end
            
            local knockbackScriptFound = false
            
            -- 1. Ищем и отключаем скрипты отбрасывания/отталкивания
            for _, scriptObj in ipairs(character:GetDescendants()) do
                if scriptObj:IsA("Script") or scriptObj:IsA("LocalScript") or scriptObj:IsA("ModuleScript") then
                    local scriptName = scriptObj.Name:lower()
                    if scriptName:find("knock") or scriptName:find("push") or scriptName:find("ragdoll") or 
                       scriptName:find("stun") or scriptName:find("force") or scriptName:find("impact") or
                       scriptName:find("throw") or scriptName:find("launch") or scriptName:find("blast") then
                        
                        pcall(function() 
                            scriptObj.Disabled = true 
                            knockbackScriptFound = true
                            print("[Bypass Ragdoll] Отключен скрипт отбрасывания:", scriptObj.Name)
                        end)
                    end
                end
            end
            
            -- 2. Ищем BodyVelocity/BodyForce эффекты отбрасывания
            local velocityFound = false
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BodyVelocity") or part:IsA("BodyForce") or part:IsA("BodyAngularVelocity") then
                    if not MainModule.Misc.OriginalRagdollProperties[part] then
                        MainModule.Misc.OriginalRagdollProperties[part] = {
                            Velocity = part.VectorVelocity or part.Force,
                            MaxForce = part.MaxForce,
                            Parent = part.Parent
                        }
                    end
                    part.VectorVelocity = Vector3.new(0, 0, 0)
                    part.Force = Vector3.new(0, 0, 0)
                    part.MaxForce = Vector3.new(0, 0, 0)
                    velocityFound = true
                end
            end
            
            -- 3. Удаляем Ragdoll объекты
            for _, child in ipairs(character:GetChildren()) do
                if child.Name == "Ragdoll" or child.Name:lower():find("ragdoll") then
                    pcall(function() 
                        child:Destroy() 
                        print("[Bypass Ragdoll] Удален Ragdoll объект:", child.Name)
                    end)
                end
            end
            
            -- 4. Удаляем папки эффектов
            for _, folderName in pairs({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking", 
                                        "Ragdolled", "Knocked", "Knockback", "Impact", "Force", "Push"}) do
                local folder = character:FindFirstChild(folderName)
                if folder then
                    pcall(function() 
                        folder:Destroy() 
                        print("[Bypass Ragdoll] Удалена папка эффектов:", folderName)
                    end)
                end
            end
            
            -- 5. Предотвращаем изменение состояния Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or
               humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or
               humanoid:GetState() == Enum.HumanoidStateType.GettingUp then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                print("[Bypass Ragdoll] Восстановлено состояние Running")
            end
            
            -- 6. Защищаем от отбрасывания через физику
            if rootPart then
                -- Временно фиксируем позицию
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                -- Если все еще двигается, используем Anchor
                if rootPart.AssemblyLinearVelocity.Magnitude > 5 then
                    rootPart.Anchored = true
                    task.wait(0.05)
                    rootPart.Anchored = false
                    print("[Bypass Ragdoll] Применен Anchor для остановки движения")
                end
            end
            
            -- 7. Отчет о найденных эффектах
            if not knockbackScriptFound and not velocityFound then
                print("[Bypass Ragdoll] Специальные скрипты/эффекты отбрасывания не найдены")
                print("[Bypass Ragdoll] Применяем скриптовую защиту от отбрасывания...")
                
                -- Создаем свой защитный скрипт
                local success, result = pcall(function()
                    -- Блокируем получение урона от отбрасывания
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                    
                    -- Защита от внешних сил
                    local connection = humanoid.StateChanged:Connect(function(old, new)
                        if new == Enum.HumanoidStateType.FallingDown or new == Enum.HumanoidStateType.Ragdoll then
                            humanoid:ChangeState(Enum.HumanoidStateType.Running)
                        end
                    end)
                    
                    return connection
                end)
                
                if success then
                    print("[Bypass Ragdoll] Скриптовая защита успешно применена")
                    table.insert(MainModule.ESPConnections, result)
                else
                    print("[Bypass Ragdoll] Ошибка при применении скриптовой защиты:", result)
                end
            end
            
            return true
        end
        
        -- Немедленная очистка
        local success = applyAntiKnockback()
        if success then
            print("[Bypass Ragdoll] Anti-Knockback применен успешно")
        end
        
        -- Периодическая очистка (реже, чтобы не лагать)
        local cleanupConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.Misc.LastEffectsCleanup < 1.0 then return end
            MainModule.Misc.LastEffectsCleanup = currentTime
            
            local success = applyAntiKnockback()
            if not success then
                -- Тихий режим, не спамим в консоль
            end
        end)
        
        table.insert(MainModule.ESPConnections, cleanupConnection)
        
    else
        print("[Bypass Ragdoll] Отключен")
        
        -- Восстанавливаем оригинальные свойства
        for obj, data in pairs(MainModule.Misc.OriginalRagdollProperties) do
            if obj and obj.Parent then
                if obj:IsA("BodyVelocity") then
                    obj.VectorVelocity = data.Velocity
                    obj.MaxForce = data.MaxForce
                elseif obj:IsA("BodyForce") then
                    obj.Force = data.Velocity
                    obj.MaxForce = data.MaxForce
                end
            end
        end
        MainModule.Misc.OriginalRagdollProperties = {}
        
        -- Восстанавливаем состояния Humanoid
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                pcall(function()
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                end)
            end
        end
    end
end

-- AutoDodge (ПОЛНОСТЬЮ ИСПРАВЛЕННЫЙ - только при появлении нового хитбокса)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodgeEnabled = enabled
    
    if MainModule.HNS.AutoDodgeConnection then
        MainModule.HNS.AutoDodgeConnection:Disconnect()
        MainModule.HNS.AutoDodgeConnection = nil
    end
    
    MainModule.HNS.TrackedHitboxes = {} -- Сбрасываем отслеживаемые хитбоксы
    MainModule.HNS.KnifePlayers = {} -- Сбрасываем игроков с ножом
    
    if enabled then
        print("[AutoDodge] Включен (Range: 10, только при новом хитбоксе)")
        
        MainModule.HNS.AutoDodgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodgeEnabled then return end
            
            local currentTime = tick()
            
            -- Проверяем игроков с ножом каждые KnifePlayerCheckRate секунд
            if currentTime - MainModule.HNS.LastKnifePlayerCheck >= MainModule.HNS.KnifePlayerCheckRate then
                MainModule.HNS.LastKnifePlayerCheck = currentTime
                MainModule.HNS.KnifePlayers = {}
                
                pcall(function()
                    local character = LocalPlayer.Character
                    if not character then return end
                    
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    
                    -- Ищем игроков с ножом в радиусе DodgeRange
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local targetCharacter = player.Character
                            local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                            
                            if targetRoot then
                                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                                
                                if distance <= MainModule.HNS.DodgeRange then
                                    -- Проверяем, есть ли у него нож
                                    local hasKnife = false
                                    
                                    -- Проверяем инвентарь
                                    for _, tool in pairs(targetCharacter:GetChildren()) do
                                        if tool:IsA("Tool") then
                                            local toolName = tool.Name:lower()
                                            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or 
                                               toolName:find("blade") or toolName:find("sword") then
                                                hasKnife = true
                                                break
                                            end
                                        end
                                    end
                                    
                                    -- Проверяем бэкпак
                                    if not hasKnife and player:FindFirstChild("Backpack") then
                                        for _, tool in pairs(player.Backpack:GetChildren()) do
                                            if tool:IsA("Tool") then
                                                local toolName = tool.Name:lower()
                                                if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or 
                                                   toolName:find("blade") or toolName:find("sword") then
                                                    hasKnife = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                    
                                    if hasKnife then
                                        MainModule.HNS.KnifePlayers[player] = {
                                            Player = player,
                                            Distance = distance,
                                            LastSeen = currentTime
                                        }
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            
            -- Если нет игроков с ножом рядом, выходим
            if not next(MainModule.HNS.KnifePlayers) then return end
            
            -- Проверяем новые хитбоксы каждые HitboxCheckRate секунд
            if currentTime - MainModule.HNS.LastHitboxCheck < MainModule.HNS.HitboxCheckRate then return end
            MainModule.HNS.LastHitboxCheck = currentTime
            
            -- Проверяем кулдаун
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                local foundNewHitbox = false
                local newHitboxPosition = nil
                local newHitboxName = nil
                
                -- Ищем новые хитбоксы в радиусе DodgeRange
                for _, part in pairs(Workspace:GetPartsInRadius(rootPart.Position, MainModule.HNS.DodgeRange)) do
                    if part:IsA("BasePart") and part.CanCollide and part.Transparency < 1 then
                        -- Пропускаем части нашего персонажа
                        if part:IsDescendantOf(character) then continue end
                        
                        -- Пропускаем части других игроков
                        local isPlayerPart = false
                        for _, player in pairs(Players:GetPlayers()) do
                            if player.Character and part:IsDescendantOf(player.Character) then
                                isPlayerPart = true
                                break
                            end
                        end
                        if isPlayerPart then continue end
                        
                        -- Пропускаем части земли/стен/пола
                        local partName = part.Name:lower()
                        if partName:find("ground") or partName:find("floor") or partName:find("wall") or 
                           partName:find("base") or partName:find("terrain") then
                            continue
                        end
                        
                        -- Проверяем, новый ли это хитбокс
                        local hitboxId = tostring(part:GetDebugId())
                        if not MainModule.HNS.TrackedHitboxes[hitboxId] then
                            -- Новый хитбокс найден!
                            MainModule.HNS.TrackedHitboxes[hitboxId] = {
                                Part = part,
                                Time = currentTime,
                                Name = part.Name
                            }
                            foundNewHitbox = true
                            newHitboxPosition = part.Position
                            newHitboxName = part.Name
                            break
                        end
                    end
                end
                
                if foundNewHitbox and newHitboxPosition then
                    -- Выполняем додж
                    MainModule.HNS.LastDodgeTime = currentTime
                    
                    -- Используем слот 1 для доджа
                    pcall(function()
                        local vim = game:GetService("VirtualInputManager")
                        -- Нажимаем клавишу 1
                        vim:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                        task.wait(0.05)
                        vim:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    end)
                    
                    -- Телепортируемся в направлении от хитбокса
                    local direction = (rootPart.Position - newHitboxPosition).Unit
                    if direction.Magnitude < 0.1 then
                        -- Если направления нет, телепортируемся случайно
                        direction = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
                    end
                    
                    local teleportDistance = 8
                    local offset = direction * teleportDistance
                    offset = Vector3.new(offset.X, 0, offset.Z) -- Не изменяем высоту
                    
                    local newPosition = rootPart.Position + offset
                    
                    -- Проверяем, чтобы не телепортироваться в стену
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    local raycastResult = Workspace:Raycast(rootPart.Position, offset, raycastParams)
                    if not raycastResult then
                        rootPart.CFrame = CFrame.new(newPosition)
                        print("[AutoDodge] Додж выполнен! Причина: новый хитбокс", newHitboxName or "Unknown")
                    else
                        -- Если на пути стена, телепортируемся в сторону
                        local sideOffset = Vector3.new(-offset.Z, 0, offset.X) -- Перпендикулярно
                        local sidePosition = rootPart.Position + sideOffset
                        rootPart.CFrame = CFrame.new(sidePosition)
                        print("[AutoDodge] Додж выполнен в сторону! Причина: новый хитбокс", newHitboxName or "Unknown")
                    end
                end
                
                -- Очищаем старые хитбоксы (старше 3 секунд)
                for hitboxId, data in pairs(MainModule.HNS.TrackedHitboxes) do
                    if currentTime - data.Time > 3 then
                        MainModule.HNS.TrackedHitboxes[hitboxId] = nil
                    end
                end
                
                -- Очищаем старых игроков с ножом (старше 5 секунд)
                for playerId, data in pairs(MainModule.HNS.KnifePlayers) do
                    if currentTime - data.LastSeen > 5 then
                        MainModule.HNS.KnifePlayers[playerId] = nil
                    end
                end
            end)
        end)
    else
        print("[AutoDodge] Отключен")
    end
end

-- Удаление эффектов (исправленная версия без лагов)
function MainModule.CleanupEffects()
    if not MainModule.Misc.RemoveStunEnabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    
    -- Удаляем эффекты Stun
    for _, child in pairs(character:GetDescendants()) do
        local childName = child.Name:lower()
        if string.find(childName, "stun") or 
           string.find(childName, "slow") or 
           string.find(childName, "freeze") then
            pcall(function() child:Destroy() end)
        end
    end
    
    -- Убираем состояние Stun у Humanoid
    if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    -- Восстанавливаем скорость
    if humanoid.WalkSpeed < 16 then
        humanoid.WalkSpeed = 16
    end
end

function MainModule.ToggleRemoveStun(enabled)
    MainModule.Misc.RemoveStunEnabled = enabled
    
    if enabled then
        MainModule.CleanupEffects()
        
        local cleanupConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.Misc.LastEffectsCleanup >= MainModule.Misc.EffectsCleanupRate then
                MainModule.CleanupEffects()
                MainModule.Misc.LastEffectsCleanup = currentTime
            end
        end)
        
        table.insert(MainModule.ESPConnections, cleanupConnection)
    else
        for i, conn in ipairs(MainModule.ESPConnections) do
            if conn and type(conn) == "function" then
                pcall(conn)
            elseif conn and conn.Disconnect then
                pcall(function() conn:Disconnect() end)
            end
        end
        MainModule.ESPConnections = {}
    end
end

-- ESP System (оптимизированная версия без лагов)
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    for _, conn in pairs(MainModule.PlayerESPConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    MainModule.PlayerESPConnections = {}
    
    for _, espType in pairs(MainModule.ESPTable) do
        for _, esp in pairs(espType) do
            if esp and esp.Destroy then
                pcall(function() esp.Destroy() end)
            end
        end
    end
    
    for key in pairs(MainModule.ESPTable) do
        MainModule.ESPTable[key] = {}
    end
    
    if MainModule.ESPFolder then
        SafeDestroy(MainModule.ESPFolder)
        MainModule.ESPFolder = nil
    end
    
    if enabled then
        MainModule.ESPFolder = Instance.new("Folder")
        MainModule.ESPFolder.Name = "CreonESP"
        MainModule.ESPFolder.Parent = Workspace
        
        for _, player in pairs(Players:GetPlayers()) do
            MainModule.CreatePlayerESP(player)
        end
        
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            MainModule.CreatePlayerESP(player)
        end)
        table.insert(MainModule.PlayerESPConnections, playerAddedConn)
        
        local updateConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.Misc.LastESPUpdate >= MainModule.Misc.ESPUpdateRate then
                MainModule.UpdateAllESP()
                MainModule.Misc.LastESPUpdate = currentTime
            end
        end)
        table.insert(MainModule.PlayerESPConnections, updateConnection)
    end
end

function MainModule.CreatePlayerESP(player)
    if player == LocalPlayer then return end
    
    local playerId = tostring(player.UserId)
    if MainModule.ESPTable.Player[playerId] and MainModule.ESPTable.Player[playerId].Destroy then
        MainModule.ESPTable.Player[playerId].Destroy()
    end
    
    local function setupESP(character)
        if not character or not character:IsDescendantOf(Workspace) then return end
        
        local rootPart = character:WaitForChild("HumanoidRootPart", 3)
        if not rootPart then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        local playerType = "Player"
        local espColor = MainModule.Misc.PlayerEspColor
        
        if player:GetAttribute("IsHider") then
            playerType = "Hider"
            espColor = MainModule.Misc.HiderEspColor
        elseif player:GetAttribute("IsHunter") then
            playerType = "Seeker"
            espColor = MainModule.Misc.SeekerEspColor
        end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_" .. player.Name
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = espColor
        highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
        highlight.OutlineColor = espColor
        highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
        highlight.Enabled = MainModule.Misc.ESPHighlight
        highlight.Parent = MainModule.ESPFolder
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Text_" .. player.Name
        billboard.Adornee = rootPart
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = MainModule.ESPFolder
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ESP_Label"
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.TextColor3 = espColor
        textLabel.TextSize = MainModule.Misc.ESPTextSize
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0.3
        textLabel.Parent = billboard
        
        local box = nil
        if MainModule.Misc.ESPBoxes then
            box = Instance.new("BoxHandleAdornment")
            box.Name = "ESP_Box_" .. player.Name
            box.Adornee = rootPart
            box.AlwaysOnTop = true
            box.Size = rootPart.Size + Vector3.new(0.5, 0.5, 0.5)
            box.Color3 = espColor
            box.Transparency = 0.7
            box.ZIndex = 10
            box.Parent = MainModule.ESPFolder
        end
        
        local function updateText()
            if not character or not character:IsDescendantOf(Workspace) then return end
            
            local currentHumanoid = character:FindFirstChildOfClass("Humanoid")
            if not currentHumanoid or currentHumanoid.Health <= 0 then return end
            
            local text = player.DisplayName or player.Name
            
            if MainModule.Misc.ESPNames then
                if player.DisplayName ~= player.Name then
                    text = player.DisplayName .. " (@" .. player.Name .. ")"
                end
            end
            
            if MainModule.Misc.ESPDistance then
                local distance = GetDistance(rootPart)
                text = text .. " [" .. distance .. "m]"
            end
            
            textLabel.Text = text
        end
        
        updateText()
        
        MainModule.ESPTable[playerType][playerId] = {
            Highlight = highlight,
            Billboard = billboard,
            Box = box,
            Destroy = function()
                SafeDestroy(highlight)
                SafeDestroy(billboard)
                if box then SafeDestroy(box) end
            end,
            Update = updateText
        }
    end
    
    if player.Character then
        setupESP(player.Character)
    end
    
    local charConn = player.CharacterAdded:Connect(setupESP)
    table.insert(MainModule.PlayerESPConnections, charConn)
end

function MainModule.UpdateAllESP()
    if not MainModule.Misc.ESPEnabled then return end
    
    for _, espType in pairs(MainModule.ESPTable) do
        for _, esp in pairs(espType) do
            if esp and esp.Update then
                pcall(function() esp.Update() end)
            end
        end
    end
end

-- Kill Aura
function MainModule.ToggleKillAura(enabled)
    MainModule.HNS.KillAuraEnabled = enabled
    
    if MainModule.HNS.KillAuraConnection then
        MainModule.HNS.KillAuraConnection:Disconnect()
        MainModule.HNS.KillAuraConnection = nil
    end
    
    if enabled then
        MainModule.HNS.KillAuraConnection = RunService.RenderStepped:Connect(function()
            if not MainModule.HNS.KillAuraEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local HRP = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                local targetPlayer = nil
                local closestDistance = math.huge
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") 
                       and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 
                       and player:GetAttribute("IsHider") then
                        
                        local distance = (HRP.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            targetPlayer = player
                        end
                    end
                end
                
                if targetPlayer and targetPlayer.Character then
                    local targetTorso = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        or targetPlayer.Character:FindFirstChild("UpperTorso")
                        or targetPlayer.Character:FindFirstChild("Torso")
                    
                    if targetTorso then
                        local frontPos = targetTorso.CFrame * CFrame.new(0, 0, -2)
                        HRP.CFrame = frontPos
                    end
                end
            end)
        end)
    end
end

-- Kill Spikes
function MainModule.ToggleKillSpikes(enabled)
    MainModule.HNS.KillSpikesEnabled = enabled
    
    if MainModule.HNS.KillSpikesConnection then
        MainModule.HNS.KillSpikesConnection:Disconnect()
        MainModule.HNS.KillSpikesConnection = nil
    end
    
    if enabled then
        pcall(function()
            MainModule.HNS.SpikePositions = {}
            
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        table.insert(MainModule.HNS.SpikePositions, spike.Position)
                    end
                end
            end
        end)
        
        MainModule.HNS.KillSpikesConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillSpikesEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then return end
                
                local HRP = character.HumanoidRootPart
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then return end
                
                local hasKnife = false
                local knifeTool = nil
                
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork")) then
                        hasKnife = true
                        knifeTool = tool
                        break
                    end
                end
                
                if not hasKnife and LocalPlayer:FindFirstChild("Backpack") then
                    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork")) then
                            hasKnife = true
                            knifeTool = tool
                            break
                        end
                    end
                end
                
                if not hasKnife then return end
                
                local nearestHider = nil
                local nearestDistance = math.huge
                local targetRootPart = nil
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetCharacter = player.Character
                        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                        local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and player:GetAttribute("IsHider") then
                            local distance = (HRP.Position - targetRoot.Position).Magnitude
                            
                            if distance < nearestDistance and distance < 50 then
                                nearestDistance = distance
                                nearestHider = player
                                targetRootPart = targetRoot
                            end
                        end
                    end
                end
                
                if nearestHider and targetRootPart and #MainModule.HNS.SpikePositions > 0 then
                    local originalPosition = HRP.CFrame
                    
                    local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                    HRP.CFrame = teleportCFrame
                    
                    if knifeTool then
                        local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                        if remoteEvent then
                            remoteEvent:FireServer()
                        end
                    end
                    
                    task.wait(0.3)
                    
                    local randomSpike = MainModule.HNS.SpikePositions[math.random(1, #MainModule.HNS.SpikePositions)]
                    targetRootPart.CFrame = CFrame.new(randomSpike)
                    
                    task.wait(4)
                    
                    HRP.CFrame = originalPosition
                end
            end)
        end)
    end
end

-- Disable/Remove Spikes
function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikesEnabled = enabled
    
    if enabled then
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        MainModule.HNS.OriginalSpikeData[spike] = {
                            Transparency = spike.Transparency,
                            CanTouch = spike.CanTouch
                        }
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

-- Teleport to Hider
function MainModule.TeleportToHider()
    pcall(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player:GetAttribute("IsHider") and 
               player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    return
                end
            end
        end
    end)
end

-- Glass Bridge System функции

-- Glass Vision (показывает настоящие/фейковые стекла)
function MainModule.ToggleGlassVision(enabled)
    MainModule.GlassBridge.GlassVisionEnabled = enabled
    
    local function updateGlassColors()
        pcall(function()
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("GlassPart") then
                    if enabled then
                        if part:GetAttribute("ActuallyKilling") ~= nil then
                            part.Color = Color3.fromRGB(255, 0, 0)  -- Фейковое стекло
                        else
                            part.Color = Color3.fromRGB(0, 255, 0)  -- Настоящее стекло
                        end
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.3
                    else
                        part.Color = Color3.fromRGB(163, 162, 165)
                        part.Material = Enum.Material.Glass
                        part.Transparency = 0
                    end
                end
            end
        end)
    end
    
    if enabled then
        updateGlassColors()
        MainModule.GlassBridge.GlassVisionConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.GlassVisionEnabled then return end
            updateGlassColors()
        end)
    else
        if MainModule.GlassBridge.GlassVisionConnection then
            MainModule.GlassBridge.GlassVisionConnection:Disconnect()
            MainModule.GlassBridge.GlassVisionConnection = nil
        end
        updateGlassColors()
    end
end

-- Anti Break (предотвращает поломку стекла)
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if enabled then
        MainModule.CreateGlassBridgeCover()
        MainModule.CreateGlassBridgePlatforms()
        
        MainModule.GlassBridge.AntiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreakEnabled then return end
            
            pcall(function()
                local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not GlassHolder then return end
                
                for _, v in pairs(GlassHolder:GetChildren()) do
                    for _, j in pairs(v:GetChildren()) do
                        if j:IsA("Model") and j.PrimaryPart then
                            if j.PrimaryPart:GetAttribute("exploitingisevil") ~= nil then
                                j.PrimaryPart:SetAttribute("exploitingisevil", nil)
                            end
                        end
                    end
                end
            end)
        end)
    else
        MainModule.RemoveGlassBridgeCover()
        MainModule.RemoveGlassBridgePlatforms()
    end
end

-- Создание Glass Bridge покрытия
function MainModule.CreateGlassBridgeCover()
    MainModule.RemoveGlassBridgeCover()
    
    pcall(function()
        local glassBridge = Workspace:FindFirstChild("GlassBridge")
        if not glassBridge then return end
        
        local glassHolder = glassBridge:FindFirstChild("GlassHolder")
        if not glassHolder then return end
        
        MainModule.GlassBridge.GlassCover = Instance.new("Part")
        MainModule.GlassBridge.GlassCover.Name = "GlassBridgeCover"
        MainModule.GlassBridge.GlassCover.Size = Vector3.new(500, 5, 500)
        MainModule.GlassBridge.GlassCover.Position = Vector3.new(-200, 515, -1534)
        MainModule.GlassBridge.GlassCover.Anchored = true
        MainModule.GlassBridge.GlassCover.CanCollide = true
        MainModule.GlassBridge.GlassCover.Transparency = 1
        MainModule.GlassBridge.GlassCover.Material = Enum.Material.Glass
        MainModule.GlassBridge.GlassCover.Color = Color3.fromRGB(255, 255, 255)
        MainModule.GlassBridge.GlassCover.Parent = Workspace
    end)
end

function MainModule.RemoveGlassBridgeCover()
    if MainModule.GlassBridge.GlassCover then
        SafeDestroy(MainModule.GlassBridge.GlassCover)
        MainModule.GlassBridge.GlassCover = nil
    end
end

-- Создание платформ на фейковых стеклах
function MainModule.CreateGlassBridgePlatforms()
    MainModule.RemoveGlassBridgePlatforms()
    
    pcall(function()
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part:GetAttribute("GlassPart") and 
               part:GetAttribute("ActuallyKilling") ~= nil then
                
                local platform = Instance.new("Part")
                platform.Name = "GlassBridgePlatform"
                platform.Size = Vector3.new(10, 0.5, 10)
                platform.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 1
                platform.Material = Enum.Material.Plastic
                platform.Color = Color3.fromRGB(255, 255, 255)
                platform.Parent = Workspace
                
                table.insert(MainModule.GlassBridge.GlassPlatforms, platform)
            end
        end
    end)
end

function MainModule.RemoveGlassBridgePlatforms()
    for _, platform in ipairs(MainModule.GlassBridge.GlassPlatforms) do
        SafeDestroy(platform)
    end
    MainModule.GlassBridge.GlassPlatforms = {}
end

-- Anti Fall защита
function MainModule.ToggleAntiFall(enabled)
    MainModule.GlassBridge.AntiFallEnabled = enabled
    
    if MainModule.GlassBridge.AntiFallConnection then
        MainModule.GlassBridge.AntiFallConnection:Disconnect()
        MainModule.GlassBridge.AntiFallConnection = nil
    end
    
    if enabled then
        MainModule.CreateGlassBridgeAntiFallPlatform()
        
        MainModule.GlassBridge.AntiFallConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiFallEnabled then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                if rootPart.Position.Y < MainModule.GlassBridge.SafeHeight then
                    rootPart.CFrame = CFrame.new(MainModule.GlassBridge.EndPosition)
                    
                    local flash = Instance.new("Part")
                    flash.Size = Vector3.new(8, 0.2, 8)
                    flash.Position = rootPart.Position - Vector3.new(0, 3, 0)
                    flash.Color = Color3.fromRGB(0, 255, 0)
                    flash.Material = Enum.Material.Neon
                    flash.Anchored = true
                    flash.CanCollide = false
                    flash.Transparency = 0.5
                    flash.Parent = Workspace
                    
                    Debris:AddItem(flash, 0.5)
                end
            end)
        end)
    else
        MainModule.RemoveGlassBridgeAntiFallPlatform()
    end
end

-- Создание Anti-Fall платформы (как стекло)
function MainModule.CreateGlassBridgeAntiFallPlatform()
    MainModule.RemoveGlassBridgeAntiFallPlatform()
    
    MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
    MainModule.GlassBridge.AntiFallPlatform.Name = "GlassBridgeAntiFallPlatform"
    MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(500, 5, 500)
    MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, MainModule.GlassBridge.SafeHeight, -1534)
    MainModule.GlassBridge.AntiFallPlatform.Anchored = true
    MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
    MainModule.GlassBridge.AntiFallPlatform.Transparency = 0.7
    MainModule.GlassBridge.AntiFallPlatform.Material = Enum.Material.Glass
    MainModule.GlassBridge.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)
    MainModule.GlassBridge.AntiFallPlatform.Parent = Workspace
end

function MainModule.RemoveGlassBridgeAntiFallPlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        SafeDestroy(MainModule.GlassBridge.AntiFallPlatform)
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
end

-- Teleport to End
function MainModule.TeleportToGlassBridgeEnd()
    pcall(function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(MainModule.GlassBridge.EndPosition)
        end
    end)
end

-- Функции скорости
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    
    local player = LocalPlayer
    
    if enabled then
        local character = player.Character or player.CharacterAdded:Wait()
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
            end
        end
        
        local speedConnection = RunService.Heartbeat:Connect(function()
            local character = player.Character
            if character and MainModule.SpeedHack.Enabled then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                end
            end
        end)
        
        table.insert(MainModule.ESPConnections, speedConnection)
    else
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
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
        local player = LocalPlayer
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
    
    return value
end

-- Функции телепортации
function MainModule.TeleportUp100()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
    end
end

function MainModule.TeleportDown40()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, -40, 0)
    end
end

-- Anti Stun QTE функция
function MainModule.ToggleAntiStunQTE(enabled)
    MainModule.AutoQTE.AntiStunEnabled = enabled
    
    if enabled then
        local antiStunConnection = RunService.Heartbeat:Connect(function()
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
        
        table.insert(MainModule.ESPConnections, antiStunConnection)
    end
end

-- Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
end

-- RLGL функции
function MainModule.TeleportToEnd()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.TeleportToStart()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
    end
end

-- Guards функции
function MainModule.SetGuardType(guardType)
    MainModule.Guards.SelectedGuard = guardType
end

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
    
    if enabled then
        local autoFarmConnection = RunService.Heartbeat:Connect(function()
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
        
        table.insert(MainModule.ESPConnections, autoFarmConnection)
    end
end

-- Rapid Fire функция
function MainModule.ToggleRapidFire(enabled)
    MainModule.Guards.RapidFire = enabled
    
    if enabled then
        local rapidFireConnection = RunService.Heartbeat:Connect(function()
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
                
                local character = LocalPlayer.Character
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
        
        table.insert(MainModule.ESPConnections, rapidFireConnection)
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
    
    if enabled then
        local infiniteAmmoConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            
            local character = LocalPlayer.Character
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
        
        table.insert(MainModule.ESPConnections, infiniteAmmoConnection)
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
    
    if enabled then
        local HITBOX_SIZE = 10
        
        local hitboxConnection = RunService.Stepped:Connect(function()
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
        
        table.insert(MainModule.ESPConnections, hitboxConnection)
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
    
    if enabled then
        local autoPullConnection = RunService.Heartbeat:Connect(function()
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
        
        table.insert(MainModule.ESPConnections, autoPullConnection)
    end
end

-- Misc функции
function MainModule.ToggleInstaInteract(enabled)
    MainModule.Misc.InstaInteract = enabled
    
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

        local instaInteractConnection = Workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end)
        
        table.insert(MainModule.ESPConnections, instaInteractConnection)
    end
end

function MainModule.ToggleNoCooldownProximity(enabled)
    MainModule.Misc.NoCooldownProximity = enabled
    
    if enabled then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        
        local noCooldownConnection = Workspace.DescendantAdded:Connect(function(obj)
            if MainModule.Misc.NoCooldownProximity then
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
        end)
        
        table.insert(MainModule.ESPConnections, noCooldownConnection)
    end
end

-- Функция для получения координат
function MainModule.GetPlayerPosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

-- Очистка при закрытии
function MainModule.Cleanup()
    for _, conn in pairs(MainModule.ESPConnections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.ESPConnections = {}
    
    for _, conn in pairs(MainModule.PlayerESPConnections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.PlayerESPConnections = {}
    
    MainModule.HNS.KillAuraEnabled = false
    MainModule.HNS.KillSpikesEnabled = false
    MainModule.HNS.DisableSpikesEnabled = false
    MainModule.HNS.AutoDodgeEnabled = false
    
    if MainModule.HNS.KillAuraConnection then
        pcall(function() MainModule.HNS.KillAuraConnection:Disconnect() end)
        MainModule.HNS.KillAuraConnection = nil
    end
    
    if MainModule.HNS.KillSpikesConnection then
        pcall(function() MainModule.HNS.KillSpikesConnection:Disconnect() end)
        MainModule.HNS.KillSpikesConnection = nil
    end
    
    if MainModule.HNS.AutoDodgeConnection then
        pcall(function() MainModule.HNS.AutoDodgeConnection:Disconnect() end)
        MainModule.HNS.AutoDodgeConnection = nil
    end
    
    MainModule.RemoveGlassBridgeCover()
    MainModule.RemoveGlassBridgePlatforms()
    MainModule.RemoveGlassBridgeAntiFallPlatform()
    
    if MainModule.GlassBridge.AntiFallConnection then
        pcall(function() MainModule.GlassBridge.AntiFallConnection:Disconnect() end)
        MainModule.GlassBridge.AntiFallConnection = nil
    end
    
    if MainModule.GlassBridge.AntiBreakConnection then
        pcall(function() MainModule.GlassBridge.AntiBreakConnection:Disconnect() end)
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if MainModule.GlassBridge.GlassVisionConnection then
        pcall(function() MainModule.GlassBridge.GlassVisionConnection:Disconnect() end)
        MainModule.GlassBridge.GlassVisionConnection = nil
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
    
    MainModule.ToggleDisableSpikes(false)
    
    if MainModule.Misc.ESPEnabled then
        MainModule.ToggleESP(false)
    end
    
    if MainModule.RLGL.GodMode then
        MainModule.ToggleGodMode(false)
    end
    
    MainModule.HNS.TrackedHitboxes = {}
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
