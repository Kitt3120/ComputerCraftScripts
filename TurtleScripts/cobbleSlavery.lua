-- This script is meant to be used with a stationed Mining Turtle in combination with a cobblestone generator and a chest underneath the Mining Turtle to farm cobblestone

local version = 0.4

local currentFuel = turtle.getFuelLevel()
local maxFuel = turtle.getFuelLimit()
local currentFuelPercentage  = currentFuel/maxFuel*100
local blockCount = 0
local sizeX, sizeY = term.getSize()
local notificationsBuffer = "None"

local function PrintBanner()
    print("  ____      _     _     _")
    print(" / ___|___ | |__ | |__ | | ___")
    print("| |   / _ \\| \'_ \\| \'_ \\| |/ _ \\")
    print("| |__| (_) | |_) | |_) | |  __/")
    print(" \\____\\___/|_.__/|_.__/|_|\\___|")
 
    print(" ____  _")
    print("/ ___|| | __ ___   _____ _ __ _   _")
    print("\\___ \\| |/ _` \\ \\ / / _ \\ \'__| | | |")
    print(" ___) | | (_| |\\ V /  __/ |  | |_| |")
    print("|____/|_|\\__,_| \\_/ \\___|_|   \\__, |")
    print("                              |___/")

    print("v"..version.." by Torben Schweren")
    write("https://github.com/Kitt3120")
end

local function WriteToNotificationsBuffer(text)
    if notificationsBuffer == "None" then
        notificationsBuffer = text
    else
        notificationsBuffer = notificationsBuffer..text
    end
end

local function PrintToNotificationsBuffer(text)
    WriteToNotificationsBuffer(text.."\n")
end

local function Log(level, message)
    PrintToNotificationsBuffer(level..": "..message)
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

local function PrintStatus()
    PrintFuelStatus()
    PrintMiningStatus()
end

local function Refuel()
    local previousSlot = turtle.getSelectedSlot()
    turtle.select(16)
    local result = turtle.refuel()
    turtle.select(previousSlot)
    return result
end

local function RefreshFuelValues()
    currentFuel = turtle.getFuelLevel()
    currentFuelPercentage  = currentFuel/maxFuel*100
end

local function IsInventoryFull()
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

local function WriteFuelBar()
    write("[")
    local fuelSteps = currentFuelPercentage/5
    for i=1,fuelSteps do
        write("=")
    end
    local missingSteps = 20-fuelSteps
    for i=1,missingSteps do
        write(" ")
    end
    write("]")
end

local function PrintScreen()
    term.clear()
    term.setCursorPos(1, 1)
    print("CobbleSlavery v"..version.." by Kitt3120")

    term.setCursorPos(1, sizeY/2 - 2)
    print("Notifications:")
    print(notificationsBuffer)

    term.setCursorPos(1, sizeY-1)
    write("Blocks mined: "..blockCount)

    term.setCursorPos(1, sizeY)
    write("Fuel ")
    WriteFuelBar()
    write(" "..currentFuelPercentage.."%")

    notificationsBuffer = "None"
end





-- Start
term.clear()
PrintBanner()
os.sleep(3)
for i=1,13 do
    print("")
    os.sleep(0.05)
end

-- Loop
while true do
    -- Refuel
    RefreshFuelValues()
    if currentFuel < maxFuel and Refuel() then
        RefreshFuelValues()
        Info("Refueled from inventory")
    end

    -- Transmit items to external inventory
    if TransferAllItems() == false then
        Warning("External inventory has ran out of space, internal inventory will fill up soon!")
    end

    -- Mining logic
    if currentFuel > 0 then
        if IsInventoryFull() == false then
            if turtle.detect() then
                turtle.dig()
                blockCount = blockCount + 1
            end
        else
            Error("No inventory space available - Mining stopped")
        end
    else
        Error("No fuel available - Mining stopped")
        Info("Fuel can be provided through slot 16 of the internal inventory")
    end

    PrintScreen()
    os.sleep(1)
end