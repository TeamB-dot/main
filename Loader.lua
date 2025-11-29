-- BlackAir Loader (Stable, 1x Execution Only)
if getgenv().BlackAir_Running then return end
getgenv().BlackAir_Running = true

local BASE = "https://raw.githubusercontent.com/TeamB-dot/main/refs/heads/main/modules/"

local function LoadModule(name)
    local url = BASE .. name .. ".lua"
    local src = game:HttpGet(url)
    return loadstring(src)()
end

-- queue_on_teleport Patch (100% Safe)
do
    local payload = "if not getgenv().BlackAir_Running then getgenv().BlackAir_Running=true; loadstring(game:HttpGet('" ..
        "https://raw.githubusercontent.com/TeamB-dot/main/refs/heads/main/loader.lua" ..
    "'))() end"

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

-- Init UI
ui.init(config, core, runtime)

-- AutoExec
if config.AutoExec then
    runtime.StartAutoFarm()
end
