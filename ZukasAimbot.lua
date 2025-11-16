local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==========================================================
-- Helper Functions & Main GUI Setup
-- ==========================================================
local function makeUICorner(element, cornerRadius)
    local corner = Instance.new("UICorner");
    corner.CornerRadius = UDim.new(0, cornerRadius or 6);
    corner.Parent = element
end

local MainScreenGui = Instance.new("ScreenGui");
MainScreenGui.Name = "UTS_CGE_Suite";
MainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
MainScreenGui.ResetOnSpawn = false;
MainScreenGui.Parent = CoreGui

local explorerWindow = nil
getgenv().TargetScope = Workspace
-- [PERFORMANCE-CRITICAL FIX] This table will be populated by the background indexer.
getgenv().TargetIndex = {}

-- ==========================================================
-- [MODULE 1] The DEX-like Custom Game Explorer (Unchanged)
-- ==========================================================
-- (This module is perfect and now links into the new indexer)
local function createExplorerWindow(statusLabel, indexerUpdateSignal)
    if explorerWindow and explorerWindow.Parent then
        explorerWindow.Visible = not explorerWindow.Visible;
        return explorerWindow
    end
    local explorerFrame = Instance.new("Frame");
    explorerFrame.Name = "ExplorerWindow";
    explorerFrame.Size = UDim2.new(0, 300, 0, 450);
    explorerFrame.Position = UDim2.new(0.5, 305, 0.5, -225);
    explorerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45);
    explorerFrame.BorderSizePixel = 1;
    explorerFrame.BorderColor3 = Color3.fromRGB(80, 80, 80);
    explorerFrame.Draggable = true;
    explorerFrame.Active = true;
    explorerFrame.ClipsDescendants = true;
    explorerFrame.Parent = MainScreenGui;
    makeUICorner(explorerFrame, 8);
    local topBar = Instance.new("Frame", explorerFrame);
    topBar.Name = "TopBar";
    topBar.Size = UDim2.new(1, 0, 0, 30);
    topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35);
    makeUICorner(topBar, 8);
    local title = Instance.new("TextLabel", topBar);
    title.Size = UDim2.new(1, -30, 1, 0);
    title.Position = UDim2.new(0, 10, 0, 0);
    title.BackgroundTransparency = 1;
    title.Font = Enum.Font.Code;
    title.Text = "Game Explorer";
    title.TextColor3 = Color3.fromRGB(200, 220, 255);
    title.TextSize = 16;
    title.TextXAlignment = Enum.TextXAlignment.Left;
    local closeButton = Instance.new("TextButton", topBar);
    closeButton.Size = UDim2.new(0, 24, 0, 24);
    closeButton.Position = UDim2.new(1, -28, 0.5, -12);
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80);
    closeButton.Font = Enum.Font.Code;
    closeButton.Text = "X";
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255);
    closeButton.TextSize = 14;
    makeUICorner(closeButton, 6);
    closeButton.MouseButton1Click:Connect(function()
        explorerFrame.Visible = false
    end);
    local treeScrollView = Instance.new("ScrollingFrame", explorerFrame);
    treeScrollView.Position = UDim2.new(0,0,0,30);
    treeScrollView.Size = UDim2.new(1, 0, 1, -30);
    treeScrollView.BackgroundColor3 = Color3.fromRGB(45, 45, 45);
    treeScrollView.BorderSizePixel = 0;
    local uiListLayout = Instance.new("UIListLayout", treeScrollView);
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
    uiListLayout.Padding = UDim.new(0, 1);
    local contextMenu = nil;
    local function closeContextMenu()
        if contextMenu and contextMenu.Parent then
            contextMenu:Destroy()
        end
    end;
    UserInputService.InputBegan:Connect(function(input)
        if not (contextMenu and contextMenu:IsAncestorOf(input.UserInputType)) and input.UserInputType ~= Enum.UserInputType.MouseButton2 then
            closeContextMenu()
        end
    end);

    local function createTree(parentInstance, parentUi, indentLevel)
        for _, child in ipairs(parentInstance:GetChildren()) do
            local itemFrame = Instance.new("Frame");
            itemFrame.Name = child.Name;
            itemFrame.Size = UDim2.new(1, 0, 0, 22);
            itemFrame.BackgroundTransparency = 1;
            itemFrame.Parent = parentUi;
            local hasChildren = #child:GetChildren() > 0;
            local toggleButton = Instance.new("TextButton");
            toggleButton.Size = UDim2.new(0, 20, 0, 20);
            toggleButton.Position = UDim2.fromOffset(indentLevel * 12, 1);
            toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100);
            toggleButton.Font = Enum.Font.Code;
            toggleButton.TextSize = 14;
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255);
            toggleButton.Text = hasChildren and "[+]" or "[-]";
            toggleButton.Parent = itemFrame;
            local nameButton = Instance.new("TextButton");
            nameButton.Size = UDim2.new(1, -((indentLevel * 12) + 22), 0, 20);
            nameButton.Position = UDim2.fromOffset((indentLevel * 12) + 22, 1);
            nameButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70);
            nameButton.Font = Enum.Font.Code;
            nameButton.TextSize = 14;
            nameButton.TextColor3 = Color3.fromRGB(220, 220, 220);
            nameButton.Text = " " .. child.Name .. " [" .. child.ClassName .. "]";
            nameButton.TextXAlignment = Enum.TextXAlignment.Left;
            nameButton.Parent = itemFrame;
            local childContainer = Instance.new("Frame", itemFrame);
            childContainer.Name = "ChildContainer";
            childContainer.Size = UDim2.new(1, 0, 0, 0);
            childContainer.Position = UDim2.new(0, 0, 1, 0);
            childContainer.BackgroundTransparency = 1;
            childContainer.ClipsDescendants = true;
            local childLayout = Instance.new("UIListLayout", childContainer);
            childLayout.SortOrder = Enum.SortOrder.LayoutOrder;
            itemFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                childContainer.Size = UDim2.new(1, 0, 0, childLayout.AbsoluteContentSize.Y);
                itemFrame.Size = UDim2.new(1, 0, 0, 22 + childContainer.AbsoluteSize.Y)
            end);
            childLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                childContainer.Size = UDim2.new(1, 0, 0, childLayout.AbsoluteContentSize.Y);
                itemFrame.Size = UDim2.new(1, 0, 0, 22 + childContainer.AbsoluteSize.Y)
            end);
            
            toggleButton.MouseButton1Click:Connect(function()
                local isExpanded = childContainer:FindFirstChildOfClass("Frame") ~= nil;
                if not hasChildren then return end;
                if isExpanded then
                    for _, v in ipairs(childContainer:GetChildren()) do
                        if v:IsA("Frame") then v:Destroy() end
                    end;
                    toggleButton.Text = "[+]"
                else
                    createTree(child, childContainer, indentLevel + 1);
                    toggleButton.Text = "[-]"
                end
            end)
            
            nameButton.MouseButton2Click:Connect(function()
                closeContextMenu();
                if child:IsA("Folder") or child:IsA("Model") or child:IsA("Workspace") then
                    contextMenu = Instance.new("Frame");
                    contextMenu.Size = UDim2.new(0, 150, 0, 30);
                    contextMenu.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y);
                    contextMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 35);
                    contextMenu.BorderSizePixel = 1;
                    contextMenu.BorderColor3 = Color3.fromRGB(80, 80, 80);
                    contextMenu.Parent = MainScreenGui;
                    local setScopeBtn = Instance.new("TextButton", contextMenu);
                    setScopeBtn.Size = UDim2.new(1, 0, 1, 0);
                    setScopeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60);
                    setScopeBtn.TextColor3 = Color3.fromRGB(200, 220, 255);
                    setScopeBtn.Font = Enum.Font.Code;
                    setScopeBtn.Text = "Set as Target Scope";
                    setScopeBtn.MouseButton1Click:Connect(function()
                        getgenv().TargetScope = child;
                        statusLabel.Text = "Scope set to: " .. child.Name;
                        indexerUpdateSignal:Fire();
                        closeContextMenu()
                    end)
                end
            end)
        end
    end
    createTree(game, treeScrollView, 0);
    explorerWindow = explorerFrame;
    return explorerFrame
end

-- ==========================================================
-- [MODULE 2] The Main "Gaming Chair" Window (UI Re-architected)
-- ==========================================================
local MainWindow = Instance.new("Frame");
MainWindow.Name = "MainWindow";
MainWindow.Size = UDim2.new(0, 520, 0, 340); -- Adjusted Size
MainWindow.Position = UDim2.new(0.5, -260, 0.5, -170);
MainWindow.BackgroundColor3 = Color3.fromRGB(35, 35, 45);
MainWindow.BorderSizePixel = 0;
MainWindow.Active = true;
MainWindow.ClipsDescendants = true;
MainWindow.Parent = MainScreenGui;
makeUICorner(MainWindow, 8);

-- Draggable Logic (Unchanged)
local isDragging = false;
local dragStart, startPosition;
MainWindow.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true;
        dragStart = input.Position;
        startPosition = MainWindow.Position;
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end);
UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
        local delta = input.Position - dragStart;
        MainWindow.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end
end);

-- Top Bar (Unchanged)
local TopBar = Instance.new("Frame");
TopBar.Name = "TopBar";
TopBar.Size = UDim2.new(1, 0, 0, 30);
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35);
TopBar.BorderSizePixel = 0;
TopBar.Parent = MainWindow;
makeUICorner(TopBar, 8);

local TitleLabel = Instance.new("TextLabel");
TitleLabel.Name = "TitleLabel";
TitleLabel.Size = UDim2.new(1, -90, 1, 0);
TitleLabel.Position = UDim2.new(0, 10, 0, 0);
TitleLabel.BackgroundTransparency = 1;
TitleLabel.Font = Enum.Font.Code;
TitleLabel.Text = "Gaming Chair";
TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255);
TitleLabel.TextSize = 16;
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left;
TitleLabel.Parent = TopBar;

local CloseButton = Instance.new("TextButton");
CloseButton.Name = "CloseButton";
CloseButton.Size = UDim2.new(0, 24, 0, 24);
CloseButton.Position = UDim2.new(1, -28, 0.5, -12);
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80);
CloseButton.Font = Enum.Font.Code;
CloseButton.Text = "X";
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255);
CloseButton.TextSize = 14;
CloseButton.Parent = TopBar;
makeUICorner(CloseButton, 6);
CloseButton.MouseButton1Click:Connect(function() MainScreenGui:Destroy() end);

local MinimizeButton = Instance.new("TextButton");
MinimizeButton.Name = "MinimizeButton";
MinimizeButton.Size = UDim2.new(0, 24, 0, 24);
MinimizeButton.Position = UDim2.new(1, -56, 0.5, -12);
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100);
MinimizeButton.Font = Enum.Font.Code;
MinimizeButton.Text = "-";
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255);
MinimizeButton.TextSize = 14;
MinimizeButton.Parent = TopBar;
makeUICorner(MinimizeButton, 6);

local ExplorerButton = Instance.new("TextButton");
ExplorerButton.Name = "ExplorerButton";
ExplorerButton.Size = UDim2.new(0, 24, 0, 24);
ExplorerButton.Position = UDim2.new(1, -84, 0.5, -12);
ExplorerButton.BackgroundColor3 = Color3.fromRGB(80, 120, 180);
ExplorerButton.Font = Enum.Font.Code;
ExplorerButton.Text = "E";
ExplorerButton.TextColor3 = Color3.fromRGB(255, 255, 255);
ExplorerButton.TextSize = 14;
ExplorerButton.Parent = TopBar;
makeUICorner(ExplorerButton, 6)

-- Main Content Area
local ContentContainer = Instance.new("Frame");
ContentContainer.Name = "ContentContainer";
ContentContainer.Size = UDim2.new(1, 0, 1, -30); -- Fill space below top bar
ContentContainer.Position = UDim2.new(0, 0, 0, 30);
ContentContainer.BackgroundTransparency = 1;
ContentContainer.Parent = MainWindow;

-- Minimize Logic
local isMinimized = false;
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized;
    ContentContainer.Visible = not isMinimized;
    if isMinimized then
        MainWindow.Size = UDim2.new(0, 200, 0, 30);
        MinimizeButton.Text = "+"
    else
        MainWindow.Size = UDim2.new(0, 520, 0, 340);
        MinimizeButton.Text = "-"
    end
end);

-- Aimbot Logic and UI Scoping
do
    -- UI Element Creation
    local statusLabel, selectLabel; -- Forward declare for explorer
    
    -- Main Page Layout
    local AimbotPage = Instance.new("Frame", ContentContainer)
    AimbotPage.Name = "AimbotPage"
    AimbotPage.Size = UDim2.new(1, 0, 1, -50) -- Leave space for status bar
    AimbotPage.BackgroundTransparency = 1;
    
    local PagePadding = Instance.new("UIPadding", AimbotPage)
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingLeft = UDim.new(0, 10)
    PagePadding.PaddingRight = UDim.new(0, 10)

    -- Left Column for Primary Settings
    local LeftColumn = Instance.new("Frame", AimbotPage)
    LeftColumn.Name = "LeftColumn"
    LeftColumn.Size = UDim2.new(0.5, -5, 1, 0)
    LeftColumn.BackgroundTransparency = 1
    local LeftLayout = Instance.new("UIListLayout", LeftColumn)
    LeftLayout.Padding = UDim.new(0, 8)
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Right Column for Targeting & Modifiers
    local RightColumn = Instance.new("Frame", AimbotPage)
    RightColumn.Name = "RightColumn"
    RightColumn.Size = UDim2.new(0.5, -5, 1, 0)
    RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
    RightColumn.BackgroundTransparency = 1
    local RightLayout = Instance.new("UIListLayout", RightColumn)
    RightLayout.Padding = UDim.new(0, 8)
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Status Bar
    local StatusBar = Instance.new("Frame", ContentContainer)
    StatusBar.Name = "StatusBar"
    StatusBar.Size = UDim2.new(1, -20, 0, 40)
    StatusBar.Position = UDim2.new(0, 10, 1, -45)
    StatusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    makeUICorner(StatusBar, 6)
    local StatusLayout = Instance.new("UIListLayout", StatusBar)
    StatusLayout.Padding = UDim.new(0, 2)
    local StatusPadding = Instance.new("UIPadding", StatusBar)
    StatusPadding.PaddingLeft = UDim.new(0, 8)
    StatusPadding.PaddingRight = UDim.new(0, 8)

    -- Helper to create a section header
    local function createSectionHeader(parent, text)
        local header = Instance.new("TextLabel", parent)
        header.Size = UDim2.new(1, 0, 0, 24)
        header.BackgroundTransparency = 1
        header.Font = Enum.Font.Code
        header.Text = text
        header.TextColor3 = Color3.fromRGB(200, 220, 255)
        header.TextSize = 16
        header.TextXAlignment = Enum.TextXAlignment.Left
        return header
    end

    -- Helper to create a setting row (label + control)
    local function createSettingRow(parent, labelText)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Code
        label.Text = labelText..":"
        label.TextColor3 = Color3.fromRGB(180, 220, 255)
        label.TextSize = 15
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        return row
    end

    -- ### Populate Left Column ###
    createSectionHeader(LeftColumn, "General Settings")
    
    local toggleKeyRow = createSettingRow(LeftColumn, "Toggle Key")
    local toggleKeyBox = Instance.new("TextBox", toggleKeyRow)
    toggleKeyBox.Size, toggleKeyBox.Position = UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0)
    toggleKeyBox.BackgroundColor3, toggleKeyBox.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    toggleKeyBox.Font, toggleKeyBox.TextSize, toggleKeyBox.Text = Enum.Font.Code, 15, "MouseButton2"
    makeUICorner(toggleKeyBox, 6)
    
    local aimPartRow = createSettingRow(LeftColumn, "Aim Part")
    local partDropdown = Instance.new("TextButton", aimPartRow)
    partDropdown.Size, partDropdown.Position = UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0)
    partDropdown.BackgroundColor3, partDropdown.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    partDropdown.Font, partDropdown.TextSize, partDropdown.Text = Enum.Font.Code, 15, "Head"
    makeUICorner(partDropdown, 6)
    
    createSectionHeader(LeftColumn, "Field of View")
    
    local fovRow = createSettingRow(LeftColumn, "FOV Radius")
    local fovValueLabel = Instance.new("TextLabel", fovRow)
    fovValueLabel.Size, fovValueLabel.Position = UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0)
    fovValueLabel.BackgroundTransparency, fovValueLabel.TextColor3 = 1, Color3.fromRGB(255,255,255)
    fovValueLabel.Font, fovValueLabel.TextSize = Enum.Font.Code, 15
    fovValueLabel.TextXAlignment, fovValueLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center

    local sliderTrack = Instance.new("Frame", LeftColumn)
    sliderTrack.Size, sliderTrack.BackgroundColor3 = UDim2.new(1, 0, 0, 4), Color3.fromRGB(20,20,30)
    sliderTrack.BorderSizePixel = 0
    makeUICorner(sliderTrack, 2)
    
    local sliderHandle = Instance.new("TextButton", sliderTrack)
    sliderHandle.Size, sliderHandle.Position = UDim2.new(0, 12, 0, 12), UDim2.new(0, 0, 0.5, -6)
    sliderHandle.BackgroundColor3, sliderHandle.BorderSizePixel = Color3.fromRGB(180, 220, 255), 0
    sliderHandle.Text = ""
    makeUICorner(sliderHandle, 6)

    -- ### Populate Right Column ###
    createSectionHeader(RightColumn, "Targeting")
    
    local playerRow = createSettingRow(RightColumn, "Target Player")
    local playerDropdown = Instance.new("TextButton", playerRow)
    playerDropdown.Size, playerDropdown.Position = UDim2.new(0.6, 0, 1, 0), UDim2.new(0.4, 0, 0, 0)
    playerDropdown.BackgroundColor3, playerDropdown.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    playerDropdown.Font, playerDropdown.TextSize, playerDropdown.Text = Enum.Font.Code, 15, "None"
    makeUICorner(playerDropdown, 6)
    
    local targetPlayerToggle = Instance.new("TextButton", RightColumn)
    targetPlayerToggle.Size = UDim2.new(1, 0, 0, 28)
    targetPlayerToggle.BackgroundColor3, targetPlayerToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    targetPlayerToggle.Font, targetPlayerToggle.TextSize, targetPlayerToggle.Text = Enum.Font.Code, 15, "Target Selected: OFF"
    makeUICorner(targetPlayerToggle, 6)

    createSectionHeader(RightColumn, "Modifiers")
    
    local silentAimToggle = Instance.new("TextButton", RightColumn)
    silentAimToggle.Size, silentAimToggle.Text = UDim2.new(1, 0, 0, 28), "Silent Aim: OFF"
    silentAimToggle.BackgroundColor3, silentAimToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    silentAimToggle.Font, silentAimToggle.TextSize = Enum.Font.Code, 15
    makeUICorner(silentAimToggle, 6)
    
    local ignoreTeamToggle = Instance.new("TextButton", RightColumn)
    ignoreTeamToggle.Size, ignoreTeamToggle.Text = UDim2.new(1, 0, 0, 28), "Ignore Team: OFF"
    ignoreTeamToggle.BackgroundColor3, ignoreTeamToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    ignoreTeamToggle.Font, ignoreTeamToggle.TextSize = Enum.Font.Code, 15
    makeUICorner(ignoreTeamToggle, 6)
    
    local wallCheckToggle = Instance.new("TextButton", RightColumn)
    wallCheckToggle.Size, wallCheckToggle.Text = UDim2.new(1, 0, 0, 28), "Wall Check: ON"
    wallCheckToggle.BackgroundColor3, wallCheckToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255)
    wallCheckToggle.Font, wallCheckToggle.TextSize = Enum.Font.Code, 15
    makeUICorner(wallCheckToggle, 6)
    
    -- ### Populate Status Bar ###
    statusLabel = Instance.new("TextLabel", StatusBar)
    statusLabel.Size, statusLabel.BackgroundTransparency = UDim2.new(1, 0, 0, 18), 1
    statusLabel.TextColor3, statusLabel.Font, statusLabel.TextSize = Color3.fromRGB(180,220,180), Enum.Font.Code, 14
    statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left

    selectLabel = Instance.new("TextLabel", StatusBar)
    selectLabel.Size, selectLabel.BackgroundTransparency = UDim2.new(1, 0, 0, 18), 1
    selectLabel.TextColor3, selectLabel.Font, selectLabel.TextSize = Color3.fromRGB(220,220,180), Enum.Font.Code, 14
    selectLabel.Text = "Press V to delete any block/model under mouse."
    selectLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- ####################################################################
    -- ### ALL AIMBOT LOGIC BELOW IS UNCHANGED - ONLY UI IS REFACTORED ####
    -- ####################################################################
    
    -- Dropdown Logic for Aim Part
    local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"};
    local dropdownOpen, dropdownFrame = false, nil;
    partDropdown.MouseButton1Click:Connect(function()
        if dropdownOpen then
            if dropdownFrame then dropdownFrame:Destroy() end
            dropdownOpen = false;
            return
        end;
        dropdownOpen = true;
        dropdownFrame = Instance.new("Frame", LeftColumn); -- Attach to column
        local absolutePos = partDropdown.AbsolutePosition
        local guiPos = MainScreenGui.AbsolutePosition
        dropdownFrame.Size = UDim2.new(0, partDropdown.AbsoluteSize.X, 0, #parts * 22)
        dropdownFrame.Position = UDim2.new(0, absolutePos.X - guiPos.X, 0, absolutePos.Y - guiPos.Y + 22)
        dropdownFrame.BackgroundColor3, dropdownFrame.BorderSizePixel = Color3.fromRGB(30,30,30), 0;
        dropdownFrame.ZIndex = 5
        makeUICorner(dropdownFrame, 6);
        for i, part in ipairs(parts) do
            local btn = Instance.new("TextButton", dropdownFrame);
            btn.Size, btn.Position = UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, (i-1)*22);
            btn.BackgroundColor3, btn.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255);
            btn.Font, btn.TextSize, btn.Text = Enum.Font.Code, 15, part;
            makeUICorner(btn, 6);
            btn.MouseButton1Click:Connect(function()
                partDropdown.Text = part;
                if dropdownFrame then dropdownFrame:Destroy() end;
                dropdownOpen = false
            end)
        end
    end);
    
    -- Variable Declarations
    local fovRadius = 150;
    local selectedPlayerTarget, selectedNpcTarget, selectedPart = nil, nil, nil;
    local playerTargetEnabled = false;
    local aiming = false;
    local silentAimEnabled = false;
    local ignoreTeamEnabled = false;
    local wallCheckEnabled = true;
    local wallCheckParams = RaycastParams.new();
    wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude;
    local activeESPs = {};
    local FovCircle = Drawing.new("Circle");
    FovCircle.Visible = false;
    FovCircle.Thickness = 1;
    FovCircle.NumSides = 64;
    FovCircle.Color = Color3.fromRGB(255, 255, 255);
    FovCircle.Transparency = 0.5;
    FovCircle.Filled = false;
    
    -- FOV Slider Logic
    local minFov, maxFov = 50, 500;
    local function updateFovFromHandlePosition()
        local trackWidth = sliderTrack.AbsoluteSize.X;
        local handleX = sliderHandle.Position.X.Offset;
        local ratio = math.clamp(handleX / (trackWidth - sliderHandle.AbsoluteSize.X), 0, 1);
        fovRadius = minFov + (maxFov - minFov) * ratio;
        fovValueLabel.Text = tostring(math.floor(fovRadius)) .. "px";
        FovCircle.Radius = fovRadius
    end;
    local function updateHandleFromFovValue()
        local trackWidth = sliderTrack.AbsoluteSize.X;
        local ratio = (fovRadius - minFov) / (maxFov - minFov);
        local handleX = ratio * (trackWidth - sliderHandle.AbsoluteSize.X);
        sliderHandle.Position = UDim2.new(0, handleX, 0.5, -6)
    end;
    task.wait();
    updateHandleFromFovValue()
    updateFovFromHandlePosition() -- Initialize text
    
    local isDraggingSlider = false;
    sliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingSlider = true end
    end);
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingSlider = false end
    end);
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = UserInputService:GetMouseLocation().X;
            local trackStartX = sliderTrack.AbsolutePosition.X;
            local handleWidth = sliderHandle.AbsoluteSize.X;
            local trackWidth = sliderTrack.AbsoluteSize.X;
            local newHandleX = mouseX - trackStartX - (handleWidth / 2);
            local clampedX = math.clamp(newHandleX, 0, trackWidth - handleWidth);
            sliderHandle.Position = UDim2.new(0, clampedX, 0.5, -6);
            updateFovFromHandlePosition()
        end
    end)
    
    -- Core Helper Functions
    local function isTeammate(player)
        if not ignoreTeamEnabled or not player then return false end;
        if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return true end;
        if LocalPlayer.TeamColor and player.TeamColor and LocalPlayer.TeamColor == player.TeamColor then return true end;
        return false
    end
    local function isPartVisible(targetPart)
        if not LocalPlayer.Character or not targetPart or not targetPart.Parent then return false end;
        local targetCharacter = targetPart:FindFirstAncestorOfClass("Model") or targetPart.Parent;
        local origin = Camera.CFrame.Position;
        wallCheckParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter};
        local result = Workspace:Raycast(origin, targetPart.Position - origin, wallCheckParams);
        return not result
    end
    local function manageESP(part, color, name)
        if not part or not part.Parent then return end;
        if activeESPs[part] then
            activeESPs[part].Color3, activeESPs[part].Name, activeESPs[part].Adornee, activeESPs[part].Size = color, name, part, part.Size
        else
            local espBox = Instance.new("BoxHandleAdornment");
            espBox.Name, espBox.Adornee, espBox.AlwaysOnTop = name, part, true;
            espBox.ZIndex, espBox.Size, espBox.Color3 = 10, part.Size, color;
            espBox.Transparency, espBox.Parent = 0.4, part;
            activeESPs[part] = espBox
        end
    end
    local function clearESP(part)
        if part then
            if activeESPs[part] then
                activeESPs[part]:Destroy();
                activeESPs[part] = nil
            end
        else
            for _, espBox in pairs(activeESPs) do espBox:Destroy() end;
            activeESPs = {}
        end
    end
    
    -- [CRITICAL LOGIC PATCH] This function now correctly checks for teammates.
    local function getClosestTargetInScope()
        local mousePos = UserInputService:GetMouseLocation();
        local minDist, closestTargetModel = math.huge, nil;
        local aimPartName = partDropdown.Text
        
        for _, model in ipairs(getgenv().TargetIndex) do
            if model and model.Parent then -- Check if target is still valid
                local player = Players:GetPlayerFromCharacter(model)
                if not (player and isTeammate(player)) then -- Proceed only if not a teammate or not a player
                    local targetPart = model:FindFirstChild(aimPartName)
                    if targetPart and (not wallCheckEnabled or isPartVisible(targetPart)) then
                        local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude;
                            if dist < minDist and dist <= fovRadius then
                                minDist, closestTargetModel = dist, model
                            end
                        end
                    end
                end
            end
        end
        return closestTargetModel
    end
    
    -- Player Dropdown Logic
    local playerDropdownOpen, playerDropdownFrame = false, nil;
    local function buildPlayerDropdownFrame()
        if playerDropdownFrame then playerDropdownFrame:Destroy() end;
        local playersList = Players:GetPlayers();
        playerDropdownFrame = Instance.new("Frame", RightColumn); -- Attach to column
        local absolutePos = playerDropdown.AbsolutePosition
        local guiPos = MainScreenGui.AbsolutePosition
        playerDropdownFrame.Size = UDim2.new(0, playerDropdown.AbsoluteSize.X, 0, #playersList * 22)
        playerDropdownFrame.Position = UDim2.new(0, absolutePos.X - guiPos.X, 0, absolutePos.Y - guiPos.Y + 22)
        playerDropdownFrame.BackgroundColor3, playerDropdownFrame.BorderSizePixel = Color3.fromRGB(30,30,30), 0;
        playerDropdownFrame.ZIndex = 5
        makeUICorner(playerDropdownFrame, 6);
        for i, plr in ipairs(playersList) do
            local btn = Instance.new("TextButton", playerDropdownFrame);
            btn.Size, btn.Position = UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, (i-1)*22);
            btn.BackgroundColor3, btn.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255);
            btn.Font, btn.TextSize, btn.Text = Enum.Font.Code, 15, plr.Name;
            makeUICorner(btn, 6);
            btn.MouseButton1Click:Connect(function()
                selectedPlayerTarget, playerDropdown.Text = plr, plr.Name;
                if playerDropdownFrame then playerDropdownFrame:Destroy() end;
                playerDropdownOpen = false;
                if playerTargetEnabled then statusLabel.Text = "Aimbot: Will target " .. plr.Name end
            end)
        end
    end
    
    targetPlayerToggle.MouseButton1Click:Connect(function()
        playerTargetEnabled = not playerTargetEnabled;
        targetPlayerToggle.Text = "Target Selected: " .. (playerTargetEnabled and "ON" or "OFF");
        if not playerTargetEnabled then
            statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
        elseif selectedPlayerTarget then
            statusLabel.Text = "Aimbot: Will target " .. selectedPlayerTarget.Name
        end
    end)
    
    playerDropdown.MouseButton1Click:Connect(function()
        if playerDropdownOpen then
            if playerDropdownFrame then playerDropdownFrame:Destroy() end;
            playerDropdownOpen = false;
            return
        end;
        playerDropdownOpen = true;
        buildPlayerDropdownFrame()
    end)
    Players.PlayerAdded:Connect(function() if playerDropdownOpen then buildPlayerDropdownFrame() end end);
    Players.PlayerRemoving:Connect(function(plr)
        if selectedPlayerTarget == plr then
            selectedPlayerTarget, playerDropdown.Text = nil, "None";
            if playerTargetEnabled then
                playerTargetEnabled = false;
                targetPlayerToggle.Text = "Target Selected: OFF"
            end
        end;
        if playerDropdownOpen then buildPlayerDropdownFrame() end
    end)
    
    -- Main Input Handling
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or toggleKeyBox:IsFocused() then return end;
        if input.KeyCode == Enum.KeyCode.V then
            local target = LocalPlayer:GetMouse().Target
            if target and target.Parent then
                local modelAncestor = target:FindFirstAncestorOfClass("Model")
                if (modelAncestor and modelAncestor == LocalPlayer.Character) or target:IsDescendantOf(LocalPlayer.Character) then
                    statusLabel.Text = "Cannot delete your own character."
                    return
                end
                if modelAncestor and modelAncestor ~= Workspace then
                    local modelName = modelAncestor.Name
                    modelAncestor:Destroy()
                    statusLabel.Text = "Deleted model: " .. modelName
                else
                    if target.Parent ~= Workspace then
                         local targetName = target.Name
                         target:Destroy()
                         statusLabel.Text = "Deleted part: " .. targetName
                    else
                         statusLabel.Text = "Cannot delete baseplate or map."
                    end
                end
            else
                statusLabel.Text = "No target under mouse to delete."
            end
        end;
        
        local key = toggleKeyBox.Text:upper();
        if (key == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2) or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name:upper() == key) then
            aiming = true;
            FovCircle.Visible = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        local key = toggleKeyBox.Text:upper();
        if (key == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2) or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name:upper() == key) then
            aiming = false;
            FovCircle.Visible = false;
            clearESP()
        end
    end)
    
    -- Render Loop
    local currentTarget = nil
    RunService.RenderStepped:Connect(function()
        if FovCircle.Visible then
            FovCircle.Position = UserInputService:GetMouseLocation()
        end
        local isCurrentTargetValid = currentTarget and currentTarget.Parent and currentTarget:FindFirstChildOfClass("Humanoid") and currentTarget:FindFirstChildOfClass("Humanoid").Health > 0
        if aiming and not isCurrentTargetValid then
            currentTarget = getClosestTargetInScope()
        elseif not aiming then
            currentTarget = nil
        end
        local aimPart, targetPlayer, targetModel = nil, nil, nil;
        local partsToDrawESPFor = {}
        if playerTargetEnabled and selectedPlayerTarget and selectedPlayerTarget.Character then
            if not isTeammate(selectedPlayerTarget) then
                targetModel, targetPlayer = selectedPlayerTarget.Character, selectedPlayerTarget
            else
                targetModel = nil
            end
        elseif selectedPart and selectedPart.Parent then
            targetModel = selectedPart:FindFirstAncestorOfClass("Model")
            if targetModel then
                local player = Players:GetPlayerFromCharacter(targetModel);
                if not player or not isTeammate(player) then targetPlayer = player else targetModel = nil end
            end
        elseif aiming and currentTarget then
            targetModel = currentTarget;
            targetPlayer = Players:GetPlayerFromCharacter(targetModel)
        end
        if targetModel then aimPart = targetModel:FindFirstChild(partDropdown.Text) end
        if selectedPart and selectedPart.Parent then table.insert(partsToDrawESPFor, {Part = selectedPart, Color = Color3.fromRGB(90, 170, 255), Name = "SelectedESP"}) end
        if aiming and aimPart and targetModel then
            if not wallCheckEnabled or isPartVisible(aimPart) then
                table.insert(partsToDrawESPFor, {Part = aimPart, Color = Color3.fromRGB(255, 80, 80), Name = "AimbotESP"});
                local distance = (Camera.CFrame.Position - aimPart.Position).Magnitude;
                local predictedPosition = aimPart.Position + (aimPart.AssemblyLinearVelocity * (distance / 2000));
                if silentAimEnabled then
                    getgenv().ZukaSilentAimTarget = predictedPosition
                else
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
                end;
                statusLabel.Text = "Aimbot: Targeting " .. (targetPlayer and targetPlayer.Name or targetModel.Name)
            else
                statusLabel.Text = "Aimbot: Target is behind a wall";
                currentTarget = nil
            end
        elseif aiming then
            statusLabel.Text = "Aimbot: No visible target in index"
        elseif not aiming and not selectedPart then
            statusLabel.Text = "Aimbot ready. Hold toggle key to aim."
        end
        for part, espBox in pairs(activeESPs) do
            local found = false;
            for _, data in ipairs(partsToDrawESPFor) do if data.Part == part then found = true; break end end;
            if not found or not part.Parent then clearESP(part) end
        end
        for _, data in ipairs(partsToDrawESPFor) do manageESP(data.Part, data.Color, data.Name) end
    end)
    
    -- Modifier Toggles
    silentAimToggle.MouseButton1Click:Connect(function()
        silentAimEnabled = not silentAimEnabled;
        silentAimToggle.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF")
    end)
    ignoreTeamToggle.MouseButton1Click:Connect(function()
        ignoreTeamEnabled = not ignoreTeamEnabled;
        ignoreTeamToggle.Text = "Ignore Team: " .. (ignoreTeamEnabled and "ON" or "OFF")
    end)
    wallCheckToggle.MouseButton1Click:Connect(function()
        wallCheckEnabled = not wallCheckEnabled;
        wallCheckToggle.Text = "Wall Check: " .. (wallCheckEnabled and "ON" or "OFF")
    end)
    
    -- [PERFORMANCE-CRITICAL FIX] The background indexer and its controller.
    local indexerUpdateSignal = Instance.new("BindableEvent")
    
    ExplorerButton.MouseButton1Click:Connect(function()
        createExplorerWindow(statusLabel, indexerUpdateSignal)
    end)
    task.spawn(function()
        local function RebuildTargetIndex()
            local newIndex = {}
            for _, descendant in ipairs(getgenv().TargetScope:GetDescendants()) do
                if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") then
                    table.insert(newIndex, descendant)
                end
            end
            getgenv().TargetIndex = newIndex
        end
        
        indexerUpdateSignal.Event:Connect(RebuildTargetIndex) -- Allow manual updates
        while task.wait(2) do -- The slow, non-laggy background loop
            RebuildTargetIndex()
        end
    end)
    indexerUpdateSignal:Fire() -- Fire once at the start to populate the index immediately.
end
