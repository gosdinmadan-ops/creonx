-- Main.lua - Creon X v2.1 (Исправленная версия)
local MainModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

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
    DamageCheckRate = 0.5
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

MainModule.HNS = {
    SpikesKill = false,
    DisableSpikes = false,
    KillHiders = false,
    AutoDodge = false,
    LastDodgeTime = 0,
    DodgeCooldown = 1.0,
    DodgeRange = 10,
    LastSpikeKillTime = 0,
    SpikeKillCooldown = 3,
    CurrentSpikeKillTarget = nil,
    IsInSpikeKillProcess = false,
    OriginalSpikeKillPosition = nil,
    KillHidersRange = 100,
    CurrentKillTarget = nil,
    LastKillTime = 0,
    KillCooldown = 0.3
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.GlassBridge = {
    AntiBreak = false,
    GlassESPEnabled = false,
    GlassPlatform = false,
    FakeGlassCover = false,
    AntiFallPlatform = nil,
    WaterRemoved = false
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
    AntiStunRagdoll = false,
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    UnlockDashEnabled = false,
    UnlockPhantomStepEnabled = false,
    LastInjuredNotify = 0,
    LastESPUpdate = 0
}

-- Анти-рагидол система
MainModule.AntiRagdoll = {
    Enabled = false,
    LastHealth = 100,
    Connection = nil
}

-- Удаление эффектов
MainModule.EffectsRemover = {
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    Connection = nil,
    LastCleanup = 0,
    CleanupRate = 0.5
}

-- Новые ESP настройки для Snow/Box
MainModule.Misc.ESPSnow = {
    Enabled = true,
    ShowDistance = true,
    ShowHP = true
}

MainModule.Misc.ESPBox = {
    Enabled = true,
    ShowDistance = true,
    ShowName = true
}

-- ESP System (оптимизированная без лагов)
MainModule.ESPTable = {}
MainModule.ESPFolder = nil
MainModule.ESPUpdateRate = 0.5  -- Обновление каждые 0.5 секунд
MainModule.ESPCache = {}
MainModule.ESPConnection = nil
MainModule.PlayerESPConnections = {}

-- HNS шипы
MainModule.HNSSpikes = {
    Positions = {},
    OriginalPositions = {},
    Disabled = false
}

-- Glass Bridge платформы
MainModule.GlassBridgePlatforms = {}
MainModule.GlassBridgeCover = nil

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
local antiBreakConnection = nil
local hnsSpikesKillConnection = nil
local hnsKillHidersConnection = nil
local hnsAutoDodgeConnection = nil
local glassBridgeESPConnection = nil
local skySquidVoidKillConnection = nil
local removeInjuredConnection = nil
local unlockDashConnection = nil
local unlockPhantomStepConnection = nil
local glassBridgeAntiFallConnection = nil
local jumpRopeAntiFallConnection = nil
local skySquidAntiFallConnection = nil

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- Анти-рагидол функции
function MainModule.AntiRagdoll.Enable()
    MainModule.AntiRagdoll.Enabled = true
    
    if MainModule.AntiRagdoll.Connection then
        MainModule.AntiRagdoll.Connection:Disconnect()
    end
    
    MainModule.AntiRagdoll.Connection = RunService.Stepped:Connect(function()
        if not MainModule.AntiRagdoll.Enabled then return end
        
        pcall(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Проверяем текущее состояние
            local currentState = humanoid:GetState()
            local shouldRecover = false
            
            -- Состояния, которые нужно восстанавливать
            local badStates = {
                Enum.HumanoidStateType.FallingDown,
                Enum.HumanoidStateType.Ragdoll,
                Enum.HumanoidStateType.Dead,
                Enum.HumanoidStateType.Stunned
            }
            
            for _, state in ipairs(badStates) do
                if currentState == state then
                    shouldRecover = true
                    break
                end
            end
            
            -- Также проверяем резкое падение здоровья
            if humanoid.Health < MainModule.AntiRagdoll.LastHealth and MainModule.AntiRagdoll.LastHealth - humanoid.Health > 20 then
                shouldRecover = true
            end
            
            MainModule.AntiRagdoll.LastHealth = humanoid.Health
            
            if shouldRecover then
                -- Восстанавливаем состояние
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
                
                -- Убираем физические эффекты
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
                
                -- Убираем эффекты рагидола
                for _, obj in pairs(character:GetDescendants()) do
                    if obj:IsA("StringValue") then
                        if obj.Name:lower():find("ragdoll") or obj.Name:lower():find("stun") then
                            obj:Destroy()
                        end
                    end
                end
            end
        end)
    end)
    
    print("Anti Ragdoll: Включено")
end

function MainModule.AntiRagdoll.Disable()
    MainModule.AntiRagdoll.Enabled = false
    
    if MainModule.AntiRagdoll.Connection then
        MainModule.AntiRagdoll.Connection:Disconnect()
        MainModule.AntiRagdoll.Connection = nil
    end
    
    print("Anti Ragdoll: Выключено")
end

function MainModule.AntiRagdoll.ForceRecover()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        -- Принудительно восстанавливаем состояние
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
        
        -- Убираем физические эффекты
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
        
        print("Anti Ragdoll: Принудительное восстановление")
    end)
end

-- Удаление эффектов функции
function MainModule.EffectsRemover.RemoveInjuredEffects()
    local character = LocalPlayer.Character
    if not character then return 0 end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return 0 end
    
    local removedCount = 0
    
    -- Список эффектов для удаления
    local effectsToRemove = {}
    
    if MainModule.EffectsRemover.RemoveInjuredEnabled then
        table.insert(effectsToRemove, "injured")
        table.insert(effectsToRemove, "injuredwalking")
    end
    
    if MainModule.EffectsRemover.RemoveStunEnabled then
        table.insert(effectsToRemove, "stun")
        table.insert(effectsToRemove, "slow")
        table.insert(effectsToRemove, "freeze")
    end
    
    if #effectsToRemove == 0 then return 0 end
    
    -- 1. Удаляем объекты в персонаже
    for _, child in pairs(character:GetDescendants()) do
        local childName = child.Name:lower()
        for _, effectName in ipairs(effectsToRemove) do
            if string.find(childName, effectName) then
                child:Destroy()
                removedCount = removedCount + 1
                break
            end
        end
    end
    
    -- 2. Удаляем анимации
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        local trackName = track.Name:lower()
        for _, effectName in ipairs(effectsToRemove) do
            if string.find(trackName, effectName) then
                track:Stop()
                removedCount = removedCount + 1
                break
            end
        end
    end
    
    -- 3. Проверяем состояния Humanoid
    if MainModule.EffectsRemover.RemoveStunEnabled then
        if humanoid:GetState() == Enum.HumanoidStateType.Stunned then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            removedCount = removedCount + 1
        end
    end
    
    -- 4. Восстанавливаем скорость
    if removedCount > 0 then
        if humanoid.WalkSpeed < 16 then
            humanoid.WalkSpeed = 16
        end
    end
    
    -- 5. Поддерживаем максимальную скорость
    MainModule.EffectsRemover.MaintainMaxSpeed()
    
    return removedCount
end

function MainModule.EffectsRemover.MaintainMaxSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Устанавливаем максимальную скорость
    if humanoid.WalkSpeed < 16 then
        humanoid.WalkSpeed = 16
    end
    
    -- Удаляем модификаторы скорости
    for _, child in pairs(character:GetDescendants()) do
        if child:IsA("NumberValue") and child.Name:lower():find("speed") then
            if child.Value < 1 then
                child.Value = 1
            end
        end
    end
end

function MainModule.EffectsRemover.ToggleRemoveInjured(enabled)
    MainModule.EffectsRemover.RemoveInjuredEnabled = enabled
    MainModule.UpdateEffectsRemover()
end

function MainModule.EffectsRemover.ToggleRemoveStun(enabled)
    MainModule.EffectsRemover.RemoveStunEnabled = enabled
    MainModule.UpdateEffectsRemover()
end

function MainModule.UpdateEffectsRemover()
    if MainModule.EffectsRemover.Connection then
        MainModule.EffectsRemover.Connection:Disconnect()
        MainModule.EffectsRemover.Connection = nil
    end
    
    if MainModule.EffectsRemover.RemoveInjuredEnabled or MainModule.EffectsRemover.RemoveStunEnabled then
        MainModule.EffectsRemover.Connection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MainModule.EffectsRemover.LastCleanup >= MainModule.EffectsRemover.CleanupRate then
                MainModule.EffectsRemover.RemoveInjuredEffects()
                MainModule.EffectsRemover.LastCleanup = currentTime
            end
        end)
    end
end

-- Оптимизированная ESP System (без лагов)
function MainModule.CreatePlayerESP(player)
    if player == LocalPlayer then return end
    
    local cacheKey = "player_" .. player.UserId
    
    -- Очищаем старый ESP для этого игрока
    if MainModule.ESPTable[cacheKey] then
        if MainModule.ESPTable[cacheKey].Destroy then
            MainModule.ESPTable[cacheKey].Destroy()
        end
        MainModule.ESPTable[cacheKey] = nil
    end
    
    -- Создаем ESP когда игрок появляется
    local function setupESP(character)
        if not character then return end
        
        -- Ждем появления HumanoidRootPart
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not rootPart then return end
        
        -- Создаем Highlight
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_" .. player.Name
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(0, 170, 255)
        highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
        highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
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
        textLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        textLabel.TextSize = MainModule.Misc.ESPTextSize
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0.3
        textLabel.Parent = billboard
        
        -- Создаем Box если включено
        local box = nil
        if MainModule.Misc.ESPBox.Enabled then
            box = Instance.new("BoxHandleAdornment")
            box.Name = "ESP_Box_" .. player.Name
            box.Adornee = rootPart
            box.AlwaysOnTop = true
            box.Size = rootPart.Size + Vector3.new(0.5, 0.5, 0.5)
            box.Color3 = Color3.fromRGB(0, 170, 255)
            box.Transparency = 0.7
            box.ZIndex = 10
            box.Parent = MainModule.ESPFolder
        end
        
        -- Функция обновления текста
        local function updateText()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Формируем текст
            local text = player.DisplayName
            
            if MainModule.Misc.ESPNames then
                text = player.Name
                if player.DisplayName ~= player.Name then
                    text = player.DisplayName .. " (@" .. player.Name .. ")"
                end
            end
            
            -- Добавляем расстояние
            if MainModule.Misc.ESPDistance then
                local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if localRoot then
                    local distance = math.floor((rootPart.Position - localRoot.Position).Magnitude)
                    text = text .. " [" .. distance .. "m]"
                end
            end
            
            -- Добавляем HP
            if MainModule.Misc.ESPSnow.ShowHP then
                text = text .. " HP:" .. math.floor(humanoid.Health)
            end
            
            textLabel.Text = text
        end
        
        -- Соединение для обновления текста
        local updateConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Misc.ESPEnabled or not character.Parent then
                if updateConnection then
                    updateConnection:Disconnect()
                end
                return
            end
            
            updateText()
        end)
        
        -- Сохраняем ESP объекты
        MainModule.ESPTable[cacheKey] = {
            Highlight = highlight,
            Billboard = billboard,
            Box = box,
            Destroy = function()
                SafeDestroy(highlight)
                SafeDestroy(billboard)
                if box then SafeDestroy(box) end
                if updateConnection then
                    updateConnection:Disconnect()
                end
            end
        }
    end
    
    -- Подключаемся к появлению персонажа
    if player.Character then
        setupESP(player.Character)
    end
    
    local charConn = player.CharacterAdded:Connect(setupESP)
    table.insert(MainModule.PlayerESPConnections, charConn)
end

function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    -- Очищаем все ESP соединения
    for _, conn in pairs(MainModule.PlayerESPConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    MainModule.PlayerESPConnections = {}
    
    -- Очищаем старые ESP
    for _, esp in pairs(MainModule.ESPTable) do
        if esp and esp.Destroy then
            SafeDestroy(esp)
        end
    end
    MainModule.ESPTable = {}
    
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
    end
end

-- Jump Rope функции
function MainModule.TeleportToJumpRopeEnd()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(737.156372, 193.805084, 920.952515)
    end
end

function MainModule.DeleteJumpRope()
    if Workspace:FindFirstChild("Effects") then
        local rope = Workspace.Effects:FindFirstChild("rope")
        if rope then
            rope:Destroy()
        end
    end
end

-- HNS функции
function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
    
    if hnsSpikesKillConnection then
        hnsSpikesKillConnection:Disconnect()
        hnsSpikesKillConnection = nil
    end
    
    if enabled then
        -- При включении Spike Kill автоматически выключаем Disable Spikes если он был включен
        if MainModule.HNS.DisableSpikes then
            MainModule.HNS.DisableSpikes = false
            MainModule.ToggleDisableSpikes(false)
        end
        
        -- Сохраняем позиции шипов
        MainModule.HNSSpikes.Positions = {}
        MainModule.HNSSpikes.OriginalPositions = {}
        
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        table.insert(MainModule.HNSSpikes.Positions, spike.Position)
                        MainModule.HNSSpikes.OriginalPositions[spike] = spike.Position
                    end
                end
            end
        end)
        
        -- Запускаем процесс Spike Kill
        hnsSpikesKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.SpikesKill then return end
            if MainModule.HNS.IsInSpikeKillProcess then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastSpikeKillTime < MainModule.HNS.SpikeKillCooldown then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Проверяем, держим ли мы нож
            local hasKnife = false
            local knifeTool = nil
            
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                    hasKnife = true
                    knifeTool = tool
                    break
                end
            end
            
            -- Также проверяем Backpack
            if not hasKnife and LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                        hasKnife = true
                        knifeTool = tool
                        break
                    end
                end
            end
            
            if not hasKnife then return end
            
            -- Ищем ближайшего живого игрока-прячущегося
            local nearestHider = nil
            local nearestDistance = math.huge
            local targetRootPart = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
                    -- Проверяем, является ли игрок прячущимся
                    local isHider = player:GetAttribute("IsHider") or false
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and isHider then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        if (MainModule.HNS.CurrentSpikeKillTarget and player == MainModule.HNS.CurrentSpikeKillTarget) or 
                           (distance < nearestDistance and distance < 100) then
                            nearestDistance = distance
                            nearestHider = player
                            targetRootPart = targetRoot
                        end
                    end
                end
            end
            
            -- Если нашли живого прячущегося в радиусе 100
            if nearestHider and targetRootPart and nearestDistance < 100 then
                MainModule.HNS.CurrentSpikeKillTarget = nearestHider
                MainModule.HNS.IsInSpikeKillProcess = true
                
                -- Сохраняем оригинальную позицию
                local originalCFrame = rootPart.CFrame
                MainModule.HNS.OriginalSpikeKillPosition = originalCFrame
                
                -- 1. Телепортируемся за спину цели
                local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                rootPart.CFrame = teleportCFrame
                
                task.wait(0.2)
                
                -- 2. Атакуем ножом
                if knifeTool then
                    local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                    if remoteEvent then
                        pcall(function()
                            remoteEvent:FireServer()
                        end)
                    end
                end
                
                -- 3. Ждем немного чтобы анимация удара сработала
                task.wait(0.5)
                
                -- 4. Проверяем жив ли еще таргет
                local targetHumanoid = nearestHider.Character:FindFirstChildOfClass("Humanoid")
                if targetHumanoid and targetHumanoid.Health > 0 then
                    -- 5. Телепортируем цель к шипам
                    if #MainModule.HNSSpikes.Positions > 0 then
                        local randomSpike = MainModule.HNSSpikes.Positions[math.random(1, #MainModule.HNSSpikes.Positions)]
                        targetRootPart.CFrame = CFrame.new(randomSpike)
                        
                        -- 6. Ждем 2 секунды для гарантированного убийства
                        task.wait(2)
                        
                        -- 7. Возвращаемся на оригинальную позицию
                        rootPart.CFrame = originalCFrame
                    end
                else
                    -- Если цель уже умерла, просто возвращаемся
                    rootPart.CFrame = originalCFrame
                end
                
                -- Сбрасываем состояние
                MainModule.HNS.LastSpikeKillTime = tick()
                MainModule.HNS.IsInSpikeKillProcess = false
                
                -- Проверяем умер ли таргет
                if not nearestHider.Character or not nearestHider.Character:FindFirstChildOfClass("Humanoid") or 
                   nearestHider.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    MainModule.HNS.CurrentSpikeKillTarget = nil
                end
            end
        end)
    else
        -- Сбрасываем состояние
        MainModule.HNS.CurrentSpikeKillTarget = nil
        MainModule.HNS.IsInSpikeKillProcess = false
        MainModule.HNS.OriginalSpikeKillPosition = nil
    end
end

function MainModule.ToggleDisableSpikes(enabled)
    MainModule.HNS.DisableSpikes = enabled
    
    if enabled then
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        spike.CanTouch = false
                        spike.Transparency = 1
                    end
                end
            end
        end)
    else
        pcall(function()
            local spikes = Workspace:FindFirstChild("HideAndSeekMap") and 
                          Workspace.HideAndSeekMap:FindFirstChild("KillingParts")
            
            if spikes then
                for _, spike in pairs(spikes:GetChildren()) do
                    if spike:IsA("BasePart") then
                        spike.CanTouch = true
                        spike.Transparency = 0
                    end
                end
            end
        end)
    end
end

function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
    
    if hnsKillHidersConnection then
        hnsKillHidersConnection:Disconnect()
        hnsKillHidersConnection = nil
    end
    
    if enabled then
        hnsKillHidersConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.KillHiders then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastKillTime < MainModule.HNS.KillCooldown then return end
            
            local character = LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Проверяем, держим ли мы нож
            local hasKnife = false
            local knifeTool = nil
            
            for _, tool in pairs(character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                    hasKnife = true
                    knifeTool = tool
                    break
                end
            end
            
            -- Также проверяем Backpack
            if not hasKnife and LocalPlayer:FindFirstChild("Backpack") then
                for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("knife") or tool.Name:lower():find("dagger") or tool.Name:lower():find("fork") or tool.Name:lower():find("нож")) then
                        hasKnife = true
                        knifeTool = tool
                        break
                    end
                end
            end
            
            if not hasKnife then return end
            
            -- Ищем ближайшего живого игрока-прячущегося
            local nearestHider = nil
            local nearestDistance = math.huge
            local targetRootPart = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
                    -- Проверяем, является ли игрок прячущимся
                    local isHider = player:GetAttribute("IsHider") or false
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 and isHider then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        if (MainModule.HNS.CurrentKillTarget and player == MainModule.HNS.CurrentKillTarget) or 
                           (distance < nearestDistance and distance < 100) then
                            nearestDistance = distance
                            nearestHider = player
                            targetRootPart = targetRoot
                        end
                    end
                end
            end
            
            -- Если нашли живого прячущегося в радиусе 100
            if nearestHider and targetRootPart and nearestDistance < 100 then
                MainModule.HNS.CurrentKillTarget = nearestHider
                
                -- Поворачиваемся к цели
                local direction = (targetRootPart.Position - rootPart.Position).Unit
                local lookVector = Vector3.new(direction.X, 0, direction.Z)
                if lookVector.Magnitude > 0 then
                    rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
                end
                
                -- Если близко, телепортируемся за спину
                if nearestDistance > 3 then
                    local teleportCFrame = targetRootPart.CFrame * CFrame.new(0, 0, -2)
                    rootPart.CFrame = teleportCFrame
                end
                
                -- Атакуем ножом
                if knifeTool then
                    local remoteEvent = knifeTool:FindFirstChild("RemoteEvent")
                    if remoteEvent then
                        pcall(function()
                            remoteEvent:FireServer()
                        end)
                    end
                end
                
                MainModule.HNS.LastKillTime = tick()
                
                -- Проверяем умер ли таргет
                if not nearestHider.Character or not nearestHider.Character:FindFirstChildOfClass("Humanoid") or 
                   nearestHider.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                    MainModule.HNS.CurrentKillTarget = nil
                end
            end
        end)
    else
        MainModule.HNS.CurrentKillTarget = nil
    end
end

-- HNS Auto Dodge функция
function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
    
    if hnsAutoDodgeConnection then
        hnsAutoDodgeConnection:Disconnect()
        hnsAutoDodgeConnection = nil
    end
    
    if enabled then
        hnsAutoDodgeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.HNS.AutoDodge then return end
            
            local currentTime = tick()
            if currentTime - MainModule.HNS.LastDodgeTime < MainModule.HNS.DodgeCooldown then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if not rootPart or not humanoid or humanoid.Health <= 0 then return end
            
            -- Ищем ближайших ищущих с ножом
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetCharacter = player.Character
                    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                        local distance = (rootPart.Position - targetRoot.Position).Magnitude
                        
                        if distance <= MainModule.HNS.DodgeRange then
                            -- Проверяем, держит ли он нож
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
                                -- Проверяем, смотрит ли он на нас
                                local directionToUs = (rootPart.Position - targetRoot.Position).Unit
                                local lookDirection = targetRoot.CFrame.LookVector
                                local dotProduct = directionToUs:Dot(lookDirection)
                                
                                if dotProduct > 0.7 and distance < 3 then
                                    -- Доджим
                                    pcall(function()
                                        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                                    end)
                                    
                                    -- Телепортируемся в сторону
                                    local randomAngle = math.random() * 2 * math.pi
                                    local teleportDistance = 4
                                    local offset = Vector3.new(
                                        math.cos(randomAngle) * teleportDistance,
                                        0,
                                        math.sin(randomAngle) * teleportDistance
                                    )
                                    
                                    local newPosition = rootPart.Position + offset
                                    rootPart.CFrame = CFrame.new(newPosition)
                                    
                                    MainModule.HNS.LastDodgeTime = tick()
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Glass Bridge функции с Anti Fall платформой
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    if enabled then
        -- Удаляем воду/синий цвет
        MainModule.RemoveGlassBridgeWater()
        
        -- Создаем Anti-Fall платформу
        MainModule.CreateGlassBridgeAntiFallPlatform()
        
        antiBreakConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
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
        -- Удаляем платформу
        MainModule.RemoveGlassBridgeAntiFallPlatform()
    end
end

function MainModule.RemoveGlassBridgeWater()
    pcall(function()
        local glassBridge = Workspace:FindFirstChild("GlassBridge")
        if glassBridge then
            for _, obj in pairs(glassBridge:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("water") or obj.Name:lower():find("blue") or obj.Color == Color3.fromRGB(0, 0, 255)) then
                    obj.Transparency = 1
                    obj.CanTouch = false
                end
            end
        end
        MainModule.GlassBridge.WaterRemoved = true
    end)
end

function MainModule.CreateGlassBridgeAntiFallPlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        SafeDestroy(MainModule.GlassBridge.AntiFallPlatform)
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    -- Создаем белую Anti-Fall платформу (видимую)
    MainModule.GlassBridge.AntiFallPlatform = Instance.new("Part")
    MainModule.GlassBridge.AntiFallPlatform.Name = "GlassBridgeAntiFallPlatform"
    MainModule.GlassBridge.AntiFallPlatform.Size = Vector3.new(200, 5, 200)
    MainModule.GlassBridge.AntiFallPlatform.Position = Vector3.new(-200, 515, -1534)
    MainModule.GlassBridge.AntiFallPlatform.Anchored = true
    MainModule.GlassBridge.AntiFallPlatform.CanCollide = true
    MainModule.GlassBridge.AntiFallPlatform.Transparency = 0  -- Видимая
    MainModule.GlassBridge.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.GlassBridge.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)  -- Белый цвет
    MainModule.GlassBridge.AntiFallPlatform.Parent = Workspace
end

function MainModule.RemoveGlassBridgeAntiFallPlatform()
    if MainModule.GlassBridge.AntiFallPlatform then
        SafeDestroy(MainModule.GlassBridge.AntiFallPlatform)
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
end

function MainModule.ToggleGlassBridgeESP(enabled)
    MainModule.GlassBridge.GlassESPEnabled = enabled
    
    if glassBridgeESPConnection then
        glassBridgeESPConnection:Disconnect()
        glassBridgeESPConnection = nil
    end
    
    if enabled then
        local function updateGlassESP()
            pcall(function()
                local glassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
                if not glassHolder then return end

                for _, tilePair in pairs(glassHolder:GetChildren()) do
                    for _, tileModel in pairs(tilePair:GetChildren()) do
                        if tileModel:IsA("Model") and tileModel.PrimaryPart then
                            local isBreakable = tileModel.PrimaryPart:GetAttribute("exploitingisevil") == true
                            local targetColor = Color3.fromRGB(163, 162, 165)
                            
                            if not MainModule.GlassBridge.AntiBreak then
                                targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                            else
                                targetColor = Color3.fromRGB(0, 255, 0)
                            end

                            for _, part in pairs(tileModel:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = targetColor
                                    part.Transparency = 0.3
                                    part.Material = Enum.Material.Glass
                                end
                            end
                        end
                    end
                end
            end)
        end
        
        updateGlassESP()
        
        glassBridgeESPConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.GlassBridge.GlassESPEnabled then return end
            updateGlassESP()
        end)
    else
        pcall(function()
            local glassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
            if not glassHolder then return end

            for _, tilePair in pairs(glassHolder:GetChildren()) do
                for _, tileModel in pairs(tilePair:GetChildren()) do
                    if tileModel:IsA("Model") and tileModel.PrimaryPart then
                        for _, part in pairs(tileModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = Color3.fromRGB(163, 162, 165)
                                part.Transparency = 0
                                part.Material = Enum.Material.Glass
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Jump Rope Anti Fall
function MainModule.ToggleJumpRopeAntiFall(enabled)
    if enabled then
        MainModule.CreateJumpRopeAntiFallPlatform()
    else
        MainModule.RemoveJumpRopeAntiFallPlatform()
    end
end

function MainModule.CreateJumpRopeAntiFallPlatform()
    if MainModule.JumpRope.AntiFallPlatform then
        SafeDestroy(MainModule.JumpRope.AntiFallPlatform)
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    -- Создаем белую Anti-Fall платформу для Jump Rope
    MainModule.JumpRope.AntiFallPlatform = Instance.new("Part")
    MainModule.JumpRope.AntiFallPlatform.Name = "JumpRopeAntiFallPlatform"
    MainModule.JumpRope.AntiFallPlatform.Size = Vector3.new(100, 5, 100)
    MainModule.JumpRope.AntiFallPlatform.Position = Vector3.new(737.156372, 188.805084, 920.952515)
    MainModule.JumpRope.AntiFallPlatform.Anchored = true
    MainModule.JumpRope.AntiFallPlatform.CanCollide = true
    MainModule.JumpRope.AntiFallPlatform.Transparency = 0  -- Видимая
    MainModule.JumpRope.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.JumpRope.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)  -- Белый цвет
    MainModule.JumpRope.AntiFallPlatform.Parent = Workspace
end

function MainModule.RemoveJumpRopeAntiFallPlatform()
    if MainModule.JumpRope.AntiFallPlatform then
        SafeDestroy(MainModule.JumpRope.AntiFallPlatform)
        MainModule.JumpRope.AntiFallPlatform = nil
    end
end

-- Sky Squid функции с Anti Fall платформой
function MainModule.ToggleSkySquidAntiFall(enabled)
    MainModule.SkySquid.AntiFall = enabled
    
    if skySquidAntiFallConnection then
        skySquidAntiFallConnection:Disconnect()
        skySquidAntiFallConnection = nil
    end
    
    if enabled then
        -- Создаем Anti-Fall платформу для Sky Squid
        MainModule.CreateSkySquidAntiFallPlatform()
    else
        if MainModule.SkySquid.AntiFallPlatform then
            SafeDestroy(MainModule.SkySquid.AntiFallPlatform)
            MainModule.SkySquid.AntiFallPlatform = nil
        end
    end
end

function MainModule.CreateSkySquidAntiFallPlatform()
    if MainModule.SkySquid.AntiFallPlatform then
        SafeDestroy(MainModule.SkySquid.AntiFallPlatform)
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    -- Создаем белую Anti-Fall платформу для Sky Squid
    MainModule.SkySquid.AntiFallPlatform = Instance.new("Part")
    MainModule.SkySquid.AntiFallPlatform.Name = "SkySquidAntiFallPlatform"
    MainModule.SkySquid.AntiFallPlatform.Size = Vector3.new(500, 5, 500)
    MainModule.SkySquid.AntiFallPlatform.Position = Vector3.new(0, 50, 0)  -- На высоте 50
    MainModule.SkySquid.AntiFallPlatform.Anchored = true
    MainModule.SkySquid.AntiFallPlatform.CanCollide = true
    MainModule.SkySquid.AntiFallPlatform.Transparency = 0  -- Видимая
    MainModule.SkySquid.AntiFallPlatform.Material = Enum.Material.Plastic
    MainModule.SkySquid.AntiFallPlatform.Color = Color3.fromRGB(255, 255, 255)  -- Белый цвет
    MainModule.SkySquid.AntiFallPlatform.Parent = Workspace
end

function MainModule.ToggleSkySquidVoidKill(enabled)
    MainModule.SkySquid.VoidKill = enabled
    
    if skySquidVoidKillConnection then
        skySquidVoidKillConnection:Disconnect()
        skySquidVoidKillConnection = nil
    end
    
    if enabled then
        -- Создаем Safe Platform при включении Void Kill
        MainModule.CreateSkySquidSafePlatform()
        
        skySquidVoidKillConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.SkySquid.VoidKill then return end
            
            pcall(function()
                local character = LocalPlayer.Character
                if not character then return end
                
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then return end
                
                -- Ищем ближайших игроков для телепортации в бездну
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            
                            if distance < 15 then
                                local voidPosition = Vector3.new(0, -10000, 0)
                                targetRoot.CFrame = CFrame.new(voidPosition)
                                
                                local platform = Instance.new("Part")
                                platform.Name = "VoidPlatform_" .. player.Name
                                platform.Size = Vector3.new(20, 5, 20)
                                platform.Position = voidPosition - Vector3.new(0, 3, 0)
                                platform.Anchored = true
                                platform.CanCollide = true
                                platform.Transparency = 0.5
                                platform.Material = Enum.Material.Neon
                                platform.Color = Color3.fromRGB(255, 0, 255)
                                platform.Parent = Workspace
                                
                                delay(10, function()
                                    if platform and platform.Parent then
                                        platform:Destroy()
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
        end)
    else
        if MainModule.SkySquid.SafePlatform then
            SafeDestroy(MainModule.SkySquid.SafePlatform)
            MainModule.SkySquid.SafePlatform = nil
        end
    end
end

function MainModule.CreateSkySquidSafePlatform()
    if MainModule.SkySquid.SafePlatform then
        SafeDestroy(MainModule.SkySquid.SafePlatform)
        MainModule.SkySquid.SafePlatform = nil
    end
    
    -- Создаем Safe Platform
    MainModule.SkySquid.SafePlatform = Instance.new("Part")
    MainModule.SkySquid.SafePlatform.Name = "SkySquidSafePlatform"
    MainModule.SkySquid.SafePlatform.Size = Vector3.new(50, 5, 50)
    MainModule.SkySquid.SafePlatform.Position = Vector3.new(0, 200, 0)
    MainModule.SkySquid.SafePlatform.Anchored = true
    MainModule.SkySquid.SafePlatform.CanCollide = true
    MainModule.SkySquid.SafePlatform.Transparency = 0.3
    MainModule.SkySquid.SafePlatform.Material = Enum.Material.Neon
    MainModule.SkySquid.SafePlatform.Color = Color3.fromRGB(0, 0, 255)
    MainModule.SkySquid.SafePlatform.Parent = Workspace
end

-- Функции скорости
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    local player = LocalPlayer
    
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    if enabled then
        local character = player.Character or player.CharacterAdded:Wait()
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                MainModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
            end
        end
        
        speedConnection = RunService.Heartbeat:Connect(function()
            local character = player.Character
            if character and MainModule.SpeedHack.Enabled then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = MainModule.SpeedHack.CurrentSpeed
                end
            end
        end)
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

-- Rebel функция
function MainModule.ToggleRebel(enabled)
    MainModule.Rebel.Enabled = enabled
    _G.InstantRebel = enabled
end

-- RLGL функции с проверкой урона
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

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
        if MainModule.RLGL.GodModeTimeout then
            MainModule.RLGL.GodModeTimeout:Disconnect()
            MainModule.RLGL.GodModeTimeout = nil
        end
    end
    
    if enabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
        
        -- Проверка урона
        godModeConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            local currentTime = tick()
            if currentTime - MainModule.RLGL.LastDamageCheck < MainModule.RLGL.DamageCheckRate then return end
            MainModule.RLGL.LastDamageCheck = currentTime
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            -- Проверяем, получили ли мы урон
            if humanoid.Health < humanoid.MaxHealth then
                -- Телепортируем на безопасные координаты
                character.HumanoidRootPart.CFrame = CFrame.new(-856, 1184, -550)
                
                -- Восстанавливаем здоровье
                humanoid.Health = humanoid.MaxHealth
                
                -- Автоматически выключаем GodMode через 10 секунд
                if MainModule.RLGL.GodModeTimeout then
                    MainModule.RLGL.GodModeTimeout:Disconnect()
                end
                
                MainModule.RLGL.GodModeTimeout = game:GetService("RunService").Heartbeat:Connect(function()
                    task.wait(10)
                    MainModule.ToggleGodMode(false)
                    if MainModule.RLGL.GodModeTimeout then
                        MainModule.RLGL.GodModeTimeout:Disconnect()
                        MainModule.RLGL.GodModeTimeout = nil
                    end
                end)
            end
        end)
    else
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") and MainModule.RLGL.OriginalHeight then
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, MainModule.RLGL.OriginalHeight, currentPos.Z)
        end
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
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

-- Вспомогательная функция задержки
local function delay(seconds, callback)
    task.spawn(function()
        task.wait(seconds)
        pcall(callback)
    end)
end

-- Очистка при закрытии
function MainModule.Cleanup()
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, antiBreakConnection, MainModule.ESPConnection,
        hnsSpikesKillConnection, hnsKillHidersConnection, hnsAutoDodgeConnection,
        glassBridgeESPConnection, skySquidVoidKillConnection, removeInjuredConnection,
        unlockDashConnection, unlockPhantomStepConnection, MainModule.AntiRagdoll.Connection,
        MainModule.EffectsRemover.Connection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем ESP соединения игроков
    for _, conn in pairs(MainModule.PlayerESPConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    MainModule.PlayerESPConnections = {}
    
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
    
    -- Очищаем ESP
    if MainModule.Misc.ESPEnabled then
        MainModule.ToggleESP(false)
    end
    
    -- Удаляем папку ESP
    if MainModule.ESPFolder then
        SafeDestroy(MainModule.ESPFolder)
        MainModule.ESPFolder = nil
    end
    
    -- Удаляем платформы
    if MainModule.GlassBridge.AntiFallPlatform then
        SafeDestroy(MainModule.GlassBridge.AntiFallPlatform)
        MainModule.GlassBridge.AntiFallPlatform = nil
    end
    
    if MainModule.JumpRope.AntiFallPlatform then
        SafeDestroy(MainModule.JumpRope.AntiFallPlatform)
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    
    if MainModule.SkySquid.AntiFallPlatform then
        SafeDestroy(MainModule.SkySquid.AntiFallPlatform)
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    
    if MainModule.SkySquid.SafePlatform then
        SafeDestroy(MainModule.SkySquid.SafePlatform)
        MainModule.SkySquid.SafePlatform = nil
    end
    
    -- Восстанавливаем шипы
    if MainModule.HNS.DisableSpikes then
        MainModule.ToggleDisableSpikes(false)
    end
    
    -- Удаляем Glass Bridge защитные платформы
    for _, platform in pairs(MainModule.GlassBridgePlatforms) do
        if platform and platform.Parent then
            SafeDestroy(platform)
        end
    end
    MainModule.GlassBridgePlatforms = {}
    
    -- Сбрасываем HNS состояния
    MainModule.HNS.CurrentSpikeKillTarget = nil
    MainModule.HNS.IsInSpikeKillProcess = false
    MainModule.HNS.OriginalSpikeKillPosition = nil
    MainModule.HNS.CurrentKillTarget = nil
    
    -- Сбрасываем RLGL GodMode timeout
    if MainModule.RLGL.GodModeTimeout then
        MainModule.RLGL.GodModeTimeout:Disconnect()
        MainModule.RLGL.GodModeTimeout = nil
    end
end

-- Автоматическая очистка при выходе
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players").LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule
