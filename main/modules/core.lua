-- core.lua
local core = {}

local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local BridgeNet = Rep:WaitForChild("BridgeNet2")
local id = BridgeNet:WaitForChild("identifierStorage")

local function debug(m) print("[BlackAir] "..m) end

-- CAR SYSTEM
function core.findCar()
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

    for _, v in ipairs(workspace.Vehicles:GetChildren()) do
        if v.Name ~= "Orange" then
            local f = v:FindFirstChild("InfoFolder")
            if f then
                local owner = f:FindFirstChild("Owner")
                if owner and owner.Value and tostring(owner.Value):lower() == player.Name:lower() then
                    return v
                end
            end
        end
    end
end

function core.unlock(car)
    local Remote = Rep.Client.Communication.LockVehicle
    pcall(function()
        Remote:InvokeServer(car,false)
    end)
end

function core.enter(car)
    local seat = car:FindFirstChild("Seats") and car.Seats:FindFirstChild("Seat1")
    if not seat then return end
    local byte = id:GetAttribute("RemoteEvent_OnSitVehicleSeat")
    local args = {
        {
            {KevArgs={car,seat}},
            byte
        }
    }
    BridgeNet.dataRemoteEvent:FireServer(unpack(args))
end

function core.exit(pos)
    local byte = id:GetAttribute("RemoteEvent_VehicleInteraction")
    local args = {
        {
            {KevArgs={6}},
            byte
        }
    }
    BridgeNet.dataRemoteEvent:FireServer(unpack(args))

    if pos then
        task.delay(1, function()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = CFrame.new(pos) end
        end)
    end
end

function core.carTP(car,pos)
    for _,p in ipairs(car:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored=true end
    end
    car:PivotTo(CFrame.new(pos+Vector3.new(0,300,0)))
    task.wait(0.2)
    car:PivotTo(CFrame.new(pos))
    for _,p in ipairs(car:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored=false end
    end
end

function core.carInFront(car)
    local root = player.Character:WaitForChild("HumanoidRootPart")
    local pos = root.Position + root.CFrame.LookVector*5
    for _,p in ipairs(car:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored=true end
    end
    car:PivotTo(CFrame.new(pos))
    task.wait(0.1)
    for _,p in ipairs(car:GetDescendants()) do
        if p:IsA("BasePart") then p.Anchored=false end
    end
end

-- ATM / CASH
function core.renameATMs()
    local folder = workspace.Map.Shop_Rob.InkasseBank
    local n=0
    for _,atm in ipairs(folder:GetChildren()) do
        if atm:IsA("Model") and atm:FindFirstChild("Main") then
            n+=1
            atm.Name="ATM"..n
        end
    end
    return n
end

function core.atmBroken()
    local folder = workspace.Map.Shop_Rob.InkasseBank
    local total,broken=0,0
    for _,atm in ipairs(folder:GetChildren()) do
        if atm:IsA("Model") and atm:FindFirstChild("Main") then
            total+=1
            if atm:GetAttribute("Destroyed") then broken+=1 end
        end
    end
    return total>0 and total==broken
end

function core.destroyATM(count)
    local byte=id:GetAttribute("RemoteEvent_OnMellee")
    for i=1,count do
        local atm=workspace.Map.Shop_Rob.InkasseBank["ATM"..i]
        if atm then
            local args={{ {KevArgs={{{HitType=3,Model=atm,Hit=atm.Main}},3}} , byte}}
            BridgeNet.dataRemoteEvent:FireServer(unpack(args))
            task.wait(0.4)
        end
    end
end

function core.collect()
    local root = player.Character:WaitForChild("HumanoidRootPart")
    local folder = workspace.Ignore
    for _,part in ipairs(folder:GetDescendants()) do
        if part:IsA("MeshPart") and (part.Position-root.Position).Magnitude<45 then
            local prompt=part:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                prompt.HoldDuration=0
                part.CFrame=CFrame.new(root.Position-Vector3.new(0,2,0))
                for i=1,60 do fireproximityprompt(prompt) end
            end
        end
    end
end

-- TANKS
function core.robTank(info,car)
    core.carTP(car,info.carTP)
    task.wait(1)

    local tank = workspace.Map.Shop_Rob:FindFirstChild(info.name)
    if not tank then return end
    local dummy = tank:FindFirstChild("Dummy")
    if not dummy then return end

    if dummy:GetAttribute("IsBedroht") then return end

    core.exit(info.playerTP)
    task.wait(1)

    local remote = dummy:FindFirstChild("OnRob")
    if not remote then return end

    local t=os.clock()+10
    while not dummy:GetAttribute("IsBedroht") and os.clock()<t do
        remote:FireServer()
        task.wait(0.2)
    end

    if dummy:GetAttribute("IsBedroht") then
        task.wait(1)
        core.collect()
    end
end

return core
