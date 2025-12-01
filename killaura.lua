-- Killaura.lua - Killaura модуль для Creon X v2.1
local KillauraModule = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

-- Локальный игрок
local LocalPlayer = Players.LocalPlayer

-- Переменные
KillauraModule.Enabled = false
KillauraModule.Range = 30
KillauraModule.Cooldown = 0.3
KillauraModule.SmoothFollow = true
KillauraModule.FollowSpeed = 0.1
KillauraModule.ImprovedMode = false
KillauraModule.RageMode = false
KillauraModule.SmartMode = false
KillauraModule.AutoAttack = false

-- Соединения
local killauraConnection = nil
local currentTarget = nil
local originalSizes = {}
local isHoldingShift = false

-- Вспомогательные функции
local function findNearestTarget()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                if distance < nearestDistance and distance < KillauraModule.Range then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

local function pressShift()
    if not isHoldingShift then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        isHoldingShift = true
    end
end

local function releaseShift()
    if isHoldingShift then
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
        isHoldingShift = false
    end
end

-- Плавное следование за целью
local function smoothFollowTarget(target)
    if not target or not target.Character then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart or not targetRoot then return end
    
    local targetPosition = targetRoot.Position
    local currentPosition = rootPart.Position
    
    -- Рассчитываем направление к цели
    local direction = (targetPosition - currentPosition).Unit
    
    if KillauraModule.RageMode then
        -- Rage Mode: более агрессивное следование
        local newPosition = currentPosition + (direction * (KillauraModule.FollowSpeed * 20))
        rootPart.CFrame = CFrame.new(newPosition.X, currentPosition.Y, newPosition.Z)
    else
        -- Smooth Mode: плавное движение
        local newPosition = currentPosition + (direction * (KillauraModule.FollowSpeed * 10))
        
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(rootPart, tweenInfo, {
            CFrame = CFrame.new(newPosition.X, currentPosition.Y, newPosition.Z)
        })
        tween:Play()
    end
    
    -- Поворачиваемся к цели
    local lookVector = Vector3.new(direction.X, 0, direction.Z)
    if lookVector.Magnitude > 0 then
        rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
    end
end

-- Атака цели
local function attackTarget(target)
    if not target or not target.Character then return end
    
    if KillauraModule.RageMode then
        -- Rage Mode: максимальная агрессия
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        pressShift()
        
        local rageKeys = {Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.Q, Enum.KeyCode.R, Enum.KeyCode.T}
        for _, key in pairs(rageKeys) do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.005)
        end
        
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        releaseShift()
        
        for _, key in pairs(rageKeys) do
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end
        
    elseif KillauraModule.ImprovedMode then
        -- Improved Mode: улучшенная атака
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        
        local attackKeys = {Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.Q, Enum.KeyCode.R}
        for _, key in pairs(attackKeys) do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end
        
    else
        -- Normal Mode: обычная атака
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        
        local attackKeys = {Enum.KeyCode.E, Enum.KeyCode.F}
        for _, key in pairs(attackKeys) do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.02)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end
    end
end

-- Improved Mode: увеличение размеров голов
local function setupImprovedMode(enabled)
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head and not originalSizes[head] then
                    originalSizes[head] = head.Size
                    head.Size = head.Size * 1.5
                end
            end
        end
    else
        -- Восстанавливаем оригинальные размеры
        for head, originalSize in pairs(originalSizes) do
            if head and head.Parent then
                head.Size = originalSize
            end
        end
        originalSizes = {}
    end
end

-- Основная функция Killaura
function KillauraModule.Toggle(enabled)
    KillauraModule.Enabled = enabled
    
    if killauraConnection then
        killauraConnection:Disconnect()
        killauraConnection = nil
    end
    
    if enabled then
        -- Настраиваем Improved Mode если включен
        if KillauraModule.ImprovedMode then
            setupImprovedMode(true)
        end
        
        killauraConnection = RunService.Heartbeat:Connect(function()
            if not KillauraModule.Enabled then return end
            
            pcall(function()
                -- Ищем новую цель если нет текущей
                if not currentTarget or not currentTarget.Character or 
                   (currentTarget.Character:FindFirstChild("Humanoid") and 
                    currentTarget.Character.Humanoid.Health <= 0) then
                    currentTarget = findNearestTarget()
                end
                
                -- Если нашли цель
                if currentTarget and currentTarget.Character then
                    local character = LocalPlayer.Character
                    if not character then return end
                    
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                    
                    if not rootPart or not targetRoot then return end
                    
                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                    
                    if distance <= KillauraModule.Range then
                        -- Плавное следование за целью
                        if KillauraModule.SmoothFollow or KillauraModule.RageMode then
                            smoothFollowTarget(currentTarget)
                        else
                            -- Прямая телепортация на короткое расстояние
                            if distance > 5 then
                                rootPart.CFrame = CFrame.new(
                                    targetRoot.Position.X,
                                    rootPart.Position.Y,
                                    targetRoot.Position.Z
                                ) + (targetRoot.CFrame.LookVector * -3)
                            end
                        end
                        
                        -- Атака цели
                        attackTarget(currentTarget)
                    else
                        -- Цель слишком далеко, ищем новую
                        currentTarget = findNearestTarget()
                    end
                end
            end)
        end)
    else
        -- Выключаем Improved Mode
        if KillauraModule.ImprovedMode then
            setupImprovedMode(false)
        end
        
        currentTarget = nil
        releaseShift()
    end
end

-- Настройка диапазона
function KillauraModule.SetRange(range)
    if range < 5 then range = 5 end
    if range > 100 then range = 100 end
    KillauraModule.Range = range
    return range
end

-- Настройка скорости следования
function KillauraModule.SetFollowSpeed(speed)
    if speed < 0.01 then speed = 0.01 end
    if speed > 1 then speed = 1 end
    KillauraModule.FollowSpeed = speed
    return speed
end

-- Переключение режимов
function KillauraModule.ToggleImprovedMode(enabled)
    KillauraModule.ImprovedMode = enabled
    setupImprovedMode(enabled)
end

function KillauraModule.ToggleRageMode(enabled)
    KillauraModule.RageMode = enabled
end

function KillauraModule.ToggleSmartMode(enabled)
    KillauraModule.SmartMode = enabled
end

function KillauraModule.ToggleAutoAttack(enabled)
    KillauraModule.AutoAttack = enabled
end

-- Очистка
function KillauraModule.Cleanup()
    if killauraConnection then
        killauraConnection:Disconnect()
        killauraConnection = nil
    end
    
    setupImprovedMode(false)
    releaseShift()
    
    currentTarget = nil
    KillauraModule.Enabled = false
    KillauraModule.ImprovedMode = false
    KillauraModule.RageMode = false
    KillauraModule.SmartMode = false
    KillauraModule.AutoAttack = false
end

print("[Killaura.lua] Killaura модуль загружен!")
print("[Killaura.lua] Доступные настройки:")
print("[Killaura.lua] 1. Range: " .. KillauraModule.Range .. " (можно менять)")
print("[Killaura.lua] 2. Smooth Follow: " .. tostring(KillauraModule.SmoothFollow))
print("[Killaura.lua] 3. Follow Speed: " .. KillauraModule.FollowSpeed)
print("[Killaura.lua] 4. Improved Mode: увеличение хитбоксов")
print("[Killaura.lua] 5. Rage Mode: агрессивная киллаура")
print("[Killaura.lua] 6. Smart Mode: умный выбор целей")
print("[Killaura.lua] 7. Auto Attack: автоматическая атака")

return KillauraModule
