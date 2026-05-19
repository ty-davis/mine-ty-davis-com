local dig = require("turt.dig")
local fuel = require("turt.fuel")
local item = require("turt.item")

local mod = {}

function inspectud(ceil)
    local isblock, block
    if ceil then
        isblock, block = turtle.inspectUp()
    else
        isblock, block = turtle.inspectDown()
    end
    return isblock, block
end

function dignplace(block, ceil)
    if ceil then
        dig.digu()
        item.placeu(block)
    else
        dig.digd()
        item.placed(block)
    end
end


function mod.floor(length, width, ceil, block)
    ceil = ceil or false
    if not block then
        local isblock, blockd = inspectud(ceil)
        if isblock then
            block = blockd.name
        else
            print("No block specified, nor at turtle. Exiting...")
            return False
        end
    else
        dignplace(block, ceil)
    end
    local w = 1
    while w <= width do
        for i=2, length do
            fuel.checknfuel()
            turtle.forward()
            dignplace(block, ceil)
        end
        w = w + 1
        if w > width then
            -- turn around right here
            turtle.turnRight()
            turtle.turnRight()
            fuel.checknfuel(length+2)
            for i = 2, length do
                turtle.forward()
            end
            fuel.checknfuel(width+2)
            turtle.turnRight()
            for i = 2, width do
                turtle.forward()
            end
            turtle.turnRight()
        else
            turtle.turnRight()
            turtle.forward()
            dignplace(block, ceil)
            turtle.turnRight()
            for i=1, length-1 do
                turtle.forward()
                dignplace(block, ceil)
            end
            w = w + 1
            if w > width then
                fuel.checknfuel(width+2)
                turtle.turnRight()
                for i = 2, width do
                    turtle.forward()
                end
                turtle.turnRight()
            else
                fuel.checknfuel(length+2)
                turtle.turnLeft()
                turtle.forward()
                dignplace(block, ceil)
                turtle.turnLeft()
            end
        end
    end
end

return mod
