local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local CurrentPowerVal = ReplicatedStorage:FindFirstChild("CurrentPower")
local PowerActiveVal = ReplicatedStorage:FindFirstChild("PowerActive")

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/unitedlarpsofamerica/FleeTheFacility/refs/heads/main/Library.lua"))()
library.title = "stalker.cc"

local Notifier = library:InitNotifications()
local Window = library:Init(Enum.KeyCode.LeftAlt)

local Config = {
    NoHackFailed = false,
    AutoHackComputer = false,
    AutoHackRange = 14,
    AutoRescue = false,
    AutoDoors = false,
    AutoExits = false,
    AutoInteractRange = 12,
    AdminJoinAlert = false,
    BeastPowerAlerts = false,
    HitAura = false,
    AutoTie = false,
    HitAuraRange = 10,
    AutoTieRange = 5,
    ChamsEnabled = false,
    ChamsOutline = false,
    BeastChams = false,
    SurvivorChams = false,
    ComputerChams = false,
    PodChams = false,
    ExitChams = false,
    BeastChamsColor = Color3.fromRGB(255, 45, 60),
    SurvivorChamsColor = Color3.fromRGB(0, 230, 255),
    ComputerChamsColor = Color3.fromRGB(0, 140, 255),
    PodChamsColor = Color3.fromRGB(150, 220, 255),
    ExitChamsColor = Color3.fromRGB(255, 215, 0),
    InactivePlayerColor = Color3.fromRGB(130, 130, 140),
    ESPEnabled = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPDistance = false,
    ComputerESP = false,
    PodESP = false,
    ExitESP = false,
    BeastArrows = false,
    BeastArrowColor = Color3.fromRGB(255, 45, 60),
    Fullbright = false,
    NoFog = false,
    Fly = false,
    FlySpeed = 50,
    TPWalk = false,
    TPWalkSpeed = 2.5,
    Noclip = false,
    CrawlBoost = false,
    CrawlBoostSpeed = 20,
    WalkSpeed = false,
    WalkSpeedValue = 24,
    JumpPower = false,
    JumpPowerValue = 65,
    InfJump = false,
    AutoFixJump = true,
    AntiRagdoll = false,
    AntiFling = false,
}

RunService.Stepped:Connect(function()
    if Config.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)


local CONFIG_DIR = "StalkerConfigs"
local AUTOLOAD_FILE = CONFIG_DIR .. "/autoload.txt"
local CurrentConfigName = "default"
local SelectedConfigName = "default"
local NewConfigName = "default"
local UI_Toggles = {}
local UI_Colorpickers = {}
local UI_Sliders = {}
local ConfigDropdown = nil
local AutoloadToggle = nil
local ToggleKeybind = nil

local function CleanConfigName(path)
    if not path or path == "" then return "" end
    local s = tostring(path)
    s = s:gsub(string.char(92), "/")
    s = s:gsub("%.json$", "")
    s = s:gsub(".*/", "")
    return s
end

local function GetConfigList()
    local list = {}
    local seen = {}
    if listfiles and isfolder and isfolder(CONFIG_DIR) then
        pcall(function()
            for _, path in ipairs(listfiles(CONFIG_DIR)) do
                if path:sub(-5) == ".json" then
                    local name = CleanConfigName(path)
                    if name ~= "" and name ~= "configs_index" and name ~= "autoload" and not seen[name] then
                        seen[name] = true
                        table.insert(list, name)
                    end
                end
            end
        end)
    end
    if not seen["default"] and isfile and isfile(CONFIG_DIR .. "/default.json") then
        seen["default"] = true
        table.insert(list, "default")
    end
    if #list == 0 then
        table.insert(list, "default")
    end
    table.sort(list)
    return list
end

local function SaveConfigNamed(cfgName)
    local cleanName = CleanConfigName(cfgName)
    if cleanName == "" then cleanName = "default" end
    if makefolder and not isfolder(CONFIG_DIR) then
        pcall(function() makefolder(CONFIG_DIR) end)
    end
    local data = {}
    for k, v in pairs(Config) do
        if typeof(v) == "Color3" then
            data[k] = {__col = true, R = v.R, G = v.G, B = v.B}
        else
            data[k] = v
        end
    end
    if library and library.ToggleKey then
        data.__ToggleKey = tostring(library.ToggleKey.Name or library.ToggleKey)
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok and encoded then
        local filePath = CONFIG_DIR .. "/" .. cleanName .. ".json"
        local success, err = pcall(function() writefile(filePath, encoded) end)
        if success then
            SelectedConfigName = cleanName
            CurrentConfigName = cleanName
            local list = GetConfigList()
            if ConfigDropdown then
                pcall(function()
                    if ConfigDropdown.Refresh then
                        ConfigDropdown:Refresh(list)
                    elseif ConfigDropdown.UpdateOptions then
                        ConfigDropdown:UpdateOptions(list)
                    end
                    ConfigDropdown:Set(cleanName)
                end)
            end
            if Notifier then Notifier:Notify("Config '" .. cleanName .. "' Saved!", 2) end
        else
            if Notifier then Notifier:Notify("Save failed: " .. tostring(err), 3) end
        end
    else
        if Notifier then Notifier:Notify("Failed to encode config!", 2) end
    end
end

local function LoadConfigNamed(cfgName)
    local cleanName = CleanConfigName(cfgName)
    if cleanName == "" then cleanName = "default" end
    local filePath = CONFIG_DIR .. "/" .. cleanName .. ".json"
    if not isfile or not isfile(filePath) then
        if Notifier then Notifier:Notify("Config '" .. cleanName .. "' not found!", 2) end
        return
    end
    local ok, content = pcall(readfile, filePath)
    if not ok or not content then
        if Notifier then Notifier:Notify("Failed to read config!", 2) end
        return
    end
    local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(content) end)
    if not decodeSuccess or type(decoded) ~= "table" then
        if Notifier then Notifier:Notify("Failed to parse config file!", 2) end
        return
    end
    for k, v in pairs(decoded) do
        if k == "__ToggleKey" then
            if Enum.KeyCode[v] then
                library.ToggleKey = Enum.KeyCode[v]
                if ToggleKeybind then
                    pcall(function()
                        if ToggleKeybind.SetKey then
                            ToggleKeybind:SetKey(Enum.KeyCode[v])
                        elseif ToggleKeybind.Set then
                            ToggleKeybind:Set(Enum.KeyCode[v])
                        end
                    end)
                end
            end
        elseif Config[k] ~= nil then
            if type(v) == "table" and v.__col then
                Config[k] = Color3.new(v.R, v.G, v.B)
                if UI_Colorpickers[k] and UI_Colorpickers[k].Set then
                    pcall(function() UI_Colorpickers[k]:Set(Config[k]) end)
                end
            else
                Config[k] = v
                if UI_Toggles[k] and UI_Toggles[k].Set then
                    pcall(function() UI_Toggles[k]:Set(v) end)
                elseif UI_Sliders[k] and (UI_Sliders[k].Set or UI_Sliders[k].Value) then
                    pcall(function()
                        if UI_Sliders[k].Set then
                            UI_Sliders[k]:Set(v)
                        elseif UI_Sliders[k].Value then
                            UI_Sliders[k]:Value(v)
                        end
                    end)
                end
            end
        end
    end
    SelectedConfigName = cleanName
    CurrentConfigName = cleanName
    if ConfigDropdown then
        pcall(function() ConfigDropdown:Set(cleanName) end)
    end
    if Notifier then Notifier:Notify("Config '" .. cleanName .. "' Loaded!", 2) end
end

local function DeleteConfigNamed(cfgName)
    local cleanName = CleanConfigName(cfgName)
    if cleanName == "" then cleanName = "default" end
    local filePath = CONFIG_DIR .. "/" .. cleanName .. ".json"
    if isfile and isfile(filePath) then
        pcall(function() delfile(filePath) end)
        local list = GetConfigList()
        if ConfigDropdown then
            pcall(function()
                if ConfigDropdown.Refresh then
                    ConfigDropdown:Refresh(list)
                elseif ConfigDropdown.UpdateOptions then
                    ConfigDropdown:UpdateOptions(list)
                end
            end)
            if #list > 0 then
                pcall(function() ConfigDropdown:Set(list[1]) end)
                SelectedConfigName = list[1]
                CurrentConfigName = list[1]
            end
        end
        if Notifier then Notifier:Notify("Deleted config '" .. cleanName .. "'", 2) end
    else
        if Notifier then Notifier:Notify("Config file not found to delete!", 2) end
    end
end

local function SetAutoload(enabled)
    if enabled then
        local chosen = CleanConfigName(SelectedConfigName or CurrentConfigName or "default")
        if chosen == "" then chosen = "default" end
        if makefolder and not isfolder(CONFIG_DIR) then
            pcall(function() makefolder(CONFIG_DIR) end)
        end
        pcall(function() writefile(AUTOLOAD_FILE, chosen) end)
        if Notifier then Notifier:Notify("Autoload set to '" .. chosen .. "'", 2) end
    else
        if isfile and isfile(AUTOLOAD_FILE) then
            pcall(function() delfile(AUTOLOAD_FILE) end)
        end
        if Notifier then Notifier:Notify("Autoload disabled", 2) end
    end
end

local saveConfig = SaveConfigNamed
local loadConfig = LoadConfigNamed
local deleteConfig = DeleteConfigNamed
local getSavedConfigsList = GetConfigList

local OriginalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    ClockTime = Lighting.ClockTime,
}

local OriginalAtmosphere = {
    Density = 0.85,
    Haze = 2.46,
    Glare = 1.64,
}
local initAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if initAtmosphere then
    OriginalAtmosphere.Density = initAtmosphere.Density
    OriginalAtmosphere.Haze = initAtmosphere.Haze
    OriginalAtmosphere.Glare = initAtmosphere.Glare
end

local function applyNoFog(enabled)
    pcall(function()
        local at = Lighting:FindFirstChildOfClass("Atmosphere")
        if enabled then
            if at then
                at.Density = 0
                at.Haze = 0
                at.Glare = 0
            end
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            if Lighting.Brightness == 0 then
                Lighting.Brightness = 1
            end
        else
            if at then
                at.Density = OriginalAtmosphere.Density
                at.Haze = OriginalAtmosphere.Haze
                at.Glare = OriginalAtmosphere.Glare
            end
            if not Config.Fullbright then
                Lighting.FogEnd = OriginalLighting.FogEnd
                Lighting.FogStart = OriginalLighting.FogStart
                Lighting.Brightness = OriginalLighting.Brightness
            end
        end
    end)
end

local function setupAtmosphereListener(at)
    if not at or not at:IsA("Atmosphere") then return end
    if not Config.NoFog then
        OriginalAtmosphere.Density = at.Density
        OriginalAtmosphere.Haze = at.Haze
        OriginalAtmosphere.Glare = at.Glare
    end
    at:GetPropertyChangedSignal("Density"):Connect(function()
        if Config.NoFog and at.Density > 0 then
            at.Density = 0
        end
    end)
    at:GetPropertyChangedSignal("Haze"):Connect(function()
        if Config.NoFog and at.Haze > 0 then
            at.Haze = 0
        end
    end)
    at:GetPropertyChangedSignal("Glare"):Connect(function()
        if Config.NoFog and at.Glare > 0 then
            at.Glare = 0
        end
    end)
end

if initAtmosphere then
    setupAtmosphereListener(initAtmosphere)
end

Lighting.ChildAdded:Connect(function(child)
    if child:IsA("Atmosphere") then
        setupAtmosphereListener(child)
        if Config.NoFog then
            child.Density = 0
            child.Haze = 0
            child.Glare = 0
        end
    end
end)

Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
    if Config.NoFog and Lighting.Brightness == 0 then
        Lighting.Brightness = (Config.Fullbright and 2) or OriginalLighting.Brightness or 1
    end
end)

Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
    if Config.NoFog and Lighting.FogEnd < 100000 then
        Lighting.FogEnd = 100000
    end
end)

local CachedComputers = {}
local CachedPods = {}
local CachedExits = {}
local CachedDoors = {}
local CachedLockers = {}
local DoorCooldowns = {}
local ComputerESP = {}
local PodESP = {}
local ExitESP = {}
local CurrentMapInstance = nil

local function updateMapCache()
    local map = ReplicatedStorage:FindFirstChild("CurrentMap") and ReplicatedStorage.CurrentMap.Value
    if not map then
        for _, c in ipairs(Workspace:GetChildren()) do
            if (c:IsA("Folder") or c:IsA("Model")) and c.Name ~= "LobbyInteractiveObjects" and c.Name ~= "Terrain" then
                if c:FindFirstChild("ComputerTable", true) or c:FindFirstChild("ExitDoor", true) or c:FindFirstChild("FreezePod", true) then
                    map = c
                    break
                end
            end
        end
    end
    CurrentMapInstance = map
    table.clear(CachedComputers)
    table.clear(CachedPods)
    table.clear(CachedExits)
    table.clear(CachedDoors)
    table.clear(CachedLockers)
    table.clear(DoorCooldowns)

    for comp, textObj in pairs(ComputerESP) do
        if not comp or not comp.Parent or not comp:IsDescendantOf(Workspace) then
            pcall(function() textObj:Destroy() end)
            ComputerESP[comp] = nil
        else
            textObj.Visible = false
        end
    end
    for pod, textObj in pairs(PodESP) do
        if not pod or not pod.Parent or not pod:IsDescendantOf(Workspace) then
            pcall(function() textObj:Destroy() end)
            PodESP[pod] = nil
        else
            textObj.Visible = false
        end
    end
    for exit, textObj in pairs(ExitESP) do
        if not exit or not exit.Parent or not exit:IsDescendantOf(Workspace) then
            pcall(function() textObj:Destroy() end)
            ExitESP[exit] = nil
        else
            textObj.Visible = false
        end
    end
    if map then
        for _, desc in ipairs(map:GetDescendants()) do
            if desc.Name == "ComputerTable" then
                table.insert(CachedComputers, desc)
            elseif desc.Name == "FreezePod" then
                table.insert(CachedPods, desc)
            elseif desc.Name == "ExitDoor" then
                table.insert(CachedExits, desc)
            elseif desc.Name == "SingleDoor" or desc.Name == "DoubleDoor" then
                table.insert(CachedDoors, desc)
            elseif desc.Name == "Locker" and desc:IsA("Model") then
                table.insert(CachedLockers, desc)
            end
        end
    end
    if #CachedExits == 0 then
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc.Name == "ExitDoor" then
                table.insert(CachedExits, desc)
            end
        end
    end
end

task.spawn(function()
    while true do
        updateMapCache()
        task.wait(2)
    end
end)

local TPSModule = nil
pcall(function()
    TPSModule = require(LocalPlayer:WaitForChild("TempPlayerStatsModule", 5))
end)

local function getCharacter(player)
    player = player or LocalPlayer
    local char = player and player.Character
    if char and char.Parent and char:IsDescendantOf(Workspace) then
        return char
    end
    return nil
end

local function getHRP(player)
    local char = getCharacter(player)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Parent and hrp:IsDescendantOf(Workspace) then
        return hrp
    end
    return nil
end

local function getHum(player)
    local char = getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isLocalPlayerCrawling()
    local hum = getHum()
    if not hum then return false end
    if hum.HipHeight < -0.5 then
        return true
    end
    local stats = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
    if stats then
        local isCrawlingVal = stats:FindFirstChild("IsCrawling")
        if isCrawlingVal and isCrawlingVal.Value == true then
            return true
        end
    end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        if track.Name == "AnimCrawl" and track.IsPlaying then
            return true
        end
    end
    return false
end

local function isPlayerBeast(player)
    if not player then return false end
    local char = player.Character
    if char and (char:FindFirstChild("Hammer") or char:FindFirstChild("Gemstone") or char:FindFirstChild("BeastPowers")) then
        return true
    end
    local stats = player:FindFirstChild("TempPlayerStatsModule")
    if stats and stats:FindFirstChild("IsBeast") and stats.IsBeast.Value == true then
        return true
    end
    return false
end

local function getPlayerRoundState(p)
    if not p then return "NotInRound" end

    local stats = p:FindFirstChild("TempPlayerStatsModule")
    if stats then
        if stats:FindFirstChild("Escaped") and stats.Escaped.Value == true then
            return "Escaped"
        end
        if not isPlayerBeast(p) and stats:FindFirstChild("Health") and stats.Health.Value <= 0 then
            return "Dead"
        end
    end

    if isPlayerBeast(p) then
        return "Beast"
    end

    local success, sb = pcall(function()
        return require(ReplicatedStorage:FindFirstChild("StatusBarModule"))
    end)
    if success and sb and sb.PlayerCells then
        local cell = sb.PlayerCells[p.Name]
        if cell then
            if cell.Name == "BeastCell" then
                return "Beast"
            end
            local nl = cell:FindFirstChild("NameLabel")
            if nl and nl.TextColor3 == Color3.fromRGB(120, 120, 120) then
                return "Dead"
            elseif nl and nl.TextColor3 == Color3.fromRGB(0, 220, 0) then
                return "Escaped"
            else
                return "Survivor"
            end
        end
    end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local sg = pg and pg:FindFirstChild("ScreenGui")
    local rb = sg and sg:FindFirstChild("RoundBar")
    if rb then
        local ri = rb:FindFirstChild("RoundInfo")
        local bc = ri and ri:FindFirstChild("BeastCell")
        local bnl = bc and bc:FindFirstChild("NameLabel")
        if bnl and bnl.Text == p.Name and bnl.Text ~= "" then
            return "Beast"
        end
        local sbFrame = rb:FindFirstChild("StatusBars")
        if sbFrame then
            for _, cell in ipairs(sbFrame:GetChildren()) do
                if cell.Name:find("SurvivorCell") then
                    local nl = cell:FindFirstChild("NameLabel")
                    if nl and nl.Text == p.Name and nl.Text ~= "" then
                        if nl.TextColor3 == Color3.fromRGB(120, 120, 120) then
                            return "Dead"
                        elseif nl.TextColor3 == Color3.fromRGB(0, 220, 0) then
                            return "Escaped"
                        else
                            return "Survivor"
                        end
                    end
                end
            end
        end
    end

    local currentMap = ReplicatedStorage:FindFirstChild("CurrentMap")
    local isMapLoaded = currentMap and currentMap.Value ~= nil
    local hasAnyRoundPlayer = false
    if success and sb and sb.PlayerCells and next(sb.PlayerCells) ~= nil then
        hasAnyRoundPlayer = true
    elseif rb then
        local ri = rb:FindFirstChild("RoundInfo")
        local bc = ri and ri:FindFirstChild("BeastCell")
        local bnl = bc and bc:FindFirstChild("NameLabel")
        if bnl and bnl.Text ~= "" then
            hasAnyRoundPlayer = true
        end
    end

    if isMapLoaded or hasAnyRoundPlayer then
        return "NotInRound"
    end

    return "Survivor"
end

local function getBeastPlayer()
    for _, p in ipairs(Players:GetPlayers()) do
        if isPlayerBeast(p) or getPlayerRoundState(p) == "Beast" then return p end
    end
    return nil
end

local function isComputerCompleted(comp)
    local screen = comp:FindFirstChild("Screen")
    if not screen then return false end
    return (screen.Color.G > screen.Color.B and screen.Color.G > screen.Color.R) or (screen.BrickColor.Name == "Dark green" or screen.BrickColor.Name == "Forest green")
end

local function isComputerError(comp)
    local screen = comp:FindFirstChild("Screen")
    if not screen then return false end
    return (screen.Color.R > 0.6 and screen.Color.G < 0.3) or (screen.BrickColor.Name == "Bright red" or screen.BrickColor.Name == "Really red")
end

local function isPodOccupied(pod)
    local podPos = pod:GetPivot().Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local stats = p:FindFirstChild("TempPlayerStatsModule")
            if stats and stats:FindFirstChild("Captured") and stats.Captured.Value == true then
                local hrp = getHRP(p)
                if hrp and (hrp.Position - podPos).Magnitude < 12 then
                    return true
                end
            end
        end
    end
    return false
end

local function isExitDoorOpen(exit)
    if not exit then return false end
    local light = exit:FindFirstChild("Light", true) or exit:FindFirstChild("ExitLight", true) or exit:FindFirstChild("DoorLight", true)
    if light and light:IsA("BasePart") then
        local bcName = light.BrickColor.Name:lower()
        if bcName:find("green") or bcName:find("lime") then
            return true
        end
        local col = light.Color
        if col.G > 0.4 and col.G > col.R and (col.G - col.R > 0.08) then
            return true
        end
    end
    for _, desc in ipairs(exit:GetDescendants()) do
        if desc:IsA("Light") and desc.Enabled then
            local col = desc.Color
            if col.G > 0.4 and col.G > col.R then
                return true
            end
        elseif desc:IsA("BasePart") and desc.Name:lower():find("light") then
            local bcName = desc.BrickColor.Name:lower()
            if bcName:find("green") or bcName:find("lime") then
                return true
            end
            if desc.Color.G > 0.4 and desc.Color.G > desc.Color.R and (desc.Color.G - desc.Color.R > 0.08) then
                return true
            end
        end
    end
    return false
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if Config.NoHackFailed and method == "FireServer" and self == RemoteEvent then
        local args = {...}
        if args[1] == "SetPlayerMinigameResult" and args[2] == false then
            return oldNamecall(self, "SetPlayerMinigameResult", true)
        end
    end
    return oldNamecall(self, ...)
end)



local lastHackAction = 0

RunService.Heartbeat:Connect(function()
    if not Config.AutoHackComputer or isPlayerBeast(LocalPlayer) then return end
    local now = os.clock()
    if now - lastHackAction < 0.25 then return end
    lastHackAction = now
    local hrp = getHRP()
    if not hrp then return end
    local list = #CachedComputers > 0 and CachedComputers or {}
    if #list == 0 then
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d.Name == "ComputerTable" then table.insert(list, d) end
        end
    end
    for _, comp in ipairs(list) do
        if comp and comp.Parent and not isComputerCompleted(comp) then
            local screen = comp:FindFirstChild("Screen")
            local screenPos = screen and screen.Position
            for _, ch in ipairs(comp:GetChildren()) do
                if ch.Name:find("ComputerTrigger") and ch:FindFirstChild("Event") then
                    local pPos = screenPos or ch.Position
                    local dist = (pPos - hrp.Position).Magnitude
                    if dist <= Config.AutoHackRange then
                        RemoteEvent:FireServer("Input", "Trigger", true, ch.Event)
                        RemoteEvent:FireServer("Input", "Action", true)
                        return
                    end
                end
            end
        end
    end
end)

local lastAutoInteract = 0

RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastAutoInteract < 0.15 then return end
    lastAutoInteract = now
    local hrp = getHRP()
    if not hrp then return end
    if Config.AutoDoors then
        local doorList = #CachedDoors > 0 and CachedDoors or {}
        if #doorList == 0 then
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d.Name == "SingleDoor" or d.Name == "DoubleDoor" then table.insert(doorList, d) end
            end
        end
        local closestDoor = nil
        local closestTrigger = nil
        local closestDist = Config.AutoInteractRange
        for _, door in ipairs(doorList) do
            if door and door.Parent and (not DoorCooldowns[door] or now >= DoorCooldowns[door]) then
                local trigger = door:FindFirstChild("DoorTrigger", true)
                if trigger and trigger:FindFirstChild("Event") and trigger:FindFirstChild("ActionSign") then
                    if trigger.ActionSign.Value == 10 then
                        local dist = (trigger.Position - hrp.Position).Magnitude
                        if dist <= closestDist then
                            closestDist = dist
                            closestDoor = door
                            closestTrigger = trigger
                        end
                    end
                end
            end
        end
        if closestDoor and closestTrigger then
            DoorCooldowns[closestDoor] = now + 0.6
            RemoteEvent:FireServer("Input", "Trigger", true, closestTrigger.Event)
            RemoteEvent:FireServer("Input", "Action", true)
            task.delay(0.08, function()
                RemoteEvent:FireServer("Input", "Action", false)
            end)
        end
    end
    if Config.AutoExits and not isPlayerBeast(LocalPlayer) then
        local exitList = #CachedExits > 0 and CachedExits or {}
        if #exitList == 0 then
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d.Name == "ExitDoor" then table.insert(exitList, d) end
            end
        end
        for _, exit in ipairs(exitList) do
            if exit and exit.Parent and not isExitDoorOpen(exit) then
                local trigger = exit:FindFirstChild("ExitDoorTrigger", true)
                if trigger and trigger:FindFirstChild("Event") then
                    local as = trigger:FindFirstChild("ActionSign")
                    if as and (as.Value == 12 or as.Value > 0) then
                        local dist = (trigger.Position - hrp.Position).Magnitude
                        if dist <= Config.AutoInteractRange then
                            RemoteEvent:FireServer("Input", "Trigger", true, trigger.Event)
                            RemoteEvent:FireServer("Input", "Action", true)
                            break
                        end
                    end
                end
            end
        end
    end
end)

local function canLocalPlayerRescue()
    if isPlayerBeast(LocalPlayer) then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local stats = LocalPlayer:FindFirstChild("TempPlayerStatsModule")
    if stats then
        local sOk, sMod = pcall(require, stats)
        if sOk and sMod and sMod.GetValue then
            if sMod.GetValue("Health") and sMod.GetValue("Health") <= 0 then return false end
            if sMod.GetValue("Ragdoll") == true then return false end
            if sMod.GetValue("Captured") == true then return false end
        end
    end
    return true
end

local function getPodTrappedPlayer(pod)
    if not pod then return nil end
    local podPos = pod:GetPivot().Position
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local stats = p:FindFirstChild("TempPlayerStatsModule")
            local captured = false
            if stats then
                local capVal = stats:FindFirstChild("Captured")
                if capVal and capVal.Value == true then
                    captured = true
                else
                    local sOk, sMod = pcall(require, stats)
                    if sOk and sMod and sMod.GetValue and sMod.GetValue("Captured") == true then
                        captured = true
                    end
                end
            end
            if captured then
                local hrp = getHRP(p)
                if hrp and (hrp.Position - podPos).Magnitude < 14 then
                    return p
                end
            end
        end
    end
    return nil
end

local lastRescueTime = 0
local RescuedDebounce = {}
local activeRescueVictim = nil
local activeRescuePod = nil

RunService.Heartbeat:Connect(function()
    if not Config.AutoRescue or not canLocalPlayerRescue() then
        activeRescueVictim = nil
        activeRescuePod = nil
        return
    end

    local now = os.clock()
    if now - lastRescueTime < 0.25 then return end
    lastRescueTime = now

    local hrp = getHRP()
    if not hrp then return end

    local targetPod = nil
    local targetTrigger = nil
    local targetVictim = nil

    for _, pod in ipairs(CachedPods) do
        if pod and pod.Parent then
            local trigger = pod:FindFirstChild("PodTrigger", true)
            if trigger and trigger:FindFirstChild("Event") and trigger:FindFirstChild("ActionSign") then
                if trigger.ActionSign.Value == 31 then
                    local p = getPodTrappedPlayer(pod)
                    if p and (not RescuedDebounce[p] or now >= RescuedDebounce[p]) then
                        targetPod = pod
                        targetTrigger = trigger
                        targetVictim = p
                        break
                    end
                end
            end
        end
    end

    if targetPod and targetTrigger and targetVictim then
        activeRescueVictim = targetVictim
        activeRescuePod = targetPod
        RemoteEvent:FireServer("Input", "Trigger", true, targetTrigger.Event)
        RemoteEvent:FireServer("Input", "Action", true)
    else
        if activeRescueVictim and activeRescuePod then
            local victim = activeRescueVictim
            local pod = activeRescuePod
            activeRescueVictim = nil
            activeRescuePod = nil

            local trigger = pod:FindFirstChild("PodTrigger", true)
            local isFree = false
            if trigger and trigger:FindFirstChild("ActionSign") then
                if trigger.ActionSign.Value ~= 31 then
                    isFree = true
                end
            end
            if isFree then
                RescuedDebounce[victim] = now + 3
            end
        end
        RemoteEvent:FireServer("Input", "Action", false)
    end
end)
