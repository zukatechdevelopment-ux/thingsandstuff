-- =================================================================================
-- ZUKA HUB - MIGRATED TO MERCURY UI
-- Architect: Your AI Assistant
-- Description: The full functionality of the ZukasRayfield hub has been
--              transplanted into the Mercury UI library. All original
--              features and addon scripts are preserved.
-- =================================================================================

-- [ Mercury Library Source Code ]
-- The entire "Mercury Lib Source.txt" content is placed here.
-- For brevity in this response, I've collapsed it. The code below assumes it's present.
-- <PASTE THE ENTIRE MERCURY LIB SOURCE.TXT SCRIPT HERE>
-- [ End of Mercury Library Source Code ]

-- After pasting the library code above this line, the migration logic begins:

print("[ZukaHub -> Mercury] Starting migration...")

-- Step 1: Create the Main Window using Mercury
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local MainWindow = Mercury:create({
    Name = "Zuka Hub",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/zukatech" -- Example link
})

print("[ZukaHub -> Mercury] Main window created.")

-- Step 2: Create the Tabs
local CommandsTab = MainWindow:tab({ Name = "Commands", Icon = "rbxassetid://4483362458" })
local UtilityTab = MainWindow:tab({ Name = "Utilities", Icon = "rbxassetid://4483362458" })
local SettingsTab = MainWindow:tab({ Name = "Hub Settings", Icon = "rbxassetid://4483362458" })

print("[ZukaHub -> Mercury] Tabs created.")

-- ============================================================================
-- === COMMANDS TAB ===
-- ============================================================================

local CommandsSection = CommandsTab:section({ Name = "Main Addons" })

-- Re-implement the 'safeButton' helper function for Mercury
-- This preserves the core logic of your original script.
local function normalizeUrl(url)
    if not url or type(url) ~= "string" then return url end
    if url:find("raw.githubusercontent.com") then return url end
    if url:find("github.com") then
        url = url:gsub("https://github.com/", "https://raw.githubusercontent.com/")
        url = url:gsub("/blob/", "/")
        url = url:gsub("/tree/", "/")
        url = url:gsub("/refs/heads/", "/")
        return url
    end
    if url:find("pastebin.com/") and not url:find("pastebin.com/raw/") then
        return url:gsub("pastebin.com/", "pastebin.com/raw/")
    end
    return url
end

local function safeButton(name, url, successMsg)
    CommandsSection:button({
        Name = name,
        Callback = function()
            local finalUrl = normalizeUrl(url)
            MainWindow:set_status("Fetching " .. name .. "...")
            local fetchOk, src = pcall(function() return game:HttpGet(finalUrl) end)
            
            if not fetchOk or not src then
                MainWindow:set_status("Error fetching addon.")
                warn("Failed to fetch " .. tostring(name) .. " from " .. tostring(finalUrl))
                return
            end
            
            local func, loadErr = loadstring(src)
            if not func then
                MainWindow:set_status("Error loading addon.")
                warn("Failed to load string for " .. tostring(name) .. ": " .. tostring(loadErr))
                return
            end
            
            local ranOk, runErr = pcall(func)
            if ranOk then
                MainWindow:set_status(successMsg or (name .. " Loaded"))
                print(successMsg or (name .. " Loaded"))
            else
                MainWindow:set_status("Error running addon.")
                warn("Error running " .. tostring(name) .. ": " .. tostring(runErr))
            end
        end
    })
end

-- Create all the addon buttons using the migrated helper function
print("[ZukaHub -> Mercury] Populating Commands tab...")
safeButton("Aimbot", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/trashaimbot.lua", "Aimbot Started")
safeButton("Fly GUI", "https://raw.githubusercontent.com/396abc/Script/refs/heads/main/FlyR15.lua", "Fly GUI Started")
safeButton("Zukas Admin", "https://raw.githubusercontent.com/zukatechdevelopment-ux/thingsandstuff/refs/heads/main/Admin.lua", "Admin Activated")
safeButton("Dex++", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/CustomDex.lua", "Dex Loaded")
safeButton("Zenith Hub +", "https://raw.githubusercontent.com/Zenith-Devs/Zenith-Hub/main/loader", "UI Activated")
safeButton("Wall-Walking", "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/WallWalk.lua", "Swag Started")
safeButton("Script-Blox API", "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/ScriptHubNA.lua", "Server Searcher Loaded")
safeButton("Universe Explorer", "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer", "Explorer Loaded")
safeButton("Server Hopper", "https://raw.githubusercontent.com/Pnsdgsa/Script-kids/refs/heads/main/Advanced%20Server%20Hop.lua", "GUI Started..")
safeButton("Fling GUI", "https://raw.githubusercontent.com/miso517/scirpt/refs/heads/main/main.lua", "Fling GUI Loaded")
safeButton("Blox Fruits", "https://rawscripts.net/raw/Arise-Crossover-Speed-Hub-X-33730", "Blox Fruits")
safeButton("Copy Console", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/consolecopy.lua", "Loaded")
safeButton("Player Attach + Follower", "https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/flingaddon.lua", "Follower GUI Loaded")
safeButton("Reach Modifier", "https://raw.githubusercontent.com/zukatechdevelopment-ux/luaprojectse3/refs/heads/main/Tool%20Modifier.lua", "Gui Loaded")
safeButton("Working Chat Bypass", "https://raw.githubusercontent.com/shadow62x/catbypass/main/upfix", "Bypass Activated")
safeButton("Ketamine/Spy", "https://raw.githubusercontent.com/InfernusScripts/Ketamine/refs/heads/main/Ketamine.lua", "Cherry Activated")
safeButton("ZukaBot AI V1", "https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/Broken.lua", "Bot v1 Loaded")
safeButton("ZukaBot AI V2", "https://raw.githubusercontent.com/theogcheater2020-pixel/luaprojects2/refs/heads/main/chat.lua", "Bot v2 Loaded")
safeButton("Zombie Game Upd3", "https://raw.githubusercontent.com/osukfcdays/zlfucker/refs/heads/main/.luau", "Zombie GUI Started")
safeButton("Zombie Attack Auto", "https://raw.githubusercontent.com/evelynnscripts/Evelynn-Hub/refs/heads/main/zombie-attack.lua", "Hub Loaded")

-- ============================================================================
-- === UTILITIES TAB ===
-- ============================================================================

local UtilitySection = UtilityTab:section({ Name = "Utilities" })

print("[ZukaHub -> Mercury] Populating Utilities tab...")
UtilitySection:button({
    Name = "Rejoin Game",
    Callback = function()
        MainWindow:set_status("Rejoining server...")
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

UtilitySection:button({
    Name = "Exploit Creator",
    Callback = function()
        MainWindow:set_status("Loading Exploit Creator...")
        loadstring(game:HttpGet("https://e-vil.com/anbu/rem.lua"))()
    end
})

-- ============================================================================
-- === HUB SETTINGS TAB ===
-- ============================================================================

local SettingsSection = SettingsTab:section({ Name = "Hub Settings" })

print("[ZukaHub -> Mercury] Populating Hub Settings tab...")
SettingsSection:button({
    Name = "Exit Zuka Hub",
    Callback = function()
        -- Mercury's destroy function is accessed via the returned window object.
        MainWindow.core.AbsoluteObject:Destroy()
        getgenv().ZukaLuaHub = nil
        print("Zuka Hub (Mercury) unloaded and cleaned up.")
    end
})

print("We're so back.")