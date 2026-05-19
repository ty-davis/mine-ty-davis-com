local fuel = require("turt.fuel")
local line = require("turt.line")
local dig = require("turt.dig")

local mod = {}

function mod.stair(dir, amt)
    dir = dir or "down"
    if dir ~= "down" and dir ~= "up" then
        print("Invalid direction for staircase")
        exit()
    end
    amt = amt or 512
    
    local i = 0
    while i < amt do
        local result = line.line(1)
        if dir == "down" then
            result = turtle.down()
        else
            result = turtle.up()
        end
        
        if not result then
            break
        end
        i = i + 1
    end
    
    -- need to come back now
    turtle.turnLeft()
    turtle.turnLeft()
    while i > 0 do
        fuel.checknfuel()
        turtle.forward()
        if dir == "down" then
            turtle.up()
        else
            turtle.down()
        end
        i = i - 1
    end    
    turtle.turnRight()
    turtle.turnRight()
end

return mod
