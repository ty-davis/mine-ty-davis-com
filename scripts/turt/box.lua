local fuel = require("turt.fuel")
local dig = require("turt.dig")
local line = require("turt.line")

local mod = {}

-- these functions assume that you
-- have placed the turtle at the
-- top, left, close corner.
-- He will go:
--   forward * l
--   right * w
--   down * h

function mod.get_heights(h)
    local hi = 0
    local result = {}
    while h > 3 do
        table.insert(result, hi * 3 + 2)
        h = h - 3
        hi = hi + 1
    end
    if h then
        table.insert(result, math.ceil(h / 2) + hi * 3)
    end
    return result
end

function mod.fullbox(length, width, height)
    local y = 1
    local hs = mod.get_heights(height)
    print("digging at heights: ", hs)
    
    for k,h in pairs(hs) do
        -- should be facing the same dir as start
        while y ~= h do
            dig.digd()
            turtle.down()
            y = y + 1
        end
        local line_h = 3
        if k == #hs then
            if h == height then
                line_h = 1
            elseif height % 3 == 0 then
                line_h = 3
            else
                line_h = 2
            end
        end
        print("LINE_H: ", line_h)
        local w = 1
        while w <= width do
            line.line(length-1, line_h)
            w = w + 1
            if w > width then
            -- turn around now
                turtle.turnRight()
                turtle.turnRight()
                fuel.checknfuel(length+5)
                for i = 1, length-1 do
                    turtle.forward()
                end
                fuel.checknfuel(width+2)
                turtle.turnRight()
                for i = 1, width-1 do
                    turtle.forward()
                end
                turtle.turnRight()
            else
                turtle.turnRight()
                line.line(1, line_h)
                turtle.turnRight()
                line.line(length-1, line_h)
                w = w + 1
                if w > width then
                    fuel.checknfuel(width+3)
                    turtle.turnRight()
                    for i = 1, width-1 do
                        turtle.forward()
                    end
                    turtle.turnRight()
                else
                    fuel.checknfuel()
                    turtle.turnLeft()
                    line.line(1, line_h)
                    turtle.turnLeft()
                end
            end
        end
    end
    while y > 1 do
        y = y - 1
        fuel.checknfuel()
        turtle.up()
    end    
end

return mod
