--[[
    -- NPC Invisibility System (v2) --
    -- Architect: You
    -- Revision: Patched a state management flaw where the script could not find the HumanoidRootPart (HRP)
    --           to disable the ignore effect. The script now stores a direct reference to the HRP
    --           when it's moved, ensuring it can always be returned to the character.
]]

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

--// Local Player
local localPlayer = Players.LocalPlayer

--// =============================== CONFIGURATION ================================================
local ACTIVATION_KEY = Enum.KeyCode.V
--// ===============================================================================================

--// State Management
local isIgnored = false
local storedHrp = nil -- FIX: This variable will hold the HRP object itself
local originalHrpParent = nil
local character = nil

--// Core Logic
local function setIgnoreState(state)
    -- Ensure the character exists
    if not character or not character.Parent then
        warn("Cannot toggle ignore: Character not found.")
        return
    end

    if state == true then
        --// ENABLE IGNORE MODE
        if isIgnored then return end
        
        -- Find the HRP inside the character *before* we move it
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            warn("Failed to enable: HumanoidRootPart not found in character.")
            return
        end
        
        print("Enabling NPC Ignore...")
        
        -- FIX: Store the HRP and its original parent
        storedHrp = humanoidRootPart
        originalHrpParent = storedHrp.Parent
        
        -- Move the HRP to Lighting
        storedHrp.Parent = Lighting
        
        isIgnored = true
        print("NPCs should now ignore you. Press [" .. ACTIVATION_KEY.Name .. "] again to disable.")

    elseif state == false then
        --// DISABLE IGNORE MODE
        if not isIgnored then return end
        print("Disabling NPC Ignore...")
        
        -- FIX: Check our stored variables instead of searching the character
        if not storedHrp or not storedHrp.Parent then
            warn("Could not disable: Stored HumanoidRootPart is missing or destroyed.")
            isIgnored = false -- Reset state to prevent getting stuck
            return
        end
        
        if not originalHrpParent or not originalHrpParent.Parent then
            warn("Could not disable: Original character parent is gone. You may need to reset.")
            isIgnored = false
            return
        end

        -- Return the stored HRP to its original parent
        storedHrp.Parent = originalHrpParent
        
        -- Clean up state variables
        isIgnored = false
        storedHrp = nil
        originalHrpParent = nil
        
        print("You are now visible to NPCs again.")
    end
end

--// Event Handling
local function onCharacterAdded(newCharacter)
    character = newCharacter
    -- Cleanly reset the state if the player respawns
    if isIgnored then
        print("Character respawned. Ignore state reset.")
        isIgnored = false
        storedHrp = nil
        originalHrpParent = nil
    end
end

-- Connect the function if a character already exists
if localPlayer.Character then
    onCharacterAdded(localPlayer.Character)
end
localPlayer.CharacterAdded:Connect(onCharacterAdded)

--// Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == ACTIVATION_KEY then
        setIgnoreState(not isIgnored)
    end
end)

print("NPC Ignore script (v2) loaded. Press [" .. ACTIVATION_KEY.Name .. "] to toggle.")
