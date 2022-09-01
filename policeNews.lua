local news = "Die Polizeistation ist Aufgrund von Umbaubarbeiten derzeit geschlossen."
local speed = 6
local textScaling = 2
local backgroundColor = colors.black
local foregroundColor = colors.white

local mon = peripheral.find("monitor")
local sizeX, sizeY = mon.getSize()
sizeX = sizeX/textScaling
sizeY = sizeY/textScaling
local newsLength = string.len(news)

local subFrom = 1
local subLength = 1
local offset = sizeX

local function ShiftLeft()
    if offset > 1 then
        offset = offset - 1
        if subLength < newsLength then
            subLength = subLength + 1
        end
    else
        subFrom = subFrom + 1
        if subLength < newsLength then
            subLength = subLength + 1
        end
        if subFrom > subLength+1 then
            subFrom = 1
            subLength = 1
            offset = sizeX
        end
    end
end

mon.setBackgroundColor(backgroundColor)
mon.setTextColor(foregroundColor)
mon.setTextScale(textScaling)
while true do
    mon.clear()
    mon.setCursorPos(offset, sizeY/2)
    mon.write(string.sub(news, subFrom, subLength))

    ShiftLeft()

    os.sleep(1/speed)
end