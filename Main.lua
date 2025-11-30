local MainModule = {}

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
    RemoveInjuredWalking = false
}

MainModule.Guards = {
    SelectedGuard = "Circle",
    AutoFarm = false,
    RapidFire = false,
    InfiniteAmmo = false,
    HitboxExpander = false,
    OriginalFireRates = {},
    OriginalAmmo = {}
}

MainModule.Dalgona = {
    CompleteEnabled = false,
    FreeLighterEnabled = false
}

MainModule.HNS = {
    AutoPickup = false,
    SpikesKill = false,
    DeleteSpikes = false,
    KillHiders = false,
    AutoDodge = false
}

MainModule.TugOfWar = {
    AutoPull = false
}

MainModule.GlassBridge = {
    AntiBreak = false
}

MainModule.Misc = {
    InstaInteract = false,
    NoCooldownProximity = false,
    EnableDash = false,
    ESPEnabled = false,
    ESPHighlight = true,
    ESPDistance = true,
    ESPFillTransparency = 0.75,
    ESPOutlineTransparency = 0,
    ESPTextSize = 22
}

-- ESP System
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
local removeInjuredConnection = nil
local dashConnection = nil
local espConnection = nil

-- Функции скорости
function MainModule.ToggleSpeedHack(enabled)
    MainModule.SpeedHack.Enabled = enabled
    local player = game:GetService("Players").LocalPlayer
    
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
        
        speedConnection = game:GetService("RunService").Heartbeat:Connect(function()
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
        local player = game:GetService("Players").LocalPlayer
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
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 100, 0)
    end
end

function MainModule.TeleportDown40()
    local player = game:GetService("Players").LocalPlayer
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
        antiStunConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.AutoQTE.AntiStunEnabled then return end
            
            pcall(function()
                local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                local impactFrames = playerGui:FindFirstChild("ImpactFrames")
                if not impactFrames then return end
                
                local replicatedStorage = game:GetService("ReplicatedStorage")
                
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

-- RLGL функции
function MainModule.TeleportToEnd()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-214.4, 1023.1, 146.7)
    end
end

function MainModule.TeleportToStart()
    local player = game:GetService("Players").LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(-55.3, 1023.1, -545.8)
    end
end

function MainModule.ToggleGodMode(enabled)
    MainModule.RLGL.GodMode = enabled
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    if enabled then
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            MainModule.RLGL.OriginalHeight = character.HumanoidRootPart.Position.Y
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, 1184.9, currentPos.Z)
        end
    else
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and MainModule.RLGL.OriginalHeight then
            local currentPos = character.HumanoidRootPart.Position
            character.HumanoidRootPart.CFrame = CFrame.new(currentPos.X, MainModule.RLGL.OriginalHeight, currentPos.Z)
        end
    end
end

-- Remove InjuredWalking функция
function MainModule.ToggleRemoveInjuredWalking(enabled)
    MainModule.RLGL.RemoveInjuredWalking = enabled
    
    if removeInjuredConnection then
        removeInjuredConnection:Disconnect()
        removeInjuredConnection = nil
    end
    
    if enabled then
        removeInjuredConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.RLGL.RemoveInjuredWalking then return end
            
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name == "InjuredWalking" or obj.Name:lower():find("stun") then
                        obj:Destroy()
                    end
                end
            end)
        end)
    end
end

-- Enable Dash функция
function MainModule.ToggleEnableDash(enabled)
    MainModule.Misc.EnableDash = enabled
    
    if dashConnection then
        dashConnection:Disconnect()
        dashConnection = nil
    end
    
    if enabled then
        local player = game:GetService("Players").LocalPlayer
        
        -- Устанавливаем максимальный уровень спринта
        pcall(function()
            if player:FindFirstChild("Boosts") and player.Boosts:FindFirstChild("Faster Sprint") then
                player.Boosts["Faster Sprint"].Value = 5
            end
        end)
        
        -- Скрываем кнопки покупки
        dashConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Misc.EnableDash then return end
            
            pcall(function()
                local shopGui = player.PlayerGui:FindFirstChild("ShopGui")
                if shopGui then
                    local storeHolder = shopGui:FindFirstChild("StoreHolder")
                    if storeHolder then
                        local store = storeHolder:FindFirstChild("Store")
                        if store then
                            local pages = store:FindFirstChild("PAGES")
                            if pages then
                                local boosts = pages:FindFirstChild("Boosts")
                                if boosts then
                                    local speedBoost = boosts:FindFirstChild("Faster Sprint")
                                    if speedBoost then
                                        -- Скрываем кнопки покупки
                                        if speedBoost:FindFirstChild("BuyButtonRobux") then
                                            speedBoost.BuyButtonRobux.Visible = false
                                        end
                                        if speedBoost:FindFirstChild("BuyButtonCoin") then
                                            speedBoost.BuyButtonCoin.Visible = false
                                        end
                                        -- Устанавливаем текст уровня
                                        if speedBoost:FindFirstChild("ItemLevel") then
                                            speedBoost.ItemLevel.Text = "Current Level (5)"
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
        -- Возвращаем исходное значение
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            if player:FindFirstChild("Boosts") and player.Boosts:FindFirstChild("Faster Sprint") then
                player.Boosts["Faster Sprint"].Value = 1 -- Исходный уровень
            end
        end)
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
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PlayableGuardRemote"):FireServer(unpack(args))
    end)
end

function MainModule.ToggleAutoFarm(enabled)
    MainModule.Guards.AutoFarm = enabled
    
    if autoFarmConnection then
        autoFarmConnection:Disconnect()
        autoFarmConnection = nil
    end
    
    if enabled then
        autoFarmConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if MainModule.Guards.AutoFarm then
                local args2 = {
                    "GameOver",
                    4450
                }
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("VideoGameRemote"):FireServer(unpack(args2))
                end)
            end
        end)
    end
end

-- Rapid Fire функция (исправленная)
function MainModule.ToggleRapidFire(enabled)
    MainModule.Guards.RapidFire = enabled
    
    if rapidFireConnection then
        rapidFireConnection:Disconnect()
        rapidFireConnection = nil
    end
    
    if enabled then
        -- Сохраняем исходные значения
        pcall(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
            if weaponsFolder then
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if gunsFolder then
                    for _, obj in ipairs(gunsFolder:GetDescendants()) do
                        if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                            MainModule.Guards.OriginalFireRates[obj] = obj.Value
                        end
                    end
                end
            end
        end)
        
        rapidFireConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Guards.RapidFire then return end
            
            pcall(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
                if not weaponsFolder then return end
                local gunsFolder = weaponsFolder:FindFirstChild("Guns")
                if not gunsFolder then return end
                
                for _, obj in ipairs(gunsFolder:GetDescendants()) do
                    if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                        obj.Value = 0
                    end
                end
                
                local player = game:GetService("Players").LocalPlayer
                local character = player.Character
                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj.Name == "FireRateCD" and (obj:IsA("NumberValue") or obj:IsA("IntValue")) then
                                    obj.Value = 0
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        -- Восстанавливаем исходные значения
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

-- Infinite Ammo функция (исправленная)
function MainModule.ToggleInfiniteAmmo(enabled)
    MainModule.Guards.InfiniteAmmo = enabled
    
    if infiniteAmmoConnection then
        infiniteAmmoConnection:Disconnect()
        infiniteAmmoConnection = nil
    end
    
    if enabled then
        -- Сохраняем исходные значения патронов
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") then
                                    MainModule.Guards.OriginalAmmo[obj] = obj.Value
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        infiniteAmmoConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Guards.InfiniteAmmo then return end
            
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if character then
                for _, tool in pairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, obj in pairs(tool:GetDescendants()) do
                            if obj:IsA("NumberValue") then
                                if obj.Name:lower():find("ammo") or 
                                   obj.Name:lower():find("bullet") or
                                   obj.Name:lower():find("clip") then
                                    obj.Value = math.huge
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        -- Восстанавливаем исходные значения патронов
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

-- Hitbox Expander функция (исправленная)
function MainModule.ToggleHitboxExpander(enabled)
    MainModule.Guards.HitboxExpander = enabled
    
    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end
    
    if enabled then
        _G.HeadSize = 30
        
        local function UpdateHeadHitboxes()
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                    pcall(function()
                        -- Увеличиваем хитбокс но делаем его полностью прозрачным
                        v.Character.Head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        v.Character.Head.Transparency = 1 -- Полностью прозрачный
                        v.Character.Head.CanCollide = false
                    end)
                end
            end
        end
        
        hitboxConnection = game:GetService("RunService").RenderStepped:Connect(UpdateHeadHitboxes)
    else
        -- Восстанавливаем оригинальные размеры и прозрачность
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                pcall(function()
                    v.Character.Head.Size = Vector3.new(2, 1, 1)
                    v.Character.Head.Transparency = 0
                    v.Character.Head.Material = "Plastic"
                    v.Character.Head.BrickColor = BrickColor.new("Medium stone grey")
                end)
            end
        end
    end
end

-- Dalgona функции
function MainModule.CompleteDalgona()
    task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        if not ReplicatedStorage then
            return
        end
        local DalgonaClientModule = ReplicatedStorage:FindFirstChild("Modules") and
                                    ReplicatedStorage.Modules:FindFirstChild("Games") and
                                    ReplicatedStorage.Modules.Games:FindFirstChild("DalgonaClient")
        if not DalgonaClientModule then
            return
        end
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
    local player = game:GetService("Players").LocalPlayer
    player:SetAttribute("HasLighter", true)
end

-- HNS функции (убраны ESP функции)
function MainModule.ToggleAutoPickup(enabled)
    MainModule.HNS.AutoPickup = enabled
end

function MainModule.ToggleSpikesKill(enabled)
    MainModule.HNS.SpikesKill = enabled
end

function MainModule.ToggleDeleteSpikes(enabled)
    MainModule.HNS.DeleteSpikes = enabled
end

function MainModule.ToggleKillHiders(enabled)
    MainModule.HNS.KillHiders = enabled
end

function MainModule.ToggleAutoDodge(enabled)
    MainModule.HNS.AutoDodge = enabled
end

-- Tug Of War функции
function MainModule.ToggleAutoPull(enabled)
    MainModule.TugOfWar.AutoPull = enabled
    
    if autoPullConnection then
        autoPullConnection:Disconnect()
        autoPullConnection = nil
    end
    
    if enabled then
        autoPullConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if MainModule.TugOfWar.AutoPull then
                pcall(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

-- Glass Bridge функции
function MainModule.ToggleAntiBreak(enabled)
    MainModule.GlassBridge.AntiBreak = enabled
    
    if antiBreakConnection then
        antiBreakConnection:Disconnect()
        antiBreakConnection = nil
    end
    
    if enabled then
        antiBreakConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.GlassBridge.AntiBreak then return end
            
            pcall(function()
                local GlassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
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
    end
end

-- ESP System функции
function MainModule.CreateESP(args)
    if not args.Object then return end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        Type = args.Type or "None",
        Highlights = {},
        Humanoid = nil,
        Connections = {}
    }

    local tableIndex = #MainModule.ESPTable[ESPManager.Type] + 1

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart then
        ESPManager.Object:SetAttribute("Transparency", ESPManager.Object.PrimaryPart.Transparency)
        ESPManager.Humanoid = Instance.new("Humanoid", ESPManager.Object)
        ESPManager.Object.PrimaryPart.Transparency = 0.99
    end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = ESPManager.Object
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = ESPManager.Color
    highlight.FillTransparency = MainModule.Misc.ESPFillTransparency
    highlight.OutlineColor = ESPManager.Color
    highlight.OutlineTransparency = MainModule.Misc.ESPOutlineTransparency
    highlight.Enabled = MainModule.Misc.ESPHighlight
    highlight.Parent = ESPManager.Object

    table.insert(ESPManager.Highlights, highlight)
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
    billboardGui.AlwaysOnTop = true
    billboardGui.ClipsDescendants = false
    billboardGui.Size = UDim2.new(0, 1, 0, 1)
    billboardGui.StudsOffset = ESPManager.Offset
    billboardGui.Parent = ESPManager.TextParent or ESPManager.Object

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Oswald
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = ESPManager.Text
    textLabel.TextColor3 = ESPManager.Color
    textLabel.TextSize = MainModule.Misc.ESPTextSize
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0.75
    textLabel.Parent = billboardGui

    function ESPManager.Destroy()
        if ESPManager.IsEntity and ESPManager.Object then
            if ESPManager.Object.PrimaryPart then
                ESPManager.Object.PrimaryPart.Transparency = ESPManager.Object.PrimaryPart:GetAttribute("Transparency")
            end
            if ESPManager.Humanoid then
                ESPManager.Humanoid:Destroy()
            end
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight:Destroy()
        end
        if billboardGui then billboardGui:Destroy() end

        if MainModule.ESPTable[ESPManager.Type][tableIndex] then
            MainModule.ESPTable[ESPManager.Type][tableIndex] = nil
        end

        for _, conn in pairs(ESPManager.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        ESPManager.Connections = {}
    end

    function ESPManager.GiveSignal(signal)
        table.insert(ESPManager.Connections, signal)
    end

    MainModule.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function MainModule.DistanceFromCharacter(obj)
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and obj and obj:IsA("BasePart") then
        return (character.HumanoidRootPart.Position - obj.Position).Magnitude
    end
    return 0
end

function MainModule.ToggleESP(enabled)
    MainModule.Misc.ESPEnabled = enabled
    
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    
    if enabled then
        -- Очищаем старые ESP
        for _, espType in pairs(MainModule.ESPTable) do
            for _, esp in pairs(espType) do
                if esp.Destroy then
                    esp:Destroy()
                end
            end
        end
        
        espConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not MainModule.Misc.ESPEnabled then return end
            
            -- Здесь будет логика создания ESP для разных объектов
            -- Пока что это заглушка для демонстрации
        end)
    else
        -- Очищаем все ESP при выключении
        for _, espType in pairs(MainModule.ESPTable) do
            for _, esp in pairs(espType) do
                if esp.Destroy then
                    esp:Destroy()
                end
            end
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

        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                makePromptInstant(obj)
            end
        end

        instaInteractConnection = workspace.DescendantAdded:Connect(function(obj)
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
        for _, v in pairs(workspace:GetDescendants()) do
            if v.ClassName == "ProximityPrompt" then
                v.HoldDuration = 0
            end
        end
        
        noCooldownConnection = workspace.DescendantAdded:Connect(function(obj)
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
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", position.X, position.Y, position.Z)
    end
    return "Не доступно"
end

return MainModule
