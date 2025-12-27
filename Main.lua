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
local StarterGui = game:GetService("StarterGui")

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
    TransparentParts = {}, -- Для частей, которые мы сделали прозрачными
    OriginalProperties = {}, -- Храним оригинальные свойства
    CheckInterval = 0.05, -- Частая проверка для мгновенного реагирования
    LastCheck = 0,
    SearchRadius = 20, -- Увеличенный радиус поиска
    Connection = nil,
    GroundParts = {}, -- Части, которые являются полом под ногами
    CharacterParts = {}, -- Части персонажа
    FootRayDistance = 5, -- Увеличенная дистанция луча
    FootCheckPoints = 8, -- Количество точек для проверки под ногами
    HeightTolerance = 2 -- Допуск по высоте для определения "под ногами"
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
    DodgeCooldown = 0.6,
    Range = 5,
    AnimationIdsSet = {},
    PlayersInRange = {},
    LastRangeUpdate = 0,
    RangeUpdateInterval = 0.5
}

MainModule.Fly = {
    Enabled = false,
    Speed = 39,
    Connection = nil,
    BodyVelocity = nil,
    IsMobile = UserInputService.TouchEnabled
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
        "rbxassetid://107989020363293",
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

-- Ultra Fast Sync Killaura - 6 блоков вперед, мгновенная синхронизация
MainModule.Killaura = {
    Enabled = false,
    TeleportAnimations = {
        "79649041083405",
        "73242877658272", 
        "85793691404836",
        "86197206792061",
        "99157505926076"
    },
    Connections = {},
    CurrentTarget = nil,
    IsAttached = false,
    AttachmentType = "behind",
    IsLifted = false,
    LiftHeight = 12, -- Увеличенная высота уклонения
    TargetAnimationsSet = {},
    
    -- Параметры синхронизации (УВЕЛИЧЕНО)
    BehindDistance = 2,          -- 2 блока сзади
    FrontDistance = 6,           -- 6 БЛОКОВ ВПЕРЕДИ (как просили)
    SpeedThreshold = 18,
    
    -- СУПЕР БЫСТРЫЕ параметры
    MovementSpeed = 65,          -- УВЕЛИЧЕНО для мгновенной синхронизации
    RotationSpeed = 18,          -- Более быстрый поворот
    Smoothness = 0.85,           -- Меньше плавности = быстрее реакция
    DodgeSpeed = 180,            -- СУПЕР быстрая скорость уклонения
    
    -- Анти-детект параметры
    MaxVelocity = 85,            -- УВЕЛИЧЕНО
    VelocitySmoothness = 0.7,    -- Меньше сглаживания = быстрее
    HumanizeFactor = 0.1,
    NaturalNoise = 0.03,         -- Меньше шума = меньше задержек
    AntiDetectionMode = true,
    
    -- Внутренние переменные
    LastPosition = Vector3.new(),
    TargetLastVelocity = Vector3.new(),
    LastHeight = 0,
    JumpSync = false,
    IsJumping = false,
    JumpStartTime = 0,
    TimeOffset = 0,
    LastAnimationCheck = 0,
    DodgeActive = false,
    DodgeStartTime = 0,
    InstantSyncActive = false,
    LastSyncTime = 0
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

for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
    MainModule.AutoDodge.AnimationIdsSet[id] = true
end

for _, id in ipairs(MainModule.VoidKillFeature.AnimationIds) do
    MainModule.VoidKillFeature.AnimationIdsSet[id] = true
end

MainModule.ZoneKillFeature.AnimationIdsSet["rbxassetid://105341857343164"] = true

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

-- Функция для показа уведомлений
local function ShowNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

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
        -- БЛОК 1: Защита и блокировка DashRequest через глубокое удаление
        local function DeepRemoveDashRequest()
            -- Инициализация окружения
            local Environment = (getgenv or function() return _G end)()
            local CoreServices = game:GetService("ReplicatedStorage")

            -- Внутренняя процедура обработки объекта
            local function ProcessTargetObject()
                local RemoteContainer = CoreServices:FindFirstChild("Remotes")
                local TargetRemote = RemoteContainer and RemoteContainer:FindFirstChild("DashRequest")
                
                if TargetRemote then
                    -- Метод 1: Изменение метатаблицы
                    if type(setrawmetatable) == "function" then
                        local SecureTable = {
                            __index = function(self, key)
                                if key == "FireServer" or key == "InvokeServer" then
                                    return function() end
                                end
                                return nil
                            end,
                            __newindex = function() end,
                            __call = function() end,
                            __metatable = "Protected"
                        }
                        setrawmetatable(TargetRemote, SecureTable)
                        MainModule.FreeDash.SecureTable = SecureTable
                    end
                    
                    -- Метод 2: Очистка интерфейса
                    local RemoteMethods = {"FireServer", "InvokeServer", "OnClientEvent", "OnClientInvoke"}
                    for _, MethodName in ipairs(RemoteMethods) do
                        pcall(function()
                            local original = TargetRemote[MethodName]
                            if original then
                                MainModule.FreeDash["Original" .. MethodName] = original
                                -- Заменяем метод на пустую функцию
                                if setrawmetatable then
                                    local mt = debug.getmetatable(TargetRemote)
                                    if mt then
                                        local originalIndex = mt.__index
                                        mt.__index = function(self, key)
                                            if key == MethodName then
                                                return function() end
                                            end
                                            return originalIndex(self, key)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                    
                    -- Метод 3: Отключение обработчиков через псевдо-событие
                    if type(getconnections) == "function" then
                        local EventHandlers = {"Changed", "AncestryChanged"}
                        for _, EventName in ipairs(EventHandlers) do
                            local EventSignal = TargetRemote[EventName]
                            if EventSignal then
                                for _, Handler in ipairs(getconnections(EventSignal)) do
                                    Handler:Disconnect()
                                end
                            end
                        end
                    end
                    
                    -- Метод 4: Изменение состояния (самый эффективный)
                    pcall(function()
                        TargetRemote.Archivable = false
                        MainModule.FreeDash.OriginalParent = TargetRemote.Parent
                        -- Альтернатива: создаем клон и подменяем
                        local FakeRemote = Instance.new("RemoteEvent")
                        FakeRemote.Name = "DashRequest"
                        for _, descendant in ipairs(TargetRemote:GetChildren()) do
                            descendant:Clone().Parent = FakeRemote
                        end
                        FakeRemote.Parent = TargetRemote.Parent
                        MainModule.FreeDash.OriginalRemote = TargetRemote
                        TargetRemote.Parent = nil
                        MainModule.FreeDash.FakeRemote = FakeRemote
                    end)
                    
                    -- Метод 5: Модификация доступа через rawset
                    if type(getrawmetatable) == "function" then
                        local ObjectMeta = getrawmetatable(TargetRemote)
                        if ObjectMeta then
                            MainModule.FreeDash.OriginalIndex = ObjectMeta.__index
                            MainModule.FreeDash.OriginalNewIndex = ObjectMeta.__newindex
                            
                            ObjectMeta.__index = function(self, Property)
                                if Property == "FireServer" or Property == "InvokeServer" then
                                    return function() end
                                end
                                return MainModule.FreeDash.OriginalIndex(self, Property)
                            end
                            
                            ObjectMeta.__newindex = function(self, Property, Value)
                                if Property == "Parent" and Value == nil then
                                    return -- Блокируем установку Parent в nil
                                end
                                return MainModule.FreeDash.OriginalNewIndex(self, Property, Value)
                            end
                        end
                    end
                end
            end

            -- Выполнение процедуры
            ProcessTargetObject()
            
            -- Защита от восстановления объекта
            local remoteFolder = CoreServices:WaitForChild("Remotes", 1)
            if remoteFolder then
                MainModule.FreeDash.RemoteAddedConnection = remoteFolder.ChildAdded:Connect(function(child)
                    if child.Name == "DashRequest" then
                        task.wait(0.1)
                        pcall(function()
                            if setrawmetatable then
                                local SecureTable = {
                                    __index = function() return function() end end,
                                    __newindex = function() end,
                                    __metatable = "Protected"
                                }
                                setrawmetatable(child, SecureTable)
                            end
                            child.Archivable = false
                            child.Parent = nil
                        end)
                    end
                end)
            end
        end

        -- БЛОК 2: Защита от создания новых DashRequest через ChildAdded
        local function BlockNewDashRequests()
            local CoreServices = game:GetService("ReplicatedStorage")
            local remoteFolder = CoreServices:WaitForChild("Remotes", 1)
            if remoteFolder then
                -- Перехватываем через ChildAdded вместо __newindex
                MainModule.FreeDash.ChildAddedHook = remoteFolder.ChildAdded:Connect(function(child)
                    if child.Name == "DashRequest" then
                        task.spawn(function()
                            task.wait(0.05) -- Небольшая задержка для безопасности
                            pcall(function()
                                -- Быстрая нейтрализация
                                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                                    if setrawmetatable then
                                        local mt = {
                                            __index = function() return function() end end,
                                            __newindex = function() end
                                        }
                                        setrawmetatable(child, mt)
                                    end
                                    child.Archivable = false
                                    child.Parent = nil
                                end
                            end)
                        end)
                    end
                end)
            end
        end

        -- Запускаем блокировку
        DeepRemoveDashRequest()
        BlockNewDashRequests()

        -- БЛОК 3: Установка Faster Sprint в 9 (вместо 5)
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                MainModule.FreeDash.OriginalSprintValue = fasterSprint.Value
                fasterSprint.Value = 8 -- Изменено с 5 на 10
            end
        end
        
        -- БЛОК 4: Дополнительная защита для remote (на всякий случай)
        local remote = ReplicatedStorage:FindFirstChild("Remotes")
        if remote then
            remote = remote:FindFirstChild("DashRequest")
            if remote then
                -- Более безопасный способ отключения
                MainModule.FreeDash.RemoteEventConnection = remote:GetPropertyChangedSignal("Parent"):Connect(function()
                    pcall(function()
                        if remote.Parent == nil then
                            -- Автоматическое восстановление FakeRemote
                            if MainModule.FreeDash.FakeRemote then
                                MainModule.FreeDash.FakeRemote.Parent = MainModule.FreeDash.OriginalParent
                            end
                        end
                    end)
                end)
            end
        end
        
    else
        -- ОТКЛЮЧЕНИЕ: Восстанавливаем всё обратно
        
        -- Отключаем все соединения
        if MainModule.FreeDash.RemoteAddedConnection then
            MainModule.FreeDash.RemoteAddedConnection:Disconnect()
            MainModule.FreeDash.RemoteAddedConnection = nil
        end
        
        if MainModule.FreeDash.ChildAddedHook then
            MainModule.FreeDash.ChildAddedHook:Disconnect()
            MainModule.FreeDash.ChildAddedHook = nil
        end
        
        if MainModule.FreeDash.RemoteEventConnection then
            MainModule.FreeDash.RemoteEventConnection:Disconnect()
            MainModule.FreeDash.RemoteEventConnection = nil
        end
        
        -- Восстанавливаем Faster Sprint
        local boosts = LocalPlayer:FindFirstChild("Boosts")
        if boosts then
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            if fasterSprint then
                fasterSprint.Value = MainModule.FreeDash.OriginalSprintValue
            end
        end
        
        -- Восстанавливаем оригинальный Remote
        if MainModule.FreeDash.OriginalRemote and MainModule.FreeDash.OriginalParent then
            pcall(function()
                MainModule.FreeDash.OriginalRemote.Parent = MainModule.FreeDash.OriginalParent
            end)
        end
        
        -- Удаляем FakeRemote
        if MainModule.FreeDash.FakeRemote then
            pcall(function() MainModule.FreeDash.FakeRemote:Destroy() end)
            MainModule.FreeDash.FakeRemote = nil
        end
        
        -- Восстанавливаем метатаблицы
        if MainModule.FreeDash.OriginalIndex then
            local remote = ReplicatedStorage:FindFirstChild("Remotes")
            if remote then
                remote = remote:FindFirstChild("DashRequest")
                if remote and getrawmetatable then
                    local mt = getrawmetatable(remote)
                    if mt then
                        mt.__index = MainModule.FreeDash.OriginalIndex
                        if MainModule.FreeDash.OriginalNewIndex then
                            mt.__newindex = MainModule.FreeDash.OriginalNewIndex
                        end
                    end
                end
            end
        end
        
        -- Восстанавливаем оригинальные методы
        local methods = {"FireServer", "InvokeServer", "OnClientEvent", "OnClientInvoke"}
        for _, method in ipairs(methods) do
            local original = MainModule.FreeDash["Original" .. method]
            if original then
                local remote = ReplicatedStorage:FindFirstChild("Remotes")
                if remote then
                    remote = remote:FindFirstChild("DashRequest")
                    if remote then
                        pcall(function()
                            remote[method] = original
                        end)
                    end
                end
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
        ShowNotification("GodMode", "Enabled", 2)
        
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
                    ShowNotification("GodMode", "Disabled", 2)
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
                    ShowNotification("GodMode", "Safe to Player", 2)
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
                    ShowNotification("GodMode", "Disabled", 2)
                    MainModule.ToggleGodMode(false)
                end
            else
                MainModule.RLGL.NoPocketSandTimer = 0
            end
        end)
    else
        ShowNotification("GodMode", "Disabled", 2)
        
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
            ShowNotification("Spikes Kill", "Knife not found!", 3)
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
                ShowNotification("Spikes Kill", "Knife not found!", 3)
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
    MainModule.Guards.HitboxExpander = enabled
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    if enabled then
        print("Hitbox Enabled...")
        hitboxConnection = RunService.Heartbeat:Connect(function()
            if not MainModule.Guards.HitboxExpander then return end
            pcall(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            if not MainModule.Hitbox.ModifiedParts[root] then
                                MainModule.Hitbox.ModifiedParts[root] = root.Size
                                root.Size = Vector3.new(MainModule.Hitbox.Size, MainModule.Hitbox.Size, MainModule.Hitbox.Size)
                                root.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end)
    else
        pcall(function()
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
        end)
    end
end

function MainModule.SetHitboxSize(size)
    MainModule.Hitbox.Size = size
    if MainModule.Guards.HitboxExpander then
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

-- Создаем набор для быстрого поиска анимаций
for _, id in ipairs(MainModule.AutoDodge.AnimationIds) do
    MainModule.AutoDodge.AnimationIdsSet[id] = true
end

-- Улучшенная функция AutoDodge
local function executeDodge()
    if not MainModule.AutoDodge.Enabled then return false end
    
    local currentTime = tick()
    local autoDodge = MainModule.AutoDodge
    
    if currentTime - autoDodge.LastDodgeTime < autoDodge.DodgeCooldown then
        return false
    end
    
    local player = game:GetService("Players").LocalPlayer
    if not player then return false end
    
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if remote then
        remote = remote:FindFirstChild("UsedTool")
        if not remote then return false end
    else
        return false
    end
    
    local tool = nil
    if player.Character then
        tool = player.Character:FindFirstChild("DODGE!")
    end
    
    if not tool and player:FindFirstChild("Backpack") then
        local backpack = player:FindFirstChild("Backpack")
        tool = backpack:FindFirstChild("DODGE!")
    end
    
    if not tool then return false end
    
    local success = pcall(function() 
        remote:FireServer("UsingMoveCustom", tool, nil, {Clicked = true}) 
    end)
    
    if success then
        autoDodge.LastDodgeTime = currentTime
        return true
    end
    
    return false
end

local function createAutoDodgeHandler()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    local function checkPlayerAnimation(player)
        if player == LocalPlayer then return end
        if not player or not player.Character then return end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        local localCharacter = LocalPlayer.Character
        if not localCharacter then return end
        
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        
        if not (localRoot and targetRoot) then return end
        
        -- Проверка расстояния
        local distance = (targetRoot.Position - localRoot.Position).Magnitude
        if distance > MainModule.AutoDodge.Range then return end
        
        -- Проверка направления взгляда
        local isLookingAtUs = false
        local targetLook = targetRoot.CFrame.LookVector
        
        -- Вектор от врага к нам
        local directionToLocal = (localRoot.Position - targetRoot.Position).Unit
        
        -- Скалярное произведение (cos угла между векторами)
        local dotProduct = targetLook:Dot(directionToLocal)
        
        -- Если враг смотрит в нашу сторону (даже не точно на нас)
        -- Значение 0 = перпендикулярно, 1 = прямо на нас, -1 = в противоположную сторону
        if dotProduct > 0 then -- Убрал 0.5, теперь любое положительное значение
            isLookingAtUs = true
        end
        
        -- Дополнительная проверка: если враг очень близко (в радиусе 2), доджим в любом случае
        if distance <= 2 then
            isLookingAtUs = true
        end
        
        if isLookingAtUs then
            -- Проверяем текущие анимации врага
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track and track.Animation then
                    local animId = track.Animation.AnimationId
                    if MainModule.AutoDodge.AnimationIdsSet[animId] then
                        executeDodge()
                        return
                    end
                end
            end
        end
    end
    
    local function setupPlayerTracking(player)
        if player == LocalPlayer then return end
        
        local function setupCharacter(character)
            if not character or not MainModule.AutoDodge.Enabled then return end
            
            local humanoid = character:WaitForChild("Humanoid", 2)
            if humanoid then
                local conn = humanoid.AnimationPlayed:Connect(function(track)
                    if not MainModule.AutoDodge.Enabled then return end
                    checkPlayerAnimation(player)
                end)
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
    
    return setupPlayerTracking
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.AutoDodge.Enabled = false
    
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
        MainModule.AutoDodge.Enabled = true
        
        local setupPlayerTracking = createAutoDodgeHandler()
        
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            task.spawn(setupPlayerTracking, player)
        end
        
        local playerAddedConn = game:GetService("Players").PlayerAdded:Connect(function(player)
            if MainModule.AutoDodge.Enabled then
                task.spawn(setupPlayerTracking, player)
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, playerAddedConn)
        
        local heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.AutoDodge.Enabled then return end
            
            local currentTime = tick()
            if currentTime - MainModule.AutoDodge.LastRangeUpdate > MainModule.AutoDodge.RangeUpdateInterval then
                MainModule.AutoDodge.LastRangeUpdate = currentTime
            end
        end)
        table.insert(MainModule.AutoDodge.Connections, heartbeatConn)
    end
end

-- Включаем/выключаем умный ноклип
function MainModule.ToggleNoclip(enabled)
    ShowNotification("Noclip", "Don't work", 2)
end

-- Простой флай: летим туда, куда смотрим/идем
function MainModule.EnableFlight()
    if MainModule.Fly.Enabled then return end
    
    MainModule.Fly.Enabled = true
    
    local character = GetCharacter()
    if not character then return end
    
    local humanoid = GetHumanoid(character)
    local rootPart = GetRootPart(character)
    if not (humanoid and rootPart) then return end
    
    -- Создаем BodyVelocity только при полете
    local function createFlyBV()
        if MainModule.Fly.BodyVelocity then
            MainModule.Fly.BodyVelocity:Destroy()
        end
        
        local flyBV = Instance.new("BodyVelocity")
        flyBV.Name = "FlyBodyVelocity"
        flyBV.MaxForce = Vector3.new(40000, 40000, 40000)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = rootPart
        
        MainModule.Fly.BodyVelocity = flyBV
        return flyBV
    end
    
    -- Создаем BodyVelocity
    local flyBV = createFlyBV()
    
    -- Функция для получения вектора движения на мобилке
    local function getMobileMoveVector()
        local moveVector = UserInputService:GetMoveVector()
        
        if moveVector.Magnitude > 0 then
            local camera = workspace.CurrentCamera
            if not camera then return Vector3.new(0, 0, 0) end
            
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector
            
            -- Обнуляем Y компоненту у векторов направления для горизонтального движения
            lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit
            rightVector = Vector3.new(rightVector.X, 0, rightVector.Z).Unit
            
            -- Комбинируем направление
            local direction = (lookVector * moveVector.Y) + (rightVector * moveVector.X)
            return direction.Unit
        end
        
        return Vector3.new(0, 0, 0)
    end
    
    -- Основной цикл полета
    MainModule.Fly.Connection = RunService.Heartbeat:Connect(function()
        if not MainModule.Fly.Enabled or not character or not character.Parent then 
            if MainModule.Fly.Connection then
                MainModule.Fly.Connection:Disconnect()
                MainModule.Fly.Connection = nil
            end
            return 
        end
        
        rootPart = GetRootPart(character)
        if not rootPart or not flyBV then 
            MainModule.DisableFlight()
            return 
        end
        
        local camera = workspace.CurrentCamera
        if not camera then return end
        
        -- Направление движения
        local moveDirection = Vector3.new(0, 0, 0)
        local lookVector = camera.CFrame.LookVector
        
        if MainModule.Fly.IsMobile then
            -- Для мобильных: летим в направлении виртуального джойстика
            local mobileDirection = getMobileMoveVector()
            if mobileDirection.Magnitude > 0 then
                moveDirection = mobileDirection
            else
                -- Если джойстик не используется, просто висим на месте
                moveDirection = Vector3.new(0, 0, 0)
            end
        else
            -- Для ПК: WASD управление относительно взгляда камеры
            local rightVector = camera.CFrame.RightVector
            
            -- Вперед/назад (W/S)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + lookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - lookVector
            end
            
            -- Влево/вправо (A/D)
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - rightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + rightVector
            end
        end
        
        -- Применяем скорость если есть направление
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit * MainModule.Fly.Speed
            flyBV.Velocity = moveDirection
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    -- Обработка смерти персонажа
    local function handleDeath()
        MainModule.DisableFlight()
    end
    
    if humanoid then
        humanoid.Died:Connect(handleDeath)
    end
    
    -- Обработка смены персонажа
    local characterAddedConnection
    characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        task.wait(0.5)
        
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
        
        if MainModule.Fly.Enabled then
            MainModule.DisableFlight()
            task.wait(0.1)
            MainModule.EnableFlight()
        end
    end)
end

function MainModule.DisableFlight()
    if not MainModule.Fly.Enabled then return end
    
    MainModule.Fly.Enabled = false
    
    -- Отключаем соединение
    if MainModule.Fly.Connection then
        MainModule.Fly.Connection:Disconnect()
        MainModule.Fly.Connection = nil
    end
    
    -- Удаляем BodyVelocity
    if MainModule.Fly.BodyVelocity then
        MainModule.Fly.BodyVelocity:Destroy()
        MainModule.Fly.BodyVelocity = nil
    end
    
    -- Возвращаем персонажа в нормальное состояние
    local character = GetCharacter()
    if character then
        local rootPart = GetRootPart(character)
        if rootPart then
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            rootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

function MainModule.ToggleFly(enabled)
    if enabled then
        ShowNotification("Fly", "Enabled", 3)
        MainModule.EnableFlight()
    else
        ShowNotification("Fly", "Disabled", 3)
        MainModule.DisableFlight()
    end
end

function MainModule.SetFlySpeed(speed)
    MainModule.Fly.Speed = math.clamp(speed, 1, 100)
    return MainModule.Fly.Speed
end

-- Инициализация анимаций
for _, animId in pairs(MainModule.Killaura.TeleportAnimations) do
    MainModule.Killaura.TargetAnimationsSet[animId] = true
end

-- Ультра быстрый поиск игрока
local function findClosestPlayer()
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    if not localPlayer then return nil end
    
    local character = localPlayer.Character
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    local myPos = rootPart.Position
    
    -- Быстрый цикл без лишних проверок
    local playerList = players:GetPlayers()
    for i = 1, #playerList do
        local player = playerList[i]
        
        if player ~= localPlayer then
            local targetChar = player.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local distance = (targetRoot.Position - myPos).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Мгновенная проверка анимаций
local function checkTargetAnimationsInstant(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    -- Мгновенная проверка без pcall для скорости
    local tracks = humanoid:GetPlayingAnimationTracks()
    
    if tracks then
        for i = 1, #tracks do
            local track = tracks[i]
            if track and track.Animation then
                local animId = tostring(track.Animation.AnimationId)
                local cleanId = animId:match("%d+")
                
                if cleanId and MainModule.Killaura.TargetAnimationsSet[cleanId] then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Быстрая проверка прыжка
local function checkTargetJumping(targetRoot)
    if not targetRoot then return false end
    
    local velocityY = targetRoot.Velocity.Y
    return velocityY > 8 -- Более чувствительная проверка
end

-- Определение направления движения (оптимизировано)
local function getTargetMovementDirection(targetRoot)
    if not targetRoot then return "forward" end
    
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    
    local horizontalVel = Vector3.new(targetVel.X, 0, targetVel.Z)
    local horizontalSpeed = horizontalVel.Magnitude
    
    if horizontalSpeed < 2 then
        return "stationary"
    end
    
    local lookDirection = Vector3.new(targetLook.X, 0, targetLook.Z).Unit
    local moveDirection = horizontalVel.Unit
    
    local dotProduct = lookDirection:Dot(moveDirection)
    
    if dotProduct < -0.2 then
        return "backward"
    elseif dotProduct > 0.6 then
        return "forward"
    else
        return "strafe"
    end
end

-- СУПЕР БЫСТРОЕ уклонение
local function performInstantDodge(localRoot, targetPos, deltaTime)
    local config = MainModule.Killaura
    
    if not config.DodgeActive then
        config.DodgeActive = true
        config.DodgeStartTime = tick()
        config.IsLifted = true
    end
    
    -- Мгновенное направление от цели
    local directionFromTarget = (localRoot.Position - targetPos).Unit
    
    -- МГНОВЕННОЕ ускорение
    local dodgeForce = directionFromTarget * config.DodgeSpeed
    localRoot.Velocity = dodgeForce + Vector3.new(0, 80, 0) -- Быстрый подъем
    
    -- Мгновенный подъем
    local currentCF = localRoot.CFrame
    localRoot.CFrame = currentCF + Vector3.new(0, deltaTime * 100, 0)
    
    -- Короткое уклонение (0.3 секунды)
    if tick() - config.DodgeStartTime > 0.3 then
        config.DodgeActive = false
    end
end

-- Быстрая анти-детект функция
local function applyFastAntiDetection(localRoot, targetVel, desiredVel, deltaTime)
    local config = MainModule.Killaura
    if not config.AntiDetectionMode then return desiredVel end
    
    -- Быстрое ограничение скорости
    local speed = desiredVel.Magnitude
    if speed > config.MaxVelocity then
        desiredVel = desiredVel.Unit * config.MaxVelocity
    end
    
    -- Быстрое смешивание
    local blendedVel = desiredVel:Lerp(targetVel, config.VelocitySmoothness)
    
    -- Минимальный шум для скорости
    config.TimeOffset = config.TimeOffset + deltaTime * 10
    local noise = Vector3.new(
        math.sin(config.TimeOffset) * config.NaturalNoise,
        math.cos(config.TimeOffset * 1.5) * config.NaturalNoise * 0.1,
        math.sin(config.TimeOffset * 0.8) * config.NaturalNoise
    ) * 5
    
    return blendedVel + noise
end

-- МГНОВЕННАЯ синхронизация позиции
local function instantPositionSync(localRoot, targetPos, targetLook, attachmentType, deltaTime)
    local config = MainModule.Killaura
    
    -- Вычисляем желаемую позицию
    local desiredOffset
    if attachmentType == "behind" then
        desiredOffset = -targetLook * config.BehindDistance
    else
        desiredOffset = targetLook * config.FrontDistance -- 6 блоков!
    end
    
    local desiredPos = targetPos + desiredOffset
    
    -- Мгновенное перемещение с высокой скоростью
    local currentPos = localRoot.Position
    local direction = desiredPos - currentPos
    local distance = direction.Magnitude
    
    if distance > 0.01 then
        -- МГНОВЕННАЯ скорость
        local speed = math.min(config.MovementSpeed * 2, distance * 50)
        local moveStep = direction.Unit * speed * deltaTime
        local newPos = currentPos + moveStep
        
        -- Быстрый поворот
        local lookAtPos
        if attachmentType == "behind" then
            lookAtPos = targetPos
        else
            lookAtPos = newPos + targetLook * 100
        end
        
        -- Быстрая интерполяция
        local targetCF = CFrame.new(newPos, lookAtPos)
        local currentCF = localRoot.CFrame
        local smoothCF = currentCF:Lerp(targetCF, config.RotationSpeed * deltaTime * 2)
        
        -- Применяем мгновенно
        localRoot.CFrame = smoothCF
        localRoot.Velocity = moveStep / deltaTime
        
        -- Активируем мгновенную синхронизацию
        config.InstantSyncActive = true
        config.LastSyncTime = tick()
        
    else
        -- Мгновенная фиксация на месте
        local lookAtPos = attachmentType == "behind" and targetPos or (desiredPos + targetLook * 100)
        localRoot.CFrame = CFrame.new(desiredPos, lookAtPos)
        localRoot.Velocity = Vector3.new(0, 0, 0)
        config.InstantSyncActive = false
    end
end

-- Основная функция - БЕЗ ЗАДЕРЖЕК
local function ultraFastSync(targetRoot, targetHumanoid, localRoot, deltaTime)
    local config = MainModule.Killaura
    
    -- Получаем данные цели МГНОВЕННО
    local targetPos = targetRoot.Position
    local targetVel = targetRoot.Velocity
    local targetLook = targetRoot.CFrame.LookVector
    local horizontalSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
    
    -- Быстрая проверка направления
    local movementDirection = getTargetMovementDirection(targetRoot)
    
    -- Быстрая проверка прыжка
    local isTargetJumping = checkTargetJumping(targetRoot)
    
    if isTargetJumping and not config.JumpSync then
        config.JumpSync = true
        config.IsJumping = true
        config.JumpStartTime = tick()
    elseif not isTargetJumping and config.JumpSync then
        if tick() - config.JumpStartTime > 0.3 then
            config.JumpSync = false
            config.IsJumping = false
        end
    end
    
    -- МГНОВЕННАЯ проверка анимаций (каждый кадр!)
    if config.CurrentTarget then
        local isAnimating = checkTargetAnimationsInstant(config.CurrentTarget)
        
        if isAnimating and not config.DodgeActive and not config.IsLifted then
            -- МГНОВЕННОЕ уклонение без задержек
            performInstantDodge(localRoot, targetPos, deltaTime)
            config.LastAnimationCheck = tick()
            return
        elseif not isAnimating and config.IsLifted and not config.DodgeActive then
            -- Быстрое опускание
            local currentY = localRoot.Position.Y
            local targetY = targetPos.Y + 4
            
            if currentY > targetY + 1 then
                local dropSpeed = 50 * deltaTime
                localRoot.CFrame = localRoot.CFrame - Vector3.new(0, dropSpeed, 0)
                config.InstantSyncActive = true
            else
                config.IsLifted = false
                config.InstantSyncActive = false
            end
        end
        
        config.LastAnimationCheck = tick()
    end
    
    -- Мгновенное определение позиции
    local shouldBeInFront = (horizontalSpeed > config.SpeedThreshold) 
        and not config.IsJumping 
        and movementDirection ~= "backward"
    
    local newAttachmentType = shouldBeInFront and "front" or "behind"
    
    if config.AttachmentType ~= newAttachmentType then
        config.AttachmentType = newAttachmentType
        config.InstantSyncActive = true -- Форсируем мгновенную синхронизацию при смене позиции
    end
    
    -- МГНОВЕННАЯ СИНХРОНИЗАЦИЯ ПОЗИЦИИ
    if config.InstantSyncActive or tick() - config.LastSyncTime > 0.1 then
        instantPositionSync(localRoot, targetPos, targetLook, config.AttachmentType, deltaTime)
        
        -- Синхронизация прыжка
        if config.IsJumping then
            local targetHeight = targetPos.Y
            local myHeight = localRoot.Position.Y
            local heightDiff = targetHeight - myHeight
            
            if math.abs(heightDiff) > 1 then
                localRoot.CFrame = localRoot.CFrame + Vector3.new(0, heightDiff * deltaTime * 30, 0)
                config.InstantSyncActive = true
            end
        end
    else
        -- Быстрая коррекция позиции
        local desiredOffset = config.AttachmentType == "behind" 
            and -targetLook * config.BehindDistance 
            or targetLook * config.FrontDistance
        
        local desiredPos = targetPos + desiredOffset
        local currentPos = localRoot.Position
        local distance = (desiredPos - currentPos).Magnitude
        
        if distance > 0.5 then
            config.InstantSyncActive = true
        end
    end
    
    -- Быстрая гравитация
    if not config.IsJumping and not config.IsLifted and not config.DodgeActive then
        local rayOrigin = localRoot.Position + Vector3.new(0, 2, 0)
        local ray = Ray.new(rayOrigin, Vector3.new(0, -6, 0))
        local hit, groundPos = workspace:FindPartOnRayWithIgnoreList(ray, {localRoot.Parent})
        
        if hit then
            local heightDiff = localRoot.Position.Y - groundPos.Y
            if heightDiff > 3 then
                localRoot.Velocity = localRoot.Velocity + Vector3.new(0, -60, 0)
            elseif heightDiff < 2.5 then
                localRoot.Velocity = localRoot.Velocity + Vector3.new(0, 20, 0)
            end
        end
    end
    
    -- Сохраняем данные
    config.LastPosition = localRoot.Position
    config.TargetLastVelocity = targetVel
end

-- Основной цикл - МАКСИМАЛЬНО БЫСТРЫЙ
local function updateUltraFastSync(deltaTime)
    if not MainModule.Killaura.Enabled then return end
    
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    if not localPlayer then return end
    
    local character = localPlayer.Character
    if not character then return end
    
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    local config = MainModule.Killaura
    
    -- Мгновенный поиск цели
    if not config.CurrentTarget or not config.IsAttached then
        local closestPlayer = findClosestPlayer()
        if closestPlayer then
            config.CurrentTarget = closestPlayer
            config.IsAttached = true
            config.IsLifted = false
            config.IsJumping = false
            config.DodgeActive = false
            config.InstantSyncActive = true
            
            local targetChar = closestPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if targetRoot then
                local targetVel = targetRoot.Velocity
                local horizontalSpeed = Vector3.new(targetVel.X, 0, targetVel.Z).Magnitude
                local targetLook = targetRoot.CFrame.LookVector
                local movementDir = getTargetMovementDirection(targetRoot)
                
                local startPos
                if horizontalSpeed > config.SpeedThreshold and movementDir ~= "backward" then
                    startPos = targetRoot.Position + (targetLook * config.FrontDistance)
                    config.AttachmentType = "front"
                else
                    startPos = targetRoot.Position - (targetLook * config.BehindDistance)
                    config.AttachmentType = "behind"
                end
                
                -- МГНОВЕННАЯ установка позиции
                localRoot.CFrame = CFrame.new(startPos, config.AttachmentType == "behind" and targetRoot.Position or (startPos + targetLook))
                config.LastPosition = startPos
                config.LastSyncTime = tick()
            end
        end
        return
    end
    
    -- Быстрая валидация цели
    local targetPlayer = config.CurrentTarget
    if not targetPlayer or not targetPlayer.Character then
        config.CurrentTarget = nil
        config.IsAttached = false
        config.DodgeActive = false
        return
    end
    
    local targetChar = targetPlayer.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
        config.CurrentTarget = nil
        config.IsAttached = false
        config.IsLifted = false
        config.IsJumping = false
        config.DodgeActive = false
        return
    end
    
    -- ВЫПОЛНЯЕМ МГНОВЕННУЮ СИНХРОНИЗАЦИЮ
    ultraFastSync(targetRoot, targetHumanoid, localRoot, deltaTime)
end

-- Включение/выключение
function MainModule.ToggleKillaura(enabled)
    local config = MainModule.Killaura
    
    if config.Enabled == enabled then return end
    
    config.Enabled = enabled
    
    -- Быстрая очистка
    for _, conn in pairs(config.Connections) do
        if conn then
            conn:Disconnect()
        end
    end
    config.Connections = {}
    
    if not enabled then
        config.CurrentTarget = nil
        config.IsAttached = false
        config.IsLifted = false
        config.IsJumping = false
        config.DodgeActive = false
        config.InstantSyncActive = false
        ShowNotification("Killaura", "Отключено", 1)
        return
    end
    
    ShowNotification("Killaura", "Включено - ULTRA FAST MODE", 1)
    
    -- ОСНОВНОЙ ЦИКЛ НА HEARTBEAT - МАКСИМАЛЬНАЯ СКОРОСТЬ
    local heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if not config.Enabled then return end
        updateUltraFastSync(deltaTime)
    end)
    
    table.insert(config.Connections, heartbeatConn)
    
    -- Быстрые обработчики событий
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    if localPlayer then
        local charConn = localPlayer.CharacterAdded:Connect(function()
            if not config.Enabled then return end
            
            task.wait(0.5) -- Минимальная задержка
            
            config.CurrentTarget = nil
            config.IsAttached = false
            config.IsLifted = false
            config.IsJumping = false
            config.DodgeActive = false
            
            -- Мгновенный поиск новой цели
            task.delay(0.1, function()
                local closestPlayer = findClosestPlayer()
                if closestPlayer then
                    config.CurrentTarget = closestPlayer
                    config.IsAttached = true
                    config.InstantSyncActive = true
                end
            end)
        end)
        table.insert(config.Connections, charConn)
    end
    
    local removeConn = players.PlayerRemoving:Connect(function(player)
        if config.Enabled and config.CurrentTarget == player then
            config.CurrentTarget = nil
            config.IsAttached = false
            config.DodgeActive = false
            
            -- Мгновенный поиск
            task.delay(0.05, function()
                local closestPlayer = findClosestPlayer()
                if closestPlayer then
                    config.CurrentTarget = closestPlayer
                    config.IsAttached = true
                    config.InstantSyncActive = true
                end
            end)
        end
    end)
    table.insert(config.Connections, removeConn)
end

-- Функции для горячих клавиш
function MainModule.SetFlyHotkey(keyCode)
    MainModule.Fly.CurrentHotkey = keyCode
end

function MainModule.SetNoclipHotkey(keyCode)
    MainModule.Noclip.CurrentHotkey = keyCode
end

function MainModule.SetKillauraHotkey(keyCode)
    MainModule.Killaura.CurrentHotkey = keyCode
end

-- Основные функции телепорта
function MainModule.TeleportToHider()
    local hider = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if IsHider(player) then
                    hider = player
                    break
                end
            end
        end
    end
    
    if hider and hider.Character then
        local rootPart = GetRootPart(hider.Character)
        if rootPart then
            SafeTeleport(rootPart.Position)
            return true
        end
    end
    return false
end

function MainModule.GetHider()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 and IsHider(player) then
                return player.Character
            end
        end
    end
    return nil
end

function MainModule.Cleanup()
    -- Отключаем все основные соединения
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
    
    -- Очищаем ESP
    MainModule.ClearESP()
    
    -- Отключаем RLGL
    if MainModule.RLGL.Connection then
        MainModule.RLGL.Connection:Disconnect()
        MainModule.RLGL.Connection = nil
    end
    
    if MainModule.RLGL.PocketSandCheck then
        MainModule.RLGL.PocketSandCheck:Disconnect()
        MainModule.RLGL.PocketSandCheck = nil
    end
    
    -- Отключаем Rebel
    if MainModule.Rebel.Connection then
        MainModule.Rebel.Connection:Disconnect()
        MainModule.Rebel.Connection = nil
    end
    
    -- Отключаем HNS
    if MainModule.HNS.InfinityStaminaConnection then
        MainModule.HNS.InfinityStaminaConnection:Disconnect()
        MainModule.HNS.InfinityStaminaConnection = nil
    end
    
    -- Отключаем SpikesKillFeature
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
    
    -- Отключаем VoidKillFeature
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
    
    -- Отключаем ZoneKillFeature
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
    
    -- ИСПРАВЛЕНО: ZoneCheckConnection был объявлен, но не создавался в ZoneKillFeature
    -- Добавлен для совместимости с вашим исходным кодом
    if MainModule.ZoneKillFeature.ZoneCheckConnection then
        MainModule.ZoneKillFeature.ZoneCheckConnection:Disconnect()
        MainModule.ZoneKillFeature.ZoneCheckConnection = nil
    end
    
    for _, conn in ipairs(MainModule.ZoneKillFeature.AnimationStoppedConnections) do
        pcall(function() conn:Disconnect() end)
    end
    MainModule.ZoneKillFeature.AnimationStoppedConnections = {}
    
    -- Отключаем GlassBridge
    if MainModule.GlassBridge.AntiBreakConnection then
        MainModule.GlassBridge.AntiBreakConnection:Disconnect()
        MainModule.GlassBridge.AntiBreakConnection = nil
    end
    
    if MainModule.GlassBridge.GlassESPConnection then
        MainModule.GlassBridge.GlassESPConnection:Disconnect()
        MainModule.GlassBridge.GlassESPConnection = nil
    end
    
    -- Отключаем JumpRope (Connection не был объявлен в структуре, но добавлен для совместимости)
    if MainModule.JumpRope.Connection then
        MainModule.JumpRope.Connection:Disconnect()
        MainModule.JumpRope.Connection = nil
    end
    
    -- Отключаем SkySquid (Connection не был объявлен в структуре, но добавлен для совместимости)
    if MainModule.SkySquid.Connection then
        MainModule.SkySquid.Connection:Disconnect()
        MainModule.SkySquid.Connection = nil
    end
    
    -- Отключаем TugOfWar
    if MainModule.TugOfWar.Connection then
        MainModule.TugOfWar.Connection:Disconnect()
        MainModule.TugOfWar.Connection = nil
    end
    
    -- Отключаем Hitbox
    if MainModule.Hitbox.Connection then
        MainModule.Hitbox.Connection:Disconnect()
        MainModule.Hitbox.Connection = nil
    end
    
    -- Отключаем AntiTimeStop
    if MainModule.AntiTimeStop.Connection then
        MainModule.AntiTimeStop.Connection:Disconnect()
        MainModule.AntiTimeStop.Connection = nil
    end
    
    -- Отключаем Killaura
    for _, conn in pairs(MainModule.Killaura.Connections) do
        if conn then conn:Disconnect() end
    end
    MainModule.Killaura.Connections = {}
    
    -- Отключаем AutoDodge
    for _, conn in pairs(MainModule.AutoDodge.Connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    MainModule.AutoDodge.Connections = {}
    
    -- Отключаем Fly
    MainModule.DisableFlight()
    
    -- Сбрасываем состояние Fly
    MainModule.Fly.Enabled = false
    MainModule.Fly.Speed = 39
    MainModule.Fly.Connection = nil
    MainModule.Fly.BodyVelocity = nil
    MainModule.Fly.BodyGyro = nil
    MainModule.Fly.HumanoidDiedConnection = nil
    MainModule.Fly.CharacterAddedConnection = nil
    
    -- ИСПРАВЛЕНО: SpeedChangeConnection не был объявлен в структуре Fly
    if MainModule.Fly.SpeedChangeConnection then
        MainModule.Fly.SpeedChangeConnection:Disconnect()
        MainModule.Fly.SpeedChangeConnection = nil
    end
    
    -- Отключаем Noclip
    if MainModule.Noclip.Connection then
        MainModule.Noclip.Connection:Disconnect()
        MainModule.Noclip.Connection = nil
    end
    
    -- Отключаем защиту от ragdoll
    MainModule.StopEnhancedProtection()
    MainModule.StopJointCleaning()
    
    -- Восстанавливаем коллизии для частей Noclip
    -- ИСПРАВЛЕНО: Используем правильную структуру данных из MainModule.Noclip
    for part, _ in pairs(MainModule.Noclip.OriginalProperties) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = true
            end)
        end
    end
    MainModule.Noclip.OriginalProperties = {}
    MainModule.Noclip.TransparentParts = {}
    
    -- Восстанавливаем хитбоксы игроков
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
    
    -- Восстанавливаем оригинальные значения патронов
    for obj, originalValue in pairs(MainModule.Guards.OriginalAmmo) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalAmmo = {}
    
    -- Восстанавливаем оригинальные значения скорострельности
    for obj, originalValue in pairs(MainModule.Guards.OriginalFireRates) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    MainModule.Guards.OriginalFireRates = {}
    
    -- Восстанавливаем оригинальные свойства для AntiTimeStop
    for humanoid, properties in pairs(MainModule.AntiTimeStop.OriginalProperties) do
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = properties.WalkSpeed
            humanoid.JumpPower = properties.JumpPower
        end
    end
    MainModule.AntiTimeStop.OriginalProperties = {}
    
    -- Удаляем платформы GlassBridge
    for _, platform in pairs(MainModule.GlassBridge.GlassPlatforms) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    MainModule.GlassBridge.GlassPlatforms = {}
    
    -- Восстанавливаем оригинальные цвета GlassBridge
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
    
    -- Удаляем анти-падение GlassBridge
    if MainModule.GlassBridge.GlassAntiFallPlatform and MainModule.GlassBridge.GlassAntiFallPlatform.Parent then
        MainModule.RemoveGlassBridgeAntiFall()
    end
    
    -- Удаляем анти-падение SkySquid
    if MainModule.SkySquid.AntiFallPlatform and MainModule.SkySquid.AntiFallPlatform.Parent then
        MainModule.RemoveSkySquidAntiFall()
    end
    
    -- Удаляем анти-падение JumpRope
    if MainModule.JumpRope.AntiFallPlatform and MainModule.JumpRope.AntiFallPlatform.Parent then
        MainModule.RemoveJumpRopeAntiFall()
    end
    
    -- ИСПРАВЛЕНО: VoidKillFeature использует свою собственную платформу
    if MainModule.VoidKillFeature.AntiFallPlatform and MainModule.VoidKillFeature.AntiFallPlatform.Parent then
        MainModule.VoidKillFeature.AntiFallPlatform:Destroy()
        MainModule.VoidKillFeature.AntiFallPlatform = nil
    end
    MainModule.VoidKillFeature.AntiFallEnabled = false
    
    -- Отключаем функции вызовом соответствующих методов
    if MainModule.SpeedHack.Enabled then
        MainModule.ToggleSpeedHack(false)
    end
    
    if MainModule.Noclip.Enabled then
        MainModule.ToggleNoclip(false)
    end
    
    if MainModule.Killaura.Enabled then
        MainModule.ToggleKillaura(false)
    end
    
    if MainModule.AutoDodge.Enabled then
        MainModule.ToggleAutoDodge(false)
    end
    
    if MainModule.Fly.Enabled then
        MainModule.ToggleFly(false)
    end
    
    -- Сбрасываем все флаги состояния
    MainModule.SpeedHack.Enabled = false
    MainModule.SpeedHack.CurrentSpeed = 16
    MainModule.Noclip.Enabled = false
    MainModule.AutoDodge.Enabled = false
    MainModule.Killaura.Enabled = false
    MainModule.Fly.Enabled = false
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
    
    ShowNotification("Cleanup", "All features disabled", 3)
end

LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not LocalPlayer.Parent then
        MainModule.Cleanup()
    end
end)

return MainModule


