-- Misc.lua - Разные функции
local MiscModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Переменные
MiscModule.SpeedHack = {
    Enabled = false,
    DefaultSpeed = 16,
    CurrentSpeed = 16,
    MaxSpeed = 150,
    MinSpeed = 16
}

MiscModule.Misc = {
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
    LastInjuredNotify = 0
}

-- ESP настройки
MiscModule.Misc.ESPSnow = {
    Enabled = true,
    ShowDistance = true,
    ShowHP = true
}

MiscModule.Misc.ESPBox = {
    Enabled = true,
    ShowDistance = true,
    ShowName = true
}

-- ESP System
MiscModule.ESPTable = {}
MiscModule.ESPFolder = nil
MiscModule.ESPUpdateRate = 0.5
MiscModule.ESPCache = {}
MiscModule.ESPConnection = nil
MiscModule.PlayerESPConnections = {}

-- Анти-рагидол система
MiscModule.AntiRagdoll = {
    Enabled = false,
    LastHealth = 100,
    Connection = nil
}

-- Удаление эффектов
MiscModule.EffectsRemover = {
    RemoveInjuredEnabled = false,
    RemoveStunEnabled = false,
    Connection = nil,
    LastCleanup = 0,
    CleanupRate = 0.5
}

-- Соединения
local speedConnection = nil
local instaInteractConnection = nil
local noCooldownConnection = nil
local antiStunConnection = nil
local antiStunRagdollConnection = nil
local removeInjuredConnection = nil

-- Вспомогательные функции
local function SafeDestroy(obj)
    if obj and obj.Parent then
        pcall(function() obj:Destroy() end)
    end
end

-- Функции скорости
function MiscModule.ToggleSpeedHack(enabled)
    MiscModule.SpeedHack.Enabled = enabled
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
                MiscModule.SpeedHack.DefaultSpeed = humanoid.WalkSpeed
            end
        end
        
        speedConnection = RunService.Heartbeat:Connect(function()
            local character = player.Character
            if character and MiscModule.SpeedHack.Enabled then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = MiscModule.SpeedHack.CurrentSpeed
                end
            end
        end)
    else
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = MiscModule.SpeedHack.DefaultSpeed
            end
        end
    end
end

function MiscModule.SetSpeed(value)
    if value < MiscModule.SpeedHack.MinSpeed then
        value = MiscModule.SpeedHack.MinSpeed
    elseif value > MiscModule.SpeedHack.MaxSpeed then
        value = MiscModule.SpeedHack.MaxSpeed
    end
    
    MiscModule.SpeedHack.CurrentSpeed = value
    
    if MiscModule.SpeedHack.Enabled then
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
function MiscModule.TeleportUp100()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
    end
end

function MiscModule.TeleportDown40()
    local player = LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, -40, 0)
    end
end

-- Anti Stun QTE функция
function MiscModule.ToggleAntiStunQTE(enabled)
    MiscModule.AutoQTE = MiscModule.AutoQTE or {AntiStunEnabled = false}
    MiscModule.AutoQTE.AntiStunEnabled = enabled
    
    if antiStunConnection then
        antiStunConnection:Disconnect()
        antiStunConnection = nil
    end
    
    if enabled then
        antiStunConnection = RunService.Heartbeat:Connect(function()
            if not MiscModule.AutoQTE.AntiStunEnabled then return end
            
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

-- Анти-рагидол функции
function MiscModule.AntiRagdoll.Enable()
    MiscModule.AntiRagdoll.Enabled = true
    
    if MiscModule.AntiRagdoll.Connection then
        MiscModule.AntiRagdoll.Connection:Disconnect()
    end
    
    MiscModule.AntiRagdoll.Connection = RunService.Stepped:Connect(function()
        if not MiscModule.AntiRagdoll.Enabled then return end
        
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
            if humanoid.Health < MiscModule.AntiRagdoll.LastHealth and MiscModule.AntiRagdoll.LastHealth - humanoid.Health > 20 then
                shouldRecover = true
            end
            
            MiscModule.AntiRagdoll.LastHealth = humanoid.Health
            
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

function MiscModule.AntiRagdoll.Disable()
    MiscModule.AntiRagdoll.Enabled = false
    
    if MiscModule.AntiRagdoll.Connection then
        MiscModule.AntiRagdoll.Connection:Disconnect()
        MiscModule.AntiRagdoll.Connection = nil
    end
    
    print("Anti Ragdoll: Выключено")
end

function MiscModule.AntiRagdoll.ForceRecover()
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
function MiscModule.EffectsRemover.RemoveInjuredEffects()
    local character = LocalPlayer.Character
    if not character then return 0 end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return 0 end
    
    local removedCount = 0
    
    -- Список эффектов для удаления
    local effectsToRemove = {}
    
    if MiscModule.EffectsRemover.RemoveInjuredEnabled then
        table.insert(effectsToRemove, "injured")
        table.insert(effectsToRemove, "injuredwalking")
    end
    
    if MiscModule.EffectsRemover.RemoveStunEnabled then
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
    if MiscModule.EffectsRemover.RemoveStunEnabled then
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
    MiscModule.EffectsRemover.MaintainMaxSpeed()
    
    return removedCount
end

function MiscModule.EffectsRemover.MaintainMaxSpeed()
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

function MiscModule.EffectsRemover.ToggleRemoveInjured(enabled)
    MiscModule.EffectsRemover.RemoveInjuredEnabled = enabled
    MiscModule.UpdateEffectsRemover()
end

function MiscModule.EffectsRemover.ToggleRemoveStun(enabled)
    MiscModule.EffectsRemover.RemoveStunEnabled = enabled
    MiscModule.UpdateEffectsRemover()
end

function MiscModule.UpdateEffectsRemover()
    if MiscModule.EffectsRemover.Connection then
        MiscModule.EffectsRemover.Connection:Disconnect()
        MiscModule.EffectsRemover.Connection = nil
    end
    
    if MiscModule.EffectsRemover.RemoveInjuredEnabled or MiscModule.EffectsRemover.RemoveStunEnabled then
        MiscModule.EffectsRemover.Connection = RunService.Heartbeat:Connect(function()
            local currentTime = tick()
            if currentTime - MiscModule.EffectsRemover.LastCleanup >= MiscModule.EffectsRemover.CleanupRate then
                MiscModule.EffectsRemover.RemoveInjuredEffects()
                MiscModule.EffectsRemover.LastCleanup = currentTime
            end
        end)
    end
end

-- ESP функции
function MiscModule.CreatePlayerESP(player)
    if player == LocalPlayer then return end
    
    local cacheKey = "player_" .. player.UserId
    
    -- Очищаем старый ESP для этого игрока
    if MiscModule.ESPTable[cacheKey] then
        if MiscModule.ESPTable[cacheKey].Destroy then
            MiscModule.ESPTable[cacheKey].Destroy()
        end
        MiscModule.ESPTable[cacheKey] = nil
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
        highlight.FillTransparency = MiscModule.Misc.ESPFillTransparency
        highlight.OutlineColor = Color3.fromRGB(0, 170, 255)
        highlight.OutlineTransparency = MiscModule.Misc.ESPOutlineTransparency
        highlight.Enabled = MiscModule.Misc.ESPHighlight
        highlight.Parent = MiscModule.ESPFolder
        
        -- Создаем Billboard для текста
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Text_" .. player.Name
        billboard.Adornee = rootPart
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = MiscModule.ESPFolder
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ESP_Label"
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
        textLabel.TextSize = MiscModule.Misc.ESPTextSize
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0.3
        textLabel.Parent = billboard
        
        -- Создаем Box если включено
        local box = nil
        if MiscModule.Misc.ESPBox.Enabled then
            box = Instance.new("BoxHandleAdornment")
            box.Name = "ESP_Box_" .. player.Name
            box.Adornee = rootPart
            box.AlwaysOnTop = true
            box.Size = rootPart.Size + Vector3.new(0.5, 0.5, 0.5)
            box.Color3 = Color3.fromRGB(0, 170, 255)
            box.Transparency = 0.7
            box.ZIndex = 10
            box.Parent = MiscModule.ESPFolder
        end
        
        -- Функция обновления текста
        local function updateText()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            
            -- Формируем текст
            local text = player.DisplayName
            
            if MiscModule.Misc.ESPNames then
                text = player.Name
                if player.DisplayName ~= player.Name then
                    text = player.DisplayName .. " (@" .. player.Name .. ")"
                end
            end
            
            -- Добавляем расстояние
            if MiscModule.Misc.ESPDistance then
                local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if localRoot then
                    local distance = math.floor((rootPart.Position - localRoot.Position).Magnitude)
                    text = text .. " [" .. distance .. "m]"
                end
            end
            
            -- Добавляем HP
            if MiscModule.Misc.ESPSnow.ShowHP then
                text = text .. " HP:" .. math.floor(humanoid.Health)
            end
            
            textLabel.Text = text
        end
        
        -- Соединение для обновления текста
        local updateConnection = RunService.Heartbeat:Connect(function()
            if not MiscModule.Misc.ESPEnabled or not character.Parent then
                if updateConnection then
                    updateConnection:Disconnect()
                end
                return
            end
            
            updateText()
        end)
        
        -- Сохраняем ESP объекты
        MiscModule.ESPTable[cacheKey] = {
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
    table.insert(MiscModule.PlayerESPConnections, charConn)
end

function MiscModule.ToggleESP(enabled)
    MiscModule.Misc.ESPEnabled = enabled
    
    -- Очищаем все ESP соединения
    for _, conn in pairs(MiscModule.PlayerESPConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    MiscModule.PlayerESPConnections = {}
    
    -- Очищаем старые ESP
    for _, esp in pairs(MiscModule.ESPTable) do
        if esp and esp.Destroy then
            SafeDestroy(esp)
        end
    end
    MiscModule.ESPTable = {}
    
    -- Удаляем папку ESP
    if MiscModule.ESPFolder then
        SafeDestroy(MiscModule.ESPFolder)
        MiscModule.ESPFolder = nil
    end
    
    if enabled then
        -- Создаем новую папку ESP
        MiscModule.ESPFolder = Instance.new("Folder")
        MiscModule.ESPFolder.Name = "CreonESP"
        MiscModule.ESPFolder.Parent = Workspace
        
        -- Создаем ESP для всех игроков
        for _, player in pairs(Players:GetPlayers()) do
            MiscModule.CreatePlayerESP(player)
        end
        
        -- Подключаемся к новым игрокам
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            MiscModule.CreatePlayerESP(player)
        end)
        table.insert(MiscModule.PlayerESPConnections, playerAddedConn)
    end
end

-- Функции для ESP компонентов
function MiscModule.ToggleSnowESP(enabled)
    MiscModule.Misc.ESPSnow.Enabled = enabled
    if MiscModule.Misc.ESPEnabled then
        MiscModule.ToggleESP(false)
        task.wait(0.1)
        MiscModule.ToggleESP(true)
    end
end

function MiscModule.ToggleBoxESP(enabled)
    MiscModule.Misc.ESPBox.Enabled = enabled
    if MiscModule.Misc.ESPEnabled then
        MiscModule.ToggleESP(false)
        task.wait(0.1)
        MiscModule.ToggleESP(true)
    end
end

-- Misc функции
function MiscModule.ToggleInstaInteract(enabled)
    MiscModule.Misc.InstaInteract = enabled
    
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

function MiscModule.ToggleNoCooldownProximity(enabled)
    MiscModule.Misc.NoCooldownProximity = enabled
    
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
            if MiscModule.Misc.NoCooldownProximity then
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
        end)
    end
end

-- Unlock функции (Don't work)
function MiscModule.ToggleUnlockDash(enabled)
    MiscModule.Misc.UnlockDashEnabled = enabled
    if enabled then
        warn("Unlock Dash: Don't work (Coming Soon)")
    end
end

function MiscModule.ToggleUnlockPhantomStep(enabled)
    MiscModule.Misc.UnlockPhantomStepEnabled = enabled
    if enabled then
        warn("Unlock Phantom Step: Don't work (Coming Soon)")
    end
end

-- Функция для получения координат
function MiscModule.GetPlayerPosition()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

-- Очистка
function MiscModule.Cleanup()
    print("Misc module cleanup")
    
    local connections = {
        speedConnection, instaInteractConnection, noCooldownConnection,
        antiStunConnection, MiscModule.AntiRagdoll.Connection,
        MiscModule.EffectsRemover.Connection, MiscModule.ESPConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Очищаем ESP
    if MiscModule.ESPFolder then
        SafeDestroy(MiscModule.ESPFolder)
        MiscModule.ESPFolder = nil
    end
end

return MiscModule
