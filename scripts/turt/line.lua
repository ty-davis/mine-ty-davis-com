local fuel = require("turt.fuel")
local dig = require("turt.dig")

local mod = {}

function mod.line(len, height)
    height = height or 3
    if height >= 2 then
       if not dig.digd() then
           return false
       end 
    elseif height >= 3 then
       if not dig.digu() then
           return false
       end
    end
    for i = 1, len do
        -- dig forward, then move and
        -- dig up and down
        fuel.checknfuel()
        if not dig.digf() then
            return false
        end
        turtle.forward()
        if height >= 2 then
            if not dig.digd() then
                return false
            end
        end
        if height >= 3 then
            if not dig.digu() then
                return false
            end
        end
    end
    return true
end

return mod
