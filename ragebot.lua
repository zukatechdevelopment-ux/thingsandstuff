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
ScreenGui.Name = "RageBotMenuGUI"
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
TitleLabel.Text = "Rage Bot"
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
AimbotPage.Name = "RageBotPage" -- Renamed for clarity
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

-- ========== Rage Bot Page ==========
do
    -- [FIX] The function `createPage` did not exist. We now use the `AimbotPage` frame created above.
    local page = AimbotPage

    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, -20, 0, 36)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,80,80)
    title.Font = Enum.Font.Code
    title.TextSize = 22
    title.Text = "Rage Bot (PvP Autofarm)"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center

    local desc = Instance.new("TextLabel", page)
    desc.Size = UDim2.new(1, -20, 0, 22)
    desc.Position = UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(220,180,180)
    desc.Font = Enum.Font.Code
    desc.TextSize = 15
    desc.Text = "Automatically hovers behind and attacks selected players."
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Center

    -- Player list
    local playerListLabel = Instance.new("TextLabel", page)
    playerListLabel.Size = UDim2.new(0, 120, 0, 22)
    playerListLabel.Position = UDim2.new(0, 20, 0, 90)
    playerListLabel.BackgroundTransparency = 1
    playerListLabel.Text = "Player List:"
    playerListLabel.TextColor3 = Color3.fromRGB(255,180,180)
    playerListLabel.Font = Enum.Font.Code
    playerListLabel.TextSize = 15
    playerListLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerListLabel.TextYAlignment = Enum.TextYAlignment.Center

    local playerDropdown = Instance.new("TextButton", page)
    playerDropdown.Size = UDim2.new(0, 180, 0, 28)
    playerDropdown.Position = UDim2.new(0, 140, 0, 90)
    playerDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
    playerDropdown.TextColor3 = Color3.fromRGB(255,255,255)
    playerDropdown.Font = Enum.Font.Code
    playerDropdown.TextSize = 15
    playerDropdown.Text = "Select Player"
    makeUICorner(playerDropdown, 6)

    local autoCycleToggle = Instance.new("TextButton", page)
    autoCycleToggle.Size = UDim2.new(0, 160, 0, 28)
    autoCycleToggle.Position = UDim2.new(0, 340, 0, 90)
    autoCycleToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    autoCycleToggle.TextColor3 = Color3.fromRGB(255,255,255)
    autoCycleToggle.Font = Enum.Font.Code
    autoCycleToggle.TextSize = 15
    autoCycleToggle.Text = "Auto Cycle: OFF"
    makeUICorner(autoCycleToggle, 6)

    local selectedPlayer = nil
    local playerNames = {}
    local playerIdx = 1
    local autoCycleEnabled = false

    local function refreshPlayerList()
        playerNames = {}
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then table.insert(playerNames, plr.Name) end
        end
        if #playerNames > 0 then
            playerIdx = math.clamp(playerIdx, 1, #playerNames)
            selectedPlayer = Players:FindFirstChild(playerNames[playerIdx])
            playerDropdown.Text = "Select Player: " .. selectedPlayer.Name
        else
            selectedPlayer = nil
            playerDropdown.Text = "No Players"
        end
    end

    playerDropdown.MouseButton1Click:Connect(function()
        if #playerNames > 0 then
            playerIdx = playerIdx + 1
            if playerIdx > #playerNames then playerIdx = 1 end
            selectedPlayer = Players:FindFirstChild(playerNames[playerIdx])
            playerDropdown.Text = "Select Player: " .. selectedPlayer.Name
        end
    end)

    autoCycleToggle.MouseButton1Click:Connect(function()
        autoCycleEnabled = not autoCycleEnabled
        autoCycleToggle.Text = "Auto Cycle: " .. (autoCycleEnabled and "ON" or "OFF")
    end)

    refreshPlayerList()
    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(refreshPlayerList)

    -- Auto cycle logic
    -- [IMPROVEMENT] Used task.spawn for better performance and modern practice
    task.spawn(function()
        while true do
            task.wait(3) -- Change interval as needed
            if autoCycleEnabled and #playerNames > 1 then
                playerIdx = playerIdx + 1
                if playerIdx > #playerNames then playerIdx = 1 end
                selectedPlayer = Players:FindFirstChild(playerNames[playerIdx])
                playerDropdown.Text = "Select Player: " .. selectedPlayer.Name
            end
        end
    end)

    -- Rage Bot toggles
    local rageToggle = Instance.new("TextButton", page)
    rageToggle.Size = UDim2.new(0, 160, 0, 32)
    rageToggle.Position = UDim2.new(0, 20, 0, 130)
    rageToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
    rageToggle.TextColor3 = Color3.fromRGB(255,255,255)
    rageToggle.Font = Enum.Font.Code
    rageToggle.TextSize = 16
    rageToggle.Text = "Rage Bot: OFF"
    makeUICorner(rageToggle, 6)

    local rageEnabled = false
    rageToggle.MouseButton1Click:Connect(function()
        rageEnabled = not rageEnabled
        rageToggle.Text = "Rage Bot: " .. (rageEnabled and "ON" or "OFF")
    end)

    -- Hover distance
    local hoverLabel = Instance.new("TextLabel", page)
    hoverLabel.Size = UDim2.new(0, 120, 0, 22)
    hoverLabel.Position = UDim2.new(0, 20, 0, 170)
    hoverLabel.BackgroundTransparency = 1
    hoverLabel.Text = "Hover Distance:"
    hoverLabel.TextColor3 = Color3.fromRGB(255,180,180)
    hoverLabel.Font = Enum.Font.Code
    hoverLabel.TextSize = 15
    hoverLabel.TextXAlignment = Enum.TextXAlignment.Left
    hoverLabel.TextYAlignment = Enum.TextYAlignment.Center

    local hoverBox = Instance.new("TextBox", page)
    hoverBox.Size = UDim2.new(0, 80, 0, 22)
    hoverBox.Position = UDim2.new(0, 140, 0, 170)
    hoverBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    hoverBox.TextColor3 = Color3.fromRGB(255,255,255)
    hoverBox.Font = Enum.Font.Code
    hoverBox.TextSize = 15
    hoverBox.Text = "6"
    hoverBox.PlaceholderText = "Studs..."
    makeUICorner(hoverBox, 6)
    local hoverDist = 6
    hoverBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local val = tonumber(hoverBox.Text)
            if val and val >= 2 and val <= 20 then
                hoverDist = val
                hoverBox.Text = tostring(hoverDist)
            else
                hoverBox.Text = tostring(hoverDist)
            end
        end
    end)

    -- Rage Bot logic
    RunService.RenderStepped:Connect(function()
        if rageEnabled and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("Humanoid") and myChar.Humanoid.Health > 0 then
                local targetHRP = selectedPlayer.Character.HumanoidRootPart
                local myHRP = myChar.HumanoidRootPart
                
                -- [FIX] Simplified CFrame logic to a single, efficient line.
                -- This positions your character behind the target and makes you look at them in one operation.
                local backVec = -targetHRP.CFrame.LookVector
                local behindPos = targetHRP.Position + (backVec * hoverDist)
                myHRP.CFrame = CFrame.lookAt(behindPos, targetHRP.Position)

                -- Attack cooldown to prevent bugs
                if not page._lastAttack or tick() - page._lastAttack > 0.05 then -- ~20 attacks/sec
                    page._lastAttack = tick()
                    local tool = myChar:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        pcall(function()
                            -- Simulate holding down attack or spam clicking
                            tool:Activate()
                            task.wait() -- Use a small, reliable wait
                            tool:Deactivate()
                        end)
                    end
                end
            end
        end
    end)
end
