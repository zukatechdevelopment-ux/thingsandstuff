-- ==========================================================
-- Services & Globals
-- ==========================================================
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================================
-- Configuration & Theme
-- ==========================================================
local Theme = {
    Background = Color3.fromRGB(35, 35, 45), Primary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(255, 80, 80), Text = Color3.fromRGB(200, 220, 255),
    TextSecondary = Color3.fromRGB(220, 180, 180), Interactive = Color3.fromRGB(40, 40, 40),
    Font = Enum.Font.Code, CornerRadius = 8
}

local Settings = {
    Enabled = false, AutoAttack = false, AutoCycle = false, HoverDistance = 6, AttackCPS = 10,
    Target = nil, LerpSpeed = 0.15, BoxReachEnabled = false,
    BoxReachSize = Vector3.new(15, 15, 15),
    BoxReachSelectedPart = nil
}

-- ==========================================================
-- Core Logic & UI State Variables
-- ==========================================================
local mainConnection, lastAttackTime = nil, 0
local equippedTool, playerList = nil, {}
local currentTargetIndex = 1
local reachSelectionBox = nil
local characterConnections = {}
local isMinimized = false -- [NEW] State for minimize feature
local originalMainWindowSize = UDim2.new(0, 600, 0, 280) -- Store original size

-- ==========================================================
-- PHASE 1: CREATE ALL UI INSTANCES
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "RageBotMenuGUI_Complete"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.ResetOnSpawn = false

local function makeUICorner(e, r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or Theme.CornerRadius);c.Parent=e end

local MainWindow = Instance.new("Frame", ScreenGui)
MainWindow.Name = "MainWindow"; MainWindow.Size = originalMainWindowSize; MainWindow.Position = UDim2.new(0.5, -300, 0.5, -140); MainWindow.BackgroundColor3 = Theme.Background; MainWindow.Active = true; makeUICorner(MainWindow)

local TopBar = Instance.new("Frame", MainWindow)
TopBar.Name = "TopBar"; TopBar.Size=UDim2.new(1,0,0,30); TopBar.BackgroundColor3=Theme.Primary; do local c=Instance.new("UICorner",TopBar);c.CornerRadius=UDim.new(0,Theme.CornerRadius)end

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Name="TitleLabel";TitleLabel.Size=UDim2.new(1,-40,1,0);TitleLabel.Position=UDim2.new(0,10,0,0);TitleLabel.BackgroundTransparency=1;TitleLabel.Font=Theme.Font;TitleLabel.Text="Rage Bot (Complete)";TitleLabel.TextColor3=Theme.Text;TitleLabel.TextSize=16;TitleLabel.TextXAlignment=Enum.TextXAlignment.Left

-- [NEW] Minimize Button created
local MinimizeButton = Instance.new("TextButton", TopBar)
MinimizeButton.Name = "MinimizeButton"; MinimizeButton.Size = UDim2.new(0,24,0,24); MinimizeButton.Position=UDim2.new(1,-28,0.5,-12); MinimizeButton.BackgroundColor3=Color3.fromRGB(80,80,100); MinimizeButton.Font=Theme.Font; MinimizeButton.TextColor3=Color3.new(1,1,1); MinimizeButton.Text="-"; MinimizeButton.TextSize=14; makeUICorner(MinimizeButton,6)

local ContentPage = Instance.new("Frame", MainWindow)
ContentPage.Name="ContentPage";ContentPage.Size=UDim2.new(1,0,1,-30);ContentPage.Position=UDim2.new(0,0,0,30);ContentPage.BackgroundTransparency=1
local LeftColumn=Instance.new("Frame",ContentPage);LeftColumn.Name="LeftColumn";LeftColumn.Size=UDim2.new(0.5,-10,1,-20);LeftColumn.Position=UDim2.new(0,10,0,10);LeftColumn.BackgroundTransparency=1;local LeftLayout=Instance.new("UIListLayout",LeftColumn);LeftLayout.Padding=UDim.new(0,10);LeftLayout.SortOrder=Enum.SortOrder.LayoutOrder
local RightColumn=Instance.new("Frame",ContentPage);RightColumn.Name="RightColumn";RightColumn.Size=UDim2.new(0.5,-10,1,-20);RightColumn.Position=UDim2.new(0.5,0,0,10);RightColumn.BackgroundTransparency=1;local RightLayout=Instance.new("UIListLayout",RightColumn);RightLayout.Padding=UDim.new(0,10);RightLayout.SortOrder=Enum.SortOrder.LayoutOrder
local playerSelectorContainer=Instance.new("Frame",LeftColumn);playerSelectorContainer.Size=UDim2.new(1,0,0,64);playerSelectorContainer.BackgroundTransparency=1;playerSelectorContainer.LayoutOrder=1
local playerSelectorLabel=Instance.new("TextLabel",playerSelectorContainer);playerSelectorLabel.Size=UDim2.new(1,0,0,30);playerSelectorLabel.BackgroundTransparency=1;playerSelectorLabel.Text="Target Player:";playerSelectorLabel.TextColor3=Theme.TextSecondary;playerSelectorLabel.Font=Theme.Font;playerSelectorLabel.TextSize=15;playerSelectorLabel.TextXAlignment=Enum.TextXAlignment.Left
local playerDropdownButton=Instance.new("TextButton",playerSelectorContainer);playerDropdownButton.Size=UDim2.new(0.6,-5,0,28);playerDropdownButton.Position=UDim2.new(0,0,0,30);playerDropdownButton.BackgroundColor3=Theme.Interactive;playerDropdownButton.TextColor3=Theme.Text;playerDropdownButton.Font=Theme.Font;playerDropdownButton.TextSize=15;playerDropdownButton.Text="Select Player";makeUICorner(playerDropdownButton,6)
local cycleToggleButton=Instance.new("TextButton",playerSelectorContainer);cycleToggleButton.Size=UDim2.new(0.4,0,0,28);cycleToggleButton.Position=UDim2.new(0.6,5,0,30);cycleToggleButton.BackgroundColor3=Theme.Interactive;cycleToggleButton.TextColor3=Theme.Text;cycleToggleButton.Font=Theme.Font;cycleToggleButton.TextSize=16;makeUICorner(cycleToggleButton,6)
local rageBotToggleContainer=Instance.new("Frame",LeftColumn);rageBotToggleContainer.LayoutOrder=2;local rageBotToggle=Instance.new("TextButton",rageBotToggleContainer)
local autoAttackToggleContainer=Instance.new("Frame",LeftColumn);autoAttackToggleContainer.LayoutOrder=3;local autoAttackToggle=Instance.new("TextButton",autoAttackToggleContainer)
local cpsInputContainer=Instance.new("Frame",LeftColumn);cpsInputContainer.LayoutOrder=4;local cpsInput=Instance.new("TextBox",cpsInputContainer)
local distanceInputContainer=Instance.new("Frame",LeftColumn);distanceInputContainer.LayoutOrder=5;local distanceInput=Instance.new("TextBox",distanceInputContainer)
local rightTitle=Instance.new("TextLabel",RightColumn);rightTitle.Size=UDim2.new(1,0,0,20);rightTitle.BackgroundTransparency=1;rightTitle.Font=Theme.Font;rightTitle.TextColor3=Theme.Accent;rightTitle.TextSize=18;rightTitle.Text="BoxReach Module";rightTitle.LayoutOrder=0
local boxReachToggleContainer=Instance.new("Frame",RightColumn);boxReachToggleContainer.LayoutOrder=1;local boxReachToggle=Instance.new("TextButton",boxReachToggleContainer)
local sizeInputContainer=Instance.new("Frame",RightColumn);sizeInputContainer.LayoutOrder=2;local sizeInput=Instance.new("TextBox",sizeInputContainer)
local partsFrame=Instance.new("Frame",RightColumn);partsFrame.LayoutOrder=3;partsFrame.Size=UDim2.new(1,0,0,120);partsFrame.BackgroundTransparency=1
local partsLabel=Instance.new("TextLabel",partsFrame);partsLabel.Size=UDim2.new(1,0,0,20);partsLabel.BackgroundTransparency=1;partsLabel.Font=Theme.Font;partsLabel.TextColor3=Theme.TextSecondary;partsLabel.Text="Tool Parts:"
local partsScroll=Instance.new("ScrollingFrame",partsFrame);partsScroll.Size=UDim2.new(1,0,1,-20);partsScroll.Position=UDim2.new(0,0,0,20);partsScroll.BackgroundColor3=Theme.Primary;partsScroll.BorderSizePixel=0
local partsLayout=Instance.new("UIListLayout",partsScroll);partsLayout.Padding=UDim.new(0,5)

-- ==========================================================
-- PHASE 2: DEFINE ALL FUNCTIONS
-- ==========================================================
function resetAllToolParts(tool) if not tool then return end;for _,d in ipairs(tool:GetDescendants())do if d:IsA("BasePart")then local o=d:FindFirstChild("OriginalSize");if o then d.Size=o.Value;o:Destroy()end end end;if reachSelectionBox then reachSelectionBox:Destroy();reachSelectionBox=nil end end
function applyBoxReach() if not Settings.BoxReachEnabled or not Settings.BoxReachSelectedPart or not Settings.BoxReachSelectedPart.Parent then return end;local p=Settings.BoxReachSelectedPart;if not p:FindFirstChild("OriginalSize")then local v=Instance.new("Vector3Value",p);v.Name="OriginalSize";v.Value=p.Size end;p.Size=Settings.BoxReachSize;if reachSelectionBox then reachSelectionBox:Destroy()end;reachSelectionBox=Instance.new("SelectionBox");reachSelectionBox.Adornee=p;reachSelectionBox.LineThickness=0.02;reachSelectionBox.Color3=Theme.Accent;reachSelectionBox.Parent=p end
function handleMovement(mR,tR)local bV=-tR.CFrame.LookVector;local tP=tR.Position+(bV*Settings.HoverDistance);local nCF=CFrame.lookAt(tP,tR.Position);mR.CFrame=mR.CFrame:Lerp(nCF,Settings.LerpSpeed)end;function handleAutoAttack()if not Settings.AutoAttack or not equippedTool then return end;local aI=1/Settings.AttackCPS;if os.clock()-lastAttackTime>=aI then lastAttackTime=os.clock();pcall(function()equippedTool:Activate()end)end end;function startBot()if mainConnection then return end;mainConnection=RunService.RenderStepped:Connect(function()if not Settings.Enabled or not Settings.Target or not Settings.Target.Character then return end;local mC,tC=LocalPlayer.Character,Settings.Target.Character;local mR,mH,tR=mC and mC:FindFirstChild("HumanoidRootPart"),mC and mC:FindFirstChildOfClass("Humanoid"),tC and tC:FindFirstChild("HumanoidRootPart");if not(mR and mH and mH.Health>0 and tR)then return end;handleMovement(mR,tR);handleAutoAttack()end)end;function stopBot()if mainConnection then mainConnection:Disconnect();mainConnection=nil end end
function populatePartList() for _,c in ipairs(partsScroll:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end;Settings.BoxReachSelectedPart = nil;if not equippedTool then return end;local selectedButton = nil;for _,p in ipairs(equippedTool:GetDescendants())do if p:IsA("BasePart")then local b=Instance.new("TextButton",partsScroll);b.Size=UDim2.new(1,-10,0,25);b.BackgroundColor3=Theme.Interactive;b.TextColor3=Theme.Text;b.Font=Theme.Font;b.Text=p.Name;b.MouseButton1Click:Connect(function()resetAllToolParts(equippedTool);Settings.BoxReachSelectedPart=p;applyBoxReach();if selectedButton then selectedButton.BackgroundColor3=Theme.Interactive end;b.BackgroundColor3=Theme.Accent;selectedButton=b end)end end end
function cleanupConnections() for i,v in ipairs(characterConnections) do v:Disconnect() end; characterConnections = {} end
function trackEquippedTool(character) cleanupConnections();resetAllToolParts(equippedTool);equippedTool = character:FindFirstChildOfClass("Tool");populatePartList();table.insert(characterConnections, character.ChildAdded:Connect(function(c)if c:IsA("Tool")then resetAllToolParts(equippedTool);equippedTool=c;populatePartList()end end));table.insert(characterConnections, character.ChildRemoved:Connect(function(c)if c==equippedTool then resetAllToolParts(equippedTool);equippedTool=nil;populatePartList()end end))end
function createToggle(button, container, text, default, cb) container.Size=UDim2.new(1,0,0,32);container.BackgroundTransparency=1;button.Size=UDim2.new(1,0,1,0);button.BackgroundColor3=Theme.Interactive;button.TextColor3=Theme.Text;button.Font=Theme.Font;button.TextSize=16;makeUICorner(button,6);local s=default;button.Text=text..": "..(s and"ON"or"OFF");button.MouseButton1Click:Connect(function()s=not s;button.Text=text..": "..(s and"ON"or"OFF");if cb then cb(s)end end)end
function createInput(textBox, container, label, default, cb) container.Size=UDim2.new(1,0,0,32);container.BackgroundTransparency=1;local l=Instance.new("TextLabel",container);l.Size=UDim2.new(0.45,0,1,0);l.BackgroundTransparency=1;l.Text=label..":";l.TextColor3=Theme.TextSecondary;l.Font=Theme.Font;l.TextSize=15;l.TextXAlignment=Enum.TextXAlignment.Left;textBox.Size=UDim2.new(0.55,0,1,0);textBox.Position=UDim2.new(0.45,0,0,0);textBox.BackgroundColor3=Theme.Interactive;textBox.TextColor3=Theme.Text;textBox.Font=Theme.Font;textBox.TextSize=15;textBox.Text=tostring(default);makeUICorner(textBox,6);textBox.FocusLost:Connect(function(e)if e then textBox.Text=tostring(cb(textBox.Text))else textBox.Text=tostring(cb(nil))end end)end

-- ==========================================================
-- PHASE 3: CONNECT ALL LOGIC TO UI
-- ==========================================================
-- ## Draggable & Minimize Logic ##
do local iS=false;local dS,sP;TopBar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then iS=true;dS=i.Position;sP=MainWindow.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then iS=false end end)end end);UserInputService.InputChanged:Connect(function(i)if(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)and iS then local d=i.Position-dS;MainWindow.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y)end end)end
-- [NEW] Minimize button logic connected here
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentPage.Visible = not isMinimized
    if isMinimized then
        MainWindow.Size = UDim2.new(0, 200, 0, 30)
        MinimizeButton.Text = "+"
    else
        MainWindow.Size = originalMainWindowSize
        MinimizeButton.Text = "-"
    end
end)

-- ## Left Column Logic ##
local cycleState = Settings.AutoCycle; cycleToggleButton.Text = "Cycle: " .. (cycleState and "ON" or "OFF")
cycleToggleButton.MouseButton1Click:Connect(function()cycleState = not cycleState;Settings.AutoCycle = cycleState;cycleToggleButton.Text = "Cycle: " .. (cycleState and "ON" or "OFF")end)
local function refreshPlayerList()playerList={};for _,p in ipairs(Players:GetPlayers())do if p~=LocalPlayer then table.insert(playerList,p)end end;if #playerList>0 then currentTargetIndex=math.clamp(currentTargetIndex,1,#playerList);Settings.Target=playerList[currentTargetIndex];playerDropdownButton.Text=Settings.Target.Name else Settings.Target=nil;playerDropdownButton.Text="No Players"end end;playerDropdownButton.MouseButton1Click:Connect(function()if #playerList==0 then return end;currentTargetIndex=(currentTargetIndex%#playerList)+1;Settings.Target=playerList[currentTargetIndex];playerDropdownButton.Text=Settings.Target.Name end);task.spawn(function()while true do task.wait(3);if Settings.AutoCycle and Settings.Enabled and #playerList>1 then currentTargetIndex=(currentTargetIndex%#playerList)+1;Settings.Target=playerList[currentTargetIndex];playerDropdownButton.Text=Settings.Target.Name end end end);refreshPlayerList();Players.PlayerAdded:Connect(refreshPlayerList);Players.PlayerRemoving:Connect(refreshPlayerList)
createToggle(rageBotToggle, rageBotToggleContainer, "Rage Bot", Settings.Enabled, function(s) Settings.Enabled=s;if s then startBot() else stopBot() end end)
createToggle(autoAttackToggle, autoAttackToggleContainer, "Auto Attack", Settings.AutoAttack, function(s) Settings.AutoAttack=s end)
createInput(cpsInput, cpsInputContainer, "CPS", Settings.AttackCPS, function(v) if v and tonumber(v) and tonumber(v)>0 and tonumber(v)<=30 then Settings.AttackCPS=tonumber(v) end;return Settings.AttackCPS end)
createInput(distanceInput, distanceInputContainer, "Distance", Settings.HoverDistance, function(v) if v and tonumber(v) and tonumber(v)>=2 and tonumber(v)<=20 then Settings.HoverDistance=tonumber(v) end;return Settings.HoverDistance end)

-- ## Right Column Logic ##
createToggle(boxReachToggle, boxReachToggleContainer, "BoxReach", Settings.BoxReachEnabled, function(s) Settings.BoxReachEnabled=s;if s then applyBoxReach()else resetAllToolParts(equippedTool)end end)
createInput(sizeInput, sizeInputContainer, "Size", "15,15,15", function(t) if t then local n={};for m in string.gmatch(t,"[^,]+")do table.insert(n,tonumber(m))end;if #n==3 and n[1]and n[2]and n[3]then Settings.BoxReachSize=Vector3.new(n[1],n[2],n[3]);applyBoxReach()end end;return string.format("%.1f,%.1f,%.1f",Settings.BoxReachSize.X,Settings.BoxReachSize.Y,Settings.BoxReachSize.Z)end)

-- ## Final Character Setup ##
if LocalPlayer.Character then trackEquippedTool(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(trackEquippedTool)
