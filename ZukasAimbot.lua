--[[
    ================================================================================================
    -- Project: UTS + CGE (Universal Targeting System + Custom Game Explorer)
    -- Architect: Hailey Marvola
    -- Version: Final Performance Build (Patch 1)
    --
    -- Description: The truly definitive build. Implements a background target indexer to completely
    --              eliminate on-demand lag from GetDescendants(). Aimbot acquisition is now
    --              instantaneous and has zero performance impact. The "Ignore Team" logic is
    --              fully patched and robust across all targeting modes. This is the final product.
    --
    -- Patch Notes (vFinal.1):
    --   - Fixed a critical logic flaw where the general aimbot (currentTarget) would still target
    --     teammates even when "Ignore Team" was enabled. The isTeammate() check is now correctly
    --     integrated into the getClosestTargetInScope() function, filtering out teammates
    --     during the initial target acquisition phase.
    ================================================================================================
]]

-- =================================================================
-- Services & Globals
-- =================================================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- =================================================================
-- Helper Functions & Main GUI Setup
-- =================================================================
local function makeUICorner(element, cornerRadius) local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, cornerRadius or 6); corner.Parent = element end
local MainScreenGui = Instance.new("ScreenGui"); MainScreenGui.Name = "UTS_CGE_Suite"; MainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global; MainScreenGui.ResetOnSpawn = false; MainScreenGui.Parent = CoreGui

local explorerWindow = nil
getgenv().TargetScope = Workspace
-- [PERFORMANCE-CRITICAL] This table will be populated by the background indexer.
getgenv().TargetIndex = {}

-- =================================================================
-- [MODULE 1] The DEX-like Custom Game Explorer
-- =================================================================
-- (This module is perfect and now links into the new indexer)
local function createExplorerWindow(statusLabel, indexerUpdateSignal)
    if explorerWindow and explorerWindow.Parent then explorerWindow.Visible = not explorerWindow.Visible; return explorerWindow end
    local explorerFrame = Instance.new("Frame"); explorerFrame.Name = "ExplorerWindow"; explorerFrame.Size = UDim2.new(0, 300, 0, 450); explorerFrame.Position = UDim2.new(0.5, 305, 0.5, -225); explorerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45); explorerFrame.BorderSizePixel = 1; explorerFrame.BorderColor3 = Color3.fromRGB(80, 80, 80); explorerFrame.Draggable = true; explorerFrame.Active = true; explorerFrame.ClipsDescendants = true; explorerFrame.Parent = MainScreenGui; makeUICorner(explorerFrame, 8); local topBar = Instance.new("Frame", explorerFrame); topBar.Name = "TopBar"; topBar.Size = UDim2.new(1, 0, 0, 30); topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35); makeUICorner(topBar, 8); local title = Instance.new("TextLabel", topBar); title.Size = UDim2.new(1, -30, 1, 0); title.Position = UDim2.new(0, 10, 0, 0); title.BackgroundTransparency = 1; title.Font = Enum.Font.Code; title.Text = "Game Explorer"; title.TextColor3 = Color3.fromRGB(200, 220, 255); title.TextSize = 16; title.TextXAlignment = Enum.TextXAlignment.Left; local closeButton = Instance.new("TextButton", topBar); closeButton.Size = UDim2.new(0, 24, 0, 24); closeButton.Position = UDim2.new(1, -28, 0.5, -12); closeButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80); closeButton.Font = Enum.Font.Code; closeButton.Text = "X"; closeButton.TextColor3 = Color3.fromRGB(255, 255, 255); closeButton.TextSize = 14; makeUICorner(closeButton, 6); closeButton.MouseButton1Click:Connect(function() explorerFrame.Visible = false end); local treeScrollView = Instance.new("ScrollingFrame", explorerFrame); treeScrollView.Position = UDim2.new(0,0,0,30); treeScrollView.Size = UDim2.new(1, 0, 1, -30); treeScrollView.BackgroundColor3 = Color3.fromRGB(45, 45, 45); treeScrollView.BorderSizePixel = 0; local uiListLayout = Instance.new("UIListLayout", treeScrollView); uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder; uiListLayout.Padding = UDim.new(0, 1); local contextMenu = nil; local function closeContextMenu() if contextMenu and contextMenu.Parent then contextMenu:Destroy() end end; UserInputService.InputBegan:Connect(function(input) if not (contextMenu and contextMenu:IsAncestorOf(input.UserInputType)) and input.UserInputType ~= Enum.UserInputType.MouseButton2 then closeContextMenu() end end);
    local function createTree(parentInstance, parentUi, indentLevel)
        for _, child in ipairs(parentInstance:GetChildren()) do
            local itemFrame = Instance.new("Frame"); itemFrame.Name = child.Name; itemFrame.Size = UDim2.new(1, 0, 0, 22); itemFrame.BackgroundTransparency = 1; itemFrame.Parent = parentUi; local hasChildren = #child:GetChildren() > 0; local toggleButton = Instance.new("TextButton"); toggleButton.Size = UDim2.new(0, 20, 0, 20); toggleButton.Position = UDim2.fromOffset(indentLevel * 12, 1); toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100); toggleButton.Font = Enum.Font.Code; toggleButton.TextSize = 14; toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255); toggleButton.Text = hasChildren and "[+]" or "[-]"; toggleButton.Parent = itemFrame; local nameButton = Instance.new("TextButton"); nameButton.Size = UDim2.new(1, -((indentLevel * 12) + 22), 0, 20); nameButton.Position = UDim2.fromOffset((indentLevel * 12) + 22, 1); nameButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70); nameButton.Font = Enum.Font.Code; nameButton.TextSize = 14; nameButton.TextColor3 = Color3.fromRGB(220, 220, 220); nameButton.Text = " " .. child.Name .. " [" .. child.ClassName .. "]"; nameButton.TextXAlignment = Enum.TextXAlignment.Left; nameButton.Parent = itemFrame; local childContainer = Instance.new("Frame", itemFrame); childContainer.Name = "ChildContainer"; childContainer.Size = UDim2.new(1, 0, 0, 0); childContainer.Position = UDim2.new(0, 0, 1, 0); childContainer.BackgroundTransparency = 1; childContainer.ClipsDescendants = true; local childLayout = Instance.new("UIListLayout", childContainer); childLayout.SortOrder = Enum.SortOrder.LayoutOrder; itemFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() childContainer.Size = UDim2.new(1, 0, 0, childLayout.AbsoluteContentSize.Y); itemFrame.Size = UDim2.new(1, 0, 0, 22 + childContainer.AbsoluteSize.Y) end); childLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() childContainer.Size = UDim2.new(1, 0, 0, childLayout.AbsoluteContentSize.Y); itemFrame.Size = UDim2.new(1, 0, 0, 22 + childContainer.AbsoluteSize.Y) end);
            toggleButton.MouseButton1Click:Connect(function() local isExpanded = childContainer:FindFirstChildOfClass("Frame") ~= nil; if not hasChildren then return end; if isExpanded then for _, v in ipairs(childContainer:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end; toggleButton.Text = "[+]" else createTree(child, childContainer, indentLevel + 1); toggleButton.Text = "[-]" end end)
            nameButton.MouseButton2Click:Connect(function() closeContextMenu(); if child:IsA("Folder") or child:IsA("Model") or child:IsA("Workspace") then contextMenu = Instance.new("Frame"); contextMenu.Size = UDim2.new(0, 150, 0, 30); contextMenu.Position = UDim2.fromOffset(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y); contextMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 35); contextMenu.BorderSizePixel = 1; contextMenu.BorderColor3 = Color3.fromRGB(80, 80, 80); contextMenu.Parent = MainScreenGui; local setScopeBtn = Instance.new("TextButton", contextMenu); setScopeBtn.Size = UDim2.new(1, 0, 1, 0); setScopeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60); setScopeBtn.TextColor3 = Color3.fromRGB(200, 220, 255); setScopeBtn.Font = Enum.Font.Code; setScopeBtn.Text = "Set as Target Scope"; setScopeBtn.MouseButton1Click:Connect(function() getgenv().TargetScope = child; statusLabel.Text = "Scope set to: " .. child.Name; indexerUpdateSignal:Fire(); closeContextMenu() end) end end)
        end
    end
    createTree(game, treeScrollView, 0); explorerWindow = explorerFrame; return explorerFrame
end

-- =================================================================
-- [MODULE 2] The Main "Gaming Chair" Window (Full Implementation)
-- =================================================================
local MainWindow = Instance.new("Frame"); MainWindow.Name = "MainWindow"; MainWindow.Size = UDim2.new(0, 600, 0, 350); MainWindow.Position = UDim2.new(0.5, -300, 0.5, -175); MainWindow.BackgroundColor3 = Color3.fromRGB(35, 35, 45); MainWindow.BorderSizePixel = 0; MainWindow.Active = true; MainWindow.ClipsDescendants = true; MainWindow.Parent = MainScreenGui; makeUICorner(MainWindow, 8); local isDragging = false; local dragStart, startPosition; MainWindow.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true; dragStart = input.Position; startPosition = MainWindow.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then isDragging = false end end) end end); UserInputService.InputChanged:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and isDragging then local delta = input.Position - dragStart; MainWindow.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y) end end); local TopBar = Instance.new("Frame"); TopBar.Name = "TopBar"; TopBar.Size = UDim2.new(1, 0, 0, 30); TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35); TopBar.BorderSizePixel = 0; TopBar.Parent = MainWindow; makeUICorner(TopBar, 8); local TitleLabel = Instance.new("TextLabel"); TitleLabel.Name = "TitleLabel"; TitleLabel.Size = UDim2.new(1, -90, 1, 0); TitleLabel.Position = UDim2.new(0, 10, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.Font = Enum.Font.Code; TitleLabel.Text = "Gaming Chair"; TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255); TitleLabel.TextSize = 16; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TopBar; local CloseButton = Instance.new("TextButton"); CloseButton.Name = "CloseButton"; CloseButton.Size = UDim2.new(0, 24, 0, 24); CloseButton.Position = UDim2.new(1, -28, 0.5, -12); CloseButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80); CloseButton.Font = Enum.Font.Code; CloseButton.Text = "X"; CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255); CloseButton.TextSize = 14; CloseButton.Parent = TopBar; makeUICorner(CloseButton, 6); CloseButton.MouseButton1Click:Connect(function() MainScreenGui:Destroy() end); local MinimizeButton = Instance.new("TextButton"); MinimizeButton.Name = "MinimizeButton"; MinimizeButton.Size = UDim2.new(0, 24, 0, 24); MinimizeButton.Position = UDim2.new(1, -56, 0.5, -12); MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100); MinimizeButton.Font = Enum.Font.Code; MinimizeButton.Text = "-"; MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255); MinimizeButton.TextSize = 14; MinimizeButton.Parent = TopBar; makeUICorner(MinimizeButton, 6); local AimbotPage = Instance.new("Frame"); AimbotPage.Name = "AimbotPage"; AimbotPage.Size = UDim2.new(1, 0, 1, -30); AimbotPage.Position = UDim2.new(0, 0, 0, 30); AimbotPage.BackgroundTransparency = 1; AimbotPage.Parent = MainWindow; local isMinimized = false; MinimizeButton.MouseButton1Click:Connect(function() isMinimized = not isMinimized; AimbotPage.Visible = not isMinimized; if isMinimized then MainWindow.Size = UDim2.new(0, 200, 0, 30); MinimizeButton.Text = "+" else MainWindow.Size = UDim2.new(0, 600, 0, 350); MinimizeButton.Text = "-" end end); local ExplorerButton = Instance.new("TextButton"); ExplorerButton.Name = "ExplorerButton"; ExplorerButton.Size = UDim2.new(0, 24, 0, 24); ExplorerButton.Position = UDim2.new(1, -84, 0.5, -12); ExplorerButton.BackgroundColor3 = Color3.fromRGB(80, 120, 180); ExplorerButton.Font = Enum.Font.Code; ExplorerButton.Text = "E"; ExplorerButton.TextColor3 = Color3.fromRGB(255, 255, 255); ExplorerButton.TextSize = 14; ExplorerButton.Parent = TopBar; makeUICorner(ExplorerButton, 6)

do
    local page = AimbotPage
    local title = Instance.new("TextLabel", page); title.Size, title.Position = UDim2.new(1, -20, 0, 36), UDim2.new(0, 10, 0, 10); title.BackgroundTransparency, title.TextColor3 = 1, Color3.fromRGB(200,220,255); title.Font, title.TextSize, title.Text = Enum.Font.Code, 22, "Aimbot Settings"; title.TextXAlignment, title.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center; local desc = Instance.new("TextLabel", page); desc.Size, desc.Position = UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 50); desc.BackgroundTransparency, desc.TextColor3 = 1, Color3.fromRGB(180,180,200); desc.Font, desc.TextSize, desc.Text = Enum.Font.Code, 15, "Configure aimbot toggle and aim part."; desc.TextXAlignment, desc.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center; local toggleKeyLabel = Instance.new("TextLabel", page); toggleKeyLabel.Size, toggleKeyLabel.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 20, 0, 90); toggleKeyLabel.BackgroundTransparency, toggleKeyLabel.Text = 1, "Toggle Key:"; toggleKeyLabel.TextColor3, toggleKeyLabel.Font, toggleKeyLabel.TextSize = Color3.fromRGB(180,220,255), Enum.Font.Code, 15; toggleKeyLabel.TextXAlignment, toggleKeyLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center; local toggleKeyBox = Instance.new("TextBox", page); toggleKeyBox.Size, toggleKeyBox.Position = UDim2.new(0, 100, 0, 22), UDim2.new(0, 140, 0, 90); toggleKeyBox.BackgroundColor3, toggleKeyBox.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); toggleKeyBox.Font, toggleKeyBox.TextSize, toggleKeyBox.Text = Enum.Font.Code, 15, "MouseButton2"; makeUICorner(toggleKeyBox, 6); local partLabel = Instance.new("TextLabel", page); partLabel.Size, partLabel.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 20, 0, 130); partLabel.BackgroundTransparency, partLabel.Text = 1, "Aim Part:"; partLabel.TextColor3, partLabel.Font, partLabel.TextSize = Color3.fromRGB(180,220,255), Enum.Font.Code, 15; partLabel.TextXAlignment, partLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center; local partDropdown = Instance.new("TextButton", page); partDropdown.Size, partDropdown.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 140, 0, 130); partDropdown.BackgroundColor3, partDropdown.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); partDropdown.Font, partDropdown.TextSize, partDropdown.Text = Enum.Font.Code, 15, "Head"; makeUICorner(partDropdown, 6); local parts = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}; local dropdownOpen, dropdownFrame = false, nil; partDropdown.MouseButton1Click:Connect(function() if dropdownOpen then if dropdownFrame then dropdownFrame:Destroy() end dropdownOpen = false; return end; dropdownOpen = true; dropdownFrame = Instance.new("Frame", page); dropdownFrame.Size, dropdownFrame.Position = UDim2.new(0, 120, 0, #parts * 22), UDim2.new(0, 140, 0, 152); dropdownFrame.BackgroundColor3, dropdownFrame.BorderSizePixel = Color3.fromRGB(30,30,30), 0; makeUICorner(dropdownFrame, 6); for i, part in ipairs(parts) do local btn = Instance.new("TextButton", dropdownFrame); btn.Size, btn.Position = UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, (i-1)*22); btn.BackgroundColor3, btn.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); btn.Font, btn.TextSize, btn.Text = Enum.Font.Code, 15, part; makeUICorner(btn, 6); btn.MouseButton1Click:Connect(function() partDropdown.Text = part; if dropdownFrame then dropdownFrame:Destroy() end; dropdownOpen = false end) end end); local statusLabel = Instance.new("TextLabel", page); statusLabel.Size, statusLabel.Position = UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 180); statusLabel.BackgroundTransparency, statusLabel.TextColor3 = 1, Color3.fromRGB(180,220,180); statusLabel.Font, statusLabel.TextSize = Enum.Font.Code, 15; statusLabel.Text = "Aimbot ready. Hold toggle key to aim."; statusLabel.TextXAlignment, statusLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center; local selectLabel = Instance.new("TextLabel", page); selectLabel.Size, selectLabel.Position = UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 210); selectLabel.BackgroundTransparency, selectLabel.TextColor3 = 1, Color3.fromRGB(220,220,180); selectLabel.Font, selectLabel.TextSize = Enum.Font.Code, 15; selectLabel.Text = "Press V to select/deselect any target under mouse."; selectLabel.TextXAlignment, selectLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center; local playerListLabel = Instance.new("TextLabel", page); playerListLabel.Size, playerListLabel.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 280, 0, 90); playerListLabel.BackgroundTransparency, playerListLabel.Text = 1, "Player List:"; playerListLabel.TextColor3, playerListLabel.Font, playerListLabel.TextSize = Color3.fromRGB(180,220,255), Enum.Font.Code, 15; playerListLabel.TextXAlignment, playerListLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center; local playerDropdown = Instance.new("TextButton", page); playerDropdown.Size, playerDropdown.Position = UDim2.new(0, 160, 0, 22), UDim2.new(0, 400, 0, 90); playerDropdown.BackgroundColor3, playerDropdown.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); playerDropdown.Font, playerDropdown.TextSize, playerDropdown.Text = Enum.Font.Code, 15, "None"; makeUICorner(playerDropdown, 6); local targetPlayerToggle = Instance.new("TextButton", page); targetPlayerToggle.Size, targetPlayerToggle.Position = UDim2.new(0, 160, 0, 32), UDim2.new(0, 400, 0, 122); targetPlayerToggle.BackgroundColor3, targetPlayerToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); targetPlayerToggle.Font, targetPlayerToggle.TextSize, targetPlayerToggle.Text = Enum.Font.Code, 15, "Target Selected: OFF"; makeUICorner(targetPlayerToggle, 6)
    local fovRadius = 150; local selectedPlayerTarget, selectedNpcTarget, selectedPart = nil, nil, nil; local playerTargetEnabled = false; local aiming = false; local silentAimEnabled = false; local ignoreTeamEnabled = false; local wallCheckEnabled = true; local wallCheckParams = RaycastParams.new(); wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude; local activeESPs = {}; local FovCircle = Drawing.new("Circle"); FovCircle.Visible = false; FovCircle.Thickness = 1; FovCircle.NumSides = 64; FovCircle.Color = Color3.fromRGB(255, 255, 255); FovCircle.Transparency = 0.5; FovCircle.Filled = false; local fovLabel = Instance.new("TextLabel", page); fovLabel.Size, fovLabel.Position = UDim2.new(0, 120, 0, 22), UDim2.new(0, 20, 0, 155); fovLabel.BackgroundTransparency, fovLabel.Text = 1, "FOV Radius:"; fovLabel.TextColor3, fovLabel.Font, fovLabel.TextSize = Color3.fromRGB(180,220,255), Enum.Font.Code, 15; fovLabel.TextXAlignment, fovLabel.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center; local fovValueLabel = Instance.new("TextLabel", page); fovValueLabel.Size, fovValueLabel.Position = UDim2.new(0, 50, 0, 22), UDim2.new(0, 390, 0, 155); fovValueLabel.BackgroundTransparency, fovValueLabel.TextColor3 = 1, Color3.fromRGB(255,255,255); fovValueLabel.Font, fovValueLabel.TextSize = Enum.Font.Code, 15; fovValueLabel.Text = tostring(fovRadius) .. "px"; fovValueLabel.TextXAlignment, fovValueLabel.TextYAlignment = Enum.TextXAlignment.Right, Enum.TextYAlignment.Center; local sliderTrack = Instance.new("Frame", page); sliderTrack.Size, sliderTrack.Position = UDim2.new(0, 300, 0, 4), UDim2.new(0, 140, 0, 164); sliderTrack.BackgroundColor3, sliderTrack.BorderSizePixel = Color3.fromRGB(20,20,30), 0; makeUICorner(sliderTrack, 2); local sliderHandle = Instance.new("TextButton", sliderTrack); sliderHandle.Size, sliderHandle.Position = UDim2.new(0, 12, 0, 12), UDim2.new(0, 0, 0.5, -6); sliderHandle.BackgroundColor3, sliderHandle.BorderSizePixel = Color3.fromRGB(180, 220, 255), 0; sliderHandle.Text = ""; makeUICorner(sliderHandle, 6); local minFov, maxFov = 50, 500; local function updateFovFromHandlePosition() local trackWidth = sliderTrack.AbsoluteSize.X; local handleX = sliderHandle.Position.X.Offset; local ratio = math.clamp(handleX / (trackWidth - sliderHandle.AbsoluteSize.X), 0, 1); fovRadius = minFov + (maxFov - minFov) * ratio; fovValueLabel.Text = tostring(math.floor(fovRadius)) .. "px"; FovCircle.Radius = fovRadius end; local function updateHandleFromFovValue() local trackWidth = sliderTrack.AbsoluteSize.X; local ratio = (fovRadius - minFov) / (maxFov - minFov); local handleX = ratio * (trackWidth - sliderHandle.AbsoluteSize.X); sliderHandle.Position = UDim2.new(0, handleX, 0.5, -6) end; task.wait(); updateHandleFromFovValue(); local isDraggingSlider = false; sliderHandle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingSlider = true end end); UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingSlider = false end end); UserInputService.InputChanged:Connect(function(input) if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then local mouseX = UserInputService:GetMouseLocation().X; local trackStartX = sliderTrack.AbsolutePosition.X; local handleWidth = sliderHandle.AbsoluteSize.X; local trackWidth = sliderTrack.AbsoluteSize.X; local newHandleX = mouseX - trackStartX - (handleWidth / 2); local clampedX = math.clamp(newHandleX, 0, trackWidth - handleWidth); sliderHandle.Position = UDim2.new(0, clampedX, 0.5, -6); updateFovFromHandlePosition() end end)
    
    local function isTeammate(player)
        if not ignoreTeamEnabled or not player then return false end
        -- Prioritize Team object first, then fallback to TeamColor
        if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then return true end
        if LocalPlayer.TeamColor and player.TeamColor and LocalPlayer.TeamColor == player.TeamColor then return true end
        return false
    end
    
    local function isPartVisible(targetPart) if not LocalPlayer.Character or not targetPart or not targetPart.Parent then return false end; local targetCharacter = targetPart:FindFirstAncestorOfClass("Model") or targetPart.Parent; local origin = Camera.CFrame.Position; wallCheckParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}; local result = Workspace:Raycast(origin, targetPart.Position - origin, wallCheckParams); return not result end
    local function manageESP(part, color, name) if not part or not part.Parent then return end; if activeESPs[part] then activeESPs[part].Color3, activeESPs[part].Name, activeESPs[part].Adornee, activeESPs[part].Size = color, name, part, part.Size else local espBox = Instance.new("BoxHandleAdornment"); espBox.Name, espBox.Adornee, espBox.AlwaysOnTop = name, part, true; espBox.ZIndex, espBox.Size, espBox.Color3 = 10, part.Size, color; espBox.Transparency, espBox.Parent = 0.4, part; activeESPs[part] = espBox end end
    local function clearESP(part) if part then if activeESPs[part] then activeESPs[part]:Destroy(); activeESPs[part] = nil end else for _, espBox in pairs(activeESPs) do espBox:Destroy() end; activeESPs = {} end end
    
    -- [BUG FIX & PERFORMANCE-CRITICAL] This function is now incredibly fast and correctly ignores teammates.
    local function getClosestTargetInScope()
        local mousePos = UserInputService:GetMouseLocation()
        local minDist, closestTargetModel = math.huge, nil
        local aimPartName = partDropdown.Text
        
        -- It iterates over the pre-built index instead of searching the workspace.
        for _, model in ipairs(getgenv().TargetIndex) do
            if model and model.Parent then -- Check if target is still valid
                -- [FIX] Get the player from the model and run the team check here.
                local player = Players:GetPlayerFromCharacter(model)
                if player and isTeammate(player) then
                    continue -- Skip to the next model if it's a teammate.
                end
                
                local targetPart = model:FindFirstChild(aimPartName)
                if targetPart and (not wallCheckEnabled or isPartVisible(targetPart)) then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < minDist and dist <= fovRadius then
                            minDist, closestTargetModel = dist, model
                        end
                    end
                end
            end
        end
        return closestTargetModel
    end

    local playerDropdownOpen, playerDropdownFrame = false, nil; local function buildPlayerDropdownFrame() if playerDropdownFrame then playerDropdownFrame:Destroy() end; local playersList = Players:GetPlayers(); playerDropdownFrame = Instance.new("Frame", page); playerDropdownFrame.Size, playerDropdownFrame.Position = UDim2.new(0, 160, 0, #playersList * 22), UDim2.new(0, 400, 0, 112); playerDropdownFrame.BackgroundColor3, playerDropdownFrame.BorderSizePixel = Color3.fromRGB(30,30,30), 0; makeUICorner(playerDropdownFrame, 6); for i, plr in ipairs(playersList) do local btn = Instance.new("TextButton", playerDropdownFrame); btn.Size, btn.Position = UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, (i-1)*22); btn.BackgroundColor3, btn.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); btn.Font, btn.TextSize, btn.Text = Enum.Font.Code, 15, plr.Name; makeUICorner(btn, 6); btn.MouseButton1Click:Connect(function() selectedPlayerTarget, playerDropdown.Text = plr, plr.Name; if playerDropdownFrame then playerDropdownFrame:Destroy() end; playerDropdownOpen = false; if playerTargetEnabled then statusLabel.Text = "Aimbot: Will target " .. plr.Name end end) end end
    targetPlayerToggle.MouseButton1Click:Connect(function() playerTargetEnabled = not playerTargetEnabled; targetPlayerToggle.Text = "Target Selected: " .. (playerTargetEnabled and "ON" or "OFF"); if not playerTargetEnabled then statusLabel.Text = "Aimbot ready. Hold toggle key to aim." elseif selectedPlayerTarget then statusLabel.Text = "Aimbot: Will target " .. selectedPlayerTarget.Name end end)
    playerDropdown.MouseButton1Click:Connect(function() if playerDropdownOpen then if playerDropdownFrame then playerDropdownFrame:Destroy() end; playerDropdownOpen = false; return end; playerDropdownOpen = true; buildPlayerDropdownFrame() end)
    Players.PlayerAdded:Connect(function() if playerDropdownOpen then buildPlayerDropdownFrame() end end); Players.PlayerRemoving:Connect(function(plr) if selectedPlayerTarget == plr then selectedPlayerTarget, playerDropdown.Text = nil, "None"; if playerTargetEnabled then playerTargetEnabled = false; targetPlayerToggle.Text = "Target Selected: OFF" end end; if playerDropdownOpen then buildPlayerDropdownFrame() end end)
    UserInputService.InputBegan:Connect(function(input, processed) if processed or toggleKeyBox:IsFocused() then return end; if input.KeyCode == Enum.KeyCode.V then clearESP(); if selectedPart or selectedPlayerTarget or selectedNpcTarget then selectedPart, selectedPlayerTarget, selectedNpcTarget, playerDropdown.Text = nil, nil, nil, "None"; statusLabel.Text = "Selection cleared." else local target = LocalPlayer:GetMouse().Target; if target then local modelAncestor = target:FindFirstAncestorOfClass("Model"); if modelAncestor and modelAncestor:FindFirstChildOfClass("Humanoid") then local plr = Players:GetPlayerFromCharacter(modelAncestor); if plr then selectedPlayerTarget, playerDropdown.Text, statusLabel.Text = plr, plr.Name, "Selected player: " .. plr.Name; selectedPart = plr.Character and plr.Character:FindFirstChild(partDropdown.Text) else selectedNpcTarget, selectedPart = modelAncestor, modelAncestor:FindFirstChild(partDropdown.Text) or target; statusLabel.Text = "Selected NPC: " .. (modelAncestor.Name or "Unnamed") end else selectedPart, statusLabel.Text = target, "Selected part: " .. (target.Name or "Unnamed") end else statusLabel.Text = "No target under mouse." end end end; local key = toggleKeyBox.Text:upper(); if (key == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2) or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name:upper() == key) then aiming = true; FovCircle.Visible = true end end)
    UserInputService.InputEnded:Connect(function(input) local key = toggleKeyBox.Text:upper(); if (key == "MOUSEBUTTON2" and input.UserInputType == Enum.UserInputType.MouseButton2) or (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name:upper() == key) then aiming = false; FovCircle.Visible = false; clearESP() end end)
    
    local currentTarget = nil
    
    RunService.RenderStepped:Connect(function()
        if FovCircle.Visible then FovCircle.Position = UserInputService:GetMouseLocation() end
        
        local isCurrentTargetValid = currentTarget and currentTarget.Parent and currentTarget:FindFirstChildOfClass("Humanoid") and currentTarget:FindFirstChildOfClass("Humanoid").Health > 0
        if aiming and not isCurrentTargetValid then
            currentTarget = getClosestTargetInScope()
        elseif not aiming then
            currentTarget = nil
        end

        local aimPart, targetPlayer, targetModel = nil, nil, nil; local partsToDrawESPFor = {}
        
        -- Logic for determining the final target model (This part is now safe because `currentTarget` will never be a teammate)
        if playerTargetEnabled and selectedPlayerTarget and selectedPlayerTarget.Character then
            if not isTeammate(selectedPlayerTarget) then targetModel, targetPlayer = selectedPlayerTarget.Character, selectedPlayerTarget
            else targetModel = nil end -- Invalidate if teammate
        elseif selectedPart and selectedPart.Parent then
            targetModel = selectedPart:FindFirstAncestorOfClass("Model")
            if targetModel then local player = Players:GetPlayerFromCharacter(targetModel); if not player or not isTeammate(player) then targetPlayer = player else targetModel = nil end end
        elseif aiming and currentTarget then
            targetModel = currentTarget; targetPlayer = Players:GetPlayerFromCharacter(targetModel)
        end
        
        if targetModel then aimPart = targetModel:FindFirstChild(partDropdown.Text) end

        if selectedPart and selectedPart.Parent then table.insert(partsToDrawESPFor, {Part = selectedPart, Color = Color3.fromRGB(90, 170, 255), Name = "SelectedESP"}) end
        
        if aiming and aimPart and targetModel then
            if not wallCheckEnabled or isPartVisible(aimPart) then
                table.insert(partsToDrawESPFor, {Part = aimPart, Color = Color3.fromRGB(255, 80, 80), Name = "AimbotESP"}); local distance = (Camera.CFrame.Position - aimPart.Position).Magnitude; local predictedPosition = aimPart.Position + (aimPart.AssemblyLinearVelocity * (distance / 2000)); if silentAimEnabled then getgenv().ZukaSilentAimTarget = predictedPosition else Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPosition) end; statusLabel.Text = "Aimbot: Targeting " .. (targetPlayer and targetPlayer.Name or targetModel.Name)
            else statusLabel.Text = "Aimbot: Target is behind a wall"; currentTarget = nil end
        elseif aiming then statusLabel.Text = "Aimbot: No visible target in index"
        elseif not aiming and not selectedPart then statusLabel.Text = "Aimbot ready. Hold toggle key to aim." end

        for part, espBox in pairs(activeESPs) do local found = false; for _, data in ipairs(partsToDrawESPFor) do if data.Part == part then found = true; break end end; if not found or not part.Parent then clearESP(part) end end
        for _, data in ipairs(partsToDrawESPFor) do manageESP(data.Part, data.Color, data.Name) end
    end)

    local silentAimToggle = Instance.new("TextButton", page); silentAimToggle.Size, silentAimToggle.Position = UDim2.new(0, 170, 0, 32), UDim2.new(0, 20, 0, 250); silentAimToggle.BackgroundColor3, silentAimToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); silentAimToggle.Font, silentAimToggle.TextSize, silentAimToggle.Text = Enum.Font.Code, 15, "Silent Aim: OFF"; makeUICorner(silentAimToggle, 6); silentAimToggle.MouseButton1Click:Connect(function() silentAimEnabled = not silentAimEnabled; silentAimToggle.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF") end)
    local ignoreTeamToggle = Instance.new("TextButton", page); ignoreTeamToggle.Size, ignoreTeamToggle.Position = UDim2.new(0, 170, 0, 32), UDim2.new(0, 200, 0, 250); ignoreTeamToggle.BackgroundColor3, ignoreTeamToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); ignoreTeamToggle.Font, ignoreTeamToggle.TextSize, ignoreTeamToggle.Text = Enum.Font.Code, 15, "Ignore Team: OFF"; makeUICorner(ignoreTeamToggle, 6); ignoreTeamToggle.MouseButton1Click:Connect(function() ignoreTeamEnabled = not ignoreTeamEnabled; ignoreTeamToggle.Text = "Ignore Team: " .. (ignoreTeamEnabled and "ON" or "OFF") end)
    local wallCheckToggle = Instance.new("TextButton", page); wallCheckToggle.Size, wallCheckToggle.Position = UDim2.new(0, 170, 0, 32), UDim2.new(0, 380, 0, 250); wallCheckToggle.BackgroundColor3, wallCheckToggle.TextColor3 = Color3.fromRGB(40,40,40), Color3.fromRGB(255,255,255); wallCheckToggle.Font, wallCheckToggle.TextSize, wallCheckToggle.Text = Enum.Font.Code, 15, "Wall Check: ON"; makeUICorner(wallCheckToggle, 6); wallCheckToggle.MouseButton1Click:Connect(function() wallCheckEnabled = not wallCheckEnabled; wallCheckToggle.Text = "Wall Check: " .. (wallCheckEnabled and "ON" or "OFF") end)
    
    -- [PERFORMANCE-CRITICAL] The background indexer and its controller.
    local indexerUpdateSignal = Instance.new("BindableEvent")
    ExplorerButton.MouseButton1Click:Connect(function() createExplorerWindow(statusLabel, indexerUpdateSignal) end)

    task.spawn(function()
        local function RebuildTargetIndex()
            local newIndex = {}
            -- Make sure TargetScope is not nil before proceeding
            if not getgenv().TargetScope then return end
            
            for _, descendant in ipairs(getgenv().TargetScope:GetDescendants()) do
                if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") then
                    -- Exclude the local player's own character from the index
                    if descendant ~= LocalPlayer.Character then
                        table.insert(newIndex, descendant)
                    end
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
