-- =================================================================
-- Services & Globals
-- =================================================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- =================================================================
-- Helper Functions
-- =================================================================
local function makeUICorner(element, cornerRadius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 6)
    corner.Parent = element
end

-- =================================================================
-- Draggable GUI Creation
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotMenuGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 600, 0, 350)
MainWindow.Position = UDim2.new(0.5, -300, 0.5, -175)
MainWindow.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Draggable = false
MainWindow.Parent = ScreenGui
makeUICorner(MainWindow, 8)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainWindow
makeUICorner(TopBar, 8)
local topCorner = TopBar:FindFirstChild("UICorner")
if topCorner then
    topCorner.CornerRadius = UDim.new(0,8)
end

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.Code
TitleLabel.Text = "Gaming Chair"
TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

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

local AimbotPage = Instance.new("Frame")
AimbotPage.Name = "AimbotPage"
AimbotPage.Size = UDim2.new(1, 0, 1, -30)
AimbotPage.Position = UDim2.new(0, 0, 0, 30)
AimbotPage.BackgroundTransparency = 1
AimbotPage.Parent = MainWindow

-- =================================================================
-- Window Interactivity Logic
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
            MainWindow.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    AimbotPage.Visible = not isMinimized
    if isMinimized then
        MainWindow.Size = UDim2.new(0, 200, 0, 30)
        MinimizeButton.Text = "+"
    else
        MainWindow.Size = UDim2.new(0, 600, 0, 350)
        MinimizeButton.Text = "-"
    end
end)

-- =================================================================
-- Aimbot Page Content
-- =================================================================
do
    local page = AimbotPage
    
    -- Region: UI Creation
    local title = Instance.new("TextLabel", page)
    title.Size, title.Position = UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency, title.TextColor3 = 1, Color3.fromRGB(200,220,255)
    title.Font, title.TextSize, title.Text = Enum.Font.Code, 22, "Aimbot Settings"
    title.TextXAlignment, title.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local desc = Instance.new("TextLabel", page)
    desc.Size, desc.Position = UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency, desc.TextColor3 = 1, Color3.fromRGB(180,180,200)
    desc.Font, desc.TextSize, desc.Text = Enum.Font.Code, 15, "Configure aimbot toggle and aim part."
    desc.TextXAlignment, desc.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local toggleKeyLabel = Instance.new("TextLabel", page)
    toggleKeyLabel.Size, toggleKeyLabel.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 20, 0, 90)
    toggleKeyLabel.BackgroundTransparency, toggleKeyLabel.Text = 1, "Toggle Key:"
    toggleKeyLabel.TextColor3, toggleKeyLabel.Font, toggleKeyLabel.TextSize = Color3.fromRGB(180,220,255), Enum.Font.Code, 15
    toggleKeyLabel.TextXAlignment, toggleKeyLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local toggleKeyBox = Instance.new("TextBox", page)
    toggleKeyBox.Size, toggleKeyBox.Position = UDim2.new(0, 100, 0, 22), UDim2.new(0, 140, 0, 90)
    toggleKeyBox.BackgroundColor3, toggleKeyBox.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    toggleKeyBox.Font, toggleKeyBox.TextSize, toggleKeyBox.Text = Enum.Font.Code, 15, "MouseButton2"
    makeUICorner(toggleKeyBox, 6)

    local partLabel = Instance.new("TextLabel", page)
    partLabel.Size, partLabel.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 20, 0, 130)
    partLabel.BackgroundTransparency, partLabel.Text = 1, "Aim Part:"
    partLabel.TextColor3, partLabel.Font, partLabel.TextSize = Color3.fromRGB(180,220,255), Enum.Font.Code, 15
    partLabel.TextXAlignment, partLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local partDropdown = Instance.new("TextButton", page)
    partDropdown.Size, partDropdown.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 140, 0, 130)
    partDropdown.BackgroundColor3, partDropdown.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    partDropdown.Font, partDropdown.TextSize, partDropdown.Text = Enum.Font.Code, 15, "Head"
    makeUICorner(partDropdown, 6)

    local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}
    local dropdownOpen, dropdownFrame = false, nil
    partDropdown.MouseButton1Click:Connect(function()
        if dropdownOpen then if dropdownFrame then dropdownFrame:Destroy() end dropdownOpen = false; return end
        dropdownOpen = true
        dropdownFrame = Instance.new("Frame", page)
        dropdownFrame.Size, dropdownFrame.Position = UDim2.new(0, 120, 0, #parts * 22), UDim2.new(0, 140, 0, 152)
        dropdownFrame.BackgroundColor3, dropdownFrame.BorderSizePixel = Color3.fromRGB(30,30,30), 0
        makeUICorner(dropdownFrame, 6)
        for i, part in ipairs(parts) do
            local btn = Instance.new("TextButton", dropdownFrame)
            btn.Size, btn.Position = UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, (i-1)*22)
            btn.BackgroundColor3, btn.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
            btn.Font, btn.TextSize, btn.Text = Enum.Font.Code, 15, part
            makeUICorner(btn, 6)
            btn.MouseButton1Click:Connect(function() partDropdown.Text = part; if dropdownFrame then dropdownFrame:Destroy() end; dropdownOpen = false end)
        end
    end)

    local statusLabel = Instance.new("TextLabel", page)
    statusLabel.Size, statusLabel.Position = UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 180)
    statusLabel.BackgroundTransparency, statusLabel.TextColor3 = 1, Color3.fromRGB(180,220,180)
    statusLabel.Font, statusLabel.TextSize = Enum.Font.Code, 15
    statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
    statusLabel.TextXAlignment, statusLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local selectLabel = Instance.new("TextLabel", page)
    selectLabel.Size, selectLabel.Position = UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 210)
    selectLabel.BackgroundTransparency, selectLabel.TextColor3 = 1, Color3.fromRGB(220,220,180)
    selectLabel.Font, selectLabel.TextSize = Enum.Font.Code, 15
    selectLabel.Text = "Press V to select/deselect any target under mouse."
    selectLabel.TextXAlignment, selectLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local playerListLabel = Instance.new("TextLabel", page)
    playerListLabel.Size, playerListLabel.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 280, 0, 90)
    playerListLabel.BackgroundTransparency, playerListLabel.Text = 1, "Player List:"
    playerListLabel.TextColor3, playerListLabel.Font, playerListLabel.TextSize = Color3.fromRGB(180,220,255), Enum.Font.Code, 15
    playerListLabel.TextXAlignment, playerListLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local playerDropdown = Instance.new("TextButton", page)
    playerDropdown.Size, playerDropdown.Position = UDim2.new(0, 160, 0, 22), UDim2.new(0, 400, 0, 90)
    playerDropdown.BackgroundColor3, playerDropdown.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    playerDropdown.Font, playerDropdown.TextSize, playerDropdown.Text = Enum.Font.Code, 15, "None"
    makeUICorner(playerDropdown, 6)
    
    local targetPlayerToggle = Instance.new("TextButton", page)
    targetPlayerToggle.Size, targetPlayerToggle.Position = UDim2.new(0, 160, 0, 32), UDim2.new(0, 400, 0, 122)
    targetPlayerToggle.BackgroundColor3, targetPlayerToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    targetPlayerToggle.Font, targetPlayerToggle.TextSize, targetPlayerToggle.Text = Enum.Font.Code, 15, "Target Selected: OFF"
    makeUICorner(targetPlayerToggle, 6)
    -- EndRegion

    -- Region: Aimbot Variables & State
    local fovRadius = 150 -- [NEW] Default FOV radius
    local selectedPlayerTarget, selectedNpcTarget, selectedPart = nil, nil, nil
    local playerTargetEnabled = false
    local aiming = false
    local silentAimEnabled = false
    local ignoreTeamEnabled = false
    local wallCheckEnabled = true
    local wallCheckParams = RaycastParams.new()
    wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude
    local activeESPs = {}
    -- EndRegion
    
    -- Region: [NEW] FOV Circle and Slider
    local FovCircle = Drawing.new("Circle")
    FovCircle.Visible = false
    FovCircle.Thickness = 1
    FovCircle.NumSides = 64
    FovCircle.Color = Color3.fromRGB(255, 255, 255)
    FovCircle.Transparency = 0.5
    FovCircle.Filled = false
    
    local fovLabel = Instance.new("TextLabel", page)
    fovLabel.Size, fovLabel.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 20, 0, 155)
    fovLabel.BackgroundTransparency, fovLabel.Text = 1, "FOV Radius:"
    fovLabel.TextColor3, fovLabel.Font, fovLabel.TextSize = Color3.fromRGB(180,220,255), Enum.Font.Code, 15
    fovLabel.TextXAlignment, fovLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local fovValueLabel = Instance.new("TextLabel", page)
    fovValueLabel.Size, fovValueLabel.Position = UDim2.new(0, 50, 0, 22), UDim2.new(0, 390, 0, 155)
    fovValueLabel.BackgroundTransparency, fovValueLabel.TextColor3 = 1, Color3.fromRGB(255,255,255)
    fovValueLabel.Font, fovValueLabel.TextSize = Enum.Font.Code, 15
    fovValueLabel.Text = tostring(fovRadius) .. "px"
    fovValueLabel.TextXAlignment, fovValueLabel.TextYAlignment = Enum.TextXAlignment.Right, Enum.TextYAlignment.Center

    local sliderTrack = Instance.new("Frame", page)
    sliderTrack.Size, sliderTrack.Position = UDim2.new(0, 300, 0, 4), UDim2.new(0, 140, 0, 164)
    sliderTrack.BackgroundColor3, sliderTrack.BorderSizePixel = Color3.fromRGB(20,20,30), 0
    makeUICorner(sliderTrack, 2)
    
    local sliderHandle = Instance.new("TextButton", sliderTrack)
    sliderHandle.Size, sliderHandle.Position = UDim2.new(0, 12, 0, 12), UDim2.new(0, 0, 0.5, -6)
    sliderHandle.BackgroundColor3, sliderHandle.BorderSizePixel = Color3.fromRGB(180, 220, 255), 0
    sliderHandle.Text = ""
    makeUICorner(sliderHandle, 6)

    local minFov, maxFov = 50, 500
    local trackWidth = sliderTrack.AbsoluteSize.X
    
    local function updateFovFromHandlePosition()
        local handleX = sliderHandle.Position.X.Offset
        local ratio = math.clamp(handleX / (trackWidth - sliderHandle.AbsoluteSize.X), 0, 1)
        fovRadius = minFov + (maxFov - minFov) * ratio
        fovValueLabel.Text = tostring(math.floor(fovRadius)) .. "px"
        FovCircle.Radius = fovRadius
    end
    
    local function updateHandleFromFovValue()
        local ratio = (fovRadius - minFov) / (maxFov - minFov)
        local handleX = ratio * (trackWidth - sliderHandle.AbsoluteSize.X)
        sliderHandle.Position = UDim2.new(0, handleX, 0.5, -6)
    end
    
    -- Set initial handle position
    updateHandleFromFovValue()

    local isDraggingSlider = false
    sliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingSlider = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingSlider = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = UserInputService:GetMouseLocation().X
            local trackStartX = sliderTrack.AbsolutePosition.X
            local handleWidth = sliderHandle.AbsoluteSize.X
            
            local newHandleX = mouseX - trackStartX - (handleWidth / 2)
            local clampedX = math.clamp(newHandleX, 0, trackWidth - handleWidth)
            
            sliderHandle.Position = UDim2.new(0, clampedX, 0.5, -6)
            updateFovFromHandlePosition()
        end
    end)
    -- EndRegion

    -- Region: Core Logic Functions
    local function isPartVisible(targetPart)
        local localCharacter = LocalPlayer.Character
        if not localCharacter or not targetPart or not targetPart.Parent then return false end
        local targetCharacter = targetPart:FindFirstAncestorOfClass("Model") or targetPart.Parent
        local origin = Camera.CFrame.Position
        wallCheckParams.FilterDescendantsInstances = {localCharacter, targetCharacter}
        local direction = targetPart.Position - origin
        local result = Workspace:Raycast(origin, direction, wallCheckParams)
        return not result
    end

    local function manageESP(part, color, name)
        if not part or not part.Parent then return end
        if activeESPs[part] then
            activeESPs[part].Color3, activeESPs[part].Name, activeESPs[part].Adornee, activeESPs[part].Size = color, name, part, part.Size
        else
            local espBox = Instance.new("BoxHandleAdornment")
            espBox.Name, espBox.Adornee, espBox.AlwaysOnTop = name, part, true
            espBox.ZIndex, espBox.Size, espBox.Color3 = 10, part.Size, color
            espBox.Transparency, espBox.Parent = 0.4, part
            activeESPs[part] = espBox
        end
    end
    
    local function clearESP(part)
        if part then
            if activeESPs[part] then activeESPs[part]:Destroy(); activeESPs[part] = nil end
        else
            for _, espBox in pairs(activeESPs) do espBox:Destroy() end
            activeESPs = {}
        end
    end

    local function getClosestPlayerToMouse()
        local mousePos = UserInputService:GetMouseLocation()
        local minDist, closestPlayer = math.huge, nil
        local aimPartName = partDropdown.Text
        
        for _, plr in ipairs(Players:GetPlayers()) do
            local isTeammate = ignoreTeamEnabled and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
            if plr ~= LocalPlayer and not isTeammate and plr.Character then
                local part = plr.Character:FindFirstChild(aimPartName)
                if part and (not wallCheckEnabled or isPartVisible(part)) then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        -- [MODIFIED] Check if the target is inside the FOV radius
                        if dist < minDist and dist <= fovRadius then
                            minDist, closestPlayer = dist, plr
                        end
                    end
                end
            end
        end
        return closestPlayer
    end
    -- EndRegion

    -- Region: UI Interactivity & Input Handling
    local playerDropdownOpen, playerDropdownFrame = false, nil
    local function buildPlayerDropdownFrame()
        if playerDropdownFrame then playerDropdownFrame:Destroy() end
        local playersList = Players:GetPlayers()
        playerDropdownFrame = Instance.new("Frame", page)
        playerDropdownFrame.Size, playerDropdownFrame.Position = UDim2.new(0, 160, 0, #playersList * 22), UDim2.new(0, 400, 0, 112)
        playerDropdownFrame.BackgroundColor3, playerDropdownFrame.BorderSizePixel = Color3.fromRGB(30,30,30), 0
        makeUICorner(playerDropdownFrame, 6)
        for i, plr in ipairs(playersList) do
            local btn = Instance.new("TextButton", playerDropdownFrame)
            btn.Size, btn.Position = UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, (i-1)*22)
            btn.BackgroundColor3, btn.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
            btn.Font, btn.TextSize, btn.Text = Enum.Font.Code, 15, plr.Name
            makeUICorner(btn, 6)
            btn.MouseButton1Click:Connect(function()
                selectedPlayerTarget, playerDropdown.Text = plr, plr.Name
                if playerDropdownFrame then playerDropdownFrame:Destroy() end
                playerDropdownOpen = false
                if playerTargetEnabled then statusLabel.Text = "Aimbot: Will target " .. plr.Name end
            end)
        end
    end

    targetPlayerToggle.MouseButton1Click:Connect(function()
        playerTargetEnabled = not playerTargetEnabled
        targetPlayerToggle.Text = "Target Selected: " .. (playerTargetEnabled and "ON" or "OFF")
        if not playerTargetEnabled then statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
        elseif selectedPlayerTarget then statusLabel.Text = "Aimbot: Will target " .. selectedPlayerTarget.Name end
    end)

    playerDropdown.MouseButton1Click:Connect(function()
        if playerDropdownOpen then if playerDropdownFrame then playerDropdownFrame:Destroy() end; playerDropdownOpen = false; return end
        playerDropdownOpen = true; buildPlayerDropdownFrame()
    end)

    Players.PlayerAdded:Connect(function() if playerDropdownOpen then buildPlayerDropdownFrame() end end)
    Players.PlayerRemoving:Connect(function(plr)
        if selectedPlayerTarget == plr then
            selectedPlayerTarget, playerDropdown.Text = nil, "None"
            if playerTargetEnabled then playerTargetEnabled = false; targetPlayerToggle.Text = "Target Selected: OFF" end
        end
        if playerDropdownOpen then buildPlayerDropdownFrame() end
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or toggleKeyBox:IsFocused() then return end
        if input.KeyCode == Enum.KeyCode.V then
            clearESP()
            if selectedPart or selectedPlayerTarget or selectedNpcTarget then
                selectedPart, selectedPlayerTarget, selectedNpcTarget, playerDropdown.Text = nil, nil, nil, "None"
                statusLabel.Text = "Selection cleared."
            else
                local target = LocalPlayer:GetMouse().Target
                if target then
                    local modelAncestor = target:FindFirstAncestorOfClass("Model")
                    if modelAncestor and modelAncestor:FindFirstChildOfClass("Humanoid") then
                        local plr = Players:GetPlayerFromCharacter(modelAncestor)
                        if plr then
                            selectedPlayerTarget, playerDropdown.Text, statusLabel.Text = plr, plr.Name, "Selected player: " .. plr.Name
                            selectedPart = plr.Character and plr.Character:FindFirstChild(partDropdown.Text)
                        else
                            selectedNpcTarget, selectedPart = modelAncestor, modelAncestor:FindFirstChild(partDropdown.Text) or target
                            statusLabel.Text = "Selected NPC: " .. (modelAncestor.Name or "Unnamed")
                        end
                    else selectedPart, statusLabel.Text = target, "Selected part: " .. (target.Name or "Unnamed") end
                else statusLabel.Text = "No target under mouse." end
            end
        end
        local key = toggleKeyBox.Text:upper()
        if (key == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2) or
           (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name:upper() == key) then
            aiming = true
            FovCircle.Visible = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        local key = toggleKeyBox.Text:upper()
        if (key == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2) or
           (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name:upper() == key) then
            aiming = false
            FovCircle.Visible = false
            clearESP()
        end
    end)
    -- EndRegion

    -- Region: Render Loop
    RunService.RenderStepped:Connect(function()
        if FovCircle.Visible then
            FovCircle.Position = UserInputService:GetMouseLocation()
        end
        
        local aimPart, targetPlayer = nil, nil
        local partsToDrawESPFor = {}

        if playerTargetEnabled and selectedPlayerTarget and selectedPlayerTarget.Character then
            local isTeammate = ignoreTeamEnabled and selectedPlayerTarget.Team and LocalPlayer.Team and selectedPlayerTarget.Team == LocalPlayer.Team
            if not isTeammate then targetPlayer, aimPart = selectedPlayerTarget, selectedPlayerTarget.Character:FindFirstChild(partDropdown.Text) end
        elseif selectedPart then
            aimPart = selectedPart
            local model = aimPart:FindFirstAncestorOfClass("Model")
            if model then targetPlayer = Players:GetPlayerFromCharacter(model) end
        elseif aiming then
            targetPlayer = getClosestPlayerToMouse()
            if targetPlayer and targetPlayer.Character then aimPart = targetPlayer.Character:FindFirstChild(partDropdown.Text) end
        end

        if selectedPart and selectedPart.Parent then table.insert(partsToDrawESPFor, {Part = selectedPart, Color = Color3.fromRGB(90, 170, 255), Name = "SelectedESP"}) end

        if aiming and aimPart then
            if not wallCheckEnabled or isPartVisible(aimPart) then
                table.insert(partsToDrawESPFor, {Part = aimPart, Color = Color3.fromRGB(255, 80, 80), Name = "AimbotESP"})
                local distance = (Camera.CFrame.Position - aimPart.Position).Magnitude
                local predictedPosition = aimPart.Position + (aimPart.AssemblyLinearVelocity * (distance / 2000))
                if silentAimEnabled then getgenv().ZukaSilentAimTarget = predictedPosition
                else Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition) end
                statusLabel.Text = "Aimbot: Targeting " .. (targetPlayer and targetPlayer.Name or aimPart.Name)
            else statusLabel.Text = "Aimbot: Target is behind a wall" end
        elseif aiming then statusLabel.Text = "Aimbot: No visible target found"
        elseif not aiming and not selectedPart then statusLabel.Text = "Aimbot ready. Hold toggle key to aim." end
        
        for part, espBox in pairs(activeESPs) do
            local found = false
            for _, data in ipairs(partsToDrawESPFor) do if data.Part == part then found = true; break end end
            if not found or not part.Parent then clearESP(part) end
        end
        for _, data in ipairs(partsToDrawESPFor) do manageESP(data.Part, data.Color, data.Name) end
    end)
    -- EndRegion
    
    -- Region: Toggle Buttons
    local silentAimToggle = Instance.new("TextButton", page)
    silentAimToggle.Size, silentAimToggle.Position = UDim2.new(0, 170, 0, 32), UDim2.new(0, 20, 0, 250)
    silentAimToggle.BackgroundColor3, silentAimToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    silentAimToggle.Font, silentAimToggle.TextSize, silentAimToggle.Text = Enum.Font.Code, 15, "Silent Aim: OFF"
    makeUICorner(silentAimToggle, 6)
    silentAimToggle.MouseButton1Click:Connect(function() silentAimEnabled = not silentAimEnabled; silentAimToggle.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF") end)
    
    local ignoreTeamToggle = Instance.new("TextButton", page)
    ignoreTeamToggle.Size, ignoreTeamToggle.Position = UDim2.new(0, 170, 0, 32), UDim2.new(0, 200, 0, 250)
    ignoreTeamToggle.BackgroundColor3, ignoreTeamToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    ignoreTeamToggle.Font, ignoreTeamToggle.TextSize, ignoreTeamToggle.Text = Enum.Font.Code, 15, "Ignore Team: OFF"
    makeUICorner(ignoreTeamToggle, 6)
    ignoreTeamToggle.MouseButton1Click:Connect(function() ignoreTeamEnabled = not ignoreTeamEnabled; ignoreTeamToggle.Text = "Ignore Team: " .. (ignoreTeamEnabled and "ON" or "OFF") end)
    
    local wallCheckToggle = Instance.new("TextButton", page)
    wallCheckToggle.Size, wallCheckToggle.Position = UDim2.new(0, 170, 0, 32), UDim2.new(0, 380, 0, 250)
    wallCheckToggle.BackgroundColor3, wallCheckToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    wallCheckToggle.Font, wallCheckToggle.TextSize, wallCheckToggle.Text = Enum.Font.Code, 15, "Wall Check: ON"
    makeUICorner(wallCheckToggle, 6)
    wallCheckToggle.MouseButton1Click:Connect(function() wallCheckEnabled = not wallCheckEnabled; wallCheckToggle.Text = "Wall Check: " .. (wallCheckEnabled and "ON" or "OFF") end)
    -- EndRegion
end
