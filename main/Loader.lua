-- Robust Loader mit Debug & zuverlässigem AutoExec
if getgenv().BlackAir_Running then return end
getgenv().BlackAir_Running = true

local BASE = "https://raw.githubusercontent.com/TeamB-dot/main/refs/heads/main/main/modules/"

local function LoadModule(name)
    local url = BASE .. name .. ".lua"
    local src = game:HttpGet(url)
    return loadstring(src)()
end

-- queue_on_teleport Patch (100% Safe)
do
    local payload = "if not getgenv().BlackAir_Running then getgenv().BlackAir_Running=true; loadstring(game:HttpGet('https://raw.githubusercontent.com/TeamB-dot/main/refs/heads/main/main/loader.lua'))() end"

    if syn and syn.queue_on_teleport then
        syn.queue_on_teleport(payload)
    elseif queue_on_teleport then
        queue_on_teleport(payload)
    end
end

-- Load Modules
local config   = LoadModule("config")
local core     = LoadModule("core")
local ui       = LoadModule("ui")
local runtime  = LoadModule("runtime")

-- Debug: Sichtbar machen, was geladen wurde
print("[BlackAir] Modules loaded:",
      "config.AutoExec=", tostring(config and config.AutoExec),
      "core=", tostring(core~=nil),
      "ui=", tostring(ui~=nil),
      "runtime=", tostring(runtime~=nil))

-- INIT RUNTIME (WICHTIG!)
runtime.init(config, core, ui)

-- Init UI
ui.init(config, core, runtime)

-- Helper: warte bis Spieler & Spiel-Objekte ready sind
local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function waitForGameReady(timeout)
    timeout = timeout or 10
    local t0 = tick()
    -- warte auf Character + HumanoidRootPart
    while tick()-t0 < timeout do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then break end
        task.wait(0.2)
    end
    -- warte auf vehicles im workspace (mindestens ein Kind oder 1 Sekunde)
    t0 = tick()
    while tick()-t0 < timeout do
        if workspace:FindFirstChild("Vehicles") and #workspace.Vehicles:GetChildren() > 0 then break end
        task.wait(0.25)
    end
end

-- AutoExec: robust starten
if config and config.AutoExec then
    print("[BlackAir] AutoExec is enabled — preparing to start AutoFarm")
    task.spawn(function()
        -- leichte Verzögerung, damit alles initialisiert ist
        waitForGameReady(8)

        -- nochmal debug bevor Start
        print("[BlackAir] Starting AutoFarm: checking core & runtime")
        print("[BlackAir] core:", core)
        if not core then
            warn("[BlackAir] core is nil — runtime.init() might not have been called correctly")
            return
        end

        -- Starte AutoFarm in pcall, damit Fehler geloggt werden
        local ok,err = pcall(function()
            runtime.StartAutoFarm()
        end)
        if not ok then
            warn("[BlackAir] StartAutoFarm failed:", err)
        else
            print("[BlackAir] StartAutoFarm called successfully")
        end
    end)
else
    print("[BlackAir] AutoExec disabled in config")
end
