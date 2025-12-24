-- Creon X v2.5 - Advanced Loader
-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local player = Players.LocalPlayer

-- Christmas colors
local CHRISTMAS_COLORS = {
    RED = Color3.fromRGB(220, 20, 60),
    GREEN = Color3.fromRGB(46, 204, 113),
    GOLD = Color3.fromRGB(241, 196, 15),
    BLUE = Color3.fromRGB(52, 152, 219),
    WHITE = Color3.fromRGB(236, 240, 241),
    SNOW = Color3.fromRGB(255, 255, 255),
    DARK_BLUE = Color3.fromRGB(15, 20, 30)
}

-- Admin key
local ADMIN_KEY = "KEYADMIN20262026LOADING"

-- Keys storage
local keysData = {
    keys = {},
    blacklist = {}
}

-- Try to load from DataStore or use memory
local function SaveKeys()
    local success, err = pcall(function()
        -- Try DataStore first
        local dataStore = DataStoreService:GetDataStore("CreonX_Keys")
        dataStore:SetAsync("KeysData", keysData)
    end)
    
    if not success then
        -- Fallback to memory with warning
        warn("Could not save to DataStore, using memory only. Error: " .. tostring(err))
        -- Можно также сохранить в ReplicatedStorage как запасной вариант
        local repStorage = game:GetService("ReplicatedStorage")
        local folder = repStorage:FindFirstChild("CreonX_Keys_Temp")
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = "CreonX_Keys_Temp"
            folder.Parent = repStorage
        end
        
        local dataValue = folder:FindFirstChild("KeysData")
        if not dataValue then
            dataValue = Instance.new("StringValue")
            dataValue.Name = "KeysData"
            dataValue.Parent = folder
        end
        
        dataValue.Value = HttpService:JSONEncode(keysData)
    end
end

local function LoadKeys()
    local success, err = pcall(function()
        -- Try DataStore first
        local dataStore = DataStoreService:GetDataStore("CreonX_Keys")
        local savedData = dataStore:GetAsync("KeysData")
        
        if savedData then
            keysData = savedData
            return
        end
    end)
    
    if not success then
        -- Try fallback from ReplicatedStorage
        local repStorage = game:GetService("ReplicatedStorage")
        local folder = repStorage:FindFirstChild("CreonX_Keys_Temp")
        if folder then
            local dataValue = folder:FindFirstChild("KeysData")
            if dataValue and dataValue.Value ~= "" then
                local success2, result = pcall(function()
                    return HttpService:JSONDecode(dataValue.Value)
                end)
                if success2 and result then
                    keysData = result
                    return
                end
            end
        end
    end
end

-- Load existing keys
LoadKeys()

-- Check if key is valid
local function IsKeyValid(key)
    -- Check if key is in blacklist
    for _, blacklistedKey in pairs(keysData.blacklist or {}) do
        if blacklistedKey == key then
            return false, "Key is blacklisted"
        end
    end
    
    -- Check if it's admin key
    if key == ADMIN_KEY then
        return true, "admin"
    end
    
    -- Check in regular keys
    for keyData, expiry in pairs(keysData.keys or {}) do
        if keyData == key then
            local currentTime = os.time()
            if expiry > currentTime then
                return true, "user"
            else
                -- Move to blacklist if expired
                table.insert(keysData.blacklist, key)
                keysData.keys[key] = nil
                SaveKeys()
                return false, "Key expired"
            end
        end
    end
    
    return false, "Invalid key"
end

-- Add new key
local function AddNewKey(key)
    if key == ADMIN_KEY then
        return false, "Cannot add admin key"
    end
    
    -- Initialize tables if nil
    keysData.keys = keysData.keys or {}
    keysData.blacklist = keysData.blacklist or {}
    
    -- Check if key already exists
    for existingKey, _ in pairs(keysData.keys) do
        if existingKey == key then
            return false, "Key already exists"
        end
    end
    
    -- Check if key is blacklisted
    for _, blacklistedKey in pairs(keysData.blacklist) do
        if blacklistedKey == key then
            return false, "Key is blacklisted"
        end
    end
    
    -- Add key with 24 hour expiry
    local expiryTime = os.time() + (24 * 60 * 60) -- 24 hours
    keysData.keys[key] = expiryTime
    SaveKeys()
    
    return true, "Key added successfully"
end

-- Get remaining time for a key
local function GetKeyRemainingTime(key)
    if not keysData.keys or not keysData.keys[key] then
        return "N/A"
    end
    
    local expiry = keysData.keys[key]
    local currentTime = os.time()
    local remaining = expiry - currentTime
    
    if remaining <= 0 then
        return "Expired"
    end
    
    local hours = math.floor(remaining / 3600)
    local minutes = math.floor((remaining % 3600) / 60)
    
    return string.format("%02d:%02d", hours, minutes)
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "CreonXLoader"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

-- Snow effect
local SnowContainer = Instance.new("Frame")
SnowContainer.Size = UDim2.new(1, 0, 1, 0)
SnowContainer.BackgroundTransparency = 1
SnowContainer.Parent = ScreenGui

local SnowParticles = {}
for i = 1, 50 do
    local snowflake = Instance.new("TextLabel")
    snowflake.Size = UDim2.new(0, math.random(8, 16), 0, math.random(8, 16))
    snowflake.Position = UDim2.new(0, math.random(0, 1000), 0, math.random(-100, 0))
    snowflake.BackgroundTransparency = 1
    snowflake.Text = "❄"
    snowflake.TextColor3 = CHRISTMAS_COLORS.SNOW
    snowflake.TextSize = math.random(14, 22)
    snowflake.TextTransparency = 0.6
    snowflake.ZIndex = 0
    snowflake.Parent = SnowContainer
    
    table.insert(SnowParticles, {
        object = snowflake,
        speed = math.random(30, 60),
        sway = math.random(-15, 15) / 100,
        rotationSpeed = math.random(-2, 2)
    })
end

-- Animate snow
RunService.RenderStepped:Connect(function(deltaTime)
    for _, snowflake in ipairs(SnowParticles) do
        if snowflake.object and snowflake.object.Parent then
            local currentPos = snowflake.object.Position
            local newY = currentPos.Y.Offset + snowflake.speed * deltaTime
            local newX = currentPos.X.Offset + snowflake.sway * 15
            
            if newY > 1000 then
                newY = -50
                newX = math.random(0, 1000)
            end
            
            if newX < 0 then newX = 1000 end
            if newX > 1000 then newX = 0 end
            
            snowflake.object.Position = UDim2.new(0, newX, 0, newY)
            snowflake.object.Rotation = snowflake.object.Rotation + snowflake.rotationSpeed
        end
    end
end)

-- Function to create stylish buttons
local function CreateStyledButton(parent, text, size, position)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = CHRISTMAS_COLORS.RED
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = CHRISTMAS_COLORS.WHITE
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CHRISTMAS_COLORS.GOLD
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2,
            TextColor3 = CHRISTMAS_COLORS.GOLD
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3,
            TextColor3 = CHRISTMAS_COLORS.WHITE
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    return button
end

-- Function to create styled frame
local function CreateStyledFrame(size, position, parent)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = CHRISTMAS_COLORS.DARK_BLUE
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CHRISTMAS_COLORS.RED
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = frame
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 20, 30)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 30))
    })
    gradient.Rotation = 45
    gradient.Parent = frame
    
    return frame
end

-- Function to create styled textbox
local function CreateStyledTextBox(parent, size, position, placeholder)
    local textBoxContainer = Instance.new("Frame")
    textBoxContainer.Size = size
    textBoxContainer.Position = position
    textBoxContainer.BackgroundTransparency = 1
    textBoxContainer.Parent = parent
    
    local textBoxFrame = Instance.new("Frame")
    textBoxFrame.Size = UDim2.new(1, 0, 1, 0)
    textBoxFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    textBoxFrame.BackgroundTransparency = 0.3
    textBoxFrame.BorderSizePixel = 0
    textBoxFrame.Parent = textBoxContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = textBoxFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CHRISTMAS_COLORS.BLUE
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = textBoxFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 1, 0)
    textBox.Position = UDim2.new(0, 10, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = CHRISTMAS_COLORS.WHITE
    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.ClearTextOnFocus = false
    textBox.Parent = textBoxFrame
    
    return textBox
end

-- Function to create styled label
local function CreateStyledLabel(parent, text, size, position, isTitle)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = isTitle and CHRISTMAS_COLORS.GOLD or CHRISTMAS_COLORS.WHITE
    label.TextSize = isTitle and 18 or 14
    label.Font = isTitle and Enum.Font.GothamBold or Enum.Font.Gotham
    label.TextStrokeColor3 = isTitle and CHRISTMAS_COLORS.RED or Color3.new(0, 0, 0)
    label.TextStrokeTransparency = isTitle and 0.5 or 0.8
    label.Parent = parent
    
    return label
end

-- Function to show notification
local function ShowNotification(text, color)
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 300, 0, 50)
    notificationFrame.Position = UDim2.new(0.5, -150, 0.8, -100) -- Start off-screen
    notificationFrame.BackgroundColor3 = color
    notificationFrame.BackgroundTransparency = 0.3
    notificationFrame.BorderSizePixel = 0
    notificationFrame.ZIndex = 100
    notificationFrame.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notificationFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 2
    stroke.Parent = notificationFrame
    
    local label = CreateStyledLabel(notificationFrame, text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), false)
    label.TextColor3 = CHRISTMAS_COLORS.WHITE
    
    -- Slide in animation
    TweenService:Create(notificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.8, 0)
    }):Play()
    
    -- Auto remove after 3 seconds
    task.delay(3, function()
        if notificationFrame and notificationFrame.Parent then
            TweenService:Create(notificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -150, 0.8, -100)
            }):Play()
            task.delay(0.3, function()
                if notificationFrame and notificationFrame.Parent then
                    notificationFrame:Destroy()
                end
            end)
        end
    end)
    
    return notificationFrame
end

-- Function to clear GUI
local function ClearGUI()
    for _, child in pairs(ScreenGui:GetChildren()) do
        if child.Name ~= "SnowContainer" then
            child:Destroy()
        end
    end
end

-- Main Key Verification GUI
local function CreateKeyVerificationGUI()
    ClearGUI()
    
    local mainFrame = CreateStyledFrame(
        UDim2.new(0, 400, 0, 300),
        UDim2.new(0.5, -200, 0.5, -150),
        ScreenGui
    )
    
    -- Title
    local titleLabel = CreateStyledLabel(
        mainFrame,
        "🎄 Creon X v2.5 🎅",
        UDim2.new(1, 0, 0, 60),
        UDim2.new(0, 0, 0, 10),
        true
    )
    
    -- Subtitle
    local subtitleLabel = CreateStyledLabel(
        mainFrame,
        "Enter your access key",
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0, 70),
        false
    )
    
    -- Key input
    local keyTextBox = CreateStyledTextBox(
        mainFrame,
        UDim2.new(0.8, 0, 0, 40),
        UDim2.new(0.1, 0, 0.4, 0),
        "Enter access key..."
    )
    
    -- Verify button
    local verifyButton = CreateStyledButton(
        mainFrame,
        "Verify Key",
        UDim2.new(0.6, 0, 0, 45),
        UDim2.new(0.2, 0, 0.65, 0)
    )
    
    verifyButton.MouseButton1Click:Connect(function()
        local key = keyTextBox.Text
        if key == "" then
            ShowNotification("Please enter a key", CHRISTMAS_COLORS.RED)
            return
        end
        
        local isValid, keyType = IsKeyValid(key)
        
        if isValid then
            ClearGUI()
            if keyType == "admin" then
                CreateAdminPanelGUI()
            else
                loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Creon.lua", true))()
            end
        else
            ShowNotification(keyType, CHRISTMAS_COLORS.RED)
        end
    end)
end

-- Admin Panel GUI
local function CreateAdminPanelGUI()
    ClearGUI()
    
    local mainFrame = CreateStyledFrame(
        UDim2.new(0, 500, 0, 400),
        UDim2.new(0.5, -250, 0.5, -200),
        ScreenGui
    )
    
    -- Title
    local titleLabel = CreateStyledLabel(
        mainFrame,
        "👑 Admin Control Panel",
        UDim2.new(1, 0, 0, 60),
        UDim2.new(0, 0, 0, 10),
        true
    )
    
    -- Subtitle
    local subtitleLabel = CreateStyledLabel(
        mainFrame,
        "Administrator Management",
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0, 70),
        false
    )
    
    -- Buttons
    local buttonY = 0.25
    local buttonHeight = 0.15
    
    -- Add New Key Button
    local addKeyButton = CreateStyledButton(
        mainFrame,
        "➕ Add New Key",
        UDim2.new(0.7, 0, 0, 50),
        UDim2.new(0.15, 0, buttonY, 0)
    )
    
    addKeyButton.MouseButton1Click:Connect(function()
        CreateAddKeyGUI()
    end)
    
    -- Key List Button
    local keyListButton = CreateStyledButton(
        mainFrame,
        "📋 Key List",
        UDim2.new(0.7, 0, 0, 50),
        UDim2.new(0.15, 0, buttonY + buttonHeight, 0)
    )
    
    keyListButton.MouseButton1Click:Connect(function()
        CreateKeyListGUI()
    end)
    
    -- Load Script Button
    local loadScriptButton = CreateStyledButton(
        mainFrame,
        "🚀 Load Script",
        UDim2.new(0.7, 0, 0, 50),
        UDim2.new(0.15, 0, buttonY + buttonHeight * 2, 0)
    )
    
    loadScriptButton.MouseButton1Click:Connect(function()
        ClearGUI()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gosdinmadan-ops/creonx/main/Creon.lua", true))()
    end)
end

-- Add Key GUI
local function CreateAddKeyGUI()
    ClearGUI()
    
    local mainFrame = CreateStyledFrame(
        UDim2.new(0, 450, 0, 300),
        UDim2.new(0.5, -225, 0.5, -150),
        ScreenGui
    )
    
    -- Title
    local titleLabel = CreateStyledLabel(
        mainFrame,
        "➕ Add New Key",
        UDim2.new(1, 0, 0, 60),
        UDim2.new(0, 0, 0, 10),
        true
    )
    
    -- Instruction
    local instructionLabel = CreateStyledLabel(
        mainFrame,
        "Enter new key (24 hour access)",
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0, 0, 0, 70),
        false
    )
    
    -- Key input
    local keyTextBox = CreateStyledTextBox(
        mainFrame,
        UDim2.new(0.8, 0, 0, 40),
        UDim2.new(0.1, 0, 0.35, 0),
        "Enter new key..."
    )
    
    -- Add button
    local addButton = CreateStyledButton(
        mainFrame,
        "Add Key",
        UDim2.new(0.5, 0, 0, 45),
        UDim2.new(0.25, 0, 0.6, 0)
    )
    
    -- Back button
    local backButton = CreateStyledButton(
        mainFrame,
        "← Back",
        UDim2.new(0.3, 0, 0, 35),
        UDim2.new(0.05, 0, 0.05, 0)
    )
    
    addButton.MouseButton1Click:Connect(function()
        local key = keyTextBox.Text
        if key == "" then
            ShowNotification("Please enter a key", CHRISTMAS_COLORS.RED)
            return
        end
        
        if string.len(key) < 10 then
            ShowNotification("Key must be at least 10 characters", CHRISTMAS_COLORS.RED)
            return
        end
        
        local success, message = AddNewKey(key)
        
        if success then
            ShowNotification("New key successfully added", CHRISTMAS_COLORS.GREEN)
            task.wait(1.5)
            CreateAdminPanelGUI()
        else
            ShowNotification(message, CHRISTMAS_COLORS.RED)
        end
    end)
    
    backButton.MouseButton1Click:Connect(function()
        CreateAdminPanelGUI()
    end)
end

-- Key List GUI
local function CreateKeyListGUI()
    ClearGUI()
    
    local mainFrame = CreateStyledFrame(
        UDim2.new(0, 600, 0, 500),
        UDim2.new(0.5, -300, 0.5, -250),
        ScreenGui
    )
    
    -- Title
    local titleLabel = CreateStyledLabel(
        mainFrame,
        "📋 Active Keys List",
        UDim2.new(1, 0, 0, 60),
        UDim2.new(0, 0, 0, 10),
        true
    )
    
    -- Back button
    local backButton = CreateStyledButton(
        mainFrame,
        "← Back to Admin Panel",
        UDim2.new(0.3, 0, 0, 35),
        UDim2.new(0.05, 0, 0.05, 0)
    )
    
    backButton.MouseButton1Click:Connect(function()
        CreateAdminPanelGUI()
    end)
    
    -- Scrolling frame for keys
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    scrollingFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = CHRISTMAS_COLORS.RED
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollingFrame
    
    -- Header row
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 40)
    headerFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    headerFrame.BackgroundTransparency = 0.5
    headerFrame.BorderSizePixel = 0
    headerFrame.LayoutOrder = 0
    headerFrame.Parent = scrollingFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = headerFrame
    
    -- Key header
    local keyHeader = CreateStyledLabel(
        headerFrame,
        "🔑 Key",
        UDim2.new(0.6, 0, 1, 0),
        UDim2.new(0, 10, 0, 0),
        false
    )
    keyHeader.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Time header
    local timeHeader = CreateStyledLabel(
        headerFrame,
        "⏰ Remaining",
        UDim2.new(0.3, 0, 1, 0),
        UDim2.new(0.65, 0, 0, 0),
        false
    )
    timeHeader.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Add keys to list
    local keyCount = 0
    if keysData.keys then
        for key, expiry in pairs(keysData.keys) do
            keyCount = keyCount + 1
            
            local keyFrame = Instance.new("Frame")
            keyFrame.Size = UDim2.new(1, 0, 0, 35)
            keyFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
            keyFrame.BackgroundTransparency = 0.6
            keyFrame.BorderSizePixel = 0
            keyFrame.LayoutOrder = keyCount
            keyFrame.Parent = scrollingFrame
            
            local keyCorner = Instance.new("UICorner")
            keyCorner.CornerRadius = UDim.new(0, 6)
            keyCorner.Parent = keyFrame
            
            -- Key text (masked)
            local maskedKey = string.sub(key, 1, 8) .. "..." .. string.sub(key, -8)
            local keyLabel = CreateStyledLabel(
                keyFrame,
                "🔐 " .. maskedKey,
                UDim2.new(0.6, 0, 1, 0),
                UDim2.new(0, 10, 0, 0),
                false
            )
            keyLabel.TextXAlignment = Enum.TextXAlignment.Left
            keyLabel.Font = Enum.Font.GothamSemibold
            
            -- Remaining time
            local remainingTime = GetKeyRemainingTime(key)
            local timeLabel = CreateStyledLabel(
                keyFrame,
                remainingTime,
                UDim2.new(0.3, 0, 1, 0),
                UDim2.new(0.65, 0, 0, 0),
                false
            )
            timeLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            -- Color code based on remaining time
            if remainingTime == "Expired" then
                timeLabel.TextColor3 = CHRISTMAS_COLORS.RED
            elseif remainingTime ~= "N/A" and tonumber(string.sub(remainingTime, 1, 2)) < 5 then
                timeLabel.TextColor3 = CHRISTMAS_COLORS.GOLD
            else
                timeLabel.TextColor3 = CHRISTMAS_COLORS.GREEN
            end
        end
    end
    
    -- Add blacklist section
    if keysData.blacklist and #keysData.blacklist > 0 then
        local separator = Instance.new("Frame")
        separator.Size = UDim2.new(1, 0, 0, 2)
        separator.BackgroundColor3 = CHRISTMAS_COLORS.RED
        separator.BackgroundTransparency = 0.5
        separator.BorderSizePixel = 0
        separator.LayoutOrder = 1000
        separator.Parent = scrollingFrame
        
        local blacklistHeader = Instance.new("Frame")
        blacklistHeader.Size = UDim2.new(1, 0, 0, 40)
        blacklistHeader.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        blacklistHeader.BackgroundTransparency = 0.5
        blacklistHeader.BorderSizePixel = 0
        blacklistHeader.LayoutOrder = 1001
        blacklistHeader.Parent = scrollingFrame
        
        local blacklistCorner = Instance.new("UICorner")
        blacklistCorner.CornerRadius = UDim.new(0, 6)
        blacklistCorner.Parent = blacklistHeader
        
        local blacklistTitle = CreateStyledLabel(
            blacklistHeader,
            "🚫 Blacklisted Keys",
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            false
        )
        blacklistTitle.TextColor3 = CHRISTMAS_COLORS.RED
        
        for _, blacklistedKey in pairs(keysData.blacklist) do
            keyCount = keyCount + 1
            
            local blacklistedFrame = Instance.new("Frame")
            blacklistedFrame.Size = UDim2.new(1, 0, 0, 35)
            blacklistedFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
            blacklistedFrame.BackgroundTransparency = 0.6
            blacklistedFrame.BorderSizePixel = 0
            blacklistedFrame.LayoutOrder = 1001 + keyCount
            blacklistedFrame.Parent = scrollingFrame
            
            local blacklistedCorner = Instance.new("UICorner")
            blacklistedCorner.CornerRadius = UDim.new(0, 6)
            blacklistedCorner.Parent = blacklistedFrame
            
            local maskedKey = string.sub(blacklistedKey, 1, 8) .. "..." .. string.sub(blacklistedKey, -8)
            local blacklistedLabel = CreateStyledLabel(
                blacklistedFrame,
                "🚫 " .. maskedKey,
                UDim2.new(1, 0, 1, 0),
                UDim2.new(0, 10, 0, 0),
                false
            )
            blacklistedLabel.TextXAlignment = Enum.TextXAlignment.Left
            blacklistedLabel.TextColor3 = CHRISTMAS_COLORS.RED
        end
    end
    
    -- No keys message
    if keyCount == 0 then
        local noKeysFrame = Instance.new("Frame")
        noKeysFrame.Size = UDim2.new(1, 0, 0, 100)
        noKeysFrame.BackgroundTransparency = 1
        noKeysFrame.LayoutOrder = 1
        noKeysFrame.Parent = scrollingFrame
        
        local noKeysLabel = CreateStyledLabel(
            noKeysFrame,
            "No keys available yet",
            UDim2.new(1, 0, 1, 0),
            UDim2.new(0, 0, 0, 0),
            false
        )
        noKeysLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    
    -- Update canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
end

-- Start with key verification GUI
CreateKeyVerificationGUI()
