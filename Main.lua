-- Main.lua - Creon X v2.1 (Полная исправленная версия)
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

MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    GodModeTimeout = nil,
    LastDamageCheck = 0,
    DamageCheckRate = 0.5,
    DamageDetected = false,
    DamageCountdown = 8  -- 8 секунд до отключения после получения урона
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

-- HNS System (обновлено)
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
    DodgeCooldown = 1.0,
    DodgeRange = 9, -- Range 9 как просили
    
    SpikePositions = {},
    OriginalSpikeData = {},
    KillSpikesConnection = nil,
    KillAuraConnection = nil,
    AutoDodgeConnection = nil,
    
    -- Для оптимизации AutoDodge
    LastHitboxCheck = 0,
    HitboxCheckRate = 0.2, -- Проверка каждые 0.2 секунды
    TrackedHitboxes = {} -- Отслеживаемые хитбоксы
}

-- Glass Bridge System (обновлено)
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

-- ESP System (оптимизированная без лагов)
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
    ESPUpdateRate = 0.3, -- Обновление ESP каждые 0.3 секунды для оптимизации
    
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
    EffectsCleanupRate = 0.3 -- Уборка эффектов каждые 0.3 секунды
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

-- Удаление эффектов (исправленная версия без лагов)
function MainModule.ToggleRemoveStun(enabled)
    MainModule.Misc.RemoveStunEnabled = enabled
    
    -- Очищаем все эффекты при включении
    if enabled then
        -- Немедленная очистка
        MainModule.CleanupEffects()
        
        -- Запускаем периодическую очистку с оптимизацией
        local cleanupConnection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.Misc.LastEffectsCleanup >= MainModule.Misc.EffectsCleanupRate then
                MainModule.CleanupEffects()
                MainModule.Misc.LastEffectsCleanup = currentTime
            end
        end)
        
        table.insert(MainModule.ESPConnections, cleanupConnection)
    else
        -- При отключении просто очищаем соединения
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

-- ESP System (оптимизированная версия без лагов)
function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    -- Очищаем старые ESP соединения
    for _, conn in pairs(MainModule.PlayerESPConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    MainModule.PlayerESPConnections = {}
    
    -- Очищаем ESP объекты
    for _, espType in pairs(MainModule.ESPTable) do
        for _, esp in pairs(espType) do
            if esp and esp.Destroy then
                pcall(function() esp.Destroy() end)
            end
        end
    end
    
    -- Очищаем таблицы
    for key in pairs(MainModule.ESPTable) do
        MainModule.ESPTable[key] = {}
    end
    
    -- Удаляем папку ESP
    if MainModule.ESPFolder then
        SafeDestroy(MainModule.ESPFolder)
        MainModule.ESPFolder = nil
    end
    
    if enabled then
        -- Создаем новую папку ESP
        MainModule.ESPFolder = Instance.new("Folder")
        MainModule.ESPFolder.Name = "CreonESP"
        MainModule.ESPFolder.Parent = Workspace
        
        -- Создаем ESP для всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            MainModule.CreatePlayerESP(player)
        end
        
        -- Подключаемся к новым игрокам
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            MainModule.CreatePlayerESP(player)
        end)
        table.insert(MainModule.PlayerESPConnections, playerAddedConn)
        
        -- Подключаем обновление ESP
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
    
    -- Очищаем старый ESP для этого игрока
    local playerId = tostring(player.UserId)
    if MainModule.ESPTable.Player[playerId] and MainModule.ESPTable.Player[playerId].Destroy then
        MainModule.ESPTable.Player[playerId].Destroy()
    end
    
    local function setupESP(character)
        if not character or not character:IsDescendantOf(Workspace) then return end
        
        -- Ждем появления HumanoidRootPart
        local rootPart = character:WaitForChild("HumanoidRootPart", 3)
        if not rootPart then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        
        -- Определяем тип игрока
        local playerType = "Player"
        local espColor = MainModule.Misc.PlayerEspColor
        
        if player:GetAttribute("IsHider") then
            playerType = "Hider"
            espColor = MainModule.Misc.HiderEspColor
        elseif player:GetAttribute("IsHunter") then
            playerType = "Seeker"
            espColor = MainModule.Misc.SeekerEspColor
        end
        
        -- Создаем Highlight
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
        
        -- Создаем Billboard для текста
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
        
        -- Создаем Box если включено
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
        
        -- Функция обновления текста
        local function updateText()
            if not character or not character:IsDescendantOf(Workspace) then return end
            
            local currentHumanoid = character:FindFirstChildOfClass("Humanoid")
            if not currentHumanoid or currentHumanoid.Health <= 0 then return end
            
            -- Формируем текст
            local text = player.DisplayName or player.Name
            
            if MainModule.Misc.ESPNames then
                if player.DisplayName ~= player.Name then
                    text = player.DisplayName .. " (@" .. player.Name .. ")"
                end
            end
            
            -- Добавляем расстояние
            if MainModule.Misc.ESPDistance then
                local distance = GetDistance(rootPart)
                text = text .. " [" .. distance .. "m]"
            end
            
            -- Добавляем HP
            if MainModule.Misc.ESPSnow and MainModule.Misc.ESPSnow.ShowHP then
                text = text .. " HP:" .. math.floor(currentHumanoid.Health)
            end
            
            textLabel.Text = text
        end
        
        -- Обновляем текст сразу
        updateText()
        
        -- Сохраняем ESP объекты
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
    
    -- Подключаемся к появлению персонажа
    if player.Character then
        setupESP(player.Character)
    end
    
    local charConn = player.CharacterAdded:Connect(setupESP)
    table.insert(MainModule.PlayerESPConnections, charConn)
end

function MainModule.UpdateAllESP()
    if not MainModule.Misc.ESPEnabled then return end
    
    -- Обновляем только видимые ESP
    for _, espType in pairs(MainModule.ESPTable) do
        for _, esp in pairs(espType) do
            if esp and esp.Update then
                pcall(function() esp.Update() end)
            end
        end
    end
end

-- Bypass Ragdoll функция
function MainModule.ToggleBypassRagdoll(enabled)
    MainModule.Misc.BypassRagdollEnabled = enabled
    
    if enabled then
        local function cleanupRagdoll()
            local character = LocalPlayer.Character
            if not character then return end
            
            -- Удаляем Ragdoll объекты
            for _, child in ipairs(character:GetChildren()) do
                if child.Name == "Ragdoll" then
                    pcall(function() child:Destroy() end)
                end
            end
            
            -- Удаляем папки эффектов
            for _, folderName in pairs({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking"}) do
                local folder = character:FindFirstChild(folderName)
                if folder then
                    folder:Destroy()
                end
            end
        end
        
        -- Немедленная очистка
        cleanupRagdoll()
        
        -- Периодическая очистка
        local cleanupConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.BypassRagdollEnabled then return end
            cleanupRagdoll()
        end)
        
        table.insert(MainModule.ESPConnections, cleanupConnection)
    end
end

-- HNS System функции (исправленные)

-- Kill Aura (автоматическое убийство хайдеров)
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
                        -- Телепортируемся перед целью
                        local frontPos = targetTorso.CFrame * CFrame.new(0, 0, -2)
                        HRP.CFrame = frontPos
                    end
                end
            end)
        end)
    end
end

-- Kill Spikes (телепортация хайдеров к шипам)
function MainModule.ToggleKillSpikes(enabled)
    MainModule.HNS.KillSpikesEnabled = enabled
    
    if MainModule.HNS.KillSpikesConnection then
        MainModule.HNS.KillSpikesConnection:Disconnect()
        MainModule.HNS.KillSpikesConnection = nil
    end
    
    if enabled then
        -- Собираем позиции шипов
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
                
                -- Проверяем, держим ли мы нож
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
                
                -- Ищем ближайшего хайдера
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
                    -- Сохраняем позицию для возврата
                    local originalPosition = HRP.CFrame
                    
                    -- Телепортируемся к цели
                    local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                    HRP.CFrame = teleportCFrame
                    
                    -- Атакуем
                    if knifeTool then
                        local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                        if remoteEvent then
                            remoteEvent:FireServer()
                        end
                    end
                    
                    task.wait(0.3)
                    
                    -- Телепортируем цель к случайным шипам
                    local randomSpike = MainModule.HNS.SpikePositions[math.random(1, #MainModule.HNS.SpikePositions)]
                    targetRootPart.CFrame = CFrame.new(randomSpike)
                    
                    -- Ждем 4 секунды
                    task.wait(4)
                    
                    -- Возвращаемся на оригинальную позицию
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

-- Auto Dodge (исправленная версия без крашей)
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodgeEnabled = enabled
    
    if MainModule.HNS.AutoDodgeConnection then
        MainModule.HNS.AutoDodgeConnection:Disconnect()
        MainModule.HNS.AutoDodgeConnection = nil
    end
    
    MainModule.HNS.TrackedHitboxes = {} -- Сбрасываем отслеживаемые хитбоксы
    
    if enabled then
        MainModule.HNS.AutoDodgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodgeEnabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastHitboxCheck < MainModule.HNS.HitboxCheckRate then return end
            MainModule.HNS.LastHitboxCheck = currentTime
            
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                
                if not rootPart or not humanoid or humanoid.Health <= 0 then return end
                
                -- Ищем ближайших игроков с ножом
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetCharacter = player.Character
                        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                        
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            
                            if distance <= MainModule.HNS.DodgeRange then
                                -- Проверяем, есть ли у него нож
                                local hasKnife = false
                                
                                for _, tool in pairs(targetCharacter:GetChildren()) do
                                    if tool:IsA("Tool") then
                                        local toolName = tool.Name:lower()
                                        if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") then
                                            hasKnife = true
                                            break
                                        end
                                    end
                                end
                                
                                if hasKnife then
                                    -- Проверяем, появился ли новый хитбокс (не человека)
                                    local foundNewHitbox = false
                                    
                                    -- Ищем новые хитбоксы в радиусе
                                    for _, part in pairs(Workspace:GetPartsInRadius(rootPart.Position, MainModule.HNS.DodgeRange)) do
                                        if part:IsA("BasePart") then
                                            local partName = part.Name:lower()
                                            -- Пропускаем части игроков
                                            if not (partName:find("head") or partName:find("torso") or partName:find("humanoid") or 
                                                   partName:find("arm") or partName:find("leg") or part:IsDescendantOf(targetCharacter)) then
                                                
                                                local hitboxId = tostring(part:GetDebugId())
                                                if not MainModule.HNS.TrackedHitboxes[hitboxId] then
                                                    -- Новый хитбокс найден
                                                    MainModule.HNS.TrackedHitboxes[hitboxId] = true
                                                    foundNewHitbox = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                    
                                    if foundNewHitbox then
                                        -- Используем слот 1 для доджа
                                        pcall(function()
                                            if UserInputService.TouchEnabled then
                                                -- Для мобильных: симулируем нажатие на слот 1
                                                local backpack = LocalPlayer:FindFirstChild("Backpack")
                                                if backpack then
                                                    local tool = backpack:FindFirstChildOfClass("Tool")
                                                    if tool then
                                                        tool.Parent = character
                                                        task.wait(0.1)
                                                        tool.Parent = backpack
                                                    end
                                                end
                                            else
                                                -- Для ПК: нажимаем клавишу 1
                                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                                                task.wait(0.05)
                                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                                            end
                                        end)
                                        
                                        -- Телепортируемся в случайном направлении
                                        local randomAngle = math.random() * 2 * math.pi
                                        local teleportDistance = 5
                                        local offset = Vector3.new(
                                            math.cos(randomAngle) * teleportDistance,
                                            0,
                                            math.sin(randomAngle) * teleportDistance
                                        )
                                        
                                        local newPosition = rootPart.Position + offset
                                        rootPart.CFrame = CFrame.new(newPosition)
                                        
                                        MainModule.HNS.LastDodgeTime = currentTime
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Очищаем старые хитбоксы (сохраняем только последние 50)
                local trackedCount = 0
                for _ in pairs(MainModule.HNS.TrackedHitboxes) do
                    trackedCount = trackedCount + 1
                end
                
                if trackedCount > 50 then
                    local newTable = {}
                    local counter = 0
                    for k, v in pairs(MainModule.HNS.TrackedHitboxes) do
                        if counter < 25 then  -- Сохраняем 25 самых новых
                            newTable[k] = v
                            counter = counter + 1
                        end
                    end
                    MainModule.HNS.TrackedHitboxes = newTable
                end
            end)
        end)
    end
end

-- RLGL GodMode (исправленная версия)
function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.GodModeTimeout then
        MainModule.RLGL.GodModeTimeout:Disconnect()
        MainModule.RLGL.GodModeTimeout = nil
    end
    
    if enabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
        
        -- Сбрасываем флаг получения урона
        MainModule.RLGL.DamageDetected = false
        
        -- Проверка урона (только один раз)
        local godModeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageCheck < MainModule.RLGL.DamageCheckRate then return end
            MainModule.RLGL.LastDamageCheck = currentTime
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Проверяем, получили ли мы урон (только один раз)
            if not MainModule.RLGL.DamageDetected and humanoid.Health < humanoid.MaxHealth then
                -- Устанавливаем флаг, что урон получен
                MainModule.RLGL.DamageDetected = true
                
                -- Телепортируем на безопасные координаты (один раз)
                character.HumanoidRootPart.CFrame = CFrame.new(-856, 1184, -550)
                
                -- Восстанавливаем здоровье
                humanoid.Health = humanoid.MaxHealth
                
                -- Запускаем таймер отключения через 8 секунд
                MainModule.RLGL.GodModeTimeout = game:GetService("RunService").Heartbeat:Connect(function()
                    task.wait(MainModule.RLGL.DamageCountdown)
                    MainModule.ToggleGodMode(false)
                    if MainModule.RLGL.GodModeTimeout then
                        MainModule.RLGL.GodModeTimeout:Disconnect()
                        MainModule.RLGL.GodModeTimeout = nil
                    end
                end)
            end
        end)
        
        table.insert(MainModule.ESPConnections, godModeConnection)
    else
        -- Сбрасываем флаг
        MainModule.RLGL.DamageDetected = false
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and MainModule.RLGL.OriginalHeight then
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, MainModule.RLGL.OriginalHeight, currentPos.Z)
        end
    end
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
        -- Создаем невидимые платформы и покрытие
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
        -- Удаляем платформы и покрытие
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
        
        -- Создаем полностью прозрачное покрытие
        MainModule.GlassBridge.GlassCover = Instance.new("Part")
        MainModule.GlassBridge.GlassCover.Name = "GlassBridgeCover"
        MainModule.GlassBridge.GlassCover.Size = Vector3.new(500, 5, 500)
        MainModule.GlassBridge.GlassCover.Position = Vector3.new(-200, 515, -1534)
        MainModule.GlassBridge.GlassCover.Anchored = true
        MainModule.GlassBridge.GlassCover.CanCollide = true
        MainModule.GlassBridge.GlassCover.Transparency = 1  -- Полностью прозрачный
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
                platform.Transparency = 1  -- Полностью прозрачный
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
        -- Создаем Anti-Fall платформу (видимую как стекло)
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
                    -- Телепортируем к концу моста
                    rootPart.CFrame = CFrame.new(MainModule.GlassBridge.EndPosition)
                    
                    -- Создаем эффект вспышки
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
    MainModule.GlassBridge.AntiFallPlatform.Transparency = 0.7  -- Как стекло
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
    -- Очищаем все соединения
    for _, conn in pairs(MainModule.ESPConnections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.ESPConnections = {}
    
    -- Очищаем ESP соединения игроков
    for _, conn in pairs(MainModule.PlayerESPConnections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.PlayerESPConnections = {}
    
    -- Очищаем HNS
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
    
    -- Очищаем Glass Bridge
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
    
    -- Очищаем ESP
    if MainModule.Misc.ESPEnabled then
        MainModule.ToggleESP(false)
    end
    
    -- Сбрасываем RLGL GodMode
    if MainModule.RLGL.GodMode then
        MainModule.ToggleGodMode(false)
    end
    
    -- Сбрасываем HNS состояния
    MainModule.HNS.TrackedHitboxes = {}
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
