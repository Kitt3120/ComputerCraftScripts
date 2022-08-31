local currentFuel = turtle.getFuelLevel()
local maxFuel = turtle.getFuelLimit()
local fuelPercentage = currentFuel/maxFuel*100
local blockCount = 0
local sentFuelWarning = false
local sentChestWarning = false
local sentInventoryWarning = false

local function Log(level, message)
    print(level..": "..message)
end

local function Info(message)
    Log("Info", message)
end

local function Warning(message)
    Log("Warning", message)
end

local function Error(message)
    Log("Error", message)
end

local function PrintFuelStatus()
    Info("Fuel level at "..fuelPercentage.."% ("..currentFuel.."/"..maxFuel..")")
end

local function PrintMiningStatus()
    Info("Mined "..blockCount.." blocks")
end

local function PrintStatus()
    PrintFuelStatus()
    PrintMiningStatus()
end

local function RefreshFuelValues()
    currentFuel = turtle.getFuelLevel()
    fuelPercentage = currentFuel/maxFuel*100
end

local function Refuel()
    local previousSlot = turtle.getSelectedSlot()
    turtle.select(16)
    local result = turtle.refuel()
    turtle.select(previousSlot)
    return result
end

local function InventoryFull()
    local count = turtle.getItemCount(15)
    if count == 0 then
        return false
    else
        return turtle.getItemSpace(15) == 0
    end
end

local function TransferAllItems()
    local previousSlot = turtle.getSelectedSlot()
    for i=1,15 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            if turtle.dropDown() == false then
                turtle.select(previousSlot)
                return false
            end
        end
    end
    turtle.select(previousSlot)
    return true
end

PrintFuelStatus()
while true do
    -- Refuel
    if Refuel() then
        Info("Refueled from inventory")
        RefreshFuelValues()
        PrintFuelStatus()
    else
        RefreshFuelValues()
    end

    -- Transmit items to external inventory
    if TransferAllItems() == false then
        if sentChestWarning == false then
            Warning("External inventory has ran out of space, internal inventory will fill up soon!")
            sentChestWarning = true
        end
    else
        sentChestWarning = false
    end

    -- Mining logic
    if currentFuel > 0 then
        sentFuelWarning = false
        if InventoryFull() == false then
            sentInventoryWarning = false
            if turtle.detect() then
                turtle.dig()
                blockCount = blockCount + 1
                if blockCount % 250 == 0 then
                    PrintStatus()
                end
            else
                os.sleep(1)
            end
        else
            if sentInventoryWarning == false then
                Error("No inventory space available - Mining stopped")
                sentInventoryWarning = true
            end
            os.sleep(10)
        end
    else
        if sentFuelWarning == false then
            Error("No fuel available - Mining stopped")
            Info("Fuel can be provided through slot 16 of the internal inventory")
            sentFuelWarning = true
        end
        os.sleep(10)
    end
end