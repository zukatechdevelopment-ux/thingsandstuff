-- =================================================================
-- Services & Globals
-- =================================================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =================================================================
-- Helper Functions
-- =================================================================
-- Utility to easily add rounded corners to UI elements
local function makeUICorner(element, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 6)
    corner.Parent = element
end

-- =================================================================
-- Draggable GUI Creation
-- =================================================================
-- Main container for the UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotMenuGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- The main window frame that holds everything
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 600, 0, 350) -- Adjusted size to fit all content
MainWindow.Position = UDim2.new(0.5, -300, 0.5, -175) -- Centered
MainWindow.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Draggable = false -- We will handle dragging manually
MainWindow.Parent = ScreenGui
makeUICorner(MainWindow, 8)

-- Top bar for title and dragging
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainWindow
makeUICorner(TopBar, 8)
local topCorner = TopBar:FindFirstChild("UICorner")
if topCorner then -- Only round the top corners of the top bar
    topCorner.CornerRadius = UDim.new(0,8)
end

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0) -- Leave space for buttons
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.Code
TitleLabel.Text = "Gaming Chair"
TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -28, 0.5, -12)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
CloseButton.Font = Enum.Font.Code
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Parent = TopBar
makeUICorner(CloseButton, 6)

-- Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -56, 0.5, -12)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
MinimizeButton.Font = Enum.Font.Code
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14
MinimizeButton.Parent = TopBar
makeUICorner(MinimizeButton, 6)

-- Content page to hold all the settings
local AimbotPage = Instance.new("Frame")
AimbotPage.Name = "AimbotPage"
AimbotPage.Size = UDim2.new(1, 0, 1, -30)
AimbotPage.Position = UDim2.new(0, 0, 0, 30)
AimbotPage.BackgroundTransparency = 1
AimbotPage.Parent = MainWindow

-- =================================================================
-- Window Interactivity Logic (Drag, Close, Minimize)
-- =================================================================
local isDragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPosition = MainWindow.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if isDragging then
            local delta = input.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    AimbotPage.Visible = not isMinimized
    if isMinimized then
        MainWindow.Size = UDim2.new(0, 200, 0, 30) -- Shrink to just the top bar
        MinimizeButton.Text = "+"
    else
        MainWindow.Size = UDim2.new(0, 600, 0, 350) -- Restore to original size
        MinimizeButton.Text = "-"
    end
end)

-- =================================================================
-- Aimbot Page Content
-- =================================================================
do
    local page = AimbotPage
    
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200,220,255)
    title.Font = Enum.Font.Code
    title.TextSize = 22
    title.Text = "Aimbot Settings"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center

    local desc = Instance.new("TextLabel", page)
    desc.Size = UDim2.new(1, -20, 0, 22)
    desc.Position = UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(180,180,200)
    desc.Font = Enum.Font.Code
    desc.TextSize = 15
    desc.Text = "Configure aimbot toggle and aim part."
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Center

    local toggleKeyLabel = Instance.new("TextLabel", page)
    toggleKeyLabel.Size = UDim2.new(0, 120, 0, 22)
    toggleKeyLabel.Position = UDim2.new(0, 20, 0, 90)
    toggleKeyLabel.BackgroundTransparency = 1
    toggleKeyLabel.Text = "Toggle Key:"
    toggleKeyLabel.TextColor3 = Color3.fromRGB(180,220,255)
    toggleKeyLabel.Font = Enum.Font.Code
    toggleKeyLabel.TextSize = 15
    toggleKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleKeyLabel.TextYAlignment = Enum.TextYAlignment.Center

    local toggleKeyBox = Instance.new("TextBox", page)
    toggleKeyBox.Size = UDim2.new(0, 100, 0, 22)
    toggleKeyBox.Position = UDim2.new(0, 140, 0, 90)
    toggleKeyBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    toggleKeyBox.TextColor3 = Color3.fromRGB(255,255,255)
    toggleKeyBox.Font = Enum.Font.Code
    toggleKeyBox.TextSize = 15
    toggleKeyBox.Text = "MouseButton2" -- CHANGED
    toggleKeyBox.PlaceholderText = "Key..."
    makeUICorner(toggleKeyBox, 6)

    local partLabel = Instance.new("TextLabel", page)
    partLabel.Size = UDim2.new(0, 120, 0, 22)
    partLabel.Position = UDim2.new(0, 20, 0, 130)
    partLabel.BackgroundTransparency = 1
    partLabel.Text = "Aim Part:"
    partLabel.TextColor3 = Color3.fromRGB(180,220,255)
    partLabel.Font = Enum.Font.Code
    partLabel.TextSize = 15
    partLabel.TextXAlignment = Enum.TextXAlignment.Left
    partLabel.TextYAlignment = Enum.TextYAlignment.Center

    local partDropdown = Instance.new("TextButton", page)
    partDropdown.Size = UDim2.new(0, 120, 0, 22)
    partDropdown.Position = UDim2.new(0, 140, 0, 130)
    partDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
    partDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    partDropdown.Font = Enum.Font.Code
    partDropdown.TextSize = 15
    partDropdown.Text = "Head"
    makeUICorner(partDropdown, 6)

    local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
    local dropdownOpen = false
    local dropdownFrame

    partDropdown.MouseButton1Click:Connect(function()
        if dropdownOpen then
            if dropdownFrame then dropdownFrame:Destroy() end
            dropdownOpen = false
            return
        end
        dropdownOpen = true
        dropdownFrame = Instance.new("Frame", page)
        dropdownFrame.Size = UDim2.new(0, 120, 0, #parts * 22)
        dropdownFrame.Position = UDim2.new(0, 140, 0, 152)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        dropdownFrame.BorderSizePixel = 0
        makeUICorner(dropdownFrame, 6)
        for i, part in ipairs(parts) do
            local btn = Instance.new("TextButton", dropdownFrame)
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*22)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 15
            btn.Text = part
            btn.AutoButtonColor = true
            makeUICorner(btn, 6)
            btn.MouseButton1Click:Connect(function()
                partDropdown.Text = part
                dropdownFrame:Destroy()
                dropdownOpen = false
            end)
        end
    end)

    local statusLabel = Instance.new("TextLabel", page)
    statusLabel.Size = UDim2.new(1, -20, 0, 22)
    statusLabel.Position = UDim2.new(0, 10, 0, 180)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(180,220,180)
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextSize = 15
    statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center

    local selectLabel = Instance.new("TextLabel", page)
    selectLabel.Size = UDim2.new(1, -20, 0, 22)
    selectLabel.Position = UDim2.new(0, 10, 0, 210)
    selectLabel.BackgroundTransparency = 1
    selectLabel.TextColor3 = Color3.fromRGB(220,220,180)
    selectLabel.Font = Enum.Font.Code
    selectLabel.TextSize = 15
    selectLabel.Text = "Press V to select/deselect any target under mouse."
    selectLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectLabel.TextYAlignment = Enum.TextYAlignment.Center

    local selectedTarget = nil
    local selectedPlayerTarget = nil
    local selectedNpcTarget = nil
    local selectedPart = nil
    local playerTargetEnabled = false

    local playerListLabel = Instance.new("TextLabel", page)
    playerListLabel.Size = UDim2.new(0, 120, 0, 22)
    playerListLabel.Position = UDim2.new(0, 280, 0, 90)
    playerListLabel.BackgroundTransparency = 1
    playerListLabel.Text = "Player List:"
    playerListLabel.TextColor3 = Color3.fromRGB(180,220,255)
    playerListLabel.Font = Enum.Font.Code
    playerListLabel.TextSize = 15
    playerListLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerListLabel.TextYAlignment = Enum.TextYAlignment.Center

    local playerDropdown = Instance.new("TextButton", page)
    playerDropdown.Size = UDim2.new(0, 160, 0, 22)
    playerDropdown.Position = UDim2.new(0, 400, 0, 90)
    playerDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
    playerDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    playerDropdown.Font = Enum.Font.Code
    playerDropdown.TextSize = 15
    playerDropdown.Text = "None"
    makeUICorner(playerDropdown, 6)

    local playerDropdownOpen = false
    local playerDropdownFrame

    local function buildPlayerDropdownFrame()
        if playerDropdownFrame then playerDropdownFrame:Destroy() playerDropdownFrame = nil end
        local playersList = Players:GetPlayers()
        playerDropdownFrame = Instance.new("Frame", page)
        playerDropdownFrame.Size = UDim2.new(0, 160, 0, (#playersList) * 22)
        playerDropdownFrame.Position = UDim2.new(0, 400, 0, 112)
        playerDropdownFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        playerDropdownFrame.BorderSizePixel = 0
        makeUICorner(playerDropdownFrame, 6)
        for i, plr in ipairs(playersList) do
            local btn = Instance.new("TextButton", playerDropdownFrame)
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.Position = UDim2.new(0, 0, 0, (i-1)*22)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 15
            btn.Text = plr.Name
            btn.AutoButtonColor = true
            makeUICorner(btn, 6)
            btn.MouseButton1Click:Connect(function()
                selectedPlayerTarget = plr
                playerDropdown.Text = plr.Name
                if playerDropdownFrame then playerDropdownFrame:Destroy() end
                playerDropdownOpen = false
                if playerTargetEnabled then
                    statusLabel.Text = "Aimbot: Will target " .. plr.Name
                end
            end)
        end
    end

    local targetPlayerToggle = Instance.new("TextButton", page)
    targetPlayerToggle.Size = UDim2.new(0, 160, 0, 32)
    targetPlayerToggle.Position = UDim2.new(0, 400, 0, 122)
    targetPlayerToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    targetPlayerToggle.TextColor3 = Color3.fromRGB(255,255,255)
    targetPlayerToggle.Font = Enum.Font.Code
    targetPlayerToggle.TextSize = 15
    targetPlayerToggle.Text = "Target Selected: OFF"
    makeUICorner(targetPlayerToggle, 6)
    targetPlayerToggle.MouseButton1Click:Connect(function()
        playerTargetEnabled = not playerTargetEnabled
        targetPlayerToggle.Text = "Target Selected: " .. (playerTargetEnabled and "ON" or "OFF")
        if not playerTargetEnabled then
            statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
        elseif selectedPlayerTarget then
             statusLabel.Text = "Aimbot: Will target " .. selectedPlayerTarget.Name
        end
    end)

    playerDropdown.MouseButton1Click:Connect(function()
        if playerDropdownOpen then
            if playerDropdownFrame then playerDropdownFrame:Destroy() end
            playerDropdownOpen = false
            return
        end
        playerDropdownOpen = true
        buildPlayerDropdownFrame()
    end)

    Players.PlayerAdded:Connect(function()
        if playerDropdownOpen then buildPlayerDropdownFrame() end
    end)
    Players.PlayerRemoving:Connect(function(plr)
        if selectedPlayerTarget == plr then
            selectedPlayerTarget = nil
            playerDropdown.Text = "None"
            if playerTargetEnabled then
                playerTargetEnabled = false
                targetPlayerToggle.Text = "Target Selected: OFF"
            end
        end
        if playerDropdownOpen then buildPlayerDropdownFrame() end
    end)

    local aiming = false
    local currentTarget = nil
    local silentAimEnabled = false
    local espConnections = {}

    local function clearAllESP()
        for _, conn in pairs(espConnections) do
            if conn then conn:Disconnect() end
        end
        espConnections = {}
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BoxHandleAdornment") and (v.Name == "AimbotESP" or v.Name == "SelectedESP") then
                v:Destroy()
            end
        end
    end
    
    local function drawESP(part, color, name)
        if not part or not part.Parent then return end
        
        local espBox = Instance.new("BoxHandleAdornment")
        espBox.Name = name
        espBox.Adornee = part
        espBox.AlwaysOnTop = true
        espBox.ZIndex = 10
        espBox.Size = part.Size
        espBox.Color3 = color
        espBox.Transparency = 0.4
        espBox.Parent = part
        
        local conn = RunService.RenderStepped:Connect(function()
            if part and part.Parent then
                espBox.Size = part.Size
                espBox.Adornee = part
            else
                espBox:Destroy()
                if espConnections[part] then
                    espConnections[part]:Disconnect()
                    espConnections[part] = nil
                end
            end
        end)
        espConnections[part] = conn
        return espBox
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.V then
            clearAllESP()
            if selectedTarget or selectedPlayerTarget or selectedNpcTarget or selectedPart then
                selectedTarget = nil
                selectedPlayerTarget = nil
                selectedNpcTarget = nil
                selectedPart = nil
                currentTarget = nil
                playerDropdown.Text = "None"
                statusLabel.Text = "Selection cleared."
            else
                local mouse = LocalPlayer:GetMouse()
                local target = mouse.Target
                if target then
                    local modelAncestor = target:FindFirstAncestorOfClass("Model")
                    if modelAncestor and modelAncestor:FindFirstChildOfClass("Humanoid") then
                        local plr = Players:GetPlayerFromCharacter(modelAncestor)
                        if plr then
                            selectedPlayerTarget = plr
                            playerDropdown.Text = plr.Name
                            statusLabel.Text = "Selected player: " .. plr.Name
                            selectedPart = plr.Character and plr.Character:FindFirstChild(partDropdown.Text)
                        else
                            selectedNpcTarget = modelAncestor
                            selectedPart = modelAncestor:FindFirstChild(partDropdown.Text) or target
                            statusLabel.Text = "Selected NPC: " .. (modelAncestor.Name or "Unnamed")
                        end
                    else
                        selectedPart = target
                        statusLabel.Text = "Selected part: " .. (target.Name or "Unnamed")
                    end
                else
                    statusLabel.Text = "No target under mouse."
                end
            end
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local key = toggleKeyBox.Text:upper()
        if (key == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2) or -- CHANGED
           (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name:upper() == key) then
            aiming = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        local key = toggleKeyBox.Text:upper()
        if (key == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2) or -- CHANGED
           (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name:upper() == key) then
            aiming = false
            clearAllESP()
        end
    end)

    local function getClosestPlayerToMouse()
        local mousePos = UserInputService:GetMouseLocation()
        local minDist = math.huge
        local closestPlayer = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(partDropdown.Text) then
                local part = plr.Character[partDropdown.Text]
                local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestPlayer = plr
                    end
                end
            end
        end
        return closestPlayer
    end

    RunService.RenderStepped:Connect(function()
        clearAllESP()

        local aimPart = nil
        local targetPlayer = nil

        if playerTargetEnabled and selectedPlayerTarget and selectedPlayerTarget.Character then
            targetPlayer = selectedPlayerTarget
            aimPart = targetPlayer.Character:FindFirstChild(partDropdown.Text)
        elseif selectedPart then
            aimPart = selectedPart
            local model = aimPart:FindFirstAncestorOfClass("Model")
            if model then targetPlayer = Players:GetPlayerFromCharacter(model) end
        elseif aiming then
            targetPlayer = getClosestPlayerToMouse()
            if targetPlayer and targetPlayer.Character then
                aimPart = targetPlayer.Character:FindFirstChild(partDropdown.Text)
            end
        end

        if selectedPart and selectedPart.Parent then
             drawESP(selectedPart, Color3.fromRGB(90, 170, 255), "SelectedESP")
        end

        if aiming and aimPart then
            drawESP(aimPart, Color3.fromRGB(255, 80, 80), "AimbotESP")

            -- =================================================================
            -- Accurate Prediction Logic
            -- =================================================================
            local cam = workspace.CurrentCamera
            -- Adjust this value based on the weapon's bullet speed for best results
            local projectileSpeed = 2000 -- Studs per second
            
            -- 1. Calculate the time it will take for a projectile to reach the target's current position
            local distance = (cam.CFrame.Position - aimPart.Position).Magnitude
            local timeToTarget = distance / projectileSpeed
            
            -- 2. Get the target's current velocity (how fast they are moving)
            local targetVelocity = aimPart.AssemblyLinearVelocity
            
            -- 3. Predict the target's future position
            -- Formula: Future Position = Current Position + (Velocity * Time)
            local predictedPosition = aimPart.Position + (targetVelocity * timeToTarget)
            -- =================================================================

            if silentAimEnabled then
                getgenv().ZukaSilentAimTarget = predictedPosition
            else
                cam.CFrame = CFrame.new(cam.CFrame.Position, predictedPosition)
            end
            statusLabel.Text = "Aimbot: Targeting " .. (targetPlayer and targetPlayer.Name or aimPart.Name)
        elseif aiming then
            statusLabel.Text = "Aimbot: No target found"
        elseif not aiming and not selectedPart then
            statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
        end
    end)

    local silentAimToggle = Instance.new("TextButton", page)
    silentAimToggle.Size = UDim2.new(0, 180, 0, 32)
    silentAimToggle.Position = UDim2.new(0, 45, 0, 250)
    silentAimToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    silentAimToggle.TextColor3 = Color3.fromRGB(255,255,255)
    silentAimToggle.Font = Enum.Font.Code
    silentAimToggle.TextSize = 15
    silentAimToggle.Text = "Silent Aim: OFF"
    makeUICorner(silentAimToggle, 6)
    silentAimToggle.MouseButton1Click:Connect(function()
        silentAimEnabled = not silentAimEnabled
        silentAimToggle.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF")
    end)
end