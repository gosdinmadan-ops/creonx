local MainModule = {}

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

local LocalPlayer = Players.LocalPlayer

MainModule.SpeedHack = {
    Enabled = false,
    DefaultSpeed = 16,
    CurrentSpeed = 16,
    MaxSpeed = 150,
    MinSpeed = 16
}

MainModule.Noclip = {
    Enabled = false,
    Connection = nil,
    OriginalTransparency = {},
    OriginalCanCollide = {},
    AffectedParts = {},
    CheckDistance = 20,
    CheckInterval = 0.1,
    ContactTime = {},
    MinContactTime = 0.5,
    
    -- УНИВЕРСАЛЬНЫЙ ОБХОД ВСЕГО
    UniversalBypass = {
        Active = true,
        Method = "HybridStealth", -- Гибридный режим
        Layers = {
            "ServerValidation",
            "PhysicsIntegrity",
            "NetworkConsistency",
            "AntiCheatDetection",
            "CharacterModification"
        }
    },
    
    -- ПЕРЕМЕННЫЕ ДЛЯ БИНДА
    BindActive = false,
    CurrentKey = Enum.KeyCode.V, -- Клавиша по умолчанию
    Debounce = false
}

MainModule.AutoDodge = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://88451099342711",
        "rbxassetid://79649041083405", 
        "rbxassetid://73242877658272",
        "rbxassetid://114928327045353",
        "rbxassetid://135690448001690", 
        "rbxassetid://103355259844069",
        "rbxassetid://125906547773381"
    },
    Connections = {},
    LastDodgeTime = 0,
    DodgeCooldown = 0.4,
    Range = 4.8,
    RangeSquared = 4.8 * 4.8,
    AnimationIdsSet = {},
    PlayersInRange = {},
    LastRangeUpdate = 0,
    RangeUpdateInterval = 0.5
}

-- Ultra Stealth Fly Module - Минималистичный и максимально скрытный
MainModule.Fly = {
    Enabled = false,
    Speed = 39,
    Connection = nil,
    BodyVelocity = nil,
    LastUpdate = 0,
    OriginalWalkSpeed = 16,
    BindKey = Enum.KeyCode.Insert,
    BindConnection = nil,
    AntiCheatEnabled = true,
    VelocityRandomization = false, -- Выключено для стабильности
    GroundCheckInterval = 0,
    HumanoidDiedConnection = nil,
    CharacterAddedConnection = nil,
    VelocityHistory = {},
    LastVelocityChange = 0,
    IsFlying = false,
    NoGyro = true, -- Без гироскопа для свободы вращения
    SmoothingFactor = 0.85, -- Фактор сглаживания
    MaxVelocityChange = 15, -- Максимальное изменение скорости за кадр
    AntiStuckEnabled = true,
    LastPosition = Vector3.zero
}

-- Таблица байпасов
local BypassMethods = {
    NetworkOwnership = function(rootPart)
        -- Безопасное получение сетевого владения
        if rootPart and rootPart:IsA("BasePart") then
            pcall(function()
                rootPart:SetNetworkOwner(nil)
                task.wait(0.05)
                rootPart:SetNetworkOwner(LocalPlayer)
            end)
        end
    end,
    
    VelocityNormalization = function(velocity)
        -- Нормализация скорости для обхода детектов
        if not velocity then return Vector3.new(0, 0, 0) end
        
        -- Добавление случайного шума
        local randomFactor = Random.new(tick()):NextNumber(0.98, 1.02)
        return velocity * randomFactor
    end,
    
    CharacterIntegrity = function(character)
        -- Проверка целостности персонажа
        if not character then return false end
        
        -- Проверка на наличие подозрительных изменений
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Удаление возможных маркеров античита
            for _, obj in pairs(rootPart:GetChildren()) do
                if obj.Name:find("AntiCheat") or obj.Name:find("Detector") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        return true
    end,
    
    PhysicsIntegrity = function(rootPart)
        -- Байпас проверок физики
        if not rootPart then return end
        
        -- Симуляция естественной физики
        local velocity = rootPart.AssemblyLinearVelocity
        if velocity.Magnitude > 100 then
            -- Нормализация высокой скорости
            rootPart.AssemblyLinearVelocity = velocity.Unit * math.min(velocity.Magnitude, 85)
        end
    end,
    
    AntiStuck = function(rootPart, lastPosition)
        -- Защита от застревания
        if not rootPart or not lastPosition then return false end
        
        local distance = (rootPart.Position - lastPosition).Magnitude
        if distance < 0.1 then
            -- Персонаж застрял, применяем корректировку
            rootPart.AssemblyLinearVelocity = Vector3.new(
                Random.new():NextNumber(-5, 5),
                2,
                Random.new():NextNumber(-5, 5)
            )
            return true
        end
        return false
    end,
    
    PatternEvasion = function()
        -- Обход паттернов античитов
        local patterns = MainModule.Fly.AntiCheatPatterns
        
        -- Случайная задержка для нарушения паттернов
        local delay = Random.new():NextNumber(0.01, 0.05)
        task.wait(delay)
        
        -- Изменение порядка операций
        if Random.new():NextInteger(1, 10) > 5 then
            task.wait(0.02)
        end
    end
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

MainModule.RLGL = {
    GodMode = false,
    OriginalHeight = nil,
    LastDamageTime = 0,
    DamageCheckRate = 0.1,
    LastHealth = 100,
    GodModeHeight = 160,
    NormalHeight = 120,
    DamageTeleportPosition = Vector3.new(-903.4, 1184.9, -556),
    StartPosition = Vector3.new(-55.3, 1023.1, -545.8),
    EndPosition = Vector3.new(-214.4, 1023.1, 146.7),
    Connection = nil,
    PocketSandCheck = nil,
    NoPocketSandTimer = 0,
    NoPocketSandCooldown = 3
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

MainModule.GlassBridge = {
    AntiBreakEnabled = false,
    AntiBreakConnection = nil,
    AntiFallEnabled = false,
    GlassPlatforms = {},
    GlassAntiFallPlatform = nil,
    GlassESPEnabled = false,
    GlassESPConnection = nil,
    EndPosition = Vector3.new(-196.372467, 522.192139, -1534.20984),
    BridgeHeight = 520.4,
    PlatformSize = Vector3.new(10000, 1, 10000),
    OriginalColors = {},
    OriginalMaterials = {},
    OriginalTransparency = {}
}

MainModule.TugOfWar = {
    AutoPull = false,
    Connection = nil
}

MainModule.JumpRope = {
    TeleportToEnd = false,
    AntiFallPlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

MainModule.SkySquid = {
    AntiFallPlatform = nil,
    SafePlatform = nil,
    Connection = nil,
    PlatformSize = Vector3.new(10000, 1, 10000)
}

MainModule.SpikesKillFeature = {
    Enabled = false,
    AnimationId = "rbxassetid://105341857343164",
    SpikesPosition = nil,
    PlatformHeightOffset = 5,
    ReturnDelay = 0.6,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    SafetyCheckConnection = nil,
    OriginalSpikes = {},
    SpikesRemoved = false,
    KnifeCheckConnection = nil,
    LastKnifeCheckTime = 0,
    KnifeCheckCooldown = 0.5,
    HasKnife = false,
    NoKnifeTimer = 0,
    NoKnifeTimeout = 2
}

MainModule.VoidKillFeature = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://105341857343164",
        "rbxassetid://71619354165195"
    },
    ZonePosition = Vector3.new(-95.1, 964.6, 67.6),
    PlatformYOffset = -4,
    PlatformSize = Vector3.new(10, 1, 10),
    ReturnDelay = 1,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    AntiFallEnabled = false,
    AntiFallPlatform = nil,
    AnimationIdsSet = {}
}

MainModule.ZoneKillFeature = {
    Enabled = false,
    AnimationIds = {
        "rbxassetid://105341857343164"
    },
    ZonePosition = Vector3.new(127.2, 54.6, 4.3),
    PlatformYOffset = -4,
    PlatformSize = Vector3.new(10, 1, 10),
    ReturnDelay = 1,
    SavedCFrame = nil,
    ActiveAnimation = false,
    AnimationStartTime = 0,
    AnimationConnection = nil,
    CharacterAddedConnection = nil,
    AnimationStoppedConnections = {},
    AnimationCheckConnection = nil,
    TrackedAnimations = {},
    AntiFallPlatform = nil,
    AnimationIdsSet = {}
}

MainModule.AntiTimeStop = {
    Enabled = false,
    Connection = nil,
    OriginalProperties = {}
}

MainModule.Hitbox = {
    Size = 150,
    Enabled = false,
    Connection = nil,
    ModifiedParts = {}
}

MainModule.FreeDash = {
    Enabled = false,
    OriginalSprintValue = 4,
    RemoteDestroyed = false
}

MainModule.FreeDashGuards = {
    Enabled = false,
    OriginalSprintValue = 4
}

MainModule.Killaura = {
    Enabled = false,
    Radius = 15,
    MaxRadius = 100,
    CurrentTarget = nil,
    TargetAnimationIds = {
        "85623602463927",
        "87978085217719", 
        "99157505926076"
    },
    Connections = {},
    IsAttached = false,
    OriginalGravity = 196.2,
    AnimationStartTime = 0,
    IsLifted = false,
    LiftHeight = 6,
    TargetAnimationsSet = {},
    LastPositionUpdate = 0,
    PositionUpdateInterval = 0.033,
    AttachYOffset = 1.8,
    SearchCooldown = 0,
    LastTargetSwitch = 0,
    LastValidTargetPos = nil,
    ReturnAfterAnimation = false,
    IsActive = false,
    HiddenForces = {},
    UseNetworkMethods = true,
    SmoothReturn = true,
    MaxForceMultiplier = 100000,
    NetworkOwnershipEnabled = true,
    UseCFrameManipulation = true,
    LastValidCFrame = nil,
    FakeVelocity = Vector3.new(0, 0, 0),
    OriginalProperties = {},
    NetworkSyncRate = 0.1,
    LastNetworkSync = 0,
    UseAssemblyLinearVelocity = true,
    ForceMultipliers = {
        Position = 100000,
        Gyro = 100000,
        Velocity = 50000,
        AntiGravity = 1.2
    },
    OriginalHumanoidState = nil,
    OriginalPlatformStand = nil,
    IsSearching = false,
    SearchAttempts = 0,
    MaxSearchAttempts = 5,
    SearchRadius = 50,
    ReturnToNormalTimer = 0,
    LastTargetDistance = 0,
    SmoothLookFactor = 0.8,
    MovementSimulation = {
        Enabled = true,
        WalkCycle = 0,
        LegMovement = 0,
        ArmMovement = 0
    },
    CombatItems = {"Fork", "Bottle", "Knife"},
    PlayerHasCombatItem = false,
    LastCombatCheck = 0,
    CombatCheckInterval = 0.1,
    OriginalCFrame = nil,
    OriginalVelocity = nil,
    OriginalAnchored = nil,
    OriginalCanCollide = nil,
    OriginalMassless = nil,
    SavedProperties = {}
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

MainModule.HNS = {
    InfinityStaminaEnabled = false,
    InfinityStaminaConnection = nil
}

MainModule.ESP = {
    Players = {},
    Objects = {},
    Connections = {},
    Folder = nil,
    MainConnection = nil,
    UpdateRate = 0.1
}

for _, id in ipairs(MainModule.Killaura.TargetAnimationIds) do
    MainModule.Killaura.TargetAnimationsSet["rbxassetid://" .. id] = true
end

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
    local currentPosition = rootPart.Position
    local currentCFrame = rootPart.CFrame
    local tempPart = Instance.new("Part")
    tempPart.Size = Vector3.new(1, 1, 1)
    tempPart.Transparency = 1
    tempPart.Anchored = true
    tempPart.CanCollide = false
    tempPart.Position = currentPosition
    tempPart.Parent = workspace
    Debris:AddItem(tempPart, 0.1)
    local fakeVelocity = Instance.new("BodyVelocity")
    fakeVelocity.Velocity = (position - currentPosition).Unit * 100
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

function MainModule.ToggleFreeDash(enabled)
    MainModule.FreeDash.Enabled = enabled
    
    if enabled then
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDash.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 5
            end
        end
        
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            remote = remote:FindFirstChild("DashRequest")
            if remote then
                remote:Destroy()
                MainModule.FreeDash.RemoteDestroyed = true
            end
        end
    else
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDash.OriginalSprintValue
            end
        end
    end
end

function MainModule.ToggleFreeDashGuards(enabled)
    MainModule.FreeDashGuards.Enabled = enabled
    
    if enabled then
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDashGuards.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 5
            end
        end
    else
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDashGuards.OriginalSprintValue
            end
        end
    end
end

function MainModule.ToggleAntiTimeStop(enabled)
    MainModule.AntiTimeStop.Enabled = enabled
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    if enabled then
        MainModule.AntiTimeStop.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.AntiTimeStop.Enabled then return end
            pcall(function()
                local character = GetCharacter()
                if not character then return end
                local humanoid = GetHumanoid(character)
                if not humanoid then return end
                if not MainModule.AntiTimeStop.OriginalProperties[humanoid] then
                    MainModule.AntiTimeStop.OriginalProperties[humanoid] = {
                        WalkSpeed = humanoid.WalkSpeed,
                        JumpPower = humanoid.JumpPower
                    }
                end
                local isFrozen = false
                local frozenEffects = {
                    "TimeStop", "TimeStopEffect", "TimeStopDebuff", "Frozen", "Freeze", 
                    "Stopped", "TimeLock", "TimeFreeze", "ZaWarudo"
                }
                for _, effectName in ipairs(frozenEffects) do
                    local effect = character:FindFirstChild(effectName)
                    if effect then
                        isFrozen = true
                        break
                    end
                end
                if humanoid:GetAttribute("TimeStopped") or 
                   humanoid:GetAttribute("Frozen") or 
                   humanoid:GetAttribute("Stopped") then
                    isFrozen = true
                end
                if isFrozen then
                    humanoid.WalkSpeed = MainModule.AntiTimeStop.OriginalProperties[humanoid].WalkSpeed
                    humanoid.JumpPower = MainModule.AntiTimeStop.OriginalProperties[humanoid].JumpPower
                    for _, effectName in ipairs(frozenEffects) do
                        local effect = character:FindFirstChild(effectName)
                        if effect then
                            effect:Destroy()
                        end
                    end
                    humanoid:SetAttribute("TimeStopped", false)
                    humanoid:SetAttribute("Frozen", false)
                    humanoid:SetAttribute("Stopped", false)
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    humanoid.PlatformStand = false
                end
            end)
        end)
        local character = GetCharacter()
        if character then
            character.ChildAdded:Connect(function(child)
                if not MainModule.AntiTimeStop.Enabled then return end
                if child.Name:find("TimeStop") or child.Name:find("Freeze") then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                end
            end)
        end
    else
        for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
            if humanoid and humanoid.Parent then
                humanoid.WalkSpeed = properties.WalkSpeed
                humanoid.JumpPower = properties.JumpPower
            end
        end
        MainModule.AntiTimeStop.OriginalProperties = {}
    end
end

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

function MainModule.HasPocketSand()
    local character = GetCharacter()
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Pocket Sand" then
                return true
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Pocket Sand" then
                return true
            end
        end
    end
    
    return false
end

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.PocketSandCheck then
        MainModule.RLGL.PocketSandCheck:Disconnect()
        MainModule.RLGL.PocketSandCheck = nil
    end
    
    if enabled then
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                MainModule.RLGL.OriginalHeight = rootPart.Position.Y
                local targetHeight = rootPart.Position.Y + MainModule.RLGL.GodModeHeight
                local targetPos = Vector3.new(rootPart.Position.X, targetHeight, rootPart.Position.Z)
                SafeTeleport(targetPos)
            end
        end
        
        MainModule.RLGL.Connection = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            if not MainModule.HasPocketSand() then
                MainModule.RLGL.NoPocketSandTimer = MainModule.RLGL.NoPocketSandTimer + task.wait()
                if MainModule.RLGL.NoPocketSandTimer >= MainModule.RLGL.NoPocketSandCooldown then
                    MainModule.ToggleGodMode(false)
                    return
                end
            else
                MainModule.RLGL.NoPocketSandTimer = 0
            end
            
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
                end
            end)
        end)
        
        MainModule.RLGL.PocketSandCheck = RunService.Heartbeat:Connect(function()
            if not MainModule.RLGL.GodMode then return end
            
            if not MainModule.HasPocketSand() then
                MainModule.RLGL.NoPocketSandTimer = MainModule.RLGL.NoPocketSandTimer + task.wait()
                if MainModule.RLGL.NoPocketSandTimer >= MainModule.RLGL.NoPocketSandCooldown then
                    MainModule.ToggleGodMode(false)
                end
            else
                MainModule.RLGL.NoPocketSandTimer = 0
            end
        end)
    else
        if MainModule.RLGL.OriginalHeight then
            local character = GetCharacter()
            if character then
                local rootPart = GetRootPart(character)
                if rootPart then
                    local targetPos = Vector3.new(rootPart.Position.X, MainModule.RLGL.OriginalHeight, rootPart.Position.Z)
                    SafeTeleport(targetPos)
                end
            end
        end
        
        MainModule.RLGL.LastHealth = 100
        MainModule.RLGL.OriginalHeight = nil
        MainModule.RLGL.NoPocketSandTimer = 0
    end
end

function MainModule.TeleportToEnd()
    SafeTeleport(MainModule.RLGL.EndPosition)
end

function MainModule.TeleportToStart()
    SafeTeleport(MainModule.RLGL.StartPosition)
end

function MainModule.ToggleBypassRagdoll(enabled)
    if MainModule.Fly.Enabled then
        MainModule.Fly.WasRagdollEnabled = enabled
        return
    end
    
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
                local harmfulFolders = {"RotateDisabled", "RagdollWakeupImmunity"}
                for _, folderName in pairs(harmfulFolders) do
                    local folder = Character:FindFirstChild(folderName)
                    if folder then
                        folder:Destroy()
                    end
                end
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
                            end
                        end
                    end
                end
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
            end)
        end)
        local char = GetCharacter()
        if char then
            char.ChildAdded:Connect(function(child)
                if child.Name == "Ragdoll" and MainModule.Misc.BypassRagdollEnabled then
                    task.wait(0.1)
                    pcall(function() child:Destroy() end)
                    local humanoid = GetHumanoid(char)
                    if humanoid then
                        humanoid.PlatformStand = false
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        end
        task.wait(0.5)
        MainModule.StartEnhancedProtection()
        MainModule.StartJointCleaning()
    else
        local character = GetCharacter()
        if character then
            local rootPart = GetRootPart(character)
            if rootPart then
                for _, conn in pairs(getconnections(rootPart.ChildAdded)) do
                    conn:Disconnect()
                end
            end
        end
        MainModule.StopEnhancedProtection()
        MainModule.StopJointCleaning()
    end
end

local harmfulEffectsList = {
    "RagdollStun", "Stun", "Stunned", "StunEffect", "StunHit",
    "Knockback", "Knockdown", "Knockout", "KB_Effect",
    "Dazed", "Paralyzed", "Paralyze", "Freeze", "Frozen", 
    "Sleep", "Sleeping", "SleepEffect", "Confusion", "Confused",
    "Slow", "Slowed", "Root", "Rooted", "Immobilized",
    "Bleed", "Bleeding", "Poison", "Poisoned", "Burn", "Burning",
    "Shock", "Shocked", "Electrocuted", "Silence", "Silenced",
    "Disarm", "Disarmed", "Blind", "Blinded", "Fear", "Feared",
    "Taunt", "Taunted", "Charm", "Charmed", "Petrify", "Petrified"
}

local enhancedProtectionConnection = nil
local jointCleaningConnection = nil
local ragdollBlockConnection = nil

local function CleanNegativeEffects(character)
    if not character or not MainModule.Misc.BypassRagdollEnabled then return end
    pcall(function()
        for _, effectName in ipairs(harmfulEffectsList) do
            local effect = character:FindFirstChild(effectName)
            if effect then
                if effect:IsA("BasePart") then
                    task.spawn(function()
                        for i = 1, 5 do
                            if effect and effect.Parent then
                                effect.Transparency = effect.Transparency + 0.2
                                task.wait(0.02)
                            end
                        end
                        pcall(function() effect:Destroy() end)
                    end)
                else
                    pcall(function() effect:Destroy() end)
                end
            end
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local badAttributes = {"Stunned", "Paralyzed", "Frozen", "Asleep", "Confused", 
                                   "Slowed", "Rooted", "Silenced", "Disarmed", "Blinded", "Feared"}
            for _, attr in ipairs(badAttributes) do
                if humanoid:GetAttribute(attr) then
                    humanoid:SetAttribute(attr, false)
                end
            end
        end
    end)
end

local function CleanJointsAndConstraints(character)
    if not character then return end
    pcall(function()
        local Humanoid = character:FindFirstChild("Humanoid")
        local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local Torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        if not (Humanoid and HumanoidRootPart and Torso) then return end
        for _, child in ipairs(character:GetChildren()) do
            if child.Name == "Ragdoll" then
                pcall(function() child:Destroy() end)
            end
        end
        for _, folderName in pairs({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking"}) do
            local folder = character:FindFirstChild(folderName)
            if folder then
                folder:Destroy()
            end
        end
        for _, obj in pairs(HumanoidRootPart:GetChildren()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:match("^CacheAttachment") then
                obj:Destroy()
            end
        end
        local joints = {"Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder"}
        for _, jointName in pairs(joints) do
            local motor = Torso:FindFirstChild(jointName)
            if motor and motor:IsA("Motor6D") and not motor.Part0 then
                motor.Part0 = Torso
            end
        end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
                part.BoneCustom:Destroy()
            end
        end
    end)
end

local function SetupRagdollListener(character)
    if not character then return end
    if ragdollBlockConnection then
        ragdollBlockConnection:Disconnect()
        ragdollBlockConnection = nil
    end
    local Humanoid = character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    ragdollBlockConnection = character.ChildAdded:Connect(function(child)
        if child.Name == "Ragdoll" then
            pcall(function() child:Destroy() end)
            pcall(function()
                Humanoid.PlatformStand = false
                Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end)
        end
    end)
end

function MainModule.StartEnhancedProtection()
    if enhancedProtectionConnection then
        enhancedProtectionConnection:Disconnect()
    end
    enhancedProtectionConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        local character = GetCharacter()
        if character then
            CleanNegativeEffects(character)
        end
    end)
end

function MainModule.StopEnhancedProtection()
    if enhancedProtectionConnection then
        enhancedProtectionConnection:Disconnect()
        enhancedProtectionConnection = nil
    end
end

function MainModule.StartJointCleaning()
    if jointCleaningConnection then
        jointCleaningConnection:Disconnect()
    end
    local character = GetCharacter()
    if character then
        CleanJointsAndConstraints(character)
        SetupRagdollListener(character)
    end
    jointCleaningConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.Misc.BypassRagdollEnabled then return end
        local character = GetCharacter()
        if character then
            CleanJointsAndConstraints(character)
        end
    end)
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        SetupRagdollListener(newChar)
        CleanJointsAndConstraints(newChar)
    end)
end

function MainModule.StopJointCleaning()
    if jointCleaningConnection then
        jointCleaningConnection:Disconnect()
        jointCleaningConnection = nil
    end
    if ragdollBlockConnection then
        ragdollBlockConnection:Disconnect()
        ragdollBlockConnection = nil
    end
end

function MainModule.FullCleanup()
    local character = GetCharacter()
    if character then
        CleanNegativeEffects(character)
        CleanJointsAndConstraints(character)
        return true
    end
    return false
end

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

function MainModule.CheckKnifeInInventory()
    local character = GetCharacter()
    if not character then return false end
    
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name:lower()
            if toolName:find("knife") or toolName:find("fork") or toolName:find("dagger") or toolName:find("нож") then
                return true, tool
            end
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
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

function MainModule.ToggleSpikesKill(enabled)
    if enabled then
        local hasKnife = MainModule.CheckKnifeInInventory()
        if not hasKnife then
            print("[CreonX] Spikes Kill: No knife in inventory")
            MainModule.SpikesKillFeature.Enabled = false
            return
        end
        MainModule.SpikesKillFeature.HasKnife = true
    end
    
    MainModule.SpikesKillFeature.Enabled = enabled
    
    if MainModule.SpikesKillFeature.AnimationConnection then
        MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationConnection = nil
    end
    if MainModule.SpikesKillFeature.CharacterAddedConnection then
        MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.SpikesKillFeature.SafetyCheckConnection then
        MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.SafetyCheckConnection = nil
    end
    if MainModule.SpikesKillFeature.AnimationCheckConnection then
        MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationCheckConnection = nil
    end
    if MainModule.SpikesKillFeature.KnifeCheckConnection then
        MainModule.SpikesKillFeature.KnifeCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.KnifeCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKillFeature.AnimationStoppedConnections = {}
    
    MainModule.SpikesKillFeature.SavedCFrame = nil
    MainModule.SpikesKillFeature.ActiveAnimation = false
    MainModule.SpikesKillFeature.AnimationStartTime = 0
    MainModule.SpikesKillFeature.TrackedAnimations = {}
    MainModule.SpikesKillFeature.NoKnifeTimer = 0
    
    if not enabled then
        MainModule.SpikesKillFeature.HasKnife = false
        return
    end
    
    MainModule.DisableSpikes(true)
    
    local function checkAnimations()
        if not MainModule.SpikesKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKillFeature.AnimationId then
                if not MainModule.SpikesKillFeature.TrackedAnimations[track] then
                    MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                    
                    if not MainModule.SpikesKillFeature.ActiveAnimation then
                        MainModule.SpikesKillFeature.ActiveAnimation = true
                        MainModule.SpikesKillFeature.AnimationStartTime = tick()
                        
                        MainModule.SpikesKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                        
                        local spikesPosition = MainModule.SpikesKillFeature.SpikesPosition
                        if not spikesPosition then
                            local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
                            local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
                            if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                                local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                                if firstSpike then
                                    spikesPosition = firstSpike.Position
                                    MainModule.SpikesKillFeature.SpikesPosition = spikesPosition
                                end
                            end
                        end
                        
                        if spikesPosition then
                            local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        else
                            local currentPos = character:GetPrimaryPartCFrame().Position
                            local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                        end
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                            
                            if MainModule.SpikesKillFeature.ActiveAnimation and MainModule.SpikesKillFeature.SavedCFrame then
                                character:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.SavedCFrame)
                                MainModule.SpikesKillFeature.SavedCFrame = nil
                                MainModule.SpikesKillFeature.ActiveAnimation = false
                                MainModule.SpikesKillFeature.TrackedAnimations = {}
                            end
                        end)
                        table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid")
        
        MainModule.SpikesKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.SpikesKillFeature.Enabled then return end
            
            if track.Animation and track.Animation.AnimationId == MainModule.SpikesKillFeature.AnimationId then
                MainModule.SpikesKillFeature.TrackedAnimations[track] = true
                
                if not MainModule.SpikesKillFeature.ActiveAnimation then
                    MainModule.SpikesKillFeature.ActiveAnimation = true
                    MainModule.SpikesKillFeature.AnimationStartTime = tick()
                    
                    MainModule.SpikesKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                    
                    local spikesPosition = MainModule.SpikesKillFeature.SpikesPosition
                    if not spikesPosition then
                        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
                        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
                        if killingParts and killingParts:FindFirstChildWhichIsA("BasePart") then
                            local firstSpike = killingParts:FindFirstChildWhichIsA("BasePart")
                            if firstSpike then
                                spikesPosition = firstSpike.Position
                                MainModule.SpikesKillFeature.SpikesPosition = spikesPosition
                            end
                        end
                    end
                    
                    if spikesPosition then
                        local targetPosition = spikesPosition + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                        char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    else
                        local currentPos = char:GetPrimaryPartCFrame().Position
                        local targetPosition = currentPos + Vector3.new(0, MainModule.SpikesKillFeature.PlatformHeightOffset, 0)
                        char:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                    end
                    
                    local stoppedConn = track.Stopped:Connect(function()
                        task.wait(MainModule.SpikesKillFeature.ReturnDelay)
                        
                        if MainModule.SpikesKillFeature.SavedCFrame then
                            char:SetPrimaryPartCFrame(MainModule.SpikesKillFeature.SavedCFrame)
                            MainModule.SpikesKillFeature.SavedCFrame = nil
                            MainModule.SpikesKillFeature.ActiveAnimation = false
                            MainModule.SpikesKillFeature.TrackedAnimations = {}
                        end
                    end)
                    table.insert(MainModule.SpikesKillFeature.AnimationStoppedConnections, stoppedConn)
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        setupCharacter(char)
    end
    
    MainModule.SpikesKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        setupCharacter(newChar)
    end)
    
    MainModule.SpikesKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then return end
        checkAnimations()
    end)
    
    MainModule.SpikesKillFeature.SafetyCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.ActiveAnimation then return end
        if tick() - MainModule.SpikesKillFeature.AnimationStartTime >= 10 then
            MainModule.SpikesKillFeature.ActiveAnimation = false
        end
    end)
    
    MainModule.SpikesKillFeature.KnifeCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.SpikesKillFeature.Enabled then return end
        
        local currentTime = tick()
        if currentTime - MainModule.SpikesKillFeature.LastKnifeCheckTime < MainModule.SpikesKillFeature.KnifeCheckCooldown then
            return
        end
        MainModule.SpikesKillFeature.LastKnifeCheckTime = currentTime
        
        local hasKnife = MainModule.CheckKnifeInInventory()
        
        if hasKnife then
            MainModule.SpikesKillFeature.HasKnife = true
            MainModule.SpikesKillFeature.NoKnifeTimer = 0
        else
            MainModule.SpikesKillFeature.NoKnifeTimer = MainModule.SpikesKillFeature.NoKnifeTimer + MainModule.SpikesKillFeature.KnifeCheckCooldown
            
            if MainModule.SpikesKillFeature.NoKnifeTimer >= MainModule.SpikesKillFeature.NoKnifeTimeout then
                print("[CreonX] Spikes Kill: Knife lost, disabling...")
                MainModule.ToggleSpikesKill(false)
            end
        end
    end)
end

function MainModule.DisableSpikes(remove)
    pcall(function()
        local hideAndSeekMap = workspace:FindFirstChild("HideAndSeekMap")
        local killingParts = hideAndSeekMap and hideAndSeekMap:FindFirstChild("KillingParts")
        if not killingParts then
            return false
        end
        if remove then
            MainModule.SpikesKillFeature.OriginalSpikes = {}
            MainModule.SpikesKillFeature.SpikesPosition = nil
            for _, spike in pairs(killingParts:GetChildren()) do
                if spike:IsA("BasePart") then
                    table.insert(MainModule.SpikesKillFeature.OriginalSpikes, spike:Clone())
                    if not MainModule.SpikesKillFeature.SpikesPosition then
                        MainModule.SpikesKillFeature.SpikesPosition = spike.Position
                    end
                    spike:Destroy()
                end
            end
            MainModule.SpikesKillFeature.SpikesRemoved = true
            return true
        else
            return true
        end
    end)
end

for _, id in ipairs(MainModule.VoidKillFeature.AnimationIds) do
    MainModule.VoidKillFeature.AnimationIdsSet[id] = true
end

function MainModule.ToggleVoidKill(enabled)
    MainModule.VoidKillFeature.Enabled = enabled
    
    if MainModule.VoidKillFeature.AnimationConnection then
        MainModule.VoidKillFeature.AnimationConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationConnection = nil
    end
    if MainModule.VoidKillFeature.CharacterAddedConnection then
        MainModule.VoidKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.VoidKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.VoidKillFeature.AnimationCheckConnection then
        MainModule.VoidKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKillFeature.AnimationStoppedConnections = {}
    
    MainModule.VoidKillFeature.SavedCFrame = nil
    MainModule.VoidKillFeature.ActiveAnimation = false
    MainModule.VoidKillFeature.AnimationStartTime = 0
    MainModule.VoidKillFeature.TrackedAnimations = {}
    
    if not enabled then
        if MainModule.VoidKillFeature.AntiFallPlatform then
            MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
            MainModule.VoidKillFeature.AntiFallPlatform = nil
        end
        MainModule.VoidKillFeature.AntiFallEnabled = false
        return
    end
    
    local function checkAnimations()
        if not MainModule.VoidKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.VoidKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    if not MainModule.VoidKillFeature.TrackedAnimations[trackKey] then
                        MainModule.VoidKillFeature.TrackedAnimations[trackKey] = true
                        
                        if not MainModule.VoidKillFeature.ActiveAnimation then
                            MainModule.VoidKillFeature.ActiveAnimation = true
                            MainModule.VoidKillFeature.AnimationStartTime = tick()
                            
                            MainModule.VoidKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                            
                            local platformPosition = MainModule.VoidKillFeature.ZonePosition + 
                                                    Vector3.new(0, MainModule.VoidKillFeature.PlatformYOffset, 0)
                            
                            MainModule.VoidKillFeature.AntiFallPlatform = Instance.new("Part")
                            MainModule.VoidKillFeature.AntiFallPlatform.Name = "VoidKillAntiFall"
                            MainModule.VoidKillFeature.AntiFallPlatform.Size = MainModule.VoidKillFeature.PlatformSize
                            MainModule.VoidKillFeature.AntiFallPlatform.Anchored = true
                            MainModule.VoidKillFeature.AntiFallPlatform.CanCollide = true
                            MainModule.VoidKillFeature.AntiFallPlatform.Transparency = 1
                            MainModule.VoidKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                            MainModule.VoidKillFeature.AntiFallPlatform.CastShadow = false
                            MainModule.VoidKillFeature.AntiFallPlatform.CanQuery = false
                            MainModule.VoidKillFeature.AntiFallPlatform.Position = platformPosition
                            MainModule.VoidKillFeature.AntiFallPlatform.Parent = workspace
                            
                            character:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidKillFeature.ZonePosition))
                            
                            local stoppedConn = track.Stopped:Connect(function()
                                task.wait(MainModule.VoidKillFeature.ReturnDelay)
                                
                                if MainModule.VoidKillFeature.SavedCFrame then
                                    character:SetPrimaryPartCFrame(MainModule.VoidKillFeature.SavedCFrame)
                                    MainModule.VoidKillFeature.SavedCFrame = nil
                                end
                                
                                MainModule.VoidKillFeature.ActiveAnimation = false
                                MainModule.VoidKillFeature.TrackedAnimations = {}
                                
                                if MainModule.VoidKillFeature.AntiFallPlatform then
                                    MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
                                    MainModule.VoidKillFeature.AntiFallPlatform = nil
                                end
                            end)
                            
                            table.insert(MainModule.VoidKillFeature.AnimationStoppedConnections, stoppedConn)
                        end
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        MainModule.VoidKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.VoidKillFeature.Enabled then return end
            
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.VoidKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    MainModule.VoidKillFeature.TrackedAnimations[trackKey] = true
                    
                    if not MainModule.VoidKillFeature.ActiveAnimation then
                        MainModule.VoidKillFeature.ActiveAnimation = true
                        MainModule.VoidKillFeature.AnimationStartTime = tick()
                        
                        MainModule.VoidKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                        
                        local platformPosition = MainModule.VoidKillFeature.ZonePosition + 
                                                Vector3.new(0, MainModule.VoidKillFeature.PlatformYOffset, 0)
                        
                        MainModule.VoidKillFeature.AntiFallPlatform = Instance.new("Part")
                        MainModule.VoidKillFeature.AntiFallPlatform.Name = "VoidKillAntiFall"
                        MainModule.VoidKillFeature.AntiFallPlatform.Size = MainModule.VoidKillFeature.PlatformSize
                        MainModule.VoidKillFeature.AntiFallPlatform.Anchored = true
                        MainModule.VoidKillFeature.AntiFallPlatform.CanCollide = true
                        MainModule.VoidKillFeature.AntiFallPlatform.Transparency = 1
                        MainModule.VoidKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                        MainModule.VoidKillFeature.AntiFallPlatform.CastShadow = false
                        MainModule.VoidKillFeature.AntiFallPlatform.CanQuery = false
                        MainModule.VoidKillFeature.AntiFallPlatform.Position = platformPosition
                        MainModule.VoidKillFeature.AntiFallPlatform.Parent = workspace
                        
                        char:SetPrimaryPartCFrame(CFrame.new(MainModule.VoidKillFeature.ZonePosition))
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.VoidKillFeature.ReturnDelay)
                            
                            if MainModule.VoidKillFeature.SavedCFrame then
                                char:SetPrimaryPartCFrame(MainModule.VoidKillFeature.SavedCFrame)
                                MainModule.VoidKillFeature.SavedCFrame = nil
                            end
                            
                            MainModule.VoidKillFeature.ActiveAnimation = false
                            MainModule.VoidKillFeature.TrackedAnimations = {}
                            
                            if MainModule.VoidKillFeature.AntiFallPlatform then
                                MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
                                MainModule.VoidKillFeature.AntiFallPlatform = nil
                            end
                        end)
                        
                        table.insert(MainModule.VoidKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        task.spawn(setupCharacter, char)
    end
    
    MainModule.VoidKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        if MainModule.VoidKillFeature.Enabled then
            task.spawn(setupCharacter, newChar)
        end
    end)
    
    MainModule.VoidKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.VoidKillFeature.Enabled then return end
        checkAnimations()
    end)
end

MainModule.ZoneKillFeature.AnimationIdsSet["rbxassetid://105341857343164"] = true

function MainModule.ToggleZoneKill(enabled)
    MainModule.ZoneKillFeature.Enabled = enabled
    
    if MainModule.ZoneKillFeature.AnimationConnection then
        MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationConnection = nil
    end
    if MainModule.ZoneKillFeature.CharacterAddedConnection then
        MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKillFeature.CharacterAddedConnection = nil
    end
    if MainModule.ZoneKillFeature.AnimationCheckConnection then
        MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
    MainModule.ZoneKillFeature.SavedCFrame = nil
    MainModule.ZoneKillFeature.ActiveAnimation = false
    MainModule.ZoneKillFeature.AnimationStartTime = 0
    MainModule.ZoneKillFeature.TrackedAnimations = {}
    
    if not enabled then
        if MainModule.ZoneKillFeature.AntiFallPlatform then
            MainModule.ZoneKillFeature.AntiFallPlatform:Destroy()
            MainModule.ZoneKillFeature.AntiFallPlatform = nil
        end
        return
    end
    
    local function checkAnimations()
        if not MainModule.ZoneKillFeature.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        local humanoid = GetHumanoid(character)
        if not humanoid then return end
        
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        for _, track in pairs(activeTracks) do
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.ZoneKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    if not MainModule.ZoneKillFeature.TrackedAnimations[trackKey] then
                        MainModule.ZoneKillFeature.TrackedAnimations[trackKey] = true
                        
                        if not MainModule.ZoneKillFeature.ActiveAnimation then
                            MainModule.ZoneKillFeature.ActiveAnimation = true
                            MainModule.ZoneKillFeature.AnimationStartTime = tick()
                            
                            MainModule.ZoneKillFeature.SavedCFrame = character:GetPrimaryPartCFrame()
                            
                            local platformPosition = MainModule.ZoneKillFeature.ZonePosition + 
                                                    Vector3.new(0, MainModule.ZoneKillFeature.PlatformYOffset, 0)
                            
                            MainModule.ZoneKillFeature.AntiFallPlatform = Instance.new("Part")
                            MainModule.ZoneKillFeature.AntiFallPlatform.Name = "ZoneKillAntiFall"
                            MainModule.ZoneKillFeature.AntiFallPlatform.Size = MainModule.ZoneKillFeature.PlatformSize
                            MainModule.ZoneKillFeature.AntiFallPlatform.Anchored = true
                            MainModule.ZoneKillFeature.AntiFallPlatform.CanCollide = true
                            MainModule.ZoneKillFeature.AntiFallPlatform.Transparency = 1
                            MainModule.ZoneKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                            MainModule.ZoneKillFeature.AntiFallPlatform.CastShadow = false
                            MainModule.ZoneKillFeature.AntiFallPlatform.CanQuery = false
                            MainModule.ZoneKillFeature.AntiFallPlatform.Position = platformPosition
                            MainModule.ZoneKillFeature.AntiFallPlatform.Parent = workspace
                            
                            character:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                            
                            local stoppedConn = track.Stopped:Connect(function()
                                task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                                
                                if MainModule.ZoneKillFeature.SavedCFrame then
                                    character:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
                                    MainModule.ZoneKillFeature.SavedCFrame = nil
                                end
                                
                                MainModule.ZoneKillFeature.ActiveAnimation = false
                                MainModule.ZoneKillFeature.TrackedAnimations = {}
                                
                                if MainModule.ZoneKillFeature.AntiFallPlatform then
                                    MainModule.ZoneKillFeature.AntiFallPlatform:Destroy()
                                    MainModule.ZoneKillFeature.AntiFallPlatform = nil
                                end
                            end)
                            
                            table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, stoppedConn)
                        end
                    end
                end
            end
        end
    end
    
    local function setupCharacter(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        
        MainModule.ZoneKillFeature.AnimationConnection = humanoid.AnimationPlayed:Connect(function(track)
            if not MainModule.ZoneKillFeature.Enabled then return end
            
            if track and track.Animation then
                local animId = track.Animation.AnimationId
                
                if MainModule.ZoneKillFeature.AnimationIdsSet[animId] then
                    local trackKey = animId .. "_" .. tostring(track)
                    MainModule.ZoneKillFeature.TrackedAnimations[trackKey] = true
                    
                    if not MainModule.ZoneKillFeature.ActiveAnimation then
                        MainModule.ZoneKillFeature.ActiveAnimation = true
                        MainModule.ZoneKillFeature.AnimationStartTime = tick()
                        
                        MainModule.ZoneKillFeature.SavedCFrame = char:GetPrimaryPartCFrame()
                        
                        local platformPosition = MainModule.ZoneKillFeature.ZonePosition + 
                                                Vector3.new(0, MainModule.ZoneKillFeature.PlatformYOffset, 0)
                        
                        MainModule.ZoneKillFeature.AntiFallPlatform = Instance.new("Part")
                        MainModule.ZoneKillFeature.AntiFallPlatform.Name = "ZoneKillAntiFall"
                        MainModule.ZoneKillFeature.AntiFallPlatform.Size = MainModule.ZoneKillFeature.PlatformSize
                        MainModule.ZoneKillFeature.AntiFallPlatform.Anchored = true
                        MainModule.ZoneKillFeature.AntiFallPlatform.CanCollide = true
                        MainModule.ZoneKillFeature.AntiFallPlatform.Transparency = 1
                        MainModule.ZoneKillFeature.AntiFallPlatform.Material = Enum.Material.Plastic
                        MainModule.ZoneKillFeature.AntiFallPlatform.CastShadow = false
                        MainModule.ZoneKillFeature.AntiFallPlatform.CanQuery = false
                        MainModule.ZoneKillFeature.AntiFallPlatform.Position = platformPosition
                        MainModule.ZoneKillFeature.AntiFallPlatform.Parent = workspace
                        
                        char:SetPrimaryPartCFrame(CFrame.new(MainModule.ZoneKillFeature.ZonePosition))
                        
                        local stoppedConn = track.Stopped:Connect(function()
                            task.wait(MainModule.ZoneKillFeature.ReturnDelay)
                            
                            if MainModule.ZoneKillFeature.SavedCFrame then
                                char:SetPrimaryPartCFrame(MainModule.ZoneKillFeature.SavedCFrame)
                                MainModule.ZoneKillFeature.SavedCFrame = nil
                            end
                            
                            MainModule.ZoneKillFeature.ActiveAnimation = false
                            MainModule.ZoneKillFeature.TrackedAnimations = {}
                            
                            if MainModule.ZoneKillFeature.AntiFallPlatform then
                                MainModule.ZoneKillFeature.AntiFallPlatform:Destroy()
                                MainModule.ZoneKillFeature.AntiFallPlatform = nil
                            end
                        end)
                        
                        table.insert(MainModule.ZoneKillFeature.AnimationStoppedConnections, stoppedConn)
                    end
                end
            end
        end)
    end
    
    local char = LocalPlayer.Character
    if char then
        task.spawn(setupCharacter, char)
    end
    
    MainModule.ZoneKillFeature.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        if MainModule.ZoneKillFeature.Enabled then
            task.spawn(setupCharacter, newChar)
        end
    end)
    
    MainModule.ZoneKillFeature.AnimationCheckConnection = RunService.Heartbeat:Connect(function()
        if not MainModule.ZoneKillFeature.Enabled then return end
        checkAnimations()
    end)
end

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

function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    if enabled then
        infiniteAmmoConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            task.spawn(function()
                local character = GetCharacter()
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                    local nameLower = obj.Name:lower()
                                    if nameLower:find("ammo") or 
                                       nameLower:find("bullet") or
                                       nameLower:find("clip") or
                                       nameLower:find("munition") then
                                        if not MainModule.Guards.OriginalAmmo[obj] then
                                            MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                        end
                                        if obj.Value < 999 then
                                            obj.Value = math.huge
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                                    local nameLower = obj.Name:lower()
                                    if nameLower:find("ammo") or 
                                       nameLower:find("bullet") or
                                       nameLower:find("clip") then
                                        if not MainModule.Guards.OriginalAmmo[obj] then
                                            MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                        end
                                        if obj.Value < 999 then
                                            obj.Value = math.huge
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
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

function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Hitbox.Enabled = enabled
    if MainModule.Hitbox.Connection then
        MainModule.Hitbox.Connection:Disconnect()
        MainModule.Hitbox.Connection = nil
    end
    if not enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and MainModule.Hitbox.ModifiedParts[root] then
                    root.Size = MainModule.Hitbox.ModifiedParts[root]
                    root.CanCollide = true
                    MainModule.Hitbox.ModifiedParts[root] = nil
                end
            end
        end
        MainModule.Hitbox.ModifiedParts = {}
        return
    end
    local function modifyPart(part)
        if not MainModule.Hitbox.ModifiedParts[part] then
            MainModule.Hitbox.ModifiedParts[part] = part.Size
            part.Size = Vector3.new(MainModule.Hitbox.Size, MainModule.Hitbox.Size, MainModule.Hitbox.Size)
            part.CanCollide = false
        end
    end
    local function onPlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            if MainModule.Hitbox.Enabled then
                local root = character:WaitForChild("HumanoidRootPart", 5)
                if root then
                    modifyPart(root)
                end
            end
        end)
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                modifyPart(root)
            end
        end
        if player ~= LocalPlayer then
            onPlayerAdded(player)
        end
    end
    MainModule.Hitbox.Connection = RunService.RenderStepped:Connect(function()
        if not MainModule.Hitbox.Enabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and not MainModule.Hitbox.ModifiedParts[root] then
                    pcall(modifyPart, root)
                end
            end
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                MainModule.Hitbox.ModifiedParts[root] = nil
            end
        end
    end)
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            onPlayerAdded(player)
        end
    end)
end

function MainModule.SetHitboxSize(size)
    MainModule.Hitbox.Size = size
    if MainModule.Hitbox.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and MainModule.Hitbox.ModifiedParts[root] then
                    root.Size = Vector3.new(size, size, size)
                end
            end
        end
    end
end

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
    if not ropeFound then
        local effects = workspace:FindFirstChild("Effects")
        if effects then
            for _, obj in pairs(effects:GetDescendants()) do
                if obj.Name:lower():find("rope") and 
                   (obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart")) then
                    obj:Destroy()
                    ropeFound = true
                    break
                end
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

function MainModule.CreateGlassBridgeAntiFall()
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.GlassBridge.GlassAntiFallPlatform:Destroy()
        MainModule.GlassBridge.GlassAntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "GlassBridgeAntiFall"
    platform.Size = MainModule.GlassBridge.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.GlassBridge.GlassAntiFallPlatform = platform
    MainModule.GlassBridge.AntiFallEnabled = true
    return platform
end

function MainModule.RemoveGlassBridgeAntiFall()
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.GlassBridge.GlassAntiFallPlatform:Destroy()
        MainModule.GlassBridge.GlassAntiFallPlatform = nil
    end
    MainModule.GlassBridge.AntiFallEnabled = false
    return true
end

function MainModule.CreateSkySquidAntiFall()
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "SkySquidAntiFall"
    platform.Size = MainModule.SkySquid.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.SkySquid.AntiFallPlatform = platform
    return platform
end

function MainModule.RemoveSkySquidAntiFall()
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.SkySquid.AntiFallPlatform:Destroy()
        MainModule.SkySquid.AntiFallPlatform = nil
    end
    return true
end

function MainModule.CreateJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    local character = GetCharacter()
    if not character then return nil end
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    local currentPosition = rootPart.Position
    local platform = Instance.new("Part")
    platform.Name = "JumpRopeAntiFall"
    platform.Size = MainModule.JumpRope.PlatformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.Plastic
    platform.CastShadow = false
    platform.CanQuery = false
    platform.Position = Vector3.new(
        currentPosition.X,
        currentPosition.Y - 5,
        currentPosition.Z
    )
    platform.Parent = workspace
    MainModule.JumpRope.AntiFallPlatform = platform
    return platform
end

function MainModule.RemoveJumpRopeAntiFall()
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.JumpRope.AntiFallPlatform:Destroy()
        MainModule.JumpRope.AntiFallPlatform = nil
    end
    return true
end

function MainModule.ToggleGlassBridgeAntiFall(enabled)
    if enabled then
        return MainModule.CreateGlassBridgeAntiFall()
    else
        return MainModule.RemoveGlassBridgeAntiFall()
    end
end

function MainModule.ToggleSkySquidAntiFall(enabled)
    if enabled then
        return MainModule.CreateSkySquidAntiFall()
    else
        return MainModule.RemoveSkySquidAntiFall()
    end
end

function MainModule.ToggleJumpRopeAntiFall(enabled)
    if enabled then
        return MainModule.CreateJumpRopeAntiFall()
    else
        return MainModule.RemoveJumpRopeAntiFall()
    end
end

function MainModule.ToggleGlassBridgeAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreakEnabled = enabled
    
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if not enabled then
        for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
            if platform and platform.Parent then
                platform:Destroy()
            end
        end
        MainModule.GlassBridge.GlassPlatforms = {}
        
        if MainModule.GlassBridge.GlassESPEnabled then
            MainModule.ToggleGlassBridgeESP(true)
        end
        return
    end
    
    local function restoreOriginalProperties()
        for part, properties in pairs(MainModule.GlassBridge.OriginalColors) do
            if part and part.Parent then
                pcall(function()
                    part.Color = properties.Color
                    part.Material = properties.Material
                    part.Transparency = properties.Transparency
                end)
            end
        end
        MainModule.GlassBridge.OriginalColors = {}
        MainModule.GlassBridge.OriginalMaterials = {}
        MainModule.GlassBridge.OriginalTransparency = {}
    end
    
    if MainModule.GlassBridge.GlassESPEnabled then
        restoreOriginalProperties()
        MainModule.GlassBridge.GlassESPEnabled = false
    end
    
    MainModule.GlassBridge.OriginalColors = {}
    MainModule.GlassBridge.OriginalMaterials = {}
    MainModule.GlassBridge.OriginalTransparency = {}
    
    local function applyGlassESP()
        local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        
        for _, tilePair in pairs(GlassHolder:GetChildren()) do
            for _, tileModel in pairs(tilePair:GetChildren()) do
                if tileModel:IsA("Model") and tileModel.PrimaryPart then
                    local primaryPart = tileModel.PrimaryPart
                    
                    for _, child in ipairs(tileModel:GetChildren()) do
                        if child:IsA("Highlight") then
                            child:Destroy()
                        end
                    end
                    
                    local isBreakable = primaryPart:GetAttribute("exploitingisevil")
                    local Color = isBreakable and Color3.fromRGB(248, 87, 87) or Color3.fromRGB(28, 235, 87)
                    
                    if not MainModule.GlassBridge.OriginalColors[primaryPart] then
                        MainModule.GlassBridge.OriginalColors[primaryPart] = {
                            Color = primaryPart.Color,
                            Material = primaryPart.Material,
                            Transparency = primaryPart.Transparency
                        }
                    end
                    
                    primaryPart.Color = Color
                    primaryPart.Transparency = 0
                    primaryPart.Material = Enum.Material.Neon
                    
                    for _, part in pairs(tileModel:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not MainModule.GlassBridge.OriginalColors[part] then
                                MainModule.GlassBridge.OriginalColors[part] = {
                                    Color = part.Color,
                                    Material = part.Material,
                                    Transparency = part.Transparency
                                }
                            end
                            part.Color = Color
                            part.Transparency = 0
                            part.Material = Enum.Material.Neon
                        end
                    end
                end
            end
        end
    end
    
    applyGlassESP()
    
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
                        for _, descendant in pairs(glassModel:GetDescendants()) do
                            if descendant:IsA("BasePart") then
                                descendant.CanCollide = true
                                descendant.Anchored = true
                                descendant.Transparency = 0
                            end
                        end
                    end
                end
            end
        end
    end)
end

function MainModule.ToggleGlassBridgeESP(enabled)
    MainModule.GlassBridge.GlassESPEnabled = enabled
    
    if MainModule.GlassBridge.GlassESPConnection then
        MainModule.GlassBridge.GlassESPConnection:Disconnect()
        MainModule.GlassBridge.GlassESPConnection = nil
    end
    
    if not enabled then
        for part, properties in pairs(MainModule.GlassBridge.OriginalColors) do
            if part and part.Parent then
                pcall(function()
                    part.Color = properties.Color
                    part.Material = properties.Material
                    part.Transparency = properties.Transparency
                end)
            end
        end
        MainModule.GlassBridge.OriginalColors = {}
        MainModule.GlassBridge.OriginalMaterials = {}
        MainModule.GlassBridge.OriginalTransparency = {}
        return
    end
    
    MainModule.GlassBridge.OriginalColors = {}
    MainModule.GlassBridge.OriginalMaterials = {}
    MainModule.GlassBridge.OriginalTransparency = {}
    
    MainModule.GlassBridge.GlassESPConnection = RunService.Heartbeat:Connect(function()
        local GlassHolder = Workspace:FindFirstChild("GlassBridge") and Workspace.GlassBridge:FindFirstChild("GlassHolder")
        if not GlassHolder then return end
        
        for _, tilePair in pairs(GlassHolder:GetChildren()) do
            for _, tileModel in pairs(tilePair:GetChildren()) do
                if tileModel:IsA("Model") and tileModel.PrimaryPart then
                    local primaryPart = tileModel.PrimaryPart
                    
                    for _, child in ipairs(tileModel:GetChildren()) do
                        if child:IsA("Highlight") then
                            child:Destroy()
                        end
                    end
                    
                    local isBreakable = primaryPart:GetAttribute("exploitingisevil")
                    local Color = isBreakable and Color3.fromRGB(248, 87, 87) or Color3.fromRGB(28, 235, 87)
                    
                    if not MainModule.GlassBridge.OriginalColors[primaryPart] then
                        MainModule.GlassBridge.OriginalColors[primaryPart] = {
                            Color = primaryPart.Color,
                            Material = primaryPart.Material,
                            Transparency = primaryPart.Transparency
                        }
                    end
                    
                    primaryPart.Color = Color
                    primaryPart.Transparency = 0
                    primaryPart.Material = Enum.Material.Neon
                    
                    for _, part in pairs(tileModel:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not MainModule.GlassBridge.OriginalColors[part] then
                                MainModule.GlassBridge.OriginalColors[part] = {
                                    Color = part.Color,
                                    Material = part.Material,
                                    Transparency = part.Transparency
                                }
                            end
                            part.Color = Color
                            part.Transparency = 0
                            part.Material = Enum.Material.Neon
                        end
                    end
                end
            end
        end
    end)
    
    local Effects = ReplicatedStorage:FindFirstChild("Modules") and 
                   ReplicatedStorage.Modules:FindFirstChild("Effects")
    if Effects then
        local success, result = pcall(function()
            return require(Effects)
        end)
        if success and result and result.AnnouncementTween then
            result.AnnouncementTween({
                AnnouncementOneLine = true,
                FasterTween = true,
                DisplayTime = 10,
                AnnouncementDisplayText = "[CreonHub]: Glass ESP Activated! Red = Breakable, Green = Safe"
            })
        end
    end
end

function MainModule.TeleportToGlassBridgeEnd()
    SafeTeleport(MainModule.GlassBridge.EndPosition)
end

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

-- ЕДИНЫЙ УНИВЕРСАЛЬНЫЙ ОБХОД
function MainModule.Noclip.UnifiedBypassSystem(character)
    if not MainModule.Noclip.UniversalBypass.Active then return end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return end
    
    local currentTime = tick()
    local bypassMultiplier = 1.0
    
    -- 1. ДИНАМИЧЕСКИЙ АНАЛИЗ СРЕДЫ
    local nearbyPlayers = #game.Players:GetPlayers()
    local serverLoad = game:GetService("Stats"):FindFirstChild("PerformanceStats")
    local physicsSmoothing = 0.95 + (math.sin(currentTime * 2) * 0.05)
    
    -- Автоподстройка под серверные условия
    if nearbyPlayers > 10 then
        bypassMultiplier = 0.7  -- Больше игроков = больше проверок
    end
    
    if serverLoad then
        local ping = serverLoad.Ping:GetValue() or 100
        bypassMultiplier = bypassMultiplier * math.clamp(ping / 150, 0.5, 1.5)
    end
    
    -- 2. ГИБРИДНЫЙ МЕТОД СКРЫТНОСТИ
    local stealthMode = MainModule.Noclip.UniversalBypass.Method
    
    if stealthMode == "HybridStealth" then
        -- Комбинируем несколько методов одновременно
        
        -- A) ПУЛЬСИРУЮЩАЯ КОЛЛИЗИЯ
        local pulsePhase = math.sin(currentTime * 3) * 0.5 + 0.5
        local shouldCollide = pulsePhase > 0.7
        
        -- B) РАСПРЕДЕЛЕННОЕ ОТКЛЮЧЕНИЕ
        local partsToProcess = {}
        for part in pairs(MainModule.Noclip.AffectedParts) do
            if part and part.Parent then
                table.insert(partsToProcess, part)
            end
        end
        
        -- Обрабатываем части постепенно
        for i, part in ipairs(partsToProcess) do
            local phaseOffset = (i / #partsToProcess) * math.pi * 2
            local partPulse = math.sin(currentTime * 2 + phaseOffset) * 0.5 + 0.5
            
            if partPulse > 0.6 then
                -- Временно восстанавливаем коллизию
                task.spawn(function()
                    local restoreTime = 0.05 + math.random() * 0.1 * bypassMultiplier
                    part.CanCollide = true
                    
                    -- Микро-физическое взаимодействие
                    if math.random(1, 100) <= 20 then
                        local fakeForce = Instance.new("BodyVelocity")
                        fakeForce.Velocity = Vector3.new(
                            (math.random() - 0.5) * 2,
                            math.random() * 0.5,
                            (math.random() - 0.5) * 2
                        )
                        fakeForce.MaxForce = Vector3.new(100, 100, 100)
                        fakeForce.Parent = part
                        game:GetService("Debris"):AddItem(fakeForce, 0.1)
                    end
                    
                    task.wait(restoreTime)
                    
                    if MainModule.Noclip.Enabled and MainModule.Noclip.AffectedParts[part] then
                        part.CanCollide = false
                    end
                end)
            end
        end
        
        -- C) ДЕСИНХРОНИЗАЦИЯ ДАННЫХ
        if math.random(1, 100) <= 30 * bypassMultiplier then
            -- Создаем фейковые события для сервера
            local fakeEvents = {
                "Collision",
                "Touch",
                "PhysicsUpdate",
                "PositionUpdate"
            }
            
            local fakeEvent = fakeEvents[math.random(1, #fakeEvents)]
            
            task.spawn(function()
                local remote = Instance.new("RemoteEvent")
                remote.Name = "Fake_" .. fakeEvent .. "_" .. math.random(10000, 99999)
                remote.Parent = rootPart
                
                -- Отправляем фейковые данные
                local fakeData = {
                    Position = rootPart.Position + Vector3.new(
                        (math.random() - 0.5) * 0.5,
                        (math.random() - 0.5) * 0.2,
                        (math.random() - 0.5) * 0.5
                    ),
                    Velocity = rootPart.Velocity * physicsSmoothing,
                    Timestamp = tick()
                }
                
                task.wait(0.05)
                remote:FireServer(fakeData)
                task.wait(0.1)
                remote:Destroy()
            end)
        end
        
        -- D) ЭМУЛЯЦИЯ НОРМАЛЬНОЙ ФИЗИКИ
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Корректируем состояние для обхода проверок
            local state = humanoid:GetState()
            
            if state == Enum.HumanoidStateType.Freefall or 
               state == Enum.HumanoidStateType.Jumping then
                -- В воздухе меньше проверок на коллизию
                bypassMultiplier = bypassMultiplier * 1.3
            end
            
            -- Микро-коррекции движения
            if math.random(1, 100) <= 25 then
                local correction = Vector3.new(
                    (math.random() - 0.5) * 0.01 * bypassMultiplier,
                    (math.random() - 0.5) * 0.005 * bypassMultiplier,
                    (math.random() - 0.5) * 0.01 * bypassMultiplier
                )
                rootPart.Velocity = rootPart.Velocity + correction
            end
        end
    end
    
    -- 3. АВТОМАТИЧЕСКАЯ ОЧИСТКА СЛЕДОВ
    local cleanupThreshold = currentTime - (5 * bypassMultiplier)
    for part, contactTime in pairs(MainModule.Noclip.ContactTime) do
        if contactTime < cleanupThreshold then
            MainModule.Noclip.ContactTime[part] = nil
            if MainModule.Noclip.AffectedParts[part] then
                task.spawn(function()
                    part.CanCollide = true
                    task.wait(0.1)
                    MainModule.Noclip.AffectedParts[part] = nil
                end)
            end
        end
    end
    
    return bypassMultiplier
end

-- ОБНОВЛЕННАЯ ФУНКЦИЯ TOGGLE
function MainModule.ToggleNoclip(enabled)
    MainModule.Noclip.Enabled = enabled
    
    if MainModule.Noclip.Connection then
        MainModule.Noclip.Connection:Disconnect()
        MainModule.Noclip.Connection = nil
    end
    
    -- Мягкое восстановление коллизий
    task.spawn(function()
        local restoreDelay = 0.02
        for part in pairs(MainModule.Noclip.AffectedParts) do
            if part and part.Parent then
                part.CanCollide = true
                task.wait(restoreDelay)
            end
        end
    end)
    
    MainModule.Noclip.AffectedParts = {}
    MainModule.Noclip.ContactTime = {}
    
    if not enabled then 
        MainModule.Noclip.BindActive = false
        return 
    end
    
    MainModule.Noclip.BindActive = true
    MainModule.Noclip.Connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not MainModule.Noclip.Enabled or not MainModule.Noclip.BindActive then return end
        
        local character = GetCharacter()
        if not character then return end
        
        local rootPart = GetRootPart(character)
        if not rootPart then return end
        
        local currentTime = tick()
        local pos = rootPart.Position
        
        -- Вызываем универсальный обход
        local bypassMultiplier = MainModule.Noclip.UnifiedBypassSystem(character)
        
        -- ОСНОВНАЯ ЛОГИКА С УЧЕТОМ ОБХОДА
        local checkDistance = MainModule.Noclip.CheckDistance * bypassMultiplier
        local checkInterval = MainModule.Noclip.CheckInterval / bypassMultiplier
        local minContactTime = MainModule.Noclip.MinContactTime * bypassMultiplier
        
        staticLastCheck = staticLastCheck or 0
        if currentTime - staticLastCheck < checkInterval then return end
        staticLastCheck = currentTime
        
        local region = Region3.new(
            pos - Vector3.new(checkDistance, 3, checkDistance),
            pos + Vector3.new(checkDistance, 5, checkDistance)
        )
        
        local parts = workspace:FindPartsInRegion3(region, character, 100)
        
        for i = 1, #parts do
            local part = parts[i]
            
            if part.CanCollide then
                local isFootContact = false
                
                if character:FindFirstChild("Humanoid") then
                    local humanoid = character.Humanoid
                    if humanoid.FloorMaterial ~= Enum.Material.Air then
                        local rayOrigin = pos
                        local rayDirection = Vector3.new(0, -5, 0)
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterDescendantsInstances = {character}
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        
                        local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                        if result and result.Instance == part then
                            isFootContact = true
                        end
                    end
                end
                
                if not isFootContact then
                    if not MainModule.Noclip.ContactTime[part] then
                        MainModule.Noclip.ContactTime[part] = currentTime
                    end
                    
                    local contactDuration = currentTime - MainModule.Noclip.ContactTime[part]
                    
                    if contactDuration >= minContactTime then
                        if not MainModule.Noclip.AffectedParts[part] then
                            MainModule.Noclip.AffectedParts[part] = true
                            part.CanCollide = false
                            
                            -- Автоматическое восстановление через случайное время
                            task.spawn(function()
                                local restoreDelay = math.random(3, 10) * bypassMultiplier
                                task.wait(restoreDelay)
                                
                                if MainModule.Noclip.AffectedParts[part] and part and part.Parent then
                                    part.CanCollide = true
                                    MainModule.Noclip.AffectedParts[part] = nil
                                    MainModule.Noclip.ContactTime[part] = nil
                                end
                            end)
                        end
                    end
                else
                    MainModule.Noclip.ContactTime[part] = nil
                    if MainModule.Noclip.AffectedParts[part] then
                        part.CanCollide = true
                        MainModule.Noclip.AffectedParts[part] = nil
                    end
                end
            end
        end
        
        -- ОЧИСТКА
        for part in pairs(MainModule.Noclip.AffectedParts) do
            if not part or not part.Parent then
                MainModule.Noclip.AffectedParts[part] = nil
                MainModule.Noclip.ContactTime[part] = nil
            end
        end
        
        for part in pairs(MainModule.Noclip.ContactTime) do
            if not part or not part.Parent or not part.CanCollide then
                MainModule.Noclip.ContactTime[part] = nil
            end
        end
    end)
end

-- СИСТЕМА БИНДОВ
function MainModule.SetupNoclipBind(key)
    if typeof(key) == "EnumItem" and key:IsA("KeyCode") then
        MainModule.Noclip.CurrentKey = key
    end
    
    local UserInputService = game:GetService("UserInputService")
    
    -- Удаляем старый бинд если есть
    if MainModule.Noclip.BindConnection then
        MainModule.Noclip.BindConnection:Disconnect()
    end
    
    -- Создаем новый бинд
    MainModule.Noclip.BindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == MainModule.Noclip.CurrentKey then
            if MainModule.Noclip.Debounce then return end
            
            MainModule.Noclip.Debounce = true
            
            -- Переключаем Noclip
            local newState = not MainModule.Noclip.Enabled
            MainModule.ToggleNoclip(newState)
            
            -- Визуальная обратная связь
            task.spawn(function()
                if newState then
                    print("[NOCLIP] Включен (Клавиша: " .. tostring(MainModule.Noclip.CurrentKey) .. ")")
                    
                    -- Минимальная визуальная индикация
                    local character = GetCharacter()
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            local originalWalk = humanoid.WalkSpeed
                            humanoid.WalkSpeed = originalWalk * 1.1
                            task.wait(0.3)
                            humanoid.WalkSpeed = originalWalk
                        end
                    end
                else
                    print("[NOCLIP] Выключен")
                end
                
                task.wait(0.3)
                MainModule.Noclip.Debounce = false
            end)
        end
    end)
    
    print("[NOCLIP] Бинд установлен на клавишу: " .. tostring(MainModule.Noclip.CurrentKey))
end

-- АВТОМАТИЧЕСКАЯ НАСТРОЙКА ПРИ ЗАГРУЗКЕ
task.spawn(function()
    task.wait(2) -- Ждем загрузки
    
    -- Автовыбор оптимальной клавиши
    local preferredKeys = {
        Enum.KeyCode.V,
        Enum.KeyCode.N,
        Enum.KeyCode.Insert,
        Enum.KeyCode.F2
    }
    
    MainModule.SetupNoclipBind(preferredKeys[1])
end)

for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
    MainModule.AutoDodge.AnimationIdsSet[id] = true
end

local function callDodge()
    -- Ищем RemoteEvent
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if remote then
        remote = remote:FindFirstChild("UsedTool")
    end
    
    if not remote then return false end
    
    -- Получаем игрока
    local player = game:GetService("Players").LocalPlayer
    
    -- Ищем инструмент DODGE! в инвентаре или экипировке
    local tool = player.Character:FindFirstChild("DODGE!") or player.Backpack:FindFirstChild("DODGE!")
    
    if tool then
        -- Прямой вызов DODGE! без экипировки
        remote:FireServer("UsingMoveCustom", tool, nil, {Clicked = true})
        return true
    end
    
    return false
end

local function createAnimationHandler(player)
    return function(track)
        if not MainModule.AutoDodge.Enabled then return end
        if player == LocalPlayer then return end
        
        local animId
        if track and track.Animation then
            animId = track.Animation.AnimationId
        end
        
        if not animId then return end
        
        if not MainModule.AutoDodge.AnimationIdsSet[animId] then
            return
        end
        
        if not LocalPlayer or not LocalPlayer.Character then return end
        if not player or not player.Character then return end
        
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not (localRoot and targetRoot) then return end
        
        local diff = targetRoot.Position - localRoot.Position
        local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
        
        -- Проверяем дистанцию 4.8 радиуса
        if distanceSquared <= MainModule.AutoDodge.RangeSquared then
            local currentTime = tick()
            if currentTime - MainModule.AutoDodge.LastDodgeTime >= MainModule.AutoDodge.DodgeCooldown then
                callDodge()
                MainModule.AutoDodge.LastDodgeTime = currentTime
            end
        end
    end
end

local function setupPlayerTracking(player)
    if player == LocalPlayer then return end
    
    local function setupCharacter(character)
        if not character or not MainModule.AutoDodge.Enabled then return end
        
        for i = 1, 2 do
            if character:FindFirstChild("Humanoid") then break end
            task.wait(0.1)
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local handler = createAnimationHandler(player)
            local conn = humanoid.AnimationPlayed:Connect(handler)
            table.insert(MainModule.AutoDodge.Connections, conn)
        end
    end
    
    if player.Character then
        task.spawn(setupCharacter, player.Character)
    end
    
    local charConn = player.CharacterAdded:Connect(function(character)
        if MainModule.AutoDodge.Enabled then
            task.spawn(setupCharacter, character)
        end
    end)
    table.insert(MainModule.AutoDodge.Connections, charConn)
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.AutoDodge.Enabled = enabled
    
    for _, conn in pairs(MainModule.AutoDodge.Connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    MainModule.AutoDodge.Connections = {}
    
    MainModule.AutoDodge.PlayersInRange = {}
    MainModule.AutoDodge.LastDodgeTime = 0
    MainModule.AutoDodge.LastRangeUpdate = 0
    
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            task.spawn(setupPlayerTracking, player)
        end
        
        local playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if MainModule.AutoDodge.Enabled then
                task.spawn(setupPlayerTracking, player)
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, playerAddedConn)
        
        local heartbeatConn = RunService.Heartbeat:Connect(function()
            if not MainModule.AutoDodge.Enabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.AutoDodge.LastRangeUpdate > MainModule.AutoDodge.RangeUpdateInterval then
                MainModule.AutoDodge.PlayersInRange = {}
                
                local localCharacter = GetCharacter()
                local localRoot = localCharacter and GetRootPart(localCharacter)
                
                if localRoot then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
                            if playerRoot then
                                local diff = playerRoot.Position - localRoot.Position
                                local distanceSquared = diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
                                
                                if distanceSquared <= MainModule.AutoDodge.RangeSquared then
                                    table.insert(MainModule.AutoDodge.PlayersInRange, player.Name)
                                end
                            end
                        end
                    end
                end
                
                MainModule.AutoDodge.LastRangeUpdate = currentTime
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, heartbeatConn)
    end
end

function MainModule.GetHider()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        if not IsHider(plr) then continue end
        if plr.Character ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            return plr.Character
        else
            continue
        end
    end
    return nil
end

function MainModule.TeleportToHider()
    if not LocalPlayer.Character then return end
    
    local hider = MainModule.GetHider()
    if not hider then
        return false
    end
    
    LocalPlayer.Character:PivotTo(hider:GetPrimaryPartCFrame())
    return true
end

-- Создаем рандомайзер для естественных отклонений
local Randomizer = Random.new(tick())

-- Байпас античита: метод минимальных изменений
local function ApplyAntiCheatBypass(rootPart, velocity)
    if not MainModule.Fly.AntiCheatEnabled then
        return velocity
    end
    
    -- Метод 1: Периодическое сброс сетевого владения (очень редко)
    if tick() - MainModule.Fly.LastUpdate > 10 then
        pcall(function()
            rootPart:SetNetworkOwner(nil)
            task.wait(0.01)
            rootPart:SetNetworkOwner(LocalPlayer)
        end)
    end
    
    -- Метод 2: Небольшие естественные отклонения
    if Randomizer:NextInteger(1, 100) > 95 then -- Только 5% времени
        local randomOffset = Vector3.new(
            Randomizer:NextNumber(-0.5, 0.5),
            Randomizer:NextNumber(-0.5, 0.5),
            Randomizer:NextNumber(-0.5, 0.5)
        )
        velocity = velocity + randomOffset
    end
    
    -- Метод 3: Ограничение резких изменений скорости
    local lastVelocity = MainModule.Fly.VelocityHistory[#MainModule.Fly.VelocityHistory]
    if lastVelocity then
        local velocityChange = (velocity - lastVelocity).Magnitude
        if velocityChange > MainModule.Fly.MaxVelocityChange then
            -- Плавное изменение скорости
            local direction = (velocity - lastVelocity).Unit
            velocity = lastVelocity + (direction * MainModule.Fly.MaxVelocityChange)
        end
    end
    
    -- Обновляем историю скоростей
    table.insert(MainModule.Fly.VelocityHistory, velocity)
    if #MainModule.Fly.VelocityHistory > 30 then
        table.remove(MainModule.Fly.VelocityHistory, 1)
    end
    
    return velocity
end

-- Проверка на застревание
local function CheckAndFixStuck(rootPart, currentPos)
    if not MainModule.Fly.AntiStuckEnabled then return false end
    
    local lastPos = MainModule.Fly.LastPosition
    MainModule.Fly.LastPosition = currentPos
    
    if lastPos == Vector3.zero then return false end
    
    local distance = (currentPos - lastPos).Magnitude
    if distance < 0.1 and tick() - MainModule.Fly.LastVelocityChange > 0.5 then
        -- Персонаж застрял, аккуратно выталкиваем
        local randomPush = Vector3.new(
            Randomizer:NextNumber(-3, 3),
            Randomizer:NextNumber(1, 3),
            Randomizer:NextNumber(-3, 3)
        )
        rootPart.Velocity = randomPush
        return true
    end
    
    return false
end

-- Функция бинда клавиши
function MainModule.BindFlyKey(keyCode)
    if MainModule.Fly.BindConnection then
        MainModule.Fly.BindConnection:Disconnect()
        MainModule.Fly.BindConnection = nil
    end
    
    MainModule.Fly.BindKey = keyCode or Enum.KeyCode.Insert
    
    MainModule.Fly.BindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == MainModule.Fly.BindKey then
            MainModule.ToggleFly(not MainModule.Fly.Enabled)
        end
    end)
    
    return MainModule.Fly.BindKey
end

-- Включение флая
function MainModule.EnableFlight()
    if MainModule.Fly.Enabled then return end
    
    print("[Fly] Enabling stealth flight...")
    
    local character = GetCharacter()
    if not character then 
        warn("[Fly] No character found")
        return 
    end
    
    local humanoid = GetHumanoid(character)
    local rootPart = GetRootPart(character)
    
    if not (humanoid and rootPart) then
        warn("[Fly] No humanoid or root part found")
        return
    end
    
    -- Сохраняем оригинальные значения
    MainModule.Fly.OriginalWalkSpeed = humanoid.WalkSpeed
    MainModule.Fly.Enabled = true
    MainModule.Fly.IsFlying = true
    MainModule.Fly.LastPosition = rootPart.Position
    
    -- Отключаем автоматическое вращение
    humanoid.AutoRotate = false
    
    -- Создаем BodyVelocity (минимальный профиль)
    local flightBodyVelocity = Instance.new("BodyVelocity")
    flightBodyVelocity.Name = "BV_Stealth"
    flightBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
    flightBodyVelocity.P = 1250
    flightBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    
    -- Безопасно назначаем родителя
    pcall(function()
        flightBodyVelocity.Parent = rootPart
    end)
    
    MainModule.Fly.BodyVelocity = flightBodyVelocity
    MainModule.Fly.VelocityHistory = {}
    
    -- Основной цикл флая
    MainModule.Fly.Connection = RunService.Heartbeat:Connect(function()
        if not MainModule.Fly.Enabled or not character or not character.Parent then 
            MainModule.DisableFlight()
            return 
        end
        
        -- Обновляем ссылки
        rootPart = GetRootPart(character)
        humanoid = GetHumanoid(character)
        
        if not (rootPart and humanoid) then
            MainModule.DisableFlight()
            return
        end
        
        local Camera = workspace.CurrentCamera
        if not Camera then return end
        
        -- Получаем направление от камеры
        local lookVector = Camera.CFrame.LookVector
        local rightVector = Camera.CFrame.RightVector
        
        -- Вычисляем вектор движения
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- Обработка клавиш движения
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + lookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - lookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - rightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + rightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Нормализуем направление если есть движение
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
            local targetVelocity = moveDirection * MainModule.Fly.Speed
            
            -- Применяем байпас античита
            targetVelocity = ApplyAntiCheatBypass(rootPart, targetVelocity)
            
            -- Плавное изменение скорости
            local currentVelocity = flightBodyVelocity.Velocity
            local smoothedVelocity = currentVelocity:Lerp(targetVelocity, MainModule.Fly.SmoothingFactor)
            
            -- Устанавливаем скорость
            flightBodyVelocity.Velocity = smoothedVelocity
            
            -- Обновляем время последнего изменения скорости
            MainModule.Fly.LastVelocityChange = tick()
            
            -- Маскируем состояние humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            
            -- Проверяем и исправляем застревание
            CheckAndFixStuck(rootPart, rootPart.Position)
            
            -- Сбрасываем AssemblyLinearVelocity (очень осторожно)
            if tick() - MainModule.Fly.LastUpdate > 0.1 then
                pcall(function()
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    MainModule.Fly.LastUpdate = tick()
                end)
            end
        else
            -- Плавная остановка
            flightBodyVelocity.Velocity = flightBodyVelocity.Velocity * 0.7
            
            -- Полная остановка при малой скорости
            if flightBodyVelocity.Velocity.Magnitude < 0.5 then
                flightBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
        
        -- Поддерживаем человечка в нейтральном состоянии
        humanoid.PlatformStand = false
    end)
    
    -- Обработка смерти персонажа
    MainModule.Fly.HumanoidDiedConnection = humanoid.Died:Connect(function()
        MainModule.DisableFlight()
    end)
    
    -- Обработка смены персонажа
    MainModule.Fly.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        task.wait(0.5)
        
        if MainModule.Fly.Enabled then
            MainModule.DisableFlight()
            task.wait(0.1)
            MainModule.EnableFlight()
        end
    end)
    
    print("[Fly] Stealth flight enabled successfully")
end

-- Выключение флая
function MainModule.DisableFlight()
    if not MainModule.Fly.Enabled then return end
    
    print("[Fly] Disabling flight...")
    
    MainModule.Fly.Enabled = false
    MainModule.Fly.IsFlying = false
    
    -- Отключаем соединения
    if MainModule.Fly.Connection then
        MainModule.Fly.Connection:Disconnect()
        MainModule.Fly.Connection = nil
    end
    
    if MainModule.Fly.HumanoidDiedConnection then
        MainModule.Fly.HumanoidDiedConnection:Disconnect()
        MainModule.Fly.HumanoidDiedConnection = nil
    end
    
    if MainModule.Fly.CharacterAddedConnection then
        MainModule.Fly.CharacterAddedConnection:Disconnect()
        MainModule.Fly.CharacterAddedConnection = nil
    end
    
    -- Восстанавливаем персонажа
    local character = GetCharacter()
    if character then
        local humanoid = GetHumanoid(character)
        if humanoid then
            humanoid.AutoRotate = true
            humanoid.WalkSpeed = MainModule.Fly.OriginalWalkSpeed
            humanoid.PlatformStand = false
        end
        
        local rootPart = GetRootPart(character)
        if rootPart then
            -- Удаляем BodyVelocity
            local bv = rootPart:FindFirstChild("BV_Stealth")
            if bv then
                bv:Destroy()
            end
            
            -- Сбрасываем физику
            pcall(function()
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.RotVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end
    
    -- Очищаем историю
    MainModule.Fly.VelocityHistory = {}
    MainModule.Fly.BodyVelocity = nil
    
    print("[Fly] Flight disabled successfully")
end

function MainModule.ToggleFly(enabled)
    if enabled then
        MainModule.EnableFlight()
    else
        MainModule.DisableFlight()
    end
end

function MainModule.SetFlySpeed(speed)
    if type(speed) == "number" and speed > 0 then
        MainModule.Fly.Speed = math.min(speed, 50) -- Ограничение для скрытности
        return MainModule.Fly.Speed
    end
    return 39
end

-- Функции настройки
function MainModule.ConfigureFly(options)
    if options then
        if options.Speed then
            MainModule.SetFlySpeed(options.Speed)
        end
        if options.AntiCheat ~= nil then
            MainModule.Fly.AntiCheatEnabled = options.AntiCheat
        end
        if options.Smoothing then
            MainModule.Fly.SmoothingFactor = math.clamp(options.Smoothing, 0.1, 0.95)
        end
    end
end

-- Инициализация бинда по умолчанию
task.spawn(function()
    task.wait(3)
    MainModule.BindFlyKey(MainModule.Fly.BindKey)
    print("[Fly] Bind key set to:", MainModule.Fly.BindKey.Name)
end)

-- Автоматическая защита
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if MainModule.Fly.Enabled then
        task.wait(0.5)
        MainModule.DisableFlight()
    end
end)

local function saveOriginalState(character)
    if not character then return end
    
    local rootPart = GetRootPart(character)
    if rootPart then
        MainModule.Killaura.OriginalCFrame = rootPart.CFrame
        MainModule.Killaura.OriginalVelocity = rootPart.Velocity
        MainModule.Killaura.OriginalAnchored = rootPart.Anchored
        MainModule.Killaura.OriginalCanCollide = rootPart.CanCollide
        MainModule.Killaura.OriginalMassless = rootPart.Massless
    end
    
    local humanoid = GetHumanoid(character)
    if humanoid then
        MainModule.Killaura.OriginalHumanoidState = humanoid:GetState()
        MainModule.Killaura.OriginalPlatformStand = humanoid.PlatformStand
        
        MainModule.Killaura.SavedProperties = {}
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                MainModule.Killaura.SavedProperties[part] = {
                    Anchored = part.Anchored,
                    CanCollide = part.CanCollide,
                    Massless = part.Massless
                }
            end
        end
    end
    
    print("Состояние сохранено")
end

local function restoreOriginalState(character)
    if not character then return end
    
    local rootPart = GetRootPart(character)
    if rootPart then
        if MainModule.Killaura.OriginalCFrame then
            rootPart.CFrame = MainModule.Killaura.OriginalCFrame
        end
        
        if MainModule.Killaura.OriginalVelocity then
            rootPart.Velocity = MainModule.Killaura.OriginalVelocity
        end
        
        if MainModule.Killaura.OriginalAnchored ~= nil then
            rootPart.Anchored = MainModule.Killaura.OriginalAnchored
        end
        
        if MainModule.Killaura.OriginalCanCollide ~= nil then
            rootPart.CanCollide = MainModule.Killaura.OriginalCanCollide
        end
        
        if MainModule.Killaura.OriginalMassless ~= nil then
            rootPart.Massless = MainModule.Killaura.OriginalMassless
        end
    end
    
    local humanoid = GetHumanoid(character)
    if humanoid then
        if MainModule.Killaura.OriginalPlatformStand ~= nil then
            humanoid.PlatformStand = MainModule.Killaura.OriginalPlatformStand
        end
        
        if MainModule.Killaura.OriginalHumanoidState then
            humanoid:ChangeState(MainModule.Killaura.OriginalHumanoidState)
        end
    end
    
    for part, properties in pairs(MainModule.Killaura.SavedProperties) do
        if part and part.Parent then
            part.Anchored = properties.Anchored
            part.CanCollide = properties.CanCollide
            part.Massless = properties.Massless
        end
    end
    
    for _, obj in pairs(rootPart:GetChildren()) do
        if obj:IsA("BodyMover") or obj:IsA("VectorForce") or obj:IsA("Attachment") then
            obj:Destroy()
        end
    end
    
    local hiddenFolder = workspace:FindFirstChild("NetworkSync")
    if hiddenFolder then
        hiddenFolder:Destroy()
    end
    
    print("Состояние восстановлено")
end

local function checkPlayerInventory()
    local character = GetCharacter()
    if not character then return false end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local hasCombatItem = false
    
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, combatItem in ipairs(MainModule.Killaura.CombatItems) do
                if string.find(tool.Name:lower(), combatItem:lower()) then
                    hasCombatItem = true
                    break
                end
            end
        end
        if hasCombatItem then break end
    end
    
    local humanoid = GetHumanoid(character)
    if humanoid then
        local equippedTool = character:FindFirstChildOfClass("Tool")
        if equippedTool then
            for _, combatItem in ipairs(MainModule.Killaura.CombatItems) do
                if string.find(equippedTool.Name:lower(), combatItem:lower()) then
                    hasCombatItem = true
                    break
                end
            end
        end
    end
    
    return hasCombatItem
end

local function findTargetAnywhere()
    local character = GetCharacter()
    if not character then return nil end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return nil end
    
    local bestTarget = nil
    local bestDistance = MainModule.Killaura.SearchRadius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = GetDistance(rootPart.Position, targetRoot.Position)
                
                if distance <= MainModule.Killaura.SearchRadius and distance < bestDistance then
                    bestDistance = distance
                    bestTarget = player
                end
            end
        end
    end
    
    if not bestTarget and MainModule.Killaura.IsSearching then
        MainModule.Killaura.SearchAttempts = MainModule.Killaura.SearchAttempts + 1
        
        if MainModule.Killaura.SearchAttempts <= MainModule.Killaura.MaxSearchAttempts then
            MainModule.Killaura.SearchRadius = MainModule.Killaura.SearchRadius + 20
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = player.Character:FindFirstChild("Humanoid")
                    
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                        local distance = GetDistance(rootPart.Position, targetRoot.Position)
                        
                        if distance <= MainModule.Killaura.SearchRadius then
                            bestTarget = player
                            break
                        end
                    end
                end
            end
        end
    end
    
    if bestTarget then
        MainModule.Killaura.IsSearching = false
        MainModule.Killaura.SearchAttempts = 0
        MainModule.Killaura.SearchRadius = 50
    end
    
    return bestTarget
end

local function attachInFrontOfTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local character = GetCharacter()
    if not character then return false end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    
    if not (targetRoot and targetHumanoid) or targetHumanoid.Health <= 0 then
        return false
    end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return false end
    
    local humanoid = GetHumanoid(character)
    if not humanoid then return false end
    
    saveOriginalState(character)
    
    humanoid.PlatformStand = true
    rootPart.CanCollide = false
    rootPart.Anchored = false
    
    local targetLookVector = targetRoot.CFrame.LookVector
    
    local targetPosition = targetRoot.Position + (targetLookVector * -2) + Vector3.new(0, 6, 0)
    
    local directionToTarget = (targetRoot.Position - targetPosition).Unit
    local newCFrame = CFrame.new(targetPosition, targetPosition + directionToTarget)
    
    rootPart.CFrame = newCFrame
    
    MainModule.Killaura.IsAttached = true
    MainModule.Killaura.LastPositionUpdate = tick()
    MainModule.Killaura.LastValidTargetPos = targetRoot.Position
    MainModule.Killaura.LastTargetDistance = GetDistance(rootPart.Position, targetRoot.Position)
    
    print("Прикреплен перед целью")
    return true
end

local function updateFrontAttachment(deltaTime)
    if not MainModule.Killaura.CurrentTarget then return end
    
    local character = GetCharacter()
    if not character then return end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return end
    
    local targetPlayer = MainModule.Killaura.CurrentTarget
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local targetLookVector = targetRoot.CFrame.LookVector
    
    local targetVelocity = targetRoot.Velocity
    local isTargetMoving = targetVelocity.Magnitude > 2
    
    local basePosition = targetRoot.Position + (targetLookVector * -2) + Vector3.new(0, 6, 0)
    
    if isTargetMoving then
        local moveDirection = targetVelocity.Unit
        basePosition = basePosition + (moveDirection * 1.5)
    end
    
    local currentPos = rootPart.Position
    local smoothFactor = 0.8
    
    if isTargetMoving then
        smoothFactor = 0.9
    else
        smoothFactor = 0.7
    end
    
    local targetPosition = currentPos:Lerp(basePosition, smoothFactor)
    
    local directionToTarget = (targetRoot.Position - targetPosition).Unit
    local targetCFrame = CFrame.new(targetPosition, targetPosition + directionToTarget)
    
    local currentCFrame = rootPart.CFrame
    local smoothCFrame = currentCFrame:Lerp(targetCFrame, 0.8)
    
    rootPart.CFrame = smoothCFrame
    
    MainModule.Killaura.LastValidTargetPos = targetRoot.Position
    MainModule.Killaura.LastTargetDistance = GetDistance(targetPosition, targetRoot.Position)
    
    MainModule.Killaura.ReturnToNormalTimer = 0
end

local function lookDirectlyAtTarget(character, targetPos, deltaTime)
    if not character or not targetPos then return end
    
    local rootPart = GetRootPart(character)
    if not rootPart then return end
    
    local currentPos = rootPart.Position
    local direction = (targetPos - currentPos).Unit
    
    local currentLook = rootPart.CFrame.LookVector
    local targetLook = direction
    local smoothedLook = currentLook:Lerp(targetLook, MainModule.Killaura.SmoothLookFactor * deltaTime * 30)
    
    local newCFrame = CFrame.new(currentPos, currentPos + smoothedLook)
    
    MainModule.Killaura.LastValidCFrame = newCFrame
    
    return newCFrame
end

local function checkTargetAnimations()
    if not MainModule.Killaura.Enabled or not MainModule.Killaura.CurrentTarget then return end
    
    local targetPlayer = MainModule.Killaura.CurrentTarget
    if not targetPlayer or not targetPlayer.Character then return end
    
    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return end
    
    local foundAnimation = false
    
    for _, track in pairs(targetHumanoid:GetPlayingAnimationTracks()) do
        if track and track.Animation then
            local animId = track.Animation.AnimationId
            
            if MainModule.Killaura.TargetAnimationsSet[animId] then
                foundAnimation = true
                
                if not MainModule.Killaura.IsLifted then
                    MainModule.Killaura.IsLifted = true
                    MainModule.Killaura.AnimationStartTime = tick()
                    MainModule.Killaura.ReturnAfterAnimation = false
                    print("Цель использует анимацию")
                end
                break
            end
        end
    end
    
    if not foundAnimation and MainModule.Killaura.IsLifted then
        local currentTime = tick()
        if currentTime - MainModule.Killaura.AnimationStartTime > 0.3 then
            MainModule.Killaura.IsLifted = false
            MainModule.Killaura.ReturnAfterAnimation = true
            print("Анимация цели завершена")
        end
    end
end

function MainModule.ToggleKillaura(enabled)
    MainModule.Killaura.Enabled = enabled
    
    for _, conn in pairs(MainModule.Killaura.Connections) do
        if conn then conn:Disconnect() end
    end
    MainModule.Killaura.Connections = {}
    
    MainModule.Killaura.CurrentTarget = nil
    MainModule.Killaura.IsAttached = false
    MainModule.Killaura.IsLifted = false
    MainModule.Killaura.IsActive = false
    MainModule.Killaura.ReturnAfterAnimation = false
    MainModule.Killaura.IsSearching = false
    MainModule.Killaura.SearchAttempts = 0
    MainModule.Killaura.SearchRadius = 50
    MainModule.Killaura.PlayerHasCombatItem = false
    
    if not enabled then
        local character = GetCharacter()
        if character then
            restoreOriginalState(character)
        end
        print("Killaura выключена, состояние восстановлено")
        return
    end
    
    print("Killaura включена")
    
    local character = GetCharacter()
    if character then
        saveOriginalState(character)
    end
    
    local lastUpdateTime = tick()
    
    table.insert(MainModule.Killaura.Connections, RunService.Heartbeat:Connect(function()
        if not MainModule.Killaura.Enabled then 
            local character = GetCharacter()
            if character then
                restoreOriginalState(character)
            end
            return 
        end
        
        local currentTime = tick()
        local deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        local character = GetCharacter()
        if not character then return end
        
        if currentTime - MainModule.Killaura.LastCombatCheck > MainModule.Killaura.CombatCheckInterval then
            local hasCombatItem = checkPlayerInventory()
            
            if hasCombatItem and not MainModule.Killaura.PlayerHasCombatItem then
                MainModule.Killaura.PlayerHasCombatItem = true
                print("Обнаружен боевой предмет, активируем Killaura")
            end
            
            if not hasCombatItem and MainModule.Killaura.PlayerHasCombatItem then
                print("Боевой предмет пропал, выключаем Killaura")
                MainModule.ToggleKillaura(false)
                return
            end
            
            MainModule.Killaura.LastCombatCheck = currentTime
        end
        
        if not MainModule.Killaura.CurrentTarget then
            if currentTime - MainModule.Killaura.SearchCooldown > 0.3 then
                local target = findTargetAnywhere()
                
                if target then
                    if attachInFrontOfTarget(target) then
                        MainModule.Killaura.CurrentTarget = target
                        MainModule.Killaura.LastTargetSwitch = currentTime
                        MainModule.Killaura.IsSearching = false
                        print("Найдена новая цель:", target.Name)
                    end
                else
                    if not MainModule.Killaura.IsSearching then
                        MainModule.Killaura.IsSearching = true
                        MainModule.Killaura.SearchAttempts = 0
                        print("Начинаем поиск цели...")
                    end
                end
                
                MainModule.Killaura.SearchCooldown = currentTime
            end
        else
            local targetPlayer = MainModule.Killaura.CurrentTarget
            local isValid = false
            
            if targetPlayer and targetPlayer.Character then
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local distance = GetDistance(GetRootPart(character).Position, targetRoot.Position)
                    
                    if distance <= MainModule.Killaura.Radius then
                        isValid = true
                    elseif MainModule.Killaura.ReturnAfterAnimation then
                        isValid = true
                    end
                end
            end
            
            if not isValid then
                MainModule.Killaura.CurrentTarget = nil
                MainModule.Killaura.IsAttached = false
                MainModule.Killaura.IsSearching = true
                MainModule.Killaura.SearchAttempts = 0
                print("Цель потеряна, ищем новую...")
                
                local humanoid = GetHumanoid(character)
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            else
                updateFrontAttachment(deltaTime)
                
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local newCFrame = lookDirectlyAtTarget(character, targetRoot.Position, deltaTime)
                    if newCFrame then
                        local rootPart = GetRootPart(character)
                        if rootPart then
                            rootPart.CFrame = rootPart.CFrame:Lerp(newCFrame, 0.6)
                        end
                    end
                end
            end
        end
        
        if MainModule.Killaura.IsAttached and not MainModule.Killaura.CurrentTarget then
            MainModule.Killaura.IsAttached = false
            
            local humanoid = GetHumanoid(character)
            if humanoid then
                humanoid.PlatformStand = false
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end))
    
    table.insert(MainModule.Killaura.Connections, RunService.Heartbeat:Connect(function()
        if MainModule.Killaura.Enabled and MainModule.Killaura.CurrentTarget then
            checkTargetAnimations()
        end
    end))
    
    table.insert(MainModule.Killaura.Connections, RunService.Heartbeat:Connect(function()
        if not MainModule.Killaura.Enabled then return end
        
        local character = GetCharacter()
        if not character then return end
        
        if not MainModule.Killaura.CurrentTarget and not MainModule.Killaura.IsSearching then
            MainModule.Killaura.ReturnToNormalTimer = MainModule.Killaura.ReturnToNormalTimer + 1/60
            
            if MainModule.Killaura.ReturnToNormalTimer > 3 then
                restoreOriginalState(character)
                MainModule.Killaura.ReturnToNormalTimer = 0
                print("Автовосстановление: нет цели 3 секунды")
            end
        else
            MainModule.Killaura.ReturnToNormalTimer = 0
        end
    end))
    
    table.insert(MainModule.Killaura.Connections, LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        task.wait(1)
        if MainModule.Killaura.Enabled then
            MainModule.Killaura.CurrentTarget = nil
            MainModule.Killaura.IsAttached = false
            MainModule.Killaura.IsActive = false
            MainModule.Killaura.PlayerHasCombatItem = false
            
            task.wait(0.5)
            saveOriginalState(newCharacter)
            
            print("Персонаж сменился, ищем новую цель...")
        end
    end))
    
    table.insert(MainModule.Killaura.Connections, LocalPlayer.Backpack.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            for _, combatItem in ipairs(MainModule.Killaura.CombatItems) do
                if string.find(child.Name:lower(), combatItem:lower()) then
                    MainModule.Killaura.PlayerHasCombatItem = true
                    print("Добавлен боевой предмет:", child.Name)
                    break
                end
            end
        end
    end))
    
    table.insert(MainModule.Killaura.Connections, LocalPlayer.Backpack.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            for _, combatItem in ipairs(MainModule.Killaura.CombatItems) do
                if string.find(child.Name:lower(), combatItem:lower()) then
                    local hasOtherCombatItems = checkPlayerInventory()
                    if not hasOtherCombatItems then
                        MainModule.Killaura.PlayerHasCombatItem = false
                        print("Удален последний боевой предмет, выключаем Killaura")
                        MainModule.ToggleKillaura(false)
                    else
                        print("Удален боевой предмет, но есть другие")
                    end
                    break
                end
            end
        end
    end))
end

function MainModule.SetKillauraRadius(radius)
    radius = math.clamp(radius, 15, MainModule.Killaura.MaxRadius)
    MainModule.Killaura.Radius = radius
    return radius
end

function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function GetCharacter()
    return LocalPlayer.Character
end

function GetRootPart(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

function GetHumanoid(character)
    return character and character:FindFirstChild("Humanoid")
end

function MainModule.Cleanup()
    local connections = {
        speedConnection, autoFarmConnection, godModeConnection, instaInteractConnection,
        noCooldownConnection, antiStunConnection, rapidFireConnection, infiniteAmmoConnection,
        hitboxConnection, autoPullConnection, bypassRagdollConnection
    }
    
    for _, conn in pairs(connections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    MainModule.ClearESP()
    
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.PocketSandCheck then
        MainModule.RLGL.PocketSandCheck:Disconnect()
        MainModule.RLGL.PocketSandCheck = nil
    end
    
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    if MainModule.SpikesKillFeature.AnimationConnection then
        MainModule.SpikesKillFeature.AnimationConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationConnection = nil
    end
    
    if MainModule.SpikesKillFeature.CharacterAddedConnection then
        MainModule.SpikesKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.SpikesKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.SpikesKillFeature.SafetyCheckConnection then
        MainModule.SpikesKillFeature.SafetyCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.SafetyCheckConnection = nil
    end
    
    if MainModule.SpikesKillFeature.AnimationCheckConnection then
        MainModule.SpikesKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.AnimationCheckConnection = nil
    end
    
    if MainModule.SpikesKillFeature.KnifeCheckConnection then
        MainModule.SpikesKillFeature.KnifeCheckConnection:Disconnect()
        MainModule.SpikesKillFeature.KnifeCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.SpikesKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.SpikesKillFeature.AnimationStoppedConnections = {}
    
    if MainModule.VoidKillFeature.AnimationConnection then
        MainModule.VoidKillFeature.AnimationConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationConnection = nil
    end
    
    if MainModule.VoidKillFeature.CharacterAddedConnection then
        MainModule.VoidKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.VoidKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.VoidKillFeature.AnimationCheckConnection then
        MainModule.VoidKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.VoidKillFeature.AnimationCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.VoidKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.VoidKillFeature.AnimationStoppedConnections = {}
    
    if MainModule.ZoneKillFeature.AnimationConnection then
        MainModule.ZoneKillFeature.AnimationConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationConnection = nil
    end
    
    if MainModule.ZoneKillFeature.CharacterAddedConnection then
        MainModule.ZoneKillFeature.CharacterAddedConnection:Disconnect()
        MainModule.ZoneKillFeature.CharacterAddedConnection = nil
    end
    
    if MainModule.ZoneKillFeature.AnimationCheckConnection then
        MainModule.ZoneKillFeature.AnimationCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.AnimationCheckConnection = nil
    end
    
    if MainModule.ZoneKillFeature.ZoneCheckConnection then
        MainModule.ZoneKillFeature.ZoneCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.ZoneCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
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
    
    if MainModule.Hitbox.Connection then
        MainModule.Hitbox.Connection:Disconnect()
        MainModule.Hitbox.Connection = nil
    end
    
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    
    if MainModule.Killaura.Connection then
        MainModule.Killaura.Connection:Disconnect()
        MainModule.Killaura.Connection = nil
    end
    
    if MainModule.Killaura.AnimationCheckConnection then
        MainModule.Killaura.AnimationCheckConnection:Disconnect()
        MainModule.Killaura.AnimationCheckConnection = nil
    end
    
    if MainModule.Killaura.CharacterAddedConnection then
        MainModule.Killaura.CharacterAddedConnection:Disconnect()
        MainModule.Killaura.CharacterAddedConnection = nil
    end
    
    if globalAnimationHandler then
        globalAnimationHandler:Disconnect()
        globalAnimationHandler = nil
    end
    
    MainModule.DisableFlight()
    
    MainModule.Fly.Enabled = false
    MainModule.Fly.Speed = 50
    MainModule.Fly.Connection = nil
    MainModule.Fly.BodyVelocity = nil
    MainModule.Fly.BodyGyro = nil
    MainModule.Fly.HumanoidDiedConnection = nil
    MainModule.Fly.CharacterAddedConnection = nil
    MainModule.Fly.SpeedChangeConnection = nil
    
    if MainModule.Noclip.Connection then
        MainModule.Noclip.Connection:Disconnect()
        MainModule.Noclip.Connection = nil
    end
    
    MainModule.StopEnhancedProtection()
    MainModule.StopJointCleaning()
    
    for part, properties in pairs(MainModule.Noclip.OriginalTransparency) do
        if part and part.Parent then
            pcall(function()
                part.Transparency = properties.Transparency
                part.CanCollide = properties.CanCollide
            end)
        end
    end
    MainModule.Noclip.OriginalTransparency = {}
    MainModule.Noclip.AffectedParts = {}
    MainModule.Noclip.ContactTime = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and MainModule.Hitbox.ModifiedParts[root] then
                root.Size = MainModule.Hitbox.ModifiedParts[root]
                root.CanCollide = true
            end
        end
    end
    MainModule.Hitbox.ModifiedParts = {}
    
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
    
    for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = properties.WalkSpeed
            humanoid.JumpPower = properties.JumpPower
        end
    end
    MainModule.AntiTimeStop.OriginalProperties = {}
    
    for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.GlassPlatforms = {}
    
    for part, properties in pairs(MainModule.GlassBridge.OriginalColors) do
        if part and part.Parent then
            pcall(function()
                part.Color = properties.Color
                part.Material = properties.Material
                part.Transparency = properties.Transparency
            end)
        end
    end
    MainModule.GlassBridge.OriginalColors = {}
    MainModule.GlassBridge.OriginalMaterials = {}
    MainModule.GlassBridge.OriginalTransparency = {}
    
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.RemoveGlassBridgeAntiFall()
    end
    
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.RemoveSkySquidAntiFall()
    end
    
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.RemoveJumpRopeAntiFall()
    end
    
    if MainModule.VoidKillFeature.AntiFallEnabled then
        MainModule.RemoveSkySquidAntiFall()
        MainModule.VoidKillFeature.AntiFallEnabled = false
    end
    
    if MainModule.SpeedHack.Enabled then
        MainModule.ToggleSpeedHack(false)
    end
    
    if MainModule.Noclip.Enabled then
        MainModule.ToggleNoclip(false)
    end
    
    if MainModule.Killaura.Enabled then
        MainModule.ToggleKillaura(false)
    end
    
    MainModule.SpeedHack.Enabled = false
    MainModule.SpeedHack.CurrentSpeed = 16
    MainModule.Noclip.Enabled = false
    MainModule.AutoDodge.Enabled = false
    MainModule.Killaura.Enabled = false
    MainModule.AutoQTE.AntiStunEnabled = false
    MainModule.Rebel.Enabled = false
    MainModule.RLGL.GodMode = false
    MainModule.Guards.AutoFarm = false
    MainModule.Guards.RapidFire = false
    MainModule.Guards.InfiniteAmmo = false
    MainModule.Guards.HitboxExpander = false
    MainModule.Hitbox.Enabled = false
    MainModule.AntiTimeStop.Enabled = false
    MainModule.HNS.InfinityStaminaEnabled = false
    MainModule.Misc.ESPEnabled = false
    MainModule.Misc.InstaInteract = false
    MainModule.Misc.NoCooldownProximity = false
    MainModule.Misc.BypassRagdollEnabled = false
    MainModule.TugOfWar.AutoPull = false
    MainModule.Dalgona.CompleteEnabled = false
    MainModule.Dalgona.FreeLighterEnabled = false
    MainModule.GlassBridge.AntiBreakEnabled = false
    MainModule.GlassBridge.AntiFallEnabled = false
    MainModule.GlassBridge.GlassESPEnabled = false
    MainModule.SpikesKillFeature.Enabled = false
    MainModule.SpikesKillFeature.TrackedAnimations = {}
    MainModule.SpikesKillFeature.SpikesRemoved = false
    MainModule.SpikesKillFeature.OriginalSpikes = {}
    MainModule.SpikesKillFeature.SpikesPosition = nil
    MainModule.SpikesKillFeature.HasKnife = false
    MainModule.VoidKillFeature.Enabled = false
    MainModule.VoidKillFeature.TrackedAnimations = {}
    MainModule.ZoneKillFeature.Enabled = false
    MainModule.ZoneKillFeature.TrackedAnimations = {}
    MainModule.FreeDash.Enabled = false
    MainModule.FreeDashGuards.Enabled = false
end

LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule






